//
// file: mak_fx.gsc
// description: clientside fx script for mak: setup, special fx functions, etc.
// scripter: 		(initial clientside work - laufer)
//

#include clientscripts\_utility; 
#include clientscripts\_fx;
#include clientscripts\_music;

main()
{
	clientscripts\createfx\nazi_zombie_asylum_fx::main();
	clientscripts\_fx::reportNumEffects();

	footsteps();
	precache_createfx_fx();
	
	disableFX = GetDvarInt( "disable_fx" );
	if( !IsDefined( disableFX ) || disableFX <= 0 )
	{
		precache_scripted_fx();
	}
	
	level thread trap_fx_monitor("auto246","north"); // north side	
	level thread trap_fx_monitor("auto242", "south");
	
	level thread zapper_switch_fx("north");
	level thread zapper_switch_fx("south");
	level thread electric_trap_wire_sparks("north");
	level thread electric_trap_wire_sparks("south");
	
	level thread perk_wire_fx("revive_on", "revive_electric_wire");
	level thread perk_wire_fx("middle_door_open", "electric_middle_door");
	level thread perk_wire_fx("fast_reload_on", "electric_fast_reload");
	level thread perk_wire_fx("doubletap_on", "electric_double_tap");
	level thread perk_wire_fx("jugger_on", "electric_juggernog");		
}

trap_fx_monitor(name,side)
{
	
	while(1)
	{
		level waittill(name);

		fire_points = getstructarray(name,"targetname");

		for(i=0;i<fire_points.size;i++)
		{
			fire_points[i] thread electric_trap_fx(name,side);		
		}

	}
	
}

electric_trap_fx(name,side)
{
	
	ang = self.angles;
	forward = anglestoforward(ang);
	up = anglestoup(ang);
	
	if ( isdefined( self.loopFX ) )
	{
		for(i = 0; i < self.loopFX.size; i ++)
		{
			self.loopFX[i] delete();
		}
		
		self.loopFX = [];
	}

	if(!isdefined(self.loopFX))
	{
		self.loopFX = [];
	}	
	
	players = getlocalplayers();
	
	for(i = 0; i < players.size; i++)
	{
		self.loopFX[i] = SpawnFx( i, level._effect["zapper"], self.origin, 0,forward,up);
		triggerfx(self.loopFX[i]);
	}
	
	level waittill(side + "off");
	//wait(30 );

	for(i = 0; i < self.loopFX.size; i ++)
	{
		self.loopFX[i] delete();
	}
	
	self.loopFX = [];

/*	if(isDefined(self.script_sound))
	{
		self.tag_origin playsound("elec_start");
		self.tag_origin playloopsound("elec_loop");
		self thread play_electrical_sound();
	}
	wait(30);
	wait(randomfloat(2));
	if(isDefined(self.script_sound))
	{
		self.tag_origin stoploopsound();
	}
	self.tag_origin delete();
	wait(2);
	notify_ent notify("elec_done");
	level notify ("arc_done"); */
		
}

//zapper_light_red(side)
//{
//	
//	lightfx = spawnstruct();
//	
//	if(side == "north")
//	{
//
//		lightfx.origin = (366, 480 ,324);
//		lightfx.angles = (0,270,0);
//	}
//	else
//	{
//		lightfx.origin = (168, -407.5, 324);
//		lightfx.angles = (0,90,0);	
//	}	
//	
//	ang = lightfx.angles;
//	forward = anglestoforward(ang);
//	up = anglestoup(ang);	
//	
//	
//	while(1)
//	{
//		
//		
//		if ( isdefined( lightfx.loopFX ) )
//		{
//			for(i = 0; i < lightfx.loopFX.size; i ++)
//			{
//				lightfx.loopFX[i] delete();
//			}
//			
//			lightfx.loopFX = [];
//		}
//	
//		if(!isdefined(lightfx.loopFX))
//		{
//			lightfx.loopFX = [];
//		}	
//		
//		players = getlocalplayers();
//		
//		for(i = 0; i < players.size; i++)
//		{
//			lightfx.loopFX[i] = SpawnFx( i, level._effect["zapper"], lightfx.origin, 0,forward,up);
//			triggerfx(lightfx.loopFX[i]);
//		}	
//	}
//
//}
//
//
//zapper_light_green(side)
//{
//
//}



/*------------------------------------
handles playing the zapper switch FX 
as well as the fx aroudn the zapper machine too
------------------------------------*/
zapper_switch_fx(ent)
{
	switchfx = getstruct("zapper_switch_fx_" + ent,"targetname");
	zapperfx = getstruct ("zapper_fx_" + ent,"targetname");
	
	switch_forward = anglestoforward(switchfx.angles);
	switch_up = anglestoup(switchfx.angles);
	
	zapper_forward = anglestoforward(zapperfx.angles);	
	zapper_up = anglestoup(zapperfx.angles);	

		
	while(1)
	{
		level waittill(ent);
		if ( isdefined( switchfx.loopFX ) )
		{
			for(i = 0; i < switchfx.loopFX.size; i ++)
			{
				switchfx.loopFX[i] delete();
				zapperfx.loopFX[i] delete();
			}		
			switchfx.loopFX = [];
			zapperfx.loopFX = [];
		}

		if(!isdefined(switchfx.loopFX))
		{
			switchfx.loopFX = [];
			zapperfx.loopFX = [];
		}	
	
		players = getlocalplayers();
		
		//zapper wall switch fx
		for(i = 0; i < players.size; i++)
		{
			switchfx.loopFX[i] = SpawnFx( i, level._effect["zapper_wall"], switchfx.origin, 0,switch_forward,switch_up);
			triggerfx(switchfx.loopFX[i]);
			
			zapperfx.loopFX[i] = SpawnFx( i, level._effect["zapper_fx"], zapperfx.origin, 0,zapper_forward,zapper_up);
			triggerfx(zapperfx.loopFX[i]);	
		}
		
		realwait(30 );

		for(i = 0; i < switchfx.loopFX.size; i ++)
		{
			switchfx.loopFX[i] delete();
			zapperfx.loopFX[i] delete();
		}
	
		switchfx.loopFX = [];
		zapperfx.loopFX = [];
	}	
}
perk_wire_fx(notify_wait, init_targetname)
{

	level waittill(notify_wait);
//	sparks = getstruct(init_targetname,"targetname");
	
	targ = getstruct(init_targetname,"targetname");
		
		while(isDefined(targ))
		{
			//fx_org moveto(targ.origin,.075);
			//Kevin adding playloop on electrical fx
			
			players = getlocalplayers();
			for(i = 0; i < players.size;i++)
			{
				playfx(i, level._effect["electric_short_oneshot"], targ.origin);
			}
			realwait(0.075);
			
			//targ playsound("elec_current_loop");
			//fx_org waittill("movedone");
			
			if(isDefined(targ.target))
			{
				targ = getstruct(targ.target,"targetname");
			}
			else
			{
				targ = undefined;
			}
		}

}

electric_trap_wire_sparks(side)
{
	while(1)
	{
		level waittill(side);
		ent = getstruct("trap_wire_sparks_"+ side,"targetname");
		ent.fx = 1;
		ent thread electric_trap_wire_sparks_stop();
		while(isDefined(ent.fx))
		{
			targ = getstruct(ent.target,"targetname");
					
			while(isDefined(targ))
			{
				players = getlocalplayers();
				for(i = 0; i < players.size;i++)
				{
					if(randomint(100) > 50)
					{
						playfx(i, level._effect["electric_short_oneshot"], targ.origin);
					}
				}
				realwait(0.075);
							
				if(isDefined(targ.target))
				{
					targ = getstruct(targ.target,"targetname");
				}
				else
				{
					targ = undefined;
				}				
			}
			wait(randomintrange(10,15));
		}
	}
}
electric_trap_wire_sparks_stop()
{
	realwait(30);
	self.fx = undefined;
}




precache_scripted_fx()
{
	level._effect["zombie_grain"]	= LoadFx( "misc/fx_zombie_grain_cloud" );
	level._effect["electric_short_oneshot"] = loadfx("env/electrical/fx_elec_short_oneshot");
	level._effect["switch_sparks"] = loadfx ("env/electrical/fx_elec_wire_spark_burst");
	
	level._effect["zapper_fx"] = loadfx("misc/fx_zombie_zapper_powerbox_on");
	level._effect["zapper_wall"] = loadfx("misc/fx_zombie_zapper_wall_control_on");
	level._effect["elec_trail_one_shot"] = loadfx("misc/fx_zombie_elec_trail_oneshot");
	
	level._effect["zapper_light_ready"] = loadfx("misc/fx_zombie_zapper_light_green");
	level._effect["zapper_light_notready"] = loadfx("misc/fx_zombie_zapper_light_red");
	level._effect["wire_sparks_oneshot"] = loadfx("env/electrical/fx_elec_wire_spark_dl_oneshot");


	
	
	
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
 
  level._effect["water_drip_sm_area"]				 = loadfx("maps/mp_maps/fx_mp_water_drip"); 
	level._effect["water_spill_long"]					 = loadfx("maps/mp_maps/fx_mp_water_spill_long");
	level._effect["water_drips_hvy_long"]			 = loadfx("maps/mp_maps/fx_mp_water_drips_hvy_long");
	level._effect["water_spill_splatter"]			 = loadfx("maps/mp_maps/fx_mp_water_spill_splatter");
	level._effect["water_splash_small"]				= loadfx("maps/mp_maps/fx_mp_water_splash_small");

	level._effect["wire_sparks"]					    = loadfx("env/electrical/fx_elec_wire_spark_burst");
	level._effect["wire_sparks_blue"]			   	= loadfx("env/electrical/fx_elec_wire_spark_burst_blue");
  
  level._effect["betty_explode"]			= loadfx("weapon/bouncing_betty/fx_explosion_betty_generic");
	level._effect["betty_trail"]				= loadfx("weapon/bouncing_betty/fx_betty_trail");
	level._effect["zapper"]							= loadfx("misc/fx_zombie_electric_trap");
	level._effect["switch_sparks"]			= loadfx("env/electrical/fx_elec_wire_spark_burst");
}



