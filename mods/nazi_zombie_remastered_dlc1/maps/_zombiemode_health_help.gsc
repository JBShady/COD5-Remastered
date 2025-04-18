#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility; 

init()
{
	level thread setup_players_health();
}

setup_players_health()
{
	flag_wait( "all_players_connected" ); 
	players = get_players();

	if(players.size == 1)
	{
		if(getDvarInt( "cg_drawHealthCount" ) == 1) 
		{
			players[0] thread setup_players_health_hud();
		}
	}
	else if(getDvarInt( "cg_drawHealthCountCoop" ) == 1) 
	{
		for( i = 0; i < players.size; i++ )
		{
			players[i] thread setup_players_health_hud();
		}
	}
}

setup_players_health_hud()
{
	level endon("end_game");

	self endon( "disconnect" );
	self endon( "death" );

	healthtext = newClientHudElem( self );
	
	self thread wait_for_death(healthtext);

	healthtext.alignX 		= "center";
	healthtext.horzAlign 	= "center";
	healthtext.vertAlign 	= "top";
	healthtext.y 	= 10;
	healthtext.foreground 	= true;
	healthtext.fontScale = 1.35; 
	healthtext.font = "default";

	healthtext.color = ( 1, 1, 1 );
	healthtext.sort = 1;

	healthtext.label = "Health: ";

	while( 1 )
	{
	
		health = self.health;
		healthtext setValue( health );
		//iprintlnbold(level.player_is_speaking);
		wait( 0.1 );
	}

}

wait_for_death(healthtext)
{
	self endon( "disconnect" );

	level waittill("end_game");
	healthtext destroy();
	healthtext delete();
}