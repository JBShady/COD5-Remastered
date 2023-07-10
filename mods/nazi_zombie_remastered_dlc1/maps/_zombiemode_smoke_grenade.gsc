#include maps\_zombiemode_utility;
#include maps\_utility;
#include common_scripts\utility;

#using_animtree( "generic_human" );

// Uses new variable set in anim script on zombies (a "self" variable) called "current_speed", which stores the name of a zombie's current movement anim. Can then use it to test if the string contains walk, run, or sprint.

// issues: hard coded to not work on the last zombie to account for  how another loop is setting him to run, however maybe this could count as a feature 

init()
{
	init_smoked_anims();
}

init_smoked_anims()
{
	level._smoke_crawler_idle = []; //make sure these can match (limbs)
	level._smoke_crawler_idle[0] = %ai_zombie_idle_crawl_delta;

	level._smoke_zombie_idle = [];
	level._smoke_zombie_idle[0] = %ai_zombie_idle_v1_delta;

	level.scr_anim["zombie"]["confused_walk1"] 	= %ai_zombie_walk_v1;
	level.scr_anim["zombie"]["confused_walk2"] 	= %ai_zombie_walk_v2; 
	level.scr_anim["zombie"]["confused_walk3"] 	= %ai_zombie_walk_v2; 
	level.scr_anim["zombie"]["confused_walk4"] 	= %ai_zombie_walk_v4; 
	level.scr_anim["zombie"]["confused_walk5"] 	= %ai_zombie_walk_v4; 
	level.scr_anim["zombie"]["confused_walk6"] 	= %ai_zombie_walk_v6; 
	level.scr_anim["zombie"]["confused_walk7"] 	= %ai_zombie_walk_v6; 

	level.scr_anim["zombie"]["confused_run1"] 	= %ai_zombie_walk_fast_v1;
	level.scr_anim["zombie"]["confused_run2"] 	= %ai_zombie_walk_fast_v2; 
	level.scr_anim["zombie"]["confused_run3"] 	= %ai_zombie_run_v2; 
	level.scr_anim["zombie"]["confused_run4"] 	= %ai_zombie_run_v2; 
	level.scr_anim["zombie"]["confused_run5"] 	= %ai_zombie_run_v4; 
	level.scr_anim["zombie"]["confused_run6"] 	= %ai_zombie_run_v4; 
	level.scr_anim["zombie"]["confused_run7"] 	= %ai_zombie_walk_v4;

}

trackSmokeGrenade()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 

	for (;;)
	{
		self waittill( "grenade_fire", grenade, weaponName );
		if (weaponName == "m8_white_smoke" )
		{
			grenade thread watchSmokeDetonation( self );
		}
	}
}

watchSmokeDetonation()
{
	self waittill( "explode", position ); // we wait for 1.5 seconds before grenade explodes after being thrown and then we start here, first delay is set in wep file

	wait(1.35); // another delay so we let the smoke start expanding

	gasEffectArea = spawn("trigger_radius", position, 0, 120, 150); 
	durationOfSmoke = 16;  // smoke only exists for a set amount of time

	for(;;)
	{
		wait(0.05);
		zombies = getaiarray("axis");
		for(i=0;i<zombies.size;i++)
		{
			if( zombies[i] istouching(gasEffectArea) && zombies[i] in_playable_area() ) // first we check zombies in the radius and are in playable area
			{
				if(!isSubStr(zombies[i].current_speed, "confused") && !isSubStr(zombies[i].current_speed, "walk") && self.has_legs ) // then we make sure they are not already confused or walkers or crawlers
				{
					zombies[i].stored_speed = zombies[i].current_speed; // then we store their OG speed, this should NEVER have "confused" in it

					if(isSubStr(zombies[i].current_speed, "run")  && zombies.size > 1 ) // if its run, we go down to walk
					{
						var = randomintrange(1, 7);
						zombies[i] thread set_run_anim( "confused_walk" + var ); 
						zombies[i].run_combatanim = level.scr_anim[zombies[i].animname]["walk" + var];
					}
					else if(isSubStr(zombies[i].current_speed, "sprint") && zombies.size > 1  ) // if its sprint, we go down to run
					{
						var = randomintrange(1, 7);
						zombies[i] thread set_run_anim( "confused_run" + var );
						zombies[i].run_combatanim = level.scr_anim[zombies[i].animname]["run" + var];
					}
				}   

				rando = randomintrange(1,101);
				if(rando <= 50 ) // 50% chance we do an additional taunt or idle even after being slowed. This is the only thing that effects walkers--so they pretty much get stunned a lot more which makes sense, theyre more likely to be confused by smoke
				{
					zombies[i] thread setSmokeStun(rando);
				}    
			}
			else // then we check zombies that are not in the radius (this includes zombies that have since exited the radius)
			{
				if(isSubStr(zombies[i].current_speed, "confused") && isDefined(zombies[i].stored_speed) ) // if they happen to be previously confused, now we reset them back to their OG anim because they left the smoke, otherwise we do nothing
				{
					zombies[i] thread set_run_anim( zombies[i].stored_speed ); 
					zombies[i].run_combatanim = level.scr_anim[zombies[i].animname][zombies[i].stored_speed];

				}
			}
		}
		durationOfSmoke -= 0.05;
        if ( durationOfSmoke <= 0 )
        break;
	}

	gasEffectArea delete();
	// smoke ends and we wait for it to fully clear
	wait(0.8);

	// fail safe to reset zombies back to og speed
	zombies = getaiarray("axis");
	for(i=0;i<zombies.size;i++) 
	{
		if(isSubStr(zombies[i].current_speed, "confused") && isDefined(zombies[i].stored_speed) ) // if they happen to be previously confused even if they never left the radius, we force them all back to their OG anim because now the smoke has faded away
		{
			zombies[i] thread set_run_anim( zombies[i].stored_speed ); 
			zombies[i].run_combatanim = level.scr_anim[zombies[i].animname][zombies[i].stored_speed];
		}
	}
}

setSmokeStun(rando) 
{
	self endon( "death" );
	if(!IsDefined(self.is_taunting))
	{
		self.is_taunting = 0;	
	}
	else if(self.is_taunting == 1) // dont spam multiple taunts all at once
	{
		return;
	}

	if( !isDefined( self ) || !isAlive( self ) )
	{
		return;
	}

	if( !self in_playable_area() || self.in_the_ground == true )
	{
		return;
	}

	if( self.has_legs )
	{
		if(rando <= 5 ) // 10% chance we do a special taunt, otherwise just go idle
		{
			self do_a_taunt_smoke();
		}
		else
		{
			self animScripted( "smoke_zombie_stun", self.origin, self.angles, level._smoke_zombie_idle[0] );
		}
	}

}

do_a_taunt_smoke()
{
	if( self.has_legs)
	{
		self.is_taunting = 1;
		self.old_origin = self.origin;
		anime = random(level._zombie_board_taunt[self.animname]);
		self animscripted("zombie_taunt",self.origin, self.angles, anime);
		wait(getanimlength(anime));
		self teleport(self.old_origin);
		self.is_taunting = undefined;	
	}
}

