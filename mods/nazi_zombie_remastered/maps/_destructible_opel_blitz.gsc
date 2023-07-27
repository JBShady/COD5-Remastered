// Destructible initialization script
#include maps\_destructible;
#using_animtree( "vehicles" );

init()
{
	set_function_pointer( "explosion_anim", "dest_opel_blitz", ::get_explosion_animation );
	set_function_pointer( "flattire_anim", "dest_opel_blitz", ::get_flattire_animation );

	build_destructible_radiusdamage( "dest_opel_blitz", undefined, 260, 350, 50, true );
								// 240, 40. Small buff 
								// ( destructibledef, offset, range, maxdamage, mindamage, bKillplayer )
	build_destructible_deathquake( "dest_opel_blitz", 0.6, 1.0, 600 );
								// ( destructible_def, scale, duration, radius )

	set_pre_explosion( "dest_opel_blitz", "destructibles/fx_dest_fire_car_fade_40" );
}

get_explosion_animation()
{
	return %v_opelblitz_explode;
}

get_flattire_animation( broken_notify )
{
	if( broken_notify == "flat_tire_left_rear" )
	{
		return %v_opelblitz_flattire_lb;
	}
	else if( broken_notify == "flat_tire_right_rear" )
	{
		return %v_opelblitz_flattire_rb;
	}
	else if( broken_notify == "flat_tire_left_front" )
	{
		return %v_opelblitz_flattire_lf;		
	}
	else if( broken_notify == "flat_tire_right_front" )
	{
		return %v_opelblitz_flattire_rf;
	}
}

empty()
{
}