// Cleaned Up By: JS (3/30/07)

// 200 participation points are given to the player for killing an enemy
// 800 participation points are taken from the player for killing a friendly
// friendly damage removes points based on amount of damage done and distance
// a max of 1000 points is allowed
// the player will fail the mission when level.friendlyfire["min_participation"] is reached
#include maps\_utility;

// main, called from _load
// self - level
main()
{
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _friendlyfire.gsc. Function: main()\n");
	#/
	
	level.friendlyfire[ "min_participation" ] 	= -1600;		// when the player hit this number of participation points the mission is failed
	level.friendlyfire[ "max_participation" ]	= 1000;		// the player will stop gaining participation points once this amount is earned
	level.friendlyfire[ "enemy_kill_points" ]	= 250;		// this many participation points are earned for killing an enemy
	level.friendlyfire[ "friend_kill_points" ] 	= -600;		// participation point penalty for killing a friendly
	level.friendlyfire[ "point_loss_interval" ] = .75;		// amount of time a point lasts
	
	SetDvar( "friendlyfire_enabled", "1" ); 
	
	// CODER_MOD: Austin (8/8/08): Disable friendly fire for co-op
	if ( coopGame() )
	{
		SetDvar( "friendlyfire_enabled", "0" ); 
	}
	
	level.friendlyFireDisabled = 0;
	
// SCRIPTER_MOD
// MikeD: No more level.player, moved to player_init()
//	thread debug_friendlyfire(); 
//	thread participation_point_flattenovertime(); 

	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _friendlyfire.gsc. Function: main() - COMPLETE\n");
	#/
}
	
// Setup for each player that spawns in, called from _load
// self - player
// SCRIPTER_MOD
// MikeD: No more level.player
player_init()
{
	self.participation = 0; 
	self thread debug_friendlyfire(); 
	self thread participation_point_flattenovertime(); 
}

// Shows debug output for friendly fire
// self - player
debug_friendlyfire()
{
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _friendlyfire.gsc. Function: debug_friendlyfire()\n");
	#/
	
	self endon( "disconnect" ); 
	
	/#
	if( GetDvar( "debug_friendlyfire" ) == "" )
	{
		SetDvar( "debug_friendlyfire", "0" ); 
	}
	
	friendly_fire = NewHudElem(); 
	friendly_fire.alignX = "right";
	friendly_fire.alignY = "middle";
	friendly_fire.x = 620;
	friendly_fire.y = 100;
	friendly_fire.fontScale = 2;
	friendly_fire.alpha = 0;
	
	for (;;)
	{
		// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
		if( getdebugdvar( "replay_debug" ) == "1" )
			println("File: _friendlyfire.gsc. Function: debug_friendlyfire() - INNER LOOP START\n");
		
		if( GetDvar( "debug_friendlyfire" ) == "1" )
		{
			friendly_fire.alpha = 1;
		}
		else
		{
			friendly_fire.alpha = 0;
		}
		
		friendly_fire Setvalue( self.participation ); 
		
		// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
		if( getdebugdvar( "replay_debug" ) == "1" )
			println("File: _friendlyfire.gsc. Function: debug_friendlyfire() - INNER LOOP WAIT\n");
		
		wait( 0.25 ); 
		
		// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
		if( getdebugdvar( "replay_debug" ) == "1" )
			println("File: _friendlyfire.gsc. Function: debug_friendlyfire() - INNER LOOP STOP\n");
	}
	
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _friendlyfire.gsc. Function: debug_friendlyfire() - COMPLLETE\n");
	#/
}

// Every entity that influences friedly fire should run this thread( ai of both teams, vehicles of both teams )
// self 	- level
// entity -	entity to register friendly fire
friendly_fire_think( entity )
{
	if( !IsDefined( entity ) )
	{
		return;
	}
	if( !IsDefined( entity.team ) )
	{
		entity.team = "allies";
	}
	
	// if the mission is failed from another entity running this function then end this one
	level endon( "mission failed" );
	
	// wait( until this entity dies
	level thread notifyDamage( entity );
	level thread notifyDamageNotDone( entity );
	level thread notifyDeath( entity );
	
	for (;;)
	{
		if( !IsDefined( entity ) )
		{
			return;
		}
		if ( entity.health <= 0 )
		{
			return;
		}
		
		entity waittill ( "friendlyfire_notify", damage, attacker, direction, point, method );
		
		//Glocke: 9/9/08 - after talking with MikeD, because the player was doing MOD_UNKNOWN of damage == -1
		if( damage < 1 )
		{
			continue;
		}
		
		if ( !isdefined( entity ) )
			return;

		if ( ( isdefined( entity.NoFriendlyfire ) ) && ( entity.NoFriendlyfire == true ) ) 
			continue;
			
		// if we dont know who the attacker is we can't do much, so ignore it. This is seldom to happen, but not impossible
		if( !IsDefined( attacker ) )
		{
			continue;
		}
		
		// check to see if the death was caused by the player or the players turret
		bPlayersDamage = false;

		if( IsPlayer( attacker ) )
		{
			bPlayersDamage = true;
		}
		else if( ( IsDefined( attacker.classname ) ) &&( attacker.classname == "script_vehicle" ) )
		{
			owner = attacker GetVehicleowner(); 

			if( IsDefined( owner ) && IsPlayer( owner ) )		
			{
				bPlayersDamage = true;

				// DPG 6/4/07 - set the player as the attacker
				attacker = owner;	
				
			}
		}
		
		// if the player didn't cause the damage then disregard
		if ( !bPlayersDamage )
		{
			continue;
		}

		same_team = entity.team == attacker.team;
		killed = damage == -1;
		
		// SCRIPTER_MOD:
		// MikeD( 02/04/07 ): Added this for the _stats.
		// Note: We should put this in the if statement below after we get the last drop from IW.
		if( !same_team )
		{			
			if( killed )
			{
				// The player killed an enemy.
//				attacker maps\_stats::set_enemy_kill( method, entity.damagelocation, entity.origin ); 

// SCRIPTER_MOD
// MikeD( 3/19/2007 ): No more level.player
//				level.player.participation += level.friendlyfire["enemy_kill_points"]; 
				attacker.participation += level.friendlyfire["enemy_kill_points"]; 
				attacker participation_point_cap(); 								
			}
			else
			{
				// The player damaged an enemy.
//				attacker maps\_stats::set_enemy_damage( method, entity.damagelocation ); 
			}

			return;
		}
		else
		{
			//CODER MOD: TKeegan, friendly fire now gives negative points
			
			arcademode_assignpoints( "arcademode_friendies_damage", attacker );
			
			if( killed ) {} //player killed friendly AI
			else {} //player damaged friendly AI
		}

		//player killed/damaged a friendly
		if ( isdefined( entity.no_friendly_fire_penalty ) )
		{		
			continue;
		}
		
// SCRIPTER_MOD
// MikeD( 3/19/2007 ): Removed and put it above, so it's in 1 if statement.
		// if an enemy was killed then incriment the players participation score
//		if( ( entity.team != level.player.team ) &&( damage == -1 ) )
//		{
//			level.player.participation += level.friendlyfire["enemy_kill_points"]; 
//			participation_point_cap(); 
//			return; 
//		}
		
// SCRIPTER_MOD
// MikeD( 3/19/2007 ): No more level.player
		//player killed/damaged a friendly
//		if( entity.team == level.player.team )
		if ( killed )
		{
			attacker.participation += level.friendlyfire["friend_kill_points"];
		}
		else
		{
			// friendly was damaged - figure out how many participation points to remove
			attacker.participation -= damage; 
		}
		
		attacker participation_point_cap(); 
		
		// dont fail the mission if death was caused by a grenade that was cooking durring an autosave
		if ( check_grenade( entity, method ) && savecommit_afterGrenade() )
		{
			if ( killed )
			{
				return;
			}
			else
			{
				continue;
			}
		}
			
// SCRIPTER_MOD
// MikeD( 3/19/2007 ): No more level.player
			// fail the mission if the players participation has reached the minimum
//			friendly_fire_checkpoints(); 
		attacker friendly_fire_checkpoints(); 
	}
}

// fail the mission if the players participation has reached the minimum
// self - player
friendly_fire_checkpoints()
{
	if( self.participation <= level.friendlyfire["min_participation"] )
	{
		// SCRIPTER_MOD
		// JesseS( 3/30/07 ): level.player is now self
		self thread missionfail(); 
	}
}

// check if the entity was killed by a grenade
// self 	- level
// entity - the damaged entity
// method - the damage type
// returns true oe false
check_grenade( entity, method )
{
	if( !IsDefined( entity ) )
	{
		return false;
	}
	
	// check if the entity was killed by a grenade
	wasGrenade = false;
	if( ( IsDefined( entity.damageweapon ) ) &&( entity.damageweapon == "none" ) )
	{
		wasGrenade = true;
	}
	if( ( IsDefined( method ) ) &&( method == "MOD_GRENADE_SPLASH" ) )
	{
		wasGrenade = true;
	}
	
	// if the entity was not killed by a grenade then exit
	return wasGrenade;
}

// Fixes any problems caused by saving after throwing a grenade
// self - level
// returns true or false
savecommit_afterGrenade()
{
	currentTime = GetTime(); 
	if ( currentTime < 4500 )
	{
		println( "^3aborting friendly fire because the level just loaded and saved and could cause a autosave grenade loop" );
		return true;
	}
	else if( ( currentTime - level.lastAutoSaveTime ) < 4500 )
	{
		println( "^3aborting friendly fire because it could be caused by an autosave grenade loop" );
		return true;
	}
	return false;
}

// Caps participation points to either the max or min
// self - player
participation_point_cap()
{
// SCRIPTER_MOD
// MikeD( 3/19/2007 ): No more level.player
//	if( level.player.participation > level.friendlyfire["max_participation"] )
//	{
//		level.player.participation = level.friendlyfire["max_participation"]; 
//	}
//	if( level.player.participation < level.friendlyfire["min_participation"] )
//	{
//		level.player.participation = level.friendlyfire["min_participation"]; 
//	}


	// DPG 6/4/07 self.participation will not be defined if in a tank. need to fix this up...
	if( !isdefined( self.participation ) )
	{
		assertmsg( "self.participation is not defined!" );
		return;	
}

	if( self.participation > level.friendlyfire["max_participation"] )
	{
		self.participation = level.friendlyfire["max_participation"]; 
	}

	if( self.participation < level.friendlyfire["min_participation"] )
	{
		self.participation = level.friendlyfire["min_participation"]; 
	}
}

// Evens out FF participation points over time
// self - player
participation_point_flattenOverTime()
{
	level endon( "mission failed" );
	self endon( "disconnect");
	for (;;)
	{
		if( self.participation > 0 )
		{
			self.participation--; 
		}
		else if( self.participation < 0 )
		{
			self.participation++; 
		}

		wait( level.friendlyfire["point_loss_interval"] ); 
	}
}

TurnBackOn()
{
	level.friendlyFireDisabled = 0;
}


TurnOff()
{
	level.friendlyFireDisabled = 1;
}


missionfail()
{
	if( GetDvar( "friendlyfire_enabled" ) != "1" )
	{
		if ( !maps\_collectibles::has_collectible( "collectible_hardcore" ) )
		{
			return;
		}
	}
	
	// SCRIPTER_MOD
	// JesseS( 3/30/07 ): removed level.player ref
	// TODO: Update these notifies to support co-op better
	self endon( "death" ); 
	level endon ( "mine death" );
	level notify ( "mission failed" );
	
	if ( level.campaign == "british" )
	{
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_BRITISH" ); 
	}
	else if ( level.campaign == "russian" )
	{
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_RUSSIAN" ); 
	}
	else
	{
		SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_AMERICAN" ); 
	}

	// shader if specified
	if ( isdefined( level.custom_friendly_fire_shader ) )
		thread maps\_load::special_death_indicator_hudelement( level.custom_friendly_fire_shader, 64, 64, 0 );
	
	logString( "failed mission: Friendly fire" );
	
	maps\_utility::missionFailedWrapper();
}

// Sends outs "friendlyfire_notify" upon FF damage
// self 	- level
// entity - entity to send / recieve notify 	
notifyDamage( entity )
{
	level endon( "mission failed" );
	entity endon( "death" );
	for (;;)
	{
		entity waittill( "damage", damage, attacker, direction, point, method );
		entity notify( "friendlyfire_notify", damage, attacker, direction, point, method );
	}
}

notifyDamageNotDone( entity )
{
	level endon( "mission failed" );
	entity waittill( "damage_notdone", damage, attacker, direction, point, method );
	entity notify( "friendlyfire_notify", -1, attacker, undefined, undefined, method );
}

// Sends outs "friendlyfire_notify" upon FF death
// self 	- level
// entity - entity to send / recieve notify 	
notifyDeath( entity )
{
	level endon( "mission failed" );
	entity waittill( "death" , attacker, method );
	entity notify( "friendlyfire_notify", -1, attacker, undefined, undefined, method );
}