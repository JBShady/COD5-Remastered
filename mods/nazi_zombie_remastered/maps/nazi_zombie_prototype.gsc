#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_music; 


main()
{
	maps\_destructible_opel_blitz::init();
	level.startInvulnerableTime = 1000;

	level.achievement_notify_func = maps\_zombiemode_utility::achievement_notify;

	precachestring(&"REMASTERED_ZOMBIE_INTRO_PROTO_LEVEL_PLACE");
	precachestring(&"REMASTERED_ZOMBIE_INTRO_PROTO_LEVEL_TIME");
	precachemodel("char_usa_raider_gear_flametank");
	precachemodel("satchel_crate");
	precachemodel("satchel_crate_lid");
	precachemodel("satchel_crate_lid_question");
	precachemodel("collision_geo_64x64x64");

	include_weapons();
	include_powerups();
	
	if( !isdefined( level.startInvulnerableTime ) )
		level.startInvulnerableTime = GetDvarInt( "player_deathInvulnerableTime" );

	maps\nazi_zombie_prototype_fx::main();
	maps\_zombiemode::main();

	init_sounds();
	init_achievement();

	level thread bad_area_fixes();
	level thread above_couches_death();
	level thread above_roof_death();
	level thread below_ground_death();
	
	maps\_zombiemode_health_help::init();
	//maps\_zombiemode_coord_help::init();

	maps\walking_anim::main();

	level thread intro_screen();

	players = get_players(); 

	
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread player_killstreak_timer();
		players[i] thread player_zombie_awareness();
	}
	
	if(players.size == 4)
	{
		players[3] thread level_pre_start_vox();
	}

	//players[randomint(players.size)] thread level_start_vox();
	level thread level_start_vox();

	level thread prototype_eggs();
	level thread play_music_easter_egg();

	spawncollision("collision_geo_64x64x64","collider",(level.satchel_crate_lid.origin + (8,0,5)), (level.satchel_crate_lid.angles) + (0,23,0));
	
/*	pillar_coords = ( 360, 357, 40 );
	pillar_angles = (0,-5,0);
	pillar = Spawn( "script_model", pillar_coords ); 
	pillar setmodel("collision_geo_64x64x64");
	pillar.angles = pillar_angles;
	spawncollision("collision_geo_64x64x64","collider", pillar_coords, pillar_angles );
*/
/*	barrier_coords = ( -237.5, 430, 40 );
	barrier_angles = (0,-7.5,0);
	barrier = Spawn( "script_model", barrier_coords ); 
	barrier setmodel("collision_geo_64x64x64");
	barrier.angles = barrier_angles;
	spawncollision("collision_geo_64x64x64","collider", barrier_coords, barrier_angles );
*/
	// If you want to modify/add to the weapons table, please copy over the _zombiemode_weapons init_weapons() and paste it here.
	// I recommend putting it in it's own function...
	// If not a MOD, you may need to provide new localized strings to reflect the proper cost.
}

init_achievement()
{
	include_achievement( "achievement_barriers" );
	include_achievement( "achievement_starman" );
	include_achievement( "achievement_lawn" );
	include_achievement( "achievement_upstairs" );
	include_achievement( "achievement_flamethrower" );
	include_achievement( "achievement_barrels" );
	include_achievement( "achievement_mortar" );
	include_achievement( "achievement_magicbox" );
	include_achievement( "achievement_laststand" );
	include_achievement( "achievement_radio" );
}

bad_area_fixes()
{
	level thread disable_stances_in_zones();
}


// do point->distance checks and volume checks
disable_stances_in_zones()
{ 	
 	players = get_players();
 	
 	for (i = 0; i < players.size; i++)
 	{
 		players[i] thread fix_hax();
		players[i] thread fix_couch_stuckspot();
 		//players[i] thread in_bad_zone_watcher();	
 		players[i] thread out_of_bounds_watcher();
 	}
}




//Chris_P - added additional checks for some hax/exploits on the stairs, by the grenade bag and on one of the columns/pillars
fix_hax()
{
	self endon("disconnect");
	self endon("death");
	
	check = 15;
	check1 = 10;
	
	while(1)
	{
	
		//stairs
		wait(.5);
		if( distance2d(self.origin,( 101, -100, 40)) < check )
		{
			self setorigin ( (101, -90, self.origin[2]));
		}
		
		//crates/boxes
		else if( distance2d(self.origin, ( 816, 645, 12) ) < check )
		{
			self setorigin ( (816, 666, self.origin[2]) );
		
		}
		
		else if( distance2d( self.origin, (376, 643, 184) ) < check )
		{
			self setorigin( (376, 665, self.origin[2]) );
		}
		
		//by grandfather clock
		else	if(distance2d(self.origin,(519 ,765, 155)) < check1) 
		{
			self setorigin( (516, 793,self.origin[2]) );
		}
		
		//broken pillar
		else if( distance2d(self.origin,(315 ,346, 79))<check1)
		{
			self setorigin( (317, 360, self.origin[2]) );
		}
	
		//rubble by pillar
		else if( distance2d(self.origin,(199, 133, 18))<check)
		{
			self setorigin( (172, 123, self.origin[2]) );
		}
		
		//nook in curved stairs
		else if( distance2d(self.origin,(142 ,-100 ,91))<check1)
		{
			self setorigin( (139 ,-87, self.origin[2]) );
		}
		
		//by sawed off shotty				
		else if( distance2d(self.origin,(192, 369 ,185))<check1)
		{
			self setorigin( (195, 400 ,self.origin[2]) );
		}
		
		//rubble pile in the corner
		else if( distance2d(self.origin,(-210, 641, 247)) < check)
		{
			self setorigin( (-173 ,677,self.origin[2] ) );
		}

	}
		
}



fix_couch_stuckspot()
{
	self endon("disconnect");
	self endon("death");
	level endon("upstairs_blocker_purchased");

	while(1)
	{
		wait(.5);

		if( distance2d(self.origin, ( 181, 161, 206) ) < 10 )
		{
			self setorigin ( (175, 175 , self.origin[2]) );
		
		}		
		
	}

}




in_bad_zone_watcher()
{
	self endon ("disconnect");
	level endon ("fake_death");
	
	no_prone_and_crouch_zones = [];
 	
 	// grenade wall
 	no_prone_and_crouch_zones[0]["min"] = (-205, -128, 144);
 	no_prone_and_crouch_zones[0]["max"] = (-89, -90, 269);
 
  	no_prone_zones = [];
  	
  	// grenade wall
  	no_prone_zones[0]["min"] = (-205, -128, 144);
 	no_prone_zones[0]["max"] = (-55, 30, 269);

	// near the sawed off
  	no_prone_zones[1]["min"] = (88, 305, 144);
 	no_prone_zones[1]["max"] = (245, 405, 269);
 	
	while (1)
 	{	
		array_check = 0;
		
		if ( no_prone_and_crouch_zones.size > no_prone_zones.size)
		{
			array_check = no_prone_and_crouch_zones.size;
		}
		else
		{
			array_check = no_prone_zones.size;
		}
		
 		for(i = 0; i < array_check; i++)
 		{
 			if (isdefined(no_prone_and_crouch_zones[i]) && 
 				self is_within_volume(no_prone_and_crouch_zones[i]["min"][0], no_prone_and_crouch_zones[i]["max"][0], 
 											no_prone_and_crouch_zones[i]["min"][1], no_prone_and_crouch_zones[i]["max"][1],
 											no_prone_and_crouch_zones[i]["min"][2], no_prone_and_crouch_zones[i]["max"][2]))
 			{
 				self allowprone(false);
 				self allowcrouch(false);	
 				break;
 			}
 			else if (isdefined(no_prone_zones[i]) && 
 				self is_within_volume(no_prone_zones[i]["min"][0], no_prone_zones[i]["max"][0], 
 											no_prone_zones[i]["min"][1], no_prone_zones[i]["max"][1],
 											no_prone_zones[i]["min"][2], no_prone_zones[i]["max"][2]))
 			{
 				self allowprone(false);
 				break;
 			}
 			else
 			{
 				self allowprone(true);
 				self allowcrouch(true);
 			}
 			
 			
 		}		
 		wait 0.05;
 	}	
}


is_within_volume(min_x, max_x, min_y, max_y, min_z, max_z)
{
	if (self.origin[0] > max_x || self.origin[0] < min_x)
	{
		return false;
	}
	else if (self.origin[1] > max_y || self.origin[1] < min_y)
	{
		return false;
	}
	else if (self.origin[2] > max_z || self.origin[2] < min_z)
	{
		return false;
	}	
	
	return true;
}

init_sounds()
{
	maps\_zombiemode_utility::add_sound( "break_stone", "break_stone" );
}

// Include the weapons that are only inr your level so that the cost/hints are accurate
// Also adds these weapons to the random treasure chest.
include_weapons()
{
	// Pistols
	include_weapon( "zombie_colt", false ); // Only a starting weapon
	include_weapon( "sw_357" );
	
	// Semi Auto
	include_weapon( "m1carbine" );
	include_weapon( "m1garand" );
	include_weapon( "gewehr43" );
	include_weapon( "svt40" ); // new

	// Full Auto
	include_weapon( "stg44" );
	include_weapon( "thompson" );
	include_weapon( "mp40" );
	include_weapon( "ppsh" ); // new
	include_weapon( "type100_smg" );  // new

	// Bolt Action

	include_weapon( "kar98k" );
	include_weapon( "springfield" );

	// Scoped
	include_weapon( "ptrs41_zombie" );
	include_weapon( "kar98k_scoped_zombie", false ); // Only in cabinet
		
	// Grenade
	include_weapon( "molotov" );
	include_weapon( "stielhandgranate", false ); // Only a wallbuy

	// Grenade Launcher
	include_weapon( "m1garand_gl" );
	include_weapon( "m7_launcher" ); 
	
	// Flamethrower
	include_weapon( "m2_flamethrower_zombie" );
	
	// Shotgun
	include_weapon( "doublebarrel" );
	include_weapon( "doublebarrel_sawed_grip" );
	include_weapon( "shotgun" );
	
	// Heavy MG
	include_weapon( "fg42_bipod" );
	include_weapon( "bar" );
	include_weapon( "mg42_bipod" );
	include_weapon( "30cal_bipod" );
	//include_weapon( "type99_lmg" ); // map1-2 excluded, japanese
	//include_weapon( "dp28" ); // map1-2 excluded, russian

	// Rocket Launcher
	include_weapon( "panzerschrek" );

	// Special
	include_weapon( "ray_gun" );
	include_weapon( "mortar_round" );
	include_weapon( "satchel_charge", false ); // Only in crate
	//include_weapon( "falling_hands", false ); // Death anim

	maps\_zombiemode_weapons::add_limited_weapon( "zombie_colt", 0 );

}

include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "carpenter" );
}

include_weapon( weapon_name, in_box )
{
	if( !isDefined( in_box ) )
	{
		in_box = true;
	}
	maps\_zombiemode_weapons::include_zombie_weapon( weapon_name, in_box );
}

include_powerup( powerup_name )
{
	maps\_zombiemode_powerups::include_zombie_powerup( powerup_name );
}


above_couches_death()
{
	level endon ("junk purchased");
	
	while (1)
	{
		wait 0.2;
				
		players = get_players();
		
		for (i = 0; i < players.size; i++)
		{
			if (players[i].origin[2] > 145)
			{
				setsaveddvar("player_deathInvulnerableTime", 0);
				players[i] DoDamage( players[i].health + 1000, players[i].origin, undefined, undefined, "riflebullet" );
				setsaveddvar("player_deathInvulnerableTime", level.startInvulnerableTime);	
			}
		}
	}
}

above_roof_death()
{
	while (1)
	{
		wait 0.2;
		
		players = get_players();
		
		for (i = 0; i < players.size; i++)
		{
			if (players[i].origin[2] > 235)
			{
				setsaveddvar("player_deathInvulnerableTime", 0);
				players[i] DoDamage( players[i].health + 1000, players[i].origin, undefined, undefined, "riflebullet" );
				setsaveddvar("player_deathInvulnerableTime", level.startInvulnerableTime);	
			}
		}
	}
}

below_ground_death()
{
	while (1)
	{
		wait 0.2;
		
		players = get_players();
		
		for (i = 0; i < players.size; i++)
		{
			if (players[i].origin[2] < -11)
			{
				setsaveddvar("player_deathInvulnerableTime", 0);
				players[i] DoDamage( players[i].health + 1000, players[i].origin, undefined, undefined, "riflebullet" );
				setsaveddvar("player_deathInvulnerableTime", level.startInvulnerableTime);	
			}
		}
	}
}


out_of_bounds_watcher()
{
	self endon ("disconnect");
	
	outside_of_map = [];
 	
 	outside_of_map[0]["min"] = (361, 591, -11);
 	outside_of_map[0]["max"] = (1068, 1031, 235);
 	
 	outside_of_map[1]["min"] = (-288, 591, -11);
 	outside_of_map[1]["max"] = (361, 1160, 235);
 	
 	outside_of_map[2]["min"] = (-272, 120, -11);
 	outside_of_map[2]["max"] = (370, 591, 235);

 	outside_of_map[3]["min"] = (-272, -912, -11);
 	outside_of_map[3]["max"] = (273, 120, 235);
 	 	
	while (1)
 	{	
		array_check = outside_of_map.size;
		
		kill_player = true;
 		for(i = 0; i < array_check; i++)
 		{
 			if (self is_within_volume(	outside_of_map[i]["min"][0], outside_of_map[i]["max"][0], 
 										outside_of_map[i]["min"][1], outside_of_map[i]["max"][1],
 										outside_of_map[i]["min"][2], outside_of_map[i]["max"][2]))
 			{
 				kill_player = false;

 			} 			
 		}		
 		
 		if (kill_player)
 		{
 			setsaveddvar("player_deathInvulnerableTime", 0);
			self DoDamage( self.health + 1000, self.origin, undefined, undefined, "riflebullet" );
			setsaveddvar("player_deathInvulnerableTime", level.startInvulnerableTime);	
 		}
 		
 		wait 0.2;
 	}	
}

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
	
	
	level.intro_hud[0] settext(&"REMASTERED_ZOMBIE_INTRO_PROTO_LEVEL_PLACE");
	level.intro_hud[1] settext(&"REMASTERED_ZOMBIE_INTRO_PROTO_LEVEL_TIME");

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
level_pre_start_vox()
{
	wait( 6 );
	plr = "plr_3_";
	self thread create_and_play_dialog( plr, "vox_level_intro", 0.25 );

}

level_start_vox()
{
	wait( 10 );
	
	players = get_players(); 

	for( i = 0; i < players.size; i++ )
	{
		players[i].has_talked = 0;
		for(;;)
		{
			zombies = getaiarray("axis" );
			close_zombies = get_array_of_closest( players[i].origin, zombies, undefined, undefined, 600 );
			
			for( j = 0; j < zombies.size; j++ )
			{
				if ( (players[i] IsLookingAt(zombies[j]) || close_zombies.size > 0 || players[i].score_total > 500) && players[i].has_talked == 0 )
				{
					players[i].has_talked = 1;
					index = maps\_zombiemode_weapons::get_player_index( players[i] );
					plr = "plr_" + index + "_";
					players[i] thread create_and_play_dialog( plr, "vox_level_start", 0.25 );
					break;
				}
				else
				{
					wait(0.1);
					continue;
				}
			}
			if(players[i].has_talked == 1)
			{
				break;
			}
			wait(0.05);
		}
	}
}


player_zombie_awareness()
{
	self endon("disconnect");
	self endon("death");
	self endon("end_game_quiet");

	wait(6);
	players = getplayers();
	index = maps\_zombiemode_weapons::get_player_index(self);
	while(1)
	{
		wait(1);		
		//zombie = get_closest_ai(self.origin,"axis");
		if( self maps\_laststand::player_is_in_laststand() ) // Prevent breathing near vox/player surrounded vox & behind zombie vocals when player is down, not needed.
		{
			continue;
		}

		zombs = getaiarray("axis");
		for(i=0;i<zombs.size;i++)
		{
			if(DistanceSquared(zombs[i].origin, self.origin) < 175 * 175)
			{
				if(!isDefined(zombs[i]))
				{
					continue;
				}

				
				dist = 175;				
				switch(zombs[i].zombie_move_speed)
				{
					case "walk": dist = 150;break;
					case "run": dist = 130; break;
					case "sprint": dist = 110;break;
				}				
				if(distance2d(zombs[i].origin,self.origin) < dist && (zombs[i].origin[2] < self.origin[2] + 80 && zombs[i].origin[2] > self.origin[2] - 80) )
				{				
					yaw = self animscripts\utility::GetYawToSpot(zombs[i].origin );
					//check to see if he's actually behind the player
					if(yaw < -100 || yaw > 100)
					{
						if(randomintrange(0,10) < 3 )
						{
							//zombs[i] playsound ("behind_vocals");
							plr = "plr_" + index + "_";
							self thread create_and_play_dialog( plr, "vox_near", 0.05 );
						}
						else if(level.player_is_speaking != 1) // nacht is scarier: only 80% chance of behind vocals, only when player isnt talking, and they're quieter
						{
							zombs[i] playsound ("behind_vocals");
						}
					}
				}				
			}
		}

		if(players.size > 0) //NEW
		{
			close_zombs = 0;
			for(i=0;i<zombs.size;i++)
			{
				if(DistanceSquared(zombs[i].origin, self.origin) < 250 * 250 && (zombs[i].origin[2] < self.origin[2] + 80 && zombs[i].origin[2] > self.origin[2] - 80) )
				{
					close_zombs ++;
				}
			}
			if(close_zombs > 4 && players.size > 1)
			{
				if(randomintrange(0,20) <= 5) // slightly hider odds than dlc2/dlc3, players less likely to be surviving while surrounded since no jug and tighter map plus we have behind vocals that can get in the way
				{
					plr = "plr_" + index + "_";
					self thread create_and_play_dialog( plr, "vox_oh_shit", .25, "resp_ohshit" );	
				}
			}
			else if(close_zombs > 7 && players.size == 1) // requires 1/3 of a horde on solo (8 out of 24)
			{
				if(randomintrange(0,20) <= 3) // slightly hider odds than dlc2/dlc3, players less likely to be surviving while surrounded since no jug and tighter map plus we have behind vocals that can get in the way
				{
					plr = "plr_" + index + "_";
					self thread create_and_play_dialog( plr, "vox_oh_shit", .25 );	
				}
			}
		}
	}
}

prototype_eggs()
{
	trigs = getentarray ("explodable_barrel", "targetname");
	for(i=0;i<trigs.size;i++)
	{
		trigs[i] thread check_for_barrel_explode();
	}	

	//what else can i do
}

check_for_barrel_explode()
{
	if(!IsDefined (level.egg_damage_counter))
	{
		level.egg_damage_counter = 0;		
	}
	self waittill ("damage");
	level.egg_damage_counter = level.egg_damage_counter + 1;
}

play_music_easter_egg()
{

	if(!IsDefined (level.egg_damage_counter))
	{
		level.egg_damage_counter = 0;		
	}
	if (!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}

	while(level.egg_damage_counter < 31)
	{ 
		wait(0.5);
	}
	
	level.eggs = 1;
	setmusicstate("eggs");
	wait(234);	

	setmusicstate("WAVE_1");
	level.eggs = 0;

}