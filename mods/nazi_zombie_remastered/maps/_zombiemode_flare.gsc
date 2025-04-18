#include maps\_zombiemode_utility;
#include maps\_utility;
#include common_scripts\utility;

// Creates MP vision effect when too close, distracts zombies, and can burn super close zombies
init()
{
	level thread upstairsChecker(); // keep flares upstairs disabled until debris is opened
}

upstairsChecker()
{
	level.noFlaresUpstairs = true;
	level waittill("junk purchased"); // when either debris is opened
	level.noFlaresUpstairs = undefined;
}

trackFlare()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 

	for (;;)
	{
		self waittill( "grenade_fire", grenade, weaponName );
		if ( isSubStr(weaponName, "flare") )
		{
			grenade thread watchFlare( self );
		}
	}
}

watchFlare(player)
{
	self waittill( "explode", position );

	flareVisionEffectRadius = 400;
	flareDistanceScale = 16;
	flare_enabled = undefined;

	flareEffectArea = spawn("trigger_radius", position, 0, flareVisionEffectRadius, flareVisionEffectRadius*2); 

	durationOfFlare = 7.5;  // flare only exists for a set amount of time

	zombies = getaiarray("axis");
	zombies = get_array_of_closest( flareEffectArea.origin, zombies );
	for (i = 0; i < zombies.size; i++)
	{
		if( DistanceSquared(zombies[i].origin, flareEffectArea.origin) < (64 * 64) && (!isDefined(zombies[i].molotov_flamed) || zombies[i].molotov_flamed == false) )
		{
			zombies[i].molotov_flamed = true;

			if( i < 2 ) // burn the closest 2 zombies just for fun, flares have sparks
			{
				zombies[i] thread animscripts\death::flame_death_fx();
				zombies[i] thread damage_on_fire_flare( player );
			}
		}
	}

	max_attract_dist = 1500;

	flareZombieTarget = Spawn( "script_origin", position + (0, 0, 5) );

	flareZombieTarget create_zombie_point_of_interest( max_attract_dist, 96, 10000 );
	flareZombieTarget.attract_to_origin = true;

	valid_poi = check_point_in_active_zone_proto( flareZombieTarget.origin );
	if( isDefined( flareZombieTarget ) )
	{
		if( valid_poi ) 
		{	
			valid_poi = check_point_in_playable_area( flareZombieTarget.origin );
		}
		
		if(valid_poi)
		{
			flareZombieTarget thread create_zombie_point_of_interest_attractor_positions( 4, 45 );
			flareZombieTarget thread wait_for_attractor_positions_complete();
			flareZombieTarget thread monitor_zombie_groans();
		}
		else
		{
			flareZombieTarget delete();
			self.script_noteworthy = undefined;
		}
	}

	for(;;)
	{
		wait(0.05);

		players = get_players();
		for (i = 0; i < players.size; i++)
		{	
			if (players[i].sessionstate == "playing" )
			{
				if(players[i] isTouching(flareEffectArea))
				{
					players[i].inFlareVisionArea = true;
					can_see = flareEffectArea maps\_zombiemode::player_can_see_me(players[i], true);
	
					distance = DistanceSquared(players[i].origin, flareEffectArea.origin);

					if(distance < (50 * 50))
					{
						//iprintlnbold("Inside flare, no see check");
						players[i] VisionSetNaked( "flare", 0.1 ); 

					}
					else if(distance < (100 * 100) && can_see)
					{
						//iprintlnbold("1");
						players[i] VisionSetNaked( "flare", 1.5 ); 

					}
					else if(distance < (200 * 200) && can_see)
					{
						//iprintlnbold("2");
						players[i] VisionSetNaked( "flare", 8 ); 

					}
					else if(distance < (300 * 300) && can_see)
					{
						//iprintlnbold("3");
						players[i] VisionSetNaked( "flare", 18 ); 

					}
					else if(distance < (400 * 400) && can_see)
					{
						//iprintlnbold("4");
						players[i] VisionSetNaked( "flare", 30 ); 
					}
		
					if(can_see == false && distance > (50 * 50))
					{
						//iprintlnbold("Not looking");
						players[i] VisionSetNaked( "zombie", 1 ); 
					}
				}
				else
				{
					players[i] VisionSetNaked( "zombie", 1 ); 
				}
			}
		}
		durationOfFlare -= 0.05;
        if ( durationOfFlare <= 0 )
        break;
	}

	players = get_players();
	for (i = 0; i < players.size; i++)
	{	
		players[i] VisionSetNaked( "zombie", 0.65 ); 
	}

	zombies = getaiarray("axis");
	for (i = 0; i < zombies.size; i++)
	{
		zombies[i] notify("flare_done"); // disable zombie flare vox
	}

	flareZombieTarget delete();
	flareEffectArea delete();
}

check_point_in_active_zone_proto(origin)
{
	if(origin[2] > 100 && isDefined(level.noFlaresUpstairs) && level.noFlaresUpstairs == true)
	{
		//iprintlnbold("flair is upstairs, disabled until we open");
		return false;
	}
	else
	{
		return true;
	}
}

wait_for_attractor_positions_complete()
{
	self waittill( "attractor_positions_generated" );
	
	self.attract_to_origin = false;
}


damage_on_fire_flare( player ) // same damage as flamethrower, but we only do 2,3,4 ticks of damage
{
	self endon ("death");
	
	flame_ticks = randomintrange(2,5);

	if(self.moveplaybackrate > 0.85) // flamer = 0.8, smoke/molotov = 0.85
	{
		self.moveplaybackrate = 0.85;
	}

	for(;;)
	{
		if( level.round_number < 6 )
		{
			dmg = level.zombie_health * RandomFloatRange( 0.2, 0.3 ); 
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
			dmg = level.zombie_health * RandomFloatRange( 0.1, 0.15 ); // when high rounding, molotov can do 20%-60% of a zombie's health depending on this and the amount of ticks + the weapon file damage which is going to be very insigificant
		}

		if ( Isdefined( player ) && Isalive( player ) )
		{
			self DoDamage( dmg, self.origin, player );
		}
		else
		{
			self DoDamage( dmg, self.origin, level );
		}
		
		flame_ticks -= 1;

        if ( flame_ticks <= 0 )
       	{
			self.molotov_flamed = undefined;
	        break;
       	}

		wait( randomfloatrange( 1.0, 3.0 ) );
	}
}

monitor_zombie_groans()
{
	self.sound_attractors = [];
	self endon( "flare_done" );
            
	while( true ) 
	{
		if( !isDefined( self ) )
		{
			return;
		}
		
		if( !isDefined( self.attractor_array ) )
		{
			wait( 0.05 );
			continue;
		}
		
		for( i = 0; i < self.attractor_array.size; i++ )
		{
			if( array_check_for_dupes( self.sound_attractors, self.attractor_array[i] ) )
			{
				if( distanceSquared( self.origin, self.attractor_array[i].origin ) < 400 * 400 )
				{
					self.sound_attractors = array_add( self.sound_attractors, self.attractor_array[i] );
					self.attractor_array[i] thread play_zombie_groans();
				}
			}
		}
		wait( 0.05 );
	}
} 

play_zombie_groans()
{
	self endon( "death" );
	self endon( "flare_done" );
            
	while(1)
	{
		if( isdefined ( self ) )
		{
			self playsound( "attack_vocals" );
			wait randomfloatrange( 2, 3 );
		}
		else
		{
			return;
		}
	}
}

