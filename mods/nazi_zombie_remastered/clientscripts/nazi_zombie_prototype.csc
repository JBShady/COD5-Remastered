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

	clientscripts\nazi_zombie_prototype_fx::main();

//	thread clientscripts\_fx::fx_init(0);
	thread clientscripts\_audio::audio_init(0);

	thread clientscripts\nazi_zombie_prototype_amb::main();
	
	level thread player_dvar_init();

	level thread fov_fix();

	// This needs to be called after all systems have been registered.
	thread waitforclient(0);

	println("*** Client : zombie running...or is it chasing? Muhahahaha");
}

player_dvar_init()
{
	waitforclient( 0 );

	players = GetLocalPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread dvar_update();
	}
}

fov_fix()
{
	while(1)
	{
/*		level waittill( "fov_death", localClientNum ); // Wait for death
		fov = GetDvarFloat("cg_fov"); // Save FOV
		if(fov < 65)
		{
			fov = 65; // failsafe incase we save 40 as the fov from spectating
		}*/
		
		level waittill( "fov_reset", localClientNum ); // Wait for respawn
		real_fov = GetDvarFloat("cg_fov_settings"); 
		SetClientDvar("cg_fov", real_fov); 
	}
}

dvar_update() // if we happen to change the dummy setting VARS on the main menu and load in-game, the actual dvar will not reflect the dummy, which in these cases we hard-code in the dvar to update
{
	self endon("disconnect");

	if(GetDvarInt("cg_fov_settings") < 65 ) // failsafe
	{
		SetClientDvar("cg_fov", 65); 
		SetClientDvar("cg_fov_settings", 65); 
	}
	else
	{
		real_fov = GetDvarFloat("cg_fov_settings"); 
		SetClientDvar("cg_fov", real_fov); 
	}
	
	//if dvars do not exist, reset to default value just incase
/*	if(GetDvar("r_fog_settings") == "" )
	{
		SetClientDvar("r_fog_settings", 1);
	}
	if(GetDvar("r_filmUseTweaks_settings") == "" )
	{
		SetClientDvar("r_filmUseTweaks_settings", 0);
	}
	if(GetDvar("r_lodBiasRigid_settings") == "" )
	{
		SetClientDvar("r_lodBiasRigid_settings", 0);
	}
	if(GetDvar("r_lodBiasSkinned_settings") == "" )
	{
		SetClientDvar("r_lodBiasSkinned_settings", 0);
	}
*/
	for(;;)
	{
		if(GetDvarInt("r_fog_settings") == 0 )
		{
			SetClientDvar("r_fog", 0);
		}
		else if(GetDvarInt("r_fog_settings") == 1 )
		{
			SetClientDvar("r_fog", 1);
		}

		if(GetDvarInt("r_filmUseTweaks_settings") == 0 )
		{
			SetClientDvar("r_filmUseTweaks", 0);
		}
		else if(GetDvarInt("r_filmUseTweaks_settings") == 1 )
		{
			SetClientDvar("r_filmUseTweaks", 1);
		}

		if(GetDvarInt("r_lodBiasRigid_settings") == 0 )
		{
			SetClientDvar("r_lodBiasRigid", 0);
		}
		else if(GetDvarInt("r_lodBiasRigid_settings") == -200 )
		{
			SetClientDvar("r_lodBiasRigid", -200);
		}

		if(GetDvarInt("r_lodBiasSkinned_settings") == 0 )
		{
			SetClientDvar("r_lodBiasSkinned", 0);
		}
		else if(GetDvarInt("r_lodBiasSkinned_settings") == -200 ) 
		{
			SetClientDvar("r_lodBiasSkinned", -200);
		}

		// FAILSAFES FOR BETTER BOBBING
		if(GetDvarFloat("cg_bobWeaponMax") != 5 ) // weapon bob
		{
			SetClientDvar("cg_bobWeaponMax", 5);
		}
		if(GetDvar("bg_bobAmplitudeProne") != "0.08 0.04" ) // prone bob
		{
			SetClientDvar("bg_bobAmplitudeProne", "0.08 0.04");
		}

		// DIFFICULTY DVARS FOR DMG
		if(GetDvarFloat("bg_fallDamageMinHeight") != 150 ) // fall dmg
		{
			SetClientDvar("bg_fallDamageMinHeight", 150);
		}
		if(GetDvarInt("player_deathInvulnerableToProjectile") != 0 ) // failsafe
		{
			SetClientDvar("player_deathInvulnerableToProjectile", 0);
		}
		if(GetDvarInt("player_deathInvulnerableTime") != 0 ) // failsafe
		{
			SetClientDvar("player_deathInvulnerableTime", 0);
		}
		if(GetDvarInt("player_deathInvulnerableToMelee") != 0 ) // failsafe
		{
			SetClientDvar("player_deathInvulnerableToMelee", 0);
		}
	
		wait(0.05);

	}
} // now that we are in game, we can freely edit the actual correct dvar and thus no special code is needed. however, to make sure the game remembers this when we quit back to the menu, we make sure to always update our setting dummy var in the menu file


// The only flaw: If we try to manually edit a dvar on the main menu, depending on what your dummy dvar is set to, it may not do anything when you load in. But this is fine, all are accessible from settings there is no reason to use console