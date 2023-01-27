#include maps\_utility;
#include animscripts\utility;
#include common_scripts\utility;

#using_animtree ("dog");

main()
{
	self endon("killanimscript");
	
	self debug_anim_print("dog_move::main()" );
	
	// Austin: TODO: may need to port SetAimAnimWeights
	//self SetAimAnimWeights( 0, 0 );
	
	self clearanim( %root, 0.2 );
	self clearanim( anim.dogAnims[self.animSet].move["run_stop"], 0 );
	
	//self thread randomSoundDuringRunLoop();

	if ( !isdefined( self.traverseComplete ) && !isdefined( self.skipStartMove ) && self.a.movement == "run" )
	{	
		self startMove();
		blendTime = 0;
	}
	else
	{
		blendTime = 0.2;
	}

	self.traverseComplete = undefined;
	self.skipStartMove = undefined;

	self clearanim( anim.dogAnims[self.animSet].move["run_start"], 0 );

	if ( self.a.movement == "run" )
	{
		if ( self need_to_turn() )
		{
			self turn();
		}
		else
		{
			weights = undefined;
			weights = self getRunAnimWeights();

			debug_anim_print( "dog_move::main() - Setting move_run" );
			debug_anim_print( "dog_move::main() - blendTime: " + blendTime );
			debug_anim_print( "dog_move::main() - weights[ 'center' ]:	" + weights[ "center" ] );
			debug_anim_print( "dog_move::main() - weights[ 'left' ]:	" + weights[ "left" ] );
			debug_anim_print( "dog_move::main() - weights[ 'right' ]:	" + weights[ "right" ] );

			self setanimrestart( anim.dogAnims[self.animSet].move["run"], weights[ "center" ], blendTime, 1 );
			self setanimrestart(anim.dogAnims[self.animSet].move["run_lean_L"], weights["left"], blendTime, 1);
			self setanimrestart(anim.dogAnims[self.animSet].move["run_lean_R"], weights["right"], blendTime, 1);
			self setflaggedanimknob( "dog_run", anim.dogAnims[self.animSet].move["run_knob"], 1, blendTime, self.moveplaybackrate );
			animscripts\shared::DoNoteTracksForTime(0.1, "dog_run");

			debug_anim_print("dog_move::main() - move_run wait 0.1 done " );
		}
	}
	else
	{
		debug_anim_print( "dog_move::main() - Setting move_walk ");
		self setflaggedanimrestart( "dog_walk", anim.dogAnims[self.animSet].move["walk"], 1, 0.2, self.moveplaybackrate );
	}
	
	//self thread animscripts\dog_stop::lookAtTarget( "normal" );
	
	while ( 1 )
	{	
		self moveLoop();
		
		if ( self.a.movement == "run" )
		{
			if ( self.disableArrivals == false )
		self thread stopMove();

		// if a "run" notify is received while stopping, clear stop anim and go back to moveLoop
		self waittill( "run" );
		self clearanim( anim.dogAnims[self.animSet].move["run_stop"] , 0.1 );
	}
}
}


moveLoop()
{
	self endon( "killanimscript" );
	self endon( "stop_soon" );

	while (1)
	{
		if ( self.disableArrivals )
			self.stopAnimDistSq = 0;
		else
			self.stopAnimDistSq = anim.dogAnims[self.animSet].dogStoppingDistSq;

		if ( self.a.movement == "run" )
		{
			if ( self need_to_turn() )
			{
				self turn();
			}
			else
			{
				weights = self getRunAnimWeights();

				self clearanim( anim.dogAnims[self.animSet].move["walk"], 0.3 );

				self setanim(anim.dogAnims[self.animSet].move["run"], weights["center"], 0.2, 1);
				self setanim(anim.dogAnims[self.animSet].move["run_lean_L"], weights["left"], 0.2, 1);
				self setanim(anim.dogAnims[self.animSet].move["run_lean_R"], weights["right"], 0.2, 1);
				self setflaggedanimknob( "dog_run", anim.dogAnims[self.animSet].move["run_knob"], 1, 0.2, self.moveplaybackrate );
		
				animscripts\shared::DoNoteTracksForTime(0.2, "dog_run");
			}
		}
		else
		{
			assert( self.a.movement == "walk" );

			self clearanim( anim.dogAnims[self.animSet].move["run_knob"], 0.3 );
			self setflaggedanim( "dog_walk", anim.dogAnims[self.animSet].move["walk"], 1, 0.2, self.moveplaybackrate );
			animscripts\shared::DoNoteTracksForTime( 0.2, "dog_walk" );

			// "stalking" behavior
			if ( self need_to_run() )
			{
				self.a.movement = "run";
				self notify( "dog_running" );
			}
		}
	}
}

startMoveTrackLookAhead()
{
	self endon("killanimscript");
	for ( i = 0; i < 2; i++ )
	{
		lookaheadAngle = vectortoangles( self.lookaheaddir );
		self OrientMode( "face angle", lookaheadAngle );
	}
}


startMove()
{
	{
		// just use code movement
		self setanimrestart( anim.dogAnims[self.animSet].move["run_start"], 1, 0.2, 1 );
	}

	self setflaggedanimknobrestart( "dog_prerun", anim.dogAnims[self.animSet].move["run_start_knob"], 1, 0.2, self.moveplaybackrate );
	
	self animscripts\shared::DoNoteTracks( "dog_prerun" );
	
	self animMode( "none" );
	self OrientMode( "face motion" );
}

		
stopMove()
{
	self endon( "killanimscript" );
	self endon( "run" );

	self clearanim( anim.dogAnims[self.animSet].move["run_knob"], 0.1 );
	self setflaggedanimrestart( "stop_anim", anim.dogAnims[self.animSet].move["run_stop"], 1, 0.2, 1 );
	self animscripts\shared::DoNoteTracks( "stop_anim" );
	}

	
randomSoundDuringRunLoop()
{
	self endon( "killanimscript" );
	while ( 1 )
	{
/#		
		if ( getdebugdvar( "debug_dog_sound" ) != "" )
			iprintln( "dog " + (self getentnum()) + " bark start " + getTime() );
#/
		if ( isdefined( self.script_growl ) )
			self play_sound_on_tag( "anml_dog_growl", "tag_eye" );
		else
			self play_sound_on_tag( "anml_dog_bark", "tag_eye" );
			
/#		
		if ( getdebugdvar( "debug_dog_sound" ) != "" )
			iprintln( "dog " + (self getentnum()) + " bark end " + getTime() );
#/
			
		wait( randomfloatrange( 0.1, 0.3 ) );
	}
}


// TODO: Austin: this functions the same as MP BG_Dog_GetRunAnimWeights
getRunAnimWeights()
{
	weights = [];
	weights["center"] = 0;
	weights["left"] = 0;
	weights["right"] = 0;
	
	if ( self.leanAmount > 0 )
	{
		if ( self.leanAmount < 0.95 )
			self.leanAmount	= 0.95;

		weights["left"] = 0;
		weights["right"] = (1 - self.leanAmount) * 20;

		if ( weights["right"] > 1 )
			weights["right"] = 1;	
		else if ( weights["right"] < 0 )
			weights["right"] = 0;	
			
		weights["center"] = 1 - weights["right"];
	}
	else if ( self.leanAmount < 0 )
	{
		if ( self.leanAmount > -0.95 )
			self.leanAmount	= -0.95;

		weights["right"] = 0;
		weights["left"] = (1 + self.leanAmount) * 20;

		if ( weights["left"] > 1 )
			weights["left"] = 1;
		if ( weights["left"] < 0 )
			weights["left"] = 0;		

		weights["center"] = 1 - weights["left"];
	}
	else
	{
		weights["left"] = 0;
		weights["right"] = 0;
		weights["center"] = 1;		
	}
	
	return weights;
}


get_turn_angle_delta(print_it)
{
// I have discovered a fundamental flaw with using the look ahead direction
// to determine the turn to angles.  In certain cases the pathing can be pathing 
// 90 degrees or more away from the current position but not in the real 
// direction of travel.  Usually this is seen by a path traversing to a path node
// not to far away from the current position, but off to the side or even behind.
// However using the look ahead distance to try eleminating this case also 
// eliminates a lot of valid cases. We need to rethink this turn system 
// for the next game.
// AlexC
	currentYaw = AngleClamp180(self.angles[1]);
	lookaheadDir = self.lookaheaddir;
	lookaheadAngles = vectortoangles(lookaheadDir);
	lookaheadYaw = AngleClamp180(lookaheadAngles[1]);
	deltaYaw = lookaheadYaw - currentYaw;

	preDeltaYaw = deltaYaw;
	if ( deltaYaw > 180 )
		deltaYaw -= 360;
	if ( deltaYaw < -180 )
		deltaYaw += 360;

	return deltaYaw;
}

need_to_turn()
{
	/#
	if ( getdvar("scr_dog_allow_turn_90") == "0" )
	{
		return false;
	}
	#/
	
	deltaYaw = self get_turn_angle_delta();

	if ( (deltaYaw > level.dogTurnAngle) || (deltaYaw < (-1 * level.dogTurnAngle)) )
	{
		debug_turn_print("need_to_turn check: " + self.lookaheaddist );
		if ( self.lookaheaddist > level.dogTurnMinDistanceToGoal )
		{
			debug_turn_print("need_to_turn: " + deltaYaw +" YES" );
			return true;
		}
	} 

	return false;
}

need_to_turn_around( deltaYaw )
{
	/#
	if ( getdvar("scr_dog_allow_turn_180") == "0" )
	{
		return false;
	}
	#/

	if ( (deltaYaw > level.dogTurnAroundAngle) || (deltaYaw < (-1 * level.dogTurnAroundAngle)) )
	{
		debug_turn_print("need_to_turn_around: " + deltaYaw +" YES" );
		return true;
	} 

	debug_turn_print("need_to_turn_around: " + deltaYaw +" NO" );
	return false;
}

clear_turn_anims()
{
	debug_anim_print( "dog_move::clear_turn_anims()" );
	self ClearAnim( anim.dogAnims[self.animSet].turn["turn_knob"], 0.0 );
}

need_to_run()
{
	run_dist_squared = 384 * 384;
	
	if ( GetDvar( "scr_dog_run_distance" ) != "" )
	{
		dist = GetDvarInt( "scr_dog_run_distance" );
		run_dist_squared = dist * dist;
	}
		
	run_yaw = 20;
	run_pitch = 30;
	run_height = 64;

	if ( self.a.movement != "walk" )
	{
		return false;
	}

	if ( self.health < self.maxhealth )
	{
		// dog took damage
		return true;
	}

	if ( !IsDefined( self.enemy ) || !IsAlive( self.enemy ) )
	{
		return false;
	}

	if ( !self CanSee( self.enemy ) )
	{
		return false;
	}

	dist = DistanceSquared( self.origin, self.enemy.origin ); 
	if ( dist > run_dist_squared )
	{
		return false;
	}

	height = self.origin[2] - self.enemy.origin[2];
	if ( abs( height ) > run_height )
	{
		return false;
	}

	yaw = self AbsYawToEnemy(); 
	if ( yaw > run_yaw )
	{
		return false;
	}

	pitch = AngleClamp180( VectorToAngles( self.origin - self.enemy.origin )[0] );
	if ( abs( pitch ) > run_pitch )
	{
		return false;
	}

	return true;
}

get_anim_string( animation )
{
	anim_str = "unknown";
	
/#
	if( animation == %german_shepard_turn_90_left )
		anim_str = "german_shepard_turn_90_left";
	else if( animation == %german_shepard_run_turn_90_left )
		anim_str = "german_shepard_run_turn_90_left";
	else if( animation == %german_shepard_turn_90_right )
		anim_str = "german_shepard_turn_90_right";
	else if( animation == %german_shepard_run_turn_90_right )
		anim_str = "german_shepard_run_turn_90_right";
	else if( animation == %german_shepard_turn_180_left )
		anim_str = "german_shepard_turn_180_left";
	else if( animation == %german_shepard_run_turn_180_left )
		anim_str = "german_shepard_run_turn_180_left";
	else if( animation == %german_shepard_turn_180_right )
		anim_str = "german_shepard_turn_180_right";
	else if( animation == %german_shepard_run_turn_180_right )
		anim_str = "german_shepard_run_turn_180_right";
#/

	return anim_str;
}

do_turn_anim( stopped_anim, run_anim, wait_time, run_wait_time )
{
	speed = length( self getaivelocity() );

	do_anim = stopped_anim;

	if ( level.dogRunTurnSpeed < speed )
	{
		do_anim = run_anim;
		wait_time = run_wait_time;
	}

	anim_str = get_anim_string( do_anim );

	self ClearAnim( %root, 0.2 );
	self ClearAnim( anim.dogAnims[self.animSet].move["run_stop"], 0.2 );
	clear_turn_anims();

	debug_anim_print("dog_move::do_turn_anim() - Setting " + anim_str );
	
	// Austin: TODO: ensure this is the correct blend function here
	self SetFlaggedAnim( "turn", do_anim, 1.0, 0.2, 1.0 );
	self animscripts\shared::DoNoteTracks( "turn" );
//self waittillmatch( "turn", "end" );//animscripts\shared::DoNoteTracksForTime( wait_time, "end");
	debug_anim_print("dog_move::turn_around_right() - done with " + anim_str + " wait time " + wait_time );
}

turn_left()
{
	self do_turn_anim( anim.dogAnims[self.animSet].turn["90_left"], anim.dogAnims[self.animSet].runTurn["90_left"], 0.5, 0.5 );
}

turn_right()
{
	self do_turn_anim( anim.dogAnims[self.animSet].turn["90_right"], anim.dogAnims[self.animSet].runTurn["90_right"], 0.5, 0.5 );
}

turn_around_left()
{
	self do_turn_anim( anim.dogAnims[self.animSet].turn["180_left"], anim.dogAnims[self.animSet].runTurn["180_left"], 0.5, 0.7 );
}

turn_around_right()
{
	self do_turn_anim( anim.dogAnims[self.animSet].turn["180_right"], anim.dogAnims[self.animSet].runTurn["180_right"], 0.5, 0.7 );
}

move_out_of_turn()
{
	if ( self.a.movement == "run" )
	{
		weights = undefined;
		weights = self getRunAnimWeights();
		blendTime = 0.2;

		debug_anim_print( "dog_move::move_out_of_turn() - Setting move_run" );
		debug_anim_print( "dog_move::move_out_of_turn() - blendTime: " + blendTime );
		debug_anim_print( "dog_move::move_out_of_turn() - weights[ 'center' ]:	" + weights[ "center" ] );
		debug_anim_print( "dog_move::move_out_of_turn() - weights[ 'left' ]:	" + weights[ "left" ] );
		debug_anim_print( "dog_move::move_out_of_turn() - weights[ 'right' ]:	" + weights[ "right" ] );

		self setanimrestart( anim.dogAnims[self.animSet].move["run"], weights[ "center" ], blendTime, 1 );
		self setanimrestart(anim.dogAnims[self.animSet].move["run_lean_L"], weights["left"], blendTime, 1);
		self setanimrestart(anim.dogAnims[self.animSet].move["run_lean_R"], weights["right"], blendTime, 1);
		self setflaggedanimknob( "dog_run", anim.dogAnims[self.animSet].move["run_knob"], 1, blendTime, self.moveplaybackrate );
		animscripts\shared::DoNoteTracksForTime(0.1, "done");

		debug_anim_print("dog_move::move_out_of_turn() - move_run wait 0.1 done " );
	}
	else
	{
		debug_anim_print( "dog_move::move_out_of_turn() - Setting move_start" );
		self setflaggedanimrestart( "dog_walk", anim.dogAnims[self.animSet].move["walk"], 1, 0.2, self.moveplaybackrate );
	}
}

turn()
{
	deltaYaw = self get_turn_angle_delta();

	if ( need_to_turn_around( deltaYaw ) )
	{
		self turn_around();
		return;
	}	
	currentYaw = AngleClamp180(self.angles[1]);
	self animMode( "zonly_physics" );

	// need to force the orient angle to the currentYaw here
	// the desired angles may already be updated for the "turn"
	// and cause a doubling of the rotation.  Telling it to face
	// current yaw resets the desired angles and uses only anim deltas
	self set_orient_mode( "face angle", currentYaw );

	debug_turn_print("turn deltaYaw: " + deltaYaw );

	if ( deltaYaw > level.dogTurnAngle )
	{
		debug_turn_print( "turn left", true);
		self turn_left();
	}
	else
	{
		debug_turn_print( "turn right", true);
		self turn_right();
	}

	self set_orient_mode( "face motion" );
	self animMode( "none" );

	move_out_of_turn();
}

turn_around()
{
	currentYaw = AngleClamp180(self.angles[1]);
	self animMode( "zonly_physics" );

	// need to force the orient angle to the currentYaw here
	// the desired angles may already be updated for the "turn"
	// and cause a doubling of the rotation.  Telling it to face
	// current yaw resets the desired angles and uses only anim deltas
	self set_orient_mode( "face angle", currentYaw );

	deltaYaw = self get_turn_angle_delta( true );
	//println("turning around " + Gettime() );

	debug_turn_print( "turn_around deltaYaw: " + deltaYaw );

	// pick either
	if (deltaYaw > 177 || deltaYaw < -177)
	{
		if ( randomint(2) == 0 )
		{
			debug_turn_print( "turn_around random right", true);
			self turn_around_right();
		}
		else
		{
			debug_turn_print( "turn_around random left", true);
			self turn_around_left();
		}
	}
	else if ( deltaYaw > level.dogTurnAroundAngle )
	{
		debug_turn_print( "turn_around left", true);
		self turn_around_left();
	}
	else
	{
		debug_turn_print( "turn_around right", true);
		self turn_around_right();
	}

	self set_orient_mode( "face motion" );
	self animMode( "none" );

	move_out_of_turn();
}
