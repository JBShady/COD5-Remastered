#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility; 

init()
{
	players = get_players();
	for( i = 0; i < players.size; i++ )
		players[i] thread setup_players_coord();
}

setup_players_coord()
{
	self endon( "disconnect" );
	self endon( "death" );

	coordtext = newClientHudElem( self );

	coordtext.alignX 		= "bottom";
	coordtext.alignY 		= "middle";
	coordtext.horzAlign 	= "bottom";
	coordtext.vertAlign 	= "middle";
	coordtext.foreground 	= true;
	coordtext.fontScale 	= 1.5;

	coordtext.color = ( 1, 1, 1 );
	coordtext.sort = 1;

	while( 1 )
	{
		coord = self.origin;
		coordtext SetText( "Player Coordinates: " + coord );
		wait( 0.1 );
	}
}