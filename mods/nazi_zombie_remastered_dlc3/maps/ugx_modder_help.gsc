//UGX Notes: This is code from DLC3 for creating the modderhelp hud. I moved this to an external file for #include purposes. Want to keep the external file references to a minimum (i.e. no maps\_filename::function())

#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility; 

//Args:
// item: the item to be analyzed
// msg: the message to display if the check fails
// type: the type of check we are performing
//Types:
// entity: checks if an entity is defined
// test: checks bool value of item parameter.

modderHelp( item, msg, type )
{
	if(!isDefined(type)) type = "entity";
	// Developer Needs To Be Set To 1
	if( getDvarInt( "developer" ) >= 1 )
	{
		// Title
		if( !isDefined( level.modderHelpText[ 0 ] ) )
		{
			level.modderHelpText[ 0 ] = modderHelpHUD_CreateText( "UGX Modtools Patch Developer Help Center" );
		}
		
		if(type == "entity")
		{
			// Check If Entity Exists Or Forced Error Msg
			if( !isDefined( item ) )
			{
				// Check If Error Msg Exists
				if( !isDefined( msg ) )
				{
					return false;
				}
				
				// Let Modder Know What's Wrong And How To Fix			
				level.modderHelpText[ level.modderHelpText.size ] = modderHelpHUD_CreateText( "^1   -" + msg );
				
				return true; // Return That There Was Something Wrong
			}
		}
		if(type == "test")
		{
			if(item)
				level.modderHelpText[ level.modderHelpText.size ] = modderHelpHUD_CreateText( "^1   -" + msg );
		}
	}
	
	return false;
}

modderHelpHUD_CreateText( Msg )
{
	temp_modderHelpHUD = newHudElem();
	temp_modderHelpHUD.x = 0; 
	temp_modderHelpHUD.y = (level.modderHelpText.size * 20) - 180;
	temp_modderHelpHUD.alignX = "left"; 
	temp_modderHelpHUD.alignY = "middle"; 
	temp_modderHelpHUD.horzAlign = "left"; 
	temp_modderHelpHUD.vertAlign = "middle"; 
	temp_modderHelpHUD.sort = 1;
	temp_modderHelpHUD.foreground = true; 
	temp_modderHelpHUD.fontScale = 1.25;
	temp_modderHelpHUD SetText( Msg ); 
	temp_modderHelpHUD.alpha = 0; 
	temp_modderHelpHUD FadeOverTime( 1.2 ); 
	temp_modderHelpHUD.alpha = 1;
	
	return temp_modderHelpHUD;
}