#include maps\_utility; 
#include common_scripts\utility; 

init_utility()
{
//	level thread edge_fog_start(); 

	level thread cheat_score(); 

//	level thread hudelem_count(); 
}

get_enemy_count()
{
	enemies = [];
	enemies = GetAiArray( "axis" );
	return enemies.size;
}

spawn_zombie( spawner, target_name ) 
{ 
	spawner.script_moveoverride = true; 

	if( IsDefined( spawner.script_forcespawn ) && spawner.script_forcespawn ) 
	{ 
		guy = spawner StalingradSpawn();  
	} 
	else 
	{ 
		guy = spawner DoSpawn();  
	} 

	spawner.count = 666; 

//	// sometimes we want to ensure a zombie will go to a particular door node
//	// so we target the spawner at a struct and put the struct near the entry point
//	if( isdefined( spawner.target ) )
//	{
//		guy.forced_entry = getstruct( spawner.target, "targetname" ); 
//	}

	if( !spawn_failed( guy ) ) 
	{ 
		if( IsDefined( target_name ) ) 
		{ 
			guy.targetname = target_name; 
		} 

		return guy;  
	}

	return undefined;  
}

create_simple_hud( client )
{
	if( IsDefined( client ) )
	{
		hud = NewClientHudElem( client ); 
	}
	else
	{
		hud = NewHudElem(); 
	}

	level.hudelem_count++; 

	hud.foreground = true; 
	hud.sort = 1; 
	hud.hidewheninmenu = false; 

	return hud; 
}

destroy_hud()
{
	level.hudelem_count--; 
	self Destroy(); 
}

all_chunks_intact( barrier_chunks )
{
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( barrier_chunks[i].destroyed && !IsDefined( barrier_chunks[i].mid_repair ))
		{
			return false; 
		}
	}

	return true; 
}

all_chunks_destroyed( barrier_chunks )
{
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( !barrier_chunks[i].destroyed )
		{
			return false; 
		}
		if ( IsDefined( barrier_chunks[i].target_by_zombie ) )
		{
			return false;
		}
	}

	return true; 
}

round_up_to_ten( score )
{
	new_score = score - score % 10; 
	if( new_score < score )
	{
		new_score += 10; 
	}
	return new_score; 
}

random_tan()
{
	rand = randomint( 100 ); 
	
	if( rand > 65 )
	{
		self StartTanning(); 
	}
}

// Returns the amount of places before the decimal, ie 1000 = 4, 100 = 3...
places_before_decimal( num )
{
	abs_num = abs( num ); 
	count = 0; 
	while( 1 )
	{
		abs_num *= 0.1; // Really doing num / 10
		count += 1; 

		if( abs_num < 1 )
		{
			return count; 
		}
	}
}

get_closest_valid_player( origin, ignore_player )
{
	valid_player_found = false; 
	
	players = get_players();

	if( IsDefined( ignore_player ) )
	{
		players = array_remove( players, ignore_player );
	}

	while( !valid_player_found )
	{
		// find the closest player
		player = GetClosest( origin, players ); 

		if( !isdefined( player ) )
		{
			return undefined; 
		}
		
		// make sure they're not a zombie or in last stand
		if( !is_player_valid( player ) )
		{
			players = array_remove( players, player ); 
			continue; 
		}
		return player; 
	}
}

is_player_valid( player )
{
	if( !IsDefined( player ) ) 
	{
		return false; 
	}

	if( !IsAlive( player ) )
	{
		return false; 
	} 

	if( !IsPlayer( player ) )
	{
		return false;
	}

	if( player.is_zombie == true )
	{
		return false; 
	}

	if( player.sessionstate == "spectator" )
	{
		return false; 
	}

	if( player.sessionstate == "intermission" )
	{
		return false; 
	}

	if(  player maps\_laststand::player_is_in_laststand() )
	{
		return false; 
	}

	return true; 
}

in_revive_trigger()
{
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		if( !IsDefined( players[i] ) || !IsAlive( players[i] ) ) 
		{
			continue; 
		}
	
		if( IsDefined( players[i].revivetrigger ) )
		{
			if( self IsTouching( players[i].revivetrigger ) )
			{
				return true;
			}
		}
	}

	return false;
}

get_closest_node( org, nodes )
{
	return getClosest( org, nodes ); 
}

get_closest_2d( origin, ents )
{
	if( !IsDefined( ents ) )
	{
		return undefined; 
	}

	dist = Distance2d( origin, ents[0].origin ); 
	index = 0; 
	for( i = 1; i < ents.size; i++ )
	{
		temp_dist = Distance2d( origin, ents[i].origin ); 
		if( temp_dist < dist )
		{
			dist = temp_dist; 
			index = i; 
		}
	}

	return ents[index]; 
}

disable_trigger()
{
	if( !IsDefined( self.disabled ) || !self.disabled )
	{
		self.disabled = true; 
		self.origin = self.origin -( 0, 0, 10000 ); 
	}
}

enable_trigger()
{
	if( !IsDefined( self.disabled ) || !self.disabled )
	{
		return; 
	}

	self.disabled = false; 
	self.origin = self.origin +( 0, 0, 10000 ); 
}

//edge_fog_start()
//{
//	playpoint = getstruct( "edge_fog_start", "targetname" ); 
//
//	if( !IsDefined( playpoint ) )
//	{
//		
//	} 
//	
//	while( isdefined( playpoint ) )
//	{
//		playfx( level._effect["edge_fog"], playpoint.origin ); 
//		
//		if( !isdefined( playpoint.target ) )
//		{
//			return; 
//		}
//		
//		playpoint = getstruct( playpoint.target, "targetname" ); 
//	}
//}

//chris_p - fix bug with this not being an ent array!
in_playable_area()
{
	trigger = GetEntarray( "playable_area", "targetname" );

	if( !IsDefined( trigger ) )
	{
		println( "No playable area trigger found! Assume EVERYWHERE is PLAYABLE" );
		return true;
	}
	
	for(i=0;i<trigger.size;i++)
	{

		if( self IsTouching( trigger[i] ) )
		{
			return true;
		}
	}

	return false;
}

/* BUG FIX UNSURE IF U WANT TO DO
in_playable_area()
{
	trigger = GetEntarray( "playable_area", "targetname" );

	if( !IsDefined( trigger ) )
	{
		println( "No playable area trigger found! Assume EVERYWHERE is PLAYABLE" );
		return true;
	}
	
	for(i=0;i<trigger.size;i++)
	{

		if( self IsTouching( trigger[i] ) )
		{
			return true;
		}
	}

	return false;
}
*/

get_random_non_destroyed_chunk( barrier_chunks )
{
	chunk = undefined; 

	chunks = get_non_destroyed_chunks( barrier_chunks ); 

	if( IsDefined( chunks ) )
	{
		return chunks[RandomInt( chunks.size )]; 
	}

	return undefined; 
}

get_closest_non_destroyed_chunk( origin, barrier_chunks )
{
	chunk = undefined; 

	chunks = get_non_destroyed_chunks( barrier_chunks ); 

	if( IsDefined( chunks ) )
	{
		return get_closest_2d( origin, chunks ); 
	}

	return undefined; 
}

get_random_destroyed_chunk( barrier_chunks )
{
	chunk = undefined; 

	chunks = get_destroyed_chunks( barrier_chunks ); 

	if( IsDefined( chunks ) )
	{
		return chunks[RandomInt( chunks.size )]; 
	}

	return undefined; 
}

get_non_destroyed_chunks( barrier_chunks )
{
	array = []; 
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( !barrier_chunks[i].destroyed && !IsDefined(barrier_chunks[i].target_by_zombie) && !IsDefined(barrier_chunks[i].mid_repair) )
		{
			if ( barrier_chunks[i].origin == barrier_chunks[i].og_origin )
			{
				array[array.size] = barrier_chunks[i]; 
			}
		}
	}

	if( array.size == 0 )
	{
		return undefined; 
	}

	return array; 
}

get_destroyed_chunks( barrier_chunks )
{
	array = []; 
	for( i = 0; i < barrier_chunks.size; i++ )
	{
		if( barrier_chunks[i].destroyed  && !isdefined( barrier_chunks[i].mid_repair ) )
		{
			array[array.size] = barrier_chunks[i]; 
		}
	}

	if( array.size == 0 )
	{
		return undefined; 
	}

	return array; 
}

is_float( num )
{
	val = num - int( num ); 

	if( val != 0 )
	{
		return true; 
	}
	else
	{
		return false; 
	}
}

array_limiter( array, total )
{
	new_array = []; 

	for( i = 0; i < array.size; i++ )
	{
		if( i < total )
		{
			new_array[new_array.size] = array[i]; 
		}
	}

	return new_array; 
}

array_validate( array )
{
	if( IsDefined( array ) && array.size > 0 )
	{
		return true;
	}
	else
	{
		return false;
	}
}

add_later_round_spawners()
{
	spawners = GetEntArray( "later_round_spawners", "script_noteworthy" );

	for( i = 0; i < spawners.size; i++ )
	{
		add_spawner( spawners[i] );
	}
}

add_spawner( spawner )
{
	if( IsDefined( spawner.script_start ) && level.round_number < spawner.script_start )
	{
		return;
	}

	if( IsDefined( spawner.locked_spawner ) && spawner.locked_spawner )
	{
		return;
	}

	if( IsDefined( spawner.has_been_added ) && spawner.has_been_added )
	{
		return;
	}

	spawner.has_been_added = true;

	level.enemy_spawns[level.enemy_spawns.size] = spawner; 
}

fake_physicslaunch( target_pos, power )
{
	start_pos = self.origin; 
	
	///////// Math Section
	// Reverse the gravity so it's negative, you could change the gravity
	// by just putting a number in there, but if you keep the dvar, then the
	// user will see it change.
	gravity = GetDvarInt( "g_gravity" ) * -1; 

	dist = Distance( start_pos, target_pos ); 
	
	time = dist / power; 
	delta = target_pos - start_pos; 
	drop = 0.5 * gravity *( time * time ); 
	
	velocity = ( ( delta[0] / time ), ( delta[1] / time ), ( delta[2] - drop ) / time ); 
	///////// End Math Section

	level thread draw_line_ent_to_pos( self, target_pos );
	self MoveGravity( velocity, time );
	return time;
}

//
// Spectating ===================================================================
//
add_to_spectate_list()
{
	if( !IsDefined( level.spectate_list ) )
	{
		level.spectate_list = [];
	}

	level.spectate_list[level.spectate_list.size] = self;
} 

remove_from_spectate_list()
{
	if( !IsDefined( level.spectate_list ) )
	{
		return undefined;
	}

	level.spectate_list = array_remove( level.spectate_list, self );
}

get_next_from_spectate_list( ent )
{
	index = 0;
	for( i = 0; i < level.spectate_list.size; i++ )
	{
		if( ent == level.spectate_list[i] )
		{
			index = i;
		}
	}

	index++;

	if( index >= level.spectate_list.size )
	{
		index = 0;
	}
	
	return level.spectate_list[index];
}

get_random_from_spectate_list()
{
	return level.spectate_list[RandomInt(level.spectate_list.size)];
}

//
// STRINGS ======================================================================= 
// 
add_zombie_hint( ref, text )
{
	if( !IsDefined( level.zombie_hints ) )
	{
		level.zombie_hints = []; 
	}

	PrecacheString( text ); 
	level.zombie_hints[ref] = text; 
}

get_zombie_hint( ref )
{
	if( IsDefined( level.zombie_hints[ref] ) )
	{
		return level.zombie_hints[ref]; 
	}

/#
	println( "UNABLE TO FIND HINT STRING " + ref ); 
#/
	return level.zombie_hints["undefined"]; 
}

// self is the trigger( usually spawned in on the fly )
// ent is the entity that has the script_hint info
set_hint_string( ent, default_ref )
{
	if( IsDefined( ent.script_hint ) )
	{
		self SetHintString( get_zombie_hint( ent.script_hint ) ); 
	}
	else
	{
		self SetHintString( get_zombie_hint( default_ref ) ); 
	}
}

//
// SOUNDS =========================================================== 
// 

add_sound( ref, alias )
{
	if( !IsDefined( level.zombie_sounds ) )
	{
		level.zombie_sounds = []; 
	}

	level.zombie_sounds[ref] = alias; 
}

play_sound_at_pos( ref, pos, ent )
{
	if( IsDefined( ent ) )
	{
		if( IsDefined( ent.script_soundalias ) )
		{
			PlaySoundAtPosition( ent.script_soundalias, pos ); 
			return;
		}

		if( IsDefined( self.script_sound ) )
		{
			ref = self.script_sound; 
		}
	}

	if( ref == "none" )
	{
		return; 
	}

	if( !IsDefined( level.zombie_sounds[ref] ) )
	{
		AssertMsg( "Sound \"" + ref + "\" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." ); 
		return; 
	}
	
	PlaySoundAtPosition( level.zombie_sounds[ref], pos ); 
}

play_sound_on_ent( ref )
{
	if( IsDefined( self.script_soundalias ) )
	{
		self PlaySound( self.script_soundalias ); 
		return;
	}

	if( IsDefined( self.script_sound ) )
	{
		ref = self.script_sound; 
	}

	if( ref == "none" )
	{
		return; 
	}

	if( !IsDefined( level.zombie_sounds[ref] ) )
	{
		AssertMsg( "Sound \"" + ref + "\" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." ); 
		return; 
	}

	self PlaySound( level.zombie_sounds[ref] ); 
}

play_loopsound_on_ent( ref )
{
	if( IsDefined( self.script_firefxsound ) )
	{
		ref = self.script_firefxsound; 
	}

	if( ref == "none" )
	{
		return; 
	}

	if( !IsDefined( level.zombie_sounds[ref] ) )
	{
		AssertMsg( "Sound \"" + ref + "\" was not put to the zombie sounds list, please use add_sound( ref, alias ) at the start of your level." ); 
		return; 
	}

	self PlaySound( level.zombie_sounds[ref] ); 
}

//
// TABLE LOOK SECTION ============================================================
// 

set_zombie_var( var, value, div )
{
	// First look it up in the table
	table = "mp/zombiemode.csv";
	table_value = TableLookUp( table, 0, var, 1 );

	if( IsDefined( table_value ) && table_value != "" )
	{
		value = int( table_value );
	}

	if( IsDefined( div ) )
	{
		value = value / div;
	}

	level.zombie_vars[var] = value;
}

//
// DEBUG SECTION ================================================================= 
// 
// shameless stole from austin
debug_ui()
{
/#
	wait 1; 
	
	x = 510; 
	y = 280; 
	menu_name = "zombie debug"; 

	menu_bkg = maps\_debug::new_hud( menu_name, undefined, x, y, 1 ); 
	menu_bkg SetShader( "white", 160, 120 ); 
	menu_bkg.alignX = "left"; 
	menu_bkg.alignY = "top"; 
	menu_bkg.sort = 10; 
	menu_bkg.alpha = 0.6; 	
	menu_bkg.color = ( 0.0, 0.0, 0.5 ); 

	menu[0] = maps\_debug::new_hud( menu_name, "SD:", 		x + 5, y + 10, 1 ); 
	menu[1] = maps\_debug::new_hud( menu_name, "ZH:", 		x + 5, y + 20, 1 ); 
	menu[1] = maps\_debug::new_hud( menu_name, "ZS:", 		x + 5, y + 30, 1 ); 
	menu[1] = maps\_debug::new_hud( menu_name, "WN:", 		x + 5, y + 40, 1 ); 

	x_offset = 120; 

	// enum
	spawn_delay			 = menu.size; 
	zombie_health		 = menu.size + 1; 
	zombie_speed		 = menu.size + 2; 
	round_number			 = menu.size + 3; 

	menu[spawn_delay]		 = maps\_debug::new_hud( menu_name, "", x + x_offset, y + 10, 1 ); 
	menu[zombie_health]	 = maps\_debug::new_hud( menu_name, "", x + x_offset, y + 20, 1 ); 
	menu[zombie_speed]	 = maps\_debug::new_hud( menu_name, "", x + x_offset, y + 30, 1 ); 
	menu[round_number]	 = 	maps\_debug::new_hud( menu_name, "", x + x_offset, y + 40, 1 ); 
	
	while( true )
	{
		wait( 0.05 ); 

		menu[spawn_delay]		SetText( level.zombie_vars["zombie_spawn_delay"] ); 
		menu[zombie_health]		SetText( level.zombie_health ); 
		menu[zombie_speed] 		SetText( level.zombie_move_speed ); 
		menu[round_number] 		SetText( level.round_number ); 
	}
#/
}

hudelem_count()
{
/#
	max = 0; 
	curr_total = 0; 
	while( 1 )
	{
		if( level.hudelem_count > max )
		{
			max = level.hudelem_count; 
		}
		
		println( "HudElems: " + level.hudelem_count + "[Peak: " + max + "]" ); 
		wait( 0.05 ); 
	}
#/
}

debug_round_advancer()
{
/#
	while( 1 )
	{
		zombs = getaiarray( "axis" ); 
		
		for( i = 0; i < zombs.size; i++ )
		{
			zombs[i] dodamage( zombs[i].health * 100, ( 0, 0, 0 ) ); 
			wait 0.5; 
		}
	}	
#/
}

cheat_score()
{
/#
//	level waittill( "introscreen_done" );
	flag_wait( "all_players_connected" );

	while( 1 )
	{
		if( GetDvar( "zombie_cheat" ) == "1" )
		{
			SetDvar( "zombie_cheat", "0" ); 

			// players spend their cash
			get_players()[0].score = 100000; 

			// also set the score onscreen
			get_players()[0] maps\_zombiemode_score::set_player_score_hud(); 	
		}
			
		wait 0.05; 
	}
#/
}

print_run_speed( speed )
{
/#
	self endon( "death" ); 
	while( 1 )
	{
		print3d( self.origin +( 0, 0, 64 ), speed, ( 1, 1, 1 ) ); 
		wait 0.05; 
	}
#/
}

draw_line_ent_to_ent( ent1, ent2 )
{
/#
	if( GetDvarInt( "zombie_debug" ) != 1 )
	{
		return; 
	}

	ent1 endon( "death" ); 
	ent2 endon( "death" ); 

	while( 1 )
	{
		line( ent1.origin, ent2.origin ); 
		wait( 0.05 ); 
	}
#/
}

draw_line_ent_to_pos( ent, pos, end_on )
{
/#
	if( GetDvarInt( "zombie_debug" ) != 1 )
	{
		return; 
	}

	ent endon( "death" ); 

	ent notify( "stop_draw_line_ent_to_pos" ); 
	ent endon( "stop_draw_line_ent_to_pos" ); 

	if( IsDefined( end_on ) )
	{
		ent endon( end_on ); 
	}

	while( 1 )
	{
		line( ent.origin, pos ); 
		wait( 0.05 ); 
	}
#/
}

debug_print( msg )
{
/#
	if( GetDvarInt( "zombie_debug" ) > 0 )
	{
		println( "######### ZOMBIE: " + msg ); 
	}
#/
}

debug_blocker( pos, rad, height )
{
/#
	self notify( "stop_debug_blocker" );
	self endon( "stop_debug_blocker" );
	
	for( ;; )
	{
		if( GetDvarInt( "zombie_debug" ) != 1 )
		{
			return;
		}

		wait( 0.05 ); 
		drawcylinder( pos, rad, height ); 
		
	}
#/
}

drawcylinder( pos, rad, height )
{
/#
	currad = rad; 
	curheight = height; 

	for( r = 0; r < 20; r++ )
	{
		theta = r / 20 * 360; 
		theta2 = ( r + 1 ) / 20 * 360; 

		line( pos +( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos +( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) ); 
		line( pos +( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos +( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) ); 
		line( pos +( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos +( cos( theta ) * currad, sin( theta ) * currad, curheight ) ); 
	}
#/
}

print3d_at_pos( msg, pos, thread_endon, offset )
{
/#
	self endon( "death" ); 

	if( IsDefined( thread_endon ) )
	{
		self notify( thread_endon ); 
		self endon( thread_endon ); 
	}

	if( !IsDefined( offset ) )
	{
		offset = ( 0, 0, 0 ); 
	}

	while( 1 )
	{
		print3d( self.origin + offset, msg ); 
		wait( 0.05 ); 
	}
#/
}

debug_breadcrumbs()
{
/#
	self endon( "disconnect" ); 

	while( 1 )
	{
		if( GetDvarInt( "zombie_debug" ) != 1 )
		{
			wait( 1 ); 
			continue; 
		}

		if( self.zombie_breadcrumbs.size < 2 )
		{
			wait( 1 ); 
			continue; 
		}

		line( self.origin, self.zombie_breadcrumbs[0] ); 
		for( i = 0; i < self.zombie_breadcrumbs.size - 1; i++ )
		{
			line( self.zombie_breadcrumbs[i], self.zombie_breadcrumbs[i + 1] ); 
		}

		wait( 0.05 ); 
	}
#/
}

debug_attack_spots_taken()
{
/#
	while( 1 )
	{
		if( GetDvarInt( "zombie_debug" ) != 2 )
		{
			wait( 1 ); 
			continue; 
		}

		wait( 0.05 );
		count = 0;
		for( i = 0; i < self.attack_spots_taken.size; i++ )
		{
			if( self.attack_spots_taken[i] )
			{
				count++;
			}
		}

		msg = "" + count + " / " + self.attack_spots_taken.size;
		print3d( self.origin, msg );
	}
#/
}

float_print3d( msg, time )
{
/#
	self endon( "death" );

	time = GetTime() + ( time * 1000 );
	offset = ( 0, 0, 72 );
	while( GetTime() < time )
	{
		offset = offset + ( 0, 0, 2 );
		print3d( self.origin + offset, msg, ( 1, 1, 1 ) );
		wait( 0.05 );
	}
#/
}

really_play_2D_sound(sound)
{
	temp_ent = spawn("script_origin", (0,0,0));
	temp_ent playsound (sound, sound + "wait");
	temp_ent waittill (sound + "wait");
	wait(0.05);
	temp_ent delete();	

}


play_sound_2D(sound)
{
	level thread really_play_2D_sound(sound);
	
	/*
	if(!isdefined(level.playsound2dent))
	{
		level.playsound2dent = spawn("script_origin",(0,0,0));
	}
	
	//players=getplayers();
	level.playsound2dent playsound ( sound );
	*/
	/*
	temp_ent = spawn("script_origin", (0,0,0));
	temp_ent playsound (sound, sound + "wait");
	temp_ent waittill (sound + "wait");
	wait(0.05);
	temp_ent delete();	
	*/
	
	
}

create_and_play_dialog( player_index, dialog_category, waittime, response )
{              
	if( !IsDefined ( self.sound_dialog ) )
	{
		self.sound_dialog = [];
		self.sound_dialog_available = [];
	}
				
	if ( !IsDefined ( self.sound_dialog[ dialog_category ] ) )
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants( player_index + dialog_category );                  
		assertex( num_variants > 0, "No dialog variants found for category: " + dialog_category );
		
		for( i = 0; i < num_variants; i++ )
		{
			self.sound_dialog[ dialog_category ][ i ] = i;     
		}	
		
		self.sound_dialog_available[ dialog_category ] = [];
	}
	
	if ( self.sound_dialog_available[ dialog_category ].size <= 0 )
	{
		self.sound_dialog_available[ dialog_category ] = self.sound_dialog[ dialog_category ];
	}
  
	variation = random( self.sound_dialog_available[ dialog_category ] );
	self.sound_dialog_available[ dialog_category ] = array_remove( self.sound_dialog_available[ dialog_category ], variation );

	sound_to_play = dialog_category + "_" + variation;
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, waittime, response);
}

setup_response_line( player, index, response )
{
	if(index == 0) //Player 1
	{
		setup_responders( player, 1, 2, 3, response );	
	}
	if(index == 1) //Player 2
	{		
		setup_responders( player, 0, 2, 3, response );	
	}		
	if(index == 2) //Player 3
	{
		setup_responders( player, 1, 0, 3, response );	
	}
	if(index == 3) //Player 4
	{
		setup_responders( player, 1, 2, 0, response );	
	}
	return;
}

setup_responders( player, partner1, partner2, partner3, response )
{
	players = getplayers();

	possible_responses = [];
	possible_responses[0] = partner1; // an int
	possible_responses[1] = partner2; // an int
	possible_responses[2] = partner3; // an int
	
	set_partner = possible_responses[randomintrange(0, players.size - 1 )];
							// If player size is 1: Won't run anyways because of a check before this function, but range would be 0 to 0
							// If player size is 2: Range will be 0 to 2,  adjusted is 0 to 1, 1 is ignored, meaning only responder 0 is active
							// If player size is 3: Range will be 0 to 3 , adjusted is 0 to 2, 2 is ignored, meaning only responder 0 and 1 is active
							// If player size is 4, range will be 0 to 4, adjusted is 0 to 3, 3 is ignored, meaning only responder 0 and 1 and 2 is active (all teammates, because the first talker cant count as a responder)

	indexPartner = maps\_zombiemode_weapons::get_player_index(players[set_partner]); // we grab the index of the player # who is chosen so we can compare their indext to their player # position, say Player 3
	if(set_partner == indexPartner ) // if for some reason Player 3 has an index of player 4 (meaning that the original player 3 left, and player 4 has now been demoted to player 3), then we will NOT play a line
	{
		if( is_player_valid( players[set_partner] ) ) // if we are down then we do not respond
		{
			plr = "plr_" + set_partner + "_";
			players[set_partner] create_and_play_responses( plr, "vox_" + response, 0.25 );
		}
	}	
}
create_and_play_responses( player_index, dialog_category, waittime )
{              	
	if( !IsDefined ( self.sound_dialog ) )
	{
		self.sound_dialog = [];
		self.sound_dialog_available = [];
	}
				
	if ( !IsDefined ( self.sound_dialog[ dialog_category ] ) )
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants( player_index + dialog_category );                  
		assertex( num_variants > 0, "No dialog variants found for category: " + dialog_category );
		
		for( i = 0; i < num_variants; i++ )
		{
			self.sound_dialog[ dialog_category ][ i ] = i;     
		}	
		
		self.sound_dialog_available[ dialog_category ] = [];
	}
	
	if ( self.sound_dialog_available[ dialog_category ].size <= 0 )
	{
		self.sound_dialog_available[ dialog_category ] = self.sound_dialog[ dialog_category ];
	}
  
	variation = random( self.sound_dialog_available[ dialog_category ] );
	self.sound_dialog_available[ dialog_category ] = array_remove( self.sound_dialog_available[ dialog_category ], variation );

	sound_to_play = dialog_category + "_" + variation;
	self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, waittime);
}


player_killstreak_timer()
{
	if(getdvar ("zombie_kills") == "") 
	{
		setdvar ("zombie_kills", "8");
	}	
	if(getdvar ("zombie_kill_timer") == "") 
	{
		setdvar ("zombie_kill_timer", "5");
	}

	kills = getdvarint("zombie_kills");
	time = getdvarint("zombie_kill_timer");

	if (!isdefined (self.timerIsrunning))	
	{
		self.timerIsrunning = 0;
	}

	while(1)
	{
		self waittill("zom_kill");	
		self.killcounter ++;

		if (self.timerIsrunning != 1)	
		{
			self.timerIsrunning = 1;
			self thread timer_actual(kills, time);			
//			iprintlnbold ("killstreak counter started");
		}
	}	

}
timer_actual(kills, time)
{

	timer = gettime() + (time * 1000);
	while(getTime() < timer)
	{
		
//		iprintlnbold ("timer:" + (getTime() + timer * .0001));
//		iprintlnbold ("kills: " + self.killcounter);

		if (self.killcounter > kills)
		{
			//playsoundatposition ("ann_vox_killstreak", (0,0,0));
			//wait(3);
			rand = randomintrange(0, 100);
			if(rand < 50) // 50% chance to not do killstreak VOX, also increased it from 7 to 8 kills so it should happen less often
			{
				self play_killstreak_dialog();
			}
//			self thread do_player_vo("vox_killstreak", 9);
			wait(1);
		
			//resets the killcounter and the timer 
			//self.killcounter = 0;

			 timer = -1;
		}
		wait(0.1);
	}

//	iprintlnbold ("Timer Is Out, Resetting Kills and Time");
	self.killcounter = 0;
	self.timerIsrunning = 0;
}

play_killstreak_dialog()
{
		index = maps\_zombiemode_weapons::get_player_index(self);
		player_index = "plr_" + index + "_";	

		//num_variants = 12;
		waittime = 0.25;
		if(!IsDefined (self.vox_killstreak))
		{
			num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_killstreak");
			self.vox_killstreak = [];
			for(i=0;i<num_variants;i++)
			{
				self.vox_killstreak[self.vox_killstreak.size] = "vox_killstreak_" + i;	
			}
			self.vox_killstreak_available = self.vox_killstreak;
		}
		sound_to_play = random(self.vox_killstreak_available);
		self.vox_killstreak_available = array_remove(self.vox_killstreak_available,sound_to_play);

	//	iprintlnbold("LINE:" + player_index + sound_to_play);

		self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, waittime);

		//self playsound(player_index + sound_to_play, "sound_done" + sound_to_play);			
		//self waittill("sound_done" + sound_to_play);

		wait(waittime);
		if (self.vox_killstreak_available.size < 1 )
		{
			self.vox_killstreak_available = self.vox_killstreak;
		}
		//This ensures that there is at least 3 seconds waittime before playing another VO.

}

include_achievement( achievement, var1, var2, var3, var4 )
{
	maps\_zombiemode_achievement::init( achievement, var1, var2, var3, var4 );
}
achievement_notify( notify_name )
{
	self notify( notify_name );
}