#include maps\_utility; 
#include common_scripts\utility;

/#

init()
{
	SetDvar( "zombie_devgui", "" );
	SetDvar( "scr_zombie_round", "1" );

	level thread zombie_devgui_think();
}


zombie_devgui_think()
{
	for ( ;; )
	{
		cmd = GetDvar( "zombie_devgui" );

		switch ( cmd )
		{
		case "money":
			array_thread( get_players(), ::zombie_devgui_give_money );	
			break;

		case "power":
			zombie_devgui_give_power();
			break;

		case "specialty_armorvest":
		case "specialty_quickrevive":
		case "specialty_fastreload":
		case "specialty_rof":
			zombie_devgui_give_perk( cmd );
			break;

		case "nuke":
		case "insta_kill":
		case "double_points":
		case "full_ammo":
			zombie_devgui_give_powerup( cmd );
			break;

		case "round":
			zombie_devgui_goto_round( GetDvarInt( "scr_zombie_round" ) );
			break;
		case "round_next":
			zombie_devgui_goto_round( level.round_number + 1 );
			break;
		case "round_prev":
			zombie_devgui_goto_round( level.round_number - 1 );
			break;

		case "chest_move":
			if ( IsDefined( level.chest_accessed ) )
			{
				iprintln( "Teddy bear will spawn on next open" );
				level.chest_accessed = 100;
			}
			break;
		}
	
		SetDvar( "zombie_devgui", "" );
		wait( 0.5 );
	}
}


zombie_devgui_give_money()
{
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );

	self.score += 100000; 
	self.score_total += 100000;
	
	self maps\_zombiemode_score::set_player_score_hud(); 
}


zombie_devgui_give_power()
{
	trigger = GetEnt( "use_master_switch", "targetname" );
	player = get_players()[0];

	if ( !IsDefined( trigger ) )
	{
		iprintln( "Map does not have power switch trigger or power is already on" );
		return;
	}

	iprintln( "Activating power" );
	trigger notify( "trigger", player );
}


zombie_devgui_give_perk( perk )
{
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	player = get_players()[0];

	if ( vending_triggers.size < 1 )
	{
		iprintln( "Map does not contain any perks machines" );
		return;
	}

	for ( i = 0; i < vending_triggers.size; i++ )
	{
		if ( vending_triggers[i].script_noteworthy == perk )
		{
			vending_triggers[i] notify( "trigger", player );
			return;
		}
	}

	iprintln( "Map does not contain perks machine with perk: " + perk );
}


zombie_devgui_give_powerup( powerup_name )
{
	player = get_players()[0];
	found = false;

	for ( i = 0; i < level.zombie_powerup_array.size; i++ )
	{
		if ( level.zombie_powerup_array[i] == powerup_name )
		{
			level.zombie_powerup_index = i;
			found = true;
			break;
		}
	}

	if ( !found )
	{
		iprintln( "Powerup not found: " + powerup_name );
		return;
	}

	// Trace to where the player is looking
	direction = player GetPlayerAngles();
	direction_vec = AnglesToForward( direction );
	eye = player GetEye();

	scale = 8000;
	direction_vec = (direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale);

	// offset 2 units on the Z to fix the bug where it would drop through the ground sometimes
	trace = bullettrace( eye, eye + direction_vec, 0, undefined );

	level.zombie_vars["zombie_drop_item"] = 1;
	level.powerup_drop_count = 0;
	level thread maps\_zombiemode_powerups::powerup_drop( trace["position"] );
}


zombie_devgui_goto_round( target_round )
{
	player = get_players()[0];

	if ( target_round < 1 )
	{
		target_round = 1;
	}

	level.zombie_health = level.zombie_vars["zombie_health_start"]; 
	level.round_number = 1;
	level.zombie_total = 0;

	// calculate zombie health
	while ( level.round_number < target_round )
	{
		maps\_zombiemode::ai_calculate_health();
		level.round_number++;
	}

	level.round_number--;

	level notify( "kill_round" );

	// fix up the hud
	if( IsDefined( level.chalk_hud2 ) )
	{
		level.chalk_hud2 maps\_zombiemode_utility::destroy_hud();

		if ( level.round_number < 11 )
		{
			level.chalk_hud2 = maps\_zombiemode::create_chalk_hud( 64 );
		}
	}

	if ( IsDefined( level.chalk_hud1 ) ) 
	{
		level.chalk_hud1 maps\_zombiemode_utility::destroy_hud();
		level.chalk_hud1 = maps\_zombiemode::create_chalk_hud();

		switch( level.round_number )
		{
		case 0:
		case 1:
			level.chalk_hud1 SetShader( "hud_chalk_1", 64, 64 );
			break;
		case 2:
			level.chalk_hud1 SetShader( "hud_chalk_2", 64, 64 );
			break;
		case 3:
			level.chalk_hud1 SetShader( "hud_chalk_3", 64, 64 );
			break;
		case 4:
			level.chalk_hud1 SetShader( "hud_chalk_4", 64, 64 );
			break;
		default:
			level.chalk_hud1 SetShader( "hud_chalk_5", 64, 64 );
			break;
		}
	}
	
	iprintln( "Jumping to round: " + target_round );
	wait( 1 );
	
	// kill all active zombies
	zombies = getaiarray( "axis" );

	if ( IsDefined( zombies ) )
	{
		for (i = 0; i < zombies.size; i++)
		{
			zombies[i] maps\_zombiemode_spawner::zombie_head_gib();
			zombies[i] dodamage(zombies[i].health + 666, zombies[i].origin);
		}
	}
}

#/