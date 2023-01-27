#include maps\_utility; 
#include common_scripts\utility;

main()
{
	precache_createfx_fx();
	scriptedFX();
	footsteps(); 
	
	maps\createfx\nazi_zombie_asylum_fx::main();
	maps\createart\nazi_zombie_asylum_art::main();
	level thread chair_light();
	
}

footsteps()
{
	animscripts\utility::setFootstepEffect( "asphalt",    LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "brick",      LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "carpet",     LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "cloth",      LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "concrete",   LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "dirt",       LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "foliage",    LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "gravel",     LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "grass",      LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "ice",        LoadFx( "bio/player/fx_footstep_snow" ) );
	animscripts\utility::setFootstepEffect( "metal",      LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "mud",        LoadFx( "bio/player/fx_footstep_mud" ) );
	animscripts\utility::setFootstepEffect( "paper",      LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "plaster",    LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock",       LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "sand",       LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "snow",       LoadFx( "bio/player/fx_footstep_snow" ) );
	animscripts\utility::setFootstepEffect( "water",      LoadFx( "bio/player/fx_footstep_water" ) );
	animscripts\utility::setFootstepEffect( "wood",       LoadFx( "bio/player/fx_footstep_dust" ) );
}

// --- Ambient_Effects ---//

precache_createfx_fx()
{
  level._effect["god_rays_small"]					  = loadfx("env/light/fx_light_god_ray_sm_single");
  level._effect["god_rays_dust_motes"]			= loadfx("env/light/fx_light_god_rays_dust_motes");
	level._effect["light_ceiling_dspot"]			= loadfx("env/light/fx_ray_ceiling_amber_dim_sm");
	level._effect["dlight_fire_glow"]				  = loadfx("env/light/fx_dlight_fire_glow");
	level._effect["god_ray_fire_ribbon"]			= loadfx("maps/mp_maps/fx_mp_ray_fire_ribbon");
	level._effect["god_ray_fire_thin"]			= loadfx("maps/mp_maps/fx_mp_ray_fire_thin");

  level._effect["electric_power_gen_on"]	  = loadfx("misc/fx_zombie_elec_gen_on");
  level._effect["electric_power_gen_idle"]	= loadfx("misc/fx_zombie_elec_gen_idle");

	level._effect["fire_detail"]					    = loadfx("env/fire/fx_fire_debris_xsmall");
	level._effect["fire_static_small"]				= loadfx("env/fire/fx_static_fire_sm_ndlight");
	level._effect["fire_static_blk_smk"]			= loadfx("env/fire/fx_static_fire_md_ndlight");
	level._effect["fire_column_creep_xsm"]		= loadfx("env/fire/fx_fire_column_creep_xsm");
	level._effect["fire_column_creep_sm"]			= loadfx("env/fire/fx_fire_column_creep_sm");
	level._effect["fire_distant_150_600"]			= loadfx("env/fire/fx_fire_150x600_tall_distant");
	level._effect["fire_window"]				    	= loadfx("env/fire/fx_fire_win_nsmk_0x35y50z");
	level._effect["fire_tree_trunk"]			       = loadfx("maps/mp_maps/fx_mp_fire_tree_trunk");
  level._effect["fire_rubble_sm_column"]       = loadfx("maps/mp_maps/fx_mp_fire_rubble_small_column");
  level._effect["fire_rubble_sm_column_smldr"] = loadfx("maps/mp_maps/fx_mp_fire_rubble_small_column_smldr");
  level._effect["fire_rubble_detail_grp"]      = loadfx("maps/mp_maps/fx_mp_fire_rubble_detail_grp");
  level._effect["fire_large_mp"]      				 = loadfx("maps/mp_maps/fx_mp_fire_large");
  level._effect["fire_med_mp"]      				   = loadfx("maps/mp_maps/fx_mp_fire_medium");

	level._effect["ash_and_embers"]					    = loadfx("env/fire/fx_ash_embers_light");
	level._effect["smoke_room_fill"]				    = loadfx("maps/ber2/fx_smoke_fill_indoor");
	level._effect["smoke_window_out_small"]			= loadfx("env/smoke/fx_smoke_door_top_exit_drk");
  level._effect["smoke_plume_xlg_slow_blk"]		= loadfx("maps/ber2/fx_smk_plume_xlg_slow_blk_w");
	level._effect["smoke_hallway_faint_dark"]		= loadfx("env/smoke/fx_smoke_hallway_faint_dark");
	level._effect["brush_smoke_smolder_sm"]			= loadfx("env/smoke/fx_smoke_brush_smolder_md");
  level._effect["smoke_fire_column_short"]    = loadfx("maps/mp_maps/fx_mp_smoke_fire_column_short");
	level._effect["smoke_impact_smolder_w"]			= loadfx("env/smoke/fx_smoke_crater_w");
	level._effect["smoke_column_tall"]			    = loadfx("maps/mp_maps/fx_mp_smoke_column_tall");
	level._effect["fog_thick"]						      = loadfx("env/smoke/fx_fog_rolling_thick_zombie");
	level._effect["fog_low_floor"]		        	= loadfx("env/smoke/fx_fog_low_floor_sm");
	level._effect["fog_low_thick"]			        = loadfx("env/smoke/fx_fog_low_thick_sm");
	
	level._effect["blood_drips"]			        	= loadfx("system_elements/fx_blood_drips_looped_decal");
	level._effect["insect_lantern"]			         = loadfx("maps/mp_maps/fx_mp_insects_lantern");
	level._effect["insect_swarm"]			           = loadfx("maps/mp_maps/fx_mp_insect_swarm");
	level._effect["insect_flies_carcass"]        = loadfx("maps/mp_maps/fx_mp_flies_carcass");

	level._effect["water_spill_fall"]				  = loadfx("maps/mp_maps/fx_mp_water_spill"); 
	level._effect["water_leak_runner"]				= loadfx("env/water/fx_water_leak_runner_100");
  level._effect["water_spill_splash"]       = loadfx("maps/mp_maps/fx_mp_water_spill_splash");
  level._effect["water_heavy_leak"]			   	= loadfx("env/water/fx_water_drips_hvy");
  
  level._effect["water_drip_sm_area"]						= loadfx("maps/mp_maps/fx_mp_water_drip");
  level._effect["water_spill_long"]						= loadfx("maps/mp_maps/fx_mp_water_spill_long");
	level._effect["water_drips_hvy_long"]				= loadfx("maps/mp_maps/fx_mp_water_drips_hvy_long");
	level._effect["water_spill_splatter"]				= loadfx("maps/mp_maps/fx_mp_water_spill_splatter");
	level._effect["water_splash_small"]				= loadfx("maps/mp_maps/fx_mp_water_splash_small");

	level._effect["wire_sparks"]					    = loadfx("env/electrical/fx_elec_wire_spark_burst");
	level._effect["wire_sparks_blue"]			   	= loadfx("env/electrical/fx_elec_wire_spark_burst_blue");
  
  level._effect["betty_explode"]			= loadfx("weapon/bouncing_betty/fx_explosion_betty_generic");
	level._effect["betty_trail"]				= loadfx("weapon/bouncing_betty/fx_betty_trail");
	level._effect["zapper"]							= loadfx("misc/fx_zombie_electric_trap");
	level._effect["switch_sparks"]			= loadfx("env/electrical/fx_elec_wire_spark_burst");
	level._effect["wire_sparks_oneshot"] = loadfx("env/electrical/fx_elec_wire_spark_dl_oneshot");
}

scriptedFX()
{
	level._effect["large_ceiling_dust"]		= LoadFx("env/dirt/fx_dust_ceiling_impact_lg_mdbrown");
	level._effect["poltergeist"]			= LoadFx("misc/fx_zombie_couch_effect");
	level._effect["electric_short_oneshot"] = loadfx("env/electrical/fx_elec_short_oneshot");

	// rise fx
	level._effect["rise_burst"]		= LoadFx("maps/mp_maps/fx_mp_zombie_hand_dirt_burst");
	level._effect["rise_billow"]	= LoadFx("maps/mp_maps/fx_mp_zombie_body_dirt_billowing");
	level._effect["rise_dust"]		= LoadFx("maps/mp_maps/fx_mp_zombie_body_dust_falling");
	
	//light 
	level._effect["chair_light_fx"] = loadfx("env/light/fx_glow_hanginglamp");
	
	//other stuff
	level._effect["electric_current"] = loadfx("misc/fx_zombie_elec_trail");
	level._effect["dog_eye_glow"] = loadfx("misc/fx_zombie_eye_dog");
	level._effect["zapper_fx"] = loadfx("misc/fx_zombie_zapper_powerbox_on");
	level._effect["dog_gib"] = loadfx("explosions/fx_flamethrower_char_explosion");
	level._effect["zapper_wall"] = loadfx("misc/fx_zombie_zapper_wall_control_on");
	level._effect["zapper_light_ready"] = loadfx("maps/zombie/fx_zombie_light_glow_green");
	level._effect["zapper_light_notready"] = loadfx("maps/zombie/fx_zombie_light_glow_red");
	level._effect["elec_room_on"] = loadfx("fx_zombie_light_elec_room_on");
	
	//electrocute fx
	level._effect["elec_md"] = loadfx("env/electrical/fx_elec_player_md");
	level._effect["elec_sm"] = loadfx("env/electrical/fx_elec_player_sm");
	level._effect["elec_torso"] = loadfx("env/electrical/fx_elec_player_torso");

	level._effect["elec_trail_one_shot"] = loadfx("misc/fx_zombie_elec_trail_oneshot");
	
	
}


/*------------------------------------
light on a rope
------------------------------------*/
chair_light()
{
	//grab the lantern model
	lantern = getent("morgue_lamp","script_noteworthy");
	lght = getent("lamp_light","targetname");

	if(!isdefined(lght))
		return;
	
	lght linkto(lantern);
	lght setlightintensity(2.1);
		
	mdl = spawn("script_model",lantern.origin);
	mdl.angles = (90,0,0);
	mdl setmodel("tag_origin");
	mdl linkto(lantern);
	playfxontag(level._effect["chair_light_fx"],mdl,"tag_origin");
		
	while(1)
	{
		wait(randomfloatrange(10,15));	
		lantern physicslaunch ( lantern.origin, (randomintrange(-20,20),randomintrange(-20,20),randomintrange(-20,20)) );
	}
}