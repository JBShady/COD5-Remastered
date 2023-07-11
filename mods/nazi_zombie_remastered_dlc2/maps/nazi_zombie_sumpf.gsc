#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_music;
#include maps\nazi_zombie_sumpf_perks;
#include maps\nazi_zombie_sumpf_zone_management;
#include maps\nazi_zombie_sumpf_magic_box;
#include maps\nazi_zombie_sumpf_trap_pendulum;
//#include maps\nazi_zombie_sumpf_trap_electric;
//#include maps\nazi_zombie_sumpf_trap_propeller;
//#include maps\nazi_zombie_sumpf_trap_barrel;
#include maps\nazi_zombie_sumpf_bouncing_betties;
#include maps\nazi_zombie_sumpf_zipline;
#include maps\nazi_zombie_sumpf_bridge;
//#include maps\nazi_zombie_sumpf_ammo_box;
#include maps\nazi_zombie_sumpf_blockers;
#include maps\nazi_zombie_sumpf_trap_perk_electric;
#include maps\_hud_util;

main()
{
	// make sure we randomize things in the map once
	level.randomize_perks = false;
	
	// JMA - used to modify the percentages of pulls of ray gun and tesla gun in magic box
	level.pulls_since_last_ray_gun = 0;
	level.pulls_since_last_tesla_gun = 0;
	level.player_drops_tesla_gun = false;
	
	//Needs to be first for CreateFX
	maps\nazi_zombie_sumpf_fx::main();
	
	// enable for dog rounds
	level.dogs_enabled = true;

	// enable for zombie risers within active player zones
	level.zombie_rise_spawners = [];
	
	// JV contains zombies allowed to be on fire
	level.burning_zombies = [];
	
	// JV volume and bridge for bridge riser blocker
	//level.bridgeriser = undefined;
	//level.brVolume = undefined;

	level.use_zombie_heroes = true;
		
	level thread maps\_callbacksetup::SetupCallbacks();

	level.character_tasks_completed = 0; // for our 4 player tasks, compare to playercount	
	level.sack_has_been_found = 0; // for flogger step
	level.meteor_ready = 0; // for our 20 zaps
	
	//precachestring(&"ZOMBIE_BETTY_ALREADY_PURCHASED");
	precachestring(&"REMASTERED_ZOMBIE_BETTY_HOWTO");
//	precachestring(&"ZOMBIE_AMMO_BOX");
	precachestring(&"REMASTERED_ZOMBIE_INTRO_SUMPF_LEVEL_PLACE");
	precachestring(&"REMASTERED_ZOMBIE_INTRO_SUMPF_LEVEL_TIME");
	
//	PrecacheShader( "richtofen_diary" );
//	PrecacheShader( "richtofen_diary_gold" );

	PrecacheShader( "hud_rope" );

	PrecacheShader( "hud_sack" );
	PrecacheShader( "hud_sack_one" );
	PrecacheShader( "hud_sack_two" );
	PrecacheShader( "hud_sack_three" );
	PrecacheShader( "hud_sack_final" );

	//ESM - red and green lights for the traps
	precachemodel("char_usa_raider_gear_flametank");
	precachemodel("zombie_zapper_cagelight_red");
	precachemodel("zombie_zapper_cagelight_green");
	precacheshellshock("electrocution");

	precachemodel("viewmodel_usa_no_model");

	// SACK & METEOR
	precachemodel("grenade_bag");
	precachemodel("fx_debris_meteor_115");
	// ROPE
	precachemodel("kwai_thickrope"); 
	precachemodel("anim_nazi_flag_burnt_rope");

	// RADIO
	PrecacheItem( "zombie_item_radio" );
	precachemodel("prop_mp_handheld_radio");
	// VODKA
	PrecacheItem( "zombie_item_vodka" );
	precachemodel( "static_berlin_mortarpestle" );
	precachemodel( "clutter_peleliu_wood_ammo_box_closed_wet" );
	precachemodel("vodka_bottle");

	// KATANA
	PrecacheItem( "zombie_item_katana" ); // when giving, make sure to set player.has_katana for gibbing
	precachemodel("weapon_jap_katana_long"); // change model?
	precachemodel("weapon_jap_katana_long_alt"); // change model?

	// JOURNAL
	PrecacheItem( "zombie_item_journal" );
	PrecacheItem( "zombie_item_journal_writing" );
	precachemodel("static_berlin_books_diary"); // model on shelf



	level.radio_fin = false;
	
	//JV - shellshock for player zipline damage
	precacheshellshock("death");

	// If you want to modify/add to the weapons table, please copy over the _zombiemode_weapons init_weapons() and paste it here.
	// I recommend putting it in it's own function...
	// If not a MOD, you may need to provide new localized strings to reflect the proper cost.	
	include_weapons();
	include_powerups();

	maps\_zombiemode::main();
    maps\nazi_zombie_sumpf_blockers::init();
	maps\walking_anim::main();
	//maps\_zombiemode_coord_help::init();
	maps\_zombiemode_health_help::init();

	//init_sounds();
	init_zombie_sumpf();
	
	level thread toilet_useage();
	level thread radio_one();
	level thread radio_two();
	level thread radio_three();
	level thread radio_eggs();
	level thread battle_radio();
	level thread whisper_radio();
	level thread meteor_trigger();

	level thread book_useage();
	// JMA - make sure tesla gun gets added into magic box after round 5
//	maps\_zombiemode_weapons::add_limited_weapon( "tesla_gun", 0);
	
//	level thread add_tesla_gun();


	level thread intro_screen();

	players = get_players(); 

	//initialize killstreak dialog	
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread player_killstreak_timer();
		
		//initialize zombie behind vox 
		players[i] thread player_zombie_awareness();
	}		
	
	players[randomint(players.size)] thread level_start_vox(); //Plays an intro message from a random player at start


}
add_tesla_gun()
{
	while(1)
	{
		level waittill( "between_round_over" );
		if(level.round_number >= 5)
		{
			maps\_zombiemode_weapons::add_limited_weapon( "tesla_gun", 1);
			break;	
		}
	}
}




// Include the weapons that are only inr your level so that the cost/hints are accurate
// Also adds these weapons to the random treasure chest.
include_weapons()
{
	// Pistols
	include_weapon( "zombie_colt", false );
	include_weapon( "zombie_tokarev", false );
	include_weapon( "zombie_nambu", false );
	include_weapon( "zombie_walther", false );

	include_weapon( "sw_357" );
	
	// Semi Auto
	include_weapon( "zombie_m1carbine" );
	include_weapon( "zombie_m1garand" );
	include_weapon( "zombie_gewehr43" );
	include_weapon( "zombie_type99_rifle" );
	include_weapon( "zombie_svt40" );

	// Full Auto
	include_weapon( "zombie_stg44" );
	include_weapon( "zombie_thompson" );
	include_weapon( "zombie_mp40" );
	include_weapon( "zombie_type100_smg" );
	include_weapon( "zombie_ppsh" );

	// Bolt Action
	//include_weapon( "springfield" );	// replaced with type99_rifle

	// Scoped
	//include_weapon( "mosin_rifle_scoped_zombie" );
	include_weapon( "ptrs41_zombie" );
	//include_weapon( "kar98k_scoped_zombie" );	// replaced with type99_rifle_scoped
	include_weapon( "type99_rifle_scoped_zombie" );	//
		
	// Grenade
	include_weapon( "molotov" );
	include_weapon( "st_grenade" );
	include_weapon( "stielhandgranate", false );

	// Grenade Launcher	
	include_weapon( "m1garand_gl_zombie" );
	include_weapon( "m7_launcher_zombie" );
	
	// Flamethrower
	include_weapon( "m2_flamethrower_zombie" );
	
	// Shotgun
	include_weapon( "zombie_doublebarrel" );
	include_weapon( "zombie_doublebarrel_sawed" );
	include_weapon( "zombie_shotgun" );

	// Heavy MG
	include_weapon( "zombie_bar" );
	include_weapon( "zombie_dp28" );
	include_weapon( "zombie_30cal" );
	include_weapon( "zombie_fg42" );
	include_weapon( "zombie_mg42" );
	include_weapon( "zombie_type99_lmg" );

	// Rocket Launcher
	include_weapon( "bazooka_zombie" );

	// Special
	include_weapon( "ray_gun" );
	include_weapon( "tesla_gun" );
	//bouncing betties
	include_weapon("mine_bouncing_betty", false);

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
	maps\_zombiemode_weapons_sumpf::include_zombie_weapon( weapon_name, in_box );
}


include_powerup( powerup_name )
{
	maps\_zombiemode_powerups::include_zombie_powerup( powerup_name );
}
	
spawn_initial_outside_zombies( name )
{
	// don't spawn in zombies in dog rounds
	if(flag("dog_round"))
		return;
		
	// make sure we spawn zombies only during the round and not between them
	while(get_enemy_count() == 0)
	{
		wait(1);
	}

	spawn_points = [];			
	spawn_points = GetEntArray(name,"targetname");
	
   for( i = 0; i < spawn_points.size; i++)
   {
		ai = spawn_zombie( spawn_points[i] );
		
		// JMA - make sure spawn_zombie doesn't fail
		if( IsDefined( ai ) )
		{
			ai maps\_zombiemode_spawner::zombie_setup_attack_properties();
			ai thread maps\_zombiemode_spawner::find_flesh();
			wait_network_frame();
		}
	}
}	

activate_door_flags(door, key)
{
     purchase_trigs = getEntArray(door, key);

     for( i = 0; i < purchase_trigs.size; i++)
     {
          if( !isDefined( level.flag[purchase_trigs[i].script_flag]))
          {
               flag_init(purchase_trigs[i].script_flag);
          }          
     }     
}

init_zombie_sumpf()
{
	//activate the initial exterior goals for the center bulding
	level.exterior_goals = getstructarray("exterior_goal","targetname");	
	
	for(i=0;i<level.exterior_goals.size;i++)
	{
		level.exterior_goals[i].is_active = 1;
	}

	// Setup the magic box
	thread maps\nazi_zombie_sumpf_magic_box::magic_box_init();	
	
	//managed zones are areas in the map that have associated spawners/goals that are turned on/off 
	//depending on where the players are in the map
	maps\nazi_zombie_sumpf_zone_management::activate_building_zones("center_building_upstairs","targetname");	
	
	// combining upstairs and downstairs into one zone
	level thread maps\nazi_zombie_sumpf_zone_management::combine_center_building_zones();
	
	// JMA - keep track of when the weapon box moves
	level thread maps\nazi_zombie_sumpf_magic_box::magic_box_tracker();		
	
	//ESM - new electricity traps
	level thread maps\nazi_zombie_sumpf_trap_perk_electric::init_elec_trap_trigs();
	
	// JMA - setup zipline deactivated trigger
	zipHintDeactivated = getent("zipline_deactivated_hint_trigger", "targetname");
	zipHintDeactivated sethintstring(&"ZOMBIE_ZIPLINE_DEACTIVATED");
	zipHintDeactivated SetCursorHint("HINT_NOICON");
	
	// JMA - setup log trap clear debris hint string
	penBuyTrigger = getentarray("pendulum_buy_trigger","targetname");
	
	for(i = 0; i < penBuyTrigger.size; i++)
	{		
		penBuyTrigger[i] sethintstring( &"ZOMBIE_CLEAR_DEBRIS" );
		penBuyTrigger[i] setCursorHint( "HINT_NOICON" );
	}
	
	//turning on the lights for the pen trap
	level thread maps\nazi_zombie_sumpf::turnLightRed("pendulum_light");	
	
	// set up the hanging dead guy in the attic
	//level thread hanging_dead_guy();
}


//ESM - added for green light/red light functionality for traps
turnLightGreen(name)
{
	zapper_lights = getentarray(name,"targetname");
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_green");	
		if (isDefined(zapper_lights[i].target))
		{
			old_light_effect = getent(zapper_lights[i].target, "targetname");
			light_effect = spawn("script_model",old_light_effect.origin);
			//light_effect = spawn("script_model",zapper_lights[i].origin);
			light_effect setmodel("tag_origin");
			if(name == "pendulum_light" && i == 0 ) // messed w the angles a bit for flogger, fx show up better now in game
			{
				light_effect.angles = (180,270,0);
			}	
			else if(name == "pendulum_light" && i == 1 )
			{
				light_effect.angles = (0,270,90);
			}	
			else
			{
				light_effect.angles = (0,270,0);
			}
			light_effect.targetname = "effect_" + name + i;
			old_light_effect delete();
			zapper_lights[i].target = light_effect.targetname;
			playfxontag(level._effect["zapper_light_ready"],light_effect,"tag_origin");
		}
	}
}

turnLightRed(name)
{
	zapper_lights = getentarray(name,"targetname");
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_red");	
		if (isDefined(zapper_lights[i].target))
		{
			old_light_effect = getent(zapper_lights[i].target, "targetname");
			light_effect = spawn("script_model",old_light_effect.origin);
			//light_effect = spawn("script_model",zapper_lights[i].origin);
			light_effect setmodel("tag_origin");	
			if(name == "pendulum_light" && i == 0 ) // messed w the angles a bit for flogger, fx show up better now in game
			{
				light_effect.angles = (180,270,0);
			}	
			else if(name == "pendulum_light" && i == 1 )
			{
				light_effect.angles = (0,270,90);
			}	
			else
			{
				light_effect.angles = (0,270,0);
			}
			light_effect.targetname = "effect_" + name + i;
			old_light_effect delete();
			zapper_lights[i].target = light_effect.targetname;
			playfxontag(level._effect["zapper_light_notready"],light_effect,"tag_origin");
		}
	}
}

player_zombie_awareness()
{
	self endon("disconnect");
	self endon("death");
	players = getplayers();
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
		if(players.size > 1)
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
			if(close_zombs > 4)
			{
				if(randomintrange(0,20) < 5)
				{
					self thread play_oh_shit_dialog();	
				}
			}
		}
		
	}
}		
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

level_start_vox()
{

	wait( 8 );//moved here
	index = maps\_zombiemode_weapons::get_player_index( self );
	plr = "plr_" + index + "_";
	// wait( 6 );//commented out
	self thread create_and_play_dialog( plr, "vox_level_start", 0.25 );

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
	
	
	level.intro_hud[0] settext(&"REMASTERED_ZOMBIE_INTRO_SUMPF_LEVEL_PLACE");
	level.intro_hud[1] settext(&"REMASTERED_ZOMBIE_INTRO_SUMPF_LEVEL_TIME");
	//level.intro_hud[2] settext(&"ZOMBIE_INTRO_ASYLUM_LEVEL_SEPTEMBER");
	
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

/*

// SUMPF EGG STEPS
// Doctor's Orders -- Harness the power of the Element

// -- SHARED -- //
1. “Suspicious Beginnings” - Find Richtofen's shelf and interact with it, you will hear his laugh.

// -- SOLO OR INCOMPLETE LOBBY -- //
2. “One & Done” - Complete only your character's tasks from the steps below depending on who you spawn as. Not eligible for achievement unless there are four players.

// -- FOUR-PLAYER COOP -- //
2. “Peter's Intel” - Peter's radio can be dislodged using a grenade and dropped to the ground, but only Dempsey can recover it. To get a strong enough radio signal so the player can use it, power on the Comm Room radio hub at the desk by solving a random three-long code where each of the three radios must be interacted with in the correct order. After the radio hub is powered on, place your handheld radio on the desk to send your message and pick it up after it completes. However, before sending this message (at any point) there are two prerequisites that must be met, ensuring Dempsey has the required intel. First, the spawn room radio message must have been activated by interacting with the three radios throughout the room. Second, Dempsey must have interacted with the 115 meteor. Without this required intel, the player will not be able to send a message and their radio will play idle static while holding.
3. “Secret Stash” - Nikolai must find some Vodka in the Storage Hut. Find the desk with the two crates and interact with the item--this acts as a dial. Turn the dial once to begin the step. For every turn, a shiny crate will be visible elsewhere in the room in one of three possible locations. The player must align the dial until it is facing the same direction as a crate. Once aligned, the player should knife the crate to search for Vodka. However, only one of the three crate locations will have it, so the player will have to keep rotating through each of the three spots until they find the Vodka. Be careful, because if you attempt to open a crate that is not aligned with the dial, the correct crate’s location will be randomized which resets any progress. If successful, knifing the correct crate will reveal a bottle of Vodka.
4. “Blade Cleansing" - Takeo must acquire a Katana from the Fishing Hut. First, pick up the medium sized rope found at one of three random locations inside the hut. Place the rope on the fishing pole to create a fishing line. Interact one more time and the fishing pole will raise a Katana out from underneath the water. However, the blade is covered in blood and Takeo will not pick it up. To clean the blade and pick it up, without shooting your weapon kill seven zombies (a lucky Japanese number) with melee in the surrounding area.
5. “Doc's On Call" - Richtofen must acquire his journal from his Quarters. Pick up the journal by interacting with it and avoid touching water, or else the journal will be reset back to the start, along with any progress. While holding the journal, the player must search for three intel sites across the map to take notes at. While taking notes, the player is left vulnerable and immobile.

// -- SHARED -- //
6. “Gear Up” - After all character tasks are complete, any player can pick up a sack found at one of three random locations in the main hut at the center of the map. This sack can be used to carry Element 115. 
7. “Swamp Samples - Locate and collect three small 115 meteor samples. One location will always be at the flogger where players must “fling” four consecutive zombies to cause it to drop. The other two locations are randomly dispersed throughout the other three areas of the swamp. Player must have the sack to pick up these samples, or else the dangerous Element will cause damage when trying to pick up.
8. “Super Charge” - The player with the meteor must now obtain the Wunderwaffe DG-2 and successfully zap 20 zombies without getting rid of the weapon.
9. “Tallying Time” - Interact with the tally marks showing "20" below the spawn room, indicating how many zaps we collected. If the Wunderwaffe is successfully charged a sound will play, otherwise the player will groan.
10. “Complete the Circuit” - The player with the super charged 115 and Wunderwaffe DG-2 must now shoot the large meteor outside the map. This will result in a "nuke" effect electrifying the surrounding zombies and the players will be rewarded. This is the moment when our characters would teleport out of Shi No Numa due to a rapid surge of Element 115 in the immediate area.

// - User hints are only displayed for when special items are required to do something (Radio, Journal). Vodka and Katana are pick-up only items and don't do anything, so no hints

*/

ee_models_setup() // Sets up models, no functionality
{
	// Radio is always in same spot
	level.handheld_radio_upper = spawn("script_model", (10373, 812.8, -318) ); // Possibly adjust coords/angle but good enough for now
	level.handheld_radio_upper setmodel("prop_mp_handheld_radio");
	level.handheld_radio_upper.angles = (10,0,80);

	// Finder is always in the same spot, however it starts hidden along with the 3 crates hidden 
	level.vodka_finder = spawn( "script_model",( 12627, -1167, -603) );
	level.vodka_finder setmodel("static_berlin_mortarpestle");
	level.vodka_finder.angles = (0,57,0); // Pointing at spot 1
	//level.vodka_finder.angles = (0,-160,0); // Pointing at spot 2
	//level.vodka_finder.angles = (0,145,0); // Pointing at spot 3

	// We always spawn in all 3, and then just hide them depending on which is shown during the step
	// Spot 1, low by door (low)
	level.vodka_box_first = spawn( "script_model",( 12486, -1067, -630.9) );
	level.vodka_box_first setmodel("clutter_peleliu_wood_ammo_box_closed_wet");
	level.vodka_box_first.angles = (2.6,35,0);
	level.vodka_box_first hide();

	// Spot 2, on barrel (medium height)
	level.vodka_box_second = spawn( "script_model",( 12640, -1574, -598) );
	level.vodka_box_second setmodel("clutter_peleliu_wood_ammo_box_closed_wet");	
	level.vodka_box_second.angles = (0,0,-10);
	level.vodka_box_second hide();

	// Spot 3, on boxes (high)
	level.vodka_box_third = spawn( "script_model",( 12447, -1491, -584) );
	level.vodka_box_third setmodel("clutter_peleliu_wood_ammo_box_closed_wet");
	level.vodka_box_third.angles = (4,-3,0); 
	level.vodka_box_third hide();

	// Init variables
	level.partspot = 0;
	rando = randomintrange(0,3);

	switch(rando) // Rope locations, three possible spots
	{
	case 0: // Top of barrel
		level.rope = spawn( "script_model",( 8830.2, 3281.57, -568.7 ) );
		level.rope setmodel("kwai_thickrope");
		level.rope.angles = ( -1, 0, 0 );
		level.partspot = 0;
		break;
	case 1: // Shelf
		level.rope = spawn( "script_model",( 8430, 2940 , -610.5 ) );
		level.rope setmodel("kwai_thickrope");
		level.rope.angles = ( -2, 25, 0 );
		level.partspot = 1;
		break;
	case 2: // Ceiling board
		level.rope = spawn( "script_model",( 8362.93, 3523, -540.1 ) );
		level.rope setmodel("kwai_thickrope");	
		level.rope.angles = ( -8, -2, 0 );
		level.partspot = 2;
		break;
	}

	level.handheld_radio_upper thread radio_drop();
	level thread vodka_pickup();
	level thread rope_pickup();

}

book_useage() 
{
	book_counter = 0;
	book_trig = getent("book_trig", "targetname");
	book_trig SetCursorHint( "HINT_NOICON" );
	book_trig UseTriggerRequireLookAt();

	// Diary is always in same spot
	level.diary = spawn( "script_model",( 11297 , 3625 , -605.5) );
	level.diary setmodel("static_berlin_books_diary");
	
	if(IsDefined(book_trig) )
	{
		maniac_l = getent("maniac_l", "targetname");
		maniac_r = getent("maniac_r", "targetname");
		
		book_trig waittill( "trigger", player );

		if(IsDefined(maniac_l))
		{
			maniac_l playsound("maniac_l");
			
		}
		if(IsDefined(maniac_r))
		{
			maniac_r playsound("maniac_r");
			
		}

		// Quest begins
		level thread ee_models_setup();
		level.first_time = 0; // for our diary vox
		wait(2.5); // we wait so players dont instantly pick up items after quest activates
		level thread diary_pickup();
	}

}

radio_drop()
{

	self setcanDamage(true);
	self.maxhealth = 100000;
	self.health = self.maxhealth;

	drop_radio = false;
	while( drop_radio == false )
	{
		self waittill("damage", damage, attacker, direction_vec, origin, type);
		if(type != "MOD_GRENADE_SPLASH" && /*type != "MOD_PROJECTILE_SPLASH" &&*/ type != "MOD_GRENADE" /*&& type != "MOD_PROJECTILE"*/ )
		{
			continue;
		}
		if(self.health < 100000 && Distance(self.origin, origin) < 45 )
		{
			drop_radio = true;
			break;	
		}
		else
		{
			self.maxhealth = 100000;
			self.health = self.maxhealth;
		}
	}
	self setcanDamage(false);

	end_point = PhysicsTrace( self.origin, (10366.1, 805.393, -525) );
	self NotSolid(); // test without this
	falltime = 0.8;
	self MoveTo(end_point, falltime, 0.15 );
	self RotateTo( (-85,30,0 ), falltime, 0.5);
	wait(falltime);
	self playsound("radio_drop");
	
	handheld_radio_trig = spawn( "trigger_radius",(10366.1, 805.393, -527.8), 0, 40, 25 );

	while(1)
	{
		handheld_radio_trig waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( handheld_radio_trig ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			if( index == 0 )
			{
				level thread radio_code();

				player playlocalsound("gren_pickup_plr");

				self delete();
				handheld_radio_trig delete();
				
				player giveweapon("zombie_item_radio"); 
				player setactionslot(1,"weapon","zombie_item_radio"); 
				player.has_special_weap = "zombie_item_radio";
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(handheld_radio_trig) )
		{
			break;
		}
	}
}

radio_code()
{
	level.radio_finished = false;

	switch(level.partspot)
	{
	case 0:
		level.radio_c1 = spawn( "trigger_radius",( 7493, -1506, -622), 0, 20, 25 );
		level.radio_c2 = spawn( "trigger_radius",( 7539, -1459, -622), 0, 20, 25 );
		level.radio_c3 = spawn( "trigger_radius",( 7575, -1423, -622 ), 0, 20, 25 );
		break;
	case 1:
		level.radio_c3 = spawn( "trigger_radius",( 7493, -1506, -622), 0, 20, 25 );
		level.radio_c1 = spawn( "trigger_radius",( 7539, -1459, -622), 0, 20, 25 );
		level.radio_c2 = spawn( "trigger_radius",( 7575, -1423, -622 ), 0, 20, 25 );
		break;
	case 2:
		level.radio_c2 = spawn( "trigger_radius",( 7493, -1506, -622), 0, 20, 25 );
		level.radio_c3 = spawn( "trigger_radius",( 7539, -1459, -622), 0, 20, 25 );
		level.radio_c1 = spawn( "trigger_radius",( 7575, -1423, -622 ), 0, 20, 25 );
		break;
	}

	level.magic_number = 0;

	level thread radio_c1();
	level thread radio_c2();
	level thread radio_c3();

	while(1)
	{
		if(level.magic_number == 3)
		{
			level.radio_c1 delete();
			level.radio_c2 delete();
			level.radio_c3 delete();
			level thread morse_radio();
			break;
		}
		wait(0.05);
	}
}

radio_c1()
{
	while(1)
	{
		level.radio_c1 waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.radio_c1 ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			weapon = player GetCurrentWeapon();
			if( index == 0 && weapon == "zombie_item_radio" )
			{
				player playlocalsound("mp_bomb_twist_0");
				if(level.magic_number == 2)
				{
					level.magic_number = 3;
					player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.25 );
				}
				else
				{
				level.magic_number = 1;
				}
				wait(0.5);
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.radio_c1) )
		{
			break;
		}
	}
}

radio_c2()
{
	while(1)
	{
		level.radio_c2 waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.radio_c2 ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			weapon = player GetCurrentWeapon();
			if( index == 0 && weapon == "zombie_item_radio" )
			{
				player playlocalsound("mp_bomb_twist_1");
				if ( level.magic_number != 0)
				{
					if(randomintrange(0,4) < 1)
					{
						player thread create_and_play_dialog( plr, "vox_gen_ask_no", 0.25 );
					}
					else
					{
			    		player thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog(); 
					}
					player playlocalsound("filecabinate_rattle");
				}
				level.magic_number = 0;
				wait(0.5);
				break; 
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.radio_c2) )
		{
			break;
		}
	}
}

radio_c3()
{
	while(1)
	{
		level.radio_c3 waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.radio_c3 ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			weapon = player GetCurrentWeapon();
			if( index == 0 && weapon == "zombie_item_radio" )
			{
				player playlocalsound("mp_bomb_twist_2");
				if(level.magic_number == 1)
				{
					level.magic_number = 2;
				}
				wait(0.5);
				break; 
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.radio_c3) )
		{
			break;
		}
	}
}

morse_radio()
{
	wait(0.5);
	morse_radio = spawn( "trigger_radius",( 7488, -1439, -642), 0, 50, 25 );
	static_sound = spawn( "script_origin",( 7488, -1439, -641), 0, 40, 25 );
	static_sound playsound("switch");
	wait(0.05);
	static_sound playloopsound( "static_loop" );

	while(1)
	{
		morse_radio waittill( "trigger", player );

		while(1)
		{
			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			weapon = player GetCurrentWeapon();

			if(index == 0 && weapon == "zombie_item_radio")
			{
				morse_radio SetCursorHint("HINT_ACTIVATE");
			}
			else
			{
				morse_radio SetCursorHint("HINT_NOICON");
				break;
			}

			if( !player IsTouching( morse_radio ) )
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
			if( level.radio_fin == false || player.seen_meteor == false )
			{
				player playlocalsound("door_deny");
				wait(1);
				break;
			}

			if( index == 0 && weapon == "zombie_item_radio" )
			{
				primaryWeapons = player GetWeaponsListPrimaries();
				if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
				{
					player SwitchToWeapon( primaryWeapons[0] );
				}
				player takeweapon("zombie_item_radio"); 
				player setactionslot(1,""); 
				player.has_special_weap = undefined;

				level.placed_radio = spawn( "script_model",( 7497, -1456, -642) );
				level.placed_radio setmodel("prop_mp_handheld_radio");
				level.placed_radio.angles = (0,60,0);

				player playlocalsound("mp_bomb_twist");
				player playlocalsound("gren_pickup_plr");

				static_sound playsound("morse_code", "morse_complete" );
				
				player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.25 );
				
				morse_radio delete();

				static_sound waittill("morse_complete" );

				level thread pickup_radio_again();

				static_sound stoploopsound( .1 );

				static_sound delete();
				break; 
			}
			else
			{
				break;
			}
		}
	}

}

pickup_radio_again()
{
	placed_radio_trig = spawn( "trigger_radius",( 7497, -1456, -642), 0, 50, 25 );

	while(1)
	{
		placed_radio_trig waittill( "trigger", player );

		while(1)
		{
			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";

			if(index == 0 )
			{
				placed_radio_trig SetCursorHint("HINT_ACTIVATE");
			}
			else
			{
				placed_radio_trig SetCursorHint("HINT_NOICON");
				break;
			}

			if( !player IsTouching( placed_radio_trig ) )
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

			if( index == 0 )
			{
				level.radio_finished = true;

				player playlocalsound("gren_pickup_plr");

				level.placed_radio delete();
				placed_radio_trig delete();
				
				//player giveweapon("zombie_item_radio"); 
				player setactionslot(1,"weapon","zombie_item_radio"); 
				player.has_special_weap = "zombie_item_radio";
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(placed_radio_trig) )
		{
			break;
		}
	}

	level.character_tasks_completed = level.character_tasks_completed + 1;
	if(level.character_tasks_completed >= getplayers().size ) // Amount of tasks just depends on how many players we have
	{
		level thread sack_spawn();
	}
	//iprintln("Dempsey steps completed");
	//iprintln("Total Character Tasks Completed: ", level.character_tasks_completed);
}


generic_vodka_trig(box_model)
{
	while(1)
	{
		self waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( self ) )
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
			if( !player meleeButtonPressed() )
			{
				break; 
			}

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			if( index == 1 && level.something_is_fishy == 0 && level.vodka_magic_number == level.where_are_we && box_model.is_visible == true )
			{
				PlayFx( level._effect["crate_destroy"], self.origin );
				player playlocalsound("wood_break");
				level thread vodka_cleanup();
				player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.05 );
				break;
			}
			else if( index == 1 && level.something_is_fishy == 1 && box_model.is_visible == true )
			{
				level.vodka_box_first hide(); 
				level.vodka_box_second hide(); 
				level.vodka_box_third hide();

				level.vodka_magic_number = randomintrange(1,4); // Resetting, we messed up 
				PlayFx( level._effect["crate_destroy"], self.origin );
				player playlocalsound("wood_break");
				player thread create_and_play_dialog( plr, "vox_gen_ask_no", 0.25 );
				wait(3);
				break;
			}
			else if( index == 1 && box_model.is_visible == true )
			{
				level.vodka_box_first hide(); 
				level.vodka_box_second hide(); 
				level.vodka_box_third hide();

				PlayFx( level._effect["crate_destroy"], self.origin );
				player playlocalsound("wood_break");

				player thread create_and_play_dialog( "plr_1_", "vox_gen_sigh", 0.05 );
			//	PlayFx( level._effect["wood_chunk_destory"], self.origin );
			//	playsoundatposition("wood_hard", self.origin);
			    wait(3);
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(self) )
		{
			break;
		}
	}

}

vodka_cleanup()
{
	switch(level.where_are_we)
	{
		case 1:
		location = level.vodka_box_first;
			break;
		case 2:
		location = level.vodka_box_second;
			break;
		case 3:
		location = level.vodka_box_third;
			break;
		default:
		location = 0;
			break;
	}
	vodka_finally = spawn( "script_model", location.origin );
	vodka_finally setmodel("vodka_bottle");
	vodka_trig_first_pickup = spawn( "trigger_radius", location.origin, 0, 40, 20 );

	level.vodka_box_first delete();
	level.vodka_box_second delete();
	level.vodka_box_third delete();
	level.vodka_trig_first delete();
	level.vodka_trig_third delete();
	level.vodka_trig_second delete();
	level.vodka_finder_trig delete();

	while(1)
	{	
		vodka_trig_first_pickup waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( vodka_trig_first_pickup ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			if( index == 1 )
			{
				vodka_trig_first_pickup delete();
				vodka_finally delete();
				player giveweapon("zombie_item_vodka"); 
				player setactionslot(1,"weapon","zombie_item_vodka"); 
				player.has_special_weap = "zombie_item_vodka";

				player playlocalsound("gren_pickup_plr");
				wait(0.75);
				player playlocalsound("bottle_open");
				player setblur( 4, 0.1 );
				player thread create_and_play_dialog( plr, "vox_trap_barrel", 0.25 );

				wait(0.75);
				player setblur(0, 0.1);

				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(vodka_trig_first_pickup) )
		{
			break;
		}
	}

	level.character_tasks_completed = level.character_tasks_completed + 1;
	if(level.character_tasks_completed >= getplayers().size ) // Amount of tasks just depends on how many players we have
	{
		level thread sack_spawn();
	}
	//iprintln("Nikolai steps completed");
	//iprintln("Total Character Tasks Completed: ", level.character_tasks_completed);
}

vodka_pickup()
{
	// stone thing needs a sound plus it shouldnt just be there by default
	level.something_is_fishy = 0;
	level.where_are_we = randomintrange(1,4); // first box to appear is random
	level.vodka_magic_number = randomintrange(1,4); // will be a random num 1,2,3

	level.vodka_finder_trig = spawn( "trigger_radius",( 12627, -1167, -603), 0, 30, 25 );
	wait_network_frame();

// Spot 1, low by door
	level.vodka_trig_first = spawn( "trigger_radius", level.vodka_box_first.origin, 0, 35, 5 );
	level.vodka_trig_first thread generic_vodka_trig(level.vodka_box_first);
	wait_network_frame();

// Spot 2, on boxes
	level.vodka_trig_second = spawn( "trigger_radius", level.vodka_box_second.origin, 0, 35, 5);
	level.vodka_trig_second thread generic_vodka_trig(level.vodka_box_second);
	wait_network_frame();

// Spot 3, on barrel
	level.vodka_trig_third = spawn( "trigger_radius", level.vodka_box_third.origin, 0, 35, 5 );
	level.vodka_trig_third thread generic_vodka_trig(level.vodka_box_third);

	level.vodka_box_first.is_visible = false;
	level.vodka_box_second.is_visible = false;
	level.vodka_box_third.is_visible = false;

	while(1)
	{	
		level.vodka_finder_trig waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.vodka_finder_trig ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			// rotation goes clockwise ->
			if( index == 1 /*&& level.vodka_finder.angles == (0,57,0)*/ && level.where_are_we == 1 ) // Pointing to spot 1, now we rotate to spot 2
			{
				if(randomintrange(0,2) == 0 )//flip a coin
				{ // fuck sum shit up
					level.vodka_box_first hide(); 
					level.vodka_box_second hide(); 
					level.vodka_box_third show(); //  If we get unlucky, showing box 3 (we are at 1, supposed to go to 2, but we go backwards to 3)
					level.vodka_box_first.is_visible = false;
					level.vodka_box_second.is_visible = false;
					level.vodka_box_third.is_visible = true;

					level.something_is_fishy = 1;
					player playlocalsound("blade_left");
				}
				else // or we go normal
				{
					level.vodka_box_first hide();
					level.vodka_box_second show(); // Show box 2
					level.vodka_box_third hide();
					level.vodka_box_first.is_visible = false;
					level.vodka_box_second.is_visible = true;
					level.vodka_box_third.is_visible = false;

					level.something_is_fishy = 0;
					player playlocalsound("blade_right");
				}

				level.where_are_we = 2; // Now pointed to spot 2
				level.vodka_finder rotateto((0,-160,0), 0.5, 0.1, 0.1); // Now pointed to spot 2	

				wait(1.25);
				break;
			}
			else if( index == 1 /*&& level.vodka_finder.angles == (0,-160,0)*/ && level.where_are_we == 2 ) // Pointing to spot 2, now we rotate to spot 3
			{
				if(randomintrange(0,2) == 0 )//flip a coin
				{ // fuck sum shit up
					level.vodka_box_first show(); //  If we get unlucky, showing box 1 (we are at 2, supposed to go to 3, but we go backwards to 1)
					level.vodka_box_second hide();
					level.vodka_box_third hide();
					level.vodka_box_first.is_visible = true;
					level.vodka_box_second.is_visible = false;
					level.vodka_box_third.is_visible = false;

					level.something_is_fishy = 1;
					player playlocalsound("blade_left");
				}
				else // or we go normal
				{
					level.vodka_box_first hide(); 
					level.vodka_box_second hide(); 
					level.vodka_box_third show(); // Show box 3
					level.vodka_box_first.is_visible = false;
					level.vodka_box_second.is_visible = false;
					level.vodka_box_third.is_visible = true;
					
					level.something_is_fishy = 0;
					player playlocalsound("blade_right");
				}
			
				level.where_are_we = 3;  // Now pointed to spot 3
				level.vodka_finder rotateto((0,145,0), 0.5, 0.1, 0.1); // Now pointed to spot 3

				wait(1.25);
				break;
			}
			else if( index == 1 /*&& level.vodka_finder.angles == (0,145,0)*/ && level.where_are_we == 3) // Pointing to spot 3, now we rotate back to spot 1
			{
				if(randomintrange(0,2) == 0 )//flip a coin
				{ // fuck sum shit up
					level.vodka_box_first hide();
					level.vodka_box_second show(); // If we get unlucky, showing box 2 (we are at 3, supposed to go to 1, but we go backwards to 2)
					level.vodka_box_third hide();
					level.vodka_box_first.is_visible = false;
					level.vodka_box_second.is_visible = true;
					level.vodka_box_third.is_visible = false;

					level.something_is_fishy = 1;
					player playlocalsound("blade_left");
				}
				else // or we go normal
				{
					level.vodka_box_first show(); // Now showing box 1
					level.vodka_box_second hide();
					level.vodka_box_third hide();
					level.vodka_box_first.is_visible = true;
					level.vodka_box_second.is_visible = false;
					level.vodka_box_third.is_visible = false;
					
					level.something_is_fishy = 0;
					player playlocalsound("blade_right");
				}
					
				level.where_are_we = 1; // Resetting, now pointed to spot 1
				level.vodka_finder rotateto((0,57,0), 0.5, 0.1, 0.1); // Resetting, now pointed to spot 1

				wait(1.25);
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.vodka_finder_trig) )
		{
			break;
		}
	}
}

rope_pickup() // Change to rope
{
	switch(level.partspot)
	{
	case 0:
		level.rope_trig = spawn( "trigger_radius",( 8830.2, 3281.57, -580 ), 0, 50, 25 );
		break;
	case 1:
		level.rope_trig = spawn( "trigger_radius",( 8430, 2940 , -610.5), 0, 40, 25 );
		break;
	case 2:
		level.rope_trig = spawn( "trigger_radius",( 8362.93, 3523, -560.1 ), 0, 40, 40 );
		break;
	}

	while(1)
	{
		level.rope_trig waittill( "trigger", player );
		player.has_rope = 0;
		while(1)
		{
			if( !player IsTouching( level.rope_trig ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			if( index == 2 )
			{
				player playlocalsound("sack_pickup");
				player item_hud_create("hud_rope");
				player thread item_hud_remove();
				player.has_rope = 1;
				level thread katana_raise();
				level.rope_trig delete();
				level.rope delete();	
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.rope_trig) )
		{
			break;
		}
	}
}

katana_raise()
{
	level.fishing_pole = spawn( "trigger_radius",( 8068.23, 3537.4, -664.875 ), 0, 30, 20 );
	
	while(1)
	{
		level.fishing_pole waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.fishing_pole ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			if( index == 2 && player.has_rope == 1 ) // Has rope, first time entering trig and places it down here
			{
				player thread create_and_play_dialog( "plr_2_", "vox_summon_katana", 0.05 );
				level notify("rope_placed");
				player playlocalsound("sack_drop");
				player.has_rope = 0;				
				level.rope_on_pole = spawn( "script_model",( 7991, 3558, -597.5 ) );
				level.rope_on_pole setmodel("anim_nazi_flag_burnt_rope");
				level.rope_on_pole.angles = (2,2,-180);
				level.fishing_pole delete();
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.fishing_pole) )
		{
			break;
		}
	}

	wait(1); 
	level.fishing_pole_two = spawn( "trigger_radius",( 8068.23, 3537.4, -664.875 ), 0, 30, 20 );
	level.sword_on_rope = spawn( "script_model",( 7995, 3560, -700 ) );
	level.sword_on_rope setmodel("weapon_jap_katana_long");
	level.sword_on_rope.angles = (-90,0,0);

	while(1)
	{
		level.fishing_pole_two waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.fishing_pole_two ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );

			if( index == 2 && player.has_rope == 0 ) // Now F again, but with no rope, this raises katana up
			{
				raisetime = 3;
				raiseto = ( 7987, 3555, -607.25 );
				player playlocalsound("earthquake");

				earthquake( 0.3, 6, level.sword_on_rope.origin + (0,0,0), 200 );
				wait(1.5);

				player playlocalsound("water_churn");

				end_point = PhysicsTrace( level.sword_on_rope.origin, raiseto );
				level.sword_on_rope NotSolid(); 


				level.sword_on_rope MoveTo( raiseto, raisetime, 2, 0.5 );
				level.sword_on_rope RotateTo( (105,0,0 ), raisetime, 2, 0.25);
				player thread create_and_play_dialog( "plr_2_", "vox_maxammo_mach", 0.05 );
				wait(2.3);
				playfxontag(level._effect["fishing_splash"], level.sword_on_rope,"tag_origin");
				level.sword_on_rope playsound("water_burst");
			
				wait( raisetime - 2.3 );

				player thread earn_katana_watcher();
				player.has_rope = undefined; 
				level.fishing_pole_two delete();
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.fishing_pole_two) )
		{
			break;
		}
	}

	level.fishing_pole_onemore = spawn( "trigger_radius",( 8068.23, 3537.4, -664.875 ), 0, 30, 20 );

	while(1)
	{
		level.fishing_pole_onemore waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.fishing_pole_onemore ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );

			if( index == 2 ) // Now F again, but not ready for katana
			{
				player thread create_and_play_dialog( "plr_2_", "vox_katana_wait", 0.25 );
				wait(1);
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.fishing_pole_onemore) )
		{
			break;
		}
	}

}

katana_water_trail()
{
	self.tag_origin = spawn("script_model",self.origin);
	self.tag_origin setmodel("tag_origin");
	playfxontag(level._effect["fishing_splash"],self.tag_origin,"tag_origin");
	self.tag_origin moveto(self.tag_origin.origin + (0,0,100),.5);
}

earn_katana_watcher() // Does not count Insta-Kill knives, too easy
{
	self endon("completed_knives");

	fishing_hut = getent("northwest_building", "targetname");
	self.getting_knives = 1;
	self.has_knives = 0;

	while(1)
	{
		while(self isTouching(fishing_hut) )
		{
			self waittill_either("knife_kill", "weapon_fired");
			if ( self isFiring() && !self isMeleeing() )
			{
				break;
			}

			if(self isTouching(fishing_hut)  ) // Only ever count melee kills if we are touching the zone and using melee
			{
				self thread delay_katana_vox();
				self.has_knives = self.has_knives + 1;
			}
			if(self.has_knives >= 7) // Japanese lucky number, related to some buddhist thing  
			{
				self.getting_knives = undefined;
				level.fishing_pole_onemore delete();
				level thread give_katana();
				self notify("completed_knives");
			}
		}
		self.has_knives = 0; // if we leave fishing_hut area and get a knife kill, it resets
		wait(0.1);
	}
}

delay_katana_vox()
{
	wait(0.75);
	self thread create_and_play_dialog( "plr_2_", "vox_gen_respond_pos", 0.25 );
}
give_katana()
{
	wait_network_frame();
	level.fishing_pole_three = spawn( "trigger_radius",( 8068.23, 3537.4, -664.875 ), 0, 30, 20 );
	level.sword_on_rope setmodel("weapon_jap_katana_long_alt");

	playfxontag(level._effect["hanging_light_fx"],level.sword_on_rope,"tag_origin");

	while(1)
	{
		level.fishing_pole_three waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( level.fishing_pole_three ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			if( index == 2 && player.has_knives >= 7 ) // Now we need to get kills before picking it up
			{
				// Katana step done, let's clean up variables and delete trig/sword model
				player giveweapon("zombie_item_katana"); 
				player setactionslot(1,"weapon","zombie_item_katana"); 
				player.has_special_weap = "zombie_item_katana";

				player playlocalsound("katana");
				player playlocalsound("ammo_pickup_plr");
				player thread create_and_play_dialog( "plr_2_", "vox_trap_chopper", 0.25 );

				player.has_knives = undefined; // no longer need var
				level.sword_on_rope delete();
				level.fishing_pole_three delete();
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(level.fishing_pole_three) )
		{
			break;
		}
	}

	falltime = 1;
	fallto = (level.rope_on_pole.origin + (0,0,-200));

	end_point = PhysicsTrace( level.rope_on_pole.origin, fallto );
	level.rope_on_pole NotSolid(); 
	level.rope_on_pole MoveTo( fallto, falltime, 0.25 );
	wait(2);
	level.rope_on_pole delete();

	level.character_tasks_completed = level.character_tasks_completed + 1;
	if(level.character_tasks_completed >= getplayers().size ) // Amount of tasks just depends on how many players we have
	{
		level thread sack_spawn();
	}
	//iprintln("Takeo steps completed");
	//iprintln("Total Character Tasks Completed: ", level.character_tasks_completed);
}


diary_pickup()
{
	diary_trig = spawn( "trigger_radius",( 11297 , 3625 , -605.5), 0, 30, 10 );

	while(1)
	{
		diary_trig waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( diary_trig ) )
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

			index = maps\_zombiemode_weapons::get_player_index( player );
			plr = "plr_" + index + "_";
			if( index == 3 )
			{
				if( level.first_time == 0 ) // Only do the VOX on the first time we pick it up; this item is special and can be re-picked up
				{
					level.first_time = 1;
					player thread create_and_play_dialog( plr, "vox_trap_battery", 0.25 );
				}
				level thread spawn_intel_sites(); // set up note taking sites, we will now do this multiple times if we reset progress

				player playlocalsound("gren_pickup_plr");

				player giveweapon("zombie_item_journal"); 
				player setactionslot(1,"weapon","zombie_item_journal"); 
				player.has_special_weap = "zombie_item_journal";

				diary_trig delete();
				level.diary delete();

				player thread diary_drop();
				break;
			}
			else
			{
				break;
			}
		}
		if (!IsDefined(diary_trig) )
		{
			break;
		}
	}

}


diary_drop()
{
	plr = "plr_3_";

	self endon("disconnect");
	self endon("death");
	while(1)
	{

		d = self depthinwater();

		if( d > 1 || self maps\_laststand::player_is_in_laststand() )
		{
			level notify("dropped"); // Notify dropped, this ends all intel loops
			level.intel1 delete();
			level.intel2 delete();
			level.intel3 delete();
			level.intel2_sound delete();

			if( d > 0 )
			{
				// Some water and visual effects
				self setwatersheeting(true, 1.1);
				self playlocalsound("water_burst");
				wait(0.1);
			}

			self playlocalsound("gren_pickup_plr");

			// Switch away from weapon if holding it
			if(self GetCurrentWeapon() == "zombie_item_journal" )
			{
				primaryWeapons = self GetWeaponsListPrimaries();
				if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
				{
					self SwitchToWeapon( primaryWeapons[0] );
				}	
			}

			self takeweapon("zombie_item_journal"); 
			self setactionslot(1,""); 
			self.has_special_weap = undefined;

			self takeweapon("zombie_item_journal_writing");

			// Some dialogue
			wait(0.4);
			self thread create_and_play_dialog( plr, "vox_gen_respond_neg", 0.25 );
			
			// And let's reset everything
			level thread diary_pickup();
			level.diary = spawn( "script_model",( 11297 , 3625 , -605.5) );
			level.diary setmodel("static_berlin_books_diary");
			break;
		}
		if(	level.intel_obtained == 3 ) // perma loop so whenever we finish the journal step, we clean up and remove the writing variant, but make sure to wait for the drop anim to finish
		{
			wait(1.6);
			self takeweapon("zombie_item_journal_writing");
			break;
		}
		wait(0.05);
	}
}

spawn_intel_sites()
{
	level.intel_obtained = 0;

	wait_network_frame();
	level.intel1 = spawn( "trigger_radius",( 10473, 1448.5, -528.5), 0, 12, 25 );	
	level thread intel_spawn(level.intel1);

	wait_network_frame();
	level.intel2 = spawn( "trigger_radius",( 7355.75, -1102.5, -679.5), 0, 12, 25 );
	level.intel2_sound = spawn( "script_origin",( 7355.75, -1102.5, -679) );
	level thread intel_spawn(level.intel2, level.intel2_sound);

	wait_network_frame();
	level.intel3 = spawn( "trigger_radius",( 11722.5, 3495, -655.5), 0, 12, 25 );
	level thread intel_spawn(level.intel3);
}


// RESTART WEAPON SHIT
/*

-> We get normal journal off shelf with ammo
	-> This results in us using the regular DropAnim

-> When we enter the trig and begin holding F...

-> We TAKE the ammo from our journal
	-> This results in us now using the EMPTY dropAnim where it just disappears
	-> Which allows us to instantly GiveWeapon with the alternate journal that has an infinite "writing" animation loop
	-> We disable controls and freeze player so all they can do is keep holding F or let go and give up
	-> We also REMOVE the normal journal from our inventory so that it looks cleaner on the HUD 

-> If we FINISH writing or give up, 
	-> We let SwitchWeapon naturally play out and switch us back to our regular gun 
	-> While we do this, we instantly give back our normal journal (which now has ammo) so it is now back in our inventory, as if we never lost it, and it can use the regular DropAnim



*/
intel_spawn(intel, button_sound)
{
    level endon("dropped");

	intel SetCursorHint("HINT_NOICON");

	talk_once = 0; // only one shout per intel

    while ( true )
    {
	    intel waittill( "trigger", DiaryHolder ); // wait for player to enter trigger

	    // Gather player info for weapons & VOX
		index = maps\_zombiemode_weapons::get_player_index( DiaryHolder );
		plr = "plr_" + index + "_";	
		current_weapon = DiaryHolder GetCurrentWeapon();

		if( index == 3 && isSubStr(current_weapon, "zombie_item_journal" ) ) // If Richtofen and holding journal--ready to go
		{
			intel SetCursorHint("HINT_ACTIVATE");
			intel SetVisibleToPlayer(DiaryHolder);	
		}

		if( index != 3)
		{
			intel SetCursorHint("HINT_NOICON"); // For other characters, or if not holding the diary--no hint
			if(talk_once == 0 )
			{
				DiaryHolder thread create_and_play_dialog( plr, "vox_name_richtofen", 0.1 ); // Each char can only shout name once to help find a spot, doesn't have to hold F
				talk_once = 1;
				continue;
			}
		}

		if( !diaryholder UseButtonPressed() || !DiaryHolder IsTouching(intel) ) // From here on, player must be holding F and touching trig, otherwise we just go back to the start
		{
			continue;
		}

	    if ( isSubStr(current_weapon, "zombie_item_journal" ) && is_player_valid(DiaryHolder) && !DiaryHolder isThrowingGrenade() )
	    {
			DiaryHolder setactionslot(1,""); // HUD looks weird because it stops being highlighted gold when switching weapons, so might as well just hide it

			DiaryHolder SetWeaponAmmoClip("zombie_item_journal", 0); // AMMO TO 0, WE ARE NOW INSTA-SWAPPING TO WRITING JOURNAL W/ EMPTY DROP ANIM
			DiaryHolder SetWeaponAmmoStock("zombie_item_journal", 0); // AMMO TO 0, WE ARE NOW INSTA-SWAPPING TO WRITING JOURNAL W/ EMPTY DROP ANIM

			DiaryHolder giveweapon("zombie_item_journal_writing");
			DiaryHolder switchToWeapon("zombie_item_journal_writing");

			DiaryHolder playlocalsound("book_open"); // Faked weapon raise sound

		    DiaryHolder DisableWeaponCycling();
	      	DiaryHolder DisableOffhandWeapons();

	        wait(0.05); // test without ? 
	
	        //Wait for a certain amount of time before success
	        intel thread WaitForWriteDownCompletion( DiaryHolder, button_sound );

	        //Wait for if we cancel writing by either leaving trig or letting go of F
	        intel WaitForWriteDownCancellation( DiaryHolder, intel );
	    }
	    else // if Richtofen attempts to write without proper requirements met (not holding journal)
	    {
			DiaryHolder thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
			wait(3); // delay so player cannot spam F on trigger
			continue;
	    }
    }

}

WaitForWriteDownCompletion( DiaryHolder, button_sound )
{
	timer = 16 + ((getplayers().size - 1) * 4.67); // about 15, 20, 25, 30, tweaked for anim to end on cue

	if( !isdefined(DiaryHolder.intelProgressBar) ) // Set up progress bar
	{
		DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_gen_cover", 0.25 );	// Only shout for help once per interaction, once we start doing progress bar

		DiaryHolder.intelProgressBar = DiaryHolder createPrimaryProgressBar(false);
		DiaryHolder.intelProgressBar setPoint("CENTER", undefined, 0, -60);
		DiaryHolder.intelProgressBar updateBar( 0.01, 1 / timer );
	}

    while( DiaryHolder UseButtonPressed() && DiaryHolder IsTouching(self) && (!DiaryHolder maps\_laststand::player_is_in_laststand()) && timer > 0 ) // we stay here while succesfully taking notes until 30 sec has passed
    {
	    if ( !isSubStr( (DiaryHolder GetCurrentWeapon()), "zombie_item_journal" ) ) // if at any point we start holding another weapon (betty), we cancel
        {
        	break;
        }

        timer -= 0.05;
		DiaryHolder playloopsound("journal_loop");
		if(isDefined(button_sound) )
		{
			button_sound playloopsound("switches_loop"); // for intel site 2, where player is at radio
		}
        wait(0.05);
    }

    DiaryHolder stoploopsound(0.1);

	if(isDefined(button_sound) )
	{
		button_sound stoploopsound(); 
	}

	if( isdefined( DiaryHolder.intelProgressBar ) )
	{
		DiaryHolder.intelProgressBar destroyElem();
	}

    if(timer <= 0)
    {
        self delete();
		if(isDefined(button_sound) )
		{
			button_sound delete();
		}
		DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_gen_respond_pos", 0.25 );

    	// UNFREEZE PLAYER
	    DiaryHolder EnableWeaponCycling();
	    DiaryHolder EnableOffhandWeapons();

	    // SWITCH BACK TO NORMAL WEAPON
		primaryWeapons = DiaryHolder GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			DiaryHolder playlocalsound("book_close");
			DiaryHolder SwitchToWeapon( primaryWeapons[0] );
		}
		// FULLY RESET JOURNAL, THIS FIXES IT ON HUD & GIVES BACK AMMO SO WE CAN HAVE NORMAL ANIMS--WORKS BECAUSE WE'RE NOT EVEN USING THIS SPECIFIC WEP DURING WRITING ANIM
		DiaryHolder takeweapon("zombie_item_journal"); 

        level.intel_obtained++;
		if(level.intel_obtained != 3)
		{
			DiaryHolder giveweapon("zombie_item_journal"); 
		}
		DiaryHolder setactionslot(1,"weapon","zombie_item_journal"); 

        self notify("write_down_complete");

        if(level.intel_obtained == 3)
        {
			level.character_tasks_completed = level.character_tasks_completed + 1;
			if(level.character_tasks_completed >= getplayers().size ) // Amount of tasks just depends on how many players we have
			{
				level thread sack_spawn();
			}
		    wait(1.5);
			DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_gen_compliment", 0.25 );
        }
        else
        {
			wait(1.25);
			DiaryHolder thread create_and_play_dialog( "plr_3_", "vox_gen_move", 0.25 );
        }
        
        //iprintlnbold("Intels complete: ",level.intel_obtained);
        //iprintlnbold("Task completion status? ", level.character_tasks_completed);
    }
}

WaitForWriteDownCancellation( DiaryHolder, intel )
{
    // Wait for if player stops holding the use button
    self endon("write_down_complete");

    while(  DiaryHolder UseButtonPressed() && DiaryHolder isTouching(intel) && (!DiaryHolder maps\_laststand::player_is_in_laststand()) )
    {
	    if ( !isSubStr( DiaryHolder GetCurrentWeapon(), "zombie_item_journal" ) ) // if we at any point start holding another weapon (betty), we cancel
        {
        	break;
        }
        wait(0.05);
    }
	
	intel SetCursorHint("HINT_NOICON"); // Instantly remove hint, we are now on cooldown

	// UNFREEZE PLAYER
    DiaryHolder EnableWeaponCycling();
    DiaryHolder EnableOffhandWeapons();

    if( !DiaryHolder maps\_laststand::player_is_in_laststand() ) // last stand check, because we do something different if we down while taking notes (resets all progress)
    {
	    // SWITCH BACK TO NORMAL WEAPON
		primaryWeapons = DiaryHolder GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			DiaryHolder playlocalsound("book_close");
		    if ( isSubStr( DiaryHolder GetCurrentWeapon(), "zombie_item_journal" ) ) // if we're holding something else like a betty, that means we meant to switch to it so no need to go back to primary wep
	        {
				DiaryHolder SwitchToWeapon( primaryWeapons[0] );
	        }
		}

		// FULLY RESET JOURNAL, THIS FIXES IT ON HUD & GIVES BACK AMMO SO WE CAN HAVE NORMAL ANIMS--WORKS BECAUSE WE'RE NOT EVEN USING THIS SPECIFIC WEP DURING WRITING ANIM
		DiaryHolder takeweapon("zombie_item_journal"); 
		DiaryHolder giveweapon("zombie_item_journal"); 
		DiaryHolder setactionslot(1,"weapon","zombie_item_journal"); 
	}
	wait(2); // Cooldown here so player does not spam F, anims could start to look weird, they get hard reset back to their gun and have to wait a cooldown/take their journal back out


}


sack_spawn()
{
	level thread meteor_spawn(); // lets spawn the meteors first even before sack is picked up, lets player figure it out themselves
	wait_network_frame();

	level.partspot = randomintrange(0,3);

	switch(level.partspot)
	{
		case 0: // on shelf near storage side
			sack = spawn( "script_model",( 10703.1, 588.1, -607) );
			sack setmodel("grenade_bag");
			sack.angles = ( 1, 150, 0 );
			sack_trig = spawn( "trigger_radius",( 10703.1, 588.1, -607), 0, 30, 25 );
			break;
		case 1: // behind box spawn
			sack = spawn( "script_model",( 9588.89, 459.272, -607) );
			sack setmodel("grenade_bag");
			sack.angles = ( -1, 50, 0 );
			sack_trig = spawn( "trigger_radius",( 9588.89, 459.272, -607), 0, 30, 25 );
			break;
		case 2: // under bed near dr quarter side
			sack = spawn( "script_model",( 10094.8, 1011.91, -660.875) );
			sack setmodel("grenade_bag");
			sack.angles = ( 3, 30, 0 );
			sack_trig = spawn( "trigger_radius",( 10094.8, 1011.91, -660.875), 0, 30, 25 );
			break;
		default:
			sack = 0;
			sack_trig = 0;
			break;
	}

	while(1)
	{
		sack_trig waittill( "trigger", player );
		player.sack = 0;

		while(1)
		{
			if( !player IsTouching( sack_trig ) )
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

			if( player.sack == 0)
			{
				player.sack = 1; // to make sure only player with sack can pickup meteors
				level.sack_has_been_found = 1; // to check for flogger step

				player sack_hud_create("hud_sack");

				player playlocalsound("sack_pickup");

				if(isDefined(level.vodka_finder))
				{
					level.vodka_finder delete();
				}

				sack_trig delete();
				sack delete();
				break;
			}
			else
			{
				break;
			}
		}
		if(!isDefined(sack_trig) )
		{
			break;
		}
	}

}


meteor_spawn()
{
	wait_network_frame();
	level.meteors_found = 0;

	meteor_spot_one = undefined;
	meteor_spot_two = undefined;

	rando = randomintrange(0,3);
	switch(rando)
	{
	case 0:
		meteor_spot_one = ( 8560.5, -532.4, -703.4);
		meteor_spot_two = ( 11305.5, 1988.25, -690.4);
		break;
	case 1:
		meteor_spot_one = ( 11305.5, 1988.25, -690.4);
		meteor_spot_two = ( 12047.1, -1498.7, -692.85);
		break;
	case 2:
		meteor_spot_one = ( 12047.1, -1498.7, -692.85);
		meteor_spot_two = ( 8560.5, -532.4, -703.4);
		break;
	}

	level thread meteor_trigs(meteor_spot_one);
	level thread meteor_trigs(meteor_spot_two);

}

meteor_trigs(meteor_origin)
{
	meteor = spawn( "script_model",( meteor_origin) );
	meteor_trig = spawn( "trigger_radius",( meteor_origin + (0,0,0.2) ), 0, 30, 20 );
	meteor_sound = spawn( "script_origin",( meteor_origin + (0,0,0.1) ) );

	//model
	meteor setmodel("fx_debris_meteor_115");

	//fx
	wait_network_frame();
	playfxontag(level._effect["meteor_ambient_small"], meteor, "tag_origin");

	//sound
	wait_network_frame();
	meteor_sound playloopsound("meteor_alt_loop");

	while(1)
	{
		meteor_trig waittill( "trigger", player );
		while(1)
		{
			if( !player IsTouching( meteor_trig ) )
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
			if(	(!isDefined(player.sack) || player.sack == 0) ) // If we don't have sack
			{
				if(!player hasperk("specialty_armorvest") || player.health - 100 < 1)
				{
					radiusdamage(player.origin,10,10,10);
				}
				else
				{
					player dodamage(10, player.origin);
				}
				player playlocalsound("pain_115");
				wait(0.5);
				break;
			}

			if(	player.sack > 0) // If we have sack
			{
				player playlocalsound("gren_pickup_plr");
				player playlocalsound("touch_115");
				player playlocalsound("burn_115");

				meteor_sound stoploopsound(0.5);
				meteor_sound delete();
				meteor delete();
				meteor_trig delete();

				index = maps\_zombiemode_weapons::get_player_index(player);
				plr = "plr_" + index + "_";
			
		        level.meteors_found++;
				player.sack_hud destroy_hud();
				player.sack_hud = undefined;

		        if(level.meteors_found == 3)
		        {
					player sack_hud_create("hud_sack_three");
				
					player.sack = 2;
					player thread waffle_checker(player);

			    	level thread phase_three();
			    	wait(0.5);
					player thread create_and_play_dialog( plr, "vox_gen_compliment", 0.25 );
			    }
				else if( level.meteors_found == 2 )
				{
					player sack_hud_create("hud_sack_two");
					wait(1.5);
					player thread create_and_play_dialog( plr, "vox_gen_ask_yes", 0.25 );
				}
				else if( level.meteors_found == 1 )
				{
					player sack_hud_create("hud_sack_one");
					wait(1.5);
					player thread create_and_play_dialog( plr, "vox_gen_ask_yes", 0.25 );
				}
				break;
			}
			else
			{
				break;
			}
		}
		if(!isDefined(meteor_trig) )
		{
			break;
		}
	}
}

sack_hud_create(sack)
{
		shader = sack;
		self.sack_hud = create_simple_hud( self );
		self.sack_hud.foreground = true; 
		self.sack_hud.sort = 2; 
		self.sack_hud.hidewheninmenu = false; 
		self.sack_hud.alignX = "center"; 
		self.sack_hud.alignY = "bottom";
		self.sack_hud.horzAlign = "right"; 
		self.sack_hud.vertAlign = "bottom";
		self.sack_hud.x = -230;
		self.sack_hud.y = -1; 
		self.sack_hud.alpha = 1;
		self.sack_hud SetShader( shader, 32, 32 );

		self thread sack_remove();
}

sack_remove()
{
	level waittill_any( "end_game", "waffle_shot" );
	
	self.sack_hud destroy_hud();
	self.sack_hud = undefined;

}

phase_three()
{
	level thread tmark();
	wait(2);
	playsoundatposition("ann_vox_dog_left", (8330, 592, -160));
	playsoundatposition("ann_vox_dog_right", (11793, 1632, -160));

	wait(1);
	
	level thread maps\_zombiemode_powerups::play_devil_dialog("ann_vox_special");

}

tmark()
{

	tally_trig = spawn( "trigger_radius",( 9651 , 809.25 , -660), 0, 30, 25 );

	while(1)
	{
		tally_trig waittill( "trigger", player );
		index = maps\_zombiemode_weapons::get_player_index( player );
		plr = "plr_" + index + "_";

		while(1)
		{
			if( !player IsTouching( tally_trig ) )
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
			if ( !IsDefined( player.groups_killed ) )
			{
				player.groups_killed = 0;
			}

			if(level.meteor_ready == 1 && player.sack == 2 )
			{
				player thread create_and_play_dialog( plr, "vox_gen_respond_pos", 0.25 );

				level thread meteor_charged();

				tally_trig delete();
			}
			else
			{
			    player thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog(); 
				break;
			}
		}
		if(!isDefined(tally_trig) )
		{
			break;
		}
	}
}

waffle_checker(player)
{

	self endon("disconnect");
	self endon("death");

	while(1)
	{
		if( level.meteor_ready == 1 )
		{
			wait(0.5);
			player playlocalsound( "shock_115" ); //  change tesla idle to louder sound to show we're done?
			player.sack_hud destroy_hud();
			player.sack_hud = undefined;
			player sack_hud_create("hud_sack_final");
			break;
		}

		wait(1);
	}
}

meteor_charged()
{

	wait(0.5);
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] play_sound_2d("shaka_sting_ending");
	}

	level thread waffe_meteor();
}

toilet_useage()
{

	toilet_counter = 0;
	toilet_trig = getent("toilet", "targetname");
	toilet_trig SetCursorHint( "HINT_NOICON" );
	toilet_trig UseTriggerRequireLookAt();
	
//	off_the_hook = spawn ("script_origin", toilet_trig.origin);
	toilet_trig playloopsound ("phone_hook");
	
	if (!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}	

	toilet_trig waittill( "trigger", player );
	toilet_trig stoploopsound(0.5);
	toilet_trig playloopsound("phone_dialtone");

	wait(0.5);

	toilet_trig waittill( "trigger", player );
	toilet_trig stoploopsound(0.5);
	toilet_trig playsound("dial_9", "sound_done");
	toilet_trig waittill("sound_done");

	toilet_trig waittill( "trigger", player );
	toilet_trig playsound("dial_1", "sound_done");
	toilet_trig waittill("sound_done");

	toilet_trig waittill( "trigger", player );
	toilet_trig playsound("dial_1");
	wait(0.5);
	toilet_trig playsound("riiing");
	wait(1);
	toilet_trig playsound("riiing");
	wait(1);			
	toilet_trig playsound ("toilet_flush", "sound_done");				
	toilet_trig waittill ("sound_done");				
	//playsoundatposition ("cha_ching", toilet_trig.origin);
	level.eggs = 1;
	setmusicstate("eggs");
	
	index = maps\_zombiemode_weapons::get_player_index(player);
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_audio_secret))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_audio_secret");
		self.vox_audio_secret = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_audio_secret[self.vox_audio_secret.size] = "vox_audio_secret_" + i;	
		}
		self.vox_audio_secret_available = self.vox_audio_secret;
	}

	player maps\_zombiemode_achievement::giveachievement_wrapper_new( "DLC2_ZOMBIE_SECRET", true); // all players should get it

	sound_to_play = random(self.vox_audio_secret_available);
	self.vox_audio_secret_available = array_remove(self.vox_audio_secret_available,sound_to_play);	
	player maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 2.75);
	
	wait(291);	
	setmusicstate("WAVE_1");
	level.eggs = 0;				
}
play_radio_sounds()
{
	radio_one = getent("radio_one_origin", "targetname");
	radio_two = getent("radio_two_origin", "targetname");
	radio_three = getent("radio_three_origin", "targetname");
	
	pa_system = getent("speaker_in_attic", "targetname");
	
	radio_one stoploopsound(2);
	radio_two stoploopsound(2);
	radio_three stoploopsound(2);
	
	wait(0.05);
	pa_system playsound("secret_message", "message_complete");
	pa_system waittill("message_complete");
	level.radio_fin = true; 
	//level notify("radios_done");
	radio_one playsound ("static");
	radio_two playsound ("static");
	radio_three playsound ("static");
}
radio_eggs()
{
	if(!IsDefined (level.radio_counter))
	{
		level.radio_counter = 0;	
	}
	while(level.radio_counter < 3)
	{
		wait(2);	
	}
	level thread play_radio_sounds();
}
battle_radio()
{
	if(!IsDefined (level.radio_counter))
	{
		level.radio_counter = 0;	
	}

	battle_radio_trig = getent ("battle_radio_trigger", "targetname");
	battle_radio_trig UseTriggerRequireLookAt();
	battle_radio_trig SetCursorHint( "HINT_NOICON" );
	battle_radio_origin = getent("battle_radio_origin", "targetname");
	
	battle_radio_trig waittill( "trigger", player);		
	battle_radio_origin playsound ("battle_message");

}
whisper_radio()
{
	if(!IsDefined (level.radio_counter))
	{
		level.radio_counter = 0;	
	}

	whisper_radio_trig = getent ("whisper_radio_trigger", "targetname");
	whisper_radio_trig UseTriggerRequireLookAt();
	whisper_radio_trig SetCursorHint( "HINT_NOICON" );
	whisper_radio_origin = getent("whisper_radio_origin", "targetname");
	
	whisper_radio_trig waittill( "trigger");		
	whisper_radio_origin playsound ("whisper_message");

}
radio_one()
{
	if(!IsDefined (level.radio_counter))
	{
		level.radio_counter = 0;	
	}
	players = getplayers();
	
	radio_one_trig = getent ("radio_one", "targetname");
	radio_one_trig UseTriggerRequireLookAt();
	radio_one_trig SetCursorHint( "HINT_NOICON" );
	radio_one = getent("radio_one_origin", "targetname");
	
	for(i=0;i<players.size;i++)
	{			
		radio_one_trig waittill( "trigger", players);
		
		level.radio_counter = level.radio_counter + 1;
		radio_one playloopsound ("static_loop");

	}	
}
radio_two()
{
	if(!IsDefined (level.radio_counter))
	{
		level.radio_counter = 0;	
	}
	players = getplayers();
	radio_two_trig = getent ("radio_two", "targetname");
	radio_two_trig UseTriggerRequireLookAt();
	radio_two_trig SetCursorHint( "HINT_NOICON" );
	radio_two = getent("radio_two_origin", "targetname");
	
	
	for(i=0;i<players.size;i++)
	{			
		radio_two_trig waittill( "trigger", players);
		level.radio_counter = level.radio_counter + 1;
		radio_two playloopsound ("static_loop");
	
	}	
}
radio_three()
{
	if(!IsDefined (level.radio_counter))
	{
		level.radio_counter = 0;	
	}
	players = getplayers();
	radio_three_trig = getent ("radio_three_trigger", "targetname");
	radio_three_trig UseTriggerRequireLookAt();
	radio_three_trig SetCursorHint( "HINT_NOICON" ); 
	radio_three = getent("radio_three_origin", "targetname");
	for(i=0;i<players.size;i++)
	{			
		radio_three_trig waittill( "trigger", players);
		level.radio_counter = level.radio_counter + 1;			
		radio_three playloopsound ("static_loop");
		
	}	
}
meteor_trigger()
{
	dmgtrig = GetEnt( "meteor", "targetname" );
	players = getplayers();

	triggers = 0;

	while(1)
	{
		dmgtrig waittill("trigger", player);

        if( (distancesquared(player.origin, dmgtrig.origin) < 1096 * 1096) && !isDefined(player.seen_meteor) ) // if seen meteor is true then that means dempsey can proceed with his steps
		{
			player.seen_meteor = true;
			player thread meteor_dialog();
			triggers++;
		}
		else
		{
			wait(0.1);	
		}

		if(triggers >= getplayers().size )
		{
			break;
		}

	}

	
}
meteor_dialog()
{
	index = maps\_zombiemode_weapons::get_player_index(self);
	player_index = "plr_" + index + "_";
	sound_to_play = "vox_gen_meteor_0";
	self maps\_zombiemode_spawner::do_player_playdialog(player_index,sound_to_play, 0.25);
}

waffe_meteor()
{
    level endon("waffle_shot");
    dmgtrig2 = GetEnt( "meteor", "targetname" );

    while(1)
    {
        dmgtrig2 waittill("damage", amount, inflictor);
        weapon = inflictor getcurrentweapon();

        if( weapon == "tesla_gun" && level.meteor_ready == 1 && inflictor.sack == 2 /*&& (level.round_number >= 20 )*/ )
        {
            dmgtrig2 playsound("tesla_happy");
            level thread kill_shock_trigger();
            level thread end_flash();
            level thread phase_three_complete();
            level notify ("waffle_shot");
        }
        else 
        {
			inflictor thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
            wait(0.1);    
        }
    }

}

kill_shock_trigger()
{
	large_meteor = GetEnt( "meteor", "targetname" );

	zombies = getaispeciesarray("axis");
	zombies = get_array_of_closest( large_meteor.origin, zombies );

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
			//zombies[i] thread animscripts\death::flame_death_fx();
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

end_flash()
{
	players = getplayers();	
	for(i=0; i<players.size; i ++)
	{
		players[i] play_sound_2d("nuke_flash");
	}

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

phase_three_complete()
{
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] play_sound_2d("shaka_sting_alt");
	}
	
	wait(3);

	if(players.size >= 4 ) // if 4 player min special scripted dialogue
	{
		//Takeo
		plr = "plr_2_";
		players[2] thread create_and_play_dialog( plr, "vox_success" );
	}

	wait(5);

	for(i = 0; i < players.size; i++)
	{	
		players[i] thread give_all_perks_forever();
		if(players.size >= 4) // must have 4 players to actually get achievement, "canon"
		{
			players[i] setclientdvar("sumpf_quest", 1 ); // all players can now complete der riese quest (if they load in as richtofen on der riese)
			players[i] maps\_zombiemode_achievement::giveachievement_wrapper_new( "DLC2_ZOMBIE_EE" ); 
		}	
	}

	if(players.size >= 4 ) // if 4 player min special scripted dialogue
	{
		//Dempsey
		plr = "plr_0_";
		players[0] thread create_and_play_dialog( plr, "vox_achievment" );
		
		wait(2.5);
		//Nikolai
		plr = "plr_1_";
		players[1] thread create_and_play_dialog( plr, "vox_success" );

		wait(1.75);
		//Richtofen
		plr = "plr_3_";
		players[3] thread create_and_play_dialog( plr, "vox_gen_compliment", 0.25 );

	}
	else // Otherwise if incomplete lobby, just do a random vox from someone
	{
		player = players[randomint(players.size)];
		index = maps\_zombiemode_weapons::get_player_index( player );
		plr = "plr_" + index + "_";
		player thread create_and_play_dialog( plr, "vox_achievment", 0.25 );
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

	players = get_players(); 

	if(!self HasPerk(level._sq_perk_array[2]) && is_player_valid(self))
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[2]);
		wait(0.5);
	}
	if(!self HasPerk(level._sq_perk_array[0]) && is_player_valid(self))
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[0]);
		wait(0.5);
	}
	if(!self HasPerk(level._sq_perk_array[1]) && is_player_valid(self))
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[1]);
		wait(0.5);
	}
	if(!self HasPerk(level._sq_perk_array[3]) && is_player_valid(self) && (players.size != 1) )
	{
		self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[3]);
	}

	//SOLO
	if(!self HasPerk(level._sq_perk_array[3]) && is_player_valid(self) && (players.size == 1 && level.solo_second_lives_left > 0) ) // if not solo, or if no lives, we just skip
	{
		if(	level.solo_second_lives_left > 0 ) // if still have lives, give quick revive
		{
			self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[3]);
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
			if(!self HasPerk(level._sq_perk_array[0]) && is_player_valid(self))
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[0]);
			}
			if(!self HasPerk(level._sq_perk_array[1]) && is_player_valid(self))
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[1]);
			}

			//COOP
			if(!self HasPerk(level._sq_perk_array[3]) && is_player_valid(self) && (players.size != 1) )
			{
				self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[3]);
			}

			//SOLO
			if(!self HasPerk(level._sq_perk_array[3]) && is_player_valid(self) && (players.size == 1 && level.solo_second_lives_left > 0) ) // if not solo, or if no lives, we just skip
			{
				if(	level.solo_second_lives_left > 0 ) // if still have lives, give quick revive
				{
					self thread maps\_zombiemode_perks::give_perk(level._sq_perk_array[3]);
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


item_hud_create(shader)
{
	self.item_hud = create_simple_hud( self );
	self.item_hud.foreground = true; 
	self.item_hud.sort = 2; 
	self.item_hud.hidewheninmenu = false; 
	self.item_hud.alignX = "center"; 
	self.item_hud.alignY = "bottom";
	self.item_hud.horzAlign = "right"; 
	self.item_hud.vertAlign = "bottom";
	self.item_hud.x = -200; 
	self.item_hud.y = -0; 
	self.item_hud.alpha = 1;
	self.item_hud SetShader( shader, 32, 32 );
}

item_hud_remove()
{
	level waittill_any( "end_game", "rope_placed" );
	self.item_hud destroy_hud();
	self.item_hud = undefined;
}
