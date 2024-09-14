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

	case "achievement_lawn":
		array_thread( players, ::achievement_give_on_counter, "DLC_ZOMBIE_LAWN", "Achievement_distant_kills", 30 ); 
		break; 

	case "achievement_flamethrower":
		array_thread( players, ::achievement_flamethrower);
		break; 

	case "achievement_barrels":
		array_thread( players, ::achievement_give_on_counter, "DLC_ZOMBIE_BARRELS", "Achievement_barrel_kills", 5); 
		break; 

	case "achievement_mortar":
		array_thread( players, ::achievement_give_on_notify, "DLC_ZOMBIE_MORTAR" );
		break; 

	case "achievement_magicbox":
		array_thread( players, ::achievement_give_on_counter, "DLC_ZOMBIE_MAGICBOX", "Achievement_box_hits", 100); 
		break; 

	case "achievement_radio": 
		array_thread( players, ::achievement_give_on_counter, "DLC_ZOMBIE_RADIO", "Achievement_radio_skips", 10); 
		break; 

	case "achievement_barriers": // For everyone
		level thread achievement_barriers(); 
		break; 

	case "achievement_starman": // For everyone
		level thread achievement_give_on_notify( "DLC_ZOMBIE_STARMAN" ); 
		break; 

	case "achievement_upstairs": // For everyone
		level thread achievement_give_on_notify( "DLC_ZOMBIE_UPSTAIRS" ); 
		break; 

	case "achievement_laststand": // For everyone
		level thread achievement_give_on_notify( "DLC_ZOMBIE_LASTSTAND" ); 
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

achievement_flamethrower()
{
	self endon( "disconnect" );
	
	while( 1 )
	{
		current_round = level.round_number;

		self.using_only_flamer = undefined;
		
		while( 1 )
		{

			self waittill_any( "weapon_fired", "grenade_fire", "check_for_flamer_ach" );

			if( current_round != level.round_number ) // if the round has progressed
			{
				//iprintlnbold("Round has progressed");
				break;
			}

			if ( (self isFiring() && self GetCurrentWeapon() == "m2_flamethrower_zombie") && !isDefined(self.using_only_flamer) ) // if we fire flamer AND we haven't set out variable yet
			{
				//iprintln("We are using flamethrower and have not used another weapon");
				self.using_only_flamer = true;
			}
			else if ( (self isFiring() && self GetCurrentWeapon() != "m2_flamethrower_zombie") || self isThrowingGrenade() ) // if we fire any NON flamer, or use grenade. If we have set to true or false, this is the only case we can get.
			{
				//iprintln("Used another weapon or grenade");
				self.using_only_flamer = false;
			}

			wait(0.1);
		}

		if(isDefined(self.using_only_flamer) && self.using_only_flamer == true && self hasweapon("m2_flamethrower_zombie") )
		{
			giveachievement_wrapper_new( "DLC_ZOMBIE_FLAMETHROWER" );
			self.using_only_flamer = undefined;
			break;
		}
/*		else
		{
			iprintlnbold("Failed, retrying this round");
		}*/
		
		wait(0.05);

	}

}

achievement_barriers()
{	
	level.zombies_not_entered = true;

	while( 1 )
	{
		level waittill( "between_round_over" );

		if( level.round_number == 5 && isdefined(level.zombies_not_entered) && level.zombies_not_entered == true ) // we flip this to undefined if a zombie breaks in
		{

			giveachievement_wrapper_new( "DLC_ZOMBIE_BARRIERS", true );
			break;
		}
		else if(level.round_number == 6 )
		{
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

	achievement_status = self GetStat( int(tableLookup( "mp/dlc_achievements.csv", 1, achievement, 0 ) ) );
	//iprintln("Achievement Status: ",achievement_status);

	if( achievement_status != 1)
	{
		self setStat( int(tableLookup( "mp/dlc_achievements.csv", 1, achievement, 0 )), 1 );
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
	return int(tableLookup( "mp/dlc_achievements.csv", 1, achievement, 0 ) );
}

getAchievementString( achievement )
{
	return tableLookupIString( "mp/dlc_achievements.csv", 1, achievement, 1 );
}
