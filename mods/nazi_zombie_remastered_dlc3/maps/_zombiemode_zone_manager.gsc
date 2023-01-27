#include common_scripts\utility; 
#include maps\_utility; 


//--------------------------------------------------------------
//  Checks to see if a player is in a zone_name volume
//--------------------------------------------------------------
player_in_zone( zone_name )
{
	// If the zone hasn't been activated, don't even bother checking
	if ( !IsDefined(level.zones[ zone_name ]) )
	{
		return false;
	}
	zone = level.zones[ zone_name ];

	// Okay check to see if a player is in one of the zone volumes
	players = get_players();
	{
		for (i = 0; i < zone.volumes.size; i++)
		{
			for (j = 0; j < players.size; j++)
			{
				if ( players[j] IsTouching(zone.volumes[i]) )
					return true;
			}
		}
	}
	return false;
}


//
//	Disable exterior_goals that have a script_noteworthy.  This can prevent zombies from
//		pathing to a goal that the zombie can't path towards the player after entering.
//	It is assumed these will be activated later, when the zone gets initialized.
deactivate_initial_barrier_goals()
{
	special_goals = getstructarray("exterior_goal", "targetname");
	for (i = 0; i < special_goals.size; i++)
	{
		if (IsDefined(special_goals[i].script_noteworthy))
		{
			special_goals[i].is_active = undefined;
			special_goals[i] trigger_off();
		}
	}
}


//
//	Allows zombies to path to the specified barriers.
//	All barriers with a script_noteworthy should initially triggered off by
//		deactivate_barrier_goals
//
activate_barrier_goals(barrier_name, key)
{
	//  
	entry_points = getstructarray(barrier_name, key);

	for(i=0;i<entry_points.size;i++)
	{
		entry_points[i].is_active = 1;
		entry_points[i] trigger_on();
	}		
}


//--------------------------------------------------------------
//	Call this when you want to allow zombies to spawn from a zone
//	-	Must have at least one info_volume with targetname = (name of the zone)
//	-	Have the info_volumes target the zone's spawners
//--------------------------------------------------------------
zone_init( zone_name )
{
	if ( IsDefined( level.zones[ zone_name ] ) )
	{
		// It's already been activated
		return;
	}

	// Add this to the list of active zones
	level.zones[ zone_name ] = spawnstruct();
	level.zones[ zone_name ].is_enabled = false;	// Does the zone need to be evaluated?
	level.zones[ zone_name ].is_occupied = false;	// Is the zone occupied by a player?
	level.zones[ zone_name ].is_active = false;		// Are the spawners currently enabled for spawning?
	level.zones[ zone_name ].adjacent_zones = [];	// NOTE: These must be defined in a separate level-specific initialization
	level.zones[ zone_name ].volumes = GetEntArray( zone_name, "targetname" );

	//assertEx( IsDefined( level.zones[ zone_name ].volumes[0] ), "zone_init: No volumes found for zone: "+zone_name );	

	if ( IsDefined( level.zones[ zone_name ].volumes[0].target ) )
	{
		// Grab all of the zombie and dog spawners and sort them into two arrays
		level.zones[ zone_name ].spawners = [];
		level.zones[ zone_name ].dog_spawners = [];
		
		spawners = GetEntArray( level.zones[ zone_name ].volumes[0].target, "targetname" );

		for (i = 0; i < spawners.size; i++)
		{
			if ( issubstr(spawners[i].classname, "dog") )
			{
				level.zones[ zone_name ].dog_spawners = add_to_array( level.zones[ zone_name ].dog_spawners, spawners[i] );
			}
			else
			{
				level.zones[ zone_name ].spawners = add_to_array( level.zones[ zone_name ].spawners, spawners[i] );
			}
		}

		level.zones[ zone_name ].dog_locations = GetStructArray(level.zones[ zone_name ].volumes[0].target + "_dog", "targetname");

		// grab all zombie rise locations for the zone
		level.zones[ zone_name ].rise_locations = GetStructArray(level.zones[ zone_name ].volumes[0].target + "_rise", "targetname");
	}
}


//
//	Turn on the zone
enable_zone( zone_name )
{
	level.zones[ zone_name ].is_enabled = true;

	// activate any player spawn points
	spawn_points = getstructarray("player_respawn_point", "targetname");
	for( i = 0; i < spawn_points.size; i++ )
	{
		if ( spawn_points[i].script_noteworthy == zone_name )
		{
			spawn_points[i].locked = false;
		}
	}

	activate_barrier_goals( zone_name+"_barriers", "script_noteworthy" );
}


//
// Makes zone_a connected to zone_b.  If one_way is false, zone_b is also made "adjacent" to zone_a
add_adjacent_zone( zone_name_a, zone_name_b, flag_name, one_way )
{
	if ( !IsDefined( one_way ) )
	{
		one_way = false;
	}

	// If it's not already activated, it will activate the zone
	//	If it's already activated, it won't do anything.
	zone_init( zone_name_a );
	zone_init( zone_name_b );

	// B becomes an adjacent zone of A
	if ( !IsDefined( level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ] ) )
	{
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ] = SpawnStruct();
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].is_connected = false;
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].flags_do_or_check = false;
		if ( IsArray( flag_name ) )
		{
			level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].flags = flag_name;
		}
		else
		{
			level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].flags[0] = flag_name;
		}
	}
	else	
	{
		// we've already defined a link condition, but we need to add another one and treat 
		//	it as an "OR" condition
		assertEx( !IsArray( flag_name ), "add_adjacent_zone: can't mix single and arrays of flags" );	
		size = level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].flags.size;
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].flags[ size ] = flag_name;
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].flags_do_or_check = true;
	}

	if ( !one_way )
	{
		if ( !IsDefined( level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ] ) )
		{
			// A becomes an adjacent zone of B
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ] = SpawnStruct();
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].is_connected = false;
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].flags_do_or_check = false;
			if ( IsArray( flag_name ) )
			{
				level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].flags = flag_name;
			}
			else
			{
				level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].flags[0] = flag_name;
			}
		}
		else	
		{
			// we've already defined a link condition, but we need to add another one and treat 
			//	it as an "OR" condition
			assertEx( !IsArray( flag_name ), "add_adjacent_zone: can't mix single and arrays of flags" );
			size = level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].flags.size;
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].flags[ size ] = flag_name;
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].flags_do_or_check = true;
		}
	}
}


//--------------------------------------------------------------
//	Gathers all flags that need to be evaluated and sets up waits for them
//--------------------------------------------------------------
setup_zone_flag_waits()
{
	flags = [];
	for( z=0; z<level.zones.size; z++ )
	{
		zkeys = GetArrayKeys( level.zones );
		for ( az = 0; az<level.zones[ zkeys[z] ].adjacent_zones.size; az++ )
		{
			azkeys = GetArrayKeys( level.zones[ zkeys[z] ].adjacent_zones );
			for ( f = 0; f< level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags.size; f++ )
			{
				no_dupes = array_check_for_dupes( flags, level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags[f] );
				if( no_dupes )
				{
					flags = add_to_array(flags, level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags[f] );
				}
			}
		}
	}
	for( i=0; i<flags.size; i++ )
	{
		level thread zone_flag_wait( flags[i] );
	}
}


//
//	Wait for a zone flag to be set and then update zones
//
zone_flag_wait( flag_name )
{
	if ( !IsDefined( level.flag[ flag_name ] ) )
	{
		flag_init( flag_name );
	}
	flag_wait( flag_name );

	// Enable adjacent zones if all flags are set for a connection
	for( z=0; z<level.zones.size; z++ )
	{
		zkeys = GetArrayKeys( level.zones );
		for ( az = 0; az<level.zones[ zkeys[z] ].adjacent_zones.size; az++ )
		{
			azkeys = GetArrayKeys( level.zones[ zkeys[z] ].adjacent_zones );

			if ( !level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].is_connected )
			{
				if ( level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags_do_or_check )
				{
					// If ANY flag is set, then connect zones
					flags_set = false;
					for ( f = 0; f< level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags.size; f++ )
					{
						if ( flag( level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags[f] ) )
						{
							flags_set = true;
							break;
						}
					}
					if ( flags_set )
					{
						level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].is_connected = true;
						if ( !level.zones[ azkeys[az] ].is_enabled )
						{
							enable_zone( azkeys[az] );
						}
					}
				}
				else
				{
					// See if ALL the flags have been set, otherwise, move on
					flags_set = true;
					for ( f = 0; f< level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags.size; f++ )
					{
						if ( !flag( level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].flags[f] ) )
						{
							flags_set = false;
						}
					}
					if ( flags_set )
					{
						level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].is_connected = true;
						if ( !level.zones[ azkeys[az] ].is_enabled )
						{
							enable_zone( azkeys[az] );
						}
					}
				}
			}
		}
	}
}


//--------------------------------------------------------------
//	This needs to be called when new zones open up via doors
//--------------------------------------------------------------
connect_zones( zone_name_a, zone_name_b, one_way )
{
	if ( !IsDefined( one_way ) )
	{
		one_way = false;
	}

	// If it's not already activated, it will activate the zone
	//	If it's already activated, it won't do anything.
	zone_init( zone_name_a );
	zone_init( zone_name_b );

	enable_zone( zone_name_a );
	enable_zone( zone_name_b );

	// B becomes an adjacent zone of A
	if ( !IsDefined( level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ] ) )
	{
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ] = SpawnStruct();
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].is_connected = true;
	}

	if ( !one_way )
	{
		// A becomes an adjacent zone of B
		if ( !IsDefined( level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ] ) )
		{
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ] = SpawnStruct();
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].is_connected = true;
		}
	}
}


//--------------------------------------------------------------
//	This one function will handle managing all zones in your map
//	to turn them on/off - probably the best way to handle this
//--------------------------------------------------------------
manage_zones( initial_zone )
{
	assertEx( IsDefined( initial_zone ), "You must specify an initial zone to manage" );	

	deactivate_initial_barrier_goals();	// Must be called before zone_init

	level.zones = [];
	// Setup zone connections
	if ( IsDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}

	if ( IsArray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			zone_init( initial_zone[i] );
			enable_zone( initial_zone[i] );
		}
	}
	else
	{
		zone_init( initial_zone );
		enable_zone( initial_zone );
	}

	setup_zone_flag_waits();

	// Now iterate through the active zones and see if we need to activate spawners
	while(getdvarint("noclip") == 0 || getdvarint("notarget") != 0	)
	{
		zkeys = GetArrayKeys( level.zones );

		// clear out active zone flags
		for( z=0; z<zkeys.size; z++ )
		{
			level.zones[ zkeys[z] ].is_active   = false;
			level.zones[ zkeys[z] ].is_occupied = false;
		}

		// Figure out which zones are active
		//	If a player occupies a zone, then that zone and any of its enabled adjacent zones will activate
		a_zone_is_active = false;	// let's us know if an active zone is found
		for( z=0; z<zkeys.size; z++ )
		{
			if ( !level.zones[ zkeys[z] ].is_enabled )
			{
				continue;
			}

			level.zones[ zkeys[z] ].is_occupied = player_in_zone( zkeys[z] );
			if ( level.zones[ zkeys[z] ].is_occupied )
			{
				level.zones[ zkeys[z] ].is_active = true;
				a_zone_is_active = true;
				for ( az=0; az<level.zones[ zkeys[z] ].adjacent_zones.size; az++ )
				{
					azkeys = GetArrayKeys( level.zones[ zkeys[z] ].adjacent_zones );
					if ( level.zones[ zkeys[z] ].adjacent_zones[ azkeys[az] ].is_connected )
					{
						level.zones[ azkeys[ az ] ].is_active = true;
					}
				}
			}
		}

		// MM - Special logic for empty spawner list
		if ( !a_zone_is_active )
		{
			if(isDefined(level.zones[ "receiver_zone" ])) //UGX
			{
				level.zones[ "receiver_zone" ].is_active = true;
				level.zones[ "receiver_zone" ].is_occupied = true;
			}
		}
		

		// Okay now we can modify the spawner list
		for( z=0; z<zkeys.size; z++ )
		{
			zone_name = zkeys[z];

			if ( !level.zones[ zkeys[z] ].is_enabled )
			{
				continue;
			}
			
			if ( level.zones[ zone_name ].is_active )
			{
				// Making an assumption that if one of the zone's spawners is in the array, then all of them are in the array
				if ( level.zones[ zone_name ].spawners.size > 0 )
				{
					no_dupes = array_check_for_dupes( level.enemy_spawns, level.zones[ zone_name ].spawners[0] );
					if( no_dupes )
					{
						for(x=0;x<level.zones[ zone_name ].spawners.size;x++)
						{
							level.zones[ zone_name ].spawners[x].locked_spawner = false;
							level.enemy_spawns = add_to_array(level.enemy_spawns, level.zones[ zone_name ].spawners[x]);
						}
					}
				}

				// Making an assumption that if one of the zone's spawners is in the array, then all of them are in the array
				if ( level.zones[ zone_name ].dog_spawners.size > 0 )
				{
					no_dupes = array_check_for_dupes( level.enemy_dog_spawns, level.zones[ zone_name ].dog_spawners[0] );
					if( no_dupes )
					{
						for(x=0;x<level.zones[ zone_name ].dog_spawners.size;x++)
						{
							level.enemy_dog_spawns = add_to_array(level.enemy_dog_spawns, level.zones[ zone_name ].dog_spawners[x]);
						}
					}
				}

				// activate any associated dog_spawn locations
				if ( level.zones[ zone_name ].dog_locations.size > 0 )
				{
					// Making an assumption that if one of the structs
					//	is in the array, then all of them are in the array
					no_dupes = array_check_for_dupes(level.enemy_dog_locations, level.zones[ zone_name ].dog_locations[0]);
					if( no_dupes )
					{
						for(x=0; x<level.zones[ zone_name ].dog_locations.size; x++)
						{
							level.zones[ zone_name ].dog_locations[x].locked_spawner = false;
							level.enemy_dog_locations = add_to_array(level.enemy_dog_locations, level.zones[ zone_name ].dog_locations[x]);
						}
					}
				}

				// activate any associated zombie_rise locations
				if ( level.zones[ zone_name ].rise_locations.size > 0 )
				{
					// Making an assumption that if one of the zone's spawners
					//	is in the array, then all of them are in the array
					no_dupes = array_check_for_dupes(level.zombie_rise_spawners, level.zones[ zone_name ].rise_locations[0]);
					if( no_dupes )
					{
						for(x=0; x<level.zones[ zone_name ].rise_locations.size; x++)
						{
							level.zones[ zone_name ].rise_locations[x].locked_spawner = false;
							level.zombie_rise_spawners = add_to_array(level.zombie_rise_spawners, level.zones[ zone_name ].rise_locations[x]);
						}
					}
				}
			}
			// The zone is not active so disable the spawners
			else
			{	
				// Making an assumption that if one of the zone's spawners
				//	is in the array, then all of them are in the array
				if ( level.zones[ zone_name ].spawners.size > 0 )
				{
					no_dupes = array_check_for_dupes( level.enemy_spawns, level.zones[ zone_name ].spawners[0] );
					if( !no_dupes )
					{
						for(x=0;x<level.zones[ zone_name ].spawners.size;x++)
						{
							level.zones[ zone_name ].spawners[x].locked_spawner = true;
							level.enemy_spawns = array_remove_nokeys(level.enemy_spawns, level.zones[ zone_name ].spawners[x]);
						}
					}
				}
				
				// Making an assumption that if one of the zone's spawners is in the array, then all of them are in the array
				if ( level.zones[ zone_name ].dog_spawners.size > 0 )
				{
					no_dupes = array_check_for_dupes( level.enemy_dog_spawns, level.zones[ zone_name ].dog_spawners[0] );
					if( !no_dupes )
					{
						for(x=0;x<level.zones[ zone_name ].dog_spawners.size;x++)
						{
							level.enemy_dog_spawns = array_remove_nokeys(level.enemy_dog_spawns, level.zones[ zone_name ].dog_spawners[x]);
						}
					}
				}

				// deactivate any associated dog spawn locations
				if ( level.zones[ zone_name ].dog_locations.size > 0 )
				{
					// Making an assumption that if one of the structs is in the array, then all of them are in the array
					no_dupes = array_check_for_dupes(level.enemy_dog_locations, level.zones[ zone_name ].dog_locations[0]);
					if( !no_dupes )
					{	
						for(x=0; x<level.zones[ zone_name ].dog_locations.size; x++)
						{
							level.zones[ zone_name ].dog_locations[x].locked_spawner = false;
							level.enemy_dog_locations = array_remove_nokeys(level.enemy_dog_locations, level.zones[ zone_name ].dog_locations[x]); 
						}
					}
				}
				// deactivate any associated zombie_rise locations
				if ( level.zones[ zone_name ].rise_locations.size > 0 )
				{
					// Making an assumption that if one of the zone's spawners
					//	is in the array, then all of them are in the array

					no_dupes = array_check_for_dupes(level.zombie_rise_spawners, level.zones[ zone_name ].rise_locations[0]);
					if( !no_dupes )
					{
						for(x=0; x<level.zones[ zone_name ].rise_locations.size; x++)
						{
							level.zones[ zone_name ].rise_locations[x].locked_spawner = false;
							level.zombie_rise_spawners = array_remove_nokeys(level.zombie_rise_spawners, level.zones[ zone_name ].rise_locations[x]);
						}
					}
				}
			}
		}

		//wait a second before another check
		wait(1);			
	}
}
