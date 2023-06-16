#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

init_elec_trap_trigs()
{
	trap_trigs = getentarray("elec_trap_trig","targetname");
	for (i = 0; i < trap_trigs.size; i++)
	{
		trap_trigs[i] thread electric_trap_think();
		trap_trigs[i] thread electric_trap_dialog();
		wait_network_frame();
	}
	//array_thread (trap_trigs,::electric_trap_think);
	//array_thread (trap_trigs,::electric_trap_dialog);
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
				
				players[i] thread do_player_vo("vox_start", 5);	
				wait(3);				
				self notify ("warning_dialog");
				//iprintlnbold("warning_given");
			}
		}
	}
}


/*------------------------------------
self = use trigger associated with the gas valve
------------------------------------*/
electric_trap_think()
{	
	self sethintstring(&"ZOMBIE_BUTTON_NORTH_FLAMES");
	self setCursorHint( "HINT_NOICON" );
	self.is_available = true;
	self.zombie_cost = 1000;
	self.in_use = 0;
	level thread maps\nazi_zombie_sumpf::turnLightGreen(self.script_string);
	
	while(1)
	{
		//valve_trigs = getentarray(self.script_noteworthy ,"script_noteworthy");		
	
		//wait until someone uses the valve
		self waittill("trigger",who);
		if( who in_revive_trigger() )
		{
			continue;
		}
		
		if(!isDefined(self.is_available))
		{			
			continue;			
		}
				
		if( is_player_valid( who ) )
		{
			if( who.score >= self.zombie_cost )
			{				
				if(!self.in_use)
				{
					self.in_use = 1;
					play_sound_at_pos( "purchase", who.origin );
					who thread add_trap_dialog();
					self thread electric_trap_move_switch(self);
					//need to play a 'woosh' sound here, like a gas furnace starting up
					self waittill("switch_activated");
					//set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );

					//turn off the valve triggers associated with this valve until the gas is available again
					//array_thread (valve_trigs,::trigger_off);
					self trigger_off();
					level thread maps\nazi_zombie_sumpf::turnLightRed(self.script_string);
					
					//this trigger detects zombies walking thru the flames
					self.zombie_dmg_trig = getent(self.target,"targetname");
					self.zombie_dmg_trig trigger_on();
					
					//play the flame FX and do the actual damage
					self thread activate_electric_trap(who);					
					
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
					self notify("trap_over");

					wait(60);
					//array_thread (valve_trigs,::trigger_on);
					self trigger_on();
					level thread maps\nazi_zombie_sumpf::turnLightGreen(self.script_string);
				
					//Play the 'alarm' sound to alert players that the traps are available again (playing on a temp ent in case the PA is already in use.
					pa_system = getent("speaker_by_log", "targetname");
					playsoundatposition("warning", pa_system.origin);
					self notify("available");

					self.in_use = 0;					
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				who thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
			}
		}
	}
}
add_trap_dialog()
{
	// using the barrel lines for the electrical traps.
	if(randomintrange(0,100) < 26)
	{
		index = maps\_zombiemode_weapons::get_player_index(self);	
		player_index = "plr_" + index + "_";
		if(!IsDefined (self.vox_trap_barrel))
		{
			num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_trap_barrel");
			self.vox_trap_barrel = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_trap_barrel[self.vox_trap_barrel.size] = "vox_trap_barrel_" + i;	
			}
			self.vox_trap_barrel_available = self.vox_trap_barrel;		
		}	
		sound_to_play = random(self.vox_trap_barrel_available);
		
		self.vox_trap_barrel_available = array_remove(self.vox_trap_barrel_available,sound_to_play);
		
		if (self.vox_trap_barrel_available.size < 1 )
		{
			self.vox_trap_barrel_available = self.vox_trap_barrel;
		}
				
		self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	}
	
}

//this used to be a gas valve, now it's a throw switch
electric_trap_move_switch(parent)
{
	tswitch = getent(parent.script_linkto,"script_linkname");
	if(tswitch.script_linkname == "110")
	{
		//turn the light above the door red
		//north_zapper_light_red();
		//machine = getent("zap_machine_north","targetname");		

		tswitch rotatepitch(180,.5);
		tswitch playsound("amb_sparks_l_b");
		tswitch waittill("rotatedone");
		self notify("switch_activated");
		self waittill("trap_over");
		tswitch rotatepitch(-180,.5);
		tswitch playsound("switch_up");
		self waittill("available");
		
		//turn the light back green once the trap is available again
		//north_zapper_light_green();
	}
	else if(tswitch.script_linkname == "111")
	{
		//south_zapper_light_red();	
		
		tswitch rotatepitch(180,.5);
		tswitch playsound("amb_sparks_l_b");
		tswitch waittill("rotatedone");
		self notify("switch_activated");
		self waittill("trap_over");
		tswitch rotatepitch(-180,.5);
		tswitch playsound("switch_up");
		self waittill("available");
		
		//south_zapper_light_green();
	}
	else if(tswitch.script_linkname == "112")
	{
		//south_zapper_light_red();	
		
		tswitch rotatepitch(180,.5);
		tswitch playsound("amb_sparks_l_b");
		tswitch waittill("rotatedone");
		self notify("switch_activated");
		self waittill("trap_over");
		tswitch rotatepitch(-180,.5);
		tswitch playsound("switch_up");
		self waittill("available");
		
		//south_zapper_light_green();
	}
	else if(tswitch.script_linkname == "113")
	{
		//south_zapper_light_red();	
		
		tswitch rotatepitch(180,.5);
		tswitch playsound("amb_sparks_l_b");
		tswitch waittill("rotatedone");
		self notify("switch_activated");
		self waittill("trap_over");
		tswitch rotatepitch(-180,.5);
		tswitch playsound("switch_up");
		self waittill("available");
		
		//south_zapper_light_green();
	}

}

activate_electric_trap(who)
{
	clientnotify(self.target);
	
	fire_points = getstructarray(self.target,"targetname");
	
	for(i=0;i<fire_points.size;i++)
	{
		wait_network_frame();
		fire_points[i] thread electric_trap_fx(self);		
	}
	
	//do the damage
	self.zombie_dmg_trig thread elec_barrier_damage(who);
	
	// reset the zapper model
	level waittill("arc_done");
	//machine setmodel("zombie_zapper_power_box");
}


electric_trap_fx(notify_ent)
{
	self.tag_origin = spawn("script_model",self.origin);
	//self.tag_origin setmodel("tag_origin");

	//playfxontag(level._effect["zapper"],self.tag_origin,"tag_origin");

//	if(isDefined(self.script_sound))
//	{
		self.tag_origin playsound("elec_start");
		self.tag_origin playloopsound("elec_loop");
		self thread play_electrical_sound();
//	} 
	wait(30);
		
	if(isDefined(self.script_sound))
	{
		self.tag_origin stoploopsound();
	}
	self.tag_origin delete(); 
	notify_ent notify("elec_done");
	level notify ("arc_done");
	
}
play_electrical_sound()
{
	level endon ("arc_done");
	while(1)
	{	
		wait(randomfloatrange(0.1, 0.5));
		playsoundatposition("elec_arc", self.origin);
	}
	

}
elec_barrier_damage(who)
{
	
	while(1)
	{
		self waittill("trigger",ent);
		
		//player is standing flames, dumbass
		if(isplayer(ent) )
		{
			ent thread player_elec_damage();
		}
		else
		{
			if ( ent enemy_is_dog() && is_magic_bullet_shield_enabled( ent ) )
			{
				continue;
			}
			
			if(!isDefined(ent.marked_for_death))
			{
				ent.marked_for_death = true;
				ent thread zombie_elec_death( randomint(100) );
				who.trapped_used[self.targetname] = level.round_number;
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
	if(!self enemy_is_dog())
	{	
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
			if( randomint(100) > 50 )
			{
				self thread electroctute_death_fx();
				self thread play_elec_vocals();
			}
			wait(randomfloat(1.25));
			self playsound("zombie_arc");
		}
	}
	else // if dog
	{
		wait(randomfloat(0.5));
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
	
	
	//PlayFxOnTag( level._effect["elec_torso"], self, "J_SpineLower" ); 
	//self playsound ("elec_jib_zombie");
	// JMA - death fx thread would end because zombie would die first before fx would be played
	//wait 1;

	tagArray = []; 
	tagArray[0] = "J_Elbow_LE"; 
	tagArray[1] = "J_Elbow_RI"; 
	tagArray[2] = "J_Knee_RI"; 
	tagArray[3] = "J_Knee_LE"; 
	tagArray = array_randomize( tagArray ); 

	// JMA - make sure it's defined
	if( isDefined(tagArray[0] ) )
	{
		PlayFxOnTag( level._effect["elec_md"], self, tagArray[0] ); 
	}
	
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

	if( isDefined(tagArray[0] ) )
	{
		PlayFxOnTag( level._effect["elec_sm"], self, tagArray[0] ); 
	}
	
	if( isDefined(tagArray[1] ) )
	{
		PlayFxOnTag( level._effect["elec_sm"], self, tagArray[1] );
	}
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