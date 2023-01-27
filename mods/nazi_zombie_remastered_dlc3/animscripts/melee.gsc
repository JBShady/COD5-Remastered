#include animscripts\Utility;
#include animscripts\SetPoseMovement;
#include animscripts\Combat_Utility;
#include common_scripts\Utility;
#include maps\_utility;
#using_animtree ("generic_human");

// ===========================================================
//     AI vs Player melee
// ===========================================================


zombMeleeMonitor()
{
	level.numZombsMeleeThisFrame = 0;
	
	while(1)
	{
		wait_network_frame();
		level.numZombsMeleeThisFrame = 0;
	}
}


MeleeCombat()
{
  //self trackScriptState( "melee", "Exposed Combat said so" );
 	self endon("killanimscript");
	self notify("melee");
//	self endon(anim.scriptChange);

	assert( CanMeleeAnyRange() );

	// AI vs AI melee disabled for now.
	//doingAiMelee = (isAI( self.enemy ) && self.enemy.type == "human");
	doingAiMelee = false;
	
	if ( doingAiMelee )
	{
		assert( animscripts\utility::okToMelee( self.enemy ) );
		animscripts\utility::IAmMeleeing( self.enemy );
		
		AiVsAiMeleeCombat();
		
		animscripts\utility::ImNotMeleeing( self.enemy );
		
		scriptChange();
		return;
	}
	
	realMelee = true;

	if ( animscripts\utility::okToMelee(self.enemy) )
		animscripts\utility::IAmMeleeing(self.enemy);
	else
		realMelee = false;

	self thread EyesAtEnemy();
	self OrientMode("face enemy");
	
	MeleeDebugPrint("Melee begin");
	
	self animMode( "zonly_physics" );
	
	resetGiveUpTime();
	
    for ( ;; )
    {
		// first, charge forward if we need to; get into place to play the melee animation
		if ( !PrepareToMelee() )
		{
			// if we couldn't get in place to melee, don't melee.
			// remember that we couldn't get in place so that we don't try again for a while.
			self.lastMeleeGiveUpTime = gettime();
			break;
		}
		
		if ( !self is_zombie() )
		{
			assert( self.a.pose == "stand");
		}
		
		MeleeDebugPrint("Melee main loop" + randomint(100));
		
		// we should now be close enough to melee.
		
		// If no one else is meleeing this person, tell the system that I am, so no one else will charge him.
		if ( !realMelee && animscripts\utility::okToMelee(self.enemy) )
		{
			realMelee = true;
			animscripts\utility::IAmMeleeing(self.enemy);
		}

		self thread EyesAtEnemy();
		
		self animscripts\battleChatter_ai::evaluateMeleeEvent();

		// TODO: we should use enemypose to play crouching melee anims when necessary.
		/*player = anim.player;
		if (self.enemy == player)
		{
			enemypose = player getstance();
		}
		else
		{
			enemypose = self.enemy.a.pose;
		}*/
		
		if( self is_zombie() )
		{
			if( IsDefined( self.enemy ) )
			{
				angles = VectorToAngles( self.enemy.origin - self.origin );
				self OrientMode( "face angle", angles[1] );
			}
		}
		else
		{
			self OrientMode("face current");			
		}
		
		if (self is_zombie())
		{
			if(!isdefined(level.numZombsMeleeThisFrame))
			{
				level thread zombMeleeMonitor();
			}
			
			while(level.numZombsMeleeThisFrame > 2)
			{
				wait_network_frame();
			}
			
			self animscripts\face::SaySpecificDialogue( undefined, "attack_vocals", 1 );

			zombie_attack = pick_zombie_melee_anim( self );
			self setflaggedanimknoballrestart("meleeanim", zombie_attack, %body, 1, .2, 1);
			
			level.numZombsMeleeThisFrame ++;
		}
		else if ( self maps\_bayonet::has_bayonet() && RandomInt( 100 ) < 0 ) // turned it off for now because the animation isn't done.
		{
			self setflaggedanimknoballrestart("meleeanim", %ai_bayonet_stab_melee, %body, 1, .2, 1);
		}
		else
		{	
			self setflaggedanimknoballrestart("meleeanim", %melee_1, %body, 1, .2, 1);
		}
		
		while ( 1 )
		{
			self waittill("meleeanim", note);
			if ( note == "end" )
			{
				break;
			}
			else if ( note == "fire" )
			{
				if ( !IsDefined( self.enemy ) )
					break;
					
				oldhealth = self.enemy.health;
				self melee();
				if ( self.enemy.health < oldhealth )
				{
					resetGiveUpTime();
				}
				else
				{
					if( isDefined( level.melee_miss_func ) )
					{
						self [[ level.melee_miss_func ]]();
					}
				}
			}
			else if ( note == "stop" )
			{
				// check if it's worth continuing with another melee.
				if ( !CanContinueToMelee() ) // "if we can't melee without charging"
					break;
			}
		}
		
		self OrientMode("face default");
    }
	
	if (realMelee)
	{
		animscripts\utility::ImNotMeleeing(self.enemy);
	}
	
	self animMode("none");
	
	//self thread animscripts\combat::main();
	self thread animscripts\combat::main();
	self notify ("stop EyesAtEnemy");
	self notify ("stop_melee_debug_print");
	scriptChange();
}

resetGiveUpTime()
{
	if ( distanceSquared( self.origin, self.enemy.origin ) > anim.chargeRangeSq )
		self.giveUpOnMeleeTime = gettime() + randomintrange( 2700, 3300 );
	else
		self.giveUpOnMeleeTime = gettime() + randomintrange( 1700, 2300 );
}

MeleeDebugPrint(text)
{
	return;
	self.meleedebugprint = text;
	self thread meleeDebugPrintThreadWrapper();
}

meleeDebugPrintThreadWrapper()
{
	if ( !isdefined(self.meleedebugthread) )
	{
		self.meleedebugthread = true;
		self meleeDebugPrintThread();
		self.meleedebugthread = undefined;
	}
}

meleeDebugPrintThread()
{
	self endon("death");
	self endon("killanimscript");
	self endon("stop_melee_debug_print");
	
	while(1)
	{
		print3d(self.origin + (0,0,60), self.meleedebugprint, (1,1,1), 1, .1);
		wait .05;
	}
}

getEnemyPose()
{
	if ( isplayer( self.enemy ) )
		return self.enemy getStance();
	else
		return self.enemy.a.pose;
}

CanContinueToMelee()
{
	return CanMeleeInternal( "already started" );
}

CanMeleeAnyRange()
{
	return CanMeleeInternal( "any range" );
}

CanMeleeDesperate()
{
	return CanMeleeInternal( "long range" );
}

CanMelee()
{
	return CanMeleeInternal( "normal" );
}

CanMeleeInternal( state )
{
	// no meleeing virtual targets
	if ( !isSentient( self.enemy ) )
		return false;

	// or dead ones
	if (!isAlive(self.enemy))
		return false;
	
	if ( isdefined( self.disableMelee ) )
	{
		assert( self.disableMelee ); // must be true or undefined
		return false;
	}
	
	// Can't charge if we're not standing
	if (self.a.pose != "stand" && !is_zombie())
		return false;
	
	// CODER_MOD: Austin (8/3/08): allow zombies to always melee, regardless of enemy stance
	if ( !self is_zombie() )
	{
		enemypose = getEnemyPose();
		if ( enemypose != "stand" && enemypose != "crouch" )
		{
			// banzai can charge prone enemies because the enemies will automatically pop up into a crouch.
			if ( !( self is_banzai() && enemypose == "prone" ) )
			{
				return false;
			}
		}
	}
	
	enemyPoint = self.enemy GetOrigin();
	vecToEnemy = enemyPoint - self.origin;
	self.enemyDistanceSq = lengthSquared( vecToEnemy );
	
	if( self.enemyDistanceSq > 25 )
	{
		// if we're not at least partially facing the guy, wait until we are
		yaw = abs(getYawToEnemy());
		if ( (yaw > 60 && state != "already started") || yaw > 110 )
			return false;
	}

	// so we don't melee charge a guy who has gained ignoreme in the past frame
	nearest_enemy_sqrd_dist = self GetClosestEnemySqDist();
	epsilon = 0.1; // Necessary to avoid rounding errors.
	if ( nearest_enemy_sqrd_dist - epsilon > self.enemyDistanceSq )
	{
		//println( "Entity " + self getEntityNumber() + " can't melee entity " + self.enemy getEntityNumber() + " at distSq " + self.enemyDistanceSq + " because there is a closer enemy at distSq " + nearest_enemy_sqrd_dist + "." );
		return false;
	}

	// AI vs AI melee disabled for now.
	//doingAIMelee = (isAI( self.enemy ) && self.enemy.type == "human");
	doingAIMelee = false;
	
	if ( doingAIMelee )
	{
		// temp disabled.
		//if ( self.enemyDistanceSq > anim.aiVsAiMeleeRangeSq )
		//	return false;
		
		// check if someone else is already meleeing my enemy.
		if ( !animscripts\utility::okToMelee(self.enemy) )
			return false;
		
		if ( isDefined( self.magic_bullet_shield ) && self.magic_bullet_shield && isdefined( self.enemy.magic_bullet_shield ) && self.enemy.magic_bullet_shield )
			return false;
	
		if ( !isMeleePathClear( vecToEnemy, enemyPoint ) )
			return false;
	}
	else
	{
		// this check can be removed when AI vs AI melee is working.
		if ( isdefined( self.enemy.magic_bullet_shield ) && self.enemy.magic_bullet_shield )
		{
			// Banzai attacks are OK against those with magic_bullet_shield - as long as the
			// shielded ones always win the melee. 
			if ( !( self is_banzai() ) )
			{
				return false;
			}
		}

		if (self.enemyDistanceSq <= anim.meleeRangeSq)
		{
				if ( !isMeleePathClear( vecToEnemy, enemyPoint ) )
				{
					if ( !self is_banzai() && !self is_zombie() )
					//if ( !self is_banzai() )
					{
						return false;
					}
					//else
					//{
						//println( "Entity " + self getEntityNumber() + " melee path to entity " + self.enemy getEntityNumber() + " at distSq " + self.enemyDistanceSq + " not clear." );
						// If we've gotten to our banzai target and our path is blocked, reduce distance and start moving again.
						//self animscripts\banzai::set_banzai_melee_distance( 32 );
					//}
				}
				
			// Enemy is already close enough to melee.
			return true;
		}
		else if ( self is_banzai() )
		{
			//println( "Banzai attacker not within melee range [sqrt(" + anim.meleeRangeSq + ")]" );
			return false;
		}
		
		
		if ( state != "any range" )
		{
			chargeRangeSq = anim.chargeRangeSq;
			if ( state == "long range" )
				chargeRangeSq = anim.chargeLongRangeSq;
			if (self.enemyDistanceSq > chargeRangeSq)
			{
				// Enemy isn't even close enough to charge.
				return false;
			}
		}
		
		if ( state == "already started" ) // if we already started, we're checking to see if we can melee *without* charging.
			return false;
		
		// at this point, we can melee iff we can charge.
	
		// don't charge if we recently missed someone
		if ( ( !self is_banzai() || IsPlayer( self.enemy ) ) && isdefined( self.lastMeleeGiveUpTime ) && gettime() - self.lastMeleeGiveUpTime < 3000 )
			return false;
		
		// check if someone else is already meleeing my enemy.
		if ( !animscripts\utility::okToMelee(self.enemy) )
			return false;
			
		// okToMelee() doesn't check to see if someone is banzai attacking the enemy. Do that here.
		if ( self.enemy animscripts\banzai::in_banzai_attack() )
			return false;
		
		// I can't melee someone else if I'm currently engaged in a banzai attack.
		if ( self animscripts\banzai::in_banzai_attack() )
		{
			//println( "t: " + gettime() + " CanMeleeInternal() being called on ent " + self GetEntityNumber() + " who is already in banzai attack with ent " + self.favoriteenemy GetEntityNumber() + "." );
			return false;
		}
	
		if( !self is_zombie() && !isMeleePathClear( vecToEnemy, enemyPoint ) )
		{
			return false;
		}
	}
	
	return true;
}

isMeleePathClear( vecToEnemy, enemyPoint )
{
	dirToEnemy = vectorNormalize( (vecToEnemy[0], vecToEnemy[1], 0 ) );
	meleePoint = enemyPoint - ( dirToEnemy[0]*32, dirToEnemy[1]*32, 0 );
	
	if ( !self isInGoal( meleePoint ) )
		return false;

	return self maymovetopoint(meleePoint);
}

// this function makes the guy run towards his enemy, and start raising his gun if he's close enough to melee.
// it will return false if he gives up, or true if he's ready to start a melee animation.
PrepareToMelee()
{
	// Jesse: for now, if we're a zombie, just skip this and see how it works out...
	if (self is_zombie())
	{
		return true;	
	}
	
	if ( !CanMeleeAnyRange() )
		return false;
	
	if (self.enemyDistanceSq <= anim.meleeRangeSq)
	{
		// just play a melee-from-standing transition
		self SetFlaggedAnimKnobAll("readyanim", %stand_2_melee_1, %body, 1, .3, 1);
		self animscripts\shared::DoNoteTracks("readyanim");
		return true;
	}

	self PlayMeleeSound();
	
	prevEnemyPos = self.enemy.origin;
	
	sampleTime = 0.1;

	raiseGunAnimTravelDist = length(getmovedelta(%run_2_melee_charge, 0, 1));
	meleeAnimTravelDist = 32;
	shouldRaiseGunDist = anim.meleeRange * 0.75 + meleeAnimTravelDist + raiseGunAnimTravelDist;
	shouldRaiseGunDistSq = shouldRaiseGunDist * shouldRaiseGunDist;
	
	shouldMeleeDist = anim.meleeRange + meleeAnimTravelDist;
	shouldMeleeDistSq = shouldMeleeDist * shouldMeleeDist;
	
	raiseGunFullDuration = getanimlength(%run_2_melee_charge) * 1000;
	raiseGunFinishDuration = raiseGunFullDuration - 100;
	raiseGunPredictDuration = raiseGunFullDuration - 200;
	raiseGunStartTime = 0;

	predictedEnemyDistSqAfterRaiseGun = undefined;
	
	
	runAnim = %run_lowready_F;
	
	self SetFlaggedAnimKnobAll("chargeanim", runAnim, %body, 1, .3, 1);
	raisingGun = false;
	
	while ( 1 )
	{
		MeleeDebugPrint("PrepareToMelee loop" + randomint(100));
		
		time = gettime();
		
		willBeWithinRangeWhenGunIsRaised = (isdefined( predictedEnemyDistSqAfterRaiseGun ) && predictedEnemyDistSqAfterRaiseGun <= shouldRaiseGunDistSq);
		
		if ( !raisingGun )
		{
			if ( willBeWithinRangeWhenGunIsRaised )
			{
				self SetFlaggedAnimKnobAllRestart("chargeanim", %run_2_melee_charge, %body, 1, .2, 1);
				raiseGunStartTime = time;
				raisingGun = true;
			}
		}
		else
		{
			// if we *are* raising our gun, don't stop unless we're hopelessly out of range,
			// or if we hit the end of the raise gun animation and didn't melee yet
			withinRangeNow = self.enemyDistanceSq <= shouldRaiseGunDistSq;
			if ( time - raiseGunStartTime >= raiseGunFinishDuration || (!willBeWithinRangeWhenGunIsRaised && !withinRangeNow) )
			{
				self SetFlaggedAnimKnobAll("chargeanim", runAnim, %body, 1, .3, 1);
				raisingGun = false;
			}
		}
		self animscripts\shared::DoNoteTracksForTime(sampleTime, "chargeanim");
		
		// it's possible something happened in the meantime that makes meleeing impossible.
		if ( !CanMeleeAnyRange() )
			return false;
		assert( isdefined( self.enemyDistanceSq ) ); // should be defined in CanMelee

		enemyVel = vectorScale( self.enemy.origin - prevEnemyPos, 1 / (gettime() - time) ); // units/msec
		prevEnemyPos = self.enemy.origin;
		
		// figure out where the player will be when we hit them if we (a) start meleeing now, or (b) start raising our gun now
		predictedEnemyPosAfterRaiseGun = self.enemy.origin + vectorScale( enemyVel, raiseGunPredictDuration );
		predictedEnemyDistSqAfterRaiseGun = distanceSquared( self.origin, predictedEnemyPosAfterRaiseGun );
		
		// if we're done raising our gun, and starting a melee now will hit the guy, our preparation is finished
		if ( raisingGun && self.enemyDistanceSq <= shouldMeleeDistSq && gettime() - raiseGunStartTime >= raiseGunFinishDuration )
			break;

		// don't keep charging if we've been doing this for too long.
		if ( !raisingGun && gettime() >= self.giveUpOnMeleeTime )
			return false;
	}
	return true;
}

PlayMeleeSound()
{
	if ( !isdefined ( self.a.nextMeleeChargeSound ) )
	{
		 self.a.nextMeleeChargeSound = 0;
	}
	
	if ( gettime() > self.a.nextMeleeChargeSound )
	{
		self animscripts\face::SaySpecificDialogue( undefined, "play_grunt_" + self.voice, 0.3 );
		self.a.nextMeleeChargeSound = gettime() + 8000;
	}
}

// ===========================================================
//     AI vs AI synced melee
// ===========================================================

AiVsAiMeleeCombat()
{
	self endon("killanimscript");
	self notify("melee");
	
	self OrientMode("face enemy");
	
	self ClearAnim( %root, 0.3 );
	
	IWin = ( randomint(10) < 8 );
	if ( isDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
		IWin = true;
	if ( isDefined( self.enemy.magic_bullet_shield ) && self.enemy.magic_bullet_shield )
		IWin = false;
	
	// TODO: more anims
	winAnim = %bog_melee_R_attack;
	loseAnim = %bog_melee_R_defend;
	
	if ( IWin )
	{
		myAnim = winAnim;
		theirAnim = loseAnim;
	}
	else
	{
		myAnim = loseAnim;
		theirAnim = winAnim;
	}
	
	// TODO: associate this with the anim
	desiredDistSqrd = 72 * 72;
	
	self PlayMeleeSound();
	
	// charge into correct distance
	AiVsAiMeleeCharge( desiredDistSqrd );
	
	if ( distanceSquared( self.origin, self.enemy.origin ) > desiredDistSqrd )
		return false;
	
	// TODO: if too close, teleport backwards?
	
	// TODO: disable pushing?
	
	// TODO: need a tag_sync to linkto, like is done with dogs
	
	// start animation, start enemy on animation
	self.meleePartner = self.enemy;
	self.enemy.meleePartner = self;
	
	//self thread meleeLink();
	
	self.enemy.meleeAnim = theirAnim;
	self.enemy animcustom( ::AiVsAiAnimCustom );
	
	self.meleeAnim = myAnim;
	self animcustom( ::AiVsAiAnimCustom ); // TODO: we should try to avoid using animcustom on ourselves
}

AiVsAiMeleeCharge( desiredDistSqrd )
{
	giveUpTime = gettime() + 2500;
	self setAnimKnobAll( %run_lowready_F, %body, 1, 0.2 );
	
	while ( distanceSquared( self.origin, self.enemy.origin ) > desiredDistSqrd && gettime() < giveUpTime )
	{
		// play run forward anim
		wait .05;
	}
}

AiVsAiAnimCustom()
{
	self endon("killanimscript");
	self AiVsAiMeleeAnim( self.meleeAnim );
}

AiVsAiMeleeAnim( myAnim )
{
	self endon("end_melee");
	self thread endMeleeOnKillanimscript();
	
	partnerDir = self.meleePartner.origin - self.origin;
	self orientMode( "face angle", vectorToAngles( partnerDir )[1] );
	self animMode( "zonly_physics" );

	self setFlaggedAnimKnobAllRestart( "meleeAnim", myAnim, %body, 1, 0.2 );
	self animscripts\shared::DoNoteTracks( "meleeAnim" );
	
	self notify("end_melee");
}

endMeleeOnKillanimscript()
{
	self endon("end_melee");
	self waittill("killanimscript");
	self.meleePartner notify("end_melee");
}

meleeLink()
{
	self linkto( self.meleePartner );
	
	self waittill("end_melee");
	
	self unlink();
}

//pick_zombie_melee_anim( zombie_guy )
//{
//	if ( zombie_guy.has_legs )
//{
//	rand = randomint(4);
//	
//	if (rand == 0)
//	{
//		melee_anim = level._zombie_melee[0];
//	}
//	else if (rand == 1)
//	{
//		melee_anim = level._zombie_melee[1];
//	}
//	else if (rand == 2)
//	{
//		melee_anim = level._zombie_melee[2];
//	}
//	else if (rand == 3)
//	{
//		melee_anim = level._zombie_melee[3];
//	}
//	else
//	{
//		melee_anim = level._zombie_melee[0];
//	}
//	}
//	else
//	{
//		rand = randomintrange( 0, 1 );
//		
//		if (rand == 0)
//		{
//			melee_anim = level._zombie_melee_crawl[0];
//		}
//		else 
//		{
//			melee_anim = level._zombie_melee_crawl[1];
//		}
//		
//	}
//
//	
//			
//	return melee_anim;
//}

//chris_p - rewrote this to be more friendly 
pick_zombie_melee_anim( zombie_guy )
{
	melee_anim = undefined;
	if ( zombie_guy.has_legs )
	{
		switch(zombie_guy.zombie_move_speed)
		{
			
			case "walk": 
				anims = array_combine(level._zombie_melee[zombie_guy.animname],level._zombie_walk_melee[zombie_guy.animname]);
				melee_anim = random(anims);
				break;
				
			case "run":			
			case "sprint":
				anims = array_combine(level._zombie_melee[zombie_guy.animname],level._zombie_run_melee[zombie_guy.animname]);
				melee_anim = random(anims);
				break;			
		}
	}
	else if(zombie_guy.a.gib_ref == "no_legs")
	{
		// if zombie have no legs whatsoever.
		melee_anim = random(level._zombie_stumpy_melee[zombie_guy.animname]);

	}
	else
	{
 		melee_anim = random(level._zombie_melee_crawl[zombie_guy.animname]);
	}

	return melee_anim;
}