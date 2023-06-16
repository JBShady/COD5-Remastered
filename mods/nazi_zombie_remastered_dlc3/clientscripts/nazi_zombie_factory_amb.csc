//
// file: template_amb.csc
// description: clientside ambient script for template: setup ambient sounds, etc.
// scripter: 		(initial clientside work - laufer)
//

#include clientscripts\_utility; 
#include clientscripts\_ambientpackage;
#include clientscripts\_music;

main()
{
	//************************************************************************************************
	//                                              Ambient Packages
	
//************************************************************************************************

	//declare an ambientpackage, and populate it with elements
	//mandatory parameters are <package name>, <alias name>, <spawnMin>, <spawnMax>
	//followed by optional parameters <distMin>, <distMax>, <angleMin>, <angleMax>

 		//DEFAULT OUTDOOR
 		declareAmbientRoom( "outside" );
 		 	setAmbientRoomTone( "outside", "ghost_wind", 1.5, 2 );
 			setAmbientRoomReverb ("outside","stoneroom", 1, 0.65);
   	
   	declareAmbientPackage( "outside" );
      addAmbientElement( "outside", "ember", .1, .6, 50, 150 ); 
      
    //SMALL INTERIOR
 		declareAmbientRoom( "int_small_room" );
 			setAmbientRoomReverb ("int_small_room","stoneroom", 1, 0.8);
   	
   	declareAmbientPackage( "int_small_pkg" );    
   	
   	//LARGE INTERIOR
 		declareAmbientRoom( "int_large_room" );
 			setAmbientRoomReverb ("int_large_room","stonecorridor", 1, 0.8);
   	
   	declareAmbientPackage( "int_large_pkg" );             
	   	
	  //DARKROOM
	  declareAmbientRoom( "darkroom" );
 			setAmbientRoomReverb ("darkroom","stoneroom", 1, 1);
 		
 		declareAmbientPackage( "darkroom" );

	//************************************************************************************************
	//                                      ACTIVATE DEFAULT AMBIENT SETTINGS
	//************************************************************************************************

  activateAmbientPackage( 0, "outside", 0 );
  activateAmbientRoom( 0, "outside", 0 );



  declareMusicState("SPLASH_SCREEN"); //one shot dont transition until done
		musicAlias("mx_splash_screen", 12);	
		musicwaittilldone();

 	declareMusicState("round_begin");
		musicAlias("chalk", 2);
		musicAliasloop("mx_zombie_wave_1", 0, 4);
		musicwaittilldone();

	declareMusicState ("round_end"); 
    musicAlias ("round_over", 2);
		musicwaittilldone();

	declareMusicState("WAVE_1"); 
		musicAliasloop("mx_zombie_wave_1", 0, 4);	
		musicwaittilldone();

 	declareMusicState("eggs"); 
		musicAlias("mx_eggs", 2);

 	declareMusicState("mx_dog_round");
		musicAliasloop("mx_dog_wave", 0, 0.5);

	declareMusicState("end_of_game");
		musicAlias("mx_game_over", 0);


	thread radio_init();
	thread start_lights();
	
	//TELEPORTER
	thread teleport_pad_init(0);
	thread teleport_pad_init(1);
	thread teleport_pad_init(2);
	
	thread teleport_2d();
	
	thread pa_init(0);
	thread pa_init(1);
	thread pa_init(2);
	thread pa_single_init();
	
	thread pole_fx_audio_init(0);
	thread pole_fx_audio_init(1);
	thread pole_fx_audio_init(2);
	
	thread homepad_loop();
	thread homepad_loop_resume(); // for egg
	thread power_audio_2d();
	thread linkall_2d();
}
add_song(song)
{
	if(!isdefined(level.radio_songs))
 		level.radio_songs = [];
	level.radio_songs[level.radio_songs.size] = song;
}

fade(id, time)
{
	rate = 0;
	if(time != 0)
		rate = 1.0 / time;

	setSoundVolumeRate(id, rate);
	setSoundVolume(id, 0.0);

	while(SoundPlaying(id) && getSoundVolume(id) > .0001)
	{
		wait(.1);
	}

	stopSound(id);
}


radio_advance()
{
	for(;;)
	{
		while(SoundPlaying(level.radio_id) || level.radio_index == 0)
		{
			wait(1);
		}
		level notify("kzmb_next_song");
		wait(1);
	}
	
}


radio_thread()
{
	assert(isdefined(level.radio_id));
	assert(isdefined(level.radio_songs));
	assert(isdefined(level.radio_index));
	assert(level.radio_songs.size > 0);

	println("Starting radio at "+self.origin);

	for(;;)
	{
		level waittill("kzmb_next_song");

		println("client changing songs");

		playsound(0, "static", self.origin);

		if(SoundPlaying(level.radio_id))
		{
			fade(level.radio_id, 1);
		}
		else
		{
			wait(.5);
		}

		level.radio_id = playsound(0, level.radio_songs[level.radio_index], self.origin);
	
		level.radio_index += 1;
		
		if(level.radio_index >= level.radio_songs.size)
		{
			level.radio_index = 0;
		}

		wait(1);
	}
}


radio_init()
{

	level.radio_id = -1;
	level.radio_index = 0;
	add_song( "wtf" );
	add_song( "dog_fire" );
	add_song( "true_crime_4" );
	add_song( "all_mixed_up" );
	add_song( "dusk" );	
	add_song( "the_march" );
	add_song( "drum_no_bass" );
	add_song( "russian_theme" );
	add_song( "sand" );
	add_song( "stag_push" );
	add_song( "pby_old" );
	add_song( "wild_card" );
	add_song( "" ); //silence must be last

	// kzmb, for all the latest killer hits

	radios = getentarray(0, "kzmb","targetname");
	
	while (!isdefined(radios) || !radios.size)
	{
		wait(5); //make sure we wait around until targetname for this ent is sent over
		radios = getentarray(0, "kzmb","targetname");
	}

	println("client found "+radios.size+" radios");
	
	array_thread(radios, ::radio_thread );
	array_thread(radios, ::radio_advance );
}

start_lights()
{
	level waittill ("pl1");

	//playsound(0,"turn_on", (0,0,0));	

	array_thread(getstructarray( "dyn_light", "targetname" ), ::light_sound);
	array_thread(getstructarray( "switch_progress", "targetname" ), ::switch_progress_sound);
	array_thread(getstructarray( "dyn_generator", "targetname" ), ::generator_sound);
	array_thread(getstructarray( "dyn_breakers", "targetname" ), ::breakers_sound);
	//array_thread(getstructarray( "perksacola", "targetname" ), ::perks_a_cola_jingle);

	//FOR a new 2d Ambience to add on, if needed
	//playertrack = clientscripts\_audio::playloopat(0,"players_ambience", (0,0,0));
}

light_sound()
{
	if(isdefined( self ) )
	{
		playsound(0,"light_start", self.origin);
		e1 = clientscripts\_audio::playloopat(0,"light",self.origin);
	}
}

generator_sound()
{
	if(isdefined( self ) )
	{
		realwait(3);
		playsound(0, "switch_progress", self.origin);
		playsound(0, "gen_start", self.origin);
		g1 = clientscripts\_audio::playloopat(0,"gen_loop",self.origin, 1);
	}
}

breakers_sound()
{
	if(isdefined( self ) )
	{
		playsound(0, "break_start", self.origin);
		b1 = clientscripts\_audio::playloopat(0,"break_loop",self.origin, 2);
	}
}

switch_progress_sound()
{
	if(isdefined( self.script_noteworthy ) )	
	{
    if( self.script_noteworthy == "1" )
    	time = .5;
    else if( self.script_noteworthy == "2" )
    	time = 1;
    else if( self.script_noteworthy == "3" )
    	time = 1.5;
    else if( self.script_noteworthy == "4" )
    	time = 2;
    else if( self.script_noteworthy == "5" )
    	time = 2.5;
    else
    	time = 0;
    	
		wait(time);
		playsound(0, "switch_progress", self.origin);
	}
}

/*
run_sparks_loop()
{
	while(1)
	{
		wait(randomfloatrange(4,15));
		if (randomfloatrange(0, 1) < 0.5)
		{
			//playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound(0,"electrical_surge", self.origin);
		}
		wait(randomintrange(1,4));
	}
}
*/

/*
perks_a_cola_jingle()
{	
	lowhum = clientscripts\_audio::playloopat(0, "perks_machine_loop", self.origin);
	self thread play_random_broken_sounds();
	while(1)
	{
		wait(randomfloatrange(40, 120));
		level notify ("jingle_playing");
		playsound (0, self.script_sound, self.origin);
		playfx (0, level._effect["electric_short_oneshot"], self.origin);
		playsound (0, "electrical_surge", self.origin);
		wait (30);
		self thread play_random_broken_sounds();		
	}	
	
}
play_random_broken_sounds()
{
	level endon ("jingle_playing");
	if (!isdefined (self.script_sound))
	{
		self.script_sound = "null";
	}
	if (self.script_sound == "mx_revive_jingle")
	{
		while(1)
		{
			wait(randomfloatrange(7, 18));
			playsound (0, "broken_random_jingle", self.origin);
			playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound (0, "electrical_surge", self.origin);
	
		}
	}
	else
	{
		while(1)
		{
			wait(randomfloatrange(7, 18));
			playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound (0, "electrical_surge", self.origin);
		}
	}
}
*/

//TELEPORTER
homepad_loop()
{
	level waittill( "pap1" );
	homepad = getstruct( "homepad_power_looper", "targetname" );
	home_breaker = getstruct( "homepad_breaker", "targetname" );
	home_breaker_loopsound = undefined;

	if(isdefined( homepad ))
	{
		clientscripts\_audio::playloopat( 0, "homepad_power_loop", homepad.origin, 1 );
	}
	if(isdefined( home_breaker ) )
	{
		home_breaker_loopsound = clientscripts\_audio::playloopat( 0, "break_arc", home_breaker.origin, 1 ); // set returned val  to a variable so we can stop it later
	}

	level waittill( "turn_off_sounds_lights" ); // for egg so we can turn off the side generator
	stoploopsound(0, home_breaker_loopsound, 0.1 );
}

homepad_loop_resume()
{
	level waittill( "pap1_resume" );
	home_breaker = getstruct( "homepad_breaker", "targetname" );

	if(isdefined( home_breaker ) )
	{
		clientscripts\_audio::playloopat( 0, "break_arc", home_breaker.origin, 1 );
	}

}

teleport_pad_init( pad )  //Plays loopers on each pad as they get activated, threads the teleportation audio
{
	telepad = getstructarray( "telepad_" + pad, "targetname" );
	telepad_loop = getstructarray( "telepad_" + pad + "_looper", "targetname" );
	homepad = getstructarray( "homepad", "targetname" );
	
	level waittill( "tp" + pad);
	array_thread( telepad_loop, ::telepad_loop );
	array_thread( telepad, ::teleportation_audio, pad );
	array_thread( homepad, ::teleportation_audio, pad );
}

telepad_loop()
{
	clientscripts\_audio::playloopat( 0, "power_loop", self.origin, 1 );
}

teleportation_audio( pad )  //Plays warmup and cooldown audio for homepad and telepads
{
	teleport_delay = 2;
	
	while(1)
	{
		level waittill( "tpw" + pad );

		if(IsDefined( self.script_sound ))
		{
			if(self.targetname == "telepad_" + pad) //Sounds play right after each other
			{
				playsound( 0, self.script_sound + "_warmup", self.origin );
				realwait(teleport_delay);
				playsound( 0, self.script_sound + "_cooldown", self.origin );
			}
			if(self.targetname == "homepad") //Sounds wait until 2 seconds before transportation
			{
				realwait(teleport_delay);
				playsound( 0, self.script_sound + "_warmup", self.origin );
				playsound( 0, self.script_sound + "_cooldown", self.origin );
			}
		}
	}		
}

//***PA System***
//Plays sounds off of PA structs strewn throughout the map


pa_init( pad )
{
	pa_sys = getstructarray( "pa_system", "targetname" );
	
	array_thread( pa_sys, ::pa_teleport, pad );
	array_thread( pa_sys, ::pa_countdown, pad );
	array_thread( pa_sys, ::pa_countdown_success, pad );
}

pa_single_init()
{
	pa_sys = getstructarray( "pa_system", "targetname" );
	
	array_thread( pa_sys, ::pa_electric_trap, "bridge" );
	array_thread( pa_sys, ::pa_electric_trap, "wuen" );
	array_thread( pa_sys, ::pa_electric_trap, "warehouse" );
	array_thread( pa_sys, ::pa_level_start );
	array_thread( pa_sys, ::pa_power_on );
	
}

pa_countdown( pad )
{
	level endon( "scd" + pad );
	
	while(1)
	{		
		level waittill( "pac" + pad );
		
		playsound( 0, "pa_buzz", self.origin );
		self thread pa_play_dialog( "pa_audio_link_start" );
	
		count = 30;
		while ( count > 0 )
		{
			if( count == 20 )
				playsound( 0, "pa_audio_link_" + count, self.origin );
			if( count == 15 )
				playsound( 0, "pa_audio_link_" + count, self.origin );
			if( count <= 10 )
				playsound( 0, "pa_audio_link_" + count, self.origin );
			
			playsound( 0, "clock_tick_1sec", (0,0,0) );	
			realwait( 1 );
			count--;
		}
		playsound( 0, "pa_buzz", self.origin );
		realwait(1.2);
		self thread pa_play_dialog( "pa_audio_link_fail" );
	}
	realwait(1);
}

pa_countdown_success( pad )
{
	level waittill( "scd" + pad );
	
	playsound( 0, "pa_buzz", self.origin );
	realwait(1.2);
	//self pa_play_dialog( "pa_audio_link_yes" );
	self pa_play_dialog( "pa_audio_act_pad_" + pad );
}

pa_teleport( pad )  //Plays after successful teleportation, threads cooldown count
{
	while(1)
	{
		level waittill( "tpc" + pad );
		realwait(1);
		
		playsound( 0, "pa_buzz", self.origin );
		realwait(1.2);
		self pa_play_dialog( "pa_teleport_finish" );
	}
}

pa_electric_trap( location )
{
	while(1)
	{
		level waittill( location );
		
		playsound( 0, "pa_buzz", self.origin );
		realwait(1.2);
		self thread pa_play_dialog( "pa_trap_inuse_" + location );
		realwait(58.5);
		playsound( 0, "pa_buzz", self.origin );
		realwait(1.2);
		self thread pa_play_dialog( "pa_trap_active_" + location );
	}
}

pa_play_dialog( alias )
{
	if( !IsDefined( self.pa_is_speaking ) )
	{
		self.pa_is_speaking = 0;	
	}
	
	if( self.pa_is_speaking != 1 )
	{
		self.pa_is_speaking = 1;
		self.pa_id = playsound( 0, alias, self.origin );
		while( SoundPlaying( self.pa_id ) )
		{
			wait( 0.01 );
		}
		self.pa_is_speaking = 0;
	}
}
	
teleport_2d()  //Plays a 2d sound for a teleporting player 1.7 seconds after activating teleporter
{
	while(1)
	{
		level waittill( "t2d" );
		playsound( 0, "teleport_2d_fnt", (0,0,0) );
		playsound( 0, "teleport_2d_rear", (0,0,0) );
	}
}

power_audio_2d()
{
	realwait(2);
	playsound( 0, "power_down_2d", (0,0,0) );
	level waittill ("pl1");
	playsound( 0, "power_up_2d", (0,0,0) );
}

linkall_2d()
{
	level waittill( "pap1" );
	playsound( 0, "linkall_2d", (0,0,0) );
}

/*
pa_cooldown_count()  //Plays lines on 30, 15, and 0
{
	cooldown = 60;
	while( cooldown > 0 )
	{
		if(cooldown == 30)
		{
			playsound( 0, "pa_cooldown_half", self.origin );
		}
		if(cooldown == 15)
		{
			playsound( 0, "pa_audio_link_15", self.origin );
		}
		realwait(1);
		cooldown--;
	}
	playsound( 0, "pa_buzz", self.origin );
	wait(1.2);
	playsound( 0, "pa_cooldown_end", self.origin );
}
*/

pole_fx_audio_init( pad )
{
	pole = getstructarray( "pole_fx_" + pad, "targetname" );
	array_thread( pole, ::pole_fx_audio, pad );
}

pole_fx_audio( pad )
{
	level waittill( "scd" + pad );
	
	while(1)
	{
		playfx(0, level._effect["zombie_elec_pole_terminal"], self.origin, anglestoforward( self.angles ) );
		playsound(0,"pole_spark", self.origin );
		realwait(randomintrange(2,7));
	}
}

pa_level_start()
{
	realwait(2);
	playsound( 0, "pa_buzz", self.origin );
	realwait(1.2);
	self pa_play_dialog( "pa_level_start" );
}

pa_power_on()
{
	level waittill ("pl1");
	
	playsound( 0, "pa_buzz", self.origin );
	realwait(1.2);
	self pa_play_dialog( "pa_power_on" );
}