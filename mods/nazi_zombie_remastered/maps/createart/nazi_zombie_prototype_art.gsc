//_createart generated.  modify at your own risk. Changing values should be fine.

main()
{

	level.tweakfile = true;
 
	// *Fog section* 

	setdvar("scr_fog_exp_halfplane", "418"); // OG 835
	setdvar("scr_fog_exp_halfheight", "200");
	setdvar("scr_fog_nearplane", "165");
	setdvar("scr_fog_red", "0.5");
	setdvar("scr_fog_green", "0.5");
	setdvar("scr_fog_blue", "0.5");
	setdvar("scr_fog_baseheight", "50");

//	// *depth of field section* 
//	level.do_not_use_dof = true;
//	level.dofDefault["nearStart"] = 0;
//	level.dofDefault["nearEnd"] = 60;
//	level.dofDefault["farStart"] = 2000;
//	level.dofDefault["farEnd"] = 10000;
//	level.dofDefault["nearBlur"] = 6;
//	level.dofDefault["farBlur"] = 2;
//
//	players = maps\_utility::get_players();
//	for( i = 0; i < players.size; i++ )
//	{
//		players[i] maps\_art::setdefaultdepthoffield();
//	}
	
	setdvar("visionstore_glowTweakEnable", "1"); 
	setdvar("visionstore_glowTweakRadius0", "5");
	setdvar("visionstore_glowTweakRadius1", "5");
	setdvar("visionstore_glowTweakBloomCutoff", "0.5");
	setdvar("visionstore_glowTweakBloomDesaturation", "0");
	setdvar("visionstore_glowTweakBloomIntensity0", "2");
	setdvar("visionstore_glowTweakBloomIntensity1", "2");
	setdvar("visionstore_glowTweakSkyBleedIntensity0", "0.29");
	setdvar("visionstore_glowTweakSkyBleedIntensity1", "0.29");

	level thread fog_settings();
 
	level thread maps\_utility::set_all_players_visionset( "oki2", 0.1 );
}

fog_settings()
{
	start_dist 			= 165;
	halfway_dist 		= 418; //originally 835
	halfway_height 		= 200;
	base_height 		= 75;
	red 				= 0.5;
	green 				= 0.5;
	blue		 		= 0.5;
	trans_time			= 0;
	
	if( IsSplitScreen() )
	{
		start_dist 			= 112;
		halfway_dist 		= 835;
		halfway_height 		= 100;
		cull_dist 			= 4000;
		maps\_utility::set_splitscreen_fog( start_dist, halfway_dist, halfway_height, base_height, red, green, blue, trans_time, cull_dist );
	}
	else
	{
		SetVolFog( start_dist, halfway_dist, halfway_height, base_height, red, green, blue, trans_time );
	}
}