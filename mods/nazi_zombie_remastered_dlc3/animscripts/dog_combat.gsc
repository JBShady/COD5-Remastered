#include common_scripts\utility;
#include animscripts\utility;
#include maps\_utility;

#using_animtree ("dog");

main()
{
	debug_anim_print("dog_combat::main() " );

	self endon("killanimscript");
	
	// Austin: TODO: may need to port SetAimAnimWeights() from MP
	//self SetAimAnimWeights( 0, 0 );

	assert( isdefined( self.enemy ) );
	if ( !isalive( self.enemy ) )
	{
		combatIdle();
		return;
	}

	assert( IsPlayer( self.enemy ) );
	self notify( "dog_combat" );
	
	if ( IsPlayer(self.enemy) )
		self meleeBiteAttackPlayer(self.enemy);
}

killplayer(player)
{
	self endon( "pvd_melee_interrupted" );
	
	player.specialDeath = true;
	player setcandamage( true );

	wait 1;

	damage = player.health + 1;
	
	if ( !isalive( player ) )
		return;
}


attackMiss()
{
	if ( isdefined( self.enemy ) )
	{
		forward	= anglestoforward( self.angles );
		dirToEnemy = self.enemy.origin - ( self.origin + vectorscale( forward, 50 ) );
		if ( vectordot( dirToEnemy, forward ) > 0 )
		{
			debug_anim_print("dog_combat::attackMiss() - Setting  combat_attack_miss" );
			//self setanimstate( "combat_attack_miss" );
			self ClearAnim( %root, 0.1 );
			self SetFlaggedAnimRestart( "miss", anim.dogAnims[self.animSet].attack["attack_player_miss"], 1.0, 0.2, 1.0 );
			self thread animscripts\dog_stop::lookAtTarget( "normal" );
		}
		else 
		{
			self.skipStartMove = true;
			self thread attackMissTrackTargetThread();

			if ( ( dirToEnemy[0] * forward[1] - dirToEnemy[1] * forward[0] ) > 0 )
			{
				debug_anim_print("dog_combat::attackMiss() - Setting  combat_attack_miss_right" );
				//self setanimstate( "combat_attack_miss_right" );
				self ClearAnim( %root, 0.1 );
				self SetFlaggedAnimRestart( "miss", anim.dogAnims[self.animSet].attack["attack_player_miss_turnR"], 1.0, 0.2, 1.0 );
			}
			else
			{
				debug_anim_print("dog_combat::attackMiss() - Setting  combat_attack_miss_left" );
				//self setanimstate( "combat_attack_miss_left" );
				self ClearAnim( %root, 0.1 );
				self SetFlaggedAnimRestart( "miss", anim.dogAnims[self.animSet].attack["attack_player_miss_turnL"], 1.0, 0.2, 1.0 );
			}
		}
	}
	else
	{
		debug_anim_print("dog_combat::attackMiss() - self.enemy undefined - Setting  combat_attack_miss" );
		//self setanimstate( "combat_attack_miss" );
		self ClearAnim( %root, 0.1 );
		self SetFlaggedAnimRestart( "miss", anim.dogAnims[self.animSet].attack["attack_player_miss"], 1.0, 0.2, 1.0 );
	}

	//self animscripts\shared::DoNoteTracks( "end" );
	self waittillmatch( "miss", "end" );
	debug_anim_print("dog_combat::attackMiss() - attackMiss notify done." );
	self notify("stop tracking");
	debug_anim_print("dog_combat::attackMiss() - Stopped tracking"  );
}


attackMissTrackTargetThread()
{
	self endon( "killanimscript" );

	wait 0.6;
	self OrientMode( "face enemy" );
}


handleMeleeBiteAttackNoteTracks( note )
{
	//assert( IsDefined( self.enemy ) );

	if ( !IsDefined( self.enemy ) )
		return;

	assert( IsPlayer( self.enemy ) );
	assert( IsAlive( self.enemy ) );

	player = self.enemy;
	
	switch ( note )
	{
	case "dog_melee":
		{
			if ( !isdefined(level.dogMeleeBiteAttackTime) )
			{
				level.dogMeleeBiteAttackTime = GetTime() - level.dogMeleeBiteAttackTimeStart;
				level.dogMeleeBiteAttackTime += 50;
			}

			hitEnt = self melee( anglesToForward( self.angles ) );

			if ( isdefined( hitEnt ) )
			{
				if ( isplayer(hitEnt) )
					hitEnt shellshock("dog_bite", 0.35);
			}
			else
			{
				//attackMiss();
				return true;
			}
		}
		break;

	case "stop_tracking":
		{
			// best guess
			melee_time = 200;

			// how much longer until the bite
			// bit of a hack solution 
			if ( !isdefined(level.dogMeleeBiteAttackTime) )
			{
				level.dogMeleeBiteAttackTimeStart = GetTime();
			}
			else
			{
				melee_time = level.dogMeleeBiteAttackTime;
			}

			self thread orientToPlayerDeadReckoning(player, melee_time);
		}
		break;
	}
}

addSafetyHealth(player)
{
	healthFrac = player getnormalhealth();
	if ( healthFrac == 0 )
		return false;
		
	if ( healthFrac < 0.25 )
	{
		player setnormalhealth( healthFrac + 0.25 );
		return true;
	}
	return false;
}

removeSafetyHealth(player)
{
	healthFrac = player getnormalhealth();
	if ( healthFrac > 0.25 )
		player setnormalhealth( healthFrac - 0.25 );
	else
		player setnormalhealth( 0.01 );
}

handleMeleeFinishAttackNoteTracks( note, player )
{
	switch( note )
	{
	case "dog_melee":

		if ( !isdefined(level.dogMeleeFinishAttackTime) )
		{
			level.dogMeleeFinishAttackTime = GetTime() - level.dogMeleeFinishAttackTimeStart;
			level.dogMeleeFinishAttackTime += 50;
		}

		hitEnt = self melee( anglesToForward( self.angles ) );
		if ( isdefined( hitEnt ) && isalive( player ) )
		{
			if ( hitEnt == player )
			{
				break;
			}
		}
		else
		{
			//attackMiss();
			return true;
		}
		break;

	case "dog_early":
		self notify( "dog_early_notetrack" );

		debug_anim_print("dog_combat::handleMeleeFinishAttackNoteTracks() - Setting  combat_attack_player_early" );
		//self setanimstate( "combat_attack_player_early" );
		self SetAnimRestart( %attack_player, 1.0, 0.2, 1.0 );
		self SetAnimRestart( %attack_player_late, 1.0, 0.2, 1.0 );
		break;

	case "dog_lunge":
		thread set_melee_timer(player);
		debug_anim_print("dog_combat::handleMeleeFinishAttackNoteTracks() - Setting  combat_attack_player_lunge" );
		//self setanimstate( "combat_attack_player_lunge" );
		self SetAnimRestart( %attack_player, 1.0, 0.2, 1.0 );
		break;

	case "dogbite_damage":

		self thread killplayer(player);
		break;

	case "stop_tracking":
		{
			// best guess
			melee_time = 200;

			// how much longer until the bite
			// bit of a hack solution 
			if ( !isdefined(level.dogMeleeFinishAttackTime) )
			{
				level.dogMeleeFinishAttackTimeStart = GetTime();
			}
			else
			{
				melee_time = level.dogMeleeFinishAttackTime;
			}

			self thread orientToPlayerDeadReckoning(player, melee_time );
		}
		break;
	}
}

orientToPlayerDeadReckoning(player, time_till_bite )
{
	enemy_attack_current_origin = player.origin;
	enemy_attack_current_time = GetTime();

	enemy_motion_time_delta = enemy_attack_current_time - self.enemy_attack_start_time;
	enemy_motion_direction = enemy_attack_current_origin - self.enemy_attack_start_origin;

	if ( enemy_motion_time_delta == 0 )
	{
		enemy_predicted_position = player.origin;
	}
	else
	{	
		enemy_velocity =  enemy_motion_direction / enemy_motion_time_delta;
		enemy_predicted_position = player.origin + (enemy_velocity * time_till_bite);
	}

	self set_orient_mode("face point", enemy_predicted_position );
}

//handle_dogbite_notetrack( note )
//{
//	switch( note )
//	{
//		case "dogbite_damage":
//			 /#
//			if ( isgodmode( level.player ) )
//				break;
//			#/ 
//
//			self thread killplayer();
//			break;
//	}
//}

set_melee_timer(player)
{
	wait( 0.15 );
	self.melee_able_timer = gettime();
	self thread dog_hint(player);

	/#
	if ( getdebugdvar( "dog_hint" ) == "on" )
	{
		introblack = newclientHudElem(player);
		introblack.x = 50;
		introblack.y = 50;
		introblack.horzAlign = "fullscreen";
		introblack.vertAlign = "fullscreen";
		introblack.foreground = true;
		introblack setShader("black", 100, 100 );
		wait ( 0.25 );
		introblack destroy();
	}
	#/
}


meleeBiteAttackPlayer(player)
{
	attackRangeBuffer = 30;

	for ( ;; )	
	{
		if ( !isalive( self.enemy ) )
			break;

		meleeRange = self.meleeAttackDist + attackRangeBuffer;
			
		if ( ( isdefined( player.syncedMeleeTarget ) && player.syncedMeleeTarget != self ) )
		{
			if ( checkEndCombat( meleeRange ) )
			{
				break;
			}
			else
			{
				combatIdle();
				continue;
			}
		}

		if ( self shouldWaitInCombatIdle() )
		{
			combatIdle();
			continue;
		}
			
		self set_orient_mode("face enemy");
		self animMode( "gravity" );

		self.safeToChangeScript = false;

		prepareAttackPlayer(player);

		// Austin 6-10-09: causes dogs on slopes to never regain their pitching ability
		//self clearpitchorient();
		
/#		
		if ( getdvarint( "debug_dog_sound" ) )
			iprintln( "dog " + (self getentnum()) + " attack player " + getTime() );

#/		
		player setNextDogAttackAllowTime( 200 );
		
		if ( dog_cant_kill_in_one_hit(player) )
		{
			level.lastDogMeleePlayerTime = getTime();
			level.dogMeleePlayerCounter++;
		
			if ( use_low_attack() )
			{
				// this is a hack using an existing anim to try and do a short range
				// ground based attack
				self animMode("angle deltas");
				
				debug_anim_print("dog_combat::meleeBiteAttackPlayer() - Setting run_attack_low" );
				self ClearAnim( %root, 0.1 );
				// Austin: TODO: ensure this is the correct blend function here
				//self SetAnim( %german_shepherd_run_attack_low, 1.0, 0.2, 1.0 );
				self SetAnimRestart( anim.dogAnims[self.animSet].move["run_attack_low"], 1.0, 0.2, 1.0 );

				
				doMeleeAfterWait( 0.1 );
				self animscripts\shared::DoNoteTracksForTime( 1.4, "done" );
				debug_anim_print("dog_combat::meleeBiteAttackPlayer() - Done with run_attack_low" );
				
				self animMode( "gravity" );
			}
			else
			{
				// 1.6 is about as big as you want to go or the dog anim will "stall"
				attack_time = 1.2 + randomfloat( 0.4 );
				debug_anim_print("dog_combat::meleeBiteAttackPlayer() - Setting  combat_run_attack" );

				self ClearAnim( %root, 0.1 );
				// Austin: TODO: ensure this is the correct blend function here
				self SetFlaggedAnimRestart( "meleeanim", anim.dogAnims[self.animSet].attack["run_attack"], 1.0, 0.2, 1.0 );
				self animscripts\shared::DoNoteTracksForTime( attack_time, "meleeanim", ::handleMeleeBiteAttackNoteTracks );
				debug_anim_print("dog_combat::meleeBiteAttackPlayer() - combat_run_attack notify done." );
			}
		}
		else
		{
			self thread dog_melee_death(player);
			player.attacked_by_dog = true;
			self thread clear_player_attacked_by_dog_on_death(player);

			debug_anim_print("dog_combat::meleeBiteAttackPlayer() - Setting  combat_attack_player" );

			self ClearAnim( %root, 0.1 );

			// Austin: TODO: ensure this is the correct blend function here
			self SetFlaggedAnimRestart( "meleeanim", anim.dogAnims[self.animSet].attack["run_attack"], 1.0, 0.2, 1.0 );
			self SetFlaggedAnimRestart( "meleeanim", anim.dogAnims[self.animSet].attack["attack_player_late"], 1.0, 0.2, 1.0 );
			self SetAnimRestart( %attack_player, 1.0, 0.0, 1.0 );
			self SetAnimRestart( %attack_player_late, 0.01, 0.0, 1.0 );
			
			
			// Austin: TODO: this call differs from MP
			self animscripts\shared::DoNoteTracks( "meleeanim", ::Handlemeleefinishattacknotetracks, undefined, player );
			debug_anim_print("dog_combat::meleeBiteAttackPlayer() - combat_attack_player notify done." );
			self notify( "dog_no_longer_melee_able" );
			self setcandamage( true );
			self unlink();
		}
		
		self.safeToChangeScript = true;

		if ( checkEndCombat( meleeRange ) )
			break;
	}
	
	self.safeToChangeScript = true;
	self animMode("none");
}

doMeleeAfterWait( time )
{
	self endon("death");

	wait(time);

	// not useing angles on the melee hit so it will always hit
	hitEnt = self melee( );
	if ( isdefined( hitEnt ) )
	{
		if ( isplayer(hitEnt) )
			hitEnt shellshock("dog_bite", 0.35);
	}
}

clear_player_attacked_by_dog_on_death(player)
{
	self waittill( "death" );
	player.attacked_by_dog = undefined;
}
			

dog_cant_kill_in_one_hit(player)
{
	// right now we want the dogs not to do the singleplayer "instant-kill"
	return true;

	if ( isdefined( player.dogs_dont_instant_kill ) )
	{
		assertex( player.dogs_dont_instant_kill, "Dont set player.dogs_dont_instant_kill to false, set to undefined" );
		return true;
	}

	if ( getTime() - level.lastDogMeleePlayerTime > 8000 )
		level.dogMeleePlayerCounter = 0;

	return level.dogMeleePlayerCounter < level.dog_hits_before_kill && 
		player.health > 25;	// little more than the damage one melee dog bite hit will do
}


// prevent multiple dogs attacking at the same time and overlapping
shouldWaitInCombatIdle()
{
	assert( isdefined( self.enemy ) && isalive( self.enemy ) );
	
	return isdefined( self.enemy.dogAttackAllowTime ) && ( gettime() < self.enemy.dogAttackAllowTime );
}

// call on target
setNextDogAttackAllowTime( time )
{
	self.dogAttackAllowTime = gettime() + time;
}


meleeStruggleVsAI()
{
	if ( !isalive( self.enemy ) )
		return;
	
	if ( isdefined( self.enemy.syncedMeleeTarget ) || self shouldWaitInCombatIdle() )
	{
		combatIdle();
		return;
	}

	self.enemy setNextDogAttackAllowTime( 500 );

	self.safeToChangeScript = false;
	self animMode( "zonly_physics" );
	self.pushable = false;

	self clearpitchorient();

	self.meleeKillTarget = !isdefined( self.enemy.magic_bullet_shield ) && 
						   ( isdefined( self.enemy.doingLongDeath ) || randomint( 100 ) > 50 );

	meleeSeqAnims = [];
	meleeSeqAnim[0] = %root;
	meleeSeqAnim[1] = %german_shepherd_attack_AI_01_start_a;
	meleeSeqAnim[2] = %german_shepherd_attack_AI_02_idle_a;
	if ( self.meleeKillTarget )
	{
		meleeSeqAnim[3] = %german_shepherd_attack_AI_03_pushed_a;
		meleeSeqAnim[4] = %german_shepherd_attack_AI_04_middle_a;
		meleeSeqAnim[5] = %german_shepherd_attack_AI_05_kill_a;
		numMeleeStage = 5;
	}
	else
	{
		meleeSeqAnim[3] = %german_shepherd_attack_AI_03_shot_a;
		numMeleeStage = 3;
	}

	angles = vectorToAngles( self.origin - self.enemy.origin );

	self.originalTarget = self.enemy;

	self setcandamage( false );
	self clearanim( meleeSeqAnim[0], 0.1 );
	self animrelative( "meleeanim", self.enemy.origin, angles, meleeSeqAnim[1] );
	self animscripts\shared::DoNoteTracks("meleeanim", ::handleStartAIPart);
	
	self setcandamage( true );
	self animMode( "zonly_physics" );
	
	for ( meleeSeq = 1; meleeSeq < numMeleeStage; meleeSeq++ )
	{
		self clearanim( meleeSeqAnim[meleeSeq], 0 );
		
		if ( !inSyncMeleeWithTarget() )
			break;
		
		// get ready to die
		if ( !self.meleeKillTarget && meleeSeq + 1 == numMeleeStage )
			self.health = 1;

		self setflaggedanimrestart("meleeanim", meleeSeqAnim[meleeSeq + 1], 1, 0, 1);
		self animscripts\shared::DoNoteTracks( "meleeanim" );
	}
	
	self unlink();
	self.pushable = true;
	self.safeToChangeScript = true;
}

combatIdle()
{
	self OrientMode("face enemy");
	self clearanim(%root, 0.1);
	self animMode( "zonly_physics" );
	
	keys = GetArrayKeys( anim.dogAnims[self.animSet].combatIdle );
	idleAnim = anim.dogAnims[self.animSet].combatIdle[ maps\_utility::random( keys ) ];
	
	//self thread combatIdlePreventOverlappingPlayer();

	//debug_anim_print("dog_combat::combatIdle() - Setting " + string(idleAnim) );
	self setflaggedanimrestart( "combat_idle", idleAnim, 1, 0.2, 1 );
	self animscripts\shared::DoNoteTracks( "combat_idle" );
	//debug_anim_print("dog_combat::combatIdle() - " + idleAnim + " notify done." );
	
	self notify( "combatIdleEnd" );
}


// when player is in melee sequence, other dogs need to move away
combatIdlePreventOverlappingPlayer()
{
	self endon( "killanimscript" );
	self endon( "combatIdleEnd" );
	
	while( 1 )
	{
		wait 0.1;
		
		// SCRIPTER_MOD: JesseS (3/25/2008): This might not work, going to set self.enemy here 
		// instead of level.player
		
		if ( !isdefined( self.enemy))
			continue;
			
		if ( !isdefined( self.enemy.syncedMeleeTarget ) || self.enemy.syncedMeleeTarget == self )
			continue;
		
		offsetVec = self.enemy.origin - self.origin;
		
		if ( offsetVec[2] * offsetVec[2] > 6400 )
			continue;			
		
		offsetVec = ( offsetVec[0], offsetVec[1], 0 );
	
		offset = length( offsetVec );
		
		if ( offset < 1 )
			offsetVec = anglestoforward( self.angles );
		
		if ( offset < 30 )
		{
			offsetVec = vectorscale( offsetVec, 3 / offset );
			self teleport( self.origin - offsetVec );
		}			
	}
}


inSyncMeleeWithTarget()
{
	return( isdefined( self.enemy ) && isdefined( self.enemy.syncedMeleeTarget ) && self.enemy.syncedMeleeTarget == self );
}

handleStartAIPart( note )
{
	if ( note != "ai_attack_start" )
		return false;

	if ( !isdefined( self.enemy ) )
		return true;
		
	if ( self.enemy != self.originalTarget )
		return true;

	// enemy already has a synced melee target
	if ( isdefined( self.enemy.syncedMeleeTarget ) )
		return true;
		
	//self.enemy thread draw_tag( "tag_sync" );

	self.enemy.syncedMeleeTarget = self;
	self.enemy animcustom(::meleeStruggleVsDog);
}

checkEndCombat( meleeRange )
{
	if ( !isdefined( self.enemy ) )
		return false;
		
	distToTargetSq = distanceSquared( self.origin, self.enemy.origin );
	
	return ( distToTargetSq > meleeRange * meleeRange );
}

use_low_attack(player)
{
	height_diff = self.enemy_attack_start_origin[2] - self.origin[2];

	low_enough = 30.0;	

	if ( height_diff < low_enough && self.enemy_attack_start_stance == "prone" )
	{
		return true;
	}

	return false;
}

prepareAttackPlayer(player)
{
	if ( !isdefined( player.player_view ) ) 
		player.player_view = PlayerView_Spawn(player);

	level.dog_death_quote = &"SCRIPT_PLATFORM_DOG_DEATH_DO_NOTHING";
	distanceToTarget = distance( self.origin, self.enemy.origin );
	targetHeight = Abs(self.enemy.origin[2] - self.origin[2]);

	self.enemy_attack_start_distance = distanceToTarget;
	self.enemy_attack_start_origin = player.origin;
	self.enemy_attack_start_time = GetTime();
	self.enemy_attack_start_stance = player getStance();

	distance_ok = ( (distanceToTarget > self.meleeAttackDist) && (targetHeight < (self.meleeAttackDist * 0.5)) );
	
	if ( distance_ok && !use_low_attack() )
	{
		offset = self.enemy.origin - self.origin;

		length = ( distanceToTarget - self.meleeAttackDist ) / distanceToTarget;
		offset = ( offset[0] * length, offset[1] * length, offset[2] * length );
		
		//self thread attackTeleportThread( offset );
	}

	/#
		if ( GetDvarInt( "anim_debug_dogs" ) == 1 || GetDvarInt( "anim_debug_dogs" ) == self GetEntNum() )
		{
			teleported = "";
			if ( distance_ok && !use_low_attack() )
			{
				teleported = "Teleported";
			}

			println("Attack Target - Dist: " + distanceToTarget + " Stance: " + self.enemy_attack_start_stance + " " + teleported);
		}	
	#/
}

// make up for error in intial attack jump position
attackTeleportThread( offset )
{
	self endon ("death");
	self endon ("killanimscript");
	reps = 5;
	increment = ( offset[0] / reps, offset[1] / reps, offset[2] / reps );
	for ( i = 0; i < reps; i++ )
	{
		self teleport (self.origin + increment);
		wait (0.05);
	}
}

player_attacked()
{
	return isalive( self ) && ( self MeleeButtonPressed() );
}



dog_hint(player)
{
	if(!isdefined(level.dogHintElem))
	{
		level.dogHitElem = [];
	}
	
	press_time = anim.dog_presstime / 1000;
	level endon ( "clearing_dog_hint" );
	
	num = player GetEntityNumber();
	
	if ( isDefined( level.dogHintElem ) )
	{
		if(isdefined(level.dogHintElem[num]))
		{
			level.dogHintElem[num] maps\_hud_util::destroyElem();
			level.dogHintElem[num] = undefined;
		}
	}

	level.dogHintElem[num] = maps\_hud_util::createFontString( "default", 2, player );
	level.dogHintElem[num].color = (1,1,1);
	level.dogHintElem[num] setText( &"SCRIPT_PLATFORM_DOG_HINT" );
	level.dogHintElem[num].x = 0;
	level.dogHintElem[num].y = 20;
	level.dogHintElem[num].alignX = "center";
	level.dogHintElem[num].alignY = "middle";
	level.dogHintElem[num].horzAlign = "center";
	level.dogHintElem[num].vertAlign = "middle";
	level.dogHintElem[num].foreground = true;
	level.dogHintElem[num].alpha = 1;
	level.dogHintElem[num] endon ( "death" );

	wait ( press_time );
	thread dog_hint_fade(player);
}

dog_hint_fade(player)
{
	level notify ( "clearing_dog_hint" );
	
	num = player GetEntityNumber();
	
	if ( isDefined( level.dogHintElem[num] ) )
	{
		level.dogHintElem[num] maps\_hud_util::destroyElem();
		level.dogHintElem[num] = undefined;
	}
}

dog_melee_death(player)
{
	self endon( "killanimscript" );
	self endon( "dog_no_longer_melee_able" );
	pressed = false;

	// change this number for difficulty level:
	press_time = anim.dog_presstime;
	
	
	self waittill( "dog_early_notetrack" );

	while ( player player_attacked() )
	{
		// wait until the player lets go of the button, if he's holding it
		wait( 0.05 );
	}
	
	for ( ;; )
	{
		if ( !pressed )
		{
			
			if ( player player_attacked() )
			{
				pressed = true;
				if ( isdefined( self.melee_able_timer ) && isalive( player ) )
				{
					if ( gettime() - self.melee_able_timer <= press_time )
					{
						player.player_view.custom_dog_save = "neck_snap";
						self notify( "melee_stop" );
						debug_anim_print("dog_combat::dog_melee_death() - Setting  combat_player_neck_snap" );
						self setflaggedanimknobrestart( "dog_death_anim", %german_shepherd_player_neck_snap, 1, 0.2, 1 );
					
						self waittillmatch( "done", "dog_death" );
						debug_anim_print("dog_combat::dog_melee_death() - combat_player_neck_snap notify done." );
						self playsound( "dog_neckbreak", self gettagorigin( "tag_eye" ) );
						self setcandamage( true );
						self.a.nodeath = true;
						dif = player.origin - self.origin;
						dif = ( dif[ 0 ], dif [ 1 ], 0 );
						self dodamage( self.health + 503, self geteye() - dif, player );
						self notify( "killanimscript" );
					}
					else
					{
						debug_anim_print("dog_combat::dog_melee_death() - Setting  combat_player_neck_snap"  );
						//self setanimstate( "combat_attack_player" );
						self ClearAnim( %root, 0.2 );

						level.dog_death_quote = &"SCRIPT_PLATFORM_DOG_DEATH_TOO_LATE";
					}
					return;
				}
				
				level.dog_death_quote = &"SCRIPT_PLATFORM_DOG_DEATH_TOO_SOON";
				debug_anim_print("dog_combat::dog_melee_death() - Setting  combat_player_neck_miss" );
				//self setanimstate( "combat_player_neck_miss" );

				// once player clicks, if it is at the wrong time, he does not get another chance.
				return;
			}
		}
		else
		{
			if ( !player player_attacked() )
			{
				pressed = false;
			}
		}

		wait( 0.05 );
	}
}

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
#using_animtree ("generic_human");

meleeStruggleVsDog()
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "end_melee_struggle" );
	self endon( "end_melee_all" );

	if ( !isdefined( self.syncedMeleeTarget ) )
		return;

	//self.syncedMeleeTarget = self;
	
	self OrientMode("face point", self.syncedMeleeTarget.origin, 1);
	self animMode( "gravity" );
	
	self.a.pose = "stand";
	self.a.special = "none";
	
	if ( usingSidearm() )
		self animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );
	
	meleeSeqAnim = [];
	meleeSeqAnim[0] = %root;
	meleeSeqAnim[1] = %AI_attacked_german_shepherd_01_start_a;
	meleeSeqAnim[2] = %AI_attacked_german_shepherd_02_idle_a;
	if ( self.syncedMeleeTarget.meleeKillTarget )
	{
		meleeSeqAnim[3] = %AI_attacked_german_shepherd_03_push_a;
		meleeSeqAnim[4] = %AI_attacked_german_shepherd_04_middle_a;
		meleeSeqAnim[5] = %AI_attacked_german_shepherd_05_death_a;
		numMeleeStage = 5;
	}
	else
	{
		meleeSeqAnim[3] = %AI_attacked_german_shepherd_03_shoot_a;
		numMeleeStage = 3;
	}
	
	self.meleeSeq = 0;

	self thread meleeStruggleVsDog_interruptedCheck();
	
	self clearanim( meleeSeqAnim[0], 0.1 );
	
	self setflaggedanimrestart( "aianim", meleeSeqAnim[ 1 ], 1, 0.1, 1 );
	
	// this needs to happen here and not when the dog starts, because "tag_sync" won't be correct at that point
	wait 0.15; // also wait a bit before tag_sync in AI animation to settle to right spot
	self.syncedMeleeTarget linkto( self, "tag_sync", (0,0,0), (0,0,0) );

	self waittillmatch( "aianim", "end" );

	for ( self.meleeSeq = 1; self.meleeSeq < numMeleeStage;  )
	{
		self clearanim( meleeSeqAnim[self.meleeSeq], 0 );
		
		self.meleeSeq++;
		
		// if starting the pistol pull out to shoot, don't let any other dog attack me for a bit
		if ( numMeleeStage == 3 && self.meleeSeq == 3 )
			self setNextDogAttackAllowTime( getAnimLength( meleeSeqAnim[ self.meleeSeq ] ) * 1000 - 1000 );
		
		self setflaggedanimrestart( "aianim", meleeSeqAnim[self.meleeSeq], 1, 0, 1 );
		self animscripts\shared::DoNoteTracks( "aianim" );
		
		// hack to let %AI_attacked_german_shepherd_03_push_a play to end when interrupted
		if ( !isdefined( self.syncedMeleeTarget ) || !isAlive( self.syncedMeleeTarget ) )	
		{
			if ( self.meleeSeq == 3 && numMeleeStage == 5 )
			{
				meleeSeqAnim[4] = %AI_attacked_german_shepherd_04_getup_a;
				numMeleeStage = 4;
			}
		}
		
		if ( self.meleeSeq == 5 )
		{	
			if ( !isdefined( self.magic_bullet_shield ) )
			{
				self.a.nodeath = true;
				self animscripts\shared::DropAllAIWeapons();
				self dodamage( self.health * 10, (0, 0, 0) );
			}
		}
	}
	
	meleeStruggleVsDog_End();
}


// check for premature termination from dog being shot by another AI or player
meleeStruggleVsDog_interruptedCheck()
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "end_melee_all" );

	meleeSeqAnim = [];
	meleeSeqAnim[1] = %AI_attacked_german_shepherd_02_getup_a;
	meleeSeqAnim[2] = %AI_attacked_german_shepherd_02_getup_a;

	if ( self.syncedMeleeTarget.meleeKillTarget )
	{
		// meleeSeqAnim[3] = %AI_attacked_german_shepherd_04_getup_a;	// handle this in meleeStruggleVsDog()
		meleeSeqAnim[4] = %AI_attacked_german_shepherd_04_getup_a;
	}

	while ( 1 )
	{
		if ( !isdefined( self.syncedMeleeTarget ) || !isAlive( self.syncedMeleeTarget ) )
			break;
			
		wait 0.1;
	}

	if ( self.meleeSeq > 0 ) 
	{
		if ( !isdefined( meleeSeqAnim[self.meleeSeq] ) )
			return;	// don't call meleeStruggleVsDog_End()

		self clearanim( %melee_dog, 0.1 );
		self setflaggedanimrestart( "getupanim", meleeSeqAnim[self.meleeSeq], 1, 0.1, 1 );
		self animscripts\shared::DoNoteTracks( "getupanim" );
	}
	
	meleeStruggleVsDog_End();
}


// this should kill both meleeStruggleVsDog() and meleeStruggleVsDog_endCheck() threads
meleeStruggleVsDog_End()
{
	self orientmode("face default");
	self.syncedMeleeTarget = undefined;
	self.meleeSeq = undefined;
	self.allowPain = true;
	self setNextDogAttackAllowTime( 1000 );
	
	self notify( "end_melee_all" );
}


//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
#using_animtree( "player" );

PlayerView_Spawn(player)
{
	playerView = spawn( "script_model", player.origin );
	playerView.angles = player.angles;
	playerView setModel( level.player_interactive_hands );
	playerView useAnimTree( #animtree );
	playerView hide();
	
	return playerView;
}


handlePlayerKnockDownNotetracks( note )
{
	switch( note )
	{
		case "allow_player_save":
		{
			if ( getdvar( "friendlySaveFromDog" ) == "1" && isdefined( self.dog ) )
			{
				wait 1;
				self.dog setcandamage( true );
			}
		}
		break;
		
		case "blood_pool":
{
			tagPos = self gettagorigin( "tag_torso" );	// rough tag to play fx on
			tagAngles = self gettagangles( "tag_torso" );
			forward = anglestoforward( tagAngles );
			up = anglestoup( tagAngles );
			right = anglestoright( tagAngles );
		
			tagPos = tagPos + vectorScale( forward, -8.5 ) + vectorScale( up, 5 ) + vectorScale( right, 0 );
			playfx( level._effect[ "deathfx_bloodpool" ], tagPos, forward, up );	// Add to level initialization animscripts\dog_init::initDogAnimations();
		}
		break;
	}
}


PlayerView_KnockDownAnim( dog, player )
{
	self endon( "pvd_melee_interrupted" );
	
	self.dog = dog;
	self thread PlayerView_CheckInterrupted(player);
	
	self setflaggedanimrestart( "viewanim", %player_view_dog_knockdown );
	self setflaggedanimrestart( "viewanim", %player_view_dog_knockdown_late );

	self setanimlimited( get_player_knockdown_knob(), 1, 0, 1 );
	self setanimlimited( get_player_knockdown_late_knob(), 0.01, 0, 1 );
	
	self animscripts\shared::DoNoteTracks( "viewanim", ::handlePlayerKnockDownNotetracks );
//	self animscripts\shared::DoNoteTracks( "viewanim_late", ::handlePlayerKnockDownNotetracks );
	
	self dontInterpolate();
	
	self.dog = undefined;
	PlayerView_EndSequence(player);
	self notify( "pvd_melee_done" );
}


PlayerView_CheckInterrupted(player)
{
	self endon( "pvd_melee_done" );
	
	self.dog waittill_any( "death", "pain", "melee_stop" );

	if ( !isdefined( player.specialDeath ) && isAlive( player ) )
	{
		self notify( "pvd_melee_interrupted" );
		self.dog notify( "pvd_melee_interrupted" );
		PlayerView_EndSequence(player);
	}
}

//showafter( time )
//{
//	self endon( "death" );
//	wait time;
//	self show();
//}

PlayerView_StartSequence( dog, player )
{
	if ( isdefined( self.inSeq ) )
		return false;

	player notify( "dog_attacks_player" );
	self.inSeq = true;
	
	if ( isalive( player ) )
		setsaveddvar( "hud_drawhud", 0 );
	
	player allowStand( true );
	player setstance( "stand" );
	player.syncedMeleeTarget = dog;
	player.player_view PlayerView_Show(player);
	//player.player_view hide();
	//player.player_view thread showafter( 1.3 );

	
	direction = dog.origin - player.origin;
	self.angles = vectortoangles( direction );
	self.angles = ( 0, self.angles[1], 0 );	

	playerpos = player.origin;
	self.origin = playerphysicstrace( ( playerpos[ 0 ], playerpos[ 1 ], playerpos[ 2 ] + 50 ), ( playerpos[ 0 ], playerpos[ 1 ], playerpos[ 2 ] - 200 ) );
	
	self thread PlayerView_KnockDownAnim( dog, player );
	self dontInterpolate();
	
	player playerLinkToAbsolute( self, "tag_player" );
	dog linkto( self, "tag_sync", (0, 0, 0), (0, 0, 0) );
	
	syncTagAngles = self gettagangles( "tag_sync" );
	dog orientmode( "face angle", syncTagAngles[ 1 ] );
	dog orientmode( "face default" );
	
	//self thread draw_tag( "tag_player" );
	//self thread draw_tag( "tag_sync" );
	//dog thread draw_tag( "tag_origin" );

	player allowLean( false );
	player allowCrouch( false );
	player allowProne( false );
	player freezeControls( true );
	
	player setcandamage( false );
	
	return true;
}

SavedNotify(player)
{
	wait 0.5;
	player playsound( "saved_from_dog" );
}

player_gets_weapons_back(player)
{
	player endon( "death" );
	player showViewModel();
	player enableweapons();
}

PlayerView_EndSequence(player)
{
	setsaveddvar( "hud_drawhud", 1 );
	
	if ( isalive( player ) )
	{
		self clearanim( %player_view_dog_knockdown, 0.1 );
		if ( isdefined( self.custom_dog_save ) )
		{
			custom_saves = [];
			custom_saves[ "neck_snap" ] = %player_view_dog_knockdown_neck_snap;
			self setflaggedanimrestart( "viewanim", custom_saves[ self.custom_dog_save ], 1, 0.2, 1 );
		}
		else
		{
			thread SavedNotify(player);
			self setflaggedanimrestart( "viewanim", %player_view_dog_knockdown_saved );
		}
	
		delaythread( 3.0, ::player_gets_weapons_back, player );
		self animscripts\shared::DoNoteTracks( "viewanim" );
		player setcandamage( true );
		player notify( "player_saved_from_dog" );

		player unlink();
		player setOrigin( self.origin );
	
		self.inSeq = undefined;
		player.player_view delete();	// delete self
		
		angles = player getplayerangles();
		player setplayerangles( (0, angles[1], 0) );
	}
	else
	{
		setsaveddvar( "compass", 0 );
	}

	player.syncedMeleeTarget = undefined;
	
	player allowLean( true );
	player allowCrouch( true );
	player allowProne( true );
	player freezeControls( false );
	player.attacked_by_dog = undefined;
}



PlayerView_Show(player)
{
	self show();
	player hideViewModel();
	player disableweapons();
}


//draw_tag( tagname )
//{
//	self endon( "death" );
//	while( 1 )
//	{
//		self thread draw_tag_for_time( tagname, 6 );
//		wait 0.05;
//	}
//}
//
//draw_tag_for_time( tagname, drawTime )
//{
//	self endon( "death" );
//	
//	range = 25;
//
//	angles = self gettagangles( tagname );	
//	origin = self gettagorigin( tagname );
//	
//	forward = anglestoforward(angles);
//	forward = vectorscale(forward, range + 50);
//	right = anglestoright(angles);
//	right = vectorscale(right, range);
//	up = anglestoup(angles);
//	up = vectorscale(up, range);
//
//	time = 0;
//	while( time < drawTime )
//	{
//		line(origin, origin + forward, (1,0,0), 1);
//		line(origin, origin + up, (0,1,0), 1);
//		line(origin, origin + right, (0,0,1), 1);
//		wait 0.05;
//		time += 0.05;
//	}
//}


get_player_dog_neck_miss_anim()
{
	return %player_view_dog_knockdown_neck_miss;
}

get_player_view_dog_knock_down_anim()
{
	return %player_view_dog_knockdown;
}

get_player_view_dog_knock_down_late_anim()
{
	return %player_view_dog_knockdown_late;
}

get_player_knockdown_knob()
{
	return %knockdown;
}

get_player_knockdown_late_knob()
{
	return %knockdown_late;
}
