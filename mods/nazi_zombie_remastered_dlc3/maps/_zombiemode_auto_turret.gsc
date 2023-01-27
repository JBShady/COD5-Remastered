#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	level.auto_turret_array = GetEntArray( "auto_turret_trigger", "script_noteworthy" );
	
	if( !isDefined( level.auto_turret_array ) )
	{
		return;
	}
	
	level.curr_auto_turrets_active = 0;
	
	if( !isDefined( level.max_auto_turrets_active ) )
	{
		level.max_auto_turrets_active = 2;
	}
	
	if( !isDefined( level.auto_turret_cost ) )
	{
		level.auto_turret_cost = 1500;
	}
	
	if( !isDefined( level.auto_turret_timeout ) )
	{
		level.auto_turret_timeout = 30;
	}
	
	for( i = 0; i < level.auto_turret_array.size; i++ )
	{
		level.auto_turret_array[i].curr_time = -1;
		level.auto_turret_array[i].turret_active = false;
		level.auto_turret_array[i] thread auto_turret_think();
	}
}

auto_turret_think()
{
	if( !isDefined( self.target ) )
	{
		return;
	}
	
	self.turret = GetEnt( self.target, "targetname" );
	
	if( !isDefined( self.turret ) )
	{
		return;
	}
	
	self.turret SetTurretTeam( "allies" );
	self.turret MakeTurretUnusable();
	
	for( ;; )
	{
		cost = level.auto_turret_cost;
		self SetHintString( &"ZOMBIE_AUTO_TURRET", cost );
		self SetCursorHint( "HINT_NOICON" );
		
		self waittill( "trigger", player );
		index = maps\_zombiemode_weapons::get_player_index(player);

		if (player maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if(player in_revive_trigger())
		{
			continue;
		}

		if ( player.score < cost )
		{
			//player iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("deny");
			player thread play_no_money_turret_dialog();
			continue;
		}

		player maps\_zombiemode_score::minus_to_player_score( cost ); 
		
		self thread auto_turret_activate();
		
		self disable_trigger();
		
		self waittill( "turret_deactivated" );
		
		self enable_trigger();
	}
}

play_no_money_turret_dialog()
{
	
}

auto_turret_activate()
{
	self endon( "turret_deactivated" );
	
	if( level.max_auto_turrets_active <= 0 )
	{
		return;
	}
	
	while( level.curr_auto_turrets_active >= level.max_auto_turrets_active ) 
	{
		worst_turret = undefined;
		worst_turret_time = -1;
		for( i = 0; i < level.auto_turret_array.size; i++ )
		{
			if( level.auto_turret_array[i] == self )
			{
				continue;
			}
			
			if( !level.auto_turret_array[i].turret_active )
			{
				continue;
			}
			
			if( worst_turret_time < 0 || level.auto_turret_array[i].curr_time < worst_turret_time )
			{
				worst_turret = level.auto_turret_array[i];
				worst_turret_time = level.auto_turret_array[i].curr_time;
			}
		}
		if( isDefined( worst_turret ) )
		{
			worst_turret auto_turret_deactivate();
		}
		else
		{
			assertex( false, "Couldn't free an auto turret to activate another, this should never be the case" );
		}
	}

	self.turret SetMode( "auto_nonai" );
	self.turret thread maps\_mgturret::burst_fire_unmanned();
	self.turret_active = true;
	self.curr_time = level.auto_turret_timeout;
	
	self thread auto_turret_update_timeout();
	
	wait( level.auto_turret_timeout );
	
	self auto_turret_deactivate();
}

auto_turret_deactivate()
{
	self.turret_active = false;
	self.curr_time = -1;
	self.turret SetMode( "manual" );
	self.turret notify( "stop_burst_fire_unmanned" );
	
	self notify( "turret_deactivated" );
}

auto_turret_update_timeout()
{
	self endon( "turret_deactivated" );
	
	while( self.curr_time > 0 )
	{
		wait( 1 );
		self.curr_time--;
	}
}