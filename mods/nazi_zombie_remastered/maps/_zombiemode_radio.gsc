#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	// radio spark
	level._effect["broken_radio_spark"] = LoadFx( "env/electrical/fx_elec_short_oneshot" );

	// kzmb, for all the latest killer hits
	radios = getentarray("kzmb","targetname");
	
	// no radios, return
	if (!isdefined(radios) || !radios.size)
	{
		return;
	}
	
	array_thread(radios, ::zombie_radio_play );

	level thread stop_the_radio();
}



zombie_radio_play()
{
	self transmittargetname();

	self setcandamage(true);
	
	if(!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}

	while (1)
	{
		self waittill ("damage", damage, attacker);

		attacker achievement_notify( "DLC_ZOMBIE_RADIO" );

		if(level.eggs != 1)
		{
			SetClientSysState("levelNotify","kzmb_next_song" );			
		}

		wait(1.0);
	}
}

stop_the_radio()
{
	if(!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}
	while(1)
	{
			if (level.eggs == 0)
			{
				wait(0.5);
			}
			else
			{
				level clientNotify ("ktr");  //Kill the Radio
				//iprintlnbold ("stopping_radio_from_GSC");
				while ( level.eggs == 1)
				{
					wait(0.5);
				}
				level clientNotify ("rrd"); //Resume the radio
				//iprintlnbold ("resuming_radio_from_GSC");
			}
			wait(0.5);
	}	
}