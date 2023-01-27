#include clientscripts\_music;
#include clientscripts\_utility; 

createZombieEyes(localClientNum)
{
	
	if(isdefined(self._eyeArray))
	{
		if(!isdefined(self._eyeArray[localClientNum]))
		{
			linkTag = "J_Eyeball_LE";
			fxModel = "tag_origin";
			fxTag = "tag_origin";			
			
			//println("Z pos " + self.origin);
			//println("Z tag pos " + self GetTagOrigin(linkTag));
			
			
			fx_eye_glow = Spawn( localClientNum, self GetTagOrigin( linkTag ), "script_model" );
			fx_eye_glow.angles = self GetTagAngles( linkTag );
			fx_eye_glow SetModel( fxModel );
			fx_eye_glow LinkTo( self, linkTag ); 	
			
			PlayFxOnTag( localClientNum, level._effect["eye_glow"], fx_eye_glow, fxTag );
			
			self._eyeArray[localClientNum] = fx_eye_glow;
		}
	} 
}

deleteZombieEyes(localClientNum)
{
	if(isdefined(self._eyeArray))
	{
		if(isdefined(self._eyeArray[localClientNum]))
		{
			self._eyeArray[localClientNum] delete();
			self._eyeArray[localClientNum] = undefined;
		}
	}
}

zombieEyeMonitor()
{
	self waittill("entityshutdown");
	
	if(isdefined(self._eyeArray))
	{
		for(i = 0; i < self._eyeArray.size; i ++)
		{
			self deleteZombieEyes(i);
		}
	}
}

zombie_eyes(localClientNum)
{
	if(!isdefined(self._eyeArray))
	{
		self._eyeArray = [];
	}

	self thread zombieEyeMonitor();
	
	if(self haseyes())
	{
		self createZombieEyes(localClientNum);
	}
}

zombie_eye_callback(localClientNum, hasEyes)
{
	if(hasEyes)
	{
		self createZombieEyes(localClientNum);
	}
	else
	{
		self deleteZombieEyes(localClientNum);
	}
	//println("Zombie " + self getentitynumber() + " " + hasEyes);
}
init_perk_machines()
{
	if ( GetDvar( "createfx" ) == "on" )
	{
		return;
	}
	
	
	level._effect["sleight_light"]							= loadfx( "misc/fx_zombie_cola_on" );
	level._effect["doubletap_light"]						= loadfx( "misc/fx_zombie_cola_dtap_on" );
	level._effect["jugger_light"]							= loadfx( "misc/fx_zombie_cola_jugg_on" );
	level._effect["revive_light"]							= loadfx( "misc/fx_zombie_cola_revive_on" ); 
	
	level thread perk_start_up();
	
}
perk_start_up()
{
	level waittill( "power_on" );
		
	timer = 0;
	duration = 0.1;
	
	machines = GetStructArray( "perksacola", "targetname" );
	
	while( true )
	{
		for( i = 0; i < machines.size; i++ )
		{
			switch( machines[i].script_sound )
			{
			case "mx_jugger_jingle":
				machines[i] thread vending_machine_flicker_light( "jugger_light", duration );
				break;
				
			case "mx_speed_jingle":
				machines[i] thread vending_machine_flicker_light( "sleight_light", duration );
				break;
				
			case "mx_doubletap_jingle":
				machines[i] thread vending_machine_flicker_light( "doubletap_light", duration );
				break;
			
			case "mx_revive_jingle":
				machines[i] thread vending_machine_flicker_light( "revive_light", duration );
				break;

			default:
				machines[i] thread vending_machine_flicker_light( "jugger_light", duration );
				break;
			}
		}
		timer += duration;
		duration += 0.2;
		if( timer >= 3 )
		{
			break;
		}
		realwait( duration );
	}
}

vending_machine_flicker_light( fx_light, duration )
{		
	players = getlocalplayers();
	for( i = 0; i < players.size; i++ )
	{
		self thread play_perk_fx_on_client( i, fx_light, duration );
	}

}
play_perk_fx_on_client( client_num, fx_light, duration )
{
	
	fxObj = spawn( client_num, self.origin +( 0, 0, -50 ), "script_model" ); 
	fxobj setmodel( "tag_origin" ); 
	//fxobj.angles = self.angles;
	playfxontag( client_num, level._effect[fx_light], fxObj, "tag_origin" ); 	 
	realwait( duration );
	fxobj delete();


}