#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;


#using_animtree( "generic_human" ); 
init()
{
	level.zombie_move_speed = 1; 
	level.zombie_health = 150; 

	zombies = getEntArray( "zombie_spawner", "script_noteworthy" ); 
	later_rounds = getentarray("later_round_spawners", "script_noteworthy" );
	
	zombies = array_combine( zombies, later_rounds );

	for( i = 0; i < zombies.size; i++ )
	{
		if( is_spawner_targeted_by_blocker( zombies[i] ) )
		{
			zombies[i].locked_spawner = true;
		}
	}
	
	array_thread(zombies, ::add_spawn_function, ::zombie_spawn_init);
	array_thread(zombies, ::add_spawn_function, ::zombie_rise);
	
}

#using_animtree( "generic_human" ); 
is_spawner_targeted_by_blocker( ent )
{
	if( IsDefined( ent.targetname ) )
	{
		targeters = GetEntArray( ent.targetname, "target" );

		for( i = 0; i < targeters.size; i++ )
		{
			if( targeters[i].targetname == "zombie_door" || targeters[i].targetname == "zombie_debris" )
			{
				return true;
			}

			result = is_spawner_targeted_by_blocker( targeters[i] );
			if( result )
			{
				return true;
			}
		}
	}

	return false;
}

// set up zombie walk cycles
zombie_spawn_init( animname_set )
{
    if( !isDefined( animname_set ) )
    {
		animname_set = false;
    }

	self.targetname = "zombie";
	self.script_noteworthy = undefined;

    if( !animname_set )
	{
		self.animname = "zombie"; 		
	}
	self.ignoreall = true; 
	self.allowdeath = true; 			// allows death during animscripted calls
	self.gib_override = true; 		// needed to make sure this guy does gibs
	self.is_zombie = true; 			// needed for melee.gsc in the animscripts
	self.has_legs = true; 			// Sumeet - This tells the zombie that he is allowed to stand anymore or not, gibbing can take 
									// out both legs and then the only allowed stance should be prone.
	
	self allowedStances( "stand" );

	self.gibbed = false; 
	self.head_gibbed = false;
	
	// might need this so co-op zombie players cant block zombie pathing
	if( getDvarInt( "grabby_zombies") == 1 )
	{
		self PushPlayer( true ); 
	}
	else
	{
		self PushPlayer( false);
	}
//	self.meleeRange = 128; 
//	self.meleeRangeSq = anim.meleeRange * anim.meleeRange; 
	
	animscripts\shared::placeWeaponOn( self.primaryweapon, "none" ); 
	
	// This isn't working, might need an "empty" weapon
	//self animscripts\shared::placeWeaponOn( self.weapon, "none" ); 

	self.disableArrivals = true; 
	self.disableExits = true; 
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true; 	
	self.suppressionThreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;

	self.badplaceawareness = 0;
	self.chatInitialized = false; 

	self disable_pain(); 

	self.maxhealth = level.zombie_health; 
	self.health = level.zombie_health; 
	self.dropweapon = false; 
	level thread zombie_death_event( self ); 

	// We need more script/code to get this to work properly
//	self add_to_spectate_list();
	self random_tan(); 
	self set_zombie_run_cycle(); 
	self thread zombie_think(); 
	self thread zombie_gib_on_damage(); 
	self thread zombie_damage_failsafe();

//	self thread zombie_head_gib(); 
	self thread delayed_zombie_eye_glow();	// delayed eye glow for ground crawlers (the eyes floated above the ground before the anim started)
	self.deathFunction = ::zombie_death_animscript;
	self.flame_damage_time = 0;

	self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );

	self notify( "zombie_init_done" );
}

/*
delayed_zombie_eye_glow:
Fixes problem where zombies that climb out of the ground are warped to their start positions
and their eyes glowed above the ground for a split second before their animation started even
though the zombie model is hidden. and applying this delay to all the zombies doesn't really matter.
*/
delayed_zombie_eye_glow()
{
	wait .5;
	self zombie_eye_glow();
}

zombie_damage_failsafe()
{
	self endon ("death");

	continue_failsafe_damage = false;	
	while (1)
	{
		//should only be for zombie exploits
		wait 0.5;
		
		if (!isdefined(self.enemy))
		{
			continue;
		}
		
		if (self istouching(self.enemy))
		{
			old_org = self.origin;
			if (!continue_failsafe_damage)
			{
				wait 5;
			}
			
			if (!isdefined(self.enemy) || self.enemy hasperk("specialty_armorvest"))
			{
				continue;
			}
		
			if (self istouching(self.enemy) 
				&& !self.enemy maps\_laststand::player_is_in_laststand()
				&& isalive(self.enemy))
			{
				if (distancesquared(old_org, self.origin) < (35 * 35) ) 
				{
					setsaveddvar("player_deathInvulnerableTime", 0);
					self.enemy DoDamage( self.enemy.health + 1000, self.enemy.origin, undefined, undefined, "riflebullet" );
					setsaveddvar("player_deathInvulnerableTime", level.startInvulnerableTime);	
				
					continue_failsafe_damage = true;
				}
			}
		}
		else
		{
			continue_failsafe_damage = false;
		}
	}
}

set_zombie_run_cycle()
{
	self set_run_speed();

	death_anims = level._zombie_deaths[self.animname];

	self.deathanim = random(death_anims);

	if(level.round_number < 3)
	{
		self.zombie_move_speed = "walk";
	}

	switch(self.zombie_move_speed)
	{
	case "walk":
		var = randomintrange(1, 9);         
		self set_run_anim( "walk" + var );                         
		self.run_combatanim = level.scr_anim[self.animname]["walk" + var];
		break;
	case "run":                                
		var = randomintrange(1, 6);
		self set_run_anim( "run" + var );               
		self.run_combatanim = level.scr_anim[self.animname]["run" + var];
		break;
	case "sprint":                 
		var = randomintrange(1, 13); // For rest of the game

		if(level.round_number < 11 || getDvarInt( "super_sprinters") == 1 ) // For early game to prevent random extra-super sprinters
		{
			var = randomintrange(1, 10);	
		}
		
		self set_run_anim( "sprint" + var );                       
		self.run_combatanim = level.scr_anim[self.animname]["sprint" + var];
		break;
	}
}

set_run_speed()
{
	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 35 ); 
	
//	self thread print_run_speed( rand );
	if( rand <= 35 )
	{
		self.zombie_move_speed = "walk"; 
	}
	else if( rand <= 70 )
	{
		self.zombie_move_speed = "run"; 
	}
	else
	{	
		self.zombie_move_speed = "sprint"; 
	}
}

// this is the main zombie think thread that starts when they spawn in
zombie_think()
{
	self endon( "death" ); 
	
	//node = level.exterior_goals[randomint( level.exterior_goals.size )]; 
	
	//CHRIS_P - test dudes rising from ground 
	if (GetDVarInt("zombie_rise_test") || (isDefined(self.script_string) && self.script_string == "riser" && randomint(100) > 25))
	{
		self.do_rise = 1;
		//self notify("do_rise");
		self waittill("risen");
	}
	else
	{
		self notify("no_rise");
	}
	
	node = undefined;

	desired_nodes = [];
	self.entrance_nodes = [];

	if( IsDefined( self.script_forcegoal ) && self.script_forcegoal )
	{
		desired_origin = get_desired_origin();

		AssertEx( IsDefined( desired_origin ), "Spawner @ " + self.origin + " has a script_forcegoal but did not find a target" );
	
		origin = desired_origin;
			
		node = getclosest( origin, level.exterior_goals ); 	
		self.entrance_nodes[0] = node;

		self zombie_history( "zombie_think -> #1 entrance (script_forcegoal) origin = " + self.entrance_nodes[0].origin );
	}
	else
	{
		origin = self.origin;

		desired_origin = get_desired_origin();
		if( IsDefined( desired_origin ) )
		{
			origin = desired_origin;
		}

		// Get the 3 closest nodes
		nodes = get_array_of_closest( origin, level.exterior_goals, undefined, 3 );

		// Figure out the distances between them, if any of them are greater than 256 units compared to the previous, drop it
		max_dist = 500;
		desired_nodes[0] = nodes[0];
		prev_dist = Distance( self.origin, nodes[0].origin );
		for( i = 1; i < nodes.size; i++ )
		{
			dist = Distance( self.origin, nodes[i].origin );
			if( ( dist - prev_dist ) > max_dist )
			{
				break;
			}

			prev_dist = dist;
			desired_nodes[i] = nodes[i];
		}

		node = desired_nodes[0];
		if( desired_nodes.size > 1 )
		{
			node = desired_nodes[RandomInt(desired_nodes.size)];
		}

		self.entrance_nodes = desired_nodes;

		self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );

		// Incase the guy does not move from spawn, then go to the closest one instead
		self thread zombie_assure_node();
	}

	AssertEx( IsDefined( node ), "Did not find a node!!! [Should not see this!]" );

	level thread draw_line_ent_to_pos( self, node.origin, "goal" );

	self.first_node = node;

	self thread zombie_goto_entrance( node );
}

get_desired_origin()
{
	if( IsDefined( self.target ) )
	{
		ent = GetEnt( self.target, "targetname" );
		if( !IsDefined( ent ) )
		{
			ent = getstruct( self.target, "targetname" );
		}
	
		if( !IsDefined( ent ) )
		{
			ent = GetNode( self.target, "targetname" );
		}
	
		AssertEx( IsDefined( ent ), "Cannot find the targeted ent/node/struct, \"" + self.target + "\" at " + self.origin );
	
		return ent.origin;
	}

	return undefined;
}

zombie_goto_entrance( node, endon_bad_path )
{
	self endon( "death" );
	level endon( "intermission" );

	if( IsDefined( endon_bad_path ) && endon_bad_path )
	{
		// If we cannot go to the goal, then end...
		// Used from find_flesh
		self endon( "bad_path" );
	}

	self zombie_history( "zombie_goto_entrance -> start goto entrance " + node.origin );

	self.got_to_entrance = false;
	self.goalradius = 128; 
	self SetGoalPos( node.origin );
	self waittill( "goal" ); 
	self.got_to_entrance = true;

	self zombie_history( "zombie_goto_entrance -> reached goto entrance " + node.origin );

	// Guy should get to goal and tear into building until all barrier chunks are gone
	self tear_into_building();

	//NOT SURE IF I USE THIS
	if(isDefined(self.first_node.clip))
	{
			self.first_node.clip connectpaths();
	}

	// here is where they zombie would play the traversal into the building( if it's a window )
	// and begin the player seek logic
	self zombie_setup_attack_properties();
	self thread find_flesh();
}


zombie_assure_node()
{
	self endon( "death" );
	self endon( "goal" );
	level endon( "intermission" );

	start_pos = self.origin;

	for( i = 0; i < self.entrance_nodes.size; i++ )
	{
		if( self zombie_bad_path() )
		{
			self zombie_history( "zombie_assure_node -> assigned assured node = " + self.entrance_nodes[i].origin );

			println( "^1Zombie @ " + self.origin + " did not move for 1 second. Going to next closest node @ " + self.entrance_nodes[i].origin );
			level thread draw_line_ent_to_pos( self, self.entrance_nodes[i].origin, "goal" );
			self.first_node = self.entrance_nodes[i];
			self SetGoalPos( self.entrance_nodes[i].origin );
		}
		else
		{
			return;
		}
	}	
	// CHRISP - must add an additional check, since the 'self.entrance_nodes' array is not dynamically updated to accomodate for entrance points that can be turned on and off
	// only do this if it's the asylum map
	if(level.script == "nazi_zombie_asylum")
	{
		wait(2);
		// Get more nodes and try again
		nodes = get_array_of_closest( self.origin, level.exterior_goals, undefined, 20 );
		self.entrance_nodes = nodes;
		for( i = 0; i < self.entrance_nodes.size; i++ )
		{
			if( self zombie_bad_path() )
			{
				self zombie_history( "zombie_assure_node -> assigned assured node = " + self.entrance_nodes[i].origin );

				println( "^1Zombie @ " + self.origin + " did not move for 1 second. Going to next closest node @ " + self.entrance_nodes[i].origin );
				level thread draw_line_ent_to_pos( self, self.entrance_nodes[i].origin, "goal" );
				self.first_node = self.entrance_nodes[i];
				self SetGoalPos( self.entrance_nodes[i].origin );
			}
			else
			{
				return;
			}
		}
	}		

	self zombie_history( "zombie_assure_node -> failed to find a good entrance point" );
	
	//assertmsg( "^1Zombie @ " + self.origin + " did not find a good entrance point... Please fix pathing or Entity setup" );
	wait(20);
	//iprintln( "^1Zombie @ " + self.origin + " did not find a good entrance point... Please fix pathing or Entity setup" );
	self DoDamage( self.health + 10, self.origin );
}

zombie_bad_path()
{
	self endon( "death" );
	self endon( "goal" );

	self thread zombie_bad_path_notify();
	self thread zombie_bad_path_timeout();

	self.zombie_bad_path = undefined;
	while( !IsDefined( self.zombie_bad_path ) )
	{
		wait( 0.05 );
	}

	self notify( "stop_zombie_bad_path" );

	return self.zombie_bad_path;
}

zombie_bad_path_notify()
{
	self endon( "death" );
	self endon( "stop_zombie_bad_path" );

	self waittill( "bad_path" );
	self.zombie_bad_path = true;
}

zombie_bad_path_timeout()
{
	self endon( "death" );
	self endon( "stop_zombie_bad_path" );

	wait( 2 );
	self.zombie_bad_path = false;
}

// zombies are trying to get at player contained behind barriers, so the barriers
// need to come down
tear_into_building()
{
	//chrisp - added this 
	//checkpass = false;
	
	self endon( "death" ); 

	self zombie_history( "tear_into_building -> start" );

	while( 1 )
	{
		if( IsDefined( self.first_node.script_noteworthy ) )
		{
			if( self.first_node.script_noteworthy == "no_blocker" )
			{
				return;
			}
		}

		if( !IsDefined( self.first_node.target ) )
		{
			return;
		}

		if( all_chunks_destroyed( self.first_node.barrier_chunks ) )
		{
			self zombie_history( "tear_into_building -> all chunks destroyed" );
		}

		// Pick a spot to tear down
		if( !get_attack_spot( self.first_node ) )
		{
			self zombie_history( "tear_into_building -> Could not find an attack spot" );
			wait( 0.5 );
			continue;
		}

		self.goalradius = 4;
		self SetGoalPos( self.attacking_spot, self.first_node.angles );
		self waittill( "goal" );

		self waittill_notify_or_timeout( "orientdone", 1 );

		self zombie_history( "tear_into_building -> Reach position and orientated" );		

		// chrisp - do one final check to make sure that the boards are still torn down
		// this *mostly* prevents the zombies from coming through the windows as you are boarding them up. 
		if( all_chunks_destroyed( self.first_node.barrier_chunks ) )
		{
			self zombie_history( "tear_into_building -> all chunks destroyed" );
			for( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
			{
				self.first_node.attack_spots_taken[i] = false;
			}
			return;
		}

		// Now tear down boards
		while( 1 )
		{
			chunk = get_closest_non_destroyed_chunk( self.origin, self.first_node.barrier_chunks );
	
			if( !IsDefined( chunk ) )
			{
				for( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
				{
					self.first_node.attack_spots_taken[i] = false;
				}
				return;
			}
								
			self zombie_history( "tear_into_building -> animating" );

			tear_anim = get_tear_anim( chunk ); 
			chunk.target_by_zombie = true;
			self AnimScripted( "tear_anim", self.origin, self.first_node.angles, tear_anim );
			self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
			
			//chris - adding new window attack & gesture animations ;)
			if(level.script != "nazi_zombie_prototype")
			{
				attack = self should_attack_player_thru_boards();
				if(isDefined(attack) && !attack && self.has_legs)
				{
					self do_a_taunt();
				}						
			}
			//chrisp - fix the extra tear anim bug
			if( all_chunks_destroyed( self.first_node.barrier_chunks ) )
			{
				for( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
				{
					self.first_node.attack_spots_taken[i] = false;
				}
				return;
			}	
		}
		self reset_attack_spot();
	}		
}

/*------------------------------------
checks to see if the zombie should 
do a taunt when tearing thru the boards
------------------------------------*/
do_a_taunt()
{
	if( !self.has_legs)
	{
		return false;
	}

	self.old_origin = self.origin;
	if(getdvar("zombie_taunt_freq") == "")
	{
		setdvar("zombie_taunt_freq","5");
	}
	freq = getdvarint("zombie_taunt_freq");
	
	if( freq >= randomint(100) )
	{
		anime = random(level._zombie_board_taunt[self.animname]);
		self animscripted("zombie_taunt",self.origin,self.angles,anime);
		wait(getanimlength(anime));
		self teleport(self.old_origin);
	}
}
/*------------------------------------
checks to see if the players are near
the entrance and tries to attack them 
thru the boards. 50% chance
------------------------------------*/
should_attack_player_thru_boards()
{
	
	//no board attacks if they are crawlers
	if( !self.has_legs)
	{
		return false;
	}
	
	if(getdvar("zombie_reachin_freq") == "")
	{
		setdvar("zombie_reachin_freq","50");
	}
	freq = getdvarint("zombie_reachin_freq");
	
	players = get_players();
	attack = false;
	
	for(i=0;i<players.size;i++)
	{
		if(distance2d(self.origin,players[i].origin) <= 72)
		{
			attack = true;
		}
	}	
	if(attack && freq >= randomint(100) )
	{
		//iprintln("checking attack");
		
		//check to see if the guy is left, right, or center 
		self.old_origin = self.origin;
		if(self.attacking_spot_index == 0) //he's in the center
		{
			
		if(randomint(100) > 50)
		{
			
				self animscripted("window_melee",self.origin,self.angles,%ai_zombie_window_attack_arm_l_out);
		}
		else
		{
			self animscripted("window_melee",self.origin,self.angles,%ai_zombie_window_attack_arm_r_out);
		}
		self window_notetracks( "window_melee" );
	



			
		}
		else if(self.attacking_spot_index == 2) //<-- he's to the left
		{
			self animscripted("window_melee",self.origin,self.angles,%ai_zombie_window_attack_arm_r_out);
			self window_notetracks( "window_melee" );
		}
		else if(self.attacking_spot_index == 1) //<-- he's to the right
		{
			self animscripted("window_melee",self.origin,self.angles,%ai_zombie_window_attack_arm_l_out);
			self window_notetracks( "window_melee" );
		}					
	}
	else
	{
		return false;	
	}
}
window_notetracks(msg)
{
	while(1)
	{
		self waittill( msg, notetrack );

		if( notetrack == "end" )
		{
			//self waittill("end");
			self teleport(self.old_origin);

			return;
		}
		if( notetrack == "fire" )
		{
			if(self.ignoreall)
			{
				self.ignoreall = false;
			}
			self melee();
		}
	}
}

crash_into_building()
{
	self endon( "death" ); 

	self zombie_history( "tear_into_building -> start" );

	while( 1 )
	{
		if( IsDefined( self.first_node.script_noteworthy ) )
		{
			if( self.first_node.script_noteworthy == "no_blocker" )
			{
				return;
			}
		}

		if( !IsDefined( self.first_node.target ) )
		{
			return;
		}

		if( all_chunks_destroyed( self.first_node.barrier_chunks ) )
		{
			self zombie_history( "tear_into_building -> all chunks destroyed" );
			return;
		}

		// Pick a spot to tear down
		if( !get_attack_spot( self.first_node ) )
		{
			self zombie_history( "tear_into_building -> Could not find an attack spot" );
			wait( 0.5 );
			continue;
		}

		self.goalradius = 4;
		self SetGoalPos( self.attacking_spot, self.first_node.angles );
		self waittill( "goal" );
		self zombie_history( "tear_into_building -> Reach position and orientated" );

		// Now tear down boards
		while( 1 )
		{
			chunk = get_closest_non_destroyed_chunk( self.origin, self.first_node.barrier_chunks );
	
			if( !IsDefined( chunk ) )
			{
				for( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
				{
					self.first_node.attack_spots_taken[i] = false;
				}
				return; 
			}

			self zombie_history( "tear_into_building -> crash" );

			//tear_anim = get_tear_anim( chunk ); 
			//self AnimScripted( "tear_anim", self.origin, self.first_node.angles, tear_anim );
			//self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
			PlayFx( level._effect["wood_chunk_destory"], chunk.origin );
			PlayFx( level._effect["wood_chunk_destory"], chunk.origin + ( randomint( 20 ), randomint( 20 ), randomint( 10 ) ) );
			PlayFx( level._effect["wood_chunk_destory"], chunk.origin + ( randomint( 40 ), randomint( 40 ), randomint( 20 ) ) );
	
			level thread maps\_zombiemode_blockers::remove_chunk( chunk, self.first_node, true );
			
			if( all_chunks_destroyed( self.first_node.barrier_chunks ) )
			{
				EarthQuake( randomfloatrange( 0.5, 0.8 ), 0.5, chunk.origin, 300 ); 
	
				if( IsDefined( self.first_node.clip ) )
				{
					self.first_node.clip ConnectPaths(); 
					wait( 0.05 ); 
					self.first_node.clip disable_trigger(); 
				}
				else
				{
					for( i = 0; i < self.first_node.barrier_chunks.size; i++ )
					{
						self.first_node.barrier_chunks[i] ConnectPaths(); 
					}
				}
			}
			else
			{
				EarthQuake( RandomFloatRange( 0.1, 0.15 ), 0.2, chunk.origin, 200 ); 
			}
					
		}

		self reset_attack_spot();
	}		
}

reset_attack_spot()
{
	if( IsDefined( self.attacking_node ) )
	{
		node = self.attacking_node;
		index = self.attacking_spot_index;
		node.attack_spots_taken[index] = false;

		self.attacking_node = undefined;
		self.attacking_spot_index = undefined;
	}
}

get_attack_spot( node )
{
	index = get_attack_spot_index( node );
	if( !IsDefined( index ) )
	{
		return false;
	}

	self.attacking_node = node;
	self.attacking_spot_index = index;
	node.attack_spots_taken[index] = true;
	self.attacking_spot = node.attack_spots[index];

	return true;
}

get_attack_spot_index( node )
{
	indexes = [];
	for( i = 0; i < node.attack_spots.size; i++ )
	{
		if( !node.attack_spots_taken[i] )
		{
			indexes[indexes.size] = i;
		}
	}

	if( indexes.size == 0 )
	{
		return undefined;
	}

	return indexes[RandomInt( indexes.size )];
}

zombie_tear_notetracks( msg, chunk, node )
{
	self endon("death");

	chunk thread check_for_zombie_death(self);

	while( 1 )
	{
		self waittill( msg, notetrack );

		if( notetrack == "end" )
		{
			return;
		}

		if( notetrack == "board" )
		{
			if( !chunk.destroyed )
			{
				self.lastchunk_destroy_time = getTime();
	
				PlayFx( level._effect["wood_chunk_destory"], chunk.origin );
				PlayFx( level._effect["wood_chunk_destory"], chunk.origin + ( randomint( 20 ), randomint( 20 ), randomint( 10 ) ) );
				PlayFx( level._effect["wood_chunk_destory"], chunk.origin + ( randomint( 40 ), randomint( 40 ), randomint( 20 ) ) );
				
				level thread maps\_zombiemode_blockers::remove_chunk( chunk, node,true );
			}
		}
	}
}

check_for_zombie_death(zombie)
{
	self endon( "destroyed" );
	zombie waittill( "death" );

	self.target_by_zombie = undefined;
}

get_tear_anim( chunk )
{
	if( self.has_legs )
	{
		z_dist = chunk.origin[2] - self.origin[2];
		if( z_dist > 70 )
		{
			tear_anim = %ai_zombie_door_tear_high;
		}
		else if( z_dist < 40 )
		{
			tear_anim = %ai_zombie_door_tear_low;
		}
		else
		{
			anims = [];
			anims[anims.size] = %ai_zombie_door_tear_left;
			anims[anims.size] = %ai_zombie_door_tear_right;
	
			tear_anim = anims[RandomInt( anims.size )];
		}
	}
	else
	{
		anims = [];
		anims[anims.size] = %ai_zombie_attack_crawl;
		anims[anims.size] = %ai_zombie_attack_crawl_lunge;

		tear_anim = anims[RandomInt( anims.size )];
	}

	return tear_anim; 
}

cap_zombie_head_gibs()
{
	if( !isDefined( level.max_head_gibs_per_frame ) )
	{
		level.max_head_gibs_per_frame = 4;
	}
	
	while( true )
	{
		level.head_gibs_this_frame = 0;
		wait_network_frame();
	}
}

zombie_head_gib( attacker )
{
	if ( is_german_build() )
	{
		return;
	}

	if( IsDefined( self.head_gibbed ) && self.head_gibbed )
	{
		return;
	}
	
	if( !isDefined( level.head_gibs_this_frame ) )
	{
		level thread cap_zombie_head_gibs();
	}
	
	if( level.head_gibs_this_frame >= level.max_head_gibs_per_frame )
	{
		return;
	}

	level.head_gibs_this_frame++;

	self.head_gibbed = true;
	self zombie_eye_glow_stop();

	size = self GetAttachSize(); 
	for( i = 0; i < size; i++ )
	{
		model = self GetAttachModelName( i ); 
		if( IsSubStr( model, "head" ) )
		{
			// SRS 9/2/2008: wet em up
			self thread headshot_blood_fx();
			if(isdefined(self.hatmodel) && (self.hatmodel == "char_ger_wermachtwet_cap1" || self.hatmodel == "char_ger_wermacht_softcap1") ) // if a cap, don't shoot it off
			{
				self detach( self.hatModel, "" ); 
			}
			else if(isdefined(self.hatmodel) )
			{
				if( IsDefined( attacker ) )
				{
					self play_sound_on_ent("zombie_impact_helmet");
				}
				self HelmetPopNew();
			}

			self play_sound_on_ent( "zombie_head_gib" );
			
			self Detach( model, "", true ); 
			self Attach( "char_ger_honorgd_zomb_behead", "", true ); 
			break; 
		}
	}

	self thread damage_over_time( self.health * 0.2, 1, attacker );
}

HelmetPopNew()
{
	if( !isdefined( self ) )
	{
		return; 
	}

	if( !isdefined( self.hatModel ) || !ModelHasPhysPreset( self.hatModel ) )
	{
		return; 
	}
	
	partName = GetPartName( self.hatModel, 0 ); 
	origin = self GetTagOrigin( partName ); //self . origin +( 0, 0, 64 ); 
	angles = self GetTagAngles( partName ); //( -90, 0 + randomint( 90 ), 0 + randomint( 90 ) ); 
	
	NewHelmetLaunch( self.hatModel, origin, angles, self.damageDir ); 

	hatModel = self.hatModel; 
	self.hatModel = undefined; 
	self.helmetPopper = self.attacker;
	
	wait 0.05; 
	
	if( !isdefined( self ) )
	{
		return; 
	}

	self detach( hatModel, "" ); 
}

NewHelmetLaunch( model, origin, angles, damageDir )
{
	launchForce = damageDir; 
  
//	launchForce = launchForce * randomFloatRange( 1100, 4000 ); 
	launchForce = launchForce * randomFloatRange( 1000, 1750 ); 

	forcex = launchForce[0]; 
	forcey = launchForce[1]; 
//	forcez = randomFloatRange( 800, 3000 ); 
	forcez = randomFloatRange( 900, 2000 ); 

	contactPoint = self.origin +( randomfloatrange( -1, 1 ), randomfloatrange( -1, 1 ), randomfloatrange( -1, 1 ) ) * 5; 

	CreateDynEntAndLaunch( model, origin, angles, contactPoint, ( forcex, forcey, forcez ) ); 
}


damage_over_time( dmg, delay, attacker )
{
	self endon( "death" );

	if( !IsAlive( self ) )
	{
		return;
	}

	if( !IsPlayer( attacker ) )
	{
		attacker = undefined;
	}

	while( 1 )
	{
		wait( delay );

		if( IsDefined( attacker ) )
		{
			self DoDamage( dmg, self.origin, attacker );
		}
		else
		{
			self DoDamage( dmg, self.origin );
		}
	}
}

// SRS 9/2/2008: reordered checks, added ability to gib heads with airburst grenades
head_should_gib( attacker, type, point )
{
	if ( is_german_build() )
	{
		return false;
	}

	if( self.head_gibbed )
	{
		return false;
	}

	// check if the attacker was a player
	if( !IsDefined( attacker ) || !IsPlayer( attacker ) )
	{
		return false; 
	}

	// check the enemy's health
	low_health_percent = ( self.health / self.maxhealth ) * 100; 
	if( low_health_percent > 10 )
	{
		return false; 
	}

	weapon = attacker GetCurrentWeapon(); 

	// SRS 9/2/2008: check for damage type
	//  - most SMGs use pistol bullets
	//  - projectiles = rockets, raygun
	if( type != "MOD_RIFLE_BULLET" && type != "MOD_PISTOL_BULLET" )
	{
		// maybe it's ok, let's see if it's a grenade
		if( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
		{
			if( Distance( point, self GetTagOrigin( "j_head" ) ) > 55 )
			{
				return false;
			}
			else
			{
				// the grenade airburst close to the head so return true
				return true;
			}
		}
		else if( type == "MOD_PROJECTILE" )
		{
			if( Distance( point, self GetTagOrigin( "j_head" ) ) > 10 )
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		// shottys don't give a testable damage type but should still gib heads
		else if( WeaponClass( weapon ) != "spread" )
		{
			return false; 
		}
	}

	// check location now that we've checked for grenade damage (which reports "none" as a location)
	if( !self animscripts\utility::damageLocationIsAny( "head", "helmet", "neck" ) )
	{
		return false; 
	}

	// check weapon - don't want "none", pistol, or flamethrower
	if( weapon == "none"  || (WeaponClass( weapon ) == "pistol" && !isSubStr(weapon, "357") ) || WeaponIsGasWeapon( self.weapon ) )
	{
		return false; 
	}

	return true; 
}

// does blood fx for fun and to mask head gib swaps
headshot_blood_fx()
{
	if( !IsDefined( self ) )
	{
		return;
	}

	if( !is_mature() )
	{
		return;
	}

	fxTag = "j_neck";
	fxOrigin = self GetTagOrigin( fxTag );
	upVec = AnglesToUp( self GetTagAngles( fxTag ) );
	forwardVec = AnglesToForward( self GetTagAngles( fxTag ) );
	
	// main head pop fx
	PlayFX( level._effect["headshot"], fxOrigin, forwardVec, upVec );
	PlayFX( level._effect["headshot_nochunks"], fxOrigin, forwardVec, upVec );
	
	wait( 0.3 );
	
	if( IsDefined( self ) )
	{
		PlayFxOnTag( level._effect["bloodspurt"], self, fxTag );
	}
}

// gib limbs if enough firepower occurs
zombie_gib_on_damage()
{
//	self endon( "death" ); 

	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type ); 

		if( !IsDefined( self ) )
		{
			return;
		}

		if( !self zombie_should_gib( amount, attacker, type ) )
		{
			continue; 
		}

		if( self head_should_gib( attacker, type, point ) && type != "MOD_BURNED" )
		{
			self zombie_head_gib( attacker );
			if(IsDefined(attacker.headshot_count))
			{
				attacker.headshot_count++;
			}
			else
			{
				attacker.headshot_count = 1;
			}
			//stats tracking
			attacker.stats["headshots"] = attacker.headshot_count;
			attacker.stats["zombie_gibs"]++;

			continue;
		}

		if( !self.gibbed )
		{
			// The head_should_gib() above checks for this, so we should not randomly gib if shot in the head
			if( self animscripts\utility::damageLocationIsAny( "head", "helmet", "neck" ) )
			{
				continue;
			}

			refs = []; 
			switch( self.damageLocation )
			{
				case "torso_upper":
				case "torso_lower":
					// HACK the torso that gets swapped for guts also removes the left arm
					//  so we need to sometimes do another ref
					refs[refs.size] = "guts"; 
					refs[refs.size] = "right_arm";
					break; 
	
				case "right_arm_upper":
				case "right_arm_lower":
				case "right_hand":
					//if( IsDefined( self.left_arm_gibbed ) )
					//	refs[refs.size] = "no_arms"; 
					//else
					refs[refs.size] = "right_arm"; 
	
					//self.right_arm_gibbed = true; 
					break; 
	
				case "left_arm_upper":
				case "left_arm_lower":
				case "left_hand":
					//if( IsDefined( self.right_arm_gibbed ) )
					//	refs[refs.size] = "no_arms"; 
					//else
					refs[refs.size] = "left_arm"; 
	
					//self.left_arm_gibbed = true; 
					break; 
	
				case "right_leg_upper":
				case "right_leg_lower":
				case "right_foot":
					if( self.health <= 0 )
					{
						// Addition "right_leg" refs so that the no_legs happens less and is more rare
						refs[refs.size] = "right_leg";
						refs[refs.size] = "right_leg";
						refs[refs.size] = "right_leg";
						refs[refs.size] = "no_legs"; 
					}
					break; 
	
				case "left_leg_upper":
				case "left_leg_lower":
				case "left_foot":
					if( self.health <= 0 )
					{
						// Addition "left_leg" refs so that the no_legs happens less and is more rare
						refs[refs.size] = "left_leg";
						refs[refs.size] = "left_leg";
						refs[refs.size] = "left_leg";
						refs[refs.size] = "no_legs";
					}
					break; 
			default:
				
				if( self.damageLocation == "none" )
				{
					// SRS 9/7/2008: might be a nade or a projectile
					if( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" || type == "MOD_PROJECTILE" )
					{
						// ... in which case we have to derive the ref ourselves
						refs = self derive_damage_refs( point );
						break;
					}
				}
				else
				{
					refs[refs.size] = "guts";
					refs[refs.size] = "right_arm"; 
					refs[refs.size] = "left_arm"; 
					refs[refs.size] = "right_leg"; 
					refs[refs.size] = "left_leg"; 
					refs[refs.size] = "no_legs"; 
					break; 
				}
			}
			if( refs.size )
			{
				self.a.gib_ref = animscripts\death::get_random( refs ); 
			
				// Don't stand if a leg is gone
				if( ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "right_leg" || self.a.gib_ref == "left_leg" ) && self.health > 0 )
				{
					self.has_legs = false; 
					self AllowedStances( "crouch" ); 
										
					which_anim = RandomInt( 6 ); 
					if(self.a.gib_ref == "no_legs")
					{
						
						if(randomint(100) < 50)
						{
							self.deathanim = %ai_zombie_crawl_death_v1;
							self set_run_anim( "death3" );
							self.run_combatanim = level.scr_anim[self.animname]["crawl_hand_1"];
							self.crouchRunAnim = level.scr_anim[self.animname]["crawl_hand_1"];
							self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl_hand_1"];
						}
						else
						{
							self.deathanim = %ai_zombie_crawl_death_v1;
							self set_run_anim( "death3" );
							self.run_combatanim = level.scr_anim[self.animname]["crawl_hand_2"];
							self.crouchRunAnim = level.scr_anim[self.animname]["crawl_hand_2"];
							self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl_hand_2"];
						}


					}
					else if( which_anim == 0 ) 
					{
						self.deathanim = %ai_zombie_crawl_death_v1;
						self set_run_anim( "death3" );
						self.run_combatanim = level.scr_anim[self.animname]["crawl1"];
						self.crouchRunAnim = level.scr_anim[self.animname]["crawl1"];
						self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl1"];
					}
					else if( which_anim == 1 ) 
					{
						self.deathanim = %ai_zombie_crawl_death_v2;
						self set_run_anim( "death4" );
						self.run_combatanim = level.scr_anim[self.animname]["crawl2"];
						self.crouchRunAnim = level.scr_anim[self.animname]["crawl2"];
						self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl2"];
					}
					else if( which_anim == 2 ) 
					{
						self.deathanim = %ai_zombie_crawl_death_v1;
						self set_run_anim( "death3" );
						self.run_combatanim = level.scr_anim[self.animname]["crawl3"];
						self.crouchRunAnim = level.scr_anim[self.animname]["crawl3"];
						self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl3"];
					}
					else if( which_anim == 3 ) 
					{
						self.deathanim = %ai_zombie_crawl_death_v2;
						self set_run_anim( "death4" );
						self.run_combatanim = level.scr_anim[self.animname]["crawl4"];
						self.crouchRunAnim = level.scr_anim[self.animname]["crawl4"];
						self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl4"];
					}
					else if( which_anim == 4 ) 
					{
						self.deathanim = %ai_zombie_crawl_death_v1;
						self set_run_anim( "death3" );
						self.run_combatanim = level.scr_anim[self.animname]["crawl5"];
						self.crouchRunAnim = level.scr_anim[self.animname]["crawl5"];
						self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl5"];
					}
					else if( which_anim == 5 ) 
					{
						self.deathanim = %ai_zombie_crawl_death_v2;
						self set_run_anim( "death4" );
						self.run_combatanim = level.scr_anim[self.animname]["crawl6"];
						self.crouchRunAnim = level.scr_anim[self.animname]["crawl6"];
						self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl6"];
					}
										
				}
			}

			if( self.health > 0 )
			{
				// force gibbing if the zombie is still alive
				self thread animscripts\death::do_gib();

				//stat tracking
				attacker.stats["zombie_gibs"]++;
			}
		}
	}
}


zombie_should_gib( amount, attacker, type )
{
	if ( is_german_build() )
	{
		return false;
	}

	if( !IsDefined( type ) )
	{
		return false; 
	}

	switch( type )
	{
		case "MOD_UNKNOWN":
		case "MOD_CRUSH": 
		case "MOD_TELEFRAG":
		case "MOD_FALLING": 
		case "MOD_SUICIDE": 
		case "MOD_TRIGGER_HURT":
		case "MOD_BURNED":
		case "MOD_MELEE":		
			return false; 
	}

	if( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" )
	{
		if( !IsDefined( attacker ) || !IsPlayer( attacker ) )
		{
			return false; 
		}

		weapon = attacker GetCurrentWeapon(); 

		if( weapon == "none" )
		{
			return false; 
		}

		if( WeaponClass( weapon ) == "pistol" && !IsSubStr(weapon,"357" ) ) 
		{
			return false; 
		}

		if( WeaponIsGasWeapon( self.weapon ) )
		{
			return false; 
		}
	}

//	println( "**DEBUG amount = ", amount );
//	println( "**DEBUG self.head_gibbed = ", self.head_gibbed );
//	println( "**DEBUG self.health = ", self.health );

	prev_health = amount + self.health;
	if( prev_health <= 0 )
	{
		prev_health = 1;
	}

	damage_percent = ( amount / prev_health ) * 100; 

	if( damage_percent < 10 /*|| damage_percent >= 100*/ )
	{
		return false; 
	}

	return true; 
}

// SRS 9/7/2008: need to derive damage location for types that return location of "none"
derive_damage_refs( point )
{
	if( !IsDefined( level.gib_tags ) )
	{
		init_gib_tags();
	}
	
	closestTag = undefined;
	
	for( i = 0; i < level.gib_tags.size; i++ )
	{
		if( !IsDefined( closestTag ) )
		{
			closestTag = level.gib_tags[i];
		}
		else
		{
			if( DistanceSquared( point, self GetTagOrigin( level.gib_tags[i] ) ) < DistanceSquared( point, self GetTagOrigin( closestTag ) ) )
			{
				closestTag = level.gib_tags[i];
			}
		}
	}
	
	refs = [];
	
	// figure out the refs based on the tag returned
	if( closestTag == "J_SpineLower" || closestTag == "J_SpineUpper" || closestTag == "J_Spine4" )
	{
		// HACK the torso that gets swapped for guts also removes the left arm
		//  so we need to sometimes do another ref
		refs[refs.size] = "guts";
		refs[refs.size] = "right_arm";
	}
	else if( closestTag == "J_Shoulder_LE" || closestTag == "J_Elbow_LE" || closestTag == "J_Wrist_LE" )
	{
		refs[refs.size] = "left_arm";
	}
	else if( closestTag == "J_Shoulder_RI" || closestTag == "J_Elbow_RI" || closestTag == "J_Wrist_RI" )
	{
		refs[refs.size] = "right_arm";
	}
	else if( closestTag == "J_Hip_LE" || closestTag == "J_Knee_LE" || closestTag == "J_Ankle_LE" )
	{
		refs[refs.size] = "left_leg";
		refs[refs.size] = "no_legs";
	}
	else if( closestTag == "J_Hip_RI" || closestTag == "J_Knee_RI" || closestTag == "J_Ankle_RI" )
	{
		refs[refs.size] = "right_leg";
		refs[refs.size] = "no_legs";
	}
	
	ASSERTEX( array_validate( refs ), "get_closest_damage_refs(): couldn't derive refs from closestTag " + closestTag );
	
	return refs;
}

init_gib_tags()
{
	tags = [];
					
	// "guts", "right_arm", "left_arm", "right_leg", "left_leg", "no_legs"
	
	// "guts"
	tags[tags.size] = "J_SpineLower";
	tags[tags.size] = "J_SpineUpper";
	tags[tags.size] = "J_Spine4";
	
	// "left_arm"
	tags[tags.size] = "J_Shoulder_LE";
	tags[tags.size] = "J_Elbow_LE";
	tags[tags.size] = "J_Wrist_LE";
	
	// "right_arm"
	tags[tags.size] = "J_Shoulder_RI";
	tags[tags.size] = "J_Elbow_RI";
	tags[tags.size] = "J_Wrist_RI";
	
	// "left_leg"/"no_legs"
	tags[tags.size] = "J_Hip_LE";
	tags[tags.size] = "J_Knee_LE";
	tags[tags.size] = "J_Ankle_LE";
	
	// "right_leg"/"no_legs"
	tags[tags.size] = "J_Hip_RI";
	tags[tags.size] = "J_Knee_RI";
	tags[tags.size] = "J_Ankle_RI";
	
	level.gib_tags = tags;
}

zombie_death_points( origin, mod, hit_location, player, zombie )
{
	//ChrisP - no points or powerups for killing zombies
	if(IsDefined(zombie.marked_for_death))
	{
		return;
	}
	
	level thread maps\_zombiemode_powerups::powerup_drop( origin );

	if( !IsDefined( player ) || !IsPlayer( player ) )
	{
		return; 
	}

	level thread play_death_vo(hit_location, player,mod,zombie);

	player maps\_zombiemode_score::player_add_points( "death", mod, hit_location ); 
}

play_insta_melee_dialog(player_index)
{
		waittime = 0.25;
		if(!IsDefined( self.one_at_a_time))
		{
			self.one_at_a_time = 0;
		}
		if(!IsDefined (self.vox_melee_insta))
		{
			num_variants = get_number_variants(player_index + "nvox_melee_insta");
			self.vox_melee_insta = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_melee_insta[self.vox_melee_insta.size] = "nvox_melee_insta_" + i;	
			}
			self.vox_melee_insta_available = self.vox_melee_insta;
		}
		if(self.one_at_a_time == 0)
		{
			self.one_at_a_time = 1;
			sound_to_play = random(self.vox_melee_insta_available);
			self.vox_melee_insta_available = array_remove(self.vox_melee_insta_available,sound_to_play);
			if (self.vox_melee_insta_available.size < 1 )
			{
				self.vox_melee_insta_available = self.vox_melee_insta;
			}
			self do_player_playdialog(player_index, sound_to_play, waittime);
			//self playsound(player_index + sound_to_play, "sound_done" + sound_to_play);			
			//self waittill("sound_done" + sound_to_play);
			wait(waittime);
			self.one_at_a_time = 0;

		}
		//This ensures that there is at least 3 seconds waittime before playing another VO.

}

do_player_playdialog(player_index, sound_to_play, waittime )
{
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	if(!IsDefined(level.player_is_speaking))
	{
		level.player_is_speaking = 0;	
	}
	if(level.player_is_speaking != 1)
	{
		level.player_is_speaking = 1;
		//iprintlnbold(sound_to_play);
		self playsound(player_index + sound_to_play, "sound_done" + sound_to_play);			
		self waittill("sound_done" + sound_to_play);
		wait(waittime);		
		level.player_is_speaking = 0;
/*		if( isdefined( response ) )
		{
			level thread setup_response_line( self, index, response ); 
		}*/
	}
}

play_explosion_dialog(player_index)
{
		
		waittime = 0.25;
		if(!IsDefined( self.one_at_a_time))
		{
			self.one_at_a_time = 0;
		}
		if(!IsDefined (self.vox_kill_explo))
		{
			num_variants = get_number_variants(player_index + "nvox_kill_explo");
			self.vox_kill_explo = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_kill_explo[self.vox_kill_explo.size] = "nvox_kill_explo_" + i;	
			}
			self.vox_kill_explo_available = self.vox_kill_explo;
		}
		if(self.one_at_a_time == 0)
		{
			self.one_at_a_time = 1;
			sound_to_play = random(self.vox_kill_explo_available);
//			iprintlnbold(player_index + "_" + sound_to_play);
			self.vox_kill_explo_available = array_remove(self.vox_kill_explo_available,sound_to_play);			
			self do_player_playdialog(player_index, sound_to_play, waittime);
			if (self.vox_kill_explo_available.size < 1 )
			{
				self.vox_kill_explo_available = self.vox_kill_explo;
			}
			self.one_at_a_time = 0;
		}
}

play_closekill_dialog(player_index)
{
		waittime = 1;
		if(!IsDefined( self.one_at_a_time))
		{
			self.one_at_a_time = 0;
		}
		if(!IsDefined(self.vox_close))
		{
			num_variants = get_number_variants(player_index + "nvox_close");
			self.vox_close = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_close[self.vox_close.size] = "nvox_close_" + i;	
			}
			self.vox_close_available = self.vox_close;
		}
		if(self.one_at_a_time == 0)
		{
			self.one_at_a_time = 1;
			if (self.vox_close_available.size >= 1)
			{
				sound_to_play = random(self.vox_close_available);
				self.vox_close_available = array_remove(self.vox_close_available,sound_to_play);
				self do_player_playdialog(player_index, sound_to_play, waittime);
			}

			if (self.vox_close_available.size < 1 )
			{
				self.vox_close_available = self.vox_close;
			}
			self.one_at_a_time = 0;
		}
}
get_number_variants(aliasPrefix)
{
		for(i=0; i<100; i++)
		{
			if( !SoundExists( aliasPrefix + "_" + i) )
			{
				//iprintlnbold(aliasPrefix +"_" + i);
				return i;
			}
		}
}
play_headshot_dialog(player_index)
{
		
		waittime = 0.25;
		if(!IsDefined (self.vox_kill_headdist))
		{
			num_variants = get_number_variants(player_index + "nvox_kill_headdist");
			//iprintlnbold(num_variants);
			self.vox_kill_headdist = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_kill_headdist[self.vox_kill_headdist.size] = "nvox_kill_headdist_" + i;
				//iprintlnbold("vox_kill_headdist_" + i);	
			}
			self.vox_kill_headdist_available = self.vox_kill_headdist;
		}
		sound_to_play = random(self.vox_kill_headdist_available);
		//iprintlnbold("LINE:" + player_index + sound_to_play);
		self do_player_playdialog(player_index, sound_to_play, waittime);
		self.vox_kill_headdist_available = array_remove(self.vox_kill_headdist_available,sound_to_play);
	
		if (self.vox_kill_headdist_available.size < 1 )
		{
			self.vox_kill_headdist_available = self.vox_kill_headdist;
		}

}
play_death_vo(hit_location, player,mod,zombie)
{
	// CHRISP - adding some modifiers here so that it doens't play 100% of the time 
	// and takes into account the damage type. 
	//	default is 10% chance of saying something
	if( getdvar("zombie_death_vo_freq") == "" )
	{
		setdvar("zombie_death_vo_freq","100"); //TUEY moved to 50---We can take this out\tweak this later.
	}
	
	chance = getdvarint("zombie_death_vo_freq");
	
	weapon = player GetCurrentWeapon();

	sound = undefined;
	//just return and don't play a sound if the chance is not there
	if(chance < randomint(100) )
	{
		return;
	}
	
	//TUEY - this funciton allows you to play a voice over when you kill a zombie and its last hit spot was something specific (like Headshot).
	//players = getplayers();
	index = maps\_zombiemode_weapons::get_player_index(player);

	if(!isdefined (level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	if(!isdefined(level.zombie_vars["zombie_insta_kill"] ))
	{
		level.zombie_vars["zombie_insta_kill"] = 0;
	}
	if(hit_location == "head" && level.zombie_vars["zombie_insta_kill"] == 0   )
	{
		if(isDefined(zombie.in_the_ground) && zombie.in_the_ground == true)
		{
			player achievement_notify( "DLC1_ZOMBIE_COURT_HEADSHOTS" );
		}
		//no VO for non bullet headshot kills
		if( mod != "MOD_PISTOL_BULLET" &&	mod != "MOD_RIFLE_BULLET" )
		{
			return;
		}
				
		//chrisp - far headshot sounds
		if(distance(player.origin,zombie.origin) > 400)
		{
			plr = "plr_" + index + "_";
			player thread play_headshot_dialog (plr);
		}	
		//remove headshot sounds for instakill
		if (level.zombie_vars["zombie_insta_kill"] != 0)
		{			
			sound = undefined;
		}

	}	
	if( mod == "MOD_BURNED" )
	{
		//TUEY play flamethrower death sounds
		rand = randomintrange(0, 100);
		if(rand < 10) // in case player is only using flamethrower slowly killing zombies, use killstreak vox here to make it less silent
		{
			//plr = "plr_" + index + "_";
			//player play_flamethrower_dialog(plr);
			player maps\_zombiemode_utility::play_killstreak_dialog();
			return;
		}
	}	


	//special case for close range melee attacks while insta-kill is on
	if (level.zombie_vars["zombie_insta_kill"] != 0)
	{
		if( (mod == "MOD_MELEE" || mod == "MOD_BAYONET" /*|| mod == "MOD_UNKNOWN"*/ || player IsMeleeing() ) && distance(player.origin,zombie.origin) < 64)
		{
			plr = "plr_" + index + "_";
			player play_insta_melee_dialog(plr);
			//sound = "plr_" + index + "_vox_melee_insta" + "_" + randomintrange(0, 5); 
			return;
		}
	}

	if(weapon == "ray_gun" )
	{
		return;
	}

	//Explosive Kills
	if((mod == "MOD_GRENADE_SPLASH" || mod == "MOD_GRENADE") && level.zombie_vars["zombie_insta_kill"] == 0 )
	{
		rand = randomintrange(0, 100);
		if(rand < 75)
		{
			plr = "plr_" + index + "_";
			player play_explosion_dialog(plr);
		}
		return;
	}
	
	if( mod == "MOD_PROJECTILE")
	{	
		rand = randomintrange(0, 100);
		if(rand < 70)
		{
			plr = "plr_" + index + "_";
			player play_explosion_dialog(plr);
		}
		return;
	}

	if(IsDefined(zombie) && distance(player.origin,zombie.origin) < 64 && level.zombie_vars["zombie_insta_kill"] == 0 && mod != "MOD_BURNED" )
	{
		rand = randomintrange(0, 100);
		if(rand < 40)
		{
			plr = "plr_" + index + "_";
			player play_closekill_dialog(plr);				
		}	
		return;
	
	}	

}

// Called from animscripts\death.gsc
zombie_death_animscript()
{
	self reset_attack_spot();

	// If no_legs, then use the AI no-legs death
	if( self.has_legs && IsDefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" )
	{
		self.deathanim = %ai_gib_bothlegs_gib;
	}

	self.grenadeAmmo = 0;

	// Give attacker points
	level zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );

	if( self.damagemod == "MOD_BURNED" || (self.damageWeapon == "molotov" && (self.damagemod == "MOD_GRENADE" || self.damagemod == "MOD_GRENADE_SPLASH")) )
	{
		if(level.flame_death_fx_frame < 5 )
		{
			level.flame_death_fx_frame++;
			level thread reset_flame_death_fx_frame();
			self thread animscripts\death::flame_death_fx();
		}
	}
	if( self.damagemod == "MOD_GRENADE" || self.damagemod == "MOD_GRENADE_SPLASH" ) 
	{
		level notify( "zombie_grenade_death", self.origin );
	}

	return false;
}

reset_flame_death_fx_frame()
{
	level notify("reset_flame_death_fx_frame");
	level endon("reset_flame_death_fx_frame");

	wait_network_frame();

	level.flame_death_fx_frame = 0;
}

damage_on_fire( player )
{
	self endon ("death");
	self endon ("stop_flame_damage");
	wait( 2 );
	
	while( isdefined( self.is_on_fire) && self.is_on_fire )
	{
		if( level.round_number < 6 )
		{
			dmg = level.zombie_health * RandomFloatRange( 0.2, 0.3 ); // 20% - 30%
		}
		else if( level.round_number < 9 )
		{
			dmg = level.zombie_health * RandomFloatRange( 0.15, 0.25 );
		}
		else if( level.round_number < 11 )
		{
			dmg = level.zombie_health * RandomFloatRange( 0.1, 0.2 );
		}
		else
		{
			dmg = level.zombie_health * RandomFloatRange( 0.1, 0.15 );
		}

		if ( Isdefined( player ) && Isalive( player ) )
		{
			self DoDamage( dmg, self.origin, player );
		}
		else
		{
			self DoDamage( dmg, self.origin, level );
		}
		
		wait( randomfloatrange( 1.0, 3.0 ) );
	}
}

check_for_perk_damage( mod, player, amount )
{
	if( mod == "MOD_RIFLE_BULLET" || mod == "MOD_PISTOL_BULLET" )
	{
		if( Isdefined( player ) && Isalive( player ) && player HasPerk( "specialty_rof" ) )
		{			
			extra_damage = (amount / 3); // 33% extra damage, same increase as firerate buff
			if(extra_damage < self.health) // we dont do extra damage if a zombie would actually die as a result of the extra damage, this fixes because DoDamage wont gib/give proper score if it kills a zombie 
			{
				self DoDamage( extra_damage, self.origin, player );
			} 
		}
	}
}
zombie_damage( mod, hit_location, hit_origin, player, amount )
{
	players = get_players();

	//ChrisP - 12/8 - no points for killing gassed zombies!
	player.use_weapon_type = mod;
	if(isDefined(self.marked_for_death))
	{
		return;
	}	
	
	if( !IsDefined( player ) )
	{
		return; 
	}

	if(getdvarint("classic_perks") == 0)
	{
		self check_for_perk_damage( mod, player, amount );
	}

	if( self zombie_flame_damage( mod, player ) )
	{
		if( self zombie_give_flame_damage_points() )
		{
			player maps\_zombiemode_score::player_add_points( "damage", mod, hit_location, false );
		}
	}
	else
	{
		player maps\_zombiemode_score::player_add_points( "damage", mod, hit_location, false );
	}

	if ( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" )
	{
		if ( isdefined( player ) && isalive( player ) )
		{
			self DoDamage( level.round_number + randomintrange( 100, 500 ), self.origin, player);
		}
		else
		{
			self DoDamage( level.round_number + randomintrange( 100, 500 ), self.origin, undefined );
		}
	}
	else if( mod == "MOD_PROJECTILE" || mod == "MOD_EXPLOSIVE" || mod == "MOD_PROJECTILE_SPLASH" || mod == "MOD_PROJECTILE_SPLASH")
	{
		if ( isdefined( player ) && isalive( player ) )
		{
			self DoDamage( level.round_number * randomintrange( 0, 100 ), self.origin, player);
		}
		else
		{
			self DoDamage( level.round_number * randomintrange( 0, 100 ), self.origin, undefined );
		}
	}
	else if( mod == "MOD_ZOMBIE_BETTY" )
	{
		if ( isdefined( player ) && isalive( player ) )
		{
			self DoDamage( level.round_number * randomintrange( 100, 200 ), self.origin, player);
		}
		else
		{
			self DoDamage( level.round_number * randomintrange( 100, 200 ), self.origin, undefined );
		}
	}

	self thread maps\_zombiemode_powerups::check_for_instakill( player );
}

zombie_damage_ads( mod, hit_location, hit_origin, player, amount )
{
	player.use_weapon_type = mod;
	if( !IsDefined( player ) )
	{
		return; 
	}

	if(getdvarint("classic_perks") == 0)
	{
		self check_for_perk_damage( mod, player, amount );
	}

	if( self zombie_flame_damage( mod, player ) )
	{
		if( self zombie_give_flame_damage_points() )
		{
			player maps\_zombiemode_score::player_add_points( "damage_ads", mod, hit_location );
		}
	}
	else
	{
		player maps\_zombiemode_score::player_add_points( "damage_ads", mod, hit_location );
	}

	self thread maps\_zombiemode_powerups::check_for_instakill( player );
}

zombie_give_flame_damage_points()
{
	if( GetTime() > self.flame_damage_time )
	{
		self.flame_damage_time = GetTime() + level.zombie_vars["zombie_flame_dmg_point_delay"];
		return true;
	}

	return false;
}

zombie_flame_damage( mod, player )
{
	if( mod == "MOD_BURNED" )
	{
		self.moveplaybackrate = 0.8;
		
		if( !IsDefined( self.is_on_fire ) || ( Isdefined( self.is_on_fire ) && !self.is_on_fire ) )
		{
			self thread damage_on_fire( player );
		}

		do_flame_death = true;
		dist = 100 * 100;
		ai = GetAiArray( "axis" );
		for( i = 0; i < ai.size; i++ )
		{
			if( IsDefined( ai[i].is_on_fire ) && ai[i].is_on_fire )
			{
				if( DistanceSquared( ai[i].origin, self.origin ) < dist )
				{
					do_flame_death = false;
					break;
				}
			}
		}

		if( do_flame_death )
		{
			self thread animscripts\death::flame_death_fx();
		}

		return true;
	}

	return false;
}


zombie_death_event( zombie )
{
	zombie waittill( "death" );
	zombie thread zombie_eye_glow_stop();
	playsoundatposition ("death_vocals", zombie.origin);
	// this is controlling killstreak voice over in the asylum.gsc
	if(isdefined (zombie.attacker) && isplayer(zombie.attacker) )
	{
		if(!isdefined ( zombie.attacker.killcounter))
		{
			zombie.attacker.killcounter = 1;
		}
		else
		{
			zombie.attacker.killcounter ++;
		}
		
		if ( IsDefined( zombie.sound_damage_player ) && zombie.sound_damage_player == zombie.attacker )
		{	
			zombie.attacker thread play_closeDamage_dialog();	
		}
		
		zombie.attacker notify("zom_kill");
	}
	
}
play_closeDamage_dialog()
{
	index = maps\_zombiemode_weapons::get_player_index(self);
	player_index = "plr_" + index + "_";
	
	if(!IsDefined (self.vox_dmg_close))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "nvox_dmg_close");
		self.vox_dmg_close = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_dmg_close[self.vox_dmg_close.size] = "nvox_dmg_close_" + i;	
		}
		self.vox_dmg_close_available = self.vox_dmg_close;
	}
	sound_to_play = random(self.vox_dmg_close_available);
	self.vox_dmg_close_available = array_remove(self.vox_dmg_close_available,sound_to_play);
	
	if( self.vox_dmg_close_available.size < 1)
	{
		self.vox_dmg_close_available = self.vox_dmg_close;	
	}
	
	//self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	self do_player_playdialog(player_index, sound_to_play, 0.25);

}

// this is where zombies go into attack mode, and need different attributes set up
zombie_setup_attack_properties()
{
	self zombie_history( "zombie_setup_attack_properties()" );

	// allows zombie to attack again
	self.ignoreall = false; 

	// push the player out of the way so they use traversals in the house.
	if( getDvarInt( "grabby_zombies") == 1 )
	{
		self PushPlayer( true ); 
	}
	else
	{
		self PushPlayer( false);
	}

	self.pathEnemyFightDist = 64;
	self.meleeAttackDist = 64;
	
	//try to prevent always turning towards the enemy
	self.maxsightdistsqrd = 128 * 128;

	// turn off transition anims
	self.disableArrivals = true; 
	self.disableExits = true; 
}


// the seeker logic for zombies
find_flesh()
{
	self endon( "death" ); 
	level endon( "intermission" );

	if( level.intermission )
	{
		return;
	}

	self.ignore_player = undefined;

	self zombie_history( "find flesh -> start" );

	self.goalradius = 32;
	while( 1 )
	{

		// try to split the zombies up when the bunch up
		// see if a bunch zombies are already near my current target; if there's a bunch
		// and I'm still far enough away, ignore my current target and go after another one
//		near_zombies = getaiarray("axis");
//		same_enemy_count = 0;
//		for (i = 0; i < near_zombies.size; i++)
//		{
//			if ( isdefined( near_zombies[i] ) && isalive( near_zombies[i] ) )
//			{
//				if ( isdefined( near_zombies[i].favoriteenemy ) && isdefined( self.favoriteenemy ) 
//				&&	near_zombies[i].favoriteenemy == self.favoriteenemy )
//				{
//					if ( distancesquared( near_zombies[i].origin, self.favoriteenemy.origin ) < 225 * 225 
//					&&	 distancesquared( near_zombies[i].origin, self.origin ) > 525 * 525)
//					{
//						same_enemy_count++;
//					}
//				}
//			}
//		}
//		
//		if (same_enemy_count > 12)
//		{
//			self.ignore_player = self.favoriteenemy;
//		}
		
		players = get_players();
				
		// If playing single player, never ignore the player
		if( players.size == 1 )
		{
			self.ignore_player = undefined;
		}

		player = get_closest_valid_player( self.origin, self.ignore_player ); 
		
		if( players.size == 1 && players[0].ignoreme )
		{
		    structs = getstructarray( "initial_spawn_points", "targetname" ); 
		    while( players.size == 1 && players[0].ignoreme && level.solo_reviving_failsafe == 1 )
		    {
		        self SetGoalPos(structs[0].origin); // spawn point by quick revive
		        wait 0.5;
		    }
		}
		if( !IsDefined( player ) )
		{
			self zombie_history( "find flesh -> can't find player, continue" );
			if( IsDefined( self.ignore_player ) )
			{
				self.ignore_player = undefined;
			}

			wait( 1 ); 
			continue; 
		}

		self.ignore_player = undefined;

		self.favoriteenemy = player;
		self thread zombie_pathing();

		self.zombie_path_timer = GetTime() + ( RandomFloatRange( 1, 3 ) * 1000 );
		while( GetTime() < self.zombie_path_timer )
		{
			wait( 0.1 );
		}

		self zombie_history( "find flesh -> bottom of loop" );

		self notify( "zombie_acquire_enemy" );
	}
}

zombie_pathing()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	level endon( "intermission" );

	assert( IsDefined( self.favoriteenemy ) );
	self.favoriteenemy endon( "disconnect" );

	self thread zombie_follow_enemy();
	self waittill( "bad_path" );

	crumb_list = self.favoriteenemy.zombie_breadcrumbs;
	bad_crumbs = [];

	while( 1 )
	{
		if( !is_player_valid( self.favoriteenemy ) )
		{
			self.zombie_path_timer = 0;
			return;
		}

		goal = zombie_pathing_get_breadcrumb( self.favoriteenemy.origin, crumb_list, bad_crumbs, ( RandomInt( 100 ) < 20 ) );
		
		if ( !IsDefined( goal ) )
		{
			debug_print( "Zombie exhausted breadcrumb search" );
			goal = self.favoriteenemy.spectator_respawn.origin;
		}

		debug_print( "Setting current breadcrumb to " + goal );

		self.zombie_path_timer += 1000;
		self SetGoalPos( goal );
		self waittill( "bad_path" );

		debug_print( "Zombie couldn't path to breadcrumb at " + goal + " Finding next breadcrumb" );
		for( i = 0; i < crumb_list.size; i++ )
		{
			if( goal == crumb_list[i] )
			{
				bad_crumbs[bad_crumbs.size] = i;
				break;
			}
		}
	}
}

zombie_pathing_get_breadcrumb( origin, breadcrumbs, bad_crumbs, pick_random )
{
	assert( IsDefined( origin ) );
	assert( IsDefined( breadcrumbs ) );
	assert( IsArray( breadcrumbs ) );

	/#
		if ( pick_random )
		{
			debug_print( "Finding random breadcrumb" );
		}
	#/
			
	for( i = 0; i < breadcrumbs.size; i++ )
	{
		if ( pick_random )
		{
			crumb_index = RandomInt( breadcrumbs.size );
		}
		else
		{
			crumb_index = i;
		}
				
		if( crumb_is_bad( crumb_index, bad_crumbs ) )
		{
			continue;
		}

		return breadcrumbs[crumb_index];
	}

	return undefined;
}

crumb_is_bad( crumb, bad_crumbs )
{
	for ( i = 0; i < bad_crumbs.size; i++ )
	{
		if ( bad_crumbs[i] == crumb )
		{
			return true;
		}
	}

	return false;
}


jitter_enemies_bad_breadcrumbs( start_crumb )
{
	trace_distance = 35;
	jitter_distance = 2;
	
	index = start_crumb;
	
	while (isdefined(self.favoriteenemy.zombie_breadcrumbs[ index + 1 ]))
	{
		current_crumb = self.favoriteenemy.zombie_breadcrumbs[ index ];
		next_crumb = self.favoriteenemy.zombie_breadcrumbs[ index + 1 ];
		
		angles = vectortoangles(current_crumb - next_crumb);
		
		right = anglestoright(angles);
		left = anglestoright(angles + (0,180,0));
		
		dist_pos = current_crumb + vectorScale( right, trace_distance );
		
		trace = bulletTrace( current_crumb, dist_pos, true, undefined );
		vector = trace["position"];
		
		if (distance(vector, current_crumb) < 17 )
		{
			self.favoriteenemy.zombie_breadcrumbs[ index ] = current_crumb + vectorScale( left, jitter_distance );
			continue;
		}
		
		
		// try the other side
		dist_pos = current_crumb + vectorScale( left, trace_distance );
		
		trace = bulletTrace( current_crumb, dist_pos, true, undefined );
		vector = trace["position"];
		
		if (distance(vector, current_crumb) < 17 )
		{
			self.favoriteenemy.zombie_breadcrumbs[ index ] = current_crumb + vectorScale( right, jitter_distance );
			continue;
		}
		
		index++;
	}
	
}

zombie_follow_enemy()
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	self endon( "bad_path" );
	
	level endon( "intermission" );

	while( 1 )
	{
		if( IsDefined( self.favoriteenemy ) )
		{
			self SetGoalPos( self.favoriteenemy.origin );
		}

		wait( 0.1 );
	}
}


// When a Zombie spawns, set his eyes to glowing.
zombie_eye_glow()
{
	if( IsDefined( level.zombie_eye_glow ) && !level.zombie_eye_glow )
	{
		return; 
	}

	if( !IsDefined( self ) )
	{
		return;
	}

	linkTag = "J_Eyeball_LE";
	fxModel = "tag_origin";
	fxTag = "tag_origin";

	// SRS 9/2/2008: only using one particle now per Barry's request;
	//  modified to be able to turn particle off
	self.fx_eye_glow = Spawn( "script_model", self GetTagOrigin( linkTag ) );
	self.fx_eye_glow.angles = self GetTagAngles( linkTag );
	self.fx_eye_glow SetModel( fxModel );
	self.fx_eye_glow LinkTo( self, linkTag );

	// TEMP for testing
	//self.fx_eye_glow thread maps\_debug::drawTagForever( fxTag );

	PlayFxOnTag( level._effect["eye_glow"], self.fx_eye_glow, fxTag );
}

// Called when either the Zombie dies or if his head gets blown off
zombie_eye_glow_stop()
{
	if( IsDefined( self.fx_eye_glow ) )
	{
		self.fx_eye_glow Delete();
	}
}


// When a Zombie spawns, set his eyes to glowing.
zombie_dog_eye_glow()
{
	if( IsDefined( level.zombie_eye_glow ) && !level.zombie_eye_glow )
	{
		return; 
	}

	if( !IsDefined( self ) )
	{
		return;
	}
	wait(.5);
	
	if(isDefined(level._effect["dog_eye_glow"] ))
	{
		self.fx_eye_glow = Spawn( "script_model", self GetTagOrigin( "TAG_EYE" ) );
		self.fx_eye_glow.angles = self GetTagAngles( "TAG_EYE" );
		self.fx_eye_glow SetModel( "tag_origin" );
		self.fx_eye_glow LinkTo( self, "TAG_EYE" );
		PlayFxOnTag( level._effect["eye_glow"], self.fx_eye_glow, "tag_origin" );
	}
}

//
// DEBUG
//

zombie_history( msg )
{
/#
	if( !IsDefined( self.zombie_history ) )
	{
		self.zombie_history = [];
	}

	self.zombie_history[self.zombie_history.size] = msg;
#/
}

/*
	Zombie Rise Stuff
*/

zombie_rise()
{
	self endon("death");
	self endon("no_rise");

	while(!IsDefined(self.do_rise))
	{
		wait_network_frame();
	}

	self thread fixRiserEntLeak();
	self do_zombie_rise();
}

fixRiserEntLeak()
{
	self waittill( "death" );

	if ( isDefined( self.anchor ) )
		self.anchor delete ();
}

/*
zombie_rise:
Zombies rise from the ground
*/
do_zombie_rise()
{
	self endon("death");

	self.zombie_rise_version = (RandomInt(99999) % 2) + 1;	// equally choose between version 1 and verson 2 of the animations
	if (self.zombie_move_speed != "walk")
	{
		// only do version 1 anims for "run" and "sprint"
		self.zombie_rise_version = 1;
	}

	self.in_the_ground = true;

	//self.zombie_rise_version = 1; // TESTING: override version

	self.anchor = spawn("script_origin", self.origin);
	self.anchor.angles = self.angles;
	self linkto(self.anchor);

	spots = GetStructArray("zombie_rise", "targetname");
	spot = random(spots);

	/#
	if (GetDVarInt("zombie_rise_test"))
	{
		spot = SpawnStruct();			// I know this never gets deleted, but it's just for testing
		spot.origin = (472, 240, 56);	// TEST LOCATION
		spot.angles = (0, 0, 0);
	}
	#/

	anim_org = spot.origin;
	anim_ang = spot.angles;

	//TODO: bbarnes: do a bullet trace to the ground so the structs don't have to be exactly on the ground.

	if (self.zombie_rise_version == 2)
	{
		anim_org = anim_org + (0, 0, -14);	// version 2 animation starts 14 units below the ground
	}
	else
	{
		anim_org = anim_org + (0, 0, -45);	// start the animation 45 units below the ground
	}

	//self Teleport(anim_org, anim_ang);	// we should get this working for MP

	self Hide();
	self.anchor moveto(anim_org, .05);
	self.anchor waittill("movedone");

	// face goal
	target_org = maps\_zombiemode_spawner::get_desired_origin();
	if (IsDefined(target_org))
	{
		anim_ang = VectorToAngles(target_org - self.origin);
		self.anchor RotateTo((0, anim_ang[1], 0), .05);
		self.anchor waittill("rotatedone");
	}

	self unlink();
	self.anchor delete();

	self thread hide_pop();	// hack to hide the pop when the zombie gets to the start position before the anim starts

	level thread zombie_rise_death(self, spot);
	spot thread zombie_rise_fx(self);

	//self animMode("nogravity");
	//self setFlaggedAnimKnoballRestart("rise", level.scr_anim["zombie"]["rise_walk"], %body, 1, .1, 1);	// no "noclip" mode for these anim functions

	self AnimScripted("rise", self.origin, self.angles, self get_rise_anim());
	self animscripts\shared::DoNoteTracks("rise", ::handle_rise_notetracks, undefined, spot);

	self notify("rise_anim_finished");
	spot notify("stop_zombie_rise_fx");
	self.in_the_ground = false;
	self notify("risen");
}

hide_pop()
{
	wait .5;
	self Show();
}

handle_rise_notetracks(note, spot)
{
	// the anim notetracks control which death anim to play
	// default to "deathin" (still in the ground)

	if (note == "deathout" || note == "deathhigh")
	{
		self.zombie_rise_death_out = true;
		self notify("zombie_rise_death_out");

		wait 2;
		spot notify("stop_zombie_rise_fx");
	}
}

/*
zombie_rise_death:
Track when the zombie should die, set the death anim, and stop the animscripted so he can die
*/
zombie_rise_death(zombie, spot)
{
	//self.nodeathragdoll = true;
	zombie.zombie_rise_death_out = false;

	zombie endon("rise_anim_finished");

	while (zombie.health > 1)	// health will only go down to 1 when playing animation with AnimScripted()
	{
		zombie waittill("damage", amount);
	}

	spot notify("stop_zombie_rise_fx");

	zombie.deathanim = zombie get_rise_death_anim();
	zombie StopAnimScripted();	// stop the anim so the zombie can die.  death anim is handled by the anim scripts.
}

/*
zombie_rise_fx:	 self is the script struct at the rise location
Play the fx as the zombie crawls out of the ground and thread another function to handle the dust falling
off when the zombie is out of the ground.
*/
zombie_rise_fx(zombie)
{
	self thread zombie_rise_dust_fx(zombie);
	self thread zombie_rise_burst_fx();
	playsoundatposition ("zombie_spawn", self.origin);
	zombie endon("death");
	self endon("stop_zombie_rise_fx");
	wait 1;
	if (zombie.zombie_move_speed != "sprint")
	{
		// wait longer before starting billowing fx if it's not a really fast animation
		wait 1;
	}
}

zombie_rise_burst_fx()
{
	self endon("stop_zombie_rise_fx");
	self endon("rise_anim_finished");
	

	playfx(level._effect["rise_burst"],self.origin + ( 0,0,randomintrange(5,10) ) );
	wait(.25);
	playfx(level._effect["rise_billow"],self.origin + ( randomintrange(-10,10),randomintrange(-10,10),randomintrange(5,10) ) );
	
	
	//burst_time = 10; // play dust fx for a max time
	//interval = randomfloatrange(.15,.45); // wait this time in between playing the effect
		
	//for (t = 0; t < burst_time; t += interval)
	//{
	//	wait interval;
	//}	
}

zombie_rise_dust_fx(zombie)
{
	dust_tag = "J_SpineUpper";
	
	self endon("stop_zombie_rise_dust_fx");
	self thread stop_zombie_rise_dust_fx(zombie);

	dust_time = 7.5; // play dust fx for a max time
	dust_interval = .1; //randomfloatrange(.1,.25); // wait this time in between playing the effect
	
	//TODO - add rising dust stuff ere
	
	for (t = 0; t < dust_time; t += dust_interval)
	{
		PlayfxOnTag(level._effect["rise_dust"], zombie, dust_tag);
		wait dust_interval;
	}
}

stop_zombie_rise_dust_fx(zombie)
{
	zombie waittill("death");
	self notify("stop_zombie_rise_dust_fx");
}

/*
get_rise_anim:
Return a random rise animation based on a possible set of animations
*/
get_rise_anim()
{
	///* TESTING: put this block back in
	speed = self.zombie_move_speed;
    return random(level._zombie_rise_anims[self.animname][self.zombie_rise_version][speed]);
	//*/

	//return %ai_zombie_traverse_ground_v1_crawlfast;
	//return %ai_zombie_traverse_ground_v2_walk;
	//return %ai_zombie_traverse_ground_v2_walk_altB;
}

/*
get_rise_death_anim:
Return a random death animation based on a possible set of animations
*/
get_rise_death_anim()
{
	possible_anims = [];

	if (self.zombie_rise_death_out)
	{
		possible_anims = level._zombie_rise_death_anims[self.animname][self.zombie_rise_version]["out"];
	}
	else
	{
		possible_anims = level._zombie_rise_death_anims[self.animname][self.zombie_rise_version]["in"];
	}

	return random(possible_anims);
}

