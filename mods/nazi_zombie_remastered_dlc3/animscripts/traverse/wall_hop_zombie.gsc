//zombie wall hop anim

#include animscripts\traverse\shared; 
#include maps\_utility;
#include animscripts\Utility;

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie &&  self.type != "dog")
	{
		wall_hop_zombie(); 
	}
	else if( self.type == "dog" )
	{
		dog_wall_and_window_hop( "wallhop", 40 ); 
	}
}

#using_animtree( "generic_human" ); 

wall_hop_zombie()
{
	anims = [];

	if( self.has_legs )
	{
		switch (self.zombie_move_speed)
		{
		case "walk":
			anims = array(
				%ai_zombie_traverse_v1,
				%ai_zombie_traverse_v2
				);
			break;
		case "run":
			anims = array(
				%ai_zombie_traverse_v5
				);
			break;
		case "sprint":
			anims = array(
				%ai_zombie_traverse_v6,
				%ai_zombie_traverse_v7
				);
			break;
		default:
			assertmsg("Zombie move speed of '" + self.zombie_move_speed + "' is not supported for wall hop.");
		}
	}
	else
	{
		anims = array(
			%ai_zombie_traverse_crawl_v1,
			%ai_zombie_traverse_v4
			);
	}

	self advancedTraverse(random(anims), 39.875);
}