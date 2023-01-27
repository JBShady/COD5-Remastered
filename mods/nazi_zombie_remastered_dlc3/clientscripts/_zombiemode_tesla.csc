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

	level._effect["tesla_viewmodel_rail_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_rail_view_ug" );
	level._effect["tesla_viewmodel_tube_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view_ug" );
	level._effect["tesla_viewmodel_tube2_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view2_ug" );
	level._effect["tesla_viewmodel_tube3_upgraded"]	= loadfx( "maps/zombie/fx_zombie_tesla_tube_view3_ug" );
	
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
		weaponname = undefined;
		
		if ( !level.tesla_play_fx[localclientnum] )
		{
			continue;
		}
		if ( !level.tesla_play_rail )
		{			
			continue;
		}

		if ( GetCurrentWeapon( localclientnum ) != "tesla_gun" && GetCurrentWeapon( localclientnum ) != "tesla_gun_upgraded" )
		{
			continue;
		}
		else
		{
			weaponname = GetCurrentWeapon( localclientnum );
		}
				
		if ( IsADS( localclientnum ) || IsThrowingGrenade( localclientnum ) )
		{
			continue;
		}
		
		if ( GetWeaponAmmoClip( localclientnum, weaponname ) <= 0 )
		{
			continue;
		}
		
		fx = level._effect["tesla_viewmodel_rail"];
		
		if ( weaponname == "tesla_gun_upgraded" )
		{
			fx = level._effect["tesla_viewmodel_rail_upgraded"];
		}
		
		PlayViewmodelFx( localclientnum, fx, "tag_flash" );
		playsound(localclientnum,"tesla_effects", (0,0,0));
	}
}

tesla_fx_tube( localclientnum )
{
	self endon( "disconnect" );
		
	for( ;; )
	{
		realwait( 0.1 );
		weaponname = undefined;
		
		if ( !level.tesla_play_fx[localclientnum] )
		{
			continue;
		}

		if ( GetCurrentWeapon( localclientnum ) != "tesla_gun" && GetCurrentWeapon( localclientnum ) != "tesla_gun_upgraded" )
		{
			continue;
		}
		else
		{
			weaponname = GetCurrentWeapon( localclientnum );
		}
		
		if ( IsThrowingGrenade( localclientnum ) )
		{
			continue;
		}
		
		ammo = GetWeaponAmmoClip( localclientnum, weaponname );
				
		if ( ammo <= 0 )
		{
			continue;
		}
		
		fx = level._effect["tesla_viewmodel_tube"];
		
		if ( weaponname == "tesla_gun_upgraded" )
		{
			if ( ammo == 3 || ammo == 4 )
			{
				fx = level._effect["tesla_viewmodel_tube2_upgraded"];
			}
			else if ( ammo == 1 || ammo == 2 )
			{
				fx = level._effect["tesla_viewmodel_tube3_upgraded"];
			}
			else
			{
				fx = level._effect["tesla_viewmodel_tube_upgraded"];
			}
		}
		else // regular tesla gun
		{
			if ( ammo == 1 )
			{
				fx = level._effect["tesla_viewmodel_tube3"];
			}
			else if ( ammo == 2 )
			{
				fx = level._effect["tesla_viewmodel_tube2"];
			}
			else
			{
				fx = level._effect["tesla_viewmodel_tube"];
			}
		}
		
		PlayViewmodelFx( localclientnum, fx, "tag_brass" );
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
		if ( GetCurrentWeapon( 0 ) == "tesla_gun" || GetCurrentWeapon( 0 ) == "tesla_gun_upgraded" )
		{
			playsound(0,"tesla_happy", (0,0,0));
			level.tesla_play_rail = false;
			realwait(2);
			level.tesla_play_rail = true;
		}
		
	}

}



