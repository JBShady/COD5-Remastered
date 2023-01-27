// Callback set up, clientside.

#include clientscripts\_utility;
#include clientscripts\_vehicle;
#include clientscripts\_lights;
#include clientscripts\_fx;

statechange(clientNum, system, newState)
{

	if(!isdefined(level._systemStates))
	{
		level._systemStates = [];
	}

	if(!isdefined(level._systemStates[system]))
	{
		level._systemStates[system] = spawnstruct();
	}

	//level._systemStates[system].oldState = oldState;
	level._systemStates[system].state = newState;
	
	if(isdefined(level._systemStates[system].callback))
	{
		[[level._systemStates[system].callback]](clientNum, newState);
	}
	else
	{
		println("*** Unhandled client system state change - " + system + " - has no registered callback function.");
	}
}

maprestart()
{
	println("*** Client script VM map restart.");
	
	// This really needs to be in a loop over 0 -> num local clients.
	// syncsystemstates(0);
}

init_fx(clientNum)
{
	waitforclient(clientNum);
	clientscripts\_fx::fx_init(clientNum);
}

localclientconnect(clientNum)
{
	println("*** Client script VM : Local client connect " + clientNum);
	
	level.usetreadfx = 1;
	if(isdefined(level._load_done) && clientNum > 0)
	{
		level notify( "kill_treads_forever" );	// doesn't work in split screen yet.
		level.usetreadfx = 0;	
		

	}
	
	if(!isdefined(level._laststand))
	{
		level._laststand = [];
	}
	
	level._laststand[clientNum] = false;
	
	level notify("effects_init_"+clientNum);
}

localclientdisconnect(clientNum)
{
	println("*** Client script VM : Local client disconnect " + clientNum);
	player = getlocalplayers()[clientNum];
	player notify("disconnect");
}

entityspawned(localClientNum)
{
	self endon( "entityshutdown" );
	
	if( self.type == "vehicle"  )
	{
		
		// if _load.csc hasn't been called (such as in most testmaps), set up vehicle arrays specifically
		if( !isdefined( level.vehicles_inited ) )
		{
			clientscripts\_vehicle::init_vehicles();
		}
		
		if(isdefined(level._customVehicleCB))
		{
			keys = getarraykeys(level._customVehicleCB);
			
			for(i = 0; i < keys.size; i ++)
			{
				if(self.vehicletype == keys[i])	// This vehicle type matches an entry in our custom CB array.
				{
					self thread [[level._customVehicleCB[keys[i]]]](localClientNum);
				}
			}
		}
		
		// aircrafts don't need treadfx/exhaustfx
		if ( !( self is_aircraft() ) && level.usetreadfx == 1 )
		{
			self thread vehicle_treads(localClientNum);
			self thread playTankExhaust(localClientNum);
			self thread vehicle_rumble(localClientNum);
			self thread vehicle_variants(localClientNum);
			self thread vehicle_clientinit(localClientNum);
			self thread vehicle_weapon_fired();
		}
		else if (self is_aircraft())
		{
			//println("*** Client : Aircraft dustkick.");
			self thread aircraft_dustkick();
		}
		
	}
}	

scriptmodelspawned(local_client_num, ent, destructable_index)
{
	if(destructable_index == 0)
		return;		// Get out of here.
	
	if(!isdefined(level.createFXent))
		return;

	fixed = false;
		
	for(i = 0; i < level.createFXent.size; i ++)
	{
		if(level.createFXent[i].v["type"] != "exploder")
			continue;
			
		exploder = level.createFXent[i];
		
		if(!isdefined(exploder.needs_fixup))
			continue;
			
		if(exploder.needs_fixup == destructable_index)
		{
//			structinfo(exploder);
			
			//exploder.v["origin"] = ent.origin;
			//exploder.v["angles"] = ent.angles;

/*			println("exp org " + exploder.v["origin"]);
			println("ent org " + ent.origin);
			println("ent ang " + ent.angles); */

			exploder.v["angles"] = VectorToAngles( ent.origin - exploder.v["origin"] ); 	

			exploder clientscripts\_fx::set_forward_and_up_vectors();

/*			keys = getarraykeys(exploder.v);
			
			for(i = 0; i < keys.size; i ++)
			{
				println(keys[i] + " : " + exploder.v[keys[i]]);
			}			

			
			println("** Fixed up exploder " + i);	*/
			exploder.needs_fixup = undefined;
			fixed = true;
		}
	}	
}

callback_activate_exploder(exploder_id)
{
	if(!isdefined(level._exploder_ids))
		return;

	keys = getarraykeys(level._exploder_ids);

	exploder = undefined;
	
	for(i = 0; i < keys.size; i ++)
	{
		if(level._exploder_ids[keys[i]] == exploder_id)
		{
			exploder = keys[i];
			break;
		}
	}

	if(!isdefined(exploder))
	{
		println("*** Client : Exploder id " + exploder_id + " unknown.");
		return;
	}

	println("*** Client callback - activate exploder " + exploder_id + " : " + exploder);

	clientscripts\_fx::activate_exploder(exploder);
}

callback_deactivate_exploder(exploder_id)
{
	if(!isdefined(level._exploder_ids))
		return;

	keys = getarraykeys(level._exploder_ids);

	exploder = undefined;
	
	for(i = 0; i < keys.size; i ++)
	{
		if(level._exploder_ids[keys[i]] == exploder_id)
		{
			exploder = keys[i];
			break;
		}
	}

	if(!isdefined(exploder))
	{
		println("*** Client : Exploder id " + exploder_id + " unknown.");
		return;
	}

	println("*** Client callback - deactivate exploder " + exploder_id + " : " + exploder);

	clientscripts\_fx::deactivate_exploder(exploder);
}

level_notify(notify_name, param1, param2)
{
	level notify(notify_name, param1, param2);
}

sound_notify(client_num, entity,  note )
{
	if ( note == "sound_dogstep_run_default" )
	{	
		entity playsound( client_num, "dogstep_run_default" );
		return true;
	}
	
	prefix = getsubstr( note, 0, 5 );

	if ( prefix != "sound" )
		return false;
		
	alias = "anml" + getsubstr( note, 5 );

	entity play_dog_sound( client_num, alias);
}

dog_sound_print( message )
{
/# 
	level.dog_debug_sound = false;
	
	if (!level.dog_debug_sound)
		return;
		
	println("CLIENT DOG SOUND: " + message );
#/
}

play_dog_sound( localClientNum, sound, position )
{
	dog_sound_print( "SOUND " + sound);
	
	if ( isdefined( position ) )
	{
		return self playsound( localClientNum, sound, position );
	}
	
	return self playsound( localClientNum, sound );
}

