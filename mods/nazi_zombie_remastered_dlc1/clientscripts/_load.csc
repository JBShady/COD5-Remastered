// clientscripts/_load.csc

#include clientscripts\_utility;
#include clientscripts\_lights;
#include clientscripts\_music;
#include clientscripts\_busing;

levelNotifyHandler(clientNum, state, oldState)
{
	if(state != "")
	{
		level notify(state, clientNum);
	}
}

end_last_stand(clientNum)
{
	self waittill("lastStandEnd");
	
	println("Last stand ending for client " + clientNum);
	
	if(getlocalplayers().size == 1)	// No busing modifications in split screen.
	{
		setBusState("return_default");
	}
	
	realwait(0.7);
	
	println("Gasp.");
	PlayLocalSound(clientNum, "revive_gasp");
}

last_stand_thread(clientNum)
{
	self thread end_last_stand(clientNum);
	
	self endon("lastStandEnd");
	
	println("*** Client : Last stand starts on client " + clientNum);
	
	if( IsDefined( level.zombie_intermission ) && level.zombie_intermission )
	{
		setBusState("zombie_death");
	}
	else if(getlocalplayers().size == 1)
	{
		setBusState("last_stand_start");
		realWait(0.1);
		setBusState("last_stand_duration");
	}
	
	startVol = 0.5;
	maxVol = 1.0;
	
	startPause = 0.5;
	maxPause = 2.0;
	
	pause = startPause;
	vol = startVol;
	
	while(1)
	{
		id = PlayLocalSound(clientNum, "heart_beat");
		setSoundVolume(id, vol);
		
		realWait(pause);
		
		if(pause < maxPause)
		{
			pause *= 1.05;
			
			if(pause > maxPause)
			{
				pause = maxPause;
			}
		}
		
		if(vol < maxVol)
		{
			vol *= 1.05;
			
			if(vol > maxVol)
			{
				vol = maxVol;
			}
		}
	}
}

last_stand_monitor(clientNum, state, oldState)
{
	player = getlocalplayers()[clientNum];
	
	if(state == "1")
	{
		if(!level._laststand[clientNum])
		{
			player thread last_stand_thread(clientNum);
			level._laststand[clientNum] = true;
		}
	}
	else
	{
		if(level._laststand[clientNum])
		{
			player notify("lastStandEnd");
			level._laststand[clientNum] = false;
		}
	}
}

effects_init_thread(client, notify_name)
{
	level waittill(notify_name);
	println("*** Client : Starting effects system for client " + client);
	clientscripts\_fx::fx_init(client);
}

main()
{
	clientscripts\_utility_code::struct_class_init();
	
	clientscripts\_utility::registerSystem("levelNotify", ::levelNotifyHandler);
	clientscripts\_utility::registerSystem("lsm", ::last_stand_monitor);
	
	level.createFX_enabled = ( getdvar( "createfx" ) != "" );
	
	if( !isDefined( level.scr_anim ) )
		level.scr_anim[ 0 ][ 0 ] = 0;
	
	clientscripts\_global_fx::main();

	clientscripts\_busing::busInit();
	
	clientscripts\_ambientpackage::init();
	
	clientscripts\_music::music_init();
	
	clientscripts\_vehicle::init_vehicles();
	
	clientscripts\_collectibles::init();
	
	clientscripts\_russian_diary::init();
	
	for(i = 0; i < 4; i ++)
	{
		level thread effects_init_thread(i, "effects_init_"+i);
	}
	
	//clientscripts\_utility::init_exploders();
	
	// Setup global listen threads

	// rfo = red flashing overlay from _gameskill.gsc
	add_listen_thread( "rfo1", clientscripts\_utility::loop_sound_on_client, "breathing_hurt", 0.884, 0.6, "rfo2" ); // Changed min/max timing to fit closer to MP rhythm (min 0.784 + 0.1, max 0.8), but slightly rounded down for more intensity in zombies
	add_listen_thread( "rfo3", clientscripts\_utility::play_sound_on_client, "breathing_better" );
	add_listen_thread( "zi", ::zombie_intermission );

	level._load_done = 1;
}

zombie_intermission()
{
	level.zombie_intermission = true;
}
