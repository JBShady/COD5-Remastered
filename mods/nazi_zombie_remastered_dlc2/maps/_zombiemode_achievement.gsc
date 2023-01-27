#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility; 

init()
{

	level thread init_achievement_variable();
	players = getplayers();
	for(i = 0 ; i < players.size; i++)
	{
		players[i].trapped_used = [];
		players[i].trapped_used["north_east_tgt"] = -1;
		players[i].trapped_used["north_west_tgt"] = -1;
		players[i].trapped_used["south_east_tgt"] = -1;
		players[i].trapped_used["south_west_tgt"] = -1;
		players[i].trapped_used["log_trap"] = -1;

		players[i] thread track_general_contractor();
		players[i] thread track_WMD_achievement();
		players[i] thread tracks_highroller_achievement();
		//players[i] thread track_hell_hound_kills();
		players[i] thread track_perk_a_holic();
		players[i] thread survive_rounds_without_revive();
		players[i] thread track_instant_melee_kills();
		players[i] thread track_headshot_count();
		players[i] thread track_total_zombie_killed();
		players[i] thread track_trap_killed();
	
	}
}
init_achievement_variable()
{
	set_zombie_var("Achievement_General_Contractor", 10);
	set_zombie_var("Achievement_WMD", 5);
	set_zombie_var("Achievement_HighRoller", 5000);
	set_zombie_var("Achievement_Survivor_1", 10);
	set_zombie_var("Achievement_Insta_Melee_Kills", 3);
	set_zombie_var("Achievement_Headshot_count", 150);
	set_zombie_var("Achievement_Crypt_Keeper", 200);
}
track_trap_killed()
{
	zombie_killed_with_trap = 0;
	wait(10);
	while(IsDefined(self))
	{
		if( level.round_number == self.trapped_used["north_east_tgt"] )
		{
			zombie_killed_with_trap += 1;
		}

		if( level.round_number == self.trapped_used["north_west_tgt"] )
		{
			zombie_killed_with_trap += 1;
		}
		
		if( level.round_number == self.trapped_used["south_east_tgt"] )
		{
			zombie_killed_with_trap += 1;
		}
		
		if( level.round_number == self.trapped_used["south_west_tgt"] )
		{
			zombie_killed_with_trap += 1;
		}
		
		if( level.round_number == self.trapped_used["log_trap"] )
		{
			zombie_killed_with_trap += 1;
		}

		if( zombie_killed_with_trap >= 3 )
		{
				//self play_achievement_dialog();
				self giveachievement_wrapper_new( "DLC2_ZOMBIE_ALL_TRAPS" ); 
				return;
		}
		else
			zombie_killed_with_trap = 0;

		wait(0.5);
	}

}
track_total_zombie_killed()
{

	while(IsDefined(self))
	{
		if(IsDefined(self.kill_tracker))
		{
			if(self.kill_tracker >= level.zombie_vars["Achievement_Crypt_Keeper"])
			{

				//self play_achievement_dialog();
				self giveachievement_wrapper_new( "DLC2_ZOMBIE_KILLS" ); 
				return;

			}

		}

		wait(0.5);

	}

}

track_headshot_count()
{

	while(IsDefined(self))
	{

		if(IsDefined(self.headshots))
		{
			if(self.headshots >= level.zombie_vars["Achievement_Headshot_count"])
			{	

				//self play_achievement_dialog();
				self giveachievement_wrapper_new( "DLC2_ZOMBIE_HEADSHOTS" ); 
				return;

			}

		}

		wait(0.5);


	}


}
track_instant_melee_kills()
{
	instant_melee_kill = 0;
	self.last_kill_method = "none";
	self endon("brawler_achievement_unlocked");

	while(IsDefined(self))
	{
		while(level.zombie_vars["zombie_insta_kill"]  == 1)
		{
			self waittill_either("zombie_killed", "insta_kill_over");
			if(self.last_kill_method == "MOD_MELEE" && level.zombie_vars["zombie_insta_kill"] == 1)
			{
				instant_melee_kill += 1;
			}
			else
			{
				instant_melee_kill = 0;
				continue;
			}

			if(instant_melee_kill >= level.zombie_vars["Achievement_Insta_Melee_Kills"])
			{

				//self play_achievement_dialog();
				self giveachievement_wrapper_new( "DLC2_ZOMBIE_MELEE_KILLS" ); 
				self notify("brawler_achievement_unlocked");

			}

		}

		wait(0.1);

		instant_melee_kill = 0;

	}

}

survive_rounds_without_revive()
{
	self endon("I_am_down");
	Achievement_unlock = false;
	while(IsDefined(self))
	{

		if(IsDefined(level.round_number) && level.round_number == level.zombie_vars["Achievement_Survivor_1"] && Achievement_unlock == false)
		{
			//self play_achievement_dialog();
			self giveachievement_wrapper_new( "DLC2_ZOMBIE_SURVIVOR" ); 
			Achievement_unlock = true;
			break;
		}

		wait(0.5);


	}


}
track_perk_a_holic()
{
	while(IsDefined(self))
	{


		if(IsDefined(self.perk_hud) && self.perk_hud.size == 4)
		{
			//self play_achievement_dialog();
			self giveachievement_wrapper_new( "DLC2_ZOMBIE_ALL_PERKS" ); 
			break;
		}

		wait(0.5);
	}



}

track_general_contractor()
{
	self.board_repair = 0;

	while(IsDefined(self))
	{
		if(self.board_repair >= level.zombie_vars["Achievement_General_Contractor"])
		{
			//self play_achievement_dialog();
			self giveachievement_wrapper_new( "DLC2_ZOMBIE_REPAIR_BOARDS" ); 
			break;
		}

		wait(0.5);

	}

}
track_WMD_achievement()
{

	//self.zombie_nuked = 0;
	while(IsDefined(self))
	{
		self waittill("nuke_triggered");
		wait(2);
		if(IsDefined(self.zombie_nuked) && self.zombie_nuked.size == 1)
		{
			//self play_achievement_dialog();
			self giveachievement_wrapper_new( "DLC2_ZOMBIE_NUKE_KILLS" ); 
			break;
		}

	}

}
tracks_highroller_achievement()
{

	while(IsDefined(self))
	{

		if(self.score_total >= level.zombie_vars["Achievement_HighRoller"])
		{
			//self play_achievement_dialog();
			self giveachievement_wrapper_new( "DLC2_ZOMBIE_POINTS" ); 
			break;

		}
		wait(0.5);

	}


}
play_achievement_dialog()
{
	if(randomintrange(0,100) < 50)
	{
		//player = getplayers();	
		index = maps\_zombiemode_weapons::get_player_index(self);
		
		player_index = "plr_" + index + "_";
		if(!IsDefined (self.vox_achievment))
		{
			num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_achievment");
			self.vox_achievment = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_achievment[self.vox_achievment.size] = "vox_achievment_" + i;	
			}
			self.vox_achievment_available = self.vox_achievment;		
		}	
		sound_to_play = random(self.vox_achievment_available);
		
		self.vox_achievment_available = array_remove(self.vox_achievment_available,sound_to_play);
		
		if (self.vox_achievment_available.size < 1 )
		{
			self.vox_achievment_available = self.vox_achievment;
		}
				
		self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	}

}

giveachievement_wrapper_new( achievement, all_players )
{
	if( IsDefined( all_players ) && all_players )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			players[i] GiveAchievementNew( achievement );
		}
	}
	else
	{
		if( !IsPlayer( self ) )
		{
			return;
		}
		self GiveAchievementNew( achievement );
	}
}

GiveAchievementNew(achievement)
{
	self endon("disconnect");

	notifyData = spawnStruct();
	notifyData.titleText = &"REMASTERED_ZOMBIE_ACHIEVEMENT";
	notifyData.notifyText = self getAchievementString( achievement );
	notifyData.iconName = achievement;
	notifyData.sound = "mp_challenge_complete";
	notifyData.duration = 3.75;
	notifyData.notifyText2 = " ";
	notifyData.textIsString = true;

	achievement_status = self GetStat( int(tableLookup( "mp/dlc2_achievements.csv", 1, achievement, 0 ) ) );
	//iprintln("Achievement Status: ",achievement_status);

	if( achievement_status != 1)
	{
		self play_achievement_dialog(); // all are solo achievements, so vox doesnt matter on coop anyway

		self setStat( int(tableLookup( "mp/dlc2_achievements.csv", 1, achievement, 0 )), 1 );
		thread maps\_hud_achievement::notifyMessage( notifyData );

		//achievement_status = self GetStat( int(tableLookup( "mp/dlc2_achievements.csv", 1, achievement, 0 ) ) );
		//iprintln("Achievement Status Updated: ",achievement_status);

	}
}

getAchievementNum( achievement )
{
	return int(tableLookup( "mp/dlc2_achievements.csv", 1, achievement, 0 ) );
}

getAchievementString( achievement )
{
	return tableLookupIString( "mp/dlc2_achievements.csv", 1, achievement, 1 );
}