#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility; 
#using_animtree( "generic_human" );

init()
{
	init_blockers(); 
//	level thread rebuild_barrier_think(); 

	//////////////////////////////////////////
	//designed by prod
	//set_zombie_var( "rebuild_barrier_cap_per_round", 500 );
	//////////////////////////////////////////
}

init_blockers()
{
	// EXTERIOR BLOCKERS ----------------------------------------------------------------- //
	level.exterior_goals = getstructarray( "exterior_goal", "targetname" ); 

	for( i = 0; i < level.exterior_goals.size; i++ )
	{
		level.exterior_goals[i] thread blocker_init();
	}

	// DOORS ----------------------------------------------------------------------------- //
	zombie_doors = GetEntArray( "zombie_door", "targetname" ); 

	for( i = 0; i < zombie_doors.size; i++ )
	{
		zombie_doors[i] thread door_init(); 
	}

	// DEBRIS ---------------------------------------------------------------------------- //
	zombie_debris = GetEntArray( "zombie_debris", "targetname" ); 

	for( i = 0; i < zombie_debris.size; i++ )
	{
		zombie_debris[i] thread debris_init(); 
	}

	// Flag Blockers ---------------------------------------------------------------------- //
	flag_blockers = GetEntArray( "flag_blocker", "targetname" );

	for( i = 0; i < flag_blockers.size; i++ )
	{
		flag_blockers[i] thread flag_blocker(); 
	}	
}

//
// DOORS --------------------------------------------------------------------------------- //
//
door_init()
{
	self.type = undefined; 

	// Figure out what kind of door we are
	targets = GetEntArray( self.target, "targetname" ); 
		
	
	//CHRIS_P - added script_flag support for doors as well
	if( isDefined(self.script_flag) && !IsDefined( level.flag[self.script_flag] ) ) 
	{
		flag_init( self.script_flag ); 
	}	

	//MM Consolidate type code
	for(i=0;i<targets.size;i++)
	{
		targets[i] disconnectpaths();
		if ( IsDefined(targets[i].script_noteworthy) && targets[i].script_noteworthy == "clip" )
		{
			self.clip = targets[i];
			self.script_string = "clip";
		}
		else if( !IsDefined( targets[i].script_string ) )
		{
			if( IsDefined( targets[i].script_angles ) )
			{
				targets[i].script_string = "rotate";
			}
			else if( IsDefined( targets[i].script_vector ) )
			{
				targets[i].script_string = "move";
			}
		}
		else
		{
			if ( targets[i].script_string == "anim" )
			{
				AssertEx( IsDefined( targets[i].script_animname ), "Blocker_init: You must specify a script_animname for "+targets[i].targetname ); 
				AssertEx( IsDefined( level.scr_anim[ targets[i].script_animname ] ), "Blocker_init: You must define a level.scr_anim for script_anim -> "+targets[i].script_animname ); 
				AssertEx( IsDefined( level.blocker_anim_func ), "Blocker_init: You must define a level.blocker_anim_func" ); 
			}
		}
	}
	self.doors = targets;

	//AssertEx( IsDefined( self.type ), "You must determine how this door opens. Specify script_angles, script_vector, or a script_noteworthy... Door at: " + self.origin ); 

	cost = 1000;
	if( IsDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}

	self set_hint_string( self, "default_buy_door_" + cost );
	self SetCursorHint( "HINT_NOICON" ); 	
	self UseTriggerRequireLookAt();
	self thread door_think(); 

	// MM - Added support for electric doors.  Don't have to add them to level scripts
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "electric_door" )
	{
		self set_door_unusable();
		if( isDefined( level.door_dialog_function ) )
		{
			self thread [[ level.door_dialog_function ]]();
		}
	}
}


door_think()
{
	// maybe the door the should just bust open instead of slowly opening.
	// maybe just destroy the door, could be two players from opposite sides..
	// breaking into chunks seems best.
	// or I cuold just give it no collision
	while( 1 )
	{
		if(isDefined(self.script_noteworthy) && self.script_noteworthy == "electric_door")
		{
			flag_wait( "electricity_on" );
		}
		else
		{
			self waittill( "trigger", who ); 
			if( !who UseButtonPressed() )
			{
				continue;
			}

			if( who in_revive_trigger() )
			{
				continue;
			}

			if( is_player_valid( who ) )
			{
				if( who.score >= self.zombie_cost )
				{
					// set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 
					if( isDefined( level.achievement_notify_func ) )
					{
						level [[ level.achievement_notify_func ]]( "DLC3_ZOMBIE_ALL_DOORS" );
					}
					bbPrint( "zombie_uses: playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type door", who.playername, who.score, level.round_number, self.zombie_cost, self.target, self.origin );
				}
				else // Not enough money
				{
					play_sound_at_pos( "no_purchase", self.doors[0].origin );
					// who thread maps\_zombiemode_perks::play_no_money_perk_dialog();
					continue;
				}
			}
		}

		// Door has been activated, make it do its thing
		sound_played = false;
		for(i=0;i<self.doors.size;i++)
		{
			self.doors[i] NotSolid(); 
			self.doors[i] connectpaths();
			
			// Prevent multiple triggers from making doors move more than once
			if ( IsDefined(self.doors[i].door_moving) )
			{
				continue;
			}
			self.doors[i].door_moving = 1;
			
			if ( ( IsDefined( self.doors[i].script_noteworthy )	&& self.doors[i].script_noteworthy == "clip" ) ||
				 ( IsDefined( self.doors[i].script_string )		&& self.doors[i].script_string == "clip" ) )
			{
				continue;
			}

			if ( IsDefined( self.doors[i].script_sound ) )
			{
				play_sound_at_pos( self.doors[i].script_sound, self.doors[i].origin );
			}
			else
			{
				play_sound_at_pos( "door_slide_open", self.doors[i].origin );
			}

			time = 1; 
			if( IsDefined( self.doors[i].script_transition_time ) )
			{
				time = self.doors[i].script_transition_time; 
			}

			// MM - each door can now have a different opening style instead of
			//	needing to be all the same
			switch( self.doors[i].script_string )
			{
			case "rotate":
				if(isDefined(self.doors[i].script_angles))
				{
					self.doors[i] RotateTo( self.doors[i].script_angles, time, 0, 0 ); 
					self.doors[i] thread door_solid_thread(); 
				}
				wait(randomfloat(.15));						
				break;
			case "move":
			case "slide_apart":
				if(isDefined(self.doors[i].script_vector))
				{
					self.doors[i] MoveTo( self.doors[i].origin + self.doors[i].script_vector, time, time * 0.25, time * 0.25 ); 
					self.doors[i] thread door_solid_thread();
				}
				wait(randomfloat(.15));						
				break;

			case "anim":
//						self.doors[i] animscripted( "door_anim", self.doors[i].origin, self.doors[i].angles, level.scr_anim[ self.doors[i].script_animname ] );
				self.doors[i] [[ level.blocker_anim_func ]]( self.doors[i].script_animname ); 
				self.doors[i] thread door_solid_thread_anim();
				wait(randomfloat(.15));						
				break;
			}

			// Just play purchase sound on the first door
            if(!sound_played)
            {
                play_sound_at_pos( "purchase", self.doors[i].origin );
                sound_played = true;
            }
				
			//Chris_P - just in case spawners are targeted
			if( isDefined( self.doors[i].target ) )
			{
				// door needs to target new spawners which will become part
				// of the level enemy array
				self.doors[i] add_new_zombie_spawners();
			}
		}
	
		//CHRIS_P
		//set any flags
		if( IsDefined( self.script_flag ) )
		{
			flag_set( self.script_flag );
		}				
		
		// get all trigs, we might want a trigger on both sides
		// of some junk sometimes
		all_trigs = getentarray( self.target, "target" ); 
		for( i = 0; i < all_trigs.size; i++ )
		{
			all_trigs[i] trigger_off(); 
		}
		break;
	}
}


//
//	Waits until it is finished moving and then returns to solid once no player is touching it
//		(So they don't get stuck).  The door is made notSolid initially, otherwise, a player
//		could block its movement or cause a player to become stuck.
door_solid_thread()
{
	// MM - added support for movedone.
	self waittill_either( "rotatedone", "movedone" ); 

	while( 1 )
	{
		players = get_players(); 
		player_touching = false; 
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] IsTouching( self ) )
			{
				player_touching = true; 
				break; 
			}
		}

		if( !player_touching )
		{
			self Solid(); 
			return; 
		}

		wait( 1 ); 
	}
}


//
//	Called on doors using anims.  It needs a different waittill, 
//		and expects the animname message to be the same as the one passed into scripted anim
door_solid_thread_anim( )
{
	// MM - added support for movedone.
	self waittillmatch( "door_anim", "end" ); 

	while( 1 )
	{
		players = get_players(); 
		player_touching = false; 
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] IsTouching( self ) )
			{
				player_touching = true; 
				break; 
			}
		}

		if( !player_touching )
		{
			self Solid(); 
			return; 
		}

		wait( 1 ); 
	}
}


//
//  Electric doors are unuseable
set_door_unusable()
{
	self sethintstring(&"ZOMBIE_FLAMES_UNAVAILABLE");
	self UseTriggerRequireLookAt();
}


//
// DEBRIS ----------------------------------------------------------------------------------- //
//

debris_init()
{
	cost = 1000;
	if( IsDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}

	self set_hint_string( self, "default_buy_debris_" + cost );
	self SetCursorHint( "HINT_NOICON" ); 

	if( isdefined (self.script_flag)  && !IsDefined( level.flag[self.script_flag] ) )
	{
		flag_init( self.script_flag ); 
	}

	self UseTriggerRequireLookAt();
	self thread debris_think(); 
}

debris_think()
{
	
	
	//this makes the script_model not-solid ( for asylum only! )
	if(level.script == "nazi_zombie_asylum")
	{
		ents = getentarray( self.target, "targetname" ); 
		for( i = 0; i < ents.size; i++ )
		{	
			if( IsDefined( ents[i].script_linkTo ) )
			{
				ents[i] notsolid();
			}
		}
	}
		
	
	while( 1 )
	{
		self waittill( "trigger", who ); 

		if( !who UseButtonPressed() )
		{
			continue;
		}

		if( who in_revive_trigger() )
		{
			continue;
		}

		if( is_player_valid( who ) )
		{
			if( who.score >= self.zombie_cost )
			{
				// set the score
				who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 
				if( isDefined( level.achievement_notify_func ) )
				{
					level [[ level.achievement_notify_func ]]( "DLC3_ZOMBIE_ALL_DOORS" );
				}
				bbPrint( "zombie_uses: playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type debris", who.playername, who.score, level.round_number, self.zombie_cost, self.target, self.origin );
				
				// delete the stuff
				junk = getentarray( self.target, "targetname" ); 
	
				if( IsDefined( self.script_flag ) )
				{
					flag_set( self.script_flag );
				}

				play_sound_at_pos( "purchase", self.origin );
	
				move_ent = undefined;
				clip = undefined;
				for( i = 0; i < junk.size; i++ )
				{	
					junk[i] connectpaths(); 
					junk[i] add_new_zombie_spawners(); 
					
	
					level notify ("junk purchased");
	
					if( IsDefined( junk[i].script_noteworthy ) )
					{
						if( junk[i].script_noteworthy == "clip" )
						{
							clip = junk[i];
							continue;
						}
					}
	
					struct = undefined;
					if( IsDefined( junk[i].script_linkTo ) )
					{
						struct = getstruct( junk[i].script_linkTo, "script_linkname" );
						if( IsDefined( struct ) )
						{
							move_ent = junk[i];
							junk[i] thread debris_move( struct );
						}
						else
						{
							junk[i] Delete();
						}
					}
					else
					{
						junk[i] Delete();
					}
				}
				
				// get all trigs, we might want a trigger on both sides
				// of some junk sometimes
				all_trigs = getentarray( self.target, "target" ); 
				for( i = 0; i < all_trigs.size; i++ )
				{
					all_trigs[i] delete(); 
				}
	
				if( IsDefined( clip ) )
				{
					if( IsDefined( move_ent ) )
					{
						move_ent waittill( "movedone" );
						move_ent notsolid();
					}
	
					clip Delete();
				}
				
				break; 								
			}
			else
			{
				play_sound_at_pos( "no_purchase", self.origin );
				// who thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
			}
		}
	}
}

debris_move( struct )
{
	self script_delay();
	//chrisp - prevent playerse from getting stuck on the stuff
	self notsolid();
	
	self play_sound_on_ent( "debris_move" );
	playsoundatposition ("lightning_l", self.origin);
	if( IsDefined( self.script_firefx ) )
	{
		PlayFX( level._effect[self.script_firefx], self.origin );
	}

	// Do a little jiggle, then move.
	if( IsDefined( self.script_noteworthy ) )
	{
		if( self.script_noteworthy == "jiggle" )
		{
			num = RandomIntRange( 3, 5 );
			og_angles = self.angles;
			for( i = 0; i < num; i++ )
			{
				angles = og_angles + ( -5 + RandomFloat( 10 ), -5 + RandomFloat( 10 ), -5 + RandomFloat( 10 ) );
				time = RandomFloatRange( 0.1, 0.4 );
				self Rotateto( angles, time );
				wait( time - 0.05 );
			}
		}
	}

	time = 0.5;
	if( IsDefined( self.script_transition_time ) )
	{
		time = self.script_transition_time; 
	}

	self MoveTo( struct.origin, time, time * 0.5 );
	self RotateTo( struct.angles, time * 0.75 );

	self waittill( "movedone" );

	self thread play_sound_on_entity ("couch_slam");
//	self playloopsound ("couch_loop");
//	self delete();
	if( IsDefined( self.script_fxid ) )
	{
		PlayFX( level._effect[self.script_fxid], self.origin );
		playsoundatposition("zombie_spawn", self.origin); //just playing the zombie_spawn sound when it deletes the blocker because it matches the particle.
	}

//	if( IsDefined( self.script_delete ) )
//	{
		self Delete();
//	}
}

//
// BLOCKER -------------------------------------------------------------------------- //
//
blocker_init()
{
	if( !IsDefined( self.target ) )
	{
		return;
	}

	targets = GetEntArray( self.target, "targetname" ); 

	self.barrier_chunks = []; 
	for( j = 0; j < targets.size; j++ )
	{
		if( IsDefined( targets[j].script_noteworthy ) )
		{
			if( targets[j].script_noteworthy == "clip" )
			{
				self.clip = targets[j]; 
				continue; 
			}
		}

		targets[j].destroyed = false;
		targets[j].claimed = false;
		targets[j].og_origin = targets[j].origin;
		self.barrier_chunks[self.barrier_chunks.size] = targets[j];
	}
    
    // Moved out of the loop, as it makes no sense to be run for every barrier chunk - Feli
	if(self.barrier_chunks.size > 0)
		self blocker_attack_spots();

	assert( IsDefined( self.clip ) );
	self.trigger_location = getstruct( self.target, "targetname" ); 

	self thread blocker_think(); 
}

blocker_attack_spots()
{
	// Get closest chunk
	chunk = getClosest( self.origin, self.barrier_chunks );
	
	dist = Distance2d( self.origin, chunk.origin ) - 36;
	spots = [];
	spots[0] = groundpos( self.origin + ( AnglesToForward( self.angles ) * dist ) + ( 0, 0, 60 ) );
	spots[spots.size] = groundpos( spots[0] + ( AnglesToRight( self.angles ) * 28 ) + ( 0, 0, 60 ) );
	spots[spots.size] = groundpos( spots[0] + ( AnglesToRight( self.angles ) * -28 ) + ( 0, 0, 60 ) );

	taken = [];
	for( i = 0; i < spots.size; i++ )
	{
		taken[i] = false;
	}

	self.attack_spots_taken = taken;
	self.attack_spots = spots;

	self thread debug_attack_spots_taken();
}

blocker_think()
{
	while( 1 )
	{
		wait( 0.5 ); 

		if( all_chunks_intact( self.barrier_chunks ) )
		{
			continue; 
		}

		self blocker_trigger_think(); 
	}
}

blocker_trigger_think()
{
	// They don't cost, they now award the player the cost...
	cost = 10;
	if( IsDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost; 
	}

	original_cost = cost;

	radius = 96; 
	height = 96; 

	if( IsDefined( self.trigger_location ) )
	{
		trigger_location = self.trigger_location; 
	}
	else
	{
		trigger_location = self; 
	}

	if( IsDefined( trigger_location.radius ) )
	{
		radius = trigger_location.radius; 
	}

	if( IsDefined( trigger_location.height ) )
	{
		height = trigger_location.height; 
	}

	trigger_pos = groundpos( trigger_location.origin ) + ( 0, 0, 4 );
	trigger = Spawn( "trigger_radius", trigger_pos, 0, radius, height ); 
	trigger thread trigger_delete_on_repair();
	/#
		if( GetDvarInt( "zombie_debug" ) > 0 )
		{
			thread debug_blocker( trigger_pos, radius, height ); 
		}
	#/

	// Rebuilding no longer costs us money... It's rewarded
	
	//////////////////////////////////////////
	//designed by prod; NO reward hint (See DT#36173)
	trigger set_hint_string( self, "default_reward_barrier_piece" );
	//trigger thread blocker_doubler_hint( "default_reward_barrier_piece_", original_cost );
	//////////////////////////////////////////
	
	doubler_status = level.zombie_vars["zombie_powerup_point_doubler_on"];

	if( level.zombie_vars["zombie_point_scalar"] == 2 )
	{
		cost = original_cost * 2;
	}
	else if( level.zombie_vars["zombie_point_scalar"] == 4 )
	{
		cost = original_cost * 4;
	}

	trigger SetCursorHint( "HINT_NOICON" ); 

	while( 1 )
	{
		trigger waittill( "trigger", player ); 

		if( player hasperk( "specialty_fastreload" ) )
		{
			has_perk = true;
		}
		else
		{
			has_perk = false;
		}
		
		if( all_chunks_intact( self.barrier_chunks ) )
		{
			trigger notify("all_boards_repaired");
			return;
		}

	
		while( 1 )
		{
			if( !player IsTouching( trigger ) )
			{
				break;
			}

			if( !is_player_valid( player ) )
			{
				break; 
			}

			if( player in_revive_trigger() )
			{
				break;
			}

	
			if( !player UseButtonPressed() )
			{
				break; 
			}

			if( doubler_status != level.zombie_vars["zombie_powerup_point_doubler_on"] )
			{
				doubler_status = level.zombie_vars["zombie_powerup_point_doubler_on"];
				cost = original_cost;
				if( level.zombie_vars["zombie_point_scalar"] == 2 )
				{
					cost = original_cost * 2;
				}
				else if( level.zombie_vars["zombie_point_scalar"] == 4 )
				{
					cost = original_cost * 4;
				}
			}
	
			// restore a random chunk
			chunk = get_random_destroyed_chunk( self.barrier_chunks ); 
			assert( chunk.destroyed == true ); 
	
			chunk Show(); 
	
			//TUEY Play the sounds
			player.rebuild_barrier_reward++; // jb - each time we repair it increases by just 1 indicating how many # of repairs, not points #, so that 2x points doesnt nerf us

			chunk play_sound_on_ent( "rebuild_barrier_piece" );
			if( (player.rebuild_barrier_reward < level.zombie_vars["rebuild_barrier_cap_per_round"]) )
			{
				play_sound_at_pos("purchase", player.origin);
				failsafe = true;
			}
			else
			{
				failsafe = undefined;
			}

			self thread replace_chunk( chunk, has_perk );
	
			assert( IsDefined( self.clip ) );
			self.clip enable_trigger(); 
			self.clip DisconnectPaths(); 

			if( !self script_delay() )
			{
				wait( 1 ); 
			}

			if( !is_player_valid( player ) )
			{
				break;
			}
	
			// set the score
			if( (player.rebuild_barrier_reward < level.zombie_vars["rebuild_barrier_cap_per_round"]) && isDefined(failsafe) && failsafe == true ) // only give points if we got sound, because of one sec delay
			{
				player maps\_zombiemode_score::add_to_player_score( cost );

			}
			// general contractor achievement for dlc 2. keep track of how many board player repaired.
			if(IsDefined(player.board_repair))
			{
				player.board_repair += 1;
			}

			if( all_chunks_intact( self.barrier_chunks ) )
			{
				trigger notify("all_boards_repaired");
				return;
			}
			
		}
	}
}

trigger_delete_on_repair()
{
	while( IsDefined( self ) )
	{
		self waittill("all_boards_repaired");
		self delete();
		break;
		
	}

}

blocker_doubler_hint( hint, original_cost )
{
	self endon( "death" );

	doubler_status = level.zombie_vars["zombie_powerup_point_doubler_on"];
	while( 1 )
	{
		wait( 0.5 );

		if( doubler_status != level.zombie_vars["zombie_powerup_point_doubler_on"] )
		{
			doubler_status = level.zombie_vars["zombie_powerup_point_doubler_on"];
			cost = original_cost;
				if( level.zombie_vars["zombie_point_scalar"] == 2 )
				{
					cost = original_cost * 2;
				}
				else if( level.zombie_vars["zombie_point_scalar"] == 4 )
				{
					cost = original_cost * 4;
				}
	
			self set_hint_string( self, hint + cost );
		}
	}
}

rebuild_barrier_reward_reset()
{
	self.rebuild_barrier_reward = 0;
}

remove_chunk( chunk, node, destroy_immediately )
{
	chunk play_sound_on_ent( "break_barrier_piece" );

	earthquake( RandomFloatRange( 0.3, 0.4 ), RandomFloatRange(0.2, 0.4), chunk.origin, 100 ); 
	
	chunk NotSolid();

	//if ( isdefined( destroy_immediately ) && destroy_immediately)
	//{
	//	chunk.destroyed = true;
	//}
	//
	fx = "wood_chunk_destory";
	if( IsDefined( self.script_fxid ) )
	{
		fx = self.script_fxid;
	}

	playfx( level._effect[fx], chunk.origin ); 
	playfx( level._effect[fx], chunk.origin + ( randomint( 20 ), randomint( 20 ), randomint( 10 ) ) ); 
	playfx( level._effect[fx], chunk.origin + ( randomint( 40 ), randomint( 40 ), randomint( 20 ) ) ); 

	if( IsDefined( chunk.script_moveoverride ) && chunk.script_moveoverride )
	{
		chunk Hide();
	}
	else
	{
//		angles = node.angles +( 0, 180, 0 );
//		force = AnglesToForward( angles + ( -60, 0, 0 ) ) * ( 200 + RandomInt( 100 ) ); 
//		chunk PhysicsLaunch( chunk.origin, force );
	
		ent = Spawn( "script_origin", chunk.origin ); 
		ent.angles = node.angles +( 0, 180, 0 );
		dist = 100 + RandomInt( 100 );
		dest = ent.origin + ( AnglesToForward( ent.angles ) * dist );
		trace = BulletTrace( dest + ( 0, 0, 16 ), dest + ( 0, 0, -200 ), false, undefined );

		if( trace["fraction"] == 1 )
		{
			dest = dest + ( 0, 0, -200 );
		}
		else
		{
			dest = trace["position"];
		}
	
//		time = 1; 
		chunk LinkTo( ent ); 

		time = ent fake_physicslaunch( dest, 200 + RandomInt( 100 ) );

//		forward = AnglesToForward( ent.angles + ( -60, 0, 0 ) ) * power ); 
//		ent MoveGravity( forward, time ); 

		if( RandomInt( 100 ) > 40 )
		{
			ent RotatePitch( 180, time * 0.5 );
		}
		else
		{
			ent RotatePitch( 90, time, time * 0.5 ); 
		}
		wait( time );

		chunk Hide();
	
		wait( 1 );
		ent Delete(); 
	}

	//if (isdefined( destroy_immediately ) && destroy_immediately)
	//{
	//	return;
	//}

	chunk.destroyed = true;
	chunk.target_by_zombie = undefined;
	chunk.mid_repair = undefined;
	chunk notify( "destroyed" );

	if( all_chunks_destroyed( node.barrier_chunks ) )
	{
		if( IsDefined( node.clip ) )
		{
			node.clip ConnectPaths(); 
			wait( 0.05 ); 
			node.clip disable_trigger(); 
		}
		else
		{
			for( i = 0; i < node.barrier_chunks.size; i++ )
			{
				node.barrier_chunks[i] ConnectPaths(); 
			}
		}
	}
}

replace_chunk( chunk, has_perk, via_powerup )
{
	if(! IsDefined( has_perk ) )
	{
		has_perk = false;
	}

	assert( IsDefined( chunk.og_origin ) );
	
	assert( !IsDefined( chunk.mid_repair ) );
	chunk.mid_repair = true;
	
	chunk Show();

	sound = "rebuild_barrier_hover";
	if( IsDefined( chunk.script_presound ) )
	{
		sound = chunk.script_presound;
	}


	if( !isdefined( via_powerup  ) )
	{
		play_sound_at_pos( sound, chunk.origin );
	}


	only_z = ( chunk.origin[0], chunk.origin[1], chunk.og_origin[2] ); 


	if( has_perk == true )
	{

		chunk RotateTo( ( 0, 0, 0 ),  0.15 ); 
		chunk waittill_notify_or_timeout( "rotatedone", 1 ); 
		wait( 0.1 ); 
	}
	else
	{

		chunk MoveTo( only_z, 0.15); 
		chunk RotateTo( ( 0, 0, 0 ),  0.3 ); 
		chunk waittill_notify_or_timeout( "rotatedone", 1 ); 
		wait( 0.2 ); 
	}


	if( has_perk == true )
	{
		chunk MoveTo( chunk.og_origin, 0.05 ); 
	}
	else
	{
		chunk MoveTo( chunk.og_origin, 0.1 ); 
	}
	
	chunk waittill_notify_or_timeout( "movedone", 1 ); 
	assert( chunk.origin == chunk.og_origin );

	if( !isdefined( via_powerup  ) )
	{
		earthquake( RandomFloatRange( 0.3, 0.4 ), RandomFloatRange(0.2, 0.4), chunk.origin, 150 ); 
	}
	
	chunk.target_by_zombie = undefined;
	chunk.destroyed = false; 
	
	assert( chunk.mid_repair == true );
	chunk.mid_repair = undefined;

	sound = "barrier_rebuild_slam";
	if( IsDefined( self.script_ender ) )
	{
		sound = self.script_ender;
	}
	
	

	chunk Solid(); 

	fx = "wood_chunk_destory";
	if( IsDefined( self.script_fxid ) )
	{
		fx = self.script_fxid;
	}
	
	if( !IsDefined( via_powerup ) )
	{
		play_sound_at_pos( sound, chunk.origin );
		playfx( level._effect[fx], chunk.origin ); 
		playfx( level._effect[fx], chunk.origin +( randomint( 20 ), randomint( 20 ), randomint( 10 ) ) ); 
		playfx( level._effect[fx], chunk.origin +( randomint( 40 ), randomint( 40 ), randomint( 20 ) ) ); 
	}

	if( !Isdefined( self.clip ) )
	{
		chunk Disconnectpaths(); 
	}
	
}

add_new_zombie_spawners()
{
	if( isdefined( self.target ) )
	{
		self.possible_spawners = getentarray( self.target, "targetname" ); 
	}	

	if( isdefined( self.script_string ) )
	{
		spawners = getentarray( self.script_string, "targetname" ); 
		self.possible_spawners = array_combine( self.possible_spawners, spawners );
	}	
	
	if( !isdefined( self.possible_spawners ) )
	{
		return; 
	}
	
	// add new check if they've been added already
	zombies_to_add = self.possible_spawners; 

	for( i = 0; i < self.possible_spawners.size; i++ )
	{
		self.possible_spawners[i].locked_spawner = false;
		add_spawner( self.possible_spawners[i] );
	}
}

//
// Flag Blocker ----------------------------------------------------------------------------------- //
//

flag_blocker()
{
	if( !IsDefined( self.script_flag_wait ) )
	{
		AssertMsg( "Flag Blocker at " + self.origin + " does not have a script_flag_wait key value pair" );
		return;
	}

	if( !IsDefined( level.flag[self.script_flag_wait] ) )
	{
		flag_init( self.script_flag_wait ); 
	}

	type = "connectpaths";
	if( IsDefined( self.script_noteworthy ) )
	{
		type = self.script_noteworthy;
	}

	flag_wait( self.script_flag_wait );

	self script_delay();

	if( type == "connectpaths" )
	{
		self ConnectPaths();
		self disable_trigger();
		return;
	}

	if( type == "disconnectpaths" )
	{
		self DisconnectPaths();
		self disable_trigger();
		return;
	}

	AssertMsg( "flag blocker at " + self.origin + ", the type \"" + type + "\" is not recognized" );
}


