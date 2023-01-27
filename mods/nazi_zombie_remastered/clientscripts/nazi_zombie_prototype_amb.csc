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
 			setAmbientRoomReverb ("zombies","stoneroom", 1, 1);
	//************************************************************************************************
	//                                      ACTIVATE DEFAULT AMBIENT SETTINGS
	//************************************************************************************************

  activateAmbientPackage( 0, "zombies", 0 );
  activateAmbientRoom( 0, "zombies", 0 );



  declareMusicState("SPLASH_SCREEN"); //one shot dont transition until done
	musicAlias("mx_splash_screen", 12);	
	musicwaittilldone();
 

  declareMusicState("WAVE_1"); 
	musicAliasloop("mx_zombie_wave_1", 0, 4);	

  declareMusicState("eggs"); 
	musicAlias("mx_eggs", 0);

  declareMusicState("end_of_game");
	musicAlias("mx_game_over", 2);

	thread radio_init();

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