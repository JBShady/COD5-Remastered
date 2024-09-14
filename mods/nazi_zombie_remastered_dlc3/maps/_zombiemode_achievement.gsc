#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility; 

init( achievement, var1, var2, var3, var4 )
{

	if( !isdefined( achievement ) )
	{
		return;
	}

	players = get_players();

	switch( achievement )
	{
	case "achievement_shiny":
		array_thread( players, ::achievement_give_on_notify, "DLC3_ZOMBIE_PAP_ONCE" ); // all set
		break; 

	case "achievement_monkey_see":
		array_thread( players, ::achievement_give_on_notify, "DLC3_ZOMBIE_USE_MONKEY" ); // all set
		break; 

	case "achievement_frequent_flyer":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_FIVE_TELEPORTS", "Achievement_frequent_flier", 8 ); // all set
		break; 

	case "achievement_this_is_a_knife":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_BOWIE_KILLS", "Achievement_this_is_a_knife", 40 ); // all set
		break; 

	case "achievement_martian_weapon":
		array_thread( players, ::Achievement_martian_weapons); // all set
		break; 

	case "achievement_double_whammy":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_TWO_UPGRADED", "Achievement_five_upgrades", 5); // all set
		break; 

	case "achievement_perkaholic":
		array_thread( players, ::Achievement_Perkholic_Anon);  // all set
		break; 

	case "achievement_secret_weapon":
		level thread achievement_give_on_notify( "DLC3_ZOMBIE_ANTI_GRAVITY" ); // need to test in coop
		break; 

	case "achievement_no_more_door":
		level thread achievement_give_on_counter( "DLC3_ZOMBIE_ALL_DOORS", "Achievement_Doors_in Giant", 9 ); // need to test in coop
		break; 

	case "achievement_back_to_future":
		level thread achievement_give_on_notify( "DLC3_ZOMBIE_FAST_LINK" ); // need to test in coop
		break; 

	default:
		iprintln( achievement + " not found! " );
		break; 
	}

}

achievement_give_on_notify( notify_name, debug_text )
{
	if ( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	self waittill( notify_name );

	if ( IsPlayer( self ) )
	{
		self giveachievement_wrapper_new( notify_name ); 
	}
	else
	{
		giveachievement_wrapper_new( notify_name, true ); 
	}
}

achievement_give_on_counter( notify_name, counter_name, counter_num, debug_text )
{

	if ( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	counter = 0;
	set_zombie_var( counter_name, counter_num );

	while( 1 )
	{
		self waittill( notify_name );
		counter += 1;
		if( counter >= level.zombie_vars[counter_name] )
		{

			if( isPlayer( self ) )
			{
				self giveachievement_wrapper_new( notify_name );
				return;
			}
			else
			{
				giveachievement_wrapper_new( notify_name, true );
				return;
			}
		}
	}
}
Achievement_martian_weapons()
{

	self endon( "disconnect" );

	while( 1 )
	{
		self waittill_any( "weapon_change", "you_got_monks" ); // Added another check for Monkey Bombs, they don't cause a weapon change :>
		martian_weapon_owned  = 0;

		if( self.sessionstate == "spectator" )
		{
			wait( 0.05 );
			continue;
		}

		if( self maps\_zombiemode_weapons::has_weapon_or_upgrade( "tesla_gun" ) )
		{
			martian_weapon_owned += 1;
		}

		if( self maps\_zombiemode_weapons::has_weapon_or_upgrade( "ray_gun" ) )
		{
			martian_weapon_owned += 1;
		}
		
		if( self HasWeapon( "zombie_cymbal_monkey" ) )
		{
			martian_weapon_owned += 1;
		}
		
		if( martian_weapon_owned >= 3 )
		{

			self giveachievement_wrapper_new( "DLC3_ZOMBIE_RAY_TESLA" ); 
			return;
		}

		wait(0.5);
	}
}

Achievement_Perkholic_Anon()
{
	self endon( "disconnect" );
	self endon( "perk_used" );
	set_zombie_var( "Achievement_Perkholic_Anon", 20 );
	
	while( 1 )
	{
		level waittill( "between_round_over" );

		if( level.round_number == level.zombie_vars["Achievement_Perkholic_Anon"])
		{

			self giveachievement_wrapper_new( "DLC3_ZOMBIE_NO_PERKS" );
			break;
		}

		wait(0.5);
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

	achievement_status = self GetStat( int(tableLookup( "mp/dlc3_achievements.csv", 1, achievement, 0 ) ) );
	//iprintln("Achievement Status: ",achievement_status);

	if( achievement_status != 1)
	{
		self setStat( int(tableLookup( "mp/dlc3_achievements.csv", 1, achievement, 0 )), 1 );
		thread maps\_hud_achievement::notifyMessage( notifyData );
		if(!isDefined(self.achievement_count))
		{
			self.achievement_count = 1;
		}
		else
		{
			self.achievement_count++;			
		}
		//achievement_status = self GetStat( int(tableLookup( "mp/dlc3_achievements.csv", 1, achievement, 0 ) ) );
		//iprintln("Achievement Status Updated: ",achievement_status);

	}
}

getAchievementNum( achievement )
{
	return int(tableLookup( "mp/dlc3_achievements.csv", 1, achievement, 0 ) );
}

getAchievementString( achievement )
{
	return tableLookupIString( "mp/dlc3_achievements.csv", 1, achievement, 1 );
}
