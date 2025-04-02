#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	players = get_players();
	if( players.size == 1 )
	{
	//iprintln ("reviving player");
	self.ignoreme = true;
	level.solo_reviving_failsafe = 1;
	wait 10;
	level.solo_reviving_failsafe = 0;
	self.ignoreme = false;

	//iprintln ("player revived");
	
	}
}