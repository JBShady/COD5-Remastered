// contains script functions for implementation of collectible host options used in XBox Live Private Matches
#include common_scripts\utility;
#include maps\_utility;


collectibles_checkpoint_restore()
{
	if( !isDefined( level.host_options_dvar ) || !isDefined( level.host_options_enabled_dvar ) )
	{
		return;
	}
		
	host_options = GetDvarInt( level.host_options_dvar );
	host_options_enabled = GetDvarInt( level.host_options_enabled_dvar );

	if ( host_options == 0 || host_options_enabled == 0 )
		return;

	if ( ( host_options & (1 << maps\_collectibles::collectible_get_unlock_value( "collectible_berserker" )) ) != 0 )
	{
		players = get_players();
		for( i = 0; i < players.size; i++)
		{			
			players[i] notify( "berserker_end" );
			
			setClientSysState("levelNotify", "berzerk_audio_off", players[i]);	
			
			if( IsDefined( self.weaponInventory ) )
			{
				has_rocketBarrage = self berserker_player_has_rocketbarrage();	
				self TakeAllWeapons();	
				if( true == has_rocketBarrage )
				{
					self GiveWeapon( "rocket_barrage" );
				}
				
				if( IsDefined( self.weaponInventory ) )
				{
					players[i] berserker_giveback_player_weapons();
				}
			}
			
			players[i] AllowSprint( true );
			players[i] SetMoveSpeedScale( 1.0 );		
			
			players[i] DisableInvulnerability();
			
			players[i] thread berserker_main();
		}
	}
}

vampire_main()
{
	self endon( "disconnect" ); 
	self endon( "death" );
	self endon( "vampire_end" );

	self player_flag_init( "vampire_damage" );

	if ( level.script == "ber3" )
	{
		wait( 45 );
	}
	else
	{
		wait( 30 );
	}
	
	self.maxhealth = Int( self.maxhealth * 1.5 );
	self.vampire_degen_rate = 6;
	
	self thread vampire_regen_damage();
	self thread vampire_regen_kill();

	for ( ;; )
	{
		wait( 1 );

		/#
			if ( GetDvarInt( "scr_health_debug" ) == 2 )
			{
				iprintln( "----\n" );
				iprintln( "Health: " + self.health + "\n" );
				iprintln( "Max Health: " + self.maxhealth + "\n" );
			}
		#/

		// last stand
		if ( self maps\_laststand::player_is_in_laststand() )
			continue;

		lowhealth = self.maxhealth * .10;

		if ( self.health <= lowhealth )
			continue;

		sav = self.maxhealth;
		self.health -= self.vampire_degen_rate;
		self.maxhealth = sav;
		
		self player_flag_set( "vampire_damage" );
	}
}


vampire_regen_health( health )
{
	sav = self.maxhealth;

	if ( ( self.health + health ) > self.maxhealth )
		self.health = self.maxhealth;
	else
		self.health = self.health + health;

	self.maxhealth = sav;
}


vampire_regen_damage()
{
	self endon( "disconnect" ); 
	self endon( "death" );
	self endon( "vampire_end" );

	for ( ;; )
	{
		self waittill( "vampire_health_regen", damage );

		// last stand
		if ( self maps\_laststand::player_is_in_laststand() )
			continue;

		regen = Int( damage / 3 );

		if ( regen < 1 )
			regen = 1;

		vampire_regen_health( regen );
	}
}


vampire_regen_kill()
{
	self endon( "disconnect" ); 
	self endon( "death" );
	self endon( "vampire_end" );

	for ( ;; )
	{
		self waittill( "vampire_kill" );

		// last stand
		if ( self maps\_laststand::player_is_in_laststand() )
			continue;

		vampire_regen_health( 10 );
	}
}


berserker_main( cheat )
{
	self endon( "disconnect" ); 
	self endon( "death" );
	self endon( "berserker_end" );
	
	if ( !IsDefined( cheat ) )
		cheat = false;

	// restore the fov
	self SetClientDvar( "cg_fov", 65 );
	self VisionSetBerserker( 0, 0 );
	self SetClientDvar( "cg_gun_x", "0" );

	self.berserker_kill_streak = 0;

	// CODER_MOD: TommyK (8/5/08)
	self.collectibles_berserker_mode_on = false;
	
	if ( !maps\_collectibles::has_collectible( "collectible_sticksstones" ) )
	{
		self DisableBerserker();
	}

	for ( ;; )
	{
		// wait for kill streak
		if ( cheat == false )
		{
			self waittill( "berserker_kill_streak" );
			assert( self.berserker_kill_streak <= 3 );
			assert( self.berserker_kill_streak > 0 );
			
			// kick off the timer
			if ( self.berserker_kill_streak == 1 )
			{
				self thread berserker_kill_timer();
			}
			
			if ( self.berserker_kill_streak < 3 )
				continue;
		}

		time = 0;
		while( time < 5 && (self getcurrentweapon() == "mortar_round" || self getcurrentweapon() == "satchel_charge_new" || IsDefined(self.disableBerserker) ) )
		{
			time += 0.1;
			wait 0.1;
		}

		if( time >= 5 )
		{
			self.berserker_kill_streak = 0;
			continue;
		}

		// set berserker mode
		self EnableBerserker();
		
		// CODER_MOD: TommyK (8/5/08)
		self.collectibles_berserker_mode_on = true;		

		// run think
		self berserker_think();

		// unset berserker mode
		if ( !maps\_collectibles::has_collectible( "collectible_sticksstones" ) )
		{
			self DisableBerserker();
		}
		
		// CODER_MOD: TommyK (8/5/08)
		self.collectibles_berserker_mode_on = false;
		
		wait( 2 );

		self AllowSprint( true );
		self SetMoveSpeedScale( 1.0 );

		// reset kill streak
		self.berserker_kill_streak = 0;

		if ( cheat == true )
		{
			UnsetCollectible( "collectible_berserker" );
			self notify( "berserker_end" );
		}
	}
}


berserker_kill_timer()
{
	self endon( "disconnect" );
	self endon( "berserker_end" );

	wait( 5 );
	self.berserker_kill_streak = 0;
}


berserker_death()
{
	self waittill( "death", attacker );
	
	if( !IsDefined( self ) )
		return;// deleted

	if( self.team != "axis" )
		return;

	if( !IsDefined( attacker ) )
		return;	

	if( !IsPlayer( attacker ) )
		return;

	if( attacker maps\_laststand::player_is_in_laststand() )
		return;

	// sanity
	if ( !maps\_collectibles::has_collectible( "collectible_berserker" ) )
		return;

	attacker.berserker_kill_streak++;
	attacker notify( "berserker_kill_streak" );
}

berserker_think()
{
	self endon( "disconnect" ); 
	self endon( "death" );

	self AllowSprint( false );
	self SetMoveSpeedScale( 0.75 );
	self EnableInvulnerability();

	self berserker_take_player_weapons();
	self thread berserker_lerp_fov_overtime( 0.5, 85 );

	setClientSysState("levelNotify", "berzerk_audio_on", self);
	
	self VisionSetBerserker( 1, 0.2 );
	wait( 0.2 );
	self VisionSetBerserker( 2, 0.6 );

	pistol = "colt";
	if( IsDefined( level.laststandpistol ) )
		pistol = level.laststandpistol; 
	
	self GiveWeapon( pistol );
	self SwitchToWeapon( pistol );

	self SetClientDvar( "cg_gun_x", "-7" );

	wait( 15 );

	// see if the rocket_barrage was given to the player when they were in berserker mode, 
	// if so, when you remove the weapons, make sure to give it back
	has_rocketBarrage = self berserker_player_has_rocketbarrage();	
	self TakeAllWeapons();	
	if( true == has_rocketBarrage )
	{
		self GiveWeapon( "rocket_barrage" );
	}

	setClientSysState("levelNotify", "berzerk_audio_off", self);

	self VisionSetBerserker( 1, 0.2 );
	wait( 0.2 );
	self VisionSetBerserker( 0, 0 );
	
	self thread berserker_lerp_fov_overtime( 0.5, 65 );
	self berserker_giveback_player_weapons();
	self SetClientDvar( "cg_gun_x", "0" );

	self DisableInvulnerability();
}

berserker_player_has_rocketbarrage()
{
	if( "rocket_barrage" == self GetCurrentWeapon() )
	{
		return true;
	}
	
	weaponInventory = self GetWeaponsList();
	for( i = 0; i < weaponInventory.size; i++ )
	{
		if( "rocket_barrage" == weaponInventory[i] )
		{
			return true;
		}
	}
	
	return false;
}


berserker_lerp_fov_overtime( time, destfov )
{
	basefov = getdvarfloat( "cg_fov" );
	incs = int( time/.05 );
	incfov = (  destfov  -  basefov  ) / incs ;
	currentfov = basefov;
	for ( i = 0; i < incs; i++ )
	{
		currentfov += incfov;
		self setClientDvar( "cg_fov", currentfov );
		wait .05;
	}
	//fix up the little bit of rounding error. not that it matters much .002, heh
	self setClientDvar( "cg_fov", destfov );
}


// self = a player
berserker_take_player_weapons()
{
	self.weaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();
	//ASSERTEX( self.lastActiveWeapon != "none", "Last active weapon is 'none,' an unexpected result." );

	self.weaponAmmo = [];

	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];

		self.weaponAmmo[weapon]["clip"] = self GetWeaponAmmoClip( weapon );
		self.weaponAmmo[weapon]["stock"] = self GetWeaponAmmoStock( weapon );
	}

	self TakeAllWeapons();
}

// self = a player
berserker_giveback_player_weapons()
{
	ASSERTEX( IsDefined( self.weaponInventory ), "player.weaponInventory is not defined - did you run take_player_weapons() first?" );

	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];

		self GiveWeapon( weapon );
		self SetWeaponAmmoClip( weapon, self.weaponAmmo[weapon]["clip"] );
		self SetWeaponAmmoStock( weapon, self.weaponAmmo[weapon]["stock"] );
	}

	// if we can't figure out what the last active weapon was, try to switch a primary weapon
	if( self.lastActiveWeapon != "none" )
	{
		self SwitchToWeapon( self.lastActiveWeapon );
	}
	else
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}
	
	self.weaponInventory = undefined;
}


sticksstones_main()
{
	self endon( "disconnect" ); 
	self endon( "death" );
	self endon( "sticksstones_end" );

	if ( level.script == "see1" )
	{
		wait( 30 );
	}
	else
	{
		wait( 5 );
	}

	//self.maxhealth = self.maxhealth * 2;
	self.health = self.maxhealth;

	for ( ;; )
	{
		if ( self GetCurrentWeapon() == "rocket_barrage" || self GetCurrentWeapon() == "air_support" || self GetCurrentWeapon() == "satchel_charge_new" )
		{
		}
		// for ber3b only. If the player has russian flag in hand he should keep holding it
		else if ( self GetCurrentWeapon() == "russian_flag" )
		{
		}
		else if ( !self maps\_laststand::player_is_in_laststand() )
		{
			// take weapons except the rocket_barrage
			weaponInventory = self GetWeaponsList();
			for( i = 0; i < weaponInventory.size; i++ )
			{
				if ( weaponInventory[i] != "rocket_barrage" && weaponInventory[i] != "air_support" && weaponInventory[i] != "satchel_charge_new" )
					self TakeWeapon( weaponInventory[i] );
			}

			pistol = "colt";
			if( IsDefined( level.laststandpistol ) )
				pistol = level.laststandpistol; 
			
			self GiveWeapon( pistol );
			self SwitchToWeapon( pistol );

			offhand = "fraggrenade";
			self GiveWeapon( offhand );
			self SetWeaponAmmoClip( offhand, 4 );
			self SwitchToOffhand( offhand );

			self EnableBerserker();
		}
		else
		{
			self DisableBerserker();
		}

		self waittill_any( "weapon_change", "player_revived", "player_downed" );
	}
}


zombie_health_regen()
{
	self endon( "death" );

	for ( ;; )
	{
		wait( 1 );

		if ( self.health < self.maxhealth )
		{
			sav = self.maxhealth;
			self.health += 25;
			self.maxhealth = sav;
		}
	}
}


morphine_think()
{
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( self maps\_laststand::player_is_in_laststand() );

	self thread morphine_shot_think();
	self thread morphine_revive_think();
}


morphine_shot_think()
{
	self endon( "disconnect" );
	self endon( "player_revived" );

	while( 1 )
	{
		self waittill( "morphine_shot", attacker );
		self.bleedout_time += 1;
	}
}


morphine_revive_think()
{
	self endon( "disconnect" );
	self endon( "player_revived" );

	while( 1 )
	{
		self waittill( "morphine_revive", attacker );
		self maps\_laststand::revive_force_revive( attacker );
	}
}