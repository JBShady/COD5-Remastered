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
	level.scr_anim["zombie"]["confused_run3"] 	= %ai_zombie_walk_fast_v1; 
	level.scr_anim["zombie"]["confused_run4"] 	= %ai_zombie_walk_fast_v2; 
	level.scr_anim["zombie"]["confused_run5"] 	= %ai_zombie_run_v2; 
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
/*
-slows zombie anims to 85%
-downgrades runners to all walkers, and sprinters to runners/walkers
-every loop, very small chance of forcing a special taunt anim
-every loop, small chance of forcing confused anim

-as a result, most zombies will be stuck in the smoke, but the faster they are and the more of them there are, the higher chance there is that a few will slip through  
*/

watchSmokeDetonation( player )
{
	self waittill( "explode", position ); // we wait for 1.5 seconds before grenade explodes after being thrown and then we start here, first delay is set in wep file

	wait(1.3); // another delay so we let the smoke start expanding

	gasEffectArea = spawn("trigger_radius", position, 0, 120, 150); 
	durationOfSmoke = 16.05;  // smoke only exists for a set amount of time

	for(;;)
	{
		wait(0.05);
		zombies = getaiarray("axis");
		zombies = get_array_of_closest( gasEffectArea.origin, zombies );

		for(i=0;i<zombies.size;i++)
		{
			if( zombies[i] istouching(gasEffectArea) && zombies[i].in_the_ground != true && zombies[i].has_legs ) // first we check zombies in the radius and are in playable area
			{
				player achievement_notify( "DLC1_ZOMBIE_SMOKE" );

				//iprintln(zombies[i].current_speed);

				if(!isSubStr(zombies[i].current_speed, "confused") ) // then we make sure they are not already confused or walkers or crawlers
				{
					// First we slow their anim down
					if( !IsDefined( zombies[i].is_on_fire ) ) // only change speed if we are NOT on fire, because if we are on fire we already have a separate speed change
					{
						zombies[i].moveplaybackrate = 0.85;
					}

					zombies[i].stored_speed = zombies[i].current_speed; // then we store their OG speed, this should NEVER have "confused" in it

					// Then we force them to a lower speed
					if((isSubStr(zombies[i].current_speed, "run") || isSubStr(zombies[i].current_speed, "walk"))  && zombies.size > 1 ) // if its run, we go down to walk category
					{
						var = randomintrange(1, 7);
						zombies[i] thread set_run_anim( "confused_walk" + var ); 
						zombies[i].run_combatanim = level.scr_anim[zombies[i].animname]["walk" + var];
					}
					else if(isSubStr(zombies[i].current_speed, "sprint") && zombies.size > 1  ) // if its sprint, we go down to run category
					{
						var = randomintrange(1, 7);
						zombies[i] thread set_run_anim( "confused_run" + var );
						zombies[i].run_combatanim = level.scr_anim[zombies[i].animname]["run" + var];
					}
				}   

				if(!isDefined(zombies[i].is_taunting) && zombies[i] in_playable_area() ) // if we are already defining taunting then that means we are currently taunting and should not spam another stun, wait to test for odds when zombie is done taunting
				{
					rando = randomintrange(1,101);
					if(rando <= 1 )
					{
						zombies[i] thread do_a_taunt_smoke(); 
					}
					else if(rando <= 7 )
					{
						zombies[i] animScripted( "smoke_zombie_stun", zombies[i].origin, zombies[i].angles, level._smoke_zombie_idle[0] );
					}
				}
			}
			else // then we check zombies that are not in the radius (this includes zombies that have since exited the radius)
			{
				if(isSubStr(zombies[i].current_speed, "confused") && isDefined(zombies[i].stored_speed) ) // if they happen to be previously confused, now we reset them back to their OG anim because they left the smoke, otherwise we do nothing
				{
					if( !IsDefined( zombies[i].is_on_fire ) ) // only change speed if we are NOT on fire, because if we are on fire we already have a separate speed change
					{
						zombies[i].moveplaybackrate = 1.0;
					}

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
			if( !IsDefined( zombies[i].is_on_fire ) ) // only change speed if we are NOT on fire, because if we are on fire we already have a separate speed change
			{
				zombies[i].moveplaybackrate = 1.0;
			}
			zombies[i] thread set_run_anim( zombies[i].stored_speed ); 
			zombies[i].run_combatanim = level.scr_anim[zombies[i].animname][zombies[i].stored_speed];
		}
	}
}

do_a_taunt_smoke()
{
	self endon( "death" );

	self.is_taunting = 1;
	self.old_origin = self.origin;
	anime = random(level._zombie_board_taunt[self.animname]);
	self animscripted("zombie_taunt",self.origin, self.angles, anime);
	wait(getanimlength(anime));
	self teleport(self.old_origin);
	self.is_taunting = undefined;	
}

