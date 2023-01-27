#include clientscripts\_utility; 
#include clientscripts\_fx;
#include clientscripts\_music;

init()
{
	if ( GetDvar( "createfx" ) == "on" )
	{
		return;
	}
	
	level._effect["tesla_viewmodel_rail"] = loadfx("maps/zombie/fx_zombie_tesla_rail_view");
	level._effect["tesla_viewmodel_tube"] = loadfx("maps/zombie/fx_zombie_tesla_tube_view");
	level._effect["tesla_viewmodel_tube2"] = loadfx("maps/zombie/fx_zombie_tesla_tube_view2");
	level._effect["tesla_viewmodel_tube3"] = loadfx("maps/zombie/fx_zombie_tesla_tube_view3");
	
	level thread player_init();
	level thread tesla_notetrack_think();
	level thread tesla_happy();
}

player_init()
{
	waitforclient( 0 );
	level.tesla_play_fx = [];
	level.tesla_play_rail = true;
	
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		level.tesla_play_fx[i] = false;
		players[i] thread tesla_fx_rail( i );
		players[i] thread tesla_fx_tube( i );
	}
}

tesla_fx_rail( localclientnum )
{
	self endon( "disconnect" );
	
	for( ;; )
	{
		realwait( RandomFloatRange( 8, 12 ) );
		
		if ( !level.tesla_play_fx[localclientnum] )
		{
			continue;
		}
		if ( !level.tesla_play_rail )
		{			
			continue;
		}

		if ( GetCurrentWeapon( localclientnum ) != "tesla_gun" )
		{
			continue;
		}
				
		if ( IsADS( localclientnum ) || IsThrowingGrenade( localclientnum ) )
		{
			continue;
		}
		
		if ( GetWeaponAmmoClip( localclientnum, "tesla_gun" ) <= 0 )
		{
			continue;
		}
		
		PlayViewmodelFx( localclientnum, level._effect["tesla_viewmodel_rail"], "tag_flash" );
		playsound(localclientnum,"tesla_effects", (0,0,0));
	}
}

tesla_fx_tube( localclientnum )
{
	self endon( "disconnect" );
		
	for( ;; )
	{
		realwait( 0.1 );
		
		if ( !level.tesla_play_fx[localclientnum] )
		{
			continue;
		}

		if ( GetCurrentWeapon( localclientnum ) != "tesla_gun" )
		{
			continue;
		}
		
		if ( IsThrowingGrenade( localclientnum ) )
		{
			continue;
		}
		
		ammo = GetWeaponAmmoClip( localclientnum, "tesla_gun" );
				
		if ( ammo <= 0 )
		{
			continue;
		}
		
		if ( ammo == 1 )
		{
			PlayViewmodelFx( localclientnum, level._effect["tesla_viewmodel_tube3"], "tag_brass" );
		}
		else if ( ammo == 2 )
		{
			PlayViewmodelFx( localclientnum, level._effect["tesla_viewmodel_tube2"], "tag_brass" );
		}
		else
		{
			PlayViewmodelFx( localclientnum, level._effect["tesla_viewmodel_tube"], "tag_brass" );
		}
	}
}
tesla_notetrack_think()
{
	for ( ;; )
	{
		level waittill( "notetrack", localclientnum, note );
		
		//println( "@@@ Got notetrack: " + note + " for client: " + localclientnum );
		
		switch( note )
		{
		case "tesla_switch_flip_off":
		case "tesla_first_raise_start":
			level.tesla_play_fx[localclientnum] = false;			
		break;	
			
		case "tesla_switch_flip_on":
		case "tesla_pullout_start":
		case "tesla_idle_start":
			level.tesla_play_fx[localclientnum] = true;			
		break;			
		
		}
	}
}
tesla_happy()
{
	for(;;)
	{
		level waittill ("TGH");
		if ( GetCurrentWeapon( 0 ) == "tesla_gun" )
		{
			playsound(0,"tesla_happy", (0,0,0));
			level.tesla_play_rail = false;
			realwait(2);
			level.tesla_play_rail = true;
		}
		
	}

}



