#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	init_weapons();
	init_weapon_upgrade();
	init_weapon_cabinet();
	treasure_chest_init();

	level thread init_weapon_crate(); // new
}

add_zombie_weapon( weapon_name, hint, cost, weaponVO, variation_count, ammo_cost  )
{
	if( IsDefined( level.zombie_include_weapons ) && !IsDefined( level.zombie_include_weapons[weapon_name] ) )
	{
		return;
	}

	add_weapon_to_sound_array(weaponVO,variation_count);

	// Check the table first
	table = "mp/zombiemode.csv";
	table_cost = TableLookUp( table, 0, weapon_name, 1 );
	table_ammo_cost = TableLookUp( table, 0, weapon_name, 2 );

	if( IsDefined( table_cost ) && table_cost != "" )
	{
		cost = round_up_to_ten( int( table_cost ) );
	}

	if( IsDefined( table_ammo_cost ) && table_ammo_cost != "" )
	{
		ammo_cost = round_up_to_ten( int( table_ammo_cost ) );
	}

	PrecacheItem( weapon_name );
	PrecacheString( hint );

	struct = SpawnStruct();
	
	if( !IsDefined( level.zombie_weapons ) )
	{
		level.zombie_weapons = [];
	}

	struct.weapon_name = weapon_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.sound = weaponVO;
	struct.variation_count = variation_count;
	struct.is_in_box = level.zombie_include_weapons[weapon_name];

	if( !IsDefined( ammo_cost ) )
	{
		ammo_cost = round_up_to_ten( int( cost * 0.5 ) );
	}

	struct.ammo_cost = ammo_cost;

	level.zombie_weapons[weapon_name] = struct;
}

include_zombie_weapon( weapon_name, in_box )
{
	if( !IsDefined( level.zombie_include_weapons ) )
	{
		level.zombie_include_weapons = [];
	}
	if( !isDefined( in_box ) )
	{
		in_box = true;
	}

	level.zombie_include_weapons[weapon_name] = in_box;
}

init_weapons()
{
	// Zombify
	PrecacheItem( "zombie_melee" );
	PrecacheItem( "falling_hands" );

	// Pistols
	add_zombie_weapon( "zombie_colt", 							&"ZOMBIE_WEAPON_COLT_50", 							50,		"",				0);
	add_zombie_weapon( "colt_dirty_harry", 						&"ZOMBIE_WEAPON_COLT_DH_100", 								100,	"",				0);
	add_zombie_weapon( "sw_357", 								&"ZOMBIE_WEAPON_SW357_100", 								100,	"",				0);
                                                        		
	// Bolt Action                                      		
	add_zombie_weapon( "kar98k", 								&"ZOMBIE_WEAPON_KAR98K_200", 								200,	"vox_crappy",	4); // 100% of the time, except Sarge has one repeating line (Does not play on wallbuy)
	add_zombie_weapon( "springfield", 							&"ZOMBIE_WEAPON_SPRINGFIELD_200", 							200,	"vox_crappy",	4); // 100% of the time, except Sarge has one repeating line
                                                        		
	// Semi Auto                                        		
	add_zombie_weapon( "gewehr43", 								&"ZOMBIE_WEAPON_GEWEHR43_600", 								600,	"",				0);
	add_zombie_weapon( "m1carbine", 							&"ZOMBIE_WEAPON_M1CARBINE_600",								600,	"",				0);
	add_zombie_weapon( "m1garand", 								&"ZOMBIE_WEAPON_M1GARAND_600", 								600,	"",				0);
	add_zombie_weapon( "svt40", 								&"ZOMBIE_WEAPON_SVT40_600", 								600,	"",				0);
                                                        		
	// Grenades                                         		
	add_zombie_weapon( "molotov", 								&"ZOMBIE_WEAPON_MOLOTOV_200", 								200,	"vox_crappy",	4); // 100% of the time, except Sarge has one reepating line
	add_zombie_weapon( "stielhandgranate", 						&"REMASTERED_ZOMBIE_WEAPON_STIELHANDGRANATE_250",	250,	"",				0);

	// Scoped
	add_zombie_weapon( "kar98k_scoped_zombie", 					&"ZOMBIE_WEAPON_KAR98K_S_750", 								750,	"vox_sniper",	2); // 100% of the time, only a cabinet wallbuy
	add_zombie_weapon( "ptrs41_zombie", 						&"ZOMBIE_WEAPON_PTRS41_750", 								750,	"vox_sniper",	2); // 100% of the time, only one sniper in the box
                                                                                             	
	// Full Auto                                                                                			
	add_zombie_weapon( "mp40", 								&"ZOMBIE_WEAPON_MP40_1000", 									1000,	"",				0);
	add_zombie_weapon( "ppsh", 								&"ZOMBIE_WEAPON_PPSH_2000", 									2000,	"",		0); // CUT. 2/3 of the time except Sarge who only has 1 line
	add_zombie_weapon( "stg44", 							&"ZOMBIE_WEAPON_STG44_1200", 									1200,	"",				0);
	add_zombie_weapon( "thompson", 							&"REMASTERED_ZOMBIE_WEAPON_THOMPSON_1200", 			1500,	"vox_thompson",	2); // 50% of the time because only 1 line is available, less repetitive
	add_zombie_weapon( "type100_smg", 						&"ZOMBIE_WEAPON_TYPE100_1000", 									1000,	"",				0);
                                                        	
	// Shotguns                                         	
	add_zombie_weapon( "doublebarrel", 						&"ZOMBIE_WEAPON_DOUBLEBARREL_1200", 							1200,	"vox_shotgun",	3); // Some characters 100%, but others less if they have less lines
	add_zombie_weapon( "doublebarrel_sawed_grip", 			&"REMASTERED_ZOMBIE_WEAPON_DOUBLEBARREL_SAWED_1200", 						1200,	"vox_shotgun",	3);
	add_zombie_weapon( "shotgun", 							&"ZOMBIE_WEAPON_SHOTGUN_1500", 									1500,	"vox_shotgun",	3);
                                                        	
	// Heavy Machineguns                                	
	add_zombie_weapon( "30cal_bipod", 						&"ZOMBIE_WEAPON_30CAL_3000", 								3000,	"vox_mg",		5); // Most of the time, occasionally won't play as some characters don't have 5 lines
	add_zombie_weapon( "bar", 								&"REMASTERED_ZOMBIE_WEAPON_BAR_1800", 				1800,	"vox_mg",		5);
	add_zombie_weapon( "fg42_bipod", 						&"ZOMBIE_WEAPON_FG42_1200", 							1500,	"vox_mg",		5);
	add_zombie_weapon( "mg42_bipod", 						&"ZOMBIE_WEAPON_MG42_1200", 							3000,	"vox_mg",		5);
	//add_zombie_weapon( "dp28", 								&"ZOMBIE_WEAPON_DP28_2250", 									2250,	"vox_mg",		5);
	//add_zombie_weapon( "type99_lmg", 						&"ZOMBIE_WEAPON_TYPE99_LMG_1750", 								1750,	"vox_mg",		5);
                                                        	
	// Grenade Launcher                                 	
	add_zombie_weapon( "m1garand_gl", 						&"ZOMBIE_WEAPON_M1GARAND_GL_1200", 								1200,	"",				0);

	// Rocket Launchers
	add_zombie_weapon( "panzerschrek", 						&"ZOMBIE_WEAPON_PANZERSCHREK_2000", 							2000,	"",				0);
	                                                    	
	// Flamethrower                                     	
	add_zombie_weapon( "m2_flamethrower_zombie", 			&"ZOMBIE_WEAPON_M2_FLAMETHROWER_3000", 							3000,	"vox_flame",	2); // 100% of the time, except Player1 only has one line, luckily this is a limited wep
                                                        	
	// Special                                          	
	add_zombie_weapon( "mortar_round", 						&"ZOMBIE_WEAPON_MORTARROUND_2000", 								2000,	"",				0);
	add_zombie_weapon( "satchel_charge", 					&"ZOMBIE_WEAPON_SATCHEL_2000", 									2000,	"",				0);
	add_zombie_weapon( "ray_gun", 							&"ZOMBIE_WEAPON_RAYGUN_10000", 									10000,	"vox_raygun",	3); // 66% chance for all characters except Sarge because he has 3 unique lines, so 100% for him
	// ONLY 1 OF THE BELOW SHOULD BE ALLOWED
	add_limited_weapon( "m2_flamethrower_zombie", 1 );
}             

add_limited_weapon( weapon_name, amount )
{
	if( !IsDefined( level.limited_weapons ) )
	{
		level.limited_weapons = [];
	}

	level.limited_weapons[weapon_name] = amount;
}                                          	

// For buying weapon upgrades in the environment
init_weapon_upgrade()
{
	weapon_spawns = [];
	weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" ); 

	for( i = 0; i < weapon_spawns.size; i++ )
	{
		hint_string = get_weapon_hint( weapon_spawns[i].zombie_weapon_upgrade ); 

		weapon_spawns[i] SetHintString( hint_string ); 
		weapon_spawns[i] setCursorHint( "HINT_NOICON" ); 
		weapon_spawns[i] UseTriggerRequireLookAt();

		weapon_spawns[i] thread weapon_spawn_think(); 
		model = getent( weapon_spawns[i].target, "targetname" ); 
		model hide(); 
	}
}

// weapon cabinets which open on use
init_weapon_cabinet()
{
	// the triggers which are targeted at doors
	weapon_cabs = GetEntArray( "weapon_cabinet_use", "targetname" ); 
	
	for( i = 0; i < weapon_cabs.size; i++ )
	{
	
		weapon_cabs[i] SetHintString( &"ZOMBIE_CABINET_OPEN_1500" ); 
		weapon_cabs[i] setCursorHint( "HINT_NOICON" ); 
		weapon_cabs[i] UseTriggerRequireLookAt();
	}

	array_thread( weapon_cabs, ::weapon_cabinet_think ); 
}

// weapon crate which opens on use
init_weapon_crate()
{
	// spawn crate model and crate lid, not originally in the map so these extra bits are needed
	satchel_crate = spawn("script_model", (1020.5, 927.1, 146.2) );
	satchel_crate setmodel("satchel_crate");
	satchel_crate.angles = (1,20,1);
	wait_network_frame();
	level.satchel_crate_lid = spawn("script_model", (satchel_crate.origin + (10.5,3.62,12.2)) );
	level.satchel_crate_lid setmodel("satchel_crate_lid");
	level.satchel_crate_lid.angles = satchel_crate.angles;
	level.satchel_crate_lid notSolid();
	wait_network_frame();
	level.question_mark = spawn("script_model", (satchel_crate.origin + (10.5,3.62,12.2)) );
	level.question_mark setmodel("satchel_crate_lid_question");
	level.question_mark.angles = satchel_crate.angles;
	level.question_mark notSolid();
	
	// create trigger
	satchel_crate_trigger = spawn( "trigger_radius",satchel_crate.origin, 0, 75, 25 );
	satchel_crate_trigger SetHintString( &"REMASTERED_ZOMBIE_CRATE_OPEN_2000" ); 
	satchel_crate_trigger setCursorHint( "HINT_NOICON" ); 

	satchel_crate_trigger thread weapon_crate_think();
}

// returns the trigger hint string for the given weapon
get_weapon_hint( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	return level.zombie_weapons[weapon_name].hint;
}

get_weapon_cost( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	return level.zombie_weapons[weapon_name].cost;
}

get_ammo_cost( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	return level.zombie_weapons[weapon_name].ammo_cost;
}

get_is_in_box( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );
	
	return level.zombie_weapons[weapon_name].is_in_box;
}


// for the random weapon chest
treasure_chest_init()
{
	// the triggers which are targeted at chests
	chests = GetEntArray( "treasure_chest_use", "targetname" ); 

	array_thread( chests, ::treasure_chest_think ); 
}

set_treasure_chest_cost( cost )
{
	level.zombie_treasure_chest_cost = cost;
}

treasure_chest_think()
{
	cost = 950;
	if( IsDefined( level.zombie_treasure_chest_cost ) )
	{
		cost = level.zombie_treasure_chest_cost;
	}

	self set_hint_string( self, "default_treasure_chest_" + cost );
	self setCursorHint( "HINT_NOICON" );
	
	// waittill someuses uses this
	user = undefined;
	while( 1 )
	{
		self waittill( "trigger", user ); 

		if( user in_revive_trigger() )
		{
			wait( 0.1 );
			continue;
		}
		
		// make sure the user is a player, and that they can afford it
		if( is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 
			break; 
		}
		else if ( user.score < cost )
		{
			play_sound_on_ent( "no_purchase" );
			continue;	
		}
		
		wait 0.05; 
	}
	
	// trigger_use->script_brushmodel lid->script_origin in radiant
	lid = getent( self.target, "targetname" ); 
	weapon_spawn_org = getent( lid.target, "targetname" ); 
	
	//open the lid
	lid thread treasure_chest_lid_open();
	
	// SRS 9/3/2008: added to help other functions know if we timed out on grabbing the item
	self.timedOut = false;
	
	// mario kart style weapon spawning
	weapon_spawn_org thread treasure_chest_weapon_spawn( self, user ); 
	
	// the glowfx	
	weapon_spawn_org thread treasure_chest_glowfx(); 
	
	// take away usability until model is done randomizing
	self disable_trigger(); 
	
	weapon_spawn_org waittill( "randomization_done" ); 

	self.grab_weapon_hint = true;
	self.chest_user = user;
	self sethintstring( &"REMASTERED_ZOMBIE_TRADE_WEAPONS" ); 
	self setCursorHint( "HINT_NOICON" ); 
	self setvisibletoplayer( user );

	self enable_trigger(); 
	self thread treasure_chest_timeout();
	
	// make sure the guy that spent the money gets the item
	// SRS 9/3/2008: ...or item goes back into the box if we time out
	while( 1 )
	{
		self waittill( "trigger", grabber ); 
		
		if( grabber == user || grabber == level )
		{
			if( grabber == user && is_player_valid( user ) && user GetCurrentWeapon() != "satchel_charge" && level.falling_down == false )
			{
				self notify( "user_grabbed_weapon" );
				user thread treasure_chest_give_weapon( weapon_spawn_org.weapon_string );
				//grabber.potentially_spamming = true;
				break; 
			}
			else if( grabber == level )
			{
				// it timed out
				self.timedOut = true;
				break;
			}
		}
		
		wait 0.05; 
	}
	self.grab_weapon_hint = false;

	weapon_spawn_org notify( "weapon_grabbed" ); 
	
	self disable_trigger(); 
		
	// spend cash here...
	// give weapon here...
	lid thread treasure_chest_lid_close( self.timedOut ); 
	
	wait 3; 
	//if(isdefined(grabber.potentially_spamming))
	//{
		//grabber.potentially_spamming = undefined;
	//}
	self enable_trigger(); 	
	self setvisibletoall();

	self thread treasure_chest_think(); 
}

treasure_chest_user_hint( trigger, user )
{
	dist = 128 * 128;
	while( 1 )
	{
		if( !IsDefined( trigger ) )
		{
			break;
		}

		if( trigger.grab_weapon_hint )
		{
			break;
		}

		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] == user )
			{
				continue;
			}

			if( DistanceSquared( players[i].origin, trigger.origin ) < dist )
			{
				players[i].ignoreTriggers = true;
			}
		}

		wait( 0.1 );
	}
}

decide_hide_show_chest_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	while( true )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			// chest_user defined if someone bought a weapon spin, false when chest closed
			if ( (IsDefined(self.chest_user) && players[i] != self.chest_user ) ||
				 !players[i] can_buy_weapon() )
			{
				self SetInvisibleToPlayer( players[i], true );
			}
			else
			{
				self SetInvisibleToPlayer( players[i], false );
			}
		}
		wait( 0.1 );
	}
}

decide_hide_show_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	while( true )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] can_buy_weapon() && level.falling_down == false )
			{
				self SetInvisibleToPlayer( players[i], false );
			}
			else
			{
				self SetInvisibleToPlayer( players[i], true );
			}
		}
		wait( 0.1 );
	}
}

can_buy_weapon()
{
	if( self GetCurrentWeapon() == "satchel_charge" )
	{
		return false;
	}
	if( self in_revive_trigger() )
	{
		return false;
	}
	
	return true;
}

treasure_chest_timeout()
{
	self endon( "user_grabbed_weapon" );
	
	wait( 12 );
	self notify( "trigger", level ); 
}

treasure_chest_lid_open()
{
	openRoll = 105;
	openTime = 0.5;
	
	self RotateRoll( 105, openTime, ( openTime * 0.5 ) );
	
	play_sound_at_pos( "open_chest", self.origin );
	play_sound_at_pos( "music_chest", self.origin );
}

treasure_chest_lid_close( timedOut )
{
	closeRoll = -105;
	closeTime = 0.5;
	
	self RotateRoll( closeRoll, closeTime, ( closeTime * 0.5 ) );
	play_sound_at_pos( "close_chest", self.origin );
}

treasure_chest_ChooseRandomWeapon( player )
{
	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !get_is_in_box( keys[i] ) )
		{
			continue;
		}

		if( player HasWeapon( keys[i] ) )
		{
			continue;
		}

		if( !IsDefined( keys[i] ) )
		{
			continue;
		}

		filtered[filtered.size] = keys[i];
	}

	// Filter out the limited weapons
	if( IsDefined( level.limited_weapons ) )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		for( q = 0; q < keys2.size; q++ )
		{
			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] HasWeapon( keys2[q] ) )
				{
					count++;
				}
			}
	
			if( count == level.limited_weapons[keys2[q]] )
			{
				filtered = array_remove( filtered, keys2[q] );
			}
		}
	}

	return filtered[RandomInt( filtered.size )];
}

treasure_chest_weapon_spawn( chest, player )
{
	assert(IsDefined(player));
	// spawn the model
	model = spawn( "script_model", self.origin ); 
	model.angles = self.angles +( 0, 90, 0 );
	
	floatHeight = 40;
	
	//move it up
	model moveto( model.origin +( 0, 0, floatHeight ), 3, 2, 0.9 ); 

	// rotation would go here

	// make with the mario kart
	modelname = undefined; 
	rand = undefined; 
	for( i = 0; i < 40; i++ )
	{
		
		if( i < 20 )
		{
			wait( 0.05 ); 
		}
		else if( i < 30 )
		{
			wait( 0.1 ); 
		}
		else if( i < 35 )
		{
			wait( 0.2 ); 
		}
		else if( i < 38 )
		{
			wait( 0.3 ); 
		}

		rand = treasure_chest_ChooseRandomWeapon( player );
		modelname = GetWeaponModel( rand );
		model setmodel( modelname ); 
	}

	self notify( "randomization_done" ); 
	self.weapon_string = rand; // here's where the org get it's weapon type for the give function
	
	model thread timer_til_despawn(floatHeight);

	self waittill( "weapon_grabbed" );
	
	if( !chest.timedOut )
	{
		model Delete();
	}
}

timer_til_despawn(floatHeight)
{
	putBackTime = 12;
	self MoveTo( self.origin - ( 0, 0, floatHeight ), putBackTime, ( putBackTime * 0.5 ) );
	wait( putBackTime );

	if(isdefined(self))
	{	
		self Delete();
	}
}


treasure_chest_glowfx()
{
	fxObj = spawn( "script_model", self.origin +( 0, 0, 0 ) ); 
	fxobj setmodel( "tag_origin" ); 
	fxobj.angles = self.angles +( 90, 0, 0 ); 
	
	playfxontag( level._effect["chest_light"], fxObj, "tag_origin"  ); 

	self waittill( "weapon_grabbed" ); 
	
	fxobj delete(); 
}

// self is the player string comes from the randomization function
treasure_chest_give_weapon( weapon_string )
{
	primaryWeapons = self GetWeaponsListPrimaries(); 
	current_weapon = undefined; 

	// This should never be true for the first time.
	if( primaryWeapons.size >= 2 ) // he has two weapons
	{
		current_weapon = self getCurrentWeapon(); // get hiss current weapon

		if ( current_weapon == "satchel_charge" )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !( weapon_string == "fraggrenade" || weapon_string == "stielhandgranate" || weapon_string == "molotov" ) )
			self TakeWeapon( current_weapon ); 
		} 
	} 

	if( IsDefined( primaryWeapons ) && !isDefined( current_weapon ) )
	{
		for( i = 0; i < primaryWeapons.size; i++ )
		{
			if( primaryWeapons.size == 1 || primaryWeapons[i] == "zombie_colt" )
			{
				continue; 
			}

			if( weapon_string != "fraggrenade" && weapon_string != "stielhandgranate" && weapon_string != "molotov" )
			{
				self TakeWeapon( primaryWeapons[i] ); 
			}
		}
	}

	self play_sound_on_ent( "purchase" ); 

    if ( (weapon_string == "ray_gun") )
    {
        playsoundatposition("raygun_stinger", (0,0,0));
    }

	self GiveWeapon( weapon_string, 0 );
	self GiveMaxAmmo( weapon_string );
	self SwitchToWeapon( weapon_string ); 

    if ( (isSubStr(weapon_string, "flamethrower") ) )
    {
		self thread flamethrower_swap();
    }
    
	play_weapon_vo(weapon_string);

}

weapon_cabinet_think()
{
	weapons = getentarray( "cabinet_weapon", "targetname" ); 

	doors = getentarray( self.target, "targetname" );
	for( i = 0; i < doors.size; i++ )
	{
		doors[i] NotSolid();
	}
		
	self.has_been_used_once = false; 

	self thread decide_hide_show_hint();

	while( 1 )
	{
		self waittill( "trigger", player );

		if( !player can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		cost = 1500;
		if( self.has_been_used_once )
		{
			cost = get_weapon_cost( self.zombie_weapon_upgrade );
		}
		else
		{
			if( IsDefined( self.zombie_cost ) )
			{
				cost = self.zombie_cost;
			}
		}

		ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );

		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}
	
		if( self.has_been_used_once )
		{
			player_has_weapon = false; 
			weapons = player GetWeaponsList(); 
			if( IsDefined( weapons ) )
			{
				for( i = 0; i < weapons.size; i++ )
				{
					if( weapons[i] == self.zombie_weapon_upgrade )
					{
						player_has_weapon = true; 
					}
				}
			}

			if( !player_has_weapon )
			{
				if( player.score >= cost )
				{
					player maps\_zombiemode_score::minus_to_player_score( cost ); 
					player weapon_give( self.zombie_weapon_upgrade ); 
				}
				else // not enough money
				{
					play_sound_on_ent( "no_purchase" );
				}			
			}
			else if ( player.score >= ammo_cost )
			{
				ammo_given = player ammo_give( self.zombie_weapon_upgrade ); 
				if( ammo_given )
				{
					player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early
				}
			}
			else // not enough money
			{
				play_sound_on_ent( "no_purchase" );
			}
		}
		else if( player.score >= cost ) // First time the player opens the cabinet
		{
			self.has_been_used_once = true;

			play_sound_at_pos( "cabinet_open", doors[0].origin );

			self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", 750, ammo_cost ); 
	//		self SetHintString( get_weapon_hint( self.zombie_weapon_upgrade ) );
			self setCursorHint( "HINT_NOICON" ); 
			player maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 
			
			doors = getentarray( self.target, "targetname" ); 
		
			for( i = 0; i < doors.size; i++ )
			{
				if( doors[i].model == "dest_test_cabinet_ldoor_dmg0" )
				{
					doors[i] thread weapon_cabinet_door_open( "left" ); 
				}
				else if( doors[i].model == "dest_test_cabinet_rdoor_dmg0" )
				{
					doors[i] thread weapon_cabinet_door_open( "right" ); 
				}
			}

			player_has_weapon = false; 
			weapons = player GetWeaponsList(); 
			if( IsDefined( weapons ) )
			{
				for( i = 0; i < weapons.size; i++ )
				{
					if( weapons[i] == self.zombie_weapon_upgrade )
					{
						player_has_weapon = true; 
					}
				}
			}

			if( !player_has_weapon )
			{
				player weapon_give( self.zombie_weapon_upgrade ); 
			}
			else
			{
				player ammo_give( self.zombie_weapon_upgrade ); 
			}	
		}
		else // not enough money
		{
			 play_sound_on_ent( "no_purchase" );
		}		
	}
}

weapon_cabinet_door_open( left_or_right )
{
	if( left_or_right == "left" )
	{
		self rotateyaw( 120, 0.3, 0.2, 0.1 ); 	
	}
	else if( left_or_right == "right" )
	{
		self rotateyaw( -120, 0.3, 0.2, 0.1 ); 	
	}	
}

weapon_crate_think()
{
	crate_sound = spawn( "script_origin", ( level.satchel_crate_lid.origin ) );
	cost = 2000;
	has_been_used_once = false; 
	lookat = level.satchel_crate_lid.origin;

	while( 1 )
	{
		self waittill( "trigger", player );
		if(isDefined(player.has_satchel) && player.has_satchel) // once we buy betties, trig is null
		{
			continue;
		}
		if( !player islookingatorigin( lookat ) || level.falling_down == true ) // new check, because we're using trigger radius that doesnt have capability to support UseTriggerRequireLookAt()
		{
			self SetInvisibleToPlayer( player, true );
			continue;
		}
		if( !player IsTouching( self ) ) // new check, just to be safe so that if player leaves trig it resets for another player to use
		{
			continue;
		}

		self SetInvisibleToPlayer( player, false );

		if( !player can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}
		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( !player UseButtonPressed() ) // new check, because we're using trigger radius that triggers when we enter zone and not press F
		{
			continue; 
		}
		if(player.score < cost && (!IsDefined(player.has_satchel) || (player.has_satchel == false) ) ) // only if we DONT have points and we DONT have satchel
		{
			crate_sound play_sound_on_ent( "no_purchase" );
			wait(0.5);
			continue;
		}

		// passing here means we HAVE points and we DONT have satchels yet
		if( has_been_used_once == false ) // open only on the first use
		{
			has_been_used_once = true;
			play_sound_at_pos( "crate_open", crate_sound.origin );
			level.satchel_crate_lid RotateTo( level.satchel_crate_lid.angles + (92,0,0), 0.4, 0.1, 0.1);
			level.question_mark RotateTo( level.question_mark.angles + (92,0,0), 0.4, 0.1, 0.1);
			level thread give_satchel_after_rounds();
			self SetHintString( &"REMASTERED_ZOMBIE_SATCHEL_PURCHASE" ); 
		}
		
		player.has_satchel = true;
		crate_sound play_sound_on_ent( "purchase" ); 

		player maps\_zombiemode_score::minus_to_player_score( 2000 ); 
				
		player thread show_satchel_hint(self);

		player giveweapon("satchel_charge"); 
		player setactionslot(4,"weapon","satchel_charge");
	    player SetWeaponAmmoClip( "satchel_charge", 2 );

	    continue;
	}
}

show_satchel_hint(satchel)
{
	self endon("death");
	self endon("disconnect");

	self setup_client_hintelem();
	self.hintelem setText(&"REMASTERED_ZOMBIE_SATCHEL_HOWTO");
	wait(0.25);
	satchel SetInvisibleToPlayer( self, true ); // moved to here so we have a little delay if we instantly buy
	wait(3.75);
	self.hintelem settext("");	
	self.hintelem delete();
}

setup_client_hintelem()
{
	self endon("death");
	self endon("disconnect");

	if(!isDefined(self.hintelem))
	{
		self.hintelem = newclienthudelem(self);
	}
	self.hintelem init_hint_hudelem(320, 220, "center", "bottom", 1.6, 1.0);
}

//satchel hint stuff
init_hint_hudelem(x, y, alignX, alignY, fontscale, alpha)
{
	self.x = x;
	self.y = y;
	self.alignX = alignX;
	self.alignY = alignY;
	self.fontScale = fontScale;
	self.alpha = alpha;
	self.sort = 20;
	//self.font = "objective";
}

give_satchel_after_rounds()
{
	while(1)
	{
		level waittill( "between_round_over" );
		{
			players = get_players();
			for(i=0;i<players.size;i++)
			{
				if(isDefined(players[i].has_satchel) && !players[i] maps\_laststand::player_is_in_laststand() )
				{
					players[i] giveweapon("satchel_charge"); 
					players[i] setactionslot(4,"weapon","satchel_charge");
				    players[i] SetWeaponAmmoClip( "satchel_charge", 2 );
				}
			}
		}
	}
}

weapon_spawn_think()
{
	cost = get_weapon_cost( self.zombie_weapon_upgrade );
	ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
	is_grenade = (WeaponType( self.zombie_weapon_upgrade ) == "grenade");
	if(is_grenade)
	{
		ammo_cost = cost;
	}

	self thread decide_hide_show_hint();

	self.first_time_triggered = false; 
	for( ;; )
	{
		self waittill( "trigger", player ); 		
		// if not first time and they have the weapon give ammo
		
		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( !player can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}
		
		player_has_weapon = false; 
		weapons = player GetWeaponsList(); 
		if( IsDefined( weapons ) )
		{
			for( i = 0; i < weapons.size; i++ )
			{
				if( weapons[i] == self.zombie_weapon_upgrade )
				{
					player_has_weapon = true; 
				}
			}
		}		
		
		
		if( !player_has_weapon )
		{
			// else make the weapon show and give it
			if( player.score >= cost )
			{
				if( self.first_time_triggered == false )
				{
					model = getent( self.target, "targetname" ); 
//					model show(); 
					model thread weapon_show( player ); 
					self.first_time_triggered = true; 
					
					if(!is_grenade)
					{
						self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost ); 
					}
				}
			
				if(is_grenade && player GetWeaponAmmoClip("stielhandgranate") >= 4)	
				{
					continue;
				}
				else
				{
					player maps\_zombiemode_score::minus_to_player_score( cost ); 
				}
				
				player weapon_give( self.zombie_weapon_upgrade ); 
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
			}
		}
		else
		{
			// if the player does have this then give him ammo.
			if( player.score >= ammo_cost )
			{
				if( self.first_time_triggered == false )
				{
					model = getent( self.target, "targetname" ); 
//					model show(); 
					model thread weapon_show( player ); 
					self.first_time_triggered = true;
					if(!is_grenade)
					{ 
						self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost ); 
					}
				}
				
				ammo_given = player ammo_give( self.zombie_weapon_upgrade ); 
				if( ammo_given )
				{
					if(is_grenade)
					{
						player maps\_zombiemode_score::minus_to_player_score( cost ); // this give him ammo to early
					}
					else
					{
						player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early
					}
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
			}
		}
	}
}




weapon_show( player )
{
	player_angles = VectorToAngles( player.origin - self.origin ); 

	player_yaw = player_angles[1]; 
	weapon_yaw = self.angles[1]; 

	yaw_diff = AngleClamp180( player_yaw - weapon_yaw ); 

	if( yaw_diff > 0 )
	{
		yaw = weapon_yaw - 90; 
	}
	else
	{
		yaw = weapon_yaw + 90; 
	}

	self.og_origin = self.origin; 
	self.origin = self.origin +( AnglesToForward( ( 0, yaw, 0 ) ) * 8 ); 

	wait( 0.05 ); 
	self Show(); 

	play_sound_at_pos( "weapon_show", self.origin, self );

	time = 1; 
	self MoveTo( self.og_origin, time ); 
}

weapon_give( weapon )
{

	primaryWeapons = self GetWeaponsListPrimaries(); 
	current_weapon = undefined; 

	// This should never be true for the first time.
	if( primaryWeapons.size >= 2 ) // he has two weapons
	{
		current_weapon = self getCurrentWeapon(); // get his current weapon

		if ( current_weapon == "satchel_charge" )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !( weapon == "fraggrenade" || weapon == "stielhandgranate" || weapon == "molotov" ) )
			{
				self TakeWeapon( current_weapon ); 
			}
		} 
	} 

	if( IsDefined( primaryWeapons ) && !isDefined( current_weapon ) )
	{
		for( i = 0; i < primaryWeapons.size; i++ )
		{
			if( primaryWeapons.size == 1 || primaryWeapons[i] == "zombie_colt" )
			{
				continue; 
			}

			if( weapon != "fraggrenade" && weapon != "stielhandgranate" && weapon != "molotov" )
			{
				self TakeWeapon( primaryWeapons[i] ); 
			}
		}
	}

	self play_sound_on_ent( "purchase" );
	self GiveWeapon( weapon, 0 ); 
	self GiveMaxAmmo( weapon ); 
	self SwitchToWeapon( weapon ); 

	if( (weapon != "kar98k" ) )
	{
		play_weapon_vo(weapon);
	}

}

get_player_index(player)
{
	assert( IsPlayer( player ) );
	assert( IsDefined( player.entity_num ) );

	//iprintln(player.entity_num);
	//return player.entity_num;
	return level.character_index[player.entity_num];

}

ammo_give( weapon )
{
	// We assume before calling this function we already checked to see if the player has this weapon...

	// Should we give ammo to the player
	give_ammo = false; 

	// Check to see if ammo belongs to a primary weapon
	if( weapon != "fraggrenade" && weapon != "stielhandgranate" && weapon != "molotov" )
	{
		if( isdefined( weapon ) )  
		{
			// get the max allowed ammo on the current weapon
			stockMax = WeaponMaxAmmo( weapon ); 
	
			// Get the current weapon clip count
			clipCount = self GetWeaponAmmoClip( weapon ); 
	
			// compare it with the ammo player actually has, if more or equal just dont give the ammo, else do
			if( ( self getammocount( weapon ) - clipcount ) >= stockMax )	
			{
				give_ammo = false; 
			}
			else
			{
				give_ammo = true; // give the ammo to the player
			}
		}
				
	}
	else
	{
		// Ammo belongs to secondary weapon
		if( self hasweapon( weapon ) )
		{
			// Check if the player has less than max stock, if no give ammo
			if( self getammocount( weapon ) < WeaponMaxAmmo( weapon ) )
			{
				// give the ammo to the player
				give_ammo = true; 					
			}
		}		
	}	


	if( give_ammo )
	{
		self playsound( "cha_ching" ); 
		self GivemaxAmmo( weapon ); 
		return true;
	}

	if( !give_ammo )
	{
		return false;
	}
}

play_weapon_vo(weapon)
{
	players = getplayers();
	index = get_player_index(self);
	if(!IsDefined (level.zombie_weapons[weapon].sound))
	{
		return;
	}	

	if( level.zombie_weapons[weapon].sound != "" )
	{
		weap = level.zombie_weapons[weapon].sound;
		waittime = 0.05;
		switch(weap)
		{
			case "vox_crappy":
				if (level.vox_crappy_available.size < 1 )
				{
					level.vox_crappy_available = level.vox_crappy;
				}
				sound_to_play = random(level.vox_crappy_available);
				level.vox_crappy_available = array_remove(level.vox_crappy_available,sound_to_play);
				break;
			case "vox_flame":
				if (level.vox_flame_available.size < 1 )
				{
					level.vox_flame_available = level.vox_flame;
				}
				sound_to_play = random(level.vox_flame_available);
				level.vox_flame_available = array_remove(level.vox_flame_available,sound_to_play);
				break;
			case "vox_mg":
				if (level.vox_mg_available.size < 1 )
				{
					level.vox_mg_available = level.vox_mg;
				}
				sound_to_play = random(level.vox_mg_available);
				level.vox_mg_available = array_remove(level.vox_mg_available,sound_to_play);
				break;
/*			case "vox_ppsh":
				if (level.vox_ppsh_available.size < 1 )
				{
					level.vox_ppsh_available = level.vox_ppsh;
				}
				sound_to_play = random(level.vox_ppsh_available);
				level.vox_ppsh_available = array_remove(level.vox_ppsh_available,sound_to_play);
				break;*/
			case "vox_raygun":
				if (level.vox_raygun_available.size < 1 )
				{
					level.vox_raygun_available = level.vox_raygun;
				}
				sound_to_play = random(level.vox_raygun_available);
				level.vox_raygun_available = array_remove(level.vox_raygun_available,sound_to_play);
				waittime = 1.5;
				break;
			case "vox_shotgun":
				if (level.vox_shotgun_available.size < 1 )
				{
					level.vox_shotgun_available = level.vox_shotgun;
				}
				sound_to_play = random(level.vox_shotgun_available);
				level.vox_shotgun_available = array_remove(level.vox_shotgun_available,sound_to_play);
				break;
			case "vox_sniper":
				if (level.vox_sniper_available.size < 1 )
				{
					level.vox_sniper_available = level.vox_sniper;
				}
				sound_to_play = random(level.vox_sniper_available);
				level.vox_sniper_available = array_remove(level.vox_sniper_available,sound_to_play);
				break;	
			case "vox_thompson":
				if (level.vox_thompson_available.size < 1 )
				{
					level.vox_thompson_available = level.vox_thompson;
				}
				sound_to_play = random(level.vox_thompson_available);
				level.vox_thompson_available = array_remove(level.vox_thompson_available,sound_to_play);
				break;					
			
			default: 
				sound_var = randomintrange(0, level.zombie_weapons[weapon].variation_count);
				sound_to_play = level.zombie_weapons[weapon].sound + "_" + sound_var;
				
		}

		plr = "plr_" + index + "_";

		self maps\_zombiemode_spawner::do_player_playdialog(plr, sound_to_play, waittime);
	}
}

add_weapon_to_sound_array(vo,num)
{
	if(!isDefined(vo))
	{
		return;
	}
	player = getplayers();
	for(i=0;i<player.size;i++)
	{
		index = maps\_zombiemode_weapons::get_player_index(player);
		player_index = "plr_" + index + "_";
		num = maps\_zombiemode_spawner::get_number_variants(player_index + vo);
	}

	switch(vo)
	{
		case "vox_crappy":
			if(!isDefined(level.vox_crappy))
			{
				level.vox_crappy = [];
				for(i=0;i<num;i++)
				{
					level.vox_crappy[level.vox_crappy.size] = "vox_crappy_" + i;						
				}				
			}
			level.vox_crappy_available = level.vox_crappy;
			break;
		case "vox_flame":
			if(!isDefined(level.vox_flame))
			{
				level.vox_flame = [];
				for(i=0;i<num;i++)
				{
					level.vox_flame[level.vox_flame.size] = "vox_flame_" + i;						
				}				
			}
			level.vox_flame_available = level.vox_flame;
			break;
		case "vox_mg":
			if(!isDefined(level.vox_mg))
			{
				level.vox_mg = [];
				for(i=0;i<num;i++)
				{
					level.vox_mg[level.vox_mg.size] = "vox_mg_" + i;						
				}				
			}
			level.vox_mg_available = level.vox_mg;
			break;
/*		case "vox_ppsh":
			if(!isDefined(level.vox_ppsh))
			{
				level.vox_ppsh = [];
				for(i=0;i<num;i++)
				{
					level.vox_ppsh[level.vox_ppsh.size] = "vox_ppsh_" + i;						
				}				
			}
			level.vox_ppsh_available = level.vox_ppsh;
			break;*/
		case "vox_raygun":
			if(!isDefined(level.vox_raygun))
			{
				level.vox_raygun = [];
				for(i=0;i<num;i++)
				{
					level.vox_raygun[level.vox_raygun.size] = "vox_raygun_" + i;						
				}				
			}
			level.vox_raygun_available = level.vox_raygun;
			break;
		case "vox_shotgun":
			if(!isDefined(level.vox_shotgun))
			{
				level.vox_shotgun = [];
				for(i=0;i<num;i++)
				{
					level.vox_shotgun[level.vox_shotgun.size] = "vox_shotgun_" + i;						
				}				
			}
			level.vox_shotgun_available = level.vox_shotgun;
			break;
		case "vox_sniper":
			if(!isDefined(level.vox_sniper))
			{
				level.vox_sniper = [];
				for(i=0;i<num;i++)
				{
					level.vox_sniper[level.vox_sniper.size] = "vox_sniper_" + i;						
				}				
			}
			level.vox_sniper_available = level.vox_sniper;
			break;
		case "vox_thompson":
			if(!isDefined(level.vox_thompson))
			{
				level.vox_thompson = [];
				for(i=0;i<num;i++)
				{
					level.vox_thompson[level.vox_thompson.size] = "vox_thompson_" + i;						
				}				
			}
			level.vox_thompson_available = level.vox_thompson;
			break;
	}

}

flamethrower_swap()
{
	self endon( "death" ); // if we die we end, because we perma lose the flamethrower
	self endon( "disconnect" ); 
	
	while( 1 ) // once we get flamer, we need to do a loop so that we can easily remove it if we lose the weapon or remove/then re-add it if we are downed/revived
	{
		weapons = self GetWeaponsList(); 
		self.has_flame_thrower = false; 
		for( i = 0; i < weapons.size; i++ )
		{
			if( isSubStr(weapons[i], "flamethrower") )
			{
				self.has_flame_thrower = true; 
			}
		}
		
		if( self.has_flame_thrower )
		{
			if( !isdefined( self.flamethrower_attached ) || !self.flamethrower_attached )
			{
				self attach( "char_usa_raider_gear_flametank", "j_spine4" ); 
				self.flamethrower_attached = true; 
			}
		}
		else if( !self.has_flame_thrower ) // this could be either us downing or swapping out the weapon for a new weapon
		{
			if( isdefined( self.flamethrower_attached ) && self.flamethrower_attached )
			{
				self detach( "char_usa_raider_gear_flametank", "j_spine4" ); 
				self.flamethrower_attached = false;
			}
		}

		if(!self.has_flame_thrower && !self maps\_laststand::player_is_in_laststand()) // last stand becomes TRUE before we remove weapons, so luckily if we die and lose flamer, it will never accidently think we are still alive as FALSE laststand
		{
			//if we no longer have the flamer while still alive, this means we actualy chose to get  rid of the weapon
			// if we are in last stand, then we will skip this break because we know we have to re-add the tank if we are revived 
			break;
		}
		wait( 0.2 ); 
	}
}

/*

satchel crate

-texture: add question mark, make texture look better?
-add some type of glow
-add collission
-add trigger
	wait(2);
	level.satchel_crate_lid RotateTo( level.satchel_crate_lid.angles + (92,0,0), 0.3, 0.1, 0.1);

*/
islookingatorigin( origin )
{
	normalvec = vectorNormalize( origin-self getShootAtPos() );
	veccomp = vectorNormalize(( origin-( 0, 0, 24 ) )-self getShootAtPos() );
	insidedot = vectordot( normalvec, veccomp );
	
	anglevec = anglestoforward( self getplayerangles() );
	vectordot = vectordot( anglevec, normalvec );
	if( vectordot > insidedot )
		return true;
	else
		return false;
}
