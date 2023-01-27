//
// file: mak_fx.gsc
// description: clientside fx script for mak: setup, special fx functions, etc.
// scripter: 		(initial clientside work - laufer)
//

#include clientscripts\_utility; 
main()
{
	clientscripts\createfx\nazi_zombie_prototype_fx::main();
	clientscripts\_fx::reportNumEffects();

	footsteps();
	precache_createfx_fx();
	
	disableFX = GetDvarInt( "disable_fx" );
	if( !IsDefined( disableFX ) || disableFX <= 0 )
	{
		precache_scripted_fx();
	}
}


precache_scripted_fx()
{
	level._effect["zombie_grain"]	= LoadFx( "misc/fx_zombie_grain_cloud" );
}

footsteps()
{
	clientscripts\_utility::setFootstepEffect( "asphalt",    LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "brick",      LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "carpet",     LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "cloth",      LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "concrete",   LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "dirt",       LoadFx( "bio/player/fx_footstep_sand" ) );
	clientscripts\_utility::setFootstepEffect( "foliage",    LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "gravel",     LoadFx( "bio/player/fx_footstep_sand" ) );
	clientscripts\_utility::setFootstepEffect( "grass",      LoadFx( "bio/player/fx_footstep_sand" ) );
	clientscripts\_utility::setFootstepEffect( "ice",        LoadFx( "bio/player/fx_footstep_snow" ) );
	clientscripts\_utility::setFootstepEffect( "metal",      LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "mud",        LoadFx( "bio/player/fx_footstep_mud" ) );
	clientscripts\_utility::setFootstepEffect( "paper",      LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "plaster",    LoadFx( "bio/player/fx_footstep_dust" ) );
	clientscripts\_utility::setFootstepEffect( "rock",       LoadFx( "bio/player/fx_footstep_sand" ) );
	clientscripts\_utility::setFootstepEffect( "sand",       LoadFx( "bio/player/fx_footstep_sand" ) );
	clientscripts\_utility::setFootstepEffect( "snow",       LoadFx( "bio/player/fx_footstep_snow" ) );
	clientscripts\_utility::setFootstepEffect( "water",      LoadFx( "bio/player/fx_footstep_water" ) );
	clientscripts\_utility::setFootstepEffect( "wood",       LoadFx( "bio/player/fx_footstep_dust" ) );
}

// --- Ambient_Effects ---//

precache_createfx_fx()
{
	level._effect["smoke_plume_xlg_slow_blk"]			= loadfx ("maps/ber2/fx_smk_plume_xlg_slow_blk_w");
	level._effect["smoke_hallway_faint_dark"]			= loadfx ("env/smoke/fx_smoke_hallway_faint_dark");
	level._effect["smoke_bank"]							      = loadfx ("env/smoke/fx_battlefield_smokebank_ling_lg_w");
	level._effect["battlefield_smokebank_sm_tan"]			= loadfx ("env/smoke/fx_battlefield_smokebank_ling_sm_w");
	level._effect["ash_and_embers"]					      = loadfx ("env/fire/fx_ash_embers_light");
	level._effect["smoke_window_out_small"]				= loadfx ("env/smoke/fx_smoke_door_top_exit_drk");
	level._effect["brush_smoke_smolder_sm"]			= loadfx ("env/smoke/fx_smoke_brush_smolder_md");
	level._effect["smoke_impact_smolder_w"]		  = loadfx ("env/smoke/fx_smoke_crater_w");
	level._effect["fire_window"]			        = loadfx ("env/fire/fx_fire_win_nsmk_0x35y50z");
	level._effect["fire_wall_100_150"]	  	= loadfx ("env/fire/fx_fire_wall_smk_0x100y155z");
  level._effect["water_heavy_leak"]			    = loadfx ("env/water/fx_water_drips_hvy");
  level._effect["water_heavy_leak_long"]			    = loadfx ("env/water/fx_water_drips_hvy_long");
  level._effect["wire_sparks"]		          = loadfx ("env/electrical/fx_elec_wire_spark_burst");
  level._effect["wire_sparks_blue"]		      = loadfx ("env/electrical/fx_elec_wire_spark_burst_blue");
  level._effect["fire_distant_150_600"]			= loadfx ("env/fire/fx_fire_150x600_tall_distant");
  level._effect["water_pipe_leak_md"]		      = loadfx ("env/water/fx_wtr_pipe_spill_md");
  level._effect["water_pipe_leak_sm"]		      = loadfx ("env/water/fx_wtr_pipe_spill_sm");
  level._effect["water_spill_fall"]		      = loadfx ("env/water/fx_wtr_spill_sm_thin"); 
  level._effect["water_wake_md"]		      = loadfx ("env/water/fx_water_wake_flow_md");
  level._effect["water_leak_runner"]	  		= loadfx ("env/water/fx_water_leak_runner_100");
  level._effect["water_wake_sm"]		      = loadfx ("env/water/fx_water_wake_flow_sm");
  level._effect["water_wake_mist"]		      = loadfx ("env/water/fx_water_wake_flow_mist");
  level._effect["water_splash_md"]		      = loadfx ("env/water/fx_water_splash_leak_md");
  level._effect["debris_dust_motes"]		      = loadfx ("maps/ber2/fx_debris_dust_motes");  
	level._effect["fire_bookcase_wide"]			 = loadfx ("env/fire/fx_fire_bookshelf_wide");
	level._effect["fire_column_creep_xsm"]	 = loadfx ("env/fire/fx_fire_column_creep_xsm");
	level._effect["fire_column_creep_sm"]		 = loadfx ("env/fire/fx_fire_column_creep_sm");
	level._effect["smoke_room_fill"]			  	= loadfx ("maps/ber2/fx_smoke_fill_indoor");
	level._effect["ash_and_embers_hall"]			  	= loadfx ("maps/ber2/fx_debris_hall_ash_embers");
	level._effect["fire_detail"]			           = loadfx ("env/fire/fx_fire_debris_xsmall");
	level._effect["fire_ceiling_50_100"]			   = loadfx ("env/fire/fx_fire_ceiling_50x100");
	level._effect["fire_ceiling_100_100"]			   = loadfx ("env/fire/fx_fire_ceiling_100x100");
	level._effect["ash_and_embers_small"]			  	= loadfx ("maps/ber2/fx_debris_fire_motes");
	level._effect["god_rays_large"]					   = loadfx("env/light/fx_light_god_rays_large");	
	level._effect["god_rays_medium"]				   = loadfx("env/light/fx_light_god_rays_medium");	
	level._effect["god_rays_small"]					   = loadfx("env/light/fx_light_god_ray_sm_single");
	level._effect["god_rays_small_short"]			 = loadfx("env/light/fx_light_god_ray_sm_shrt_single");
	level._effect["god_rays_dust_motes"]			 = loadfx("env/light/fx_light_god_rays_dust_motes");
	level._effect["fog_thick"]		 			    = loadfx("env/smoke/fx_fog_rolling_thick_600x600");
  level._effect["falling_lf_elm"]       			= loadfx("env/foliage/fx_leaves_fall_elm");
  level._effect["light_ceiling_dspot"]		  = loadfx ("env/light/fx_ray_ceiling_amber_dim_sm");
  level._effect["dlight_fire_glow"]			       = loadfx ("env/light/fx_dlight_fire_glow");
  level._effect["fire_static_small"]			     = loadfx ("env/fire/fx_static_fire_sm_ndlight");
	level._effect["fire_static_blk_smk"]			   = loadfx ("env/fire/fx_static_fire_md_ndlight");
}



