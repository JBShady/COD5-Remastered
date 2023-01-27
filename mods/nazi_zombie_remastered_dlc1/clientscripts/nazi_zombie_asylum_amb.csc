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
 			setAmbientRoomReverb ("zombies","stoneroom", 1, 0.8);

        declareAmbientPackage( "bathroom" );
            addAmbientElement( "bathroom", "amb_spooky_2d", 5, 8, 300, 2000 );
			addAmbientElement( "bathroom", "amb_water_drips_rand", 0.2, 0.5, 50, 350 );

 		declareAmbientRoom( "bathroom" );
 			setAmbientRoomReverb ("bathroom","SMALLROOM", 0.7, 1);

        declareAmbientPackage( "outside" );
            addAmbientElement( "zombies", "amb_spooky_2d", 5, 8, 300, 2000 );

 		declareAmbientRoom( "outside" );
 			//setAmbientRoomTone( "outside", "bgt_base" );
 			setAmbientRoomReverb ("outside","forest", 1, 0.5);


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
	musicAliasloop("mx_zombie_wave_1", 0, 4);
	musicwaittilldone();

 declareMusicState ("round_end"); 
    musicAlias ("round_over", 2);
	musicwaittilldone();

  declareMusicState("WAVE_1"); 
	musicAliasloop("mx_zombie_wave_1", 4, 4);	

  declareMusicState("eggs"); 
	musicAlias("mx_eggs", 0);

  declareMusicState("mx_dog_round");
	musicAliasloop("mx_dog_wave", 2, 0.5);


  declareMusicState("end_of_game");
	musicAlias("mx_game_over", 2);



	thread start_lights();
	thread play_random_generator_sparks();
	
	

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

//MODIFIED for ASYLUM (playing off a different location)
radio_thread()
{
	level endon("eggs");
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

		level.radio_id = playsound(0, level.radio_songs[level.radio_index], (650, 88, 353));
	
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
	level waittill ("start_lights");
	realwait(2.0);
	array_thread(getstructarray( "electrical_circuit", "targetname" ), ::circuit_sound);
//	playsound(0,"turn_on", (0,0,0));	


	realwait (3.0);
	array_thread(getstructarray( "electrical_surge", "targetname" ), ::light_sound);
	array_thread(getstructarray( "low_buzz", "targetname" ), ::buzz_sound);
	array_thread(getstructarray( "oneshot_sparks_loop", "targetname"), ::play_oneshot_sparks_loop);
	array_thread(getstructarray( "light_ceiling", "targetname" ), ::light_sound);
	thread play_elec_room_sweets();


//	array_thread(getstructarray( "perksacola", "targetname" ), ::perks_a_cola_jingle);

	realwait(7);
	playsound(0,"turn_on", (0,0,0));
// Turns on 2D track for each player *move to client*
	playertrack = clientscripts\_audio::playloopat(0,"players_ambience", (0,0,0));
	realwait(2);
	playsound(0,"ann_vox_laugh_l", (-16, 184, 952));
//	array_thread(getstructarray( "electrical_room", "targetname" ), ::electrical_room_sound);
}
light_sound()
{

	realwait(randomfloatrange(1,4));
	playsound(0,"electrical_surge", self.origin);
	playfx (0, level._effect["electric_short_oneshot"], self.origin);
	realwait(randomfloatrange(1,2));
	e1 = clientscripts\_audio::playloopat(0,"light",self.origin);
	
	self run_sparks_loop();
}
run_sparks_loop()
{
	//fx_spark = level._effect["fx_elec_sparking_oneshot"];
	while(1)
	{

		realwait(randomfloatrange(4,15));
		if (randomfloatrange(0, 1) < 0.5)
		{
			playfx (0, level._effect["electric_short_oneshot"], self.origin);
			playsound(0,"electrical_surge", self.origin);
		}
		realwait(randomintrange(1,4));
	}
}
circuit_sound()
{
	realwait(1);
	playsound(0,"circuit", self.origin);
}
buzz_sound()
{
	lowbuzz = clientscripts\_audio::playloopat(0,"low_arc", self.origin);

}
play_oneshot_sparks_loop()
{
//	lightbuzz = clientscripts\_audio::playloopat(0, "arc_loop_light", self.origin);
	while(1)
	{
		realwait(randomfloatrange(0.25,0.5));
		playfx (0, level._effect["wire_sparks_oneshot"], self.origin);
		playsound(0,"arc_spark_light", self.origin);
	}

}
play_random_generator_sparks()
{
	level endon ("switch_flipped_generator");
		
	while(1)
	{
		
		realwait(randomfloatrange(0.45, 0.85));
		{
			playsound(0,"elec_arc_generator", (-672, -264, 296));			
		}
	}
}
play_elec_room_sweets()
{
	while(1)
	{
		realwait(randomfloatrange(0.25, 1));
		playsound(0, "elec_room_sweets", (-584, -392, 344));

	}
}
