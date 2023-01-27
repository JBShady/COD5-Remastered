#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;


randomize_vending_machines()
{
	// grab all the vending machines
	vending_machines = [];
	vending_machines = getentarray("zombie_vending","targetname");	
		
	// grab all vending machine start locations
	start_locations = [];
	start_locations[0] = getent("random_vending_start_location_0", "script_noteworthy");
	start_locations[1] = getent("random_vending_start_location_1", "script_noteworthy");
	start_locations[2] = getent("random_vending_start_location_2", "script_noteworthy");
	start_locations[3] = getent("random_vending_start_location_3", "script_noteworthy");

    //Save the origin data of all the start locations	
	level.start_locations = [];
	level.start_locations[level.start_locations.size] = start_locations[0].origin;
	level.start_locations[level.start_locations.size] = start_locations[1].origin;
	level.start_locations[level.start_locations.size] = start_locations[2].origin;
	level.start_locations[level.start_locations.size] = start_locations[3].origin;
	
	level.perks_opened = 0;

	start_locations = array_randomize(start_locations);

	for(i=0;i<vending_machines.size;i++)
	{
		origin = start_locations[i].origin;
		angles = start_locations[i].angles;	
	
		machine = vending_machines[i] get_vending_machine(start_locations[i]);
		
		start_locations[i].origin = origin;
		start_locations[i].angles = angles;
		machine.origin = origin;
		machine.angles = angles;
		
		machine hide();                                                                 
		vending_machines[i] trigger_on();
	}
}

get_vending_machine(start_location)
{
	machine = GetEnt(self.target, "targetname");
	
	start_location.origin = machine.origin;
	start_location.angles = machine.angles;

	self enablelinkto();
	
	self linkto(start_location);
//      machine linkto(start_location);

    return machine;
}

activate_vending_machine(machine, origin)
{
	//activate perks-a-cola
	level notify( "master_switch_activated" );
	
	switch(machine)
	{

	   case "zombie_vending_jugg_on_price":     	
	        level notify("juggernog_sumpf_on");
	        clientnotify("jugg_on");	         
           break;
                
	   case "zombie_vending_doubletap_price":
	        level notify("doubletap_sumpf_on");
	        clientnotify("doubletap_on");
	        break;
	        
	   case "zombie_vending_revive_on_price":
	        level notify("revive_sumpf_on");	
	        clientnotify("revive_on");
           break;
           
       case "zombie_vending_sleight_on_price":
	        level notify("sleight_sumpf_on");
	        clientnotify("fast_reload_on");
           break;
   }
   
   play_vending_vo( machine, origin );	
}

play_vending_vo( machine, origin )
{
	players = get_players();		
	players_somewhat_near = get_array_of_closest( origin, players, undefined, undefined, 512 );
	players_super_near = get_array_of_closest( origin, players, undefined, undefined, 192 );

	player = undefined;
		
	for( i = 0; i < players_somewhat_near.size; i++ )
	{
		if ( SightTracePassed( players_somewhat_near[i] GetEye(), origin, false, undefined ) )
		{
			player = players_somewhat_near[i];
			//iprintln("aimed at perk");
		}
		else if(players_super_near > 0 )
		{
			player = players_super_near[i];
			//iprintln("super near");
		}
	}
	
	if ( !IsDefined( player ) )
	{
		return;
	}
//	player thread play_rando_perk_dialog();
	
	switch( machine )
	{

	   case "zombie_vending_jugg_on_price":     	
			player thread play_jugga_shout();
	
           break;
                
	   case "zombie_vending_doubletap_price":
			player thread play_dbltap_shout();
	
	        break;
	        
	   case "zombie_vending_revive_on_price":
			player thread play_revive_shout();
	
           break;
           
       case "zombie_vending_sleight_on_price":
			player thread play_speed_shout();
	
           break;
   }	
	
}

play_jugga_shout()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_perk_jugga))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_perk_jugga");
		self.vox_gen_perk_jugga = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_perk_jugga[self.vox_gen_perk_jugga.size] = "vox_gen_perk_jugga_" + i;	
		}
		self.vox_gen_perk_jugga_available = self.vox_gen_perk_jugga;		
	}	
	sound_to_play = random(self.vox_gen_perk_jugga_available);
	
	self.vox_gen_perk_jugga_available = array_remove(self.vox_gen_perk_jugga_available,sound_to_play);
	
	if (self.vox_gen_perk_jugga_available.size < 1 )
	{
		self.vox_gen_perk_jugga_available = self.vox_gen_perk_jugga;
	}
	wait(2);		
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
}
play_dbltap_shout()
{

	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_perk_dbltap))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_perk_dbltap");
		self.vox_gen_perk_dbltap = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_perk_dbltap[self.vox_gen_perk_dbltap.size] = "vox_gen_perk_dbltap_" + i;	
		}
		self.vox_gen_perk_dbltap_available = self.vox_gen_perk_dbltap;		
	}	
	sound_to_play = random(self.vox_gen_perk_dbltap_available);
	
	self.vox_gen_perk_dbltap_available = array_remove(self.vox_gen_perk_dbltap_available,sound_to_play);
	
	if (self.vox_gen_perk_dbltap_available.size < 1 )
	{
		self.vox_gen_perk_dbltap_available = self.vox_gen_perk_dbltap;
	}
	wait(2);		
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
}
play_revive_shout()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_perk_revive))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_perk_revive");
		self.vox_gen_perk_revive = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_perk_revive[self.vox_gen_perk_revive.size] = "vox_gen_perk_revive_" + i;	
		}
		self.vox_gen_perk_revive_available = self.vox_gen_perk_revive;		
	}	
	sound_to_play = random(self.vox_gen_perk_revive_available);
	
	self.vox_gen_perk_revive_available = array_remove(self.vox_gen_perk_revive_available,sound_to_play);
	
	if (self.vox_gen_perk_revive_available.size < 1 )
	{
		self.vox_gen_perk_revive_available = self.vox_gen_perk_revive;
	}
	wait(2);		
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
}
play_speed_shout()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_perk_speed))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_perk_speed");
		self.vox_gen_perk_speed = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_perk_speed[self.vox_gen_perk_speed.size] = "vox_gen_perk_speed_" + i;	
		}
		self.vox_gen_perk_speed_available = self.vox_gen_perk_speed;		
	}	
	sound_to_play = random(self.vox_gen_perk_speed_available);
	
	self.vox_gen_perk_speed_available = array_remove(self.vox_gen_perk_speed_available,sound_to_play);
	
	if (self.vox_gen_perk_speed_available.size < 1 )
	{
		self.vox_gen_perk_speed_available = self.vox_gen_perk_speed;
	}
	wait(2);		
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);	
	
}
play_rando_perk_dialog()
{
	if(randomintrange(0,100) < 50 && ( level.perks_opened == 2 || level.perks_opened == 3 ))
	{
	wait(1);
	//player = getplayers();	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_perk_lottery))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_perk_lottery");
		self.vox_perk_lottery = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_perk_lottery[self.vox_perk_lottery.size] = "vox_perk_lottery_" + i;	
		}
		self.vox_perk_lottery_available = self.vox_perk_lottery;		
	}	
	sound_to_play = random(self.vox_perk_lottery_available);
	
	self.vox_perk_lottery_available = array_remove(self.vox_perk_lottery_available,sound_to_play);
	
	if (self.vox_perk_lottery_available.size < 1 )
	{
		self.vox_perk_lottery_available = self.vox_perk_lottery;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	}

}
vending_randomization_effect(index)
{

	level.perks_opened = level.perks_opened + 1;

	vending_triggers = getentarray("zombie_vending","targetname");
	machines = [];

	for( j = 0; j < vending_triggers.size; j++)
	{
		machines[j] = getent(vending_triggers[j].target, "targetname");
	}

	for( j = 0; j < machines.size; j++)
	{
		if(machines[j].origin == level.start_locations[index])
		{
			break;
		}
	}
	
/*	if(isDefined(level.first_time_opening_perk_hut))
	{
        if(level.first_time_opening_perk_hut)
        {
            if(machines[j].model != "zombie_vending_jugg_on_price" || machines[j].model != "zombie_vending_sleight_on_price")
            {
                for( i = 0; i < machines.size; i++)
                {
                    if( i != j && (machines[i].model == "zombie_vending_jugg_on_price" || machines[i].model == "zombie_vending_sleight_on_price"))
                    {
                        break;
                    }
                }
                
                // grab all vending machine start locations
            	start_locations = [];
            	start_locations[0] = getent("random_vending_start_location_0", "script_noteworthy");
            	start_locations[1] = getent("random_vending_start_location_1", "script_noteworthy");
            	start_locations[2] = getent("random_vending_start_location_2", "script_noteworthy");
            	start_locations[3] = getent("random_vending_start_location_3", "script_noteworthy");

                target_index = undefined;
                switch_index = undefined;
            	
            	for( x = 0; x < start_locations.size; x++)
            	{
                    if(start_locations[x].origin == level.start_locations[index])
                    {
                        target_index = x;
                    }
                    
                    if(start_locations[x].origin == machines[i].origin)
                    {
                        switch_index = x;
                    }
                }
                
                temp_origin = machines[j].origin;
                temp_angles = machines[j].angles;
                machines[j].origin = machines[i].origin;
                machines[j].angles = machines[i].angles;
                start_locations[target_index].origin = start_locations[switch_index].origin;
                start_locations[target_index].angles = start_locations[switch_index].angles;
                machines[i].origin = temp_origin;
                machines[i].angles = temp_angles;
                start_locations[switch_index].origin = temp_origin;
                start_locations[switch_index].angles = temp_angles;
                j = i;                
            }
            
            level.first_time_opening_perk_hut = false;
        }
    }*/

	playsoundatposition("rando_start",machines[j].origin);
	
	origin = machines[j].origin;
	// 	shock = spawnfx(level._effect["zapper"], origin);
	// shock = spawnfx(level._effect["stub"], origin);
	players = get_players();		
	players = get_array_of_closest( origin, players, undefined, undefined, 525 );

	player = players[randomintrange(0,players.size)];
	player thread play_rando_perk_dialog();

	if( level.vending_model_info.size  > 1 )
	{
		PlayFxOnTag(level._effect["zombie_perk_start"], machines[j], "tag_origin" );
		playsoundatposition("rando_perk", machines[j].origin);
	}
	else
	{

		PlayFxOnTag(level._effect["zombie_perk_4th"], machines[j], "tag_origin" );
		playsoundatposition("rando_perk", machines[j].origin);

	}

	true_model = machines[j].model;

	machines[j] setmodel(true_model);    
	machines[j] show();

	floatHeight = 40;
	
	//play 2D sound for everybody
	
	level thread play_sound_2D("perk_lottery");
	
	//playsoundatposition("perk_lottery", (0,0,0));
	
	//move it up
	machines[j] moveto( origin +( 0, 0, floatHeight ), 5, 3, 0.5 );
	//triggerfx(shock);

	tag_fx = Spawn( "script_model", machines[j].origin + (0,0,40));
	tag_fx SetModel( "tag_origin" );
	tag_fx LinkTo(machines[j]);

	modelindex = 0;    
	machines[j] Vibrate( machines[j].angles, 2, 1, 4);
	for( i = 0; i < 30; i++)      
	{                             

	/*	if( i < 20 )
		{
			wait( 0.2 ); 
		}
		else if( i < 30 )
		{
			wait( 0.35 ); 
		}
		else if( i < 35 )
		{
			wait( 0.4 ); 
		}
		else if( i < 38 )
		{
			wait( 0.5 ); 
		}*/

		wait(0.15);



		if(level.vending_model_info.size > 1)
		{
			while(!isdefined(level.vending_model_info[modelindex]))
			{
				modelindex++;

				if(modelindex == 4)
				{
					modelindex = 0;
				}
			}

			modelname = level.vending_model_info[modelindex];
			machines[j] setmodel( modelname ); 
			PlayFxOnTag(level._effect["zombie_perk_flash"], tag_fx, "tag_origin" );
			modelindex++;
		

			if(modelindex == 4)
			{
				modelindex = 0;
			}
		}
	}
	
	//shock delete();

	modelname = true_model;
	machines[j] setmodel( modelname );

	//move it down
	machines[j] moveto( origin, 0.3, 0.3, 0 );
	PlayFxOnTag(level._effect["zombie_perk_end"], machines[j], "tag_origin" );
	playsoundatposition ("perks_rattle", machines[j].origin);
	maps\nazi_zombie_sumpf_perks::activate_vending_machine(true_model, origin);
	for(i = 0; i < machines.size; i++)
	{
		if(isdefined(level.vending_model_info[i]))
		{
			if(level.vending_model_info[i] == true_model)
			{
				level.vending_model_info[i] = undefined;
				break;
			}
		}
	}
}

randomize_weapons(list)
{ 
	// grab all the vending machines with their weights into separate lists
   vending_machines_with_weights = strTok(list, ";");
    
	// grab all the vending machines
	vending_machine_list = getentarray("zombie_vending","targetname");
  
	// grab all vending machine start locations
	start_locations = [];
	start_locations[0] = getent("random_vending_start_location_0", "script_noteworthy");
	start_locations[1] = getent("random_vending_start_location_1", "script_noteworthy");
	start_locations[2] = getent("random_vending_start_location_2", "script_noteworthy");
	start_locations[3] = getent("random_vending_start_location_3", "script_noteworthy");

	//loop through all the lists  
	for(i = 0; i < vending_machines_with_weights.size; i++)
	{    
		vending_machine = strTok(vending_machines_with_weights[i],":");
    
		index = 0;
		for(; index < vending_machine_list.size; index++)
		{
      	if(vending_machine_list[index].target == vending_machine[0])
      	{
				break;
			}
		}
    
		weaponList = strTok(vending_machine[1], ",");
		vending_location = getent(vending_machine_list[index].target, "targetname");
    
		location = 0;
		for(; location < start_locations.size; location++)
		{
			if(start_locations[location].origin == vending_location.origin)
			{
				break;        
			}
		}
    
		switch(location)
		{ 
			case 0:
				randomize_weapons_for_building("rws_nw", weaponList);
				break;
				
			case 1:
				randomize_weapons_for_building("rws_ne", weaponList);
				break;
				
			case 2:
				randomize_weapons_for_building("rws_se", weaponList);
				break;
			
			case 3:
				randomize_weapons_for_building("rws_sw", weaponList);
				break;
		} 
	}
}

randomize_weapons_for_building( spawnpoint_name, weaponList )
{
	start_locations = [];
	start_locations = getEntArray( spawnpoint_name, "script_noteworthy");
	weaponList = array_randomize(weaponList);

	for(j = 0; j < start_locations.size; j++)
	{
		origin = start_locations[j].origin;
		angles = start_locations[j].angles;
		trigger = start_locations[j];
    
		trigger.targetname = "weapon_upgrade";
		trigger.zombie_weapon_upgrade = weaponList[j];
    
		rand = randomIntRange(j*weaponList.size, (j+1)*weaponList.size);
		trigger.target = weaponList[j] + rand;
    
		model_name = GetWeaponModel(weaponList[j]);
		weapon = spawn("script_model", origin);
		weapon setmodel(model_name);
		weapon.targetname = trigger.target;
		weapon.angles = angles;
		trigger trigger_on();
	}
}


say_down_vo()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_down_gen))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_down_gen");
		self.vox_down_gen = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_down_gen[self.vox_down_gen.size] = "vox_down_gen_" + i;	
		}
		self.vox_down_gen_available = self.vox_down_gen;		
	}	
	sound_to_play = random(self.vox_down_gen_available);
	
	self.vox_down_gen_available = array_remove(self.vox_down_gen_available,sound_to_play);
	
	if (self.vox_down_gen_available.size < 1 )
	{
		self.vox_down_gen_available = self.vox_down_gen;
	}
	wait(0.5);	//waits so player grunt doesn't overlap with down VO	
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	
}


say_revived_vo()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_revived))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_revived");
		self.vox_revived = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_revived[self.vox_revived.size] = "vox_revived_" + i;	
		}
		self.vox_revived_available = self.vox_revived;		
	}	
	sound_to_play = random(self.vox_revived_available);
	
	self.vox_revived_available = array_remove(self.vox_revived_available,sound_to_play);
	
	if (self.vox_revived_available.size < 1 )
	{
		self.vox_revived_available = self.vox_revived;
	}
			
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	
}