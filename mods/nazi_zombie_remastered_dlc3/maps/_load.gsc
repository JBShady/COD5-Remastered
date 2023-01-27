#include common_scripts\utility;
#include maps\_utility;
//#include maps\_debug;
#include maps\_hud_util;

main( bScriptgened,bCSVgened,bsgenabled )
{
println( "_LOAD START TIME = " + GetTime() );
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: main()\n" ); 
	}
	#/
	
	set_early_level(); 
	
	animscripts\weaponList::precacheclipfx(); 
	
	if( !IsDefined( level.script_gen_dump_reasons ) )
	{
		level.script_gen_dump_reasons = []; 
	}
	if( !IsDefined( bsgenabled ) )
	{
		level.script_gen_dump_reasons[level.script_gen_dump_reasons.size] = "First run"; 
	}
	if( !IsDefined( bCSVgened ) )
	{
		bCSVgened = false; 
	}
	level.bCSVgened = bCSVgened; 
	
	if( !IsDefined( bScriptgened ) )
	{
		bScriptgened = false; 
	}
	else
	{
		bScriptgened = true; 
	}
	level.bScriptgened = bScriptgened; 

	/#
	ascii_logo();
	#/
	
	if( GetDvar( "debug" ) == "" )
	{
		SetDvar( "debug", "0" ); 
	}

	if( GetDvar( "fallback" ) == "" )
	{
		SetDvar( "fallback", "0" ); 
	}

	if( GetDvar( "angles" ) == "" )
	{
		SetDvar( "angles", "0" ); 
	}

	if( GetDvar( "noai" ) == "" )
	{
		SetDvar( "noai", "off" ); 
	}

	if( GetDvar( "scr_RequiredMapAspectratio" ) == "" )
	{
		SetDvar( "scr_RequiredMapAspectratio", "1" ); 
	}
		
	CreatePrintChannel( "script_debug" ); 

	// MikeD (9/4/2008): ZombieMode, reset dvar
	if( !isdefined( level.zombiemode  ) || !level.zombiemode  )
	{
		//coder mod: tkeegan - new code dvar
		setSavedDvar( "zombiemode", "0" );
	}		
	
	if( !IsDefined( anim.notetracks ) )
	{
		// string based array for notetracks
		anim.notetracks = []; 
		animscripts\shared::registerNoteTracks(); 
	}
	
	level._loadStarted = true; 
	level.first_frame = true; 
	level.level_specific_dof = false; 
	
	// CODER_MOD
	// DSL - 05/21/08 - Set to true when all players have connected to the game.
	//level._players_connected = false;
	flag_init( "all_players_connected" );
	flag_init( "all_players_spawned" );
	flag_init( "drop_breadcrumbs");
	flag_set( "drop_breadcrumbs" );
	
	thread remove_level_first_frame(); 

	level.wait_any_func_array = []; 
	level.run_func_after_wait_array = []; 
	level.do_wait_endons_array = []; 
	
	level.script = Tolower( GetDvar( "mapname" ) ); 
	level.radiation_totalpercent = 0; 

	level.clientscripts = ( GetDvar( "cg_usingClientScripts" ) != "" );; 

	level._client_exploders = [];
	level._client_exploder_ids = [];

	registerClientSys( "levelNotify" ); 
	registerClientSys( "lsm" );
	
	flag_init( "missionfailed" ); 
	flag_init( "auto_adjust_initialized" ); 
	flag_init( "global_hint_in_use" ); 
	
	// MikeD( 12/15/2007 ): IW abandoned this feature( auto-adjust )
	//thread maps\_gameskill::aa_init_stats(); 

	// MikeD( 12/15/2007 ): Doesn't appear to do anything...
	// thread player_death_detection(); 

	level.default_run_speed = 190; 
	SetSavedDvar( "g_speed", level.default_run_speed ); 
	
	if( !arcadeMode() )
	{
		SetSavedDvar( "sv_saveOnStartMap", true ); 
	}
	else
	{
		// MikeD( 12/15/2007 ): This only seems be setup for the Credits level of CoD4.
		SetSavedDvar( "sv_saveOnStartMap", false ); 
		thread arcademode_save(); 
	}

	level.dronestruct = []; 
	struct_class_init(); 

	if( !IsDefined( level.flag ) )
	{
		level.flag = []; 
		level.flags_lock = []; 
	}
	else
	{
		// flags initialized before this should be checked for stat tracking
		flags = GetArrayKeys( level.flag ); 
		array_levelthread( flags, ::check_flag_for_stat_tracking ); 
	}
	
	// can be turned on and off to control friendly_respawn_trigger
	flag_init( "respawn_friendlies" ); 
	flag_init( "player_flashed" ); 

	// for script gen
	flag_init( "scriptgen_done" ); 
	level.script_gen_dump_reasons = []; 
	if( !IsDefined( level.script_gen_dump ) )
	{
		level.script_gen_dump = []; 
		level.script_gen_dump_reasons[0] = "First run"; 
	}

	if( !IsDefined( level.script_gen_dump2 ) )
	{
		level.script_gen_dump2 = []; 
	}
		
	if( IsDefined( level.createFXent ) )
	{
		script_gen_dump_addline( "maps\\createfx\\"+level.script+"_fx::main(); ", level.script+"_fx" );  // adds to scriptgendump
	}

	if( IsDefined( level.script_gen_dump_preload ) )
	{
		for( i = 0; i < level.script_gen_dump_preload.size; i++ )
		{
			script_gen_dump_addline( level.script_gen_dump_preload[i].string, level.script_gen_dump_preload[i].signature ); 
		}
	}

//	level.player.maxhealth = level.player.health; 
//	level.player.shellshocked = false; 
//	level.aim_delay_off = false; 
//	level.player.inWater = false; 
//	level.last_wait_spread = -1; 
	level.last_mission_sound_time = -5000; 

	// MikeD( 9/4/2007 ): These 2 arrays are needed for _colors.
	level.hero_list = []; 
	level.ai_array = []; 
	thread precache_script_models(); 
	
	// SCRIPT_MOD
	// these are head icons so you can see who the players are
	PrecacheHeadIcon( "headicon_american" ); 

/#
	PrecacheModel( "fx" ); 
//	PrecacheModel( "temp" ); 
#/	
	PrecacheModel( "tag_origin" ); 
	PrecacheModel( "tag_origin_animate" ); 
	PrecacheShellShock( "level_end" ); 
	PrecacheShellShock( "default" ); 
	PrecacheShellShock( "flashbang" ); 
	PrecacheShellShock( "dog_bite" ); 
	PrecacheShellShock( "pain" ); 
	PrecacheRumble( "damage_heavy" ); 
	PrecacheRumble( "damage_light" ); 
	PrecacheRumble( "grenade_rumble" ); 
	PrecacheRumble( "artillery_rumble" ); 
	
	PrecacheString( &"GAME_GET_TO_COVER" ); 
	PrecacheString( &"SCRIPT_GRENADE_DEATH" ); 
	PrecacheString( &"SCRIPT_GRENADE_SUICIDE_LINE1" ); 
	PrecacheString( &"SCRIPT_GRENADE_SUICIDE_LINE2" ); 
	PrecacheString( &"SCRIPT_EXPLODING_VEHICLE_DEATH" ); 
	PrecacheString( &"SCRIPT_EXPLODING_BARREL_DEATH" ); 
	PrecacheString( &"SCRIPT_PANZERSHREK_DEATH" ); 
	PrecacheString( &"SCRIPT_TANKSHELL_DEATH" ); 
	PrecacheString( &"STARTS_AVAILABLE_STARTS" ); 
	PrecacheString( &"STARTS_CANCEL" );  
	PrecacheString( &"STARTS_DEFAULT" ); 
	PrecacheShader( "overlay_low_health" ); 
	PrecacheShader( "overlay_low_health_compass" ); 
	PrecacheShader( "hud_grenadeicon" ); 
	PrecacheShader( "hud_grenadepointer" ); 
	PrecacheShader( "hud_burningcaricon" ); 
	PrecacheShader( "hud_burningbarrelicon" ); 
	PrecacheShader( "black" );
	PrecacheShader( "white" );

	PreCacheShellShock( "death" );
	PreCacheShellShock( "explosion" );
	PreCacheShellShock( "tank_mantle" );
	
	// MikeD( 10/30/2007 ): Defaulting water off
	WaterSimEnable( false ); 
	
	level.createFX_enabled = ( GetDvar( "createfx" ) != "" ); 

	maps\_cheat::init(); 

	maps\_mgturret::main(); 
	maps\_mgturret::setdifficulty(); 

	setupExploders(); 
	maps\_art::main(); 
	thread maps\_vehicle::init_vehicles(); 	
	
	maps\_anim::init(); 

	thread maps\_createfx::fx_init(); 
	if( level.createFX_enabled )
	{
		maps\_callbackglobal::init(); 
		calculate_map_center(); 
		maps\_loadout::init_loadout(); // MikeD: Just to set the level.campaign		
		maps\_createfx::createfx(); 
	}

	maps\_detonategrenades::init(); 
	
	thread setup_simple_primary_lights(); 
	
	// MikeD( 10/28/2007 3:06:12 ): Precache Gib FX
	animscripts\death::precache_gib_fx(); 

	// --------------------------------------------------------------------------------
	// ---- PAST THIS POINT THE SCRIPTS DONT RUN WHEN GENERATING REFLECTION PROBES ----
	// --------------------------------------------------------------------------------
	/#	
	if( GetDvar( "r_reflectionProbeGenerate" ) == "1" )
	{
		maps\_global_fx::main(); 
		maps\_loadout::init_loadout(); // MikeD: Just to set the level.campaign
		level waittill( "eternity" ); 
	}
	#/
	
	thread handle_starts(); 
		
	if( GetDvar( "g_connectpaths" ) == "2" )
	{
		/# println( "g_connectpaths == 2; halting script execution" ); #/
		level waittill( "eternity" ); 
	}

	println( "level.script: ", level.script ); 

	// CODE_MOD
	maps\_callbackglobal::init(); 
	maps\_callbacksetup::SetupCallbacks(); 
	maps\_autosave::main(); 

	maps\_anim::init(); 
	maps\_busing::businit(); 
	maps\_ambient::init(); 
	maps\_ambientpackage::init(); 
	maps\_music::music_init(); 
	
	// lagacy... necessary?
	anim.useFacialAnims = false; 

	if( !IsDefined( level.missionfailed ) )
	{
		level.missionfailed = false; 
	}

	maps\_gameskill::setSkill();
	maps\_loadout::init_loadout();
	maps\_destructible::main();
	//maps\_ai_supplements::init_ai_supplements();
	maps\_challenges_coop::init();
	maps\_hud_message::init();
	SetObjectiveTextColors();
	maps\_laststand::init(); 	
	
	// CODE_MOD
	thread maps\_cooplogic::init(); 
	thread maps\_ingamemenus::init(); 
	calculate_map_center(); 

	// global effects for objects
	maps\_global_fx::main(); 
	
	//thread devhelp(); // disabled due to localization errors
	
// CODER_MOD
// moved from _loadout::give_loadout()
	if( !IsDefined( level.campaign ) )
	{
		level.campaign = "american"; 
	}

	SetSavedDvar( "ui_campaign", level.campaign ); // level.campaign is set in maps\_loadout::init_loadout

	/#
	thread maps\_debug::mainDebug(); 
	#/

// SCRIPTER_MOD
// MikeD( 3/20/2007 ): Added for _createcam to work.
/#
	// commented out prevent variable limit being hit
	//maps\_createcam::main(); 
#/	

	// MikeD( 7/27/2007 ): Added the SaveGame here for the beginning of the level.
	level thread maps\_autosave::start_level_save(); 

	// CODER_MOD
	// DSL - 05/21/08 - All players have connected mechanism.
	level thread all_players_connected();
	level thread all_players_spawned();
	thread maps\_introscreen::main(); 

	thread maps\_minefields::main(); 
	thread maps\_shutter::main(); 
//	thread maps\_breach::main(); 
//	thread maps\_inventory::main(); 
//	thread maps\_photosource::main(); 
	thread maps\_endmission::main(); 
	maps\_friendlyfire::main(); 

	// For _anim to track what animations have been used. Uncomment this locally if you need it.
//	thread usedAnimations(); 

	array_levelthread( GetEntArray( "badplace", "targetname" ), ::badplace_think ); 
	array_levelthread( GetEntArray( "delete_on_load", "targetname" ), ::deleteEnt ); 
	array_thread( GetNodeArray( "traverse", "targetname" ), ::traverseThink ); 
	/# array_thread( GetNodeArray( "deprecated_traverse", "targetname" ), ::deprecatedTraverseThink ); #/
	array_thread( GetEntArray( "piano_key", "targetname" ), ::pianoThink ); 
	array_thread( GetEntArray( "piano_damage", "targetname" ), ::pianoDamageThink ); 
	array_thread( GetEntArray( "water", "targetname" ), ::waterThink ); 
	
	thread maps\_interactive_objects::main(); 
	// CODER_MOD (Austin 05/22/08): renamed _intelligence to _collectibles
println( "_LOAD COLLECTIBLE TIME = " + GetTime() );
	thread maps\_collectibles::main(); 
	thread maps\_audio::main(); 
	// CODER_MOD
	// Droche 01/28/09 moved to last stand
	// no longer needed
	//thread maps\_revive::main(); 
	
	// this has to come before _spawner moves the turrets around
	thread massNodeInitFunctions(); 
	
	// Various newvillers globalized scripts
	flag_init( "spawning_friendlies" ); 
	flag_init( "friendly_wave_spawn_enabled" ); 
	flag_clear( "spawning_friendlies" ); 
	
	level.spawn_funcs = []; 
	level.spawn_funcs["allies"] = []; 
	level.spawn_funcs["axis"] = []; 
	level.spawn_funcs["neutral"] = []; 
	thread maps\_spawner::goalVolumes(); 
	thread maps\_spawner::friendlyChains(); 
	thread maps\_spawner::friendlychain_onDeath(); 

//	array_thread( GetEntArray( "ally_spawn", "targetname" ), maps\_spawner::squadThink ); 
	array_thread( GetEntArray( "friendly_spawn", "targetname" ), maps\_spawner::friendlySpawnWave ); 
	array_thread( GetEntArray( "flood_and_secure", "targetname" ), maps\_spawner::flood_and_secure ); 
	
	// Do various things on triggers
	array_thread( GetEntArray( "ambient_volume", "targetname" ), maps\_ambient::ambientVolume ); 
	
	level.trigger_hint_string = []; 
	level.trigger_hint_func = []; 
	level.fog_trigger_current = undefined;
	
	if( !IsDefined( level.trigger_flags ) )
	{
		// may have been defined by AI spawning
		init_trigger_flags(); 
	}

	trigger_funcs = []; 
	trigger_funcs["camper_spawner"] = maps\_spawner::camper_trigger_think; 
	trigger_funcs["flood_spawner"] = maps\_spawner::flood_trigger_think; 
	trigger_funcs["trigger_spawner"] = maps\_spawner::trigger_spawner; 
	trigger_funcs["friendly_wave"] = maps\_spawner::friendly_wave; 
	trigger_funcs["friendly_wave_off"] = maps\_spawner::friendly_wave; 
//	trigger_funcs["friendly_mgTurret"] = maps\_spawner::friendly_mgTurret; 
	trigger_funcs["trigger_autosave"] = maps\_autosave::trigger_autosave; 
	trigger_funcs["autosave_now"] = maps\_autosave::autosave_now_trigger; 
	trigger_funcs["trigger_unlock"] = ::trigger_unlock; 
	trigger_funcs["trigger_lookat"] = ::trigger_lookat; 
	trigger_funcs["trigger_looking"] = ::trigger_looking; 
	trigger_funcs["trigger_cansee"] = ::trigger_cansee; 
	trigger_funcs["flag_set"] = ::flag_set_trigger; 
	trigger_funcs["flag_set_player"] = ::flag_set_player_trigger; 
	trigger_funcs["flag_unset"] = ::flag_unset_trigger; 
	trigger_funcs["flag_clear"] = ::flag_unset_trigger; 
	trigger_funcs["random_spawn"] = maps\_spawner::random_spawn; 
	trigger_funcs["objective_event"] = maps\_spawner::objective_event_init; 
//	trigger_funcs["eq_trigger"] = ::eq_trigger; 
	trigger_funcs["friendly_respawn_trigger"] = ::friendly_respawn_trigger; 
	trigger_funcs["friendly_respawn_clear"] = ::friendly_respawn_clear; 
//	trigger_funcs["radio_trigger"] = ::radio_trigger; 
	trigger_funcs["trigger_ignore"] = ::trigger_ignore; 
	trigger_funcs["trigger_pacifist"] = ::trigger_pacifist; 
	trigger_funcs["trigger_delete"] = ::trigger_turns_off; 
	trigger_funcs["trigger_delete_on_touch"] = ::trigger_delete_on_touch; 
	trigger_funcs["trigger_off"] = ::trigger_turns_off; 
	trigger_funcs["trigger_outdoor"] = maps\_spawner::outdoor_think; 
	trigger_funcs["trigger_indoor"] = maps\_spawner::indoor_think; 
	trigger_funcs["trigger_hint"] = ::trigger_hint; 
	trigger_funcs["trigger_grenade_at_player"] = ::throw_grenade_at_player_trigger; 
	trigger_funcs["two_stage_spawner"] = maps\_spawner::two_stage_spawner_think; 
	trigger_funcs["flag_on_cleared"] = maps\_load::flag_on_cleared; 
	trigger_funcs["flag_set_touching"] = ::flag_set_touching; 
	trigger_funcs["delete_link_chain"] = ::delete_link_chain; 
	trigger_funcs["trigger_fog"] = ::trigger_fog; 
	trigger_funcs["trigger_coop_warp"] = maps\_utility::trigger_coop_warp; 
	

	trigger_funcs["no_crouch_or_prone"] = ::no_crouch_or_prone_think; 
	trigger_funcs["no_prone"] = ::no_prone_think; 
	


	// trigger_multiple and trigger_radius can have the trigger_spawn flag set
	trigger_multiple = GetEntArray( "trigger_multiple", "classname" ); 
	trigger_radius = GetEntArray( "trigger_radius", "classname" ); 
	triggers = array_merge( trigger_multiple, trigger_radius ); 

	for( i = 0; i < triggers.size; i++ )
	{
		if( triggers[i].spawnflags & 32 )
		{
			thread maps\_spawner::trigger_spawner( triggers[i] ); 
		}
	}

	for( p = 0; p < 6; p++ )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple"; 
				break; 

			case 1:
				triggertype = "trigger_once"; 
				break; 

			case 2:
				triggertype = "trigger_use"; 
				break; 
				
			case 3:	
				triggertype = "trigger_radius"; 
				break; 
			
			case 4:	
				triggertype = "trigger_lookat"; 
				break; 

			default:
				assert( p == 5 ); 
				triggertype = "trigger_damage"; 
				break; 
		}

		triggers = GetEntArray( triggertype, "classname" ); 

		for( i = 0; i < triggers.size; i++ )
		{
			if( IsDefined( triggers[i].target ) )
			{
				level thread maps\_spawner::trigger_Spawn( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_flag_true ) )
			{
				level thread script_flag_true_trigger( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_flag_false ) )
			{
				level thread script_flag_false_trigger( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_autosavename ) || IsDefined( triggers[i].script_autosave ) )
			{
				level thread maps\_autosave::autosave_name_think( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_fallback ) )
			{
				level thread maps\_spawner::fallback_think( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_mgTurretauto ) )
			{
				level thread maps\_mgturret::mgTurret_auto( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_killspawner ) )
			{
				level thread maps\_spawner::kill_spawner( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_emptyspawner ) )
			{
				level thread maps\_spawner::empty_spawner( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_prefab_exploder ) )
			{
				triggers[i].script_exploder = triggers[i].script_prefab_exploder; 
			}

			if( IsDefined( triggers[i].script_exploder ) )
			{
				level thread maps\_load::exploder_load( triggers[i] ); 
			}

			if( IsDefined( triggers[i].ambient ) )
			{
				triggers[i] thread maps\_ambient::ambient_trigger(); 
			}

			if( IsDefined( triggers[i].script_triggered_playerseek ) )
			{
				level thread triggered_playerseek( triggers[i] ); 
			}
				
			if( IsDefined( triggers[i].script_bctrigger ) )
			{
				level thread bctrigger( triggers[i] ); 
			}

			if( IsDefined( triggers[i].script_trigger_group ) )
			{
				triggers[i] thread trigger_group(); 
			}

			if( IsDefined( triggers[i].script_random_killspawner ) )
			{
				level thread maps\_spawner::random_killspawner( triggers[i] ); 
			}

			// MikeD( 06/26/07 ): Added script_notify, which will send out the value set to script_notify as a level notify once triggered
			if( IsDefined( triggers[i].script_notify ) )
			{
				level thread trigger_notify( triggers[i], triggers[i].script_notify ); 
			}

			if( IsDefined( triggers[i].targetname ) )
			{
				// do targetname specific functions
				targetname = triggers[i].targetname; 
				if( IsDefined( trigger_funcs[targetname] ) )
				{
					level thread[[trigger_funcs[targetname]]]( triggers[i] ); 
				}
			}
		}
	}
	
	level.ai_number = 0; 
	level.shared_portable_turrets = []; 
	maps\_spawner::main(); 

	maps\_hud::init(); 
	//maps\_hud_weapons::init(); 

	thread load_friendlies(); 

	thread maps\_animatedmodels::main(); 	
	script_gen_dump(); 
	thread weapon_ammo(); 
	thread filmy(); 

	// CODE_MOD
	// moved from _utility::shock_ondeath() so hot joiners would not try and 
	// precache mid game
	PrecacheShellShock( "default" ); 

	level thread maps\_gameskill::aa_init_stats(); 

	level thread onFirstPlayerReady(); 
	level thread onPlayerConnect(); 

	// Handles the "placed weapons" in the map. Deletes the ones that we do not want depending on the amount of coop players
	level thread adjust_placed_weapons();

	// MikeD( 5/20/2008 ): Check to make sure splitscreen fog is setup
	if( !IsDefined( level.splitscreen_fog ) )
	{
		set_splitscreen_fog(); 
	}
	
	level notify( "load main complete" ); 
	
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: main() - COMPLETE\n" ); 
	}
	#/

println( "_LOAD END TIME = " + GetTime() );
}

onFirstPlayerReady()
{
	level waittill( "first_player_ready", player ); 

	// Do various things on triggers( these require there to be a player )
	array_thread( GetEntArray( "ambient_volume", "targetname" ), maps\_ambient::ambientVolume ); 
	array_thread( GetEntArray( "ambient_package", "targetname" ), maps\_ambientpackage::ambientPackageTrigger ); 

	// put any calls here that you want to happen when the FIRST player connects to the game
	println( "*********************First player connected to game." ); 
}

onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player ); 

		// do not redefine the .a variable if there already is one
		if( !IsDefined( player.a ) )
		{
			player.a = SpawnStruct(); 
		}
		
		player thread animscripts\init::onPlayerConnect(); 
		player thread onPlayerSpawned(); 
		player thread onPlayerDisconnect(); 

		// if we are in splitscreen then turn the water off to 
		// help the frame rate
		if( IsSplitScreen() )
		{
			SetDvar( "r_watersim", false ); 
		}
	}
}

onPlayerDisconnect()
{
	self waittill( "disconnect" ); 
	
	// if we are in dropping out of splitscreen then turn 
	// the water back on
	if( IsSplitScreen() )
	{
		SetDvar( "r_watersim", true ); 
	}
}

// CODE_MOD
// moved most of the player initialization functionality out of the main() function
// into player_init() so we can call it every spawn.  Nothing should be in here
// that you dont want to happen every spawn.
onPlayerSpawned()
{
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: onPlayerSpawned()\n" ); 
	}
	#/
	
	self endon( "disconnect" ); 
	
	for( ;; )
	{
		// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
		/#
		if( GetDebugDvar( "replay_debug" ) == "1" )
		{
			println( "File: _load.gsc. Function: onPlayerSpawned() - INNER LOOP START\n" ); 
		
			println( "File: _load.gsc. Function: onPlayerSpawned() - INNER LOOP START WAIT\n" ); 
		}
		#/
		
		self waittill( "spawned_player" ); 

		self.maxhealth = 100; 
		self.attackeraccuracy = 1; 
		
		self.pers["class"] = "closequarters"; 
		
		println( "player health: "+self.health ); 
	
		// MikeD: Stop all of the extra stuff, if createFX is enabled.
		if( level.createFX_enabled )
		{
			continue; 
		}
	
		self SetThreatBiasGroup( "allies" ); 
	
		self notify( "noHealthOverlay" ); 
		
		// SCRIPTER_MOD: JesseS( 6/4/200 ):  added start health for co-op health scaling
		self.starthealth = self.maxhealth; 
			
		self.shellshocked = false; 
		self.inWater = false; 
	
		// make sure any existing attachments have been removed		
		self DetachAll(); 

		self maps\_loadout::give_model( self.pers["class"] ); 
		maps\_loadout::give_loadout( true );
	
		// SCRIPTER_MOD: SRS 5/3/2008: to support _weather
		if( IsDefined( level.playerWeatherStarted ) && level.playerWeatherStarted )
		{
			self thread maps\_weather::player_weather_loop(); 
		}

		self maps\_art::setdefaultdepthoffield(); 

		if( !IsDefined( self.player_inited ) || !self.player_inited )
		{
			self maps\_friendlyfire::player_init(); 

			// SCRIPTER_MOD: JesseS( 4/12/2008 ): Per player init
			if( GetDvar( "arcademode" ) == "1" )
			{
				self thread maps\_arcademode::player_init(); 
			}

			// CODER_MOD - JamesS added self to player_death_detection
			self thread player_death_detection(); 
			self thread flashMonitor(); 
			self thread shock_ondeath(); 
			self thread shock_onpain(); 

			self thread maps\_quotes::main(); 

			// handles satchels/claymores with special script
			self thread maps\_detonategrenades::watchGrenadeUsage();

			self thread playerDamageRumble(); 
			self thread maps\_gameskill::playerHealthRegen();
			self thread maps\_colors::player_init_color_grouping();

			self maps\_laststand::revive_hud_create();

			self thread maps\_cheat::player_init(); 

			wait( 0.05 );
			self.player_inited = true;
		}
	}
}

set_early_level()
{
	level.early_level = []; 
	level.early_level["training"] 	 = false; 
	level.early_level["mak"] 		 = true; 
	level.early_level["pel1"] 		 = false; 
	level.early_level["pel1a"] 		 = false; 
	level.early_level["pel1b"] 		 = false; 
	level.early_level["pel2"] 		 = false; 
	level.early_level["pby_fly"] 	 = false; 
	level.early_level["hol1"] 		 = false; 
	level.early_level["hol2"] 		 = false; 
	level.early_level["hol3"] 		 = false; 
	level.early_level["ber1"] 		 = false; 
	level.early_level["ber2"] 		 = false; 
	level.early_level["ber3"] 		 = false; 
	level.early_level["ber3b"] 		 = false; 
	level.early_level["see1"] 		 = false; 
	level.early_level["oki1"] 		 = false; 
	level.early_level["oki2"] 		 = false; 
	level.early_level["oki3"] 		 = false; 
}

setup_simple_primary_lights()
{
	flickering_lights = GetEntArray( "generic_flickering", "targetname" ); 	
	pulsing_lights = GetEntArray( "generic_pulsing", "targetname" ); 
	double_strobe = GetEntArray( "generic_double_strobe", "targetname" ); 
	fire_flickers = GetEntArray( "fire_flicker", "targetname" ); 	
	
	array_thread( flickering_lights, maps\_lights::generic_flickering ); 
	array_thread( pulsing_lights, maps\_lights::generic_pulsing ); 
	array_thread( double_strobe, maps\_lights::generic_double_strobe ); 
	array_thread( fire_flickers, maps\_lights::fire_flicker );  
}


weapon_ammo()
{
	ents = GetEntArray(); 
	for( i = 0; i < ents.size; i ++ )
	{
		if( ( IsDefined( ents[i].classname ) ) &&( GetSubStr( ents[i].classname, 0, 7 ) == "weapon_" ) )
		{
			weap = ents[i]; 
			change_ammo = false; 
			clip = undefined; 
			extra = undefined; 
				
			if( IsDefined( weap.script_ammo_clip ) )
			{
				clip = weap.script_ammo_clip; 
				change_ammo = true; 
			}

			if( IsDefined( weap.script_ammo_extra ) )
			{
				extra = weap.script_ammo_extra; 
				change_ammo = true; 
			}
			
			if( change_ammo )
			{
				if( !IsDefined( clip ) )
				{
					assertmsg( "weapon: " + weap.classname + " " + weap.origin + " sets script_ammo_extra but not script_ammo_clip" ); 
				}

				if( !IsDefined( extra ) )
				{
					assertmsg( "weapon: " + weap.classname + " " + weap.origin + " sets script_ammo_clip but not script_ammo_extra" ); 
				}
				weap ItemWeaponSetAmmo( clip, extra ); 
				
			}
		}
	}
}

trigger_group()
{
	self thread trigger_group_remove(); 

	level endon( "trigger_group_" + self.script_trigger_group ); 
	self waittill( "trigger" ); 
	level notify( "trigger_group_" + self.script_trigger_group, self ); 
}

trigger_group_remove()
{
	level waittill( "trigger_group_" + self.script_trigger_group, trigger ); 
	if( self != trigger )
	{
		self Delete(); 
	}
}

exploder_load( trigger )
{
	level endon( "killexplodertridgers"+trigger.script_exploder ); 
	trigger waittill( "trigger" ); 
	if( IsDefined( trigger.script_chance ) && RandomFloat( 1 )>trigger.script_chance )
	{
		if( IsDefined( trigger.script_delay ) )
		{
			wait( trigger.script_delay ); 
		}
		else
		{
			wait( 4 ); 
		}

		level thread exploder_load( trigger ); 
		return; 
	}

	exploder( trigger.script_exploder ); 
	level notify( "killexplodertridgers"+trigger.script_exploder ); 
}


//usedAnimations()
//{
//	SetDvar( "usedanim", "" ); 
//	while( 1 )
//	{
//		if( GetDvar( "usedanim" ) == "" )
//		{
//			wait( 2 ); 
//			continue; 
//		}
//
//		animname = GetDvar( "usedanim" ); 
//		SetDvar( "usedanim", "" ); 
//
//		if( !IsDefined( level.completedAnims[animname] ) )
//		{
//			println( "^d---- No anims for ", animname, "^d -----------" ); 
//			continue; 
//		}
//
//		println( "^d----Used animations for ", animname, "^d: ", level.completedAnims[animname].size, "^d -----------" ); 
//		for( i = 0; i < level.completedAnims[animname].size; i++ )
//		{
//			println( level.completedAnims[animname][i] ); 
//		}
//	}
//}


badplace_think( badplace )
{
	if( !IsDefined( level.badPlaces ) )
	{
		level.badPlaces = 0; 
	}
		
	level.badPlaces++; 		
	Badplace_Cylinder( "badplace" + level.badPlaces, -1, badplace.origin, badplace.radius, 1024 ); 
}


setupExploders()
{
	level.exploders = []; 
	
	// Hide exploder models.
	ents = GetEntArray( "script_brushmodel", "classname" ); 
	smodels = GetEntArray( "script_model", "classname" ); 
	for( i = 0; i < smodels.size; i++ )
	{
		ents[ents.size] = smodels[i]; 
	}

	for( i = 0; i < ents.size; i++ )
	{
		if( IsDefined( ents[i].script_prefab_exploder ) )
		{
			ents[i].script_exploder = ents[i].script_prefab_exploder; 
		}

		if( IsDefined( ents[i].script_exploder ) )
		{
			if( ents[i].script_exploder < 10000 )
			{
				level.exploders[ents[i].script_exploder] = true;  // nate. I wanted a list
			}

			if( ( ents[i].model == "fx" ) &&( ( !IsDefined( ents[i].targetname ) ) ||( ents[i].targetname != "exploderchunk" ) ) )
			{
				ents[i] Hide(); 
			}
			else if( ( IsDefined( ents[i].targetname ) ) &&( ents[i].targetname == "exploder" ) )
			{
				ents[i] Hide(); 
				ents[i] NotSolid(); 
				if( IsDefined( ents[i].script_disconnectpaths ) )
					ents[i] ConnectPaths(); 
			}
			else if( ( IsDefined( ents[i].targetname ) ) &&( ents[i].targetname == "exploderchunk" ) )
			{
				ents[i] Hide(); 
				ents[i] NotSolid(); 
				if( IsDefined( ents[i].spawnflags ) &&( ents[i].spawnflags & 1 ) )
				{
					ents[i] ConnectPaths(); 
				}
			}
		}
	}

	script_exploders = []; 

	potentialExploders = GetEntArray( "script_brushmodel", "classname" ); 
	for( i = 0; i < potentialExploders.size; i++ )
	{
		if( IsDefined( potentialExploders[i].script_prefab_exploder ) )
		{
			potentialExploders[i].script_exploder = potentialExploders[i].script_prefab_exploder; 
		}
			
		if( IsDefined( potentialExploders[i].script_exploder ) )
		{
			script_exploders[script_exploders.size] = potentialExploders[i]; 
		}
	}

	println("Server : Potential exploders from brushmodels " + potentialExploders.size);

	potentialExploders = GetEntArray( "script_model", "classname" ); 
	for( i = 0; i < potentialExploders.size; i++ )
	{
		if( IsDefined( potentialExploders[i].script_prefab_exploder ) )
		{
			potentialExploders[i].script_exploder = potentialExploders[i].script_prefab_exploder; 
		}

		if( IsDefined( potentialExploders[i].script_exploder ) )
		{
			script_exploders[script_exploders.size] = potentialExploders[i]; 
		}
	}

	println("Server : Potential exploders from script_model " + potentialExploders.size);

	potentialExploders = GetEntArray( "item_health", "classname" ); 
	for( i = 0; i < potentialExploders.size; i++ )
	{
		if( IsDefined( potentialExploders[i].script_prefab_exploder ) )
		{
			potentialExploders[i].script_exploder = potentialExploders[i].script_prefab_exploder; 
		}

		if( IsDefined( potentialExploders[i].script_exploder ) )
		{
			script_exploders[script_exploders.size] = potentialExploders[i]; 
		}
	}
	
	println("Server : Potential exploders from item_health " + potentialExploders.size);

	
	if( !IsDefined( level.createFXent ) )
	{
		level.createFXent = []; 
	}
	
	acceptableTargetnames = []; 
	acceptableTargetnames["exploderchunk visible"] = true; 
	acceptableTargetnames["exploderchunk"] = true; 
	acceptableTargetnames["exploder"] = true; 
	
	exploderId = 1;
	
	for( i = 0; i < script_exploders.size; i++ )
	{
		exploder = script_exploders[i]; 
		
		ent = createExploder( exploder.script_fxid ); 
		ent.v = []; 
		ent.v["origin"] = exploder.origin; 
		ent.v["angles"] = exploder.angles; 
		ent.v["delay"] = exploder.script_delay; 
		ent.v["firefx"] = exploder.script_firefx; 
		ent.v["firefxdelay"] = exploder.script_firefxdelay; 
		ent.v["firefxsound"] = exploder.script_firefxsound; 
		ent.v["firefxtimeout"] = exploder.script_firefxtimeout; 
		ent.v["trailfx"] = exploder.script_trailfx; 
		ent.v["trailfxtag"] = exploder.script_trailfxtag; 
		ent.v["trailfxdelay"] = exploder.script_trailfxdelay; 
		ent.v["trailfxsound"] = exploder.script_trailfxsound; 
		ent.v["trailfxtimeout"] = exploder.script_firefxtimeout; 
		ent.v["earthquake"] = exploder.script_earthquake; 
		ent.v["rumble"] = exploder.script_rumble; 
		ent.v["damage"] = exploder.script_damage; 
		ent.v["damage_radius"] = exploder.script_radius; 
		ent.v["repeat"] = exploder.script_repeat; 
		ent.v["delay_min"] = exploder.script_delay_min; 
		ent.v["delay_max"] = exploder.script_delay_max; 
		ent.v["target"] = exploder.target; 
		ent.v["ender"] = exploder.script_ender; 
		ent.v["physics"] = exploder.script_physics; 
		ent.v["type"] = "exploder"; 
		ent.v["exploder_server"] = exploder.script_exploder_server;
//		ent.v["worldfx"] = true; 

		if( !IsDefined( exploder.script_fxid ) )
		{
			ent.v["fxid"] = "No FX"; 
		}
		else
		{
			ent.v["fxid"] = exploder.script_fxid; 
		}
		ent.v["exploder"] = exploder.script_exploder; 
		assertex( IsDefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" ); 

		if( !IsDefined( ent.v["delay"] ) )
		{
			ent.v["delay"] = 0; 
		}

		// MikeD( 4/14/2008 ): Attempt to use the fxid as the sound reference, this way Sound can add sounds to anything
		// without the scripter needing to modify the map
		if( IsDefined( exploder.script_sound ) )
		{
			ent.v["soundalias"] = exploder.script_sound; 
		}
		else if( ent.v["fxid"] != "No FX"  )
		{
			if( IsDefined( level.scr_sound ) && IsDefined( level.scr_sound[ent.v["fxid"]] ) )
			{
				ent.v["soundalias"] = level.scr_sound[ent.v["fxid"]]; 
			}
		}		
					
		exploder_id_set = false;
					
		if( IsDefined( exploder.target ) )
		{

							
			temp_ent = GetEnt( ent.v["target"], "targetname" ); 
			if( IsDefined( temp_ent ) )
			{
				exploder_id_set = true;
				temp_ent setexploderid(exploderId);
				exploderId++;

				org = temp_ent.origin; 
				temp_ent transmittargetname();	// transmit target name to client...
			}
			else
			{
				temp_ent = GetStruct( ent.v["target"], "targetname" ); 
				org = temp_ent.origin; 
				exploderId++;
			}

			ent.v["angles"] = VectorToAngles( org - ent.v["origin"] ); 
//			forward = AnglesToForward( angles ); 
//			up = AnglesToUp( angles ); 
		}
			
		// this basically determines if its a brush/model exploder or not
		if( exploder.classname == "script_brushmodel" || IsDefined( exploder.model ) )
		{
			if(exploder_id_set == false)
			{
				exploder setexploderid(exploderId);
				
				exploderId++;			
				exploder_id_set = true;
			}
			
			ent.model = exploder; 
			ent.model.disconnect_paths = exploder.script_disconnectpaths; 
		}
		
		if( IsDefined( exploder.targetname ) && IsDefined( acceptableTargetnames[exploder.targetname] ) )
		{
			ent.v["exploder_type"] = exploder.targetname; 
		}
		else
		{
			ent.v["exploder_type"] = "normal"; 
		}
		
		ent maps\_createfx::post_entity_creation_function(); 
	}
	
	for(i = 0; i < level.createFXent.size;i ++ )
	{
		ent = level.createFXent[i];
		
		if(ent.v["type"] != "exploder")
			continue;
			
		ent.v["exploder_id"] = getExploderId( ent );
		
	}
	
	reportExploderIds();
	
}

// SCRIPTER_MOD
// MikeD( 3/15/2007 ): This function does not appear to be called anywhere!
nearAIRushesPlayer()
{
	if( IsAlive( level.enemySeekingPlayer ) )
	{
		return; 
	}

	enemy = get_closest_ai( self.origin, "axis" ); 

	if( !IsDefined( enemy ) )
	{
		return; 
	}

	if( Distance( enemy.origin, self.origin ) > 400 )
	{
		return; 
	}
		
	level.enemySeekingPlayer = enemy; 
	enemy SetGoalEntity( self ); 
	enemy.goalradius = 512; 	
	
}
		
		
playerDamageRumble()
{
	while( true )
	{
		self waittill( "damage", amount ); 

		if( IsDefined( self.specialDamage ) )
		{
			continue; 
		}
		
		self PlayRumbleOnEntity( "damage_heavy" ); 		
	}
}

map_is_early_in_the_game()
{
	/#
	if( IsDefined( level.testmap ) )
	{
		return true; 
	}
	#/
	
	/#
	if( !IsDefined( level.early_level[level.script] ) )
	{
		level.early_level[level.script] = false; 
	}
	#/
	
	return level.early_level[level.script]; 
}

player_throwgrenade_timer()
{
	self endon( "death" ); 
	self endon("disconnect");
	
	self.lastgrenadetime = 0; 
	while( 1 )
	{
		while( ! self IsThroWingGrenade() )
		{
			wait( .05 ); 
		}
		self.lastgrenadetime = GetTime(); 
		while( self IsThroWingGrenade() )
		{
			wait( .05 ); 
		}
	}
}

player_special_death_hint()
{
	self endon( "disconnect" ); 

	self thread player_throwgrenade_timer(); // this thread used in coop also

	if( isSplitScreen() || coopGame() )
	{
		return;
	}

	if( IsAlive( self ) )
	{
		//thread maps\_quotes::setDeadQuote(); 
	}

	self waittill( "death", attacker, cause, weaponName ); 
	
	if( cause != "MOD_GRENADE" && cause != "MOD_GRENADE_SPLASH" && cause != "MOD_SUICIDE" && cause != "MOD_EXPLOSIVE" && cause != "MOD_PROJECTILE" && cause != "MOD_PROJECTILE_SPLASH" )
	{
		return; 
	}
		
	if( level.gameskill >= 2 )
	{
		// less death hinting on hard / fu
		if( !map_is_early_in_the_game() )
		{
			return; 
		}
	}

	if( cause == "MOD_SUICIDE" && map_is_early_in_the_game() )
	{
		timeSinceThrown = GetTime() - self.lastgrenadetime;
		if( timeSinceThrown < 4100 || timeSinceThrown > 4300 )
		{
			return; //magic number copied from fraggrenade asset.
		}

		level notify( "new_quote_string" ); 
		self thread grenade_death_text_hudelement( &"SCRIPT_GRENADE_SUICIDE_LINE1", &"SCRIPT_GRENADE_SUICIDE_LINE2" ); 
		return; 
	}

	if( cause == "MOD_PROJECTILE" || cause == "MOD_PROJECTILE_SPLASH" )
	{
		if( IsDefined( attacker ) && attacker != self )
		{
			if( IsDefined( weaponName ) && weaponName == "panzerschrek" )
			{
				level notify( "new_quote_string" );
				SetDvar( "ui_deadquote", "@SCRIPT_PANZERSHREK_DEATH" ); 
				return; 
			}
			else if( attacker.classname == "script_vehicle" && IsDefined(attacker.vehicletype) && attacker maps\_vehicle::vehicle_is_tank( ) )
			{
				level notify( "new_quote_string" );
				SetDvar( "ui_deadquote", "@SCRIPT_TANKSHELL_DEATH" ); 
				return; 
			}
		}
	}
	
	if( cause == "MOD_EXPLOSIVE" )
	{
		if( IsDefined( attacker ) && IsDefined( attacker.car_explosion ) )
        {
			level notify( "new_quote_string" ); 
			// You know what would be cool? If people would PUT THE TEXT OF THE LOCALIZED STRING IN THE COMMENT!!!!!!
			// You were killed by an exploding vehicle. Vehicles on fire are likely to explode.
			SetDvar( "ui_deadquote", "@SCRIPT_EXPLODING_VEHICLE_DEATH" ); 
			thread special_death_indicator_hudelement( "hud_burningcaricon", 96, 96 ); 
			return; 
		}
		
		// check if the death was caused by a barrel
		// have to check time and location against the last explosion because the attacker isn't the
		// barrel because the ent that damaged the barrel is passed through as the attacker instead
		if( IsDefined( level.lastExplodingBarrel ) )
		{
			// killed the same frame a barrel exploded
			if( GetTime() != level.lastExplodingBarrel["time"] )
				return; 
			
			// within the blast radius of the barrel that exploded
			d = Distance( self.origin, level.lastExplodingBarrel["origin"] ); 
			if( d > 350 )
				return; 
			
			// must have been killed by that barrel
			level notify( "new_quote_string" ); 
			// You were killed by an exploding barrel. Red barrels will explode when shot.
			SetDvar( "ui_deadquote", "@SCRIPT_EXPLODING_BARREL_DEATH" ); 
			thread special_death_indicator_hudelement( "hud_burningbarrelicon", 64, 64 ); 
			return; 
		}
		
		return; 
	}
	
	if( cause == "MOD_GRENADE" || cause == "MOD_GRENADE_SPLASH" )
	{
		if( IsDefined( weaponName ) && !IsWeaponDetonationTimed( weaponName ) )
		{
			return; 
		}

		level notify( "new_quote_string" ); 
		// Would putting the content of the string here be so hard?
		SetDvar( "ui_deadquote", "@SCRIPT_GRENADE_DEATH" ); 
		thread grenade_death_indicator_hudelement(); 
		return; 
	}
}

grenade_death_text_hudelement( textLine1, textLine2 )
{
	self.failingMission = true; 
	
	SetDvar( "ui_deadquote", "" ); 

	wait( 1.5 ); 

	fontElem = NewHudElem(); 
	fontElem.elemType = "font"; 
	fontElem.font = "default"; 
	fontElem.fontscale = 1.5; 
	fontElem.x = 0; 
	fontElem.y = -30; 
	fontElem.alignX = "center"; 
	fontElem.alignY = "middle"; 
	fontElem.horzAlign = "center"; 
	fontElem.vertAlign = "middle"; 
	fontElem SetText( textLine1 ); 
	fontElem.foreground = true; 
	fontElem.alpha = 0; 
	fontElem FadeOverTime( 1 ); 
	fontElem.alpha = 1; 

	if( IsDefined( textLine2 ) )
	{
		fontElem = NewHudElem(); 
		fontElem.elemType = "font"; 
		fontElem.font = "default"; 
		fontElem.fontscale = 1.5; 
		fontElem.x = 0; 
		fontElem.y = -25 + level.fontHeight * fontElem.fontscale; 
		fontElem.alignX = "center"; 
		fontElem.alignY = "middle"; 
		fontElem.horzAlign = "center"; 
		fontElem.vertAlign = "middle"; 
		fontElem SetText( textLine2 ); 
		fontElem.foreground = true; 
		fontElem.alpha = 0; 
		fontElem FadeOverTime( 1 ); 
		fontElem.alpha = 1; 
	}
}

grenade_death_indicator_hudelement()
{
	self endon( "disconnect" ); 
	wait( 1.5 ); 
	overlayIcon = NewClientHudElem( self ); 
	overlayIcon.x = 0; 
	overlayIcon.y = 68; 
	overlayIcon SetShader( "hud_grenadeicon", 50, 50 ); 
	overlayIcon.alignX = "center"; 
	overlayIcon.alignY = "middle"; 
	overlayIcon.horzAlign = "center"; 
	overlayIcon.vertAlign = "middle"; 
	overlayIcon.foreground = true; 
	overlayIcon.alpha = 0; 
	overlayIcon FadeOverTime( 1 ); 
	overlayIcon.alpha = 1; 

	overlayPointer = NewClientHudElem( self ); 
	overlayPointer.x = 0; 
	overlayPointer.y = 25; 
	overlayPointer SetShader( "hud_grenadepointer", 50, 25 ); 
	overlayPointer.alignX = "center"; 
	overlayPointer.alignY = "middle"; 
	overlayPointer.horzAlign = "center"; 
	overlayPointer.vertAlign = "middle"; 
	overlayPointer.foreground = true; 
	overlayPointer.alpha = 0; 
	overlayPointer FadeOverTime( 1 ); 
	overlayPointer.alpha = 1; 
	
	self thread grenade_death_indicator_hudelement_cleanup( overlayIcon, overlayPointer ); 
}

// CODE_MOD
grenade_death_indicator_hudelement_cleanup( hudElemIcon, hudElemPointer )
{
	self endon( "disconnect" ); 
	self waittill( "spawned" ); 
		
	hudElemIcon Destroy(); 
	hudElemPointer Destroy(); 
}

special_death_indicator_hudelement( shader, iWidth, iHeight, fDelay )
{
	if( !IsDefined( fDelay ) )
	{
		fDelay = 1.5; 
	}

	wait( fDelay ); 
	overlay = NewClientHudElem( self ); 
	overlay.x = 0; 
	overlay.y = 40; 
	overlay SetShader( shader, iWidth, iHeight ); 
	overlay.alignX = "center"; 
	overlay.alignY = "middle"; 
	overlay.horzAlign = "center"; 
	overlay.vertAlign = "middle"; 
	overlay.foreground = true; 
	overlay.alpha = 0; 
	overlay FadeOverTime( 1 ); 
	overlay.alpha = 1; 

	self thread special_death_death_indicator_hudelement_cleanup( overlay ); 
}

special_death_death_indicator_hudelement_cleanup( overlay )
{
	self endon( "disconnect" ); 
	self waittill( "spawned" ); 
		
	overlay Destroy(); 
}



// SCRIPTER_MOD
// MikeD( 3/16/2007 ) TODO: Test this feature
triggered_playerseek( trig )
{
	groupNum = trig.script_triggered_playerseek; 
	trig waittill( "trigger" ); 
	
	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		if( !IsAlive( ai[i] ) )
		{
			continue; 
		}

		if( ( IsDefined( ai[i].script_triggered_playerseek ) ) &&( ai[i].script_triggered_playerseek == groupNum ) )
		{
			ai[i].goalradius = 800; 
			ai[i] SetGoalEntity( get_closest_player() ); 
			level thread maps\_spawner::delayed_player_seek_think( ai[i] ); 
		}
	}
}

// SCRIPTER_MOD: JesseS( 8/13/200 ):  added script_struct support
traverseThink()
{
	ent = GetEnt( self.target, "targetname" ); 
	
	if( IsDefined( ent ) )
	{
		self.traverse_height = ent.origin[2]; 
		ent Delete(); 			
	}
	else
	{
		struct = GetStruct( self.target, "targetname" ); 
		
		if( IsDefined( struct ) )
		{
			self.traverse_height = struct.origin[2]; 
		}
		else
		{
			assertmsg( "traverse node with targetname of 'traverse' needs to target a script_origin or script_struct to determine height! " ); 
		}
	}
}


/#
deprecatedTraverseThink()
{
	wait( .05 ); 
	println( "^1Warning: deprecated traverse used in this map somewhere around " + self.origin ); 
	if( GetDvarInt( "scr_traverse_debug" ) )
	{
		while( 1 )
		{
			print3d( self.origin, "deprecated traverse!" ); 
			wait( .05 ); 
		}
	}
}
#/

pianoDamageThink()
{
	org = self GetOrigin(); 
//	note = "piano_" + self.script_noteworthy; 
//	self SetHintString( &"SCRIPT_PLATFORM_PIANO" ); 
	note[0] = "large"; 
	note[1] = "small"; 
	for( ;; )
	{
		self waittill( "trigger" ); 
		thread play_sound_in_space( "bullet_" + random( note ) + "_piano", org ); 
	}
}

pianoThink()
{
	org = self GetOrigin(); 
	note = "piano_" + self.script_noteworthy; 
	self SetHintString( &"SCRIPT_PLATFORM_PIANO" ); 
	for( ;; )
	{
		self waittill( "trigger" ); 
		thread play_sound_in_space( note , org ); 
	}
}

// SCRIPTER_MOD
// MikeD( 3/16/2007 ) TODO: Test this feature
bcTrigger( trigger )
{
	realTrigger = undefined; 
	
	if( IsDefined( trigger.target ) )
	{
		targetEnts = GetEntArray( trigger.target, "targetname" ); 

		if( IsSubStr( targetEnts[0].classname, "trigger" ) )
		{
			realTrigger = targetEnts[0]; 
		}
	}
	
	if( IsDefined( realTrigger ) )
	{
		realTrigger waittill( "trigger", other ); 
	}
	else
	{
		trigger waittill( "trigger", other ); 
	}
	
	soldier = undefined; 
	
	if( IsDefined( realTrigger ) )
	{
		player_touching = get_player_touching( trigger ); 
		if( other.team == "axis" && IsDefined( player_touching ) )
		{
			soldier = get_closest_ai( player_touching GetOrigin(), "allies" ); 

			if( Distance( soldier.origin, player_touching GetOrigin() ) > 512 )
			{
				return; 
			}
		}
		else if( other.team == "allies" )
		{
			soldiers = GetAiArray( "axis" ); 
			
			for( index = 0; index < soldiers.size; index++ )
			{
				if( soldiers[index] IsTouching( trigger ) )
				{
					soldier = soldiers[index]; 
				}
			}
		}
	}
	else if( IsPlayer( other ) )
	{
		soldier = get_closest_ai( other GetOrigin(), "allies" ); 
		if( Distance( soldier.origin, other GetOrigin() ) > 512 )
		{
			return; 
		}
	}
	else
	{
		soldier = other; 
	}
	
	if( !IsDefined( soldier ) )
	{
		return; 
	}

	soldier custom_battlechatter( trigger.script_bctrigger ); 
}

// SCRIPTER_MOD
// MikeD( 3/16/2007 ) TODO: Test this feature
waterThink()
{
	assert( IsDefined( self.target ) ); 
	targeted = GetEnt( self.target, "targetname" ); 
	assert( IsDefined( targeted ) ); 
	waterHeight = targeted.origin[2]; 
	targeted = undefined; 
	
	level.depth_allow_prone = 8; 
	level.depth_allow_crouch = 33; 
	level.depth_allow_stand = 50; 
	
	//prof_begin( "water_stance_controller" ); 
	
	for( ;; )
	{
		wait( 0.05 ); 
		//restore all defaults
		players = get_players(); 
		for( i = 0; i < players.size; i++ )
		{
			if( players[i].inWater )
			{
				players[i] AllowProne( true ); 
				players[i] AllowCrouch( true ); 
				players[i] AllowStand( true ); 
				thread waterThink_rampSpeed( level.default_run_speed ); 
			}
		}
		
		//wait( until in water )
		self waittill( "trigger", other ); 

		if( !IsPlayer( other ) )
		{
			continue; 
		}

		while( 1 )
		{
			players = get_players(); 

			players_in_water_count = 0; 
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] IsTouching( self ) )
				{
					players_in_water_count++; 
					players[i].inWater = true; 
					playerOrg = players[i] GetOrigin(); 
					d = ( playerOrg[2] - waterHeight ); 
					if( d > 0 )
					{
						continue; 
					}
					
					//slow the players movement based on how deep it is
					newSpeed = Int( level.default_run_speed - abs( d * 5 ) ); 
					if( newSpeed < 50 )
					{
						newSpeed = 50; 
					}
					assert( newSpeed <= 190 ); 
					thread waterThink_rampSpeed( newSpeed ); 
					
					//controll the allowed stances in this water height
					if( abs( d ) > level.depth_allow_crouch )
					{
						players[i] AllowCrouch( false ); 
					}
					else
					{
						players[i] AllowCrouch( true ); 
					}
					
					if( abs( d ) > level.depth_allow_prone )
					{
						players[i] AllowProne( false ); 
					}
					else
					{
						players[i] AllowProne( true ); 
					}
				}
				else
				{
					if( players[i].inWater )
					{
						players[i].inWater = false; 
					}
				}
			}

			if( players_in_water_count == 0 )
			{
				break; 
			}

			wait( 0.5 ); 
		}

		wait( 0.05 ); 
	}
	
	prof_end( "water_stance_controller" ); 
}

waterThink_rampSpeed( newSpeed )
{
	level notify( "ramping_water_movement_speed" ); 
	level endon( "ramping_water_movement_speed" ); 

// SCRIPTER_MOD
// MikeD( 3/16/2007 ): This will not work since it change the GLOBAL g_speed... We're going to need to be able to change each player's speed if we want this!
// MikeD TODO: FIX THE PLAYER SPEED SO IT AFFECTS EACH PLAYER!
//	rampTime = 0.5; 
//	numFrames = Int( rampTime * 20 ); 
//	
//	currentSpeed = GetDvarInt( "g_speed" ); 
//	
//	qSlower = false; 
//	if( newSpeed < currentSpeed )
//		qSlower = true; 
//	
//	speedDifference = Int( abs( currentSpeed - newSpeed ) ); 
//	speedStepSize = Int( speedDifference / numFrames ); 
//	
//	for( i = 0 ; i < numFrames ; i++ )
//	{
//		currentSpeed = GetDvarInt( "g_speed" ); 
//		if( qSlower )
//			SetSavedDvar( "g_speed", ( currentSpeed - speedStepSize ) ); 
//		else
//			SetSavedDvar( "g_speed", ( currentSpeed + speedStepSize ) ); 
//		wait( 0.05 ); 
//	}
//	SetSavedDvar( "g_speed", newSpeed ); 
}



massNodeInitFunctions()
{
	nodes = GetAllNodes(); 

	thread maps\_mgturret::auto_mgTurretLink( nodes ); 
	thread maps\_mgturret::saw_mgTurretLink( nodes ); 
	thread maps\_colors::init_color_grouping( nodes ); 
}


/* 
**********

TRIGGER_UNLOCK

**********
*/ 

trigger_unlock( trigger )
{
	// trigger unlocks unlock another trigger. When that trigger is hit, all unlocked triggers relock
	// trigger_unlocks with the same script_noteworthy relock the same triggers
	
	noteworthy = "not_set"; 
	if( IsDefined( trigger.script_noteworthy ) )
	{
		noteworthy = trigger.script_noteworthy; 
	}
		
	target_triggers = GetEntArray( trigger.target, "targetname" ); 

	trigger thread trigger_unlock_death( trigger.target ); 

	for( ;; )
	{	
		array_thread( target_triggers, ::trigger_off ); 
		trigger waittill( "trigger" ); 
		array_thread( target_triggers, ::trigger_on ); 
		
		wait_for_an_unlocked_trigger( target_triggers, noteworthy ); 

		array_notify( target_triggers, "relock" ); 
	}
}

trigger_unlock_death( target )
{
	self waittill( "death" ); 
	target_triggers = GetEntArray( target, "targetname" ); 
	array_thread( target_triggers, ::trigger_off ); 
}

wait_for_an_unlocked_trigger( triggers, noteworthy )
{
	level endon( "unlocked_trigger_hit" + noteworthy ); 
	ent = SpawnStruct(); 
	for( i = 0; i < triggers.size; i++ )
	{
		triggers[i] thread report_trigger( ent, noteworthy ); 
	}
	ent waittill( "trigger" ); 
	level notify( "unlocked_trigger_hit" + noteworthy ); 
}

report_trigger( ent, noteworthy )
{
	self endon( "relock" ); 
	level endon( "unlocked_trigger_hit" + noteworthy ); 
	self waittill( "trigger" ); 
	ent notify( "trigger" ); 
}

/* 
**********

TRIGGER_LOOKAT

**********
*/ 

get_trigger_targs()
{
	triggers = []; 
	target_origin = undefined; // was self.origin
	if( IsDefined( self.target ) )
	{
		targets = GetEntArray( self.target, "targetname" ); 
		orgs = []; 
		for( i = 0; i < targets.size; i ++ )
		{
			if( targets[i].classname == "script_origin" )
			{
				orgs[orgs.size] = targets[i]; 
			}

			if( IsSubStr( targets[i].classname, "trigger" ) )
			{
				triggers[triggers.size] = targets[i]; 
			}
		}
		
		assertex( orgs.size < 2, "Trigger at " + self.origin + " targets multiple script origins" ); 
		if( orgs.size == 1 )
		{
			target_origin = orgs[0].origin; 
			orgs[0] Delete(); 
		}
	}
	
	assertex( IsDefined( target_origin ), self.targetname + " at " + self.origin + " has no target origin." ); 

	array = []; 
	array["triggers"] = triggers; 
	array["target_origin"] = target_origin; 
	return array; 
}

trigger_lookat( trigger )
{
	// ends when the flag is hit
	trigger_lookat_think( trigger, true ); 
}

trigger_looking( trigger )
	{
	// flag is only set while the thing is being looked at
	trigger_lookat_think( trigger, false ); 
	}
	
trigger_lookat_think( trigger, endOnFlag )
{
	dot = 0.78; 
	if( IsDefined( trigger.script_dot ) )
	{
		dot = trigger.script_dot; 
	}
		
	array = trigger get_trigger_targs(); 
	triggers = array["triggers"]; 
	target_origin = array["target_origin"]; 

	has_flag = IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy ); 
	flagName = undefined; 
	
	if( has_flag )
	{
		flagName = trigger get_trigger_flag(); 
		if( !IsDefined( level.flag[flagName] ) )
		{
			flag_init( flagName ); 
		}
	}
	else
	{
		if( !triggers.size )
		{
			assertex( IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy ), "Trigger_lookat at " + trigger.origin + " has no script_flag! The script_flag is used as a flag that gets set when the trigger is activated." ); 
		}
	}

	if( endOnFlag && has_flag )
	{
		level endon( flagName ); 
	}

	trigger endon( "death" ); 
	
	for( ;; )
	{
		if( has_flag )
		{
			flag_clear( flagName ); 
		}
	
		trigger waittill( "trigger", other ); 
	
		assertex( IsPlayer( other ), "trigger_lookat currently only supports looking from the player" ); 

		if( !IsPlayer( other ) )
		{
			continue; 
		}

		while( other IsTouching( trigger ) )
		{
			if( !SightTracePassed( other GetEye(), target_origin, false, undefined ) )
			{
				if( has_flag )
				{
					flag_clear( flagName ); 
				}
				wait( 0.5 ); 
				continue; 
			}
				
			normal = VectorNormalize( target_origin - other.origin ); 
		    player_angles = other GetPlayerAngles(); 
		    player_forward = AnglesToForward( player_angles ); 

	//		angles = VectorToAngles( target_origin - other.origin ); 
	//	    forward = AnglesToForward( angles ); 
	//		draw_arrow( other.origin, level.player.origin + vectorscale( forward, 150 ), ( 1, 0.5, 0 ) ); 
	//		draw_arrow( other.origin, level.player.origin + vectorscale( player_forward, 150 ), ( 0, 0.5, 1 ) ); 
	
			dot = VectorDot( player_forward, normal ); 
			if( dot >= 0.78 )
			{
				if( has_flag )
				{
					flag_set( flagName ); 
				}

				// notify targetted triggers as well
				array_thread( triggers, ::send_notify, "trigger" ); 

				if( endOnFlag )
				{
					return; 
				}

				wait( 2 ); 
			}
			else
			{
				if( has_flag )
				{
					flag_clear( flagName ); 
				}
			}
		
			wait( 0.5 ); 
		}
	}
}

/* 
* * * * * * * * * * 

TRIGGER_CANSEE

* * * * * * * * * * 
*/ 

trigger_CanSee( trigger )
{
	triggers = []; 
	target_origin = undefined; // was trigger.origin

	array = trigger get_trigger_targs(); 
	triggers = array["triggers"]; 
	target_origin = array["target_origin"]; 

	has_flag = IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy ); 
	flagName = undefined; 
	
	if( has_flag )
	{
		flagName = trigger get_trigger_flag(); 
		if( !IsDefined( level.flag[flagName] ) )
		{
			flag_init( flagName ); 
		}
	}
	else
	{
		if( !triggers.size )
		{
			assertex( IsDefined( trigger.script_flag ) || IsDefined( trigger.script_noteworthy ), "Trigger_cansee at " + trigger.origin + " has no script_flag! The script_flag is used as a flag that gets set when the trigger is activated." ); 
		}
	}
	
	trigger endon( "death" ); 
	
	range = 12; 
	offsets = []; 
	offsets[offsets.size] = ( 0, 0, 0 ); 
	offsets[offsets.size] = ( range, 0, 0 ); 
	offsets[offsets.size] = ( range * -1, 0, 0 ); 
	offsets[offsets.size] = ( 0, range, 0 ); 
	offsets[offsets.size] = ( 0, range * -1, 0 ); 
	offsets[offsets.size] = ( 0, 0, range ); 
	
	for( ;; )
	{
		if( has_flag )
		{
			flag_clear( flagName ); 
		}
			
		trigger waittill( "trigger", other ); 
		assertex( IsPlayer( other ), "trigger_cansee currently only supports looking from the player" ); 
		
		while( other IsTouching( trigger ) )
		{
			if( !( other cantraceto( target_origin, offsets ) ) )
			{
				if( has_flag )
				{
					flag_clear( flagName ); 
				}
				wait( 0.1 ); 
				continue; 
			}
			
			if( has_flag )
			{
				flag_set( flagName ); 
			}

			// notify targetted triggers as well
			array_thread( triggers, ::send_notify, "trigger" ); 
			wait( 0.5 ); 
		}
	}
}

cantraceto( target_origin, offsets )
{
	for( i = 0; i < offsets.size; i++ )
	{
		if( SightTracePassed( self GetEye(), target_origin + offsets[i], true, self ) )
		{
			return true; 
		}
	}
	return false; 
}


indicate_start( start )
{
	hudelem = NewHudElem(); 
	hudelem.alignX = "left"; 
	hudelem.alignY = "middle"; 
	hudelem.x = 70; 
	hudelem.y = 400; 
//	hudelem.label = "Loading from start: " + start; 
	hudelem.label = start; 
	hudelem.alpha = 0; 
	hudelem.fontScale = 3; 
	wait( 1 ); 
	hudelem FadeOverTime( 1 ); 
	hudelem.alpha = 1; 
	wait( 5 ); 
	hudelem FadeOverTime( 1 ); 
	hudelem.alpha = 0; 
	wait( 1 ); 
	hudelem Destroy(); 
}

/* 
 ============= 
///ScriptDocBegin
"Name: trigger_notify()"
"Summary: Sends out a level notify of the trigger's script_notify once triggered"
"Module: Trigger"
"CallOn: "
"Example: trigger thread trigger_notify(); "
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
*/ 
trigger_notify( trigger, msg )
{
	trigger endon( "death" ); 

	trigger waittill( "trigger", other ); 
	level notify( msg, other ); 
}

handle_starts()
{
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: handle_starts()\n" ); 
	}
	#/
	
	if( !IsDefined( level.start_functions ) )
	{
		level.start_functions = []; 
	}

	assertex( GetDvar( "jumpto" ) == "", "Use the START dvar instead of JUMPTO" ); 

	start = Tolower( GetDvar( "start" ) ); 

	// find the start that matches the one the dvar is set to, and execute it
	dvars = GetArrayKeys( level.start_functions ); 

	for( i = 0; i < dvars.size; i++ )
	{
		if( start == dvars[i] )
		{
			level.start_point = start; 
			break; 
		}
	}

	if( !IsDefined( level.start_point ) )
	{
		level.start_point = "default"; 
	}
	
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: handle_starts() - WAITING FOR FIRST PLAYER\n" ); 
	}
	#/
	
	wait_for_first_player(); 
	
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: handle_starts() - FOUND FIRST PLAYER\n" ); 
	}
	#/
	
	thread start_menu(); 
	
	// CODER_MOD - JamesS - wait( here for a frame so that things will get setup properly before running the start
	// This is currently needed because ONLINE is not defined and wait_for_first_player returns immediately
	//wait 0.05 ); // MikeD: online should be enabled now.
	
	if( level.start_point != "default" )
	{
		thread indicate_start( level.start_loc_string[level.start_point] ); 
		thread[[level.start_functions[level.start_point]]](); 
		return; 
	}
	
	if( IsDefined( level.default_start ) )
	{
		thread[[level.default_start]](); 
	}

	string = get_string_for_starts( dvars ); 
	SetDvar( "start", string ); 
	
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: handle_starts() - COMPLETE\n" ); 
	}
	#/
	
}

get_string_for_starts( dvars )
{
	string = " ** No starts have been set up for this map with maps\_utility::add_start()."; 
	if( dvars.size )
	{
		string = " ** "; 
		for( i = dvars.size - 1; i >= 0; i-- )
		{
			string = string + dvars[i] + " "; 
		}
	}
	
	SetDvar( "start", string ); 
	return string; 
}

devhelp_hudElements( hudarray, alpha )
{
	for( i = 0; i < hudarray.size; i++ )
	{
		for( p = 0; p < 2; p++ )
		{
			hudarray[i][p].alpha = alpha; 
		}
	}

}


create_start( start, index )
{
	hudelem = NewHudElem(); 
	hudelem.alignX = "left"; 
	hudelem.alignY = "middle"; 
	hudelem.x = 10; 
	hudelem.y = 80 + index * 20; 
	hudelem.label = start; 
	hudelem.alpha = 0; 

	hudelem.fontScale = 2; 
	hudelem FadeOverTime( 0.5 ); 
	hudelem.alpha = 1; 
	return hudelem; 
}

start_menu()
{
	level.start_loc_string["default"] = &"STARTS_DEFAULT"; 
	level.start_loc_string["cancel"] = &"STARTS_CANCEL"; 

	for( ;; )
	{
		if( GetDvarInt( "debug_start" ) )
		{
			SetDvar( "debug_start", 0 ); 
			SetSavedDvar( "hud_drawhud", 1 ); 
			display_starts(); 
		}
		else
		{
			level.display_starts_Pressed = false; 
		}
		wait( 0.05 ); 
	}
}

display_starts() 
{
	level.display_starts_Pressed = true; 
	dvars = GetArrayKeys( level.start_functions ); 
	if( dvars.size <= 0 )
	{
		return; 
	}
		
	dvars[dvars.size] = "default"; 
	dvars[dvars.size] = "cancel"; 
	
	title = create_start( &"STARTS_AVAILABLE_STARTS", -1 ); 
	title.color = ( 1, 1, 1 ); 
	elems = []; 
	
	//-- Glocke 2/28 - Only put starts with defined string values into debug menu
	level.start_loc_string = array_remove( level.start_loc_string, &"MISSING_LOC_STRING", true ); 
	dvars = GetArrayKeys( level.start_loc_string ); 
	
	for( i = 0; i < dvars.size; i++ )
	{
		elems[elems.size] = create_start( level.start_loc_string[dvars[i]] , dvars.size - i ); 
	}
	
	selected = dvars.size - 1; 
	
	up_pressed = false; 
	down_pressed = false; 
	
	players = get_players(); 
	for( ;; )
	{	
		// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
		/#
		if( GetDebugDvar( "replay_debug" ) == "1" )
		{
			println( "File: _load.gsc. Function: display_starts() - INNER LOOP START\n" ); 
		}
		#/
	
		if( !( players[0] ButtonPressed( "F10" ) ) )
		{
			level.display_starts_Pressed = false; 
		}

		
		for( i = 0; i < dvars.size; i++ )
		{
			elems[i].color = ( 0.7, 0.7, 0.7 ); 
		}
	
		elems[selected].color = ( 1, 1, 0 ); 

		if( !up_pressed )
		{
			if( players[0] ButtonPressed( "UPARROW" ) || players[0] ButtonPressed( "DPAD_UP" ) || players[0] ButtonPressed( "APAD_UP" ) )
			{
				up_pressed = true; 
				selected++; 
			}
		}
		else
		{
			if( !players[0] ButtonPressed( "UPARROW" ) && !players[0] ButtonPressed( "DPAD_UP" ) && !players[0] ButtonPressed( "APAD_UP" ) )
			{
				up_pressed = false; 
			}
		}
		

		if( !down_pressed )
		{
			if( players[0] ButtonPressed( "DOWNARROW" ) || players[0] ButtonPressed( "DPAD_DOWN" ) || players[0] ButtonPressed( "APAD_DOWN" ) )
			{
				down_pressed = true; 
				selected--; 
			}
		}
		else
		{
			if( !players[0] ButtonPressed( "DOWNARROW" ) && !players[0] ButtonPressed( "DPAD_DOWN" ) && !players[0] ButtonPressed( "APAD_DOWN" ) )
			{
				down_pressed = false; 
			}
		}
		
		if( selected < 0 )
		{
			selected = dvars.size - 1; 
		}
			
		if( selected >= dvars.size )
		{
			selected = 0; 
		}
		
		
		if( players[0] ButtonPressed( "kp_enter" ) || players[0] ButtonPressed( "BUTTON_A" ) || players[0] ButtonPressed( "enter" ) )
		{
			if( dvars[selected] == "cancel" )
			{
				title Destroy(); 
				for( i = 0; i < elems.size; i++ )
				{
					elems[i] Destroy(); 
				}
				break; 
			}
			
			SetDvar( "start", dvars[selected] ); 
			ChangeLevel( level.script, false ); 
		}
		
		// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
		/#
		if( GetDebugDvar( "replay_debug" ) == "1" )
		{
			println( "File: _load.gsc. Function: display_starts() - INNER LOOP END\n" ); 
		}
		#/
		wait( 0.05 ); 
	}

}

devhelp()
{
	/#
	helptext = []; 
	helptext[helptext.size] = "P: pause                                                       "; 
	helptext[helptext.size] = "T: super speed                                                 "; 
	helptext[helptext.size] = ".: fullbright                                                  "; 
	helptext[helptext.size] = "U: toggle normal maps                                          "; 
	helptext[helptext.size] = "Y: print a line of text, useful for putting it in a screenshot "; 
	helptext[helptext.size] = "H: toggle detailed ent info                                    "; 
	helptext[helptext.size] = "g: toggle simplified ent info                                  "; 
	helptext[helptext.size] = ", : show the triangle outlines                                  "; 
	helptext[helptext.size] = "-: Back 10 seconds                                             "; 
	helptext[helptext.size] = "6: Replay mark                                                 "; 
	helptext[helptext.size] = "7: Replay goto                                                 "; 
	helptext[helptext.size] = "8: Replay live                                                 "; 
	helptext[helptext.size] = "0: Replay back 3 seconds                                       "; 
	helptext[helptext.size] = "[: Replay restart                                              "; 
	helptext[helptext.size] = "\: map_restart                                                 "; 
	helptext[helptext.size] = "U: draw material name                                          "; 
	helptext[helptext.size] = "J: display tri counts                                          "; 
	helptext[helptext.size] = "B: cg_ufo                                                      "; 
	helptext[helptext.size] = "N: ufo                                                         "; 
	helptext[helptext.size] = "C: god                                                         ";                                      
	helptext[helptext.size] = "K: Show ai nodes                                               ";                                      
	helptext[helptext.size] = "L: Show ai node connections                                    ";                                      
	helptext[helptext.size] = "Semicolon: Show ai pathing                                     ";                                      

	
	strOffsetX = []; 
	strOffsetY = []; 
	strOffsetX[0] = 0; 
	strOffsetY[0] = 0; 
	strOffsetX[1] = 1; 
	strOffsetY[1] = 1; 
	strOffsetX[2] = -2; 
	strOffsetY[2] = 1; 
	strOffsetX[3] = 1; 
	strOffsetY[3] = -1; 
	strOffsetX[4] = -2; 
	strOffsetY[4] = -1; 
	hudarray = []; 
	for( i = 0; i < helptext.size; i++ )
	{
		newStrArray = []; 
		for( p = 0; p < 2; p++ )
		{
			// setup instructional text
			newStr = NewDebugHudElem(); 
			newStr.alignX = "left"; 
			newStr.location = 0; 
			newStr.foreground = 1; 
			newStr.fontScale = 1.40; 
			newStr.sort = 20 - p; 
			newStr.alpha = 1; 
			newStr.x = 54 + strOffsetX[p]; 
			newStr.y = 80 + strOffsetY[p]+ i * 15; 
			newstr SetText( helptext[i] ); 
			if( p > 0 )
			{
				newStr.color = ( 0, 0, 0 ); 
			}
			
			newStrArray[newStrArray.size] = newStr; 
		}
		hudarray[hudarray.size] = newStrArray; 
	}
	
	devhelp_hudElements( hudarray , 0 ); 

	while( 1 )
	{
		// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
		if( GetDebugDvar( "replay_debug" ) == "1" )
		{
			println( "File: _load.gsc. Function: devhelp() - INNER LOOP START\n" ); 
		}
		
		update = false; 

		players = get_players(); 
		if( players.size > 0 && players[0] ButtonPressed( "F1" ) )
		{
			devhelp_hudElements( hudarray , 1 ); 
			while( players[0] ButtonPressed( "F1" ) )
			{
				wait( 0.05 ); 
			}
		}

		devhelp_hudElements( hudarray , 0 ); 
		
		// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
		if( GetDebugDvar( "replay_debug" ) == "1" )
		{
			println( "File: _load.gsc. Function: devhelp() - INNER LOOP END\n" ); 
		}
		
		wait( .05 ); 
	}
	#/
}

flag_set_player_trigger( trigger )
{
	flag = trigger get_trigger_flag(); 
	
	if( !IsDefined( level.flag[flag] ) )
	{
		flag_init( flag ); 
	}
	
	for( ;; )
	{
		trigger waittill( "trigger", other ); 

		if( !IsPlayer( other ) )
		{
			continue; 
		}

		self script_delay(); 
		flag_set( flag ); 
	}
}

flag_set_trigger( trigger )
{
	trigger endon( "death" ); 
	flag = trigger get_trigger_flag(); 
	
	if( !IsDefined( level.flag[flag] ) )
	{
		flag_init( flag ); 
	}
	
	for( ;; )
	{
		trigger waittill( "trigger" ); 
		self script_delay(); 
		flag_set( flag ); 
	}
}

flag_unset_trigger( trigger )
{
	flag = trigger get_trigger_flag(); 
	
	if( !IsDefined( level.flag[flag] ) )
	{
		flag_init( flag ); 
	}

	for( ;; )
	{
		trigger waittill( "trigger" ); 
		self script_delay(); 
		flag_clear( flag ); 
	}
}

eq_trigger( trigger )
{
	level.set_eq_func[true] = ::set_eq_on; 
	level.set_eq_func[false] = ::set_eq_off; 
	targ = GetEnt( trigger.target, "targetname" ); 
	for( ;; )
	{
		trigger waittill( "trigger" ); 
		ai = GetAiArray( "allies" ); 
		for( i = 0; i < ai.size; i++ )
		{
			ai[i][[level.set_eq_func[ai[i] IsTouching( targ )]]](); 
		}

		while( any_player_IsTouching( trigger ) )
		{
			wait( 0.05 ); 
		}

		ai = GetAiArray( "allies" ); 
		for( i = 0; i < ai.size; i++ )
		{
			ai[i][[level.set_eq_func[false]]](); 
		}
	}
	/*
	num = level.eq_trigger_num; 
	trigger.eq_num = num; 
	level.eq_trigger_num++; 
	waittillframeend; // let the ai get their eq_num table created
	waittillframeend; // let the ai get their eq_num table created
	level.eq_trigger_table[num] = []; 
	if( IsDefined( trigger.script_linkto ) )
	{
		tokens = Strtok( trigger.script_linkto, " " ); 
		for( i = 0; i < tokens.size; i++ )
		{
			target_trigger = GetEnt( tokens[i], "script_linkname" ); 
			// add the trigger num to the list of triggers this trigger hears 
			level.eq_trigger_table[num][level.eq_trigger_table[num].size] = target_trigger.eq_num; 		
		}
	}
	
	for( ;; )
	{
		trigger waittill( "trigger", other ); 
		
		// are we already registered with this trigger?
		if( other.eq_table[num] )
		{
			continue; 
		}
			
		other thread[[level.touched_eq_function[other.is_the_player]]]( num, trigger ); 
	}
	*/
}


player_ignores_triggers()
{
	self endon( "death" ); 
	self.ignoretriggers = true; 
	wait( 1 ); 
	self.ignoretriggers = false; 
}

get_trigger_eq_nums( num )
{
	// tally up the triggers this trigger hears into, including itself
	nums = []; 
	nums[0] = num; 
	for( i = 0; i < level.eq_trigger_table[num].size; i++ )
	{
		nums[nums.size] = level.eq_trigger_table[num][i]; 
	}
	return nums; 
}


player_touched_eq_trigger( num, trigger )
{
	self endon( "death" ); 

	nums = get_trigger_eq_nums( num ); 	
	for( r = 0; r < nums.size; r++ )
	{
		self.eq_table[nums[r]] = true; 
		self.eq_touching[nums[r]] = true; 
	}

	thread player_ignores_triggers(); 

	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		guy = ai[i]; 
		// is the ai in this trigger with us?
		for( r = 0; r < nums.size; r++ )
		{
			if( guy.eq_table[nums[r]] )
			{
				guy EqOff(); 
				break; 
			}
		}
	}

	while( self IsTouching( trigger ) )
	{
		wait( 0.05 ); 
	}
		
	for( r = 0; r < nums.size; r++ )
	{
		self.eq_table[nums[r]] = false; 
		self.eq_touching[nums[r]] = undefined; 
	}
	
	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		guy = ai[i]; 

		was_in_our_trigger = false; 
		// is the ai in the trigger we just left?
		for( r = 0; r < nums.size; r++ )
		{
			// was the guy in a trigger we could hear into?
			if( guy.eq_table[nums[r]] )
			{
				was_in_our_trigger = true; 
			}
		}
		
		if( !was_in_our_trigger )
		{
			continue; 
		}

		// check to see if the guy is in any of the triggers we're still in
	
		touching = GetArrayKeys( self.eq_touching ); 
		shares_trigger = false; 
		for( p = 0; p < touching.size; p++ )
		{
			if( !guy.eq_table[touching[p]] )
			{
				continue; 
			}
				
			shares_trigger = true; 
			break; 
		}
		
		// if he's not in a trigger with us, turn his eq back on
		if( !shares_trigger )
		{
			guy EqOn(); 
		}
	}
}

// SCRIPTER_MOD
// MikeD( 3/16/2007 ): This function does appear to be called at all.
ai_touched_eq_trigger( num, trigger )
{
	self endon( "death" ); 

	nums = get_trigger_eq_nums( num ); 	
	for( r = 0; r < nums.size; r++ )
	{
		self.eq_table[nums[r]] = true; 
		self.eq_touching[nums[r]] = true; 
	}

	// are we in the same trigger as the player?
	break_out = false; 
	for( r = 0; r < nums.size; r++ )
	{
		players = get_players(); 
		for( i = 0; i < players.size; i++ )
		{
			if( players[i].eq_table[nums[r]] )
			{
				self EqOff(); 
				break_out = true; 
			}
		}

		if( break_out )
		{
			break; 
		}
	}
		
	// so other AI can touch the trigger
	self.ignoretriggers = true; 
	wait( 1 ); 
	self.ignoretriggers = false; 
	while( self IsTouching( trigger ) )
	{
		wait( 0.5 ); 
	}
		
	nums = get_trigger_eq_nums( num ); 	
	for( r = 0; r < nums.size; r++ )
	{
		self.eq_table[nums[r]] = false; 
		self.eq_touching[nums[r]] = undefined; 
	}
		
	touching = GetArrayKeys( self.eq_touching ); 
	for( i = 0; i < touching.size; i++ )
	{
		// is the player in a trigger that we're still in?
		player_eq_count = 0; 
		players = get_players(); 
		for( q = 0; q < players.size; q++ )
		{
			if( players[q].eq_table[touching[i]] )
			{
				// then don't turn eq back on
				continue; 
			}
		}

		if( player_eq_count == 0 )
		{
			return; 
		}
	}

	self EqOn(); 
}

ai_eq()
{
	level.set_eq_func[false] = ::set_eq_on; 
	level.set_eq_func[true] = ::set_eq_off; 
	index = 0; 
	for( ;; )
	{
		while( !level.ai_array.size )
		{
			wait( 0.05 ); 
		}
		waittillframeend; 
		waittillframeend; 
		keys = GetArrayKeys( level.ai_array ); 
		index++; 
		if( index >= keys.size )
		{
			index = 0; 
		}
		guy = level.ai_array[keys[index]]; 

		players = get_players(); 
		for( i = 0; i < players.size; i++ )
		{
			guy[[level.set_eq_func[SightTracePassed( players[i] GetEye(), guy GetEye(), false, undefined )]]](); 
		}
		wait( 0.05 ); 
	}
}

set_eq_on()
{
	self EqOn(); 
}

set_eq_off()
{
	self EqOff(); 
}

add_tokens_to_trigger_flags( tokens )
{
	for( i = 0; i < tokens.size; i++ )
	{
		flag = tokens[i]; 
		if( !IsDefined( level.trigger_flags[flag] ) )
		{
			level.trigger_flags[flag] = []; 
		}
		
		level.trigger_flags[flag][level.trigger_flags[flag].size] = self; 
	}
}

script_flag_false_trigger( trigger )
{
	// all of these flags must be false for the trigger to be enabled
	tokens = create_flags_and_return_tokens( trigger.script_flag_false ); 
	trigger add_tokens_to_trigger_flags( tokens ); 
	trigger update_trigger_based_on_flags(); 
}

script_flag_true_trigger( trigger )
{
	// all of these flags must be false for the trigger to be enabled
	tokens = create_flags_and_return_tokens( trigger.script_flag_true ); 
	trigger add_tokens_to_trigger_flags( tokens ); 
	trigger update_trigger_based_on_flags(); 
}

/*
	for( ;; )
	{
		trigger trigger_on(); 
		wait_for_flag( tokens ); 
		
		trigger trigger_off(); 
		wait_for_flag( tokens ); 
		for( i = 0; i < tokens.size; i++ )
		{
			flag_wait( tokens[i] ); 
		}		
	}
	*/


/*
script_flag_true_trigger( trigger )
{
	// any of these flags have to be true for the trigger to be enabled
	tokens = create_flags_and_return_tokens( trigger.script_flag_true ); 

	for( ;; )
	{
		trigger trigger_off(); 
		wait_for_flag( tokens ); 
		trigger trigger_on(); 
		for( i = 0; i < tokens.size; i++ )
		{
			flag_waitopen( tokens[i] ); 
		}		
	}
}
*/

wait_for_flag( tokens )
{
	for( i = 0; i < tokens.size; i++ )
	{
		level endon( tokens[i] ); 
	}
	level waittill( "foreverrr" ); 
}

friendly_respawn_trigger( trigger )
{
	spawners = GetEntArray( trigger.target, "targetname" ); 
	assertex( spawners.size == 1, "friendly_respawn_trigger targets multiple spawner with targetname " + trigger.target + ". Should target just 1 spawner." ); 
	spawner = spawners[0]; 
	assertex( !IsDefined( spawner.script_forcecolor ), "targeted spawner at " + spawner.origin + " should not have script_forcecolor set!" ); 
	spawners = undefined; 
	
	spawner endon( "death" ); 
	
	for( ;; )
	{
		trigger waittill( "trigger" ); 
		
		// SRS 12/20/2007: updated to allow for multiple color chains to be reinforced from different areas
		if( IsDefined( trigger.script_forcecolor ) )
		{
			level.respawn_spawners_specific[trigger.script_forcecolor] = spawner; 
		}
		else
		{
			level.respawn_spawner = spawner; 
		}
		flag_set( "respawn_friendlies" ); 
		wait( 0.5 ); 
	}
}

friendly_respawn_clear( trigger )
{
	for( ;; )
	{
		trigger waittill( "trigger" ); 
		flag_clear( "respawn_friendlies" ); 
		wait( 0.5 ); 
	}
}

//radio_trigger( trigger )
//{
//	trigger waittill( "trigger" ); 
//	radio_dialogue( trigger.script_noteworthy ); 	
//}

trigger_ignore( trigger )
{
	thread trigger_runs_function_on_touch( trigger, ::set_ignoreme, ::get_ignoreme ); 
}

trigger_pacifist( trigger )
{
	thread trigger_runs_function_on_touch( trigger, ::set_pacifist, ::get_pacifist ); 
}

trigger_runs_function_on_touch( trigger, set_func, get_func )
{
	for( ;; )
	{
		trigger waittill( "trigger", other ); 
		if( !IsAlive( other ) )
		{
			continue; 
		}

		if( other[[get_func]]() )
		{
			continue; 
		}
		other thread touched_trigger_runs_func( trigger, set_func ); 
	}
}

touched_trigger_runs_func( trigger, set_func )
{
	self endon( "death" ); 
	self.ignoreme = true; 
	[[set_func]]( true ); 
	// so others can touch the trigger
	self.ignoretriggers = true; 	
	wait( 1 ); 
	self.ignoretriggers = false; 
	
	while( self IsTouching( trigger ) )
	{
		wait( 1 ); 
	}
	
	[[set_func]]( false ); 
}

trigger_turns_off( trigger )
{
	trigger waittill( "trigger" ); 
	trigger trigger_off(); 
	
	if( !IsDefined( trigger.script_linkTo ) )
	{
		return; 
	}
	
	// also turn off all triggers this trigger links to
	tokens = Strtok( trigger.script_linkto, " " ); 
	for( i = 0; i < tokens.size; i++ )
	{
		array_thread( GetEntArray( tokens[i], "script_linkname" ), ::trigger_off ); 
	}
}



script_gen_dump_checksaved()
{
	signatures = GetArrayKeys( level.script_gen_dump ); 
	for( i = 0; i < signatures.size; i++ )
	{
		if( !IsDefined( level.script_gen_dump2[signatures[i]] ) )
	 	{
			level.script_gen_dump[signatures[i]] = undefined; 
			level.script_gen_dump_reasons[level.script_gen_dump_reasons.size] = "Signature unmatched( removed feature ): "+signatures[i]; 
		}
	}
}

script_gen_dump()
{
	//initialize scriptgen dump
	/#

	script_gen_dump_checksaved(); // this checks saved against fresh, if there is no matching saved value then something has changed and the dump needs to happen again.
	
	if( !level.script_gen_dump_reasons.size )
	{
		flag_set( "scriptgen_done" ); 
		return; // there's no reason to dump the file so exit
	}
	
	firstrun = false; 
	if( level.bScriptgened )
	{
		println( " " ); 
		println( " " ); 
		println( " " ); 
		println( "^2----------------------------------------" ); 
		println( "^3Dumping scriptgen dump for these reasons" ); 
		println( "^2----------------------------------------" ); 
		for( i = 0; i < level.script_gen_dump_reasons.size; i++ )
		{
			if( IsSubStr( level.script_gen_dump_reasons[i], "nowrite" ) )
			{
				substr = GetSubStr( level.script_gen_dump_reasons[i], 15 ); // I don't know why it's 15, maybe investigate -nate
				println( i+". ) "+substr ); 
				
			}
			else
			{
				println( i+". ) "+level.script_gen_dump_reasons[i] ); 
				if( level.script_gen_dump_reasons[i] == "First run" )
				{
					firstrun = true; 
				}
			}
		}
		println( "^2----------------------------------------" ); 
		println( " " ); 
		if( firstrun )
		{
			println( "for First Run make sure you delete all of the vehicle precache script calls, createart calls, createfx calls( most commonly placed in maps\\"+level.script+"_fx.gsc ) " ); 
			println( " " ); 
			println( "replace:" ); 
			println( "maps\\\_load::main( 1 ); " ); 
			println( " " ); 
			println( "with( don't forget to add this file to P4 ):" ); 
			println( "maps\\scriptgen\\"+level.script+"_scriptgen::main(); " ); 
			println( " " ); 
		}
//		println( "make sure this is in your "+level.script+".csv:" ); 
//		println( "rawfile, maps/scriptgen/"+level.script+"_scriptgen.gsc" ); 
		println( "^2----------------------------------------" ); 
		println( " " ); 
		println( "^2/\\/\\/\\" ); 
		println( "^2scroll up" ); 
		println( "^2/\\/\\/\\" ); 
		println( " " ); 
	}
	else
	{
/*		println( " " ); 
		println( " " ); 
		println( "^3for legacy purposes I'm printing the would be script here, you can copy this stuff if you'd like to remain a dinosaur:" ); 
		println( "^3otherwise, you should add this to your script:" ); 
		println( "^3maps\\\_load::main( 1 ); " ); 
		println( " " ); 
		println( "^3rebuild the fast file and the follow the assert instructions" ); 
		println( " " ); 
		
		*/
		return; 
	}
	
	filename = "scriptgen/"+level.script+"_scriptgen.gsc"; 
	csvfilename = "zone_source/"+level.script+".csv"; 
	
	if( level.bScriptgened )
	{
		file = OpenFile( filename, "write" ); 
	}
	else
	{
		file = 0; 
	}

	assertex( file != -1, "File not writeable( check it and and restart the map ): " + filename ); 

	script_gen_dumpprintln( file, "//script generated script do not write your own script here it will go away if you do." ); 
	script_gen_dumpprintln( file, "main()" ); 
	script_gen_dumpprintln( file, "{" ); 
	script_gen_dumpprintln( file, "" ); 
	script_gen_dumpprintln( file, "\tlevel.script_gen_dump = []; " ); 
	script_gen_dumpprintln( file, "" ); 

	signatures = GetArrayKeys( level.script_gen_dump ); 
	for( i = 0; i < signatures.size; i++ )
	{
		if( !IsSubStr( level.script_gen_dump[signatures[i]], "nowrite" ) )
		{
		    script_gen_dumpprintln( file, "\t"+level.script_gen_dump[signatures[i]] ); 
		}
	}

	for( i = 0; i < signatures.size; i++ )
	{
        if( !IsSubStr( level.script_gen_dump[signatures[i]], "nowrite" ) )
	    {
	        script_gen_dumpprintln( file, "\tlevel.script_gen_dump["+"\""+signatures[i]+"\""+"] = "+"\""+signatures[i]+"\""+"; " ); 
	    }
		else
		{
			script_gen_dumpprintln( file, "\tlevel.script_gen_dump["+"\""+signatures[i]+"\""+"] = "+"\"nowrite\""+"; " ); 
		}
	}

	script_gen_dumpprintln( file, "" ); 
	
	keys1 = undefined; 
	keys2 = undefined; 
	// special animation threading to capture animtrees
	if( IsDefined( level.sg_precacheanims ) )
	{
		keys1 = GetArrayKeys( level.sg_precacheanims ); 
	}

	if( IsDefined( keys1 ) )
	{
		for( i = 0; i < keys1.size; i++ )
		{
			script_gen_dumpprintln( file, "\tanim_precach_"+keys1[i]+"(); " ); 
		}
	}

	
	script_gen_dumpprintln( file, "\tmaps\\\_load::main( 1, "+level.bCSVgened+", 1 ); " ); 
	script_gen_dumpprintln( file, "}" ); 
	script_gen_dumpprintln( file, "" ); 
	
	/// animations section
	
//	level.sg_precacheanims[animtree][animation]
	if( IsDefined( level.sg_precacheanims ) )
	{
		keys1 = GetArrayKeys( level.sg_precacheanims ); 
	}

	if( IsDefined( keys1 ) )
	{
		for( i = 0; i < keys1.size; i++ )
		{
			//first key being the animtree
			script_gen_dumpprintln( file, "#using_animtree( \""+keys1[i]+"\" ); " ); 
			script_gen_dumpprintln( file, "anim_precach_"+keys1[i]+"()" );  // adds to scriptgendump
			script_gen_dumpprintln( file, "{" ); 
			script_gen_dumpprintln( file, "\tlevel.sg_animtree[\""+keys1[i]+"\"] = #animtree; " );  // adds to scriptgendump get the animtree without having to put #using animtree everywhere.
	
			keys2 = GetArrayKeys( level.sg_precacheanims[keys1[i]] ); 
			if( IsDefined( keys2 ) )
			{
			    for( j = 0; j < keys2.size; j++ )
		        {
				    script_gen_dumpprintln( file, "\tlevel.sg_anim[\""+keys2[j]+"\"] = %"+keys2[j]+"; " );  // adds to scriptgendump	
				}
			}
			script_gen_dumpprintln( file, "}" ); 
			script_gen_dumpprintln( file, "" ); 
		}
	}
	
	
	if( level.bScriptgened )
	{
		saved = Closefile( file ); 
	}
	else
	{
		saved = 1;  //dodging save for legacy levels
	}
	
	//CSV section	
		
	if( level.bCSVgened )
	{
		csvfile = OpenFile( csvfilename, "write" ); 
	}
	else
	{
		csvfile = 0; 
	}
	
	assertex( csvfile != -1, "File not writeable( check it and and restart the map ): " + csvfilename ); 
	
	signatures = GetArrayKeys( level.script_gen_dump ); 
	for( i = 0; i < signatures.size; i++ )
	{
		script_gen_csvdumpprintln( csvfile, signatures[i] ); 
	}

	if( level.bCSVgened )
	{
		csvfilesaved = Closefile( csvfile ); 
	}
	else
	{
		csvfilesaved = 1; //dodging for now
	}

	// check saves
		
	assertex( csvfilesaved == 1, "csv not saved( see above message? ): " + csvfilename ); 
	assertex( saved == 1, "map not saved( see above message? ): " + filename ); 

	#/
	
	//level.bScriptgened is not set on non scriptgen powered maps, keep from breaking everything
	assertex( !level.bScriptgened, "SCRIPTGEN generated: follow instructions listed above this error in the console" ); 
	if( level.bScriptgened )
	{
		assertmsg( "SCRIPTGEN updated: Rebuild fast file and run map again" ); 
	}
		
	flag_set( "scriptgen_done" ); 
	
}


script_gen_csvdumpprintln( file, signature )
{
	
	prefix = undefined; 
	writtenprefix = undefined; 
	path = ""; 
	extension = ""; 
	
	
	if( IsSubStr( signature, "ignore" ) )
	{
		prefix = "ignore"; 
	}
	else if( IsSubStr( signature, "col_map_sp" ) )
	{
		prefix = "col_map_sp"; 
	}
	else if( IsSubStr( signature, "gfx_map" ) )
	{
		prefix = "gfx_map"; 
	}
	else if( IsSubStr( signature, "rawfile" ) )
	{
		prefix = "rawfile"; 
	}
	else if( IsSubStr( signature, "sound" ) )
	{
		prefix = "sound"; 
	}
	else if( IsSubStr( signature, "xmodel" ) )
	{
		prefix = "xmodel"; 
	}
	else if( IsSubStr( signature, "xanim" ) )
	{
		prefix = "xanim"; 
	}
	else if( IsSubStr( signature, "item" ) )
	{
		prefix = "item"; 
		writtenprefix = "weapon"; 
		path = "sp/"; 
	}
	else if( IsSubStr( signature, "fx" ) )
	{
		prefix = "fx"; 
	}
	else if( IsSubStr( signature, "menu" ) )
	{
		prefix = "menu"; 
		writtenprefix = "menufile"; 
		path = "ui/scriptmenus/"; 
		extension = ".menu"; 
	}
	else if( IsSubStr( signature, "rumble" ) )
	{
		prefix = "rumble"; 
		writtenprefix = "rawfile"; 
		path = "rumble/"; 
	}
	else if( IsSubStr( signature, "shader" ) )
	{
		prefix = "shader"; 
		writtenprefix = "material"; 
	}
	else if( IsSubStr( signature, "shock" ) )
	{
		prefix = "shock"; 
		writtenprefix = "rawfile"; 
		extension = ".shock"; 
		path = "shock/"; 
	}
	else if( IsSubStr( signature, "string" ) )
	{
		prefix = "string"; 
		assertmsg( "string not yet supported by scriptgen" );  // I can't find any instances of string files in a csv, don't think we've enabled localization yet
	}
	else if( IsSubStr( signature, "turret" ) )
	{
		prefix = "turret"; 
		writtenprefix = "weapon"; 
		path = "sp/"; 
	}
	else if( IsSubStr( signature, "vehicle" ) )
	{
		prefix = "vehicle"; 
		writtenprefix = "rawfile"; 
		path = "vehicles/"; 
	}
	
	
/*		
sg_PrecacheVehicle( vehicle )
*/

		
	if( !IsDefined( prefix ) )
	{
		return; 
	}

	if( !IsDefined( writtenprefix ) )
	{
		string = prefix+", "+GetSubStr( signature, prefix.size+1, signature.size ); 
	}
	else
	{
		string = writtenprefix+", "+path+GetSubStr( signature, prefix.size+1, signature.size )+extension; 
	}

	
	/*		
	ignore, code_post_gfx
	ignore, common
	col_map_sp, maps/nate_test.d3dbsp
	gfx_map, maps/nate_test.d3dbsp
	rawfile, maps/nate_test.gsc
	sound, voiceovers, rallypoint, all_sp
	sound, us_battlechatter, rallypoint, all_sp
	sound, ab_battlechatter, rallypoint, all_sp
	sound, common, rallypoint, all_sp
	sound, generic, rallypoint, all_sp
	sound, requests, rallypoint, all_sp	
*/

	// printing to file is optional	
	if( file == -1 || !level.bCSVgened )
	{
		println( string ); 
	}
	else
	{
		FPrintLn( file, string ); 
	}
}

script_gen_dumpprintln( file, string )
{
	// printing to file is optional
	if( file == -1 || !level.bScriptgened )
	{
		println( string ); 
	}
	else
	{
		FPrintLn( file, string ); 
	}
}

trigger_hInt( trigger )
{
	assertex( IsDefined( trigger.script_hint ), "Trigger_hint at " + trigger.origin + " has no .script_hint" ); 
	trigger endon( "death" ); 
	
	if( !IsDefined( level.displayed_hints ) )
	{
		level.displayed_hints = []; 
	}
	// give level script a chance to set the hint string and optional boolean functions on this hint
	waittillframeend; 

	hint = trigger.script_hint; 
	assertex( IsDefined( level.trigger_hint_string[hint] ), "Trigger_hint with hint " + hint + " had no hint string assigned to it. Define hint strings with add_hint_string()" ); 
	trigger waittill( "trigger", other ); 
	assertex( IsPlayer( other ), "Tried to do a trigger_hint on a non player entity" ); 
	
	if( IsDefined( level.displayed_hints[hint] ) )
	{
			return; 
	}
	level.displayed_hints[hint] = true; 
	
	display_hInt( hint ); 
}

stun_test()
{
	if( GetDvar( "stuntime" ) == "" )
	{
		SetDvar( "stuntime", "1" ); 
	}

	level.player.allowads = true; 

	for( ;; )
	{
		self waittill( "damage" ); 
		if( GetDvarInt( "stuntime" ) == 0 )
		{
			continue; 
		}
		self thread stun_player( self PlayerAds() ); 			
	}
}

stun_player( ADS_fraction )
{
	self notify( "stun_player" ); 
	self endon( "stun_player" ); 
	
	if( ADS_fraction > .3 )
	{

		if( self.allowads == true )
		{
			self PlaySound( "player_hit_while_ads" ); 
		}
			
		self.allowads = false; 
		self AllowAds( false ); 
	}

	self SetSpreadOverride( 20 ); 
	
	wait( GetDvarInt( "stuntime" ) ); 

	self AllowAds( true ); 
	self.allowads = true; 
	self ReSetSpreadOverride(); 
}

throw_grenade_at_player_trigger( trigger )
{
	trigger endon( "death" ); 
	
	trigger waittill( "trigger" ); 

	ThrowGrenadeAtPlayerASAP(); 
}

flag_on_cleared( trigger )
{
	flag = trigger get_trigger_flag(); 
	
	if( !IsDefined( level.flag[flag] ) )
	{
		flag_init( flag ); 
	}
	
	for( ;; )
	{
		trigger waittill( "trigger" ); 
		wait( 1 ); 
		if( trigger found_toucher() )
		{
			continue; 
		}

		break; 
	}
	
	flag_set( flag ); 
}

found_toucher()
{			
	ai = GetAiArray( "axis" ); 
	for( i = 0; i < ai.size; i++ )
	{
		guy = ai[i]; 
		if( !IsAlive( guy ) )
		{
			continue; 
		}
			
		if( guy IsTouching( self ) )
		{
			return true; 
		}

		// spread the touches out over time
		wait( 0.1 ); 
	}
	
	// couldnt find any touchers so do a single frame complete check just to make sure
	
	ai = GetAiArray( "axis" ); 
	for( i = 0; i < ai.size; i++ )
	{
		guy = ai[i]; 
		if( guy IsTouching( self ) )
		{
			return true; 
		}
	}
	
	return false; 
}

trigger_delete_on_touch( trigger )
{
	for( ;; )
	{
		trigger waittill( "trigger", other ); 
		if( IsDefined( other ) )
		{
			// might've been removed before we got it
			other Delete(); 
		}
	}
}


flag_set_touching( trigger )
{
	flag = trigger get_trigger_flag(); 
	
	if( !IsDefined( level.flag[flag] ) )
	{
		flag_init( flag ); 
	}
	
	for( ;; )
	{
		trigger waittill( "trigger", other ); 
		flag_set( flag ); 
		while( IsAlive( other ) && other IsTouching( trigger ) && IsDefined( trigger ) )
		{
			wait( 0.25 ); 
		}
		flag_clear( flag ); 
	}
}

/*
rpg_aim_assist()
{
	level.player endon( "death" ); 
	for( ;; )
	{
		level.player waittill( "weapon_fired" ); 
		currentweapon = level.player GetCurrentWeapon(); 
		if( ( currentweapon == "rpg" ) ||( currentweapon == "rpg_player" ) )
		{
			thread rpg_aim_assist_attractor(); 
		}
	}
}

rpg_aim_assist_attractor()
{
	prof_begin( "rpg_aim_assist" ); 
	
	// Trace to where the player is looking
	start = level.player GetEye(); 
	direction = level.player GetPlayerAngles(); 
	coord = BulletTrace( start, start + vector_multiply( AnglesToForward( direction ), 15000 ), true, level.player )["position"]; 
	
	thread draw_line_for_time( level.player.origin, coord, 1, 0, 0, 10000 ); 
	
	prof_end( "rpg_aim_assist" ); 
	
	attractor = missile_createAttractorOrigin( coord, 10000, 3000 ); 
	wait( 3.0 ); 
	missile_deleteAttractor( attractor ); 
}
*/

add_nodes_mins_maxs( nodes )
{
	for( index = 0; index < nodes.size; index++ )
	{
		origin = nodes[index].origin;

		level.nodesMins = expandMins( level.nodesMins, origin ); 
		level.nodesMaxs = expandMaxs( level.nodesMaxs, origin ); 
	}
}

calculate_map_center()
{
	//GLocke( 5/14 ) -- Do not compute and set the map center if the level script has already done so.
	if( !IsDefined( level.mapCenter ) )
	{
		level.nodesMins = ( 0, 0, 0 ); 
		level.nodesMaxs = ( 0, 0, 0 );
	
		// grab all of the path nodes in the level and use them to determine the
		// the center of the playable map
		nodes = GetAllNodes();

		if( IsDefined( nodes[0] ) )
		{
			level.nodesMins = nodes[0].origin;
			level.nodesMaxs = nodes[0].origin;
		}
	
		add_nodes_mins_maxs( nodes );
	
		level.mapCenter = findBoxCenter( level.nodesMins, level.nodesMaxs ); 
		
		/#
			println( "map center: ", level.mapCenter ); 
		#/

		SetMapCenter( level.mapCenter ); 
	}
}


SetObjectiveTextColors()
{
	// The darker the base color, the more-readable the text is against a stark-white backdrop.
	// However; this sacrifices the "white-hot"ness of the text against darker backdrops.

	MY_TEXTBRIGHTNESS_DEFAULT = "1.0 1.0 1.0"; 
	MY_TEXTBRIGHTNESS_90 = "0.9 0.9 0.9"; 
	MY_TEXTBRIGHTNESS_85 = "0.85 0.85 0.85"; 

	if( level.script == "armada" )
	{
		SetSavedDvar( "con_typewriterColorBase", MY_TEXTBRIGHTNESS_90 ); 
		return; 
	}

	SetSavedDvar( "con_typewriterColorBase", MY_TEXTBRIGHTNESS_DEFAULT ); 
}

ammo_pickup( sWeaponType )
{
	// possible weapons that the player could have that get this type of ammo
	validWeapons = []; 
	if( sWeaponType == "grenade_launcher" )
	{
		validWeapons[0] = "m203_m4"; 
		validWeapons[1] = "m203"; 
		validWeapons[2] = "gp25"; 
		validWeapons[3] = "m4m203_silencer_reflex"; 
	}
	else if( sWeaponType == "rpg" )
	{
		validWeapons[0] = "rpg"; 
		validWeapons[1] = "rpg_player"; 
		validWeapons[2] = "rpg_straight"; 
	}
	else if( sWeaponType == "c4" )
	{
		validWeapons[0] = "c4"; 
	}
	else if( sWeaponType == "claymore" )
	{
		validWeapons[0] = "claymore"; 
	}
	assert( validWeapons.size > 0 ); 
	
	trig = Spawn( "trigger_radius", self.origin, 0, 25, 32 ); 
	
	for( ;; )
	{
		trig waittill( "trigger", triggerer ); 
		
		if( !IsDefined( triggerer ) )
		{
			continue; 
		}
		
		if( triggerer != IsPlayer( triggerer ) )
		{
			continue; 
		}
		
		// check if the player is carrying one of the valid grenade launcher weapons
		weaponToGetAmmo = undefined; 
		weapons = triggerer GetWeaponsList(); 
		for( i = 0 ; i < weapons.size ; i++ )
		{
			for( j = 0 ; j < validWeapons.size ; j++ )
			{
				if( weapons[i] == validWeapons[j]	 )
				{
					weaponToGetAmmo = weapons[i]; 
				}
			}
		}
		
		// no grenade launcher found
		if( !IsDefined( weaponToGetAmmo ) )
		{
			continue; 
		}
		
		// grenade launcher found - check if the player has max ammo already
		if( triggerer GetFractionMaxAmmo( weaponToGetAmmo ) >= 1 )
		{
			continue; 
		}
		
		// player picks up the ammo
		break; 
	}
	
	// give player one more ammo, play pickup sound, and delete the ammo and trigger
	triggerer SetWeaponAmmoStock( weaponToGetAmmo, triggerer GetWeaponAmmoStock( weaponToGetAmmo ) + 1 ); 
	triggerer PlayLocalSound( "grenade_pickup" ); 
	trig Delete(); 
	self Delete(); 
}

get_script_linkto_targets()
{
	targets = []; 
	if( !IsDefined( self.script_linkto ) )
	{
		return targets; 
	}
		
	tokens = Strtok( self.script_linkto, " " ); 
	for( i = 0; i < tokens.size; i++ )
	{
		token = tokens[i]; 
		target = GetEnt( token, "script_linkname" ); 
		if( IsDefined( target ) )
		{
			targets[targets.size] = target; 
		}
	}
	return targets; 
}

delete_link_chain( trigger )
{
	// deletes all entities that it script_linkto's, and all entities that entity script linktos, etc.
	trigger waittill( "trigger" ); 

	targets = trigger get_script_linkto_targets(); 
	array_thread( targets, ::delete_links_then_self ); 
}

delete_links_then_self()
{
	targets = get_script_linkto_targets(); 
	array_thread( targets, ::delete_links_then_self ); 
	self Delete(); 
}

defer_vision_set_naked(vision, time)
{
	if(NumRemoteClients())
	{
		wait_network_frame();
	}
	
	self VisionSetNaked( vision, time ); 
}

/*
	A depth trigger that sets fog
*/
trigger_fog( trigger )
{
	trigger endon( "death" );

	dofog = true; 
	if( !IsDefined( trigger.script_start_dist ) )
	{
		dofog = false; 
	}

	if( !IsDefined( trigger.script_halfway_dist ) )
	{
		dofog = false; 
	}

	if( !IsDefined( trigger.script_halfway_height ) )
	{
		dofog = false; 
	}

	if( !IsDefined( trigger.script_base_height ) )
	{
		dofog = false; 
	}

	if( !IsDefined( trigger.script_color ) )
	{
		dofog = false; 
	}

	if( !IsDefined( trigger.script_transition_time  ) )
	{
		dofog = false; 
	}

	do_sunsamplesize = false;
	sunsamplesize_time = undefined;
	if( IsDefined( trigger.script_sunsample ) )
	{
		do_sunsamplesize = false;
		trigger.lerping_dvar["sm_sunSampleSizeNear"] = false;

		sunsamplesize_time = 1;
		if( IsDefined( trigger.script_transition_time  ) )
		{
			sunsamplesize_time = trigger.script_sunsample_time;
		}

		if( IsDefined( trigger.script_sunsample_time ) )
		{
			sunsamplesize_time = trigger.script_sunsample_time;			
		}
	}
	
	// loop forever, waittill player is in trigger and do fog and vision file changes
	for( ;; )
	{
		trigger waittill( "trigger", other ); 
		assertex( IsPlayer( other ), "Non-player entity touched a trigger_fog." ); 
		
		wait( 0.05 ); 
		
		players = get_players();
		
		for(i = 0; i < players.size; i ++)
		{
			player = players[i];
			
			if(player istouching(trigger))
			{
				if( !IsSplitscreen() )
				{
					if( dofog && ( !isdefined(player.fog_trigger_current) || player.fog_trigger_current != trigger ))
					{
						player SetVolFog( trigger.script_start_dist, trigger.script_halfway_dist, 
											trigger.script_halfway_height, trigger.script_base_height, 
											trigger.script_color[0], trigger.script_color[1], trigger.script_color[2], 
											trigger.script_transition_time ); 	
					}
				}
		
				if( (IsDefined( trigger.script_vision ) && IsDefined( trigger.script_vision_time )) && ( !isdefined(player.fog_trigger_current) || player.fog_trigger_current != trigger ) )
				{
					player thread defer_vision_set_naked(trigger.script_vision, trigger.script_vision_time);
				}
				
				player.fog_trigger_current = trigger;		
				
			}
		}
		
		// Non coop settings only
		players = get_players();
		if( players.size > 1 )
		{
			if( do_sunsamplesize )
			{
				dvar = "sm_sunSampleSizeNear";
				if( !trigger.lerping_dvar[dvar] && GetDvar( dvar ) != trigger.script_sunsample )
				{
					level thread lerp_trigger_dvar_value( trigger, dvar, trigger.script_sunsample, sunsamplesize_time );
				}
			}
		}
	}
}

lerp_trigger_dvar_value( trigger, dvar, value, time )
{
	trigger.lerping_dvar[dvar] = true;
	steps = time * 20;
	curr_value = GetDvarFloat( dvar );
	diff = ( curr_value - value ) / steps;
	
	for( i = 0; i < steps; i++ )
	{
		curr_value = curr_value - diff;
		SetSavedDvar( dvar, curr_value );
		wait( 0.05 );
	}
	
	SetSavedDvar( dvar, value );
	trigger.lerping_dvar[dvar] = false;
}

set_fog_progress( progress )
{
	anti_progress = 1 - progress; 
	startdist = self.script_start_dist * anti_progress + self.script_start_dist * progress; 
	halfwayDist = self.script_halfway_dist * anti_progress + self.script_halfway_dist * progress; 
	color = self.script_color * anti_progress + self.script_color * progress; 
	
	SetVolFog( startdist, halfwaydist, self.script_halfway_height, self.script_base_height, color[0], color[1], color[2], 0.4 ); 
}

remove_level_first_frame()
{
	wait( 0.05 ); 
	level.first_frame = undefined;
}

no_crouch_or_prone_think( trigger )
{
	for( ;; )
	{
		trigger waittill( "trigger", other ); 

		if( !IsPlayer( other ) )
		{
			continue; 
		}

		while( other IsTouching( trigger ) )
		{
			other AllowProne( false ); 
			other AllowCrouch( false ); 
			wait( 0.05 ); 
		}

		other AllowProne( true ); 
		other AllowCrouch( true ); 
	}
}

no_prone_think( trigger )
{
	for( ;; )
	{
		trigger waittill( "trigger", other ); 

		if( !IsPlayer( other ) )
		{
			continue; 
		}

		while( other IsTouching( trigger ) )
		{
			other AllowProne( false ); 
			wait( 0.05 ); 
		}

		other AllowProne( true ); 
	}
}

ascii_logo()
{
	println( " .d8888b.     .d88888b.    8888888b.          888       888   888       888" );      
	println( "d88P  Y88b   d88P' 'Y88b   888  'Y88b         888   o   888   888   o   888" );                
	println( "888    888   888     888   888    888   d8b   888  d8b  888   888  d8b  888" ); 
	println( "888          888     888   888    888   Y8P   888 d888b 888   888 d888b 888" ); 
	println( "888          888     888   888    888         888d88888b888   888d88888b888" ); 
	println( "888    888   888     888   888    888   d8b   88888P Y88888   88888P Y88888" ); 
	println( "Y88b  d88P   Y88b. .d88P   888  .d88P   Y8P   8888P   Y8888   8888P   Y8888" );
	println( " 'Y8888P'     'Y88888P'    8888888P'          888P     Y888   888P     Y888" );
}


load_friendlies()
{
	if( IsDefined( game["total characters"] ) )
	{
		game_characters = game["total characters"]; 
		println( "Loading Characters: ", game_characters ); 
	}
	else
	{
		println( "Loading Characters: None!" ); 
		return; 
	}

	ai = GetAiArray( "allies" ); 
	total_ai = ai.size; 
	index_ai = 0; 

	spawners = GetSpawnerTeamArray( "allies" ); 
	total_spawners = spawners.size; 
	index_spawners = 0; 

	while( 1 )
	{
		if( ( ( total_ai <= 0 ) &&( total_spawners <= 0 ) ) ||( game_characters <= 0 ) )
		{
			return; 
		}

		if( total_ai > 0 )
		{
			if( IsDefined( ai[index_ai].script_friendname ) )
			{
				total_ai -- ; 
				index_ai ++ ; 
				continue; 
			}

			println( "Loading character.. ", game_characters ); 
			ai[index_ai] codescripts\character::new(); 
			ai[index_ai] thread codescripts\character::load( game["character" +( game_characters - 1 )] ); 
			total_ai -- ; 
			index_ai ++ ; 
			game_characters -- ; 
			continue; 
		}

		if( total_spawners > 0 )
		{
			if( IsDefined( spawners[index_spawners].script_friendname ) )
			{
				total_spawners -- ; 
				index_spawners ++ ; 
				continue; 
			}

			println( "Loading character.. ", game_characters ); 
			info = game["character" +( game_characters - 1 )]; 
			precache( info["model"] ); 
			precache( info["model"] ); 
			spawners[index_spawners] thread spawn_setcharacter( game["character" +( game_characters - 1 )] ); 
			total_spawners -- ; 
			index_spawners ++ ; 
			game_characters -- ; 
			continue; 
		}
	}
}

check_flag_for_stat_tracking( msg )
{
	if( !issuffix( msg, "aa_" ) )
	{
		return; 
	}
		
	[[level.sp_stat_tracking_func]]( msg ); 
}



precache_script_models()
{
	if( !IsDefined( level.scr_model ) )
	{
		return; 
	}
	models = GetArrayKeys( level.scr_model ); 
	for( i = 0; i < models.size; i++ )
	{
		PrecacheModel( level.scr_model[models[i]] ); 
	}
}


filmy()
{
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: filmy()\n" ); 
	}
	#/
	
	if( GetDvar( "grain_test" ) == "" )
	{
		return; 
	}
	effect = LoadFx( "misc/grain_test" ); 
	looper = Spawn( "script_model", level.player GetEye() ); 
	looper SetModel( "tag_origin" ); 
	looper Hide(); 
	PlayFxonTag( effect, looper, "tag_origin" ); 
	settimescale( 1.7 ); 
	while( 1 )
	{
		wait( .05 ); 
		VisionSetNaked( "sepia" ); 
		looper.origin = level.player GetEye() +( vector_multiply( AnglesToForward( level.player GetPlayerAngles() ), 50 ) ); 
	}
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( GetDebugDvar( "replay_debug" ) == "1" )
	{
		println( "File: _load.gsc. Function: filmy() - COMPLETE\n" ); 
	}
	#/
}

arcademode_save()
{
	has_save = []; 
	has_save["training"] = 		true; 
	has_save["mak"] = 				true; 
	has_save["pel1"] = 				true; 
	has_save["pel1a"] = 			true; 
	has_save["pel1b"] = 			true; 
	has_save["pel2"] = 				true; 
	has_save["pby_fly"] = 		true; 
	has_save["hol1"] = 				true; 
	has_save["hol2"] = 				true; 
	has_save["hol3"] = 				true; 
	has_save["see1"] = 				true; 
	has_save["ber1"] = 				true; 
	has_save["ber2"] = 				true; 	
	has_save["sniper"] = 			true; 			
	has_save["ber3"] = 				true; 
	has_save["oki1"] = 				true; 
	has_save["oki2"] = 				true; 
	has_save["oki3"] = 				true; 
	
// SCRIPTER_MOD: JesseS( 4/12/2008 ): Took this out for test maps, will need this again when we ship
//	if( has_save[level.script] )
//		return; 
		
//	wait( 2.5 ); 
//	imagename = "levelshots / autosave / autosave_" + level.script + "start"; 
//	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", imagename, true ); 
}

player_death_detection()
{
	// a dvar starts high then degrades over time whenever the player dies, 
	// checked from maps\_utility::player_died_recently()
	SetDvar( "player_died_recently", "0" ); 
	thread player_died_recently_degrades(); 

	level add_wait( ::flag_wait, "missionfailed" ); 
	self add_wait( ::waittill_msg, "death" ); 
	do_wait_any(); 
		
	recently_skill = []; 
	recently_skill[0] = 70; 
	recently_skill[1] = 30; 
	recently_skill[2] = 0; 
	recently_skill[3] = 0; 
	
	SetDvar( "player_died_recently", recently_skill[level.gameskill] ); 
}

player_died_recently_degrades()
{
	for( ;; )
	{
		recent_death_time = GetDvarInt( "player_died_recently" ); 
		if( recent_death_time > 0 )
		{
			recent_death_time -= 5; 
			SetDvar( "player_died_recently", recent_death_time ); 
		}
		wait( 5 ); 
	}
}

all_players_connected()
{
	while(1)
	{
		num_con = getnumconnectedplayers(); 
		num_exp = getnumexpectedplayers();
		if(num_con == num_exp && (num_exp != 0))
		{
			flag_set( "all_players_connected" );
	        // CODER_MOD: GMJ (08/28/08): Setting dvar for use by code
	        SetDvar( "all_players_are_connected", "1" ); 
			return;
		}

		wait( 0.05 );
	}
}

all_players_spawned()
{
	flag_wait( "all_players_connected" );
	waittillframeend; // We need to make sure the clients actually get setup before we can do things to them.

	while(1)
	{
		players = get_players();

		count = 0;
		for( i = 0; i < players.size; i++ )
		{
			if( players[i].sessionstate == "playing" )
			{
				count++;
			}
		}

		if( count == players.size )
		{
			break;
		}

		wait( 0.05 );
	}

	flag_set( "all_players_spawned" );
}

// MikeD (6/24/2008): This handles what placed weapons to keep depending on the amount of players in the game
adjust_placed_weapons()
{
	weapons = GetEntArray( "placed_weapon", "targetname" );

	flag_wait( "all_players_connected" );

	players = get_players();
	player_count = players.size;

	for( i = 0; i < weapons.size; i++ )
	{
		if( IsDefined( weapons[i].script_player_min ) && player_count < weapons[i].script_player_min )
		{
			weapons[i] Delete();
		}
	}
	
}

