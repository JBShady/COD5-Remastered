#include maps\_utility;
#include maps\_hud_util;
#include animscripts\utility;
#include common_scripts\utility;

//LANG_ENGLISH        "&&1 Challenges Unlocked - &&2 XP Rewarded"


main()
{
	precachestring( &"SCRIPT_AM_X" );
	precachestring( &"SCRIPT_PLUS" );
	precachestring( &"SCRIPT_MINUS" );	
	precachestring( &"SCRIPT_AM_DIFFICULTY_BONUS" );
	precachestring( &"SCRIPT_AM_DIFFICULTY_BONUS_X" );
	
	precachestring( &"SCRIPT_AM_SUICIDE_ONE_LAST_GO" );
	precachestring( &"SCRIPT_AM_SUICIDE_COMMITED" );
	precachestring( &"SCRIPT_AM_SUICIDE_KICKED" );
	
	precachestring( &"SCRIPT_AM_LOW_SCORE_WARNING" );
	
	precachestring( &"SCRIPT_AM_BONUS_HARDEST_2_KILL" );
	precachestring( &"SCRIPT_AM_BONUS_MOST_REVIVES" );
	precachestring( &"SCRIPT_AM_BONUS_MOST_HEADSHOTS" );
		
	precachestring( &"SCRIPT_AM_PLAYERNAME" );
	
	precachestring( &"SCRIPT_AM_MISSION_SCORE" );	
 	precachestring( &"SCRIPT_AM_ROUND_BONUS" );	
 	  	
	level.color_cool_green = ( 0.8, 2.0, 0.8 );
	level.color_cool_green_glow = ( 0.3, 0.6, 0.3 );
	
	level.arcadeMode_score_firstplace = -1;
	
	// gotta kill these number of guys to get the multiplier	
	level.arcadeMode_kill_streak_multiplier_count = 3;
			
	// the colors used for the kill streak guys
	arcadeMode_init_kill_streak_colors();	
	
	level.arcadeMode_success = false;
	
	waittillframeend; // so level.script is set	
			
	arcademode_dvar_init();
	
	level.global_kill_func = ::arcademode_death;
	level.onPlayerKilled = ::arcademode_playerkilled;
		
	flag_init( "arcademode_complete" );	
	flag_init( "arcademode_ending_complete" );
	flag_init( "arcademode_progress2nextbonus" );

	level thread onPlayerConnect();
	
	setsaveddvar( "missionsuccessbar", "0" );
	setsaveddvar( "bonusbackground", "0" );
	
	//TEST CODE
	//setdvar("friendlyfire_enabled", 0);	
}


pSetDvar(dvarName, value)
{
	setdvar( dvarName + self getEntityNumber(), value );
}


pAddToDvar(dvarName, valueToAdd)
{
	currentValue = getDvarInt( dvarName + self getEntityNumber() );
	setdvar( dvarName + self getEntityNumber(), currentValue + valueToAdd );
	return currentValue + valueToAdd;
}

pGetIntDvar(dvarName)
{
	return getDvarInt( dvarName + self getEntityNumber() );
}

setDvarIfUndefined(dvarName, defaultValue)
{
	if( !isDefined( getDvar( dvarName ) ) || "" == getDvar( dvarName ) )
	{
		setdvar( dvarName, defaultValue );
	}
}

// self is the player
player_init()
{			
	self.arcadeMode_ks_current_count = level.arcademode_ks[ self getScoreMultiplier() + 1 ];
	self.arcademode_ks_ends = 0;
	
	self setClientDvars( "ui_hud_hardcore", 0 );
	
	self pSetDvar("arcademode_suicidedeaths", 0);
	self pSetDvar("arcademode_checkpointsubtract", 0);
	
	self thread killStreakMonitor();
	
	self.arcademode_updatePlusTotal = 0;
	self.arcademode_updateMinusTotal = 0;

	self.arcademode_bonus["lastKillTime"] = 0;
	self.arcademode_bonus["uberKillingMachineStreak"] = 0;
		
	self.arcademode_warningShown = false;
	
	self pSetDvar( "player_suicides_total", 0 );
	self pSetDvar( "player_committed_suicide", 0 );
	self pSetDvar( "current_restorable_points", 0 );
	self pSetDvar( "previous_restorable_points", 0 );
}


onPlayerConnect()
{
	self endon( "arcademode_complete" );
	
	for( ;; )
	{
		level waittill( "connecting", player ); 
				
		player thread onPlayerSpawned();
	}
}

	
onPlayerSpawned()
{
	self endon("disconnect");
	self endon( "arcademode_complete" );

	for(;;)
	{
		self waittill("spawned_player");
		
		if( !isdefined( self.hud_scoreplusupdate ) )
		{
			self.hud_scoreplusupdate = newScoreHudElem(self);
			self.hud_scoreplusupdate.hidewheninmenu = true;
			self.hud_scoreplusupdate.horzAlign = "center";
			self.hud_scoreplusupdate.vertAlign = "middle";
			self.hud_scoreplusupdate.alignX = "center";
			self.hud_scoreplusupdate.alignY = "middle";
	 		self.hud_scoreplusupdate.x = 0;
			self.hud_scoreplusupdate.y = -60;
			self.hud_scoreplusupdate.font = "big";
			self.hud_scoreplusupdate.fontscale = 2.0;
			self.hud_scoreplusupdate.archived = false;
			self.hud_scoreplusupdate.color = ( 1, 1, 0.5 );
			self.hud_scoreplusupdate fontPulseInit();
			self.hud_scoreplusupdate.alpha = 0;
		}
		
		if( !isdefined( self.hud_scoreminusupdate ) )
		{
			self.hud_scoreminusupdate = newScoreHudElem(self);
			self.hud_scoreminusupdate.hidewheninmenu = true;
			self.hud_scoreminusupdate.horzAlign = "center";
			self.hud_scoreminusupdate.vertAlign = "middle";
			self.hud_scoreminusupdate.alignX = "center";
			self.hud_scoreminusupdate.alignY = "middle";
	 		self.hud_scoreminusupdate.x = 0;
			self.hud_scoreminusupdate.y = -35;
			self.hud_scoreminusupdate.font = "big";
			self.hud_scoreminusupdate.fontscale = 2.0;
			self.hud_scoreminusupdate.archived = false;
			self.hud_scoreminusupdate.color = (1, 0.3, 0.3);	
			self.hud_scoreminusupdate fontPulseInit();
			self.hud_scoreminusupdate.alpha = 0;
		}
		
		if( !isdefined( self.hud_scoremulti ) )
		{
			self.hud_scoremulti = newScoreHudElem(self);
			self.hud_scoremulti.hidewheninmenu = true;
			self.hud_scoremulti.horzAlign = "center";
			self.hud_scoremulti.vertAlign = "middle";
			self.hud_scoremulti.alignX = "center";
			self.hud_scoremulti.alignY = "middle";
	 		self.hud_scoremulti.x = 0;
			self.hud_scoremulti.y = -90;
			self.hud_scoremulti.font = "big";
			self.hud_scoremulti.fontscale = 2.5;
			self.hud_scoremulti.archived = false;
			self.hud_scoremulti fontPulseInit();
			self.hud_scoremulti.alpha = 0;
		}
		
			
					
		//self.teamKillPunish = false;
		//if ( level.minimumAllowedSuicides >= 0 && self.pers["player_suicides_total"] > level.minimumAllowedSuicides )
		//	self thread reduceTeamKillsOverTime();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

arcadeMode_checkpoint_save()
{
	if( !arcadeMode() )
		return;
		
	players = get_players();
	for( i = 0; i < players.size; i++)
	{
		players[i] pSetDvar( "current_restorable_points", 0);
		players[i] pSetDvar( "previous_restorable_points", 0);
	}
}

arcadeMode_checkpoint_restore()
{
	if( !arcadeMode() )
		return;

	setsaveddvar( "missionsuccessbar", "0" );
	setsaveddvar( "bonusbackground", "0" );
		
	players = get_players();
	for( i = 0; i < players.size; i++)
	{
		players[i] setClientDvars( "ui_hud_hardcore", 0 );
		
		players[i] thread arcademode_kill_streak_reset( true );
		
		//hide to score and multi hud
		players[i] notify( "update_plus_score" );
		players[i] notify( "update_multi_score" );
		players[i].arcademode_updatePlusTotal = 0;
		players[i].hud_scoreplusupdate.alpha = 0;		
		players[i].hud_scoremulti.alpha = 0;
		players[i].arcademode_warningShown = false;
		
		current_restorable_points = players[i] pGetIntDvar( "current_restorable_points"); //points to subtract from the current death
		previous_restorable_points = players[i] pGetIntDvar( "previous_restorable_points"); //points you subtracted from a previous death
		
		restorable_points = previous_restorable_points + current_restorable_points;
						
		players[i].score += restorable_points;
		
		//player_respawn_points = players[i].score + restorable_points;
		//if( player_respawn_points <= 0 ) //can't give a player less than 0
		//{
		//	restorable_points -= player_respawn_points;
		//	current_restorable_points -= player_respawn_points;
		//	players[i].score = 0;
		//}
		//else 
		//{
		//	players[i].score = player_respawn_points;
		//}		
		
		if( players[i].score < 0 )
		{
			if( true == minimumScoreProcessing( players[i] ) )
			{
				continue; //return; //player kicked -- return == bad - no players after this processed.
			}
			players[i] thread updateMinusScoreHUD( current_restorable_points, 5.0 );
		}
		
		players[i] pSetDvar( "current_restorable_points", 0);
		players[i] pSetDvar( "previous_restorable_points", restorable_points);
				
		//Show suicide message
		player_committed_suicide = players[i] pGetIntDvar( "player_committed_suicide" );
		if( player_committed_suicide == 1 )
		{		
			player_suicides_total = players[i] pGetIntDvar( "player_suicides_total" );
			minimumAllowedSuicides = getdvarint( "arcademode_minimumAllowedSuicides" );
			
			if((player_suicides_total + 1 == minimumAllowedSuicides) && (players[i] getentitynumber() != 0))
			{
				players[i] thread show_warning_message( 7.0, &"SCRIPT_AM_SUICIDE_ONE_LAST_GO", 0 );
			}
			else
			{
				players[i] thread show_warning_message( 7.0, &"SCRIPT_AM_SUICIDE_COMMITED", 0 );
			}
			
			players[i] pSetDvar( "player_committed_suicide", 0 );

		}
	
	}
	
	level thread updatePlayers();
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



arcademode_playerkilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if( true == IsSplitScreen() )
	{
		//not point in banning in splitscreen and u can't ban the host cause u can't kick them
		return;
	}
	
	if ( isPlayer( eAttacker ) && sMeansOfDeath == "MOD_SUICIDE" )
	{
		if( self getentitynumber() == eAttacker getentitynumber() )
		{	
			if( IsDefined(self.lastgrenadetime) )
			{
				timeSinceThrown = GetTime() - self.lastgrenadetime;
				if( timeSinceThrown < 4100 || timeSinceThrown > 4300 )	// not my grenade
				{
					return; //magic number copied from fraggrenade asset.
				}
			}

			self pSetDvar( "player_committed_suicide", 1 );
			
			penalty_points = getDvarInt( "arcademode_score_suicide" );
			current_penalty_points = self pGetIntDvar( "current_restorable_points" );
			
			current_penalty_points += penalty_points;
			self pSetDvar( "current_restorable_points", current_penalty_points );

			self pAddToDvar( "player_suicides_total", 1 );
			player_suicides_total = self pGetIntDvar( "player_suicides_total" );
			
			minimumAllowedSuicides = getdvarint( "arcademode_minimumAllowedSuicides" );
			if( player_suicides_total >= minimumAllowedSuicides && self getentitynumber() != 0 )
			{	
				ban( self getentitynumber() );
				return;
			}
		}
	}
}


show_warning_message( time, message, y, player )
{	
	self endon( "disconnect" );
	self endon( "arcademode_complete" );
	
	warning_hud = newclientHudElem( self );

	warning_hud.hidewheninmenu = true;
	warning_hud.horzAlign = "center";
	warning_hud.vertAlign = "middle";
	warning_hud.alignX = "center";
	warning_hud.alignY = "middle";
	warning_hud.x = 0;
	warning_hud.y = y;
	warning_hud.foreground = true;
	warning_hud.font = "default";
	warning_hud.fontScale = 2.0;
	warning_hud.color = ( 1.0, 1.0, 1.0 );	
	
	warning_hud.alpha = 1;
	if( isDefined ( player ) )
	{
		warning_hud setText( message, player );
	}
	else
	{
		warning_hud setText( message );
	}
	
	warning_hud fadeOverTime( time );
	
	warning_hud.alpha = 0;
	
	wait( time + 0.2 );
	
	warning_hud destroy();
}

reduceTeamKillsOverTime()
{
	timePerOneTeamkillReduction = 20.0;
	reductionPerSecond = 1.0 / timePerOneTeamkillReduction;
	
	while(1)
	{
		if ( isAlive( self ) )
		{
			player_suicides_total = self pGetIntDvar( "player_suicides_total" );
			player_suicides_total -= reductionPerSecond;
			self pSetDvar( "player_suicides_total", player_suicides_total );
			
			if ( self pGetIntDvar( "player_suicides_total" ) < level.minimumAllowedSuicides )
			{	
				self pSetDvar( "player_suicides_total", level.minimumAllowedSuicides );
				break;
			}
		}
		wait 1;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
minimumScoreProcessing( player )
{
	if( 0 != player getentitynumber() && false == IsSplitScreen() ) 	// changed || for && to fix issue where host was considered for banning.
	{
		if( level.arcademode_minimumAllowedWarning < player.score )
		{
			player.arcademode_warningShown = false;
		}
		else if( level.arcademode_minimumAllowedWarning >= player.score 
			&& level.arcademode_minimumAllowedPoints < player.score
			&& player.arcademode_warningShown == false )
		{		
			player thread show_warning_message( 7.0, &"SCRIPT_AM_LOW_SCORE_WARNING", 30 );
			player.arcademode_warningShown = true;
		}
		else if( player.score <= level.arcademode_minimumAllowedPoints )
		{		
			ban( player getentitynumber() );
			return true;
		}
	}
	return false;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

arcademode_dvar_init()
{
	//use getDvarInt(dvarName);
	
	//player
	setDvarIfUndefined ( "arcademode_score_suicide",		-500 );
	setDvarIfUndefined ( "arcademode_score_laststand",		-50 );
	setDvarIfUndefined ( "arcademode_score_revive",			40 );
	
	setDvarIfUndefined ("arcademode_minimumAllowedSuicides",5 );
		
	setDvarIfUndefined ("arcademode_minimumAllowedPoints", 	-1500 );
	setDvarIfUndefined ("arcademode_minimumAllowedWarning", -500 );
	
	level.arcademode_minimumAllowedPoints = getDvarInt( "arcademode_minimumAllowedPoints" );
	level.arcademode_minimumAllowedWarning = getDvarInt( "arcademode_minimumAllowedWarning" );	
	
	//Friendies AI
	setDvarIfUndefined ( "arcademode_friendies_damage",		-10 );	
	
	//enemy
	setDvarIfUndefined ( "arcademode_score_kill",			50 );
	setDvarIfUndefined ( "arcademode_score_melee",			40 );
	setDvarIfUndefined ( "arcademode_score_headshot",		50 );
	setDvarIfUndefined ( "arcademode_score_upperbody",		10 );
	setDvarIfUndefined ( "arcademode_score_lowerbody",		0 );
	setDvarIfUndefined ( "arcademode_score_assist",			20 );
	setDvarIfUndefined ( "arcademode_score_explosion",		0 );
		
	level.arcadeMode_killBase = getDvarInt( "arcademode_score_kill" );
	
	//objects
	setDvarIfUndefined ( "arcademode_score_explodableitem",	10 );
	setDvarIfUndefined ( "arcademode_score_enemyexitingcar",100 );
	setDvarIfUndefined ( "arcademode_score_banzai",			150 );
	setDvarIfUndefined ( "arcademode_score_vehicle",		30 );
	setDvarIfUndefined ( "arcademode_score_dog",			50 );
	setDvarIfUndefined ( "arcademode_score_tankassist",		50 );	
	setDvarIfUndefined ( "arcademode_score_tank",			250 );
	setDvarIfUndefined ( "arcademode_score_tank_friendly",	-50 );
	setDvarIfUndefined ( "arcademode_score_tankmantle",		500 );
	setDvarIfUndefined ( "arcademode_score_watertower",		150 );
	setDvarIfUndefined ( "arcademode_score_treehugger",		100 );
	
	//actions
	setDvarIfUndefined ( "arcademode_score_bombplant",		200 );
	
	// SRS 8/12/2008: generic, for scripters to assign level-specific points
	setDvarIfUndefined ( "arcademode_score_generic100", 	100 );
	setDvarIfUndefined ( "arcademode_score_generic250", 	250 );
	setDvarIfUndefined ( "arcademode_score_generic500", 	500 );
	setDvarIfUndefined ( "arcademode_score_generic750", 	750 );
	setDvarIfUndefined ( "arcademode_score_generic1000", 	1000 );

	//collectables
	setDvarIfUndefined ( "arcademode_score_berserker",		20 );
	setDvarIfUndefined ( "arcademode_score_hardcore",		10 );
	setDvarIfUndefined ( "arcademode_score_body_armor",		20 );
	setDvarIfUndefined ( "arcademode_score_thunder",		10 );
	setDvarIfUndefined ( "arcademode_score_zombie",			10 );
	setDvarIfUndefined ( "arcademode_score_vampire",		10 );
	setDvarIfUndefined ( "arcademode_score_dirtyharry",		10 );
	setDvarIfUndefined ( "arcademode_score_hard_headed",	20 );
	setDvarIfUndefined ( "arcademode_score_dead_hands",		20 );
	setDvarIfUndefined ( "arcademode_score_sticksstones",	20 );
	setDvarIfUndefined ( "arcademode_score_flak_jacket",	10 );
	setDvarIfUndefined ( "arcademode_score_morphine",		10 );	
	
	//Round Bonus	
	setDvarIfUndefined ( "arcademode_bonus_hardest2kill",	1000 );
	setDvarIfUndefined ( "arcademode_bonus_mostrevives",	500 );
	setDvarIfUndefined ( "arcademode_bonus_mostheadshots",	500 );	
		
	// KILL STREAKS	
	setDvarIfUndefined ( "arcademode_ks_2",	3 );
	setDvarIfUndefined ( "arcademode_ks_3",	3 );
	setDvarIfUndefined ( "arcademode_ks_4",	4 );
	setDvarIfUndefined ( "arcademode_ks_5",	4 );
	setDvarIfUndefined ( "arcademode_ks_6",	4 );
	setDvarIfUndefined ( "arcademode_ks_7",	5 );
	setDvarIfUndefined ( "arcademode_ks_8",	5 );
	setDvarIfUndefined ( "arcademode_ks_9",	3 );
	setDvarIfUndefined ( "arcademode_ks_10",3 );
	
	setDvarIfUndefined ( "arcademode_ks_time_2", 7 );
	setDvarIfUndefined ( "arcademode_ks_time_3", 5 );
	setDvarIfUndefined ( "arcademode_ks_time_4", 5 );
	setDvarIfUndefined ( "arcademode_ks_time_5", 5 );
	setDvarIfUndefined ( "arcademode_ks_time_6", 4 );
	setDvarIfUndefined ( "arcademode_ks_time_7", 4 );
	setDvarIfUndefined ( "arcademode_ks_time_8", 3 );	
	setDvarIfUndefined ( "arcademode_ks_time_9", 10  );
	setDvarIfUndefined ( "arcademode_ks_time_10", 10  );	
	
	setDvarIfUndefined ( "arcademode_ks_maxtime", 15 );	
	
	kill_Streaks = [];
	kill_Streaks[ 2 ] = getDvarInt( "arcademode_ks_2" );
	kill_Streaks[ 3 ] = getDvarInt( "arcademode_ks_3" );
	kill_Streaks[ 4 ] = getDvarInt( "arcademode_ks_4" );
	kill_Streaks[ 5 ] = getDvarInt( "arcademode_ks_5" );
	kill_Streaks[ 6 ] = getDvarInt( "arcademode_ks_6" );
	kill_Streaks[ 7 ] = getDvarInt( "arcademode_ks_7" );
	kill_Streaks[ 8 ] = getDvarInt( "arcademode_ks_8" );
	kill_Streaks[ 9 ] = getDvarInt( "arcademode_ks_9" );
	kill_Streaks[ 10 ] = getDvarInt( "arcademode_ks_10" );
	level.arcademode_ks = kill_Streaks;
	
	
	kill_StreaksTime = []; //in seconds
	kill_StreaksTime[ 2 ] = getDvarInt( "arcademode_ks_time_2" );
	kill_StreaksTime[ 3 ] = getDvarInt( "arcademode_ks_time_3" );
	kill_StreaksTime[ 4 ] = getDvarInt( "arcademode_ks_time_4" );
	kill_StreaksTime[ 5 ] = getDvarInt( "arcademode_ks_time_5" );
	kill_StreaksTime[ 6 ] = getDvarInt( "arcademode_ks_time_6" );
	kill_StreaksTime[ 7 ] = getDvarInt( "arcademode_ks_time_7" );
	kill_StreaksTime[ 8 ] = getDvarInt( "arcademode_ks_time_8" );
	kill_StreaksTime[ 9 ] = getDvarInt( "arcademode_ks_time_9" );
	kill_StreaksTime[ 10 ] = getDvarInt( "arcademode_ks_time_10" );	
	level.arcademode_ks_time = kill_StreaksTime;
	
	level.arcademode_ks_max_streaks = level.arcademode_ks.size + 1;
	level.arcademode_ks_max_time = getDvarInt( "arcademode_ks_maxtime" ) * 1000;
	
	arcadeMode_init_kill_streak_colors();	
	
	damage_adder = [];
	damage_adder[ "melee" ] = 0;
	damage_adder[ "pistol" ] = 20;
	damage_adder[ "rifle" ] = 0;
	damage_adder[ "explosive" ] = 0;
	damage_adder[ "fire" ] = 0;
	damage_adder[ "none" ] = 0;
	level.arcademode_weaponAdded = damage_adder;	
	
	death_types = [];
	death_types[ "MOD_MELEE" ] = "melee";
	death_types[ "MOD_BAYONET" ] = "melee";
	death_types[ "MOD_PISTOL_BULLET" ] = "pistol";
	death_types[ "MOD_RIFLE_BULLET" ] = "rifle";
	death_types[ "MOD_PROJECTILE" ] = "explosive";
	death_types[ "MOD_PROJECTILE_SPLASH" ] = "explosive";
	death_types[ "MOD_EXPLOSIVE" ] = "explosive";
	death_types[ "MOD_GRENADE" ] = "explosive";
	death_types[ "MOD_GRENADE_SPLASH" ] = "explosive";
	death_types[ "MOD_IMPACT" ] = "explosive";
	death_types[ "MOD_BURNED" ] = "fire";		
	level.arcademode_deathtypes = death_types;
	
	skill_multiplier = [];
	skill_multiplier[ 0 ] = 1;
	skill_multiplier[ 1 ] = 1.5;
	skill_multiplier[ 2 ] = 3;
	skill_multiplier[ 3 ] = 4;
	level.arcadeMode_skillMultiplier = skill_multiplier;	
}

player_add_points_cheats( dvarName, mod, hit_location )
{
	bonus = 0;
	
	if( mod == "MOD_MELEE" || mod == "MOD_BAYONET" )
	{
		if ( maps\_collectibles::has_collectible( "collectible_berserker" ) && self.collectibles_berserker_mode_on == true )
		{
			bonus += getDvarInt( "arcademode_score_berserker" );	//melee kills
		}	
	}
	
	if( hit_location == "head" || hit_location == "helmet" )
	{	
		if ( maps\_collectibles::has_collectible( "collectible_body_armor" ) )
		{
			bonus += getDvarInt( "arcademode_score_body_armor" );	//headshots
		}		
		if ( maps\_collectibles::has_collectible( "collectible_thunder" ) )
		{
			bonus += getDvarInt( "arcademode_score_thunder" );	//headshots
		}		
		if ( maps\_collectibles::has_collectible( "collectible_zombie" ) )
		{
			bonus += getDvarInt( "arcademode_score_zombie" );	//headshots
		}	
	}	
	
	if( mod == "MOD_PISTOL_BULLET" || mod == "MOD_RIFLE_BULLET" )
	{	
		if ( maps\_collectibles::has_collectible( "collectible_vampire" ) )
		{
			bonus += getDvarInt( "arcademode_score_vampire" );	//bullet kills
		}
		if ( maps\_collectibles::has_collectible( "collectible_dirtyharry" ) && self maps\_laststand::player_is_in_laststand() )
		{
			bonus += getDvarInt( "arcademode_score_dirtyharry" );	//bullet kills
		}		
		if ( maps\_collectibles::has_collectible( "collectible_hard_headed" ) )
		{
			bonus += getDvarInt( "arcademode_score_hard_headed" );	//bullet kills
		}
		if ( maps\_collectibles::has_collectible( "collectible_dead_hands" ) )
		{
			bonus += getDvarInt( "arcademode_score_dead_hands" );	//bullet kills
		}
	}
			
	if( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" || mod == "MOD_IMPACT" )
	{
		if ( maps\_collectibles::has_collectible( "collectible_sticksstones" ) )
		{
			bonus += getDvarInt( "arcademode_score_sticksstones" );	//grenade (impact) kills
		}
		if ( maps\_collectibles::has_collectible( "collectible_flak_jacket" ) )
		{
			bonus += getDvarInt( "arcademode_score_flak_jacket" );	//grenade kills
		}
	}

	if( dvarName == "arcademode_score_revive" )
	{
		if ( maps\_collectibles::has_collectible( "collectible_morphine" ) )
		{
			bonus += getDvarInt( "arcademode_score_morphine" ); //revives 
		}
	}
	 
	return bonus;
}

player_points_kill_bonus( points, enemy, mod, hit_location )
{
	if ( mod == "MOD_MELEE" || mod == "MOD_BAYONET")
	{	
		if( self getScoreMultiplier() >= 8 )
		{
			self thread arcademode_add_kill_streak();
		}
		
		points += getDvarInt( "arcademode_score_melee" );
		
		//check to see if the enemy was stabbed in the back
		vAngles = enemy.anglesOnDeath[1];
		pAngles = self.anglesOnKill[1];
		angleDiff = AngleClamp180( vAngles - pAngles );
		
		if ( 90 > angleDiff && 0 < angleDiff )
		{		
			points *= 2;
		}		
	}
	else
	{
		switch ( hit_location )
		{
		case "head":
		case "helmet":
			if( self getScoreMultiplier() == 8 )
			{
				self thread arcademode_add_kill_streak();
			}
			points += getDvarInt( "arcademode_score_headshot" );
			break;
	
		case "neck":	
		case "torso_upper":
			points += getDvarInt( "arcademode_score_upperbody" );
			break;
	
		case "torso_lower":
			points += getDvarInt( "arcademode_score_lowerbody" );
			break;
		}
	}
	
	return points;
}

arcademode_death( mod, hit_location, hit_origin, player, enemy, uberKillingMachineStreak )
{
	if ( flag( "arcademode_complete" ) )
		return;

	// CODER_MOD: GMJ (07/31/08): Protect against player not actually being a player.
    if ( !isDefined( player ) || !isPlayer( player ) ) 
    {
        println( "Warning: arcadeMode_add_points called on a non-player" );
        return;
    }
		
	if ( !isdefined( hit_location ) )
		hit_location = "none";
		
	death_type = level.arcadeMode_deathtypes[ mod ];
	if ( !isdefined( death_type ) )
	{
		death_type = "none";
	}		
	
	points = player player_points_kill_bonus( level.arcadeMode_killBase, enemy, mod, hit_location );

	if( player.score + points < 10000000 )
	{			
		points += level.arcademode_weaponAdded[ death_type ];
		
		points += player player_add_points_cheats( "", mod, hit_location );
		
		points = round_up_to_ten( points );
		
		points *= player getScoreMultiplier() * uberKillingMachineStreak;
		
		player.score += points;
				
		//TEST CODE
		//if( hit_location == "head" )
		//{
			//player maps\_challenges_coop::giveRankXP( "challenge", points );
			//arcademode_upload_highscore();
			//changeLevel( "" );  // back to title screen
			//nextmission();
			//return;
		//}	
		
		if( player getScoreMultiplier() < 8 )
		{
			player thread arcademode_add_kill_streak();
		}
			
		player thread updatePlusScoreHUD( points );
	}
	else
	{
		player.score = 10000000;
	}
		
	level thread updatePlayers();
}

arcademode_assignpoints_toplayer( dvar, player, restore_at_checkpoint )
{
	if ( flag( "arcademode_complete" ) )
		return;

    if ( !IsPlayer( player ) ) 
    {
        println( "Warning: arcadeMode_add_points called on a non-player" );
        return;
    }

	points = getDvarInt( dvar );
	if( !isDefined( points ) )
	{
		assertex( 0, "Unknown arcade mode dvar" );
	}
	
	if( 0 == points ) 
	{
		return;
	}
			
	if( 0 < points )
	{	
		if( player.score + points < 10000000 )
		{
			points *= player getScoreMultiplier();
			
			points = round_up_to_ten( points );
			
			points += player player_add_points_cheats( dvar, "", "" );
			
			player.score += points;
					
			player thread updatePlusScoreHUD( points );
			
			if( player getScoreMultiplier() < 8 )
			{
				player thread arcademode_add_kill_streak();
			}
		}
		else
		{
			player.score = 10000000;
		}		
	}
	else
	{		
		player thread arcademode_kill_streak_reset( false );
		
		points = round_up_to_ten( points );
		
		player.score += points;
		
		if( true == minimumScoreProcessing( player ) )
		{
			return; //player kicked
		}
					
		player thread updateMinusScoreHUD( points );
	}
	
	level thread updatePlayers();
	
	if( isDefined(restore_at_checkpoint) && true == restore_at_checkpoint ) 
	{
		restorable_points = points + self pGetIntDvar( "current_restorable_points" );
		self pSetDvar( "current_restorable_points", restorable_points );
	}		
}

arcadeMode_player_laststand()
{
	if( false == arcademode() )	{
		return;
	}
		
	self thread arcademode_assignpoints_toplayer( "arcademode_score_laststand", self );
	coopinfo( "msgcoop_playerdown", self );
}

arcadeMode_player_revive()
{
	if( false == arcademode() )	{
		return;
	}
	
	self thread arcademode_assignpoints_toplayer( "arcademode_score_revive", self );
}

updatePlayers()
{		
	level endon( "arcademode_complete" );
	
	players = get_players();
	
	highestScore = players[0].score;
	highestPlayer = players[0];

	for( i = 1; i < players.size; i++ )
	{
		if( players[i].score > highestPlayer.score )
		{
			highestPlayer = players[i];			
		}
	}
		
	if( highestScore > 0 )
	{
		if( level.arcadeMode_score_firstplace != highestPlayer getEntityNumber() )
		{
			level.arcadeMode_score_firstplace = highestPlayer getEntityNumber();
			coopinfo( "msgcoop_1stplace", highestPlayer );
		}
	}
}
	

round_up_to_ten( score )
{
	new_score = int(score) - int(score) % 10;
	if ( new_score < score )
		new_score += 10;
	return new_score;
}


updatePlusScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "arcademode_complete" );
		
	if ( amount == 0 || !isDefined( self.hud_scoreplusupdate ) )
		return;

	self notify( "update_plus_score" );
	self endon( "update_plus_score" );

	self.arcademode_updatePlusTotal += amount;

	wait ( 0.05 );

	if( isDefined( self.hud_scoreplusupdate ) )
	{			
		if ( self.arcademode_updatePlusTotal > 0 )
		{
			self.hud_scoreplusupdate setValue( self.arcademode_updatePlusTotal );
			self.hud_scoreplusupdate.alpha = 0.85;
			self.hud_scoreplusupdate thread fontPulse( self );
			self.hud_scoreplusupdate.label = &"SCRIPT_PLUS";
			wait 1;
			self.hud_scoreplusupdate fadeOverTime( 0.75 );
			self.hud_scoreplusupdate.alpha = 0;
			
			self.arcademode_updatePlusTotal = 0;
		}
	}
}


updateMinusScoreHUD( amount, time )
{
	self endon( "disconnect" );
	self endon( "arcademode_complete" );	

	if ( amount == 0 || !isDefined( self.hud_scoreplusupdate ))
		return;

	self notify( "update_minus_score" );
	self endon( "update_minus_score" );

	self.arcademode_updateMinusTotal += amount;

	wait ( 0.05 );

	if( false == isDefined( time ) )
	{
		time = 0.75;
	}
	
	if( isDefined( self.hud_scoreminusupdate ) )
	{			
		if ( self.arcademode_updateMinusTotal < 0 )
		{
			self.hud_scoreminusupdate setValue( self.arcademode_updateMinusTotal );
			self.hud_scoreminusupdate.alpha = 0.85;
			self.hud_scoreminusupdate thread fontPulse( self );			
			wait 1;
			self.hud_scoreminusupdate fadeOverTime( time );
			self.hud_scoreminusupdate.alpha = 0;
			
			self.arcademode_updateMinusTotal = 0;
		}
	}
}

updateMutliScoreHUD( multi )
{
	self endon( "disconnect" );
	self endon( "arcademode_complete" );
		
	if ( multi < 2 || !isDefined( self.hud_scoremulti ) )
		return;

	self notify( "update_multi_score" );
	self endon( "update_multi_score" );

	wait ( 0.05 );

	if( isDefined( self.hud_scoremulti ) )
	{		
		self.hud_scoremulti setValue( multi );
		self.hud_scoremulti.alpha = 0.85;
		self.hud_scoremulti thread fontPulse( self );
		self.hud_scoremulti.label = &"SCRIPT_AM_X";
		self.hud_scoremulti.color = level.arcadeMode_streak_color[ multi - 1 ];
		wait 2;
		self.hud_scoremulti fadeOverTime( 0.75 );
		self.hud_scoremulti.alpha = 0;
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
killStreakMonitor()
{
	self endon("disconnect");
	self endon("arcademode_complete");
		
	while( true )
	{
		wait( 0.2 );
		
		if( self getScoreMultiplier() != 1 && self.arcademode_ks_ends < gettime() )
		{
			self thread arcademode_kill_streak_reset( false );
		}
	}	
}

arcademode_kill_streak_reset( checkpointRestart )
{
	if ( flag( "arcademode_complete" ) )
		return;
		
	killstreak_achieved = self getScoreMultiplier();	
	if( 1 == killstreak_achieved )
	{
		return;
	}
	
	self notify( "update_multi_score" );
	self.hud_scoremulti.alpha = 0;
	
	self setScoreMultiplier( 1 );
	
	self.arcadeMode_ks_current_count = level.arcademode_ks[ self getScoreMultiplier() + 1 ];
	self.arcademode_ks_ends = 0;
		
	if( false == checkpointRestart )
	{
		if( killstreak_achieved > 1 )
		{
			if ( killstreak_achieved >= 8 )
			{	
				coopinfo( "msgcoop_killstreakwon", self );
				self playlocalsound( "arcademode_kill_streak_won" );				
			}
			else
			{
				coopinfo( "msgcoop_killstreaklost", self );
				self playlocalsound( "arcademode_kill_streak_lost" );				
			}
		}
	}
}

new_ending_hud( align, fade_in_time, x_off, y_off )
{
	hud_ending = newClientHudElem( self );
    hud_ending.foreground = true;
	hud_ending.x = x_off;
	hud_ending.y = y_off;
	hud_ending.alignX = "right";
	hud_ending.alignY = "top";
	hud_ending.horzAlign = "right";
    hud_ending.vertAlign = "top";
    	
 	hud_ending.fontScale = 3;
	if ( getdvar( "widescreen" ) == "1" )
	{
  		hud_ending.fontScale = 5;
	}
	hud_ending.color = ( 0.8, 1.0, 0.8 );
	hud_ending.font = "big";
	hud_ending.glowColor = ( 0.3, 0.6, 0.3 );
	hud_ending.glowAlpha = 1;

	hud_ending.alpha = 0;
	hud_ending fadeovertime( fade_in_time );
	hud_ending.alpha = 1;
	hud_ending.hidewheninmenu = true;
	return hud_ending;
}


arcademode_add_kill_streak()
{
	if ( self getScoreMultiplier() == level.arcademode_ks_max_streaks || self maps\_laststand::player_is_in_laststand() )
	{
		return;
	}
		
	self.arcadeMode_ks_current_count--;	
	
	if( 0 >= self.arcadeMode_ks_current_count )
	{		
		current_multiplier = self getScoreMultiplier() + 1;
		self setScoreMultiplier( current_multiplier );
		
		self thread updateMutliScoreHUD( current_multiplier );
		
		self playlocalsound( "arcademode_kill_streak_won" );
		
		curtime = gettime();
		
		if( self.arcademode_ks_ends < curtime ) 
		{
			self.arcademode_ks_ends = curtime; 			
		}
		
		self.arcademode_ks_ends += level.arcademode_ks_time[ current_multiplier ] * 1000;
		
		if( self.arcademode_ks_ends > level.arcademode_ks_max_time + curtime )
		{
			self.arcademode_ks_ends = level.arcademode_ks_max_time + curtime;
		}
			
		self.arcadeMode_ks_current_count = level.arcademode_ks[ current_multiplier + 1 ];
		
		maps\_challenges_coop::doMissionCallback( "multiplierChanged", self );
	}	
}

arcadeMode_init_kill_streak_colors()
{
	level.arcadeMode_streak_color = [];
	level.arcadeMode_streak_glow = [];
	
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = level.color_cool_green; // 1
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 0.8, 0.8, 2.0 ); // 2
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 2.0, 0.8, 0.0 ); // 3
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 0.5, 2.0, 2.0 ); // 4
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 2.0, 0.5, 2.0 ); // 5
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 0.3, 0.3, 2.0 ); // 6
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 2.0, 2.0, 0.5 ); // 7
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 2.0, 2.0, 2.0 ); // 8
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 2.0, 2.0, 2.0 ); // 9
	level.arcadeMode_streak_color[ level.arcadeMode_streak_color.size ] = ( 2.0, 2.0, 2.0 ); // 10	
	
	for ( i = 0; i < level.arcadeMode_streak_color.size; i++ )
	{
		level.arcadeMode_streak_glow[ i ] = ( level.arcadeMode_streak_color[ i ][ 0 ] * 0.35, level.arcadeMode_streak_color[ i ][ 1 ] * 0.35, level.arcadeMode_streak_color[ i ][ 2 ] * 0.35 );
	}
	
	// this one has a custom glow color so might as well use it
	level.arcadeMode_streak_color[ 0 ] = level.color_cool_green_glow;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fade_out( timer )
{
	self fadeovertime( timer );
	self.alpha = 0;
	wait( timer );
	
	self destroy();
}

fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3;
	self.outFrames = 5;
}

fontPulse( player )
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );
	self endon( "arcademode_complete" );	
	
	if( isDefined ( player ) )
	{
		player endon("disconnect");
	}
	
	scaleRange = self.maxFontScale - self.baseFontScale;
	
	while ( self.fontScale < self.maxFontScale )
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
		wait 0.05;
	}
		
	while ( self.fontScale > self.baseFontScale )
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
		wait 0.05;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

arcademode_complete()
{
	// for use with outside scripts because flag "arcademode_complete" may not be initialized
	if ( getdvar("arcademode") != "1" )
		return false;
	return flag( "arcademode_complete" );
}


arcadeMode_ends( level_index )
{
	if ( flag( "arcademode_complete" ) )
		return;
	flag_set( "arcademode_complete" );
	
	level notify ( "arcademode_complete" );
			
	players = get_players();
	for( i = 0; i < players.size; i++)
	{
		if( !isAlive( players[i] ) )
		{
			// a mission failed happened
			return;
		}
			
		players[i] freezePlayerForRoundEnd();
	}
	
	visionSetNaked( "mpOutro", 2.0 );
	
	wait(1.5);
			
	if( isCoopEPD() )
	{
		flag_set( "arcademode_ending_complete" );
		return;
	}	

	//-------CHEAT CARD STUFF-------	
	//------------------------------
	players = get_players();
	for( i = 0; i < players.size; i++)
	{
		players[i] notify( "vampire_end" );
	}	
	
	clientNotify( "vampire_end" );	//remove the vampire vision set	
	//------------------------------
	//------------------------------	
		
	setSavedDvar( "cg_drawOverheadNames", 0 );

	players = get_players();
	for( i = 0; i < players.size; i++)
	{
		players[i] notify ( "arcademode_complete" );
		
		players[i].hud_scoreplusupdate notify ( "arcademode_complete" );
		players[i].hud_scoreminusupdate notify ( "arcademode_complete" );
				
		players[i].hud_scoreplusupdate destroy();
		players[i].hud_scoreminusupdate destroy();
		players[i].hud_scoremulti destroy();
		
		players[i] setClientDvars( "ui_hud_hardcore", 1 );
	}	
	
	fadeToBlack = NewHudElem(); 
	fadeToBlack.x = 0; 
	fadeToBlack.y = 0;
	fadeToBlack.alpha = 0;
	fadeToBlack.horzAlign = "fullscreen"; 
	fadeToBlack.vertAlign = "fullscreen"; 
	fadeToBlack.foreground = false; 
	fadeToBlack.sort = 50; 
	fadeToBlack SetShader( "black", 640, 480 ); 	
	fadeToBlack FadeOverTime( 2.0 );
	fadeToBlack.alpha = 1; 
		     	
	mission_bonus( level_index );
		
	if( isDefined( level.nextmission_cleanup ) ) 
    {
    	level thread [[level.nextmission_cleanup]]();
    }	
	
	arcademode_upload_highscore();
	
	fadeToBlack FadeOverTime( 2.0 );
	fadeToBlack.alpha = 0; 
	
	for( i = 0; i < players.size; i++)
	{
		players[i] spawnIntermission();
	}
			
	wait(6.0);
	
	setsaveddvar( "missionsuccessbar", "0" );
			
	players = get_players();
	for( i = 0; i < players.size; i++)
	{
		players[i] setClientDvars( "ui_hud_hardcore", 0 );
	}	
	
	flag_set( "arcademode_ending_complete" );
}

freezePlayerForRoundEnd()
{
	//self clearLowerMessage();
		
	self closeMenu();
	self closeInGameMenu();
	
	self enableInvulnerability();
	
	self freezeControls( true );
}

spawnIntermission()
{
	self notify( "spawned" ); 
	self notify( "end_respawn" ); 
	
	self setSpawnVariables(); 
	
	self freezeControls( false ); 
	
	self.sessionstate = "intermission"; 
	self.spectatorclient = -1; 
	self.killcamentity = -1; 
	self.archivetime = 0; 
	self.psoffsettime = 0; 
	self.friendlydamage = undefined; 
	
	self default_onSpawnIntermission();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 ); 
}

setSpawnVariables()
{
	resetTimeout();

	// Stop shellshock and rumble
	self StopShellshock();
	self StopRumble( "damage_heavy" );
}

default_onSpawnIntermission()
{
	spawnpointname = "info_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = spawnPoints[0];
	
	if( isDefined( spawnpoint ) )
	{
		self spawn( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		println("NO '" + spawnpointname + "' SPAWNPOINTS IN MAP");
		println("NO '" + spawnpointname + "' SPAWNPOINTS IN MAP");
		println("NO '" + spawnpointname + "' SPAWNPOINTS IN MAP");
		println("NO '" + spawnpointname + "' SPAWNPOINTS IN MAP");
		println("NO '" + spawnpointname + "' SPAWNPOINTS IN MAP");
		println("'" + spawnpointname + "', this spawnpoint is used for the end of arcade mode where the scoreboard is show, exactly like MP");
		
		//assertex( spawnpoints.size, "There are no info_intermission spawn points in the map.  There must be at least one."  );
	}
}

arcademode_upload_highscore()
{
	if( level.systemLink || true == IsSplitScreen() )
	{
		return;
	}
	
	// update profile with new record
	levelScoreIndices = [];	
	levelScoreIndices[ "mak" ] 				= 0;
	levelScoreIndices[ "pel1" ] 			= 1;
	levelScoreIndices[ "pel2" ] 			= 2;
	levelScoreIndices[ "see1" ] 			= 3;
	levelScoreIndices[ "pel1a" ] 			= 4;
	levelScoreIndices[ "pel1b" ] 			= 5;
	levelScoreIndices[ "see2" ] 			= 6;
	levelScoreIndices[ "ber1" ] 			= 7;
	levelScoreIndices[ "ber2" ] 			= 8;
	levelScoreIndices[ "oki2" ] 			= 9;
	levelScoreIndices[ "oki3" ] 			= 10;
	levelScoreIndices[ "ber3" ] 			= 11;
	levelScoreIndices[ "ber3b" ] 			= 12;
	//levelScoreIndices[ "nazi_zombie_prototype" ] = 13;
	
	mission = -1;
	if ( isdefined( levelScoreIndices[ level.script ] ) )
	{
		mission = levelScoreIndices[ level.script ];	
	}
	
	assertEx( mission >= 0 && mission < 13, mission );
	if ( isDefined( mission ) )
	{		
		players = get_players();
		for( i = 0; i < players.size; i++)
		{
			previousHighscore = players[i] getcurrentarcadehighscore(mission);
			currentHighscore = players[i].score;
			
			if ( currentHighscore > previousHighscore )
			{
				players[i] UploadScore( mission, currentHighscore );
			}
		}
	}	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

compile_bonus()
{
	players = get_players();
	
	//BONUS TIME bitches!
	hardest2killNum = players[0].downs;
	hardest2kill = [];
	hardest2kill[0] = 0; 	
	
	mostRevivesNum = players[0].revives;
	mostRevives = [];
	mostRevives[0] = 0; //index into players
	
	mostHeadshotsNum = players[0].headshots;
	mostHeadshots = [];
	mostHeadshots[0] = 0; 	
	
	for(i = 1; i < players.size; i++)
	{
		if(players[i].downs < hardest2killNum)
		{
			hardest2killNum = players[i].downs;
			hardest2kill = [];
			hardest2kill[0] = i; 
		}
		else if(players[i].downs == hardest2killNum)
		{
			hardest2kill[hardest2kill.size] = i; 
		}
	
		if(players[i].revives > mostRevivesNum)
		{
			mostRevivesNum = players[i].revives;
			mostRevives = [];
			mostRevives[0] = i; 
		}
		else if(players[i].revives == mostRevivesNum)
		{
			mostRevives[mostRevives.size] = i; 
		}
		
		if(players[i].headshots > mostHeadshotsNum)
		{
			mostHeadshotsNum = players[i].headshots;
			mostHeadshots = [];
			mostHeadshots[0] = i; 
		}
		else if(players[i].headshots == mostHeadshotsNum)
		{
			mostHeadshots[mostHeadshots.size] = i; 
		}		
	}	
	
	for(i = 0; i < hardest2kill.size; i++)
	{
		if( players[ hardest2kill[i] ].score > 0 )
		{
			players[ hardest2kill[i] ].hardest2kill = true;	
		}
	}
	
	if(mostRevivesNum > 0) 
	{
		for(i = 0; i < mostRevives.size; i++)
		{	
			if( players[ mostrevives[i] ].score > 0 )
			{		
				players[ mostrevives[i] ].mostrevives = true;
			}
		}
	}	
	
	if(mostHeadshotsNum > 0) 
	{
		for(i = 0; i < mostHeadshots.size; i++)
		{
			if( players[ mostheadshots[i] ].score > 0 )
			{		
				players[ mostheadshots[i] ].mostheadshots = true;
			}
		}		
	}	
}


calculate_bonusforclient()
{
	bonus = 0;
	if( isDefined( self.hardest2kill ) )
	{
		bonus += getDvarInt( "arcademode_bonus_hardest2kill" );
	}
	
	if( isDefined( self.mostrevives ) )
	{
		bonus += getDvarInt( "arcademode_bonus_mostrevives" );
	}
	
	if( isDefined( self.mostheadshots ) )
	{
		bonus += getDvarInt( "arcademode_bonus_mostheadshots" );
	}
	
	bonus = round_up_to_ten( bonus );
	
	return bonus;
}

calculate_skillbonusforclient( score )
{
	skillmult = level.arcadeMode_skillMultiplier[ level.gameskill ];
	
	bonus = (skillmult * score) - score;
	
	bonus = round_up_to_ten( bonus );

	return bonus;
}

mission_bonus( level_index )
{
	flag_clear( "arcademode_progress2nextbonus" );
	
	setsaveddvar( "bonusbackground", "1" );
	
	fade_in_time = 1;
	
	missionScoreYpos = -30;	
	bonusYpos = missionScoreYpos + 40;
	difficultyYpos = missionScoreYpos + 40;
			
	///////////////////////////MISSION SCORE///////////////////////////
	//Mission Score - SERVER
	hud_missionscore = new_levelend_hud( "center", "left", 2.5, -125, missionScoreYpos, fade_in_time );
	hud_missionscore settext( &"SCRIPT_AM_MISSION_SCORE" );

	players = get_players();
	for( i = 0; i < players.size; i++ ) 
	{
		//Mission Score Value - CLIENT
		players[i].hud_missionscorevalue = players[i] new_levelend_hud( "center", "right", 2.5, 125, missionScoreYpos, fade_in_time, players[i] );
		players[i].hud_missionscorevalue.color = ( 1, 0.85, 0 );
		players[i].hud_missionscorevalue setvalue( players[i].score );
		players[i].hud_missionscorevalue.score = players[i].score;		
	}
		
	//tally final score for scoreboard and challenges
	compile_bonus();
	
	for( i = 0; i < players.size; i++)
	{
		if( players[i].score > 0 )
		{
			// no headshot, revive or least downs bonuses in seelow 2 tank level
			if( level.script != "see2" )
			{
				bonus = players[i] calculate_bonusforclient();
				
				players[i].score += bonus;	
			}
			
			bonus = calculate_skillbonusforclient( players[i].score );
			
			players[i].score += bonus;	
		}
	}
	
	setsaveddvar( "missionsuccessbar", "1" );
		
	maps\_challenges_coop::doMissionCallback( "levelEnd", level_index );
	
	wait( 2.0 );
		
	///////////////////////////ROUND BONUS///////////////////////////
	
	// no headshot, revive or least downs bonuses in seelow 2 tank level
	if( level.script != "see2" )
	{		
		//Round Bonus - SERVER
		hud_missionroundbonus = new_levelend_hud( "center", "left", 2.0, -125, bonusYpos, fade_in_time );
		hud_missionroundbonus settext( &"SCRIPT_AM_ROUND_BONUS" );	
		
	
		level.arcademode_progress2nextbonus = 0; 
		
		for( i = 0; i < players.size; i++ ) 
		{
		     players[i] thread progress2nextbonus_disconnect_threat( players[i], players.size ); 
		     players[i] thread client_roundbonus( players.size, bonusYpos, fade_in_time );
		}
		
		flag_wait( "arcademode_progress2nextbonus" );		
		
		for( i = 0; i < players.size; i++ ) 
		{
			players[i].hud_missionroundbonusvalue fadeOverTime( 1.0 );
			players[i].hud_missionroundbonusvalue.alpha = 0;
		}			
		
		//CLEAN UP ROUND BONUS
		hud_missionroundbonus fadeOverTime( 1.0 );	
		hud_missionroundbonus.alpha = 0;	
		
		wait(1.5);
	
		hud_missionroundbonus destroy();
		for( i = 0; i < players.size; i++ ) 
		{
			players[i].hud_missionroundbonusvalue destroy();		
		}	
	}
		
	///////////////////////////DIFFICULTY BONUS///////////////////////////
	///////////////////////////DIFFICULTY BONUS///////////////////////////
	///////////////////////////DIFFICULTY BONUS///////////////////////////
	
	skillmult = level.arcadeMode_skillMultiplier[ level.gameskill ];
	if( skillmult > 1 )
	{	
		//Difficulty Bonus - SERVER
		hud_missiondifficulty = new_levelend_hud( "center", "left", 2.0, -125, difficultyYpos, fade_in_time );
		hud_missiondifficulty settext( &"SCRIPT_AM_DIFFICULTY_BONUS" );		
						
		flag_clear( "arcademode_progress2nextbonus" );
		
		level.arcademode_progress2nextbonus = 0; 
		
		//Difficulty Value - CLIENT
		hud_missiondifficultyvalue = new_levelend_hud( "center", "right", 2.0, 125, difficultyYpos, fade_in_time );
		hud_missiondifficultyvalue.color = ( 1, 0.85, 0 );
		hud_missiondifficultyvalue settext( &"SCRIPT_AM_DIFFICULTY_BONUS_X", skillmult );	
	
		for( i = 0; i < players.size; i++ ) 
		{
		     players[i] thread progress2nextbonus_disconnect_threat( players[i], players.size ); 
		     players[i] thread client_difficultybonus( players.size, difficultyYpos, fade_in_time );
		}		
			
		flag_wait( "arcademode_progress2nextbonus" );
			
		hud_missiondifficulty fadeOverTime( 1.0 );
		hud_missiondifficultyvalue fadeOverTime( 1.0 );		
		hud_missiondifficulty.alpha = 0;
		hud_missiondifficultyvalue.alpha = 0;			
								
		wait(1.5);
		
		hud_missiondifficulty destroy();
		hud_missiondifficultyvalue destroy();

	}	
	//CLEAN UP MISSION SUCCESS & MISSION SCORE
	hud_missionscore fadeOverTime( 1.0 );
	hud_missionscore.alpha = 0;	

	for( i = 0; i < players.size; i++ ) 
	{	
		players[i].hud_missionscorevalue fadeOverTime( 1.0 );
		players[i].hud_missionscorevalue.alpha = 0;
	}		
		
	wait(1.5);
	
	hud_missionscore destroy();

	for( i = 0; i < players.size; i++ ) 
	{	
		players[i].hud_missionscorevalue destroy();
	}
	
	setsaveddvar( "bonusbackground", "0" );
}



combine_points( hud_mission, bonus )
{
    self endon( "disconnect" );
    
    self playLoopSound( "score_tally_loop" );    
    
	final_score = bonus + hud_mission.score;
	
	for ( ;; )
	{
		difference = final_score - hud_mission.score;
		boost = difference * 0.2 + 1;
		if ( difference <= 15 )
			boost = 1;
			
		boost = int( boost );
		
		hud_mission.score += boost;
				
		if ( hud_mission.score > final_score )
		{
			hud_mission.score = final_score;
		}
			
		hud_mission setvalue( hud_mission.score );

		if ( hud_mission.score == final_score )
			break;

		wait( 0.05 );
	}
	
	self stopLoopSound();
}

combine_hudpoints( hud_mission, hud_bonus )
{
    self endon( "disconnect" );
	
    self playLoopSound( "score_tally_loop" ); 
	   
	final_score = hud_mission.score + hud_bonus.score;
	
	for ( ;; )
	{
		difference = final_score - hud_mission.score;
		boost = difference * 0.2 + 1;
		if ( difference <= 15 )
			boost = 1;
			
		boost = int( boost );
		
		hud_mission.score += boost;
		hud_bonus.score -= boost;
				
		if ( hud_mission.score > final_score )
		{
			hud_mission.score = final_score;
			hud_bonus.score = 0;
		}
			
		hud_mission setvalue( hud_mission.score );
		hud_bonus setvalue( hud_bonus.score );

		if ( hud_mission.score == final_score )
			break;

		wait( 0.05 );
	}
	
	self stopLoopSound();
}

new_levelend_hud( horzAlign, alignX, fontScale, x_off, y_off, fade_in_time, player )
{
	if ( isDefined( player ) )
	{
		hud_elem = newClientHudElem( player );
	}
	else
	{
		hud_elem = newHudElem();
	}
	
    hud_elem.foreground = true;
    hud_elem.sort = 50;
	hud_elem.x = x_off;
	hud_elem.y = y_off;
	hud_elem.alignX = alignX;
	hud_elem.alignY = "middle";
	hud_elem.horzAlign = horzAlign;
	hud_elem.vertAlign = "middle";

	hud_elem.font = "big";
	hud_elem.fontScale = fontScale;
 	
	hud_elem.color = (1.0, 1.0, 1.0);
	hud_elem.glowColor = (0.3, 0.6, 0.3);
	hud_elem.glowAlpha = 1;

	hud_elem.alpha = 0;
	hud_elem fadeovertime( fade_in_time );
	hud_elem.alpha = 1;
	
	hud_elem.hidewheninmenu = true;	
	
	return hud_elem;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

client_roundbonus( count, bonusYpos, fade_in_time ) 
{ 
    self endon( "disconnect" ); 
      
    if( self.hud_missionscorevalue.score < 0 )
	{
    	bonus = 0;
    }
    else
    {
    	bonus = self calculate_bonusforclient();
    }
    
	//Mission Round Bonus Value
	self.hud_missionroundbonusvalue = new_levelend_hud( "center", "right", 2.0, 125, bonusYpos, fade_in_time, self );
	self.hud_missionroundbonusvalue.color = ( 1, 0.85, 0 );
	self.hud_missionroundbonusvalue setvalue( bonus );
	self.hud_missionroundbonusvalue.score = bonus;   
	
	bonusYpos += 40;
	
	hud_hardest2kill = undefined;
	hud_mostrevives = undefined;
	hud_mostheadshots = undefined;
		
	/////////////////////////////////HARDEST 2 KILL///////////////////////////////////
	if( isDefined( self.hardest2kill ) )
	{	
		hud_hardest2kill = new_levelend_hud( "center", "center", 2.0, 0, bonusYpos, fade_in_time, self );
		hud_hardest2kill settext( &"SCRIPT_AM_BONUS_HARDEST_2_KILL", getDvarInt ( "arcademode_bonus_hardest2kill" ) );
		bonusYpos += 30;
	}	
	
	/////////////////////////////////MOST REVIVES///////////////////////////////////
	if( isDefined( self.mostrevives ) )
	{		
		hud_mostrevives = new_levelend_hud( "center", "center", 2.0, 0, bonusYpos, fade_in_time, self );
		hud_mostrevives settext( &"SCRIPT_AM_BONUS_MOST_REVIVES", getDvarInt ( "arcademode_bonus_mostrevives" ) );
		bonusYpos += 30;
	}	
	
	/////////////////////////////////MOST HEADSHOTS///////////////////////////////////
	if( isDefined( self.mostheadshots ) )
	{		
		hud_mostheadshots = new_levelend_hud( "center", "center", 2.0, 0, bonusYpos, fade_in_time, self );
		hud_mostheadshots settext( &"SCRIPT_AM_BONUS_MOST_HEADSHOTS", getDvarInt ( "arcademode_bonus_mostheadshots" ) );
	}	
	
	wait( fade_in_time + 0.5 );
	
	self combine_hudpoints( self.hud_missionscorevalue, self.hud_missionroundbonusvalue );
		
    level.arcademode_progress2nextbonus++; 
 
	if( isDefined( self.hardest2kill ) )
	{
		hud_hardest2kill fadeOverTime( 1.0 );
		hud_hardest2kill.alpha = 0;
	}
	
	if( isDefined( self.mostrevives ) )
	{
		hud_mostrevives fadeOverTime( 1.0 );
		hud_mostrevives.alpha = 0;
	}
	
	if( isDefined( self.mostheadshots ) )
	{
		hud_mostheadshots fadeOverTime( 1.0 );
		hud_mostheadshots.alpha = 0;
	}
	
	wait( 1.0 );
    
	if( isDefined( self.hardest2kill ) )
	{
		hud_hardest2kill destroy();
	}
	
	if( isDefined( self.mostrevives ) )
	{
		hud_mostrevives destroy();
	}
	
	if( isDefined( self.mostheadshots ) )
	{
		hud_mostheadshots destroy();
	}	
	
	if( level.arcademode_progress2nextbonus == count ) 
	{ 
		flag_set( "arcademode_progress2nextbonus" ); 
	} 
} 
 
client_difficultybonus( count, difficultyYpos, fade_in_time ) 
{ 
    self endon( "disconnect" ); 
		
    
    if( self.hud_missionscorevalue.score < 0 )
	{
    	bonus = 0;
    }
    else
    {
    	bonus = calculate_skillbonusforclient( self.hud_missionscorevalue.score );
    }    
	
	wait( fade_in_time + 0.5 );
	self combine_points( self.hud_missionscorevalue, bonus );
	wait(1.5);		
	
    level.arcademode_progress2nextbonus++; 
 
	if( level.arcademode_progress2nextbonus == count ) 
	{ 
		flag_set( "arcademode_progress2nextbonus" ); 
	} 		
}
  
progress2nextbonus_disconnect_threat( player, count ) 
{ 
     self waittill( "disconnect" ); 
 
     level.arcademode_progress2nextbonus++; 
 
     if( level.arcademode_progress2nextbonus == count ) 
     { 
          flag_set( "arcademode_progress2nextbonus" );           
     } 
}

