#include maps\_zombiemode_utility;
#include maps\_utility;
#include common_scripts\utility;

#using_animtree( "generic_human" );

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
	self waittill( "explode", position ); // we wait for 1.5 seconds before grenade explodes after being thrown and then we start here

	wait(1.5); //wait another 1.5 seconds for smoke to start expanding

	gasEffectArea = spawn("trigger_radius", position, 0, 120, 150); 
	durationOfSmoke = 15; 

	for(;;)
	{
		wait(0.05); // Is this necessary
		zombies = getaiarray("axis");
		for(i=0;i<zombies.size;i++)
		{
			if( zombies[i] istouching(gasEffectArea) && zombies[i] in_playable_area() ) // first we check zombies in the radius and are in playable area
			{
				if(!isSubStr(zombies[i].current_speed, "confused") && !isSubStr(zombies[i].current_speed, "walk") && self.has_legs ) // then we make sure they are not already confused or walkers or crawlers
				{
					zombies[i].stored_speed = zombies[i].current_speed; // then we store their OG speed, this should NEVER have "confused" in it

					if(isSubStr(zombies[i].current_speed, "run") && zombies.size > 1 )
					{
						var = randomintrange(1, 7);
						zombies[i] thread set_run_anim( "confused_walk" + var ); 
						zombies[i].run_combatanim = level.scr_anim[zombies[i].animname]["walk" + var];
					}
					else if(isSubStr(zombies[i].current_speed, "sprint") && zombies.size > 1 )
					{
						var = randomintrange(1, 7);
						zombies[i] thread set_run_anim( "confused_run" + var );
						zombies[i].run_combatanim = level.scr_anim[zombies[i].animname]["run" + var];
					}
				}   

				rando = randomintrange(1,49);
				if(rando <= 12 ) // 25% chance we do an additional taunt or idle even after being slowed, this is the only thing that effects walkers and crawlers
				{
					zombies[i] thread setSmokeStun(rando);
				}    
			}
			else // then we check zombies not in the radius (this includes zombies that have since exited the radius)
			{
				if(isSubStr(zombies[i].current_speed, "confused") && isDefined(zombies[i].stored_speed) ) // if they happen to be previously confused, now we reset them back to their OG anim because they left the smoke
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
	wait(1);

	zombies = getaiarray("axis");
	for(i=0;i<zombies.size;i++)
	{
		if(isSubStr(zombies[i].current_speed, "confused") && isDefined(zombies[i].stored_speed) ) // if they happen to be previously confused, now we reset them back to their OG anim because they left the smoke
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
	else if(self.is_taunting == 1)
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
		if(rando == 1)
		{
			self do_a_taunt_smoke();
		}
		else
		{
			self animScripted( "smoke_zombie_stun", self.origin, self.angles, level._smoke_zombie_idle[0] );
		//	wait(1); // Is this necessary?
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


// things to test
// if a zombie is outside of map
// if rising
// if entering map
