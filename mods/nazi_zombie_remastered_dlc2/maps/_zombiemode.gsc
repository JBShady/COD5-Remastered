#include maps\_anim; 
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_music; 
#include maps\_zombiemode_utility; 
#include maps\_busing;

#using_animtree( "generic_human" ); 

main()
{
	precache_shaders();
	precache_models();

	PrecacheItem( "fraggrenade" );
	PrecacheItem( "colt" );

	game[ "menu_clientdvar" ] = "menu_clientdvar";   // these two lines at beginning of gsc
	precacheMenu( game[ "menu_clientdvar" ] );

	init_strings();
	init_levelvars();
	init_animscripts();
	init_sounds();
	init_shellshocks();
	init_flags();

	// the initial spawners
	level.enemy_spawns = getEntArray( "zombie_spawner_init", "targetname" ); 
	SetAILimit( 24 );

	//maps\_destructible_type94truck::init(); 

	level.custom_introscreen = ::zombie_intro_screen; 
	level.reset_clientdvars = ::onPlayerConnect_clientDvars;

	init_fx(); 


	// load map defaults
	maps\_load::main();

	level.hudelem_count = 0;
	level.remove_ee_ef = 0;
	level.solo_reviving_failsafe = 0;
	// Call the other zombiemode scripts
	//maps\_zombiemode_net::init();
	maps\_zombiemode_weapons_sumpf::init();
	maps\_zombiemode_blockers::init();
	maps\_zombiemode_spawner::init();
	maps\_zombiemode_powerups::init();
	maps\_zombiemode_radio::init();	
	maps\_zombiemode_perks::init();
	maps\_zombiemode_tesla::init();
	maps\_zombiemode_dogs::init();

	//revive_retreat_point();

	/#
		maps\_zombiemode_devgui::init();
	#/

	init_utility();

	// register a client system...
	maps\_utility::registerClientSys("zombify");

	level thread coop_player_spawn_placement();

	// zombie ai and anim inits
	init_anims(); 

	// Sets up function pointers for animscripts to refer to
	level.playerlaststand_func = ::player_laststand;
	//	level.global_kill_func = maps\_zombiemode_spawner::zombie_death; 
	level.global_damage_func = maps\_zombiemode_spawner::zombie_damage; 
	level.global_damage_func_ads = maps\_zombiemode_spawner::zombie_damage_ads;
	level.overridePlayerKilled = ::player_killed_override;
	level.overridePlayerDamage = ::player_damage_override;

	// used to a check in last stand for players to become zombies
	level.is_zombie_level = true; 
	level.player_becomes_zombie = ::zombify_player; 

	// so we dont get the uber colt when we're knocked out
	level.laststandpistol = "colt";

	level.round_start_time = 0;

	level thread onPlayerConnect(); 

	init_dvars();
	initZombieLeaderboardData();


	flag_wait( "all_players_connected" ); 

	players = get_players();

	if( players.size == 1 && getdvarint("classic_perks") == 0 ) // Make sure classic perks are disabled, thus the new remastered solo revives will be enabled
	{
		level.solo_quick_revive = true;
	}

	switch(players.size)
	{	
		case 1:
			level.dynEnt_spawnedLimit = 50;
			break;
		case 2:
			level.dynEnt_spawnedLimit = 40;
			break;
		case 3:
			level.dynEnt_spawnedLimit = 30;
			break;
		case 4:
			level.dynEnt_spawnedLimit = 25;
			break;
		default:
			level.dynEnt_spawnedLimit = 50;
			break;	
	}

	SetDvar( "dynEnt_spawnedLimit", level.dynEnt_spawnedLimit );
/*	if(getDvarInt("classic_perks") == 1) //enable old jug
	{
		level thread check_for_old_jug();
	}*/

	if(level.script == "nazi_zombie_asylum" || level.script == "nazi_zombie_factory" || level.script == "nazi_zombie_sumpf")
	{
		maps\_zombiemode_achievement::init();
	}
	//thread zombie_difficulty_ramp_up(); 

	// Start the Zombie MODE!
	level thread end_game();
	level thread round_start();
	level thread players_playing();
	//level thread check_for_jugg_perk();

	//chrisp - adding spawning vo 
	//level thread spawn_vo();
	
	level thread disable_character_dialog();

	//level thread prevent_near_origin();

	DisableGrenadeSuicide();

	level.startInvulnerableTime = GetDvarInt( "player_deathInvulnerableTime" );

	// Do a SaveGame, so we can restart properly when we die
	SaveGame( "zombie_start", &"AUTOSAVE_LEVELSTART", "", true );

	// TESTING
	//	wait( 3 );
	//	level thread intermission();
	//	thread testing_spawner_bug();

	if(!IsDefined(level.eggs) )
	{
		level.eggs = 0;
	}
}

/*revive_retreat_point()
{
	sleight = getEnt("radio_three_origin", "targetname");
	level.revive_point = spawn("script_origin", sleight.origin + ( 50, 0, 0 ) );
}*/



/*------------------------------------
chrisp - adding vo to track players ammo
------------------------------------*/

track_ammo_count()
{
	self endon("disconnect");
	self endon("death");
	if(!IsDefined (self.player_ammo_low))	
	{
		self.player_ammo_low = false;
	}	
	if(!IsDefined(self.player_ammo_out))
	{
		self.player_ammo_out = false;
	}
	while ( true )
	{
		wait 0.5;
		if ( !is_player_valid( self ) )
		{				
			continue;
		}
		weap = self getcurrentweapon();

		if(!isDefined(weap) || weap == "none" || (isSubStr(weap, "zombie_perk_bottle")) || weap == "mine_bouncing_betty" || weap == "syrette" || weap == "m2_flamethrower_zombie" || weap == "m7_launcher_zombie" || (isSubStr(weap, "zombie_item")) || weap == "falling_hands" || weap == "zombie_melee" )
		{
			continue;
		}
		ammo_count = self GetAmmoCount( weap );
		if ( ammo_count > 5 )
		{
			continue;
		}		

		if ( ammo_count > 0 )
		{
			if ( !self.player_ammo_low )
			{
				self thread add_low_ammo_dialog();
				self thread ammo_low_dialog_timer();
			}
		}
		else
		{	
			if ( !self.player_ammo_out )
			{
				self thread add_no_ammo_dialog( weap );
				self thread ammo_out_dialog_timer();
			}
		}
	}	
}

ammo_low_dialog_timer()
{
	self.player_ammo_low = true;
	wait 20;
	self.player_ammo_low = false;
}

ammo_out_dialog_timer()
{
	self.player_ammo_out = true;
	wait 20;
	self.player_ammo_out = false;	
}

add_low_ammo_dialog()
{
	index = maps\_zombiemode_weapons::get_player_index(self);	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_ammo_low))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_ammo_low");
		self.vox_ammo_low = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_ammo_low[self.vox_ammo_low.size] = "vox_ammo_low_" + i;	
		}
		self.vox_ammo_low_available = self.vox_ammo_low;		
	}	
	sound_to_play = random(self.vox_ammo_low_available);
	
	self.vox_ammo_low_available = array_remove(self.vox_ammo_low_available,sound_to_play);
	
	if (self.vox_ammo_low_available.size < 1 )
	{
		self.vox_ammo_low_available = self.vox_ammo_low;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
	
	
}
add_no_ammo_dialog( weap )
{
	self endon( "disconnect" );
	wait 1;
	// Let's pause here a couple of seconds to see if we're really out of ammo.
	// If you take a weapon, there's a second or two where your current weapon
	// will be set to no ammo while you switch to the new one.
	while ( self isSwitchingWeapons() )
	{
		wait 0.1;
	}

	curr_weap = self getcurrentweapon();
	if ( !IsDefined(curr_weap) || curr_weap != weap || self GetAmmoCount( curr_weap ) != 0 )
	{
		// False alarm
		return;
	}


	index = maps\_zombiemode_weapons::get_player_index(self);	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_ammo_out))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_ammo_out");
		self.vox_ammo_out = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_ammo_out[self.vox_ammo_out.size] = "vox_ammo_out_" + i;	
		}
		self.vox_ammo_out_available = self.vox_ammo_out;		
	}	
	sound_to_play = random(self.vox_ammo_out_available);
	
	self.vox_ammo_out_available = array_remove(self.vox_ammo_out_available,sound_to_play);
	
	if (self.vox_ammo_out_available.size < 1 )
	{
		self.vox_ammo_out_available = self.vox_ammo_out;
	}

	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
	
	
}

add_pain_vox()
{	
	index = maps\_zombiemode_weapons::get_player_index(self);	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_pain))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_pain");
		self.vox_gen_pain = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_pain[self.vox_gen_pain.size] = "vox_gen_pain_" + i;	
		}
		self.vox_gen_pain_available = self.vox_gen_pain;		
	}	
	sound_to_play = random(self.vox_gen_pain_available);
	
	self.vox_gen_pain_available = array_remove(self.vox_gen_pain_available,sound_to_play);
	
	if (self.vox_gen_pain_available.size < 1 )
	{
		self.vox_gen_pain_available = self.vox_gen_pain;
	}
	// Don't bother threading do dialog on Nacht, pain vox should be over quick so that we are more likely to hear it again or death vox, given that players aren't survivng a bunch of hits without jug		
	level.player_is_speaking = 1;
	self playsound(player_index + sound_to_play);		
	wait(0.4);
	level.player_is_speaking = 0;
}
/*------------------------------------
audio plays when more than 1 player connects
------------------------------------*/
spawn_vo()
{
	//not sure if we need this
	wait(1);
	
	players = getplayers();
	
	//just pick a random player for now and play some vo 
	if(players.size > 1)
	{
		player = random(players);
		index = maps\_zombiemode_weapons::get_player_index(player);
		player thread spawn_vo_player(index,players.size);
	}

}

spawn_vo_player(index,num)
{
	sound = "plr_" + index + "_vox_" + num +"play";
	self playsound(sound, "sound_done");			
	self waittill("sound_done");
}

testing_spawner_bug()
{
	wait( 0.1 );
	level.round_number = 7;

	spawners = [];
	spawners[0] = GetEnt( "testy", "targetname" );
	while( 1 )
	{
		wait( 1 );
		level.enemy_spawns = spawners;
	}
}

precache_shaders()
{
	PrecacheShader( "hud_chalk_1" );
	PrecacheShader( "hud_chalk_2" );
	PrecacheShader( "hud_chalk_3" );
	PrecacheShader( "hud_chalk_4" );
	PrecacheShader( "hud_chalk_5" );

	PrecacheShader( "dlc2_zombie_survivor");
	PrecacheShader( "dlc2_zombie_secret");
	PrecacheShader( "dlc2_zombie_repair_boards");
	PrecacheShader( "dlc2_zombie_points");
	PrecacheShader( "dlc2_zombie_nuke_kills");
	PrecacheShader( "dlc2_zombie_melee_kills");
	PrecacheShader( "dlc2_zombie_kills");
	PrecacheShader( "dlc2_zombie_headshots");
	PrecacheShader( "dlc2_zombie_all_traps");
	PrecacheShader( "dlc2_zombie_all_perks");
	PrecacheShader( "dlc2_zombie_ee");
}

precache_models()
{
	precachemodel( "char_ger_honorgd_zomb_behead" ); 
	precachemodel( "char_ger_zombieeye" ); 
	PrecacheModel( "tag_origin" );
}

init_shellshocks()
{
	level.player_killed_shellshock = "zombie_death";
	PrecacheShellshock( level.player_killed_shellshock );
}

init_strings()
{
	PrecacheString( &"ZOMBIE_WEAPONCOSTAMMO" );
	PrecacheString( &"ZOMBIE_ROUND" );
	PrecacheString( &"SCRIPT_PLUS" );
	PrecacheString( &"ZOMBIE_GAME_OVER" );
	PrecacheString( &"ZOMBIE_SURVIVED_ROUND" );
	PrecacheString( &"ZOMBIE_SURVIVED_ROUNDS" );
	PrecacheString( &"REMASTERED_ZOMBIE_TRADE_WEAPONS");
	PrecacheString( &"REMASTERED_ZOMBIE_TRADE_WEAPONS_ALT");

	add_zombie_hint( "undefined", &"ZOMBIE_UNDEFINED" );

	// Random Treasure Chest
	add_zombie_hint( "default_treasure_chest_950", &"REMASTERED_ZOMBIE_RANDOM_WEAPON_950" );

	// Barrier Pieces
	add_zombie_hint( "default_buy_barrier_piece_10", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_10" );
	add_zombie_hint( "default_buy_barrier_piece_20", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_20" );
	add_zombie_hint( "default_buy_barrier_piece_50", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_50" );
	add_zombie_hint( "default_buy_barrier_piece_100", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_100" );

	// REWARD Barrier Pieces
	add_zombie_hint( "default_reward_barrier_piece", &"ZOMBIE_BUTTON_REWARD_BARRIER" );
	add_zombie_hint( "default_reward_barrier_piece_10", &"ZOMBIE_BUTTON_REWARD_BARRIER_10" );
	add_zombie_hint( "default_reward_barrier_piece_20", &"ZOMBIE_BUTTON_REWARD_BARRIER_20" );
	add_zombie_hint( "default_reward_barrier_piece_30", &"ZOMBIE_BUTTON_REWARD_BARRIER_30" );
	add_zombie_hint( "default_reward_barrier_piece_40", &"ZOMBIE_BUTTON_REWARD_BARRIER_40" );
	add_zombie_hint( "default_reward_barrier_piece_50", &"ZOMBIE_BUTTON_REWARD_BARRIER_50" );

	// Debris
	add_zombie_hint( "default_buy_debris_100", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_100" );
	add_zombie_hint( "default_buy_debris_200", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_200" );
	add_zombie_hint( "default_buy_debris_250", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_250" );
	add_zombie_hint( "default_buy_debris_500", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_500" );
	add_zombie_hint( "default_buy_debris_750", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_750" );
	add_zombie_hint( "default_buy_debris_1000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1000" );
	add_zombie_hint( "default_buy_debris_1250", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1250" );
	add_zombie_hint( "default_buy_debris_1500", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1500" );
	add_zombie_hint( "default_buy_debris_1750", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1750" );
	add_zombie_hint( "default_buy_debris_2000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_2000" );

	// Doors
	add_zombie_hint( "default_buy_door_100", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_100" );
	add_zombie_hint( "default_buy_door_200", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_200" );
	add_zombie_hint( "default_buy_door_250", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_250" );
	add_zombie_hint( "default_buy_door_500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_500" );
	add_zombie_hint( "default_buy_door_750", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_750" );
	add_zombie_hint( "default_buy_door_1000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1000" );
	add_zombie_hint( "default_buy_door_1250", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1250" );
	add_zombie_hint( "default_buy_door_1500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1500" );
	add_zombie_hint( "default_buy_door_1750", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1750" );
	add_zombie_hint( "default_buy_door_2000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_2000" );

	// Areas
	//add_zombie_hint( "default_buy_area_100", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_100" );
	//add_zombie_hint( "default_buy_area_200", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_200" );
	//add_zombie_hint( "default_buy_area_250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_250" );
	add_zombie_hint( "default_buy_area_500", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_500" );
	add_zombie_hint( "default_buy_area_750", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_750" );
	add_zombie_hint( "default_buy_area_1000", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1000" );
	add_zombie_hint( "default_buy_area_1250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1250" );
	add_zombie_hint( "default_buy_area_1500", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1500" );
	add_zombie_hint( "default_buy_area_1750", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1750" );
	add_zombie_hint( "default_buy_area_2000", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_2000" );
}

init_sounds()
{
	add_sound( "end_of_round", "round_over" );
	add_sound( "end_of_game", "mx_game_over" ); //Had to remove this and add a music state switch so that we can add other musical elements.
	add_sound( "chalk_one_up", "chalk" );
	add_sound( "purchase", "cha_ching" );
	add_sound( "no_purchase", "no_cha_ching" );

	// Zombification
	// TODO need to vary these up
	add_sound( "playerzombie_usebutton_sound", "attack_vocals" );
	add_sound( "playerzombie_attackbutton_sound", "attack_vocals" );
	add_sound( "playerzombie_adsbutton_sound", "attack_vocals" );

	// Head gib
	add_sound( "zombie_head_gib", "zombie_head_gib" );
	add_sound( "zombie_impact_helmet", "zombie_impact_helmet" );

	// Blockers
	add_sound( "rebuild_barrier_piece", "repair_boards" );
	add_sound( "rebuild_barrier_hover", "boards_float" );
	add_sound( "debris_hover_loop", "couch_loop" );
	add_sound( "break_barrier_piece", "break_boards" );
	add_sound("blocker_end_move", "board_slam");
	add_sound( "barrier_rebuild_slam", "board_slam" );

	// Doors
	add_sound( "door_slide_open", "door_slide_open" );
	add_sound( "door_rotate_open", "door_slide_open" );

	// Debris
	add_sound( "debris_move", "weap_wall" );

	// Random Weapon Chest
	add_sound( "open_chest", "lid_open" );
	add_sound( "music_chest", "music_box" );
	add_sound( "close_chest", "lid_close" );

	// Weapons on walls
	add_sound( "weapon_show", "weap_wall" );

}

init_levelvars()
{
	level.intermission = false;
	level.dog_intermission = false;
	level.zombie_total = 0;
	level.no_laststandmissionfail = true;
	level.falling_down = false;

	level.zombie_vars = [];

	// Default to not zombify the player till further support
	set_zombie_var( "zombify_player", 					false );

	set_zombie_var( "below_world_check", 				-1000 );

	// Respawn in the spectators in between rounds
	set_zombie_var( "spectators_respawn", 				true );

	// Round	
	set_zombie_var( "zombie_use_failsafe", 				true );
	set_zombie_var( "zombie_round_time", 				30 );
	set_zombie_var( "zombie_between_round_time", 		10 );
	set_zombie_var( "zombie_intermission_time", 		15 );

	// Spawning
	set_zombie_var( "zombie_spawn_delay", 				3 );

	// AI 
	set_zombie_var( "zombie_health_increase", 			100 );
	set_zombie_var( "zombie_health_increase_percent", 	10, 	100 );
	set_zombie_var( "zombie_health_start", 				150 );
	set_zombie_var( "zombie_max_ai", 					24 );
	set_zombie_var( "zombie_ai_per_player", 			6 );

	// Scoring
	set_zombie_var( "zombie_score_start", 				500 );
/#
	if( GetDvarInt( "zombie_cheat" ) >= 1 )
	{
		set_zombie_var( "zombie_score_start", 			100000 );
	}
#/
	set_zombie_var( "zombie_score_kill", 				50 );
	set_zombie_var( "zombie_score_damage", 				5 );
	set_zombie_var( "zombie_score_bonus_melee", 		80 );
	set_zombie_var( "zombie_score_bonus_head", 			50 );
	set_zombie_var( "zombie_score_bonus_neck", 			20 );
	set_zombie_var( "zombie_score_bonus_torso", 		10 );
	set_zombie_var( "zombie_score_bonus_burn", 			10 );

	set_zombie_var( "penalty_no_revive_percent", 		10, 	100 );
	set_zombie_var( "penalty_died_percent", 			0, 		100 );
	set_zombie_var( "penalty_downed_percent", 			5, 		100 );	

	set_zombie_var( "zombie_flame_dmg_point_delay",		500 );	

	if ( IsSplitScreen() )
	{
		set_zombie_var( "zombie_timer_offset", 			280 );	// hud offsets
	}
}

init_dvars()
{
	level.zombiemode = true;

	//coder mod: tkeegan - new code dvar
	setSavedDvar( "zombiemode", "1" );
	SetDvar( "ui_gametype", "zom" );	
/*	setSavedDvar( "fire_world_damage", "0" );	
	setSavedDvar( "fire_world_damage_rate", "0" );	
	setSavedDvar( "fire_world_damage_duration", "0" );	*/

	if( GetDvar( "zombie_debug" ) == "" )
	{
		SetDvar( "zombie_debug", "0" );
	}

	if( GetDvar( "zombie_cheat" ) == "" )
	{
		SetDvar( "zombie_cheat", "0" );
	}
	
	if(getdvar("magic_chest_movable") == "")
	{
		SetDvar( "magic_chest_movable", "1" );
	}

	if(getdvar("magic_box_explore_only") == "")
	{
		SetDvar( "magic_box_explore_only", "1" );
	}

	SetDvar( "revive_trigger_radius", "60" ); 

}

initZombieLeaderboardData()
{
	// Initializing Leaderboard Stat Variables
/*	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["highestwave"] = "nz_prototype_highestwave";
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["highestwave_two"] = "nz_prototype_highestwave_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["highestwave_three"] = "nz_prototype_highestwave_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["highestwave_four"] = "nz_prototype_highestwave_four";
	
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["totalpoints"] = "nz_prototype_totalpoints";
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["totalpoints_two"] = "nz_prototype_totalpoints_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["totalpoints_three"] = "nz_prototype_totalpoints_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_prototype"]["totalpoints_four"] = "nz_prototype_totalpoints_four";
	
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["highestwave"] = "nz_asylum_highestwave";
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["highestwave_two"] = "nz_asylum_highestwave_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["highestwave_three"] = "nz_asylum_highestwave_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["highestwave_four"] = "nz_asylum_highestwave_four";
	
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["totalpoints"] = "nz_asylum_totalpoints";
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["totalpoints_two"] = "nz_asylum_totalpoints_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["totalpoints_three"] = "nz_asylum_totalpoints_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_asylum"]["totalpoints_four"] = "nz_asylum_totalpoints_four";
	*/
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["highestwave"] = "nz_sumpf_highestwave";
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["highestwave_two"] = "nz_sumpf_highestwave_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["highestwave_three"] = "nz_sumpf_highestwave_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["highestwave_four"] = "nz_sumpf_highestwave_four";
	
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["totalpoints"] = "nz_sumpf_totalpoints";
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["totalpoints_two"] = "nz_sumpf_totalpoints_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["totalpoints_three"] = "nz_sumpf_totalpoints_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_sumpf"]["totalpoints_four"] = "nz_sumpf_totalpoints_four";

/*	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["highestwave"] = "nz_factory_highestwave";
	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["highestwave_two"] = "nz_factory_highestwave_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["highestwave_three"] = "nz_factory_highestwave_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["highestwave_four"] = "nz_factory_highestwave_four";

	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["totalpoints"] = "nz_factory_totalpoints";
	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["totalpoints_two"] = "nz_factory_totalpoints_two";
	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["totalpoints_three"] = "nz_factory_totalpoints_three";
	level.zombieLeaderboardStatVariable["nazi_zombie_factory"]["totalpoints_four"] = "nz_factory_totalpoints_four";*/

	// Initializing Leaderboard Number
	level.zombieLeaderboardNumber["nazi_zombie_prototype"]["waves"] = true;
	level.zombieLeaderboardNumber["nazi_zombie_asylum"]["waves"] = true;
	level.zombieLeaderboardNumber["nazi_zombie_sumpf"]["waves"] = true;
	level.zombieLeaderboardNumber["nazi_zombie_factory"]["waves"] = true;
}

init_flags()
{
	flag_init("spawn_point_override");
}

init_fx()
{
	level._effect["wood_chunk_destory"]	 	= loadfx( "impacts/large_woodhit" );

	level._effect["edge_fog"]			 	= LoadFx( "env/smoke/fx_fog_zombie_amb" ); 
	level._effect["chest_light"]		 	= LoadFx( "env/light/fx_ray_sun_sm_short" ); 

	level._effect["eye_glow"]			 	= LoadFx( "misc/fx_zombie_eye_single" ); 

	level._effect["zombie_grain"]			= LoadFx( "misc/fx_zombie_grain_cloud" );

	level._effect["headshot"] 				= LoadFX( "impacts/flesh_hit_head_fatal_lg_exit" );
	level._effect["headshot_nochunks"] 		= LoadFX( "misc/fx_zombie_bloodsplat" );
	level._effect["bloodspurt"] 			= LoadFX( "misc/fx_zombie_bloodspurt" );
	level._effect["tesla_head_light"]		= Loadfx( "maps/zombie/fx_zombie_tesla_neck_spurt");

	level._effect["rise_burst_water"]		= LoadFx("maps/zombie/fx_zombie_body_wtr_burst");
	level._effect["rise_billow_water"]	= LoadFx("maps/zombie/fx_zombie_body_wtr_billowing");
	level._effect["rise_dust_water"]		= LoadFx("maps/zombie/fx_zombie_body_wtr_falling");

	// Flamethrower
	level._effect["character_fire_pain_sm"]              		= loadfx( "env/fire/fx_fire_player_sm_1sec" );
	level._effect["character_fire_death_sm"]             		= loadfx( "env/fire/fx_fire_player_md" );
	level._effect["character_fire_death_torso"] 				= loadfx( "env/fire/fx_fire_player_torso" );
}

// zombie specific anims
init_anims()
{
	// deaths
	level.scr_anim["zombie"]["death1"] 	= %ai_zombie_death_v1;
	level.scr_anim["zombie"]["death2"] 	= %ai_zombie_death_v2;
	level.scr_anim["zombie"]["death3"] 	= %ai_zombie_crawl_death_v1;
	level.scr_anim["zombie"]["death4"] 	= %ai_zombie_crawl_death_v2;

	// run cycles
	
	level.scr_anim["zombie"]["walk1"] 	= %ai_zombie_walk_v1;
	level.scr_anim["zombie"]["walk2"] 	= %ai_zombie_walk_v2;
	level.scr_anim["zombie"]["walk3"] 	= %ai_zombie_walk_v3;
	level.scr_anim["zombie"]["walk4"] 	= %ai_zombie_walk_v4;



	
	level.scr_anim["zombie"]["run1"] 	= %ai_zombie_walk_fast_v1;
	level.scr_anim["zombie"]["run2"] 	= %ai_zombie_walk_fast_v2;
	level.scr_anim["zombie"]["run3"] 	= %ai_zombie_walk_fast_v3;

	//level.scr_anim["zombie"]["run4"] 	= %ai_zombie_run_v1;
	
	//level.scr_anim["zombie"]["run6"] 	= %ai_zombie_run_v4;

	level.scr_anim["zombie"]["sprint1"] = %ai_zombie_sprint_v1;
	level.scr_anim["zombie"]["sprint2"] = %ai_zombie_sprint_v2;
	//level.scr_anim["zombie"]["sprint3"] = %ai_zombie_sprint_v3;
	//level.scr_anim["zombie"]["sprint3"] = %ai_zombie_sprint_v4;
	//level.scr_anim["zombie"]["sprint4"] = %ai_zombie_sprint_v5;

	// run cycles in prone
	level.scr_anim["zombie"]["crawl1"] 	= %ai_zombie_crawl;
	level.scr_anim["zombie"]["crawl2"] 	= %ai_zombie_crawl_v1;
	level.scr_anim["zombie"]["crawl3"] 	= %ai_zombie_crawl_v2;
	level.scr_anim["zombie"]["crawl4"] 	= %ai_zombie_crawl_v3;
	level.scr_anim["zombie"]["crawl5"] 	= %ai_zombie_crawl_v4;
	level.scr_anim["zombie"]["crawl6"] 	= %ai_zombie_crawl_v5;
	level.scr_anim["zombie"]["crawl_hand_1"] = %ai_zombie_walk_on_hands_a;
	level.scr_anim["zombie"]["crawl_hand_2"] = %ai_zombie_walk_on_hands_b;



	
	level.scr_anim["zombie"]["crawl_sprint1"] 	= %ai_zombie_crawl_sprint;
	level.scr_anim["zombie"]["crawl_sprint2"] 	= %ai_zombie_crawl_sprint_1;
	level.scr_anim["zombie"]["crawl_sprint3"] 	= %ai_zombie_crawl_sprint_2;

	level._zombie_melee = [];
	level._zombie_walk_melee = [];
	level._zombie_run_melee = [];


	if(level.script == "nazi_zombie_sumpf")
	{

		/*level.scr_anim["zombie"]["walk1"] 	= %ai_zombie_jap_walk_A;
		level.scr_anim["zombie"]["walk2"] 	= %ai_zombie_jap_walk_B;*/




		level._zombie_melee[0] 				= %ai_zombie_jap_attack_v6; 
		level._zombie_melee[1] 				= %ai_zombie_jap_attack_v5; 
		level._zombie_melee[2] 				= %ai_zombie_jap_attack_v1; 
		level._zombie_melee[3] 				= %ai_zombie_jap_attack_v2;	
		level._zombie_melee[4]				= %ai_zombie_jap_attack_v3;
		level._zombie_melee[5]				= %ai_zombie_jap_attack_v4;

		level._zombie_run_melee[0]				=	%ai_zombie_jap_run_attack_v1;
		level._zombie_run_melee[1]				=	%ai_zombie_jap_run_attack_v2;

	/*	level.scr_anim["zombie"]["run1"] 	= %ai_zombie_jap_run_v1;
		level.scr_anim["zombie"]["run2"] 	= %ai_zombie_jap_run_v2;
		level.scr_anim["zombie"]["run3"] 	= %ai_zombie_jap_run_v4;*/
		level.scr_anim["zombie"]["run4"] 	= %ai_zombie_walk_fast_v1;
		level.scr_anim["zombie"]["run5"] 	= %ai_zombie_walk_fast_v2;
		level.scr_anim["zombie"]["run6"] 	= %ai_zombie_walk_fast_v3;
		level.scr_anim["zombie"]["run7"] 	= %ai_zombie_jap_run_v1;
		level.scr_anim["zombie"]["run8"] 	= %ai_zombie_jap_run_v2;
		level.scr_anim["zombie"]["run9"] 	= %ai_zombie_jap_run_v1;
		level.scr_anim["zombie"]["run10"] 	= %ai_zombie_jap_run_v2;
		level.scr_anim["zombie"]["run11"] 	= %ai_zombie_jap_run_v6;
		//new one ^ diluted with repeat of normal anims, rare

		level.scr_anim["zombie"]["walk5"] 	= %ai_zombie_jap_walk_v1;
		level.scr_anim["zombie"]["walk6"] 	= %ai_zombie_jap_walk_v2;
		level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_jap_walk_v3;
		level.scr_anim["zombie"]["walk8"] 	= %ai_zombie_jap_walk_v4;
		//new one ^

		level.scr_anim["zombie"]["sprint3"] = %ai_zombie_jap_run_v3;
		level.scr_anim["zombie"]["sprint4"] = %ai_zombie_jap_run_v3;
		level.scr_anim["zombie"]["sprint5"] = %ai_zombie_sprint_v1;
		level.scr_anim["zombie"]["sprint6"] = %ai_zombie_sprint_v2;
		level.scr_anim["zombie"]["sprint7"] = %ai_zombie_jap_run_v5; // swapped 5 and 6. 5 is actually faster, so it should be under the sprint category
		//new one ^ diluted with a repeat of normal anims, rare



	}
	else
	{


		level._zombie_melee[0] 				= %ai_zombie_attack_forward_v1; 
		level._zombie_melee[1] 				= %ai_zombie_attack_forward_v2; 
		level._zombie_melee[2] 				= %ai_zombie_attack_v1; 
		level._zombie_melee[3] 				= %ai_zombie_attack_v2;	
		level._zombie_melee[4]				= %ai_zombie_attack_v1;
		level._zombie_melee[5]				= %ai_zombie_attack_v4;
		level._zombie_melee[6]				= %ai_zombie_attack_v6;	
		level._zombie_run_melee[0]				=	%ai_zombie_run_attack_v1;
		level._zombie_run_melee[1]				=	%ai_zombie_run_attack_v2;
		level._zombie_run_melee[2]				=	%ai_zombie_run_attack_v3;
		level.scr_anim["zombie"]["walk5"] 	= %ai_zombie_walk_v6;
		level.scr_anim["zombie"]["walk6"] 	= %ai_zombie_walk_v7;
		level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_walk_v8;
		level.scr_anim["zombie"]["walk8"] 	= %ai_zombie_walk_v9;


		level.scr_anim["zombie"]["run4"] 	= %ai_zombie_run_v2;
		level.scr_anim["zombie"]["run5"] 	= %ai_zombie_run_v4;


	}

	

	level._zombie_walk_melee[0]			= %ai_zombie_walk_attack_v1;
	level._zombie_walk_melee[1]			= %ai_zombie_walk_attack_v2;
	level._zombie_walk_melee[2]			= %ai_zombie_walk_attack_v3;
	level._zombie_walk_melee[3]			= %ai_zombie_walk_attack_v4;

	// melee in crawl
	level._zombie_melee_crawl = [];
	level._zombie_melee_crawl[0] 		= %ai_zombie_attack_crawl; 
	level._zombie_melee_crawl[1] 		= %ai_zombie_attack_crawl_lunge;

	level._zombie_stumpy_melee = [];
	level._zombie_stumpy_melee[0] = %ai_zombie_walk_on_hands_shot_a;
	level._zombie_stumpy_melee[1] = %ai_zombie_walk_on_hands_shot_b;
	//level._zombie_melee_crawl[2]		= %ai_zombie_crawl_attack_A;

	// tesla deaths
	level._zombie_tesla_death = [];
	level._zombie_tesla_death[0] = %ai_zombie_tesla_death_a;
	level._zombie_tesla_death[1] = %ai_zombie_tesla_death_b;
	level._zombie_tesla_death[2] = %ai_zombie_tesla_death_c;
	level._zombie_tesla_death[3] = %ai_zombie_tesla_death_d;
	level._zombie_tesla_death[4] = %ai_zombie_tesla_death_e;

	level._zombie_tesla_crawl_death = [];
	level._zombie_tesla_crawl_death[0] = %ai_zombie_tesla_crawl_death_a;
	level._zombie_tesla_crawl_death[1] = %ai_zombie_tesla_crawl_death_b;


	/*
	ground crawl
	*/

	// set up the arrays
	level._zombie_rise_anims = [];

	//level._zombie_rise_anims[1]["walk"][0]		= %ai_zombie_traverse_ground_v1_crawl;
	level._zombie_rise_anims[1]["walk"][0]		= %ai_zombie_traverse_ground_v1_walk;

	//level._zombie_rise_anims[1]["run"][0]		= %ai_zombie_traverse_ground_v1_crawlfast;
	level._zombie_rise_anims[1]["run"][0]		= %ai_zombie_traverse_ground_v1_run;

	level._zombie_rise_anims[1]["sprint"][0]	= %ai_zombie_traverse_ground_climbout_fast;

	//level._zombie_rise_anims[2]["walk"][0]		= %ai_zombie_traverse_ground_v2_walk;	//!broken
	level._zombie_rise_anims[2]["walk"][0]		= %ai_zombie_traverse_ground_v2_walk_altA;
	//level._zombie_rise_anims[2]["walk"][2]		= %ai_zombie_traverse_ground_v2_walk_altB;//!broken

	// ground crawl death
	level._zombie_rise_death_anims = [];

	level._zombie_rise_death_anims[1]["in"][0]		= %ai_zombie_traverse_ground_v1_deathinside;
	level._zombie_rise_death_anims[1]["in"][1]		= %ai_zombie_traverse_ground_v1_deathinside_alt;

	level._zombie_rise_death_anims[1]["out"][0]		= %ai_zombie_traverse_ground_v1_deathoutside;
	level._zombie_rise_death_anims[1]["out"][1]		= %ai_zombie_traverse_ground_v1_deathoutside_alt;

	level._zombie_rise_death_anims[2]["in"][0]		= %ai_zombie_traverse_ground_v2_death_low;
	level._zombie_rise_death_anims[2]["in"][1]		= %ai_zombie_traverse_ground_v2_death_low_alt;

	level._zombie_rise_death_anims[2]["out"][0]		= %ai_zombie_traverse_ground_v2_death_high;
	level._zombie_rise_death_anims[2]["out"][1]		= %ai_zombie_traverse_ground_v2_death_high_alt;
	
	//taunts
	level._zombie_run_taunt = [];
	level._zombie_board_taunt = [];
	
	//level._zombie_taunt[0] = %ai_zombie_taunts_1;
	//level._zombie_taunt[1] = %ai_zombie_taunts_4;
	//level._zombie_taunt[2] = %ai_zombie_taunts_5b;
	//level._zombie_taunt[3] = %ai_zombie_taunts_5c;
	//level._zombie_taunt[4] = %ai_zombie_taunts_5d;
	//level._zombie_taunt[5] = %ai_zombie_taunts_5e;
	//level._zombie_taunt[6] = %ai_zombie_taunts_5f;
	//level._zombie_taunt[7] = %ai_zombie_taunts_7;
	//level._zombie_taunt[8] = %ai_zombie_taunts_9;
	//level._zombie_taunt[8] = %ai_zombie_taunts_11;
	//level._zombie_taunt[8] = %ai_zombie_taunts_12;
	
	level._zombie_board_taunt[0] = %ai_zombie_taunts_4;
	level._zombie_board_taunt[1] = %ai_zombie_taunts_7;
	level._zombie_board_taunt[2] = %ai_zombie_taunts_9;
	level._zombie_board_taunt[3] = %ai_zombie_taunts_5b;
	level._zombie_board_taunt[4] = %ai_zombie_taunts_5c;
	level._zombie_board_taunt[5] = %ai_zombie_taunts_5d;
	level._zombie_board_taunt[6] = %ai_zombie_taunts_5e;
	level._zombie_board_taunt[7] = %ai_zombie_taunts_5f;

}

// Initialize any animscript related variables
init_animscripts()
{
	// Setup the animscripts, then override them (we call this just incase an AI has not yet spawned)
	animscripts\init::firstInit();

	anim.idleAnimArray		["stand"] = [];
	anim.idleAnimWeights	["stand"] = [];
	anim.idleAnimArray		["stand"][0][0] 	= %ai_zombie_idle_v1_delta;
	anim.idleAnimWeights	["stand"][0][0] 	= 10;

	anim.idleAnimArray		["crouch"] = [];
	anim.idleAnimWeights	["crouch"] = [];	
	anim.idleAnimArray		["crouch"][0][0] 	= %ai_zombie_idle_crawl_delta;
	anim.idleAnimWeights	["crouch"][0][0] 	= 10;
}

// Handles the intro screen
zombie_intro_screen( string1, string2, string3, string4, string5 )
{
	flag_wait( "all_players_connected" );

	wait( 1 );

	//TUEY Set music state to Splash Screencompass
	setmusicstate( "SPLASH_SCREEN" );
	wait (0.2);

	players = get_players(); // co-op failsafe because some stupid engine thing is resetting our cheat protected dvars right when we load in, so we wait a second and then change them again here
	for( i = 0; i < players.size; i++ )
	{
		players[i] SetClientDvars(
		"player_backSpeedScale", "0.9",
		"player_strafeSpeedScale", "0.9",
		"player_sprintStrafeSpeedScale", "0.8",
		"aim_automelee_range", "96",
        "aim_automelee_lerp", "50",
        "player_meleechargefriction", "2500",
        "dynEnt_spawnedLimit", level.dynEnt_spawnedLimit,
		"aim_autobayonet_range", "100",
		"cg_hudDamageIconTime", "2500", // fixed damage marks from disappearing too quick
		"cg_firstPersonTracerchance", "0.5", // can see bullet tracers as you shoot in 1st person now
		"player_aimblend_back_low", "0 0.3 0.5", // 3rd person look up/down
		"playerSpectating", "0"
		 ); 	
	}
	//TUEY Set music state to WAVE_1
	//	setmusicstate("WAVE_1");
}

players_playing()
{
	// initialize level.players_playing
	players = get_players();
	level.players_playing = players.size;

	wait( 20 );

	players = get_players();
	level.players_playing = players.size;
	for( i = 0; i < players.size; i++ )
	{
		players[i] SetClientDvars(
		"player_backSpeedScale", "0.9",
		"player_strafeSpeedScale", "0.9",
		"player_sprintStrafeSpeedScale", "0.8",
		"aim_automelee_range", "96",
        "aim_automelee_lerp", "50",
        "player_meleechargefriction", "2500",
        "dynEnt_spawnedLimit", level.dynEnt_spawnedLimit,
		"aim_autobayonet_range", "100",
		"cg_hudDamageIconTime", "2500", // fixed damage marks from disappearing too quick
		"cg_firstPersonTracerchance", "0.5", // can see bullet tracers as you shoot in 1st person now
		"player_aimblend_back_low", "0 0.3 0.5", // 3rd person look up/down
		"playerSpectating", "0"
		); 

	}
}

//
// NETWORK SECTION ====================================================================== //
//

watchGrenadeThrow()
{
	self endon( "disconnect" ); 
	self endon( "death" );

	while(1)
	{
		self waittill("grenade_fire", grenade);

		if(isdefined(grenade))
		{
			if(self maps\_laststand::player_is_in_laststand() || level.falling_down == true )
			{
				wait(0.05);
				grenade delete();
			}
		}
	}
}

wait_for_sticky_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 
	
	for( ;; )
	{
		self waittill( "grenade_fire", sticky, weap );
		if( weap == "st_grenade" )
		{
			self thread sticky_grenade(sticky);
		}

	}
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player ); 

		player.entity_num = player GetEntityNumber(); 
		player thread onPlayerSpawned(); 
		player thread onPlayerDisconnect(); 
		player thread player_revive_monitor();
		player thread watchGrenadeThrow();

		player thread maps\walking_anim::main();

		player thread track_ammo_count();

		player thread maps\nazi_zombie_sumpf_bouncing_betties::bouncing_betty_watch(); 
		player thread maps\nazi_zombie_sumpf_bouncing_betties::betty_no_weapons(); 

		player thread wait_for_sticky_fired(); 

		player thread maps\_zombiemode_molotov::trackMolotov(); 

		player thread getAimAssistDvar();

		player.score = level.zombie_vars["zombie_score_start"]; 
		player.score_total = player.score; 
		player.old_score = player.score; 

		player.is_zombie = false; 
		player.initialized = false;
		player.zombification_time = 0;
	}
}

onPlayerConnect_clientDvars()
{
	self SetClientDvars( "cg_deadChatWithDead", "1",
		"cg_deadChatWithTeam", "1",
		"cg_deadHearTeamLiving", "1",
		"cg_deadHearAllLiving", "1",
		"cg_everyoneHearsEveryone", "1",
		"g_deadchat", "1",
		"compass", "0",
		"hud_showStance", "0",
		"cg_thirdPerson", "0",
		"cg_thirdPersonAngle", "0",
		"ammoCounterHide", "0",
		"miniscoreboardhide", "0",
		"ui_hud_hardcore", "0" );

	self SetClientDvars(
		"aim_automelee_range", "96", // less likely to lunge
        "aim_automelee_lerp", "50",  // lunge is quicker
        "player_meleechargefriction", "2500", //"stickiness " when knifing
		"aim_autobayonet_range", "100", // less likely to lunge with bayonet
		"player_backSpeedScale", "0.9", // back speed faster, similar to console
		"player_strafeSpeedScale", "0.9", // buffed strafe
		"player_sprintStrafeSpeedScale", "0.8", // buffed strafe
		"playerSpectating", "0", // spectating hud
		"cg_firstPersonTracerchance", "0.5", // can see bullet tracers as you shoot in 1st person now
		"player_aimblend_back_low", "0 0.3 0.5", // 3rd person look up/down
		"cg_hudDamageIconTime", "2500" ); // fixed damage marks from disappearing too quick

	self SetClientDvars(
		"cg_overheadIconsize", "0",
        "cg_overheadRanksize", "0"); 

	if( getDvar( "classic_perks" ) == "" || getDvar("classic_perks") == "0" ) // if dvar doesn't exist or is disabled, we stay default
	{
		//self SetClientDvars( "classic_perks", 0 );
		self setclientdvar("player_lastStandBleedoutTime", 45);
	}
	else if( getDvar( "classic_perks" ) == "1" )
	{
		//self SetClientDvars( "classic_perks", 1 );
		self setclientdvar("player_lastStandBleedoutTime", 30);
	}
	self FreezeControls( false );

	self SetDepthOfField( 0, 0, 512, 4000, 4, 0 );

}


onPlayerDisconnect()
{
	self waittill( "disconnect" ); 
	self remove_from_spectate_list();
}

onPlayerSpawned()
{
	self endon( "disconnect" ); 

	for( ;; )
	{
		self waittill( "spawned_player" ); 
		players = getplayers();
		if(players.size > 1)
		{
			self SetClientDvar( "cg_ScoresColor_Gamertag_0" , "1 1 1 1" );
			self SetClientDvar( "cg_ScoresColor_Gamertag_1" , GetDvar( "cg_ScoresColor_Gamertag_1") );
			self SetClientDvar( "cg_ScoresColor_Gamertag_2" , GetDvar( "cg_ScoresColor_Gamertag_2") );
			self SetClientDvar( "cg_ScoresColor_Gamertag_3" , GetDvar( "cg_ScoresColor_Gamertag_3") );
			level.solo_egg = 0;
		}
		self SetClientDvars(
			"cg_overheadIconsize", "0",
	        "cg_overheadRanksize", "0"); 
		
		self.can_solo_revive = false;

		self SetClientDvars( "cg_thirdPerson", "0",
			//"cg_fov", "80",
			"cg_thirdPersonAngle", "0" );

		self SetDepthOfField( 0, 0, 512, 4000, 4, 0 );

		self add_to_spectate_list();

		self SetClientDvars(
		"player_backSpeedScale", "0.9",
		"player_strafeSpeedScale", "0.9",
		"player_sprintStrafeSpeedScale", "0.8",
		"playerSpectating", "0", // spectating hud
		"aim_automelee_range", "96",
        "aim_automelee_lerp", "50",
        "player_meleechargefriction", "2500",
		"aim_autobayonet_range", "100",
		"cg_firstPersonTracerchance", "0.5", // can see bullet tracers as you shoot in 1st person now
		"player_aimblend_back_low", "0 0.3 0.5", // 3rd person look up/down
		"cg_hudDamageIconTime", "2500" );
     
     	self setClientDvar( "bg_fallDamageMinHeight", "150" );
		self setClientDvar( "player_deathInvulnerableToProjectile", "0" );
		self setClientDvar( "player_deathInvulnerableTime", "0" );
		self setClientDvar( "player_deathInvulnerableToMelee", "0" );

		self FreezeControls( false );

		if( getDvar( "classic_perks" ) == "" || getDvar("classic_perks") == "0" ) // if dvar doesn't exist or is disabled, we stay default
		{
			self setclientdvar("player_lastStandBleedoutTime", 45);
		}
		else if( getDvar( "classic_perks" ) == "1" )
		{
			self setclientdvar("player_lastStandBleedoutTime", 30);
		}

		if( isdefined( self.initialized ) )
		{
			if( self.initialized == false )
			{
				self.initialized = true; 
				//				self maps\_zombiemode_score::create_player_score_hud(); 

				// set the initial score on the hud		
				self maps\_zombiemode_score::set_player_score_hud( true ); 
				self thread player_zombie_breadcrumb();
				self thread player_reload();

				//Init stat tracking variables
				self.stats["kills"] = 0;
				self.stats["score"] = 0;
				self.stats["downs"] = 0;
				self.stats["revives"] = 0;
				self.stats["perks"] = 0;
				self.stats["headshots"] = 0;
				self.stats["zombie_gibs"] = 0;
			}
		}
	}
}

//
//	Keep track of players going down and getting revived
player_revive_monitor()
{
	self endon( "disconnect" ); 

	while (1)
	{
		self waittill( "player_revived", reviver );	

		if ( IsDefined(reviver) && (get_players().size != 1) )

		{
			// Check to see how much money you lost from being down.
			points = self.score_lost_when_downed;
			if ( points > 300 )
			{
				points = 300;
			}
			reviver maps\_zombiemode_score::add_to_player_score( points );
			self.score_lost_when_downed = 0;
			self thread maps\_zombiemode_perks::say_revived_vo();
		}
	}
}


player_laststand()
{
	self maps\_zombiemode_score::player_downed_penalty();
	self thread maps\_zombiemode_perks::say_down_vo();
	if( IsDefined( self.intermission ) && self.intermission )
	{
		maps\_challenges_coop::doMissionCallback( "playerDied", self );

		level waittill( "forever" );
	}
}

spawnSpectator()
{
	self endon( "disconnect" ); 
	self endon( "spawned_spectator" ); 
	self notify( "spawned" ); 
	self notify( "end_respawn" );

	//setClientSysState( "levelNotify", "fov_death", self );

	if( level.intermission )
	{
		return;
	}

	if( IsDefined( level.no_spectator ) && level.no_spectator )
	{
		wait( 3 );
		ExitLevel();
	}

	// The check_for_level_end looks for this
	self.is_zombie = true;

	// Remove all reviving abilities
	self notify ( "zombified" );

	if( IsDefined( self.revivetrigger ) )
	{
		self.revivetrigger delete();
		self.revivetrigger = undefined;
	}

	self.zombification_time = getTime(); //set time when player died

	resetTimeout(); 

	// Stop shellshock and rumble
	self StopShellshock(); 
	self StopRumble( "damage_heavy" ); 

	self.sessionstate = "spectator"; 
	self.spectatorclient = -1;

	self remove_from_spectate_list();

	self.maxhealth = self.health;
	self.shellshocked = false; 
	self.inWater = false; 
	self.friendlydamage = undefined; 
	self.hasSpawned = true; 
	self.spawnTime = getTime(); 
	self.afk = false; 

	println( "*************************Zombie Spectator***" );
	self detachAll();

	self setSpectatePermissions( true );
	self thread spectator_thread();

	self Spawn( self.origin, self.angles );
	self notify( "spawned_spectator" );
}

setSpectatePermissions( isOn )
{
	self AllowSpectateTeam( "allies", isOn );
	self AllowSpectateTeam( "axis", false );
	self AllowSpectateTeam( "freelook", false );
	self AllowSpectateTeam( "none", false );	
}

spectator_thread()
{
	self endon( "disconnect" ); 
	self endon( "spawned_player" );

	if( IsSplitScreen() )
	{
		last_alive = undefined;
		players = get_players();

		for( i = 0; i < players.size; i++ )
		{
			if( !players[i].is_zombie )
			{
				last_alive = players[i];
			}
		}

		share_screen( last_alive, true );

		return;
	}

	self thread spectator_toggle_3rd_person();
}

spectator_toggle_3rd_person()
{
	self endon( "disconnect" ); 
	self endon( "spawned_player" ); // If a player respawns
	level endon( "intermission" ); // Game over, if all players die
	
	self SetClientDvars( "playerSpectating", "1", "cg_thirdPerson", "1", "cg_thirdPersonAngle", "354" );
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
	wait(0.1); // ensure that we save our fov before we mess with it below
	wait_network_frame();
	// We start by setting up everything for 3rd person, only below do we start the toggling if a player so chooses
	self SetClientDvars("cg_fov", "40");

	third_person = true;

	self thread reset_spec_hud();

    while(1)
    {
    	for(;;)
    	{
    		if(self useButtonPressed ())
    		{
    			break;
    		}
    		else
    		{
    			wait(0.05);
    			continue;
    		}
    	}

    	third_person = !third_person;
        self set_third_person(third_person);

		wait(0.5);
    }
}

set_third_person( value )
{
	if( value )
	{
		self SetClientDvars( "cg_thirdPerson", "1", "cg_thirdPersonAngle", "354", "cg_fov", "40" );
		
		self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
	}
	else
	{
		self SetClientDvars( "cg_thirdPerson", "0", "cg_thirdPersonAngle", "0", "cg_fov", "65" );
		
		self setDepthOfField( 0, 0, 512, 4000, 4, 0 );
	}
}

reset_spec_hud()
{
	self waittill_any( "spawned_player", "fix_your_fov" );
	
	setClientSysState( "levelNotify", "fov_reset", self );
	
	self SetClientDvar("playerSpectating", "0");
}

spectators_respawn()
{
	level endon( "between_round_over" );

	if( !IsDefined( level.zombie_vars["spectators_respawn"] ) || !level.zombie_vars["spectators_respawn"] )
	{
		return;
	}

	if( !IsDefined( level.custom_spawnPlayer ) )
	{
		// Custom spawn call for when they respawn from spectator
		level.custom_spawnPlayer = ::spectator_respawn;
	}

	while( 1 )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i].sessionstate == "spectator" )
			{
				players[i] [[level.spawnPlayer]]();
				if (isDefined(level.script) && level.round_number > 6 && players[i].score < 1500)
				{
					players[i].old_score = players[i].score;
					players[i].score = 1500;
					players[i] maps\_zombiemode_score::set_player_score_hud();
				}
				players[i] giveweapon( "stielhandgranate" );	// re-init grenades
				players[i] setweaponammoclip( "stielhandgranate", 0);
				if( isDefined( players[i].has_special_weap ) && players[i].has_special_weap )
				{
					wait(0.1);
					players[i] setactionslot(1,"weapon", players[i].has_special_weap ); 

					if(players[i].has_special_weap == "zombie_item_journal")
					{
						if(level.intel_obtained < 3) // if journal we only give it back if we haven't completed the intel, but once we have 3 intel we don't need the actual wep
						{
							players[i] giveweapon( players[i].has_special_weap ); 
						}
					}
					else if(players[i].has_special_weap == "zombie_item_radio")
					{
						if(	level.radio_finished == false ) // if radio step is not done we have to give back actual radio
						{
							players[i] giveweapon( players[i].has_special_weap ); 
						}
					}
					else if(players[i].has_special_weap == "zombie_item_vodka")
					{
						if(	isDefined(players[i].not_drunk) && players[i].not_drunk == true ) // only give it back if we haev not drunk it
						{
							players[i] giveweapon( players[i].has_special_weap ); 
						}						
					}
					else
					{
						players[i] giveweapon( players[i].has_special_weap ); 
					}
				}

			}
		}

		wait( 1 );
	}
}

spectator_respawn()
{
	println( "*************************Respawn Spectator***" );
	assert( IsDefined( self.spectator_respawn ) );

	origin = self.spectator_respawn.origin;
	angles = self.spectator_respawn.angles;

	self setSpectatePermissions( false );
	
	new_origin = undefined;
	
	/#
	new_origin = check_for_valid_spawn_near_team( self );
	#/

	if( IsDefined( new_origin ) )
	{
		self Spawn( new_origin, angles );
	}
	else
	{
		self Spawn( origin, angles );
	}


	if( IsSplitScreen() )
	{
		last_alive = undefined;
		players = get_players();

		for( i = 0; i < players.size; i++ )
		{
			if( !players[i].is_zombie )
			{
				last_alive = players[i];
			}
		}

		share_screen( last_alive, false );
	}

	self.has_betties = undefined;
	self.is_burning = undefined;

	// The check_for_level_end looks for this
	self.is_zombie = false;
	self.ignoreme = false;

	setClientSysState("lsm", "0", self);	// Notify client last stand ended.
	self RevivePlayer();

	self notify( "spawned_player" );

	self SetClientDvar("playerSpectating", "0");

	// Penalize the player when we respawn, since he 'died'
	self maps\_zombiemode_score::player_reduce_points( "died" );

	self thread player_zombie_breadcrumb();

	return true;
}

check_for_valid_spawn_near_team( revivee )
{


	players = get_players();
	spawn_points = getstructarray("player_respawn_point", "targetname");

	if( spawn_points.size == 0 )
		return undefined;

	for( i = 0; i < players.size; i++ )
	{
		if( is_player_valid( players[i] ) )
		{
			for( j = 0 ; j < spawn_points.size; j++ )
			{
				if( DistanceSquared( players[i].origin, spawn_points[j].origin ) < ( 1000 * 1000 ) )
				{
					spawn_array = getstructarray( spawn_points[j].target, "targetname" );

					for( k = 0; k < spawn_array.size; k++ )
					{
						if( spawn_array[k].script_int == (revivee.entity_num + 1) )
						{
							return spawn_array[k].origin; 
						}
					}	

					return spawn_array[0].origin;
				}

			}

		}

	}

	return undefined;

}


get_players_on_team(exclude)
{

	teammates = [];

	players = get_players();
	for(i=0;i<players.size;i++)
	{		
		//check to see if other players on your team are alive and not waiting to be revived
		if(players[i].spawn_side == self.spawn_side && !isDefined(players[i].revivetrigger) && players[i] != exclude )
		{
			teammates[teammates.size] = players[i];
		}
	}

	return teammates;
}



get_safe_breadcrumb_pos( player )
{
	players = get_players();
	valid_players = [];

	min_dist = 150 * 150;
	for( i = 0; i < players.size; i++ )
	{
		if( !is_player_valid( players[i] ) )
		{
			continue;
		}

		valid_players[valid_players.size] = players[i];
	}

	for( i = 0; i < valid_players.size; i++ )
	{
		count = 0;
		for( q = 1; q < player.zombie_breadcrumbs.size; q++ )
		{
			if( DistanceSquared( player.zombie_breadcrumbs[q], valid_players[i].origin ) < min_dist )
			{
				continue;
			}
			
			count++;
			if( count == valid_players.size )
			{
				return player.zombie_breadcrumbs[q];
			}
		}
	}

	return undefined;
}

round_spawning()
{
	level endon( "intermission" );
	level endon( "stop_round_spawning" );
/#
	level endon( "kill_round" );
#/

	if( level.intermission )
	{
		return;
	}

	if( level.enemy_spawns.size < 1 )
	{
		ASSERTMSG( "No spawners with targetname zombie_spawner in map." ); 
		return; 
	}

/#
	if ( GetDVarInt( "zombie_cheat" ) == 2 || GetDVarInt( "zombie_cheat" ) >= 4 ) 
	{
		return;
	}
#/

	ai_calculate_health(); 

	count = 0; 

	//CODER MOD: TOMMY K
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		players[i].zombification_time = 0;
	}

	max = level.zombie_vars["zombie_max_ai"];

	multiplier = level.round_number / 5;
	if( multiplier < 1 )
	{
		multiplier = 1;
	}

	// After round 10, exponentially have more AI attack the player
	if( level.round_number >= 10 )
	{
		multiplier *= level.round_number * 0.15;
	}

	player_num = get_players().size;

	if( player_num == 1 && getDvarInt( "classic_zombies") == 1 )
	{
		max += 0;
	}
	else if( player_num == 1 )
	{
		max += int( ( 0.5 * level.zombie_vars["zombie_ai_per_player"] ) * multiplier ); 
	}
	else
	{
		max += int( ( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] ) * multiplier ); 
	}


	
	if ( level.first_round )
	{
		max = int( max * 0.2 );	
	}
	else if (level.round_number < 3)
	{
		max = int( max * 0.4 );
	}
	else if (level.round_number < 4)
	{
		max = int( max * 0.6 );
	}
	else if (level.round_number < 5)
	{
		max = int( max * 0.8 );
	}


	level.zombie_total = max;
	mixed_spawns = 0;	// Number of mixed spawns this round.  Currently means number of dogs in a mixed round

	// DEBUG HACK:	
	//max = 1;
	old_spawn = undefined;
	while( count < max )
	{
		wait_network_frame();
		if(level.enemy_spawns.size <= 0)
		{
			wait(0.1);
			continue;
		}

        if(get_enemy_count() > 31)
		{
			wait(0.05);
            continue;
		}
		
		spawn_point = level.enemy_spawns[RandomInt( level.enemy_spawns.size )]; 

		if( !IsDefined( old_spawn ) )
		{
				old_spawn = spawn_point;
		}
		else if( Spawn_point == old_spawn )
		{
				spawn_point = level.enemy_spawns[RandomInt( level.enemy_spawns.size )]; 
		}
		old_spawn = spawn_point;


		ai = spawn_zombie( spawn_point ); 
		if( IsDefined( ai ) )
		{
			level.zombie_total--;
			ai thread round_spawn_failsafe();
			count++; 
		}
		wait( level.zombie_vars["zombie_spawn_delay"] ); 
		wait_network_frame();
	}

	if( level.round_number > 3 )
	{
		zombies = getaiarray( "axis" );
		while( zombies.size > 0 )
		{
			if( zombies.size == 1 && zombies[0].has_legs == true && (!isSubStr(zombies[0].current_speed, "sprint") ) ) //if already a sprinter, we don't reset their anim to prevent issues w super sprinters
			{
				var = randomintrange(1, 3);
				zombies[0] set_run_anim( "sprint" + var );                       
				zombies[0].run_combatanim = level.scr_anim[zombies[0].animname]["sprint" + var];
			}
			wait(0.5);
			zombies = getaiarray("axis");
		}

	}

}

// TESTING: spawn one zombie at a time
round_spawning_test()
{
	while (true)
	{
		spawn_point = level.enemy_spawns[RandomInt( level.enemy_spawns.size )];	// grab a random spawner

		ai = spawn_zombie( spawn_point );
		ai waittill("death");

		wait 5;
	}
}
/////////////////////////////////////////////////////////

round_text( text )
{
	if( level.first_round )
	{
		intro = true;
	}
	else
	{
		intro = false;
	}

	hud = create_simple_hud();
	hud.horzAlign = "center"; 
	hud.vertAlign = "middle";
	hud.alignX = "center"; 
	hud.alignY = "middle";
	hud.y = -100;
	hud.foreground = 1;
	hud.fontscale = 16.0;
	hud.alpha = 0; 
	hud.color = ( 1, 1, 1 );

	hud SetText( text ); 
	hud FadeOverTime( 1.5 );
	hud.alpha = 1;
	wait( 1.5 );

	if( intro )
	{
		wait( 1 );
		level notify( "intro_change_color" );
	}

	hud FadeOverTime( 3 );
	//hud.color = ( 0.8, 0, 0 );
	hud.color = ( 0.423, 0.004, 0 );
	wait( 3 );

	if( intro )
	{
		level waittill( "intro_hud_done" );
	}

	hud FadeOverTime( 1.5 );
	hud.alpha = 0;
	wait( 1.5 ); 
	hud destroy();
}

round_start()
{
	level.zombie_health = level.zombie_vars["zombie_health_start"]; 
	level.round_number = 1; 
	level.first_round = true;

	// so players get init'ed with grenades
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] giveweapon( "stielhandgranate" );	
		players[i] setweaponammoclip( "stielhandgranate", 0);
		players[i] SetClientDvars( "ammoCounterHide", "0", "miniscoreboardhide", "0" );	 // fail safe incase our hud is still hidden
	}

	level.chalk_hud1 = create_chalk_hud( 2 );
	level.chalk_hud2 = create_chalk_hud( 66 );

	//	level waittill( "introscreen_done" );
	
	level.round_spawn_func = ::round_spawning;

	/#
		if (GetDVarInt("zombie_rise_test"))
		{
			level.round_spawn_func = ::round_spawning_test;		// FOR TESTING, one zombie at a time, no round advancement
		}
	#/

	level thread round_think(); 
}


create_chalk_hud( x )
{
	if( !IsDefined( x ) )
	{
		x = 0;
	}

	hud = create_simple_hud();
	hud.alignX = "left"; 
	hud.alignY = "bottom";
	hud.horzAlign = "left"; 
	hud.vertAlign = "bottom";
	hud.color = ( 0.423, 0.004, 0 );
	hud.x = x; 
	hud.alpha = 0;

	hud SetShader( "hud_chalk_1", 64, 64 );

	return hud;
}
play_intro_VO()
{
	
	wait(3);
	players = getplayers();	
	for(i=0;i<players.size;i++)
	{
		index = maps\_zombiemode_weapons::get_player_index(players[i]);
		player_index = "plr_" + index + "_";
		sound_to_play = "vox_name_int_0";
		players[i] 	maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.05);
		wait(0.7);
	}

	//Plays a random start line on one of the characters
//	i = randomintrange(0,players.size);
//	players[i] playsound ("plr_" + i + "_vox_start" + "_" + randomintrange(0, variation_count));
	
}
wait_until_first_player()
{
	players = get_players();
	if( !IsDefined( players[0] ) )
	{
		level waittill( "first_player_ready" );
	}
}
chalk_one_up()
{
	
	if(!IsDefined(level.doground_nomusic))
	{
		level.doground_nomusic = 0;
	}
	if( level.first_round )
	{
		intro = true;
		//Play the intro sound at the beginning of the round
	 	//level thread play_intro_VO(); (commented out for Corky)

	}
	else
	{
		intro = false;
	}

	round = undefined;	
	if( intro )
	{
		round = create_simple_hud();
		round.alignX = "center"; 
		round.alignY = "bottom";
		round.horzAlign = "center"; 
		round.vertAlign = "bottom";
		round.fontscale = 16;
		round.color = ( 1, 1, 1 );
		round.x = 0;
		round.y = -265;
		round.alpha = 0;
		round SetText( &"ZOMBIE_ROUND" );

		round FadeOverTime( 1 );
		round.alpha = 1;
		wait( 1 );

		round FadeOverTime( 3 );
		//		round.color = ( 0.8, 0, 0 );
		round.color = ( 0.423, 0.004, 0 );
	}

	hud = undefined;
	if( level.round_number < 6 || level.round_number > 10 )
	{
		hud = level.chalk_hud1;
		hud.fontscale = 32;
	}
	else if( level.round_number < 11 )
	{
		hud = level.chalk_hud2;

      	if(level.round_number == 6)
        	hud.color = (1, 1, 1);
	}

	if( intro )
	{
		hud.alpha = 0;
		hud.horzAlign = "center";
		hud.x = -5;
		hud.y = -200;
	}

	hud FadeOverTime( 0.5 );
	hud.alpha = 0;

	if( level.round_number == 11 && IsDefined( level.chalk_hud2 ) )
	{
		level.chalk_hud2 FadeOverTime( 0.5 );
		level.chalk_hud2.alpha = 0;
	}

	wait( 0.5 );

	//	play_sound_at_pos( "chalk_one_up", ( 0, 0, 0 ) );

	if(IsDefined(level.eggs) && level.eggs != 1 && level.intermission == false )
	{
		if(level.doground_nomusic ==0 )
		{
			setmusicstate("round_begin");	
		}
		
	}

	if( level.round_number == 11 && IsDefined( level.chalk_hud2 ) )
	{
		level.chalk_hud2 destroy_hud();
	}

	if( level.round_number > 10 )
	{
		hud SetValue( level.round_number );
	}

	hud FadeOverTime( 0.5 );
	hud.alpha = 1;

	if( intro )
	{
		wait( 3 );

		if( IsDefined( round ) )
		{
			round FadeOverTime( 1 );
			round.alpha = 0;
		}

		wait( 0.25 );

		level notify( "intro_hud_done" );
		hud MoveOverTime( 1.75 );
		hud.horzAlign = "left";
		//		hud.x = 0;
		hud.x = 2;
		hud.y = 0;
		wait( 2 );

		round destroy_hud();
	}

	if( level.round_number > 10 )
	{
	}
	else if( level.round_number > 5 )
	{
		hud SetShader( "hud_chalk_" + ( level.round_number - 5 ), 64, 64 );
	}
	else if( level.round_number > 1 )
	{
		hud SetShader( "hud_chalk_" + level.round_number, 64, 64 );
	}	
/*
	else 
	{
		setmusicstate("WAVE_1");
	}
*/	

	//	ReportMTU(level.round_number);	// In network debug instrumented builds, causes network spike report to generate.
}


chalk_round_hint()
{
	huds = [];
	huds[huds.size] = level.chalk_hud1;

	if( level.round_number > 5 && level.round_number < 11 )
	{
		huds[huds.size] = level.chalk_hud2;
	}

	time = level.zombie_vars["zombie_between_round_time"];
	for( i = 0; i < huds.size; i++ )
	{
		huds[i] FadeOverTime( time * 0.25 );
		huds[i].color = ( 1, 1, 1 );
	}
	if(IsDefined(level.eggs) && level.eggs != 1 && level.intermission == false)
	{
		if(IsDefined(level.doground_nomusic && level.doground_nomusic == 0 ))
		{
			setmusicstate("round_end");
		}
		else if(IsDefined(level.doground_nomusic  && level.doground_nomusic == 1 ))
		{
			play_sound_2D( "bright_sting" );
		}
	}

	if(IsDefined(level.doground_nomusic && level.doground_nomusic == 0 ))
	{
		wait( time * 0.25 );
	}
	//	play_sound_at_pos( "end_of_round", ( 0, 0, 0 ) );

 	prev_round = level.round_number;

	// Pulse
	fade_time = 0.5;
	steps =  ( time * 0.5 ) / fade_time;
	for( q = 0; q < steps; q++ )
	{
		for( i = 0; i < huds.size; i++ )
		{
			if( !IsDefined( huds[i] ) )
			{
				continue;
			}

			huds[i] FadeOverTime( fade_time );
			huds[i].alpha = 0;
		}

		wait( fade_time );

        if(prev_round < level.round_number)
        {
            chalk_one_up();
            prev_round = level.round_number;
            
            // Makes the second chalk HUD on round 6 flash white too when it first appears (looks nicer) - Feli
            if(level.round_number == 6 && huds.size == 1 && IsDefined(level.chalk_hud2))
                huds[huds.size] = level.chalk_hud2;
        }

		for( i = 0; i < huds.size; i++ )
		{
			if( !IsDefined( huds[i] ) )
			{
				continue;
			}

			huds[i] FadeOverTime( fade_time );
			huds[i].alpha = 1;		
		}

		wait( fade_time );
	}

	for( i = 0; i < huds.size; i++ )
	{
		if( !IsDefined( huds[i] ) )
		{
			continue;
		}

		huds[i] FadeOverTime( time * 0.25 );
		//		huds[i].color = ( 0.8, 0, 0 );
		huds[i].color = ( 0.423, 0.004, 0 );
		huds[i].alpha = 1;
	}
}

round_think()
{
	for( ;; )
	{
		//////////////////////////////////////////
		//designed by prod DT#36173
		maxrepairs = 5 * level.round_number;
		if ( maxrepairs > 50 )
			maxrepairs = 50;
		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxrepairs;
		//////////////////////////////////////////

		level.round_timer = level.zombie_vars["zombie_round_time"]; 
		
		add_later_round_spawners();

		chalk_one_up();
		//		round_text( &"ZOMBIE_ROUND_BEGIN" );

		maps\_zombiemode_powerups::powerup_round_start();

		players = get_players();
		array_thread( players, maps\_zombiemode_blockers::rebuild_barrier_reward_reset );

		level thread award_grenades_for_survivors();

		level.round_start_time = getTime();
		level thread [[level.round_spawn_func]]();

		round_wait(); 
		level.first_round = false;

		level thread spectators_respawn();

		//		round_text( &"ZOMBIE_ROUND_END" );
		level thread chalk_round_hint();

		wait( level.zombie_vars["zombie_between_round_time"] ); 

		// here's the difficulty increase over time area
		timer = level.zombie_vars["zombie_spawn_delay"];

		if( timer < 0.08 )
		{
			timer = 0.08; 
		}	

		level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;

		// Increase the zombie move speed
		level.zombie_move_speed = level.round_number * 8;

		level.round_number++;

		level notify( "between_round_over" );
	}
}


award_grenades_for_survivors()
{
	players = get_players();

	for (i = 0; i < players.size; i++)
	{
		if (!players[i].is_zombie && !players[i] maps\_laststand::player_is_in_laststand() )
		{
			if( !players[i] HasWeapon( "stielhandgranate" ) )
			{
				players[i] GiveWeapon( "stielhandgranate" );	
				players[i] SetWeaponAmmoClip( "stielhandgranate", 0 );
			}

			if ( players[i] GetFractionMaxAmmo( "stielhandgranate") < .25 )
			{
				players[i] SetWeaponAmmoClip( "stielhandgranate", 2 );
			}
			else if (players[i] GetFractionMaxAmmo( "stielhandgranate") < .5 )
			{
				players[i] SetWeaponAmmoClip( "stielhandgranate", 3 );
			}
			else
			{
				players[i] SetWeaponAmmoClip( "stielhandgranate", 4 );
			}
		}
	}
}

ai_calculate_health()
{
	// After round 10, get exponentially harder
	if( level.round_number >= 10 )
	{
		level.zombie_health += Int( level.zombie_health * level.zombie_vars["zombie_health_increase_percent"] ); 
		return;
	}

	if( level.round_number > 1 )
	{
		level.zombie_health = Int( level.zombie_health + level.zombie_vars["zombie_health_increase"] ); 
	}

}

//put the conditions in here which should
//cause the failsafe to reset
round_spawn_failsafe()
{
	self endon("death");//guy just died

	//////////////////////////////////////////////////////////////
	//FAILSAFE "hack shit"  DT#33203
	//////////////////////////////////////////////////////////////
	prevorigin = self.origin;
	while(1)
	{
		if( !level.zombie_vars["zombie_use_failsafe"] )
		{
			return;
		}

		wait( 30 );

		//if i've torn a board down in the last 5 seconds, just 
		//wait 30 again.
		if ( isDefined(self.lastchunk_destroy_time) )
		{
			if ( (getTime() - self.lastchunk_destroy_time) < 5000 )
				continue; 
		}

		//fell out of world
		if ( self.origin[2] < level.zombie_vars["below_world_check"] )
		{
			self dodamage( self.health + 100, (0,0,0) );	
			break;
		}

		//hasnt moved 24 inches in 30 seconds?	
		if ( DistanceSquared( self.origin, prevorigin ) < 576 ) 
		{
			// DEBUG HACK
			self dodamage( self.health + 100, (0,0,0) );	
			break;
		}

		prevorigin = self.origin;
	}
	//////////////////////////////////////////////////////////////
	//END OF FAILSAFE "hack shit"
	//////////////////////////////////////////////////////////////
}

// Waits for the time and the ai to die
round_wait()
{
		wait( 1 );

		if( flag("dog_round" ) )
		{
			wait(7);
			while( level.dog_intermission )
			{
				wait(0.5);
			}
			
		}
		else
		{
			while( get_enemy_count() > 0 || level.zombie_total > 0 || level.intermission)
			{
				wait( 0.5 );
			}

		}
		
}

zombify_player()
{
	self maps\_zombiemode_score::player_died_penalty(); 

	if( !IsDefined( level.zombie_vars["zombify_player"] ) || !level.zombie_vars["zombify_player"] )
	{
		self thread spawnSpectator(); 
		return; 
	}

	self.ignoreme = true; 
	self.is_zombie = true; 
	self.zombification_time = getTime(); 

	self.team = "axis"; 
	self notify( "zombified" ); 

	if( IsDefined( self.revivetrigger ) )
	{
		self.revivetrigger Delete(); 
	}
	self.revivetrigger = undefined; 

	self setMoveSpeedScale( 0.3 ); 
	self reviveplayer(); 

	self TakeAllWeapons(); 
	self starttanning(); 
	self GiveWeapon( "zombie_melee", 0 ); 
	self SwitchToWeapon( "zombie_melee" ); 
	self DisableWeaponCycling(); 
	self DisableOffhandWeapons(); 
	self VisionSetNaked( "zombie_turned", 1 ); 

	maps\_utility::setClientSysState( "zombify", 1, self ); 	// Zombie grain goooo

	self thread maps\_zombiemode_spawner::zombie_eye_glow(); 

	// set up the ground ref ent
	self thread injured_walk(); 
	// allow for zombie attacks, but they lose points?

	self thread playerzombie_player_damage(); 
	self thread playerzombie_soundboard(); 
}

playerzombie_player_damage()
{
	self endon( "death" ); 
	self endon( "disconnect" ); 

	self thread playerzombie_infinite_health();  // manually keep regular health up
	self.zombiehealth = level.zombie_health; 

	// enable PVP damage on this guy
	// self EnablePvPDamage(); 

	while( 1 )
	{
		self waittill( "damage", amount, attacker, directionVec, point, type ); 

		if( !IsDefined( attacker ) || !IsPlayer( attacker ) )
		{
			wait( 0.05 ); 
			continue; 
		}

		self.zombiehealth -= amount; 

		if( self.zombiehealth <= 0 )
		{
			// "down" the zombie
			self thread playerzombie_downed_state(); 
			self waittill( "playerzombie_downed_state_done" ); 
			self.zombiehealth = level.zombie_health; 
		}
	}
}

playerzombie_downed_state()
{
	self endon( "death" ); 
	self endon( "disconnect" ); 

	downTime = 15; 

	startTime = GetTime(); 
	endTime = startTime +( downTime * 1000 ); 

	self thread playerzombie_downed_hud(); 

	self.playerzombie_soundboard_disable = true; 
	self thread maps\_zombiemode_spawner::zombie_eye_glow_stop(); 
	self DisableWeapons(); 
	self AllowStand( false ); 
	self AllowCrouch( false ); 
	self AllowProne( true ); 

	while( GetTime() < endTime )
	{
		wait( 0.05 ); 
	}

	self.playerzombie_soundboard_disable = false; 
	self thread maps\_zombiemode_spawner::zombie_eye_glow(); 
	self EnableWeapons(); 
	self AllowStand( true ); 
	self AllowCrouch( false ); 
	self AllowProne( false ); 

	self notify( "playerzombie_downed_state_done" ); 
}

playerzombie_downed_hud()
{
	self endon( "death" ); 
	self endon( "disconnect" ); 

	text = NewClientHudElem( self ); 
	text.alignX = "center"; 
	text.alignY = "middle"; 
	text.horzAlign = "center"; 
	text.vertAlign = "bottom"; 
	text.foreground = true; 
	text.font = "default"; 
	text.fontScale = 1.8; 
	text.alpha = 0; 
	text.color = ( 1.0, 1.0, 1.0 ); 
	text SetText( &"ZOMBIE_PLAYERZOMBIE_DOWNED" ); 

	text.y = -113; 	
	if( IsSplitScreen() )
	{
		text.y = -137; 
	}

	text FadeOverTime( 0.1 ); 
	text.alpha = 1; 

	self waittill( "playerzombie_downed_state_done" ); 

	text FadeOverTime( 0.1 ); 
	text.alpha = 0; 
}

playerzombie_infinite_health()
{
	self endon( "death" ); 
	self endon( "disconnect" ); 

	bighealth = 100000; 

	while( 1 )
	{
		if( self.health < bighealth )
		{
			self.health = bighealth; 
		}

		wait( 0.1 ); 
	}
}

playerzombie_soundboard()
{
	self endon( "death" ); 
	self endon( "disconnect" ); 

	self.playerzombie_soundboard_disable = false; 

	self.buttonpressed_use = false; 
	self.buttonpressed_attack = false; 
	self.buttonpressed_ads = false; 

	self.useSound_waitTime = 3 * 1000;  // milliseconds
	self.useSound_nextTime = GetTime(); 
	useSound = "playerzombie_usebutton_sound"; 

	self.attackSound_waitTime = 3 * 1000; 
	self.attackSound_nextTime = GetTime(); 
	attackSound = "playerzombie_attackbutton_sound"; 

	self.adsSound_waitTime = 3 * 1000; 
	self.adsSound_nextTime = GetTime(); 
	adsSound = "playerzombie_adsbutton_sound"; 

	self.inputSound_nextTime = GetTime();  // don't want to be able to do all sounds at once

	while( 1 )
	{
		if( self.playerzombie_soundboard_disable )
		{
			wait( 0.05 ); 
			continue; 
		}

		if( self UseButtonPressed() )
		{
			if( self can_do_input( "use" ) )
			{
				self thread playerzombie_play_sound( useSound ); 
				self thread playerzombie_waitfor_buttonrelease( "use" ); 
				self.useSound_nextTime = GetTime() + self.useSound_waitTime; 
			}
		}
		else if( self AttackButtonPressed() )
		{
			if( self can_do_input( "attack" ) )
			{
				self thread playerzombie_play_sound( attackSound ); 
				self thread playerzombie_waitfor_buttonrelease( "attack" ); 
				self.attackSound_nextTime = GetTime() + self.attackSound_waitTime; 
			}
		}
		else if( self AdsButtonPressed() )
		{
			if( self can_do_input( "ads" ) )
			{
				self thread playerzombie_play_sound( adsSound ); 
				self thread playerzombie_waitfor_buttonrelease( "ads" ); 
				self.adsSound_nextTime = GetTime() + self.adsSound_waitTime; 
			}
		}

		wait( 0.05 ); 
	}
}

can_do_input( inputType )
{
	if( GetTime() < self.inputSound_nextTime )
	{
		return false; 
	}

	canDo = false; 

	switch( inputType )
	{
	case "use":
		if( GetTime() >= self.useSound_nextTime && !self.buttonpressed_use )
		{
			canDo = true; 
		}
		break; 

	case "attack":
		if( GetTime() >= self.attackSound_nextTime && !self.buttonpressed_attack )
		{
			canDo = true; 
		}
		break; 

	case "ads":
		if( GetTime() >= self.useSound_nextTime && !self.buttonpressed_ads )
		{
			canDo = true; 
		}
		break; 

	default:
		ASSERTMSG( "can_do_input(): didn't recognize inputType of " + inputType ); 
		break; 
	}

	return canDo; 
}

playerzombie_play_sound( alias )
{
	self play_sound_on_ent( alias ); 
}

playerzombie_waitfor_buttonrelease( inputType )
{
	if( inputType != "use" && inputType != "attack" && inputType != "ads" )
	{
		ASSERTMSG( "playerzombie_waitfor_buttonrelease(): inputType of " + inputType + " is not recognized." ); 
		return; 
	}

	notifyString = "waitfor_buttonrelease_" + inputType; 
	self notify( notifyString ); 
	self endon( notifyString ); 

	if( inputType == "use" )
	{
		self.buttonpressed_use = true; 
		while( self UseButtonPressed() )
		{
			wait( 0.05 ); 
		}
		self.buttonpressed_use = false; 
	}

	else if( inputType == "attack" )
	{
		self.buttonpressed_attack = true; 
		while( self AttackButtonPressed() )
		{
			wait( 0.05 ); 
		}
		self.buttonpressed_attack = false; 
	}

	else if( inputType == "ads" )
	{
		self.buttonpressed_ads = true; 
		while( self AdsButtonPressed() )
		{
			wait( 0.05 ); 
		}
		self.buttonpressed_ads = false; 
	}
}

remove_ignore_attacker()
{
	self notify( "new_ignore_attacker" );
	self endon( "new_ignore_attacker" );
	self endon( "disconnect" );
	
	if( !isDefined( level.ignore_enemy_timer ) )
	{
		level.ignore_enemy_timer = 0.4;
	}
	
	wait( level.ignore_enemy_timer );
	
	self.ignoreAttacker = undefined;
}

player_damage_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	/*	
	if(self hasperk("specialty_armorvest") && eAttacker != self)
	{
			iDamage = iDamage * 0.75;
			iprintlnbold(idamage);
	}*/
	
	if( sMeansOfDeath == "MOD_FALLING" && (iDamage > self.maxhealth * 0.30) ) // only do shellshock on fall damage if damage is greater than 30% of health (if we have jug then basically we never get that then)
	{
		self stopShellshock();

		sMeansOfDeath = "MOD_EXPLOSIVE";
	}
	else if( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_HIT_BY_OBJECT" || sMeansOfDeath == "MOD_CRUSH" || sMeansOfDeath == "MOD_DROWN" ) // patch co-op restart from peter
	{
		sMeansOfDeath = "MOD_RIFLE_BULLET";
	}

	if( isDefined( eAttacker ) )
	{
		if( isDefined( self.ignoreAttacker ) && self.ignoreAttacker == eAttacker ) 
		{
			return;
		}
		
		if( isDefined( eAttacker.is_zombie ) && eAttacker.is_zombie )
		{
			self.ignoreAttacker = eAttacker;
			self thread remove_ignore_attacker();
		}
		
		if( isDefined( eAttacker.damage_mult ) )
		{
			iDamage *= eAttacker.damage_mult;
		}
		eAttacker notify( "hit_player" );
		if( level.player_is_speaking != 1 /*&& self.health > 50*/ )
		{
			self thread add_pain_vox();	
		}
	}
	finalDamage = iDamage;

	if (sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_GRENADE")  // For all grenade explosive damage. Molotovs, M1 Launcher, Frags, and anything else
	{
		if( self.health > 75 )
		{
			if(isSubStr(sWeapon, "molotov") )
			{
				finalDamage = radiusDamage(eInflictor.origin, 200,120,50, eAttacker); 
			}
			else if(isSubStr(sWeapon, "st_grenade") ) // Sticky grenade
			{
				finalDamage = radiusDamage(eInflictor.origin, 180,115,40, eAttacker);
			}
			else if(isSubStr(sWeapon, "m7_launcher") ) 
			{
				finalDamage = radiusDamage(eInflictor.origin, 200,125,50, eAttacker);
			}
			else // For frags (and all other cases)
			{
				finalDamage = radiusDamage(eInflictor.origin, 256,120,50, eAttacker);
			}
			// Inner radius damage is always above 100, so that right below you it will kill you with no Jug
			self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
			return;
		}
	}

	if (sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_PROJECTILE")  // For all projectile explosive damage. Ray Gun, Panzer, Waffle, and anything else
	{
		if( self.health > 75 )
		{
			if(isSubStr(sWeapon, "panzer") || isSubStr(sWeapon, "bazooka"))
			{
				finalDamage = radiusDamage(eInflictor.origin, 256,125,50, eAttacker);
			}
			else if(isSubStr(sWeapon, "ray_gun") ) 
			{
				finalDamage = 80;
			}
			else if(isSubStr(sWeapon, "tesla_gun") ) 
			{
				if(self.health > 90 )
				{
					finalDamage = 90;	
				}
				else
				{
					finalDamage = 75;
				}
			}
			else // For anything else, do Vanilla damage
			{
				finalDamage = 75;	
			}

			self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
			return;
		}
	}

	if( iDamage < self.health )
	{
		if ( IsDefined( eAttacker ) )
		{
			eAttacker.sound_damage_player = self;
		}
		
		//iprintlnbold(iDamage);
		self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
		return;
	}
	if( level.intermission )
	{
		level waittill( "forever" );
	}

	players = get_players();
	count = 0;
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] == self || players[i].is_zombie || players[i] maps\_laststand::player_is_in_laststand() || players[i].sessionstate == "spectator" )
		{
			count++;
		}
	}


// SOLO REVIVE
	if( players.size == 1 && getdvarint("classic_perks") == 0 )
	{
		if( self HasPerk( "specialty_quickrevive" ) )
		{
			self UnsetPerk( "specialty_quickrevive" );

			self.can_solo_revive = true;
			self thread maps\_laststand::PlayerLastStand( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );
		
			self thread maps\_zombie_poi::init();

			self thread silent_while_down();

			wait(10.5);

			if(GetDvarInt("character_dialog") == 0)
			{
				level.player_is_speaking = 0;
			}
			self thread maps\_zombiemode_perks::say_revived_vo();
			return;
		}
		else
		{
			self.can_solo_revive = false;
		}
	}

	if( count < players.size )
	{
		self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
		return;
	}

	self.intermission = true;

	self thread maps\_laststand::PlayerLastStand( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );
	self player_fake_death();

	if( count == players.size )
	{
		level notify( "end_game" );
		level.remove_ee_ef = 1;
	}
	else
	{
		self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
	}
}

end_game()
{

	level waittill ( "end_game" );

	level.intermission = true;

	if( getDvarInt( "sv_cheats") != 1 )
	{
		update_leaderboards();
	}

	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		setClientSysState( "lsm", "0", players[i] );
	}
	
	self StopShellshock(); 
	self StopRumble( "damage_heavy" ); 

	level.zombie_vars["zombie_powerup_insta_kill_time"] = 0;
	level.zombie_vars["zombie_powerup_point_doubler_time"] = 0;
	wait 0.1;

	game_over = NewHudElem( self );
	game_over.alignX = "center";
	game_over.alignY = "middle";
	game_over.horzAlign = "center";
	game_over.vertAlign = "middle";
	game_over.y -= 10;
	game_over.foreground = true;
	game_over.fontScale = 3;
	game_over.alpha = 0;
	game_over.color = ( 1.0, 1.0, 1.0 );
	game_over SetText( &"ZOMBIE_GAME_OVER" );

	game_over FadeOverTime( 1 );
	game_over.alpha = 1;

	survived = NewHudElem( self );
	survived.alignX = "center";
	survived.alignY = "middle";
	survived.horzAlign = "center";
	survived.vertAlign = "middle";
	survived.y += 20;
	survived.foreground = true;
	survived.fontScale = 2;
	survived.alpha = 0;
	survived.color = ( 1.0, 1.0, 1.0 );

	if( level.round_number < 2 )
	{
		survived SetText( &"ZOMBIE_SURVIVED_ROUND" );
	}
	else
	{
		survived SetText( &"ZOMBIE_SURVIVED_ROUNDS", level.round_number );
	}
	//TUEY had to change this since we are adding other musical elements
	setmusicstate("end_of_game");
	setbusstate("default");
	
	survived FadeOverTime( 1 );
	survived.alpha = 1;
	
	destroy_chalk_hud();

	wait( 1 );
	//play_sound_at_pos( "end_of_game", ( 0, 0, 0 ) );
	wait( 2 );
	level.player_is_speaking = 1;

	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] SetClientDvars( "ammoCounterHide", "1",
				"miniscoreboardhide", "1" );
		
		
	}
	
	intermission();

	wait( level.zombie_vars["zombie_intermission_time"] );

	level notify( "stop_intermission" );
	array_thread( get_players(), ::player_exit_level );
	setmusicstate( "SILENT" );

	wait( 1.5 );

	if( is_coop() )
	{
		wait(3.5); // extra lil wait because sometimes co-op lobbies the intermission cuts off early since music can start a bit later
		ExitLevel( false );
	}
	else
	{
		MissionFailed();
	}



	// Let's not exit the function
	wait( 666 );
}

destroy_chalk_hud()
{
	if( isDefined( level.chalk_hud1 ) )
	{
		level.chalk_hud1 Destroy();
		level.chalk_hud1 = undefined;
	}
	if( isDefined( level.chalk_hud2 ) )
	{
		level.chalk_hud2 Destroy();
		level.chalk_hud2 = undefined;
	}
}

update_leaderboards()
{
/*	if( level.systemLink || IsSplitScreen() )
	{
		return; 
	}*/

	nazizombies_upload_highscore();
	nazizombies_set_new_zombie_stats();
}

player_fake_death()
{
	level.falling_down = true;

	level notify ("fake_death");
	self notify ("fake_death");

	self TakeAllWeapons();
	self AllowSprint( false );
	self AllowStand( false );
	self AllowCrouch( false );
	self AllowProne( true );
	self AllowLean( false );

	self.ignoreme = true;
	self EnableInvulnerability();

	self setactionslot(1,""); 
	self setactionslot(4,""); 

	d = self depthinwater(); 
	if( d == 0 ) // Skip animation if player has any depth in water, as they dont fall into prone in water 
	{
		self giveweapon("falling_hands");
		self SwitchToWeapon("falling_hands");
	}

	wait(1);
	
	self SetStance( "prone" );
	self FreezeControls( true );
}
player_revived()
{
        self AllowLean( true );
        self AllowSprint( true );
        self AllowMelee( true );
        self AllowStand( true );
        self AllowCrouch( true );
        self FreezeControls( false );
        wait( 0.5 );
        self.maxhealth = 100;
        self.health = 100;
        wait( 2.5 );
        self.ignoreme = false;
        self DisableInvulnerability();
}

player_exit_level()
{
	self AllowStand( true );
	self AllowCrouch( false );
	self AllowProne( false );

	if( IsDefined( self.game_over_bg ) )
	{
		self.game_over_bg.foreground = true;
		self.game_over_bg.sort = 100;
		self.game_over_bg FadeOverTime( 1 );
		self.game_over_bg.alpha = 1;
	}
}

player_killed_override()
{
	// BLANK
	level waittill( "forever" );
}


injured_walk()
{
	self.ground_ref_ent = Spawn( "script_model", ( 0, 0, 0 ) ); 

	self.player_speed = 50; 

	// TODO do death countdown	
	self AllowSprint( false ); 
	self AllowProne( false ); 
	self AllowCrouch( false ); 
	self AllowAds( false ); 
	self AllowJump( false ); 

	self PlayerSetGroundReferenceEnt( self.ground_ref_ent ); 
	self thread limp(); 
}

limp()
{
	level endon( "disconnect" ); 
	level endon( "death" ); 
	// TODO uncomment when/if SetBlur works again
	//self thread player_random_blur(); 

	stumble = 0; 
	alt = 0; 

	while( 1 )
	{
		velocity = self GetVelocity(); 
		player_speed = abs( velocity[0] ) + abs( velocity[1] ); 

		if( player_speed < 10 )
		{
			wait( 0.05 ); 
			continue; 
		}

		speed_multiplier = player_speed / self.player_speed; 

		p = RandomFloatRange( 3, 5 ); 
		if( RandomInt( 100 ) < 20 )
		{
			p *= 3; 
		}
		r = RandomFloatRange( 3, 7 ); 
		y = RandomFloatRange( -8, -2 ); 

		stumble_angles = ( p, y, r ); 
		stumble_angles = vector_multiply( stumble_angles, speed_multiplier ); 

		stumble_time = RandomFloatRange( .35, .45 ); 
		recover_time = RandomFloatRange( .65, .8 ); 

		stumble++; 
		if( speed_multiplier > 1.3 )
		{
			stumble++; 
		}

		self thread stumble( stumble_angles, stumble_time, recover_time ); 

		level waittill( "recovered" ); 
	}
}

stumble( stumble_angles, stumble_time, recover_time, no_notify )
{
	stumble_angles = self adjust_angles_to_player( stumble_angles ); 

	self.ground_ref_ent RotateTo( stumble_angles, stumble_time, ( stumble_time/4*3 ), ( stumble_time/4 ) ); 
	self.ground_ref_ent waittill( "rotatedone" ); 

	base_angles = ( RandomFloat( 4 ) - 4, RandomFloat( 5 ), 0 ); 
	base_angles = self adjust_angles_to_player( base_angles ); 

	self.ground_ref_ent RotateTo( base_angles, recover_time, 0, ( recover_time / 2 ) ); 
	self.ground_ref_ent waittill( "rotatedone" ); 

	if( !IsDefined( no_notify ) )
	{
		level notify( "recovered" ); 
	}
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[0]; 
	ra = stumble_angles[2]; 

	rv = AnglesToRight( self.angles ); 
	fv = AnglesToForward( self.angles ); 

	rva = ( rv[0], 0, rv[1]*-1 ); 
	fva = ( fv[0], 0, fv[1]*-1 ); 
	angles = vector_multiply( rva, pa ); 
	angles = angles + vector_multiply( fva, ra ); 
	return angles +( 0, stumble_angles[1], 0 ); 
}

coop_player_spawn_placement()
{
	structs = getstructarray( "initial_spawn_points", "targetname" ); 

	flag_wait( "all_players_connected" ); 

	//chrisp - adding support for overriding the default spawning method
	if(flag("spawn_point_override"))
	{
		return;
	}
	players = get_players(); 

	for( i = 0; i < players.size; i++ )
	{
		players[i] setorigin( structs[i].origin ); 
		players[i] setplayerangles( structs[i].angles ); 
		players[i].spectator_respawn = structs[i];
	}
}


player_zombie_breadcrumb()
{
	self endon( "disconnect" ); 
	self endon( "spawned_spectator" ); 
	level endon( "intermission" );

	self.zombie_breadcrumbs = []; 
	self.zombie_breadcrumb_distance = 24 * 24; // min dist (squared) the player must move to drop a crumb
	self.zombie_breadcrumb_area_num = 3;	   // the number of "rings" the area breadcrumbs use
	self.zombie_breadcrumb_area_distance = 16; // the distance between each "ring" of the area breadcrumbs

	self store_crumb( self.origin ); 
	last_crumb = self.origin;

	self thread debug_breadcrumbs(); 

	while( 1 )
	{
		wait_time = 0.1;
		
	/#
		if( self isnotarget() )
		{
			wait( wait_time ); 
			continue;
		}
	#/

		store_crumb = true; 
		airborne = false;
		crumb = self.origin;
		
		if ( !self IsOnGround() )
		{
			airborne = true;
			store_crumb = false; 
			wait_time = 0.05;
		}
		
		if( !airborne && DistanceSquared( crumb, last_crumb ) < self.zombie_breadcrumb_distance )
		{
			store_crumb = false; 
		}

		if ( airborne && self IsOnGround() )
		{
			// player was airborne, store crumb now that he's on the ground
			store_crumb = true;
			airborne = false;
		}
		
		// PI_CHANGE_BEGIN
		// JMA - we don't need to store new crumbs, the zipline will store our destination as a crumb
		if( isDefined(level.script) && level.script == "nazi_zombie_sumpf" && (isDefined(self.on_zipline) && self.on_zipline == true))
		{
			airborne = false;
			store_crumb = false; 			
		}
		// PI_CHANGE_END

		if( store_crumb )
		{
			debug_print( "Player is storing breadcrumb " + crumb );
			last_crumb = crumb;
			self store_crumb( crumb );
		}

		wait( wait_time ); 
	}
}


store_crumb( origin )
{
	offsets = [];
	height_offset = 32;
	
	index = 0;
	for( j = 1; j <= self.zombie_breadcrumb_area_num; j++ )
	{
		offset = ( j * self.zombie_breadcrumb_area_distance );
		
		offsets[0] = ( origin[0] - offset, origin[1], origin[2] );
		offsets[1] = ( origin[0] + offset, origin[1], origin[2] );
		offsets[2] = ( origin[0], origin[1] - offset, origin[2] );
		offsets[3] = ( origin[0], origin[1] + offset, origin[2] );

		offsets[4] = ( origin[0] - offset, origin[1], origin[2] + height_offset );
		offsets[5] = ( origin[0] + offset, origin[1], origin[2] + height_offset );
		offsets[6] = ( origin[0], origin[1] - offset, origin[2] + height_offset );
		offsets[7] = ( origin[0], origin[1] + offset, origin[2] + height_offset );

		for ( i = 0; i < offsets.size; i++ )
		{
			self.zombie_breadcrumbs[index] = offsets[i];
			index++;
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////LEADERBOARD CODE///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//CODER MOD: TOMMY K
nazizombies_upload_highscore()
{
	if( getDvarInt( "classic_zombies") == 1 || getDvarInt( "zombiemode_dev") == 1 ) // if playing with 24 limit or with super sprinters disabled, these are considered cheats because they make the game easier. classic perks or grabby zombies is OK, these make the game harder
	{
		//iPrintLn("Highscores not saved, current Game Options configuration not allowed");
		return;
	}
	
	map_name = GetDvar( "mapname" );

	if ( !isZombieLeaderboardAvailable( map_name, "waves" ) )
	{
		return;
	}

	players = get_players();		

	switch( players.size )
	{
	case 1:
		extra = "";
		override = false;
		break; 
	case 2:
		extra = "_two";
		override = true;
		break;
	case 3:
		extra = "_three";
		override = true;
		break;
	case 4:
		extra = "_four";
		override = true;
		break;
	default:
		extra = "";
		override = false;
		break; 
	}

	high_wave_string = "highestwave" + extra;
	total_points_string = "totalpoints" + extra;

	for( i = 0; i < players.size; i++ )
	{
		pre_highest_wave = players[i] playerZombieStatGet( map_name, high_wave_string, override ); 
		new_highest_wave = level.round_number;
		new_highest_wave = int( new_highest_wave );

		if( new_highest_wave > pre_highest_wave )
		{
			players[i] playerZombieStatSet( map_name, high_wave_string, new_highest_wave, override );
		}

		pre_total_points = players[i] playerZombieStatGet( map_name, total_points_string, override ); 				
		if( players[i].score_total > pre_total_points )
		{
			players[i] playerZombieStatSet( map_name, total_points_string, players[i].score_total, override );	
		}
	}
}

isZombieLeaderboardAvailable( map, type )
{
	if ( !isDefined( level.zombieLeaderboardNumber[map] ) )
		return 0;
	
	if ( !isDefined( level.zombieLeaderboardNumber[map][type] ) )
		return 0;

	return 1;
}

getZombieStatVariable( map, variable )
{
	if ( !isDefined( level.zombieLeaderboardStatVariable[map][variable] ) )
		assertMsg( "Unknown stat variable " + variable + " for map " + map );
		
	return level.zombieLeaderboardStatVariable[map][variable];
}

playerZombieStatGet( map, variable, override )
{
	stat_variable = getZombieStatVariable( map, variable );
	result = self zombieStatGet( stat_variable, override );

	return result;
}

playerZombieStatSet( map, variable, value, override )
{
	stat_variable = getZombieStatVariable( map, variable );
	self zombieStatSet( stat_variable, value, override );
}

nazizombies_set_new_zombie_stats()
{
	level.current_play_time = int( GetTime()/1000 ); 		// gets the time in seconds	

	players = get_players();		
	for( i = 0; i < players.size; i++ )
	{
		//grab stat and add final totals
		total_kills = players[i] zombieStatGet( "zombie_kills" ) + players[i].stats["kills"];
		total_points = players[i] zombieStatGet( "zombie_points" ) + players[i].stats["score"];
		total_rounds = players[i] zombieStatGet( "zombie_rounds" ) + (level.round_number - 1); // rounds survived
		total_downs = players[i] zombieStatGet( "zombie_downs" ) + players[i].stats["downs"];
		total_revives = players[i] zombieStatGet( "zombie_revives" ) + players[i].stats["revives"];
		total_perks = players[i] zombieStatGet( "zombie_perks_consumed" ) + players[i].stats["perks"];
		total_headshots = players[i] zombieStatGet( "zombie_heashots" ) + players[i].stats["headshots"];
		total_zombie_gibs = players[i] zombieStatGet( "zombie_gibs" ) + players[i].stats["zombie_gibs"];
		previous_play_time = players[i] zombieStatGet( "nz_sumpf_timeinwave" );

		//set zombie stats
		players[i] zombieStatSet( "zombie_kills", total_kills ); // 2100
		players[i] zombieStatSet( "zombie_points", total_points ); // 2101
		players[i] zombieStatSet( "zombie_rounds", total_rounds ); // 2102
		players[i] zombieStatSet( "zombie_downs", total_downs ); // 2103
		players[i] zombieStatSet( "zombie_revives", total_revives ); // 2104
		players[i] zombieStatSet( "zombie_perks_consumed", total_perks ); // 2105
		players[i] zombieStatSet( "zombie_heashots", total_headshots ); // 2106
		players[i] zombieStatSet( "zombie_gibs", total_zombie_gibs ); // 2107
		players[i] zombieStatSet( "nz_sumpf_timeinwave", int(level.current_play_time + previous_play_time) ); 

/*		if( getDvarInt( "classic_zombies") == 1 ) // if playing with 24 limit, this considered cheats because they make the game easier. classic perks or grabby zombies is OK, these make the game harder
		{
			//iPrintLn("Highscores not saved, current Game Options configuration not allowed");
		}
		else
		{*/
		players[i].xp = players[i] zombieStatGet( "rankxp" );

		if( players[i].xp <= 160000 ) // once we get 160k XP, then we are at max level so dont need to keep adding
		{
			players[i].xp = total_kills * 10; // calculate our new xp,  based on 1 zombie kill = 10 xp, we cannot lose progress because its tied to total kills which gets summed above 

			players[i].rank = players[i] maps\_challenges_coop::getRankForXp( players[i].xp ); 
			players[i] zombieStatSet( "rankxp", players[i].xp ); 
		}

		if ( players[i].xp >= 160000 ) // once we have gotten max rank, we can prestige
		{
			players[i].prestige = int(total_rounds/total_downs); // round to down ratio, because this ratio is different every game we can lose progress on this stat

			if(players[i].prestige > 10)
			{
				players[i].prestige = 10;
			}

			players[i] zombieStatSet( "plevel", players[i].prestige ); 
		}
		else
		{
			players[i].prestige = 0;
		}

		players[i] setRank( players[i].rank, players[i].prestige );
	//	}

		// note: to get stat number, do table lookup without GetStat--GetStat forces the stat value
	}
}

makeRankNumber( wave, players, time )
{
	if( time > 86400 ) 
		time = 86400; // cap it at like 1 day, need to cap cause you know some muppet is gonna end up trying it

	//pad out time
	padding = "";
	if ( 10 > time )
		padding += "0000";
	else if( 100 > time )
		padding += "000";
	else if( 1000 > time )
		padding += "00";
	else if( 10000 > time )
		padding += "0";

	rank = wave + "" + players + padding + time;

	return rank;
}


//CODER MOD: TOMMY K
/*
=============
statGet

Returns the value of the named stat
=============
*/
zombieStatGet( dataName, override )
{
/*	if( level.systemLink || true == IsSplitScreen() )
	{
		return; 
	}*/

	if(isDefined(override) && override == true)
	{
		return self getStat( int(tableLookup( "mp/dlc2_achievements.csv", 1, dataName, 0 )) );
	}
	else
	{
		return self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
	}
}

//CODER MOD: TOMMY K
/*
=============
setStat

Sets the value of the named stat
=============
*/
zombieStatSet( dataName, value, override )
{
/*	if( level.systemLink || true == IsSplitScreen() )
	{
		return; 
	}*/

	if(isDefined(override) && override == true)
	{
		self setStat( int(tableLookup( "mp/dlc2_achievements.csv", 1, dataName, 0 )), value );	
	}
	else
	{
		self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value );	
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//
// INTERMISSION =========================================================== //
//

intermission()
{
	level.intermission = true;
	level notify( "intermission" );

	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		setclientsysstate( "levelNotify", "zi", players[i] ); // Tell clientscripts we're in zombie intermission

		players[i] SetClientDvars( "cg_thirdPerson", "0" );
		players[i] setDepthOfField( 0, 0, 512, 4000, 4, 0 );
		players[i] notify("fix_your_fov");

		players[i] SetClientDvar("playerSpectating", "0");

		players[i].health = 100; // This is needed so the player view doesn't get stuck
		players[i] thread player_intermission();
	}

	wait( 0.25 );

	// Delay the last stand monitor so we are 100% sure the zombie intermission ("zi") is set on the cients
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		setClientSysState( "lsm", "1", players[i] );
	}

	visionset = "zombie";
	if( IsDefined( level.zombie_vars["intermission_visionset"] ) )
	{
		visionset = level.zombie_vars["intermission_visionset"];
	}

	level thread maps\_utility::set_all_players_visionset( visionset, 2 );
	level thread zombie_game_over_death();
}

zombie_game_over_death()
{
	// Kill remaining zombies, in style!
	zombies = GetAiArray( "axis" );
	for( i = 0; i < zombies.size; i++ )
	{
		if( !IsAlive( zombies[i] ) )
		{
			continue;
		}

		zombies[i] SetGoalPos( zombies[i].origin );
	}

	for( i = 0; i < zombies.size; i++ )
	{
		if( !IsAlive( zombies[i] ) )
		{
			continue;
		}

		wait( 0.5 + RandomFloat( 2 ) );

		zombies[i] maps\_zombiemode_spawner::zombie_head_gib();
		zombies[i] DoDamage( zombies[i].health + 666, zombies[i].origin );
	}
}

player_intermission()
{
	self closeMenu();
	self closeInGameMenu();

	level endon( "stop_intermission" );
    self endon("disconnect");
    self endon("death");

	//Show total gained point for end scoreboard and lobby
	self.score = self.score_total;

	self.sessionstate = "intermission";
	self.spectatorclient = -1; 
	self.killcamentity = -1; 
	self.archivetime = 0; 
	self.psoffsettime = 0; 
	self.friendlydamage = undefined;

	points = getstructarray( "intermission", "targetname" );

	if( !IsDefined( points ) || points.size == 0 )
	{
		points = getentarray( "info_intermission", "classname" ); 
		if( points.size < 1 )
		{
			println( "NO info_intermission POINTS IN MAP" ); 
			return;
		}	
	}

	self.game_over_bg = NewClientHudelem( self );
	self.game_over_bg.horzAlign = "fullscreen";
	self.game_over_bg.vertAlign = "fullscreen";
	self.game_over_bg SetShader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;

	org = undefined;
	while( 1 )
	{
		points = array_randomize( points );
		for( i = 0; i < points.size; i++ )
		{
			point = points[i];
			// Only spawn once if we are using 'moving' org
			// If only using info_intermissions, this will respawn after 5 seconds.
			if( !IsDefined( org ) )
			{
				self Spawn( point.origin, point.angles );
			}

			// Only used with STRUCTS
			if( IsDefined( points[i].target ) )
			{
				if( !IsDefined( org ) )
				{
					org = Spawn( "script_origin", self.origin + ( 0, 0, -60 ) );
				}

				self LinkTo( org, "", ( 0, 0, -60 ), ( 0, 0, 0 ) );
				self SetPlayerAngles( points[i].angles );
				org.origin = points[i].origin;

				speed = 20;
				if( IsDefined( points[i].speed ) )
				{
					speed = points[i].speed;
				}

				target_point = getstruct( points[i].target, "targetname" );
				dist = Distance( points[i].origin, target_point.origin );
				time = dist / speed;

				q_time = time * 0.25;
				if( q_time > 1 )
				{
					q_time = 1;
				}

				self.game_over_bg FadeOverTime( q_time );
				self.game_over_bg.alpha = 0;

				org MoveTo( target_point.origin, time, q_time, q_time );
				wait( time - q_time );

				self.game_over_bg FadeOverTime( q_time );
				self.game_over_bg.alpha = 1;

				wait( q_time );
			}
			else
			{
				self.game_over_bg FadeOverTime( 1 );
				self.game_over_bg.alpha = 0;

				wait( 5 );

				self.game_over_bg FadeOverTime( 1 );
				self.game_over_bg.alpha = 1;

				wait( 1 );
			}
		}
	}
}

prevent_near_origin()
{
	while (1)
	{
		players = get_players();

		for (i = 0; i < players.size; i++)
		{
			for (q = 0; q < players.size; q++)
			{
				if (players[i] != players[q])
				{	
					if (check_to_kill_near_origin(players[i], players[q]))
					{
						p1_org = players[i].origin;
						p2_org = players[q].origin;

						wait 5;

						if (check_to_kill_near_origin(players[i], players[q]))
						{
							if ( (distance(players[i].origin, p1_org) < 30) && distance(players[q].origin, p2_org) < 30)
							{
								setsaveddvar("player_deathInvulnerableTime", 0);
								players[i] DoDamage( players[i].health + 1000, players[i].origin, undefined, undefined, "riflebullet" );
								setsaveddvar("player_deathInvulnerableTime", level.startInvulnerableTime);	
							}
						}
					}	
				}
			}	
		}

		wait 0.2;
	}
}

check_to_kill_near_origin(player1, player2)
{
	if (!isdefined(player1) || !isdefined(player2))
	{
		return false;		
	}

	if (distance(player1.origin, player2.origin) > 12)
	{
		return false;
	}

	if ( player1 maps\_laststand::player_is_in_laststand() || player2 maps\_laststand::player_is_in_laststand() )
	{
		return false;
	}

	if (!isalive(player1) || !isalive(player2))
	{
		return false;		
	}

	return true;
}

check_for_jugg_perk()
{
	while(true)
	{
		players = getplayers();
		for(i = 0; i < players.size; i++)
		{
			if(players[i] hasperk("specialty_armorvest") && !isdefined(players[i].is_burning) && !is_magic_bullet_shield_enabled(players[i]))
			{

				if( !flag( "dog_round" ) )
				{
					players[i].health += 40;
				}
				else
				{
					players[i].health += 3;
				}

				if(players[i].health > 160)
				{
					players[i].health = 160;

				}

			}

		}
			wait(0.5);
	}

}

player_reload()
{
	self endon( "disconnect" );
	self endon( "death" );
 
	for(;;)
	{
		self waittill( "reload_start" );
		weap = self getCurrentWeapon(); // For weapon they are reloading, only do the LMGs for our heroes because these guns are usually used when defending and have slow reloads, call-outs more important
		ammo_count = self GetWeaponAmmoClip( weap ); // For weapon they are reloading, only shout reload if the mag is actually empty at 0
		zombies = getaiarray("axis" );
		zombies = get_array_of_closest( self.origin, zombies, undefined, undefined, 500 ); // Also, only shout reload when zombies are near, or else no reason to tell teammates
		if( zombies.size > 1 && ammo_count == 0 && (weap == "zombie_mg42" || weap == "zombie_30cal" || weap == "zombie_type99_lmg" || weap == "zombie_dp28") ) 
		{
			self thread add_reload_vox();
		}
		else
		{
			wait 0.3;
			continue;
		}
	wait(randomintrange(22,40)); // Cool down, only plays once in a while
	}
}

add_reload_vox()
{
	index = maps\_zombiemode_weapons::get_player_index(self);	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_reload))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_reload");
		self.vox_gen_reload = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_reload[self.vox_gen_reload.size] = "vox_gen_reload_" + i;	
		}
		self.vox_gen_reload_available = self.vox_gen_reload;		
	}	
	sound_to_play = random(self.vox_gen_reload_available);
	
	self.vox_gen_reload_available = array_remove(self.vox_gen_reload_available,sound_to_play);
	
	if (self.vox_gen_reload_available.size < 1 )
	{
		self.vox_gen_reload_available = self.vox_gen_reload;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
}


silent_while_down()
{
	wait(1);
	time = 0;
	while(time < 9)
	{
		level.player_is_speaking = 1;
		time += 0.1;
		wait(0.1);
	}

}


sticky_grenade(sticky)
{
	velocitySq = 10000 * 10000;
	oldPos = sticky.origin;
	
	sticky_pos = [];
	while( velocitySq != 0 )
	{
		wait( 0.05 );
		velocitySq = distanceSquared( sticky.origin, oldPos );
		oldPos = sticky.origin;
		sticky_pos = array_add(sticky_pos, sticky.origin);
	}
	
	index = -1; // init variable, if it stays -1 that means we have not touched a zombie or player

	sticked = GetAiSpeciesArray( "axis", "all" );	
	for(i=0;i<sticked.size;i++) // first we check all zombies
	{
		ri_arm = sticked[i] gettagorigin("j_elbow_ri");
		le_arm = sticked[i] gettagorigin("j_elbow_le");
		if(distance2d(sticky.origin, sticked[i].origin) < 20 || distance(sticky.origin, ri_arm) < 15 || distance(sticky.origin, le_arm) < 15)
		{
			index = i;
			break;
		}
	}

	if( index == -1 ) // if index has not been saved and we are still at -1, that means we have not stuck to a zombie so now we check if we stick to a player
	{
		sticked = getplayers();
		for(i=0;i<sticked.size;i++)
		{
			ri_arm = sticked[i] gettagorigin("j_elbow_ri");
			le_arm = sticked[i] gettagorigin("j_elbow_le");
			if(distance2d(sticky.origin, sticked[i].origin) < 20 || distance(sticky.origin, ri_arm) < 15 || distance(sticky.origin, le_arm) < 15)
			{
				index = i;
				if(self == sticked[index]) // we skip faking the nade if we sticky ourselves because you can't do this normally
				{
					return;
				}
				break;
			}
		}
	}

	d = sticky depthinwater();
	if(index == -1 && d <= 0 ) // if still -1, it is sticking to environment so we skip faking the nade as there is no need (unless we have a positive water depth, we fake in water so the grenade doesn't spam-sink weirdly)
	{
		return;
	}

	// Hide and delete actual grenade, spawn new fake grenade that actually sticks to AI/players
	sticky hide();
	spawnorig = sticky_pos[sticky_pos.size - 1];
	sticky_model = Spawn("script_model", spawnorig);
	sticky_model.angles = sticky.angles;
	sticky_model setModel("weapon_mp_sticky_grenade");
	sticky delete();
	sticky_model EnableLinkTo();
	sticky_model LinkTo(sticked[index], "J_MainRoot");

	count = 0;
	while(count < 1.75) // explode timer
	{
		count = count + 0.05;
		wait(0.05);
	}

	// Fake grenade explosion using engine function and then delete fake model
	self MagicGrenadeType( "st_grenade", sticky_model.origin, ( 0, 0, 0 ), 0 ); 
	wait(.05);
	sticky_model delete();
}

disable_character_dialog()
{
	flag_wait("all_players_connected");

	while(1)
	{
		if(GetDvarInt("character_dialog") == 0)
		{
			level.player_is_speaking = 0;
			while(GetDvarInt("character_dialog") == 0)
			{
				wait .1;
			}
		}

		while(GetDvarInt("character_dialog") == 1)
		{
			level.player_is_speaking = 1;
			wait .1;
		}
	}

}

// test dogs and crawers, seem to work but less likely to lock on? do prints
getAimAssistDvar(dvar)
{
	level endon("end_game");
	self endon("disconnect");
	self endon("death");
    
 	flag_wait( "all_players_connected" ); 

    self openMenunomouse(game["menu_clientdvar"]);

    for(;;)
    {
        self waittill("menuresponse", menu, response);
        if( response == "aim_autoaim_lock_disabled")
        {
        	self notify("disable_aim_assist");
        	//iPrintLnbold("disabling");
        }
        else if( response == "aim_autoaim_lock_enabled")
        {
        	self notify("disable_aim_assist"); // faisafe 
        	wait_network_frame();
        	self thread AimAssist();
        	//iPrintLnbold("enabling");
        }

        wait(0.05);
    }
}

AimAssist()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("death");
	self endon("disable_aim_assist");

	self thread is_reloading_checker();

	for(;;)
	{
		//self iPrintLn("Aim assist is running");
		range_to_use = self is_assisted_weapon();

		if( range_to_use != 0 && self.sessionstate != "spectator" )
		{
			tag = "j_spine4";
			view_pos = self Geteye();
			self.head = self getTagOrigin("j_head");
			zombies = get_array_of_closest( view_pos, getaispeciesarray("axis", "all"), undefined, undefined, undefined );		
			for ( i = 0; i < zombies.size; i++ )
			{	
				zombies[i].head = zombies[i] getTagOrigin(tag);
				if ( !IsDefined( zombies[i] ) )
				{
					continue;
				}
				enemy_origin = zombies[i].origin;
				test_range_squared = DistanceSquared( view_pos, enemy_origin );
				if ( test_range_squared < range_to_use )
				{	
					if(zombies[i] player_can_see_me(self) && bulletTracePassed(self.head, zombies[i].head, false, undefined))
					{
						if(self adsButtonPressed() && self.is_reloading == false && !self IsMeleeing() && self playerADS() < 0.6)
						{
							self setPlayerAngles(vectorToAngles((zombies[i] getTagOrigin(tag)) - (self getEye())));

							while( self adsButtonPressed() )
							{
								wait .05;
							}
							break;
						}
					}
				}
			}
		}
		wait 0.05;
	}
}

is_reloading_checker()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("death");
	self endon("disable_aim_assist");

	for(;;)
	{
		self.is_reloading = false;
		self waittill( "reload_start" );

		weap = self getCurrentWeapon();

		while( (self GetWeaponAmmoClip( weap ) != WeaponClipSize( weap ) && self GetWeaponAmmoStock( weap ) != 0 ) && !self isMeleeing() && !self IsThrowingGrenade() && !self isSwitchingWeapons() ) // if we switch weps, throw grenade, or melee we cancel reload
		{
			self.is_reloading = true;
			wait(0.5);
		}
	}
}

is_assisted_weapon()
{
    weap = self getCurrentWeapon();

	if(!isDefined(weap) || weap == "none" || isSubStr(weap, "zombie_perk") || weap == "zombie_knuckle_crack" || weap == "zombie_bowie_flourish"  || weap == "mine_bouncing_betty" || weap == "satchel_charge" || weap == "mortar_round" || weap == "syrette" || isSubStr(weap, "m7_launcher") || isSubStr(weap, "zombie_item") )
	{
		return 0;
	}
	else if(self.is_reloading == true || self IsMeleeing() || self IsThrowingGrenade() || self isSwitchingWeapons() )
	{
		return 0;
	}
	else
	{
		weapclass = WeaponClass(weap);
		switch(weapclass)
		{	
			case "rifle":
				range = 1200 * 1200;
				break;
			case "smg":
			case "mg":
			case "rocketlauncher":
				range = 900 * 900;
				break;
			default: // for pistol, spread, gas
				range = 550 * 550;
				break;	
		}
	    return range;
	}
}

player_can_see_me( player )
{
	playerAngles = player getplayerangles();
	playerForwardVec = AnglesToForward( playerAngles );
	playerUnitForwardVec = VectorNormalize( playerForwardVec );
	
	zombiePos = self GetOrigin();
	playerPos = player GetOrigin();
	playerToZombieVec = zombiePos - playerPos;
	playerToZombieUnitVec = VectorNormalize( playerToZombieVec );
	
	forwardDotZombie = VectorDot( playerUnitForwardVec, playerToZombieUnitVec );

    if ( forwardDotZombie >= 1 )
    {
        angleFromCenter = 0;
    }
    else if ( forwardDotZombie <= -1 )
    {
        angleFromCenter = 180;
    }
    else
    {
		angleFromCenter = ACos( forwardDotZombie );
    }

    playerFOV = 65;
    zombieVsPlayerFOVBuffer = 0.2;

	distance = self check_distance(player);

	playerCanSeeMe = angleFromCenter <= ( ( playerFOV * distance ) * ( 1 - zombieVsPlayerFOVBuffer ) ); 

	return playerCanSeeMe;
}

check_distance(player) // Further away zombies have weaker aim assist, only checks a more narrow angle 
{
	if(distance(self.origin, player.origin) < 90)
		return .45;
	if(distance(self.origin, player.origin) <= 100)
		return .4;
	if(distance(self.origin, player.origin) <= 150)
		return .3;
	if(distance(self.origin, player.origin) <= 200)
		return .25;
	if(distance(self.origin, player.origin) <= 250)
		return .225;
	if(distance(self.origin, player.origin) <= 300)
		return .2;
	if(distance(self.origin, player.origin) <= 350)
		return .175;
	if(distance(self.origin, player.origin) <= 400)
		return .15;
	return .125;
}

