#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

init()
{
	randomize_character_index();
}

randomize_character_index()
{
	level.random_character_index = [];
	for( i = 0; i < 4; i++ )
	{
		level.random_character_index[ i ] = i;
	}
	level.random_character_index = array_randomize( level.random_character_index );
}