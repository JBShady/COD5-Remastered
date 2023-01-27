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
}



zombie_radio_play()
{
	self transmittargetname();

	self setcandamage(true);
	
	while (1)
	{
		self waittill ("damage");

		println("changing radio stations");

		SetClientSysState("levelNotify","kzmb_next_song");

		wait(1.0);
	}
}