#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility; 
#include maps\_zombiemode_zone_manager; 
#include maps\nazi_zombie_factory_teleporter;
#include maps\_music;
#include maps\_hud_util;


main()
{
	// This has to be first for CreateFX -- Dale
	maps\nazi_zombie_factory_fx::main();


/*	maps\_zombiemode::main();
	players = GetPlayers();
	players[0] SetClientDvar("sv_cheats",1);
*/
	// used to modify the percentages of pulls of ray gun and tesla gun in magic box
	level.pulls_since_last_ray_gun = 0;
	level.pulls_since_last_tesla_gun = 0;
	level.player_drops_tesla_gun = false;

	level.dogs_enabled = true;		//PI ESM - added for dog support
//	level.crawlers_enabled = true;		//MM - added for crawler support
	level.mixed_rounds_enabled = true;	// MM added support for mixed crawlers and dogs
	level.burning_zombies = [];		//JV max number of zombies that can be on fire
	level.traps = [];				//Contains all traps currently in this map
	level.zombie_rise_spawners = [];	// Zombie riser control
	level.max_barrier_search_dist_override = 400;

	//level.door_dialog_function = maps\_zombiemode::play_door_dialog;
	level.achievement_notify_func = maps\_zombiemode_utility::achievement_notify;
	level.dog_spawn_func = maps\_zombiemode_dogs::dog_spawn_factory_logic;

	// Animations needed for door initialization
	script_anims_init();

	level thread maps\_callbacksetup::SetupCallbacks();
	
	level.zombie_anim_override = maps\nazi_zombie_factory::anim_override_func;
	

	SetDvar( "perk_altMeleeDamage", 1000 ); // adjusts how much melee damage a player with the perk will do, needs only be set once

	precachestring(&"ZOMBIE_FLAMES_UNAVAILABLE");
	precachestring(&"REMASTERED_ZOMBIE_FLAMES_UNAVAILABLE_HAND");

	precachestring(&"REMASTERED_ZOMBIE_ELECTRIC_SWITCH");

	precachestring(&"ZOMBIE_POWER_UP_TPAD");
	precachestring(&"ZOMBIE_TELEPORT_TO_CORE");
	precachestring(&"ZOMBIE_LINK_TPAD");
	precachestring(&"ZOMBIE_LINK_ACTIVE");
	precachestring(&"ZOMBIE_INACTIVE_TPAD");
	precachestring(&"ZOMBIE_START_TPAD");

	precacheshellshock("electrocution");
	precachemodel("zombie_zapper_cagelight_red");
	precachemodel("zombie_zapper_cagelight_green");
	precacheModel("lights_indlight_on" );
	precacheModel("lights_milit_lamp_single_int_on" );
	precacheModel("lights_tinhatlamp_on" );
	precacheModel("lights_berlin_subway_hat_0" );
	precacheModel("lights_berlin_subway_hat_50" );
	precacheModel("lights_berlin_subway_hat_100" );
	precachemodel("collision_geo_32x32x128");
	precacheModel("collision_wall_64x64x10"); // new
	precachemodel("char_usa_raider_gear_flametank");

	precacheModel("zombie_handheld_radio"); // cut radio
	precacheModel("zombie_books_open");
	precacheModel("panel_fuse"); // new
	precacheModel("static_global_electric_wire"); // new
	precacheModel("zombie_teleporter_button"); // new
	precacheModel("static_seelow_toolbox"); // new
	precacheModel("zombie_sumpf_zipcage_switch"); //new

	PrecacheShader("hud_fuse"); // new
	PrecacheShader("hud_fuse_wire"); // new
	PrecacheShader("hud_tools"); // new

	PrecacheItem( "zombie_item_journal" ); // new
	PrecacheItem( "zombie_item_beaker" ); // new

	precachestring(&"ZOMBIE_BETTY_ALREADY_PURCHASED");
	precachestring(&"REMASTERED_ZOMBIE_BETTY_HOWTO");
	precachestring(&"REMASTERED_ZOMBIE_INTRO_FACTORY_LEVEL_PLACE");
	precachestring(&"REMASTERED_ZOMBIE_INTRO_FACTORY_LEVEL_TIME");

	include_weapons();
	include_powerups();
	level.use_zombie_heroes = true;
	maps\_zombiemode::main("receiver_zone_spawners");
	//maps\_zombiemode_coord_help::init();
	maps\_zombiemode_health_help::init();

	maps\walking_anim::main();
	
	init_sounds();
	init_achievement();
	//ESM - activate the initial exterior goals
	//level.exterior_goals = getstructarray("exterior_goal","targetname");		
	
	//for(i=0;i<level.exterior_goals.size;i++)
	//{
	//	level.exterior_goals[i].is_active = 1;
	//}
	//ESM - two electrice switches, everything inactive until the right one gets used
//	level thread wuen_electric_switch();
//	level thread warehouse_electric_switch();
//	level thread watch_bridge_halves();
	level thread power_electric_switch();
	
	level thread magic_box_init();

	// This controls when zones become active and start monitoring players so zombies can spawn
//	level thread setup_door_waits();

	// If you want to modify/add to the weapons table, please copy over the _zombiemode_weapons init_weapons() and paste it here.
	// I recommend putting it in it's own function...
	// If not a MOD, you may need to provide new localized strings to reflect the proper cost.	

	
	//ESM - time for electrocuting
	thread init_elec_trap_trigs();

	level.zone_manager_init_func = ::factory_zone_init;
	level thread maps\_zombiemode_zone_manager::manage_zones( "receiver_zone" );

	teleporter_init();
	
	//AUDIO: Initiating Killstreak Dialog and Zombie Behind Vocals
	players = get_players(); 
	
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread player_killstreak_timer();
		players[i] thread player_zombie_awareness();
	}
	
	players[randomint(players.size)] thread level_start_vox(); //Plays a "Power's Out" Message from a random player at start

	level thread intro_screen();

	level thread jump_from_bridge();
	level lock_additional_player_spawner();

	level thread bridge_init();
	
	//AUDIO EASTER EGGS
	level thread phono_egg_init( "phono_one", "phono_one_origin" );
	level thread phono_egg_init( "phono_two", "phono_two_origin" );
	level thread phono_egg_init( "phono_three", "phono_three_origin" );

	level thread setup_meteor_audio();
	//level thread meteor_egg_play();
	level thread radio_egg_init( "radio_one", "radio_one_origin" );
	level thread radio_egg_init( "radio_two", "radio_two_origin" );
	level thread radio_egg_init( "radio_three", "radio_three_origin" );
	level thread radio_egg_init( "radio_four", "radio_four_origin" );
	level thread radio_egg_init( "radio_five", "radio_five_origin" );
	//level thread radio_egg_hanging_init( "radio_five", "radio_five_origin" );
	level.monk_scream_trig = getent( "monk_scream_trig", "targetname" );
	level thread play_giant_mythos_lines();
	level thread play_level_easteregg_vox( "vox_corkboard_1" );
	level thread play_level_easteregg_vox( "vox_corkboard_2" );
	level thread play_level_easteregg_vox( "vox_corkboard_3" );
	level thread play_level_easteregg_vox( "vox_teddy" );
	level thread play_level_easteregg_vox( "vox_fieldop" );
	level thread play_level_easteregg_vox( "vox_telemap" );
	level thread play_level_easteregg_vox( "vox_maxis" );
	level thread play_level_easteregg_vox( "vox_illumi_1" );
	level thread play_level_easteregg_vox( "vox_illumi_2" );

	// Special level specific settings
	set_zombie_var( "zombie_powerup_drop_max_per_round", 3 );	// lower this to make drop happen more often

	// Check under the machines for change
	trigs = GetEntArray( "audio_bump_trigger", "targetname" );
	for ( i=0; i<trigs.size; i++ )
	{
		if ( IsDefined(trigs[i].script_sound) && trigs[i].script_sound == "perks_rattle" && IsDefined(trigs[i].script_string) && trigs[i].script_string != "revive_perk" )
		{
			trigs[i] thread check_for_change();
		}
		else if ( IsDefined(trigs[i].script_sound) && trigs[i].script_sound == "perks_rattle" && IsDefined(trigs[i].script_string) && trigs[i].script_string == "revive_perk" )
		{
			trigs[i] thread check_for_change_quick();
		}
	}

	trigs = GetEntArray( "trig_ee", "targetname" );
	array_thread( trigs, ::extra_events);

	level thread flytrap();
	level thread hanging_dead_guy( "hanging_dead_guy" );

	spawncollision("collision_geo_32x32x128","collider",(-5, 543, 112), (0, 348.6, 0));
	spawncollision("collision_wall_64x64x10","collider",(606.1, -2225, 286.5), (0, -90, 0)); // new, fixes collision at cat walk barrier

	level thread fix_bad_spots();
	level thread sumpf_check();
	level thread maps\nazi_zombie_factory_new_eggs::init();
}

init_achievement()
{
	include_achievement( "achievement_shiny" );
	include_achievement( "achievement_monkey_see" );
	include_achievement( "achievement_frequent_flyer" );
	include_achievement( "achievement_this_is_a_knife" );
	include_achievement( "achievement_martian_weapon" );
	//include_achievement( "achievement_faction_weapon" );
	include_achievement( "achievement_double_whammy" );
	include_achievement( "achievement_perkaholic" );
	include_achievement( "achievement_secret_weapon", "zombie_kar98k_upgraded" );
	include_achievement( "achievement_no_more_door" );
	include_achievement( "achievement_back_to_future" );

}

//
//	Create the zone information for zombie spawning
//
factory_zone_init()
{
	// Note this setup is based on a flag-centric view of setting up your zones.  A brief
	//	zone-centric example exists below in comments

	// Outside East Door
	add_adjacent_zone( "receiver_zone",		"outside_east_zone",	"enter_outside_east" );

	// Outside West Door
	add_adjacent_zone( "receiver_zone",		"outside_west_zone",	"enter_outside_west" );

	// Wnuen building ground floor
	add_adjacent_zone( "wnuen_zone",		"outside_east_zone",	"enter_wnuen_building" );

	// Wnuen stairway
	add_adjacent_zone( "wnuen_zone",		"wnuen_bridge_zone",	"enter_wnuen_loading_dock" );

	// Warehouse bottom 
	add_adjacent_zone( "warehouse_bottom_zone", "outside_west_zone",	"enter_warehouse_building" );

	// Warehosue top
	add_adjacent_zone( "warehouse_bottom_zone", "warehouse_top_zone",	"enter_warehouse_second_floor" );
	add_adjacent_zone( "warehouse_top_zone",	"bridge_zone",			"enter_warehouse_second_floor" );

	// TP East
	add_adjacent_zone( "tp_east_zone",			"wnuen_zone",			"enter_tp_east" );
	flag_array[0] = "enter_tp_east";
	flag_array[1] = "enter_wnuen_building";
	add_adjacent_zone( "tp_east_zone",			"outside_east_zone",	flag_array,			true );

	// TP South
	add_adjacent_zone( "tp_south_zone",			"outside_south_zone",	"enter_tp_south" );

	// TP West
	add_adjacent_zone( "tp_west_zone",			"warehouse_top_zone",	"enter_tp_west" );
	flag_array[0] = "enter_tp_west";
	flag_array[1] = "enter_warehouse_second_floor";
	add_adjacent_zone( "tp_west_zone",			"warehouse_bottom_zone", flag_array,		true );

	/*
	// A ZONE-centric example of initialization
	//	It's the same calls, sorted by zone, and made one-way to show connections on a per/zone basis

	// Receiver zone
	add_adjacent_zone( "receiver_zone",		"outside_east_zone",	"enter_outside_east",		true );
	add_adjacent_zone( "receiver_zone",		"outside_west_zone",	"enter_outside_west",		true );

	// Outside East Zone
	add_adjacent_zone( "outside_east_zone",	"receiver_zone",		"enter_outside_east",		true );
	add_adjacent_zone( "outside_east_zone",	"wnuen_zone",			"enter_wnuen_building",		true );

	// Wnuen Zone
	add_adjacent_zone( "wnuen_zone",		"tp_east_zone",			"enter_tp_east",			true );
	add_adjacent_zone( "wnuen_zone",		"wnuen_bridge_zone",	"enter_wnuen_loading_dock",	true );

	// TP East
	add_adjacent_zone( "tp_east_zone",		"wnuen_zone",			"enter_tp_east",			true );
	flag_array[0] = "enter_tp_east";
	flag_array[1] = "enter_wnuen_building";
	add_adjacent_zone( "tp_east_zone",		"outside_east",			flag_array,					true );
	*/
}


//
//	Intro Chyron!
intro_screen()
{

	flag_wait( "all_players_connected" );
	wait(2);
	level.intro_hud = [];
	for(i = 0;  i < 3; i++)
	{
		level.intro_hud[i] = newHudElem();
		level.intro_hud[i].x = 4;
		level.intro_hud[i].y = 0;
		level.intro_hud[i].alignX = "left";
		level.intro_hud[i].alignY = "bottom";
		level.intro_hud[i].horzAlign = "left";
		level.intro_hud[i].vertAlign = "bottom";
		level.intro_hud[i].foreground = true;

		if ( level.splitscreen && !level.hidef )
		{
			level.intro_hud[i].fontScale = 2.75;
		}
		else
		{
			level.intro_hud[i].fontScale = 1.75;
		}
		level.intro_hud[i].alpha = 0.0;
		level.intro_hud[i].color = (1, 1, 1);
		level.intro_hud[i].inuse = false;
	}
	level.intro_hud[0].y = -110;
	level.intro_hud[1].y = -90;
	level.intro_hud[2].y = -70;


	level.intro_hud[0] settext(&"REMASTERED_ZOMBIE_INTRO_FACTORY_LEVEL_PLACE");
	level.intro_hud[1] settext(&"REMASTERED_ZOMBIE_INTRO_FACTORY_LEVEL_TIME");
//	level.intro_hud[2] settext(&"ZOMBIE_INTRO_FACTORY_LEVEL_DATE");

	for(i = 0 ; i < 3; i++)
	{
		level.intro_hud[i] FadeOverTime( 1.5 ); 
		level.intro_hud[i].alpha = 1;
		wait(1.5);
	}
	wait(1.5);
	for(i = 0 ; i < 3; i++)
	{
		level.intro_hud[i] FadeOverTime( 1.5 ); 
		level.intro_hud[i].alpha = 0;
		wait(1.5);
	}	
	//wait(1.5);
	for(i = 0 ; i < 3; i++)
	{
		level.intro_hud[i] destroy();
	}
}


//-------------------------------------------------------------------
//	Animation functions - need to be specified separately in order to use different animtrees
//-------------------------------------------------------------------
#using_animtree( "zombie_factory" );
script_anims_init()
{
	level.scr_anim[ "half_gate" ]			= %o_zombie_lattice_gate_half;
	level.scr_anim[ "full_gate" ]			= %o_zombie_lattice_gate_full;
	level.scr_anim[ "difference_engine" ]	= %o_zombie_difference_engine_ani;

	level.blocker_anim_func = ::factory_playanim;
}

factory_playanim( animname )
{
	self UseAnimTree(#animtree);
	self animscripted("door_anim", self.origin, self.angles, level.scr_anim[animname] );
}


#using_animtree( "generic_human" );
anim_override_func()
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

		level.scr_anim["zombie"]["run4"] 	= %ai_zombie_run_v2;
		level.scr_anim["zombie"]["run5"] 	= %ai_zombie_run_v4;
		level.scr_anim["zombie"]["run6"] 	= %ai_zombie_run_v3;

		level.scr_anim["zombie"]["walk5"] 	= %ai_zombie_walk_v6;
		level.scr_anim["zombie"]["walk6"] 	= %ai_zombie_walk_v7;
		level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_walk_v8;
		level.scr_anim["zombie"]["walk8"] 	= %ai_zombie_walk_v9;
}

lock_additional_player_spawner()
{
	
	spawn_points = getstructarray("player_respawn_point", "targetname");
	for( i = 0; i < spawn_points.size; i++ )
	{

			spawn_points[i].locked = true;

	}
}

//-------------------------------------------------------------------------------
// handles lowering the bridge when power is turned on
//-------------------------------------------------------------------------------
bridge_init()
{
	flag_init( "bridge_down" );
	// raise bridge
	wnuen_bridge = getent( "wnuen_bridge", "targetname" );
	wnuen_bridge_coils = GetEntArray( "wnuen_bridge_coils", "targetname" );
	for ( i=0; i<wnuen_bridge_coils.size; i++ )
	{
		wnuen_bridge_coils[i] LinkTo( wnuen_bridge );
	}
	wnuen_bridge rotatepitch( 90, 1, .5, .5 );

	warehouse_bridge = getent( "warehouse_bridge", "targetname" );
	warehouse_bridge_coils = GetEntArray( "warehouse_bridge_coils", "targetname" );
	for ( i=0; i<warehouse_bridge_coils.size; i++ )
	{
		warehouse_bridge_coils[i] LinkTo( warehouse_bridge );
	}
	warehouse_bridge rotatepitch( -90, 1, .5, .5 );
	
	bridge_audio = getstruct( "bridge_audio", "targetname" );

	// wait for power
	flag_wait( "electricity_on" );

	// lower bridge
	wnuen_bridge rotatepitch( -90, 4, .5, 1.5 );
	warehouse_bridge rotatepitch( 90, 4, .5, 1.5 );
	
	if(isdefined( bridge_audio ) )
		playsoundatposition( "bridge_lower", bridge_audio.origin );

	wnuen_bridge connectpaths();
	warehouse_bridge connectpaths();

	exploder( 500 );

	// wait until the bridges are down.
	wnuen_bridge waittill( "rotatedone" );
	
	flag_set( "bridge_down" );
	if(isdefined( bridge_audio ) )
		playsoundatposition( "bridge_hit", bridge_audio.origin );

	wnuen_bridge_clip = getent( "wnuen_bridge_clip", "targetname" );
	wnuen_bridge_clip delete();

	warehouse_bridge_clip = getent( "warehouse_bridge_clip", "targetname" );
	warehouse_bridge_clip delete();

	maps\_zombiemode_zone_manager::connect_zones( "wnuen_bridge_zone", "bridge_zone" );
	maps\_zombiemode_zone_manager::connect_zones( "warehouse_top_zone", "bridge_zone" );
}


//
//
jump_from_bridge()
{
	trig = GetEnt( "trig_outside_south_zone", "targetname" );
	trig waittill( "trigger" );

	maps\_zombiemode_zone_manager::connect_zones( "outside_south_zone", "bridge_zone", true );
	maps\_zombiemode_zone_manager::connect_zones( "outside_south_zone", "wnuen_bridge_zone", true );
}


init_sounds()
{
	maps\_zombiemode_utility::add_sound( "break_stone", "break_stone" );
	maps\_zombiemode_utility::add_sound( "gate_door",	"open_door" );
	maps\_zombiemode_utility::add_sound( "heavy_door",	"open_door" );
}


// Include the weapons that are only inr your level so that the cost/hints are accurate
// Also adds these weapons to the random treasure chest.
include_weapons()
{
	// Starting Pistols
	include_weapon( "zombie_colt", false );
	include_weapon( "zombie_colt_upgraded", false );
	include_weapon( "zombie_walther", false );
	include_weapon( "zombie_walther_upgraded", false );
	include_weapon( "zombie_nambu", false );
	include_weapon( "zombie_nambu_upgraded", false );
	include_weapon( "zombie_tokarev", false );
	include_weapon( "zombie_tokarev_upgraded", false );
	
	// Pistols
	include_weapon( "zombie_sw_357" );
	include_weapon( "zombie_sw_357_upgraded", false );

	// Bolt Action
	include_weapon( "zombie_kar98k" );
	include_weapon( "zombie_kar98k_upgraded", false );
//	include_weapon( "springfield");		
//	include_weapon( "zombie_type99_rifle" );
//	include_weapon( "zombie_type99_rifle_upgraded", false );

	// Semi Auto
	include_weapon( "zombie_m1carbine" );
	include_weapon( "zombie_m1carbine_upgraded", false );
	include_weapon( "zombie_m1garand" );
	include_weapon( "zombie_m1garand_upgraded", false );
	include_weapon( "zombie_gewehr43" );
	include_weapon( "zombie_gewehr43_upgraded", false );
	include_weapon( "zombie_svt40" );
	include_weapon( "zombie_svt40_upgraded", false );

	// Full Auto
	include_weapon( "zombie_stg44" );
	include_weapon( "zombie_stg44_upgraded", false );
	include_weapon( "zombie_thompson" );
	include_weapon( "zombie_thompson_upgraded", false );
	include_weapon( "zombie_mp40" );
	include_weapon( "zombie_mp40_upgraded", false );
	include_weapon( "zombie_type100_smg" );
	include_weapon( "zombie_type100_smg_upgraded", false );

	// Scoped
	include_weapon( "ptrs41_zombie" );
	include_weapon( "ptrs41_zombie_upgraded", false );
	include_weapon( "mosin_rifle_scoped_zombie" );
	include_weapon( "mosin_rifle_scoped_zombie_upgraded", false );

	// RIFLES DISABLED
/*	include_weapon( "kar98k_scoped_zombie", false );
	include_weapon( "kar98k_scoped_zombie_upgraded", false );

	include_weapon( "type99_rifle_scoped_zombie", false );
	include_weapon( "type99_rifle_scoped_zombie_upgraded", false );

	include_weapon( "springfield_scoped_zombie", false );
	include_weapon( "springfield_scoped_zombie_upgraded", false );*/

	// Grenade
	include_weapon( "molotov" );
	include_weapon( "stielhandgranate", false );

	// Grenade Launcher	
	include_weapon( "m1garand_gl_zombie" );
	include_weapon( "m1garand_gl_zombie_upgraded", false );
	include_weapon( "m7_launcher_zombie" );
	include_weapon( "m7_launcher_zombie_upgraded", false );

	// Flamethrower
	include_weapon( "m2_flamethrower_zombie" );
	include_weapon( "m2_flamethrower_zombie_upgraded", false );

	// Shotgun
	include_weapon( "zombie_doublebarrel" );
	include_weapon( "zombie_doublebarrel_upgraded", false );
	include_weapon( "zombie_doublebarrel_sawed" );
	include_weapon( "zombie_doublebarrel_sawed_upgraded", false );
	include_weapon( "zombie_shotgun" );
	include_weapon( "zombie_shotgun_upgraded", false );

	// Heavy MG
	include_weapon( "zombie_bar" );
	include_weapon( "zombie_bar_upgraded", false );
	include_weapon( "zombie_fg42" );
	include_weapon( "zombie_fg42_upgraded", false );

	include_weapon( "zombie_30cal" );
	include_weapon( "zombie_30cal_upgraded", false );
	include_weapon( "zombie_mg42" );
	include_weapon( "zombie_mg42_upgraded", false );
	include_weapon( "zombie_ppsh" );
	include_weapon( "zombie_ppsh_upgraded", false );
	include_weapon( "zombie_type99_lmg" );
	include_weapon( "zombie_type99_lmg_upgraded", false );
	include_weapon( "zombie_dp28" );
	include_weapon( "zombie_dp28_upgraded", false );

	// Rocket Launcher
	include_weapon( "panzerschrek_zombie" );
	include_weapon( "panzerschrek_zombie_upgraded", false );

	// Special
	include_weapon( "ray_gun", true, ::factory_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded", false );
	include_weapon( "tesla_gun", true, ::factory_tesla_weighting_func );
	include_weapon( "tesla_gun_upgraded", false );
	include_weapon( "zombie_cymbal_monkey", true, ::factory_cymbal_monkey_weighting_func );

	//include_weapon( "falling_hands", false );
	//bouncing betties
	include_weapon("mine_bouncing_betty", false);

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "zombie_colt", 0 );
	//maps\_zombiemode_weapons::add_limited_weapon( "zombie_kar98k", 0 );
	//maps\_zombiemode_weapons::add_limited_weapon( "zombie_gewehr43", 0 );
	//maps\_zombiemode_weapons::add_limited_weapon( "zombie_m1garand", 0 );
}

factory_tesla_weighting_func()
{
	num_to_add = 1;
	if( isDefined( level.pulls_since_last_tesla_gun ) )
	{
		// player has dropped the tesla for another weapon, so we set all future polls to 20% nerfed to 15
		if( isDefined(level.player_drops_tesla_gun) && level.player_drops_tesla_gun == true )
		{						
			num_to_add += int(.15 * level.zombie_include_weapons.size);		
		}
		
		// player has not seen tesla gun in late rounds
		if( !isDefined(level.player_seen_tesla_gun) || level.player_seen_tesla_gun == false )
		{
			// after round 10 the Tesla gun percentage increases to 20% nerfed to 15
			if( level.round_number > 10 )
			{
				num_to_add += int(.15 * level.zombie_include_weapons.size);
			}		
			// after round 5 the Tesla gun percentage increases to 15% nerfed to 10
			else if( level.round_number > 5 )
			{
				// calculate the number of times we have to add it to the array to get the desired percent
				num_to_add += int(.10 * level.zombie_include_weapons.size);
			}						
		}
	}
	return num_to_add;
}


factory_ray_gun_weighting_func()
{
	if( level.box_moved == true || level.box_moved == false )
	{	
		num_to_add = 1;
		// increase the percentage of ray gun
		if( isDefined( level.pulls_since_last_ray_gun ) )
		{
			// after 12 pulls the ray gun percentage increases to 15%
			if( level.pulls_since_last_ray_gun > 11 )
			{
				num_to_add += int(level.zombie_include_weapons.size*0.1);
			}			
			// after 8 pulls the Ray Gun percentage increases to 10%
			else if( level.pulls_since_last_ray_gun > 7 )
			{
				num_to_add += int(.05 * level.zombie_include_weapons.size);
			}		
		}
		return num_to_add;	
	}
	else
	{
		return 0;
	}
}


//
//	Slightly elevate the chance to get it until someone has it, then make it even
factory_cymbal_monkey_weighting_func()
{
	players = get_players();
	count = 0;
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] maps\_zombiemode_weapons::has_weapon_or_upgrade( "zombie_cymbal_monkey" ) )
		{
			count++;
		}
	}
	if ( count > 0 )
	{
		return 1;
	}
	else
	{
		if( level.round_number < 10 )
		{
			return 3;
		}
		else
		{
			return 5;
		}
	}
}


include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "carpenter" );
}



//turn on all of the perk machines
activate_vending_machines()
{
	//activate perks-a-cola
	//level notify( "master_switch_activated" );
	
	//level notify( "specialty_armorvest_power_on" );
	//level notify( "specialty_rof_power_on" );
	//level notify( "specialty_quickrevive_power_on" );
	//level notify( "specialty_fastreload_power_on" );
	
	//clientnotify("revive_on");
	//clientnotify("middle_door_open");
	//clientnotify("fast_reload_on");
	//clientnotify("doubletap_on");
	//clientnotify("jugger_on");	

}


#using_animtree( "generic_human" ); 
force_zombie_crawler()
{
	if( !IsDefined( self ) )
	{
		return;
	}

	if( !self.gibbed )
	{
		refs = []; 

		refs[refs.size] = "no_legs"; 

		if( refs.size )
		{
			self.a.gib_ref = animscripts\death::get_random( refs ); 
		
			// Don't stand if a leg is gone
			self.has_legs = false; 
			self AllowedStances( "crouch" ); 
								
			which_anim = RandomInt( 5 ); 
			
			if( which_anim == 0 ) 
			{
				self.deathanim = %ai_zombie_crawl_death_v1;
				self set_run_anim( "death3" );
				self.run_combatanim = level.scr_anim["zombie"]["crawl1"];
				self.crouchRunAnim = level.scr_anim["zombie"]["crawl1"];
				self.crouchrun_combatanim = level.scr_anim["zombie"]["crawl1"];
			}
			else if( which_anim == 1 ) 
			{
				self.deathanim = %ai_zombie_crawl_death_v2;
				self set_run_anim( "death4" );
				self.run_combatanim = level.scr_anim["zombie"]["crawl2"];
				self.crouchRunAnim = level.scr_anim["zombie"]["crawl2"];
				self.crouchrun_combatanim = level.scr_anim["zombie"]["crawl2"];
			}
			else if( which_anim == 2 ) 
			{
				self.deathanim = %ai_zombie_crawl_death_v1;
				self set_run_anim( "death3" );
				self.run_combatanim = level.scr_anim["zombie"]["crawl3"];
				self.crouchRunAnim = level.scr_anim["zombie"]["crawl3"];
				self.crouchrun_combatanim = level.scr_anim["zombie"]["crawl3"];
			}
			else if( which_anim == 3 ) 
			{
				self.deathanim = %ai_zombie_crawl_death_v2;
				self set_run_anim( "death4" );
				self.run_combatanim = level.scr_anim["zombie"]["crawl4"];
				self.crouchRunAnim = level.scr_anim["zombie"]["crawl4"];
				self.crouchrun_combatanim = level.scr_anim["zombie"]["crawl4"];
			}
			else if( which_anim == 4 ) 
			{
				self.deathanim = %ai_zombie_crawl_death_v1;
				self set_run_anim( "death3" );
				self.run_combatanim = level.scr_anim["zombie"]["crawl5"];
				self.crouchRunAnim = level.scr_anim["zombie"]["crawl5"];
				self.crouchrun_combatanim = level.scr_anim["zombie"]["crawl5"];
			}								
		}

		if( self.health > 50 )
		{
			self.health = 50;
			
			// force gibbing if the zombie is still alive
			self thread animscripts\death::do_gib();
		}
	}
}


//
//	This initialitze the box spawn locations
//	You can disable boxes from appearing by not adding their script_noteworthy ID to the list
//
magic_box_init()
{
	//MM - all locations are valid.  If it goes somewhere you haven't opened, you need to open it.
	level.open_chest_location = [];
	level.open_chest_location[0] = "chest1";	// TP East
	level.open_chest_location[1] = "chest2";	// TP West
	level.open_chest_location[2] = "chest3";	// TP South
	level.open_chest_location[3] = "chest4";	// WNUEN
	level.open_chest_location[4] = "chest5";	// Warehouse bottom
	level.open_chest_location[5] = "start_chest";
}


/*------------------------------------
the electric switch under the bridge
once this is used, it activates other objects in the map
and makes them available to use
------------------------------------*/
power_electric_switch()
{
	trig = getent("use_power_switch","targetname");
	master_switch = getent("power_switch","targetname");	
	master_switch notsolid();
	//master_switch rotatepitch(90,1);
	trig sethintstring(&"REMASTERED_ZOMBIE_ELECTRIC_SWITCH");
		
	//turn off the buyable door triggers for electric doors
// 	door_trigs = getentarray("electric_door","script_noteworthy");
// 	array_thread(door_trigs,::set_door_unusable);
// 	array_thread(door_trigs,::play_door_dialog);

	cheat = false;
	
/# 
	if( GetDvarInt( "zombie_cheat" ) >= 3 )
	{
		wait( 5 );
		cheat = true;
	}
#/	

	user = undefined;
	if ( cheat != true )
	{
		trig waittill("trigger",user);
	}
	
	// MM - turning on the power powers the entire map
// 	if ( IsDefined(user) )	// only send a notify if we weren't originally triggered through script
// 	{
// 		other_trig = getent("use_warehouse_switch","targetname");
// 		other_trig notify( "trigger", undefined );
// 
// 		wuen_trig = getent("use_wuen_switch", "targetname" );
// 		wuen_trig notify( "trigger", undefined );
// 	}

	master_switch rotateroll(-90,.3);

	//TO DO (TUEY) - kick off a 'switch' on client script here that operates similiarly to Berlin2 subway.
	master_switch playsound("switch_flip");
	flag_set( "electricity_on" );
	wait_network_frame();
	clientnotify( "revive_on" );
	wait_network_frame();
	clientnotify( "fast_reload_on" );
	wait_network_frame();
	clientnotify( "doubletap_on" );
	wait_network_frame();
	clientnotify( "jugger_on" );
	wait_network_frame();
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "revive_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
	level notify( "specialty_armorvest_power_on" );
	wait_network_frame();
	level notify( "specialty_rof_power_on" );
	wait_network_frame();
	level notify( "specialty_quickrevive_power_on" );
	wait_network_frame();
	level notify( "specialty_fastreload_power_on" );
	wait_network_frame();

//	clientnotify( "power_on" );
	ClientNotify( "pl1" );	// power lights on
	exploder(600);

	trig delete();	
	
	playfx(level._effect["switch_sparks"] ,getstruct("power_switch_fx","targetname").origin);

	// Don't want east or west to spawn when in south zone, but vice versa is okay
	maps\_zombiemode_zone_manager::connect_zones( "outside_east_zone", "outside_south_zone" );
	maps\_zombiemode_zone_manager::connect_zones( "outside_west_zone", "outside_south_zone", true );
}


/**********************
Electrical trap
**********************/
init_elec_trap_trigs()
{
	//trap_trigs = getentarray("gas_access","targetname");
	//array_thread (trap_trigs,::electric_trap_think);
	//array_thread (trap_trigs,::electric_trap_dialog);

	// MM - traps disabled for now
	array_thread( getentarray("warehouse_electric_trap",	"targetname"), ::electric_trap_think, "enter_warehouse_building" );
	array_thread( getentarray("wuen_electric_trap",			"targetname"), ::electric_trap_think, "enter_wnuen_building" );
	array_thread( getentarray("bridge_electric_trap",		"targetname"), ::electric_trap_think, "bridge_down" );
}

electric_trap_dialog()
{

	self endon ("warning_dialog");
	level endon("switch_flipped");
	timer =0;
	while(1)
	{
		wait(0.5);
		players = get_players();
		for(i = 0; i < players.size; i++)
		{		
			dist = distancesquared(players[i].origin, self.origin );
			if(dist > 70*70)
			{
				timer = 0;
				continue;
			}
			if(dist < 70*70 && timer < 3)
			{
				wait(0.5);
				timer ++;
			}
			if(dist < 70*70 && timer == 3)
			{
				
				index = maps\_zombiemode_weapons::get_player_index(players[i]);
				plr = "plr_" + index + "_";
				//players[i] create_and_play_dialog( plr, "vox_level_start", 0.25 );
				wait(3);				
				self notify ("warning_dialog");
				//iprintlnbold("warning_given");
			}
		}
	}
}


/*------------------------------------
	This controls the electric traps in the level
		self = use trigger associated with the trap
------------------------------------*/
electric_trap_think( enable_flag )
{	
	self sethintstring(&"REMASTERED_ZOMBIE_FLAMES_UNAVAILABLE_HAND");
	self.zombie_cost = 1000;
	
	self thread electric_trap_dialog();

	// get a list of all of the other triggers with the same name
	triggers = getentarray( self.targetname, "targetname" );
	flag_wait( "electricity_on" );

	// Get the damage trigger.  This is the unifying element to let us know it's been activated.
	self.zombie_dmg_trig = getent(self.target,"targetname");
	self.zombie_dmg_trig.in_use = 0;

	// Set buy string
	self sethintstring(&"ZOMBIE_BUTTON_NORTH_FLAMES");
	self setCursorHint( "HINT_NOICON" );

	// Getting the light that's related is a little esoteric, but there isn't
	// a better way at the moment.  It uses linknames, which are really dodgy.
	light_name = "";	// scope declaration
	tswitch = getent(self.script_linkto,"script_linkname");
	switch ( tswitch.script_linkname )
	{
	case "10":	// wnuen
	case "11":
		light_name = "zapper_light_wuen";	
		break;

	case "20":	// warehouse
	case "21":
		light_name = "zapper_light_warehouse";
		break;

	case "30":	// Bridge
	case "31":
		light_name = "zapper_light_bridge";
		break;
	}

	// The power is now on, but keep it disabled until a certain condition is met
	//	such as opening the door it is blocking or waiting for the bridge to lower.
	if ( !flag( enable_flag ) )
	{
		self trigger_off();

		zapper_light_red( light_name );
		flag_wait( enable_flag );

		self trigger_on();
	}

	// Open for business!  
	zapper_light_green( light_name );

	while(1)
	{
		//valve_trigs = getentarray(self.script_noteworthy ,"script_noteworthy");		
	
		//wait until someone uses the valve
		self waittill("trigger",who);
		if( who in_revive_trigger() )
		{
			continue;
		}
		
		if( is_player_valid( who ) )
		{
			if( who.score >= self.zombie_cost )
			{				
				if(!self.zombie_dmg_trig.in_use)
				{
					self.zombie_dmg_trig.in_use = 1;

					//turn off the valve triggers associated with this trap until available again
					array_thread (triggers, ::trigger_off);

					play_sound_at_pos( "purchase", who.origin );
					self thread electric_trap_move_switch(self);
					//need to play a 'woosh' sound here, like a gas furnace starting up
					self waittill("switch_activated");
					//set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );

					//this trigger detects zombies walking thru the flames
					self.zombie_dmg_trig trigger_on();

					//play the flame FX and do the actual damage
					self thread activate_electric_trap();					

					//wait until done and then re-enable the valve for purchase again
					self waittill("elec_done");
					
					clientnotify(self.script_string +"off");
										
					//delete any FX ents
					if(isDefined(self.fx_org))
					{
						self.fx_org delete();
					}
					if(isDefined(self.zapper_fx_org))
					{
						self.zapper_fx_org delete();
					}
					if(isDefined(self.zapper_fx_switch_org))
					{
						self.zapper_fx_switch_org delete();
					}
										
					//turn the damage detection trigger off until the flames are used again
			 		self.zombie_dmg_trig trigger_off();
					self notify("trap_over");

					wait(30);

					array_thread (triggers, ::trigger_on);

					//COLLIN: Play the 'alarm' sound to alert players that the traps are available again (playing on a temp ent in case the PA is already in use.
					//speakerA = getstruct("loudspeaker", "targetname");
					//playsoundatposition("warning", speakera.origin);
					self notify("available");

					self.zombie_dmg_trig.in_use = 0;
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				who thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
			}
		}
	}
}


//
//  it's a throw switch
electric_trap_move_switch(parent)
{
	light_name = "";	// scope declaration
	tswitch = getent(parent.script_linkto,"script_linkname");
	switch ( tswitch.script_linkname )
	{
	case "10":	// wnuen
	case "11":
		light_name = "zapper_light_wuen";	
		break;

	case "20":	// warehouse
	case "21":
		light_name = "zapper_light_warehouse";
		break;

	case "30":
	case "31":
		light_name = "zapper_light_bridge";
		break;
	}
	
	//turn the light above the door red, rotate lever down, and play sound
	zapper_light_red( light_name );
	tswitch rotatepitch(180,.5);
	tswitch playsound("amb_sparks_l_b");
	tswitch waittill("rotatedone");

	//when lever is down, activate
	self notify("switch_activated");

	//wait until trap is done and then rotate back up
	self waittill("trap_over");
	tswitch rotatepitch(-180,.5);
	tswitch playsound("switch_up");

	//wait until trap is ready to turn green
	self waittill("available");
	
	//turn the light back green once the trap is available again
	zapper_light_green( light_name );
}


//
//
activate_electric_trap()
{
	if(isDefined(self.script_string) && self.script_string == "warehouse")
	{
		clientnotify("warehouse");
	}
	else if(isDefined(self.script_string) && self.script_string == "wuen")
	{
		clientnotify("wuen");
	}
	else
	{
		clientnotify("bridge");
	}	
		
	clientnotify(self.target);
	
	fire_points = getstructarray(self.target,"targetname");
	
	for(i=0;i<fire_points.size;i++)
	{
		wait_network_frame();
		fire_points[i] thread electric_trap_fx(self);		
	}
	
	//do the damage
	self.zombie_dmg_trig thread elec_barrier_damage();
	
	// reset the zapper model
	level waittill("arc_done");
}


//
//
electric_trap_fx(notify_ent)
{
	self.tag_origin = spawn("script_model",self.origin);
	//self.tag_origin setmodel("tag_origin");

	//playfxontag(level._effect["zapper"],self.tag_origin,"tag_origin");

	self.tag_origin playsound("elec_start");
	self.tag_origin playloopsound("elec_loop");
	self thread play_electrical_sound();
	
	wait(30);
		
	self.tag_origin stoploopsound();
		
	self.tag_origin delete(); 
	notify_ent notify("elec_done");
	level notify ("arc_done");	
}


//
//
play_electrical_sound()
{
	level endon ("arc_done");
	while(1)
	{	
		wait(randomfloatrange(0.1, 0.5));
		playsoundatposition("elec_arc", self.origin);
	}
	

}


//
//
elec_barrier_damage()
{	
	while(1)
	{
		self waittill("trigger",ent);
		
		//player is standing electricity, dumbass
		if(isplayer(ent) )
		{
			ent thread player_elec_damage();
		}
		else
		{
			if(!isDefined(ent.marked_for_death))
			{
				ent.marked_for_death = true;
				ent thread zombie_elec_death( randomint(100) );
			}
		}
	}
}
play_elec_vocals()
{
	if(IsDefined (self)) 
	{
		org = self.origin;
		wait(0.15);
		playsoundatposition("elec_vocals", org);
		playsoundatposition("zombie_arc", org);
		playsoundatposition("exp_jib_zombie", org);
	}
}
player_elec_damage()
{	
	self endon("death");
	self endon("disconnect");
	
	if(!IsDefined (level.elec_loop))
	{
		level.elec_loop = 0;
	}	
	
	if( !isDefined(self.is_burning) && !self maps\_laststand::player_is_in_laststand() )
	{
		self stopShellshock();

		self.is_burning = 1;		
		self setelectrified(1.25);	
		
		if(level.elec_loop == 0)
		{	
			elec_loop = 1;
			//self playloopsound ("electrocution");
			self playsound("zombie_arc");
		}

        if(self.health < 225)
        {
            shocktime = 2.5;
            self shellshock("electrocution", shocktime);
        }

		if(!self hasperk("specialty_armorvest") || self.health - 100 < 1)
		{
			
			radiusdamage(self.origin,10,self.health + 100,self.health + 100);
			self.is_burning = undefined;

		}
		else
		{
			self dodamage(50, self.origin);
			wait(.1);
			//self playsound("zombie_arc");
			self.is_burning = undefined;
		}


	}

}


zombie_elec_death(flame_chance)
{
	self endon("death");
	
	//10% chance the zombie will burn, a max of 6 burning zombs can be goign at once
	//otherwise the zombie just gibs and dies
	if(!self enemy_is_dog())
	{
		if(flame_chance > 90 && level.burning_zombies.size < 6)
		{
			level.burning_zombies[level.burning_zombies.size] = self;
			self thread zombie_flame_watch();
			self playsound("ignite");
			self thread animscripts\death::flame_death_fx();
			wait(randomfloat(1.25));		
		}
		else
		{
			
			refs[0] = "guts";
			refs[1] = "right_arm"; 
			refs[2] = "left_arm"; 
			refs[3] = "right_leg"; 
			refs[4] = "left_leg"; 
			refs[5] = "no_legs";
			refs[6] = "head";
			self.a.gib_ref = refs[randomint(refs.size)];

			playsoundatposition("zombie_arc", self.origin);
			if( randomint(100) > 50 )
			{
				self thread electroctute_death_fx();
				self thread play_elec_vocals();
			}
			wait(randomfloat(1.25));
			self playsound("zombie_arc");
		}
	}
	else // if dog
	{
		wait(randomfloat(0.5));
	}

	self dodamage(self.health + 666, self.origin);
	//iprintlnbold("should be damaged");
}

zombie_flame_watch()
{
	self waittill("death");
	self stoploopsound();
	level.burning_zombies = array_remove_nokeys(level.burning_zombies,self);
}


//
//	Swaps a cage light model to the red one.
zapper_light_red( lightname )
{
	zapper_lights = getentarray( lightname, "targetname");
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_red");	

		if(isDefined(zapper_lights[i].fx))
		{
			zapper_lights[i].fx delete();
		}

		if(lightname == "zapper_light_warehouse" || lightname == "zapper_light_wuen" )
		{
			zapper_lights[i].fx = Spawn("script_model", zapper_lights[i].origin);
		}
		else
		{
			zapper_lights[i].fx = maps\_zombiemode_net::network_safe_spawn( "trap_light_red", 2, "script_model", zapper_lights[i].origin );
		}
		
		zapper_lights[i].fx setmodel("tag_origin");
		zapper_lights[i].fx.angles = zapper_lights[i].angles+(-90,0,0);

		// fx is playing twice on one of the red lights, causing it to stay red longer than it should
		playfxontag(level._effect["zapper_light_notready"],zapper_lights[i].fx,"tag_origin");
	}
}


//
//	Swaps a cage light model to the green one.
zapper_light_green( lightname )
{
	zapper_lights = getentarray( lightname, "targetname");
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_green");	

		if(isDefined(zapper_lights[i].fx))
		{
			zapper_lights[i].fx delete();
		}
		
		if(lightname == "zapper_light_warehouse" || lightname == "zapper_light_wuen" )
		{
			zapper_lights[i].fx = Spawn("script_model", zapper_lights[i].origin);
		}
		else
		{
			zapper_lights[i].fx = maps\_zombiemode_net::network_safe_spawn( "trap_light_green", 2, "script_model", zapper_lights[i].origin );
		}

		zapper_lights[i].fx setmodel("tag_origin");
		zapper_lights[i].fx.angles = zapper_lights[i].angles+(-90,0,0);
		playfxontag(level._effect["zapper_light_ready"],zapper_lights[i].fx,"tag_origin");
	}
}


//
//	
electroctute_death_fx()
{
	self endon( "death" );


	if (isdefined(self.is_electrocuted) && self.is_electrocuted )
	{
		return;
	}
	
	self.is_electrocuted = true;
	
	self thread electrocute_timeout();
		
	// JamesS - this will darken the burning body
	self StartTanning(); 

	if(self.team == "axis")
	{
		level.bcOnFireTime = gettime();
		level.bcOnFireOrg = self.origin;
	}
	
	
	PlayFxOnTag( level._effect["elec_torso"], self, "J_SpineLower" ); 
	self playsound ("elec_jib_zombie");
	wait 1;

	tagArray = []; 
	tagArray[0] = "J_Elbow_LE"; 
	tagArray[1] = "J_Elbow_RI"; 
	tagArray[2] = "J_Knee_RI"; 
	tagArray[3] = "J_Knee_LE"; 
	tagArray = array_randomize( tagArray ); 

	PlayFxOnTag( level._effect["elec_md"], self, tagArray[0] ); 
	self playsound ("elec_jib_zombie");

	wait 1;
	self playsound ("elec_jib_zombie");

	tagArray[0] = "J_Wrist_RI"; 
	tagArray[1] = "J_Wrist_LE"; 
	if( !IsDefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
	{
		tagArray[2] = "J_Ankle_RI"; 
		tagArray[3] = "J_Ankle_LE"; 
	}
	tagArray = array_randomize( tagArray ); 

	PlayFxOnTag( level._effect["elec_sm"], self, tagArray[0] ); 
	PlayFxOnTag( level._effect["elec_sm"], self, tagArray[1] );

}

electrocute_timeout()
{
	self endon ("death");
	self playloopsound("fire_manager_0");
	// about the length of the flame fx
	wait 12;
	self stoploopsound();
	if (isdefined(self) && isalive(self))
	{
		self.is_electrocuted = false;
		self notify ("stop_flame_damage");
	}
	
}

//*** AUDIO SECTION ***

player_zombie_awareness()
{
	self endon("disconnect");
	self endon("death");
	players = getplayers();
	wait(6);
	index = maps\_zombiemode_weapons::get_player_index(self);
	while(1)
	{
		wait(1);
		
		if( self maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		//zombie = get_closest_ai(self.origin,"axis");
		
		zombs = getaiarray("axis");
		for(i=0;i<zombs.size;i++)
		{
			if(DistanceSquared(zombs[i].origin, self.origin) < 200 * 200)
			{
				if(!isDefined(zombs[i]))
				{
					continue;
				}
				
				dist = 200;				
				switch(zombs[i].zombie_move_speed)
				{
					case "walk": dist = 200;break;
					case "run": dist = 250; break;
					case "sprint": dist = 275;break;
				}				
				if(distance2d(zombs[i].origin,self.origin) < dist)
				{				
					yaw = self animscripts\utility::GetYawToSpot(zombs[i].origin );
					//check to see if he's actually behind the player
					if(yaw < -95 || yaw > 95)
					{
						zombs[i] playsound ("behind_vocals");
					}
				}				
			}
		}
		if(players.size > 0) //NEW
		{
			//Plays 'teamwork' style dialog if there are more than 1 player...
			close_zombs = 0;
			for(i=0;i<zombs.size;i++)
			{
				if(DistanceSquared(zombs[i].origin, self.origin) < 250 * 250)
				{
					close_zombs ++;
				}
			}
			if(close_zombs > 4 && players.size > 1)
			{
				if(randomintrange(0,20) < 5)
				{
					plr = "plr_" + index + "_";
					self thread create_and_play_dialog( plr, "vox_oh_shit", .25, "resp_ohshit" );	
				}
			}
			else if(close_zombs > 8 && players.size == 1)
			{
				if(randomintrange(0,20) < 2)
				{
					plr = "plr_" + index + "_";
					self thread create_and_play_dialog( plr, "vox_oh_shit", .25 );	
				}
			}
		}
	}
}		

level_start_vox()
{
	wait( 6 );//moved here
	
	index = maps\_zombiemode_weapons::get_player_index( self );
	plr = "plr_" + index + "_";
	// wait( 6 );//commented out
	self thread create_and_play_dialog( plr, "vox_level_start", 0.25 );

	// Do easter egg vox on solo
	players = get_players();
	if( players.size == 1 )
	{
		wait( 4 );
		while(1)
			{
				vox_rand = randomintrange(1,101);
				if( level.round_number <= 5 )
				{
					if( vox_rand <= 5 /*3*/ )
					{
						index = maps\_zombiemode_weapons::get_player_index(self);
						plr = "plr_" + index + "_";
						self thread create_and_play_dialog( plr, "vox_gen_giant", 0.25 );
					}
				}
				else if (level.round_number > 5 )
				{
					return;
				}
				wait(randomintrange(60,240));
			}
	}

}
check_for_change()
{
	while (1)
	{
		self waittill( "trigger", player );

		if ( player GetStance() == "prone" )
		{
			is_change = true;
			player maps\_zombiemode_score::add_to_player_score( 30, is_change );
			play_sound_at_pos( "purchase", player.origin );
			break;
		}
	}
}


check_for_change_quick()
{
	while (1)
	{
		self waittill( "trigger", player );

		if ( player GetStance() == "prone" && level.revive_gone == false )
		{
			is_change = true;
			player maps\_zombiemode_score::add_to_player_score( 30, is_change );
			play_sound_at_pos( "purchase", player.origin );
			break;
		}
	}
}

extra_events()
{
	self UseTriggerRequireLookAt();
	self SetCursorHint( "HINT_NOICON" ); 
	self waittill( "trigger" );

	targ = GetEnt( self.target, "targetname" );
	if ( IsDefined(targ) )
	{
		targ MoveZ( -10, 5 );
	}
}


//
//	Activate the flytrap!
flytrap()
{
	flag_init( "hide_and_seek" );
	level.flytrap_counter = 0;

	// Hide Easter Eggs...
	// Explosive Monkey
	level thread hide_and_seek_target( "ee_exp_monkey" );
	wait_network_frame();
	level thread hide_and_seek_target( "ee_bowie_bear" );
	wait_network_frame();
	level thread hide_and_seek_target( "ee_perk_bear" );
	wait_network_frame();
	
	trig_control_panel = GetEnt( "trig_ee_flytrap", "targetname" );

	// Wait for it to be hit by an upgraded weapon
	upgrade_hit = false;
	while ( !upgrade_hit )
	{
		trig_control_panel waittill( "damage", amount, inflictor, direction, point, type );

		weapon = inflictor getcurrentweapon();
		if ( maps\_zombiemode_weapons::is_weapon_upgraded( weapon ) )
		{
			upgrade_hit = true;
		}
	}

	trig_control_panel playsound( "flytrap_hit" );
	playsoundatposition( "flytrap_creeper", trig_control_panel.origin );
	thread play_sound_2d( "sam_fly_laugh" );
	//iprintlnbold( "Samantha Sez: Hahahahahaha" );

	// Float the objects
	level achievement_notify("DLC3_ZOMBIE_ANTI_GRAVITY");
	level ClientNotify( "ag1" );	// Anti Gravity ON
	wait(9.0);
	thread play_sound_2d( "sam_fly_act_0" );
	wait(6.0);
	
	thread play_sound_2d( "sam_fly_act_1" );
	wait(3.0);
	//iprintlnbold( "Samantha Sez: Let's play Hide and Seek!" );

	//	Now find them!
	flag_set( "hide_and_seek" );

	flag_wait( "ee_exp_monkey" );
	flag_wait( "ee_bowie_bear" );
	flag_wait( "ee_perk_bear" );

/*	level.teleporter_powerups_reward = true;
	wait( 4.0 );

	ss = getstruct( "teleporter_powerup", "targetname" );
	ss thread maps\_zombiemode_powerups::special_powerup_drop(ss.origin, true, true);
*/
	// Colin, play music here.
//	println( "Still Alive" );
}


//
//	Controls hide and seek object and trigger
hide_and_seek_target( target_name )
{
	flag_init( target_name );

	obj_array = GetEntArray( target_name, "targetname" );
	for ( i=0; i<obj_array.size; i++ )
	{
		obj_array[i] Hide();
	}

	trig = GetEnt( "trig_"+target_name, "targetname" );
	trig trigger_off();
	flag_wait( "hide_and_seek" );

	// Show yourself
	for ( i=0; i<obj_array.size; i++ )
	{
		obj_array[i] Show();
	}
	trig trigger_on();
	trig waittill( "trigger" );
	
	level.flytrap_counter = level.flytrap_counter +1;
	thread flytrap_samantha_vox();
	trig playsound( "object_hit" );

	for ( i=0; i<obj_array.size; i++ )
	{
		obj_array[i] Hide();
	}
	flag_set( target_name );
}

phono_egg_init( trigger_name, origin_name )
{
	if(!IsDefined (level.phono_counter))
	{
		level.phono_counter = 0;	
	}
	players = getplayers();
	phono_trig = getent ( trigger_name, "targetname");
	phono_origin = getent( origin_name, "targetname");
	
	if( ( !isdefined( phono_trig ) ) || ( !isdefined( phono_origin ) ) )
	{
		return;
	}
	
	phono_trig UseTriggerRequireLookAt();
	phono_trig SetCursorHint( "HINT_NOICON" ); 
	
	for(i=0;i<players.size;i++)
	{			
		phono_trig waittill( "trigger", players);
		level.phono_counter = level.phono_counter + 1;
		phono_origin play_phono_egg();
	}	
}

play_phono_egg()
{
	if(!IsDefined (level.phono_counter))
	{
		level.phono_counter = 0;	
	}
	
	if( level.phono_counter == 1 )
	{
		//iprintlnbold( "Phono Egg One Activated!" );
		self playsound( "phono_one" );
	}
	if( level.phono_counter == 2 )
	{
		//iprintlnbold( "Phono Egg Two Activated!" );
		self playsound( "phono_two" );
	}
	if( level.phono_counter == 3 )
	{
		//iprintlnbold( "Phono Egg Three Activated!" );
		self playsound( "phono_three" );
	}
}

radio_egg_init( trigger_name, origin_name )
{
	players = getplayers();
	radio_trig = getent( trigger_name, "targetname");
	radio_origin = getent( origin_name, "targetname");

	if( ( !isdefined( radio_trig ) ) || ( !isdefined( radio_origin ) ) )
	{
		return;
	}

	radio_trig UseTriggerRequireLookAt();
	radio_trig SetCursorHint( "HINT_NOICON" ); 
	radio_origin playloopsound( "radio_static" );

	for(i=0;i<players.size;i++)
	{			
		radio_trig waittill( "trigger", players);
		radio_origin stoploopsound( .1 );
		//iprintlnbold( "You activated " + trigger_name + ", playing off " + origin_name );
		radio_origin playsound( trigger_name );
	}	
}


//Hanging dead guy
hanging_dead_guy( name )
{
	//grab the hanging dead guy model
	dead_guy = getent( name, "targetname");

	if( !isdefined(dead_guy) )
		return;

	dead_guy physicslaunch ( dead_guy.origin, (randomintrange(-20,20),randomintrange(-20,20),randomintrange(-20,20)) );
}

setup_meteor_audio()
{
    wait(1);
    level.meteor_counter = 0;
	level thread meteor_egg( "meteor_one", (901.5, -557.5, 163) ); // High
	level thread meteor_egg( "meteor_two", (990, -900.5, 118) ); // Low
	level thread meteor_egg( "meteor_three", (-1346, -445, 251.5) ); // Type 100
}

meteor_egg( trigger_name, coords )
{
	meteor_trig = getent ( trigger_name, "targetname");

	meteor_trig UseTriggerRequireLookAt();
	meteor_trig SetCursorHint( "HINT_NOICON" ); 
		
	//meteor_trig PlayLoopSound( "meteor_loop" );

	meteor_trig waittill( "trigger", player );
	
	//meteor_trig stoploopsound(1);

	player playsound( "meteor_affirm" );
	

	level.meteor_counter = level.meteor_counter + 1;
	
	if( level.meteor_counter == 3 )
	{ 
	    level thread play_music_easter_egg();
	}
}

play_music_easter_egg()
{
	if (!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}
	
	level.eggs = 1;
	setmusicstate("eggs");
	
	//player thread create_and_play_dialog( plr, "vox_audio_secret", .25);
	
	wait(270);	
	setmusicstate("WAVE_1");
	level.eggs = 0;
}

flytrap_samantha_vox()
{
	if(!IsDefined (level.flytrap_counter))
	{
		level.flytrap_counter = 0;	
	}

	if( level.flytrap_counter == 1 )
	{
		//iprintlnbold( "Samantha Sez: Way to go!" );
		thread play_sound_2d( "sam_fly_first" );
	}
	if( level.flytrap_counter == 2 )
	{
		//iprintlnbold( "Samantha Sez: Two? WOW!" );
		thread play_sound_2d( "sam_fly_second" );
	}
	if( level.flytrap_counter == 3 )
	{
		//iprintlnbold( "Samantha Sez: And GAME OVER!" );		
		thread play_sound_2d( "sam_fly_last" );
		return;
	}
	wait(0.05);
}

play_giant_mythos_lines()
{
	round = 5; 
	
	wait(10);
	while(1)
	{
		vox_rand = randomintrange(1,101);
		
		if( level.round_number <= round )
		{
			if( vox_rand <= 5 /*3*/ )
			{
			players = get_players();
				if( players.size != 1 )
				{
					p = randomint(players.size);
					index = maps\_zombiemode_weapons::get_player_index(players[p]);
					plr = "plr_" + index + "_";

					if(players[p].sessionstate != "spectator" )
					{
						players[p] thread create_and_play_dialog( plr, "vox_gen_giant", .25 );
					}
				}
				//iprintlnbold( "Just played Gen Giant line off of player " + p );
			}
		}
		else if (level.round_number > round )
		{
			return;
		}
		wait(randomintrange(60,240));
	}
}


play_level_easteregg_vox( object )
{
	percent = 50;
	
	trig = getent( object, "targetname" );
	
	if(!isdefined( trig ) )
	{
		return;
	}
	
	trig UseTriggerRequireLookAt();
	trig SetCursorHint( "HINT_NOICON" ); 
	
	only_count_once = true;
	level.successful_corks = 0;

	while(1)
	{
		trig waittill( "trigger", who );
		
		vox_rand = randomintrange(1,101);
			
		if( vox_rand <= percent )
		{
			index = maps\_zombiemode_weapons::get_player_index(who);
			plr = "plr_" + index + "_";
			
			switch( object )
			{
				case "vox_corkboard_1":
					if(	(index != 3 || getplayers().size == 1) && isDefined(only_count_once) && only_count_once && level.can_do_quest == true)
					{
						only_count_once = undefined;
						level.successful_corks += 1;
					}
					//iprintlnbold( "Inside trigger " + object );
					who thread create_and_play_dialog( plr, "vox_resp_corkmap", .25 );
					break;
				case "vox_corkboard_2":
					if(	(index != 3 || getplayers().size == 1) && isDefined(only_count_once) && only_count_once && level.can_do_quest == true)
					{
						only_count_once = undefined;
						level.successful_corks += 1;
					}
					//iprintlnbold( "Inside trigger " + object );
					who thread create_and_play_dialog( plr, "vox_resp_corkmap", .25 );
					break;
				case "vox_corkboard_3":
					if(	(index != 3 || getplayers().size == 1) && isDefined(only_count_once) && only_count_once && level.can_do_quest == true)
					{
						only_count_once = undefined;
						level.successful_corks += 1;
					}
					//iprintlnbold( "Inside trigger " + object );
					who thread create_and_play_dialog( plr, "vox_resp_corkmap", .25 );
					break;
				case "vox_teddy":
					if( index != 2 )
					{
						//iprintlnbold( "Inside trigger " + object );
						//object setHintString( "Test" );
						who thread create_and_play_dialog( plr, "vox_resp_teddy", .25 );
					}
					break;
				case "vox_fieldop":
					if( (index != 1) && (index != 3) )
					{
						//iprintlnbold( "Inside trigger " + object );
						//outside barrier by fly trap, dempsey and takeo only
						who thread create_and_play_dialog( plr, "vox_resp_fieldop", .25 );
					}
					break;
				case "vox_maxis":
					if( index == 3 )
					{
						//iprintlnbold( "Inside trigger " + object );
						//Dog paw area, richtofen only
						who thread create_and_play_dialog( plr, "vox_resp_maxis", .25 );
					}
					break;
				case "vox_illumi_1":
					if( index == 3 )
					{
						//iprintlnbold( "Inside trigger " + object );
						//Hidden in spawn room, richtofen only
						who thread create_and_play_dialog( plr, "vox_resp_maxis", .25 );
					}
					break;
				case "vox_illumi_2":
					if( index == 3 )
					{
						//iprintlnbold( "Inside trigger " + object );
						//Hidden on ceiling of single green jar room, richtofen only
						who thread create_and_play_dialog( plr, "vox_resp_maxis", .25 );
					}
					break;
				default:
					return;
			}
		}
		else
		{
			index = maps\_zombiemode_weapons::get_player_index(who);
			plr = "plr_" + index + "_";
			
			who thread create_and_play_dialog( plr, "vox_gen_sigh", .25 );
		}
		wait(15);
	}
}


fix_bad_spots()
{
	//this bad spot is a  radius right at the spot where you can stand and all the zombies wont go for you
	bad_spot = spawn( "trigger_radius",( 793.5, 666, 53 ), 0, 125, 50 ); // radius, height
	good_spot = (759.5, 589.5, 54); // this is the closest i can get zombies to walk to towards that radius, if i tell them to go to the player or coords directly inside the radius they'll just fail

	while(1)
	{
		bad_spot waittill( "trigger", player );
		player.has_rope = 0;
		while(1)
		{
			if( !player IsTouching( bad_spot ) ) // if player leaves we stop checking zombies
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}

			zombies = GetAiSpeciesArray( "axis", "all" );
			for(i = 0; i < zombies.size; i++)
			{
				if(IsDefined(zombies[i].recalculating) && zombies[i].recalculating)
				{
					continue;
				}
				if(int(DistanceSquared(bad_spot.origin, zombies[i].origin)) < 800*800 && zombies[i] in_playable_area())
				{
					zombies[i].recalculating = true;
					zombies[i] thread recalculate_pathing(good_spot, bad_spot);
				}
			}
			wait(0.05);
		}
	}
}

recalculate_pathing(good_spot, bad_spot)
{
	self SetGoalPos(good_spot);
	while(1)
	{
		bad_spot waittill("trigger_radius", who);
/*		if( isplayer(who) ) // if a new player enters the trig we force a re-calculation
		{				// this is for cases where a player leaves then re-enters the trigger, which would result in zombies being stuck on this waittill and set to "true", and unable to recalculate a 2nd time
			break;
		}*/
		if( self != who ) // if the zombie going to this spot is not the one who triggers the radius (other zombies)
		{
			continue; // keep checking
		}
		else
		{
			break; // if our correct zombie trigs, then break and we have succeeded no more re-calculating
		}
	}
	self.recalculating = false;
}

// only concerns
// how does it work in co-op (when other players are far away?, when other players are near but not in, or when multiple in trig)
//what if a player enters and then leaves trig, zombies will get stuck on recalculating true status because of our waittill (its not based on time)
	//do it time based, say like 5 sec
	//only grab close zombs?

/*

// FACTORY EGG STEPS
// Industrial Extraordinaire -- Restore facility operations after starting the plan

// -- SHARED -- //
1. “Prescribed Adherence” - In order to proceed the host must have previously completed the sumpf quest. Richtofen must be in the lobby if in 4-player or solo.
2. “Electricians” - Turn on the power and link all three teleporters to the mainframe.
3. “Elevate Your Senses" - Activate the Fly Trap with a Pack-a-Punched weapon and complete Samantha’s game.
4. “Forensic Investigation” - At any point, interact with all three corkboards throughout the map. If in 4-player, this step must be done by anyone except Richtofen.

// -- SOLO OR FOUR-PLAYER COOP -- //
5. “Secret Preparations” - Richtofen must prepare his plan to override the teleporter functionality by studying with his journal at each of the three chalkboards by Teleporter A. 

// -- SHARED -- //
6. “Craft the Fuse” - Players must find and pick up a fuse hidden in one of three spots at Teleporter C. The player with the fuse must then cut off a piece of wire found in one of three spots near Teleporter B using the Bowie Knife.
7. “Modify the Mainframe” - With the parts and plan formulated, the player must head back to the mainframe panel and insert the fuse modification. An orange light will appear as the system prepares. Complete the round to move on.
8. “Sync Up” - The orange light will disappear, and a player can interact with the mainframe panel now to synchronize each teleporter with the new modification. Upon interacting, a timer will begin where all three teleporters have to be synced before time runs out, with the time depending on how many players are in the game. To sync the teleporters, shoot the red button inside each with a Pack-a-Punched weapon. If the timer runs out, the mainframe panel will turn red. If successful, the panel will turn orange. In both cases, you must finish the round before re-attempting or moving on.
9. “Unlimited Power” - The mainframe panel will now allow a player to interact with it and disable an “electrical limit,” allowing more power to flow through the teleporters as per Richtofen’s plan. With the limit disabled, players should now attempt to teleport. Unfortunately, upon attempting to use any of the 3 teleporters the system will fail and the teleporters will say that the link has been interrupted. At the mainframe, the panel will have a red light and say “safety failsafe engaged” due to the players forcing in too much power. Finish the round before moving on.
10. “Please Undo?” - players will see that they can now interact with the panel to “recycle the power” in the hopes of establishing the teleporter links. However, they will learn that “additional maintenance” is required as each teleporter is fried.
11. “Unroutinely Maintenance” - Players must now go through each teleporter area, in any order, to make the necessary repairs. Each teleporter area will have sparks on three broken parts, with red warning lights indicating a problem. The sparks and lights will all disappear as each repair is made and the teleporter hintstring will update.
12. “We Can Fix It” - Locate and pick up the toolbox located near Teleporter A in one of three random locations before being able to make any repairs. This player will now have the “tools.”
13. “Teleporter A” - The player with the tool must interact with the three sparking areas. Without the tool, the player will be damaged. This teleporter is straightforward and demonstrates the general concept of fixing a teleporter--as we are right by where we picked up the tools. 
14. “Teleporter B” - Players must align the lever at the correct angle matching the seconds-hand on the clock while holding a beaker of red chemicals near the boiler, which can be picked up on the nearby shelves. Upon doing so, smoke will rise up and the player with the tool must interact with the three sparks. Without the tool, the player will be damaged. Eventually, the lever will reset back to its starting position. If at any point sparks are repaired without the lever at the correct angle, the step is failed and will have to be restarted.
15. “Teleporter C” - The player with the tool must interact with the three sparking areas. Without the tool, the player will be damaged. However, there is a lever connected to a pipe that must be aligned correctly which can be found in the tunnel by the grenade wall chalk. The lever must be set in a position corresponding to the position of each spark in order for the spark to be repaired (left, middle, right). In co-op, the lever will reset if a player is not standing at the lever “holding” it in place.
16. “Gen Resurrection” - The telemap will still show a red light at the mainframe even after fixing all three teleporters, indicating the location of the last problem. To fix the insufficient power, players will have to shock the spawn room generator back on by zapping 10 close zombies with one tesla gun shot.
17. “Manual Overload” - After restoring facility operations back to normal, the only way forward is to skip the official procedures. All must be in a teleporter together, and a player must fire the upgraded Wunderwaffe DG-while initiating the teleport. Upon coming out of the mainframe, a “nuke” effect will shock surrounding zombies and all players will receive a reward. This is the moment our characters would be leaving Der Riese…only time will tell what new discoveries await them.

// - Lights at the mainframe panel indicate the round must be completed before moving on. Red means something is wrong, orange means all is fine.

*/

item_hud_create(item)
{
	shader = item;
	self.item_hud = create_simple_hud( self );
	self.item_hud.foreground = true; 
	self.item_hud.sort = 2; 
	self.item_hud.hidewheninmenu = false; 
	self.item_hud.alignX = "center"; 
	self.item_hud.alignY = "bottom";
	self.item_hud.horzAlign = "right"; 
	self.item_hud.vertAlign = "bottom";
	self.item_hud.x = -230;
	self.item_hud.y = -1; 
	self.item_hud.alpha = 1;
	self.item_hud SetShader( shader, 32, 32 );

	self thread item_hud_remove();
}

item_hud_remove()
{
	level waittill_any( "end_game", "fuse_wire_placed", "tools_used_up" );
	
	self.item_hud destroy_hud();
	self.item_hud = undefined;

}

sumpf_check()
{
	wait(0.1);
	
	level.can_do_quest = false;

	if(GetDvarInt("sumpf_quest") != 1 ) // moved giving journal over to loadout gsc because it kept getting wiped/not set on co-op due to latency
	{
		return; // first we make sure our host has done the quest before even moving on
	}

	players = getplayers();
	index = maps\_zombiemode_weapons::get_player_index( players[0] );

	if( players.size > 1 || (players.size == 1 && index == 3) ) // if so, then we check to proceed ONLY if we are in co-op or if we are Richtofen in solo
	{
		level.can_do_quest = true;
		level thread phase_one_quest();
	}
}

phase_one_quest()
{

	while(1) // first we just make sure to wait until we have explored the map enough
	{
		if(level.flytrap_counter >= 3 && level.successful_corks >= 3 )
		{
			break;
		}
		wait(0.05);
	}

	level.chalks_studied = 0;

	players = getplayers();
	if(players.size == 1 || players.size == 4 ) // if 2 or 3 we skip this because we dont have richtofen
	{
		players[(players.size - 1)] giveweapon("zombie_item_journal"); 

		intel1 = spawn( "trigger_radius",( 628.125, -450, 64.125), 0, 12, 25 );	
		level thread teleporter_a_eddy(intel1);

		wait_network_frame();
		intel2 = spawn( "trigger_radius",( 852.875, -508.751, 64.125), 0, 12, 25 );	
		level thread teleporter_a_eddy(intel2);

		wait_network_frame();
		intel3 = spawn( "trigger_radius",( 867.177, -871.282, 64.125), 0, 12, 25 );	
		level thread teleporter_a_eddy(intel3);

		level waittill("studying_completed");	
	}


	level.fuse_holder = 0;
	level.partspot = randomintrange(0,3); // determines where pick-up items will be
	big = false; //by default we just use normal sized radius unless exception

	fuse = undefined;
	wire = undefined;


	switch(level.partspot) // Fuse locations, three possible spots. Might need to change fx to play on tag so we can delete it
	{
	case 0: // Left shelf
		fuse = spawn( "script_model",( 584.56, -2880, 110.7 ) );
		fuse setmodel("panel_fuse");
		fuse.angles = ( 0, -45, 0 );
		playfxontag(level._effect["electric_fuse_spark"], fuse, "tag_origin");
		fuse thread random_spark_sounds();
		break;
	case 1: // Right shelf
		fuse = spawn( "script_model",( -4.9, -2922.04, 112.1 ) );
		fuse setmodel("panel_fuse");
		fuse.angles = ( 0, 45, 0 );
		playfxontag(level._effect["electric_fuse_spark"], fuse, "tag_origin");
		fuse thread random_spark_sounds();
		break;
	case 2: // Door shelf
		fuse = spawn( "script_model",( -4, -2456.95, 139.91 ) );
		fuse setmodel("panel_fuse");
		fuse.angles = ( 0, -30, 0 );
		playfxontag(level._effect["electric_fuse_spark"], fuse, "tag_origin");
		fuse thread random_spark_sounds();
		break;
	}

	level thread part_pickup(fuse, "fuse", big); 

	wait_network_frame();

	switch(level.partspot) // Wire locations, three possible spots
	{
	case 0: // by furnace
		wire = spawn( "script_model",( -480.7, -1045.6, 67.125 ) );
		wire setmodel("static_global_electric_wire");
		wire.angles = ( 0, -130, 0 );
		break;
	case 1: // by trap
		wire = spawn( "script_model",( -560, -383, 67.125 ) );
		wire setmodel("static_global_electric_wire");
		wire.angles = ( 0, 130, 0 );
		break;
	case 2: // in middle chunk
		wire = spawn( "script_model",( -737, -721.1, 67.25 ) );
		wire setmodel("static_global_electric_wire");
		wire.angles = ( 0, -170, 0 );
		big = true; // needed bigger radius
		break;
	}

	level thread part_pickup(wire, "wire", big); 

}

teleporter_a_eddy(intel) // don't need to check for index, only richtofen can have journal
{
	intel SetCursorHint("HINT_ACTIVATE");

    while ( true )
    {
	    intel waittill( "trigger", DiaryHolder ); // wait for player to enter trigger

	    // Gather player info for weapons & VOX
		index = maps\_zombiemode_weapons::get_player_index( DiaryHolder );
		plr = "plr_" + index + "_";	
		current_weapon = DiaryHolder GetCurrentWeapon();

		if( /*!diaryholder UseButtonPressed() ||*/ !DiaryHolder IsTouching(intel) ) // From here on, player must be holding F and touching trig, otherwise we just go back to the start
		{
			continue;
		}

	    if ( isSubStr(current_weapon, "zombie_item_journal" ) && is_player_valid(DiaryHolder) && !DiaryHolder isThrowingGrenade() )
	    {
	        wait(0.05); // test without ? 
	
	        //Wait for a certain amount of time before success
	        intel thread WaitForStudyingCompletion( DiaryHolder );

	        //Wait for if we cancel writing by either leaving trig or letting go of F
	        intel WaitForStudyingCancellation( DiaryHolder, intel );
	    }
	    else // if Richtofen attempts to write without proper requirements met (not holding journal)
	    {
			DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_gen_sigh", 0.05 );
			wait(10); // delay if we try to do it without journal
			continue;
	    }
    }
}

WaitForStudyingCancellation( DiaryHolder, intel )
{
    // Wait for if player stops holding the use button
    self endon("chalk_done");

    while(  DiaryHolder isTouching(intel) && (!DiaryHolder maps\_laststand::player_is_in_laststand()) )
    {
	    if ( !isSubStr( DiaryHolder GetCurrentWeapon(), "zombie_item_journal" ) ) // if we at any point start holding another weapon (betty), we cancel
        {
        	break;
        }
        wait(0.05);
    }

	wait(3);
}

WaitForStudyingCompletion( DiaryHolder )
{
	timer = 5;

    while( DiaryHolder IsTouching(self) && (!DiaryHolder maps\_laststand::player_is_in_laststand()) && timer > 0 ) // we stay here while succesfully taking notes until 30 sec has passed
    {
	    if ( !isSubStr( (DiaryHolder GetCurrentWeapon()), "zombie_item_journal" ) ) // if at any point we start holding another weapon (betty), we cancel
        {
        	break;
        }

        timer -= 0.05;
        wait(0.05);
    }

    if(timer <= 0)
    {
        self delete();

        self notify("chalk_done");

        level.chalks_studied++;

		if(level.chalks_studied == 3)
		{
			DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_resp_illumi", 0.1 );
			level notify("studying_completed");
		}
		else
		{
			DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_resp_corkmap", 0.1 );
		}
    }
}

part_pickup(part, type, big)
{
	wait_network_frame();

	radius = 30;
	
	if( big == true )
	{
		radius = 45;
	}
	
	part_trigger = spawn( "trigger_radius",( part.origin ), 0, radius, 20 );

	while(1)
	{
		part_trigger waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( part_trigger ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if( type == "wire" && !player meleeButtonPressed() && isDefined(player.has_fuse) && player.has_fuse == true ) // For WIRE only, and for players WITH FUSE, we have to knife
			{
				break; 
			}
			if( type == "wire" && !player UseButtonPressed() && !isDefined(player.has_fuse) ) // For WIRE only, and for PLAYERS WITHOUT FUSE
			{
				break; 
			}
			if( type != "wire" && !player UseButtonPressed() )
			{
				break; 
			}

			index = maps\_zombiemode_weapons::get_player_index(player);
			plr = "plr_" + index + "_";

			if( type == "fuse" ) // For fuse part, anyone can grab
			{
				player playlocalsound("gren_pickup_plr"); // Generic pickup sound

				if(!player hasperk("specialty_armorvest") || player.health - 100 < 1)
				{
					radiusdamage(player.origin,10,5,5);
				}
				else
				{
					player dodamage(5, player.origin);
				}

				player.has_fuse = true;
				player item_hud_create("hud_fuse");
				player playlocalsound("light_start");   // Special pickup sound

				player set_fuse_holder_name();

				part_trigger delete();
				part delete();
				break;
			}

			if( type == "tools" )
			{
				player playlocalsound("gren_pickup_plr"); // Generic pickup sound
				player.has_tools = true;
				player item_hud_create("hud_tools"); // need hud
				part_trigger delete();
				part delete();
				break;
			}

			if(	type == "wire" && IsDefined(player.has_fuse) && player.has_fuse && player hasperk( "specialty_altmelee" ) ) // For wire part, only fuse player can pick up
			{
				player playlocalsound("sack_drop"); 

				player.item_hud destroy_hud(); // We fix up hud and fix up current player variable to adjust for new part picked up
				player.item_hud = undefined;
				player.has_fuse = undefined;
				player.has_fuse_wire = true;
				player item_hud_create("hud_fuse_wire");

				player thread create_and_play_dialog( plr, "vox_gen_ask_yes", 0.1 );
				level thread phase_two_quest();
				part_trigger delete();
				part delete();
				break;
			}
			else if(type == "wire" && isDefined(level.fuse_holder) && level.fuse_holder != 0 && player.has_fuse != true ) // If no one has found the fuse, we don't do this yet, but if a player has fuse we shout for them to come over
			{
				player thread create_and_play_dialog( plr, "vox_name_"+level.fuse_holder, 0.1 ); 
				wait(3);
				break;
			}
			else if( type == "wire" && IsDefined(player.has_fuse) && player.has_fuse && !player hasperk( "specialty_altmelee" ) ) // no bowie yet
			{
				player thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
				break;
			}

			if( type == "juice" )
			{
				player playlocalsound("gren_pickup_plr"); // Generic pickup sound

				player giveweapon("zombie_item_beaker"); 
				player setactionslot(1,"weapon","zombie_item_beaker"); 
				player.has_special_weap = "zombie_item_beaker";
				if(self hasweapon("zombie_item_journal") )
				{
					if(self GetCurrentWeapon() == "zombie_item_journal" )
					{
						primaryWeapons = self GetWeaponsListPrimaries();
						if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
						{
							self SwitchToWeapon( primaryWeapons[0] );
						}	
					}
					self takeweapon("zombie_item_journal"); 
				}
				player thread juicer_timer();

				part_trigger delete();
				part delete();
				break;
			}
			break;
		}
		if(!isDefined(part_trigger) )
		{
			break;
		}
	}
}

set_fuse_holder_name()
{
	index = maps\_zombiemode_weapons::get_player_index(self);
	switch(index)
	{
	case 0:
		level.fuse_holder = "dempsey";
		break;
	case 1:
		level.fuse_holder = "nikolai";
		break;
	case 2: 
		level.fuse_holder = "takeo";
		break;
	case 3: 
		level.fuse_holder = "richtofen";
		break;
	}
}

random_spark_sounds()
{
	while(1)
	{
		if(!IsDefined(self) )
		{
			break;
		}
		playsoundatposition("fuse_sparks", self.origin);
		wait(randomfloatrange(0.5, 2));
	}
}

phase_two_quest() // Mainframe control panel
{
	level thread mainframe_panel_a();

	level waittill("phase_two_complete");

	level thread phase_three_quest();

}

mainframe_panel_a() // May need a check in co-op for hintstring showing properly
{
	wait_network_frame();

	panel_trigger = spawn( "trigger_radius",( -150.875, 300, 93.125 ), 0, 10, 20 );
	panel_origin = (-186, 301, 140);

	while(1)
	{
		panel_trigger waittill( "trigger", player );
		index = maps\_zombiemode_weapons::get_player_index(player);
		plr = "plr_" + index + "_";
		while(1)
		{
			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( panel_origin ) )
			{
				panel_trigger SetCursorHint("HINT_NOICON");
				break;
			}
			if( !player IsTouching( panel_trigger ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if(	IsDefined(player.has_fuse_wire) && player.has_fuse ) // For wire part, only fuse player can pick up
			{
				panel_trigger SetCursorHint("HINT_ACTIVATE");
				panel_trigger SetVisibleToPlayer(player);	
			}
			else if( !IsDefined(player.has_fuse_wire) )
			{
				panel_trigger SetCursorHint("HINT_NOICON");
				player thread create_and_play_dialog( plr, "vox_name_"+level.fuse_holder, 0.1 ); 
				wait(3);
				break;
			}
			if( !player UseButtonPressed() )
			{
				break; 
			}

			if(	IsDefined(player.has_fuse_wire) && player.has_fuse ) // For wire part, only fuse player can pick up
			{
				player playlocalsound("switch_progress");
				index = maps\_zombiemode_weapons::get_player_index(player);
				plr = "plr_" + index + "_";
				player thread create_and_play_dialog( plr, "vox_gen_stayback", 0.25 );

				player.item_hud destroy_hud(); // Clean up hud
				player.item_hud = undefined;
				player.has_fuse_wire = undefined;

				panel_trigger delete();
				break;
			}
			else
			{
				break;
			}
		}
		if(!isDefined(panel_trigger) )
		{
			break;
		}
	}

	// Scripted event, fuse inserted into mainframe panel
	level.panel_s_o = spawn( "script_origin", ( -186, 301, 154.5) );
	
	fuse = spawn( "script_model", ( -186, 301, 154.5) );
	fuse setmodel("panel_fuse");
	fuse.angles = ( 0, 90, 49 );

	playsoundatposition("switch_progress", fuse.origin);
	level.panel_s_o PlayLoopSound("tele_spark_loop");
	playfx(level._effect["electric_fuse_spark_placed"], ( -181, 301, 150.5));

	time = 1.75;
	new_pos = ( -186, 301, 154.5) + (8,0,-10);
	fuse NotSolid(); // test without
	fuse MoveTo( new_pos, time, 0.1, 0.05 );

	wait(1.1);
	playfx(level._effect["electric_fuse_spark_placed"], ( -178, 301, 147.5));

	playfxontag(level._effect["electric_fuse_spark_smoking"], fuse, "tag_origin");

	wait(0.1);
	level.panel_s_o stoploopsound();
	playsoundatposition("tele_spark_hit", fuse.origin);
	fx_light = spawn("script_model", (-177, 295.1, 144));
	fx_light setModel("tag_origin");
	playFxOnTag(level._effect["zapper_light_waiting"], fx_light, "tag_origin");

	wait(0.55);
	//level.panel_s_o delete();
	fuse delete();

	index = maps\_zombiemode_weapons::get_player_index(player);
	plr = "plr_" + index + "_";
	player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.1 );
	
	level waittill ( "between_round_over" ); // wait till we get to the next round over
	fx_light delete();

	level thread damage_trig_checker();
	

}

damage_trig_checker()
{
	while(1)
	{
		level.syncs_completed = 0; // always start at 0 progress, whether for first time or for if we fail

		level thread mainframe_panel_b(); // threads mainframe trigger. this gets disabled during countdown, and then always gets deleted after a fail/success 

		level waittill("begin_sync"); // we wait for a user to notify from the trigger
	
		level.panel_s_o playloopsound( "ticktock_loop" ); // plays loop sound on script origin @ mainframe panel
		level.sync_timer_active = "counting"; // set up timer
		level thread sync_timer(); // set up timer

		level.a = (1264, 1206, 279); // these following lines all set up dmg trigs
		level thread damage_trig_teleporter(level.a, (0,0,0) );
		
		level.b = (-1715, -1107.75, 310.5);
		level thread damage_trig_teleporter(level.b, (0,90,0) );
		
		level.c = (296.75, -3126, 266);
		level thread damage_trig_teleporter(level.c, (0, -180, 0) );

		while(level.sync_timer_active == "counting") // pause here will counting down
		{
			//iprintln("counting");
			wait( .05 );
		}		
		level.panel_s_o stoploopsound(.05); // we always stop loop sound, either if we fail or suceed

		level.panel_trigger_sync delete(); // we delete the trigger because we're going to thread again and spawn another if we loop
		
		level notify("finish_sync"); // ends all loops because we will be threading them again, need to be careful tho because we want to make sure the dmg trigs get deleted if we failed as we will spawn them again

		if(level.sync_timer_active == "success")
		{
			playsoundatposition( "pa_buzz",  (-186, 301, 140) ); // plays good sound on panel
			break;
		}
		else if(level.sync_timer_active == "off") // ran out of time
		{
			playsoundatposition( "packa_deny",  (-186, 301, 140) ); // plays bad sound on panel

			fx_light = spawn("script_model", (-177, 295.1, 144));
			fx_light setModel("tag_origin");
			playFxOnTag(level._effect["zapper_light_notready"], fx_light, "tag_origin");

			level waittill ( "between_round_over" ); // if we fail, we wait till we get to the next round over
			
			fx_light delete();

		}
	}
	level.panel_s_o delete();

	fx_light = spawn("script_model", (-177, 295.1, 144));
	fx_light setModel("tag_origin");
	playFxOnTag(level._effect["zapper_light_waiting"], fx_light, "tag_origin");

	level waittill ( "between_round_over" ); // if we fail, we wait till we get to the next round over
	
	fx_light delete();

	level thread mainframe_panel_c();
}

sync_timer() // balanced for co-op and solo
{
	players = getplayers();
	time = 60;
	time /= players.size;
	wait(time);
	level.sync_timer_active = "off";
}

damage_trig_teleporter(location, angles)
{
	level endon("finish_sync");

	wait_network_frame();

	teleporter_dmg_trig = spawn("script_model", location ); 
	teleporter_dmg_trig setmodel("zombie_teleporter_button");
	teleporter_dmg_trig.angles = angles;
	teleporter_dmg_trig hide();
	teleporter_dmg_trig setcanDamage(true);
	teleporter_dmg_trig.maxhealth = 100000;
	teleporter_dmg_trig.health = self.maxhealth;
	damaged = false;
	while( damaged == false && level.sync_timer_active == "counting") // if it gets changed to off then we auto stop checking for damage so that we can delete the trig to clean up
	{
		teleporter_dmg_trig waittill( "damage", amount, inflictor, direction, point, type );
		weapon = inflictor getcurrentweapon();
		if ( maps\_zombiemode_weapons::is_weapon_upgraded( weapon ) ) // if we have an upgraded weapon
		{
			if(damaged == false && teleporter_dmg_trig.health < 100000 && Distance(self.origin, point) < 100 )
			{
				damaged = true;
				level.syncs_completed += 1;
				playsoundatposition( "linkall_2d", location ); 	// NEED BETTER SOUND TO TELL PLAYER THEY DID IT
				break;	
			}
		}
		else
		{
			self.maxhealth = 100000;
			self.health = self.maxhealth;
			continue;
		}
	}
	
	teleporter_dmg_trig delete();
	
	if(level.syncs_completed >= 3)
	{
		level.sync_timer_active = "success";
		players = getplayers();

		if(players.size != 4 ) // if we have 4 players they will all be spread out doing step at the same time so no need for extra reminder of success
		{
			playsoundatposition( "pa_buzz",  location ); // plays good sound on panel
		}

		rando = players[randomint(players.size)];
		index = maps\_zombiemode_weapons::get_player_index( rando );
		plr = "plr_" + index + "_";
		rando create_and_play_dialog( plr, "vox_gen_compliment", 0.1 );
	}
}

mainframe_panel_b()
{
	level endon("finish_sync");

	wait_network_frame();

	countdown_on = false;

	level.panel_trigger_sync = spawn( "trigger_radius",( -150.875, 300, 93.125 ), 0, 10, 20 );
	
	panel_origin = (-186, 301, 140);
	
	level.panel_trigger_sync setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_OVERRIDE");
	level.panel_trigger_sync SetCursorHint("HINT_NOICON");

	while(1)
	{
		level.panel_trigger_sync waittill( "trigger", player );

		while(1)
		{
			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( panel_origin ) ) // if we look away
			{
				level.panel_trigger_sync setHintString("");
				break;
			}
			if( !player IsTouching( level.panel_trigger_sync ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if(countdown_on == true)
			{
				level.panel_trigger_sync setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_SYNC");
				level.panel_trigger_sync SetCursorHint("HINT_NOICON");
			}
			else
			{
				level.panel_trigger_sync setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_OVERRIDE");
				level.panel_trigger_sync SetCursorHint("HINT_NOICON");
			}
			if( !player UseButtonPressed() )
			{
				break; 
			}
			if(	countdown_on == false )
			{
				countdown_on = true;

				level notify("begin_sync");

				player playlocalsound("switch_progress"); // this will be spot for generic pressing button sound, might want to change?

				index = maps\_zombiemode_weapons::get_player_index(player);
				plr = "plr_" + index + "_";
				player thread create_and_play_dialog( plr, "vox_gen_move", 0.25 );
				break;
			}
			else
			{
				break;
			}
		}
		if(!isDefined(level.panel_trigger_sync) )
		{
			break;
		}
	}

}

mainframe_panel_c()
{
	wait_network_frame();

	level.current_limit = true;

	level.panel_trigger_sync = spawn( "trigger_radius",( -150.875, 300, 93.125 ), 0, 10, 20 );
	
	panel_origin = (-186, 301, 140);
	
	level.panel_trigger_sync setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_LIMIT");
	level.panel_trigger_sync SetCursorHint("HINT_NOICON");

	while(1)
	{
		level.panel_trigger_sync waittill( "trigger", player );

		while(1)
		{
			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( panel_origin ) ) // if we look away
			{
				level.panel_trigger_sync setHintString("");
				break;
			}
			if( !player IsTouching( level.panel_trigger_sync ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if(level.current_limit == false)
			{
				level.panel_trigger_sync setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_LIMIT_DISABLED");
				level.panel_trigger_sync SetCursorHint("HINT_NOICON");
			}
			else
			{
				level.panel_trigger_sync setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_LIMIT");
				level.panel_trigger_sync SetCursorHint("HINT_NOICON");
			}
			if( !player UseButtonPressed() )
			{
				break; 
			}
			if(	level.current_limit == true ) // if the limit is on (default)
			{
				level.current_limit = false;

				player playlocalsound("switch_progress"); // this will be spot for generic pressing button sound, might want to change?
			
				playsoundatposition( "pa_buzz", panel_origin ); // plays good sound on panel
				
				index = maps\_zombiemode_weapons::get_player_index(player);
				
				if(index == 3)
				{
					player thread create_and_play_dialog( "plr_3_", "vox_gen_laugh", 0.05 );
				}
				else
				{
					plr = "plr_" + index + "_";
					player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.05 );

				}
				break;
			}
			else
			{
				break;
			}
		}
		if(!isDefined(level.panel_trigger_sync) )
		{
			break;
		}
	}

}

mainframe_panel_d()
{
	wait_network_frame();

	level.panel_trigger_failsafe = spawn( "trigger_radius",( -150.875, 300, 93.125 ), 0, 10, 20 );
	
	panel_origin = (-186, 301, 140);
	
	level.panel_trigger_failsafe setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_FAILSAFE");
	level.panel_trigger_failsafe SetCursorHint("HINT_NOICON");

	while(1)
	{
		level.panel_trigger_failsafe waittill( "trigger", player );

		while(1)
		{
			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( panel_origin ) ) // if we look away
			{
				level.panel_trigger_failsafe setHintString("");
				break;
			}
			if( !player IsTouching( level.panel_trigger_failsafe ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			level.panel_trigger_failsafe setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_FAILSAFE");
			level.panel_trigger_failsafe SetCursorHint("HINT_NOICON");
			if( !player UseButtonPressed() )
			{
				break; 
			}
			player thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog(); // MAKE SURE THIS WORKS
			break;
		}
		if(!isDefined(level.panel_trigger_failsafe) )
		{
			break;
		}
	}

}

mainframe_panel_e()
{
	wait_network_frame();

	has_pressed = false;

	level.panel_trigger_recycle = spawn( "trigger_radius",( -150.875, 300, 93.125 ), 0, 10, 20 );
	
	panel_origin = (-186, 301, 140);
	
	level.panel_trigger_recycle setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_RECYCLE");
	level.panel_trigger_recycle SetCursorHint("HINT_NOICON");

	while(1)
	{
		level.panel_trigger_recycle waittill( "trigger", player );

		while(1)
		{
			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( panel_origin ) ) // if we look away
			{
				level.panel_trigger_recycle setHintString("");
				break;
			}
			if( !player IsTouching( level.panel_trigger_recycle ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if(has_pressed == false)
			{
				level.panel_trigger_recycle setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_RECYCLE");
				level.panel_trigger_recycle SetCursorHint("HINT_NOICON");		
			}
			else
			{
				level.panel_trigger_recycle setHintString(&"REMASTERED_ZOMBIE_MAINFRAME_PANEL_MAINT");
				level.panel_trigger_recycle SetCursorHint("HINT_NOICON");
			}
			if( !player UseButtonPressed() )
			{
				break; 
			}
			if(	has_pressed == false ) 
			{
				index = maps\_zombiemode_weapons::get_player_index(player);
				plr = "plr_" + index + "_";
				player thread create_and_play_dialog( plr, "vox_gen_ask_yes", 0.05 );

				has_pressed = true;

				level notify("phase_two_complete");

				player playlocalsound("switch_progress"); // this will be spot for generic pressing button sound, might want to change?
			
				playsoundatposition( "pa_buzz", panel_origin ); // plays good sound on panel
				
				level.panel_trigger_recycle setHintString("");

				wait(2);
				player thread create_and_play_dialog( plr, "vox_gen_damn", 0.1 );	
				break;
			}
			else
			{
				break;
			}
		}
		if(!isDefined(level.panel_trigger_recycle) )
		{
			break;
		}
	}

}

phase_three_quest()
{
	level.repairs_made = 0;
	level.teleporter_a_sparks = 0;
	level.teleporter_b_sparks = 0;
	level.teleporter_c_sparks = 0;

	level thread teleporter_a_fix(); // This one is easy, it's where we get toolbox and learn how to fix a TP
	level thread teleporter_b_fix();
	level thread teleporter_c_fix();

	level waittill("all_teleporters_fixed"); 
	level.panel_trigger_recycle delete();
	level thread generator_checker(); // start checking for generator to be powered
	level notify("tools_used_up"); // cleans up hud, we no longer need tools
	
	wait(5); // wait a few seconds and clean up the models, shows player we are done fixing individual teles
	level.lever delete(); 
	level.lever_pipe delete();
}

generator_checker()
{
	gen_trig = spawn("trigger_radius", (-411, 342.8, -2.9), 0, 125, 250); //radius, height
	gen_zombies = 0;

	while(1)
	{
		level waittill("tesla_damage", player, zombie);  // we ONLY notify when 1) a zombie is shocked and 2) 10 zombies total are zapped
		//iprintlnbold("10 zombies shocked, checking if first zombie touched radius");
		if(zombie isTouching(gen_trig) )// then we check if the first zombie was touching our radius
		{
			break;
		}
		else
		{
			continue;
		}
	}

	gen_trig delete();

	wait(0.15);

	level.teleporters_are_broken = undefined; // this should let us teleport again
	level.current_limit = undefined;
	for ( i = 0; i < level.teleporter_pad_trig.size; i++ )
	{
		level.teleporter_pad_trig[i] sethintstring( &"ZOMBIE_TELEPORT_TO_CORE" );
	}

	ClientNotify( "pap1_resume" ); // turns back on sounds
	exploder( 101 ); // turns back on spawn gen

	level thread teleport_out_checker();

	wait(2);
	index = maps\_zombiemode_weapons::get_player_index(player);
	plr = "plr_" + index + "_";
	player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.1 );

	// thread last step, tele waffe checker
	// additional sounds? smoke/explosion to help show we shocked on generator
}

teleport_out_checker()
{
	level.teleporting_out_ready = true; // so that teleporter gsc knows it can start sending the notify and checking for players
	level.all_players_teleported = false; // set up, only gets changed to true when all players teleport in teleporter gsc
	timer = level.teleport_delay + 0.5;
	waffe_shot = false;
	waffle_shooter = undefined;

	while(1)
	{
		level waittill("teleporting_out"); //  everytime we teleport, we check to see if a player shoots waffe correctly
		players = getplayers();

		while(timer > 0)
		{
			for ( i = 0; i < players.size; i++ )
			{
				if(players[i] isFiring() && !players[i] isMeleeing() && players[i] getCurrentWeapon() == "tesla_gun_upgraded" )
				{
					waffe_shot = true;
					waffle_shooter = players[i];
				}
			}
			timer -= 0.05;
			wait(0.05);
		}

		if(waffe_shot == true && level.all_players_teleported == true )
		{
			break;
		}
		else
		{
			waffe_shot = false; // reset
			level.all_players_teleported = false; // reset
			timer = level.teleport_delay + 0.5; // reset
		}

	}
	level.all_players_teleported = undefined;
	level.teleporting_out_ready = undefined;

	players = getplayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] play_sound_2d("bowl_sting_ending");
	}

	level thread end_flash();

	wait(9);

	index = maps\_zombiemode_weapons::get_player_index(waffle_shooter);
	plr = "plr_" + index + "_";
	waffle_shooter thread create_and_play_dialog( plr, "vox_achievment", 0.05 );
	for(i = 0; i < players.size; i++)
	{	
		players[i] thread give_all_perks_forever();
		if(players.size >= 4) 
		{
			players[i] setclientdvar("factory_quest", 1 ); // for menu achievement
			players[i] maps\_zombiemode_achievement::giveachievement_wrapper_new( "DLC3_ZOMBIE_EE_FACTORY" ); 
		}	
	}

	if(players.size > 1) // some extra rando vox if we have more players
	{
		wait(4);
		rando = players[randomint(players.size)];
		index = maps\_zombiemode_weapons::get_player_index( rando );
		plr = "plr_" + index + "_";
		rando create_and_play_dialog( plr, "vox_gen_compliment", 0.1 );
	}

	wait(6);
	for (i = 0; i < players.size; i++)
	{
		players[i] play_sound_2d("zombie_theater");
	}
}

end_flash()
{
	wait(1.5);
	players = getplayers();	
	for(i=0; i<players.size; i ++)
	{
		players[i] play_sound_2d("nuke_flash");
	}
	level thread kill_shock_trigger();
	
	fadetowhite = newhudelem();

	fadetowhite.x = 0; 
	fadetowhite.y = 0; 
	fadetowhite.alpha = 0; 

	fadetowhite.horzAlign = "fullscreen"; 
	fadetowhite.vertAlign = "fullscreen"; 
	fadetowhite.foreground = true; 
	fadetowhite SetShader( "white", 640, 480 ); 

	// Fade into white
	fadetowhite FadeOverTime( 0.2 ); 
	fadetowhite.alpha = 0.8; 

	wait 0.5;
	fadetowhite FadeOverTime( 1.0 ); 
	fadetowhite.alpha = 0; 

	wait 1.1;
	fadetowhite destroy();
}

kill_shock_trigger()
{
	mainframe = getent( "trigger_teleport_core", "targetname" );

	zombies = getaispeciesarray("axis");
	zombies = get_array_of_closest( mainframe.origin, zombies );
	for (i = 0; i < zombies.size; i++)
	{
		wait(randomfloatrange(0.05, 0.1));
		if( !IsDefined( zombies[i] ) )
		{
			continue;
		}

		if( is_magic_bullet_shield_enabled( zombies[i] ) )
		{
			continue;
		}

		if( i < 13 && !( zombies[i] enemy_is_dog() ) )
		{
			zombies[i] maps\_zombiemode_tesla::tesla_play_death_fx(1);
		}

		if( !( zombies[i] enemy_is_dog() ) )
		{
			zombies[i] maps\_zombiemode_spawner::zombie_head_gib();
		}

		zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
		playsoundatposition( "elec_vocals_tesla", zombies[i].origin );
	}

}

teleporter_a_fix()
{
	// SPAWN TOOLBOX //
	tools = undefined;
	big = false;

	switch(level.partspot) // Tool locations, three possible spots
	{
	case 0: // by cages
		tools = spawn( "script_model",( 1579.4, 365, 78 ) );
		tools setmodel("static_seelow_toolbox");
		tools.angles = ( -5, -30, 0 );
		big = true;
		break;
	case 1: // by barrels
		tools = spawn( "script_model",( 1027.2, 329, 64.125 ) );
		tools setmodel("static_seelow_toolbox");
		tools.angles = ( 0, 170, 0 );
		break;
	case 2: // under shelf
		tools = spawn( "script_model",( 1028, 6, 69 ) );
		tools setmodel("static_seelow_toolbox");
		tools.angles = ( -10, 20, 0 );
		break;
	}
	level thread part_pickup(tools, "tools", big); 
	// END SPAWN TOOLBOX //

	// Spawn lights
	level thread spawn_warning_light( (1585, 1004, 312.4), "teleporter_a" );
	level thread spawn_warning_light( (983.9, 934.7, 311.4), "teleporter_a" );

	// Spawn sparks
	wait(0.5);
	level thread spawn_sparks( (1072.9, 1171, 213), "teleporter_a" ); // left
	wait(0.5);
	level thread spawn_sparks( (1453, 1191.4, 189.5), "teleporter_a" ); // right
	wait(0.5);
	level thread spawn_sparks( (1550, 1120, 208.3), "teleporter_a" ); // far right
	
	level waittill("teleporter_a_fixed"); 
	level.teleporter_a_sparks = undefined;

	playsoundatposition( "pa_buzz",  level.a ); 
	exploder( 102 ); // turns back on tele

	ClientNotify( "t01" ); 

	//level.teleporter_pad_trig[0] teleport_trigger_invisible( false );
	level.teleporter_pad_trig[0] sethintstring( &"REMASTERED_ZOMBIE_TELEPORT_LACKS_POWER" );

	level.repairs_made += 1;

	if(level.repairs_made == 3)
	{
		level notify("all_teleporters_fixed");
	}
	// Change hintstring of TP?
}

teleporter_b_fix()
{
	level.juicer_failed = 1; // always 1 unless we go out of our way to do the step correctly
	level.you_failed_juice = 0;
	level.teleporter_b_fixed = false;

	// Spawn lights
	level thread spawn_warning_light( (-1543.6, -757.5, 299.6), "teleporter_b" );

	// Red juice
	juice = spawn( "script_model",(-1372.9, -651.9, 199.125) );
	juice setmodel("tag_origin");
	level thread part_pickup(juice, "juice", false); 
	
	// Spawn boiler trig
	level thread spawn_boiler_lever();

	// boiler origin
	//(-1368.2, -964.27, 215.5)

	while(1)
	{
		// Spawn sparks
		wait( randomint(5) );
		level thread spawn_sparks( (-1657.1, -1348.9, 230.13), "teleporter_b", 0 ); // right
		wait( randomint(5) );
		level thread spawn_sparks( (-1699.1, -1276.2, 215.1), "teleporter_b", 1 ); // left
		wait( randomint(5) );
		level thread spawn_sparks( (-1616, -848.2, 218.5), "teleporter_b", 2 ); // lower left 

		level waittill("teleporter_b_fixed_potential"); // we think we might be fixed, we recieve a notify from hitting 0 sparks

		if(level.juicer_failed == 1 || level.you_failed_juice == 1) 
		{
			level.teleporter_b_sparks = 0; // reset progress
			level.you_failed_juice = 0;
			continue; // we failed, keep trying
		}
		else
		{
			level.lever_trig delete();
			level.teleporter_b_fixed = true;
			break;

		}
	}
	
	level notify("teleporter_b_fixed"); // instead we have an extra condition for this tele to make step harder
	level.juicer_failed = undefined;
	level.teleporter_b_sparks = undefined;

	playsoundatposition( "pa_buzz",  level.b ); 
	exploder( 104 ); // turns back on tele

	ClientNotify( "t21" ); 

	//level.teleporter_pad_trig[2] teleport_trigger_invisible( false );
	level.teleporter_pad_trig[2] sethintstring( &"REMASTERED_ZOMBIE_TELEPORT_LACKS_POWER" );

	level.repairs_made += 1;
	if(level.repairs_made == 3)
	{
		level notify("all_teleporters_fixed");
	}
	// Change hintstring of TP?
}


spawn_boiler_lever()
{
	wait_network_frame();

	location = (-1453.5, -944, 225);
	level.lever = spawn("script_model", location );
	level.lever setModel("zombie_sumpf_zipcage_switch");
	level.lever.angles = (0,90,-20); // neutral pos
	level.lever_trig = spawn( "trigger_radius", location + (-40,0,0) , 0, 20, 20 );
	level.lever_trig SetCursorHint("HINT_NOICON");
	resetting = false;
	
	while(1)
	{
		level.lever_trig waittill( "trigger", player );
		if( !player UseButtonPressed() || !player IsTouching(level.lever_trig) || resetting == true ) // From here on, player must be holding F and touching trig, otherwise we just go back to the start
		{
			continue;
		}

		if( is_player_valid(player) && !player isThrowingGrenade() )
		{
			while( player UseButtonPressed() && player IsTouching(level.lever_trig) && (!player maps\_laststand::player_is_in_laststand()) && level.juicer_failed == 1 ) // only keep moving while juicer_failed is 1, if we suceed it goes to 0
			{
				level.lever rotateTo( (level.lever.angles + (-45,0,0) ), 0.5, 0.1, 0.1 );
				playsoundatposition( "switch_progress", level.lever.origin );
				//self rotateTo( (180,0,-30), 0.25, 0.1, 0.1); 
				wait(1.25);	
			}

		}
		if(level.lever.angles[0] == 90)
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(distance(players[i].origin, (-1368.2, -964.27, 215.5) ) < 200 )
				{
					if(players[i] hasweapon("zombie_item_beaker") )
					{
						players[i] thread cleanup_juicer();

						playFx(level._effect["teleporter_smoke_fail"], location + (100,0,-20) );
						playsoundatposition( "steam_effect", location );
						wait_network_frame();
						playsoundatposition( "shoot_off", location ); // need new sound
						level.juicer_failed = 0;
						wait(15);
						level.juicer_failed = 1;
						if(level.teleporter_b_fixed == false )
						{
							juice = spawn( "script_model",(-1372.9, -651.9, 199.125) );
							juice setmodel("tag_origin");
							level thread part_pickup(juice, "juice", false); 
						}
					}
				}
			}
		}
		
		if(level.lever.angles != (0,90,-20) && level.juicer_failed == 1 && level.teleporter_b_fixed == false ) // only reset when we're doing things wrong and not at neutral pos, if we do something right we remain
		{
			resetting = true;
			level.lever rotateTo( (0,90,-20), 0.75, 0.1, 0.1 );
			playsoundatposition( "switch_progress", level.lever.origin );
			wait(0.75);
			resetting = false;
			
			if(getplayers().size > 1)
			{
				index = maps\_zombiemode_weapons::get_player_index(player);
				plr = "plr_" + index + "_";
				player thread create_and_play_dialog( plr, "vox_gen_teamwork", 0.25 );
			}
		}

		if(!isDefined(level.lever_trig) )
		{
			break;
		}
		wait(0.05);
	}
}

juicer_timer()
{
	duration = 25 / getplayers().size ;
	//self playloopsound("idk");
	if(self hasperk("specialty_armorvest") )
	{
		self.maxhealth = 350;
		self.health = 350;
	}
	else
	{
		self.maxhealth = 200;
		self.health = 200;	
	}
	
	self setblur( 2, duration / 2 );
	while(1)
	{
		wait(0.05);
		duration -= 0.05;
        if ( duration <= 0 )
        break;
	}
	self setblur( 0, 1.5 );

	if(self hasweapon("zombie_item_beaker") ) // if we still have the weapon this means we failed and so we reset, otherwise if we suceed then that step cleans up our weap
	{
		self cleanup_juicer();

		if(level.teleporter_b_fixed == false )
		{
			juice = spawn( "script_model",(-1372.9, -651.9, 199.125) );
			juice setmodel("tag_origin");
			level thread part_pickup(juice, "juice", false); 
		}
	}

}

cleanup_juicer()
{
	self playlocalsound("bottle_break");

	if(self hasperk("specialty_armorvest") )
	{
		self.maxhealth = 250;
		self.health = 250;
	}
	else
	{
		self.maxhealth = 100;
		self.health = 100;	
	}

	if(self GetCurrentWeapon() == "zombie_item_beaker" )
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}	
	}

	self takeweapon("zombie_item_beaker"); 
	self setactionslot(1,""); 
	self.has_special_weap = undefined;
}

teleporter_c_fix()
{
	level.bad_spark_error = 0; // will always be 0 unless we make a mistake while trying to solve

	// Spawn lights
	level thread spawn_warning_light( (590.2, -3025.15, 324.5), "teleporter_c" );
	level thread spawn_warning_light( (-17.7, -3027, 324.35), "teleporter_c" );

	level thread spawn_valve_lever();

	while(1)
	{
		// Spawn sparks
		wait( randomint(10) );
		level thread spawn_sparks( (588.7, -3087, 164), "teleporter_c", 1 ); // left 
		wait( randomint(10) );
		level thread spawn_sparks( (432.8, -3138.4, 206.7), "teleporter_c", 0 ); // middle
		wait( randomint(10) );
		level thread spawn_sparks( (57.3, -3134.9, 198.7), "teleporter_c", 2 ); // right

		level waittill("teleporter_c_fixed_potential"); // we think we might be fixed, we recieve a notify from hitting 0 sparks

		if(level.bad_spark_error == 1)
		{
			level.bad_spark_error = 0; // we reset error potential, clean slate
			level.teleporter_c_sparks = 0; // reset progress
			continue; // we failed, keep trying
		}
		else
		{
			level.lever_trig_pipe delete();
			break;

		}
	}
	
	level notify("teleporter_c_fixed"); // instead we have an extra condition for this tele to make step harder

	level.where_are_we = undefined;
	level.bad_spark_error = undefined;
	level.teleporter_c_sparks = undefined;

	playsoundatposition( "pa_buzz",  level.c ); 
	exploder( 103 ); // turns back on tele

	ClientNotify( "t11" ); 

	//level.teleporter_pad_trig[1] teleport_trigger_invisible( false );
	level.teleporter_pad_trig[1] sethintstring( &"REMASTERED_ZOMBIE_TELEPORT_LACKS_POWER" );

	level.repairs_made += 1;
	if(level.repairs_made == 3)
	{
		level notify("all_teleporters_fixed");
	}
}


spawn_warning_light(location, teleporter)
{
	wait_network_frame();
	fx_light = spawn("script_model", location );
	fx_light setModel("tag_origin");
	playFxOnTag(level._effect["zapper_light_notready"], fx_light, "tag_origin");

	level waittill(teleporter + "_fixed");
	
	fx_light delete();

}

spawn_sparks(location, teleporter, number) // NEED SPARK LOOP SOUND
{
	wait_network_frame();

	// SPARK FX & SOUND
	fx_spark = spawn("script_model", location );
	fx_spark setModel("tag_origin");
	playfxontag(level._effect["switch_sparks"], fx_spark, "tag_origin");
	fx_spark thread random_spark_sounds();

	// SPARK TRIG
	trig_spark = spawn( "trigger_radius", location, 0, 45, 20 );
	trig_spark SetCursorHint("HINT_NOICON");

	while(1)
	{
		trig_spark waittill( "trigger", player );

		while(1)
		{
			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( location ) ) // if we look away
			{
				trig_spark SetCursorHint("HINT_NOICON");
				break;
			}
			if( !player IsTouching( trig_spark ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			
			trig_spark SetCursorHint("HINT_ACTIVATE");

			if( !player UseButtonPressed() )
			{
				break; 
			}
			if(IsDefined(player.has_tools) && player.has_tools)
			{
				if(teleporter == "teleporter_c")
				{
					if(level.where_are_we != number)
					{
						level.bad_spark_error = 1;
					
						if(getplayers().size > 1 )
						{
							index = maps\_zombiemode_weapons::get_player_index(player);
							plr = "plr_" + index + "_";
							player thread create_and_play_dialog( plr, "vox_gen_help", 0.25 );
						}
					}
				}
				if(teleporter == "teleporter_b")
				{
					if(level.juicer_failed == 1) // if we ever tried to fix without correct parameters
					{
						level.you_failed_juice = 1;

						if(getplayers().size > 1 )
						{
							index = maps\_zombiemode_weapons::get_player_index(player);
							plr = "plr_" + index + "_";
							player thread create_and_play_dialog( plr, "vox_gen_help", 0.25 );
						}
					}
				}
				player playlocalsound("switch_up");
				trig_spark delete();
			}
			else if(!IsDefined(player.has_tools) || player.has_tools == false ) // if we have no tools, do a lil dmg and groan
			{
				player playlocalsound("pole_spark"); 

				if(!player hasperk("specialty_armorvest") || player.health - 100 < 1)
				{
					radiusdamage(player.origin,10,5,5);
				}
				else
				{
					player dodamage(5, player.origin);
				}
				break;
			}

			break;

		}
		if(!isDefined(trig_spark) )
		{
			break;
		}
	}

	fx_spark delete();

	switch(teleporter)
	{
	case "teleporter_a":
		level.teleporter_a_sparks += 1;
		if(level.teleporter_a_sparks == 3)
		{
			level notify("teleporter_a_fixed");
		}
		break;
	case "teleporter_b":
		level.teleporter_b_sparks += 1;
		if(level.teleporter_b_sparks == 3)
		{
			level notify("teleporter_b_fixed_potential");
		}
		break;
	case "teleporter_c":
		level.teleporter_c_sparks += 1;
		if(level.teleporter_c_sparks == 3)
		{
			level notify("teleporter_c_fixed_potential");
		}
		break;
	}


}

spawn_valve_lever()
{
	wait_network_frame();

	location = (-98.5,-2404.8, 151);
	level.lever_pipe = spawn("script_model", location );
	level.lever_pipe setModel("zombie_sumpf_zipcage_switch");
	level.lever_pipe.angles = (180,0,0); // neutral pos
	level.lever_trig_pipe = spawn( "trigger_radius", location - (0,0,40), 0, 8, 30 );
	level.lever_trig_pipe SetCursorHint("HINT_NOICON");

	level.where_are_we = 0; // neutral pos
	level.thread_only_once = 0;

	while(1)
	{
		level.lever_trig_pipe waittill( "trigger", player );
		while(1)
		{
/*			if( !player maps\nazi_zombie_factory_new_eggs::islookingatorigin( location ) ) // if we look away
			{
				break;
			}*/
			
			if(getplayers().size != 1 && level.thread_only_once == 0 )
			{
				level.thread_only_once = 1;
				player thread check_touching_trig();
			}
			if( !player IsTouching( level.lever_trig_pipe ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if( !player UseButtonPressed() )
			{
				break; 
			}
			if(level.where_are_we == 0) // If neutral, we move left
			{
				playsoundatposition( "switch_progress", level.lever_pipe.origin );
				level.lever_pipe rotateTo( (180,0,-30), 0.25, 0.1, 0.1); // Left
				level.where_are_we = 1; // Left
				wait(1.25);
				break;
			}
			else if(level.where_are_we == 1) // if left, we move right (twice as long distance)
			{
				playsoundatposition( "switch_progress", level.lever_pipe.origin );
				level.lever_pipe rotateTo( (180,0,30), 0.25*2, 0.1, 0.1); // Right
				level.where_are_we = 2; // Right
				wait(1.25);
				break;
			}
			else if(level.where_are_we == 2) // if right, we move neutral
			{
				playsoundatposition( "switch_progress", level.lever_pipe.origin );
				level.lever_pipe rotateTo( (180,0,0), 0.25, 0.1, 0.1); // Neutral
				level.where_are_we = 0; // Neutral
				wait(1.25);
				break;
			}
			break;
		}
		if(!isDefined(level.lever_trig_pipe) )
		{
			break;
		}
	}
}

give_all_perks_forever()
{
	self endon("disconnect");
	self endon("death");

	if(!IsDefined(level._sq_perk_array))
	{
		level._sq_perk_array = [];
		
		machines = GetEntArray( "zombie_vending", "targetname" );	
		
		for(i = 0; i < machines.size; i ++)
		{
			level._sq_perk_array[level._sq_perk_array.size] = machines[i].script_noteworthy;
		}
	}

	players = get_players(); // First time we give perks 0.5 wait for nice delay effect

	if(!self HasPerk(level._sq_perk_array[2]) && is_player_valid(self))
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[2]);
		wait(0.5);
	}
	if(!self HasPerk(level._sq_perk_array[3]) && is_player_valid(self))
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[3]);
		wait(0.5);
	}
	if(!self HasPerk(level._sq_perk_array[0]) && is_player_valid(self))
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[0]);
		wait(0.5);
	}
	if(!self HasPerk(level._sq_perk_array[1]) && is_player_valid(self) && (players.size != 1) ) // COOP
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[1]);
	}
	//SOLO
	if(!self HasPerk(level._sq_perk_array[1]) && is_player_valid(self) && (players.size == 1 && level.solo_second_lives_left > 0) ) // if not solo, or if no lives, we just skip
	{
		if(	level.solo_second_lives_left > 0 ) // if still have lives, give quick revive
		{
			self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[1]);
		}

		level.solo_second_lives_left = level.solo_second_lives_left - 1;

		if( level.solo_second_lives_left == 0 )
		{
			level thread maps\_zombiemode_perks::revive_machine_exit();
		}
	}

	while(1)
	{
		//for(i = 3; i > level._sq_perk_array.size; i --)
		//{
		//no for loop, yes this is more messy but now they're in rainbow perk order :)
			if ( level.remove_ee_ef == 1)
			{
				self.perk_hud[ "specialty_armorvest" ] destroy_hud();
				self.perk_hud[ "specialty_rof" ] destroy_hud();
				self.perk_hud[ "specialty_fastreload" ] destroy_hud();
				self.perk_hud[ "specialty_quickrevive" ] destroy_hud();
				break;
			}
			if(!self HasPerk(level._sq_perk_array[2]) && is_player_valid(self))
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[2]);
			}
			if(!self HasPerk(level._sq_perk_array[3]) && is_player_valid(self))
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[3]);
			}
			if(!self HasPerk(level._sq_perk_array[0]) && is_player_valid(self))
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[0]);
			}

			//COOP
			if(!self HasPerk(level._sq_perk_array[1]) && is_player_valid(self) && (players.size != 1) )
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[1]);
			}

			//SOLO
			if(!self HasPerk(level._sq_perk_array[1]) && is_player_valid(self) && (players.size == 1 && level.solo_second_lives_left > 0) ) // if not solo, or if no lives, we just skip
			{
				if(	level.solo_second_lives_left > 0 ) // if still have lives, give quick revive
				{
					self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[1]);
				}

				level.solo_second_lives_left = level.solo_second_lives_left - 1;

				if( level.solo_second_lives_left == 0 )
				{
					level thread maps\_zombiemode_perks::revive_machine_exit();
				}
			}

		//}
		wait(0.05);
	}
}

check_touching_trig()
{
	while(self isTouching(level.lever_trig_pipe) )
	{
		wait(0.05);
	}

	if(level.where_are_we != 0 )
	{	
		wait(1);
		playsoundatposition( "switch_progress", level.lever_pipe.origin );
		level.lever_pipe rotateTo( (180,0,0), 0.25, 0.1, 0.1); // Neutral
		level.where_are_we = 0; // Neutral		

		index = maps\_zombiemode_weapons::get_player_index(self);
		plr = "plr_" + index + "_";
		self thread create_and_play_dialog( plr, "vox_gen_teamwork", 0.25 );
	}
	level.thread_only_once = 0;
}

