#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility; 

init()
{
	wait 3;
	radio = spawn( "script_model",( -147, -1233, 221) );
	radio setModel( "static_berlin_ger_radio" );
	radio.angles = ( 0, -12, 0 );
	wait 1;

	new_book = spawn( "script_model",( -615.4, -2155.2, 156.14) );
	new_book setModel( "zombie_books_open" );
	new_book.angles = ( 2.5, -10, 0 );


	radio_trig = spawn( "trigger_radius",( -147, -1233, 221), 0, 40, 25 );
	//radio_trig setHintString( "Play Radio" );
	radio_trig setCursorHint( "HINT_NOICON" );
	
	while(1)
	{
		radio_trig waittill("trigger", player);
		
		while(1)
		{
			if( !player IsTouching( radio_trig ) )
			{
				break;
			}
			if( !is_player_valid( player ) )
			{
				break; 
			}
			if( player in_revive_trigger() )
			{
				break;
			}
			if (player getStance() == "stand")
			{
				break;
			}
			if( !player UseButtonPressed() )
			{
				break; 
			}

			radio playSound("radio_two", "sound_done");
			radio_trig delete();

			radio waittill("sound_done");
			break;
		}
		if(!isDefined(radio_trig) )
		{
			break;
		}
	}
}