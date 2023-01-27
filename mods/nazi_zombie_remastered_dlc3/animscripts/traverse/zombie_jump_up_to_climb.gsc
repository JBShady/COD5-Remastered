#include animscripts\Utility;
#include animscripts\traverse\shared;
#using_animtree ("generic_human");

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie && self.has_legs == true &&  self.type != "dog" )
	{
		low_wall_zombie();
	}
	else if( IsDefined( self.is_zombie ) && self.is_zombie && self.has_legs == false )
	{
		low_wall_crawler();
	}
	else if( self.type == "dog" )
	{
		dog_jump_up(96, 7);
	}
}

low_wall_zombie()
{

	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_jump_up_2_climb;

	DoTraverse( traverseData );


}

low_wall_crawler()
{

	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_crawl_jump_up_2_climb;

	DoTraverse( traverseData );


}



