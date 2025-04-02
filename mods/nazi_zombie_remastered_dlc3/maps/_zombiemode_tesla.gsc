#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
#include maps\_zombiemode_net;

#using_animtree( "generic_human" );

init()
{
	if( !tesla_gun_exists() )
	{
		return;
	}

	level._effect["tesla_bolt"]				= loadfx( "maps/zombie/fx_zombie_tesla_bolt_secondary" );
	level._effect["tesla_shock"]			= loadfx( "maps/zombie/fx_zombie_tesla_shock" );
	level._effect["tesla_shock_secondary"]	= loadfx( "maps/zombie/fx_zombie_tesla_shock_secondary" );

	level._effect["tesla_viewmodel_rail"]	= loadfx( "maps/zombie/fx_zombie_tesla_rail_view" );
	level._effect["tesla_viewmodel_tube"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view" );
	level._effect["tesla_viewmodel_tube2"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view2" );
	level._effect["tesla_viewmodel_tube3"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view3" );
	level._effect["tesla_viewmodel_rail_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_rail_view_ug" );
	level._effect["tesla_viewmodel_tube_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view_ug" );
	level._effect["tesla_viewmodel_tube2_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view2_ug" );
	level._effect["tesla_viewmodel_tube3_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view3_ug" );

	level._effect["tesla_shock_eyes"]		= loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );

	precacheshellshock( "electrocution" );
	
	set_zombie_var( "tesla_max_arcs",			5 );
	set_zombie_var( "tesla_max_enemies_killed", 10 );
	set_zombie_var( "tesla_max_enemies_killed_upgraded", 12 );
	set_zombie_var( "tesla_radius_start",		300 );
	set_zombie_var( "tesla_radius_decay",		20 );
	set_zombie_var( "tesla_head_gib_chance",	50 );
	set_zombie_var( "tesla_arc_travel_time",	0.5, undefined, true );
	set_zombie_var( "tesla_kills_for_powerup",	10 );
	set_zombie_var( "tesla_min_fx_distance",	128 );
	set_zombie_var( "tesla_network_death_choke",4 );

	level thread on_player_connect(); 
}


tesla_damage_init( hit_location, hit_origin, player )
{
	player endon( "disconnect" );

	if ( IsDefined( player.tesla_enemies_hit ) && player.tesla_enemies_hit > 0 )
	{
		debug_print( "TESLA: Player: '" + player.playername + "' currently processing tesla damage" );
		return;
	}

	if( IsDefined( self.zombie_tesla_hit ) && self.zombie_tesla_hit )
	{
		// can happen if an enemy is marked for tesla death and player hits again with the tesla gun
		return;
	}

	debug_print( "TESLA: Player: '" + player.playername + "' hit with the tesla gun" );

	//TO DO Add Tesla Kill Dialog thread....
	
	player.tesla_enemies = undefined;
	player.tesla_enemies_hit = 1;
	player.tesla_powerup_dropped = false;
	player.tesla_arc_count = 0;
	
	upgraded_status = (self.damageweapon == "tesla_gun_upgraded" );

	self tesla_arc_damage( self, player, 1, upgraded_status );
	
	if( player.tesla_enemies_hit >= 4)
	{
		player thread tesla_killstreak_sound();
	}
	if( player.tesla_enemies_hit >= 10 && isDefined(level.teleporters_are_broken) && level.teleporters_are_broken == true )
	{
		level notify("tesla_damage", player, self); // for egg
	}
	player.tesla_enemies_hit = 0;
}


// this enemy is in the range of the source_enemy's tesla effect
tesla_arc_damage( source_enemy, player, arc_num, upgraded_status )
{
	player endon( "disconnect" );

	debug_print( "TESLA: Evaulating arc damage for arc: " + arc_num + " Current enemies hit: " + player.tesla_enemies_hit );

	tesla_flag_hit( self, true );
	wait_network_frame();
	self thread tesla_do_damage( source_enemy, arc_num, player, upgraded_status );

	radius_decay = level.zombie_vars["tesla_radius_decay"] * arc_num;
	enemies = tesla_get_enemies_in_area( self GetTagOrigin( "j_head" ), level.zombie_vars["tesla_radius_start"] - radius_decay, player );
	tesla_flag_hit( enemies, true );

	debug_print( "TESLA: " + enemies.size + " enemies hit during arc: " + arc_num );
			
	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] == self )
		{
			continue;
		}
		
		if ( tesla_end_arc_damage( arc_num + 1, player.tesla_enemies_hit, upgraded_status ) )
		{			
			tesla_flag_hit( enemies[i], false );
			continue;
		}

		player.tesla_enemies_hit++;
		enemies[i] tesla_arc_damage( self, player, arc_num + 1, upgraded_status );
	}
}


tesla_end_arc_damage( arc_num, enemies_hit_num, upgraded_status )
{
	if ( arc_num >= level.zombie_vars["tesla_max_arcs"] )
	{
		debug_print( "TESLA: Ending arcing. Max arcs hit" );
		return true;
		//TO DO Play Super Happy Tesla sound
	}

	max = level.zombie_vars["tesla_max_enemies_killed"];
	if(upgraded_status)
	{
		max = level.zombie_vars["tesla_max_enemies_killed_upgraded"];
	}
	
	if ( enemies_hit_num >= max )
	{
		debug_print( "TESLA: Ending arcing. Max enemies killed" );
		return true;
	}

	radius_decay = level.zombie_vars["tesla_radius_decay"] * arc_num;
	if ( level.zombie_vars["tesla_radius_start"] - radius_decay <= 0 )
	{
		debug_print( "TESLA: Ending arcing. Radius is less or equal to zero" );
		return true;
	}

	return false;
	//TO DO play Tesla Missed sound (sad)
}


tesla_get_enemies_in_area( origin, distance, player )
{
	/#
		level thread tesla_debug_arc( origin, distance );
	#/
	
	distance_squared = distance * distance;
	enemies = [];

	if ( !IsDefined( player.tesla_enemies ) )
	{
		player.tesla_enemies = GetAiSpeciesArray( "axis", "all" );
		player.tesla_enemies = get_array_of_closest( origin, player.tesla_enemies );
	}

	zombies = player.tesla_enemies; 

	if ( IsDefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( !IsDefined( zombies[i] ) )
			{
				continue;
			}

			test_origin = zombies[i] GetTagOrigin( "j_head" );

			if ( IsDefined( zombies[i].zombie_tesla_hit ) && zombies[i].zombie_tesla_hit == true )
			{
				continue;
			}

			if ( is_magic_bullet_shield_enabled( zombies[i] ) )
			{
				continue;
			}

			if ( DistanceSquared( origin, test_origin ) > distance_squared )
			{
				continue;
			}

			if ( !BulletTracePassed( origin, test_origin, false, undefined ) )
			{
				continue;
			}

			enemies[enemies.size] = zombies[i];
		}
	}

	return enemies;
}


tesla_flag_hit( enemy, hit )
{
	if( IsArray( enemy ) )
	{
		for( i = 0; i < enemy.size; i++ )
		{
			enemy[i].zombie_tesla_hit = hit;
		}
	}
	else
	{
		enemy.zombie_tesla_hit = hit;
	}
}


tesla_do_damage( source_enemy, arc_num, player, upgraded_status )
{
	player endon( "disconnect" );

	if ( arc_num > 1 )
	{
		time = RandomFloat( 0.2, 0.6 ) * arc_num;

		if(upgraded_status)
		{
			time /= 1.25;
		}

		wait(time);
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	if ( !self enemy_is_dog() )
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

	if( source_enemy != self )
	{
		if ( player.tesla_arc_count > 3 )
		{
			wait_network_frame();
			player.tesla_arc_count = 0;
		}
		
		player.tesla_arc_count++;
		source_enemy tesla_play_arc_fx( self );
	}

	while ( player.tesla_network_death_choke > level.zombie_vars["tesla_network_death_choke"] )
	{
		debug_print( "TESLA: Choking Tesla Damage. Dead enemies this network frame: " + player.tesla_network_death_choke );		
		wait( 0.05 ); 
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	player.tesla_network_death_choke++;

	self.tesla_death = true;

	self tesla_play_death_fx( arc_num );
	
	// use the origin of the arc orginator so it pics the correct death direction anim
	origin = source_enemy.origin;
	if ( source_enemy == self || !IsDefined( origin ) )
	{
		origin = player.origin;
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}
	
	if( self.animname == "boss_zombie" )
	{
		if( !isDefined( level.boss_tesla_damage ) )
		{
			level.boss_tesla_damage = 1000;
		}
		self DoDamage( level.boss_tesla_damage, origin, player );
	}
	else
	{
		self DoDamage( self.health + 666, origin, player );
	}
	player maps\_zombiemode_score::player_add_points( "death", "", "" );

	if ( !player.tesla_powerup_dropped && player.tesla_enemies_hit >= level.zombie_vars["tesla_kills_for_powerup"] )
	{
		player.tesla_powerup_dropped = true;
		level.zombie_vars["zombie_drop_item"] = 1;
		level thread maps\_zombiemode_powerups::powerup_drop( self.origin );
	}
}


tesla_play_death_fx( arc_num )
{
	tag = "J_SpineUpper";
	fx = "tesla_shock";

	if ( self enemy_is_dog() )
	{
		tag = "J_Spine1";
	}

	if ( arc_num > 1 )
	{
		fx = "tesla_shock_secondary";
	}

	network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[fx], self, tag );
	self playsound( "imp_tesla" );

	if ( !self enemy_is_dog() )
	{
		if( RandomInt( 100 ) < level.zombie_vars["tesla_head_gib_chance"] )
		{
			wait( RandomFloat( 0.53, 1.0 ) );
			self maps\_zombiemode_spawner::zombie_head_gib();
		}
		else
		{
			network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect["tesla_shock_eyes"], self, "J_Eyeball_LE" );
		}
	}
}


tesla_play_arc_fx( target )
{
	if ( !IsDefined( self ) || !IsDefined( target ) )
	{
		// TODO: can happen on dog exploding death
		wait( level.zombie_vars["tesla_arc_travel_time"] );
		return;
	}
	
	tag = "J_SpineUpper";

	if ( self enemy_is_dog() )
	{
		tag = "J_Spine1";
	}

	target_tag = "J_SpineUpper";

	if ( target enemy_is_dog() )
	{
		target_tag = "J_Spine1";
	}
	
	origin = self GetTagOrigin( tag );
	target_origin = target GetTagOrigin( target_tag );
	distance_squared = level.zombie_vars["tesla_min_fx_distance"] * level.zombie_vars["tesla_min_fx_distance"];

	if ( DistanceSquared( origin, target_origin ) < distance_squared )
	{
		debug_print( "TESLA: Not playing arcing FX. Enemies too close." );		
		return;
	}
	
	fxOrg = Spawn( "script_model", origin );
	fxOrg SetModel( "tag_origin" );

	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	playsoundatposition( "tesla_bounce", fxOrg.origin );
	
	fxOrg MoveTo( target_origin, level.zombie_vars["tesla_arc_travel_time"] );
	fxOrg waittill( "movedone" );
	fxOrg delete();
}


tesla_gun_exists()
{
	return IsDefined( level.zombie_weapons["tesla_gun"] );
}


tesla_debug_arc( origin, distance )
{
/#
	if ( GetDvarInt( "zombie_debug" ) != 3 )
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
	return ( ( IsDefined( self.damageweapon ) && (self.damageweapon == "tesla_gun" || self.damageweapon == "tesla_gun_upgraded" ) ) && ( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" ) );
}

enemy_killed_by_tesla()
{
	return ( IsDefined( self.tesla_death ) && self.tesla_death == true ); 
	
}


on_player_connect()
{
	for( ;; )
	{
		level waittill( "connecting", player ); 
		player thread tesla_sound_thread(); 
		player thread tesla_pvp_thread();
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

		if ( !IsDefined( result ) )
		{
			continue;
		}

		if( ( result == "weapon_change" || result == "grenade_fire" ) && (self GetCurrentWeapon() == "tesla_gun" || self GetCurrentWeapon() == "tesla_gun_upgraded" ) )
		{
			self PlayLoopSound( "tesla_idle", 0.25 );
			//self thread tesla_engine_sweets();

		}
		else
		{
			self notify ("weap_away");
			self StopLoopSound(0.25);


		}
	}
}
tesla_engine_sweets()
{

	self endon( "disconnect" ); 
	self endon ("weap_away");
	while(1)
	{
		wait(randomintrange(7,15));
		self play_tesla_sound ("tesla_sweeps_idle");

	}

}


tesla_pvp_thread()
{
	self endon( "disconnect" );
	self endon( "death" );
	self waittill( "spawned_player" ); 

	for( ;; )
	{
		self waittill( "weapon_pvp_attack", attacker, weapon, damage, mod );

		if( self maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if ( weapon != "tesla_gun" && weapon != "tesla_gun_upgraded" )
		{
			continue;
		}

		if ( mod != "MOD_PROJECTILE" && mod != "MOD_PROJECTILE_SPLASH" )
		{
			continue;
		}

		if ( self == attacker )
		{
			damage = int( self.maxhealth * .25 );
			if ( damage < 25 )
			{
				damage = 25;
			}

			if ( self.health - damage < 1 )
			{
				self.health = 1;
			}
			else
			{
				self.health -= damage;
			}

			if(self hasperk("specialty_armorvest") )
			{
				self.maxhealth = 250;
			}
			else
			{
				self.maxhealth = 100;
			}
		}
		
		self stopShellshock(); // refresh shellshock so grenades dont undo the ability to get shellshocked

		self setelectrified( 1.0 );	
		self shellshock( "electrocution", 1.0 );
		self playsound( "tesla_bounce" );
	}
}
play_tesla_sound(emotion)
{
	self endon( "disconnect" );

	if(!IsDefined (level.one_emo_at_a_time))
	{
		level.one_emo_at_a_time = 0;
		level.var_counter = 0;	
	}
	if(level.one_emo_at_a_time == 0)
	{
		level.var_counter ++;
		level.one_emo_at_a_time = 1;
		org = spawn("script_origin", self.origin);
		org LinkTo(self);
		org playsound (emotion, "sound_complete"+ "_"+level.var_counter);
		org waittill("sound_complete"+ "_"+level.var_counter);
		org delete();
		level.one_emo_at_a_time = 0;
	}		
}

tesla_killstreak_sound()
{
	self endon( "disconnect" );

	//TUEY Play some dialog if you kick ass with the Tesla gun
	index = maps\_zombiemode_weapons::get_player_index( self );
	plr = "plr_" + index + "_";
	self thread maps\_zombiemode_spawner::play_tesla_dialog(plr);	
	wait(3.5);
	//self thread play_tesla_sound("tesla_happy"); (moved to client)
	level clientNotify ("TGH");
}


tesla_network_choke()
{
	self endon( "disconnect" );
	self endon( "death" );
	self waittill( "spawned_player" ); 

	self.tesla_network_death_choke = 0;

	for ( ;; )
	{
		wait_network_frame();
		wait_network_frame();
		self.tesla_network_death_choke = 0;
	}
}
