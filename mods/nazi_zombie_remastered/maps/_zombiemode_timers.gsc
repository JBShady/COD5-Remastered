#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

init()
{
	if(getDvarInt( "cg_drawTimers" ) == 1)
	{
		level thread gameTimers();
		level thread wait_for_death();
	}

	if(getDvarInt( "cg_drawTrapTimers" ) == 1)
	{
		if(isDefined(level.remaster_mod) && level.remaster_mod == true)
		{
			level.first_time_zip = 15; // set an initial zip timer because mod makes first use shorter cooldown
			level.trap_time = 30;
			level.zip_time = 30;
			level.flogger_time = 45;
			level.trap_time_sumpf = 60;
		}
		else
		{
			level.trap_time = 25;
			level.zip_time = 40;
			level.first_time_zip = level.zip_time;
			level.flogger_time = 45;
			level.trap_time_sumpf = 90;
		}

		level thread trapTimerSetup();
		level thread wait_for_death_traps();
	}

	//level thread moveSpeedFix();
}

gameTimers()
{
	level endon( "end_game" ); // end on GAME OVER

	if ( !IsDefined( level.timer_hud_right ) ) // init hud array if doesnt exist
	{
		level.timer_hud_right = [];
	}

	level createTimerHUD(true); // create game timer

	flag_wait( "all_players_connected" ); 
   	level.start_time = GetTime() / 1000;

   	level.timer_hud_right[0] setTimerUp(0);

	while(1)
	{
		if(level.first_round == true)
		{
			wait(6.75); // adjustment for intro cinematic so timer is consistent with beginning time of other rounders + 0.5 adjustment for chalk delay
		}
		else
		{
			level.timer_hud_right[1] destroy_hud();
			level.timer_hud_right[1] = undefined;
			wait(0.5); // normal rounds, adjustment for delay in chalk function between round start and zombies can spawn
		}

		level notify("reset_round_time");

		//iprintlnbold("Start Timer");
		level.start_round_time = GetTime() / 1000;
		level createTimerHUD(); // create round timer
	   	level.timer_hud_right[1] setTimerUp(0); // this round timer will start exactly as the first zombie can spawn

	   	wait(1); // failsafe

		if( flag("dog_round" ) )
		{
			wait(7);
			while( level.dog_intermission )
			{
				wait(0.05);
			}
		}
		else
		{
			while( get_enemy_count() > 0 || level.zombie_total > 0 )
			{
				wait( 0.05 );
			}
		}

		//iprintlnbold("End timer");
		time = (GetTime() / 1000) - level.start_round_time;
		level thread pauseTimer(level.timer_hud_right[1], time); // ends as soon as last zombie is killed

		wait(level.zombie_vars["zombie_between_round_time"] / 1.25 );

		level.timer_hud_right[1] FadeOverTime( 2 );
		level.timer_hud_right[1].alpha = 0;


		level waittill("between_round_over"); // notified as soon as a round changes
	}
}

pauseTimer(hud, time)
{
	level endon("reset_round_time");
	
	hud.color =  (0.95294, 0.72156, 0.21176);
	while(1)
	{
		hud settimer(time - 0.1);
		wait(0.05);
	}
}

createTimerHUD(game_timer)
{
	timer = create_simple_hud();
	timer.x = -15; 
	timer.y = 10 + (level.timer_hud_right.size * 16); // as we have more timers it moves down 18 units each time
	timer.alignX = "right"; 
	timer.horzAlign = "right";
	timer.vertAlign = "top"; 
	
	if(isDefined(game_timer))
	{
		timer.label = "Game: "; 
	}
	else
	{
		timer.color =  (0.65, 0.7, 0.7);
		timer.label = "Round: "; 
	}
	timer.alpha = 1;
	timer.fontScale = 1.35; 
	timer.font = "default";

	level.timer_hud_right[level.timer_hud_right.size] = timer; // add individual timer to array
}

trapTimerSetup()
{
	flag_wait("all_players_connected");
	
	if (IsDefined(level.script) && level.script == "nazi_zombie_asylum")
	{
		trap_trigs = getentarray("gas_access", "targetname");

		trap_trigs[0] thread waitForTrap( level.trap_time, "South Balcony" ); 
		trap_trigs[1] thread waitForTrap( level.trap_time, "North Balcony" );

		//array_thread( getentarray("gas_access","targetname") , ::waitForTrap, level.trap_time );
	}
	else if (IsDefined(level.script) && level.script == "nazi_zombie_sumpf")
	{
		trap_trigs = getentarray("elec_trap_trig", "targetname");

		trap_trigs[0] thread waitForTrap( level.trap_time_sumpf, "Dr.'s Quarters" ); 
		trap_trigs[1] thread waitForTrap( level.trap_time_sumpf, "Fishing Hut" );
		trap_trigs[2] thread waitForTrap( level.trap_time_sumpf, "Comm Room" );
		trap_trigs[3] thread waitForTrap( level.trap_time_sumpf, "Storage" );

		array_thread (getentarray("pendulum_buy_trigger","targetname"),::waitForTrap, level.flogger_time, "Flogger" ); 

		array_thread (getentarray("zipline_buy_trigger", "targetname"),::waitForTrap, level.zip_time, "Zipline" ); 
	}
	else if (IsDefined(level.script) && level.script == "nazi_zombie_factory")
	{
		array_thread( getentarray("warehouse_electric_trap", "targetname") , ::waitForTrap, level.trap_time, "Warehouse" );
		array_thread( getentarray("wuen_electric_trap",	"targetname") , ::waitForTrap, level.trap_time, "Laboratory" );
		array_thread( getentarray("bridge_electric_trap", "targetname") , ::waitForTrap, level.trap_time, "Bridge" );
	}
}

createTrapTimerHUD(trap_index, label)
{
	timer = create_simple_hud();
	timer.x = 15; 
	timer.y = 10 + ((trap_index) * 16); // as we have more timers it moves down 18 units each time
	timer.alignX = "left"; 
	timer.horzAlign = "left";
	timer.vertAlign = "top"; 
	
	if(isDefined(label))
	{
		timer.label = label + ": "; 
	}
	else
	{
		timer.label = "Trap " + int(trap_index + 1) + ": ";  // default trap text
	}
	timer.alpha = 1;
	timer.fontScale = 1.35; 
	timer.font = "default";

	level.timer_hud_left[trap_index] = timer; // add individual timer to array
}

waitForTrap(cooldown, label, alt)
{
	level endon( "end_game" ); // end on GAME OVER

	while(1)
	{
		if(isDefined(label) && label == "Flogger")
		{
			self waittill("leverUp");
		}
		else if(isDefined(label) && label == "Zipline")
		{
			self waittill ("zipDone");
			if(isdefined(level.first_time_zip))
			{
				wait(1.5); // extra wait because first notify is buried behind various lever rotating waits
				cooldown = level.first_time_zip;
				level.first_time_zip = undefined;
			}
			else
			{
				cooldown = level.zip_time;
			}
		}
		else
		{
			self waittill("elec_done");
		}

		if ( !IsDefined( level.timer_hud_left ) ) // init hud array if doesnt exist
		{
			level.timer_hud_left = [];
		}
		if ( !IsDefined( level.free_trap_index ) ) // init hud array if doesnt exist
		{
			level.free_trap_index = [];
		}

		if (level.free_trap_index.size > 0)
		{
			lowest = level.free_trap_index[0];
		    for (i = 1; i < level.free_trap_index.size; i++)
		    {
		        if (level.free_trap_index[i] < lowest)
		            lowest = level.free_trap_index[i];
		    }
		    trap_index = lowest;
		    level.free_trap_index = array_remove(level.free_trap_index, trap_index); // Remove used free index
		}
		else
		{
		    trap_index = level.timer_hud_left.size;
		}

		level createTrapTimerHUD(trap_index, label); // create hud
   		level.timer_hud_left[trap_index] setTimer(cooldown);

   		wait(cooldown);

		level.timer_hud_left[trap_index] destroy_hud();
		level.timer_hud_left[trap_index] = undefined;
		level.free_trap_index[level.free_trap_index.size] = trap_index;

/*		j = 0;
		for( i = 0; i < level.timer_hud_left.size; i++ ) // redo hud 
		{
			if(isDefined(level.timer_hud_left[i]))
			{
				level.timer_hud_left[i].y = 10 + (j * 16);
				j++;
			}
		}*/

	}
}

wait_for_death() // pause timers on end
{
	level waittill("end_game");
	
	time = (GetTime() / 1000) - level.start_time;
	time_round = (GetTime() / 1000) - level.start_round_time;

	level thread pauseTimer(level.timer_hud_right[0], time); 

	if(get_enemy_count() > 0 || level.zombie_total > 0)
	{
		level thread pauseTimer(level.timer_hud_right[1], time_round);
	}

}

wait_for_death_traps() // clear trap timers on end
{
	level waittill("end_game");
	
	if(isDefined(level.timer_hud_left))
	{
		for( i = 0; i < level.timer_hud_left.size; i++ )
		{
			level.timer_hud_left[i] destroy_hud();
			level.timer_hud_left[i] = undefined;
		}		
	}

}

/*moveSpeedFix()
{
	level endon( "intermission" ); // end on GAME OVER

	for( ;; )
	{
		level waittill( "connected", player );

		player SetClientDvars( 
			"player_backSpeedScale", "1", 
			"player_strafeSpeedScale", "1");

	}

}*/

// TO DO
// add labels for verruckt traps
// test unique times are correct for all shi no numa timers
// test in co-op
// test on dogs

//ideas, powerup cycle
// box hits


// TO DO VANILLA
// need to verify all work on vanilla, specifically zipline first time