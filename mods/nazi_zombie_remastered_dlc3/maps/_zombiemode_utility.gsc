#include maps\_utility; 
#include common_scripts\utility; 

init_utility()
{
//	level thread edge_fog_start(); 

//	level thread hudelem_count(); 
}

get_enemy_count()
{
	enemies = [];
	valid_enemies = [];
	enemies = GetAiSpeciesArray( "axis", "all" );
	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i].animname != "boss_zombie" )
		{
			valid_enemies = array_add( valid_enemies, enemies[i] );
		}
	}
	return valid_enemies.size;
}

spawn_zombie( spawner, target_name ) 
{ 
	spawner.script_moveoverride = true; 

	if( IsDefined( spawner.script_forcespawn ) && spawner.script_forcespawn ) 
	{ 
		guy = spawner StalingradSpawn();  
	} 
	else 
	{ 
		guy = spawner DoSpawn();  
	} 

	spawner.count = 666; 

//	// sometimes we want to ensure a zombie will go to a particular door node
//	// so we target the spawner at a struct and put the struct near the entry point
//	if( isdefined( spawner.target ) )
//	{
//		guy.forced_entry = getstruct( spawner.target, "targetname" ); 
//	}

	if( !spawn_failed( guy ) ) 
	{ 
		if( IsDefined( target_name ) ) 
		{ 
			guy.targetname = target_name; 
		} 

		return guy;  
	}

	return undefined;  
}

create_simple_hud( client )
{
	if( IsDefined( client ) )
	{
		hud = NewClientHudElem( client ); 
	}
	else
	{
		hud = NewHudElem(); 
	}

	level.hudelem_count++; 

	hud.foreground = true; 
	hud.sort = 1; 
	hud.hidewheninmenu = false; 

	return hud; 
}

destroy_hud()
{
	level.hudelem_count--; 
	self Destroy(); 
}

all_chunks_intact( barrier_chunks )
{
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( barrier_chunks[i].destroyed && !IsDefined( barrier_chunks[i].mid_repair ))
		{
			return false; 
		}
	}

	return true; 
}

all_chunks_destroyed( barrier_chunks )
{
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( !barrier_chunks[i].destroyed )
		{
			return false; 
		}
		if ( IsDefined( barrier_chunks[i].target_by_zombie ) )
		{
			return false;
		}
	}

	return true; 
}

check_point_in_playable_area( origin )
{
	playable_area = getentarray("playable_area","targetname");

	check_model = spawn ("script_model", origin + (0,0,40));
	
	valid_point = false;
	for (i = 0; i < playable_area.size; i++)
	{
		if (check_model istouching(playable_area[i]))
		{
			valid_point = true;
		}
	}
	
	check_model delete();
	return valid_point;
}

check_point_in_active_zone( origin )
{
	player_zones = GetEntArray( "player_zone", "script_noteworthy" );
	if( !isDefined( level.zones ) || !isDefined( player_zones ) )
	{
		return true;
	}
	
	scr_org = spawn( "script_origin", origin+(0, 0, 40) );
	
	one_valid_zone = false;
	for( i = 0; i < player_zones.size; i++ )
	{
		if( scr_org isTouching( player_zones[i] ) )
		{
			if( isDefined( level.zones[player_zones[i].targetname] ) && 
				isDefined( level.zones[player_zones[i].targetname].is_enabled ) )
			{
				one_valid_zone = true;
			}
		}
	}
	
	return one_valid_zone;
}

round_up_to_ten( score )
{
	new_score = score - score % 10; 
	if( new_score < score )
	{
		new_score += 10; 
	}
	return new_score; 
}

random_tan()
{
	rand = randomint( 100 ); 
	
	// PI_CHANGE_BEGIN - JMA - only 15% chance that we are going to spawn charred zombies in sumpf
	if(isDefined(level.script) && level.script == "nazi_zombie_sumpf")
	{
		percentNotCharred = 85;
	}
	else
	{
		percentNotCharred = 65;
	}
	
	if( rand > percentNotCharred )
	{
		self StartTanning(); 
	}
	// PI_CHANGE_END
}

// Returns the amount of places before the decimal, ie 1000 = 4, 100 = 3...
places_before_decimal( num )
{
	abs_num = abs( num ); 
	count = 0; 
	while( 1 )
	{
		abs_num *= 0.1; // Really doing num / 10
		count += 1; 

		if( abs_num < 1 )
		{
			return count; 
		}
	}
}

create_zombie_point_of_interest( attract_dist, num_attractors, added_poi_value, start_turned_on )
{
	if( !isDefined( added_poi_value ) )
	{
		self.added_poi_value = 0;
	}
	else
	{
		self.added_poi_value = added_poi_value;
	}
	
	if( !isDefined( start_turned_on ) )
	{
		start_turned_on = true;
	}
	
	self.script_noteworthy = "zombie_poi";
	self.poi_active = start_turned_on;

	if( isDefined( attract_dist ) )
	{
		self.poi_radius = attract_dist * attract_dist;
	}
	else // This poi has no maximum attract distance, it will attract all zombies
	{
		self.poi_radius = undefined;
	}
	self.num_poi_attracts = num_attractors;
	self.attract_to_origin = true;
}

create_zombie_point_of_interest_attractor_positions( num_attract_dists, diff_per_dist, attractor_width )
{
	forward = ( 0, 1, 0 );
	
	if( !isDefined( self.num_poi_attracts ) || self.script_noteworthy != "zombie_poi" )
	{
		return;
	}
	
	if( !isDefined( num_attract_dists ) )
	{
		num_attract_dists = 4;
	}
	
	if( !isDefined( diff_per_dist ) )
	{
		diff_per_dist = 45;
	}
	
	if( !isDefined( attractor_width ) )
	{
		attractor_width = 45;
	}
	
	self.attract_to_origin = false;
	
	self.num_attract_dists = num_attract_dists;
	
	// The last index in the attractor_position arrays for each of the four distances
	self.last_index = [];
	for( i = 0; i < num_attract_dists; i++ )
	{
		self.last_index[i] = -1;
	}
	
	self.attract_dists = [];
	for( i = 0; i < self.num_attract_dists; i++ )
	{
		self.attract_dists[i] = diff_per_dist * (i+1);
	}
	
	// Array of max positions per distance
	// 0 = close, 1 = med, 2 = far, 3 = very far
	max_positions = [];
	for( i = 0; i < self.num_attract_dists; i++ )
	{
		max_positions[i] = int(3.14*2*self.attract_dists[i]/attractor_width);
	}
	
	num_attracts_per_dist = self.num_poi_attracts/self.num_attract_dists;
	
	self.max_attractor_dist = self.attract_dists[ self.attract_dists.size - 1 ] * 1.1; // Give some wiggle room for assigning nodes
	
	diff = 0;
	
	self thread debug_draw_attractor_positions();
	
	// Determine the ideal number of attracts based on what a distance can actually hold after any bleed from closer
	// distances is added to the calculated
	actual_num_positions = [];
	for( i = 0; i < self.num_attract_dists; i++ )
	{
		if( num_attracts_per_dist > (max_positions[i]+diff) )
		{
			actual_num_positions[i] = max_positions[i];
			diff += num_attracts_per_dist - max_positions[i];
		}
		else
		{
			actual_num_positions[i] = num_attracts_per_dist + diff;
			diff = 0;
		}	
	}
	
	// Determine the actual positions that will be used, including failed nodes from closer distances, index zero is always the origin
	self.attractor_positions = [];
	failed = 0;
	angle_offset = 0; // Angle offset, used to make nodes not all perfectly radial
	prev_last_index = -1;
	for( j = 0; j < 4; j++ )
	{
		if( (actual_num_positions[j]+failed) < max_positions[j] )
		{
			actual_num_positions[j] += failed;
			failed = 0;
		}
		else if( actual_num_positions[j] < max_positions[j] ) 
		{
			actual_num_positions[j] = max_positions[j];
			failed = max_positions[j] - actual_num_positions[j];
		}
		failed += self generated_radius_attract_positions( forward, angle_offset, actual_num_positions[j], self.attract_dists[j] );
		angle_offset += 15;
		self.last_index[j] = int(actual_num_positions[j] - failed + prev_last_index);
		prev_last_index = self.last_index[j];
	}
	
	self notify( "attractor_positions_generated" );
}

generated_radius_attract_positions( forward, offset, num_positions, attract_radius )
{
	failed = 0;
	degs_per_pos = 360 / num_positions;
	for( i = offset; i < 360+offset; i += degs_per_pos )
	{
		altforward = forward * attract_radius;
		rotated_forward = ( (cos(i)*altforward[0] - sin(i)*altforward[1]), (sin(i)*altforward[0] + cos(i)*altforward[1]), altforward[2] );
		pos = maps\_zombiemode_server_throttle::server_safe_ground_trace( "poi_trace", 10, self.origin + rotated_forward + ( 0, 0, 100 ) );
		if( abs( pos[2] - self.origin[2] ) < 60 )
		{
			pos_array = [];
			pos_array[0] = pos;
			pos_array[1] = self;
			self.attractor_positions = array_add( self.attractor_positions , pos_array );
		}
		else
		{
			failed++;
		}
	}
	return failed;
}

debug_draw_attractor_positions()
{
	/#
	while( true )
	{
		while( !isDefined( self.attractor_positions ) )
		{
			wait( 0.05 );
			continue;
		}
		for( i = 0; i < self.attractor_positions.size; i++ )
		{
			Line( self.origin, self.attractor_positions[i][0], (1, 0, 0), true, 1 );
		}
		wait( 0.05 );
		if( !IsDefined( self ) )
		{
			return;
		}
	}
	#/
}


get_zombie_point_of_interest( origin )
{
	curr_radius = undefined;
	
	ent_array = getEntArray( "zombie_poi", "script_noteworthy" );
	
	best_poi = undefined;
	position = undefined;
	best_dist = 10000 * 10000;
	
	for( i = 0; i < ent_array.size; i++ )
	{
		if( !isDefined( ent_array[i].poi_active ) || !ent_array[i].poi_active  )
		{
			continue;
		}
		
		dist = distanceSquared( origin, ent_array[i].origin );
		
		dist -= ent_array[i].added_poi_value;
		
		if( isDefined( ent_array[i].poi_radius ) )
		{
			curr_radius = ent_array[i].poi_radius;
		}
		
		if( (!isDefined( curr_radius ) || dist < curr_radius) && dist < best_dist && ent_array[i] can_attract(self) )
		{
			best_poi = ent_array[i];
		}
	}
	
	if( isDefined( best_poi ) )
	{
		// Override, currently only used for monkeys in the air.
		if( isDefined( best_poi.attract_to_origin ) && best_poi.attract_to_origin ) 
		{
			position = [];
			position[0] = groundpos( best_poi.origin + (0, 0, 100) );
			position[1] = self;
		}
		else
		{
			position = self add_poi_attractor( best_poi );
		}
	}
	
	return position;
}

activate_zombie_point_of_interest()
{
	if( self.script_noteworthy != "zombie_poi" )
	{
		return;
	}
	
	self.poi_active = true;
}

deactivate_zombie_point_of_interest()
{
	if( self.script_noteworthy != "zombie_poi" )
	{
		return;
	}
	
	self.poi_active = false;
}

//PI_CHANGE_BEGIN - 6/18/09 JV This works to help set "wait" points near the stage if all players are in the process teleportation.  
//It is unlike the previous function in that you dictate the poi.
assign_zombie_point_of_interest (origin, poi)
{
	position = undefined;
	doremovalthread = false;

	if (IsDefined(poi) && poi can_attract(self))
	{
		//don't want to touch add poi attractor, but yeah, this is kind of weird
		if (!IsDefined(poi.attractor_array) || ( IsDefined(poi.attractor_array) && array_check_for_dupes( poi.attractor_array, self ) ))
			doremovalthread = true;
		
		position = self add_poi_attractor( poi );
		
		//now that I know this is the first time they've been added, set up the thread to remove them from the array
		if (IsDefined(position) && doremovalthread && !array_check_for_dupes( poi.attractor_array, self  ))
			self thread update_on_poi_removal( poi );		
	}
	
	return position;
}
//PI_CHANGE_END

remove_poi_attractor( zombie_poi )
{
	if( !isDefined( zombie_poi.attractor_array ) )
	{
		return;
	}
	
	for( i = 0; i < zombie_poi.attractor_array.size; i++ )
	{
		if( zombie_poi.attractor_array[i] == self )
		{
			self notify( "kill_poi" );
			
			zombie_poi.attractor_array = array_remove( zombie_poi.attractor_array, zombie_poi.attractor_array[i] );
			zombie_poi.claimed_attractor_positions = array_remove( zombie_poi.claimed_attractor_positions, zombie_poi.claimed_attractor_positions[i] );
		}
	}
}

add_poi_attractor( zombie_poi )
{
	if( !isDefined( zombie_poi ) )
	{
		return;
	}
	if( !isDefined( zombie_poi.attractor_array ) )
	{
		zombie_poi.attractor_array = [];
	}
	
	// If we are not yet an attractor to this poi, claim an attractor position and start attracting to it
	if( array_check_for_dupes( zombie_poi.attractor_array, self ) )
	{
		if( !isDefined( zombie_poi.claimed_attractor_positions ) )
		{
			zombie_poi.claimed_attractor_positions = [];
		}
		
		if( !isDefined( zombie_poi.attractor_positions ) || zombie_poi.attractor_positions.size <= 0 )
		{
			return undefined;
		}
		
		start = -1;
		end = -1;
		last_index = -1;
		for( i = 0; i < 4; i++ )
		{
			if( zombie_poi.claimed_attractor_positions.size < zombie_poi.last_index[i] ) 
			{
				start = last_index+1;
				end = zombie_poi.last_index[i];
				break;
			}
			last_index = zombie_poi.last_index[i];
		}
		
		
		best_dist = 10000*10000;
		best_pos = undefined;
		if( start < 0 )
		{
			start = 0;
		}
		if( end < 0 )
		{
			return undefined;
		}
		for( i = int(start); i <= int(end); i++ )
		{
			if( array_check_for_dupes( zombie_poi.claimed_attractor_positions, zombie_poi.attractor_positions[i] ) )
			{
				dist = distancesquared( zombie_poi.attractor_positions[i][0], self.origin );
				if( dist < best_dist || !isDefined( best_pos ) )
				{
					best_dist = dist;
					best_pos = zombie_poi.attractor_positions[i];
				}
			}
		}
		
		if( !isDefined( best_pos ) )
		{
			return undefined;
		}
		
		zombie_poi.attractor_array = array_add( zombie_poi.attractor_array, self );
		self thread update_poi_on_death( zombie_poi );		
		
		zombie_poi.claimed_attractor_positions = array_add( zombie_poi.claimed_attractor_positions, best_pos );
		
		return best_pos;
	}
	else
	{
		for( i = 0; i < zombie_poi.attractor_array.size; i++ )
		{
			if( zombie_poi.attractor_array[i] == self )
			{
				if( isDefined( zombie_poi.claimed_attractor_positions ) && isDefined( zombie_poi.claimed_attractor_positions[i] ) )
				{
					return zombie_poi.claimed_attractor_positions[i];
				}
			}
		}
	}
	
	return undefined;
}

can_attract( attractor )
{
	if( !isDefined( self.attractor_array ) )
	{
		self.attractor_array = [];
	}
	if( !array_check_for_dupes( self.attractor_array, attractor ) )
	{
		return true;
	}
	if( isDefined(self.num_poi_attracts) && self.attractor_array.size >= self.num_poi_attracts )
	{
		return false;
	}
	return true;
}

update_poi_on_death( zombie_poi )
{
	self endon( "kill_poi" );
	
	self waittill( "death" );
	self remove_poi_attractor( zombie_poi );
}

//PI_CHANGE_BEGIN - 6/18/09 JV This was set up to work with assign_zombie_point_of_interest (which works with the teleportation in theater).
//The poi attractor array needs to be emptied when a player is teleported out of projection room (if they were all in there).  
//As a result, we wait for the poi's death (I'm sending that notify via the level script)
update_on_poi_removal (zombie_poi )
{	
	zombie_poi waittill( "death" );
	
	if( !isDefined( zombie_poi.attractor_array ) )
		return;
	
	for( i = 0; i < zombie_poi.attractor_array.size; i++ )
	{
		if( zombie_poi.attractor_array[i] == self )
		{	
			zombie_poi.attractor_array = array_remove_index( zombie_poi.attractor_array, i );
			zombie_poi.claimed_attractor_positions = array_remove_index( zombie_poi.claimed_attractor_positions, i );
		}
	}
	
}
//PI_CHANGE_END

invalidate_attractor_pos( attractor_pos, zombie )
{
	if( !isDefined( self ) || !isDefined( attractor_pos ) )
	{
		wait( 0.1 );
		return undefined;
	}
	
	if( isDefined( self.attractor_positions) && !array_check_for_dupes( self.attractor_positions, attractor_pos ) )
	{
		index = 0;
		for( i = 0; i < self.attractor_positions.size; i++ )
		{
			if( self.attractor_positions[i] == attractor_pos )
			{
				index = i;
			}
		}
		
		for( i = 0; i < self.last_index.size; i++ )
		{
			if( index <= self.last_index[i] )
			{
				self.last_index[i]--;
			}
		}
		
		self.attractor_array = array_remove( self.attractor_array, zombie );
		self.attractor_positions = array_remove( self.attractor_positions, attractor_pos );
		for( i = 0; i < self.claimed_attractor_positions.size; i++ )
		{
			if( self.claimed_attractor_positions[i][0] == attractor_pos[0] )
			{
				self.claimed_attractor_positions = array_remove( self.claimed_attractor_positions, self.claimed_attractor_positions[i] );
			}
		}
	}
	else
	{
		wait( 0.1 );
	}
	
	return get_zombie_point_of_interest( zombie.origin );
}

get_closest_valid_player( origin, ignore_player )
{
	valid_player_found = false; 
	
	players = get_players();

	if( IsDefined( ignore_player ) )
	{
		players = array_remove( players, ignore_player );
	}

	while( !valid_player_found )
	{
		// find the closest player
		player = GetClosest( origin, players ); 

		if( !isdefined( player ) )
		{
			return undefined; 
		}
		
		// make sure they're not a zombie or in last stand
		if( !is_player_valid( player ) )
		{
			players = array_remove( players, player ); 
			continue; 
		}
		return player; 
	}
}

is_player_valid( player )
{
	if( !IsDefined( player ) ) 
	{
		return false; 
	}

	if( !IsAlive( player ) )
	{
		return false; 
	} 

	if( !IsPlayer( player ) )
	{
		return false;
	}

	if( player.is_zombie == true )
	{
		return false; 
	}

	if( player.sessionstate == "spectator" )
	{
		return false; 
	}

	if( player.sessionstate == "intermission" )
	{
		return false; 
	}

	if(  player maps\_laststand::player_is_in_laststand() )
	{
		return false; 
	}

	if ( player isnotarget() )
	{
		return false;
	}
	
	return true; 
}

in_revive_trigger()
{
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		if( !IsDefined( players[i] ) || !IsAlive( players[i] ) ) 
		{
			continue; 
		}
	
		if( IsDefined( players[i].revivetrigger ) )
		{
			if( self IsTouching( players[i].revivetrigger ) )
			{
				return true;
			}
		}
	}

	return false;
}

get_closest_node( org, nodes )
{
	return getClosest( org, nodes ); 
}

get_closest_2d( origin, ents )
{
	if( !IsDefined( ents ) )
	{
		return undefined; 
	}

	dist = Distance2d( origin, ents[0].origin ); 
	index = 0; 
	for( i = 1; i < ents.size; i++ )
	{
		temp_dist = Distance2d( origin, ents[i].origin ); 
		if( temp_dist < dist )
		{
			dist = temp_dist; 
			index = i; 
		}
	}

	return ents[index]; 
}

disable_trigger()
{
	if( !IsDefined( self.disabled ) || !self.disabled )
	{
		self.disabled = true; 
		self.origin = self.origin -( 0, 0, 10000 ); 
	}
}

enable_trigger()
{
	if( !IsDefined( self.disabled ) || !self.disabled )
	{
		return; 
	}

	self.disabled = false; 
	self.origin = self.origin +( 0, 0, 10000 ); 
}

//edge_fog_start()
//{
//	playpoint = getstruct( "edge_fog_start", "targetname" ); 
//
//	if( !IsDefined( playpoint ) )
//	{
//		
//	} 
//	
//	while( isdefined( playpoint ) )
//	{
//		playfx( level._effect["edge_fog"], playpoint.origin ); 
//		
//		if( !isdefined( playpoint.target ) )
//		{
//			return; 
//		}
//		
//		playpoint = getstruct( playpoint.target, "targetname" ); 
//	}
//}


//chris_p - fix bug with this not being an ent array!
in_playable_area()
{
	trigger = GetEntarray( "playable_area", "targetname" );

	if( !IsDefined( trigger ) )
	{
		println( "No playable area trigger found! Assume EVERYWHERE is PLAYABLE" );
		return true;
	}
	
	for(i=0;i<trigger.size;i++)
	{

		if( self IsTouching( trigger[i] ) )
		{
			return true;
		}
	}

	return false;
}

get_random_non_destroyed_chunk( barrier_chunks )
{
	chunk = undefined; 

	chunks = get_non_destroyed_chunks( barrier_chunks ); 

	if( IsDefined( chunks ) )
	{
		return chunks[RandomInt( chunks.size )]; 
	}

	return undefined; 
}

get_closest_non_destroyed_chunk( origin, barrier_chunks )
{
	chunk = undefined; 

	chunks = get_non_destroyed_chunks( barrier_chunks ); 

	if( IsDefined( chunks ) )
	{
		return get_closest_2d( origin, chunks ); 
	}

	return undefined; 
}

get_random_destroyed_chunk( barrier_chunks )
{
	chunk = undefined; 

	chunks = get_destroyed_chunks( barrier_chunks ); 

	if( IsDefined( chunks ) )
	{
		return chunks[RandomInt( chunks.size )]; 
	}

	return undefined; 
}

get_non_destroyed_chunks( barrier_chunks )
{
	array = []; 
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( !barrier_chunks[i].destroyed && !IsDefined(barrier_chunks[i].target_by_zombie) && !IsDefined(barrier_chunks[i].mid_repair) )
		{
			if ( barrier_chunks[i].origin == barrier_chunks[i].og_origin )
			{
				array[array.size] = barrier_chunks[i]; 
			}
		}
	}

	if( array.size == 0 )
	{
		return undefined; 
	}

	return array; 
}

get_destroyed_chunks( barrier_chunks )
{
	array = []; 
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( barrier_chunks[i].destroyed  && !isdefined( barrier_chunks[i].mid_repair ) )
		{
			array[array.size] = barrier_chunks[i]; 
		}
	}

	if( array.size == 0 )
	{
		return undefined; 
	}

	return array; 
}

is_float( num )
{
	val = num - int( num ); 

	if( val != 0 )
	{
		return true; 
	}
	else
	{
		return false; 
	}
}

array_limiter( array, total )
{
	new_array = []; 

	for( i = 0; i < array.size; i++ )
	{
		if( i < total )
		{
			new_array[new_array.size] = array[i]; 
		}
	}

	return new_array; 
}

array_validate( array )
{
	if( IsDefined( array ) && array.size > 0 )
	{
		return true;
	}
	else
	{
		return false;
	}
}

add_later_round_spawners()
{
	spawners = GetEntArray( "later_round_spawners", "script_noteworthy" );

	for( i = 0; i < spawners.size; i++ )
	{
		add_spawner( spawners[i] );
	}
}

add_spawner( spawner )
{
	if( IsDefined( spawner.script_start ) && level.round_number < spawner.script_start )
	{
		return;
	}

	if( IsDefined( spawner.locked_spawner ) && spawner.locked_spawner )
	{
		return;
	}

	if( IsDefined( spawner.has_been_added ) && spawner.has_been_added )
	{
		return;
	}

	spawner.has_been_added = true;

	level.enemy_spawns[level.enemy_spawns.size] = spawner; 
}

fake_physicslaunch( target_pos, power )
{
	start_pos = self.origin; 
	
	///////// Math Section
	// Reverse the gravity so it's negative, you could change the gravity
	// by just putting a number in there, but if you keep the dvar, then the
	// user will see it change.
	gravity = GetDvarInt( "g_gravity" ) * -1; 

	dist = Distance( start_pos, target_pos ); 
	
	time = dist / power; 
	delta = target_pos - start_pos; 
	drop = 0.5 * gravity *( time * time ); 
	
	velocity = ( ( delta[0] / time ), ( delta[1] / time ), ( delta[2] - drop ) / time ); 
	///////// End Math Section

	level thread draw_line_ent_to_pos( self, target_pos );
	self MoveGravity( velocity, time );
	return time;
}

//
// Spectating ===================================================================
//
add_to_spectate_list()
{
	if( !IsDefined( level.spectate_list ) )
	{
		level.spectate_list = [];
	}

	level.spectate_list[level.spectate_list.size] = self;
} 

remove_from_spectate_list()
{
	if( !IsDefined( level.spectate_list ) )
	{
		return undefined;
	}

	level.spectate_list = array_remove( level.spectate_list, self );
}

get_next_from_spectate_list( ent )
{
	index = 0;
	for( i = 0; i < level.spectate_list.size; i++ )
	{
		if( ent == level.spectate_list[i] )
		{
			index = i;
		}
	}

	index++;

	if( index >= level.spectate_list.size )
	{
		index = 0;
	}
	
	return level.spectate_list[index];
}

get_random_from_spectate_list()
{
	return level.spectate_list[RandomInt(level.spectate_list.size)];
}

//
// STRINGS ======================================================================= 
// 
add_zombie_hint( ref, text )
{
	if( !IsDefined( level.zombie_hints ) )
	{
		level.zombie_hints = []; 
	}

	PrecacheString( text ); 
	level.zombie_hints[ref] = text; 
}

get_zombie_hint( ref )
{
	if( IsDefined( level.zombie_hints[ref] ) )
	{
		return level.zombie_hints[ref]; 
	}

/#
	println( "UNABLE TO FIND HINT STRING " + ref ); 
#/
	return level.zombie_hints["undefined"]; 
}

// self is the trigger( usually spawned in on the fly )
// ent is the entity that has the script_hint info
set_hint_string( ent, default_ref )
{
	if( IsDefined( ent.script_hint ) )
	{
		self SetHintString( get_zombie_hint( ent.script_hint ) ); 
	}
	else
	{
		self SetHintString( get_zombie_hint( default_ref ) ); 
	}
}

//
// SOUNDS =========================================================== 
// 

add_sound( ref, alias )
{
	if( !IsDefined( level.zombie_sounds ) )
	{
		level.zombie_sounds = []; 
	}

	level.zombie_sounds[ref] = alias; 
}

play_sound_at_pos( ref, pos, ent )
{
	if( IsDefined( ent ) )
	{
		if( IsDefined( ent.script_soundalias ) )
		{
			PlaySoundAtPosition( ent.script_soundalias, pos ); 
			return;
		}

		if( IsDefined( self.script_sound ) )
		{
			ref = self.script_sound; 
		}
	}

	if( ref == "none" )
	{
		return; 
	}

	if( !IsDefined( level.zombie_sounds[ref] ) )
	{
		AssertMsg( "Sound \"" + ref + "\" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." ); 
		return; 
	}
	
	PlaySoundAtPosition( level.zombie_sounds[ref], pos ); 
}

play_sound_on_ent( ref )
{
	if( IsDefined( self.script_soundalias ) )
	{
		self PlaySound( self.script_soundalias ); 
		return;
	}

	if( IsDefined( self.script_sound ) )
	{
		ref = self.script_sound; 
	}

	if( ref == "none" )
	{
		return; 
	}

	if( !IsDefined( level.zombie_sounds[ref] ) )
	{
		AssertMsg( "Sound \"" + ref + "\" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." ); 
		return; 
	}

	self PlaySound( level.zombie_sounds[ref] ); 
}

play_loopsound_on_ent( ref )
{
	if( IsDefined( self.script_firefxsound ) )
	{
		ref = self.script_firefxsound; 
	}

	if( ref == "none" )
	{
		return; 
	}

	if( !IsDefined( level.zombie_sounds[ref] ) )
	{
		AssertMsg( "Sound \"" + ref + "\" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." ); 
		return; 
	}

	self PlaySound( level.zombie_sounds[ref] ); 
}


string_to_float( string )
{
	floatParts = strTok( string, "." );
	if ( floatParts.size == 1 )
		return int(floatParts[0]);

	whole = int(floatParts[0]);
	decimal = int(floatParts[1]);
	while ( decimal > 1 )
		decimal *= 0.1;

	if ( whole >= 0 )
		return (whole + decimal);
	else
		return (whole - decimal);
}

//
// TABLE LOOK SECTION ============================================================
// 

set_zombie_var( var, value, div, is_float )
{
	// First look it up in the table
	table = "mp/zombiemode.csv";
	table_value = TableLookUp( table, 0, var, 1 );

	if ( !IsDefined( is_float ) )
	{
		is_float = false;
	}

	if( IsDefined( table_value ) && table_value != "" )
	{
		if( is_float )
		{
			value = string_to_float( table_value );
		}
		else
		{
			value = int( table_value );
		}
	}

	if( IsDefined( div ) )
	{
		value = value / div;
	}

	level.zombie_vars[var] = value;
}

//
// DEBUG SECTION ================================================================= 
// 
// shameless stole from austin
debug_ui()
{
/#
	wait 1; 
	
	x = 510; 
	y = 280; 
	menu_name = "zombie debug"; 

	menu_bkg = maps\_debug::new_hud( menu_name, undefined, x, y, 1 ); 
	menu_bkg SetShader( "white", 160, 120 ); 
	menu_bkg.alignX = "left"; 
	menu_bkg.alignY = "top"; 
	menu_bkg.sort = 10; 
	menu_bkg.alpha = 0.6; 	
	menu_bkg.color = ( 0.0, 0.0, 0.5 ); 

	menu[0] = maps\_debug::new_hud( menu_name, "SD:", 		x + 5, y + 10, 1 ); 
	menu[1] = maps\_debug::new_hud( menu_name, "ZH:", 		x + 5, y + 20, 1 ); 
	menu[1] = maps\_debug::new_hud( menu_name, "ZS:", 		x + 5, y + 30, 1 ); 
	menu[1] = maps\_debug::new_hud( menu_name, "WN:", 		x + 5, y + 40, 1 ); 

	x_offset = 120; 

	// enum
	spawn_delay			 = menu.size; 
	zombie_health		 = menu.size + 1; 
	zombie_speed		 = menu.size + 2; 
	round_number			 = menu.size + 3; 

	menu[spawn_delay]		 = maps\_debug::new_hud( menu_name, "", x + x_offset, y + 10, 1 ); 
	menu[zombie_health]	 = maps\_debug::new_hud( menu_name, "", x + x_offset, y + 20, 1 ); 
	menu[zombie_speed]	 = maps\_debug::new_hud( menu_name, "", x + x_offset, y + 30, 1 ); 
	menu[round_number]	 = 	maps\_debug::new_hud( menu_name, "", x + x_offset, y + 40, 1 ); 
	
	while( true )
	{
		wait( 0.05 ); 

		menu[spawn_delay]		SetText( level.zombie_vars["zombie_spawn_delay"] ); 
		menu[zombie_health]		SetText( level.zombie_health ); 
		menu[zombie_speed] 		SetText( level.zombie_move_speed ); 
		menu[round_number] 		SetText( level.round_number ); 
	}
#/
}

hudelem_count()
{
/#
	max = 0; 
	curr_total = 0; 
	while( 1 )
	{
		if( level.hudelem_count > max )
		{
			max = level.hudelem_count; 
		}
		
		println( "HudElems: " + level.hudelem_count + "[Peak: " + max + "]" ); 
		wait( 0.05 ); 
	}
#/
}

debug_round_advancer()
{
/#
	while( 1 )
	{
		zombs = getaiarray( "axis" ); 
		
		for( i = 0; i < zombs.size; i++ )
		{
			zombs[i] dodamage( zombs[i].health * 100, ( 0, 0, 0 ) ); 
			wait 0.5; 
		}
	}	
#/
}

print_run_speed( speed )
{
/#
	self endon( "death" ); 
	while( 1 )
	{
		print3d( self.origin +( 0, 0, 64 ), speed, ( 1, 1, 1 ) ); 
		wait 0.05; 
	}
#/
}

draw_line_ent_to_ent( ent1, ent2 )
{
/#
	if( GetDvarInt( "zombie_debug" ) != 1 )
	{
		return; 
	}

	ent1 endon( "death" ); 
	ent2 endon( "death" ); 

	while( 1 )
	{
		line( ent1.origin, ent2.origin ); 
		wait( 0.05 ); 
	}
#/
}

draw_line_ent_to_pos( ent, pos, end_on )
{
/#
	if( GetDvarInt( "zombie_debug" ) != 1 )
	{
		return; 
	}

	ent endon( "death" ); 

	ent notify( "stop_draw_line_ent_to_pos" ); 
	ent endon( "stop_draw_line_ent_to_pos" ); 

	if( IsDefined( end_on ) )
	{
		ent endon( end_on ); 
	}

	while( 1 )
	{
		line( ent.origin, pos ); 
		wait( 0.05 ); 
	}
#/
}

debug_print( msg )
{
/#
	if( GetDvarInt( "zombie_debug" ) > 0 )
	{
		println( "######### ZOMBIE: " + msg ); 
	}
#/
}

debug_blocker( pos, rad, height )
{
/#
	self notify( "stop_debug_blocker" );
	self endon( "stop_debug_blocker" );
	
	for( ;; )
	{
		if( GetDvarInt( "zombie_debug" ) != 1 )
		{
			return;
		}

		wait( 0.05 ); 
		drawcylinder( pos, rad, height ); 
		
	}
#/
}

drawcylinder( pos, rad, height )
{
/#
	currad = rad; 
	curheight = height; 

	for( r = 0; r < 20; r++ )
	{
		theta = r / 20 * 360; 
		theta2 = ( r + 1 ) / 20 * 360; 

		line( pos +( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos +( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) ); 
		line( pos +( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos +( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) ); 
		line( pos +( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos +( cos( theta ) * currad, sin( theta ) * currad, curheight ) ); 
	}
#/
}

print3d_at_pos( msg, pos, thread_endon, offset )
{
/#
	self endon( "death" ); 

	if( IsDefined( thread_endon ) )
	{
		self notify( thread_endon ); 
		self endon( thread_endon ); 
	}

	if( !IsDefined( offset ) )
	{
		offset = ( 0, 0, 0 ); 
	}

	while( 1 )
	{
		print3d( self.origin + offset, msg ); 
		wait( 0.05 ); 
	}
#/
}

debug_breadcrumbs()
{
/#
	self endon( "disconnect" ); 

	while( 1 )
	{
		if( GetDvarInt( "zombie_debug" ) != 1 )
		{
			wait( 1 ); 
			continue; 
		}

		for( i = 0; i < self.zombie_breadcrumbs.size; i++ )
		{
			drawcylinder( self.zombie_breadcrumbs[i], 5, 5 );
		}

		wait( 0.05 ); 
	}
#/
}

debug_attack_spots_taken()
{
/#
	while( 1 )
	{
		if( GetDvarInt( "zombie_debug" ) != 2 )
		{
			wait( 1 ); 
			continue; 
		}

		wait( 0.05 );
		count = 0;
		for( i = 0; i < self.attack_spots_taken.size; i++ )
		{
			if( self.attack_spots_taken[i] )
			{
				count++;
			}
		}

		msg = "" + count + " / " + self.attack_spots_taken.size;
		print3d( self.origin, msg );
	}
#/
}

float_print3d( msg, time )
{
/#
	self endon( "death" );

	time = GetTime() + ( time * 1000 );
	offset = ( 0, 0, 72 );
	while( GetTime() < time )
	{
		offset = offset + ( 0, 0, 2 );
		print3d( self.origin + offset, msg, ( 1, 1, 1 ) );
		wait( 0.05 );
	}
#/
}
do_player_vo(snd, variation_count)
{

	
	index = maps\_zombiemode_weapons::get_player_index(self);	
	sound = "plr_" + index + "_" + snd; 
	if(IsDefined (variation_count))
	{
		sound = sound + "_" + randomintrange(0, variation_count);
	}
	if(!isDefined(level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	
	if (level.player_is_speaking == 0)
	{	
		level.player_is_speaking = 1;
		self playsound(sound, "sound_done");			
		self waittill("sound_done");
		//This ensures that there is at least 3 seconds waittime before playing another VO.
		wait(2);
		level.player_is_speaking = 0;
	}	
}
player_killstreak_timer()
{
	if(getdvar ("zombie_kills") == "") 
	{
		setdvar ("zombie_kills", "7");
	}	
	if(getdvar ("zombie_kill_timer") == "") 
	{
		setdvar ("zombie_kill_timer", "5");
	}

	kills = getdvarint("zombie_kills");
	time = getdvarint("zombie_kill_timer");

	if (!isdefined (self.timerIsrunning))	
	{
		self.timerIsrunning = 0;
	}

	while(1)
	{
		self waittill("zom_kill");	
		self.killcounter ++;

		if (self.timerIsrunning != 1)	
		{
			self.timerIsrunning = 1;
			self thread timer_actual(kills, time);			
//			iprintlnbold ("killstreak counter started");
		}
	}	

}
timer_actual(kills, time)
{

	timer = gettime() + (time * 1000);
	while(getTime() < timer)
	{
		
//		iprintlnbold ("timer:" + (getTime() + timer * .0001));
//		iprintlnbold ("kills: " + self.killcounter);

		if (self.killcounter > kills)
		{
			//playsoundatposition ("ann_vox_killstreak", (0,0,0));
			//wait(3);

			self play_killstreak_dialog();

//			self thread do_player_vo("vox_killstreak", 9);
			wait(1);
		
			//resets the killcounter and the timer 
			//self.killcounter = 0;

			 timer = -1;
		}
		wait(0.1);
	}

//	iprintlnbold ("Timer Is Out, Resetting Kills and Time");
	self.killcounter = 0;
	self.timerIsrunning = 0;
}
play_killstreak_dialog()
{
		index = maps\_zombiemode_weapons::get_player_index(self);
		player_index = "plr_" + index + "_";	

		//num_variants = 12;
		waittime = 0.25;
		if(!IsDefined (self.vox_killstreak))
		{
			num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_killstreak");
			self.vox_killstreak = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_killstreak[self.vox_killstreak.size] = "vox_killstreak_" + i;	
			}
			self.vox_killstreak_available = self.vox_killstreak;
		}
		sound_to_play = random(self.vox_killstreak_available);
		self.vox_killstreak_available = array_remove(self.vox_killstreak_available,sound_to_play);

	//	iprintlnbold("LINE:" + player_index + sound_to_play);

		self do_player_killstreak_dialog(player_index, sound_to_play, waittime);

		//self playsound(player_index + sound_to_play, "sound_done" + sound_to_play);			
		//self waittill("sound_done" + sound_to_play);

		wait(waittime);
		if (self.vox_killstreak_available.size < 1 )
		{
			self.vox_killstreak_available = self.vox_killstreak;
		}
		//This ensures that there is at least 3 seconds waittime before playing another VO.

}
do_player_killstreak_dialog(player_index, sound_to_play, waittime)
{
	if(!IsDefined(level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	if(level.player_is_speaking != 1)
	{
		level.player_is_speaking = 1;
		self playsound(player_index + sound_to_play, "sound_done" + sound_to_play);			
		self waittill("sound_done" + sound_to_play);
		wait(waittime);		
		level.player_is_speaking = 0;
	}
}

is_magic_bullet_shield_enabled( ent )
{
	if( !IsDefined( ent ) )
		return false;

	return ( IsDefined( ent.magic_bullet_shield ) && ent.magic_bullet_shield == true );
}

enemy_is_dog()
{
	return ( self.type == "dog" );
}


really_play_2D_sound(sound)
{
	temp_ent = spawn("script_origin", (0,0,0));
	temp_ent playsound (sound, sound + "wait");
	temp_ent waittill (sound + "wait");
	wait(0.05);
	temp_ent delete();	

}


play_sound_2D(sound)
{
	level thread really_play_2D_sound(sound);
	
	/*
	if(!isdefined(level.playsound2dent))
	{
		level.playsound2dent = spawn("script_origin",(0,0,0));
	}
	
	//players=getplayers();
	level.playsound2dent playsound ( sound );
	*/
	/*
	temp_ent = spawn("script_origin", (0,0,0));
	temp_ent playsound (sound, sound + "wait");
	temp_ent waittill (sound + "wait");
	wait(0.05);
	temp_ent delete();	
	*/
	
	
}

create_and_play_dialog( player_index, dialog_category, waittime, response )
{              
	if( !IsDefined ( self.sound_dialog ) )
	{
		self.sound_dialog = [];
		self.sound_dialog_available = [];
	}
				
	if ( !IsDefined ( self.sound_dialog[ dialog_category ] ) )
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants( player_index + dialog_category );                  
		assertex( num_variants > 0, "No dialog variants found for category: " + dialog_category );
		
		for( i = 0; i < num_variants; i++ )
		{
			self.sound_dialog[ dialog_category ][ i ] = i;     
		}	
		
		self.sound_dialog_available[ dialog_category ] = [];
	}
	
	if ( self.sound_dialog_available[ dialog_category ].size <= 0 )
	{
		self.sound_dialog_available[ dialog_category ] = self.sound_dialog[ dialog_category ];
	}
  
	variation = random( self.sound_dialog_available[ dialog_category ] );
	self.sound_dialog_available[ dialog_category ] = array_remove( self.sound_dialog_available[ dialog_category ], variation );

	sound_to_play = dialog_category + "_" + variation;
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, waittime, response);
}

/*
setup_response_waittime( sound_to_play )
{
	level waittill( "player_vox_done" );
	level notify( "play_response_line" );
}
*/

setup_response_line( player, index, response )
{
	if(index == 0) //DEMPSEY: Hero Nikolai, Rival Richtofen
	{
		setup_rival_hero( player, 1, 3, response );	
	}
	if(index == 1) //NICKOLAI: Hero Richtofen, Rival Takeo
	{		
		setup_rival_hero( player, 3, 2, response );
	}		
	if(index == 2) //TAKEO: Hero Dempsey, Rival Nickolai
	{
		setup_rival_hero( player, 0, 1, response );	
	}
	if(index == 3) //RICHTOFEN: Hero Nickolai, Rival Dempsey
	{
		setup_rival_hero( player, 2, 0, response );
	}
	return;
}

setup_rival_hero( player, hero, rival, response )
{
	players = getplayers();

	playHero = isdefined(players[hero]);
	playRival = isdefined(players[rival]);
	
	if(playHero && playRival)
	{
		if(randomfloatrange(0,1) < .5)
		{
			playRival = false;
		}
		else
		{
			playHero = false;
		}
	}	
	if( playHero )
	{		
		if( distancesquared (player.origin, players[hero].origin) < 500*500)
		{
			plr = "plr_" + hero + "_";
			players[hero] create_and_play_responses( plr, "vox_hr_" + response, 0.25 );
		}
		else
		{
			if(isdefined( players[rival] ) )
			{
				playRival = true;
			}
		}
	}		
	if( playRival )
	{
		if( distancesquared (player.origin, players[rival].origin) < 500*500)
		{
			plr = "plr_" + rival + "_";
			players[rival] create_and_play_responses( plr, "vox_riv_" + response, 0.25 );
		}
	}
}

create_and_play_responses( player_index, dialog_category, waittime )
{              	
	if( !IsDefined ( self.sound_dialog ) )
	{
		self.sound_dialog = [];
		self.sound_dialog_available = [];
	}
				
	if ( !IsDefined ( self.sound_dialog[ dialog_category ] ) )
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants( player_index + dialog_category );                  
		assertex( num_variants > 0, "No dialog variants found for category: " + dialog_category );
		
		for( i = 0; i < num_variants; i++ )
		{
			self.sound_dialog[ dialog_category ][ i ] = i;     
		}	
		
		self.sound_dialog_available[ dialog_category ] = [];
	}
	
	if ( self.sound_dialog_available[ dialog_category ].size <= 0 )
	{
		self.sound_dialog_available[ dialog_category ] = self.sound_dialog[ dialog_category ];
	}
  
	variation = random( self.sound_dialog_available[ dialog_category ] );
	self.sound_dialog_available[ dialog_category ] = array_remove( self.sound_dialog_available[ dialog_category ], variation );

	sound_to_play = dialog_category + "_" + variation;
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, waittime);
}

include_weapon( weapon_name, in_box, weighting_func )
{
	if( !isDefined( in_box ) )
	{
		in_box = true;
	}
	maps\_zombiemode_weapons::include_zombie_weapon( weapon_name, in_box, weighting_func );
}

include_powerup( powerup_name )
{
	maps\_zombiemode_powerups::include_zombie_powerup( powerup_name );
}

include_achievement( achievement, var1, var2, var3, var4 )
{
	maps\_zombiemode_achievement::init( achievement, var1, var2, var3, var4 );
}
achievement_notify( notify_name )
{
	self notify( notify_name );
}