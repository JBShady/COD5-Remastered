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
	
        declareAmbientPackage( "zombies" );
            addAmbientElement( "zombies", "amb_spooky_2d", 5, 8, 300, 2000 );

 		declareAmbientRoom( "zombies" );
 			//setAmbientRoomTone( "zombies", "bgt_base" );
 			setAmbientRoomReverb ("zombies","MOUNTAINS", 1, 0.5);

        declareAmbientPackage( "bathroom" );
            addAmbientElement( "bathroom", "amb_spooky_2d", 5, 8, 300, 2000 );
			addAmbientElement( "bathroom", "amb_water_drips_rand", 0.2, 0.5, 50, 350 );

 		declareAmbientRoom( "bathroom" );
 			setAmbientRoomReverb ("bathroom","SMALLROOM", 1, 0.7);

        declareAmbientPackage( "outside" );
            addAmbientElement( "zombies", "amb_spooky_2d", 5, 8, 300, 2000 );

 		declareAmbientRoom( "outside" );
 			//setAmbientRoomTone( "outside", "bgt_base" );
 			setAmbientRoomReverb ("outside","forest", 1, 0.5);
 		
	 	declareAmbientRoom( "shack" );
		//setAmbientRoomTone( "shack", "bgt_base" );
		setAmbientRoomReverb ("shack","bathroom", 1, 0.7);
		
 		declareAmbientPackage( "shack" );
		 	addAmbientElement( "shack", "amb_spooky_2d", 5, 8, 300, 2000 );
		 	addAmbientElement( "shack", "wood_creak", 5, 12, 10, 450 );
		 	
		 declareAmbientRoom( "wood_shack" );
		//setAmbientRoomTone( "wood_shack", "bgt_base" );
		setAmbientRoomReverb ("wood_shack","SMALLROOM", 1, 0.5);
		
 		declareAmbientPackage( "wood_shack" );
		 	addAmbientElement( "wood_shack", "amb_spooky_2d", 5, 8, 300, 2000 );
		 	addAmbientElement( "wood_shack", "wood_creak", 5, 12, 10, 450 );
 			
 		declareAmbientRoom( "hut_downstairs" );
 			setAmbientRoomReverb ("hut_downstairs","HALLWAY", 1, 0.6);
 		
 		declareAmbientPackage( "hut_downstairs" );
 			addAmbientElement( "hut_downstairs", "amb_spooky_2d", 10, 18, 300, 2000 );
 			addAmbientElement( "hut_downstairs", "wood_creak", 5, 12, 10, 450 );

 		declareAmbientRoom( "perks_hut" );
			setAmbientRoomReverb ("perks_hut","HALLWAY", 1, 0.7);
				
		declareAmbientPackage( "perks_hut" );
		 	addAmbientElement( "perks_hut", "amb_spooky_2d", 5, 8, 300, 2000 );
			addAmbientElement( "perks_hut", "wood_creak", 5, 12, 10, 450 );

	//************************************************************************************************
	//                                      ACTIVATE DEFAULT AMBIENT SETTINGS
	//************************************************************************************************

  activateAmbientPackage( 0, "zombies", 0 );
  activateAmbientRoom( 0, "zombies", 0 );



  declareMusicState("SPLASH_SCREEN"); //one shot dont transition until done
	musicAlias("mx_splash_screen", 12);	
	musicwaittilldone();

 declareMusicState("round_begin");
	musicAlias("chalk", 2);
	musicAliasloop("mx_zombie_wave_1", 0, 0.5);
	musicwaittilldone();

 declareMusicState ("round_end"); 
    musicAlias ("round_over", 2);
	musicwaittilldone();

  declareMusicState("WAVE_1"); 
	musicAliasloop("mx_zombie_wave_1", 0, 0.5);	
	musicwaittilldone();

  declareMusicState("eggs"); 
	musicAlias("mx_eggs", 2);

  declareMusicState("last_zombie");
	musicAliasloop("mx_last_zombie", 0, 0.5);


  declareMusicState("mx_dog_round");
	musicAliasloop("mx_dog_wave", 0, 0.5);


  declareMusicState("end_of_game");
	musicAlias("mx_game_over", 4);

	declareMusicState("SILENT");


//	thread radio_init();
//	thread start_lights();

/*
	thread start_speed_sounds();
	thread start_revive_sounds();
	thread start_doubletap_sounds();
	thread start_jugganog_sounds();
*/

	thread play_meteor_loop();
	

}
play_meteor_loop()
{
	meteor = clientscripts\_audio::playloopat(0,"meteor_loop", (11264, -1920, -592));
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
	
//	array_thread(radios, ::radio_thread );
//	array_thread(radios, ::radio_advance );

}

start_lights()
{
	level waittill ("start_lights");
	wait(2.0);

	array_thread(getstructarray( "electrical_circuit", "targetname" ), ::circuit_sound);
	playsound(0,"turn_on", (0,0,0));	


	wait (3.0);
	array_thread(getstructarray( "electrical_surge", "targetname" ), ::light_sound);
	array_thread(getstructarray( "low_buzz", "targetname" ), ::buzz_sound);
	array_thread(getstructarray( "perksacola", "targetname" ), ::perks_a_cola_jingle);

// Turns on 2D track for each player *move to client*
	playertrack = clientscripts\_audio::playloopat(0,"players_ambience", (0,0,0));
	
//	array_thread(getstructarray( "electrical_room", "targetname" ), ::electrical_room_sound);
}
light_sound()
{

	wait(randomfloatrange(1,4));
	playsound(0,"electrical_surge", self.origin);
	playfx (0, level._effect["electric_short_oneshot"], self.origin);
	wait(randomfloatrange(1,2));
	e1 = clientscripts\_audio::playloopat(0,"light",self.origin);
	
	self run_sparks_loop();
}
run_sparks_loop()
{
	//fx_spark = level._effect["fx_elec_sparking_oneshot"];
	while(1)
	{

		wait(randomfloatrange(4,15));
		if (randomfloatrange(0, 1) < 0.5)
		{
			playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound(0,"electrical_surge", self.origin);
		}
		wait(randomintrange(1,4));
	}
}
circuit_sound()
{
	wait(1);
	playsound(0,"circuit", self.origin);
}
buzz_sound()
{
	lowbuzz = clientscripts\_audio::playloopat(0,"low_arc", self.origin);

}
start_jugganog_sounds()
{
	level waittill ("jugg_on");
	
	iprintlnbold("Machine_ON!!!");
	
	machine = getstructarray( "perksacola", "targetname" );
	for(i=0;i<machine.size;i++)
	{
		if(machine[i].script_sound == "mx_jugger_jingle")
		{
			machine[i] thread perks_a_cola_jingle();
			iprintlnbold("Jugga_Run_Jingle");
		}
	}
}
start_speed_sounds()
{
	level waittill ("fast_reload_on");
	
	iprintlnbold("Machine_ON!!!");
	
	machine = getstructarray( "perksacola", "targetname" );
	for (i=0;i<machine.size;i++)
	{
		if(machine[i].script_sound == "mx_speed_jingle")
		{
			machine[i] thread perks_a_cola_jingle();
			iprintlnbold("Speed_Run_Jingle");
		}
	}
}
start_revive_sounds()
{
	level waittill ("revive_on");
	
	iprintlnbold("Machine_ON!!!");
	
	machine = getstructarray( "perksacola", "targetname" );
	for (i=0;i<machine.size;i++)
	{
		if(machine[i].script_sound == "mx_revive_jingle")
		{
			machine[i] thread perks_a_cola_jingle();
			iprintlnbold("Revive_Run_Jingle");
		}
	}
}
start_doubletap_sounds()
{
	level waittill ("doubletap_on");
	
	iprintlnbold("Machine_ON!!!");
	
	machine = getstructarray( "perksacola", "targetname" );
	for (i=0;i<machine.size;i++)
	{
		if(machine[i].script_sound == "mx_doubletap_jingle")
		{
			machine[i] thread perks_a_cola_jingle();
			iprintlnbold("DT_Run_Jingle");
		}
	}
}
perks_a_cola_jingle()
{	
	lowhum = clientscripts\_audio::playloopat(0, "perks_machine_loop", self.origin);
	
	iprintlnbold("Low_HUM_IS_ON!");
	
	self thread play_random_broken_sounds();
	while(1)
	{
		wait(randomfloatrange(10, 20));
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
	//	playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound (0, "electrical_surge", self.origin);
	
		}
	}
	else
	{
		while(1)
		{
			wait(randomfloatrange(7, 18));
	//		playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound (0, "electrical_surge", self.origin);
		}
	}
}