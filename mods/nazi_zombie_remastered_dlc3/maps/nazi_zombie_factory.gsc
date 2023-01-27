#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility; 
#include maps\_zombiemode_zone_manager; 
#include maps\nazi_zombie_factory_teleporter;
#include maps\_music;


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

	precacheModel("static_berlin_ger_radio");
	precacheModel("zombie_books_open");



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

	level thread teddy_easteregg_vox();

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
	spawncollision("collision_wall_64x64x10","collider",(606.1, -2225, 286.5), (0, -90, 0)); // new

	thread maps\nazi_zombie_factory_new_eggs::init();
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
		level.intro_hud[i].x = 3;
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
	// DP-28 DISABLED FOR NOW
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
		// player has dropped the tesla for another weapon, so we set all future polls to 20%
		if( isDefined(level.player_drops_tesla_gun) && level.player_drops_tesla_gun == true )
		{						
			num_to_add += int(.2 * level.zombie_include_weapons.size);		
		}
		
		// player has not seen tesla gun in late rounds
		if( !isDefined(level.player_seen_tesla_gun) || level.player_seen_tesla_gun == false )
		{
			// after round 10 the Tesla gun percentage increases to 20%
			if( level.round_number > 10 )
			{
				num_to_add += int(.2 * level.zombie_include_weapons.size);
			}		
			// after round 5 the Tesla gun percentage increases to 15%
			else if( level.round_number > 5 )
			{
				// calculate the number of times we have to add it to the array to get the desired percent
				num_to_add += int(.15 * level.zombie_include_weapons.size);
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
	
	//turn the light above the door red
	zapper_light_red( light_name );
	tswitch rotatepitch(180,.5);
	tswitch playsound("amb_sparks_l_b");
	tswitch waittill("rotatedone");

	self notify("switch_activated");
	self waittill("available");
	tswitch rotatepitch(-180,.5);

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
		if( !self enemy_is_dog() && randomint(100) > 50 )
		{
			self thread electroctute_death_fx();
			self thread play_elec_vocals();
		}
		wait(randomfloat(1.25));
		self playsound("zombie_arc");
	}

	self dodamage(self.health + 666, self.origin);
	iprintlnbold("should be damaged");
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

/*
play_oh_shit_dialog()
{
	//player = getplayers();	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_oh_shit))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_oh_shit");
		self.vox_oh_shit = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_oh_shit[self.vox_oh_shit.size] = "vox_oh_shit_" + i;	
		}
		self.vox_oh_shit_available = self.vox_oh_shit;		
	}	
	sound_to_play = random(self.vox_oh_shit_available);
	
	self.vox_oh_shit_available = array_remove(self.vox_oh_shit_available,sound_to_play);
	
	if (self.vox_oh_shit_available.size < 1 )
	{
		self.vox_oh_shit_available = self.vox_oh_shit;
	}
	
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
}
*/

level_start_vox()
{
	wait( 6 );//moved here
	index = maps\_zombiemode_weapons::get_player_index( self );
	plr = "plr_" + index + "_";
	// wait( 6 );//commented out
	self thread create_and_play_dialog( plr, "vox_level_start", 0.25 );
	// Do easter egg vox on solo
	wait( 4 );
	//self thread create_and_play_dialog( plr, "vox_gen_giant", 0.25 );

	players = get_players();
	if( players.size == 1 )
	{
		while(1)
			{
				vox_rand = randomintrange(1,101);
				if( level.round_number <= 5 )
				{
					if( vox_rand <= 5 /*3*/ )
					{
					rando_easter_egg_mythos(plr);
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
	//iprintlnbold( "Samantha Sez: Let's play Hide and Seek!" );

	//	Now find them!
	flag_set( "hide_and_seek" );

	flag_wait( "ee_exp_monkey" );
	flag_wait( "ee_bowie_bear" );
	flag_wait( "ee_perk_bear" );

	level.teleporter_powerups_reward = true;
	wait( 4.0 );

	ss = getstruct( "teleporter_powerup", "targetname" );
	ss thread maps\_zombiemode_powerups::special_powerup_drop(ss.origin, true, true);

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

/*
radio_egg_hanging_init( trigger_name, origin_name )
{
	radio_trig = getent( trigger_name, "targetname");
	radio_origin = getent( origin_name, "targetname");

	if( ( !isdefined( radio_trig ) ) || ( !isdefined( radio_origin ) ) )
	{
		return;
	}
	
	while(1)
	{
		radio_trig waittill( "trigger", player);
		dist = distancesquared(player.origin, radio_trig.origin);
		if( dist < 900 * 900)
		{
			radio_origin playsound( trigger_name );
			return;
		}
		else
		{
			wait(.05);
		}
	}	
}
*/

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
				players[p] thread create_and_play_dialog( plr, "vox_gen_giant", .25 );
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
			

rando_easter_egg_mythos()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_giant))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_giant");
		self.vox_gen_giant = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_giant[self.vox_gen_giant.size] = "vox_gen_giant_" + i;	
		}
		self.vox_gen_giant_available = self.vox_gen_giant;		
	}	
	sound_to_play = random(self.vox_gen_giant_available);
	
	self.vox_gen_giant_available = array_remove(self.vox_gen_giant_available,sound_to_play);
	
	if (self.vox_gen_giant_available.size < 1 )
	{
		self.vox_gen_giant_available = self.vox_gen_giant;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	
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
					//iprintlnbold( "Inside trigger " + object );
					who thread create_and_play_dialog( plr, "vox_resp_corkmap", .25 );
					break;
				case "vox_corkboard_2":
					//iprintlnbold( "Inside trigger " + object );
					who thread create_and_play_dialog( plr, "vox_resp_corkmap", .25 );
					break;
				case "vox_corkboard_3":
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

teddy_easteregg_vox()
{

	teddy_trig = spawn( "trigger_radius",( -660, -1440, 199), 0, 70, 50 );
	players = getplayers();

	for(i=0;i<players.size;i++)
	{	
		while(1)
		{
			teddy_trig waittill( "trigger", player );
			if(!isdefined (level.player_is_speaking))
			{
				level.player_is_speaking = 0;
			}

			weapon = player getCurrentWeapon();
			aiming = isADS( player );
			if( aiming && ( isSubStr(weapon, "ptrs41") || isSubStr(weapon, "scoped") ) && level.player_is_speaking == 0 )
			{
				if( randomintrange(0,100) < 35 )
				{
					wait(0.5);
					index = maps\_zombiemode_weapons::get_player_index(player);
					plr = "plr_" + index + "_";
					player thread create_and_play_dialog( plr, "vox_resp_teddy", 0.25 );
					break; 
				}
				wait(1);
			}
			wait(0.5);
		}
	}
}	