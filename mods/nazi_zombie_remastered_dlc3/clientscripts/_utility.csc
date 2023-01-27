#include clientscripts\_utility_code; 
#include clientscripts\_fx; 
#include clientscripts\_music;

/*
=============
///ScriptDocBegin
"Name: getstructarray( <name> , <type )"
"Summary: gets an array of script_structs"
"Module: Array"
"CallOn: An entity"
"MandatoryArg: <name>: "
"MandatoryArg: <type>: "
"Example: fxemitters = getstructarray( "streetlights" , "targetname" )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

error( message )
{
	println( "^c * ERROR * ", message );
	wait 0.05;
 }

// fancy quicker struct array handling, assumes array elements are objects with which an index can be asigned to( IE: can't do 5.struct_array_index ) 
// also have to be sure that objects can't be a part of another structarray setup as the index position is asigned to the object



getstruct( name, type )
{
	if(!IsDefined( level.struct_class_names ) )
		return undefined;
	
	array = level.struct_class_names[ type ][ name ];
	if( !IsDefined( array ) )
	{
		println("**** Getstruct returns undefined on " + name + " : " + " type.");
		return undefined; 
	}

	if( array.size > 1 )
	{
		assertMsg( "getstruct used for more than one struct of type " + type + " called " + name + "." );
		return undefined; 
	}
	return array[ 0 ];
}

getstructarray( name, type )
{
	assertEx( IsDefined( level.struct_class_names ), "Tried to getstruct before the structs were init" );

	array = level.struct_class_names[type][name]; 
	if(!IsDefined( array ) )
	{
		return []; 
	}
	else
	{
		return array; 
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: play_sound_in_space( <clientNum>, <alias> , <origin>  )"
"Summary: Stop playing the the loop sound alias on an entity"
"Module: Sound"
"CallOn: Level"
"MandatoryArg: <clientNum> : local client to hear the sound."
"MandatoryArg: <alias> : Sound alias to play"
"MandatoryArg: <origin> : Origin of the sound"
"Example: play_sound_in_space( "siren", level.speaker.origin );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
play_sound_in_space( localClientNum, alias, origin)
{
	PlaySound( localClientNum, alias, origin); 
}

vectorScale( vector, scale )
{
	vector = (vector[0] * scale, vector[1] * scale, vector[2] * scale);
	return vector;
}

vector_multiply( vec, dif )
{
	vec = ( vec[ 0 ] * dif, vec[ 1 ] * dif, vec[ 2 ] * dif );
	return vec; 
}

/* 
 ============= 
///ScriptDocBegin
"Name: array_thread( <entities> , <process> , <var1> , <var2> , <var3> )"
"Summary: Threads the < process > function on every entity in the < entities > array. The entity will become "self" in the specified function."
"Module: Array"
"CallOn: "
"MandatoryArg: <entities> : array of entities to thread the process"
"MandatoryArg: <process> : pointer to a script function"
"OptionalArg: <var1> : parameter 1 to pass to the process"
"OptionalArg: <var2> : parameter 2 to pass to the process"
"OptionalArg: <var3> : parameter 3 to pass to the process"
"Example: array_thread( getaiarray( "allies" ), ::set_ignoreme, false );"
"SPMP: both"
///ScriptDocEnd
 ============= 
*/ 
array_thread( entities, process, var1, var2, var3 )
{
	keys = getArrayKeys( entities );
	
	if ( IsDefined( var3 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
			entities[ keys[ i ] ] thread [[ process ]]( var1, var2, var3 );
			
		return;
	}

	if ( IsDefined( var2 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
			entities[ keys[ i ] ] thread [[ process ]]( var1, var2 );
			
		return;
	}

	if ( IsDefined( var1 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
			entities[ keys[ i ] ] thread [[ process ]]( var1 );
			
		return;
	}

	for( i = 0 ; i < keys.size ; i ++ )
		entities[ keys[ i ] ] thread [[ process ]]();
}

registerSystem(sSysName, cbFunc)
{
	if(!IsDefined(level._systemStates))
	{
		level._systemStates = [];
	}
	
	if(level._systemStates.size >= 32)	
	{
		error("Max num client systems exceeded.");
		return;
	}
	
	if(IsDefined(level._systemStates[sSysName]))
	{
		error("Attempt to re-register client system : " + sSysName);
		return;
	}
	else
	{
		level._systemStates[sSysName] = spawnstruct();
		level._systemStates[sSysName].callback = cbFunc;
	}	
}

loop_sound_Delete( ender, entId )
{
//	ent endon( "death" ); 
	self waittill( ender ); 
	deletefakeent(0, entId); 
}

loop_fx_sound( clientNum, alias, origin, ender )
{
	entId = spawnfakeent(clientNum);

	if( IsDefined( ender ) )
	{
		thread loop_sound_Delete( ender, entId ); 
		self endon( ender ); 
	}
	
	setfakeentorg(clientNum, entId, origin);
	playloopsound( clientNum, entId, alias ); 
}

waitforclient(client)
{
	while(!clienthassnapshot(client))
	{
		wait(0.01);
	}
	syncsystemstates(client);	
}

/* 
 ============= 
///CScriptDocBegin
"Name: within_fov( <start_origin> , <start_angles> , <end_origin> , <fov> )"
"Summary: Returns true if < end_origin > is within the players field of view, otherwise returns false."
"Module: Vector"
"CallOn: "
"MandatoryArg: <start_origin> : starting origin for FOV check( usually the players origin )"
"MandatoryArg: <start_angles> : angles to specify facing direction( usually the players angles )"
"MandatoryArg: <end_origin> : origin to check if it's in the FOV"
"MandatoryArg: <fov> : cosine of the FOV angle to use"
"Example: qBool = within_fov( level.player.origin, level.player.angles, target1.origin, cos( 45 ) );"
"SPMP: singleplayer"
///CScriptDocEnd
 ============= 
 */ 
within_fov( start_origin, start_angles, end_origin, fov )
{
	normal = VectorNormalize( end_origin - start_origin ); 
	forward = AnglesToForward( start_angles ); 
	dot = VectorDot( forward, normal ); 

	return dot >= fov; 
}


/* 
============= 
///CScriptDocBegin
"Name: add_to_array( <array> , <ent> )"
"Summary: Adds < ent > to < array > and returns the new array."
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : The array to add < ent > to."
"MandatoryArg: <ent> : The entity to be added."
"Example: nodes = add_to_array( nodes, new_node );"
"SPMP: singleplayer"
///CScriptDocEnd
============= 
*/ 
add_to_array( array, ent )
{
	if( !IsDefined( ent ) )
		return array; 

	if( !IsDefined( array ) )
		array[ 0 ] = ent;
	else
		array[ array.size ] = ent;

	return array; 
}

setFootstepEffect(name, fx)
{
	assertEx(IsDefined(name), "Need to define the footstep surface type.");
	assertEx(IsDefined(fx), "Need to define the mud footstep effect.");
	if (!IsDefined(level._optionalStepEffects))
		level._optionalStepEffects = [];
	level._optionalStepEffects[level._optionalStepEffects.size] = name;
	level._effect["step_" + name] = fx;
}

getExploderId( ent )
{
	if(!IsDefined(level._exploder_ids))
	{
		level._exploder_ids = [];
		level._exploder_id = 1;
	}

	if(!IsDefined(level._exploder_ids[ent.v["exploder"]]))
	{
		level._exploder_ids[ent.v["exploder"]] = level._exploder_id;
		level._exploder_id ++;
	}

	return level._exploder_ids[ent.v["exploder"]];
}

reportExploderIds()
{
	if(!IsDefined(level._exploder_ids))
		return;
		
	keys = GetArrayKeys( level._exploder_ids ); 

	println("Client Exploder dictionary : ");

	for( i = 0; i < keys.size; i++ )
	{
		println(keys[i] + " : " + level._exploder_ids[keys[i]]);
	}
	
}

init_exploders()
{
	println("*** Init exploders...");	
	script_exploders = []; 

	ents = GetStructArray( "script_brushmodel", "classname" ); 
	println("Client : s_bm " + ents.size);
	
	smodels = GetStructArray( "script_model", "classname" ); 
	println("Client : sm " + smodels.size);

	for( i = 0; i < smodels.size; i++ )
	{
		ents[ents.size] = smodels[i]; 
	}

	for( i = 0; i < ents.size; i++ )
	{
		if( IsDefined( ents[i].script_prefab_exploder ) )
		{
			ents[i].script_exploder = ents[i].script_prefab_exploder; 
		}
	}

	potentialExploders = GetStructArray( "script_brushmodel", "classname" ); 
	println("Client : Potential exploders from script_brushmodel " + potentialExploders.size);
	
	for( i = 0; i < potentialExploders.size; i++ )
	{
		if( IsDefined( potentialExploders[i].script_prefab_exploder ) )
		{
			potentialExploders[i].script_exploder = potentialExploders[i].script_prefab_exploder; 
		}
			
		if( IsDefined( potentialExploders[i].script_exploder ) )
		{
			script_exploders[script_exploders.size] = potentialExploders[i]; 
		}
	}

	potentialExploders = GetStructArray( "script_model", "classname" ); 
	println("Client : Potential exploders from script_model " + potentialExploders.size);
	
	for( i = 0; i < potentialExploders.size; i++ )
	{
		if( IsDefined( potentialExploders[i].script_prefab_exploder ) )
		{
			potentialExploders[i].script_exploder = potentialExploders[i].script_prefab_exploder; 
		}

		if( IsDefined( potentialExploders[i].script_exploder ) )
		{
			script_exploders[script_exploders.size] = potentialExploders[i]; 
		}
	}

	// Also support script_structs to work as exploders
	for( i = 0; i < level.struct.size; i++ )
	{
		if( IsDefined( level.struct[i].script_prefab_exploder ) )
		{
			level.struct[i].script_exploder = level.struct[i].script_prefab_exploder; 
		}

		if( IsDefined( level.struct[i].script_exploder ) )
		{
			script_exploders[script_exploders.size] = level.struct[i]; 
		}
	}

	if( !IsDefined( level.createFXent ) )
	{
		level.createFXent = []; 
	}
	
	acceptableTargetnames = []; 
	acceptableTargetnames["exploderchunk visible"] = true; 
	acceptableTargetnames["exploderchunk"] = true; 
	acceptableTargetnames["exploder"] = true; 
	
	exploder_id = 1;
	
	for( i = 0; i < script_exploders.size; i++ )
	{
		exploder = script_exploders[i]; 
		ent = createExploder( exploder.script_fxid ); 
		ent.v = []; 
		if(!IsDefined(exploder.origin))
		{
			println("************** NO EXPLODER ORIGIN." + i);
		}
		ent.v["origin"] = exploder.origin; 
		ent.v["angles"] = exploder.angles; 
		ent.v["delay"] = exploder.script_delay; 
		ent.v["firefx"] = exploder.script_firefx; 
		ent.v["firefxdelay"] = exploder.script_firefxdelay; 
		ent.v["firefxsound"] = exploder.script_firefxsound; 
		ent.v["firefxtimeout"] = exploder.script_firefxtimeout; 
		ent.v["trailfx"] = exploder.script_trailfx; 
		ent.v["trailfxtag"] = exploder.script_trailfxtag; 
		ent.v["trailfxdelay"] = exploder.script_trailfxdelay; 
		ent.v["trailfxsound"] = exploder.script_trailfxsound; 
		ent.v["trailfxtimeout"] = exploder.script_firefxtimeout; 
		ent.v["earthquake"] = exploder.script_earthquake; 
		ent.v["rumble"] = exploder.script_rumble; 
		ent.v["damage"] = exploder.script_damage; 
		ent.v["damage_radius"] = exploder.script_radius; 
		ent.v["repeat"] = exploder.script_repeat; 
		ent.v["delay_min"] = exploder.script_delay_min; 
		ent.v["delay_max"] = exploder.script_delay_max; 
		ent.v["target"] = exploder.target; 
		ent.v["ender"] = exploder.script_ender; 
		ent.v["physics"] = exploder.script_physics; 
		ent.v["type"] = "exploder"; 
//		ent.v["worldfx"] = true; 

		if( !IsDefined( exploder.script_fxid ) )
		{
			ent.v["fxid"] = "No FX"; 
		}
		else
		{
			ent.v["fxid"] = exploder.script_fxid; 
		}
		ent.v["exploder"] = exploder.script_exploder; 
	//	assertex( IsDefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" ); 

		if( !IsDefined( ent.v["delay"] ) )
		{
			ent.v["delay"] = 0; 
		}

		// MikeD( 4/14/2008 ): Attempt to use the fxid as the sound reference, this way Sound can add sounds to anything
		// without the scripter needing to modify the map
		if( IsDefined( exploder.script_sound ) )
		{
			ent.v["soundalias"] = exploder.script_sound; 
		}
		else if( ent.v["fxid"] != "No FX"  )
		{
			if( IsDefined( level.scr_sound ) && IsDefined( level.scr_sound[ent.v["fxid"]] ) )
			{
				ent.v["soundalias"] = level.scr_sound[ent.v["fxid"]]; 
			}
		}		

		fixup_set = false;

		if(IsDefined(ent.v["target"]))
		{					
			ent.needs_fixup = exploder_id;
			exploder_id++;
			fixup_set = true;
			
/*			temp_ent = GetEnt(0, ent.v["target"], "targetname" ); 
			if( IsDefined( temp_ent ) )
			{
				org = temp_ent.origin; 
			}
			else */
			{
				temp_ent = GetStruct( ent.v["target"], "targetname" ); 
				org = temp_ent.origin; 
			}

			if(IsDefined(org))
			{
				ent.v["angles"] = VectorToAngles( org - ent.v["origin"] ); 	
			}
			else		
			{
					println("*** Client : Exploder " + exploder.script_fxid + " Failed to find target ");
			}
			
			if(IsDefined(ent.v["angles"]))
			{
				ent set_forward_and_up_vectors();
			}
			else
			{
				println("*** Client " + exploder.script_fxid + " has no angles.");
			}

		}
		
		
		// this basically determines if its a brush/model exploder or not
		if( exploder.classname == "script_brushmodel" || IsDefined( exploder.model ) )
		{
			if(IsDefined(exploder.model))
			{
				println("*** exploder " + exploder_id + " model " + exploder.model);
			}
			ent.model = exploder; 
			//ent.model.disconnect_paths = exploder.script_disconnectpaths; 
			if(fixup_set == false)
			{
				ent.needs_fixup = exploder_id;
				exploder_id++;
			}
		}
		
		if( IsDefined( exploder.targetname ) && IsDefined( acceptableTargetnames[exploder.targetname] ) )
		{
			ent.v["exploder_type"] = exploder.targetname; 
		}
		else
		{
			ent.v["exploder_type"] = "normal"; 
		}		
	}

	for(i = 0; i < level.createFXent.size;i ++ )
	{
		ent = level.createFXent[i];
		
		if(ent.v["type"] != "exploder")
			continue;
			
		ent.v["exploder_id"] = getExploderId( ent );
		
	}
	
	reportExploderIds();	
	
	
	println("*** Client : " + script_exploders.size + " exploders.");
	
}


playfx_for_all_local_clients( fx_id, pos, forward_vec, up_vec )
{
	
	localPlayers = getlocalplayers();
	
	if( IsDefined( up_vec ) )
	{
		for(i = 0; i < localPlayers.size; i ++)
		{
			playfx( i, fx_id, pos, forward_vec, up_vec ); 	
		}		
	}
	else if( IsDefined( forward_vec ) )
	{
		for(i = 0; i < localPlayers.size; i ++)
		{
			playfx( i, fx_id, pos, forward_vec ); 	
		}		
	}
	else
	{
		for(i = 0; i < localPlayers.size; i ++)
		{
			playfx( i, fx_id, pos ); 	
		}		
	}
}

play_sound_on_client( sound_alias )
{
	players = GetLocalPlayers();

	PlaySound( 0, sound_alias, players[0].origin );
}

loop_sound_on_client( sound_alias, min_delay, max_delay, end_on )
{
	players = GetLocalPlayers();

	if( IsDefined( end_on ) )
	{
		level endon( end_on );
	}

	for( ;; )
	{
		play_sound_on_client( sound_alias );
		realwait( min_delay + RandomFloat( max_delay ) );
	}
}

add_listen_thread( wait_till, func, param1, param2, param3, param4, param5 )
{
	level thread add_listen_thread_internal( wait_till, func, param1, param2, param3, param4, param5 );
}

add_listen_thread_internal( wait_till, func, param1, param2, param3, param4, param5 )
{
	for( ;; )
	{
		level waittill( wait_till );

		if( IsDefined( param5 ) )
		{
			level thread [[ func ]]( param1, param2, param3, param4, param5 );
		}
		else if( IsDefined( param4 ) )
		{
			level thread [[ func ]]( param1, param2, param3, param4 );
		}
		else if( IsDefined( param3 ) )
		{
			level thread [[ func ]]( param1, param2, param3 );
		}
		else if( IsDefined( param2 ) )
		{
			level thread [[ func ]]( param1, param2 );
		}
		else if( IsDefined( param1 ) )
		{
			level thread [[ func ]]( param1 );
		}
		else
		{
			level thread [[ func ]]();
		}
	}
}

addLightningExploder(num)
{
	if (!isdefined(level.lightningExploder))
	{
		level.lightningExploder = [];
		level.lightningExploderIndex = 0;
	}
		
	level.lightningExploder[level.lightningExploder.size] = num;
}


/* 
 ============= 
///CScriptDocBegin
"Name: splitscreen_populate_dvars( <clientNum> )"
"Summary: Populates profile dvars with settings read from clientNum's profile data."
"Module: System"
"MandatoryArg: <clientNum> : the local client num of the profile to be read"
"Example: splitscreen_populate_dvars( 1 );"
"SPMP: singleplayer"
///CScriptDocEnd
 ============= 
 */ 
splitscreen_populate_dvars( clientNum )
{
	if ( getlocalplayers().size <= 1 )
	{
		return;
	}
	
	UpdateDvarsFromProfile( clientNum );
}


/* 
 ============= 
///CScriptDocBegin
"Name: splitscreen_restore_dvars()"
"Summary: Restores profile dvars with settings read from client 0's profile data."
"Module: System"
"Example: splitscreen_restore_dvars();"
"SPMP: singleplayer"
///CScriptDocEnd
 ============= 
 */ 
splitscreen_restore_dvars()
{
	if ( getlocalplayers().size <= 1 )
	{
		return;
	}
	
	splitscreen_populate_dvars( 0 );
}

