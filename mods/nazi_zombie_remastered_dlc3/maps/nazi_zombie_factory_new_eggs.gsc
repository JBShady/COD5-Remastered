#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility; 

init()
{
	// Cut radio from IOS
	level thread new_radio_trig();

	// Cut Teddy VOX
	level thread new_teddy_trig();
}

new_radio_trig()
{
	wait_network_frame();
	location = ( -138.2, -1230, 222.65);
	radio = spawn( "script_model", location );
	radio setModel( "zombie_handheld_radio" );
	radio.angles = ( -90, 0, -291 );
	radio playloopsound( "radio_static" );

	radio_trig = spawn( "trigger_radius", location, 0, 40, 25 );
	radio_trig setCursorHint( "HINT_NOICON" );
	
	while(1)
	{
		radio_trig waittill("trigger", player);
		
		while(1)
		{
			if( !player islookingatorigin(radio.origin))
			{
				break;
			}
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
			if( !player UseButtonPressed() )
			{
				break; 
			}
			radio stoploopsound( .1 );
			radio playSound("radio_two");
			radio_trig delete();
			break;
		}
		if(!isDefined(radio_trig) )
		{
			break;
		}
	}
}

new_teddy_trig()
{	
	wait_network_frame();

	teddy_stand_trig = spawn( "trigger_radius",( -667.5, -1410, 199), 0, 50, 25 );

	teddy_look_trig = spawn( "script_model",( -604.5, -2100, 200) );
	teddy_look_trig setModel( "zombie_teddybear" );
	teddy_look_trig.angles = ( 0, 90, 0 );
	teddy_look_trig hide();

	players = getplayers();

	triggers = 0;

	while(1)
	{
		teddy_stand_trig waittill("trigger", player);
        if( !isADS(player) ) // if we arent even ADS then keep waiting
        {
        	wait(0.1);
        	continue;
        }

		wait(3); // if we are ADS we wait 3 seconds then check again if we are still ADS so you have to actually be looking at the chalk not just accidentaly doing it

		weapon = player getcurrentweapon();
        if( isADS(player) && ( isSubStr(weapon, "ptrs41") || isSubStr(weapon, "scoped") ) && player islookingatorigin(teddy_look_trig.origin) && !isDefined(player.seen_teddy) ) 
		{
			player.seen_teddy = true;
			index = maps\_zombiemode_weapons::get_player_index(player);
			plr = "plr_" + index + "_";
			player thread create_and_play_dialog( plr, "vox_resp_teddy", 0.25 );
			triggers++;
		}
		else
		{
			wait(0.1);	
		}

		if(triggers >= getplayers().size )
		{
			break;
		}

	}
	
	teddy_stand_trig delete();
	teddy_look_trig delete();
}

islookingatorigin( origin )
{
	normalvec = vectorNormalize( origin-self getShootAtPos() );
	veccomp = vectorNormalize(( origin-( 0, 0, 24 ) )-self getShootAtPos() );
	insidedot = vectordot( normalvec, veccomp );
	
	anglevec = anglestoforward( self getplayerangles() );
	vectordot = vectordot( anglevec, normalvec );
	if( vectordot > insidedot )
		return true;
	else
		return false;
}
