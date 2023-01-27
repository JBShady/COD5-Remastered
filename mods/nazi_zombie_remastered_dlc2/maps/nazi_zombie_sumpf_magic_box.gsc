#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\nazi_zombie_sumpf_trap_pendulum;
//#include maps\nazi_zombie_sumpf_trap_electric;
//#include maps\nazi_zombie_sumpf_trap_propeller;
#include maps\nazi_zombie_sumpf_blockers;
#include maps\nazi_zombie_sumpf_zone_management;

magic_box_init()
{
      maps\nazi_zombie_sumpf::activate_door_flags("magic_blocker", "script_noteworthy");
		
      level.open_chest_location = [];
      level.open_chest_location[0] = undefined;
		level.open_chest_location[1] = undefined;
		level.open_chest_location[2] = undefined;
		level.open_chest_location[3] = undefined;
		level.open_chest_location[4] = "start_chest";
		level.open_chest_location[5] = "attic_chest";
		
		//Declaring global bool that monitors perk huts
		players = get_players();
		if(players.size < 2)
		{
            level.first_time_opening_perk_hut = true;
        }
		
		level thread waitfor_flag_open_chest_location("nw_magic_box");
		level thread waitfor_flag_open_chest_location("ne_magic_box");
		level thread waitfor_flag_open_chest_location("se_magic_box");
		level thread waitfor_flag_open_chest_location("sw_magic_box");
}

waitfor_flag_open_chest_location(which)
{
     wait(3);
		     
     switch(which)
     {
     case "nw_magic_box":
         flag_wait("nw_magic_box");
         level.open_chest_location[0] = "nw_chest";
         
         // activate zones to that area 
         thread maps\nazi_zombie_sumpf_zone_management::activate_outdoor_zones("northwest","targetname");			

			// spawn initial zombies
			if (get_enemy_count() != 0 && !flag("dog_round"))
			{				
				thread maps\nazi_zombie_sumpf::spawn_initial_outside_zombies( "northwest_initial_zombies" );
			}
			
			// JV initialize the swinging concrete block
			maps\nazi_zombie_sumpf_trap_pendulum::initPendulumTrap();	
				
			//JV pendulum cannot be activated until this debris is cleared
			penBuyTrigger = getentarray("pendulum_buy_trigger","targetname");
			array_thread (penBuyTrigger, maps\nazi_zombie_sumpf_trap_pendulum::penThink);
			
			// adding spawners when area is opened
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("nw_magic_box_dog_spawners");
			
         break;
          
     case "ne_magic_box":
         flag_wait("ne_magic_box");
         level.open_chest_location[1] = "ne_chest";
          
         // activate zones to that area
			thread maps\nazi_zombie_sumpf_zone_management::activate_outdoor_zones("northeast","targetname");			
          
			// spawn initial zombies
			if (get_enemy_count() != 0 && !flag("dog_round"))
			{
				thread maps\nazi_zombie_sumpf::spawn_initial_outside_zombies( "northeast_initial_zombies" );
			}
			
			// JV initialize the easy access routes
			level thread maps\nazi_zombie_sumpf_zipline::initZipline();
			
			// adding dog spawners when area is opened
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("ne_magic_box_dog_spawners");
						
         break;
          
     case "se_magic_box":
	      flag_wait("se_magic_box");
	      level.open_chest_location[2] = "se_chest";

	      // activate zones to that area
			thread maps\nazi_zombie_sumpf_zone_management::activate_outdoor_zones("southeast","targetname");			
          
			// spawn initial zombies
			if (get_enemy_count() != 0 && !flag("dog_round"))
			{
				thread maps\nazi_zombie_sumpf::spawn_initial_outside_zombies( "southeast_initial_zombies" );
			}
			
			// adding dog spawners when area is opened
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("se_magic_box_dog_spawners");
			
         break;
          
     case "sw_magic_box":
         flag_wait("sw_magic_box");
         level.open_chest_location[3] = "sw_chest";
          
         // activate zones to that area
			thread maps\nazi_zombie_sumpf_zone_management::activate_outdoor_zones("southwest","targetname");			

			// spawn initial zombies
			if (get_enemy_count() != 0 && !flag("dog_round"))
			{
				thread maps\nazi_zombie_sumpf::spawn_initial_outside_zombies( "southwest_initial_zombies" );
			}
			
			// adding dog spawners when area is opened
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("sw_magic_box_dog_spawners");
						
         break;
          
     default:
          return;
     
     }
     
     // JMA - here is where we actually randomize perks and weapons when the first blockable is unlocked
     if(isDefined(level.randomize_perks) && level.randomize_perks == false)
     {
			maps\nazi_zombie_sumpf_perks::randomize_vending_machines();

            level.vending_model_info = [];			
			level.vending_model_info[level.vending_model_info.size] = "zombie_vending_jugg_on_price";     
        	level.vending_model_info[level.vending_model_info.size] = "zombie_vending_doubletap_price";
        	level.vending_model_info[level.vending_model_info.size] = "zombie_vending_revive_on_price";   
        	level.vending_model_info[level.vending_model_info.size] = "zombie_vending_sleight_on_price";
			
			//Weighting the weapons with the vending machine names
			//Format - "vending_machine_name1:gun1,gun2,gun3,gun4,:;vending_machine_name2...etc."
			//Vending Machines: vending_doubletap, vending_jugg, vending_revive, vending_sleight,
		
		   //Guns:30cal,bar,doublebarrel, doublebarrel_sawed_grip,fg42,gewehr43,kar98k_scoped_zombie,m1carbine,m1garand
		   //  ,m1garand_gl_zombie,mg42,type100_smg,panzerschrek_zombie,ppsh,ptrs41_zombie,shotgun,springfield,stg44,sw_357,thompson 
		   
// 			list = "vending_doubletap:30cal,bar,doublebarrel_sawed_grip,fg42:;";
// 			list = list + "vending_jugg:gewehr43,m1carbine,mg42,m1garand_gl_zombie:;";		
// 			list = list + "vending_revive:type100_smg, panzerschrek_zombie,ppsh,ptrs41_zombie:;";
// 			list = list + "vending_sleight:shotgun,springfield,stg44,sw_357:;";
// 		
// 		 	maps\nazi_zombie_sumpf_perks::randomize_weapons(list);
// 		 	maps\_zombiemode_weapons::init_weapon_upgrade();
// 			
			level.randomize_perks = true;
     }
     
     //adding flag waits for after vending machines are randomized
     switch(which)
     {
        case "nw_magic_box":
            flag_wait("northwest_building_unlocked");
            maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("nw_perk_hut_dog_spawners");
			maps\nazi_zombie_sumpf_perks::vending_randomization_effect(0);
            break;
        case "ne_magic_box":
            flag_wait("northeast_building_unlocked");
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("ne_perk_hut_dog_spawners");
            maps\nazi_zombie_sumpf_perks::vending_randomization_effect(1);
            break;
        case "se_magic_box":
            flag_wait("southeast_building_unlocked");
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("se_perk_hut_dog_spawners");
            maps\nazi_zombie_sumpf_perks::vending_randomization_effect(2);
            break;
        case "sw_magic_box":
            flag_wait("southwest_building_unlocked");
			maps\nazi_zombie_sumpf_zone_management::add_area_dog_spawners("sw_perk_hut_dog_spawners");
            maps\nazi_zombie_sumpf_perks::vending_randomization_effect(3);	
            break;
     }
}

// This function makes sure that the first move is in the perks hut and afterwards to any random location
magic_box_tracker()
{
	// wait until the first move
	level waittill("weapon_fly_away_start");
	
	// make sure weapon box spawns in one of the perks hut as the first move
   level.open_chest_location[0] = "nw_chest";
	level.open_chest_location[1] = "ne_chest";
	level.open_chest_location[2] = "se_chest";
	level.open_chest_location[3] = "sw_chest";
	level.open_chest_location[4] = undefined;
	level.open_chest_location[5] = undefined;			

	// JMA - used to determine if magic box has moved
	level.magic_box_first_move = true;
	
	// magic box has finished the first move
	level waittill("magic_box_light_switch");

	// make the weapon box move to any of the six locations
   level.open_chest_location[0] = "nw_chest";
	level.open_chest_location[1] = "ne_chest";
	level.open_chest_location[2] = "se_chest";
	level.open_chest_location[3] = "sw_chest";
	level.open_chest_location[4] = "start_chest";
	level.open_chest_location[5] = "attic_chest";
}
