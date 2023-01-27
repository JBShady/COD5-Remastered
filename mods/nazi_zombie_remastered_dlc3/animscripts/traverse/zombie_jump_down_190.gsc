#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree ("generic_human");

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie )
	{
		if ( self.type != "dog" )
		{
			if ( self.has_legs == true )
			{
				jump_down_zombie();
			}
			else
			{
				jump_down_crawler();
			}
		}
		else
		{
			dog_jump_down(190, 7);
		}
	}
}


jump_down_zombie()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_jump_down_190;

	DoTraverse( traverseData );
}


jump_down_crawler()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_crawl_jump_down_189;

	DoTraverse( traverseData );
}
