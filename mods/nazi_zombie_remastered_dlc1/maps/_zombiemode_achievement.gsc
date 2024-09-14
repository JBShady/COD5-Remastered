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
		
	case "achievement_court_headshots":
		array_thread( players, ::achievement_give_on_counter, "DLC1_ZOMBIE_COURT_HEADSHOTS", "Achievement_special_headshots", 20 );
		break;

	case "achievement_downed_kills":
		array_thread( players, ::achievement_give_on_counter, "DLC1_ZOMBIE_DOWNED_KILLS", "Achievement_downed_kills", 5 );
		break; 

	case "achievement_mg":
		array_thread( players, ::achievement_give_on_notify, "DLC1_ZOMBIE_MG" );
		break;

	case "achievement_betty":
		array_thread( players, ::achievement_give_on_notify, "DLC1_ZOMBIE_BETTY" );
		break;

	case "achievement_smoke":
		array_thread( players, ::achievement_give_on_notify, "DLC1_ZOMBIE_SMOKE" );
		break; 

	case "achievement_teddy":
		array_thread( players, ::achievement_give_on_notify, "DLC1_ZOMBIE_TEDDY" );
		break;

	case "achievement_doors": // For everyone
		level thread achievement_give_on_counter( "DLC1_ZOMBIE_DOORS", "Achievement_Doors_in_verruckt", 9 );
		break; 

	case "achievement_zap": // For evereyone
		level thread achievement_give_on_notify( "DLC1_ZOMBIE_ZAP" );
		break; // may want some additional testing with traps

	case "achievement_power": // For everyone
		level thread achievement_give_on_notify( "DLC1_ZOMBIE_POWER" );
		break; 

	case "achievement_song": // For everyone
		level thread achievement_give_on_notify( "DLC1_ZOMBIE_SONG" );
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

	achievement_status = self GetStat( int(tableLookup( "mp/dlc1_achievements.csv", 1, achievement, 0 ) ) );
	//iprintln("Achievement Status: ",achievement_status);

	if( achievement_status != 1)
	{
		self setStat( int(tableLookup( "mp/dlc1_achievements.csv", 1, achievement, 0 )), 1 );
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
	return int(tableLookup( "mp/dlc1_achievements.csv", 1, achievement, 0 ) );
}

getAchievementString( achievement )
{
	return tableLookupIString( "mp/dlc1_achievements.csv", 1, achievement, 1 );
}
