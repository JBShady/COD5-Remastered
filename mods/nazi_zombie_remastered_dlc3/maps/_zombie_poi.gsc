#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	players = get_players();
	if( players.size == 1 )
	{
	//iprintln ("reviving player");
	level.revive_point create_zombie_point_of_interest( 15360, 960, 100000, true );

	wait 10;

	//iprintln ("player revived");
	
	level.revive_point create_zombie_point_of_interest( 0, 0, 0, false );
	}
}