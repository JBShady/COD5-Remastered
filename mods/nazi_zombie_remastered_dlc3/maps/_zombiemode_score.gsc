#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
}

//chris_p - added dogs to the scoring
player_add_points( event, mod, hit_location ,is_dog)
{
	if( level.intermission )
	{
		return;
	}

	if( !is_player_valid( self ) )
	{
		return;
	}
	
	points = 0;

	switch( event )
	{
		case "death":
			points = level.zombie_vars["zombie_score_kill"]; 
			points += player_add_points_kill_bonus( mod, hit_location );
			if(IsDefined(self.kill_tracker))
			{
				self.kill_tracker++;
			}
			else
			{
				self.kill_tracker = 1;
			}
			//stats tracking
			self.stats["kills"] = self.kill_tracker;

			if( mod == "MOD_MELEE" && self hasperk( "specialty_altmelee" ) )
			{	
				self achievement_notify( "DLC3_ZOMBIE_BOWIE_KILLS" );
			}

			if( level.zombie_vars["zombie_powerup_insta_kill_on"] == 1 && mod == "MOD_UNKNOWN" )
			{
				points = points * 2;
			}

			break; 
	
		case "damage":
			points = level.zombie_vars["zombie_score_damage"]; 
			break; 
	
		case "damage_ads":
			points = Int( level.zombie_vars["zombie_score_damage"] * 1.25 ); 
			break;
	
		default:
			assertex( 0, "Unknown point event" ); 
			break; 
	}

	points = round_up_to_ten( points ) * level.zombie_vars["zombie_point_scalar"];
	

	self.score += points; 
	self.score_total += points;
	//stat tracking
	self.stats["score"] = self.score_total;

	self set_player_score_hud(); 
//	self thread play_killstreak_vo();
}
//TUEY Old killstreak VO script---moved to utility
/*
play_killstreak_vo()
{
	index = maps\_zombiemode_weapons::get_player_index(self);
	self.killstreak = "vox_killstreak";
	
	if(!isdefined (level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	if (!isdefined (self.killstreak_points))
	{
		self.killstreak_points = 0;
	}
	self.killstreak_points = self.score_total;	
	if (!isdefined (self.killstreaks))
	{
		self.killstreaks = 1;
	}
	if (self.killstreak_points > 1500 * self.killstreaks )
	{
		wait (randomfloatrange(0.1, 0.3));
		if(level.player_is_speaking != 1)
		{
			level.player_is_speaking = 1;
			self playsound ("plr_" + index + "_" +self.killstreak, "sound_done");
			self waittill("sound_done");
			level.player_is_speaking = 0;
				
		}
		self.killstreaks ++;
	}
	

}
*/
player_add_points_kill_bonus( mod, hit_location )
{
	if( mod == "MOD_MELEE" )
	{
		return level.zombie_vars["zombie_score_bonus_melee"]; 
	}

	if( mod == "MOD_BURNED" )
	{
		return level.zombie_vars["zombie_score_bonus_burn"];
	}

	score = 0; 

	switch( hit_location )
	{
		case "head":
		case "helmet":
			score = level.zombie_vars["zombie_score_bonus_head"]; 
			break; 
	
		case "neck":
			score = level.zombie_vars["zombie_score_bonus_neck"]; 
			break; 
	
		case "torso_upper":
		case "torso_lower":
			score = level.zombie_vars["zombie_score_bonus_torso"]; 
			break; 
	}

	return score; 
}

player_reduce_points( event, mod, hit_location )
{
	if( level.intermission )
	{
		return;
	}

	points = 0; 

	switch( event )
	{
		case "no_revive_penalty":
			percent = level.zombie_vars["penalty_no_revive_percent"];
			points = self.score * percent;
			break; 
	
		case "died":
			percent = level.zombie_vars["penalty_died_percent"];
			points = self.score * percent;
			break; 

		case "downed":
			percent = level.zombie_vars["penalty_downed_percent"];;
			self notify("I_am_down");
			points = self.score * percent;

			self.score_lost_when_downed = round_up_to_ten( int( points ) );
			break; 
	
		default:
			assertex( 0, "Unknown point event" ); 
			break; 
	}

	points = self.score - round_up_to_ten( int( points ) );

	if( points < 0 )
	{
		points = 0;
	}

	self.score = points;
	
	self set_player_score_hud(); 
}

add_to_player_score( cost, is_change )
{
	if( level.intermission )
	{
		return;
	}

	self.score += cost; 

	// also set the score onscreen
	self set_player_score_hud(is_change); 
}

minus_to_player_score( cost )
{
	if( level.intermission )
	{
		return;
	}

	self.score -= cost; 

	// also set the score onscreen
	self set_player_score_hud(); 
}

player_died_penalty()
{
	// Penalize all of the other players
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] != self && !players[i].is_zombie )
		{
			players[i] player_reduce_points( "no_revive_penalty" );
		}
	}
}

player_downed_penalty()
{
	self player_reduce_points( "downed" );

		
}

//
// SCORING HUD --------------------------------------------------------------------- //
//

// Updates player score hud
set_player_score_hud( is_change, init )
{
//	num = self.entity_num; 

	score_diff = self.score - self.old_score; 

    if(score_diff == 0) return; // Don't display changes of 0 points - Feli

	self thread score_highlight( self.score, score_diff, is_change ); 

	if( IsDefined( init ) )
	{
		return; 
	}

	self.old_score = self.score; 
}

// Create the huds and sets values/text to the hudelems on the upper left
//create_player_score_hud()
//{
//	// TODO: We need to clean up the score huds if a player disconnects
//
//	if( !IsDefined( level.score_leaders ) )
//	{
//		level.score_leaders = []; 
//	}
//
//	level.score_leaders[level.score_leaders.size] = self; 
//
//	if( !IsDefined( level.hud_scores ) )
//	{
//		if( is_coop() )
//		{
//			level.hud_names = []; 
//		}
//
//		level.hud_scores = []; 	
//	}
//
//	level.hud_y_size = 20; 
//	level.hud_score_x_offset = 100; 
//
//	num = self.entity_num; 
//	y = level.hud_scores.size * level.hud_y_size; 
//
//	// Only show the names if we're playing coop. 
//	if( is_coop() && !IsSplitscreen() )
//	{
//		level.hud_names[num] = create_score_hud( 0, y ); 
//		level.hud_names[num] SetText( self ); 
//
//		level.hud_scores[num] = create_score_hud( level.hud_score_x_offset, y ); 
//	}
//	else
//	{
//		level.hud_scores[num] = create_score_hud( 0, 0, true ); 
//	}
//}

// Creates the actual hudelem that will always show up on the upper left
//create_score_hud( x, y, playing_sp )
//{
//	font_size = 8; 
//
//	// Use newclienthudelem if playing sp or splitscreen
//	if( IsDefined( playing_sp ) && playing_sp )
//	{
//		font_size = 16; 
//		hud = NewClientHudElem( self ); 
//	}
//	else
//	{
//		hud = NewHudElem(); 
//	}
//
//	level.hudelem_count++; 
//
//	hud.foreground = true; 
//	hud.sort = 1; 
//	hud.x = x; 
//	hud.y = y; 
//	hud.fontScale = font_size; 
//	hud.alignX = "left"; 
//	hud.alignY = "middle"; 
//	hud.horzAlign = "left"; 
//	hud.vertAlign = "top"; 
//	hud.color = ( 0.8, 0.0, 0.0 ); 
////	hud.glowColor = ( 0, 1, 0 ); 
////	hud.glowAlpha = 1; 
//	hud.hidewheninmenu = false; 
//	
//	return hud; 
//}

//sort_score_board( init )
//{
//	// Figure out the order by score
//	players = get_players(); 
//	for( i = 0; i < players.size; i++ )
//	{
//		for( q = i; q < players.size; q++ )
//		{
//			if( players[q].score > players[i].score )
//			{
//				temp = players[i]; 
//				players[i] = players[q]; 
//				players[q] = temp; 
//			}
//		}
//	}
//
//	// Place the scores in order by score
//	for( i = 0; i < players.size; i++ )
//	{
//		num = players[i].entity_num; 
//		y = i * 20;
//
//		if( IsDefined( level.hud_scores[num] ) )
//		{
//			if( level.hud_scores[num].y != y )
//			{
//				level.hud_scores[num].y = y;
//				level.hud_names[num].y  = y; 
//			}
//		}
//	}
//}

// Creates a hudelem used for the points awarded/taken away
create_highlight_hud( x, y, value )
{
	font_size = 8; 

	if( IsSplitScreen() )
	{
		hud = NewClientHudElem( self );
	}
	else
	{
		hud = NewHudElem();
	}

	level.hudelem_count++; 

	hud.foreground = true; 
	hud.sort = 0; 
	hud.x = x; 
	hud.y = y; 
	hud.fontScale = font_size; 
	hud.alignX = "right"; 
	hud.alignY = "middle"; 
	hud.horzAlign = "right";
	hud.vertAlign = "bottom";

	if( value < 1 )
	{
//		hud.color = ( 0.8, 0, 0 ); 
		hud.color = ( 0.423, 0.004, 0 );
	}
	else
	{
		hud.color = ( 0.9, 0.9, 0.0 );
		hud.label = &"SCRIPT_PLUS";
	}

//	hud.glowColor = ( 0.3, 0.6, 0.3 );
//	hud.glowAlpha = 1; 
	hud.hidewheninmenu = false; 

	hud SetValue( value ); 

	return hud; 	
}

// Handles the creation/movement/deletion of the moving hud elems
score_highlight( score, value, is_change )
{
	self endon( "disconnect" ); 

	if(isDefined(is_change) && is_change)
	{
		if(value == 30)
		{
			value = 25;
		}		
	}
	// Location from hud.menu
	score_x = -103;
	score_y = -71;

	x = score_x;

	if( IsSplitScreen() )
	{
		y = score_y;
	}
	else
	{
		players = get_players();
		num = ( players.size - self GetEntityNumber() ) - 1;
		y = ( num * -18 ) + score_y;
	}
//	places = places_before_decimal( score ) - 1; 

//	if( IsDefined( playing_sp ) && playing_sp )
//	{
//		// Adds more to the X if the score is larger
//		x += places * 20; 
//	}
//	else // playing coop
//	{
//		x = level.hud_score_x_offset; 
//		y = level.hud_scores[self.entity_num].y;

		// Adds more to the X if the score is larger
//		x += places * 10; 
//	}

	time = 0.5; 
	half_time = time * 0.5; 

	hud = create_highlight_hud( x, y, value ); 

	// Move the hud
	hud MoveOverTime( time ); 
	hud.x -= 20 + RandomInt( 40 ); 
	hud.y -= ( -15 + RandomInt( 30 ) ); 

	wait( half_time ); 

	// Fade half-way through the move
	hud FadeOverTime( half_time ); 
	hud.alpha = 0; 

	wait( half_time ); 

	hud Destroy(); 
	level.hudelem_count--; 
}
