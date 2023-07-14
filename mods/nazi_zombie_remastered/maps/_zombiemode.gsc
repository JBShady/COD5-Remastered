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

	PrecacheItem( "stielhandgranate" );
	PrecacheItem( "zombie_colt" );

	init_strings();
	init_levelvars();
	init_animscripts();
	init_sounds();
	init_shellshocks();

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
	// Call the other zombiemode scripts
	maps\_zombiemode_weapons::init();
	maps\_zombiemode_blockers::init();
	maps\_zombiemode_spawner::init();
	maps\_zombiemode_powerups::init();
	maps\_zombiemode_radio::init();	
		
	init_utility();

	// register a client system...
	maps\_utility::registerClientSys("zombify");

	// fog settings
	//setexpfog( 150, 800, 0.803, 0.812, 0.794, 10 ); 

//	level thread check_for_level_end(); 
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
	level.laststandpistol = "zombie_colt";
	
	level.round_start_time = 0;
	
	level thread onPlayerConnect(); 

	init_dvars();

	flag_wait( "all_players_connected" ); 
	
	//thread zombie_difficulty_ramp_up(); 

	players = get_players();

/*	if(players.size != 1)
	{
		setDvar( "classic_zombies", 0);
	}*/

	// Start the Zombie MODE!
	level thread end_game();
	level thread round_start();
	level thread players_playing();

	DisableGrenadeSuicide();

	level thread track_players_ammo_count();
	level thread disable_character_dialog();

	// Do a SaveGame, so we can restart properly when we die
	SaveGame( "zombie_start", &"AUTOSAVE_LEVELSTART", "", true );

	if(!IsDefined(level.eggs) )
	{
		level.eggs = 0;
	}
	// TESTING
//	wait( 3 );
//	level thread intermission();
//	thread testing_spawner_bug();
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
	precacheshader( "nazi_intro" ); 
	precacheshader( "zombie_intro" ); 
	PrecacheShader( "hud_chalk_1" );
	PrecacheShader( "hud_chalk_2" );
	PrecacheShader( "hud_chalk_3" );
	PrecacheShader( "hud_chalk_4" );
	PrecacheShader( "hud_chalk_5" );
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
	PrecacheString( &"REMASTERED_ZOMBIE_ENTER_FIRST_PERSON" );
	PrecacheString( &"REMASTERED_ZOMBIE_ENTER_THIRD_PERSON" );
	
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
	add_zombie_hint( "default_buy_area_100", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_100" );
	add_zombie_hint( "default_buy_area_200", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_200" );
	add_zombie_hint( "default_buy_area_250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_250" );
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
	add_sound( "end_of_game", "mx_game_over" );
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

	if( GetDvar( "zombie_debug" ) == "" )
	{
		SetDvar( "zombie_debug", "0" );
	}

	if( GetDvar( "zombie_cheat" ) == "" )
	{
		SetDvar( "zombie_cheat", "0" );
	}

	SetDvar( "revive_trigger_radius", "60" );

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
	level.scr_anim["zombie"]["walk5"] 	= %ai_zombie_walk_v6; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["walk6"] 	= %ai_zombie_walk_v7; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_walk_v8; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["walk8"] 	= %ai_zombie_walk_v9; // New, from Bo1

	level.scr_anim["zombie"]["run1"] 	= %ai_zombie_walk_fast_v1;
	level.scr_anim["zombie"]["run2"] 	= %ai_zombie_walk_fast_v2;
	level.scr_anim["zombie"]["run3"] 	= %ai_zombie_walk_fast_v3;
	level.scr_anim["zombie"]["run4"] 	= %ai_zombie_run_v2; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["run5"] 	= %ai_zombie_run_v4; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["sprint1"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint2"] = %ai_zombie_sprint_v2; 	
	level.scr_anim["zombie"]["sprint3"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint4"] = %ai_zombie_sprint_v2;
	level.scr_anim["zombie"]["sprint5"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint6"] = %ai_zombie_sprint_v2; 	
	level.scr_anim["zombie"]["sprint7"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint8"] = %ai_zombie_sprint_v2; 	
	level.scr_anim["zombie"]["sprint9"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint10"] = %ai_zombie_sprint_v2; 	
	level.scr_anim["zombie"]["sprint11"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint12"] = %ai_zombie_sprint_v2; 	
	level.scr_anim["zombie"]["sprint13"] = %ai_zombie_sprint_v1; 
	level.scr_anim["zombie"]["sprint14"] = %ai_zombie_sprint_v2; 	
	level.scr_anim["zombie"]["sprint15"] = %ai_zombie_sprint_w_object_5; //super sprinters, 1/15  chance (ai_zombie_sprint_v4 is for Verruckt, which is a 1/3 chance)

	// run cycles in prone
	level.scr_anim["zombie"]["crawl1"] 	= %ai_zombie_crawl; 
	level.scr_anim["zombie"]["crawl2"] 	= %ai_zombie_crawl_v1; 
	level.scr_anim["zombie"]["crawl3"] 	= %ai_zombie_crawl_v2; //New, from Verruckt/Riese

	//below, not sure which "new" ones are actualy used versus just in game files
	level.scr_anim["zombie"]["crawl4"] 	= %ai_zombie_crawl_v3; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["crawl5"] 	= %ai_zombie_crawl_v4; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["crawl6"] 	= %ai_zombie_crawl_sprint; // Moved over, this is just the classic Nacht fast crawler
	level.scr_anim["zombie"]["crawl_hand_1"] = %ai_zombie_walk_on_hands_a; //New, from Verruckt/Riese
	level.scr_anim["zombie"]["crawl_hand_2"] = %ai_zombie_walk_on_hands_b; //New, from Verruckt/Riese


	if( !isDefined( level._zombie_melee ) )
	{
		level._zombie_melee = [];
	}
	if( !isDefined( level._zombie_walk_melee ) )
	{
		level._zombie_walk_melee = [];
	}
	if( !isDefined( level._zombie_run_melee ) )
	{
		level._zombie_run_melee = [];
	}
	level._zombie_melee["zombie"] = [];
	level._zombie_walk_melee["zombie"] = [];
	level._zombie_run_melee["zombie"] = [];

	level._zombie_melee["zombie"][0] 				= %ai_zombie_attack_forward_v1; // Slow anim
	level._zombie_melee["zombie"][1] 				= %ai_zombie_attack_forward_v2; // Slow anim
	level._zombie_melee["zombie"][2] 				= %ai_zombie_attack_forward_v1;  // Slow anim, repeated for higher odds to stop and hit
	level._zombie_melee["zombie"][3] 				= %ai_zombie_attack_forward_v2;	 // Slow anim, repeated for higher odds to stop and hit
	level._zombie_melee["zombie"][4]				= %ai_zombie_attack_v1; // Slow anim
	level._zombie_melee["zombie"][5] 				= %ai_zombie_attack_v2; // Slow anim
	level._zombie_melee["zombie"][6] 				= %ai_zombie_attack_v1;  // Slow anim, repeated for higher odds to stop and hit
	level._zombie_melee["zombie"][7] 				= %ai_zombie_attack_v2; // Slow anim, repeated for higher odds to stop and hit
	level._zombie_melee["zombie"][8]				= %ai_zombie_attack_v4; //New faster hit, from Verruckt/Riese, kept more rare  10% in this pool
	level._zombie_melee["zombie"][9]				= %ai_zombie_attack_v6;	 //New faster hit, from Verruckt/Riese, kept more rare  10% in this pool

	level._zombie_run_melee["zombie"][0]				=	%ai_zombie_run_attack_v1; //New fast hit, from Verruckt/Riese, when running, less than 50% we do one of these new hits otherwise we do classic old slow hits
	level._zombie_run_melee["zombie"][1]				=	%ai_zombie_run_attack_v2; //New fast hit, from Verruckt/Riese
	level._zombie_run_melee["zombie"][2]				=	%ai_zombie_run_attack_v3; //New fast hit, from Verruckt/Riese
	level._zombie_run_melee["zombie"][3]				=	%ai_zombie_attack_forward_v1; // Slow anim, repeated for higher odds to stop and hit
	level._zombie_run_melee["zombie"][4]				=	%ai_zombie_attack_forward_v2; // Slow anim, repeated for higher odds to stop and hit
	level._zombie_run_melee["zombie"][5]				=	%ai_zombie_attack_v1; // Slow anim, repeated for higher odds to stop and hit
	level._zombie_run_melee["zombie"][6]				=	%ai_zombie_attack_v2; // Slow anim, repeated for higher odds to stop and hit

	if( isDefined( level.zombie_anim_override ) )
	{
		[[ level.zombie_anim_override ]]();
	}

	level._zombie_walk_melee["zombie"][0]			= %ai_zombie_walk_attack_v1; //New, from Verruckt/Riese
	level._zombie_walk_melee["zombie"][1]			= %ai_zombie_walk_attack_v2; //New, from Verruckt/Riese
	level._zombie_walk_melee["zombie"][2]			= %ai_zombie_walk_attack_v3; //New, from Verruckt/Riese
	level._zombie_walk_melee["zombie"][3]			= %ai_zombie_walk_attack_v4; //New, from Verruckt/Riese

	// melee in crawl
	if( !isDefined( level._zombie_melee_crawl ) )
	{
		level._zombie_melee_crawl = [];
	}
	level._zombie_melee_crawl["zombie"] = [];
	level._zombie_melee_crawl["zombie"][0] 		= %ai_zombie_attack_crawl; 
	level._zombie_melee_crawl["zombie"][1] 		= %ai_zombie_attack_crawl_lunge;
	

	if( !isDefined( level._zombie_stumpy_melee ) )
	{
		level._zombie_stumpy_melee = [];
	}
	level._zombie_stumpy_melee["zombie"] = [];
	level._zombie_stumpy_melee["zombie"][0] = %ai_zombie_walk_on_hands_shot_a;
	level._zombie_stumpy_melee["zombie"][1] = %ai_zombie_walk_on_hands_shot_b;

	if( !isDefined( level._zombie_deaths ) )
	{
		level._zombie_deaths = [];
	}
	level._zombie_deaths["zombie"] = [];
	level._zombie_deaths["zombie"][0] = %ch_dazed_a_death;
	level._zombie_deaths["zombie"][1] = %ch_dazed_b_death;
	level._zombie_deaths["zombie"][2] = %ch_dazed_c_death;
	level._zombie_deaths["zombie"][3] = %ch_dazed_d_death;
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
	//TUEY Set music state to WAVE_1
	//setmusicstate("WAVE_1");

	players = get_players(); // co-op failsafe because some stupid engine thing is resetting our cheat protected dvars right when we load in, so we wait a second and then change them again here
	for( i = 0; i < players.size; i++ )
	{
		players[i] SetClientDvars(
		"player_backSpeedScale", "0.9",
		"player_strafeSpeedScale", "0.9",
		"player_sprintStrafeSpeedScale", "0.8",
		"aim_automelee_range", "96",
        "aim_automelee_lerp", "50",
        "player_meleechargefriction", "2500" );	
	}
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
        "player_meleechargefriction", "2500" );	
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
		self waittill("grenade_fire", grenade, type);

		if ( type == "Stielhandgranate" ) // skip special grenades like molotovs
		{
			if( randomIntRange( 0, 4 ) == 0 ) // 1 in 4 chances of grenade out vox
			{
				self thread say_grenade_vo();
			}
		}
		if(isdefined(grenade))
		{
			if(self maps\_laststand::player_is_in_laststand()) // or dead delete?
			{
				wait(0.05);
				grenade delete();
			}
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
		"player_backSpeedScale", "0.9", // back speed faster, similar to console
		"player_strafeSpeedScale", "0.9", // buffed strafe
		"player_sprintStrafeSpeedScale", "0.8" );  // buffed strafe

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
			self SetClientDvar( "cg_ScoresColor_Gamertag_0" , GetDvar( "cg_hudGrenadeIndicatorTargetColor") );
			self SetClientDvar( "cg_ScoresColor_Gamertag_1" , GetDvar( "cg_ScoresColor_Gamertag_1") );
			self SetClientDvar( "cg_ScoresColor_Gamertag_2" , GetDvar( "cg_ScoresColor_Gamertag_2") );
			self SetClientDvar( "cg_ScoresColor_Gamertag_3" , GetDvar( "cg_ScoresColor_Gamertag_3") );
		}
		self SetClientDvars(
				"cg_overheadIconsize", "0",
		        "cg_overheadRanksize", "0"); 
			
		self SetClientDvars( "cg_thirdPerson", "0",
							 //"cg_fov", "65",
							 "cg_thirdPersonAngle", "0" );

		self SetDepthOfField( 0, 0, 512, 4000, 4, 0 );

		self add_to_spectate_list();

		self SetClientDvars(
		"player_backSpeedScale", "0.9",
		"player_strafeSpeedScale", "0.9",
		"player_sprintStrafeSpeedScale", "0.8",
		
		"aim_automelee_range", "96",
        "aim_automelee_lerp", "50",
        "player_meleechargefriction", "2500" );

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

player_laststand()
{
	self maps\_zombiemode_score::player_downed_penalty();
	self thread say_down_vo();

	if( IsDefined( self.intermission ) && self.intermission )
	{
		// Taken from _laststand since we will never go back to it...
		//self.downs++;
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

	setClientSysState( "levelNotify", "fov_death", self );

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

	wait(0.1); // ensure that we save our fov before we mess with it below
	wait_network_frame();
	// We start by setting up everything for 3rd person, only below do we start the toggling if a player so chooses
	third_person = true;
	self SetClientDvars( "cg_thirdPerson", "1",	"cg_thirdPersonAngle", "354", "cg_fov", "40" );
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );

	self.viewChangeSpec = newClientHudElem( self );

	self.viewChangeSpec.alignX 		= "center";
	self.viewChangeSpec.alignY 		= "middle";
	self.viewChangeSpec.horzAlign 	= "center";
	self.viewChangeSpec.vertAlign 	= "bottom";
	self.viewChangeSpec.y 	= -100;
	self.viewChangeSpec.x 	= 6;
	self.viewChangeSpec.foreground 	= true;
	self.viewChangeSpec.hideWhenInMenu = true;
	self.viewChangeSpec.fontScale = 1.2;

	self.viewChangeSpec SetText( &"REMASTERED_ZOMBIE_ENTER_FIRST_PERSON" );

	self thread reset_spec_hud();

    while(1)
    {
		countdown_time = 0.25;
		for(;;)
		{
		    wait(0.05);
			if ( self meleeButtonPressed() )
		    {
		        countdown_time -= 0.05;
		        if ( countdown_time <= 0 ) break;
		    }
		    else if ( countdown_time != 0.25 )  
		        countdown_time = 0.25;
		}

    	third_person = !third_person;
        self set_third_person(third_person);

		wait(0.5);
    }
	// destroy hud when respawn and if last person dies
}

set_third_person( value )
{
	if( value )
	{
		self SetClientDvars( "cg_thirdPerson", "1", "cg_thirdPersonAngle", "354", "cg_fov", "40" );
		
		self.viewChangeSpec SetText( &"REMASTERED_ZOMBIE_ENTER_FIRST_PERSON" );

		self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
	}
	else
	{
		self SetClientDvars( "cg_thirdPerson", "0", "cg_thirdPersonAngle", "0", "cg_fov", "65" );
		
		self.viewChangeSpec SetText( &"REMASTERED_ZOMBIE_ENTER_THIRD_PERSON" );

		self setDepthOfField( 0, 0, 512, 4000, 4, 0 );
	}
}

reset_spec_hud()
{
	self waittill_any( "spawned_player", "fix_your_fov" );
	
	setClientSysState( "levelNotify", "fov_reset", self );
	
	self.viewChangeSpec destroy();
	self.viewChangeSpec = undefined;
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
			}
		}

		wait( 1 );
	}
}

spectator_respawn()
{
	println( "*************************Respawn Spectator***" );

	spawn_off_player = get_closest_valid_player( self.origin );
	//origin = get_safe_breadcrumb_pos( spawn_off_player );
    origin = undefined;

	self setSpectatePermissions( false );
					
	if( IsDefined( origin ) )
	{
		angles = VectorToAngles( spawn_off_player.origin - origin );
	}
	else
	{
/*		spawnpoints = GetEntArray( "info_player_deathmatch", "classname" );
		num = RandomInt( spawnpoints.size );
		origin = spawnpoints[num].origin;
		angles = spawnpoints[num].angles;*/
		origin = self.respawn_point.origin;
		angles = self.respawn_point.angles;
	}

	self Spawn( origin, angles );

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

	// The check_for_level_end looks for this
	self.is_zombie = false;
	self.ignoreme = false;

	setClientSysState("lsm", "0", self);	// Notify client last stand ended.
	self RevivePlayer();
	
	self notify( "spawned_player" );

	if(isDefined(self.viewChangeSpec) )
	{
		self.viewChangeSpec destroy();
		self.viewChangeSpec = undefined;
	}

	// Penalize the player when we respawn, since he 'died'
	self maps\_zombiemode_score::player_reduce_points( "died" );
	
	self thread player_zombie_breadcrumb();
	
	return true;
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
		level.zombies = [];
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

	while( count < max )
	{
		wait_network_frame(); //UGX fix
		if(level.enemy_spawns.size <= 0) continue; //UGX fix

		spawn_point = level.enemy_spawns[RandomInt( level.enemy_spawns.size )]; 

		while( get_enemy_count() > 31 )
		{
			wait( 0.05 );
		}

		ai = spawn_zombie( spawn_point ); 

		if( IsDefined( ai ) )
		{
			level.zombie_total--;
			ai thread round_spawn_failsafe();
			count++; 
		}

		wait( level.zombie_vars["zombie_spawn_delay"] ); 
		wait_network_frame();

		// TESTING! Only 1 Zombie for testing
//		level waittill( "forever" );
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
	
	/#
		//level thread bunker_ui(); 
	#/

	level.chalk_hud1 = create_chalk_hud(2);
	level.chalk_hud2 = create_chalk_hud( 66 );

	level.round_spawn_func = ::round_spawning;

//	level waittill( "introscreen_done" );

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

chalk_one_up()
{
	if( level.first_round )
	{
		intro = true;
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

	//play_sound_at_pos( "chalk_one_up", ( 0, 0, 0 ) );

	if(IsDefined(level.eggs) && level.eggs !=1 && level.round_number > 1 && level.intermission == false ) // only do this after round 1, because on round one we are using the mx splash screen which uses up our music state
	{
		setmusicstate("round_begin");
	}
	else if(IsDefined(level.eggs) && level.eggs !=1 && level.round_number == 1)
	{
		play_sound_at_pos( "chalk_one_up", ( 0, 0, 0 ) );
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

	if(IsDefined(level.eggs) && level.eggs !=1 && level.intermission == false)
	{
		setmusicstate("round_end");
	}

	wait( time * 0.25 );

	//play_sound_at_pos( "end_of_round", ( 0, 0, 0 ) );

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
	//TUEY - MOVE THIS LATER
	//TUEY Set music state to round 1
	//setmusicstate( "WAVE_1" );

	for( ;; )
	{
		//////////////////////////////////////////
		//designed by prod DT#36173
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
			maxreward = 500;
		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
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

	while( get_enemy_count() > 0 || level.zombie_total > 0 || level.intermission )
	{
		wait( 0.5 );
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
	else if( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_HIT_BY_OBJECT" || sMeansOfDeath == "MOD_CRUSH" )
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
			rand = randomintrange(0, 100);
			if( (rand < 60) && (sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH") )
			{
				self thread add_cough_vox();
			}
			else
			{
				self thread add_pain_vox();	
			}
		}
	}
	finalDamage = iDamage;
	
	if (sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_GRENADE")  // For all grenade explosive damage. Molotovs, M1 Launcher, Frags, and anything else
	{
		if( self.health > 75 )
		{
		//iPrintLn(sMeansOfDeath, " with ", sWeapon);

			if(isSubStr(sWeapon, "molotov") ) // Radius 200, damage medium (400-100)
			{
				finalDamage = radiusDamage(eInflictor.origin, 200,120,50, eAttacker); 
			}
			else if(isSubStr(sWeapon, "m7_launcher") ) // Radius 200, damage high (600-75), upgraded radius is 350
			{
				finalDamage = radiusDamage(eInflictor.origin, 200,125,50, eAttacker);
			}
			else // For frags (and all other cases), Radius 256, damage low (300-75)
			{
				finalDamage = radiusDamage(eInflictor.origin, 256,120,50, eAttacker);
			}
			// Inner radius damage is always above 100, so that right below you it will kill you with no Jug
			self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
			return;
		}
	}

	// Monkeys, Radius 100, damage high (5000-450)
	// Sticky, Radius 180, damage high (1000-300)
	//Ray gun / Waffe - no radius damage, just a flat red screen damage, higher for Waffe because it's a stronger wep

	if (sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_PROJECTILE")  // For all projectile explosive damage. Ray Gun, Panzer, Waffle, and anything else
	{
		if( self.health > 75 )
		{
		//iPrintLn(sMeansOfDeath, " with ", sWeapon);

			if(isSubStr(sWeapon, "panzer") ) // Radius 256, damage high (600-75), upgraded radius is 400
			{
				finalDamage = radiusDamage(eInflictor.origin, 256,125,50, eAttacker);
			}
			else if(isSubStr(sWeapon, "ray_gun") ) // Ray Gun instant red screen
			{
				finalDamage = 80;
			}
			else // For anything else, do Vanilla factory-style damage
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
	}
	else
	{
		self maps\_callbackglobal::finishPlayerDamageWrapper( eInflictor, eAttacker, finalDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
	}
}

end_game()
{
	level waittill ( "end_game" );

	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		setClientSysState( "lsm", "0", players[i] );
		players[i] notify("end_game_quiet");
	}

	self StopShellshock(); 
	self StopRumble( "damage_heavy" ); 

	setmusicstate("end_of_game");
	setbusstate("default");

	level.intermission = true;
	level.zombie_vars["zombie_powerup_insta_kill_time"] = 0;
	level.zombie_vars["zombie_powerup_point_doubler_time"] = 0;
	wait 0.1;

	//update_leaderboards();
	
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

	survived FadeOverTime( 1 );
	survived.alpha = 1;

	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] SetClientDvars( "ammoCounterHide", "1",
				"miniscoreboardhide", "1" );
		
		
	}
	destroy_chalk_hud();


	wait( 1 );
	//play_sound_at_pos( "end_of_game", ( 0, 0, 0 ) );
	wait( 2 );
	level.player_is_speaking = 1;

	level clientNotify ("ktr"); // stop radio 

	intermission();

	wait( level.zombie_vars["zombie_intermission_time"] );

	level notify( "stop_intermission" );
	array_thread( get_players(), ::player_exit_level );

	wait( 1.5 );

/*	for ( j = 0; j < get_players().size; j++ )
	{
		player = get_players()[j];
		survived[j] Destroy();
		game_over[j] Destroy();
	}*/

// Scoreboard shows up on respawn which is weird

	if( is_coop() )
	{
		wait(7); // extra lil wait because sometimes co-op lobbies the intermission cuts off early since music can start a bit later
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
	if( level.systemLink || IsSplitScreen() )
	{
		return; 
	}

	nazizombies_upload_highscore();	
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

	self giveweapon("falling_hands");
	self SwitchToWeapon("falling_hands");

	wait(1);

	self SetStance( "prone" );
	self FreezeControls( true );
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
	
	players = get_players(); 
	
	for( i = 0; i < players.size; i++ )
	{
		players[i] setorigin( structs[i].origin ); 
		players[i] setplayerangles( structs[i].angles ); 
		players[i].respawn_point = structs[i];
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
	// Nazi Zombie Leaderboards
	// nazi_zombie_prototype_waves = 13
	// nazi_zombie_prototype_points = 14
	
	// this has gotta be the dumbest way of doing this, but at 1:33am in the morning my brain is fried!
	playersRank = 1;
	if( level.players_playing == 1 )
		playersRank = 4;
	else if( level.players_playing == 2 )
		playersRank = 3;
	else if( level.players_playing == 3 )
		playersRank = 2;

	players = get_players();		
	for( i = 0; i < players.size; i++ )
	{
		pre_highest_wave = players[i] zombieStatGet( "nz_prototype_highestwave" ); 
		pre_time_in_wave = players[i] zombieStatGet( "nz_prototype_timeinwave" );
		
		new_highest_wave = level.round_number + "" + playersRank;
		new_highest_wave = int( new_highest_wave );
		
		if( new_highest_wave >= pre_highest_wave )
		{
			if( players[i].zombification_time == 0 )
			{
				players[i].zombification_time = getTime();
			}
			
			player_survival_time = players[i].zombification_time - level.round_start_time; 
			player_survival_time = int( player_survival_time/1000 ); 			
			
			if( new_highest_wave > pre_highest_wave || player_survival_time > pre_time_in_wave )
			{
				// 13 = nazi_zombie_prototype_waves leaderboard				
				rankNumber = makeRankNumber( level.round_number, playersRank, player_survival_time );
								
				players[i] UploadScore( 13, int(rankNumber), level.round_number, player_survival_time, level.players_playing ); 
				
				players[i] zombieStatSet( "nz_prototype_highestwave", new_highest_wave ); 
				players[i] zombieStatSet( "nz_prototype_timeinwave", player_survival_time ); 			
			}
		}		
		
		pre_total_points = players[i] zombieStatGet( "nz_prototype_totalpoints" ); 				
		if( players[i].score_total > pre_total_points )
		{
			// 14 = nazi_zombie_prototype_waves leaderboard
			//total_spent = players[i].score_total - players[i].score; 
			
			players[i] UploadScore( 14, players[i].score_total, players[i].kills, level.players_playing ); 
			
			players[i] zombieStatSet( "nz_prototype_totalpoints", players[i].score_total ); 
		}			
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
zombieStatGet( dataName )
{
	if( level.systemLink || true == IsSplitScreen() )
	{
		return; 
	}
	
	return self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
}

//CODER MOD: TOMMY K
/*
=============
setStat

Sets the value of the named stat
=============
*/
zombieStatSet( dataName, value )
{
	if( level.systemLink || true == IsSplitScreen() )
	{
		return; 
	}
	
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value );	
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
		players[i] notify("fix_your_fov");

		if(isDefined(players[i].viewChangeSpec) )
		{
			players[i].viewChangeSpec destroy();
			players[i].viewChangeSpec = undefined;
		}

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
		level.player_is_speaking = 1; // Make sure no one accidently talks during intermission
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


track_players_ammo_count()
{
	self endon("disconnect");
	self endon("death");
	if(!IsDefined (level.player_ammo_low))	
	{
		level.player_ammo_low = 0;
	}	
	while(1)
	{
		players = get_players();
		for(i=0;i<players.size;i++)
		{
	
			weap = players[i] getcurrentweapon();
			//Excludes all Perk based 'weapons' so that you don't get low ammo spam.
			if(!isDefined(weap) || weap == "none" || weap == "syrette" || weap == "m2_flamethrower_zombie" || weap == "m7_launcher" || weap == "zombie_melee" || weap == "falling_hands" )
			{
				continue;
			}
			if ( players[i] GetAmmoCount( weap ) > 5)
			{
				continue;
			}
			if ( players[i] maps\_laststand::player_is_in_laststand() )
			{				
				continue;
			}
			else if (players[i] GetAmmoCount( weap ) < 5 && players[i] GetAmmoCount( weap ) > 0)
			{
				if (level.player_ammo_low == 0)
				{
					level.player_ammo_low = 1;
					players[i] thread add_low_ammo_dialog();		
					//put in this wait to keep the game from spamming about being low on ammo.
					wait(20);
					level.player_ammo_low = 0;
				}
	
			}
			else
			{
				continue;
			}
		}
		wait(.5);
	}	
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
	wait(0.35);
	level.player_is_speaking = 0;
}


add_cough_vox()
{
	index = maps\_zombiemode_weapons::get_player_index(self);	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_kill_cough))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_kill_cough");
		self.vox_kill_cough = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_kill_cough[self.vox_kill_cough.size] = "vox_kill_cough_" + i;	
		}
		self.vox_kill_cough_available = self.vox_kill_cough;		
	}	
	sound_to_play = random(self.vox_kill_cough_available);
	
	self.vox_kill_cough_available = array_remove(self.vox_kill_cough_available,sound_to_play);
	
	if (self.vox_kill_cough_available.size < 1 )
	{
		self.vox_kill_cough_available = self.vox_kill_cough;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.05 );	
	
}

player_reload()
{
	self endon( "disconnect" );
	self endon( "death" );
 
	for(;;)
	{
		self waittill( "reload_start" );
		weap = self getCurrentWeapon(); // For weapon they are reloading, exclude colt because early game is less intense and we dont want reload shout in last stand
		mag = weaponClipSize(weap); // For weapon they are reloading, exclude clips of just 1 & 2 (Rocket launchers, double barels; these guns you end up reloading quite a bit)
		ammo_count = self GetWeaponAmmoClip( weap ); // For weapon they are reloading, only shout reload if the mag is actually empty at 0
		zombies = getaiarray("axis" );
		zombies = get_array_of_closest( self.origin, zombies, undefined, undefined, 500 ); // Also, only shout reload when more than 1 zombie is near, or else no reason to tell teammates
		if( zombies.size > 1 && mag > 2 && ammo_count == 0 && weap != "zombie_colt") 
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

			reviver thread say_revived_vo();
			self thread say_revived_resp_vo();

		}
	}
}

say_down_vo()
{
	wait(0.5);

	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_down_gen))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_down_gen");
		self.vox_down_gen = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_down_gen[self.vox_down_gen.size] = "vox_down_gen_" + i;	
		}
		self.vox_down_gen_available = self.vox_down_gen;		
	}	
	sound_to_play = random(self.vox_down_gen_available);
	
	self.vox_down_gen_available = array_remove(self.vox_down_gen_available,sound_to_play);
	
	if (self.vox_down_gen_available.size < 1 )
	{
		self.vox_down_gen_available = self.vox_down_gen;
	}
	
	rando = randomintrange(1, 11 );
	//iprintln(rando);
	if(rando < 2 && get_players().size > 2 ) // 10% chance when there's at least 3 or 4 players
	{
		if(index == 0) // If the downed player is player one, unfortunately only index 2 and 3 have lines for this
		{
			//iprintln("mandown_rare");
			self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.2, "mandown_rare");
		}
		else if(index == 3) // If the downed player is sarge, all other 3 char have lines for this
		{
			//iprintln("gen_sarge");
			self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.2, "gen_sarge");
		}
	}
	else if(rando < 7 && get_players().size != 1) // only 60% chance we yell regular mandown, it can get repetitive
	{
		//iprintln("mandown_gen");
		self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.2, "mandown_gen");
	}
	else
	{
		//iprintlnbold("down vo");
		self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25 );
	}
}


say_revived_vo()
{
	wait(0.16); // wait for player to be up
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.revived_teammate))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_revived_teammate");
		self.revived_teammate = [];
		for(i=0;i<num_variants;i++)
		{
			self.revived_teammate[self.revived_teammate.size] = "vox_revived_teammate_" + i;	
		}
		self.revived_teammate_available = self.revived_teammate;		
	}	
	sound_to_play = random(self.revived_teammate_available);
	
	self.revived_teammate_available = array_remove(self.revived_teammate_available,sound_to_play);
	
	if (self.revived_teammate_available.size < 1 )
	{
		self.revived_teammate_available = self.revived_teammate;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.05 );
	
}

say_revived_resp_vo()
{
	wait(1.5);
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_revived))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_revived");
		self.vox_revived = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_revived[self.vox_revived.size] = "vox_revived_" + i;	
		}
		self.vox_revived_available = self.vox_revived;		
	}	
	sound_to_play = random(self.vox_revived_available);
	
	self.vox_revived_available = array_remove(self.vox_revived_available,sound_to_play);
	
	if (self.vox_revived_available.size < 1 )
	{
		self.vox_revived_available = self.vox_revived;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25 );
	
}

say_grenade_vo()
{
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_grenade))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_grenade");
		self.vox_grenade = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_grenade[self.vox_grenade.size] = "vox_grenade_" + i;	
		}
		self.vox_grenade_available = self.vox_grenade;		
	}	
	sound_to_play = random(self.vox_grenade_available);
	
	self.vox_grenade_available = array_remove(self.vox_grenade_available,sound_to_play);
	
	if (self.vox_grenade_available.size < 1 )
	{
		self.vox_grenade_available = self.vox_grenade;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.05 );
	
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