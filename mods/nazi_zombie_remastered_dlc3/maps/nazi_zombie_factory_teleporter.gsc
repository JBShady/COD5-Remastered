#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

//-------------------------------------------------------------------------------
// setup and kick off think functions
//-------------------------------------------------------------------------------
teleporter_init()
{
	level.teleport = [];
	level.active_links = 0;
	level.countdown = 0;

	level.teleport_delay = 2;
	level.teleport_cost = 1500;
	level.teleport_cooldown = 5;
	level.is_cooldown = false;
	level.active_timer = -1;
	level.teleport_time = 0;

	flag_init( "teleporter_pad_link_1" );
	flag_init( "teleporter_pad_link_2" );
	flag_init( "teleporter_pad_link_3" );

	wait_for_all_players();

	// Get the Pad triggers
	for ( i=0; i<3; i++ )
	{
		trig = GetEnt( "trigger_teleport_pad_" + i, "targetname");
		if ( IsDefined(trig) )
		{
			level.teleporter_pad_trig[i] = trig;
		}
	}

	thread teleport_pad_think( 0 );
	thread teleport_pad_think( 1 );
	thread teleport_pad_think( 2 );
	thread teleport_core_think();

	thread start_black_room_fx();
	thread init_pack_door();
	
	SetDvar( "factoryAftereffectOverride", "-1" );
	
	packapunch_see = getent( "packapunch_see", "targetname" );
	if(isdefined( packapunch_see ) )
	{
		packapunch_see thread play_packa_see_vox();
	}
	
	level.teleport_ae_funcs = [];
	
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_fov;
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_shellshock;
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_shellshock_electric;
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_bw_vision;
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_red_vision;
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_flashy_vision;
	level.teleport_ae_funcs[level.teleport_ae_funcs.size] = maps\nazi_zombie_factory_teleporter::teleport_aftereffect_flare_vision;
}

//-------------------------------------------------------------------------------
// sets up up the pack a punch door
//-------------------------------------------------------------------------------
init_pack_door()
{
	door = getent( "pack_door", "targetname" );

	door movez( -50, 0.05, 0 );
	wait(1.0);

	flag_wait( "all_players_connected" );

	door movez(  50, 1.5, 0 );
	door playsound( "packa_door_1" );

	// Open slightly the first two times
	flag_wait( "teleporter_pad_link_1" );
	door movez( -35, 1.5, 1 );
	door playsound( "packa_door_2" );
	door thread packa_door_reminder();
	wait(2);

	// Second link
	flag_wait( "teleporter_pad_link_2" );
	door movez( -25, 1.5, 1 );
	door playsound( "packa_door_2" );
	wait(2);

	// Final Link
	flag_wait( "teleporter_pad_link_3" );

	door movez( -60, 1.5, 1 );
	door playsound( "packa_door_2" );

	//door rotateyaw( -90, 1.5, 1 );

	clip = getentarray( "pack_door_clip", "targetname" );
	for ( i = 0; i < clip.size; i++ )
	{
		clip[i] connectpaths();
		clip[i] delete();
	}
}

//-------------------------------------------------------------------------------
// handles activating and deactivating pads for cool down
//-------------------------------------------------------------------------------
pad_manager()
{
	for ( i = 0; i < level.teleporter_pad_trig.size; i++ )
	{
		// shut off the pads
		if (!isDefined(level.teleporters_are_broken) ) 
		{
			if( level.teleporter_pad_trig[i].teleport_active == true ) // extra check so we only put cooldown message if the tele is actually active, this is for cases where player tries to activate link 2 or 3 right after link 1
			{
				level.teleporter_pad_trig[i] sethintstring( &"REMASTERED_ZOMBIE_TELEPORT_COOLDOWN" );
			}
			level.teleporter_pad_trig[i] teleport_trigger_invisible( false );
		}
	}

	level.is_cooldown = true;
	wait( level.teleport_cooldown );
	level.is_cooldown = false;

	for ( i = 0; i < level.teleporter_pad_trig.size; i++ )
	{
		if (isDefined(level.teleporters_are_broken) && level.teleporters_are_broken == true)
		{
			level.teleporter_pad_trig[i] teleport_trigger_invisible( false );
			level.teleporter_pad_trig[i] sethintstring( &"REMASTERED_ZOMBIE_LINK_INTERRUPTED" );
		}
		else if ( level.teleporter_pad_trig[i].teleport_active )
		{
			level.teleporter_pad_trig[i] sethintstring( &"ZOMBIE_TELEPORT_TO_CORE" );
		}
		else
		{
			level.teleporter_pad_trig[i] sethintstring( &"ZOMBIE_LINK_TPAD" );
		}
//		level.teleporter_pad_trig[i] teleport_trigger_invisible( false );
	}
}

//-------------------------------------------------------------------------------
// staggers the black room fx
//-------------------------------------------------------------------------------
start_black_room_fx()
{
	for ( i = 901; i <= 904; i++ )
	{
		wait( 1 );
		exploder( i );
	}
}

//-------------------------------------------------------------------------------
// handles turning on the pad and waiting for link
//-------------------------------------------------------------------------------
teleport_pad_think( index )
{
	tele_help = getent( "tele_help_" + index, "targetname" );
	if(isdefined( tele_help ) )
	{
		tele_help thread play_tele_help_vox();
	}
	
	active = false;
	
	// init the pad
	level.teleport[index] = "waiting";

	trigger = level.teleporter_pad_trig[ index ];

	trigger setcursorhint( "HINT_NOICON" );
	trigger sethintstring( &"ZOMBIE_FLAMES_UNAVAILABLE" );

	flag_wait( "electricity_on" );

	trigger sethintstring( &"ZOMBIE_POWER_UP_TPAD" );
	trigger.teleport_active = false;

	if ( isdefined( trigger ) )
	{
		while ( !active )
		{
			trigger waittill( "trigger" );

			if ( level.active_links < 3 )
			{
				trigger_core = getent( "trigger_teleport_core", "targetname" );
				trigger_core teleport_trigger_invisible( false );
			}

			// when one starts the others disabled
			for ( i=0; i<level.teleporter_pad_trig.size; i++ )
			{
				level.teleporter_pad_trig[ i ] teleport_trigger_invisible( true );
			}
			level.teleport[index] = "timer_on";
			
			// start the countdown back to the core
			trigger thread teleport_pad_countdown( index, 30 );
			teleporter_vo( "countdown", trigger );

			// wait for the countdown
			while ( level.teleport[index] == "timer_on" )
			{
				wait( .05 );
			}

			// core was activated in time
			if ( level.teleport[index] == "active" )
			{
				active = true;
				ClientNotify( "pw" + index );	// pad wire #
											
				//AUDIO
				ClientNotify( "tp" + index );	// Teleporter #

				// MM - Auto teleport the first time
				teleporter_wire_wait( index );

//				trigger teleport_trigger_invisible( true );
				trigger thread player_teleporting( index );
			}
			else
			{
				// Reenable triggers
 				for ( i=0; i<level.teleporter_pad_trig.size; i++ )
 				{
 					level.teleporter_pad_trig[ i ] teleport_trigger_invisible( false );
 				}
			}
			wait( .05 );
		}

		trigger thread teleport_pad_active_think( index );
	}
}

//-------------------------------------------------------------------------------
// updates the teleport pad timer
//-------------------------------------------------------------------------------
teleport_pad_countdown( index, time )
{
	self endon( "stop_countdown" );

//	iprintlnbold( &"ZOMBIE_START_TPAD" );

	if ( level.active_timer < 0 )
	{
		level.active_timer = index;
	}

	level.countdown++;

	//AUDIO
	ClientNotify( "pac" + index );
	ClientNotify( "TRf" );	// Teleporter receiver map light flash

	// start timer for all players
	//	Add a second for VO sync
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread maps\_zombiemode_timer::start_timer( time+1, "stop_countdown" );
	}
	wait( time+1 );

	if ( level.active_timer == index )
	{
		level.active_timer = -1;
	}

	// ran out of time to activate teleporter
	level.teleport[index] = "timer_off";
//	iprintlnbold( "out of time" );
	ClientNotify( "TRs" );	// Stop flashing the receiver map light

	level.countdown--;
}

//-------------------------------------------------------------------------------
// handles teleporting players when triggered
//-------------------------------------------------------------------------------
teleport_pad_active_think( index )
{
//	self endon( "player_teleported" );

	// link established, can be used to teleport
	self setcursorhint( "HINT_NOICON" );
	self.teleport_active = true;

	user = undefined;

//	self sethintstring( &"ZOMBIE_TELEPORT_TO_CORE" );
//	self teleport_trigger_invisible( false );

	while ( 1 )
	{
		self waittill( "trigger", user );
		if ( is_player_valid( user ) && user.score >= level.teleport_cost && !level.is_cooldown && !isdefined(level.teleporters_are_broken) )
		{
			for ( i = 0; i < level.teleporter_pad_trig.size; i++ )
			{
				level.teleporter_pad_trig[i] teleport_trigger_invisible( true );
			}

			user maps\_zombiemode_score::minus_to_player_score( level.teleport_cost );
		
			// Non-threaded so the trigger doesn't activate before the cooldown
			if(isDefined(level.current_limit) && level.current_limit == false)
			{
				self player_teleporting_fail( index );

			}
			else
			{
				self player_teleporting( index, user );
			}
		}
		else if(!level.is_cooldown && !isdefined(level.teleporters_are_broken) )
		{
			play_sound_on_ent( "no_purchase" );
		}
		else if(isDefined(level.teleporters_are_broken) && level.teleporters_are_broken == true)
		{
			user thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog(); 
		}
	}
}
player_teleporting_fail( index )
{
	level.panel_trigger_sync delete(); // Remove the generic "limit disabled" hint, as we will now switch to emergency hint w/ light

	level.teleporters_are_broken = true;

	// begin the teleport
	// add 3rd person fx
	teleport_pad_start_exploder( index );

	// play startup fx at the core
	exploder( 105 );

	//AUDIO
	ClientNotify( "tpw" + index ); 

	// start fps fx
	self thread teleport_pad_player_fx( level.teleport_delay );
	
	// wait a bit
	wait( level.teleport_delay );

	// end fps fx
	self notify( "fx_done" );

	location = undefined;

	switch ( index )
	{
	case 0:
		location = (1262.5, 1274.7, 200.125);
		break;

	case 1:
		location = (297.5, -3194.4, 189.125);
		break;

	case 2:
		location = (-1783.8, -1109, 231.125);
		break;
	}

	playsoundatposition("teleporter_fail", location + (0,0,10) );

	playFx(level._effect["teleporter_smoke_fail"], location + (0,0,3) );
	
	stop_exploder( 101 );

	stop_exploder( 102 );

	stop_exploder( 103 );

	stop_exploder( 104 );

	ClientNotify( "turn_off_sounds_lights" ); // turns off generators/tele sounds so they seem "broken"

	if ( level.is_cooldown == false )
	{
		self thread pad_manager(); 
	}

	players = get_players(); 
	j = undefined;
	for( i = 0; i < players.size; i++ ) 
	{
		if(Distance2D(players[i].origin, self.origin) < 88)
		{
			if( !players[i] maps\_laststand::player_is_in_laststand() )
			{
				players[i] stopShellshock();
				if(!players[i] hasperk("specialty_armorvest") || players[i].health - 100 < 1)
				{
					radiusdamage(players[i].origin,10,10,10);
				}
				else
				{
					players[i] dodamage(10, players[i].origin);
				}
				players[i] shellshock( "electrocution", 2.5 );

				j = i; // lets grab the last player we looped through who was within the radius for extra vox response
			}
		}
	}

	level thread continue_player_teleporting_fail(players[j]);
}

continue_player_teleporting_fail(player)
{
	wait(1);
	index = maps\_zombiemode_weapons::get_player_index( player );
	plr = "plr_" + index + "_";
	player thread create_and_play_dialog( plr, "vox_gen_respond_neg", 0.25 ); // so we can sometimes get a neg response

	level thread maps\nazi_zombie_factory::mainframe_panel_d();

	fx_light = spawn("script_model", (-177, 295.1, 144));
	fx_light setModel("tag_origin");
	playFxOnTag(level._effect["zapper_light_notready"], fx_light, "tag_origin");

	level waittill ( "between_round_over" ); // when we fail, we wait till we get to the next round over before cleaning up panel
	
	fx_light delete();
	level.panel_trigger_failsafe delete();

	level thread maps\nazi_zombie_factory::mainframe_panel_e();

	wait(randomintrange(60,240));

	players = get_players(); 
	for( i = 0; i < players.size; i++ ) 
	{
		if(players[i] hasweapon("zombie_item_journal") && players[i].has_special_weap == "zombie_item_journal" )
		{
			if(players[i] GetCurrentWeapon() == "zombie_item_journal" )
			{
				primaryWeapons = players[i] GetWeaponsListPrimaries();
				if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
				{
					players[i] SwitchToWeapon( primaryWeapons[0] );
				}	
			}
			players[i] takeweapon("zombie_item_journal"); 
			players[i] setactionslot(1,""); 
			players[i].has_special_weap = undefined;
			players[i] playlocalsound("gren_pickup_plr");
		}

	}

}
shout_fire_if_tesla(user)
{
	players = getplayers();

	if(randomintrange(0,4) == 0 ) // 25% chance reminder to "fire" 
	{
		for ( i = 0; i < players.size; i++ )
		{	
			if(players[i] getCurrentWeapon() == "tesla_gun_upgraded" ) // if someone is holding correct wep , character who pressed teleport shouts to fire
			{
				index = maps\_zombiemode_weapons::get_player_index(user);
				plr = "plr_" + index + "_";
				user thread create_and_play_dialog( plr, "vox_gen_fire", 0.1 );
			}
		}
	}
}
//-------------------------------------------------------------------------------
// handles moving the players and fx, etc...moved out so it can be threaded
//-------------------------------------------------------------------------------
player_teleporting( index, user )
{
	if(isDefined(level.teleporting_out_ready) && level.teleporting_out_ready == true)
	{
		level notify("teleporting_out");
		level thread shout_fire_if_tesla(user);
	}

	time_since_last_teleport = GetTime() - level.teleport_time;

	// begin the teleport
	// add 3rd person fx
	teleport_pad_start_exploder( index );

	// play startup fx at the core
	exploder( 105 );

	//AUDIO
	ClientNotify( "tpw" + index );

	// start fps fx
	self thread teleport_pad_player_fx( level.teleport_delay );
	
	//AUDIO
	self thread teleport_2d_audio();

	// Activate the TP zombie kill effect
	self thread teleport_nuke( 20, 300);	// Max 20 zombies and range 300

	// wait a bit
	wait( level.teleport_delay );

	// end fps fx
	self notify( "fx_done" );

	// add 3rd person beam fx
	teleport_pad_end_exploder( index );

	// teleport the players
	self teleport_players();

	//AUDIO
	ClientNotify( "tpc" + index );

	// only need this if it's not cooling down
	if ( level.is_cooldown == false )
	{
		self thread pad_manager();
	}

	// Now spawn a powerup goodie after a few seconds
	wait( 2.0 );
	ss = getstruct( "teleporter_powerup", "targetname" );
	if ( IsDefined( ss ) )
	{
		ss thread maps\_zombiemode_powerups::special_powerup_drop(ss.origin);
	}

	// Special for teleporting too much.  The Dogs attack!
	if ( time_since_last_teleport < 60000 && level.active_links == 3 && level.round_number > 20 )
	{
		level thread maps\_zombiemode_dogs::special_dog_spawn( undefined, 4, true );
		//iprintlnbold( "Samantha Sez: No Powerup For You!" );
		//thread play_sound_2d( "sam_nospawn" );
	}
	level.teleport_time = GetTime();
}

//-------------------------------------------------------------------------------
// pad fx for the start of the teleport
//-------------------------------------------------------------------------------
teleport_pad_start_exploder( index )
{
	switch ( index )
	{
	case 0:
		exploder( 202 );
		break;

	case 1:
		exploder( 302 );
		break;

	case 2:
		exploder( 402 );
		break;
	}
}

//-------------------------------------------------------------------------------
// pad fx for the end of the teleport
//-------------------------------------------------------------------------------
teleport_pad_end_exploder( index )
{
	switch ( index )
	{
	case 0:
		exploder( 201 );
		break;

	case 1:
		exploder( 301 );
		break;

	case 2:
		exploder( 401 );
		break;
	}
}

//-------------------------------------------------------------------------------
// used to enable / disable the pad use trigger for players
//-------------------------------------------------------------------------------
teleport_trigger_invisible( enable )
{
	players = getplayers();

	for ( i = 0; i < players.size; i++ )
	{
		if ( isdefined( players[i] ) )
		{
			self SetInvisibleToPlayer( players[i], enable );
		}
	}
}

//-------------------------------------------------------------------------------
// checks if player is within radius of the teleport pad
//-------------------------------------------------------------------------------
player_is_near_pad( player )
{
	radius = 88;
	scale_factor = 2;

	dist = Distance2D( player.origin, self.origin );
	dist_touching = radius * scale_factor;

	if ( dist < dist_touching )
	{
		return true;
	}

	return false;
}


//-------------------------------------------------------------------------------
// this is the 1st person effect seen when touching the teleport pad
//-------------------------------------------------------------------------------
teleport_pad_player_fx( delay )
{
	self endon( "fx_done" );

	while ( 1 )
	{
		players = getplayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( isdefined( players[i] ) )
			{
				if ( self player_is_near_pad( players[i] ) )
				{
					players[i] SetTransported( delay );
				}
				else
				{
					players[i] SetTransported( 0 );
				}
			}
		}
		wait ( .05 );
	}
}

//-------------------------------------------------------------------------------
// send players back to the core
//-------------------------------------------------------------------------------
teleport_players()
{
	player_radius = 16;

	players = getplayers();

	core_pos = [];
	occupied = [];
	image_room = [];
	players_touching = [];		// the players that will actually be teleported

	player_idx = 0;

	prone_offset = (0, 0, 49);
	crouch_offset = (0, 0, 20);
	stand_offset = (0, 0, 0);

	// send players to a black room to flash images for a few seconds
	for ( i = 0; i < 4; i++ )
	{
		core_pos[i] = getent( "origin_teleport_player_" + i, "targetname" );
		occupied[i] = false;
		image_room[i] = getent( "teleport_room_" + i, "targetname" );

		if ( isdefined( players[i] ) )
		{
			players[i] settransported( 0 );
			
			if ( self player_is_near_pad( players[i] ) )
			{
				players_touching[player_idx] = i;
				player_idx++;

				if( isDefined(level.teleporting_out_ready) && level.teleporting_out_ready == true )
				{
					if((players_touching.size) == getplayers().size)
					{
						level.all_players_teleported = true;
					}
				}
				if ( isdefined( image_room[i] ) && !players[i] maps\_laststand::player_is_in_laststand() )
				{
					players[i] disableOffhandWeapons();
					players[i] disableweapons();
					if( players[i] getstance() == "prone" )
					{
						desired_origin = image_room[i].origin + prone_offset;
					}
					else if( players[i] getstance() == "crouch" )
					{
						desired_origin = image_room[i].origin + crouch_offset;
					}
					else
					{
						desired_origin = image_room[i].origin + stand_offset;
					}
					
					players[i].teleport_origin = spawn( "script_origin", players[i].origin );
					players[i].teleport_origin.angles = players[i].angles;
					players[i] linkto( players[i].teleport_origin );
					players[i].teleport_origin.origin = desired_origin;
					players[i] FreezeControls( true );
					wait_network_frame();

					if( IsDefined( players[i] ) )
					{
						setClientSysState( "levelNotify", "black_box_start", players[i] );
						players[i].teleport_origin.angles = image_room[i].angles;
					}
				}
			}
		}
	}

	wait( 2 );

	// Nuke anything at the core
	core = GetEnt( "trigger_teleport_core", "targetname" );
	core thread teleport_nuke( undefined, 300);	// Max any zombies at the pad range 300

	// check if any players are standing on top of core teleport positions
	for ( i = 0; i < players.size; i++ )
	{
		if ( isdefined( players[i] ) )
		{
			for ( j = 0; j < 4; j++ )
			{
				if ( !occupied[j] )
				{
					dist = Distance2D( core_pos[j].origin, players[i].origin );
					if ( dist < player_radius )
					{
						occupied[j] = true;
					}
				}
			}
			setClientSysState( "levelNotify", "black_box_end", players[i] );
		}
	}

	wait_network_frame();

	// move players to the core
	for ( i = 0; i < players_touching.size; i++ )
	{
		player_idx = players_touching[i];
		player = players[player_idx];

		if ( !IsDefined( player ) )
		{
			continue;
		}

		// find a free space at the core
		slot = i;
		start = 0;
		while ( occupied[slot] && start < 4 )
		{
			start++;
			slot++;
			if ( slot >= 4 )
			{
				slot = 0;
			}
		}
		occupied[slot] = true;
		pos_name = "origin_teleport_player_" + slot;
		teleport_core_pos = getent( pos_name, "targetname" );

		player unlink();

		assert( IsDefined( player.teleport_origin ) );
		player.teleport_origin delete();
		player.teleport_origin = undefined;

		player enableweapons();
		player enableoffhandweapons();
		player setorigin( core_pos[slot].origin );
		player setplayerangles( core_pos[slot].angles );
		player FreezeControls( false );
		player thread teleport_aftereffects();
		
		vox_rand = randomintrange(1,101);  //RARE: Sets up rare post-teleport line
		
		if( vox_rand <= 5 )
		{
			player teleporter_vo( "vox_tele_sick_rare" );
			//iprintlnbold( "Hey, this is the random teleport sickness line!" );
		}
		else
		{
			player teleporter_vo( "vox_tele_sick" );
		}
		
		player achievement_notify( "DLC3_ZOMBIE_FIVE_TELEPORTS" );
	}

	// play beam fx at the core
	exploder( 106 );
}

//-------------------------------------------------------------------------------
// updates the hint string when countdown is started and expired
//-------------------------------------------------------------------------------
teleport_core_hint_update()
{
	self setcursorhint( "HINT_NOICON" );

	while ( 1 )
	{
		// can't use teleporters until power is on
		if ( !flag( "electricity_on" ) )
		{
			self sethintstring( &"ZOMBIE_FLAMES_UNAVAILABLE" );
		}
		else if ( teleport_pads_are_active() )
		{
			self sethintstring( &"ZOMBIE_LINK_TPAD" );
		}
		else if ( level.active_links == 0 )
		{
			self sethintstring( &"ZOMBIE_INACTIVE_TPAD" );
		}
		else
		{
			self sethintstring( "" );
		}

		wait( .05 );
	}
}

//-------------------------------------------------------------------------------
// establishes the link between teleporter pads and the core
//-------------------------------------------------------------------------------
teleport_core_think()
{
	trigger = getent( "trigger_teleport_core", "targetname" );
	if ( isdefined( trigger ) )
	{
		trigger thread teleport_core_hint_update();

		// disable teleporters to power is turned on
		flag_wait( "electricity_on" );

		while ( 1 )
		{
			if ( teleport_pads_are_active() )
			{
				trigger waittill( "trigger" );

//				trigger teleport_trigger_invisible( true );

//				iprintlnbold( &"ZOMBIE_LINK_ACTIVE" );

				// link the activated pads
				for ( i = 0; i < level.teleport.size; i++ )
				{
					if ( isdefined( level.teleport[i] ) )
					{
						if ( level.teleport[i] == "timer_on" )
						{
							level.teleport[i] = "active";
							level.active_links++;
							flag_set( "teleporter_pad_link_"+level.active_links );
							
							//AUDIO
							ClientNotify( "scd" + i );

							teleport_core_start_exploder( i );

							// check for all teleporters active
							if ( level.active_links == 3 )
							{
								exploder( 101 );
								exploder( 169 ); // seperated generator and mainframe fx so that when we re-nable gen for egg we dont spam mainframe pap fx
								ClientNotify( "pap1" );	// Pack-A-Punch door on
								teleporter_vo( "linkall", trigger );
								if( level.round_number <= 7 )
								{
									achievement_notify( "DLC3_ZOMBIE_FAST_LINK" );
								}
								Earthquake( 0.3, 2.0, trigger.origin, 3700 );
							}

							// stop the countdown for the teleport pad
							pad = "trigger_teleport_pad_" + i;
							trigger_pad = getent( pad, "targetname" );
							trigger_pad stop_countdown();
							ClientNotify( "TRs" );	// Stop flashing the receiver map light
							level.active_timer = -1;
						}
					}
				}
			}

			wait( .05 );
		}
	}
}

stop_countdown()
{
	self notify( "stop_countdown" );
	players = get_players();
	
	for( i = 0; i < players.size; i++ )
	{
		players[i] notify( "stop_countdown" );
	}
}

//-------------------------------------------------------------------------------
// checks if any of the teleporter pads are counting down
//-------------------------------------------------------------------------------
teleport_pads_are_active()
{
	// have any pads started?
	if ( isdefined( level.teleport ) )
	{
		for ( i = 0; i < level.teleport.size; i++ )
		{
			if ( isdefined( level.teleport[i] ) )
			{
				if ( level.teleport[i] == "timer_on" )
				{
					return true;
				}
			}
		}
	}

	return false;
}

//-------------------------------------------------------------------------------
// starts the exploder for the teleport pad fx
//-------------------------------------------------------------------------------
teleport_core_start_exploder( index )
{
	switch ( index )
	{
	case 0:
		exploder( 102 );
		break;

	case 1:
		exploder( 103 );
		break;

	case 2:
		exploder( 104 );
		break;
	}
}

teleport_2d_audio()
{
	self endon( "fx_done" );

	while ( 1 )
	{
		players = getplayers();
		
		wait(1.7);
		
		for ( i = 0; i < players.size; i++ )
		{
			if ( isdefined( players[i] ) )
			{
				if ( self player_is_near_pad( players[i] ) )
				{
					setClientSysState("levelNotify", "t2d", players[i]);	
				}
			}
		}
	}
}


// kill anything near the pad
teleport_nuke( max_zombies, range )
{
	zombies = getaispeciesarray("axis");

	zombies = get_array_of_closest( self.origin, zombies, undefined, max_zombies, range );

	for (i = 0; i < zombies.size; i++)
	{
		wait (randomfloatrange(0.2, 0.3));
		if( !IsDefined( zombies[i] ) )
		{
			continue;
		}

		if( is_magic_bullet_shield_enabled( zombies[i] ) )
		{
			continue;
		}

		if( !( zombies[i] enemy_is_dog() ) )
		{
			zombies[i] maps\_zombiemode_spawner::zombie_head_gib();
		}

		zombies[i] dodamage( 10000, zombies[i].origin );
		playsoundatposition( "nuked", zombies[i].origin );
	}
}

teleporter_vo( tele_vo_type, location )
{
	if( !isdefined( location ))
	{
		self thread teleporter_vo_play( tele_vo_type, 2 );
	}
	else
	{
		players = get_players();
		for (i = 0; i < players.size; i++)
		{
			if (distance (players[i].origin, location.origin) < 64)
			{
				switch ( tele_vo_type )
				{
					case "linkall":
						players[i] thread teleporter_vo_play( "vox_tele_linkall" );
						break;
					case "countdown":
						players[i] thread teleporter_vo_play( "vox_tele_count", 3 );
						break;
				}
			}
		}
	}
}

teleporter_vo_play( vox_type, pre_wait )
{
	if(!isdefined( pre_wait ))
	{
		pre_wait = 0;
	}
	index = maps\_zombiemode_weapons::get_player_index(self);
	plr = "plr_" + index + "_";
	wait(pre_wait);
	self create_and_play_dialog( plr, vox_type, 0.25 );
}

play_tele_help_vox()
{
	level endon( "tele_help_end" );
	
	while(1)
	{
		self waittill("trigger", who);
		
		if( flag( "electricity_on" ) && level.active_links < 3 )
		{
			who thread teleporter_vo_play( "vox_tele_help" );	
			level notify( "tele_help_end" );
		}
		
		while(IsDefined (who) && (who) IsTouching (self))
		{
			wait(0.1);
		}
	}
}

play_packa_see_vox()
{
	wait(10);
	
	if( !flag( "teleporter_pad_link_3" ) )
	{
		self waittill("trigger", who);
		if ( level.active_links < 3 )
		{
			who thread teleporter_vo_play( "vox_perk_packa_see" );
		}
	}
}


//	
//	This should match the perk_wire_fx_client function
//	waits for the effect to travel along the wire
teleporter_wire_wait( index )
{
	targ = getstruct( "pad_"+index+"_wire" ,"targetname");
	if ( !IsDefined( targ ) )
	{
		return;
	}

	while(isDefined(targ))
	{
		if(isDefined(targ.target))
		{
			target = getstruct(targ.target,"targetname");
			wait( 0.1 );

			targ = target;
		}
		else
		{
			break;
		}		
	}
}

// Teleporter Aftereffects
teleport_aftereffects()
{
	if( GetDvar( "factoryAftereffectOverride" ) == "-1" )
	{
		self thread [[ level.teleport_ae_funcs[RandomInt(level.teleport_ae_funcs.size)] ]]();
	}
	else
	{
		self thread [[ level.teleport_ae_funcs[int(GetDvar( "factoryAftereffectOverride" ))] ]]();
	}
}

teleport_aftereffect_shellshock()
{
	//iprintln( "*** Explosion Aftereffect***\n" );
	self shellshock( "explosion", 4 );
}

teleport_aftereffect_shellshock_electric()
{
	//iprintln( "***Electric Aftereffect***\n" );
	self shellshock( "electrocution", 4 );
}

// tae indicates to Clientscripts that a teleporter aftereffect should start

teleport_aftereffect_fov()
{
	setClientSysState( "levelNotify", "tae", self );
}

teleport_aftereffect_bw_vision( localClientNum )
{
	setClientSysState( "levelNotify", "tae", self );
}

teleport_aftereffect_red_vision( localClientNum )
{
	setClientSysState( "levelNotify", "tae", self );
}

teleport_aftereffect_flashy_vision( localClientNum )
{
	setClientSysState( "levelNotify", "tae", self );
}

teleport_aftereffect_flare_vision( localClientNum )
{
	setClientSysState( "levelNotify", "tae", self );
}

packa_door_reminder()
{
	while( !flag( "teleporter_pad_link_3" ) )
	{
		rand = randomintrange(4,16);
		self playsound( "packa_door_hitch" );
		wait(rand);
	}
}
