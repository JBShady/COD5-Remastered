#include maps\_utility; 
#include maps\_zombiemode_net;
#include common_scripts\utility; 
#include maps\_zombiemode_utility;

#using_animtree( "generic_human" );

init()
{
	if( !tesla_gun_exists() )
	{
		return;
	}

	level._effect[ "tesla_bolt" ] = loadfx( "maps/zombie/fx_zombie_tesla_bolt_secondary" );
	level._effect[ "tesla_shock" ] = loadfx( "maps/zombie/fx_zombie_tesla_shock" );
	level._effect[ "tesla_shock_eyes" ] = loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );
	level._effect[ "tesla_viewmodel_rail" ] = loadfx( "maps/zombie/fx_zombie_tesla_rail_view" );
	level._effect[ "tesla_viewmodel_tube" ] = loadfx( "maps/zombie/fx_zombie_tesla_tube_view" );
	level._effect[ "tesla_viewmodel_tube2" ] = loadfx( "maps/zombie/fx_zombie_tesla_tube_view2" );
	level._effect[ "tesla_viewmodel_tube3" ] = loadfx( "maps/zombie/fx_zombie_tesla_tube_view3" );
	level._effect[ "tesla_shock_secondary" ] = loadfx( "maps/zombie/fx_zombie_tesla_shock_secondary" );
	level._effect[ "tesla_viewmodel_rail_upgraded" ] = loadfx( "maps/zombie/fx_zombie_tesla_rail_view_ug" );
	level._effect[ "tesla_viewmodel_tube_upgraded" ] = loadfx( "maps/zombie/fx_zombie_tesla_tube_view_ug" );
	level._effect[ "tesla_viewmodel_tube2_upgraded" ] = loadfx( "maps/zombie/fx_zombie_tesla_tube_view2_ug" );
	level._effect[ "tesla_viewmodel_tube3_upgraded" ] = loadfx( "maps/zombie/fx_zombie_tesla_tube_view3_ug" );

	precacheshellshock( "electrocution" );
	
	if( !isdefined( level.boss_tesla_damage ) )
	{
		level.boss_tesla_damage = 1000;
	}

	set_zombie_var( "tesla_max_arcs", 5 );
	set_zombie_var( "tesla_radius_decay", 20 );
	set_zombie_var( "tesla_radius_start", 300 );
	set_zombie_var( "tesla_head_gib_chance", 50 );
	set_zombie_var( "tesla_min_fx_distance", 128 );
	set_zombie_var( "tesla_kills_for_powerup", 15 );
	set_zombie_var( "tesla_max_enemies_killed", 12 );
	set_zombie_var( "tesla_network_death_choke", 4 );
	set_zombie_var( "tesla_max_enemies_killed_upgraded", 24 );
	set_zombie_var( "tesla_arc_travel_time", 0.5, undefined, true );

	level thread on_player_connect(); 
}

tesla_damage_init( hit_location, hit_origin, player )
{
	player endon( "disconnect" );

	// Make sure the closest zombie from the hit origin is the one that initially gets hit
	zombs_hit = [];
	zombs = GetAISpeciesArray( "axis" );
	for( i = 0; i < zombs.size; i++ )
	{
		if( isdefined( zombs[i].attacker ) && zombs[i].attacker == player )
		{
			if( isdefined( zombs[i].damageweapon ) && ( zombs[i].damageweapon == "zap_gun" || zombs[i].damageweapon == "zap_gun_upgraded" || zombs[i].damageweapon == "zapgun_dw" || zombs[i].damageweapon == "zapgun_dw_upgraded" || zombs[i].damageweapon == "tesla_gun" || zombs[i].damageweapon == "tesla_gun_upgraded" || zombs[i].damageweapon == "tesla_gun_powerup" || zombs[i].damageweapon == "tesla_gun_powerup_upgraded" ) )
			{
				if( !is_true( zombs[i].zombie_tesla_hit ) && !is_true( zombs[i].humangun_zombie_1st_hit_response ) )
				{
					zombs_hit[ zombs_hit.size ] = zombs[i];
				}
			}
		}
	}
	
	if( zombs_hit.size == 0 )
	{
		return;
	}

	closest_zomb = getclosest( hit_origin, zombs_hit );
	if( self != closest_zomb )
	{
		return;
	}

	if( isdefined( self.zombie_tesla_hit ) && self.zombie_tesla_hit )
	{
		// can happen if an enemy is marked for tesla death and player hits again with the tesla gun
		return;
	}

	if( isdefined( player.tesla_enemies_hit ) && player.tesla_enemies_hit > 0 )
	{
		debug_print( "TESLA: Player: '" + player.playername + "' currently processing tesla damage" );
		return;
	}

	debug_print( "TESLA: Player: '" + player.playername + "' hit with the tesla gun" );

	// TO DO Add Tesla Kill Dialog thread....
	player.tesla_arc_count = 0;
	player.tesla_enemies_hit = 1;
	player.tesla_enemies = undefined;
	player.tesla_powerup_dropped = false;
	
	upgraded = ( self.damageweapon == "tesla_gun_upgraded" || self.damageweapon == "zap_gun_upgraded" || self.damageweapon == "zapgun_dw_upgraded" || self.damageweapon == "tesla_gun_powerup_upgraded" );

	self tesla_arc_damage( self, player, 1, upgraded );
	
	if( player.tesla_enemies_hit >= 4 )
	{
		player thread tesla_killstreak_sound();
	}

	player.tesla_enemies_hit = 0;
}

// this enemy is in the range of the source_enemy's tesla effect
tesla_arc_damage( source_enemy, player, arc_num, upgraded )
{
	player endon( "disconnect" );

	debug_print( "TESLA: Evaulating arc damage for arc: " + arc_num + " Current enemies hit: " + player.tesla_enemies_hit );

	tesla_flag_hit( self, true );
	
	wait_network_frame();

	radius_decay = level.zombie_vars[ "tesla_radius_decay" ] * arc_num;
	enemies = tesla_get_enemies_in_area( self GetCentroid(), level.zombie_vars[ "tesla_radius_start" ] - radius_decay, player );

	tesla_flag_hit( enemies, true );

	self thread tesla_do_damage( source_enemy, arc_num, player, upgraded );

	debug_print( "TESLA: " + enemies.size + " enemies hit during arc: " + arc_num );
			
	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] == self )
		{
			continue;
		}
		
		if( tesla_end_arc_damage( arc_num + 1, player.tesla_enemies_hit, upgraded ) )
		{			
			tesla_flag_hit( enemies[i], false );
			continue;
		}

		player.tesla_enemies_hit++;
		enemies[i] tesla_arc_damage( self, player, arc_num + 1, upgraded );
	}
}

tesla_end_arc_damage( arc_num, enemies_hit_num, upgraded )
{
	if( arc_num >= level.zombie_vars[ "tesla_max_arcs" ] )
	{
		// TO DO Play Super Happy Tesla sound
		debug_print( "TESLA: Ending arcing. Max arcs hit" );
		return true;
	}

	max = level.zombie_vars[ "tesla_max_enemies_killed" ];
	if( upgraded )
	{
		max = level.zombie_vars[ "tesla_max_enemies_killed_upgraded" ];
	}

	if( enemies_hit_num >= max )
	{
		debug_print( "TESLA: Ending arcing. Max enemies killed" );		
		return true;
	}

	radius_decay = level.zombie_vars[ "tesla_radius_decay" ] * arc_num;
	if( level.zombie_vars[ "tesla_radius_start" ] - radius_decay <= 0 )
	{
		debug_print( "TESLA: Ending arcing. Radius is less or equal to zero" );
		return true;
	}

	// TO DO play Tesla Missed sound (sad)
	return false;
}

tesla_get_enemies_in_area( origin, distance, player )
{
	/#
		level thread tesla_debug_arc( origin, distance );
	#/
	
	enemies = [];
	distance_squared = distance * distance;
	if( !isdefined( player.tesla_enemies ) )
	{
		player.tesla_enemies = GetAISpeciesArray( "axis", "all" );
		player.tesla_enemies = get_array_of_closest( origin, player.tesla_enemies );
	}

	zombies = player.tesla_enemies; 

	if( isdefined( zombies ) )
	{
		for( i = 0; i < zombies.size; i++ )
		{
			if( !isdefined( zombies[i] ) )
			{
				continue;
			}

			test_origin = zombies[i] GetCentroid();
			if( !isdefined( test_origin ) )
			{
				test_origin = zombies[i].origin;
			}

			if( is_magic_bullet_shield_enabled( zombies[i] ) )
			{
				continue;
			}

			if( DistanceSquared( origin, test_origin ) > distance_squared )
			{
				continue;
			}

			if( isdefined( zombies[i].zombie_tesla_hit ) && zombies[i].zombie_tesla_hit == true )
			{
				continue;
			}

			if( isdefined( zombies[i].lightning_chain_immune ) && zombies[i].lightning_chain_immune )
			{
				continue;
			}

			if( isdefined( zombies[i].humangun_zombie_1st_hit_response ) && zombies[i].humangun_zombie_1st_hit_response )
			{
				continue;
			}

			if( !zombies[i] DamageConeTrace( origin, player ) && !BulletTracePassed( origin, test_origin, false, undefined ) && !SightTracePassed( origin, test_origin, false, undefined ) )
			{
				continue;
			}

			enemies[ enemies.size ] = zombies[i];
		}
	}

	return enemies;
}

tesla_flag_hit( enemy, hit )
{
	if( isdefined( enemy ) )
	{
		if( IsArray( enemy ) )
		{
			for( i = 0; i < enemy.size; i++ )
			{
				if( isdefined( enemy[i] ) )
				{
					enemy[i].zombie_tesla_hit = hit;
				}
			}
		}
		else if( isdefined( enemy ) )
		{
			enemy.zombie_tesla_hit = hit;
		}
	}
}

tesla_do_damage( source_enemy, arc_num, player, upgraded )
{
	player endon( "disconnect" );

	if( arc_num > 1 )
	{
		time = RandomFloat( 0.2, 0.6 ) * arc_num;
		if( upgraded )
		{
			time /= 1.5;
		}

		wait time;
	}

	if( !isdefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	if( !self enemy_is_dog() )
	{
		if( self.has_legs )
		{
			self.deathanim = random( level._zombie_tesla_death[self.animname] );
		}
		else
		{
			self.deathanim = random( level._zombie_tesla_crawl_death[self.animname] );
		}
	}
	else
	{
		self.a.nodeath = undefined;
	}

	if( isdefined( self.is_traversing ) && self.is_traversing )
	{
		self.deathanim = undefined;
	}

	if( source_enemy != self )
	{
		if( player.tesla_arc_count > 3 )
		{
			wait_network_frame();
			player.tesla_arc_count = 0;
		}
		
		player.tesla_arc_count++;
		source_enemy tesla_play_arc_fx( self );
	}

	while( player.tesla_network_death_choke > level.zombie_vars["tesla_network_death_choke"] )
	{
		debug_print( "TESLA: Choking Tesla Damage. Dead enemies this network frame: " + player.tesla_network_death_choke );		
		wait( 0.05 ); 
	}

	if( !isdefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	player.tesla_network_death_choke++;

	self.tesla_death = true;
	self tesla_play_death_fx( arc_num );
	
	// use the origin of the arc orginator so it pics the correct death direction anim
	origin = source_enemy.origin;
	if( source_enemy == self || !isdefined( origin ) )
	{
		origin = player.origin;
	}

	if( !isdefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}
	
	if( isdefined( self.tesla_damage_func ) )
	{
		self [[ self.tesla_damage_func ]]( origin, player );
		return;
	}
	else if( isdefined( self.boss_enemy ) && self.boss_enemy )
	{
		self.zombie_tesla_hit = false;
		self DoDamage( 750, origin, player );
		return;
	}
	else if( isdefined( self.animname ) && self.animname == "boss_zombie" )
	{
		self.zombie_tesla_hit = false;
		self DoDamage( level.boss_tesla_damage, origin, player );
		return;
	}
	else
	{
		self DoDamage( self.health + 666, origin, player );
	}
	
	self.handle_death_notetracks = ::tesla_handle_death_notetracks;

	if( !isdefined( self.deathpoints_already_given ) && self.deathpoints_already_given && !self enemy_is_dog() )
	{
		self.deathpoints_already_given = 1;
		player maps\_zombiemode_score::player_add_points( "death", "", "" );
	}

	if( !player.tesla_powerup_dropped && player.tesla_enemies_hit >= level.zombie_vars[ "tesla_kills_for_powerup" ] )
	{
		player.tesla_powerup_dropped = true;
		level.zombie_vars[ "zombie_drop_item" ] = 1;
		level thread maps\_zombiemode_powerups::powerup_drop( self.origin );
	}
}

tesla_handle_death_notetracks( note )
{
	if( note == "elec_vocals_tesla" )
	{
		self PlaySound( "elec_vocals_tesla" );
	}
}

tesla_play_death_fx( arc_num )
{
	fx = "tesla_shock";
	tag = "j_spineupper";
	if( self enemy_is_dog() )
	{
		tag = "j_spine1";
	}

	if( arc_num > 1 )
	{
		fx = "tesla_shock_secondary";
	}

	self PlaySound( "imp_tesla" );
	level thread play_elec_vox( self.origin );
	PlayFXOnTag( level._effect[ fx ], self, tag );
	network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[ fx ], self, tag );

	if( isdefined( self.tesla_head_gib_func ) && !self.head_gibbed && ( !isdefined( self.no_gib ) && self.no_gib ) )
	{
		[[ self.tesla_head_gib_func ]]();
	}
	else if( !self enemy_is_dog() && "quad_zombie" != self.animname && "boss_zombie" != self.animname && !self.head_gibbed && ( !isdefined( self.no_gib ) && self.no_gib ) )
	{
		if( RandomInt( 100 ) < level.zombie_vars[ "tesla_head_gib_chance" ] )
		{
			wait( RandomFloat( 0.53, 1.0 ) );
			self maps\_zombiemode_spawner::zombie_head_gib();
		}
		else
		{
			PlayFXOnTag( level._effect[ "tesla_shock_eyes" ], self, "J_Eyeball_LE" );		
			network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[ "tesla_shock_eyes" ], self, "J_Eyeball_LE" );
		}
	}
}

play_elec_vox_choke()
{
	while( 1 )
	{
		level._num_tesla_elec_vox = 0;
		wait_network_frame();
		wait_network_frame();
	}
}

play_elec_vox( origin )
{
	if( !isdefined( level._num_tesla_elec_vox ) )
	{
		level thread play_elec_vox_choke();
	}
	
	wait( RandomFloatRange( 0, 0.2 ) );
	
	// DSL - Choking these to a max of 1 per network frame.
	while( level._num_tesla_elec_vox > 0 )
	{
		wait_network_frame();
	}
	
	level._num_tesla_elec_vox++;
	
	PlaySoundAtPosition( "elec_vocals_tesla", origin );
		
	org = Spawn( "script_origin", origin );
	org PlaySound( "elec_vocals_tesla", "sound_complete" );
	org waittill( "sound_complete" );
	org Delete();
}

tesla_play_arc_fx( target )
{
	if( !isdefined( self ) || !isdefined( target ) )
	{
		// TODO: can happen on dog exploding death
		wait( level.zombie_vars[ "tesla_arc_travel_time" ] );
		return;
	}
	
	tag = "j_spineupper";
	if( self enemy_is_dog() )
	{
		tag = "j_spine1";
	}

	target_tag = "j_spineupper";
	if( target enemy_is_dog() )
	{
		target_tag = "j_spine1";
	}
	
	origin = self GetTagOrigin( tag );
	target_origin = target GetTagOrigin( target_tag );
	distance_squared = level.zombie_vars[ "tesla_min_fx_distance" ] * level.zombie_vars[ "tesla_min_fx_distance" ];

	if( DistanceSquared( origin, target_origin ) < distance_squared )
	{
		debug_print( "TESLA: Not playing arcing FX. Enemies too close." );		
		return;
	}
	
	fxorg = Spawn( "script_model", origin );
	fxorg SetModel( "tag_origin" );

	PlaySoundAtPosition( "tesla_bounce", fxorg.origin );
	fx = PlayFXOnTag( level._effect[ "tesla_bolt" ], fxorg, "tag_origin" );	
	fxorg MoveTo( target_origin, level.zombie_vars[ "tesla_arc_travel_time" ] );
	fxorg waittill( "movedone" );
	fxorg Delete();
}

tesla_gun_exists()
{
	return isdefined( level.zombie_weapons[ "tesla_gun" ] );
}

tesla_debug_arc( origin, distance )
{
/#
	if( GetDvarInt( "zombie_debug" ) != 3 )
	{
		return;
	}

	start = GetTime();

	while( GetTime() < start + 3000 )
	{
		drawcylinder( origin, distance, 1 );
		wait( 0.05 ); 
	}
#/
}

is_tesla_damage( mod )
{
	return ( ( isdefined( self.damageweapon ) && ( self.damageweapon == "zap_gun" || self.damageweapon == "zap_gun_upgraded" || self.damageweapon == "zapgun_dw" || self.damageweapon == "zapgun_dw_upgraded" || self.damageweapon == "tesla_gun" || self.damageweapon == "tesla_gun_upgraded" || self.damageweapon == "tesla_gun_powerup" || self.damageweapon == "tesla_gun_powerup_upgraded" ) ) && ( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" || mod == "MOD_PISTOL_BULLET" || mod == "MOD_RIFLE_BULLET" ) );
}

enemy_killed_by_tesla()
{
	return ( isdefined( self.tesla_death ) && self.tesla_death == true ); 
}

on_player_connect()
{
	for( ;; )
	{
		level waittill( "connecting", player ); 
		player thread tesla_pvp_thread();
		player thread tesla_sound_thread(); 
		player thread tesla_network_choke();
	}
}

tesla_sound_thread()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 

	for( ;; )
	{
		result = self waittill_any_return( "grenade_fire", "death", "player_downed", "weapon_change", "grenade_pullback" );		

		if( !isdefined( result ) )
		{
			continue;
		}

		if( ( result == "weapon_change" || result == "grenade_fire" ) && self GetCurrentWeapon() == "zap_gun" || self GetCurrentWeapon() == "zap_gun_upgraded" || self GetCurrentWeapon() == "tesla_gun" || self GetCurrentWeapon() == "tesla_gun_upgraded" || self GetCurrentWeapon() == "tesla_gun_powerup" || self GetCurrentWeapon() == "tesla_gun_powerup_upgraded" )
		{
			self thread tesla_engine_sweets();
			self PlayLoopSound( "tesla_idle", 0.25 );
		}
		else
		{
			self notify( "weap_away" );
			self StopLoopSound( 0.25 );
		}
	}
}

tesla_engine_sweets()
{

	self endon( "weap_away" );
	self endon( "disconnect" ); 

	while( 1 )
	{
		wait( RandomIntRange( 7, 15 ) );
		self play_tesla_sound( "tesla_sweeps_idle" );
	}
}

tesla_pvp_thread()
{
	self endon( "death" );
	self endon( "disconnect" );

	self waittill( "spawned_player" ); 

	for( ;; )
	{
		self waittill( "weapon_pvp_attack", attacker, weapon, damage, mod );

		if( self maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if( mod != "MOD_PROJECTILE" && mod != "MOD_PROJECTILE_SPLASH" )
		{
			continue;
		}

		if( weapon != "zap_gun" && weapon != "zap_gun_upgraded" && weapon != "zapgun_dw" && weapon != "zapgun_dw_upgraded" && weapon != "tesla_gun" && weapon != "tesla_gun_upgraded" && weapon != "tesla_gun_powerup" && weapon != "tesla_gun_powerup_upgraded" )
		{
			continue;
		}
/*
		if( self == attacker )
		{
			damage = Int( self.maxhealth * .25 );
			if( damage < 25 )
			{
				damage = 25;
			}

			if( self.health - damage < 1 )
			{
				self.health = 1;
			}
			else
			{
				self.health -= damage;
			}
		}
*/
		self SetElectrified( 1.0 );	
		self PlaySound( "tesla_bounce" );
		self ShellShock( "electrocution", 1.0 );
	}
}

play_tesla_sound( emotion )
{
	self endon( "disconnect" );

	if( !isdefined( level.one_emo_at_a_time ) )
	{
		level.one_emo_at_a_time = 0;
		level.var_counter = 0;	
	}
	
	if( level.one_emo_at_a_time == 0 )
	{
		level.var_counter ++;
		level.one_emo_at_a_time = 1;
		org = Spawn( "script_origin", self.origin );
		org LinkTo( self );
		org PlaySound( emotion, "sound_complete" + "_" + level.var_counter );
		org waittill( "sound_complete" + "_" + level.var_counter );
		org Delete();
		level.one_emo_at_a_time = 0;
	}		
}

tesla_killstreak_sound()
{
	self endon( "disconnect" );

	// TUEY Play some dialog if you kick ass with the Tesla gun
	index = maps\_zombiemode_weapons::get_player_index( self );
	plr = "plr_" + index + "_";
	self thread maps\_zombiemode_spawner::play_tesla_dialog( plr );	
	wait( 3.5 );
	level clientnotify( "TGH" );
	self thread play_tesla_sound( "tesla_happy" );
}

tesla_network_choke()
{
	self endon( "death" );
	self endon( "disconnect" );

	self waittill( "spawned_player" ); 

	self.tesla_network_death_choke = 0;

	for( ;; )
	{
		wait_network_frame();
		wait_network_frame();
		self.tesla_network_death_choke = 0;
	}
}

