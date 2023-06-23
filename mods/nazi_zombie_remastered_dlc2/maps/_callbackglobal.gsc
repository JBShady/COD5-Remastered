#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_music; 

init()
{
	level.splitscreen = isSplitScreen(); 
	level.xenon = ( getdvar( "xenonGame" ) == "true" ); 
	level.ps3 = ( getdvar( "ps3Game" ) == "true" ); 
	level.wii = ( getdvar( "wiiGame" ) == "true" ); 
	level.onlineGame = getDvarInt( "onlinegame" ); 
	level.systemLink = getDvarInt( "systemlink" ); 
	level.console = ( level.xenon || level.ps3 || level.wii ); 

	// CODER_MOD: Austin (8/15/08): display briefing menu until all players have joined
	PrecacheMenu( "briefing" );

    // CODER_MOD
    // GMJ( 7/13/08 ): Players can earn xp and unlock things in private matches.
	level.rankedMatch = ( level.onlineGame 
                          // && !getDvarInt( "xblive_privatematch" )
                        ); 
	
/#
	if( getdvarint( "scr_forcerankedmatch" ) == 1 )
	{
		level.rankedMatch = true; 
	}
#/
}

SetupCallbacks()
{
	level.otherPlayersSpectate = false; 
	
	level.spawnPlayer = ::spawnPlayer; 
	level.spawnClient = ::spawnClient; 
	level.spawnSpectator = ::spawnSpectator; 
	level.spawnIntermission = ::spawnIntermission; 
		
	
	level.onSpawnPlayer = ::default_onSpawnPlayer; 
	level.onPostSpawnPlayer = ::default_onPostSpawnPlayer; 
	level.onSpawnSpectator = ::default_onSpawnSpectator; 
	level.onSpawnIntermission = ::default_onSpawnIntermission; 

	level.onStartGameType = ::blank; 
	level.onPlayerConnect = ::blank; 
	level.onPlayerDisconnect = ::blank; 
	level.onPlayerDamage = ::blank; 
	level.onPlayerKilled = ::blank; 
	level.onPlayerWeaponSwap = ::blank; 

	level.loadout = ::menuLoadout; 
}


blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}

// CODER_MOD
// Austin( 7/5/07 ): used by the curve code to notify the level entity of a curve event
Callback_CurveNotify( string, curveId, nodeIndex )
{
	level notify( string, curveId, nodeIndex ); 
}


Callback_StartGameType()
{
	//CODER_MOD: TOMMYK 07/16/2008 - For coop scoreboards
	//maps\_gameskill::initialScoreUpdate(); 
}


BriefInvulnerability()
{
	self endon( "disconnect" );
	
	self EnableInvulnerability();
	/#
	println( "****EnableInvulnerability****" ); 
	#/
	
	wait (3);
	
	self DisableInvulnerability();
	/#
	println( "****DisableInvulnerability****" ); 
	#/
}


Callback_SaveRestored()
{
	/#
	println( "****Coop CodeCallback_SaveRestored****" ); 
	#/
	
	players = get_players(); 
	level.debug_player = players[0]; 	
	
	num = 0; 
	
	if( isdefined( level._save_pos ) )
	{
		num = level._save_trig_ent; 
	}
	
//	println("*** Restoring with breadcrumbs from player " + num);
	
	for( i = 0; i < 4; i++ )
	{
		player = players[i];
		if( isDefined( player ) )
		{
// CODER_MOD JB - Prevents "death" loop with player upon restoring savegame
			player thread BriefInvulnerability();
			player thread maps\_quotes::main(); 
			
/*			player setorigin( level._player_breadcrumbs[num][i].pos ); 
			player setplayerangles( level._player_breadcrumbs[num][i].ang ); 	 */

			if( isdefined( player.savedVisionSet ) )
			{
				player VisionSetNaked( player.savedVisionSet, 0.1 ); 
			}

			// this is to aviod having the deaths reset when restarting from a checkpoint
			dvarName = "player" + player GetEntityNumber() + "downs";
			player.downs = getdvarint( dvarName );

			maps\_challenges_coop::doMissionCallback( "checkpointLoaded", player ); 
		}
	}

	// CODER_MOD: Austin (7/31/08): re-initialize the collectibles system
	maps\_collectibles::onSaveRestored();

	maps\_challenges_coop::onSaveRestored();

	// CODER_MOD: TommyK (8/5/08)
	level thread maps\_arcademode::arcadeMode_checkpoint_restore();
	
	level thread maps\_collectibles_game::collectibles_checkpoint_restore();
}

Player_BreadCrumb_Reset( position, angles )
{
	if( !isdefined( angles ) )
	{
		angles = ( 0, 0, 0 ); 
	}
	
	level.playerPrevOrigin0 = position; 
	level.playerPrevOrigin1 = position; 
	
	if( !isdefined( level._player_breadcrumbs ) )
	{
		level._player_breadcrumbs = []; 
		
		for( i = 0; i < 4; i ++ )
		{
			level._player_breadcrumbs[i] = []; 

			for( j = 0; j < 4; j ++ )
			{
				level._player_breadcrumbs[i][j] = spawnstruct(); 
			}
		}
		
	}
	
	for( i = 0; i < 4; i ++ )
	{	
		for( j = 0; j < 4; j ++ )
		{
			level._player_breadcrumbs[i][j].pos = position; 
			level._player_breadcrumbs[i][j].ang = angles; 
		}
	}

}

Player_BreadCrumb_Update()
{
	self endon( "disconnect" ); 
	drop_distance = 70; 
	right = anglestoright( self.angles ) * drop_distance; 
	level.playerPrevOrigin0 = self.origin + right; 
	level.playerPrevOrigin1 = self.origin - right; 
	
	if( !isdefined( level._player_breadcrumbs ) )
	{
		Player_BreadCrumb_Reset( self.origin, self.angles ); 
	}
	
	num = self GetEntityNumber(); 
	
	while( 1 )
	{
		wait 1; 
		dist_squared = distancesquared( self.origin, level.playerPrevOrigin0 ); 
		if( dist_squared > 500*500 )	// just in case player is teleported
		{
			right = anglestoright( self.angles ) * drop_distance; 
			level.playerPrevOrigin0 = self.origin + right; 
			level.playerPrevOrigin1 = self.origin - right; 
		}
		else if( dist_squared > drop_distance*drop_distance )
		{
			level.playerPrevOrigin1 = level.playerPrevOrigin0; 
			level.playerPrevOrigin0 = self.origin; 
		}
		
		dist_squared = distancesquared( self.origin, level._player_breadcrumbs[num][0].pos ); 
		
/*		if( dist_squared > 500 * 500 )
		{
			right = anglestoright( self.angles ) * drop_distance; 
			pos = self.origin -( right * 2 ); 

			level._player_breadcrumbs[num][0].pos = pos; 
			pos += right; 
			level._player_breadcrumbs[num][1].pos = pos; 
			pos += right; 
			pos += right; 	// skip player position
			level._player_breadcrumbs[num][2].pos = pos; 
			pos += right; 
			level._player_breadcrumbs[num][3].pos = pos; 
			
			for( i = 0; i < 4; i ++ )
			{
				level._player_breadcrumbs[num][i].ang = self.angles; 
			}
		}
		else if( dist_squared > drop_distance * drop_distance ) */
		
		dropBreadcrumbs = true;
		
		if(IsDefined( level.flag ) && IsDefined( level.flag["drop_breadcrumbs"]))
		{
			if(!flag("drop_breadcrumbs"))
			{
				dropBreadcrumbs = false;
			}
		}
		
		if( dropBreadcrumbs && (dist_squared > drop_distance * drop_distance) ) 
		{
			for( i = 2; i >= 0; i -- )
			{
				level._player_breadcrumbs[num][i + 1].pos = level._player_breadcrumbs[num][i].pos; 
				level._player_breadcrumbs[num][i + 1].ang = level._player_breadcrumbs[num][i].ang; 
			}
			
			level._player_breadcrumbs[num][0].pos = PlayerPhysicsTrace(self.origin, self.origin + ( 0, 0, -1000 )); 
			level._player_breadcrumbs[num][0].ang = self.angles; 
		}
	/*	
		for( i = 0; i < 4; i ++ )
		{	
			col = ( 0.0, 0.8, 0.0 ); 
			
			switch( num )
			{
				case 1:
					col = ( 0.8, 0.0, 0.0 ); 
					break; 
				case 2:
					col = ( 0.0, 0.0, 0.8 ); 
					break; 
				case 3:
					col = ( 0.8, 0.0, 0.8 ); 
					break; 
			}
			print3d( level._player_breadcrumbs[num][i].pos, i, col, 1, 1, 20 ); 
		} 
		
		if( num == 0 )
		{
			if( isdefined( level._save_pos ) )
			{
				print3d( level._save_pos, "svp " + level._save_trig_ent, ( 0.0, 0.8, 0.0 ), 1, 1, 20 ); 				
			}
		} 
		*/
	} 
}

SetPlayerSpawnPos()
{
	players = get_players(); 
	player = players[0]; 

	if( !isdefined( level._player_breadcrumbs ) )
	{
		spawnpoints = getentarray( "info_player_deathmatch", "classname" ); 
		
		if( player.origin == ( 0, 0, 0 ) && isdefined( spawnpoints ) && spawnpoints.size > 0 )
		{
			Player_BreadCrumb_Reset( spawnpoints[0].origin, spawnpoints[0].angles ); 
		}
		else
		{
			Player_BreadCrumb_Reset( player.origin, player.angles ); 
		}
	}
	
	too_close = 30; 
	spawn_pos = level._player_breadcrumbs[0][0].pos; 
	dist_squared = distancesquared( player.origin, spawn_pos ); 

	if( dist_squared > 500*500 )	// just in case player is teleported
	{
		if( player.origin != ( 0, 0, 0 ) )
		{
			spawn_pos = player.origin +( 0, 30, 0 ); 
		}
	}
	else if( dist_squared < too_close*too_close )
	{
		spawn_pos = level._player_breadcrumbs[0][1].pos; 
	}
	
	spawn_angles = vectornormalize( player.origin - spawn_pos ); 
	spawn_angles = vectorToAngles( spawn_angles ); 

	// make sure that this is a valid spawn position
	if( !playerpositionvalid( spawn_pos ) )
	{
		// for now just put them at the player position
		// we know this position is valid
		spawn_pos = player.origin; 
		spawn_angles = player.angles; 
	}
	/*	
	self setOrigin( spawn_pos ); 
	
	// set them looking at player0
	self setPlayerAngles( spawn_angles );  */
}

Callback_PlayerConnect()
{
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
	{
		println( "File: _callbackglobal.gsc. Function: Callback_PlayerConnect()\n" ); 
	}
	#/
	
	thread first_player_connect(); 

	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
	{
		println( "File: _callbackglobal.gsc. Function: Callback_PlayerConnect() - START WAIT begin and waittillframeend\n" ); 
	}
	#/
	
	self waittill( "begin" ); 
	self reset_clientdvars();
	waittillframeend; 

	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
	{
		println( "File: _callbackglobal.gsc. Function: Callback_PlayerConnect() - STOP WAIT begin and waittillframeend\n" ); 
	}
	#/

	level notify( "connected", self ); 

	self thread maps\_load::player_special_death_hint();
	
	// we want to give the player a good default starting position
	// info_player_spawn actually gets renamed to info_player_deathmatch
	// in the game
	info_player_spawn = getentarray( "info_player_deathmatch", "classname" ); 
	
	if( isdefined( info_player_spawn ) && info_player_spawn.size > 0 )
	{
		// CODER_MOD
		// Danl( 08/03/07 ) Band aid to spawn clients at host position.
		players = get_players(); 
		if( Isdefined( players ) &&( players.size != 0 ) )// || players[0] == self ) )
		{
			if( players[0] == self )
			{
				println( "2:  Setting player origin to info_player_start " + info_player_spawn[0].origin ); 
				self setOrigin( info_player_spawn[0].origin ); 
				self setPlayerAngles( info_player_spawn[0].angles ); 
				self thread Player_BreadCrumb_Update(); 
			}
			else
			{
				println( "Callback_PlayerConnect:  Setting player origin near host position " + players[0].origin ); 
				self SetPlayerSpawnPos(); 
				self thread Player_BreadCrumb_Update(); 
			}
		}
		else
		{
			println( "Callback_PlayerConnect:  Setting player origin to info_player_start " + info_player_spawn[0].origin ); 
			self setOrigin( info_player_spawn[0].origin ); 
			self setPlayerAngles( info_player_spawn[0].angles ); 
			self thread Player_BreadCrumb_Update(); 
		}
	}

	// SCRIPTER_MOD
	// JesseS( 3/15/2007 ): added player flag setup function
	// CODER_MOD 
	// Danl( 08/03/2007 ) - bandaid to facilitate hot joined players being at the host position on restart from checkpoint
	if( !IsDefined( self.flag ) )
	{
		self.flag = []; 
		self.flags_lock = []; 
	}

	if( !IsDefined( self.flag["player_has_red_flashing_overlay"] ) )
	{
		self player_flag_init( "player_has_red_flashing_overlay" ); 
		self player_flag_init( "player_is_invulnerable" ); 
	}

	if( !IsDefined( self.flag["loadout_given"] ) )
	{
		self player_flag_init( "loadout_given" ); 
	}

	self player_flag_clear( "loadout_given" ); 

	// CODER_MOD
	// Austin( 6/20/07 ): added spectate camera

	// create the spectate camera
//	self.spectate_cam = spawn( "script_camera", ( 0, 0, 0 ) ); 
//
//	// pick a random player to spectate on
//	players = get_players(); 
//	if( players.size > 0 )
//	{
//		num = RandomInt( players.size ); 
//
//		self.spectate_cam linkto( players[num], "tag_origin", ( -100, 0, 50 ), ( 0, 0, 0 ) ); 
//
//		// activate the spectate camera
//		self playerlinktocamera( self.spectate_cam, 0, 0 ); 
//	}
	
	// CODER_MOD: Jon E - This is needed for the SP_TOOL or MP_TOOL to work for MODS
	if( GetDvar( "r_reflectionProbeGenerate" ) == "1" )
	{
		waittillframeend; 
		//self spawn( self.origin, self.angles ); 
		self thread spawnPlayer(); 
		return; 
	}
		
/#
	if( !isdefined( level.spawnClient ) )
	{
		waittillframeend; 
		//self spawn( self.origin, self.angles ); 
		self thread spawnPlayer(); 
		return; 
	}  
#/
	self setClientDvar( "ui_allow_loadoutchange", "1" ); 

	self thread[[level.spawnClient]](); 

	dvarName = "player" + self GetEntityNumber() + "downs";
	setdvar( dvarName, self.downs );
		
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
	{
		println( "File: _callbackglobal.gsc. Function: Callback_PlayerConnect() - COMPLETE\n" ); 
	}
	#/
}

reset_clientdvars()
{
	if( IsDefined( level.reset_clientdvars ) )
	{
		self [[level.reset_clientdvars]]();
		return;
	}

	self SetClientDvars( "compass", "1",
						 "hud_showStance", "1",
						 "cg_thirdPerson", "0",
						 "cg_thirdPersonAngle", "0",
						 "ammoCounterHide", "0",
						 "miniscoreboardhide", "0",
						 "ui_hud_hardcore", "0",
						 "credits_active", "0" );

	self AllowSpectateTeam( "allies", false );
	self AllowSpectateTeam( "axis", false );
	self AllowSpectateTeam( "freelook", false );
	self AllowSpectateTeam( "none", false );
}


Callback_PlayerDisconnect()
{
}

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	//CODER MOD: TOMMY K, this is to prevent a player killing another player
	if( isdefined( eAttacker ) && isPlayer( eAttacker ) && ( !isDefined( level.friendlyexplosivedamage ) || !level.friendlyexplosivedamage ))
	{
		if( self != eAttacker )
		{
			//one player shouldn't damage another player, grenades, airstrikes called in by another player
			return;
		}
		else if( sMeansOfDeath != "MOD_GRENADE_SPLASH"
				&& sMeansOfDeath != "MOD_GRENADE"
				&& sMeansOfDeath != "MOD_EXPLOSIVE"
				&& sMeansOfDeath != "MOD_PROJECTILE"
				&& sMeansOfDeath != "MOD_PROJECTILE_SPLASH"
				&& sMeansOfDeath != "MOD_BURNED" )
		{
			//player should be able to damage they're selves with grenades and stuff
			//otherwise don't damage the player, so like airstrikes  won't kill the player
			return;
		}
	}
	
	// Override MUST call finishPlayerDamage if the damage is to be applied
	if( IsDefined( level.overridePlayerDamage ) )
	{
		self [[level.overridePlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime );
		return;
	}		

	self finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
}


finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ); 
}

/*================ 
Called when a player has been revived while in last stand
 ================ */
Callback_RevivePlayer()
{
	self endon( "disconnect" ); 
	self RevivePlayer(); 
}


/*================ 
Called when a player has been killed, but has last stand perk.
self is the player that was killed.
 ================ */
Callback_PlayerLastStand( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self endon( "disconnect" ); 
	[[maps\_laststand::PlayerLastStand]]( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration ); 
}


Callback_PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self thread[[level.onPlayerKilled]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration ); 

	// get rid of the head icon
	//self.headicon = ""; 
	
//	setmusicstate( "DEATH" ); 

	self.downs++;
	dvarName = "player" + self GetEntityNumber() + "downs";
	setdvar( dvarName, self.downs );

	if( IsDefined( level.player_killed_shellshock ) )
	{
		self ShellShock( level.player_killed_shellshock, 3 );
	}
	else
	{
		self ShellShock( "death", 3 );
	}

	self PlayLocalSound( "mx_death" ); 
	self PlayLocalSound( "mx_death_rear" ); 

	// restore the movement
	self setmovespeedscale( 1.0 ); 
	self.ignoreme = false; 

	self notify( "killed_player" ); 
	
	wait( 1 ); 
	// wait for the death sequence to finish

	if( IsDefined( level.overridePlayerKilled ) )
	{
		self [[level.overridePlayerKilled]]();
	}

	if( get_players().size > 1 )
	{
		// CODER_MOD 
		// BNANDAKUMAR( 05/29/08 )
		// We will display a Mission Failed text for all the players
		// We will also display a message below if "You have died" or "Your teammate has died"
		players = get_players(); 
		for( i = 0; i < players.size; i++ )
		{
			if( isDefined( players[i] ) )
			{
				players[i] thread maps\_quotes::displayMissionFailed(); 
				if( !isAlive( players[i] ) )
				{
					players[i] thread maps\_quotes::displayPlayerDead(); 
					println( "Player #"+i+" is dead" ); 
				}
				else
				{
					players[i] thread maps\_quotes::displayTeammateDead( self ); 
					println( "Player #"+i+" is alive" ); 
				}
			}
		}
		missionfailed(); 
		return; 
	}
	
/#
	if( !isdefined( level.spawnClient ) )
	{
		waittillframeend; 
		self spawn( self.origin, self.angles ); 
		return; 
	}  
#/
}

// this function is going to handle waiting for player input or programmed delays before starting the spawn
spawnClient()
{
	self endon( "disconnect" ); 
	self endon( "end_respawn" ); 

	println( "*************************spawnClient****" ); 

	// CODER_MOD
	// Austin( 6/20/07 ): added spectate camera
	
	// shut off the spectate cam
	self unlink(); 
	
	if( isdefined( self.spectate_cam ) )
	{
		self.spectate_cam delete(); 
	}

	if( level.otherPlayersSpectate )
	{
		self thread	[[level.spawnSpectator]](); 
	}
	else
	{
		self thread	[[level.spawnPlayer]](); 
	}
}

spawnPlayer( spawnOnHost )
{
	self endon( "disconnect" ); 
	self endon( "spawned_spectator" ); 
	self notify( "spawned" ); 
	self notify( "end_respawn" ); 

	// Be sure everyone is connected before actually spawning in.
	// Wait until all players are connected
	synchronize_players(); 

	setSpawnVariables(); 
	
	self.sessionstate = "playing"; 
	self.spectatorclient = -1; 
	self.archivetime = 0; 
	self.psoffsettime = 0; 
	self.statusicon = ""; 
//	self.maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" ); 
//	self.health = self.maxhealth; 
	self.maxhealth = self.health; 
	self.shellshocked = false; 
	self.inWater = false; 
	self.friendlydamage = undefined; 
	self.hasSpawned = true; 
	self.spawnTime = getTime(); 
	self.afk = false; 

	println( "*************************spawnPlayer****" ); 
	self detachAll(); 

	if( IsDefined( level.custom_spawnPlayer ) )
	{
		self [[level.custom_spawnPlayer]]();
		return;
	}

	if( isdefined( level.onSpawnPlayer ) )
	{
		self [[level.onSpawnPlayer]](); 
	}

	wait_for_first_player(); 
	
	if( isdefined( spawnOnHost ) )
	{
		self Spawn( get_players()[0].origin, get_players()[0].angles ); 
		self SetPlayerSpawnPos(); 
	}
	else
	{
		self Spawn( self.origin, self.angles ); 			
	}

	if( isdefined( level.onPostSpawnPlayer ) )
	{
		self[[level.onPostSpawnPlayer]](); 
	}

	if( isdefined( level.onPlayerWeaponSwap ) )
	{
		self thread[[level.onPlayerWeaponSwap]](); 
	}

	// Insert all checks for other utility scripts here...
	// If you do not thread it, make sure it immediately finishes the function( no waits )
	self maps\_introscreen::introscreen_player_connect(); 

	// should not need this wait.  something in the spawn overides the weapons
	waittillframeend; 
	
	// CODER_MOD
	// Dan L( 08/01/06 ) we need to delay the rest of the creation process, until the messages dealing with the
	// spawning of the player has finished propagating to remote clients.  This is not a good final solution.
	// Ultimately, this whole chain of code shouldn't be triggered off until the server has determined that the clients
	// have all received the map_restart message.
	if( self != get_players()[0] )
	{
		wait( 0.5 ); 
	}
	
	self notify( "spawned_player" ); 
}

synchronize_players()
{
	// If this flag is not set, then we are either in a testmap or reflection probes is being called
	if( !IsDefined( level.flag ) || !IsDefined( level.flag["all_players_connected"] ) )
	{
		println( "^1****    ERROR: You must call _load::main() if you don't want bad coop things to happen!    ****" );
		println( "^1****    ERROR: You must call _load::main() if you don't want bad coop things to happen!    ****" );
		println( "^1****    ERROR: You must call _load::main() if you don't want bad coop things to happen!    ****" );
		return;
	}

	// MikeD( 6/2/2008 ): If the expected and connected players match, then don't even bother with
	// the synchronize screen.
	if( GetNumConnectedPlayers() == GetNumExpectedPlayers() )
	{
		return; 
	}

	if( flag( "all_players_connected" ) )
	{
		return; 
	}

	// CODER_MOD: Austin (8/15/08): rework to display briefing menu in online coop and black screen for splitscreen
	background = undefined;

	if ( level.onlineGame || level.systemLink ) 
	{
		self OpenMenu( "briefing" );
	}
	else
	{
		background = NewHudElem(); 
		background.x = 0; 
		background.y = 0; 
		background.horzAlign = "fullscreen"; 
		background.vertAlign = "fullscreen"; 
		background.foreground = true; 
		background SetShader( "black", 640, 480 ); 
	}
	
	flag_wait( "all_players_connected" );

	if ( level.onlineGame || level.systemLink ) 
	{
		players = get_players();

		for ( i = 0; i < players.size; i++ )
		{
			players[i] CloseMenu();
		}
	}
	else 
	{
		assert( IsDefined( background ) );
		background Destroy(); 
	}
}

spawnSpectator()
{
	self endon( "disconnect" ); 
	self endon( "spawned_spectator" ); 
	self notify( "spawned" ); 
	self notify( "end_respawn" ); 

	setSpawnVariables(); 
	
	self.sessionstate = "spectator"; 
	self.spectatorclient = -1; 
	if( isdefined( level.otherPlayersSpectateClient ) )
	{
		self.spectatorclient = level.otherPlayersSpectateClient getEntityNumber(); 
	}

	self setClientDvars( "cg_thirdPerson", 0 );	
	self setSpectatePermissions();
	
	self.archivetime = 0; 
	self.psoffsettime = 0; 
	self.statusicon = ""; 
//	self.maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" ); 
//	self.health = self.maxhealth; 
	self.maxhealth = self.health; 
	self.shellshocked = false; 
	self.inWater = false; 
	self.friendlydamage = undefined; 
	self.hasSpawned = true; 
	self.spawnTime = getTime(); 
	self.afk = false; 

	println( "*************************spawnSpectator***" ); 
	self detachAll(); 

	if( isdefined( level.onSpawnSpectator ) )
	{
		self[[level.onSpawnSpectator]](); 
	}
	
	self Spawn( self.origin, self.angles ); 

	// should not need this wait.  something in the spawn overides the weapons
	waittillframeend; 
	
	flag_wait( "all_players_connected" ); 
	
	self notify( "spawned_spectator" ); 
}

setSpectatePermissions()
{
	self AllowSpectateTeam( "allies", true );
	self AllowSpectateTeam( "axis", false );
	self AllowSpectateTeam( "freelook", false );
	self AllowSpectateTeam( "none", false );
}

spawnIntermission()
{
	self notify( "spawned" ); 
	self notify( "end_respawn" ); 
	
	self setSpawnVariables(); 
	
	self freezeControls( false ); 
	
	self setClientDvar( "cg_everyoneHearsEveryone", "1" ); 
	
	self.sessionstate = "intermission"; 
	self.spectatorclient = -1; 
	self.killcamentity = -1; 
	self.archivetime = 0; 
	self.psoffsettime = 0; 
	self.friendlydamage = undefined; 
	
	[[level.onSpawnIntermission]](); 
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 ); 
}

default_onSpawnPlayer()
{
}


default_onPostSpawnPlayer()
{
}


default_onSpawnSpectator()
{
}

default_onSpawnIntermission()
{
	spawnpointname = "info_intermission"; 
	spawnpoints = getentarray( spawnpointname, "classname" ); 
	
	// CODER_MOD: TommyK (8/5/08)
	if(spawnpoints.size < 1)
	{
		println( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" ); 
		return;
	}	
	
	spawnpoint = spawnpoints[RandomInt(spawnpoints.size)];	
	if( isDefined( spawnpoint ) )
	{
		self spawn( spawnpoint.origin, spawnpoint.angles ); 
	}
}

first_player_connect()
{
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
/#
	if( getdebugdvar( "replay_debug" ) == "1" )
	{
		println( "File: _callbackglobal.gsc. Function: first_player_connect()\n" ); 
	}
#/
	
	waittillframeend; 

	if( isDefined( self ) )
	{
		level notify( "connecting", self ); 

		players = get_players(); 
		if( isdefined( players ) &&( players.size == 0 || players[0] == self ) )
		{
			level notify( "connecting_first_player", self ); 
			self waittill( "spawned_player" ); 
			
			waittillframeend; 
			
			level notify( "first_player_ready", self ); 
		}
	}
	
	// CODER_MOD: Bryce( 05/08/08 ): Useful output for debugging replay system
/#
	if( getdebugdvar( "replay_debug" ) == "1" )
	{
		println( "File: _callbackglobal.gsc. Function: first_player_connect() - COMPLETE\n" ); 
	}
#/
}

menuLoadout( response )
{
//	class = self maps\mp\gametypes\_class::getClassChoice( response ); 
	println( "*************************************** " + response ); 
	
	if( response != "back" )
	{
			self.pers["class"] = response; 
	}
	
	self thread[[level.spawnClient]](); 
}

setSpawnVariables()
{
	resetTimeout(); 

	// Stop shellshock and rumble
	self StopShellshock(); 
	self StopRumble( "damage_heavy" ); 
}

