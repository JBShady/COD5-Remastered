// Test clientside script for mak

#include clientscripts\_utility;
#include clientscripts\_music;

zombie_monitor(clientNum)
{
	self endon("disconnect");
	self endon("zombie_off");
	
	while(1)
	{
		if(isdefined(self.zombifyFX))
		{
			playfx(clientNum, level._effect["zombie_grain"], self.origin);
		}
		realwait(0.1);		
	}
}

zombifyHandler(clientNum, newState, oldState)
{
	player = getlocalplayers()[clientNum];
		
	if(newState == "1")
	{
		if(!isdefined(player.zombifyFX))	// We're not already in zombie mode.
		{
			player.zombifyFX = 1;
			player thread zombie_monitor(clientNum);	// thread a monitor on it.
			println("Zombie effect on");
		}
	}
	else if(newState == "0")
	{
		if(isdefined(player.zombifyFX))		// We're already in zombie mode.
		{
				player.zombifyFX = undefined;
				self notify("zombie_off");	// kill the monitor thread
				println("Zombie effect off");
		}
	}
}

main()
{

	// _load!
	clientscripts\_load::main();

	println("Registering zombify");
	clientscripts\_utility::registerSystem("zombify", ::zombifyHandler);

	clientscripts\nazi_zombie_factory_teleporter::main();

	clientscripts\nazi_zombie_factory_fx::main();
	
	clientscripts\_zombiemode_tesla::init();

//	thread clientscripts\_fx::fx_init(0);
	thread clientscripts\_audio::audio_init(0);

	thread clientscripts\nazi_zombie_factory_amb::main();

	level._zombieCBFunc = clientscripts\_zombie_mode::zombie_eyes;
	
	// This needs to be called after all systems have been registered.
	thread waitforclient(0);

	println("*** Client : zombie running...or is it chasing? Muhahahaha");
	
}


