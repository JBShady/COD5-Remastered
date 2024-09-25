#include common_scripts\utility; 
#include maps\_utility_code; 
/*
=============
///ScriptDocBegin
"Name: set_vision_set( <visionset> , <transition_time> )"
"Summary: Sets the vision set over time"
"Module: Utility"
"MandatoryArg: <visionset>: Visionset file to use"
"OptionalArg: <transition_time>: Time to transition to the new vision set. Defaults to 1 second."
"Example: set_vision_set( "blackout_darkness", 0.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_vision_set( visionset, transition_time )
{
	if ( init_vision_set( visionset ) )
		return;

	if ( !isdefined( transition_time ) )
		transition_time = 1;
	visionSetNaked( visionset, transition_time );
}

/*
=============
///ScriptDocBegin
"Name: set_nvg_vision( <visionset> , <transition_time> )"
"Summary: Sets the night vision set over time"
"Module: Utility"
"MandatoryArg: <visionset>: Visionset file to use"
"OptionalArg: <transition_time>: Time to transition to the new vision set. Defaults to 1 second."
"Example: set_nvg_vision( "blackout_darkness", 0.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_nvg_vision( visionset, transition_time )
{
//	init_vision_set( visionset );
		
	if ( !isdefined ( transition_time ) )
		transition_time = 1;
	visionSetNight( visionset, transition_time );
}

/* 
 ============= 
///ScriptDocBegin
"Name: sun_light_fade( <startSunColor>, <endSunColor>, <fTime> )"
"Summary: Fade to a given sunlight RGB value over the specified time"
"Module: Utility"
"MandatoryArg: <startSunColor> : Starting RGB values (use whatever the current sun is set to)"
"MandatoryArg: <endSunColor> : Target RGB values the sun colors should change to"
"MandatoryArg: <fTime> : Time in seconds for the fade to occur"
"Example: thread sun_light_fade( (.5,.8,.75), (3.5,3.5,3.5), 2 )"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

sun_light_fade( startSunColor, endSunColor, fTime)
{
	fTime = int( fTime * 20 );
			
	// determine difference btwn starting and target sun RGBs
	increment = [];
	for(i=0;i<3;i++)	
		increment[i] = ( startSunColor[ i ] - endSunColor[ i ] ) / fTime;

	// change gradually to new sun color over time
    newSunColor = [];
    for(i=0;i<fTime;i++)
    {
    	wait(0.05);
    	for(j=0;j<3;j++)
    		newSunColor[ j ] = startSunColor[ j ] - ( increment[ j ] *  i );
		setSunLight( newSunColor[ 0 ], newSunColor[ 1 ], newSunColor[ 2 ] );
	}
    //set sunlight to new target values to account for rounding off decimal places
    setSunLight( endSunColor[ 0 ], endSunColor[ 1 ], endSunColor[ 2 ] );
}

/*
 ============= 
///ScriptDocBegin
"Name: ent_flag_wait( <flagname> )"
"Summary: Waits until the specified flag is set on self. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to wait on"
"Example: enemy ent_flag_wait( "goal" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_wait( msg )
{
	self endon("death");
	
	while( !self.ent_flag[ msg ] )
		self waittill( msg );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag_wait_either( <flagname1> , <flagname2> )"
"Summary: Waits until either of the the specified flags are set on self. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname1> : name of one flag to wait on"
"MandatoryArg: <flagname2> : name of the other flag to wait on"
"Example: enemy ent_flag_wait( "goal", "damage" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_wait_either( flag1, flag2 )
{
	self endon("death");

	for( ;; )
	{
		if( ent_flag( flag1 ) )
			return;
		if( ent_flag( flag2 ) )
			return;
		
		self waittill_either( flag1, flag2 );
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag_wait_or_timeout( <flagname> , <timer> )"
"Summary: Waits until either the flag gets set on self or the timer elapses. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname1: Name of one flag to wait on"
"MandatoryArg: <timer> : Amount of time to wait before continuing regardless of flag."
"Example: ent_flag_wait_or_timeout( "time_to_go", 3 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_wait_or_timeout( flagname, timer )
{
	self endon("death");

	start_time = gettime();
	for( ;; )
	{
		if( self.ent_flag[ flagname ] )
			break;
			
		if( gettime() >= start_time + timer * 1000 )
			break;

		self ent_wait_for_flag_or_time_elapses( flagname, timer );
	}
}
	
ent_flag_waitopen( msg )
{
	self endon("death");
	
	while( self.ent_flag[ msg ] )
		self waittill( msg );
}

ent_flag_assert( msg )
{
	assertEx( !self ent_flag( msg ), "Flag " + msg + " set too soon on entity at position " + self.origin );	
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag_init( <flagname> )"
"Summary: Initialize a flag to be used. All flags must be initialized before using ent_flag_set or ent_flag_wait.  Some flags for ai are set by default such as 'goal', 'death', and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to create"
"Example: enemy ent_flag_init( "hq_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_init( message )
{
	if( !isDefined( self.ent_flag ) )
	{
		self.ent_flag = [];
		self.ent_flags_lock = [];
	}
	if ( !isdefined( level.first_frame ) )
		assertEx( !isDefined( self.ent_flag[ message ] ), "Attempt to reinitialize existing message: " + message + " on entity at position " + self.origin );
	self.ent_flag[ message ] = false;
 /#
	self.ent_flags_lock[ message ] = false;
#/
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag_set_delayed( <flagname> , <delay> )"
"Summary: Sets the specified flag after waiting the delay time on self, all scripts using ent_flag_wait on self will now continue."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to set"
"MandatoryArg: <delay> : time to wait before setting the flag"
"Example: entity flag_set_delayed( "hq_cleared", 2.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_set_delayed( message, delay )
{
	wait( delay ); 
	self ent_flag_set( message );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag_set( <flagname> )"
"Summary: Sets the specified flag on self, all scripts using ent_flag_wait on self will now continue."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to set"
"Example: enemy ent_flag_set( "hq_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_set( message )
{
 /#
 	assertEx( isdefined( self ), "Attempt to set a flag on entity that is not defined" );
	assertEx( isDefined( self.ent_flag[ message ] ), "Attempt to set a flag before calling flag_init: " + message + " on entity at position " + self.origin  );
	assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = true;
#/	
	self.ent_flag[ message ] = true;
	self notify( message );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag_clear( <flagname> )"
"Summary: Clears the specified flag on self."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to clear"
"Example: enemy ent_flag_clear( "hq_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag_clear( message )
{
 /#
 	assertEx( isdefined( self ), "Attempt to clear a flag on entity that is not defined" );
	assertEx( isDefined( self.ent_flag[ message ] ), "Attempt to set a flag before calling flag_init: " + message + " on entity at position " + self.origin  );
	assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = false;
#/	
	//do this check so we don't unneccessarily send a notify
	if(	self.ent_flag[ message ] )
	{
		self.ent_flag[ message ] = false;
		self notify( message );
	}
}

ent_flag_clear_delayed( message, delay )
{
	wait( delay );
	self ent_flag_clear( message );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: ent_flag( <flagname> )"
"Summary: Checks if the flag is set on self. Returns true or false."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to check"
"Example: enemy ent_flag( "death" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
ent_flag( message )
{
	assertEx( isalive( self ), "Attempt to check a flag on entity that is not alive or removed" );
	assertEx( isdefined( message ), "Tried to check flag but the flag was not defined." );
	assertEx( isdefined( self.ent_flag[ message ] ), "Tried to check flag " + message + " but the flag was not initialized, on entity at position " + self.origin  );
	if( !self.ent_flag[ message ] )
		return false; 

	return true; 
}

ent_flag_init_ai_standards()
{
	message_array = [];
	
	message_array[ message_array.size ] = "goal";
	message_array[ message_array.size ] = "damage";

	for( i = 0; i < message_array.size; i++)
	{
		self ent_flag_init( message_array[ i ] );
		self thread ent_flag_wait_ai_standards( message_array[ i ] );
	}	
}

ent_flag_wait_ai_standards( message )
{
	/*
	only runs the first time on the message, so for 
	example if it's waiting on goal, it will only set
	the goal to true the first time.  It also doesn't 
	call ent_set_flag() because that would notify the 
	message possibly twice in the same frame, or worse 
	in the next frame.
	*/
	self endon("death");
	self waittill( message );
		self.ent_flag[ message ] = true;
}
	
 /* 
 ============= 
///ScriptDocBegin
"Name: flag_wait_either( <flagname1> , <flagname2> )"
"Summary: Waits until either of the the specified flags are set."
"Module: Flag"
"CallOn: "
"MandatoryArg: <flagname1> : name of one flag to wait on"
"MandatoryArg: <flagname2> : name of the other flag to wait on"
"Example: flag_wait( "hq_cleared", "hq_destroyed" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
flag_wait_either( flag1, flag2 )
{
	for( ;; )
	{
		if( flag( flag1 ) )
			return;
		if( flag( flag2 ) )
			return;
		
		level waittill_either( flag1, flag2 );
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: flag_wait_any( <flagname1> , <flagname2>, <flagname3> , <flagname4> )"
"Summary: Waits until any of the the specified flags are set."
"Module: Flag"
"CallOn: "
"MandatoryArg: <flagname1> : name of a flag to wait on"
"MandatoryArg: <flagname2> : name of a flag to wait on"
"OptionalArg: <flagname3> : name of a flag to wait on"
"OptionalArg: <flagname4> : name of a flag to wait on"
"Example: flag_wait_any( "hq_cleared", "hq_destroyed", "hq_overrun", "hq_skipped" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */
flag_wait_any( flag1, flag2, flag3, flag4 )
{
	array = [];
	if( isdefined( flag4 ) )
	{
		array[ array.size ] = flag1;
		array[ array.size ] = flag2;
		array[ array.size ] = flag3;
		array[ array.size ] = flag4;
	}	
	else if( isdefined( flag3 ) )
	{
		array[ array.size ] = flag1;
		array[ array.size ] = flag2;
		array[ array.size ] = flag3;
	}	
	else if( isdefined( flag2 ) )
	{
		flag_wait_either( flag1, flag2 );
		return;
	}
	else
		{
		assertmsg( "flag_wait_any() needs at least 2 flags passed to it" );
			return; 
		}

	for( ;; )
	{
		for(i=0; i<array.size; i++)
		{
			if( flag( array[i] ) )
				return;
		}
		
		level waittill_any( flag1, flag2, flag3, flag4 );
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: flag_wait_all( <flagname1> , <flagname2>, <flagname3> , <flagname4> )"
"Summary: Waits until all of the the specified flags are set."
"Module: Flag"
"CallOn: "
"MandatoryArg: <flagname1> : name of a flag to wait on"
"MandatoryArg: <flagname2> : name of a flag to wait on"
"OptionalArg: <flagname3> : name of a flag to wait on"
"OptionalArg: <flagname4> : name of a flag to wait on"
"Example: flag_wait_any( "hq_cleared", "hq_destroyed", "hq_overrun", "hq_skipped" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
flag_wait_all( flag1, flag2, flag3, flag4 )
{
	if( isdefined( flag1 ) )
		flag_wait( flag1 );
	
	if( isdefined( flag2 ) )
		flag_wait( flag2 );
	
	if( isdefined( flag3 ) )
		flag_wait( flag3 );

	if( isdefined( flag4 ) )
		flag_wait( flag4 );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: flag_wait_or_timeout( <flagname> , <timer> )"
"Summary: Waits until either the flag gets set or the timer elapses."
"Module: Flag"
"CallOn: "
"MandatoryArg: <flagname1: Name of one flag to wait on"
"MandatoryArg: <timer> : Amount of time to wait before continuing regardless of flag."
"Example: flag_wait_or_timeout( "time_to_go", 3 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
flag_wait_or_timeout( flagname, timer )
{
	start_time = gettime();
	for( ;; )
	{
		if( level.flag[ flagname ] )
			break;
			
		if( gettime() >= start_time + timer * 1000 )
			break;

		wait_for_flag_or_time_elapses( flagname, timer );
	}
}

/* 
============= 
///ScriptDocBegin
"Name: flag_waitopen_or_timeout( <flagname> , <timer> )"
"Summary: Waits until either the flag gets cleared or the timer elapses."
"Module: Flag"
"CallOn: "
"MandatoryArg: <flagname1: Name of one flag to wait on"
"MandatoryArg: <timer> : Amount of time to wait before continuing regardless of flag."
"Example: flag_waitopen_or_timeout( "time_to_go", 3 );"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/
flag_waitopen_or_timeout( flagname, timer )
{
	start_time = gettime();
	for( ;; )
	{
		if( !level.flag[ flagname ] )
			break;
			
		if( gettime() >= start_time + timer * 1000 )
			break;

		wait_for_flag_or_time_elapses( flagname, timer );
	}
}

flag_trigger_init( message, trigger, continuous )
{
	flag_init( message );

	if( !isDefined( continuous ) )
		continuous = false;
	
	assert( isSubStr( trigger.classname, "trigger" ) );
	trigger thread _flag_wait_trigger( message, continuous );
	
	return trigger;
}


flag_triggers_init( message, triggers, all )
{
	flag_init( message );

	if( !isDefined( all ) )
		all = false;
	
	for( index = 0; index < triggers.size; index ++ )
	{
		assert( isSubStr( triggers[ index ].classname, "trigger" ) );
		triggers[ index ] thread _flag_wait_trigger( message, false );
	}

	return triggers;
}

flag_assert( msg )
{
	assertEx( !flag( msg ), "Flag " + msg + " set too soon!" );	
}

/* 
============= 
///ScriptDocBegin
"Name: flag_set_delayed( <flagname> , <delay> )"
"Summary: Sets the specified flag after waiting the delay time, all scripts using flag_wait will now continue."
"Module: Flag"
"CallOn: "
"MandatoryArg: <flagname> : name of the flag to set"
"MandatoryArg: <delay> : time to wait before setting the flag"
"Example: flag_set_delayed( "hq_cleared", 2.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
*/
flag_set_delayed( message, delay )
{
	wait( delay );
	flag_set( message );
}

flag_clear_delayed( message, delay )
{
	wait( delay );
	flag_clear( message );
}

_flag_wait_trigger( message, continuous )
{
	self endon( "death" );
	
	for( ;; )
	{
		self waittill( "trigger", other );
		flag_set( message );

		if( !continuous )
		return; 

		while( other isTouching( self ) )
			wait( 0.05 );
		
		flag_clear( message );
	}
}

level_end_save()
{
	if( level.missionfailed )
	{
		return;
	}

	if ( flag( "game_saving" ) )
	{
		return;
	}

	players = get_players();
	if( !IsAlive( players[0] ) )
	{
		return; 
	}
		
		
	flag_set( "game_saving" );
		
	imagename = "levelshots / autosave / autosave_" + level.script + "end";

	saveGame( "levelend", &"AUTOSAVE_AUTOSAVE", imagename, true ); // does not print "Checkpoint Reached"
	
	flag_clear( "game_saving" );
}

/* 
============= 
///ScriptDocBegin
"Name: autosave_by_name( <savename> )"
"Summary: autosave the game with the specified save name"
"Module: Autosave"
"CallOn: "
"MandatoryArg: <savename> : name of the save file to create"
"Example: thread autosave_by_name( "building2_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
*/
autosave_by_name( name )
{
	thread autosave_by_name_thread( name ); 
}

autosave_by_name_thread( name, timeout )
{
	if( !IsDefined( level.curAutoSave ) )
	{
		level.curAutoSave = 1; 
	}	
	
	imageName = "levelshots / autosave / autosave_" + level.script + level.curAutoSave;
	result = level maps\_autosave::try_auto_save( level.curAutoSave, "autosave", imagename, timeout );
	if( IsDefined( result ) && result )
	{
		level.curAutoSave++;
	}
}

/*
=============
///ScriptDocBegin
"Name: autosave_or_timeout( <name> , <timeout> )"
"Summary: Autosaves with the specified name but times out if the time elapses"
"Module: Autosave"
"MandatoryArg: <name>: The name"
"MandatoryArg: <timeout>: The timeout"
"Example: autosave_or_timeout( "thename", 3.5 )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
autosave_or_timeout( name, timeout )
{
	thread autosave_by_name_thread( name, timeout );
}



error( message )
{
	println( "^c * ERROR * ", message );
	wait 0.05;

 /#
	if( GetDebugDvar( "debug" ) != "1" )
		assertmsg( "This is a forced error - attach the log file" ); 
#/
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_levelthread( <entities> , <process> , <var1> , <var2> , <var3> )"
"Summary: Threads the < process > function for every entity in the < entities > array. The level calls the function and each entity of the array is passed as the first parameter to the process."
"Module: Array"
"CallOn: "
"MandatoryArg: <entities> : array of entities to thread the process"
"MandatoryArg: <process> : pointer to a script function"
"OptionalArg: <var1> : parameter 1 to pass to the process"
"OptionalArg: <var2> : parameter 2 to pass to the process"
"OptionalArg: <var3> : parameter 3 to pass to the process"
"Example: array_levelthread( getentarray( "palm", "targetname" ), ::palmTrees );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_levelthread( array, process, var1, var2, var3 )
{
	keys = getArrayKeys( array );
	
	if( isdefined( var3 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
			thread [[ process ]]( array[ keys[ i ] ], var1, var2, var3 );
			
		return;
	}

	if( isdefined( var2 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
			thread [[ process ]]( array[ keys[ i ] ], var1, var2 );
			
		return;
	}

	if( isdefined( var1 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
			thread [[ process ]]( array[ keys[ i ] ], var1 );
			
		return;
	}

	for( i = 0 ; i < keys.size ; i ++ )
		thread [[ process ]]( array[ keys[ i ] ] );
}

/*
=============
///ScriptDocBegin
"Name: debug_message( <message> , <origin>, <duration> )"
"Summary: Prints 3d debug text at the specified location for a duration of time."
"Module: Debug"
"MandatoryArg: <message>: String to print"
"MandatoryArg: <origin>: Location of string ( x, y, z )"
"OptionalArg: <duration>: Time to keep the string on screen. Defaults to 5 seconds."
"Example: debug_message( "I am the enemy", enemy.origin, 3.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
debug_message( message, origin, duration )
{
	if( !IsDefined( duration ) )
		duration = 5; 
		
	for( time = 0; time < ( duration * 20 );time ++ )
	{
		print3d( ( origin + ( 0, 0, 45 ) ), message, ( 0.48, 9.4, 0.76 ), 0.85 );
		wait 0.05;
	}
}

/*
=============
///ScriptDocBegin
"Name: debug_message_clear( <message> , <origin>, <duration>, <extraEndon> )"
"Summary: Prints 3d debug text at the specified location for a duration of time, but can be cleared before the normal time has passed if a notify occurs."
"Module: Debug"
"MandatoryArg: <message>: String to print"
"MandatoryArg: <origin>: Location of string ( x, y, z )"
"OptionalArg: <duration>: Time to keep the string on screen. Defaults to 5 seconds."
"OptionalArg: <extraEndon>: Level notify string that will make this text go away before the time expires."
"Example: debug_message( "I am the enemy", enemy.origin, 3.0, "enemy died" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
debug_message_clear( message, origin, duration, extraEndon )
{
	if( IsDefined( extraEndon ) )
	{
		level notify( message + extraEndon ); 
		level endon( message + extraEndon ); 
	}
	else
	{
		level notify( message ); 
		level endon( message ); 
	}
	
	if( !IsDefined( duration ) )
		duration = 5; 
		
	for( time = 0; time < ( duration * 20 );time ++ )
	{
		print3d( ( origin + ( 0, 0, 45 ) ), message, ( 0.48, 9.4, 0.76 ), 0.85 );
		wait 0.05;
	}
}

chain_off( chain )
{
	trigs = GetEntArray( "trigger_friendlychain", "classname" ); 
	for( i = 0;i < trigs.size;i ++ )
		if( ( isdefined( trigs[ i ].script_chain ) ) && ( trigs[ i ].script_chain == chain ) )
		{
			if( isdefined( trigs[ i ].oldorigin ) )
			trigs[ i ].origin = trigs[ i ].oldorigin;
			else
			trigs[ i ].oldorigin = trigs[ i ].origin;

		trigs[ i ].origin = trigs[ i ].origin + ( 0, 0, -5000 );
	}
}

chain_on( chain )
{
	trigs = GetEntArray( "trigger_friendlychain", "classname" ); 
	for( i = 0;i < trigs.size;i ++ )
	if( ( isdefined( trigs[ i ].script_chain ) ) && ( trigs[ i ].script_chain == chain ) )
	{
		if( isdefined( trigs[ i ].oldorigin ) )
			trigs[ i ].origin = trigs[ i ].oldorigin;
	}
}

precache( model )
{
	ent = spawn( "script_model", ( 0, 0, 0 ) );
	ent.origin = level.player getorigin();
	ent setmodel( model );
	ent delete();
}

/* 
============= 
///ScriptDocBegin
"Name: add_to_array( <array> , <ent> )"
"Summary: Adds < ent > to < array > and returns the new array."
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : The array to add < ent > to."
"MandatoryArg: <ent> : The entity to be added."
"Example: nodes = add_to_array( nodes, new_node );"
"SPMP: singleplayer"
///ScriptDocEnd
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

closerFunc( dist1, dist2 )
{
	return dist1 >= dist2; 
}

fartherFunc( dist1, dist2 )
{
	return dist1 <= dist2; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: getClosest( <org> , <array> , <dist> )"
"Summary: Returns the closest entity in < array > to location < org > "
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of entities to check distance on"
"OptionalArg: <dist> : Minimum distance to check"
"Example: friendly = getclosest( level.player.origin, allies );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
getClosest( org, array, dist )
{
	return compareSizes( org, array, dist, ::closerFunc ); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: getClosestFx( <org> , <fxarray> , <dist> )"
"Summary: Returns the closest fx struct created by createfx in < fxarray > to location < org > "
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of createfx structs to check distance on. These are obtained with getfxarraybyID( <fxid> )"
"OptionalArg: <dist> : Minimum distance to check"
"Example: fxstruct = getClosestFx( hallway_tv, fxarray );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
getClosestFx( org, fxarray, dist )
{
	return compareSizesFx( org, fxarray, dist, ::closerFunc );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: getFarthest( <org> , <array> , <dist> )"
"Summary: Returns the farthest entity in < array > to location < org > "
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be farthest from."
"MandatoryArg: <array> : Array of entities to check distance on"
"OptionalArg: <dist> : Maximum distance to check"
"Example: target = getFarthest( level.player.origin, targets );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
getFarthest( org, array, dist )
{
	return compareSizes( org, array, dist, ::fartherFunc ); 
}

compareSizesFx( org, array, dist, compareFunc )
{
	if( !array.size )
		return undefined;
	if( isdefined( dist ) )
	{
		struct = undefined;
		keys = getArrayKeys( array );
		for( i = 0; i < keys.size; i ++ )
		{
			newdist = distance( array[ keys[ i ] ].v[ "origin" ], org );
			if( [[ compareFunc ]]( newDist, dist ) )
				continue;
			dist = newdist;
			struct = array[ keys[ i ] ];
		}
		return struct;
	}

	keys = getArrayKeys( array );
	struct = array[ keys[ 0 ] ];
	dist = distance( struct.v[ "origin" ], org );
	for( i = 1; i < keys.size; i ++ )
	{
		newdist = distance( array[ keys[ i ] ].v[ "origin" ], org );
		if( [[ compareFunc ]]( newDist, dist ) )
			continue;
		dist = newdist;
		struct = array[ keys[ i ] ];
	}
	return struct;
}

compareSizes( org, array, dist, compareFunc )
{
	if( !array.size )
		return undefined; 
	if( IsDefined( dist ) )
	{
		ent = undefined; 
		keys = GetArrayKeys( array ); 
		for( i = 0; i < keys.size; i ++ )
			{
			newdist = distance( array[ keys[ i ] ].origin, org );
			if( [[ compareFunc ]]( newDist, dist ) )
				continue; 
			dist = newdist; 
			ent = array[ keys[ i ] ];
		}
		return ent; 
	}

	keys = GetArrayKeys( array ); 
	ent = array[ keys[ 0 ] ];
	dist = Distance( ent.origin, org ); 
	for( i = 1; i < keys.size; i ++ )
		{
		newdist = distance( array[ keys[ i ] ].origin, org );
		if( [[ compareFunc ]]( newDist, dist ) )
			continue; 
		dist = newdist; 
		ent = array[ keys[ i ] ];
	}
	return ent; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_closest_point( <origin> , <points> , <maxDist> )"
"Summary: Returns the closest point from array < points > from location < origin > "
"Module: Distance"
"CallOn: "
"MandatoryArg: <origin> : Origin to be closest to."
"MandatoryArg: <points> : Array of points to check distance on"
"OptionalArg: <maxDist> : Maximum distance to check"
"Example: target = getFarthest( level.player.origin, targets );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_closest_point( origin, points, maxDist )
{
	assert( points.size ); 
		
	closestPoint = points[ 0 ];
	dist = Distance( origin, closestPoint ); 
	
	for( index = 0; index < points.size; index ++ )
	{
		testDist = distance( origin, points[ index ] );
		if( testDist >= dist )
			continue; 
			
		dist = testDist; 
		closestPoint = points[ index ];
	}
	
	if( !IsDefined( maxDist ) || dist <= maxDist )
		return closestPoint; 
		
	return undefined; 		
}


 /* 
 ============= 
///ScriptDocBegin
"Name: get_within_range( <org> , <array> , <dist> )"
"Summary: Returns all elements from the array that are within DIST range to ORG."
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of entities to check distance on"
"OptionalArg: <dist> : Maximum distance to check"
"Example: close_ai = get_within_range( level.player.origin, ai, 500 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_within_range( org, array, dist )
{
	guys = [];
	for( i = 0; i < array.size; i ++ )
	{
		if( distance( array[ i ].origin, org ) <= dist )
			guys[ guys.size ] = array[ i ];
	}
	return guys;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_outisde_range( <org> , <array> , <dist> )"
"Summary: Returns all elements from the array that are outside DIST range to ORG."
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of entities to check distance on"
"OptionalArg: <dist> : Maximum distance to check"
"Example: close_ai = get_outside_range( level.player.origin, ai, 500 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_outside_range( org, array, dist )
{
	guys = [];
	for( i = 0; i < array.size; i ++ )
	{
		if( distance( array[ i ].origin, org ) > dist )
			guys[ guys.size ] = array[ i ];
	}
	return guys;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_closest_living( <org> , <array> , <dist> )"
"Summary: Returns the closest living entity from the array from the origin"
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of entities to check distance on"
"OptionalArg: <dist> : Maximum distance to check"
"Example: kicker = get_closest_living( node.origin, ai );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_closest_living( org, array, dist )
{
	if( !IsDefined( dist ) )
		dist = 9999999; 
	if( array.size < 1 )
		return; 
	ent = undefined; 		
	for( i = 0;i < array.size;i ++ )
		{
		if( !isalive( array[ i ] ) )
			continue; 
		newdist = distance( array[ i ].origin, org );
		if( newdist >= dist )
			continue; 
		dist = newdist; 
		ent = array[ i ];
	}
	return ent; 
}

get_highest_dot( start, end, array )
{
	if( !array.size )
		return; 
	
	ent = undefined; 		
	
	angles = VectorToAngles( end - start ); 
	dotforward = AnglesToForward( angles ); 
	dot = -1; 
	for( i = 0;i < array.size;i ++ )
	{
		angles = vectorToAngles( array[ i ].origin - start );
		forward = AnglesToForward( angles ); 
		
		newdot = VectorDot( dotforward, forward ); 
		if( newdot < dot )
			continue; 
		dot = newdot; 
		ent = array[ i ];
	}
	return ent; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_closest_index( <org> , <array> , <dist> )"
"Summary: same as getClosest but returns the closest entity's array index instead of the actual entity."
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of entities to check distance on."
"OptionalArg: <dist> : Maximum distance to check"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_closest_index( org, array, dist )
{
	if( !IsDefined( dist ) )
		dist = 9999999; 
	if( array.size < 1 )
		return; 
	index = undefined; 		
	for( i = 0;i < array.size;i ++ )
	{
		newdist = distance( array[ i ].origin, org );
		if( newdist >= dist )
			continue; 
		dist = newdist; 
		index = i; 
	}
	return index; 
}

get_farthest( org, array )
{
	if( array.size < 1 )
	{
		return; 
	}
		
	dist = Distance( array[0].origin, org ); 
	ent = array[0]; 
	for( i = 1; i < array.size; i++ )
	{
		newdist = Distance( array[i].origin, org ); 
		if( newdist <= dist )
		{
			continue; 
		}
		dist = newdist; 
		ent = array[i]; 
	}
	return ent; 
}

get_closest_exclude( org, ents, excluders )
{
	if( !IsDefined( ents ) )
		return undefined; 

	range = 0; 
	if( IsDefined( excluders ) && excluders.size )
	{
		exclude = []; 
		for( i = 0;i < ents.size;i ++ )
			exclude[ i ] = false;

		for( i = 0;i < ents.size;i ++ )
		for( p = 0;p < excluders.size;p ++ )
		if( ents[ i ] == excluders[ p ] )
			exclude[ i ] = true;

		found_unexcluded = false; 
		for( i = 0;i < ents.size;i ++ )
		if( ( !exclude[ i ] ) && ( isdefined( ents[ i ] ) ) )
			{
				found_unexcluded = true; 
			range = distance( org, ents[ i ].origin );
				ent = i; 
				i = ents.size + 1; 
			}

		if( !found_unexcluded )
			return( undefined ); 
		}
	else
	{
		for( i = 0;i < ents.size;i ++ )
		if( isdefined( ents[ i ] ) )
		{
			range = distance( org, ents[ 0 ].origin );
				ent = i; 
				i = ents.size + 1; 
			}
		}

	ent = undefined; 

	for( i = 0;i < ents.size;i ++ )
	if( isdefined( ents[ i ] ) )
		{
			exclude = false; 
			if( IsDefined( excluders ) )
			{
			for( p = 0;p < excluders.size;p ++ )
			if( ents[ i ] == excluders[ p ] )
						exclude = true; 
					}
	
			if( !exclude )
			{
			newrange = distance( org, ents[ i ].origin );
				if( newrange <= range )
				{
					range = newrange; 
					ent = i; 
				}
			}
		}

	if( IsDefined( ent ) )
		return ents[ ent ];
	else
		return undefined; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_closest_ai( <org> , <team> )"
"Summary: Returns the closest AI of the specified team to the specified origin."
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <team> : Team to use. Can be "allies", "axis", or "both"."
"Example: friendly = get_closest_ai( level.player.origin, "allies" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_closest_ai( org, team )
{
	if( IsDefined( team ) )
		ents = GetAiArray( team ); 
	else
		ents = GetAiArray(); 

	if( ents.size == 0 )
		return undefined; 

	return getClosest( org, ents ); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_array_of_closest( <org> , <array> , <excluders> , <max>, <maxdist> )"
"Summary: Returns an array of all the entities in < array > sorted in order of closest to farthest."
"Module: Distance"
"CallOn: "
"MandatoryArg: <org> : Origin to be closest to."
"MandatoryArg: <array> : Array of entities to check distance on."
"OptionalArg: <excluders> : Array of entities to exclude from the check."
"OptionalArg: <max> : Max size of the array to return"
"OptionalArg: <maxdist> : Max distance from the origin to return acceptable entities"
"Example: allies_sort = get_array_of_closest( originFC1.origin, allies );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_array_of_closest( org, array, excluders, max, maxdist )
{
	// pass an array of entities to this function and it will return them in the order of closest
	// to the origin you pass, you can also set max to limit how many ents get returned
	if( !IsDefined( max ) )
		max = array.size; 
	if( !isdefined( excluders ) )
		excluders = [];
	
	maxdists2rd = undefined;
	if( isdefined( maxdist ) )
		maxdists2rd = maxdist * maxdist;
		
	// return the array, reordered from closest to farthest
	dist = []; 
	index = []; 
	for( i = 0;i < array.size;i ++ )
	{
		excluded = false; 
		for( p = 0;p < excluders.size;p ++ )
			{
			if( array[ i ] != excluders[ p ] )
				continue; 
			excluded = true; 
			break; 
		}
		if( excluded )
			continue; 
			
		length = distancesquared( org, array[ i ].origin );
		
		if( isdefined( maxdists2rd ) && maxdists2rd < length )
			continue;
			
		dist[ dist.size ] = length;
		
		
		index[ index.size ] = i;
	}
		
	for( ;; )
	{
		change = false; 
		for( i = 0;i < dist.size - 1;i ++ )
			{
			if( dist[ i ] <= dist[ i + 1 ] )
				continue; 
			change = true; 
			temp = dist[ i ];
			dist[ i ] = dist[ i + 1 ];
			dist[ i + 1 ] = temp;
			temp = index[ i ];
			index[ i ] = index[ i + 1 ];
			index[ i + 1 ] = temp;
		}
		if( !change )
			break; 
		}
	
	newArray = []; 
	if( max > dist.size )
		max = dist.size; 
	for( i = 0;i < max;i ++ )
		newArray[ i ] = array[ index[ i ] ];
	return newArray; 
}

get_closest_ai_exclude( org, team, excluders )
{
	if( IsDefined( team ) )
		ents = GetAiArray( team ); 
	else
		ents = GetAiArray(); 

	if( ents.size == 0 )
		return undefined; 

	return get_closest_exclude( org, ents, excluders ); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: stop_magic_bullet_shield()"
"Summary: Stops magic bullet shield on an AI, setting his health back to a normal value and making him vulnerable to death."
"Module: AI"
"CallOn: AI"
"Example: friendly stop_magic_bullet_shield();"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

stop_magic_bullet_shield()
{
	self notify( "stop_magic_bullet_shield" );
	assertex( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield, "Tried to stop magic bullet shield on a guy without magic bulletshield" ); 

	if ( self.health > self.mbs_oldhealth )
	{
		// the designer may have intentionally set the guys health lower, so don't overwrite it.
		self.health = self.mbs_oldhealth;
	}

	self.a.nextStandingHitDying = self.mbs_anim_nextStandingHitDying;
	self.attackerAccuracy = 1;

	self.mbs_oldhealth = undefined;
	self.mbs_anim_nextStandingHitDying = undefined;
	self.magic_bullet_shield = undefined;

	// MikeD (5/9/2008): AI should do bloodimpacts when magic_bullet_shield is disabled
	self BloodImpact( true );

	self notify( "internal_stop_magic_bullet_shield" );
}

// For future projects we should distinguish between "death" and "deletion"
// Since we currently do not, bulletshield has to be turned off before deleting characters, or you will get the 2nd assert below
magic_bullet_death_detection()
{
	self endon( "internal_stop_magic_bullet_shield" );
	export = self.export; 
	self waittill( "death" ); 
	// CODER_MOD - JamesS - temp disable until IW integration is working better
	//if( IsDefined( self ) )
	//	assertex( 0, "Magic bullet shield guy with export " + export + " died some how." ); 
	//else
	//	assertex( 0, "Magic bullet shield guy with export " + export + " died, most likely deleted from spawning guys." ); 
	
}
	
 /* 
 ============= 
///ScriptDocBegin
"Name: magic_bullet_shield( <health> , <time> , <oldhealth> , <maxhealth_modifier>, <no_death_detection> )"
"Summary: Makes an AI invulnerable to death. When he gets shot, he is ignored by enemies for < time > seconds and his health is regenerated."
"Module: AI"
"CallOn: AI"
"OptionalArg: <health> : Health to set on the AI while in magic_bullet_shield. Default is 100000000."
"OptionalArg: <time> : Time in seconds that the AI will be ignored after taking damage. Default is 0 seconds (not ignored)."
"OptionalArg: <oldhealth> : Health to give the AI when magic bullet shield is turned off. Default is the AI's health value when magic_bullet_shield is called."
"OptionalArg: <maxhealth_modifier> : Multiplier for the AI's .maxhealth while in magic_bullet_shield mode. Modifies the color the friendly name will be. This is rarely set, but sometimes used for scripted sequences."
"OptionalArg: <no_death_detection> : Set this to make the AI not script error on death, like if you want the guy to be deletable."
"Example: friendly thread magic_bullet_shield();"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 

magic_bullet_shield( health, time, oldhealth, maxhealth_modifier, no_death_detection )
{
	if ( IsAI(self) ) // AI only
	{
		assertex( isalive( self ), "Tried to do magic_bullet_shield on a dead or undefined guy." );
		assertex( !self.delayedDeath, "Tried to do magic_bullet_shield on a guy about to die." );
	}
		
	self endon( "internal_stop_magic_bullet_shield" );
	assertex( !isdefined( self.magic_bullet_shield ), "Can't call magic bullet shield on a character twice. Use make_hero and remove_heroes_from_array so that you don't end up with shielded guys in your logic." );
	
	if( !IsDefined( maxhealth_modifier ) )
		maxhealth_modifier = 1; 
	
	if( !IsDefined( oldhealth ) )
		oldhealth = self.health; 

	self.mbs_oldhealth = oldhealth;
	
	if ( IsAI(self) ) // AI only
	{
		self.mbs_anim_nextStandingHitDying = self.a.nextStandingHitDying;
		self.attackerAccuracy = 0;
	self.a.disableLongDeath = true; 
	self.a.nextStandingHitDying = false; 
	}
	
	/#
	if ( !isdefined( no_death_detection ) )
		thread magic_bullet_death_detection(); 
	else
		assertex( no_death_detection, "no_death_detection must be undefined or true" );
	#/

	self.magic_bullet_shield = true; 
	if ( !isdefined( time ) )
		time = 0;

	if( !IsDefined( health ) )
		health = 100000000; 
		
	assertex( health >= 5000, "MagicBulletShield shouldnt be set with low health amounts like < 5000" ); 

	// MikeD (5/9/2008): AI should not do bloodimpacts when magic_bullet_shield is enabled
	self BloodImpact( false );
	
	while( 1 )
	{
		self.health = health; 
		self.maxhealth = ( self.health * maxhealth_modifier ); 
		oldHealth = self.health; 
		self waittill( "damage" ); // This needs to listen to damage instead of pain for zombies - Feli

		if( oldHealth == self.health )// the game spams pain notify every frame while a guy is in pain script
			continue; 
			
		assertex( self.health > 1000, "Magic bullet shield guy got impossibly low health" ); 
		
		if ( time > 0 )
		self thread ignore_me_timer( time ); 

		self thread turret_ignore_me_timer( 5 );
	}
}

/*
=============
///ScriptDocBegin
"Name: disable_long_death(  )"
"Summary: Disables long death on Self"
"Module: Utility"
"CallOn: An enemy AI"
"Example: level.zakhaev disable_long_death(0"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_long_death()
{
	assertex( isalive( self ), "Tried to disable long death on a non living thing" );
	self.a.disableLongDeath = true;
}

/*
=============
///ScriptDocBegin
"Name: enable_long_death(  )"
"Summary: Enables long death on Self"
"Module: Utility"
"CallOn: An enemy AI"
"Example: level.zakhaev enable_long_death(0"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_long_death()
{
	assertex( isalive( self ), "Tried to enable long death on a non living thing" );
	self.a.disableLongDeath = false;
}


/*
=============
///ScriptDocBegin
"Name: deletable_magic_bullet_shield( <health> , <time> , <oldhealth> , <maxhealth_modifier> )"
"Summary: A version of magic bullet shield that does not error if the AI dies. Useful for guys that can be deleted but you want them to have aspects of MBS."
"Module: AI"
"CallOn: AI"
"OptionalArg: <health> : Health to set on the AI while in magic_bullet_shield. Default is 100000000."
"OptionalArg: <time> : Time in seconds that the AI will be ignored after taking damage. Default is 0 seconds (not ignored)."
"OptionalArg: <oldhealth> : Health to give the AI when magic bullet shield is turned off. Default is the AI's health value when magic_bullet_shield is called."
"OptionalArg: <maxhealth_modifier> : Multiplier for the AI's .maxhealth while in magic_bullet_shield mode. Modifies the color the friendly name will be. This is rarely set, but sometimes used for scripted sequences."
"Example: friendly thread magic_bullet_shield();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
deletable_magic_bullet_shield( health, time, oldhealth, maxhealth_modifier )
{
	magic_bullet_shield( health, time, oldhealth, maxhealth_modifier, true );
}


get_ignoreme()
{
	return self.ignoreme; 
}

set_ignoreme( val )
{
	assertex( IsSentient( self ), "Non ai tried to set ignoreme" ); 
	self.ignoreme = val; 
}

set_ignoreall( val )
{
	assertEx( isSentient( self ), "Non ai tried to set ignoraell" );
	self.ignoreall = val;
}

get_pacifist()
{
	return self.pacifist; 
}

set_pacifist( val )
{
	assertex( IsSentient( self ), "Non ai tried to set pacifist" ); 
	self.pacifist = val; 
}

ignore_me_timer( time )
{
	if( !isdefined( self.ignore_me_timer_prev_value ) )
		self.ignore_me_timer_prev_value = self.ignoreme;
	
	ai = GetAiArray( "axis" ); 
	// force my enemy to acquire a new enemy
	for( i = 0; i < ai.size; i ++ )
	{
		guy = ai[ i ];
		if( !IsAlive( guy.enemy ) )
			continue; 
		if( guy.enemy != self )
			continue; 
		guy notify( "enemy" ); 
	}
	self endon( "death" ); 
	self endon( "pain" ); 
	// MikeD (11/1/2007): Disable pain as well.
	self.a.disablePain = true;
	self.ignoreme = true;
	wait( time ); 
	// MikeD (11/1/2007): Re-enable pain as well.
	self.a.disablePain = false;
	self.ignoreme = self.ignore_me_timer_prev_value;
	self.ignore_me_timer_prev_value = undefined;
}

turret_ignore_me_timer( time )
{
	self endon( "death" );
	self endon( "pain" );
	
	self.turretInvulnerability = true;
	wait time;
	self.turretInvulnerability = false;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_randomize( <array> )"
"Summary: Randomizes the array and returns the new array."
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : Array to be randomized."
"Example: roof_nodes = array_randomize( roof_nodes );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_randomize( array )
{
    for( i = 0; i < array.size; i ++ )
    {
        j = RandomInt( array.size ); 
        temp = array[ i ];
        array[ i ] = array[ j ];
        array[ j ] = temp;
    }
    return array; 
}
 /* 
 ============= 
///ScriptDocBegin
"Name: array_reverse( <array> )"
"Summary: Reverses the order of the array and returns the new array."
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : Array to be reversed."
"Example: patrol_nodes = array_reverse( patrol_nodes );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_reverse( array )
{
	array2 = [];
	for( i = array.size - 1; i >= 0; i -- )
		array2[ array2.size ] = array[ i ];
	return array2;
}

exploder_damage()
{
	if( isdefined( self.v[ "delay" ] ) )
		delay = self.v[ "delay" ];
	else
		delay = 0; 
		
	if( isdefined( self.v[ "damage_radius" ] ) )
		radius = self.v[ "damage_radius" ];
	else
		radius = 128; 

	damage = self.v[ "damage" ];
	origin = self.v[ "origin" ];
	
	wait( delay ); 
	// Range, max damage, min damage
	RadiusDamage( origin, radius, damage, damage ); 
}

exploder( num )
{
	[[ level.exploderFunction ]]( num );
}

exploder_before_load( num )
{
	// gotta wait twice because the createfx_init function waits once then inits all exploders. This guarentees
	// that if an exploder is run on the first frame, it happens after the fx are init.
	waittillframeend; 
	waittillframeend; 
	activate_exploder( num ); 
}

exploder_after_load( num )
{
	activate_exploder( num ); 
}

activate_exploder_on_clients(num)
{

	if(!isdefined(level._exploder_ids[num]))
		return;

	if(!isdefined(level._client_exploders[num]))
	{
		level._client_exploders[num] = 1;
	}
	
	if(!isdefined(level._client_exploder_ids[num]))
	{
		level._client_exploder_ids[num] = 1;
	}	

	ActivateClientExploder(level._exploder_ids[num]);
}

delete_exploder_on_clients(num)
{
	if(!isdefined(level._exploder_ids[num]))
		return;
	
	
	if(!isdefined(level._client_exploders[num]))
	{
		return;
	}
	
	level._client_exploders[num] = undefined;

	level._client_exploder_ids[num] = undefined;
	
	DeactivateClientExploder(level._exploder_ids[num]);
}

activate_exploder( num )
{
	num = int( num ); 
	
	client_send = true;
	
	prof_begin( "activate_exploder" );
	for( i = 0;i < level.createFXent.size;i ++ )
	{
		ent = level.createFXent[ i ];
		if( !IsDefined( ent ) )
			continue;
	
		if( ent.v[ "type" ] != "exploder" )
			continue; 	
	
		// make the exploder actually removed the array instead?
		if( !isdefined( ent.v[ "exploder" ] ) )
			continue; 

		if( ent.v[ "exploder" ] != num )
			continue; 

		if(isdefined(ent.v["exploder_server"]))
		{
			client_send = false;
		}

		ent activate_individual_exploder();
		
	}
	
	if(level.clientScripts)
	{
		if(!level.createFX_enabled && client_send == true)
		{
			activate_exploder_on_clients(num);
		}
	}	
	
	prof_end( "activate_exploder" );
}

stop_exploder( num )
{
	num = int( num );
	
	if(level.clientScripts)
	{
		if(!level.createFX_enabled)
		{
			delete_exploder_on_clients(num);
		}
	}
	
	for( i = 0;i < level.createFXent.size;i ++ )
	{
		ent = level.createFXent[ i ];
		if( !IsDefined( ent ) )
			continue; 
	
		if( ent.v[ "type" ] != "exploder" )
			continue; 

		// make the exploder actually removed the array instead?
		if( !isdefined( ent.v[ "exploder" ] ) )
			continue;

		if( ent.v[ "exploder" ] != num )
			continue;
	
		if ( !isdefined( ent.looper ) )
			continue;

		ent.looper delete();
	}
}

/*
=============
///ScriptDocBegin
"Name: activate_individual_exploder()"
"Summary: Activates an individual exploder, rather than all the exploders of a given number"
"Module: Utility"
"CallOn: An exploder"
"Example: exploder activate_individual_exploder();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
	
activate_individual_exploder()
{
	// CODER_MOD : DSL - Contents of if statement created on client.
	
	if(level.createFX_enabled || !level.clientScripts || !isdefined(level._exploder_ids[int(self.v["exploder"])] ) || isdefined(self.exploder_server))
	{
/#		
		println("Exploder " + self.v["exploder"] + " created on server.");
#/		
		if( isdefined( self.v[ "firefx" ] ) )
			self thread fire_effect();
	
		if( isdefined( self.v[ "fxid" ] ) && self.v[ "fxid" ] != "No FX" )
			self thread cannon_effect();
		else
		if( isdefined( self.v[ "soundalias" ] ) )
			self thread sound_effect();

		if( isdefined( self.v[ "earthquake" ] ) )
			self thread exploder_earthquake();
	
		if( isdefined( self.v[ "rumble" ] ) )
			self thread exploder_rumble();
	}

	// CODER_MOD : DSL - Stuff below here happens on the server.

	if( IsDefined( self.v[ "trailfx" ] ) )
	{
		self thread trail_effect();
	}

	if( isdefined( self.v[ "damage" ] ) )
		self thread exploder_damage();

	if( self.v[ "exploder_type" ] == "exploder" )
		self thread brush_show();
	else
	if( ( self.v[ "exploder_type" ] == "exploderchunk" ) || ( self.v[ "exploder_type" ] == "exploderchunk visible" ) )
		self thread brush_throw();
	else
		self thread brush_delete();
}



loop_sound_Delete( ender, ent )
{
	ent endon( "death" ); 
	self waittill( ender ); 
	ent Delete(); 
}

loop_fx_sound( alias, origin, ender, timeout )
{
	org = Spawn( "script_origin", ( 0, 0, 0 ) ); 
	if( IsDefined( ender ) )
	{
		thread loop_sound_Delete( ender, org ); 
		self endon( ender ); 
	}
	org.origin = origin; 
	org PlayLoopSound( alias ); 
	if( !IsDefined( timeout ) )
		return; 
		
	wait( timeout ); 
//	org Delete(); 
}

brush_Delete()
{
// 		if( ent.v[ "exploder_type" ] != "normal" && !isdefined( ent.v[ "fxid" ] ) && !isdefined( ent.v[ "soundalias" ] ) )
// 		if( !isdefined( ent.script_fxid ) )

	num = self.v[ "exploder" ];
	if( isdefined( self.v[ "delay" ] ) )
		wait( self.v[ "delay" ] );
	else
		wait( .05 );// so it disappears after the replacement appears

	if( !IsDefined( self.model ) )
		return; 


	assert( IsDefined( self.model ) ); 

	if( self.model.spawnflags & 1 )
		self.model ConnectPaths(); 

	if( level.createFX_enabled )
	{
		if( IsDefined( self.exploded ) )
			return; 
			
		self.exploded = true; 
		self.model Hide(); 
		self.model NotSolid(); 
		
		wait( 3 ); 
		self.exploded = undefined; 
		self.model Show(); 
		self.model Solid(); 
		return; 
	}

	if( !isdefined( self.v[ "fxid" ] ) || self.v[ "fxid" ] == "No FX" )
		self.v[ "exploder" ] = undefined;
		
	waittillframeend;// so it hides stuff after it shows the new stuff
	self.model Delete(); 
}

brush_Show()
{
	if( isdefined( self.v[ "delay" ] ) )
		wait( self.v[ "delay" ] );
	
	assert( IsDefined( self.model ) ); 
	
	self.model Show(); 
	self.model Solid(); 
		
	if( self.model.spawnflags & 1 )
	{
		if( !IsDefined( self.model.disconnect_paths ) )
			self.model ConnectPaths(); 
		else
			self.model DisconnectPaths(); 
		}

	if( level.createFX_enabled )
	{
		if( IsDefined( self.exploded ) )
			return; 

		self.exploded = true; 
		wait( 3 ); 
		self.exploded = undefined; 
		self.model Hide(); 
		self.model NotSolid(); 
	}
}

brush_throw()
{
	if( isdefined( self.v[ "delay" ] ) )
		wait( self.v[ "delay" ] );

	ent = undefined; 
	if( isdefined( self.v[ "target" ] ) )
		ent = getent( self.v[ "target" ], "targetname" );

	if( !IsDefined( ent ) )
	{
		ent = GetStruct( self.v["target"], "targetname" );

		if( !IsDefined( ent ) )
		{
			self.model Delete(); 
			return; 
		}
	}

	self.model Show(); 

	startorg = self.v[ "origin" ];
	startang = self.v[ "angles" ];
	org = ent.origin; 


	temp_vec = ( org - self.v[ "origin" ] );
	x = temp_vec[ 0 ];
	y = temp_vec[ 1 ];
	z = temp_vec[ 2 ];

	physics = isdefined( self.v[ "physics" ] );
	if ( physics )
	{
		target = undefined;
		if ( isdefined( ent.target ) )
			target = getent( ent.target, "targetname" );
		
		if ( !isdefined( target ) )
		{
			contact_point = startorg;// no spin just push it.
			throw_vec = ent.origin;
		}
		else
		{
			contact_point = ent.origin;
			throw_vec = vector_multiply(target.origin - ent.origin, self.v[ "physics" ]);

		}
		
// 		model = spawn( "script_model", startorg );
// 		model.angles = startang;
// 		model physicslaunch( model.origin, temp_vec );
		self.model physicslaunch( contact_point, throw_vec );
		return;
	}
	else
	{
	self.model RotateVelocity( ( x, y, z ), 12 ); 
		self.model moveGravity( ( x, y, z ), 12 );
	}


	if( level.createFX_enabled )
	{
		if( IsDefined( self.exploded ) )
			return; 

		self.exploded = true; 
		wait( 3 ); 
		self.exploded = undefined; 
		self.v[ "origin" ] = startorg;
		self.v[ "angles" ] = startang;
		self.model Hide(); 
		return; 
	}
	
	self.v[ "exploder" ] = undefined;
	wait( 6 ); 
	self.model Delete(); 
//	self Delete(); 
}

flood_Spawn( spawners )
{
	maps\_spawner::flood_spawner_scripted( spawners ); 
}

vector_multiply( vec, dif )
{
	vec = ( vec[ 0 ] * dif, vec[ 1 ] * dif, vec[ 2 ] * dif );
	return vec; 
}

set_ambient( track )
{
	level.ambient = track; 
	if( ( isdefined( level.ambient_track ) ) && ( isdefined( level.ambient_track[ track ] ) ) )
	{
		ambientPlay( level.ambient_track[ track ], 2 );
		println( "playing ambient track ", track ); 
	}
}

random( array )
{
	return array [ randomint( array.size ) ];
}

get_friendly_chain_node( chainstring )
{
	chain = undefined; 
	trigger = GetEntArray( "trigger_friendlychain", "classname" ); 
	for( i = 0;i < trigger.size;i ++ )
	{
		if( ( isdefined( trigger[ i ].script_chain ) ) && ( trigger[ i ].script_chain == chainstring ) )
		{
			chain = trigger[ i ];
			break; 
		}
	}

	if( !IsDefined( chain ) )
	{
 /#
		maps\_utility::error( "Tried to get chain " + chainstring + " which does not exist with script_chain on a trigger." ); 
#/
		return undefined; 
	}

	node = GetNode( chain.target, "targetname" ); 
	return node; 
}

shock_onpain()
{
	self endon( "death" ); 
	self endon( "disconnect" ); 

	if( GetDvar( "blurpain" ) == "" )
	{
		SetDvar( "blurpain", "on" ); 
	}

	while( 1 )
	{
		oldhealth = self.health; 
		self waittill( "damage", damage, attacker, direction_vec, point, mod ); 

		if( IsDefined( level.shock_onpain ) && !level.shock_onpain )
		{
			continue;
		}

		if( IsDefined( self.shock_onpain ) && !self.shock_onpain )
		{
			continue;
		}

		if( self.health < 1 )
		{
			continue;
		}

		if( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" )
		{
			continue;
		}
		else if( mod == "MOD_GRENADE_SPLASH" || mod == "MOD_GRENADE" ||  mod == "MOD_EXPLOSIVE" )
		{
			self shock_onexplosion( damage );
		}
		else
		{
			if( GetDvar( "blurpain" ) == "on" )
			{
				self ShellShock( "pain", 0.5 ); 
			}
		}
	}
}

shock_onexplosion( damage )
{
	time = 0; 

	multiplier = self.maxhealth / 100; 
	scaled_damage = damage * multiplier;
	
	if( scaled_damage >= 90 )
	{
		time = 4; 
	}
	else if( scaled_damage >= 50 )
	{
		time = 3; 
	}
	else if( scaled_damage >= 25 )
	{
		time = 2; 
	}
	else if( scaled_damage > 10 )
	{
		time = 1; 
	}
	
	if( time )
	{
		self ShellShock( "explosion", time );
	}
}

shock_ondeath()
{
	// CODE_MOD
	// moved to _load::main so hot joiners would not try and 
	// precache mid game
	//precacheShellshock( "default" );
	self waittill( "death" ); 

	if( IsDefined( level.shock_ondeath ) && !level.shock_ondeath )
	{
		return;
	}

	if( IsDefined( self.shock_ondeath ) && !self.shock_ondeath )
	{
		return;
	}
	
	if( isdefined( self.specialDeath ) )
		return;
	
	if( getdvar( "r_texturebits" ) == "16" )
		return; 
	//self shellshock( "default", 3 );
}

delete_on_death( ent )
{
	ent endon( "death" ); 
	self waittill( "death" ); 
	if( IsDefined( ent ) )
		ent delete();
}


delete_on_death_wait_sound( ent, sounddone )
{
	ent endon( "death" );
	self waittill( "death" );
	if( isdefined( ent ) )
	{
		if ( ent iswaitingonsound() )
			ent waittill( sounddone );
		
		ent Delete(); 
	}
}

is_dead_sentient()
{
	return isSentient( self ) && !isalive( self );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: play_sound_on_tag( <alias> , <tag>, <ends_on_death> )"
"Summary: Play the specified sound alias on a tag of an entity"
"Module: Sound"
"CallOn: An entity"
"MandatoryArg: <alias> : Sound alias to play"
"OptionalArg: <tag> : Tag on the entity to play sound on. If no tag is specified the entities origin will be used."
"OptionalArg: <ends_on_death> : The sound will be cut short if the entity dies. Defaults to false."
"Example: vehicle thread play_sound_on_tag( "horn_honk", "tag_engine" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
play_sound_on_tag( alias, tag, ends_on_death )
{
	if ( is_dead_sentient() )
		return; 

	org = Spawn( "script_origin", ( 0, 0, 0 ) ); 
	org endon( "death" ); 

	thread delete_on_death_wait_sound( org, "sounddone" );
	if ( isdefined( tag ) )
		org LinkTo( self, tag, ( 0, 0, 0 ), ( 0, 0, 0 ) ); 
	else
	{
		org.origin = self.origin; 
		org.angles = self.angles; 
		org LinkTo( self ); 
	}

	org PlaySound( alias, "sounddone" ); 
	if ( isdefined( ends_on_death ) )
	{
		assertex( ends_on_death, "ends_on_death must be true or undefined" );
		wait_for_sounddone_or_death( org );
		if(is_dead_sentient())
		  org StopSounds();
		wait( 0.05 ); // stopsounds doesnt work if the org is deleted same frame
	}
	else
	{
	org waittill( "sounddone" ); 
	}
	org Delete(); 
}


/* 
============= 
///ScriptDocBegin
"Name: play_sound_on_tag_endon_death( <alias>, <tag> )"
"Summary: Play the specified sound alias on a tag of an entity but gets cut short if the entity dies"
"Module: Sound"
"CallOn: An entity"
"MandatoryArg: <alias> : Sound alias to play"
"OptionalArg: <tag> : Tag on the entity to play sound on. If no tag is specified the entities origin will be used."
"Example: vehicle thread play_sound_on_tag_endon_death( "horn_honk", "tag_engine" );"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 
play_sound_on_tag_endon_death( alias, tag )
{
	play_sound_on_tag( alias, tag, true );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: play_sound_on_entity( <alias> )"
"Summary: Play the specified sound alias on an entity at it's origin"
"Module: Sound"
"CallOn: An entity"
"MandatoryArg: <alias> : Sound alias to play"
"Example: level.player play_sound_on_entity( "breathing_better" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
play_sound_on_entity( alias )
{
	play_sound_on_tag( alias );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: play_loop_sound_on_tag( <alias> , <tag>, bStopSoundOnDeath )"
"Summary: Play the specified looping sound alias on a tag of an entity"
"Module: Sound"
"CallOn: An entity"
"MandatoryArg: <alias> : Sound alias to loop"
"OptionalArg: <tag> : Tag on the entity to play sound on. If no tag is specified the entities origin will be used."
"OptionalArg: <bStopSoundOnDeath> : Defaults to true. If true, will stop the looping sound when self dies"
"Example: vehicle thread play_loop_sound_on_tag( "engine_belt_run", "tag_engine" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
play_loop_sound_on_tag( alias, tag, bStopSoundOnDeath )
{
	org = Spawn( "script_origin", ( 0, 0, 0 ) ); 
	org endon( "death" ); 
	if ( !isdefined( bStopSoundOnDeath ) )
		bStopSoundOnDeath = true;
	if ( bStopSoundOnDeath )
	thread delete_on_death( org ); 
	if( IsDefined( tag ) )
		org LinkTo( self, tag, ( 0, 0, 0 ), ( 0, 0, 0 ) ); 
	else
	{
		org.origin = self.origin; 
		org.angles = self.angles; 
		org LinkTo( self ); 
	}
//	org endon( "death" ); 
	org PlayLoopSound( alias ); 
//	println( "playing loop sound ", alias, " on entity at origin ", self.origin, " at ORIGIN ", org.origin ); 
	self waittill( "stop sound" + alias ); 
	org StopLoopSound( alias ); 
	org Delete(); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: stop_loop_sound_on_entity( <alias> )"
"Summary: Stop playing the the loop sound alias on an entity"
"Module: Sound"
"CallOn: An entity"
"MandatoryArg: <alias> : Sound alias to stop looping"
"Example: vehicle thread stop_loop_sound_on_entity( "engine_belt_run" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
stop_loop_sound_on_entity( alias )
{
	self notify( "stop sound" + alias );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: play_loop_sound_on_entity( <alias> , <offset> )"
"Summary: Play loop sound alias on an entity"
"Module: Sound"
"CallOn: An entity"
"MandatoryArg: <alias> : Sound alias to loop"
"OptionalArg: <offset> : Offset for sound origin relative to the world from the models origin."
"Example: vehicle thread play_loop_sound_on_entity( "engine_belt_run" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
play_loop_sound_on_entity( alias, offset )
{
	org = Spawn( "script_origin", ( 0, 0, 0 ) ); 
	org endon( "death" ); 
	thread delete_on_death( org ); 
	if( IsDefined( offset ) )
	{
		org.origin = self.origin + offset; 
		org.angles = self.angles; 
		org LinkTo( self ); 
	}
	else
	{
		org.origin = self.origin; 
		org.angles = self.angles; 
		org LinkTo( self ); 
	}
//	org endon( "death" ); 
	org PlayLoopSound( alias ); 
//	println( "playing loop sound ", alias, " on entity at origin ", self.origin, " at ORIGIN ", org.origin ); 
	self waittill( "stop sound" + alias ); 
	org StopLoopSound( alias ); 
	org Delete(); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: play_sound_in_space( <alias> , <origin> , <master> )"
"Summary: Stop playing the the loop sound alias on an entity"
"Module: Sound"
"CallOn: Level"
"MandatoryArg: <alias> : Sound alias to play"
"MandatoryArg: <origin> : Origin of the sound"
"OptionalArg: <master> : Play this sound as a master sound. Defaults to false"
"Example: play_sound_in_space( "siren", level.speaker.origin );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
play_sound_in_space( alias, origin, master )
{
	org = Spawn( "script_origin", ( 0, 0, 1 ) ); 
	
	if( !IsDefined( origin ) )
		origin = self.origin; 
	org.origin = origin; 
	if( IsDefined( master ) && master )
		org PlaySoundAsMaster( alias, "sounddone" ); 
	else
		org PlaySound( alias, "sounddone" ); 
	org waittill( "sounddone" ); 
	
	// 5/29/08 - guzzo added b/c sometimes org can undefined and will cause a crash when it's deleted
	if( isdefined( org ) )
	{
		org Delete(); 
	}
	
}

lookat( ent, timer )
{
	if( !IsDefined( timer ) )
		timer = 10000; 

	self animscripts\shared::lookatentity( ent, timer, "alert" ); 
}

save_friendlies()
{
	ai = GetAiArray( "allies" ); 
	game_characters = 0; 
	for( i = 0;i < ai.size;i ++ )
		{
		if( isdefined( ai[ i ].script_friendname ) )
			continue; 

//		attachsize = 
//		println( "attachSize = ", self GetAttachSize() ); 

		game[ "character" + game_characters ] = ai[ i ] codescripts\character::save();
		game_characters ++ ;
	}

	game[ "total characters" ] = game_characters;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: spawn_failed( <spawn> )"
"Summary: Checks to see if the spawned AI spawned correctly or had errors. Also waits until all spawn initialization is complete. Returns true or false."
"Module: AI"
"CallOn: "
"MandatoryArg: <spawn> : The actor that just spawned"
"Example: spawn_failed( level.price );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
spawn_failed( spawn )
{
	if( !IsAlive( spawn ) )
		return true; 
	if( !IsDefined( spawn.finished_spawning ) )
		spawn waittill( "finished spawning" ); 

	if( IsAlive( spawn ) )
		return false; 

	return true; 
}

spawn_setcharacter( data )
{
	codescripts\character::precache( data ); 

	self waittill( "spawned", spawn ); 
	if( maps\_utility::spawn_failed( spawn ) )
		return; 

	println( "Size is ", data[ "attach" ].size );
	spawn codescripts\character::new(); 
	spawn codescripts\character::load( data ); 
}

key_hint_print( message, binding )
{
	// Note that this will insert only the first bound key for the action
	iprintlnbold( message, binding[ "key1" ] );
}

view_tag( tag )
{
	self endon( "death" ); 
//	for( ;; )
//	{
//		maps\_debug::drawTag( tag ); 
//		wait( 0.05 ); 
//	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: assign_animtree( <animname> )"
"Summary: Assigns the level.scr_animtree for the given animname to self."
"Module: _anim"
"OptionalArg: <animname> : You can optionally assign the animname for self at this juncture."
"Example: model = assign_animtree( "whatever" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

assign_animtree( animname )
{
	if( isdefined( animname ) )
		self.animname = animname;
		
	assertEx( isdefined( level.scr_animtree[ self.animname ] ), "There is no level.scr_animtree for animname " + self.animname );
	self UseAnimTree( level.scr_animtree[ self.animname ] );
}

assign_model()
{
	assertEx( isdefined( level.scr_model[ self.animname ] ), "There is no level.scr_model for animname " + self.animname );
	self setmodel( level.scr_model[ self.animname ] );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: spawn_anim_model( <animname>, <origin> )"
"Summary: Spawns a script model and gives it the animtree and model associated with that animname"
"Module: _anim"
"MandatoryArg: <animname> : Name of the animname from this map_anim.gsc."
"OptionalArg: <origin> : Optional origin."
"Example: model = spawn_anim_model( "player_rappel" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

spawn_anim_model( animname, origin )
{
	if ( !isdefined( origin ) )
		origin = ( 0, 0, 0 );
	model = spawn( "script_model", origin );
	model.animname = animname;
	model assign_animtree();
	model assign_model();
	return model;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: trigger_wait( <strName> , <strKey> )"
"Summary: Waits until a trigger with the specified key / value is triggered"
"Module: Trigger"
"CallOn: "
"MandatoryArg: <strName> : Name of the key on this trigger"
"MandatoryArg: <strKey> : Key on the trigger to use, example: "targetname" or "script_noteworthy""
"Example: trigger_wait( "player_in_building1, "targetname" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
trigger_wait( strName, strKey )
{
	eTrigger = GetEnt( strName, strKey ); 
	if( !IsDefined( eTrigger ) )
	{
		assertmsg( "trigger not found: " + strName + " key: " + strKey ); 
		return; 
	}
	eTrigger waittill( "trigger", eOther ); 
	level notify( strName, eOther ); 
	return eOther; 
}

trigger_wait_targetname( strName )
{
	eTrigger = getent( strName, "targetname" );
	if( !isdefined( eTrigger ) )
	{
		assertmsg( "trigger not found: " + strName + " targetname ");
		return;
	}
	eTrigger waittill( "trigger", eOther );
	level notify( strName, eOther );
	return eOther;
}


 /* 
 ============= 
///ScriptDocBegin
"Name: set_flag_on_trigger( <eTrigger> , <strFlag> )"
"Summary: Calls flag_set to set the specified flag when the trigger is triggered"
"Module: Trigger"
"CallOn: "
"MandatoryArg: <eTrigger> : trigger entity to use"
"MandatoryArg: <strFlag> : name of the flag to set"
"Example: set_flag_on_trigger( trig, "player_is_outside" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_flag_on_trigger( eTrigger, strFlag )
{
	if( !level.flag[ strFlag ] )
	{
		eTrigger waittill( "trigger", eOther ); 
		flag_set( strFlag ); 
		return eOther; 
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_flag_on_targetname_trigger( <flag> )"
"Summary: Sets the specified flag when a trigger with targetname < flag > is triggered."
"Module: Trigger"
"CallOn: "
"MandatoryArg: <flag> : name of the flag to set, and also the targetname of the trigger to use"
"Example:  set_flag_on_targetname_trigger( "player_is_outside" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_flag_on_targetname_trigger( msg )
{
	assert( isdefined( level.flag[ msg ] ) );
	if( flag( msg ) )
		return; 
		
	trigger = GetEnt( msg, "targetname" ); 
	trigger waittill( "trigger" ); 
	flag_set( msg ); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: is_in_array( <aeCollection> , <eFindee> )"
"Summary: Returns true if < eFindee > is an entity in array < aeCollection > . False if it is not. "
"Module: Array"
"CallOn: "
"MandatoryArg: <aeCollection> : array of entities to search through"
"MandatoryArg: <eFindee> : entity to check if it's in the array"
"Example: qBool = is_in_array( eTargets, vehicle1 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
is_in_array( aeCollection, eFindee )
{
	for( i = 0; i < aeCollection.size; i ++ )
		{
		if( aeCollection[ i ] == eFindee )
			return( true ); 
		}
	
	return( false ); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: waittill_dead( <guys> , <num> , <timeoutLength> )"
"Summary: Waits until all the AI in array < guys > are dead."
"Module: AI"
"CallOn: "
"MandatoryArg: <guys> : Array of actors to wait until dead"
"OptionalArg: <num> : Number of guys that must die for this function to continue"
"OptionalArg: <timeoutLength> : Number of seconds before this function times out and continues"
"Example: waittill_dead( getaiarray( "axis" ) );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
waittill_dead( guys, num, timeoutLength )
{
	// verify the living - ness of the ai
	allAlive = true; 
	for( i = 0;i < guys.size;i ++ )
		{
		if( isalive( guys[ i ] ) )
			continue; 
		allAlive = false; 
		break; 
	}
	assertex( allAlive, "Waittill_Dead was called with dead or removed AI in the array, meaning it will never pass." ); 
	if( !allAlive )
	{	
		newArray = []; 
		for( i = 0;i < guys.size;i ++ )
		{
			if( isalive( guys[ i ] ) )
				newArray[ newArray.size ] = guys[ i ];
		}
		guys = newArray; 
	}

	ent = SpawnStruct(); 
	if( IsDefined( timeoutLength ) )
	{
		ent endon( "thread_timed_out" );
		ent thread waittill_dead_timeout( timeoutLength ); 
	}
	
	ent.count = guys.size; 
	if( IsDefined( num ) && num < ent.count )
		ent.count = num; 
	array_thread( guys, ::waittill_dead_thread, ent ); 
	
	while( ent.count > 0 )
		ent waittill( "waittill_dead guy died" );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: waittill_dead_or_dying( <guys> , <num> , <timeoutLength> )"
"Summary: Similar to waittill_dead(). Waits until all the AI in array < guys > are dead OR dying (long deaths)."
"Module: AI"
"CallOn: "
"MandatoryArg: <guys> : Array of actors to wait until dead or dying"
"OptionalArg: <num> : Number of guys that must die or be dying for this function to continue"
"OptionalArg: <timeoutLength> : Number of seconds before this function times out and continues"
"Example: waittill_dead_or_dying( getaiarray( "axis" ) );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
waittill_dead_or_dying( guys, num, timeoutLength )
{
	// verify the living - ness and healthy - ness of the ai
	newArray = [];
	for( i = 0;i < guys.size;i ++ )
	{
		if( isalive( guys[ i ] ) && !guys[ i ].ignoreForFixedNodeSafeCheck )
			newArray[ newArray.size ] = guys[ i ];
	}
	guys = newArray;

	ent = spawnStruct();
	if( isdefined( timeoutLength ) )
	{
		ent endon( "thread_timed_out" );
		ent thread waittill_dead_timeout( timeoutLength );
	}
	
	ent.count = guys.size;
	
	// optional override on count
	if( isdefined( num ) && num < ent.count )
		ent.count = num;
		
	array_thread( guys, ::waittill_dead_or_dying_thread, ent );
	
	while( ent.count > 0 )
		ent waittill( "waittill_dead_guy_dead_or_dying" );
}

waittill_dead_thread( ent )
{
	self waittill( "death" ); 
	ent.count-- ;
	ent notify( "waittill_dead guy died" ); 
}

waittill_dead_or_dying_thread( ent )
{
	self waittill_either( "death", "pain_death" );
	ent.count-- ;
	ent notify( "waittill_dead_guy_dead_or_dying" );
}

waittill_dead_timeout( timeoutLength )
{
	wait( timeoutLength ); 
	self notify( "thread_timed_out" );
}

waittill_aigroupcleared( aigroup )
{
	while( level._ai_group[ aigroup ].spawnercount || level._ai_group[ aigroup ].aicount )
		wait( 0.25 );
}

waittill_aigroupcount( aigroup, count )
{
	while( level._ai_group[ aigroup ].spawnercount + level._ai_group[ aigroup ].aicount > count )
		wait( 0.25 );
}

get_ai_group_count( aigroup )
{
	return( level._ai_group[ aigroup ].spawnercount + level._ai_group[ aigroup ].aicount );
}

get_ai_group_sentient_count( aigroup )
{
	return( level._ai_group[ aigroup ].aicount );
}

get_ai_group_ai( aigroup )
{
	aiSet = []; 
	for( index = 0; index < level._ai_group[ aigroup ].ai.size; index ++ )
	{
		if( !isAlive( level._ai_group[ aigroup ].ai[ index ] ) )
			continue;
			
		aiSet[ aiSet.size ] = level._ai_group[ aigroup ].ai[ index ];
	}
	
	return( aiSet );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_living_ai( <name> , <type> )"
"Summary: Returns single spawned ai in the level of <name> and <type>. Error if used on more than one ai with same name and type "
"Module: AI"
"CallOn: "
"MandatoryArg: <name> : the value of the targetname or script_noteworthy of the ai"
"MandatoryArg: <type> : valid types are targetname and script_noteworthy"
"Example: patroller = get_living_ai( "patrol", "script_noteworthy" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_living_ai( name, type )
{
	array = get_living_ai_array( name, type );
	if( array.size > 1 )
	{
		assertMsg( "get_living_ai used for more than one living ai of type " + type + " called " + name + "." );
		return undefined;
	}
	return array[0];
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_living_ai_array( <name> , <type> )"
"Summary: Returns array of spawned ai in the level of <name> and <type> "
"Module: AI"
"CallOn: "
"MandatoryArg: <name> : the value of the targetname or script_noteworthy of the ai"
"MandatoryArg: <type> : valid types are targetname, classname and script_noteworthy"
"Example: patrollers = get_living_ai_array( "patrol", "script_noteworthy" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_living_ai_array(name, type)
{
	ai = getaiarray("allies");
	ai = array_combine(ai, getaiarray("axis") );
	
	array = [];
	for(i=0; i<ai.size; i++)
	{
		switch(type)
		{
			case "targetname":{
				if(isdefined(ai[i].targetname) && ai[i].targetname == name)
					array[array.size] = ai[i];	
			}break;	
		 	case "script_noteworthy":{
				if(isdefined(ai[i].script_noteworthy) && ai[i].script_noteworthy == name)
					array[array.size] = ai[i];
			}break;
			case "classname":{
				if(isdefined(ai[i].classname) && ai[i].classname == name)
					array[array.size] = ai[i];
			}break;
		}
	}
	return array;
}
			
 /* 
 ============= 
///ScriptDocBegin
"Name: get_living_aispecies( <name> , <type>, <breed> )"
"Summary: Returns single spawned ai in the level of <name> and <type>. Error if used on more than one ai with same name and type "
"Module: AI"
"CallOn: "
"MandatoryArg: <name> : the value of the targetname or script_noteworthy of the ai"
"MandatoryArg: <type> : valid types are targetname and script_noteworthy"
"OptionalArg: <bread> : the breadof spieces, if none is given, defaults to 'all' "
"Example: patroller = get_living_aispecies( "patrol", "script_noteworthy", "dog" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_living_aispecies( name, type, breed )
{
	array = get_living_ai_array( name, type, breed );
	if( array.size > 1 )
	{
		assertMsg( "get_living_aispecies used for more than one living ai of type " + type + " called " + name + "." );
		return undefined;
	}
	return array[0];
}
	
 /* 
 ============= 
///ScriptDocBegin
"Name: get_living_aispecies_array( <name> , <type>, <breed> )"
"Summary: Returns array of spawned ai of any speices in the level of <name>, <type>, and <breed> "
"Module: AI"
"CallOn: "
"MandatoryArg: <name> : the value of the targetname or script_noteworthy of the ai"
"MandatoryArg: <type> : valid types are targetname and script_noteworthy"
"OptionalArg: <bread> : the breadof spieces, if none is given, defaults to 'all' "
"Example: patrollers = get_living_aispecies_array( "patrol", "script_noteworthy", "dog" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_living_aispecies_array(name, type, breed)
{
	if( !isdefined( breed ) )
		breed = "all";
		
	ai = getaispeciesarray("allies", breed);
	ai = array_combine(ai, getaispeciesarray("axis", breed) );
	
	array = [];
	for(i=0; i<ai.size; i++)
	{
		switch(type)
		{
			case "targetname":{
				if(isdefined(ai[i].targetname) && ai[i].targetname == name)
					array[array.size] = ai[i];	
			}break;	
		 	case "script_noteworthy":{
				if(isdefined(ai[i].script_noteworthy) && ai[i].script_noteworthy == name)
					array[array.size] = ai[i];
			}break;
		}
	}
	return array;
}

// Creates an event based on this message if none exists, and sets it to true after the delay.
gather_delay_proc( msg, delay )
{
	if( isdefined( level.gather_delay[ msg ] ) )
	{
		if( level.gather_delay[ msg ] )
		{
			wait( 0.05 ); 
			if( IsAlive( self ) )
				self notify( "gather_delay_finished" + msg + delay ); 
			return; 
		}
		
		level waittill( msg ); 
		if( IsAlive( self ) )
			self notify( "gather_delay_finished" + msg + delay ); 
		return; 
	}
	
	level.gather_delay[ msg ] = false;
	wait( delay ); 
	level.gather_delay[ msg ] = true;
	level notify( msg ); 
	if( IsAlive( self ) )
		self notify( "gather_delay_finished" + msg + delay ); 
}

gather_delay( msg, delay )
{
	thread gather_delay_proc( msg, delay ); 
	self waittill( "gather_delay_finished" + msg + delay ); 
}

set_environment( env )
{
	animscripts\utility::setEnv( env ); 
}

death_waiter( notifyString )
{
	self waittill( "death" ); 
	level notify( notifyString ); 
}

getchar( num )
{
	if( num == 0 )
		return "0"; 
	if( num == 1 )
		return "1"; 
	if( num == 2 )
		return "2"; 
	if( num == 3 )
		return "3"; 
	if( num == 4 )
		return "4"; 
	if( num == 5 )
		return "5"; 
	if( num == 6 )
		return "6"; 
	if( num == 7 )
		return "7"; 
	if( num == 8 )
		return "8"; 
	if( num == 9 )
		return "9"; 
}

waittill_either( msg1, msg2 )
{
	self endon( msg1 ); 
	self waittill( msg2 ); 
}

getlinks_array( array, linkMap )// don't pass stuff through as an array of struct.linkname[] but only linkMap[]
{
	ents = []; 
	for( j = 0; j < array.size; j ++ )
	{
		node = array[ j ];
		script_linkname = node.script_linkname; 
		if( !IsDefined( script_linkname ) )
			continue; 
		if( !isdefined( linkMap[ script_linkname ] ) )
			continue; 
		ents[ ents.size ] = node;
	}
	return ents; 
}

// Adds only things that are new to the array.
// Requires the arrays to be of node with script_linkname defined.
array_merge_links( array1, array2 )
{
	if( !array1.size )
		return array2; 
	if( !array2.size )
		return array1; 

	linkMap = []; 

	for( i = 0; i < array1.size; i ++ )
	{
		node = array1[ i ];
		linkMap[ node.script_linkname ] = true;
	}

	for( i = 0; i < array2.size; i ++ )
		{
		node = array2[ i ];
		if( isdefined( linkMap[ node.script_linkname ] ) )
			continue; 
		linkMap[ node.script_linkname ] = true;
		array1[ array1.size ] = node;
	}

	return array1; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_combine( <array1> , <array2> )"
"Summary: Combines the two arrays and returns the resulting array. This function doesn't care if it produces duplicates in the array."
"Module: Array"
"CallOn: "
"MandatoryArg: <array1> : first array"
"MandatoryArg: <array2> : second array"
"Example: combinedArray = array_combine( array1, array2 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_combine( array1, array2 )
{
	if( !array1.size )
		return array2; 

	array3 = [];
	
	keys = getarraykeys( array1 );
	for( i = 0;i < keys.size;i ++ )
	{
		key = keys[ i ];
		array3[ array3.size ] = array1[ key ]; 
	}	

	keys = getarraykeys( array2 );
	for( i = 0;i < keys.size;i ++ )
	{
		key = keys[ i ];
		array3[ array3.size ] = array2[ key ];
	}
	
	return array3; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_merge( <array1> , <array2> )"
"Summary: Combines the two arrays and returns the resulting array. Adds only things that are new to the array, no duplicates."
"Module: Array"
"CallOn: "
"MandatoryArg: <array1> : first array"
"MandatoryArg: <array2> : second array"
"Example: combinedArray = array_merge( array1, array2 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_merge( array1, array2 )// adds only things that are new to the array
{
	if( array1.size == 0 )
		return array2; 
	if( array2.size == 0 )
		return array1; 
	newarray = array1; 
	for( i = 0;i < array2.size;i ++ )
	{
		foundmatch = false; 
		for( j = 0;j < array1.size;j ++ )
			if( array2[ i ] == array1[ j ] )
			{
				foundmatch = true; 
				break; 
			}
		if( foundmatch )
			continue; 
		else
			newarray[ newarray.size ] = array2[ i ];
	}
	return newarray; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_exclude( <array> , <arrayExclude> )"
"Summary: Returns an array excluding all members of < arrayExclude > "
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : Array containing all items"
"MandatoryArg: <arrayExclude> : Arary containing all items to remove"
"Example: newArray = array_exclude( array1, array2 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_exclude( array, arrayExclude )// returns "array" minus all members of arrayExclude
{
	newarray = array;
	for( i = 0;i < arrayExclude.size;i ++ )
	{
		if( is_in_array( array, arrayExclude[ i ] ) )
			newarray = array_remove( newarray, arrayExclude[ i ] );
	}
	
	return newarray;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: flat_angle( <angle> )"
"Summary: Returns the specified angle as a flat angle.( 45, 90, 30 ) becomes( 0, 90, 30 ). Useful if you just need an angle around Y - axis."
"Module: Vector"
"CallOn: "
"MandatoryArg: <angle> : angles to flatten"
"Example: yaw = flat_angle( node.angles );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
flat_angle( angle )
{
	rangle = ( 0, angle[ 1 ], 0 );
	return rangle; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: flat_origin( <org> )"
"Summary: Returns a flat origin of the specified origin. Moves Z corrdinate to 0.( x, y, z ) becomes( x, y, 0 )"
"Module: Vector"
"CallOn: "
"MandatoryArg: <org> : origin to flatten"
"Example: org = flat_origin( self.origin );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
flat_origin( org )
{
	rorg = ( org[ 0 ], org[ 1 ], 0 );
	return rorg; 

}

plot_points( plotpoints, r, g, b, timer )
{
	lastpoint = plotpoints[ 0 ];
	if( !IsDefined( r ) )
		r = 1; 
	if( !IsDefined( g ) )
		g = 1; 
	if( !IsDefined( b ) )
		b = 1; 
	if( !IsDefined( timer ) )
		timer = 0.05; 
	for( i = 1;i < plotpoints.size;i ++ )
	{
		thread draw_line_for_time( lastpoint, plotpoints[ i ], r, g, b, timer );
		lastpoint = plotpoints[ i ];	
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: draw_line_for_time( <org1> , <org2> , <r> , <g> , <b> , <timer> )"
"Summary: Draws a line from < org1 > to < org2 > in the specified color for the specified duration"
"Module: Debug"
"CallOn: "
"MandatoryArg: <org1> : starting origin for the line"
"MandatoryArg: <org2> : ending origin for the line"
"MandatoryArg: <r> : red color value( 0 to 1 )"
"MandatoryArg: <g> : green color value( 0 to 1 )"
"MandatoryArg: <b> : blue color value( 0 to 1 )"
"MandatoryArg: <timer> : time in seconds the line should last"
"Example: thread draw_line_for_time( player.origin, vehicle.origin, 1, 0, 0, 10.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
draw_line_for_time( org1, org2, r, g, b, timer )
{
	timer = gettime() + ( timer * 1000 );
	while( GetTime() < timer )
	{
		line( org1, org2, ( r, g, b ), 1 ); 
		wait .05;		
	}
	
}

 /* 
 ============= 
///ScriptDocBegin
"Name: draw_line_to_ent_for_time( <org1> , <ent> , <r> , <g> , <b> , <timer> )"
"Summary: Draws a line from < org1 > to < ent > origin in the specified color for the specified duration. Updates to the entities origin each frame."
"Module: Debug"
"CallOn: "
"MandatoryArg: <org1> : starting origin for the line"
"MandatoryArg: <ent> : entity to draw line to"
"MandatoryArg: <r> : red color value( 0 to 1 )"
"MandatoryArg: <g> : green color value( 0 to 1 )"
"MandatoryArg: <b> : blue color value( 0 to 1 )"
"MandatoryArg: <timer> : time in seconds the line should last"
"Example: thread draw_line_to_ent_for_time( level.player.origin, vehicle, 1, 0, 0, 10.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
draw_line_to_ent_for_time( org1, ent, r, g, b, timer )
{
	timer = gettime() + ( timer * 1000 );
	while( GetTime() < timer )
	{
		line( org1, ent.origin, ( r, g, b ), 1 ); 
		wait .05;		
	}
	
}

draw_line_from_ent_for_time( ent, org, r, g, b, timer )
{
	draw_line_to_ent_for_time( org, ent, r, g, b, timer );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: draw_line_from_ent_to_ent_for_time( <ent1> , <ent2> , <r> , <g> , <b> , <timer> )"
"Summary: Draws a line from one entity origin to another entity origin in the specified color for the specified duration. Updates to the entities origin each frame."
"Module: Debug"
"CallOn: "
"MandatoryArg: <ent1> : entity to draw line from"
"MandatoryArg: <ent2> : entity to draw line to"
"MandatoryArg: <r> : red color value( 0 to 1 )"
"MandatoryArg: <g> : green color value( 0 to 1 )"
"MandatoryArg: <b> : blue color value( 0 to 1 )"
"MandatoryArg: <timer> : time in seconds the line should last"
"Example: thread draw_line_from_ent_to_ent_for_time( level.player, vehicle, 1, 0, 0, 10.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
draw_line_from_ent_to_ent_for_time( ent1, ent2, r, g, b, timer )
{
	ent1 endon( "death" );
	ent2 endon( "death" );
	
	timer = gettime() + ( timer * 1000 );
	while( gettime() < timer )
	{
		line( ent1.origin, ent2.origin, ( r, g, b ), 1 ); 
		wait .05;		
	}
	
}

 /* 
 ============= 
///ScriptDocBegin
"Name: draw_line_from_ent_to_ent_until_notify( <ent1> , <ent2> , <r> , <g> , <b> , <notifyEnt> , <notifyString> )"
"Summary: Draws a line from one entity origin to another entity origin in the specified color until < notifyEnt > is notified < notifyString > . Updates to the entities origin each frame."
"Module: Debug"
"CallOn: "
"MandatoryArg: <ent1> : entity to draw line from"
"MandatoryArg: <ent2> : entity to draw line to"
"MandatoryArg: <r> : red color value( 0 to 1 )"
"MandatoryArg: <g> : green color value( 0 to 1 )"
"MandatoryArg: <b> : blue color value( 0 to 1 )"
"MandatoryArg: <notifyEnt> : entity that waits for the notify"
"MandatoryArg: <notifyString> : notify string that will make the line stop being drawn"
"Example: thread draw_line_from_ent_to_ent_until_notify( level.player, guy, 1, 0, 0, guy, "anim_on_tag_done" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
draw_line_from_ent_to_ent_until_notify( ent1, ent2, r, g, b, notifyEnt, notifyString )
{
	assert( isdefined( notifyEnt ) );
	assert( isdefined( notifyString ) );
	
	ent1 endon( "death" );
	ent2 endon( "death" );
	
	notifyEnt endon( notifyString );
	
	while( 1 )
	{
		line( ent1.origin, ent2.origin, ( r, g, b ), 0.05 );
		wait .05;		
	}
	
}

 /* 
 ============= 
///ScriptDocBegin
"Name: draw_line_until_notify( <org1> , <org2> , <r> , <g> , <b> , <notifyEnt> , <notifyString> )"
"Summary: Draws a line from < org1 > to < org2 > in the specified color until < notifyEnt > is notified < notifyString > "
"Module: Debug"
"CallOn: "
"MandatoryArg: <org1> : starting origin for the line"
"MandatoryArg: <org2> : ending origin for the line"
"MandatoryArg: <r> : red color value( 0 to 1 )"
"MandatoryArg: <g> : green color value( 0 to 1 )"
"MandatoryArg: <b> : blue color value( 0 to 1 )"
"MandatoryArg: <notifyEnt> : entity that waits for the notify"
"MandatoryArg: <notifyString> : notify string that will make the line stop being drawn"
"Example: thread draw_line_until_notify( self.origin, targetLoc, 1, 0, 0, self, "stop_drawing_line" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
draw_line_until_notify( org1, org2, r, g, b, notifyEnt, notifyString )
{
	assert( IsDefined( notifyEnt ) ); 
	assert( IsDefined( notifyString ) ); 
	
	notifyEnt endon( notifyString ); 
	
	while( 1 )
	{
		draw_line_for_time( org1, org2, r, g, b, 0.05 ); 	
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: draw_arrow_time( <start> , <end> , <color> , <duration> )"
"Summary: Draws an arrow pointing at < end > in the specified color for < duration > seconds."
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <start> : starting coordinate for the arrow"
"MandatoryArg: <end> : ending coordinate for the arrow"
"MandatoryArg: <color> :( r, g, b ) color array for the arrow"
"MandatoryArg: <duration> : time in seconds to draw the arrow"
"Example: thread draw_arrow_time( lasttarg.origin, targ.origin, ( 0, 0, 1 ), 5.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
draw_arrow_time( start, end, color, duration )
{
	level endon( "newpath" ); 
	pts = []; 
	angles = VectorToAngles( start - end ); 
	right = AnglesToRight( angles ); 
	forward = AnglesToForward( angles ); 
	up = AnglesToUp( angles ); 

	dist = Distance( start, end ); 
	arrow = []; 
	range = 0.1; 
		 	
	arrow[ 0 ] =  start;
	arrow[ 1 ] =  start + vectorScale( right, dist * ( range ) ) + vectorScale( forward, dist * - 0.1 );
	arrow[ 2 ] =  end;
	arrow[ 3 ] =  start + vectorScale( right, dist * ( - 1 * range ) ) + vectorScale( forward, dist * - 0.1 );

	arrow[ 4 ] =  start;
	arrow[ 5 ] =  start + vectorScale( up, dist * ( range ) ) + vectorScale( forward, dist * - 0.1 );
	arrow[ 6 ] =  end;
	arrow[ 7 ] =  start + vectorScale( up, dist * ( - 1 * range ) ) + vectorScale( forward, dist * - 0.1 );
	arrow[ 8 ] =  start;

	r = color[ 0 ];
	g = color[ 1 ];
	b = color[ 2 ];
	
	plot_points( arrow, r, g, b, duration ); 
}

draw_arrow( start, end, color )
{
	level endon( "newpath" ); 
	pts = []; 
	angles = VectorToAngles( start - end ); 
	right = AnglesToRight( angles ); 
	forward = AnglesToForward( angles ); 

	dist = Distance( start, end ); 
	arrow = []; 
	range = 0.05; 
	arrow[ 0 ] =  start;
	arrow[ 1 ] =  start + vectorScale( right, dist * ( range ) ) + vectorScale( forward, dist * - 0.2 );
	arrow[ 2 ] =  end;
	arrow[ 3 ] =  start + vectorScale( right, dist * ( - 1 * range ) ) + vectorScale( forward, dist * - 0.2 );

	for( p = 0;p < 4;p ++ )
	{
		nextpoint = p + 1;
		if( nextpoint >= 4 )
			nextpoint = 0; 
		line( arrow[ p ], arrow[ nextpoint ], color, 1.0 );
	}
}

clear_enemy_passthrough()
{
	self notify( "enemy" ); 
	self ClearEnemy(); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: battlechatter_off( <team> )"
"Summary: Disable battlechatter for the specified team"
"Module: Battlechatter"
"CallOn: "
"MandatoryArg: <team> : team to disable battlechatter on"
"Example: battlechatter_off( "allies" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
battlechatter_off( team )
{
	if( !IsDefined( level.battlechatter ) )
	{
		level.battlechatter = []; 
		level.battlechatter[ "axis" ] = true;
		level.battlechatter[ "allies" ] = true;
		level.battlechatter[ "neutral" ] = true;
	}

	if( IsDefined( team ) )
	{
		level.battlechatter[ team ] = false;
		soldiers = GetAiArray( team ); 
	}
	else
	{
		level.battlechatter[ "axis" ] = false;
		level.battlechatter[ "allies" ] = false;
		level.battlechatter[ "neutral" ] = false;
		soldiers = GetAiArray(); 
	}

	if( !IsDefined( anim.chatInitialized ) || !anim.chatInitialized )
		return; 

	for( index = 0; index < soldiers.size; index ++ )
	{
		if(!isdefined(team) || soldiers[index].team == team)
			soldiers[ index ].battlechatter = false;
	}

	had_to_wait = false;
	for( index = 0; index < soldiers.size; index ++ )
	{
		soldier = soldiers[ index ];
		if( !IsAlive( soldier ) )
			continue; 
			
		if( !soldier.chatInitialized )
			continue; 

		if( !soldier.isSpeaking )
			continue; 
			
		soldier wait_until_done_speaking(); 
		had_to_wait = true;
	}

	if( had_to_wait )
	{
		wait( 1.5 ); 
	}	
		
	if( IsDefined( team ) )
	{
		level notify( team + " done speaking" ); 
	}
	else
	{
		level notify( "done speaking" ); 
	}
}

 /* 
 ============= 
///ScriptDocBegin
"Name: battlechatter_on( <team> )"
"Summary: Enable battlechatter for the specified team"
"Module: Battlechatter"
"CallOn: "
"MandatoryArg: <team> : team to enable battlechatter on"
"Example: battlechatter_on( "allies" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
battlechatter_on( team )
{
	thread battlechatter_on_thread( team ); 
}

battlechatter_on_thread( team )
{

	if( !IsDefined( level.battlechatter ) && !isdefined(team))
	{
		level.battlechatter = []; 
		level.battlechatter[ "axis" ] = true;
		level.battlechatter[ "allies" ] = true;
		level.battlechatter[ "neutral" ] = true;
	}
	else if(!IsDefined( level.battlechatter ) && isdefined(team))
	{
		level.battlechatter = []; 
		level.battlechatter[ "axis" ] = false;
		level.battlechatter[ "allies" ] = false;
		level.battlechatter[ "neutral" ] = false;
		level.battlechatter[ team ] = true;

	}

	if( !anim.chatInitialized )
		return; 

	// buffer time
	wait( 1.5 ); 

	/*
	if((isdefined(team) && !level.battlechatter[ team ]) 
	|| (!level.battlechatter[ "axis" ] && !level.battlechatter[ "allies" ] && !level.battlechatter[ "neutral" ])
		)
	{
		animscripts\battlechatter::resetAllSayTimes();
	}
	*/
	
	if( IsDefined( team ) )
	{
		level.battlechatter[ team ] = true;
		soldiers = GetAiArray( team ); 
	}
	else
	{
		level.battlechatter[ "axis" ] = true;
		level.battlechatter[ "allies" ] = true;
		level.battlechatter[ "neutral" ] = true;
		soldiers = GetAiArray(); 
	}

	for( index = 0; index < soldiers.size; index ++ )
		soldiers[ index ] set_battlechatter( true );

}

set_battlechatter( state )
{
	if( !anim.chatInitialized )
		return; 

	if( self.type == "dog" )
		return;

	if( state )
	{
		if( IsDefined( self.script_bcdialog ) && !self.script_bcdialog )
			self.battlechatter = false; 
		else
			self.battlechatter = true; 
		}
	else
	{
		self.battlechatter = false; 
		
		while( IsDefined( self.isSpeaking ) && self.isSpeaking )
			wait(.05);
	}
}

//
// This is for scripted sequence guys that the LD has setup to not 
// get interrupted in route.
//

set_friendly_chain_wrapper( node )
{
	// SCRIPTER_MOD
	// MikeD (3/23/2007): No more level.player,TODO: for now we're going to use self. We may need this to be the globalfriendlychain stuff.
	// level.player SetFriendlyChain( node ); 
	self SetFriendlyChain( node ); 
	level notify( "newFriendlyChain", node.script_noteworthy ); 
}


// Newvillers objective management
 /* 
	level.currentObjective = "obj1";// disables non obj1 friendly chains if you're using newvillers style friendlychains
	objEvent = get_obj_event( "center_house" );// a trigger with targetname objective_event and a script_deathchain value
	
	objEvent waittill_objectiveEvent();// this waits until the AI with the event's script_deathchain are dead, 
											then waits for trigger from the player. If it targets a friendly chain then it'll
											make the friendlies go to the chain.
 */ 

get_obj_origin( msg )
{
	objOrigins = GetEntArray( "objective", "targetname" ); 
	for( i = 0;i < objOrigins.size;i ++ )
		{
		if( objOrigins[ i ].script_noteworthy == msg )
			return objOrigins[ i ].origin;
	}
}

get_obj_event( msg )
{
	objEvents = GetEntArray( "objective_event", "targetname" ); 
	for( i = 0;i < objEvents.size;i ++ )
		{
		if( objEvents[ i ].script_noteworthy == msg )
			return objEvents[ i ];
	}
}


waittill_objective_event()
{
	waittill_objective_event_proc( true ); 
}

waittill_objective_event_notrigger()
{
	waittill_objective_event_proc( false ); 
}


// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player, removed since nothing calls it.
//obj_set_chain_and_enemies()
//{
//	objChain = GetNode( self.target, "targetname" ); 
//	objEnemies = GetEntArray( self.target, "targetname" ); 
//	flood_and_secure_scripted( objEnemies ); 
////	array_thread( , ::flood_begin ); 
//	level notify( "new_friendly_trigger" ); 
//	level.player set_friendly_chain_wrapper( objChain ); 
//}

flood_begin()
{
	self notify( "flood_begin" ); 
}

// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player, removed since nothing calls it.
//flood_and_secure_scripted( spawners, insTantRespawn )
//{
//	/*
//		The "scripted" version acts as if it had been player triggered.
//		
//		spawns AI that run to a spot then get a big goal radius. They stop spawning when auto Delete Kicks in, then start
//		again when they are retriggered or the player gets close.
//	
//		trigger targetname flood_and_secure
//		ai spawn and run to goal with small goalradius then get large goalradius
//		spawner starts with a notify from any flood_and_secure trigger that triggers it
//		spawner stops when an AI from it is Deleted to make space for a new AI or when count is depleted
//		spawners with count of 1 only make 1 guy.
//		spawners with count of more than 1 only deplete in count when the player kills the AI.
//		spawner can target another spawner. When first spawner's ai dies from death( not deletion ), second spawner activates.
//	*/
//
//	if( !IsDefined( insTantRespawn ) )
//	{
//		insTantRespawn = false; 
//	}
//
//	if( !IsDefined( level.spawnerWave ) )
//	{
//		level.spawnerWave = []; 
//	}
//	array_thread( spawners, maps\_spawner::flood_and_secure_spawner, insTantRespawn ); 
//
//	for( i = 0; i < spawners.size; i++ )
//	{
//		spawners[i].playerTriggered = true; 
//		spawners[i] notify( "flood_begin" ); 
//	}
//}


debugorigin()
{
//	self endon( "killanimscript" ); 
//	self endon( anim.scriptChange ); 
	self notify( "Debug origin" ); 
	self endon( "Debug origin" ); 
	self endon( "death" ); 
	for( ;; )
	{
		forward = AnglesToForward( self.angles ); 
		forwardFar = vectorScale( forward, 30 ); 
		forwardClose = vectorScale( forward, 20 ); 
		right = AnglesToRight( self.angles ); 
		left = vectorScale( right, -10 ); 
		right = vectorScale( right, 10 ); 
		line( self.origin, self.origin + forwardFar, ( 0.9, 0.7, 0.6 ), 0.9 ); 
		line( self.origin + forwardFar, self.origin + forwardClose + right, ( 0.9, 0.7, 0.6 ), 0.9 ); 
		line( self.origin + forwardFar, self.origin + forwardClose + left, ( 0.9, 0.7, 0.6 ), 0.9 ); 
		wait( 0.05 ); 
	}
}


get_links()
{
	return Strtok( self.script_linkTo, " " ); 
}

/*
=============
///ScriptDocBegin
"Name: get_linked_ents()"
"Summary: Returns an array of entities that SELF is linked to"
"Module: Utility"
"CallOn: An entity that links to other entities"
"Example: spawners = heli get_linked_ents()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_linked_ents()
{
	array = [];

	if ( isdefined( self.script_linkto ) )
	{
		linknames = get_links();
		for ( i = 0; i < linknames.size; i ++ )
		{
			ent = getent( linknames[ i ], "script_linkname" );
			if ( isdefined( ent ) )
			{
				array[ array.size ] = ent;
			}
		}
	}
	
	return array;
}

/*
=============
///ScriptDocBegin
"Name: get_linked_structs()"
"Summary: Returns an array of entities that SELF is linked to"
"Module: Utility"
"CallOn: An entity that links to other entities"
"Example: spawners = heli get_linked_structs()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_linked_structs()
{
	array = [];

	if ( isdefined( self.script_linkto ) )
	{
		linknames = get_links();
		for ( i = 0; i < linknames.size; i ++ )
		{
			ent = getstruct( linknames[ i ], "script_linkname" );
			if ( isdefined( ent ) )
			{
				array[ array.size ] = ent;
			}
		}
	}
	
	return array;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: get_last_ent_in_chain( <sEntityType> )"
"Summary: Get the last entity/node/vehiclenode in a chain of targeted entities"
"Module: Entity"
"CallOn: Any entity that targets a chain of linked nodes, vehiclenodes or other entities like script_origin"
"MandatoryArg: <sEntityType>: needs to be specified as 'vehiclenode', 'pathnode' or 'ent'"
"Example: eLastNode = eVehicle get_last_ent_in_chain( "vehiclenode" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
get_last_ent_in_chain( sEntityType )
{
	ePathpoint = self;
	while ( isdefined(ePathpoint.target) )
	{
		wait (0.05);
		if ( isdefined( ePathpoint.target ) )
		{
			switch ( sEntityType )
			{
				case "vehiclenode":
					ePathpoint = getvehiclenode( ePathpoint.target, "targetname" );
					break;
				case "pathnode":
					ePathpoint = getnode( ePathpoint.target, "targetname" );
					break;
				case "ent":
					ePathpoint = getent( ePathpoint.target, "targetname" );
					break;
				default:
					assertmsg("sEntityType needs to be 'vehiclenode', 'pathnode' or 'ent'");
			}			
		}
		else
			break;
	}		
	ePathend = ePathpoint;
	return ePathend;
}


// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player, removed since nothing calls it.
//player_seek( timeout )
//{
//	goalent = Spawn( "script_origin", level.player.origin ); 
//	goalent LinkTo( level.player ); 
//	if( IsDefined( timeout ) )
//	{
//		self thread timeout( timeout ); 
//	}
//	self SetGoalEntity( goalent ); 
//	if( !IsDefined( self.oldgoalradius ) )
//	{
//		self.oldgoalradius = self.goalradius; 
//	}
//	self.goalradius = 300; 
//	self waittill_any( "goal", "timeout" ); 
//	if( IsDefined( self.oldgoalradius ) )
//	{
//		self.goalradius = self.oldgoalradius; 
//		self.oldgoalradius = undefined; 
//	}
//	goalent Delete(); 
//}


timeout( timeout )
{
	self endon( "death" ); 
	wait( timeout ); 
	self notify( "timeout" ); 
}

set_forcegoal()
{
	if( IsDefined( self.set_forcedgoal ) )
		return; 
	
	self.oldfightdist 	 = self.pathenemyfightdist; 
	self.oldmaxdist 	 = self.pathenemylookahead; 
	self.oldmaxsight 	 = self.maxsightdistsqrd; 
	
	self.pathenemyfightdist = 8; 
	self.pathenemylookahead = 8; 
	self.maxsightdistsqrd = 1; 
	self.set_forcedgoal = true; 
}

unset_forcegoal()
{
	if( !IsDefined( self.set_forcedgoal ) )
		return; 
	
	self.pathenemyfightdist = self.oldfightdist; 
	self.pathenemylookahead = self.oldmaxdist; 
	self.maxsightdistsqrd 	 = self.oldmaxsight; 
	self.set_forcedgoal = undefined; 
}


array_add( array, ent )
{
	array[ array.size ] = ent;
	return array; 
}

array_removeDead_keepkeys( array )
{
	newArray = [];
	keys = getarraykeys( array );
	for( i = 0; i < keys.size; i ++ )
	{
		key = keys[ i ];
		if( !isalive( array[ key ] ) )
			continue;
		newArray[ key ] = array[ key ];
	}

	return newArray;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_removeDead( <array> )"
"Summary: Returns a new array of < array > minus the dead entities"
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : The array to search for dead entities in."
"Example: friendlies = array_removeDead( friendlies );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_removeDead( array )
{
	newArray = []; 
	for( i = 0; i < array.size; i ++ )
		{
		if( !isalive( array[ i ] ) )
			continue; 
		newArray[ newArray.size ] = array[ i ];
	}

	return newArray; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_removeUndefined( <array> )"
"Summary: Returns a new array of < array > minus the undefined indicies"
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : The array to search for undefined indicies in."
"Example: ents = array_removeUndefined( ents );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_removeUndefined( array )
{
	newArray = []; 
	for( i = 0; i < array.size; i ++ )
		{
		if( !isdefined( array[ i ] ) )
			continue; 
		newArray[ newArray.size ] = array[ i ];
	}

	return newArray; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_insert( <array> , <object> , <index> )"
"Summary: Returns a new array of < array > plus < object > at the specified index"
"Module: Array"
"CallOn: "
"MandatoryArg: <array> : The array to add to."
"MandatoryArg: <object> : The entity to add"
"MandatoryArg: <index> : The index position < object > should be added to."
"Example: ai = array_insert( ai, spawned, 0 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_insert( array, object, index )
{
	if( index == array.size )
	{
		temp = array; 
		temp[ temp.size ] = object;
		return temp; 
	}
	temp = []; 
	offset = 0; 
	for( i = 0; i < array.size; i ++ )
	{
		if( i == index )
		{
			temp[ i ] = object;
			offset = 1; 
		}
		temp[ i + offset ] = array[ i ];
	}
	
	return temp; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: array_remove( <ents> , <remover> )"
"Summary: Returns < ents > array minus < remover > "
"Module: Array"
"CallOn: "
"MandatoryArg: <ents> : array to remove < remover > from"
"MandatoryArg: <remover> : entity to remove from the array"
"Example: ents = array_remove( ents, guy );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
array_remove( ents, remover, keepArrayKeys )
{
	newents = []; 
	 // if this array is a simple numbered array - array keys will return the array in a reverse order
	 // causing the array that is returned from this function to be flipped, that is an un expected 
	 // result, which is why we're counting down in the for loop instead of the usual counting up
	keys = getArrayKeys( ents );
	
	//GLocke 2/28/08 - added ability to keep array keys from previous array
	if(IsDefined(keepArrayKeys))
	{
		for( i = keys.size - 1; i >= 0; i -- )
		{
			if( ents[ keys[ i ] ] != remover )
				newents[ keys[i] ] = ents[ keys[ i ] ];
		}
		
		return newents;
	}
	
	// Returns array with index of ints
	for( i = keys.size - 1; i >= 0; i -- )
	{
		if( ents[ keys[ i ] ] != remover )
			newents[ newents.size ] = ents[ keys[ i ] ];
	}

	return newents; 
}

array_remove_nokeys( ents, remover )
{
	newents = [];
	if(ents.size <= 1) return ents; //UGX_SCRIPT: Needed this check, otherwise arrays with size of 1 or less go out of range.
	for ( i = 0; i < ents.size; i++ )
		if( ents[ i ] != remover )
			newents[ newents.size ] = ents[ i ];
	return newents;
}

array_remove_index( array, index )
{
	newArray = [];
	keys = getArrayKeys( array );
	for( i = ( keys.size - 1 );i >= 0 ; i -- )
	{
		if( keys[ i ] != index )
			newArray[ newArray.size ] = array[ keys[ i ] ];
	}

	return newArray;
}

array_notify( ents, notifier )
{
	for( i = 0;i < ents.size;i ++ )
		ents[ i ] notify( notifier );
}

// MikeD (3/20/2007): Checks the array if the "single" already exists, if so it returns false.
array_check_for_dupes( array, single )
{
	for( i = 0; i < array.size; i++ )
	{
		if( array[i] == single )
		{
			return false;
		}
	}

	return true;
}

// Lucas (5/22/2008) added an array_swap for easy quicksorting
array_swap( array, index1, index2 )
{
	assertEx( index1 < array.size, "index1 to swap out of range" );
	assertEx( index2 < array.size, "index2 to swap out of range" );
	
	temp = array[index1];
	array[index1] = array[index2];
	array[index2] = temp;
}

// fancy quicker struct array handling, assumes array elements are objects with which an index can be asigned to( IE: can't do 5.struct_array_index ) 
// also have to be sure that objects can't be a part of another structarray setup as the index position is asigned to the object

getstruct( name, type )
{
	assertEx( isdefined( level.struct_class_names ), "Tried to getstruct before the structs were init" );
	
	array = level.struct_class_names[ type ][ name ];
	if( !IsDefined( array ) )
	{
		return undefined; 
	}

	if( array.size > 1 )
	{
		assertMsg( "getstruct used for more than one struct of type " + type + " called " + name + "." );
		return undefined; 
	}
	return array[ 0 ];
}

struct_arraySpawn()
{
	struct = SpawnStruct(); 
	struct.array = []; 
	struct.lastindex = 0; 
	return struct; 
}

structarray_add( struct, object )
{
	assert( !isdefined( object.struct_array_index ) );// can't have elements of two structarrays on these. can add that later if it's needed
	struct.array[ struct.lastindex ] = object;
	object.struct_array_index = struct.lastindex; 
	struct.lastindex ++ ;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: structarray_remove( <struct> , <object )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1> : "
"OptionalArg: <param2> : "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
structarray_remove( struct, object )
{
	structarray_swaptolast( struct, object ); 
	struct.array[ struct.lastindex - 1 ] = undefined;
	struct.lastindex -- ;
}

structarray_swaptolast( struct, object )
{
	struct structarray_swap( struct.array[ struct.lastindex - 1 ], object );
}

structarray_shuffle( struct, shuffle )
{
	for( i = 0;i < shuffle;i ++ )
		struct structarray_swap( struct.array[ i ], struct.array[ randomint( struct.lastindex ) ] );
}

// starts this ambient track
set_ambient_alias( ambient, alias )
{
	// change the meaning of this ambience so that the ambience can change over the course of the level
	level.ambient_modifier[ ambient ] = alias;
	// if the ambient being aliased is the current ambience then restart it so it gets the new track
	if( level.ambient == ambient )
		maps\_ambient::activateAmbient( ambient ); 
}


get_use_key()
{
	if( level.console )
	{
	 	return " + usereload";
	}
 	else
	{
 		return " + activate";
	}
}

 /* 
	move_generic		"Go! Go! Go!"
	move_flank			"Find a way to flank them! Go!"
	move_flankleft		"Take their left flank! Go!"
	move_flankright		"Move in on their left flank! Go!"
	move_follow			"Follow me!"
	move_forward		"Keep moving forward!"
	move_back			"Fall back!"
	
	infantry_generic	"Enemy Infantry!"
	infantry_exposed	"Infatry in the open!"
	infantry_many		"We got a load of german troops out there!"
	infantry_sniper		"Get your heads down! Sniper!"
	infantry_panzer		"Panzerschreck!"
	
	vehicle_halftrack	"Halftrack!"
	vehicle_panther		"Panther heavy tank!"
	vehicle_panzer		"Panzer tank!"
	vehicle_tank		"Look out! Enemy armor!"
	vehicle_truck		"Troop truck!"

	action_smoke		"Get some smoke out there!"

	The following can be appended to any infantry or vehicle dialog line:	
	_left				"On our left!"
	_right				"To the right!"
	_front				"Up front!"
	_rear				"Behind us!"
	_north				"To the north!"
	_south				"South!"
	_east				"To the east!"
	_west				"To the west!"
	_northwest			"To the northwest!"
	_southwest			"To the southwest!"
	_northeast			"To the northeast!"
	_southwest			"To the southeast!"
	_inbound_left		"Incoming
	_inbound_right		"Closing on our right flank!"
	_inbound_front		"Inbound dead ahead!"
	_inbound_rear		"Approaching from the rear!"
	_inbound_north		"Coming in from the north!"
	_inbound_south		"Coming in from the south!"
	_inbound_east		"Approaching from the east!"
	_inbound_west		"Pushing in from the west!"
 */ 

custom_battlechatter( string )
{
	excluders = []; 
	excluders[ 0 ] = self;
	buddy = get_closest_ai_exclude( self.origin, self.team, excluders ); 

	if( IsDefined( buddy ) && Distance( buddy.origin, self.origin ) > 384 ) 
		buddy = undefined; 

	self animscripts\battlechatter_ai::beginCustomEvent(); 

	tokens = Strtok( string, "_" ); 

	if( !tokens.size )
		return; 
		
	if( tokens[ 0 ] == "move" )
	{
		if( tokens.size > 1 )
			modifier = tokens[ 1 ];
		else 
			modifier = "generic"; 
			
		self animscripts\battlechatter_ai::addGenericAliasEx( "order", "move", modifier ); 
			
	}
	else if( tokens[ 0 ] == "infantry" )
	{
		self animscripts\battlechatter_ai::addGenericAliasEx( "threat", "infantry", tokens[ 1 ] );
		
		if( tokens.size > 2 && tokens[ 2 ] != "inbound" )
			self animscripts\battlechatter_ai::addGenericAliasEx( "direction", "relative", tokens[ 2 ] );
		else if( tokens.size > 2 )
			self animscripts\battlechatter_ai::addGenericAliasEx( "direction", "inbound", tokens[ 3 ] );
		}
	else if( tokens[ 0 ] == "vehicle" )
	{
		self animscripts\battlechatter_ai::addGenericAliasEx( "threat", "vehicle", tokens[ 1 ] );
		
		if( tokens.size > 2 && tokens[ 2 ] != "inbound" )
			self animscripts\battlechatter_ai::addGenericAliasEx( "direction", "relative", tokens[ 2 ] );
		else if( tokens.size > 2 )
			self animscripts\battlechatter_ai::addGenericAliasEx( "direction", "inbound", tokens[ 3 ] );
	}
	
	self animscripts\battlechatter_ai::endCustomEvent( 2000 ); 
}


force_custom_battlechatter( string, targetAI )
{
	tokens = Strtok( string, "_" ); 
	soundAliases = []; 

	if( !tokens.size )
		return; 

	if( isDefined( targetAI ) && ( isDefined( targetAI.bcName ) || isDefined( targetAI.bcRank ) ) )
	{
		if( IsDefined( targetAI.bcName ) )
			nameAlias = self buildBCAlias( "name", targetAI.bcName ); 
		else
			nameAlias = self buildBCAlias( "rank", targetAI.bcRank ); 
			
		if( SoundExists( nameAlias ) )
			soundAliases[ soundAliases.size ] = nameAlias;
	}	
		
	if( tokens[ 0 ] == "move" )
	{
		if( tokens.size > 1 )
			modifier = tokens[ 1 ];
		else 
			modifier = "generic"; 
			
		soundAliases[ soundAliases.size ] = self buildBCAlias( "order", "move", modifier );
	}
	else if( tokens[ 0 ] == "infantry" )
	{
		soundAliases[ soundAliases.size ] = self buildBCAlias( "threat", "infantry", tokens[ 1 ] );
		
		if( tokens.size > 2 && tokens[ 2 ] != "inbound" )
			soundAliases[ soundAliases.size ] = self buildBCAlias( "direction", "relative", tokens[ 2 ] );
		else if( tokens.size > 2 )
			soundAliases[ soundAliases.size ] = self buildBCAlias( "direction", "inbound", tokens[ 3 ] );
	}
	else if( tokens[ 0 ] == "vehicle" )
	{
		soundAliases[ soundAliases.size ] = self buildBCAlias( "threat", "vehicle", tokens[ 1 ] );
		
		if( tokens.size > 2 && tokens[ 2 ] != "inbound" )
			soundAliases[ soundAliases.size ] = self buildBCAlias( "direction", "relative", tokens[ 2 ] );
		else if( tokens.size > 2 )
			soundAliases[ soundAliases.size ] = self buildBCAlias( "direction", "inbound", tokens[ 3 ] );
	}
	else if( tokens[ 0 ] == "order" )
	{
		if( tokens.size > 1 )
			modifier = tokens[ 1 ];
		else 
			modifier = "generic"; 

		soundAliases[ soundAliases.size ] = self buildBCAlias( "order", "action", modifier );
	}
	else if( tokens[ 0 ] == "cover" )
	{
		if( tokens.size > 1 )
			modifier = tokens[ 1 ];
		else 
			modifier = "generic"; 

		soundAliases[ soundAliases.size ] = self buildBCAlias( "order", "cover", modifier );
	}
	
	for( index = 0; index < soundAliases.size; index ++ )
	{
		self playSound( soundAliases[ index ], soundAliases[ index ], true );
		self waittill( soundAliases[ index ] );
	}
}


buildBCAlias( action, type, modifier )
{
	if( IsDefined( modifier ) )
		return( self.countryID + "_" + self.npcID + "_" + action + "_" + type + "_" + modifier ); 
	else
		return( self.countryID + "_" + self.npcID + "_" + action + "_" + type ); 
}

get_stop_watch( time, othertime )
{
	watch = NewHudElem(); 
	if( level.console )
	{
		watch.x = 68; 
		watch.y = 35; 
	}
	else
	{
		watch.x = 58; 
		watch.y = 95; 
	}
	
	watch.alignx = "center"; 
	watch.aligny = "middle"; 
	watch.horzAlign = "left"; 
	watch.vertAlign = "middle"; 
	if( IsDefined( othertime ) )
		timer = othertime; 
	else
		timer = level.explosiveplanttime; 
	watch setClock( timer, time, "hudStopwatch", 64, 64 );// count down for level.explosiveplanttime of 60 seconds, size is 64x64
	return watch; 
}

objective_is_active( msg )
{
	active = false; 
	// objective must be active for this trigger to hit
	for( i = 0;i < level.active_objective.size;i ++ )
		{
		if( level.active_objective[ i ] != msg )
			continue; 
		active = true; 
		break; 
	}
	return( active ); 
}

objective_is_inactive( msg )
{
	inactive = false; 
	// objective must be active for this trigger to hit
	for( i = 0;i < level.inactive_objective.size;i ++ )
		{
		if( level.inactive_objective[ i ] != msg )
			continue; 
		inactive = true; 
		break; 
	}
	return( inactive ); 
}

set_objective_inactive( msg )
{
	// remove the objective from the active list
	array = []; 
	for( i = 0;i < level.active_objective.size;i ++ )
		{
		if( level.active_objective[ i ] == msg )
			continue; 
		array[ array.size ] = level.active_objective[ i ];
	}
	level.active_objective = array; 
	
	
	// add it to the inactive list
	exists = false; 
	for( i = 0;i < level.inactive_objective.size;i ++ )
		{
		if( level.inactive_objective[ i ] != msg )
			continue; 
		exists = true; 
	}
	if( !exists )
		level.inactive_objective[ level.inactive_objective.size ] = msg;
		
	/#
	// assert that each objective is only on one list
	for( i = 0;i < level.active_objective.size;i ++ )
	{
		for( p = 0;p < level.inactive_objective.size;p ++ )
			assertEx( level.active_objective[ i ] != level.inactive_objective[ p ], "Objective is both inactive and active" );
	}
	#/
}

set_objective_active( msg )
{
	// remove the objective from the inactive list
	array = []; 
	for( i = 0;i < level.inactive_objective.size;i ++ )
		{
		if( level.inactive_objective[ i ] == msg )
			continue; 
		array[ array.size ] = level.inactive_objective[ i ];
	}
	level.inactive_objective = array; 
		
	// add it to the active list
	exists = false; 
	for( i = 0;i < level.active_objective.size;i ++ )
		{
		if( level.active_objective[ i ] != msg )
			continue; 
		exists = true; 
	}
	if( !exists )
		level.active_objective[ level.active_objective.size ] = msg;
		
	/#
	// assert that each objective is only on one list
	for( i = 0;i < level.active_objective.size;i ++ )
	{
		for( p = 0;p < level.inactive_objective.size;p ++ )
			assertEx( level.active_objective[ i ] != level.inactive_objective[ p ], "Objective is both inactive and active" );
	}
	#/
}

// CODER_MOD JamesS not used function
//detect_friendly_fire()
//{
//	level thread maps\_friendlyfire::detectFriendlyFireOnEntity( self ); 
//}

missionFailedWrapper()
{
	if( level.missionfailed )
		return;

	if ( isdefined( level.nextmission ) )
		return;  // don't fail the mission while the game is on it's way to the next mission.

/*	// will return in the next game
	/#
	if ( isgodmode( level.player ) )
	{
		println( getdvar( "ui_deadquote" ) );
		return; 
	}
	#/ 
*/

	level.missionfailed = true; 	
	flag_set( "missionfailed" );

	if ( getdvar( "failure_disabled" ) == "1" )
		return;
	
	MissionFailed(); 
}

// MikeD (11/1/2007): Used to call the next mission
nextmission()
{
	maps\_endmission::_nextmission();
}

script_delay()
{
	if( IsDefined( self.script_delay ) )
	{
		wait( self.script_delay ); 
		return true;
	}
	else 
	if( isDefined( self.script_delay_min ) && isDefined( self.script_delay_max ) )
	{
		wait( RandomFloatrange( self.script_delay_min, self.script_delay_max ) ); 
		return true;
	}
		
	return false;
}


script_wait( called_from_spawner )
{
	// co-op scaling should only affect calls from spawning functions
	if (!isdefined(called_from_spawner))
	{
		called_from_spawner = false;
	}
	
	// set to 1 as default, decease scalar as more players join
	coop_scalar = 1;
	if ( called_from_spawner )
	{
		players = get_players();
		
		if (players.size == 2)
		{
			coop_scalar = 0.7;
		}
		else if (players.size == 3)
		{
			coop_scalar = 0.4;
		}
		else if (players.size == 4)
		{
			coop_scalar = 0.1;
		}
	}
	
	startTime = GetTime(); 
	if( IsDefined( self.script_wait ) )
	{
		wait( self.script_wait * coop_scalar); 

		if( IsDefined( self.script_wait_add ) )
			self.script_wait += self.script_wait_add; 
		}
	else if( IsDefined( self.script_wait_min ) && IsDefined( self.script_wait_max ) )
	{
		wait( RandomFloatrange( self.script_wait_min, self.script_wait_max ) * coop_scalar); 

		if( IsDefined( self.script_wait_add ) )
		{
			self.script_wait_min += self.script_wait_add; 
			self.script_wait_max += self.script_wait_add; 
		}
	}

	return( GetTime() - startTime ); 
}

guy_enter_vehicle( guy, vehicle )
{
	maps\_vehicle_aianim::guy_enter( guy, vehicle ); 
}

guy_array_enter_vehicle( guy, vehicle )
{
	maps\_vehicle_aianim::guy_array_enter( guy, vehicle ); 
}

guy_runtovehicle_load( guy, vehicle )
{
	maps\_vehicle_aianim::guy_runtovehicle( guy, vehicle ); 
	
}

get_force_color_guys( team, color )
{
	ai = GetAiArray( team ); 
	guys = []; 
	for( i = 0; i < ai.size; i ++ )
	{
		guy = ai[ i ];
		if( !IsDefined( guy.script_forceColor ) )
			continue; 
		
		if( guy.script_forceColor != color )
			continue; 
		guys[ guys.size ] = guy;
	}
	
	return guys; 
}

get_all_force_color_friendlies()
{
	ai = GetAiArray( "allies" ); 
	guys = []; 
	for( i = 0; i < ai.size; i ++ )
	{
		guy = ai[ i ];
		if( !IsDefined( guy.script_forceColor ) )
			continue; 
		guys[ guys.size ] = guy;
	}
	
	return guys; 
}

enable_ai_color()
{
	if( isdefined( self.script_forceColor ) )
		return;
	if( !isdefined( self.old_forceColor ) )
		return;
		
	set_force_color( self.old_forcecolor );
	self.old_forceColor = undefined;
}

disable_ai_color()
{
	if( isdefined( self.new_force_color_being_set ) )
	{
		self endon( "death" );
		 // setting force color happens after waittillframeend so we need to wait until it finishes
		 // setting before we disable it, so a set followed by a disable will send the guy to a node.
		self waittill( "done_setting_new_color" );
	}
	
	self clearFixedNodeSafeVolume();
	 // any color on this guy?
	if( !isdefined( self.script_forceColor ) )
	{
		return;
	}

	assertEx( !isdefined( self.old_forcecolor ), "Tried to disable forcecolor on a guy that somehow had a old_forcecolor already. Investigate!!!" );
	
	self.old_forceColor = self.script_forceColor;
	
	
	 // first remove the guy from the force color array he used to belong to
	level.arrays_of_colorForced_ai[ self.team ][ self.script_forcecolor ] = array_remove( level.arrays_of_colorForced_ai[ self.team ][ self.script_forcecolor ], self );
// 	self maps\_colors::removeAIFromColorNumberArray();
	
	maps\_colors::left_color_node();
	self.script_forceColor = undefined;
	self.currentColorCode = undefined;
	 /#
	update_debug_friendlycolor( self.ai_number );
	#/ 
}

clear_force_color()
{
	disable_ai_color();
}

check_force_color( _color )
{
	color = level.colorCheckList[ tolower( _color ) ];
	if( isdefined( self.script_forcecolor ) && color == self.script_forcecolor )
		return true; 
	else
		return false; 
}

get_force_color()
{
	color = self.script_forceColor; 
	return color; 
}

shortenColor( color )
{
	assertEx( isdefined( level.colorCheckList[ tolower( color ) ] ), "Tried to set force color on an undefined color: " + color );
	return level.colorCheckList[ tolower( color ) ];
}


set_force_color( _color )
{
	// shorten and lowercase the ai's forcecolor to a single letter
	color = shortenColor( _color ); 
	
	assertEx( maps\_colors::colorIsLegit( color ), "Tried to set force color on an undefined color: " + color );
	
	if( !isAI( self ) )
	{
		set_force_color_spawner( color ); 
		return; 
	}
		
	assertEx( isalive( self ), "Tried to set force color on a dead / undefined entity." );
	 /* 
	/#
	thread insure_player_does_not_set_forcecolor_twice_in_one_frame(); 
	#/
	 */ 

	if( self.team == "allies" )
	{
		 // enable fixed node mode.
		self.fixedNode = true;
		self.fixedNodeSafeRadius = 64;
		self.pathEnemyFightDist = 0;
		self.pathEnemyLookAhead = 0;
	}

// 	maps\_colors::removeAIFromColorNumberArray();	
	self.script_color_axis = undefined;
	self.script_color_allies = undefined;
	self.old_forcecolor = undefined;
	
	if( isdefined( self.script_forcecolor ) )
	{
		// first remove the guy from the force color array he used to belong to
		level.arrays_of_colorForced_ai[ self.team ][ self.script_forcecolor ] = array_remove( level.arrays_of_colorForced_ai[ self.team ][ self.script_forcecolor ], self );
	}
	self.script_forceColor = color;

	// get added to the new array of AI that are forced to this color
	level.arrays_of_colorForced_ai[ self.team ][ self.script_forceColor ] = array_add( level.arrays_of_colorForced_ai[ self.team ][ self.script_forceColor ], self );
	
	
	 // set it here so that he continues in script as the correct color
	thread new_color_being_set( color );
}

set_force_color_spawner( color )
{
	 /* 
	team = undefined; 
	colorTeam = undefined; 
	if( IsSubStr( self.classname, "axis" ) )
	{
		colorTeam = self.script_color_axis; 
		team = "axis"; 
	}
	
	if( IsSubStr( self.classname, "ally" ) )
	{
		colorTeam = self.script_color_allies; 
		team = "allies"; 
	}

	maps\_colors::removeSpawnerFromColorNumberArray(); 	
	 */ 
	
	self.script_forceColor = color; 
// 	self.script_color_axis = undefined;
// 	self.script_color_allies = undefined;
	self.old_forceColor = undefined;
// 	thread maps\_colors::spawner_processes_colorCoded_ai();
}

issue_color_orders( color_team, team )
{
	colorCodes = Strtok( color_team, " " ); 
	colors = []; 
	colorCodesByColorIndex = []; 
	
	for( i = 0;i < colorCodes.size;i ++ )
	{
		color = undefined; 
		if( issubstr( colorCodes[ i ], "r" ) )
			color = "r"; 
		else
		if( issubstr( colorCodes[ i ], "b" ) )
			color = "b"; 
		else
		if( issubstr( colorCodes[ i ], "y" ) )
			color = "y"; 
		else
		if( issubstr( colorCodes[ i ], "c" ) )
			color = "c"; 
		else
		if( issubstr( colorCodes[ i ], "g" ) )
			color = "g"; 
		else
		if( issubstr( colorCodes[ i ], "p" ) )
			color = "p"; 
		else
		if( issubstr( colorCodes[ i ], "o" ) )
			color = "o"; 
		else
			assertEx( 0, "Trigger at origin " + self getorigin() + " had strange color index " + colorCodes[ i ] );
		
		colorCodesByColorIndex[ color ] = colorCodes[ i ];
		colors[ colors.size ] = color;
	}
	
	assert( colors.size == colorCodes.size ); 
	
	for( i = 0;i < colorCodes.size;i ++ )
	{
		// remove deleted spawners
		level.arrays_of_colorCoded_spawners[ team ][ colorCodes[ i ] ] = array_removeUndefined( level.arrays_of_colorCoded_spawners[ team ][ colorCodes[ i ] ] );

		assertex( isdefined( level.arrays_of_colorCoded_spawners[ team ][ colorCodes[ i ] ] ), "Trigger refer to a color# that does not exist in any node for this team." );
		// set the .currentColorCode on each appropriate spawner
		for( p = 0;p < level.arrays_of_colorCoded_spawners[ team ][ colorCodes[ i ] ].size;p ++ )
			level.arrays_of_colorCoded_spawners[ team ][ colorCodes[ i ] ][ p ].currentColorCode = colorCodes[ i ];
	}

	for( i = 0;i < colors.size;i ++ )
	{
		// remove the dead from the color forced ai
		level.arrays_of_colorForced_ai[ team ][ colors[ i ] ] = array_removeDead( level.arrays_of_colorForced_ai[ team ][ colors[ i ] ] );
			
		// set the destination of the color forced spawners
		level.currentColorForced[ team ][ colors[ i ] ] = colorCodesByColorIndex[ colors[ i ] ];
	}
		
	for( i = 0;i < colorCodes.size;i ++ )
	{
		ai_array = [];
		ai_array = maps\_colors::issue_leave_node_order_to_ai_and_get_ai( colorCodes[ i ], colors[ i ], team );
		maps\_colors::issue_color_order_to_ai( colorCodes[ i ], colors[ i ], team, ai_array );
	}
}


// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player
//TODO: Non-hacky rumble.
flashRumbleLoop( duration )
{
	goalTime = GetTime() + duration * 1000; 
	
	while( GetTime() < goalTime )
	{
		self PlayRumbleOnEntity( "damage_heavy" ); 
		wait( 0.05 ); 
	}
}

// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player
flashMonitor()
{
	self endon( "death" ); 
	
	for( ;; )
	{
		self waittill( "flashbang", percent_distance, percent_angle, attacker, team );
	
		if( "1" == GetDvar( "noflash" ) )
		{
			continue; 
		}

		 // PrintLn( "Flashed by a grenade from team '", team, "'." );
		
		 // if it's close enough, angle doesn't matter so much
		frac = ( percent_distance - 0.75 ) / ( 1 - 0.75 );
		if( frac > percent_angle )
			percent_angle = frac;
	
		if( percent_angle < 0.5 )
		{
			percent_angle = 0.5; 
		}
		else if( percent_angle > 0.8 )
		{
			percent_angle = 1; 
		}
	
		 // at 200 or less of the full range of 1000 units, get the full effect
		minamountdist = 0.2;
		if( percent_distance > 1 - minamountdist )
			percent_distance = 1.0;
		else
			percent_distance = percent_distance / ( 1 - minamountdist );
		
		if( team == "axis" ) 
			seconds = percent_distance * percent_angle * 6.0;
		else
			seconds = percent_distance * percent_angle * 3.0;
	
		if( seconds < 0.25 )
			continue;

		if( isdefined( self.maxflashedseconds ) && seconds > self.maxflashedseconds )
 			seconds = self.maxflashedseconds;
		
		self.flashingTeam = team;
		self notify( "flashed" );
		self.flashendtime = gettime() + seconds * 1000; // player is flashed if flashDoneTime > gettime()
		self shellshock( "flashbang", seconds );
		flag_set( "player_flashed" );
		thread unflash_flag( seconds );
		
		if( seconds > 2 )
			thread flashRumbleLoop( 0.75 );
		else
			thread flashRumbleLoop( 0.25 );
		
		 // if it's an enemy's flash grenade, 
		 // flash nearby allies so they can't take out enemies going after the player
		if( team != "allies" )
			self thread flashNearbyAllies( seconds, team );
	}
}



flashNearbyAllies( baseDuration, team )
{
	wait .05;
	
	allies = getaiarray( "allies" );
	for( i = 0; i < allies.size; i ++ )
	{
		if( distanceSquared( allies[ i ].origin, self.origin ) < 350 * 350 )
		{
			duration = baseDuration + randomfloatrange( - 1000, 1500 );
			if( duration > 4.5 )
				duration = 4.5;
			else if( duration < 0.25 )
				continue;
			
			newendtime = gettime() + duration * 1000;
			if( !isdefined( allies[ i ].flashendtime ) || allies[ i ].flashendtime < newendtime )
			{
				allies[ i ].flashingTeam = team;
				allies[ i ] setFlashBanged( true, duration );
			}
		}
	}
}

pauseEffect()
{
	// CODER_MOD - temp disable for IW integration - JamesS
	//self maps\_createfx::stop_fx_looper();
}

restartEffect()
{
	// CODER_MOD - temp disable for IW integration - JamesS
	//self maps\_createfx::restart_fx_looper();
}

createLoopEffect( fxid )
{
	ent = maps\_createfx::createEffect( "loopfx", fxid ); 
	ent.v[ "delay" ] = 0.5;
	return ent; 
}

createOneshotEffect( fxid )
{
	ent = maps\_createfx::createEffect( "oneshotfx", fxid ); 
	ent.v[ "delay" ] = -15;
	return ent; 
}

reportExploderIds()
{
	if(!isdefined(level._exploder_ids))
		return;
		
	keys = GetArrayKeys( level._exploder_ids ); 

	println("Server Exploder dictionary : ");

	for( i = 0; i < keys.size; i++ )
	{
		println(keys[i] + " : " + level._exploder_ids[keys[i]]);
	}
	
}

getExploderId( ent )
{
	if(!isdefined(level._exploder_ids))
	{
		level._exploder_ids = [];
		level._exploder_id = 1;
	}

	if(!isdefined(level._exploder_ids[ent.v["exploder"]]))
	{
		level._exploder_ids[ent.v["exploder"]] = level._exploder_id;
		level._exploder_id ++;
	}

	return level._exploder_ids[ent.v["exploder"]];
}


createExploder( fxid )
{
	
	ent = maps\_createfx::createEffect( "exploder", fxid ); 
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder_type" ] = "normal";
	
	return ent; 
}

getfxarraybyID( fxid )
{
	array = []; 
	for( i = 0;i < level.createFXent.size;i ++ )
	{
		if( level.createFXent[ i ].v[ "fxid" ] == fxid )
			array[ array.size ] = level.createFXent[ i ];
	}
	return array; 
}

ignoreAllEnemies( qTrue )
{
	self notify( "ignoreAllEnemies_threaded" ); 
	self endon( "ignoreAllEnemies_threaded" ); 
	
	if( qTrue )
	{
		// put the ai in a threat bias group that ignores all the other groups so he
		// doesnt get distracted and go into exposed while his goal radius is too small
		
		self.old_threat_bias_group = self GetThreatBiasGroup(); 
		
		num = undefined; 
		/#
			num = self GetEntNum(); 
			println( "entity: " + num + "ignoreAllEnemies TRUE" ); 
			println( "entity: " + num + " threatbiasgroup is " + self.old_threat_bias_group ); 
		#/
		
		CreateThreatBiasGroup( "ignore_everybody" ); 
		/#
			println( "entity: " + num + "ignoreAllEnemies TRUE" ); 
			println( "entity: " + num + " SetThreatBiasGroup( ignore_everybody )" ); 
		#/
		self SetThreatBiasGroup( "ignore_everybody" ); 
		teams = []; 
		teams[ "axis" ] = "allies";
		teams[ "allies" ] = "axis";
		
		assertex( self.team != "neutral", "Why are you making a guy have team neutral? And also, why is he doing anim_reach?" ); 
		ai = getaiarray( teams[ self.team ] );
		groups = []; 
		for( i = 0; i < ai.size; i ++ )
			groups[ ai[ i ] getthreatbiasgroup() ] = true;
	
		keys = GetArrayKeys( groups ); 
		for( i = 0; i < keys.size; i ++ )
		{
			/#
				println( "entity: " + num + "ignoreAllEnemies TRUE" ); 
				println( "entity: " + num + " setthreatbias( " + keys[ i ] + ", ignore_everybody, 0 )" );
			#/
			setthreatbias( keys[ i ], "ignore_everybody", 0 );
		}
			
		// should now be impossible for this guy to attack anybody on the other team
	}
	else
	{
		num = undefined; 
		assertex( IsDefined( self.old_threat_bias_group ), "You can't use ignoreAllEnemies( false ) on an AI that has never ran ignoreAllEnemies( true )" ); 
		/#
			num = self GetEntNum(); 
			println( "entity: " + num + "ignoreAllEnemies FALSE" ); 
			println( "entity: " + num + " self.old_threat_bias_group is " +  self.old_threat_bias_group ); 
		#/
		if( self.old_threat_bias_group != "" )
		{
			/#
				println( "entity: " + num + "ignoreAllEnemies FALSE" ); 
				println( "entity: " + num + " SetThreatBiasGroup( " + self.old_threat_bias_group + " )" ); 
			#/
			self SetThreatBiasGroup( self.old_threat_bias_group ); 
		}
		self.old_threat_bias_group = undefined; 
	}
}



vehicle_detachfrompath()
{
	maps\_vehicle::vehicle_pathDetach(); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: vehicle_resumepath()"
"Summary: will resume to the last path a vehicle was on.  Only used for helicopters, ground vehicles don't ever deviate."
"Module: Vehicle"
"CallOn: An entity"
"Example: helicopter vehicle_resumepath();"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

vehicle_resumepath()
{
	thread maps\_vehicle::vehicle_resumepathvehicle();
}

 /* 
 ============= 
///ScriptDocBegin
"Name: vehicle_land()"
"Summary: lands a vehicle on the ground, _vehicle scripts take care of offsets and determining where the ground is relative to the origin.  Returns when land is complete"
"Module: Vehicle"
"CallOn: An entity"
"Example: helicopter vehicle_land();"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

vehicle_land()
{
	maps\_vehicle::vehicle_landvehicle(); 
}

vehicle_liftoff( height )
{
	maps\_vehicle::vehicle_liftoffvehicle( height ); 
}

vehicle_dynamicpath( node, bwaitforstart )
{
	maps\_vehicle::vehicle_paths( node, bwaitforstart );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: groundpos( <origin> )"
"Summary: bullettraces to the ground and returns the position that it hit."
"Module: Utility"
"CallOn: An entity"
"MandatoryArg: <origin> : "
"Example: groundposition = helicopter groundpos( helicopter.origin ); "
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

groundpos( origin )
{
	return bullettrace( origin, ( origin + ( 0, 0, -100000 ) ), 0, self )[ "position" ];
}

playergroundpos(origin)
{
	return playerphysicstrace(origin, ( origin + ( 0, 0, -100000 ) ));
}

change_player_health_packets( num )
{
	level.player_health_packets += num; 
	level notify( "update_health_packets" ); 

	if( level.player_health_packets >= 3 )
		level.player_health_packets = 3; 

//	if( level.player_health_packets <= 0 )
//		level.player DoDamage( level.player.health + 1623453, ( 0, 0, 0 ) ); 
}

getvehiclespawner( targetname )
{
	spawner = getent( targetname + "_vehiclespawner", "targetname" );
	return spawner; 
}

getvehiclespawnerarray( targetname )
{
	spawner = getentarray( targetname + "_vehiclespawner", "targetname" );
	return spawner; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: player_fudge_moveto( <dest> , <moverate> )"
"Summary: this function is to fudge move the player. Use this as a placeholder for an actual animation. returns when finished"
"Module: Player"
"CallOn: Level"
"MandatoryArg: <dest> : origin to move the player to"
"OptionalArg: <moverate> : Units per second to move the player.  defaults to 200"
"Example: player_fudge_moveto( carexitorg );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

player_fudge_moveto( dest, moverate )
{
	//moverate = units/persecond
	if( !IsDefined( moverate ) )
	{
		moverate = 200; 
	}
	//this function is to fudge move the player. I'm using this as a placeholder for an actual animation
	
// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player, instead self is the player.
//	org = Spawn( "script_origin", level.player.origin ); 
	org = Spawn( "script_origin", self.origin ); 
	org.origin = self.origin; 
	self LinkTo( org ); 
	dist = Distance( self.origin, dest ); 
	movetime = dist/moverate; 
	org MoveTo( dest, dist/moverate, .05, .05 ); 
	wait( movetime ); 
	self UnLink(); 

	org Delete();
}


add_start( msg, func, loc_string )
{
	assertex( !IsDefined( level._loadStarted ), "Can't create starts after _load" ); 
	if( !IsDefined( level.start_functions ) )
		level.start_functions = [];
	
	msg = tolower( msg );
	level.start_functions[ msg ] = func;
	
	// CODER_MOD - JamesS we don't want this quite yet
	//assertEx( isdefined( loc_string ), "Starts now require a localize string" );
	if( IsDefined(loc_string) )
	{
		precachestring(loc_string);
		level.start_loc_string[ msg ] = loc_string;
	}
	else
	{
		level.start_loc_string[ msg ] = &"MISSING_LOC_STRING";
	}
}

default_start( func )
{
	level.default_start = func; 
}

linetime( start, end, color, timer )
{
	thread linetime_proc( start, end, color, timer ); 
}

 /* 
 ============= 
///ScriptDocBegin
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
///ScriptDocEnd
 ============= 
 */ 
within_fov( start_origin, start_angles, end_origin, fov )
{
	normal = VectorNormalize( end_origin - start_origin ); 
	forward = AnglesToForward( start_angles ); 
	dot = VectorDot( forward, normal ); 

	return dot >= fov; 
}

waitSpread( start, end )
{
	if( !IsDefined( end ) )
	{
		end = start; 
		start = 0; 
	}
	assertEx( isdefined( start ) && isdefined( end ), "Waitspread was called without defining amount of time" );
	
	 // temporarily disabling waitspread until I have time to fix it properly
	wait( randomfloatrange( start, end ) );
	if( 1 )
		return;
	
	personal_wait_index = undefined; 
	
	if( !IsDefined( level.active_wait_spread ) )
	{
		// the first guy sets it up and runs the master logic. Thread it off in case he dies
		
		level.active_wait_spread = true; 
		level.wait_spreaders = 0; 
		personal_wait_index = level.wait_spreaders; 
		level.wait_spreaders ++ ;
		thread waitSpread_code( start, end ); 
	}
	else
	{
		personal_wait_index = level.wait_spreaders; 
		level.wait_spreaders ++ ;
		waittillframeend;// give every other waitspreader in this frame a chance to increment wait_spreaders
	}

	waittillframeend;// wait for the logic to setup the waits
	
	wait( level.wait_spreader_allotment[ personal_wait_index ] );	
	
}

/*
=============
///ScriptDocBegin
"Name: wait_for_buffer_time_to_pass( <last_queue_time> , <buffer_time> )"
"Summary: Wait until the current time is equal or greater than the last_queue_time (in ms) + buffer_time (in seconds)"
"Module: Utility"
"MandatoryArg: <last_queue_time>: The gettime() of the last event you want to buffer"
"MandatoryArg: <buffer_time>: The amount of time you want to insure has passed since the last queue time"
"Example: wait_for_buffer_time_to_pass( level.last_time_we_checked, 3 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
wait_for_buffer_time_to_pass( last_queue_time, buffer_time )
{
	timer = buffer_time * 1000 - ( gettime() - last_queue_time );
	timer *= 0.001;
	if ( timer > 0 )
	{
		// 500ms buffer time between radio or dialogue sounds
		wait( timer );
	}
}

	
/*
=============
///ScriptDocBegin
"Name: dialogue_queue( <msg> )"
"Summary: Plays an anim_single_queue on the guy, with the guy as the actor"
"Module: Utility"
"CallOn: An ai"
"MandatoryArg: <msg>: The dialogue scene, defined as level.scr_sound[ guys.animname ][ "scene" ] "
"Example: level.price dialogue_queue( "nice_find_macgregor" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
	
dialogue_queue( msg )
{
	self maps\_anim::anim_single_queue( self, msg );
}

radio_dialogue( msg )
{
	players = get_players();
	assertEX( isdefined( level.scr_radio[ msg ] ), "Tried to play radio dialogue " + msg + " that did not exist! Add it to level.scr_radio" );
	if ( !isdefined( level.player_radio_emitter ) )
	{
		ent = spawn( "script_origin", (0,0,0) );
		ent linkto( players[0], "", (0,0,0), (0,0,0) );
		level.player_radio_emitter = ent;
	}

	level.player_radio_emitter play_sound_on_tag( level.scr_radio[ msg ], undefined, true );
}

/*
=============
///ScriptDocBegin
"Name: radio_dialogue_stop( <radio_dialogue_stop> )"
"Summary: Stops any radio dialogue currently playing"
"Module: Utility"
"Example: radio_dialogue_stop();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
radio_dialogue_stop()
{
	if ( !isdefined( level.player_radio_emitter ) )
		return;
	level.player_radio_emitter delete();
}
/*
radio_dialogue_queue( msg )
{
	assertEX( isdefined( level.scr_radio[ msg ] ), "Tried to play radio dialogue " + msg + " that did not exist! Add it to level.scr_radio" );

	 // thread off so if the calling thread gets killed we dont get stuck with a queue on the guy
	thread radio_queue_thread( msg );

	for( ;; )
	{
		if( !isdefined( self._radio_queue ) )
			break;
			
		self waittill( "finished_radio" );
	}
}
*/

radio_dialogue_queue( msg )
{
	level function_stack( ::radio_dialogue, msg );
}

// HUD ELEMENT STUFF
hint_create( text, background, backgroundAlpha )
{
	struct = SpawnStruct(); 
	if( IsDefined( background ) && background == true )
		struct.bg = NewHudElem(); 
	struct.elm = NewHudElem(); 
	
	struct hint_position_internal( backgroundAlpha );
	// elm.label 		 = struct.text;
	// elm.debugtext 	 = struct.text;
	struct.elm SetText( text ); 

	return struct; 
}

hint_Delete()
{
	self notify( "death" ); 
	
	if( IsDefined( self.elm ) )
		self.elm Destroy(); 
	if( IsDefined( self.bg ) )
		self.bg Destroy(); 
}

hint_position_internal( bgAlpha )
{
	if( level.console )
		self.elm.fontScale = 2; 
	else
		self.elm.fontScale = 1.6; 
		
	self.elm.x 			 = 0; 
	self.elm.y		 	 = -40; 
	self.elm.alignX 	 = "center"; 
	self.elm.alignY 	 = "bottom"; 	
	self.elm.horzAlign 	 = "center"; 
	self.elm.vertAlign 	 = "middle"; 
	self.elm.sort		 = 1;
	self.elm.alpha		 = 0.8;
	
	if( !IsDefined( self.bg ) )
		return; 
		
	self.bg.x 			 = 0; 
	self.bg.y 			 = -40; 
	self.bg.alignX 		 = "center"; 
	self.bg.alignY 		 = "middle"; 
	self.bg.horzAlign 	 = "center"; 
	self.bg.vertAlign 	 = "middle"; 
	self.bg.sort		 = -1;
	
	if( level.console )
		self.bg SetShader( "popmenu_bg", 650, 52 ); 
	else
		self.bg SetShader( "popmenu_bg", 650, 42 ); 
	
	if ( !isdefined( bgAlpha ) )
		bgAlpha = 0.5;
	
	self.bg.alpha = bgAlpha;
}

string( num )
{
	return( "" + num ); 
}

ignoreEachOther( group1, group2 )
{
	// these threatbias groups ignore each other
	assertex( ThreatBiasGroupExists( group1 ), "Tried to make threatbias group " + group1 + " ignore " + group2 + " but " + group1 + " does not exist!" ); 
	assertex( ThreatBiasGroupExists( group2 ), "Tried to make threatbias group " + group2 + " ignore " + group1 + " but " + group2 + " does not exist!" ); 
	SetIgnoreMeGroup( group1, group2 ); 
	SetIgnoreMeGroup( group2, group1 ); 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: add_global_spawn_function( <team> , <func> , <param1> , <param2> , <param3> )"
"Summary: All spawners of this team will run this function on spawn."
"Module: Utility"
"MandatoryArg: <team> : The team of the spawners that will run this function."
"MandatoryArg: <func> : The function to run."
"OptionalArg: <param1> : An optional parameter."
"OptionalArg: <param2> : An optional parameter."
"OptionalArg: <param3> : An optional parameter."
"Example: add_global_spawn_function( "axis", ::do_the_amazing_thing, some_amazing_parameter );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

add_global_spawn_function( team, function, param1, param2, param3 )
{
	assertEx( isdefined( level.spawn_funcs ), "Tried to add_global_spawn_function before calling _load" );

	func = [];
	func[ "function" ] = function;
	func[ "param1" ] = param1;
	func[ "param2" ] = param2;
	func[ "param3" ] = param3;

	level.spawn_funcs[ team ][ level.spawn_funcs[ team ].size ] = func;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: remove_global_spawn_function( <team> , <func> )"
"Summary: Remove this function from the global spawn functions for this team."
"Module: Utility"
"MandatoryArg: <team> : The team of the spawners that will no longer run this function."
"MandatoryArg: <func> : The function to remove."
"Example: remove_global_spawn_function( "allies", ::do_the_amazing_thing );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

remove_global_spawn_function( team, function )
{
	assertEx( isdefined( level.spawn_funcs ), "Tried to remove_global_spawn_function before calling _load" );

	array = [];
	for( i = 0; i < level.spawn_funcs[ team ].size; i ++ )
	{
		if( level.spawn_funcs[ team ][ i ][ "function" ] != function )
		{
			array[ array.size ] = level.spawn_funcs[ team ][ i ];
		}
	}
	
	assertEx( level.spawn_funcs[ team ].size != array.size, "Tried to remove a function from level.spawn_funcs, but that function didn't exist!" );
	level.spawn_funcs[ team ] = array;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: add_spawn_function( <func> , <param1> , <param2> , <param3>, <param4> )"
"Summary: Anything that spawns from this spawner will run this function. Anything."
"Module: Utility"
"MandatoryArg: <func1> : The function to run."
"OptionalArg: <param1> : An optional parameter."
"OptionalArg: <param2> : An optional parameter."
"OptionalArg: <param3> : An optional parameter."
"OptionalArg: <param4> : An optional parameter."
"Example: spawner add_spawn_function( ::do_the_amazing_thing, some_amazing_parameter );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

add_spawn_function( function, param1, param2, param3, param4 )
{
	assertEx( !isalive( self ), "Tried to add_spawn_function to a living guy." );
	assertEx( isdefined( self.spawn_functions ), "Tried to add_spawn_function before calling _load" );
	
	func = []; 
	func[ "function" ] = function;
	func[ "param1" ] = param1;
	func[ "param2" ] = param2;
	func[ "param3" ] = param3;
	func[ "param4" ] = param4;
	
	self.spawn_functions[ self.spawn_functions.size ] = func;
}

array_Delete( array )
{
	for( i = 0; i < array.size; i ++ )
	{
		array[ i ] delete();
	}
}

PlayerUnlimitedAmmoThread()
{
	while( 1 )
	{
		wait( 5 ); 

		if ( getdvar( "UnlimitedAmmoOff" ) == "1" )
			continue;
// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player
		players = get_players();
		for( q = 0; q < players.size; q++ )
		{
			currentWeapon = players[q] GetCurrentWeapon(); 
			if( currentWeapon == "none" )
			{
				continue; 
			}
	
			currentAmmo = players[q] GetFractionMaxAmmo( currentWeapon ); 
			if( currentAmmo < 0.2 )
			{
				players[q] GiveMaxAmmo( currentWeapon ); 
			}
		}
	}
}


ignore_triggers( timer )
{
	// ignore triggers for awhile so others can trigger the trigger we're in.
	self endon( "death" ); 
	self.ignoreTriggers = true; 
	if( IsDefined( timer ) )
	{
		wait( timer ); 
	}
	else
	{
		wait( 0.5 ); 
	}
	self.ignoreTriggers = false; 
}

 /* 
 ============= 
///ScriptDocBegin
"Name: delayThread( <delay> , <function> , <arg1> , <arg2> , <arg3> )"
"Summary: Delaythread is cool! It saves you from having to write extra script for once off commands. Note you don�t have to thread it off. Delaythread is that smart!"
"Module: Utility"
"MandatoryArg: <delay> : The delay before the function occurs"
"MandatoryArg: <delay> : The function to run."
"OptionalArg: <arg1> : parameter 1 to pass to the process"
"OptionalArg: <arg2> : parameter 2 to pass to the process"
"OptionalArg: <arg3> : parameter 3 to pass to the process"
"OptionalArg: <arg4> : parameter 4 to pass to the process"
"Example: Delaythread( ::flag_set, "player_can_rappel", 3 );
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

delayThread( timer, func, param1, param2, param3, param4 )
{
	// to thread it off
	thread delayThread_proc( func, timer, param1, param2, param3, param4 );
}

activate_trigger_with_targetname( msg )
{
	trigger = getent( msg, "targetname" );
	trigger activate_trigger();
}

activate_trigger_with_noteworthy( msg )
{
	trigger = getent( msg, "script_noteworthy" );
	trigger activate_trigger();
}

disable_trigger_with_targetname( msg )
{
	trigger = getent( msg, "targetname" );
	trigger trigger_off();
}

disable_trigger_with_noteworthy( msg )
{
	trigger = getent( msg, "script_noteworthy" );
	trigger trigger_off();
}

// SRS 9/6/2008: added "enable" versions for wrapping trigger_on() functionality
enable_trigger_with_targetname( msg )
{
	trigger = getent( msg, "targetname" );
	trigger trigger_on();
}

enable_trigger_with_noteworthy( msg )
{
	trigger = getent( msg, "script_noteworthy" );
	trigger trigger_on();
}

is_hero()
{
	return isdefined( level.hero_list[ get_ai_number() ] );
}

get_ai_number()
{
	if( !IsDefined( self.ai_number ) )
	{
		set_ai_number(); 
	}
	return self.ai_number; 
}

set_ai_number()
{
	self.ai_number = level.ai_number; 
	level.ai_number ++ ;
}

make_hero()
{
	level.hero_list[ self.ai_number ] = true;
}

unmake_hero()
{
	level.hero_list[ self.ai_number ] = undefined;
}

get_heroes()
{
	array = []; 
	ai = GetAiArray( "allies" ); 
	for( i = 0; i < ai.size; i ++ )
	{
		if( ai[ i ] is_hero() )
			array[ array.size ] = ai[ i ];
	}
	return array; 
}

set_team_pacifist( team, val )
{
	ai = GetAiArray( team ); 
	for( i = 0; i < ai.size; i ++ )
	{
		ai[ i ].pacifist = val;
	}
}

replace_on_death()
{
	maps\_colors::colorNode_replace_on_death(); 
}

spawn_reinforcement( classname, color )
{
	maps\_colors::colorNode_spawn_reinforcement( classname, color );
}

clear_promotion_order()
{
	level.current_color_order = []; 
}

set_promotion_order( deadguy, replacer )
{
	if( !IsDefined( level.current_color_order ) )
	{
		level.current_color_order = []; 
	}

	deadguy = shortenColor( deadguy ); 
	replacer = shortenColor( replacer ); 
	
	level.current_color_order[ deadguy ] = replacer;
	
	// if there is no color order for the replacing color than
	// let script assume that it is meant to be replaced by
	// respawning guys
	if( !isdefined( level.current_color_order[ replacer ] ) )
		set_empty_promotion_order( replacer ); 
}

set_empty_promotion_order( deadguy )
{
	if( !IsDefined( level.current_color_order ) )
	{
		level.current_color_order = []; 
	}

	level.current_color_order[ deadguy ] = "none";
}

remove_dead_from_array( array )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
	{
		if( !isalive( array[ i ] ) )
			continue;
		newarray[ newarray.size ] = array[ i ];
	}
	return newarray;
}

remove_heroes_from_array( array )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
	{
		if( array[ i ] is_hero() )
			continue;
		newarray[ newarray.size ] = array[ i ];
	}
	return newarray;
}

remove_all_animnamed_guys_from_array( array )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
	{
		if( isdefined( array[ i ].animname ) )
			continue;
		newarray[ newarray.size ] = array[ i ];
	}
	return newarray;
}

remove_color_from_array( array, color )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
	{
		guy = array[ i ];
		if( !isdefined( guy.script_forceColor ) )
			continue;
		if( guy.script_forceColor == color )
			continue;
		newarray[ newarray.size ] = guy;
	}
	return newarray;
}

remove_noteworthy_from_array( array, noteworthy )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
	{
		guy = array[ i ];
		if( !isdefined( guy.script_noteworthy ) )
			continue;
		if( guy.script_noteworthy == noteworthy )
			continue;
		newarray[ newarray.size ] = guy;
	}
	return newarray;
}

get_closest_colored_friendly( color, origin )
{
	allies = get_force_color_guys( "allies", color ); 
	allies = remove_heroes_from_array( allies ); 

	if( !IsDefined( origin ) )
	{
// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player, TODO: we may want to think of a better solution.
// For now, using players[0]
//		friendly_origin = level.player.origin; 
		players = get_players();
		friendly_origin = players[0].origin; 
	}
	else
	{
		friendly_origin = origin; 
	}

	return getclosest( friendly_origin, allies ); 
}

remove_without_classname( array, classname )
{
	newarray = []; 
	for( i = 0; i < array.size; i ++ )
	{
		if( !issubstr( array[ i ].classname, classname ) )
			continue;
		newarray[ newarray.size ] = array[ i ];
	}
	return newarray;
}

remove_without_model( array, model )
{
	newarray = [];
	for( i = 0; i < array.size; i ++ )
		{
		if( !issubstr( array[ i ].model, model ) )
			continue; 
		newarray[ newarray.size ] = array[ i ];
	}
	return newarray; 
}


get_closest_colored_friendly_with_classname( color, classname, origin )
{
	allies = get_force_color_guys( "allies", color ); 
	allies = remove_heroes_from_array( allies ); 

	if( !IsDefined( origin ) )
	{
// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player, TODO: we may want to think of a better solution.
// For now, using players[0]
//		friendly_origin = level.player.origin; 
		players = get_players();
		friendly_origin = players[0].origin; 
	}
	else
	{
		friendly_origin = origin; 
	}
		
	allies = remove_without_classname( allies, classname ); 

	return getclosest( friendly_origin, allies ); 
}




promote_nearest_friendly( colorFrom, colorTo )
{
	for( ;; )
	{
		friendly = get_closest_colored_friendly( colorFrom ); 
		if( !IsAlive( friendly ) )
		{
			wait( 1 ); 
			continue; 
		}
		
		friendly set_force_color( colorTo ); 
		return; 
	}
}

instantly_promote_nearest_friendly( colorFrom, colorTo )
{
	for( ;; )
	{
		friendly = get_closest_colored_friendly( colorFrom ); 
		if( !IsAlive( friendly ) )
		{
			assertex( 0, "Instant promotion from " + colorFrom + " to " + colorTo + " failed!" ); 
			return; 
		}
		
		friendly set_force_color( colorTo ); 
		return; 
	}
}

instantly_promote_nearest_friendly_with_classname( colorFrom, colorTo, classname )
{
	for( ;; )
	{
		friendly = get_closest_colored_friendly_with_classname( colorFrom, classname ); 
		if( !IsAlive( friendly ) )
		{
			assertex( 0, "Instant promotion from " + colorFrom + " to " + colorTo + " failed!" ); 
			return; 
		}
		
		friendly set_force_color( colorTo ); 
		return; 
	}
}

promote_nearest_friendly_with_classname( colorFrom, colorTo, classname )
{
	for( ;; )
	{
		friendly = get_closest_colored_friendly_with_classname( colorFrom, classname );
		if( !isalive( friendly ) )
		{
			wait( 1 );
			continue;
		}
		
		friendly set_force_color( colorTo );
		return;
	}
}

instantly_set_color_from_array_with_classname( array, color, classname )
{
	 // the guy is removed from the array so the function can be run on the array again
	foundGuy = false;
	newArray = [];
	for( i = 0; i < array.size; i ++ )
	{
		guy = array[ i ];
		if( foundGuy || !isSubstr( guy.classname, classname ) )
		{
			newArray[ newArray.size ] = guy;
			continue;
		}

		foundGuy = true;
		guy set_force_color( color );
	}
	return newArray;
}

instantly_set_color_from_array( array, color )
{
	 // the guy is removed from the array so the function can be run on the array again
	foundGuy = false;
	newArray = [];
	for( i = 0; i < array.size; i ++ )
	{
		guy = array[ i ];
		if( foundGuy  )
		{
			newArray[ newArray.size ] = guy;
			continue;
		}

		foundGuy = true;
		guy set_force_color( color );
	}
	return newArray;
}

wait_for_script_noteworthy_trigger( msg )
{	
	wait_for_trigger( msg, "script_noteworthy" ); 
}

wait_for_targetname_trigger( msg )
{	
	wait_for_trigger( msg, "targetname" ); 
}

wait_for_flag_or_timeout( msg, timer )
{
	if( flag( msg ) )
		return; 
		
	ent = SpawnStruct(); 
	ent thread ent_waits_for_level_notify( msg ); 
	ent thread ent_times_out( timer ); 
	ent waittill( "done" ); 
}

wait_for_trigger_or_timeout( timer )
{
	ent = SpawnStruct(); 
	ent thread ent_waits_for_trigger( self ); 
	ent thread ent_times_out( timer ); 
	ent waittill( "done" ); 
}

wait_for_either_trigger( msg1, msg2 )
{	
	ent = SpawnStruct(); 
	array = []; 
	array = array_combine( array, GetEntArray( msg1, "targetname" ) ); 
	array = array_combine( array, GetEntArray( msg2, "targetname" ) ); 
	for( i = 0; i < array.size; i ++ )
	{
		ent thread ent_waits_for_trigger( array[ i ] );
	}

	ent waittill( "done" ); 
}

dronespawn( spawner )
{
	drone = maps\_spawner::spawner_dronespawn( spawner );
	assert( isdefined( drone ) );
	
	return drone;
}

makerealai( drone )
{
	return maps\_spawner::spawner_makerealai( drone ); 
}

get_trigger_flag()
{
	if( IsDefined( self.script_flag ) )
	{
		return self.script_flag; 
	}
	
	if( IsDefined( self.script_noteworthy ) )
	{
		return self.script_noteworthy; 
	}
	
	assertex( 0, "Flag trigger at " + self.origin + " has no script_flag set." ); 
}

isSpawner()
{
	spawners = GetSpawnerArray(); 
	for( i = 0; i < spawners.size; i ++ )
		{
		if( spawners[ i ] == self )
			return true; 
		}
	return false; 
}

set_default_pathenemy_settings()
{
	if( self.team == "allies" )
	{
		self.pathEnemyLookAhead = 350; 
		self.pathEnemyFightDist = 350; 
		return; 
	}
	if( self.team == "axis" )
	{
		self.pathEnemyLookAhead = 350; 
		self.pathEnemyFightDist = 350; 
		return; 
	}
}

cqb_walk( on_or_off )// ( deprecated )
{
	if( on_or_off == "on" )
	{
		self enable_cqbwalk();
	}
	else
	{
		assert( on_or_off == "off" );
		self disable_cqbwalk();
	}
}

enable_cqbwalk()
{
	self.cqbwalking = true;
	level thread animscripts\cqb::findCQBPointsOfInterest();
	
	 /#
	self thread animscripts\cqb::CQBDebug();
	#/ 
}

disable_cqbwalk()
{
	self.cqbwalking = false;
	self.cqb_point_of_interest = undefined;
	
	/#
	self notify( "end_cqb_debug" );
	#/ 
}

cqb_aim( the_target )
{
	if( !isdefined( the_target ) )
	{
		self.cqb_target = undefined;
	}
	else
	{
		self.cqb_target = the_target;	
		
		if( !isdefined( the_target.origin ) )
			assertmsg( "target passed into cqb_aim does not have an origin!" );
	}
}


set_force_cover( val )
{
	assertex( val == "hide" || val == "none" || val == "show", "invalid force cover set on guy" ); 
	assertex( IsAlive( self ), "Tried to set force cover on a dead guy" ); 
	self.a.forced_cover = val; 
}

waittill_notify_or_timeout( msg, timer )
{
	self endon( msg ); 
	wait( timer ); 
}

do_in_order( func1, param1, func2, param2 )
{
	if( isdefined( param1 ) )
		[[ func1 ]]( param1 );
	else
		[[ func1 ]]();
	if( isdefined( param2 ) )
		[[ func2 ]]( param2 );
	else
		[[ func2 ]]();
}

scrub()
{
	// sets an AI to default settings, ignoring the .script_ values on him.
	self maps\_spawner::scrub_guy(); 
}

send_notify( msg )
{
	// functionalized so it can be function pointer'd
	self notify( msg ); 
}

deleteEnt( ent )
{
	// created so entities can be deleted using array_thread
	ent Delete(); 
}


getfx( fx )
{
	assertEx( isdefined( level._effect[ fx ] ), "Fx " + fx + " is not defined in level._effect." );
	return level._effect[ fx ];
}

getanim( anime )
{
	assertex( IsDefined( self.animname ), "Called getanim on a guy with no animname" ); 
	assertEx( isdefined( level.scr_anim[ self.animname ][ anime ] ), "Called getanim on an inexistent anim" );
	return level.scr_anim[ self.animname ][ anime ];
}

getanim_from_animname( anime, animname )
{
	assertEx( isdefined( animname ), "Must supply an animname" );
	assertEx( isdefined( level.scr_anim[ animname ][ anime ] ), "Called getanim on an inexistent anim" );
	return level.scr_anim[ animname ][ anime ];
}

getanim_generic( anime )
{
	assertEx( isdefined( level.scr_anim[ "generic" ][ anime ] ), "Called getanim_generic on an inexistent anim" );
	return level.scr_anim[ "generic" ][ anime ];
}

add_hint_string( name, string, optionalFunc )
{
	assertex( IsDefined( level.trigger_hint_string ), "Tried to add a hint string before _load was called." ); 
	assertex( IsDefined( name ), "Set a name for the hint string. This should be the same as the script_hint on the trigger_hint." ); 
	assertex( IsDefined( string ), "Set a string for the hint string. This is the string you want to appear when the trigger is hit." ); 
		
	level.trigger_hint_string[ name ] = string;
	precachestring( string );
	if( IsDefined( optionalFunc ) )
	{
		level.trigger_hint_func[ name ] = optionalFunc;
	}
}

fire_radius( origin, radius )
{
	/#
	if( level.createFX_enabled )
	{
		return; 
	}
	#/
	
	trigger = Spawn( "trigger_radius", origin, 0, radius, 48 ); 

	for( ;; )
	{
		trigger waittill( "trigger", other ); 
// SCRIPTER_MOD
// MikeD (3/23/2007): No more level.player
//		assertex( other == level.player, "Tried to burn a non player in a fire" ); 
//		level.player DoDamage( 5, origin ); 
		assertex( IsPlayer( other ), "Tried to burn a non player in a fire" ); 
		other DoDamage( 5, origin ); 
	}
}

clearThreatBias( group1, group2 )
{
	SetThreatBias( group1, group2, 0 ); 
	SetThreatBias( group2, group1, 0 ); 
}

scr_println( msg )
{
	 // so println can be called from a function pointer
	println( msg );
}

 // use in moderation!
ThrowGrenadeAtPlayerASAP()
{
	players = get_players();
	if ( players.size > 0 )
	{
		best_target	= undefined;
		closest_dist	= 99999999;	
		for (i=0;i<players.size;i++)
		{
			if ( isdefined(players[i]) )
			{
				dist = DistanceSquared( self.origin, players[i].origin );
				if ( dist < closest_dist )
				{
					best_target	= players[i];
					closest_dist	= dist;
				}
			}
		}
	
		if ( isdefined(best_target) )
		{
			animscripts\combat_utility::ThrowGrenadeAtPlayerASAP_combat_utility(best_target);
		}
	}
}
// scriptgen precache wrapper commands - Nathan
// This will enable automatic zone source CSV exports if approved

 /* 
	It's important that when you write scripts with sg_precache in 
	them that you halt the scripts that use these assets when a scriptgen dump is required.
	
	If done currectly before the scriptgen dump call all of of the sg_precache commands will happen 
	and you won't have to run the game again to catch new sg_precaches;
	
	Do this to wait untill the sg_precache dump has been called( now it's ok to continue );
	
	sg_wait_dump();
	
	sg_precache lines should go before _load but in the case of tools they can go after.   
	IE in effectsEd somebody could initiate a dump after specifying some new assets to load.

 */ 

sg_precachemodel( model )
{
	script_gen_dump_addline( "precachemodel( \"" + model + "\" );", "xmodel_" + model );// adds to scriptgendump
	
}

sg_precacheitem( item )
{
	script_gen_dump_addline( "precacheitem( \"" + item + "\" );", "item_" + item );// adds to scriptgendump
}

sg_precachemenu( menu )
{
	script_gen_dump_addline( "precachemenu( \"" + menu + "\" );", "menu_" + menu );// adds to scriptgendump
}

sg_precacherumble( rumble )
{
	script_gen_dump_addline( "precacherumble( \"" + rumble + "\" );", "rumble_" + rumble );// adds to scriptgendump
}

sg_precacheshader( shader )
{
	script_gen_dump_addline( "precacheshader( \"" + shader + "\" );", "shader_" + shader );// adds to scriptgendump
}

sg_precacheshellshock( shock )
{
	script_gen_dump_addline( "precacheshellshock( \"" + shock + "\" );", "shock_" + shock );// adds to scriptgendump
}

sg_precachestring( string )
{
	script_gen_dump_addline( "precachestring( \"" + string + "\" );", "string_" + string );// adds to scriptgendump
}

sg_precacheturret( turret )
{
	script_gen_dump_addline( "precacheturret( \"" + turret + "\" );", "turret_" + turret );// adds to scriptgendump
}

sg_precachevehicle( vehicle )
{
	script_gen_dump_addline( "precachevehicle( \"" + vehicle + "\" );", "vehicle_" + vehicle );// adds to scriptgendump
}

sg_getanim( animation )
{
	return level.sg_anim[ animation ];
}

sg_getanimtree( animtree )
{
	return level.sg_animtree[ animtree ];
}



sg_precacheanim( animation, animtree )
{
	if( !isdefined( animtree ) )
		animtree = "generic_human";
	 /* 
	 this is where the money is at.  we no longer have to seperate scripts that have animations in them
	 this eliminates the need for seperate vehiclescript calls, gags with animations, etc. 
	 animations are a string value when sg_precacheanim is called this writes them to the script gen and the CSV as animations
	 usage is something like this
	 
	sg_precacheanim( animation );
	
	when you go to use the anim do:
	
	animation = sg_getanim( animation );
	
	this will get the animation from scriptgen.
	
	 */ 
// 	script_gen_dump_addline( "level.sg_anim[ \"" + animation + "\" ] = %" + animation + ";", "animation_" + animation );// adds to scriptgendump
	
	sg_csv_addtype( "xanim", animation );
	if( !isdefined( level.sg_precacheanims ) )
		level.sg_precacheanims = [];
	if( !isdefined( level.sg_precacheanims[ animtree ] ) )
		level.sg_precacheanims[ animtree ] = [];
	
	level.sg_precacheanims[ animtree ][ animation ] = true;// no sence setting it to anything else if the string is already in array key. beh.
}



sg_getfx( fx )
{
	return level.sg_effect[ fx ];
}

sg_precachefx( fx )
{
	 /* 
	
	effects require an id returned from loadfx. it's a little bit different kind of asset but will work the same as animations
	
	use
	
	sg_getfx( fx ); to get the effects id for the specified effect string
	
	 */ 
	script_gen_dump_addline( "level.sg_effect[ \"" + fx + "\" ] = loadfx( \"" + fx + "\" );", "fx_" + fx );// adds to scriptgendump
}

sg_wait_dump()
{
	flag_wait( "scriptgen_done" );
}

sg_standard_includes()
{
	
	sg_csv_addtype( "ignore", "code_post_gfx" );
	sg_csv_addtype( "ignore", "common" );
	sg_csv_addtype( "col_map_sp", "maps/" + tolower( getdvar( "mapname" ) ) + ".d3dbsp" );
	sg_csv_addtype( "gfx_map", "maps/" + tolower( getdvar( "mapname" ) ) + ".d3dbsp" );
	sg_csv_addtype( "rawfile", "maps/" + tolower( getdvar( "mapname" ) ) + ".gsc" );
	sg_csv_addtype( "rawfile", "maps / scriptgen/" + tolower( getdvar( "mapname" ) ) + "_scriptgen.gsc" );
	
	sg_csv_soundadd( "us_battlechatter", "all_sp" );// todo. find this automagically by ai's
	sg_csv_soundadd( "ab_battlechatter", "all_sp" );// 
	
	sg_csv_soundadd( "voiceovers", "all_sp" );
	sg_csv_soundadd( "common", "all_sp" );
	sg_csv_soundadd( "generic", "all_sp" );
	sg_csv_soundadd( "requests", "all_sp" );

// 	ignore, code_post_gfx
// 	ignore, common
// 	col_map_sp, maps / nate_test.d3dbsp
// 	gfx_map, maps / nate_test.d3dbsp
// 	rawfile, maps / nate_test.gsc
// 	sound, voiceovers, rallypoint, all_sp
// 	sound, us_battlechatter, rallypoint, all_sp
// 	sound, ab_battlechatter, rallypoint, all_sp
// 	sound, common, rallypoint, all_sp
// 	sound, generic, rallypoint, all_sp
// 	sound, requests, rallypoint, all_sp	
	
}

sg_csv_soundadd( type, loadspec )
{
	script_gen_dump_addline( "nowrite Sound CSV entry: " + type, "sound_" + type + ", " + tolower( getdvar( "mapname" ) ) + ", " + loadspec );// adds to scriptgendump
}

sg_csv_addtype( type, string )
{
	script_gen_dump_addline( "nowrite CSV entry: " + type + ", " + string, type + "_" + string );// adds to scriptgendump
}

array_combine_keys( array1, array2 )// mashes them in. array 2 will overwrite like keys, this works for what I'm using it for - Nate.
{
	if( !array1.size )
		return array2;
	keys = getarraykeys( array2 );
	for( i = 0;i < keys.size;i ++ )
		array1[ keys[ i ] ] = array2[ keys[ i ] ];
	return array1;
}

set_ignoreSuppression( val )
{
	self.ignoreSuppression = val;
}

set_goalradius( radius )
{
	self.goalradius = radius;
}

try_forever_spawn()
{
	export = self.export;
	for( ;; )
	{
		assertEx( isdefined( self ), "Spawner with export " + export + " was deleted." );
		guy = self dospawn();
		if( spawn_failed( guy ) )
		{
			wait( 1 );
			continue;
		}
		return guy;
	}
}

set_allowdeath( val )
{
	self.allowdeath = val;
}

set_run_anim( anime, alwaysRunForward )
{
	assertEx( isdefined( anime ), "Tried to set run anim but didn't specify which animation to ues" );
	assertEx( isdefined( self.animname ), "Tried to set run anim on a guy that had no anim name" );
	assertEx( isdefined( level.scr_anim[ self.animname ][ anime ] ), "Tried to set run anim but the anim was not defined in the maps _anim file" );
	
	self.current_speed = anime;

	//this is good for slower run animations like patrol walks
	if( isdefined( alwaysRunForward ) )
		self.alwaysRunForward = alwaysRunForward;
	else
		self.alwaysRunForward = true;
		
	self.a.combatrunanim = level.scr_anim[ self.animname ][ anime ];
	self.run_noncombatanim = self.a.combatrunanim;
	self.walk_combatanim = self.a.combatrunanim;
	self.walk_noncombatanim = self.a.combatrunanim;
	self.preCombatRunEnabled = false;
}

set_generic_run_anim( anime, alwaysRunForward )
{
	assertEx( isdefined( anime ), "Tried to set generic run anim but didn't specify which animation to ues" );
	assertEx( isdefined( level.scr_anim[ "generic" ][ anime ] ), "Tried to set generic run anim but the anim was not defined in the maps _anim file" );
	
	//this is good for slower run animations like patrol walks
	if ( isdefined( alwaysRunForward ) )
	{
		if ( alwaysRunForward )
			self.alwaysRunForward = alwaysRunForward;
		else
			self.alwaysRunForward = undefined;
	}
	else
		self.alwaysRunForward = true;
	
	self.a.combatrunanim = level.scr_anim[ "generic" ][ anime ];
	self.run_noncombatanim = self.a.combatrunanim;
	self.walk_combatanim = self.a.combatrunanim;
	self.walk_noncombatanim = self.a.combatrunanim;
	self.preCombatRunEnabled = false;
}

clear_run_anim()
{
	self.alwaysRunForward = undefined;
	self.a.combatrunanim = undefined;
	self.run_noncombatanim = undefined;
	self.walk_combatanim = undefined;
	self.walk_noncombatanim = undefined;
	self.preCombatRunEnabled = true;
}

debugvar( msg, timer )
{
	if( getdvar( msg ) == "" )
	{
		setdvar( msg, timer );
	}
	return getdvarfloat( msg );
}

physicsjolt_proximity( outer_radius, inner_radius, force )
{
	 // Usage: <entity > thread physicjolt_proximity( 400, 256, ( 0, 0, 0.1 ) );

	self endon( "death" );
	self endon( "stop_physicsjolt" );

	if( !isdefined( outer_radius ) || !isdefined( inner_radius ) || !isdefined( force ) )
	{
		outer_radius = 400;
		inner_radius = 256;
		force = ( 0, 0, 0.075 );	 // no direction on this one.
	}

	fade_distance = outer_radius * outer_radius;

	fade_speed = 3;
	base_force = force;

	while( true )
	{
		wait 0.1; 

		force = base_force;

		if( self.classname == "script_vehicle" )
		{
			speed = self getspeedMPH();
			if( speed < fade_speed )
			{
				scale = speed / fade_speed;
				force = vector_multiply( base_force, scale );
			}
		}

		dist = distancesquared( self.origin, level.player.origin );
		scale = fade_distance / dist;
		if( scale > 1 )
			scale = 1;
		force = vector_multiply( force, scale );
		total_force = force[ 0 ] + force[ 1 ] + force[ 2 ];

		//if( total_force > 0.025 )
		//	physicsJitter( self.origin, outer_radius, inner_radius, force[ 2 ], force[ 2 ] * 2.0 );
	}
}

set_goal_entity( ent )
{
	self setGoalEntity( ent );
}


activate_trigger()
{
	assertEx( !isdefined( self.trigger_off ), "Tried to activate trigger that is OFF( either from trigger_off or from flags set on it through shift - G menu" );

	if( isdefined( self.script_color_allies ) )
	{
		 // so we don't run activate_color_trigger twice, we set this var
		self.activated_color_trigger = true;
		maps\_colors::activate_color_trigger( "allies" );
	}

	if( isdefined( self.script_color_axis ) )
	{ 
		// so we don't run activate_color_trigger twice, we set this var
		self.activated_color_trigger = true;
		maps\_colors::activate_color_trigger( "axis" );
	}
	
	self notify( "trigger" );
	
	if( self.classname != "trigger_friendlychain" )
		return;

	node = getnode( self.target, "targetname" );
	assertEx( isdefined( node ), "Trigger_friendlychain at " + self.origin + " doesn't target a node" );
	level.player setfriendlychain( node );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: self_delete()"
"Summary: Just calls the delete() script command on self. Reason for this is so that we can use array_thread to delete entities"
"Module: Entity"
"CallOn: An entity"
"Example: ai[ 0 ] thread self_delete();"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
self_delete()
{
	self delete();
}

remove_noColor_from_array( ai )
{
	newarray = [];
	for( i = 0; i < ai.size; i ++ )
	{
		guy = ai[ i ];
		if( guy has_color() )
			newarray[ newarray.size ] = guy;
	}
	
	return newarray;
}

has_color()
{
	 // can lose color during the waittillframeend in left_color_node
	if( self.team == "axis" )
	{
		return isdefined( self.script_color_axis ) || isdefined( self.script_forceColor );
	}
	
	return isdefined( self.script_color_allies ) || isdefined( self.script_forceColor );
}

clear_colors()
{
	clear_team_colors( "axis" );
	clear_team_colors( "allies" );
}

clear_team_colors( team )
{
	level.currentColorForced[ team ][ "r" ] = undefined;
	level.currentColorForced[ team ][ "b" ] = undefined;
	level.currentColorForced[ team ][ "c" ] = undefined;
	level.currentColorForced[ team ][ "y" ] = undefined;
	level.currentColorForced[ team ][ "p" ] = undefined;
	level.currentColorForced[ team ][ "o" ] = undefined;
	level.currentColorForced[ team ][ "g" ] = undefined;
}


get_script_palette()
{
	rgb = [];
	rgb[ "r" ] = ( 1, 0, 0 );
	rgb[ "o" ] = ( 1, 0.5, 0 );
	rgb[ "y" ] = ( 1, 1, 0 );
	rgb[ "g" ] = ( 0, 1, 0 );
	rgb[ "c" ] = ( 0, 1, 1 );
	rgb[ "b" ] = ( 0, 0, 1 );
	rgb[ "p" ] = ( 1, 0, 1 );
	return rgb;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: notify_delay( <notify_string> , <delay> )"
"Summary: Notifies self the string after waiting the specified delay time"
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <notify_string> : The string to notify"
"MandatoryArg: <delay> : Time to wait( in seconds ) before sending the notify."
"Example: vehicle notify_delay( "start_to_smoke", 3.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
notify_delay( sNotifyString, fDelay )
{
	assert( isdefined( self ) );
	assert( isdefined( sNotifyString ) );
	assert( isdefined( fDelay ) );
	assert( fDelay > 0 );
	
	self endon( "death" );
	wait fDelay;
	if( !isdefined( self ) )
		return;
	self notify( sNotifyString );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: gun_remove()"
"Summary: Removed the gun from the given AI. Often used for scripted sequences where you dont want the AI to carry a weapon."
"Module: AI"
"CallOn: An AI"
"Example: level.price gun_remove();"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
gun_remove()
{
	self animscripts\shared::placeWeaponOn( self.weapon, "none" );
}

 /* 
 ============= 
 ///ScriptDocBegin
"Name: gun_switchto()"
"Summary: Switches the given AI's gun to the one specified."
"Module: AI"
"CallOn: An AI"
"MandatoryArg: <weaponName> : The weapontype name you want the AI to switch to."
"MandatoryArg: <whichHand> : Which hand to put the weapon in."
"Example: level.zeitzev gun_switchto( "ppsh", "right" );"
"SPMP: singleplayer"
 ///ScriptDocEnd
 ============= 
 */ 
gun_switchto( weaponName, whichHand )
{
	self animscripts\shared::placeWeaponOn( weaponName, whichHand );
}

/* 
 ============= 
///ScriptDocBegin
"Name: gun_recall()"
"Summary: Give the AI his gun back."
"Module: AI"
"CallOn: An AI"
"Example: level.price gun_recall();"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
gun_recall()
{
	self animscripts\shared::placeWeaponOn( self.weapon, "right" );
}

 /* 
 ============= 
 ///ScriptDocBegin
"Name: lerp_player_view_to_tag( <tag> , <lerptime> , <fraction> , <right_arc> , <left_arc> , <top_arc> , <bottom_arc> )"
"Summary: Lerps the player's view to the tag on the entity that calls the function.."
"Module: Utility"
"CallOn: An entity you want to lerp the player's view to."
"MandatoryArg: <ent> : The entity you want to link self (player) to."
"MandatoryArg: <tag> : Tag on the entity that you're lerping to."
"MandatoryArg: <lerptime> : Time to lerp over."
"OptionalArg: <fraction> : 0 to 1 amount that the rotation of the player's view should be effected by the entity. If you set it less than 1 then the player's view will not get all the way to the final angle."
"OptionalArg: <arcs> : Various arcs that limit how far the player can change his view."
"Example: players[0] lerp_player_view_to_tag( car, "tag_windshield", 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 

// MikeD (11/12/2007): Modified to support co-op. No more level.player
lerp_player_view_to_tag( ent, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc )
{
	if( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	lerp_player_view_to_tag_internal( ent, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, false );
}

/* 
============= 
///ScriptDocBegin
"Name: lerp_player_view_to_tag_and_hit_geo( <tag> , <lerptime> , <fraction> , <right_arc> , <left_arc> , <top_arc> , <bottom_arc> )"
"Summary: Lerps the player's view to the tag on the entity that calls the function. Geo will block the player."
"Module: Utility"
"CallOn: An entity you want to lerp the player's view to."
"MandatoryArg: <tag> : Tag on the entity that you're lerping to."
"MandatoryArg: <lerptime> : Time to lerp over."
"OptionalArg: <fraction> : 0 to 1 amount that the rotation of the player's view should be effected by the entity. If you set it less than 1 then the player's view will not get all the way to the final angle."
"OptionalArg: <arcs> : Various arcs that limit how far the player can change his view."
"Example: car lerp_player_view_to_tag_and_hit_geo( "tag_windshield", 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 
	
lerp_player_view_to_tag_and_hit_geo( ent, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc )
{
	if( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	lerp_player_view_to_tag_internal( ent, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, true );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: lerp_player_view_to_position( <origin> , <angles> , <lerptime> , <fraction> , <right_arc> , <left_arc> , <top_arc> , <bottom_arc>, <hit_geo> )"
"Summary: Lerps the player's view to an origin and angles. See lerp_player_view_to_tag."
"Module: Utility"
"MandatoryArg: <origin> : The origin you're lerping to."
"MandatoryArg: <angles> : The angles you're lerping to."
"MandatoryArg: <lerptime> : Time to lerp over."
"OptionalArg: <fraction> : 0 to 1 amount that the rotation of the player's view should be effected by the destination angles. If you set it less than 1 then the player's view will not get all the way to the final angle."
"OptionalArg: <arcs> : Various arcs that limit how far the player can change his view."
"OptionalArg: <hit_geo> : Sets if the player will hit geo."
"Example: lerp_player_view_to_position( org.origin, org.angles );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

lerp_player_view_to_position( origin, angles, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo )
{
	if( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	linker = spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = self.origin;
	linker.angles = self getplayerangles();

	if( isdefined( hit_geo ) )
	{
		self playerlinkto( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo );
	}
	else if( isdefined( right_arc ) )
	{
		self playerlinkto( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc );
	}
	else if( isdefined( fraction ) )
	{
		self playerlinkto( linker, "", fraction );
	}
	else
	{
		self playerlinkto( linker );
	}
		
	linker moveto( origin, lerptime, lerptime * 0.25 );
	linker rotateto( angles, lerptime, lerptime * 0.25 );
//	wait( lerptime );
	linker waittill( "movedone" );
	linker delete();
}


/* 
============= 
///ScriptDocBegin
"Name: lerp_player_view_to_tag_oldstyle( <tag> , <lerptime> , <fraction> , <right_arc> , <left_arc> , <top_arc> , <bottom_arc> )"
"Summary: Lerps the player's view to the tag on the entity that calls the function, using the oldstyle link which moves the player's view when the tag rotates."
"Module: Utility"
"CallOn: An entity you want to lerp the player's view to."
"MandatoryArg: <tag> : Tag on the entity that you're lerping to."
"MandatoryArg: <lerptime> : Time to lerp over."
"OptionalArg: <fraction> : 0 to 1 amount that the rotation of the player's view should be effected by the entity. If you set it less than 1 then the player's view will not get all the way to the final angle."
"OptionalArg: <arcs> : Various arcs that limit how far the player can change his view."
"Example: car lerp_player_view_to_tag_oldstyle( "tag_windshield", 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 
lerp_player_view_to_tag_oldstyle( tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc )
{
	lerp_player_view_to_tag_oldstyle_internal( tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, false );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: lerp_player_view_to_position_oldstyle( <origin> , <angles> , <lerptime> , <fraction> , <right_arc> , <left_arc> , <top_arc> , <bottom_arc>, <hit_geo> )"
"Summary: Lerps the player's view to an origin and angles. See lerp_player_view_to_tag_oldstyle. Oldstyle means that you're going to move to the point where the player's feet would be, rather than directly below the point where the view would be."
"Module: Utility"
"MandatoryArg: <origin> : The origin you're lerping to."
"MandatoryArg: <angles> : The angles you're lerping to."
"MandatoryArg: <lerptime> : Time to lerp over."
"OptionalArg: <fraction> : 0 to 1 amount that the rotation of the player's view should be effected by the destination angles. If you set it less than 1 then the player's view will not get all the way to the final angle."
"OptionalArg: <arcs> : Various arcs that limit how far the player can change his view."
"OptionalArg: <hit_geo> : Sets if the player will hit geo."
"Example: lerp_player_view_to_position_oldstyle( org.origin, org.angles );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

lerp_player_view_to_position_oldstyle( origin, angles, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo )
{
	if( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	linker = spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = get_player_feet_from_view();
	linker.angles = level.player getplayerangles();

	if( isdefined( hit_geo ) )
	{
		self playerlinktodelta( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo );
	}
	else
	if( isdefined( right_arc ) )
	{
		self playerlinktodelta( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc );
	}
	else
	if( isdefined( fraction ) )
	{
		self playerlinktodelta( linker, "", fraction );
	}
	else
	{
		self playerlinktodelta( linker );
	}
		
	linker moveto( origin, lerptime, lerptime * 0.25 );
	linker rotateto( angles, lerptime, lerptime * 0.25 );
//	wait( lerptime );
	linker waittill( "movedone" );
	linker delete();
}

 /* 
 ============= 
///ScriptDocBegin
"Name: lerp_player_view_to_moving_position_oldstyle( <origin> , <angles> , <lerptime> , <fraction> , <right_arc> , <left_arc> , <top_arc> , <bottom_arc>, <hit_geo> )"
"Summary: Lerps the player's view to an origin and angles. See lerp_player_view_to_tag_oldstyle. Oldstyle means that you're going to move to the point where the player's feet would be, rather than directly below the point where the view would be."
"Module: Utility"
"MandatoryArg: <origin> : The origin you're lerping to."
"MandatoryArg: <angles> : The angles you're lerping to."
"MandatoryArg: <lerptime> : Time to lerp over."
"OptionalArg: <fraction> : 0 to 1 amount that the rotation of the player's view should be effected by the destination angles. If you set it less than 1 then the player's view will not get all the way to the final angle."
"OptionalArg: <arcs> : Various arcs that limit how far the player can change his view."
"OptionalArg: <hit_geo> : Sets if the player will hit geo."
"Example: lerp_player_view_to_position_oldstyle( org.origin, org.angles );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

lerp_player_view_to_moving_position_oldstyle( ent, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo )
{
	if( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	linker = spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = self.origin;
	linker.angles = self getplayerangles();

	if( isdefined( hit_geo ) )
	{
		self playerlinktodelta( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc, hit_geo );
	}
	else
	if( isdefined( right_arc ) )
	{
		self playerlinktodelta( linker, "", fraction, right_arc, left_arc, top_arc, bottom_arc );
	}
	else
	if( isdefined( fraction ) )
	{
		self playerlinktodelta( linker, "", fraction );
	}
	else
	{
		self playerlinktodelta( linker );
	}

	max_count=lerptime/0.0167;
	count=0;
	while (count < max_count)
	{		
		origin = ent gettagorigin( tag );
		angles = ent gettagangles( tag );
		
		linker moveto( origin, 0.0167*(max_count-count) );
		linker rotateto( angles, 0.0167*(max_count-count) );
		wait( 0.0167 );
		count++;
	}
	linker delete();
}

// can't make a function pointer out of a code command
timer( time )
{
	wait( time );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: waittill_either_function( <func1> , <parm1> , <func2> , <parm2> )"
"Summary: Returns when either func1 or func2 have returned."
"Module: Utility"
"MandatoryArg: <func1> : A function pointer to a function that may return at some point."
"MandatoryArg: <func2> : Another function pointer to a function that may return at some point."
"OptionalArg: <parm1> : An optional parameter for func1."
"OptionalArg: <parm2> : An optional parameter for func2."
"Example: player_moves( 500 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 

waittill_either_function( func1, parm1, func2, parm2 )
{
	ent = spawnstruct();
	thread waittill_either_function_internal( ent, func1, parm1 );
	thread waittill_either_function_internal( ent, func2, parm2 );
	ent waittill( "done" );
}

waittill_msg( msg )
{
	if( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	self waittill( msg );
}
 

 /* 
 ============= 
///ScriptDocBegin
"Name: display_hint( <hint> )"
"Summary: Displays a hint created with add_hint_string."
"Module: Utility"
"MandatoryArg: <hint> : The hint reference created with add_hint_string."
"Example: display_hint( "huzzah" )"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
display_hint( hint )
{
	if ( getdvar( "chaplincheat" ) == "1" )
		return;

	// hint triggers have an optional function they can boolean off of to determine if the hint will occur
	// such as not doing the NVG hint if the player is using NVGs already
	if( isdefined( level.trigger_hint_func[ hint ] ) )
	{
		if( [[ level.trigger_hint_func[ hint ] ]]() )
			return;

		HintPrint( level.trigger_hint_string[ hint ], level.trigger_hint_func[ hint ] );
	}
	else
	{
		HintPrint( level.trigger_hint_string[ hint ] );
	}
}

getGenericAnim( anime )
{
	assertex( isdefined( level.scr_anim[ "generic" ][ anime ] ), "Generic anim " + anime + " was not defined in your _anim file." );
	return level.scr_anim[ "generic" ][ anime ];
}

/* 
============= 
///ScriptDocBegin
"Name: enable_careful()"
"Summary: Makes an AI not advance into his fixednode safe radius if an enemy enters it."
"Module: AI"
"Example: guy enable_careful()"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 
enable_careful()
{
	assertex( isai( self ), "Tried to make an ai careful but it wasn't called on an AI" );
	self.script_careful = true;
}

/* 
============= 
///ScriptDocBegin
"Name: disable_careful()"
"Summary: Turns off careful mode for this AI."
"Module: AI"
"Example: guy disable_careful()"
"SPMP: singleplayer"
///ScriptDocEnd
============= 
*/ 
disable_careful()
{
	assertex( isai( self ), "Tried to unmake an ai careful but it wasn't called on an AI" );
	self.script_careful = false;
	self notify( "stop_being_careful" );
}
	
clear_dvar( msg )
{
	setdvar( msg, "" );
}

/*
=============
///ScriptDocBegin
"Name: mission( <name> )"
"Summary: Returns true if name is the current mission"
"Module: Utility"
"MandatoryArg: <name>: Name of the mission to test"
"Example: if ( mission( "bog_a" ) )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
mission( name )
{
	return level.script == name;
}
		
set_fixednode_true()
{
	self.fixednode = true;
}
	
set_fixednode_false()
{
	self.fixednode = true;
}


spawn_ai()
{
	if ( isdefined( self.script_forcespawn ) )
		return self stalingradSpawn();
	return self doSpawn();
}

 /* 
 ============= 
///ScriptDocBegin
"Name: function_stack( <function>, <param1>, <param2>, <param3>, <param4> )"
"Summary: function stack is used to thread off multiple functions one after another an insure that they get called in the order you sent them in (like a FIFO queue or stack). function_stack will wait for the function to finish before continuing the next line of code, but since it internally threads the function off, the function will not end if the parent function which called function_stack() ends.  function_stack is also local to the entity that called it, if you call it on nothing it will use level and all functions sent to the stack will wait on the previous one sent to level.  The same works for entities.  This way you can have 2 AI's that thread off multiple functions but those functions are in individual stacks for each ai"
"Module: utility"
"CallOn: level or an entity."
"MandatoryArg: <function> : the function to send to the stack" 
"OptionalArg: <param1> : An optional parameter for <function>."
"OptionalArg: <param2> : An optional parameter for <function>."
"OptionalArg: <param3> : An optional parameter for <function>."
"OptionalArg: <param4> : An optional parameter for <function>."
"Example: level thread function_stack(::radio_dialogue, "scoutsniper_mcm_okgo" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
function_stack( func, param1, param2, param3, param4 )
{
	self endon( "death" );
	localentity = spawnstruct();
	localentity thread function_stack_proc( self, func, param1, param2, param3, param4 );
	localentity waittill_either( "function_done", "death" );
}

geo_off()
{
	if( isDefined( self.geo_off ) )
		return;
	
	self.realorigin = self getorigin();	
	self moveto(self.realorigin + (0,0, -10000), .2);	

	self.geo_off = true;
}

geo_on()
{
	if( !isDefined( self.geo_off ) )
		return;
		
	self moveto(self.realorigin, .2);	
	self waittill( "movedone");
	self.geo_off = undefined;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_blur( <magnitude>, <transition time> )"
"Summary: calls script command setblur( <magnitude>, <transition time> )"
"Module: utility"
"CallOn: "
"MandatoryArg: <magnitude> : amount of blur to transition to" 
"MandatoryArg: <transition time> : time in seconds to transition to desired blur amount"
"Example: set_blur( 8, 3.1 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */
set_blur( magnitude, time )
{
	self setblur( magnitude, time );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_goal_node( <node> )"
"Summary: calls script command setgoalnode( <node> ), but also sets self.last_set_goalnode to <node>"
"Module: AI"
"CallOn: AI"
"MandatoryArg: <node> : node to send the ai to"
"Example: guy set_goal_node( node );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_goal_node( node )
{
	self.last_set_goalnode 	= node;
	self.last_set_goalpos 	= undefined;
	self.last_set_goalent 	= undefined;

	self setgoalnode( node );
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_goal_pos( <origin> )"
"Summary: calls script command setgoalpos( <origin> ), but also sets self.last_set_goalpos to <origin>"
"Module: AI"
"CallOn: AI"
"MandatoryArg: <origin> : origin to send the ai to"
"Example: guy set_goal_pos( vector );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */
set_goal_pos( origin )
{
	self.last_set_goalnode 	= undefined;
	self.last_set_goalpos 	= origin;
	self.last_set_goalent 	= undefined;
	
	self setgoalpos( origin );
}

/*
=============
///ScriptDocBegin
"Name: set_goal_ent( <entity> )"
"Summary: calls script command setgoalpos( <entity>.origin ), but also sets self.last_set_goalent to <origin>"
"Module: AI"
"CallOn: AI"
"MandatoryArg: <entity> : entity with .origin variable to send the ai to"
"Example: guy set_goal_ent( script_origin );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_goal_ent( target )
{
	set_goal_pos( target.origin );
	self.last_set_goalent 	= target;
}

/*
=============
///ScriptDocBegin
"Name: objective_complete( <obj> )"
"Summary: Sets an objective to DONE"
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <obj>: The objective index"
"Example: objective_complete( 3 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
objective_complete( obj )
{
	objective_state( obj, "done" );
	level notify( "objective_complete" + obj );
}


/*
=============
///ScriptDocBegin
"Name: run_thread_on_targetname( <msg> , <func> , <param1> , <param2> , <param3> )"
"Summary: Runs the specified thread on any entity with that targetname"
"Module: Utility"
"MandatoryArg: <msg>: The targetname"
"MandatoryArg: <func>: The function"
"OptionalArg: <param1>: Optional argument"
"OptionalArg: <param2>: Optional argument"
"OptionalArg: <param3>: Optional argument"
"Example: run_thread_on_targetname( "chopper_guys", ::add_spawn_function, ::chopper_guys_land );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

run_thread_on_targetname( msg, func, param1, param2, param3 )
{
	array = getentarray( msg, "targetname" );
	array_thread( array, func, param1, param2, param3 );
}


/*
=============
///ScriptDocBegin
"Name: run_thread_on_noteworthy( <msg> , <func> , <param1> , <param2> , <param3> )"
"Summary: Runs the specified thread on any entity with that noteworthy"
"Module: Utility"
"MandatoryArg: <msg>: The noteworthy"
"MandatoryArg: <func>: The function"
"OptionalArg: <param1>: Optional argument"
"OptionalArg: <param2>: Optional argument"
"OptionalArg: <param3>: Optional argument"
"Example: run_thread_on_noteworthy( "chopper_guys", ::add_spawn_function, ::chopper_guys_land );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/


run_thread_on_noteworthy( msg, func, param1, param2, param3 )
{
	array = getentarray( msg, "script_noteworthy" );
	
	array_thread( array, func, param1, param2, param3 );
}



/*
=============
///ScriptDocBegin
"Name: handsignal( <xanim> , <ender> , <waiter> )"
"Summary: Makes an AI do a handsignal"
"Module: Utility"
"CallOn: An ai"
"MandatoryArg: <xanim>: The string name of the animation. See below for list."
"OptionalArg: <ender>: An optional ender "
"OptionalArg: <waiter>: An optional string to wait for level notify on "
"Example: level.price handsignal( "go" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============

Add this to your _anim script:
	level.scr_anim[ "generic" ][ "signal_onme" ]				= %CQB_stand_wave_on_me;
	level.scr_anim[ "generic" ][ "signal_go" ]					= %CQB_stand_wave_go_v1;
	level.scr_anim[ "generic" ][ "signal_stop" ]				= %CQB_stand_signal_stop;
	

*/
handsignal( xanim, ender, waiter )
{
	if ( isdefined( ender ) )
		level endon( ender );
		
	if ( isdefined( waiter ) )
		level waittill( waiter );
	
	switch ( xanim )
	{
		case "go":
			self setanimrestart( getGenericAnim( "signal_go" ), 1, 0, 1.1 );
			break;	
		case "onme":
			self maps\_anim::anim_generic( self, "signal_onme" );
			break;
		case "stop":
			self setanimrestart( getGenericAnim( "signal_stop" ), 1, 0, 1.1 );
			break;
		case "moveup":
			self setanimrestart( getGenericAnim( "signal_moveup" ), 1, 0, 1.1 );
			break;
	}
}

get_guy_with_script_noteworthy_from_spawner( script_noteworthy )
{
	spawner = getentarray( script_noteworthy, "script_noteworthy" );
	assertex( spawner.size == 1, "Tried to get guy from spawner but there were zero or multiple spawners" );
	guys = array_spawn( spawner );
	return guys[ 0 ];
}

get_guy_with_targetname_from_spawner( targetname )
{
	spawner = getentarray( targetname, "targetname" );
	assertex( spawner.size == 1, "Tried to get guy from spawner but there were zero or multiple spawners" );
	guys = array_spawn( spawner );
	return guys[ 0 ];
}

get_guys_with_targetname_from_spawner( targetname )
{
	spawners = getentarray( targetname, "targetname" );
	assertex( spawners.size > 0, "Tried to get guy from spawner but there were zero spawners" );
	return array_spawn( spawners );
}

/*
=============
///ScriptDocBegin
"Name: array_spawn( <spawners> )"
"Summary: "
"Module: Utility"
"CallOn: An array of spawners"
"MandatoryArg: <spawners>: The spawners"
"Example: guys = array_spawn( hooligans );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
array_spawn( spawners )
{
	guys = [];
	for ( i = 0; i < spawners.size; i++ )
	{
		spawner = spawners[ i ];
		spawner.count = 1;
		guy = spawner spawn_ai();
		spawn_failed( guy );
		assertEx( isalive( guy ), "Guy with export " + spawner.export + " failed to spawn." );
		guys[ guys.size ] = guy;
	}
	
	assertex( guys.size == spawners.size, "Didnt spawn correct number of guys" );
	
	return guys;
}

/*
=============
///ScriptDocBegin
"Name: add_dialogue_line( <name> , <msg> )"
"Summary: Prints temp dialogue on the screen in lieu of a sound alias."
"Module: Utility"
"MandatoryArg: <name>: The character."
"MandatoryArg: <msg>: The dialogue."
"Example: thread add_dialogue_line( "MacMillan", "Put me down over there on the slope by the mattress." );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_dialogue_line( name, msg )
{
	if( getdvarint("loc_warnings") )
		return;  // I'm not localizing your damn temp dialog lines - Nate.
		
	if ( !isdefined( level.dialogue_huds ) )
	{
		level.dialogue_huds = [];
	}

	for ( index = 0;; index++ )
	{
		if ( !isdefined( level.dialogue_huds[ index ] ) )
			break;
	}
	
	level.dialogue_huds[ index ] = true;

	hudelem = maps\_hud_util::createFontString( "default", 1.5 );
	hudelem.location = 0;
	hudelem.alignX = "left";
	hudelem.alignY = "top";
	hudelem.foreground = 1;
	hudelem.sort = 20;

	hudelem.alpha = 0;
	hudelem fadeOverTime( 0.5 );
	hudelem.alpha = 1;
	hudelem.x = 40;
	hudelem.y = 260 + index * 18;
	hudelem.label = "<" + name + "> " + msg;
	hudelem.color = (1,1,0);
	
	wait( 2 );
	timer = 2 * 20;
	hudelem fadeOverTime( 6 );
	hudelem.alpha = 0;
	
	for ( i = 0; i < timer; i++ )
	{
		hudelem.color = ( 1,1, 1 / ( timer - i ) );
		wait( 0.05 );
	}
	wait( 4 );
	
	hudelem destroy();
	
	level.dialogue_huds[ index ] = undefined;
}

alphabetize( array )
{
	if ( array.size <= 1 )
		return array;
		
	count = 0;
	for ( ;; )
	{
		changed = false;
		for ( i = 0; i < array.size - 1; i++ )
		{
			if ( is_later_in_alphabet( array[ i ], array[ i + 1 ] ) )
			{
				val = array[ i ];
				array[ i ] = array[ i + 1 ];
				array[ i + 1 ] = val;
				changed = true;
				count++;
				if ( count >= 10 )
				{
					count = 0;
					wait( 0.05 );
				}
			}
		}
		
		if ( !changed )
			return array;
	}
	
	return array;
}
set_grenadeammo( count )
{
	self.grenadeammo = count;
}

// self = player
get_player_feet_from_view()
{
	tagorigin = self.origin;
	upvec = anglestoup( self getplayerangles() );
	height = self GetPlayerViewHeight();
	
	player_eye = tagorigin + (0,0,height);
	player_eye_fake = tagorigin + vector_multiply( upvec, height );
	
	diff_vec = player_eye - player_eye_fake;
	
	fake_origin = tagorigin + diff_vec;
	return fake_origin;
}


set_baseaccuracy( val )
{
	self.baseaccuracy = val;
}

set_console_status()
{
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _utility.gsc. Function: set_console_status()\n");
	#/
	
	if ( !isdefined( level.Console ) )
		level.Console = getdvar( "consoleGame" ) == "true";
	else
		assertex( level.Console == ( getdvar( "consoleGame" ) == "true" ), "Level.console got set incorrectly." );

	if ( !isdefined( level.Consolexenon ) )
		level.xenon = getdvar( "xenonGame" ) == "true";
	else
		assertex( level.xenon == ( getdvar( "xenonGame" ) == "true" ), "Level.xenon got set incorrectly." );
			
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _utility.gsc. Function: set_console_status() - COMPLETE\n");
	#/
}

autosave_now( optional_useless_string, suppress_print )
{
	return maps\_autosave::autosave_game_now( suppress_print );
}

set_generic_deathanim( deathanim )
{
	self.deathanim = getgenericanim( deathanim );
}

set_deathanim( deathanim )
{
	self.deathanim = getanim( deathanim );
}

clear_deathanim()
{
	self.deathanim = undefined;
}

/*
=============
///ScriptDocBegin
"Name: hunted_style_door_open( <soundalias> )"
"Summary: Animates the door/gate/whatever in the style of Hunted's cool price door opening."
"Module: Utility"
"CallOn: A door or gate calls it"
"OptionalArg: <Soundalias>: A soundalias to play "
"Example: door hunted_style_door_open( "door_wood_slow_creaky_open" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
hunted_style_door_open( soundalias )
{
	wait( 1.75 );

	if ( isdefined( soundalias ) )
		self playsound( soundalias );
	else
		self playsound( "door_wood_slow_open" );
		
	self rotateto( self.angles + ( 0, 70, 0 ), 2, .5, 0 );
	self connectpaths();
	self waittill( "rotatedone" );
	self rotateto( self.angles + ( 0, 40, 0 ), 2, 0, 2 );
}

/*
=============
///ScriptDocBegin
"Name: palm_style_door_open( <soundalias> )"
"Summary: Animates the door/gate/whatever in the style of Hunted's cool price door opening but with the palm instead of door knob."
"Module: Utility"
"CallOn: A door or gate calls it"
"OptionalArg: <Soundalias>: A soundalias to play "
"Example: door palm_style_door_open( "door_wood_slow_creaky_open" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
palm_style_door_open( soundalias )
{
	wait( 1.35 );

	if ( isdefined( soundalias ) )
		self playsound( soundalias );
	else
		self playsound( "door_wood_slow_open" );
		
	self rotateto( self.angles + ( 0, 70, 0 ), 2, .5, 0 );
	self connectpaths();
	self waittill( "rotatedone" );
	self rotateto( self.angles + ( 0, 40, 0 ), 2, 0, 2 );
}



/*
=============
///ScriptDocBegin
"Name: lerp_fov_overtime( <time> , <destfov> )"
"Summary: lerps from the current cg_fov value to the destfov value linearly over time"
"Module: Player"
"CallOn: Level"
"MandatoryArg: <time>: time to lerp"
"OptionalArg: <destfov>: field of view to go to"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

lerp_fov_overtime( time, destfov )
{
	basefov = getdvarfloat( "cg_fov" );
	incs = int( time/.05 
	);
	incfov = (  destfov  -  basefov  ) / incs ;
	currentfov = basefov;
	for ( i = 0; i < incs; i++ )
	{
		currentfov += incfov;
		setsaveddvar( "cg_fov", currentfov );
		wait .05;
	}
	//fix up the little bit of rounding error. not that it matters much .002, heh
	setsaveddvar( "cg_fov", destfov );
	
}

/*
=============
///ScriptDocBegin
"Name: putGunAway()"
"Summary: Puts the AI's weapon away"
"Module: Utility"
"CallOn: An ai"
"Example: level.price putGunAaway();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

putGunAway()
{
	animscripts\shared::placeWeaponOn( self.weapon, "none" );
	self.weapon = "none";
}

/*
=============
///ScriptDocBegin
"Name: apply_fog()"
"Summary: Applies the "start" fog settings for this trigger"
"Module: Utility"
"CallOn: A trigger_fog"
"Example: trigger_fog apply_fog()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
apply_fog()
{
	maps\_load::set_fog_progress( 0 );
}

/*
=============
///ScriptDocBegin
"Name: apply_end_fog()"
"Summary: Applies the "end" fog settings for this trigger"
"Module: Utility"
"CallOn: A trigger_fog"
"Example: trigger_fog apply_end_fog()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
apply_end_fog()
{
	maps\_load::set_fog_progress( 1 );
}


anim_stopanimscripted()
{
	self stopanimscripted();
	self notify( "single anim", "end" );
	self notify( "looping anim", "end" );
}

/*
=============
///ScriptDocBegin
"Name: disable_pain()"
"Summary: Disables pain on the AI"
"Module: Utility"
"CallOn: An ai"
"Example: level.zakhaev disable_pain();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_pain()
{
	assertex( isalive( self ), "Tried to disable pain on a non ai" );
	self.a.disablePain = true;
}

/*
=============
///ScriptDocBegin
"Name: enable_pain()"
"Summary: Enables pain on the AI"
"Module: Utility"
"CallOn: An ai"
"Example: level.zakhaev enable_pain();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_pain()
{
	assertex( isalive( self ), "Tried to enable pain on a non ai" );
	self.a.disablePain = false;
}

_delete()
{
	self delete();
}

/*
=============
///ScriptDocBegin
"Name: disable_oneshotfx_with_noteworthy( <noteworthy> )"
"Summary: Disables _global_fx that have the given noteworthy on them"
"Module: Utility"
"MandatoryArg: <noteworthy>: The script_noteworthy"
"Example: disable_oneshotfx_with_noteworthy( "blackout_spotlight_fx" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_oneshotfx_with_noteworthy( noteworthy )
{
	assertex( isdefined( level._global_fx_ents[ noteworthy ] ), "No _global_fx ents have noteworthy " + noteworthy );
	keys = getarraykeys( level._global_fx_ents[ noteworthy ] );
	for ( i = 0; i < keys.size; i++ )
	{
		level._global_fx_ents[ noteworthy ][ keys[ i ] ].looper delete();
		level._global_fx_ents[ noteworthy ][ keys[ i ] ] = undefined;
	}
}

_setLightIntensity( val )
{
	self setLightIntensity( val );
}


_linkto( targ, tag, org, angles )
{
	if ( isdefined( angles ) )
	{
		self linkto( targ, tag, org, angles );
		return;
	}
	if ( isdefined( org ) )
	{
		self linkto( targ, tag, org );
		return;
	}
	if ( isdefined( tag ) )
	{
		self linkto( targ, tag );
		return;
	}
	self linkto( targ );
}

/*
=============
///ScriptDocBegin
"Name: array_wait( <array>, <msg>, <timeout> )"
"Summary: waits for every entry in the <array> to recieve the <msg> notify, die, or timeout"
"Module: Utility"
"MandatoryArg: <array>: the array of entities to wait on"
"MandatoryArg: <msg>: the msg each array entity will wait on"
"OptionalArg: <timeout>: timeout to kill the wait prematurely"
"Example: array_wait( guys, "at the hq" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
array_wait(array, msg, timeout)
{	
	keys = getarraykeys(array);	
	structs = [];
	for(i=0; i<keys.size; i++)
	{
		key = keys[i];
		
	}
	
	for(i=0; i<keys.size; i++)
	{
		key = keys[i];
		structs[ key ] = spawnstruct();
		structs[ key ]._array_wait = true;	
		
		structs[ key ] thread array_waitlogic1( array[ key ], msg, timeout );
	}
	
	for(i=0;i<keys.size; i++)
	{
		key = keys[i];
		if( isdefined( array[ key ] ) && structs[ key ]._array_wait)
			structs[ key ] waittill( "_array_wait" );	
	}
}

/*
=============
///ScriptDocBegin
"Name: die()"
"Summary: The entity does damage to itself of > health value"
"Module: Utility"
"CallOn: An entity"
"Example: enemy die();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
die()
{
	self dodamage( self.health + 150, (0,0,0) );
}

/*
=============
///ScriptDocBegin
"Name: getmodel( <model> )"
"Summary: Returns the level.scr_model[ model ]"
"Module: Utility"
"MandatoryArg: <model>: The string index into level.scr_model"
"Example: setmodel( getmodel( "zakhaevs arm" ) );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
getmodel( str )
{
	assertex( isdefined( level.scr_model[ str ] ), "Tried to getmodel on model " + str + " but level.scr_model[ " + str + " was not defined." );
	return level.scr_model[ str ];
}

/*
=============
///ScriptDocBegin
"Name: isADS()"
"Summary: Returns true if the player is more than 50% ads"
"Module: Utility"
"Example: player_is_ads = isADS();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
isADS( player )
{
	return ( player playerADS() > 0.5 );
}

/*
=============
///ScriptDocBegin
"Name: enable_auto_adjust_threatbias()"
"Summary: Allows auto adjust to change the player threatbias. Defaults to on"
"Module: Utility"
"Example: enable_auto_adjust_threatbias();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

enable_auto_adjust_threatbias(player)
{
	level.auto_adjust_threatbias = true;

	if ( level.gameskill >= 2 )
	{
		// hard and vet use locked values
		player.threatbias = int( maps\_gameskill::get_locked_difficulty_val( "threatbias", 1 ) );
		return;
	}
	
	// set the threatbias based on the current difficulty frac
	level.auto_adjust_difficulty_frac = getdvarint( "autodifficulty_frac" );
	current_frac = level.auto_adjust_difficulty_frac * 0.01;
	
	// get the scalar value for threat bias
	players = get_players();
	level.coop_player_threatbias_scalar = maps\_gameskill::getCoopValue( "coopFriendlyThreatBiasScalar", players.size  );	
	
	if (!isdefined(level.coop_player_threatbias_scalar))
	{
		level.coop_player_threatbias_scalar = 1;
	}	
			
	player.threatbias = int( maps\_gameskill::get_blended_difficulty( "threatbias", current_frac ) * level.coop_player_threatbias_scalar);
}

/*
=============
///ScriptDocBegin
"Name: disable_auto_adjust_threatbias()"
"Summary: Disallows auto adjust to change the player threatbias. Defaults to on"
"Module: Utility"
"Example: disable_auto_adjust_threatbias();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

disable_auto_adjust_threatbias()
{
	level.auto_adjust_threatbias = false;
}

/*
=============
///ScriptDocBegin
"Name: disable_replace_on_death()"
"Summary: Disables replace on death"
"Module: Color"
"CallOn: An AI"
"Example: guy disable_replace_on_death();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_replace_on_death()
{
	self.replace_on_death = undefined;
	self notify( "_disable_reinforcement" );
}

/*
=============
///ScriptDocBegin
"Name: waittill_player_lookat( <fov>, <timer> )"
"Summary: Waits until the player is looking at this entity."
"Module: Utility"
"CallOn: An AI"
"OptionalArg: <fov>: Overwrite the default fov "
"OptionalArg: <timer>: Optional parameter to control how long you have to look before it triggers"
"OptionalArg: <dot_only>: If true, it will only check FOV and not tracepassed"
"Example: level.price waittill_player_lookat();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
waittill_player_lookat( dot, timer, dot_only )
{
	if ( !isdefined( dot ) )
		dot = 0.92;

	if ( !isdefined( timer ) )
		timer = 0;
	
	base_time = int( timer * 20 );
	count = base_time;
	self endon( "death" );
	ai_guy = isai( self );
	org = undefined;
	for ( ;; )
	{
		if ( ai_guy )
			org = self geteye();
		else
			org = self.origin;
			
		if ( player_looking_at( org, dot, dot_only ) )
		{
			count--;
			if ( count <= 0 )
				return true;
		}
		else
		{
			count = base_time;
		}
		wait( 0.1 );
	}
}

/*
=============
///ScriptDocBegin
"Name: waittill_player_lookat_for_time( <timer> , <dot> )"
"Summary: Wait until the player is looking at this entity for x time"
"Module: Utility"
"CallOn: An AI"
"MandatoryArg: <timer>: How long the player must look before the timer passes "
"OptionalArg: <dot>: Optional override dot"
"OptionalArg: <dot_only>: If true, it will only check FOV and not tracepassed"
"Example: self waittill_player_lookat_for_time( 0.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
waittill_player_lookat_for_time( timer, dot, dot_only )
{
	assertex( isdefined( timer ), "Tried to do waittill_player_lookat_for_time with no time parm." );
	waittill_player_lookat( dot, timer, dot_only );
}

/*
=============
///ScriptDocBegin
"Name: player_looking_at( <org>, <dot> )"
"Summary: Checks to see if the player can dot and trace to a point"
"Module: Utility"
"MandatoryArg: <org>: The position you're checking if the player is looking at"
"OptionalArg: <dot>: Optional override dot"
"OptionalArg: <dot_only>: If true, it will only check FOV and not tracepassed"
"Example: if ( player_looking_at( org.origin ) )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_looking_at( start, dot, dot_only )
{
	end = level.player geteye();
	
	angles = vectorToAngles( start - end );
	forward = anglesToForward( angles );
	player_angles = level.player getplayerangles();
	player_forward = anglesToForward( player_angles );
		
	new_dot = vectordot( forward, player_forward );
	if ( new_dot < dot )
	{
		return false;
	}
	
	if ( isdefined( dot_only ) )
	{
		assertex( dot_only, "dot_only must be true or undefined" );
		return true;
	}
	
	trace = bullettrace( start, end, false, undefined );
	return trace[ "fraction" ] == 1;
}



/*
=============
///ScriptDocBegin
"Name: add_wait( <func> , <parm1> , <parm2> , <parm3> )"
"Summary: Adds a function that you want to wait for completion on. Self of the function will be whatever add_wait is called on. Make sure you call add_wait before any wait, since the functions are stored globally."
"Module: Utility"
"MandatoryArg: <func>: The function."
"OptionalArg: <parm1>: Optional parameter"
"OptionalArg: <parm2>: Optional parameter"
"OptionalArg: <parm3>: Optional parameter"
"Example: add_wait( ::waittill_player_lookat );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_wait( func, parm1, parm2, parm3 )
{
	ent = spawnstruct();
	
	ent.caller = self;
	ent.func = func;
	ent.parms = [];
	if ( isdefined( parm1 ) )
	{
		ent.parms[ ent.parms.size ] = parm1;
	}
	if ( isdefined( parm2 ) )
	{
		ent.parms[ ent.parms.size ] = parm2;
	}
	if ( isdefined( parm3 ) )
	{
		ent.parms[ ent.parms.size ] = parm3;
	}
	
	level.wait_any_func_array[ level.wait_any_func_array.size ] = ent;
}

/*
=============
///ScriptDocBegin
"Name: add_func( <func> , <parm1> , <parm2> , <parm3> )"
"Summary: Adds a function that runs after an add_wait/do_wait completes."
"Module: Utility"
"MandatoryArg: <func>: The function."
"OptionalArg: <parm1>: Optional parameter"
"OptionalArg: <parm2>: Optional parameter"
"OptionalArg: <parm3>: Optional parameter"
"Example: add_func( ::waittill_player_lookat );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_func( func, parm1, parm2, parm3 )
{
	ent = spawnstruct();
	
	ent.caller = self;
	ent.func = func;
	ent.parms = [];
	if ( isdefined( parm1 ) )
	{
		ent.parms[ ent.parms.size ] = parm1;
	}
	if ( isdefined( parm2 ) )
	{
		ent.parms[ ent.parms.size ] = parm2;
	}
	if ( isdefined( parm3 ) )
	{
		ent.parms[ ent.parms.size ] = parm3;
	}
	
	level.run_func_after_wait_array[ level.run_func_after_wait_array.size ] = ent;
}

/*
=============
///ScriptDocBegin
"Name: add_endon( <endon> )"
"Summary: Adds an endon that will kill a do_wait. Threads can't acquire a parent's endons so this is a way to force an endon in cases where a do_wait could be killed, otherwise it'll cause a thread leak."
"Module: Utility"
"MandatoryArg: <endon>: The endon."
"Example: level.price add_endon( "shazam" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_endon( name )
{
	ent = spawnstruct();
	ent.caller = self;
	ent.ender = name;
	
	level.do_wait_endons_array[ level.do_wait_endons_array.size ] = ent;
}

/*
=============
///ScriptDocBegin
"Name: do_wait_any()"
"Summary: Waits until any of functions defined by add_wait complete. Clears the global variable where the functions were being stored."
"Module: Utility"
"Example: do_wait_any();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
do_wait_any()
{
	assertex( isdefined( level.wait_any_func_array ), "Tried to do a do_wait without addings funcs first" );
	assertex( level.wait_any_func_array.size > 0, "Tried to do a do_wait without addings funcs first" );
	do_wait( level.wait_any_func_array.size - 1 );
}

/*
=============
///ScriptDocBegin
"Name: do_wait()"
"Summary: Waits until all of the functions defined by add_wait complete. Clears the global variable where the functions were being stored."
"Module: Utility"
"Example: do_wait();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
do_wait( count_to_reach )
{
	if ( !isdefined( count_to_reach ) )
		count_to_reach = 0;

		
	assertex( isdefined( level.wait_any_func_array ), "Tried to do a do_wait without addings funcs first" );
	ent = spawnstruct();
	array = level.wait_any_func_array;
	endons = level.do_wait_endons_array;
	after_array = level.run_func_after_wait_array;
	
 	level.wait_any_func_array = [];
 	level.run_func_after_wait_array = [];
 	level.do_wait_endons_array = [];

	ent.count = array.size;
	ent array_levelthread( array, ::waittill_func_ends, endons );
	for ( ;; )
	{
		if ( ent.count <= count_to_reach )
			break;
		ent waittill( "func_ended" );
	}
	ent notify( "all_funcs_ended" );

	array_levelthread( after_array, ::exec_func, [] );
}


/*
=============
///ScriptDocBegin
"Name: is_default_start()"
"Summary: Returns true if you're playing from the default start"
"Module: Utility"
"Example: if ( is_default_start() )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
is_default_start()
{
	return level.start_point == "default";
}

_Earthquake( scale, duration, source, radius )
{
	Earthquake( scale, duration, source, radius );
}

/*
=============
///ScriptDocBegin
"Name: waterfx( <endflag> )"
"Summary: Makes AI have trails in water. Can be used on the player as well, so you're not a vampire."
"Module: Utility"
"CallOn: An AI or player"
"OptionalArg: <endflag>: A flag to end on "
"Example: level.price thread waterfx();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
waterfx( endflag )
{
// currently using these devraw fx:
//	level._effect[ "water_stop" ]						= loadfx( "misc/parabolic_water_stand" );
//	level._effect[ "water_movement" ]					= loadfx( "misc/parabolic_water_movement" );

	if ( isdefined( endflag ) )
	{
		flag_assert( endflag );
		level endon( endflag );
	}
	for ( ;; )
	{
		wait( randomfloatrange( 0.15, 0.3 ) );
		start = self.origin + (0,0,150);
		end = self.origin - (0,0,150);
		trace = BulletTrace( start, end, false, undefined );
		if ( trace[ "surfacetype" ] != "water" )
			continue;

		fx = "water_movement";
		if ( self == level.player )
		{
			if ( distance( level.player getvelocity(), (0,0,0) ) < 5 )
			{
				fx = "water_stop";
			}
		}
		else
		if ( isdefined( level._effect[ "water_" + self.a.movement ] ) )
		{
			fx = "water_" + self.a.movement;
		}
		
		playfx( getfx( fx ), trace[ "position" ], trace[ "normal" ] );			
	}
}

/*
=============
///ScriptDocBegin
"Name: mix_up( <sound> )"
"Summary: Used to blend sounds on a script model vehicle. See maps\sniperescape_code::seaknight_sound()"
"Module: Utility"
"CallOn: A sound blend entity"
"OptionalArg: <Sound>: The sound alias to blend, blends with the _off version of the alias. "
"Example: maps\sniperescape_code::seaknight_sound();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
mix_up( sound )
{
	timer = 3 * 20;
	for ( i = 0; i < timer; i++ )
	{
		self SetSoundBlend( sound, sound + "_off", ( timer - i ) / timer );
		wait( 0.05 );
	}
}

/*
=============
///ScriptDocBegin
"Name: mix_down( <sound> )"
"Summary: Used to blend sounds on a script model vehicle. See maps\sniperescape_code::seaknight_sound()"
"Module: Utility"
"CallOn: A sound blend entity"
"OptionalArg: <Sound>: The sound alias to blend, blends with the _off version of the alias. "
"Example: maps\sniperescape_code::seaknight_sound();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
mix_down( sound )
{
	timer = 3 * 20;
	for ( i = 0; i < timer; i++ )
	{
		self SetSoundBlend( sound, sound + "_off", i / timer );
		wait( 0.05 );
	}
}

/*
=============
///ScriptDocBegin
"Name: manual_linkto( <entity> , <offset> )"
"Summary: Sets an entity to the origin of another entity every server frame, for entity types that don't support linkto"
"Module: Utility"
"CallOn: An entity that doesn't support linkto, like soundblend entities."
"MandatoryArg: <entity>: The entity to link to "
"OptionalArg: <offset>: The offset to use "
"Example: flyblend thread manual_linkto( self, (0,0,0) );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
manual_linkto( entity, offset )
{
	entity endon( "death" );
	self endon( "death" );
	// for entities that don't support linkto, like soundblend entities
	if ( !isdefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	
	for ( ;; )
	{
		self.origin = entity.origin + offset;
		self.angles = entity.angles;
		wait( 0.05 );
	}
}

make_array( index1, index2, index3, index4, index5 )
{
	assertex( isdefined( index1 ), "Need to define index 1 at least" );
	array = [];
	array[ array.size ] = index1;
	if ( isdefined( index2 ) )
	{
		array[ array.size ] = index2;
	}
	
	if ( isdefined( index3 ) )
	{
		array[ array.size ] = index3;
	}
	
	if ( isdefined( index4 ) )
	{
		array[ array.size ] = index4;
	}
	
	if ( isdefined( index5 ) )
	{
		array[ array.size ] = index5;
	}
	
	return array;
}


/*
=============
///ScriptDocBegin
"Name: fail_on_friendly_fire()"
"Summary: If this is run, the player will fail the mission if he kills a friendly"
"Module: Utility"
"Example: fail_on_friendly_fire();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fail_on_friendly_fire()
{
	if ( !isdefined( level.friendlyfire_friendly_kill_points ) )
	{
		level.friendlyfire_friendly_kill_points = level.friendlyfire[ "friend_kill_points" ];
	}
	level.friendlyfire[ "friend_kill_points" ] 	= -60000;
}

/*
=============
///ScriptDocBegin
"Name: normal_friendly_fire_penalty()"
"Summary: Returns friendly fire penalty to normal"
"Module: Utility"
"Example: normal_friendly_fire_penalty();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
normal_friendly_fire_penalty()
{
	if ( !isdefined( level.friendlyfire_friendly_kill_points ) )
		return;
		
	level.friendlyfire[ "friend_kill_points" ] = level.friendlyfire_friendly_kill_points ;
}

/*
=============
///ScriptDocBegin
"Name: getPlayerClaymores()"
"Summary: Returns the number of claymores the player has"
"Module: Utility"
"Example: count = getPlayerClaymores();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
getPlayerClaymores()
{
	heldweapons = level.player getweaponslist();
	stored_ammo = [];
	for ( i = 0; i < heldweapons.size; i++ )
	{
		weapon = heldweapons[ i ];
		stored_ammo[ weapon ] = level.player getWeaponAmmoClip( weapon );
	}
			
	
	claymoreCount = 0;
	if ( isdefined( stored_ammo[ "claymore" ] ) && stored_ammo[ "claymore" ] > 0 )
	{
		claymoreCount = stored_ammo[ "claymore" ];
	}
	return claymoreCount;
}

/*
=============
///ScriptDocBegin
"Name: getPlayerC4()"
"Summary: Returns the number of c4 the player has"
"Module: Utility"
"Example: count = getPlayerC4();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
getPlayerC4()
{
	heldweapons = level.player getweaponslist();
	stored_ammo = [];
	for ( i = 0; i < heldweapons.size; i++ )
	{
		weapon = heldweapons[ i ];
		stored_ammo[ weapon ] = level.player getWeaponAmmoClip( weapon );
	}
			
	
	c4Count = 0;
	if ( isdefined( stored_ammo[ "c4" ] ) && stored_ammo[ "c4" ] > 0 )
	{
		c4Count = stored_ammo[ "c4" ];
	}
	return c4Count;
}

_wait( timer )
{
	wait( timer );
}

_setsaveddvar( var, val )
{
	setsaveddvar( var, val );
}
 
/*
=============
///ScriptDocBegin
"Name: giveachievement_wrapper( <achievment>, [all_players] )"
"Summary: Gives an Achievement to the specified player"
"Module: Coop"
"MandatoryArg: <achievment>: The code string for the achievement"
"OptionalArg: [all_players]: If true, then give everyone the achievement"
"Example: player giveachievement_wrapper( "MAK_ACHIEVEMENT_RYAN" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
giveachievement_wrapper( achievement, all_players )
{
	if ( achievement == "" )
		return;
	
	//no chieves in coopEPD(public demo)
	if ( isCoopEPD() )
		return;
		
	if( !( maps\_cheat::is_cheating() ) && ! ( flag("has_cheated") ) )
	{
		if( IsDefined( all_players ) && all_players )
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				players[i] GiveAchievement( achievement );
			}
		}
		else
		{
			if( !IsPlayer( self ) )
			{
				println( "^1self needs to be a player for _utility::giveachievement_wrapper()" );
				return;
			}

			self GiveAchievement( achievement );
		}
	}
}

/*
=============
///ScriptDocBegin
"Name: delete_on_not_defined()"
"Summary: Weapons don't seem to notify death when they're picked up."
"Module: Utility"
"CallOn: An entity"
"Example: javelin delete_on_not_defined()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
delete_on_not_defined()
{
	for ( ;; )
	{
		if ( !isdefined( self ) )
			return;
		wait( 0.05 );
	}
}

slowmo_start()
{
	flag_set( "disable_slowmo_cheat" );
}

slowmo_end()
{
	maps\_cheat::slowmo_system_defaults();
	flag_clear( "disable_slowmo_cheat" );	
}

slowmo_setspeed_slow( speed )
{
	if( !maps\_cheat::slowmo_check_system() )
		return;
		
	level.slowmo.speed_slow = speed;
}

slowmo_setspeed_norm( speed )
{
	if( !maps\_cheat::slowmo_check_system() )
		return;
	
	level.slowmo.speed_norm = speed;
}

slowmo_setlerptime_in( time )
{
	if( !maps\_cheat::slowmo_check_system() )
		return;
	
	level.slowmo.lerp_time_in = time;
}

slowmo_setlerptime_out( time )
{
	if( !maps\_cheat::slowmo_check_system() )
		return;
	
	level.slowmo.lerp_time_out = time;
}

slowmo_lerp_in()
{
	if( !flag( "disable_slowmo_cheat" ) )
		return;
	
	level.slowmo thread maps\_cheat::gamespeed_set( level.slowmo.speed_slow, level.slowmo.speed_current, level.slowmo.lerp_time_in );	
	//level.slowmo thread maps\_cheat::gamespeed_slowmo();
}

slowmo_lerp_out()
{
	if( !flag( "disable_slowmo_cheat" ) )
		return;
		
	level.slowmo thread maps\_cheat::gamespeed_reset();
}

add_earthquake( name, mag, duration, radius )
{
	level.earthquake[ name ][ "magnitude" ] = mag;
	level.earthquake[ name ][ "duration" ] = duration;
	level.earthquake[ name ][ "radius" ] = radius;
}

// CODER_MOD: TommyK (8/5/08)
/*
=============
///ScriptDocBegin
"Name: arcademode_assignpoints( <amountDvar> , <player> )"
"Summary: Assign points in arcade mode."
"Module: ArcadeMode"
"MandatoryArg: <amountDvar>: arcade mode dvar with points value"
"MandatoryArg: <player>: player to give points too"
"Example: arcademode_assignpoints( "arcademode_score_explodableitem", self );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
arcademode_assignpoints( amountDvar, player )
{
	if ( getdvar( "arcademode" ) != "1" )
		return;
	thread maps\_arcademode::arcademode_assignpoints_toplayer( amountDvar, player );
}


arcadeMode()
{
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _utility.gsc. Function: arcadeMode()\n");
	#/
	isArcadeMode = getdvar( "arcademode" ) == "1";
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _utility.gsc. Function: arcadeMode() - COMPLETE\n");
	#/
	return isArcadeMode;
	
}

coopGame()
{
	return (( getdvar( "systemlink" ) == "1" ) || (getdvar( "onlinegame" ) == "1" ) || IsSplitScreen() );
//	players = GetPlayers();
//	return ( players.size > 1);
}

// CODER_MOD: Austin (08/30/08): added to spawn in corpse by collectible
#using_animtree ("generic_human");
collectible_corpse_spawn( origin_target, enemy_char_model_function )
{
	orig = GetStruct( origin_target, "targetname" );

	if( !IsDefined( orig ) )
	{
		ASSERTMSG( "collectible_corpse: couldn't GetStruct: '" + origin_target + "'" );
	}

	orig.origin = groundpos( orig.origin );

	corpse = Spawn( "script_model", orig.origin );
	corpse.angles = orig.angles;
	corpse [[ enemy_char_model_function ]]();
	corpse Detach( corpse.gearModel );
	corpse UseAnimTree( #animtree );
	corpse.animname = "collectible";
	corpse.targetname = "collectible_corpse";

	corpse thread maps\_anim::anim_loop_solo( corpse, "collectible_loop", undefined, "stop_collectible_loop", orig );

	level waittill( "stop_collectible_loop" );
	corpse notify( "stop_collectible_loop" );
	wait( 0.1 );
	corpse Delete();
}


MusicPlayWrapper( song, timescale, overrideCheat )
{
	level.last_song = song;
	if ( !arcadeMode() )
	{
		if ( !isdefined( timescale ) )
			timescale = true;
		if ( !isdefined( overrideCheat ) )
			overrideCheat = false;
		MusicPlay( song, timescale, overrideCheat );
	}
}

player_is_near_live_grenade()
{
	grenades = getentarray( "grenade", "classname" );
	for ( i = 0; i < grenades.size; i++ )
	{
		grenade = grenades[ i ];
		
		players = get_players();
		for( j = 0; j < players.size; j++ )
		{
			if( DistanceSquared( grenade.origin, players[j].origin ) < 250 * 250 )	// grenade radius is 220
			{
			/# 
				maps\_autosave::auto_save_print( "autosave failed: live grenade too close to player " + j ); 
			#/

				return true;
			}
		}
	}

	return false;
}

player_died_recently()
{
	return getdvarint( "player_died_recently" ) > 0;
}

lerp_dvar_value( dvar, value, time )
{
	steps = time * 20;
	curr_value = GetDvarFloat( dvar );
	diff = ( curr_value - value ) / steps;
	
	for( i = 0; i < steps; i++ )
	{
		curr_value = curr_value - diff;
		SetSavedDvar( dvar, curr_value );
		wait( 0.05 );
	}
	
	SetSavedDvar( dvar, value );
}


/*
=============
///ScriptDocBegin
"Name: set_splitscreen_fog( [start_dist], [halfway_dist], [halfway_height], [base_height], [red], [green], [blue], [trans_time], [cull_dist] )"
"Summary: Sets the splitscreen fog for the level"
"Module: Splitscreen"
"OptionalArg: [start_dist]: the distance the fog starts at from the player's camera"
"OptionalArg: [halfway_dist]: the half-way mark for where the fog is 50% opaque"
"OptionalArg: [halfway_height]: the half-way height mark for where the fog starts to fade out"
"OptionalArg: [base_height]: the base height"
"OptionalArg: [red]: how much red to apply, 0 - 1"
"OptionalArg: [green]: how much green to apply, 0 - 1"
"OptionalArg: [blue]: how much blue to apply, 0 - 1 "
"OptionalArg: [trans_time]: the time it takes to go from it's current fog setting to the new fog setting"
"OptionalArg: [cull_dist]: the distance at which the game stop rendering objects"
"Example: set_splitscreen_fog( 500, 2000, 100000, 0, 0.5, 0.5, 0.5, 1, 4000 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_splitscreen_fog( start_dist, halfway_dist, halfway_height, base_height, red, green, blue, trans_time, cull_dist )
{
	if( !IsSplitScreen() )
	{
		return; 
	}

/#
	if( !IsDefined( start_dist ) && !IsDefined( halfway_dist ) && !IsDefined( halfway_height ) && !IsDefined( base_height ) && !IsDefined( red ) && !IsDefined( green ) && !IsDefined( blue ) )
	{
		level thread default_fog_print();
	}
#/

	if( !IsDefined( start_dist ) )
	{
		start_dist = 0;
	}

	if( !IsDefined( halfway_dist ) )
	{
		halfway_dist = 200;
	}

	if( !IsDefined( base_height ) )
	{
		base_height = -2000;
	}

	if( !IsDefined( red ) )
	{
		red = 1;
	}

	if( !IsDefined( green ) )
	{
		green = 1;
	}

	if( !IsDefined( blue ) )
	{
		blue = 0;
	}

	if( !IsDefined( trans_time ) )
	{
		trans_time = 0;
	}

	if( !IsDefined( cull_dist ) )
	{
		cull_dist = 2000;
	}

	halfway_height = base_height + 2000;

	// This is used to make sure we set it up properly, if not _load should check this var and set the fog again.
	level.splitscreen_fog = true;

	SetVolFog( start_dist, halfway_dist, halfway_height, base_height, red, green, blue, 0 );
	//this not working
	//setVolFog( 0, 11.5, 46, 0, .62, .68, .57, 0);
	SetCullDist( cull_dist ); 
}

default_fog_print()
{
	wait_for_first_player();

	iprintlnbold( "^3USING DEFAULT FOG SETTINGS FOR SPLITSCREEN" );
	wait( 8 );
	iprintlnbold( "^3USING DEFAULT FOG SETTINGS FOR SPLITSCREEN" );
	wait( 8 );
	iprintlnbold( "^3USING DEFAULT FOG SETTINGS FOR SPLITSCREEN" );
}

// SCRIPTER_MOD
// MikeD( 03/07/07 ): Coop Section...

//--------------//
// Coop Section //
//--------------//

/*
=============
///ScriptDocBegin
"Name: share_screen( <player>, <toggle>, [instant] )"
"Summary: Toggles on/off the ability to show 1 screen instead of multiple while playing splitscreen"
"Module: Splitscreen"
"Example: share_screen( player, true );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
share_screen( player, toggle, instant )
{
	if( !IsSplitscreen() )
	{
		return;
	}

	time = 1;

	if( IsDefined( instant ) && instant )
	{
		time = 0.1;
	}

	// Set toggle to the opposite. Since the utility script name is different from the code
	// function.
	toggle = !toggle;

	SplitViewAllowed( player GetEntityNumber(), toggle, time );
}

/*
=============
///ScriptDocBegin
"Name: get_players()"
"Summary: Returns all of the players currently in the level"
"Module: Coop"
"Example: players = get_players();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_players()
{
	players = GetPlayers();
	return players; 
}

/*
=============
///ScriptDocBegin
"Name: get_host()"
"Summary: Returns the host of the game"
"Module: Coop"
"Example: host = get_host();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_host()
{
	players = get_players(); 

	for( i = 0; i < players.size; i++ )
	{
		if( players[i] GetEntityNumber() == 0 )
		{
			return players[i];
		}
	}
}

/*
=============
///ScriptDocBegin
"Name: is_coop()"
"Summary: Returns true if we're playing a coop game"
"Module: Coop"
"Example: if( is_coop() )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
is_coop()
{
	players = get_players();
	if( players.size > 1 )
	{
		return true;
	}

	return false;
}

/*
=============
///ScriptDocBegin
"Name: any_player_IsTouching( <ent> )"
"Summary: Return true/false if any player in touching the given entity."
"Module: Coop"
"MandatoryArg: <ent>: The entity to check against if a player is touching"
"Example: if( any_player_IsTouching( trigger ) )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
any_player_IsTouching( ent )
{
	players = get_players(); 

	for( i = 0; i < players.size; i++ )
	{
		if( IsAlive( players[i] ) && players[i] IsTouching( ent ) )
		{
			return true; 
		}
	}

	return false; 
}

/*
=============
///ScriptDocBegin
"Name: get_player_touching( <ent> )"
"Summary: Returns the player that is touching the given entity, if no players are touching the entity, it returns undefined."
"Module: Coop"
"MandatoryArg: <ent>: The entity to use to see if the player is touching"
"Example: toucher = get_player_touching( trigger ) )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_player_touching( ent )
{
	players = get_players(); 

	for( i = 0; i < players.size; i++ )
	{
		if( IsAlive( players[i] ) && players[i] IsTouching( ent ) )
		{
			return players[i]; 
		}
	}

	return undefined; 
}

/*
=============
///ScriptDocBegin
"Name: get_closest_player( <org> )"
"Summary: Returns the closest player to the given origin."
"Module: Coop"
"MandatoryArg: <origin>: The vector to use to compare the distances to"
"Example: closest_player = get_closest_player( objective.origin );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_closest_player( org )
{
	players = get_players(); 

	return GetClosest( org, players ); 
}


add_player_spawnpoint( spawnpoint )
{
	if( !IsDefined( level.player_spawnpoints ) )
	{
		clear_player_spawnpoints(); 
	}

	level.player_spawnpoints[level.player_spawnpoints.size] = spawnpoint; 
}

clear_player_spawnpoints()
{
	level.player_spawnpoints = []; 
}

set_player_spawnpoints( spawnpoints )
{
	level.player_spawnpoints = spawnpoints; 
}

freezecontrols_all( toggle, delay )
{
	if( IsDefined( delay ) )
	{
		wait( delay );
	}

	players = get_players(); 
	
	for( i = 0; i < players.size; i++ )
	{
		players[i] FreezeControls( toggle ); 
	}
}

/*
=============
///ScriptDocBegin
"Name: get_random_player()"
"Summary: Returns a random player."
"Module: Coop"
"Example: player = get_random_player();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_random_player()
{
	players = get_players(); 
	
	// DPG 6/25/07 need to reassign the returned array to the players array
	players = array_randomize( players ); 
	
	return players[0]; 
}

/*
=============
///ScriptDocBegin
"Name: set_all_players_blur( <amount>, <time> )"
"Summary: Sets the given blur on all of the players."
"Module: Coop"
"MandatoryArg: <amount>: The amount of blur you want"
"MandatoryArg: <time>: The duration that it will take to go from the current blur to the specified blur"
"Example: set_all_players_blur( 5, 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_all_players_blur( amount, time )
{
	wait_for_first_player();
	flag_wait( "all_players_connected" );

	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		players[i] SetBlur( amount, time ); 
	}
}

/*
=============
///ScriptDocBegin
"Name: set_all_players_double_vision( <amount>, <time> )"
"Summary: Sets the given double vision on all of the players."
"Module: Coop"
"MandatoryArg: <amount>: The amount of double vision you want"
"MandatoryArg: <time>: The duration that it will take to go from the current double vision to the specified double vision"
"Example: set_all_players_double_vision( 5, 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_all_players_double_vision( amount, time )
{
	wait_for_first_player();
	flag_wait( "all_players_connected" );

	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		players[i] SetDoubleVision( amount, time );
	}
}

/*
=============
///ScriptDocBegin
"Name: set_all_players_shock( <shellshock_file>, <time> )"
"Summary: Sets the given shellshock on all of the players
"Module: Coop"
"MandatoryArg: <shellshock_file>: The shellshock file used on all of the players"
"MandatoryArg: <time>: The duration that it will take to go from the current shellshock (if any) to the specified shellshock"
"Example: set_all_players_shock( "mak_shellshock", 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_all_players_shock( shellshock_file, time )
{
	wait_for_first_player();
	flag_wait( "all_players_connected" );

	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		players[i] Shellshock( shellshock_file, time ); 
	}
}

/*
=============
///ScriptDocBegin
"Name: set_all_players_visionset( <vision_file>, <time> )"
"Summary: Sets the given vision set on all of the players."
"Module: Coop"
"MandatoryArg: <vision_file>: The vision file used on all of the players"
"MandatoryArg: <time>: The duration that it will take to go from the current vision set (if any) to the specified vision set"
"Example: set_all_players_visionset( "mak_intro", 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_all_players_visionset( vision_file, time )
{
	wait_for_first_player();
	flag_wait( "all_players_connected" );

	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		players[i] VisionSetNaked( vision_file, time ); 
	}
}

/*
=============
///ScriptDocBegin
"Name: hide_all_player_models()"
"Summary: Hides all of the player's 3rd person models"
"Module: Coop"
"Example: hide_all_player_models();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
hide_all_player_models()
{
	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		players[i] Hide(); 
	}	
}

/*
=============
///ScriptDocBegin
"Name: show_all_player_models()"
"Summary: Shows all of the player's 3rd person models"
"Module: Coop"
"Example: show_all_player_models();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
show_all_player_models()
{
	flag_wait( "all_players_connected" );

	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		players[i] Show(); 
	}	
}

// SCRIPTER_MOD
// JesseS( 3/15/2007 ): Added co-op flags sections, didn't convert trigger flags for now.
// TODO: Covert trigger based flag setting
player_flag_wait( msg )
{
	while( !self.flag[msg] )
	{
		self waittill( msg ); 
	}
}

player_flag_wait_either( flag1, flag2 )
{
	for( ;; )
	{
		if( flag( flag1 ) )
		{
			return; 
		}

		if( flag( flag2 ) )
		{
			return; 
		}
		
		self waittill_either( flag1, flag2 ); 
	}
}

player_flag_waitopen( msg )
{
	while( self.flag[msg] )
	{
		self waittill( msg ); 
	}
}

player_flag_init( message, trigger )
{
	if( !IsDefined( self.flag ) )
	{
		self.flag = []; 
		self.flags_lock = []; 
	}

	assertex( !IsDefined( self.flag[message] ), "Attempt to reinitialize existing message: " + message ); 
	self.flag[message] = false; 
/#
	self.flags_lock[message] = false; 
#/
}

player_flag_set_delayed( message, delay )
{
	wait( delay ); 
	player_flag_set( message ); 
}

player_flag_set( message )
{
/#
	assertex( IsDefined( self.flag[message] ), "Attempt to set a flag before calling flag_init: " + message ); 
	assert( self.flag[message] == self.flags_lock[message] ); 
	self.flags_lock[message] = true; 
#/	
	self.flag[message] = true; 
	self notify( message ); 
}

player_flag_clear( message )
{
/#
	assertex( IsDefined( self.flag[message] ), "Attempt to set a flag before calling flag_init: " + message ); 
	assert( self.flag[message] == self.flags_lock[message] ); 
	self.flags_lock[message] = false; 
#/	
	self.flag[message] = false; 
	self notify( message ); 
}

player_flag( message )
{
	assertex( IsDefined( message ), "Tried to check flag but the flag was not defined." ); 
	if( !self.flag[message] )
	{
		return false; 
	}

	return true; 
}

/*
=============
///ScriptDocBegin
"Name: wait_for_first_player()"
"Summary: Waits for the first player to connect before returning"
"Module: Coop"
"Example: wait_for_first_player();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
wait_for_first_player()
{
	players = get_players();
	if( !IsDefined( players ) || players.size == 0 )
	{
		level waittill( "first_player_ready" );
	}
}

/*
=============
///ScriptDocBegin
"Name: wait_for_all_players()"
"Summary: Waits for all of the players to connect before returning"
"Module: Coop"
"Example: wait_for_all_players();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
wait_for_all_players()
{
	flag_wait( "all_players_connected" );
}

findBoxCenter( mins, maxs )
{
	center = ( 0, 0, 0 );
	center = maxs - mins;
	center = ( center[0]/2, center[1]/2, center[2]/2 ) + mins;
	return center;
}

expandMins( mins, point )
{
	if ( mins[0] > point[0] )
	{
		mins = ( point[0], mins[1], mins[2] );
	}
	if ( mins[1] > point[1] )
	{
		mins = ( mins[0], point[1], mins[2] );
	}
	if ( mins[2] > point[2] )
	{
		mins = ( mins[0], mins[1], point[2] );
	}
	return mins;
}

expandMaxs( maxs, point )
{
	if ( maxs[0] < point[0] )
	{
		maxs = ( point[0], maxs[1], maxs[2] );
	}
	if ( maxs[1] < point[1] )
	{
		maxs = ( maxs[0], point[1], maxs[2] );
	}
	if ( maxs[2] < point[2] )
	{
		maxs = ( maxs[0], maxs[1], point[2] );
	}
	return maxs;
}


// dpg 12/7/07 brought over this function from IW scripts. returns ai that are touching the specified volume
getAIarrayTouchingVolume( sTeamName, sVolumeName, eVolume )
{
	if ( !isdefined( eVolume ) )
	{
		eVolume = getent( sVolumeName, "targetname" );
		assertEx( isDefined( eVolume ), sVolumeName + " does not exist" );		
	}

	if ( sTeamName == "all" )
	{
		aTeam = getaiarray();
	}
	else
	{
		aTeam = getaiarray( sTeamName );
	}
	
	aGuysTouchingVolume = [];
	for( i=0; i < aTeam.size; i++ )
	{
		if ( aTeam[i] isTouching( eVolume ) )
		{
			aGuysTouchingVolume[aGuysTouchingVolume.size] = aTeam[i];
		}
	}
	
	return aGuysTouchingVolume;	
}

// CODER_MOD
// DSL 01/15/08 - Functions for dealing with client side script systems.

registerClientSys(sSysName)
{
	if(!isdefined(level._clientSys))
	{
		level._clientSys = [];
	}
	
	if(level._clientSys.size >= 32)	
	{
		error("Max num client systems exceeded.");
		return;
	}
	
	if(isdefined(level._clientSys[sSysName]))
	{
		error("Attempt to re-register client system : " + sSysName);
		return;
	}
	else
	{
		level._clientSys[sSysName] = spawnstruct();
		level._clientSys[sSysName].sysID = ClientSysRegister(sSysName);
		/#
		println("registered client system "+sSysName+" to id "+level._clientSys[sSysName].sysID );
		#/

	}	
}

setClientSysState(sSysName, sSysState, player)
{
	if(!isdefined(level._clientSys))
	{
		error("setClientSysState called before registration of any systems.");
		return;
	}
	
	if(!isdefined(level._clientSys[sSysName]))
	{
		error("setClientSysState called on unregistered system " + sSysName);
		return;
	}
	
	if(isdefined(player))
	{
		player ClientSysSetState(level._clientSys[sSysName].sysID, sSysState);
	}
	else
	{
		ClientSysSetState(level._clientSys[sSysName].sysID, sSysState);
		level._clientSys[sSysName].sysState = sSysState;
		/#
		println("set client system "+sSysName+"("+level._clientSys[sSysName].sysID+")"+" to "+sSysState);
		#/

	}
}

getClientSysState(sSysName)
{
	if(!isdefined(level._clientSys))
	{
		error("Cannot getClientSysState before registering any client systems.");
		return "";
	}
	
	if(!isdefined(level._clientSys[sSysName]))
	{
		error("Client system " + sSysName + " cannot return state, as it is unregistered.");
		return "";
	}
	
	if(isdefined(level._clientSys[sSysName].sysState))
	{
		return level._clientSys[sSysName].sysState;
	}
	
	return "";
}

russian_diary_event( outcome )
{
	outcome = ToLower( outcome );

	switch( outcome )
	{
	case "good":
		level clientNotify( "pcg" );
	break;

	case "evil":
		level clientNotify( "pce" );
	break;

	default:
		assertmsg( "Unknown russian diary outcome: '" + outcome + "'" );
	break;
	}
}

// CODER_MOD GMJ 05/19/08 - Wait until a snapshot is acknowledged.
//                          Can help control having too many spawns in one frame.
wait_network_frame()
{
    snapshot_ids = getsnapshotindexarray();

    acked = undefined;
    while (!isdefined(acked))
    {
        level waittill("snapacknowledged");
        acked = snapshotacknowledged(snapshot_ids);
    } 
}

// SCRIPTER_MOD: JesseS (5/15/200): For sending notifies to the client.
clientNotify(event)
{
	if(level.clientscripts)
	{
		maps\_utility::setClientSysState("levelNotify", event);
	}
}

// CODER_MOD GMJ 06/05/08
// Wait until either:
// 1) it is ok to spawn according to the network (best-guess).
// 2) max_wait_seconds elapse.
ok_to_spawn( max_wait_seconds )
{
	if( IsDefined( max_wait_seconds ) )
	{
	    timer = GetTime() + max_wait_seconds * 1000;
	
	    while( GetTime() < timer && !OkToSpawn() )
	    {
	        wait( 0.05 );
	    }
	}
	else
	{
		while( !OkToSpawn() )
		{
			wait( 0.05 );
		}
	}
}

set_breadcrumbs(starts)
{
	ASSERTEX( starts.size == 4, "set_breadcrumbs: there aren't 4 player start spots!" );
	
	if(!isdefined(level._player_breadcrumbs))
	{
		maps\_callbackglobal::Player_BreadCrumb_Reset((0,0,0));
	}
	
	for(i = 0; i < 4; i ++)
	{
		for(j = 0; j < 4; j ++)
		{
			level._player_breadcrumbs[i][j].pos = starts[j].origin;
			if(isdefined(starts[j].angles))
			{
				level._player_breadcrumbs[i][j].ang = starts[j].angles;
			}
			else
			{
				level._player_breadcrumbs[i][j].ang = (0,0,0);
			}
		}
	}
}

set_breadcrumbs_player_positions()
{
	if(!isdefined(level._player_breadcrumbs))
	{
		maps\_callbackglobal::Player_BreadCrumb_Reset((0,0,0));
	}	
	
	players = get_players();
	
	for(i = 0; i < players.size; i ++)
	{
		level._player_breadcrumbs[i][0].pos = players[i].origin;
		level._player_breadcrumbs[i][0].ang = players[i].angles;
	}
}

trigger_coop_warp( trigger )
{
	if( !IsDefined( trigger.target ) )
	{
		AssertMsg( "warp_trigger at " + trigger.origin + " does not target anything, the .target is undefined" );
		return;
	}

	structs = getstructarray( trigger.target, "targetname" );
	structs = array_randomize( structs );

	// CODER_MOD : DSL - if trigger is linked to a fog trigger, associate the fog trigger with
	// all of the warp positions.

	if(isdefined(trigger.script_linkto))
	{
		for(i = 0; i < structs.size; i ++)
		{
			structs[i].script_linkto = trigger.script_linkto;
		}
	}

	if( !IsDefined( structs ) || structs.size == 0 )
	{
		AssertMsg( "warp_trigger at " + trigger.origin + " does not target any structs" );
		return;
	}
	
	// SRS 7/30/2008: should have set up enough spots for at least double the coop player limit
	requiredStructs = 8;
	if( structs.size < requiredStructs )
	{
		ASSERTMSG( "warp_trigger at " + trigger.origin + " only targets " + structs.size + " structs.  You should target at least " + requiredStructs + ", in case some spots are invalid when warping occurs." );
		return;
	}

	safe_trigger = GetEnt( trigger.target, "targetname" );

	if( !IsDefined( safe_trigger ) )
	{
		AssertMsg( "warp_trigger at " + trigger.origin + " does not target a safe trigger" );
		return;
	}

	/#
		//array_thread(structs, ::debug_warp_point);
	#/

	trigger waittill( "trigger", toucher );

	if(!isdefined(trigger.touchedby))	// make sure we're not firing twice.
	{
		trigger.touchedby = toucher;
	
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] == toucher || players[i] IsTouching( safe_trigger ) )
			{
				continue;
			}
			players[i] thread warp_player_start( 0.2 );
			players[i].warp_start = true;
		}
	
		println("Deleting warp trigger.");
		trigger delete();
	
		wait( 1 );
	
		all_ai	= GetAiArray();	
		players = get_players();
		
		avoid_ents = array_combine( all_ai, players );
		for( i = 0; i < players.size; i++ )
		{
			if( !isDefined(players[i].warp_start) || players[i].warp_start == false )
			{
				players[i].warp_start = undefined;
				continue;
			}
		
			warp_struct = undefined;
			for( q = 0; q < structs.size; q++ )
			{
				if( warp_spot_is_safe( structs[q], avoid_ents ) )
				{
					warp_struct		 = structs[q];
					warp_struct.used = true;
					break;
				}
			}
	
			if( IsDefined( warp_struct ) )
			{
				players[i].no_warp = undefined;
				players[i] thread warp_player_end();
				players[i] thread coop_warp_player( warp_struct );
			}
			else
			{
				players[i].no_warp = true;
			}
		}
		
		///////////////////////////////////////////////////////////////////////////////////////
		//KRAZY KING MOD
		//attempt to failsafe the warpage.
		retries = 30;
		while ( retries )
		{
			// Jesse: We need this in case a player drops
			players = get_players();
			
			for( i = 0; i < players.size; i++ )
			{
				// check for players touching the safe trigger, since they dont need to be warped anyway
				if( !isdefined(players[i].no_warp) || players[i] IsTouching( safe_trigger ) )
				{
					// Jesse: In case you've made it to a safe trigger but you've been set to warp
					players[i].no_warp = undefined;
					continue;
				}
	
				if ( retries == 1 )
					avoid_ents = [];
	
				warp_struct = undefined;
				for( q = 0; q < structs.size; q++ )
				{
					if( warp_spot_is_safe( structs[q], avoid_ents ) )
					{
						warp_struct		 = structs[q];
						warp_struct.used = true;
						break;
					}
				}
				if( IsDefined( warp_struct ) )
				{
					players[i].no_warp = undefined;
					players[i] thread warp_player_end();
					players[i] thread coop_warp_player( warp_struct );
				}
				else
				{
					players[i].no_warp = true;
				}
			}
	
			dudes_needing_warps = players.size;
			for( i = 0; i < players.size; i++ )
			{
				if( !isdefined(players[i].no_warp)  )
				{
					dudes_needing_warps--;
				}
			}	
			if ( dudes_needing_warps == 0 )
			{
				return;
			}
		
			wait 2;
			retries--;
		}	
	
		// Jesse: Get players after every wait!
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			//umm let the scripter know something didnt work.
			assert (!isdefined(players[i].no_warp));
		}
	}	
}

coop_warp_player( struct )
{
	pos = playergroundpos( struct.origin );

	if( IsDefined( level._effect["warp_fx"] ) )
	{
		PlayFx( level._effect["warp_fx"], pos + ( 0, 0, 72 ) );
	}

	// If player is on a turret, unmount them from it, pre warp.
	
	mg42s = GetEntArray( "misc_mg42", "classname" );
	turrets = GetEntArray( "misc_turret", "classname" );

	turrets = array_combine( mg42s, turrets );
	
	for(i = 0; i < turrets.size; i ++)
	{
		ent = turrets[i] getturretowner();
		
		if(isdefined(ent))
		{
			if(ent == self)
			{
				// We're on this turret...
				
				ent useby(self);
				self stopusingturret();
				break;
			}
		}
	}	

	self SetOrigin( pos );
	self SetPlayerAngles( struct.angles );
	
	// If the warp point is associated with a fog trigger, ensure that the warped player
	// has the right fog settings set.
	
	if(isdefined(struct.script_linkto))
	{
		trigger = GetEnt(struct.script_linkto, "script_linkname");	// Get the fog trigger
		
		if(!isdefined(trigger))
			return;
	
		if(isdefined(trigger.script_start_dist))	// Not so great check to make sure this trigger is a fog trig.
		{
			self SetVolFog( trigger.script_start_dist, trigger.script_halfway_dist, 
											trigger.script_halfway_height, trigger.script_base_height, 
											trigger.script_color[0], trigger.script_color[1], trigger.script_color[2], 
											trigger.script_transition_time ); 	

			if( IsDefined( trigger.script_vision ) && IsDefined( trigger.script_vision_time ) )
			{
				self VisionSetNaked( trigger.script_vision, trigger.script_vision_time ); 
			}			
		}		
	}
}

warp_player_start( fade_time )
{
	if(!isdefined(self.warp_text))
	{
		self EnableInvulnerability();
		self DisableWeapons();
	
		hudString = &"GAME_COOP_WARP_PLAYER_HINT";

		if ( GetDvarInt( "splitscreen" ) && !GetDvarInt( "hidef" ) )
			fontScale = 2.5;
		else
			fontScale = 1.75;
	
		self.warp_text = newClientHudElem( self );
		self.warp_text.y = 100;
		self.warp_text.alignX = "center";
		self.warp_text.horzAlign = "center";
		self.warp_text.vertAlign = "top";
		self.warp_text.foreground = true;
		self.warp_text.fontScale = fontScale; 
		self.warp_text.sort = 1;
		self.warp_text.hidewheninmenu = true;
		self.warp_text SetText( hudString );
	
		self.warp_text.alpha = 0;
		self.warp_text FadeOverTime( fade_time );
		self.warp_text.alpha = 1;
	
		self.warp_bg = newClientHudElem( self );
		self.warp_bg.x = 0;
		self.warp_bg.y = 0;
		self.warp_bg.horzAlign = "fullscreen";
		self.warp_bg.vertAlign = "fullscreen";
		self.warp_bg.foreground = true;
		self.warp_bg.sort = 1;
		self.warp_bg.hidewheninmenu = true;
		self.warp_bg SetShader( "black", 640, 480 );
	
		self.warp_bg.alpha = 0;
		self.warp_bg FadeOverTime( fade_time );
		self.warp_bg.alpha = 1;
	}
}

warp_player_end()
{
	self EnableWeapons();
	
	if( IsDefined( self.warp_text ) )
	{
		self.warp_text FadeOverTime( 0.5 );
		self.warp_text.alpha = 0;

		self.warp_bg FadeOverTime( 0.5 );
		self.warp_bg.alpha = 0;

		wait( 0.5 );

		self.warp_text Destroy();
		self.warp_bg Destroy();

		wait( 3 ); // Give a little time to recover
	}

	self DisableInvulnerability();
	self notify ("coop_warp_complete");
}

warp_spot_is_safe( struct, avoid_ents )
{
	// Check to see if the struct is already being used
	if( IsDefined( struct.used ) && struct.used )
	{
		return false;
	}

	//	if( struct InSolid

	
	// Check to see if the spot is too close to an AI
	dist = 40;
	for( i = 0; i < avoid_ents.size; i++ )
	{
		if( DistanceSquared( avoid_ents[i].origin, struct.origin ) < dist * dist )
		{
			return false;
		}
	}

	return true;
}

// called on one player
warp_a_player( warp_point )
{
	self thread warp_player_start( 0.2 );
	wait 0.2;
	self coop_warp_player( warp_point );
	self thread warp_player_end();
	
}

debug_warp_point()
{
	/#
	while(1)
	{
		print3d(self.origin,"+",(0.0,1.0,0.0),1);
		print3d(groundpos(self.origin),"+",(1.0,0.0,0.0),1);
		print3d(playergroundpos(self.origin),"+",(0.0,0.0,1.0),1);
		wait(0.05);
	}
	#/
}
/* 
 ============= 
///ScriptDocBegin
"Name: spread_array_thread( <entities> , <process> , <var1> , <var2> , <var3> )"
"Summary: Threads the < process > function on every entity in the < entities > array. The entity will become "self" in the specified function.  Each thread is started 1 network frame apart from the next."
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

spread_array_thread( entities, process, var1, var2, var3 )
{
	keys = getArrayKeys( entities );
	
	if ( isdefined( var3 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
		{
			entities[ keys[ i ] ] thread [[ process ]]( var1, var2, var3 );
			wait_network_frame();
		}
			
		return;
	}

	if ( isdefined( var2 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
		{
			entities[ keys[ i ] ] thread [[ process ]]( var1, var2 );
			wait_network_frame();
		}
			
		return;
	}

	if ( isdefined( var1 ) )
	{
		for( i = 0 ; i < keys.size ; i ++ )
		{
			entities[ keys[ i ] ] thread [[ process ]]( var1 );
			wait_network_frame();
		}
			
		return;
	}

	for( i = 0 ; i < keys.size ; i ++ )
	{
		entities[ keys[ i ] ] thread [[ process ]]();
		wait_network_frame();
	}
}