#include maps\_zombiemode_utility;
#include maps\_utility;
#include common_scripts\utility;

// Creates AOE damage radius upon molotov impact. They still suck, but they're pretty useful during Insta-Kills to throw at choke points!

trackMolotov()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 
	for (;;)
	{
		self waittill( "grenade_fire", grenade, weaponName );
		if ( isSubStr(weaponName, "molotov") )
		{
			grenade thread watchMolotovFire( self );
		}
	}
}

watchMolotovFire(player)
{
	velocitySq = 10000 * 10000;
	oldPos = self.origin;
	sticky_pos = [];
	while( velocitySq != 0 )
	{
		wait( 0.05 );
		velocitySq = distanceSquared( self.origin, oldPos );
		oldPos = self.origin;
		sticky_pos = array_add(sticky_pos, self.origin);
	}

	fireEffectArea = spawn("trigger_radius", self.origin, 0, 80, 15); 
	durationOfFire = 8;  // fire only exists for a set amount of time

	for(;;)
	{
		wait(0.05);
		zombies = getaiarray("axis");
		zombies = get_array_of_closest( fireEffectArea.origin, zombies );
		for (i = 0; i < zombies.size; i++)
		{
/*			if( !IsDefined( zombies[i] ) )
			{
				continue;
			}*/
			if(zombies[i] isTouching(fireEffectArea) && (!isDefined(zombies[i].molotov_flamed) || zombies[i].molotov_flamed == false) )
			{
				zombies[i].molotov_flamed = true;

				if( i < 4 ) // don't spam flame FX, just char zombies after a few
				{
					zombies[i] thread animscripts\death::flame_death_fx();
				}
				else
				{
					zombies[i] StartTanning();
				}

				zombies[i] thread damage_on_fire_molotov( player );
			}
		}

		durationOfFire -= 0.05;
        if ( durationOfFire <= 0 )
        break;
	}

	fireEffectArea delete();
}

damage_on_fire_molotov( player ) // same damage as flamethrower, but we only do 2,3,4 ticks of damage
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
