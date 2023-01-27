#include maps\_utility; 
#include common_scripts\utility; 
#using_animtree( "generic_human" ); 

init_mgTurretsettings()
{
	level.mgTurretSettings["easy"]["convergenceTime"] = 2.5; 
	level.mgTurretSettings["easy"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["easy"]["accuracy"] = 0.38; 
	level.mgTurretSettings["easy"]["aiSpread"] = 2; 
	level.mgTurretSettings["easy"]["playerSpread"] = 0.5; 	

	level.mgTurretSettings["medium"]["convergenceTime"] = 1.5; 
	level.mgTurretSettings["medium"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["medium"]["accuracy"] = 0.38; 
	level.mgTurretSettings["medium"]["aiSpread"] = 2; 
	level.mgTurretSettings["medium"]["playerSpread"] = 0.5; 	

	level.mgTurretSettings["hard"]["convergenceTime"] = .8; 
	level.mgTurretSettings["hard"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["hard"]["accuracy"] = 0.38; 
	level.mgTurretSettings["hard"]["aiSpread"] = 2; 
	level.mgTurretSettings["hard"]["playerSpread"] = 0.5; 	

	level.mgTurretSettings["fu"]["convergenceTime"] = .4; 
	level.mgTurretSettings["fu"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["fu"]["accuracy"] = 0.38; 
	level.mgTurretSettings["fu"]["aiSpread"] = 2; 
	level.mgTurretSettings["fu"]["playerSpread"] = 0.5; 	
}

main()
{
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
	/#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _mgturret.gsc. Function: main()\n");
	#/
	
	if( GetDvar( "mg42" ) == "" )
	{
		SetDvar( "mgTurret", "off" ); 
	}
		
	level.magic_distance = 24; 

	turretInfos = getEntArray( "turretInfo", "targetname" );
	for( index = 0; index < turretInfos.size; index++ )
    {
		turretInfos[index] Delete();
    }
    
	// CODER_MOD: Bryce (05/08/08): Useful output for debugging replay system
    /#
	if( getdebugdvar( "replay_debug" ) == "1" )
		println("File: _mgturret.gsc. Function: main() - COMPLETE\n");
	#/
}

// SCRIPTER_MOD: JesseS (4/16/2008): Added this back in special for HMG guys
portable_mg_behavior()
{
	// run overrides
	self.a.combatrunanim = %ai_mg_shoulder_run;
	self.run_noncombatanim = %ai_mg_shoulder_run;
	
	// walk overrides
	self.walk_combatanim = %ai_mg_shoulder_run;
	self.walk_noncombatanim = %ai_mg_shoulder_run;
	
	// Crouch overrides
	self.a.crouchRunAnim = %ai_mg_shoulder_run;
	self.crouchrun_combatanim = %ai_mg_shoulder_run;

	// dont try to blend into left, right backwards anims
	self.alwaysRunForward = true;	
	
	// These are important for not getting wacky animation changing problems
	// when stoping and starting motion
	self.disableExits = true;
}




mg42_trigger()
{
	self waittill( "trigger" ); 
	level notify( self.targetname ); 
	level.mg42_trigger[self.targetname] = true; 
//	println( "trigger at ", self GetOrigin(), " was triggered" ); 
	self Delete(); 
}

mgTurret_auto( trigger )
{
	trigger waittill( "trigger" ); 
	ai = GetAiArray( "axis" ); 
	for( i = 0; i < ai.size; i++ )
	{
		if( ( IsDefined( ai[i].script_mg42auto ) ) &&( trigger.script_mg42auto == ai[i].script_mg42auto ) )
		{
			ai[i] notify( "auto_ai" ); 
			println( "^a ai auto on!" ); 
		}
	}

	spawners = GetSpawnerArray(); 
	for( i = 0; i < spawners.size; i++ )
	{
		if( ( IsDefined( spawners[i].script_mg42auto ) ) &&( trigger.script_mg42auto == spawners[i].script_mg42auto ) )
		{
			spawners[i].ai_mode = "auto_ai"; 
			println( "^aspawner ", i, " set to auto" ); 
		}
	}
		
	maps\_spawner::kill_trigger( trigger ); 
}

mg42_suppressionFire( targets )
{
	self endon( "death" ); 
	self endon( "stop_suppressionFire" ); 
	if( !IsDefined( self.suppresionFire ) )
	{
		self.suppresionFire = true; 
	}
	
	for( ;; )
	{
		while( self.suppresionFire )
		{
			self SetTargetEntity( targets[RandomInt( targets.size )] ); 
			wait( 2 + RandomFloat( 2 ) ); 
		}
		
		self ClearTargetEntity(); 
		while( !self.suppresionFire )
		{
			wait( 1 ); 
		}
	}
}

manual_think( mg42 ) // For regular spawned guys that are told to use mg42s manually vs static target
{
// SCRIPTER_MOD
// MikeD( 3/21/2007 ): org is not used in this function
//	org = self.origin; 

	self waittill( "auto_ai" ); 
	mg42 notify( "stopfiring" ); 
	mg42 SetMode( "auto_ai" ); // auto, auto_ai, manual

// SCRIPTER_MOD
// MikeD( 3/21/2007 ): No more level.player, anyways, auto_ai should just Kick in against everyone.
// No need to set the tarGetEntity here. TESinG!
//	mg42 SetTargetEntity( level.player ); 
}

burst_fire_settings( setting )
{
	if( setting == "delay" )
	{
		return 0.2; 
	}
	else if( setting == "delay_range" )
	{
		return 0.5; 
	}
	else if( setting == "burst" )
	{
		return 0.5; 
	}
	else if( setting == "burst_range" )
	{
		return 4; 
	}
}

burst_fire_unmanned()
{
	self notify( "stop_burst_fire_unmanned" );
	self endon( "stop_burst_fire_unmanned" );
	self endon( "death" ); 
	if( IsDefined( self.script_delay_min ) )
	{
		mg42_delay = self.script_delay_min; 
	}
	else
	{
		mg42_delay = burst_fire_settings( "delay" ); 
	}

	if( IsDefined( self.script_delay_max ) ) 
	{
		mg42_delay_range = self.script_delay_max - mg42_delay; 
	}
	else
	{
		mg42_delay_range = burst_fire_settings( "delay_range" ); 
	}

	if( IsDefined( self.script_burst_min ) )
	{
		mg42_burst = self.script_burst_min; 
	}
	else
	{
		mg42_burst = burst_fire_settings( "burst" ); 
	}

	if( IsDefined( self.script_burst_max ) ) 
	{
		mg42_burst_range = self.script_burst_max - mg42_burst; 
	}
	else
	{
		mg42_burst_range = burst_fire_settings( "burst_range" ); 
	}

	pauseUntilTime = GetTime(); 
	turretState = "start";
	// SRS 05/02/07 - added this for link_turrets() so we can accurately tell when the function is
	//  actually firing or just waiting between bursts (IsFiringTurret() returns true the whole time)
	self.script_shooting = false;

	for( ;; )
	{
		if( IsDefined( self.manual_targets ) )
		{
			self ClearTargetEntity();
			self SetTargetEntity( self.manual_targets[RandomInt( self.manual_targets.size )] );
		}

		duration = ( pauseUntilTime - GetTime() ) * 0.001; 
		if( self IsFiringTurret() &&( duration <= 0 ) )
		{
			if( turretState != "fire" )
			{
				turretState = "fire";

				self thread DoShoot();
				self.script_shooting = true;
			}

			duration = mg42_burst + RandomFloat( mg42_burst_range ); 

			//println( "fire duration: ", duration ); 
			self thread TurretTimer( duration );

			self waittill( "turretstatechange" ); // code or script
			
			self.script_shooting = false;

			duration = mg42_delay + RandomFloat( mg42_delay_range ); 
			//println( "stop fire duration: ", duration ); 

			pauseUntilTime = GetTime() + Int( duration * 1000 ); 
		}
		else
		{
			if( turretState != "aim" )
			{
				turretState = "aim"; 

//				self SetAnimKnobReStart( %standMG42gun_aim_foward ); 
			}
			
			//println( "aim duration: ", duration ); 
			self thread TurretTimer( duration );

			self waittill( "turretstatechange" ); // code or script
		}
	}
}

DoShoot()
{
	self endon( "death" ); 
	self endon( "turretstatechange" ); // code or script

	for( ;; )
	{
		self ShootTurret(); 
		wait( 0.1 ); 
	}
}

TurretTimer( duration )
{
	if( duration <= 0 )
	{
		return; 
	}

	self endon( "turretstatechange" ); // code

	//println( "start turret timer" ); 

	wait( duration ); 
	if( IsDefined( self ) )
	{
		self notify( "turretstatechange" ); 
	}

	//println( "end turret timer" ); 
}

random_spread( ent )
{
	self endon( "death" ); 

	self notify( "stop random_spread" ); 
	self endon( "stop random_spread" ); 
	
	self endon( "stopfiring" ); 
	self SetTargetEntity( ent ); 
	
	while( 1 )
	{

// SCRIPTER_MOD
// MikeD( 3/21/2007 ): No more level.player
//		if( ent == level.player )
//			ent.origin = self.manual_target GetOrigin(); 
//		else
//			ent.origin = self.manual_target.origin; 

		if( IsPlayer( ent ) )
		{
			ent.origin = self.manual_target GetOrigin(); 
		}
		else
		{
			ent.origin = self.manual_target.origin; 
		}

		ent.origin += ( 20 - RandomFloat( 40 ), 20 - RandomFloat( 40 ), 20 - RandomFloat( 60 ) ); 
		wait( 0.2 ); 
	}
}

mg42_firing( mg42 )
{
	self notify( "stop_using_built_in_burst_fire" ); 
	self endon( "stop_using_built_in_burst_fire" ); 

	mg42 StopFiring(); 
	
	while( 1 )
	{
		mg42 waittill( "startfiring" ); 
		self thread burst_fire( mg42 ); 
		mg42 StartFiring(); 

		mg42 waittill( "stopfiring" ); 
		mg42 StopFiring(); 
	}
}


burst_fire( mg42, manual_target )
{
	mg42 endon( "death" ); // MikeD: Incase we delete the mg42.
	mg42 endon( "stopfiring" ); 
	self endon( "stop_using_built_in_burst_fire" ); 


	if( IsDefined( mg42.script_delay_min ) )
	{
		mg42_delay = mg42.script_delay_min; 
	}
	else
	{
		mg42_delay = maps\_mgturret::burst_fire_settings( "delay" ); 
	}

	if( IsDefined( mg42.script_delay_max ) ) 
	{
		mg42_delay_range = mg42.script_delay_max - mg42_delay; 
	}
	else
	{
		mg42_delay_range = maps\_mgturret::burst_fire_settings( "delay_range" ); 
	}

	if( IsDefined( mg42.script_burst_min ) )
	{
		mg42_burst = mg42.script_burst_min; 
	}
	else
	{
		mg42_burst = maps\_mgturret::burst_fire_settings( "burst" ); 
	}

	if( IsDefined( mg42.script_burst_max ) ) 
	{
		mg42_burst_range = mg42.script_burst_max - mg42_burst; 
	}
	else
	{
		mg42_burst_range = maps\_mgturret::burst_fire_settings( "burst_range" ); 
	}

	while( 1 )
	{	
		mg42 StartFiring(); 

		if( IsDefined( manual_target ) )
		{
			mg42 thread random_spread( manual_target ); 
		}
			
		wait( mg42_burst + RandomFloat( mg42_burst_range ) ); 

		mg42 StopFiring(); 

		wait( mg42_delay + RandomFloat( mg42_delay_range ) ); 
	}
}



_spawner_mg42_think()
{
	if( !IsDefined( self.flagged_for_use ) )
	{
		self.flagged_for_use = false; 
	}

	if( !IsDefined( self.targetname ) )
	{
		return; 
	}

	node = GetNode( self.targetname, "target" ); 
	if( !IsDefined( node ) )
	{
		return; 
	}

	if( !IsDefined( node.script_mg42 ) )
	{
		return; 
	}

	if( !IsDefined( node.mg42_enabled ) )
	{
		node.mg42_enabled = true; 
	}

	self.script_mg42 = node.script_mg42; 

	first_run = true; 
	while( 1 )
	{
		if( first_run )
		{
			first_run = false; 

			if( ( IsDefined( node.targetname ) ) ||( self.flagged_for_use ) )
			{
				self waittill( "get new user" ); 
			}
		}

		if( !node.mg42_enabled )
		{
			node waittill( "enable mg42" ); 
			node.mg42_enabled = true; 
		}

		excluders = []; 
		ai = GetAiArray(); 
		for( i = 0; i < ai.size; i++ )
		{
			excluded = true; 
			if( ( IsDefined( ai[i].script_mg42 ) ) &&( ai[i].script_mg42 == self.script_mg42 ) )
				excluded = false; 

			if( IsDefined( ai[i].used_an_mg42 ) )
			{
				excluded = true; 
			}
				
			if( excluded )
			{
				excluders[excluders.size] = ai[i]; 
			}
		}

		if( excluders.size )
		{
			ai = maps\_utility::get_closest_ai_exclude( node.origin, undefined, excluders ); 
		}
		else
		{
			ai = maps\_utility::get_closest_ai( node.origin, undefined ); 
		}
		excluders = undefined; 

		if( IsDefined( ai ) )
		{
			ai notify( "stop_going_to_node" ); 
			ai thread maps\_spawner::go_to_node( node ); 
			ai waittill( "death" ); 
		}
		else
		{
			self waittill( "get new user" ); 
		}
	}
}

// SCRIPTER_MOD
// MikeD (3/22/2007): Not being used, keeping it around for an example... 
// We need to investigate to see what this is actually doing.
//mg42_think()
//{		
//	if( !IsDefined( self.ai_mode ) )
//	{
//		self.ai_mode = "manual_ai"; 
//	}
//		
//	node = GetNode( self.target, "targetname" ); 
//	if( !IsDefined( node ) )
//	{
//		println( "Guy at org ", self.origin, " had no node" ); 
//		return; 
//	}
//	mg42 = GetEnt( node.target, "targetname" ); 
//	mg42.org = node.origin; 
//	
//	if( IsDefined( mg42.target ) )
//	{
//		if( ( !IsDefined( level.mg42_trigger ) ) ||( !IsDefined( level.mg42_trigger[mg42.target] ) ) )
//		{
//			level.mg42_trigger[mg42.target] = false; 
//			GetEnt( mg42.target, "targetname" ) thread mg42_trigger(); 
//		}
//		trigger = true; 
//	}
//	else
//	{
//		trigger = false; 
//	}
//
//	while( 1 )
//	{		
//		if( self.count == 0 )
//		{
//			return; 
//		}
//
//		mg42_gunner = undefined; 			
//		while( !IsDefined( mg42_gunner ) )
//		{
//			mg42_gunner = self DoSpawn(); 
//			wait( 1 ); 
//		}
//		
////		println( "gunner thinking" ); 
//
//		mg42_gunner thread mg42_gunner_think( mg42, trigger, self.ai_mode ); 
//		mg42_gunner thread mg42_firing( mg42 ); 
//		
//		mg42_gunner waittill( "death" ); 
////		println( "gunner thought" ); 
//		if( IsDefined( self.script_delay ) )
//		{
//			wait( self.script_delay ); 
//		}
//		else if( ( IsDefined( self.script_delay_min ) ) &&( IsDefined( self.script_delay_max ) ) )
//		{
//			wait( self.script_delay_min + RandomFloat( self.script_delay_max - self.script_delay_min ) ); 
//		}
//		else
//		{
//			wait( 1 ); 
//		}
//	}
//}

kill_objects( owner, msg, temp1, temp2 )
{
	owner waittill( msg ); 
	if( IsDefined( temp1 ) )
	{
		temp1 Delete(); 
	}
		
	if( IsDefined( temp2 ) )
	{
		temp2 Delete(); 
	}
}

// SCRIPTER_MOD
// MikeD (3/22/2007): Not being used, keeping it around for an example... 
// We need to investigate to see what this is actually doing.
//mg42_gunner_think( mg42, trigger, ai_mode )
//{
//	self endon( "death" ); 
//
//	if( ai_mode == "manual_ai" )
//	{
//		while( 1 )
//		{
//			self thread mg42_gunner_manual_think( mg42, trigger ); 
//			self waittill( "auto_ai" ); 			
//			self move_use_turret( mg42, "auto_ai" ); // was SetMode( "auto_ai" ) and ClearTargetEntity()
//			self waittill( "manual_ai" ); 
//		}
//	}
//	else
//	{
//		while( 1 )
//		{
//			self move_use_turret( mg42, "auto_ai", level.player ); // was SetMode( "auto_ai" ) and SetTargetEntity( level.player )
//			self waittill( "manual_ai" ); 
//			self thread mg42_gunner_manual_think( mg42, trigger ); 
//			self waittill( "auto_ai" ); 
//		}
//	}
//}

// SCRIPTER_MOD
// MikeD (3/22/2007): Not being used, keeping it around for an example... 
// We need to investigate to see what this is actually doing.
//player_safe()
//{
//	if( !IsDefined( level.player_covertrigger ) )
//	{
//		return false; 
//	}
//
//	if( level.player GetStance() == "prone" )
//	{
//		return true; 
//	}
//
//	if( ( level.player_covertype == "cow" ) &&( level.player GetStance() == "crouch" ) )
//	{
//		return true; 
//	}
//
//	return false; 
//}

// SCRIPTER_MOD
// MikeD (3/22/2007): Not being used, keeping it around for an example... 
// We need to investigate to see what this is actually doing.
//stance_num()
//{
//	if( level.player GetStance() == "prone" )
//	{
//		return( 0, 0, 5 ); 
//	}
//	else if( level.player GetStance() == "crouch" )
//	{
//		return( 0, 0, 25 ); 
//	}
//	
//	return( 0, 0, 50 ); 
//}

// SCRIPTER_MOD
// MikeD (3/22/2007): Not being used, keeping it around for an example... 
// We need to investigate to see what this is actually doing.
//mg42_gunner_manual_think( mg42, trigger )
//{
//	self endon( "death" ); 
//	self endon( "auto_ai" ); 
//
////	maps\_utility::debug_message( "MANUAL", self.origin ); 
//	
//	self.pacifist = true; 
//	self SetGoalPos( mg42.org ); 
//	self.goalradius = level.magic_distance; 
//	self waittill( "goal" ); 
//
//	if( trigger )
//	{
//		if( !level.mg42_trigger[mg42.target] )
//		{
//			level waittill( mg42.target ); 
//		}
//	}
//	
//	self.pacifist = false; 
//	
////	mg42 SetMode( "manual_ai" ); // auto, auto_ai, manual
//	mg42 SetMode( "auto_ai" ); // auto, auto_ai, manual
//	mg42 ClearTargetEntity(); 
//	targ_org = Spawn( "script_origin", ( 0, 0, 0 ) ); 
//
//	tempmodel = Spawn( "script_model", ( 0, 0, 0 ) ); 
//	tempmodel.scale = 3; 
//	if( GetDvar( "mg42" ) != "off" )
//	{
//		tempmodel SetModel( "temp" ); 
//	}
//	tempmodel thread temp_think( mg42, targ_org ); 
//	level thread kill_objects( self, "death", targ_org, tempmodel ); 
//	level thread kill_objects( self, "auto_ai", targ_org, tempmodel ); 
//	
//	mg42.player_target = false; 
//	mg42timer = 0; 
//	targets = GetEntArray( "mg42_target", "targetname" ); 
//
//	if( targets.size > 0 )
//	{
//		script_targets = true; 
//		current_org = targets[RandomInt( targets.size )].origin; 
//		
//		self thread shoot_mg42_script_targets( targets ); 
//		self move_use_turret( mg42 ); 
//		self.target_entity = targ_org; 
//		mg42 SetMode( "manual_ai" ); // auto, auto_ai, manual
//		mg42 SetTargetEntity( targ_org ); 
//		mg42 notify( "startfiring" ); 
//		 
//		mindist = 15; 
//		wait_time = 0.08; // 2.8 / 20; 
//		dif = 0.05; // 1 / 20; 
////		player_safe_time = GetTime() + 5500 + RandomFloat( 5000 ); 
//		targ_org.origin = targets[RandomInt( targets.size )].origin; 
//
//		shoot_timer = 0; 
////		while( GetTime() < player_safe_time )
//			
//		while( !IsDefined( level.player_covertrigger ) )
//		{
//			current_org = targ_org.origin; 
//			if( Distance( current_org, targets[self.gun_targ].origin ) > mindist )
//			{
//				temp_vec = VectorNormalize( targets[self.gun_targ].origin - current_org ); 
//				temp_vec = vectorScale( temp_vec, mindist ); 
//				current_org += temp_vec; 
//			}
//			else
//			{
//				self notify( "next_target" ); 
//			}
//
//			targ_org.origin = current_org; 
//
//			wait( 0.1 ); 
//		}
//		
//		while( 1 )
//		{
//			for( i = 0; i < 1; i+= dif )
//			{
//				targ_org.origin = vector_multiply( current_org, 1.0-i ) + 
//				vector_multiply( level.player GetOrigin() + stance_num(), i ); 
//
//				if( player_safe() )
//				{
//					i = 2; 
//				}
//								
//				wait( wait_time ); 
//			}
//
//			old_org = level.player GetOrigin(); 
//			while( !player_safe() )
//			{
//				targ_org.origin = level.player GetOrigin(); 
//				vec_dif = targ_org.origin - old_org; 
//				targ_org.origin = targ_org.origin + vec_dif + stance_num(); 
//				old_org = level.player GetOrigin(); 
//				wait( 0.1 ); 
//			}
//	
//			if( player_safe() )
//			{
//				shoot_timer = GetTime() + 1500 + RandomFloat( 4000 ); 
//				while( ( player_safe() ) &&( IsDefined( level.player_covertrigger.target ) ) &&( GetTime() < shoot_timer ) )
//				{
//					target = GetEntArray( level.player_covertrigger.target, "targetname" ); 
//					target = target[RandomInt( target.size )]; 
//					targ_org.origin = target.origin + 
//						( RandomFloat( 30 ) - 15, RandomFloat( 30 ) - 15, RandomFloat( 40 ) - 60 ); 
//						
//					wait( 0.1 ); 
//				}
//			}
//
//			self notify( "next_target" ); 
//			while( player_safe() )
//			{
//				current_org = targ_org.origin; 
//				if( Distance( current_org, targets[self.gun_targ].origin ) > mindist )
//				{
//					temp_vec = VectorNormalize( targets[self.gun_targ].origin - current_org ); 
//					temp_vec = vectorScale( temp_vec, mindist ); 
//					current_org += temp_vec; 
//				}
//				else
//				{
//					self notify( "next_target" ); 
//				}
//
//				targ_org.origin = current_org; 
//
//				wait( 0.1 ); 
//			}
//		}
//	}
//	else
//	{
//		while( 1 )
//		{
//			// Play is not safe, shoot player.
//			self move_use_turret( mg42 ); 
//			while( !IsDefined( level.player_covertrigger ) )
//			{
//				if( !mg42.player_target )
//				{
//					mg42 SetTargetEntity( level.player ); 
//					mg42.player_target = true; 
//	//				mg42 SetTargetEntity( tempmodel ); 
//					tempmodel.targent = level.player; 
//				}
//				wait( 0.2 ); 
//			}
//			
//			// Player is safe so shoot in front of him.
//			mg42 SetMode( "manual_ai" ); // auto, auto_ai, manual
//			self move_use_turret( mg42 ); 
//			mg42 notify( "startfiring" ); 
//			shoot_timer = GetTime() + 1500 + RandomFloat( 4000 ); 
//			while( shoot_timer > GetTime() )
//			{
//				if( IsDefined( level.player_covertrigger ) )
//				{
//					target = GetEntArray( level.player_covertrigger.target, "targetname" ); 
//					target = target[RandomInt( target.size )]; 
//					targ_org.origin = target.origin + 
//						( RandomFloat( 30 ) - 15, RandomFloat( 30 ) - 15, RandomFloat( 40 ) - 60 ); 
//					mg42 SetTargetEntity( targ_org ); 
//					tempmodel.targent = targ_org; 
//					wait( RandomFloat( 1 ) ); 
//				}
//				else
//				{
//					break; 
//				}
//			}
//			mg42 notify( "stopfiring" ); 
//
//			// Play is still safe, shoot friendlies.
//			self move_use_turret( mg42 ); 
//			if( mg42.player_target )
//			{
//				mg42 SetMode( "auto_ai" ); // auto, auto_ai, manual
//				mg42 ClearTargetEntity(); 
//				mg42.player_target = false; 
//				tempmodel.targent = tempmodel; 
//				tempmodel.origin = ( 0, 0, 0 ); 
//			}
//
//			while( IsDefined( level.player_covertrigger ) )
//			{
//				wait( 0.2 ); 			
//			}
//			
//			wait( .750 + RandomFloat( .200 ) ); 
//		}	
//	}
//}


shoot_mg42_script_targets( targets )
{
	self endon( "death" ); 
	while( 1 )
	{
		targ_filled = []; 
		for( i = 0; i < targets.size; i++ )
		{
			targ_filled[i] = false; 
		}
			
		for( i = 0; i < targets.size; i++ )
		{
			self.gun_targ = RandomInt( targets.size ); 
			self waittill( "next_target" ); 
			while( targ_filled[self.gun_targ] )
			{
				self.gun_targ++; 
				if( self.gun_targ >= targets.size )
				{
					self.gun_targ = 0; 
				}
			}
			
			targ_filled[self.gun_targ] = true; 
			
		}
	}
}	



move_use_turret( mg42, aitype, target )
{
	self SetGoalPos( mg42.org ); 
	self.goalradius = level.magic_distance; 
	self waittill( "goal" ); 
	if( IsDefined( aitype ) && aitype == "auto_ai" )
	{
		mg42 SetMode( "auto_ai" ); 
		if( IsDefined( target ) )
		{
			mg42 SetTargetEntity( target ); 
		}
		else
		{
			mg42 ClearTargetEntity(); 
		}
	}
	self USeturret( mg42 ); // dude should be near the mg42
}

temp_think( mg42, targ )
{
	if( GetDvar( "mg42" ) == "off" )
	{
		return; 
	}

	self.targent = self; 
	while( 1 )
	{
		self.origin = targ.origin; 		
		line( self.origin, mg42.origin, ( 0.2, 0.5, 0.8 ), 0.5 ); 			
		wait( 0.1 ); 
	}
}

// This is a thread that runs for each turret managing AI users of the turret
turret_think( node )
{
	turret = GetEnt( node.auto_mg42_target, "targetname" ); 
	mintime = 0.5; 
	if( IsDefined( turret.script_turret_reuse_min ) )
	{
		mintime = turret.script_turret_reuse_min; 
	}
	maxtime = 2; 
	if( IsDefined( turret.script_turret_reuse_max ) )
	{
		mintime = turret.script_turret_reuse_max; 
	}
	assert( maxtime >= mintime ); 
	for( ;; )
	{
		turret waittill( "turret_deactivate" ); 
		wait( mintime + RandomFloat( maxtime - mintime ) ); // Wait for a bit before calling the next AI over.
		while( !( IsTurretActive( turret ) ) )
		{
			turret_find_user( node, turret ); 
			wait( 1.0 ); 
		}
	}
}

turret_find_user( node, turret )
{
	ai = GetAiArray(); 	
	for( i = 0; i < ai.size; i++ )
	{
		if( ai[i] IsInGoal( node.origin ) && ai[i] CanUSeturret( turret ) )
		{
			savekeepclaimed = ai[i].keepClaimedNodeInGoal; 
			ai[i].keepClaimedNodeInGoal = false; 
			if( !( ai[i] UseCOverNode( node ) ) )
			{
				ai[i].keepClaimedNodeInGoal = savekeepclaimed; 
			}
		}
	}
}

setDifficulty()
{
	init_mgTurretsettings();
	
	mg42s = GetEntArray( "misc_turret", "classname" ); 
	
	difficulty = GetDifficulty(); 
	
	for( index = 0; index < mg42s.size; index++ )
	{
		if( IsDefined( mg42s[index].script_skilloverride ) )
		{
			switch( mg42s[index].script_skilloverride )
			{
				case "easy":
					difficulty = "easy"; 
					break; 
				case "medium":
					difficulty = "medium"; 
					break; 
				case "hard":
					difficulty = "hard"; 
					break; 
				case "fu":
					difficulty = "fu"; 
					break; 
				default:
					continue; 
			}
		}
		mg42_setdifficulty( mg42s[index], difficulty ); 
	}
}

mg42_setdifficulty( mg42, difficulty )
{
		mg42.convergenceTime = level.mgTurretSettings[difficulty]["convergenceTime"]; 
		mg42.suppressionTime = level.mgTurretSettings[difficulty]["suppressionTime"]; 
		mg42.accuracy = level.mgTurretSettings[difficulty]["accuracy"]; 
		mg42.aiSpread = level.mgTurretSettings[difficulty]["aiSpread"]; 
		mg42.playerSpread = level.mgTurretSettings[difficulty]["playerSpread"]; 	
}


mg42_target_drones( nonai, team, fakeowner )
{
	if( !IsDefined( fakeowner ) )
	{
		fakeowner = false; 
	}
	self endon( "death" ); 
	self.dronefailed = false; 
	if( !IsDefined( self.script_fireondrones ) )
	{
		self.script_fireondrones = false; 
	}
	if( !IsDefined( nonai ) )
	{
		nonai = false; 
	}
	self SetMode( "manual_ai" ); 
	difficulty = GetDifficulty(); 
	if( !IsDefined( level.drones ) )
	{
		waitfornewdrone = true; 
	}
	else
	{
		waitfornewdrone = false; 
	}
	while( 1 )
	{
		if( fakeowner && !IsDefined( self.fakeowner ) )
		{
			self SetMode( "manual" ); 
			while( !IsDefined( self.fakeowner ) )
			{
				wait( .2 ); 
			}
			
		}
		else if( nonai )
		{
			self SetMode( "auto_nonai" ); 
		}
		else
		{
			self SetMode( "auto_ai" ); 
		}
		
		if( waitfornewdrone )
		{
			level waittill( "new_drone" ); 
		}

		if( !IsDefined( self.oldconvergencetime ) )
		{
			self.oldconvergencetime = self.convergencetime; 
		}
		self.convergencetime = 2; 

		if( !nonai )
		{
			turretowner = self GetTurretOwner(); 
// SCRIPTER_MOD
// MikeD (3/22/2007): No more level.player
//			if( !IsAlive( turretowner ) || turretowner == level.player )

			if( !IsAlive( turretowner ) || IsPlayer( turretowner ) )
			{
				wait( .05 ); 
				continue; 
			}
			else
			{
				team = turretowner.team; 
			}
		}
		else
		{
			if( fakeowner && !IsDefined( self.fakeowner ) )
			{
				wait( .05 ); 
				continue; 
			}
			assert( IsDefined( team ) ); 
			turretowner = undefined; 
		}
		if( team == "allies" )
		{
			targetteam = "axis"; 
		}
		else
		{
			targetteam = "allies"; 
		}

		while( level.drones[targetteam].lastindex )
		{
			//self GetTagAngles( "tag_flash" )
			target = get_bestdrone( targetteam ); 
			if( !IsDefined( self.script_fireondrones ) || !self.script_fireondrones )
			{
				wait( .2 ); 
				break; 
			}
			if( !IsDefined( target ) )
			{
				wait( .2 ); 
				break; 
			}
			if( nonai )	
			{
				self SetMode( "manual" ); 
			}
			else
			{
				self SetMode( "manual_ai" ); 
			}
				
			thread drone_fail( target, 3 ); 
			if( !self.dronefailed )
			{
				self SetTargetEntity( target.turrettarget ); 
				self ShootTurret(); 
				self StartFiring(); 
			}
			else
			{
				self.dronefailed = false; 
				wait( .05 ); 
				continue; 
				
			}
			target waittill_any ("death","drone_mg42_fail");
			waittillframeend; 
			if( !nonai && !( IsDefined( self GetTurretOwner() ) && self GetTurretOwner() == turretowner ) )
			{
				break; 
			}
		}
		self.convergencetime = self.oldconvergencetime; 
		self.oldconvergencetime = undefined; 
		self ClearTargetEntity(); 
		self StopFiring(); 
		if( level.drones[targetteam].lastindex )
		{
			waitfornewdrone = false; 
		}
		else
		{
			waitfornewdrone = true; 
		}
	}
}

drone_fail( drone, time )
{
	self endon( "death" ); 
	drone endon( "death" ); 
	timer = GetTime()+( time*1000 ); 
	while( timer > GetTime() )
	{
		turrettarget = self GetTurretTarget(); 
//		BulletTracePassed( < start>, < end>, < hit characters>, < ignore entity> )
		if( !SightTracePassed( self GetTagOrigin( "tag_flash" ), drone.origin+( 0, 0, 40 ), 0, drone ) )
		{
			self.dronefailed = true; 
			wait( .2 ); 
			break; 
		}
		else if( IsDefined( turrettarget ) && Distance( turrettarget.origin, self.origin ) < Distance( self.origin, drone.origin ) )
		{
			self.dronefailed = true; 
			wait( .1 ); 
			break; 	
		}
		wait( .1 ); 
	}
//	maps\_utility::structarray_swaptolast( level.drones[drone.team], drone ); 
	maps\_utility::structarray_shuffle( level.drones[drone.team], 1 ); 
	drone notify( "drone_mg42_fail" ); 
}

get_bestdrone( team )
{
	//prof_begin( "drone_mg42" ); 
//	dotvalue = .88; 
//	dist = 9999999; 
	if( level.drones[team].lastindex < 1 )
	{
		return; 
	}
	ent = undefined; 
	dotforward = AnglesToForward( self.angles ); 
	for( i = 0; i < level.drones[team].lastindex; i++ )
	{
		angles = VectorToAngles( level.drones[team].array[i].origin - self.origin ); 
		forward = AnglesToForward( angles ); 
		if( VectorDot( dotforward, forward ) < .88 )
		{
			continue; 
		}
//		if( !SightTracePassed( level.drones[team].array[i].origin, self.origin+( 0, 0, 10 ), 0, level.drones[team].array[i] ) )
//			continue; 
//		newdist = Distance( level.drones[team].array[i].origin, self.origin ); 
//		if( newdist >= dist )
//			continue; 
//		dist = newdist; 
		ent = level.drones[team].array[i]; 
		break; 
	}
	aitarget = self GetTurretTarget(); 
	if( IsDefined( ent ) && IsDefined( aitarget ) && Distance( self.origin, aitarget.origin ) < Distance( self.origin, ent.origin ) )
	{
		ent = undefined;  // shoot at ai if they are closer
	}
	//prof_end( "drone_mg42" ); 
	return ent; 
}

saw_mgTurretLink( nodes )
{
	possible_turrets = getEntArray( "misc_turret", "classname" );
	turrets = [];
	for ( i=0; i < possible_turrets.size; i++ )
	{
		if ( isDefined( possible_turrets[ i ].targetname ) )
			continue;
			
		if ( isdefined( possible_turrets[ i ].isvehicleattached ) )
		{
			assertEx( possible_turrets[ i ].isvehicleattached != 0, "Setting must be either true or undefined" );
			continue;
		}

		turrets[ possible_turrets[ i ].origin + "" ] = possible_turrets[ i ];
	}

	// did we find any turrets?
	if ( !turrets.size )
		return;
		
	for ( nodeIndex = 0; nodeIndex < nodes.size; nodeIndex++)
	{
		node = nodes[ nodeIndex ];
		if ( node.type == "Path" )
			continue;
		if ( node.type == "Begin" )
			continue;
		if ( node.type == "End" )
			continue;

	    nodeForward = anglesToForward( ( 0, node.angles[ 1 ], 0 ) );

		keys = getArrayKeys( turrets );
		for ( i=0; i < keys.size; i++ )
		{
			turret = turrets[ keys[ i ] ];
			
			// SCRIPTER_MOD: JesseS (6/25/2007):  upped distance here, some stand nodes were just outside of
			// 50 units, also, in other places, this logic is copied but set to 75 or so units
			if ( distance( node.origin, turret.origin ) > 75 )
				continue;
		
		   turretForward = anglesToForward( ( 0, turret.angles[ 1 ], 0 ) );
		    
			dot = vectorDot( nodeForward, turretForward );
			if ( dot < 0.9 )
				continue;

			// SCRIPTER_MOD: JesseS (8/13/200):  changed this to a script_struct that spawns in
			//node.turretInfo = spawn( "script_origin", turret.origin );	
			node.turretInfo = spawnstruct();
			node.turretInfo.origin = turret.origin;
			node.turretInfo.angles = turret.angles;
			node.turretInfo.node = node;

			node.turretInfo.leftArc = 45;
			node.turretInfo.rightArc = 45;
			node.turretInfo.topArc = 15;
			node.turretInfo.bottomArc = 15;
			
/*
			if ( isDefined( turret.leftArc ) )
				node.turretInfo.leftArc = min( turret.leftArc, 45 );

			if ( isDefined( turret.rightArc ) )
				node.turretInfo.rightArc = min( turret.rightArc, 45 );

			if ( isDefined( turret.topArc ) )
				node.turretInfo.topArc = min( turret.topArc, 15 );

			if ( isDefined( turret.bottomArc ) )
				node.turretInfo.bottomArc = min( turret.bottomArc, 15 );
*/

			turrets[ keys[ i ] ] = undefined;
			turret delete();
			println("PortableMG: " + turret.weaponinfo + " was set up to be portable.");
		}
	}

	keys = getArrayKeys( turrets );
	for ( i=0; i < keys.size; i++ )
	{
		turret = turrets[ keys[ i ] ];
//		assertMsg( "ERROR: turret at " + turret.origin + " could not link to any node!" );
		println( "^1!!!ERROR: turret at " + turret.origin + " could not link to any node! You need to make sure that a node is directly behind the mg42 and less than 50 units behind it." );

	}
}

auto_mgTurretLink( nodes )
{
	// Attaches MG turrets with targetname auto_mgTurret to cover crouch and stand nodes.
	possible_turrets = GetEntArray( "misc_turret", "classname" ); 
	turrets = []; 
	for( i = 0; i < possible_turrets.size; i++ )
	{
		if ( !isDefined( possible_turrets[ i ].targetname ) || tolower( possible_turrets[ i ].targetname ) != "auto_mgturret" )
			continue;
		// if the turret is legit, create a unique string reference to it
		if( !IsDefined( possible_turrets[i].export ) )
		{
			continue; 
		}
		if( !IsDefined( possible_turrets[i].script_dont_link_turret ) )
		{
			turrets[possible_turrets[i].origin + ""] = possible_turrets[i]; 
		}
	}

	// did we find any turrets?
	if( !turrets.size )
	{
		return; 
	}
		
	for( nodeIndex = 0; nodeIndex < nodes.size; nodeIndex++ )
	{
		node = nodes[nodeIndex]; 
		if( node.type == "Path" )
		{
			continue; 
		}
		if( node.type == "Begin" )
		{
			continue; 
		}
		if( node.type == "End" )
		{
			continue; 
		}
//		if( node.type != "Turret" )
//			continue; 

	    nodeForward = AnglesToForward( ( 0, node.angles[1], 0 ) ); 

		keys = GetArrayKeys( turrets ); 
		for( i = 0; i < keys.size; i++ )
		{
			turret = turrets[keys[i]]; 
			if( Distance( node.origin, turret.origin ) > 70 )
			{
				continue; 
			}
		
		    turretForward = AnglesToForward( ( 0, turret.angles[1], 0 ) ); 
		    
			dot = VectorDot( nodeForward, turretForward ); 
			if( dot < 0.9 )
			{
				continue; 
			}
	
			node.turret = turret; 
			turret.node = node; 
			turret.isSetup = true;
			assertEx( isdefined( turret.export ), "Turret at " + turret.origin + " does not have a .export value but is near a cover node. If you do not want them to link, use .script_dont_link_turret." );

			// remove the reference for it so that the other nodes dont
			// scan for this turret
			turrets[keys[i]] = undefined; 
		}
		
//		assertex( IsDefined( node.turret ), "Cover node at " + node.origin + " has no turret!" ); 
	}
	
	/#
	// err the unclaimed turrets
	keys = GetArrayKeys( turrets ); 
	if( keys.size )
	{
		println( "The turrets at the following origins were not auto-bound to a node_turret." ); 
		println( "Set .script_dont_link_turret if you do not want a turret to use a node_turret." ); 
		for( i = 0; i < keys.size; i++ )
		{
			println( keys[i] ); 
		}
		assertex( 0, "Turrets failed to be linked to node_turrets, see list above." ); 
	}
	#/
	
		/*
		// logic that makes the node "call" for ai
		if( IsDefined( node.auto_mgTurret_target ) )
		{
			thread maps\_mgturret::turret_think( node ); 
		}
		*/

	
	nodes = undefined; 
}


save_turret_sharing_info()
{
	// shares turrets so a guy at a turret knows where to run if he decides to move the turret
	self.shared_turrets = []; 
	self.shared_turrets["connected"] = []; 
	self.shared_turrets["ambush"] = []; 
	
	if( !IsDefined( self.export ) )
	{
		assertex( !IsDefined( self.script_turret_share ), "Turret at " + self.origin + " has script_turret_share but has no .export value, so script_turret_share won't have any effect." ); 
		assertex( !IsDefined( self.script_turret_ambush ), "Turret at " + self.origin + " has script_turret_ambush but has no .export value, so script_turret_ambush won't have any effect." ); 
		return; 
	}
		
	level.shared_portable_turrets[self.export] = self; 

	if( IsDefined( self.script_turret_share ) )
	{
		// turn the origin into a unique string
		
		// record which turrets share with this one
		strings = Strtok( self.script_turret_share, " " ); 
		
		for( i = 0; i < strings.size; i++ )
		{
			self.shared_turrets["connected"][strings[i]] = true; 
		}
	}

	if( IsDefined( self.script_turret_ambush ) )
	{
		// turn the origin into a unique string
		
		// record which turrets share with this one
		strings = Strtok( self.script_turret_ambush, " " ); 
		
		for( i = 0; i < strings.size; i++ )
		{
			self.shared_turrets["ambush"][strings[i]] = true; 
		}
	}
}

/*
mg42setup_gun()
{
	assertex( IsDefined( self.target ), "Portable MG42 guy at origin " + self.origin + " has no target" ); 
	mg42node = GetNode( self.target, "targetname" ); 
	mg42 = GetEnt( self.target, "targetname" ); 
	
	if( !IsDefined( mg42.shared_turrets ) )
	{
		mg42 save_turret_sharing_info(); 
	}
	
	// If the portable gunner targets a node then he's going to do a chain of nodes to the destination, which should
	// be an mg42. Otherwise he's directly targetting an mg42.
	if( IsDefined( mg42node ) )
	{
		// Set this so later we can run along it as a chain.
		self.mg42node = mg42node; 
		assert( !IsDefined( mg42 ), "guy at " + self.origin + " targets an ent and a node" ); 
		for( ;; )
		{
			newnode = GetNode( mg42node.target, "targetname" ); 
			if( !IsDefined( newnode ) )
			{
				mg42 = GetEnt( mg42node.target, "targetname" ); 
				break; 
			}
			mg42node = newnode; 
		}
	}
	
	assertex( IsDefined( mg42 ), "Portable MG42 guy at origin " + self.origin + " doesn't target an mg42" ); 
	assertex( mg42.classname == "misc_turret", "Portable MG42 guy at origin " + self.origin + " doesn't target an mg42" ); 
	if( !IsDefined( mg42.isSetup ) )
	{
		mg42 hide_turret(); 
	}
	return mg42; 
}
*/

restoreDefaultPitch()
{
	self notify( "gun_placed_again" ); 
	self endon( "gun_placed_again" ); 
	self waittill( "restore_default_drop_pitch" ); 
	wait( 1 ); 
	self RestoreDefaultDropPitch(); 
}

dropTurret()
{
	thread dropTurretProc(); 
}

dropTurretProc()
{
	turret = Spawn( "script_model", ( 0, 0, 0 ) ); 
	turret.origin = self GetTagOrigin( level.portable_mg_gun_tag ); 
	turret.angles = self GetTagAngles( level.portable_mg_gun_tag ); 
	turret SetModel( self.turretModel ); 
	forward = AnglesToForward( self.angles ); 
	forward = vectorScale( forward, 100 ); 
	turret MoveGravity( forward, 0.5 ); 
	self Detach( self.turretModel,  level.portable_mg_gun_tag ); 
	self.turretmodel = undefined; 
	wait( 0.7 ); 
	turret Delete(); 
}


turretDeathDetacher()
{
	self endon( "kill_turret_detach_thread" ); 
	self endon( "dropped_gun" ); 
	self waittill( "death" ); 
	if( !IsDefined( self ) )
	{
		return; // in case many guys die at once and we are removed
	}
	dropTurret(); 
}

turretDetacher()
{
	self endon( "death" ); 
	self endon( "kill_turret_detach_thread" ); 
	// in case the enemy gets close to a portable turret guy
	self waittill( "dropped_gun" ); 
	self Detach( self.turretModel,  level.portable_mg_gun_tag ); 
}

restoreDefaults()
{
//	self.goalradius = 350; 
	self.run_noncombatanim = undefined; 
	self.run_combatanim = undefined; 
	self set_all_exceptions( animscripts\init::empty ); 
}

restorePitch()
{
	self waittill( "turret_deactivate" ); 
	self RestoreDefaultDropPitch(); 
}

update_enemy_target_pos_while_running( ent )
{
	self endon( "death" ); 
	self endon( "end_mg_behavior" ); 
	self endon( "stop_updating_enemy_target_pos" ); 

	for( ;; )
	{
		self waittill( "saw_enemy" ); 		
		ent.origin = self.last_enemy_sighting_position; 
	}
}

move_target_pos_to_new_turrets_visibility( ent, new_spot )
{
	// moves the target position to a point where the new turret
	// can see it. If the position gets updated by seeing an enemy
	// then that position also gets pushed towards the last turret to
	// the point of visibility on the assumption that towards the old
	// turret will bring it into visibility without causing it to 
	// go to a weird point.
	
	// in any case the whole system probably needs a failsafe in case
	// the target position gets way outside the gun's allowed angles
	
	self endon( "death" ); 
	self endon( "end_mg_behavior" ); 
	self endon( "stop_updating_enemy_target_pos" ); 

	old_turret_pos = self.turret.origin +( 0, 0, 16 ); // turrets are on geo so it could abstruct; 
	dest_pos = new_spot.origin +( 0, 0, 16 ); 
	
	for( ;; )
	{
		wait( 0.05 ); // plenty of time while he runs, doesn't have to happen often

		if( SightTracePassed( ent.origin, dest_pos, 0, undefined ) )
		{
//			line( ent.origin, dest_pos, ( 0, 1, 0 ) ); 
			continue; 
		}

//		line( ent.origin, dest_pos, ( 1, 0, 0 ) ); 
		
		// move the target pos towards the last turret position
		angles = VectorToAngles( old_turret_pos - ent.origin ); 
		forward = AnglesToForward( angles ); 
		forward = vectorscale( forward, 8 ); 
		
		ent.origin = ent.origin + forward; 
	}
}

record_bread_crumbs_for_ambush( ent )
{
	self endon( "death" ); 
	self endon( "end_mg_behavior" ); 
	self endon( "stop_updating_enemy_target_pos" ); 
	
	ent.bread_crumbs = []; 
	for( ;; )
	{
//		print3d( self.origin +( 0, 0, 50 ), "*", ( 1, 1, 0 ), 1, 1.5, 10*20 ); 
		ent.bread_crumbs[ent.bread_crumbs.size] = self.origin +( 0, 0, 50 ); 
		wait( 0.35 ); 	
	}
}

aim_turret_at_ambush_point_or_visible_enemy( turret, ent )
{
	if( !IsAlive( self.current_enemy ) && self CanSee( self.current_enemy ) )
	{
		// if we can see our enemy then just aim at him
		ent.origin = self.last_enemy_sighting_position; 
		return; 
	}
	
	
	forward = AnglesToForward( turret.angles ); 
	
	// find the best bread crumb to aim at
	// start a few from the back because the crumbs from while we were walking at the gun
	// arent going to be good
	for( i = ent.bread_crumbs.size - 3; i >= 0; i-- )
	{
		// dot check it so we're not aiming at the breadcrumbs we walked over
		crumb = ent.bread_crumbs[i]; 
		normal = VectorNormalize( crumb - turret.origin ); 
		dot = VectorDot( forward, normal ); 
		if( dot < 0.75 )
		{
			continue; 
		}

		ent.origin = crumb; 
			
		// find the first one we cant see and aim there
		if( SightTracePassed( turret.origin, crumb, 0, undefined ) )
		{
//			linetime( turret.origin, crumb, ( 0, 1, 0 ), 10 ); 
			continue; 
		}
		
//		linetime( turret.origin, crumb, ( 1, 0, 0 ), 10 ); 
		break; 
	}
}

find_a_new_turret_spot( ent )
{
	// find a new spot to go to
	array = get_portable_mg_spot( ent ); 
	new_spot = array["spot"]; 
	connection_type = array["type"]; 
	
	if( !IsDefined( new_spot ) )
	{
		return; 
	}

	reserve_turret( new_spot ); 
		
	// if we see the enemy while we run, update the target position
	thread update_enemy_target_pos_while_running( ent ); 
	thread move_target_pos_to_new_turrets_visibility( ent, new_spot ); 
	
	if( connection_type == "ambush" )
	{
		thread record_bread_crumbs_for_ambush( ent ); 
	}

	if( new_spot.isSetup )
	{
		leave_gun_and_run_to_new_spot( new_spot ); 
	}
	else
	{
		pickup_gun( new_spot ); 
		run_to_new_spot_and_setup_gun( new_spot ); 
	}
		
	self notify( "stop_updating_enemy_target_pos" ); 

	if( connection_type == "ambush" )
	{
		aim_turret_at_ambush_point_or_visible_enemy( new_spot, ent ); 
	}

//	thread snap_lock_turret_onto_target( new_spot ); 
	
	new_spot SetTargetEntity( ent ); 
}

snap_lock_turret_onto_target( turret )
{
	// turn manual on for a moment so he aims quickly to the spot he wants to aim at.
	turret SetMode( "manual" ); 
	wait( 0.5 ); 
	turret SetMode( "manual_ai" ); 
}

leave_gun_and_run_to_new_spot( spot )
{
	assert( spot.reserved == self ); 
	// spot is a bit of a misnomer as its actually a hidden gun we 
	// rematerialize when he runs to it

	self StopUSeturret(); 
	self animscripts\shared::placeWeaponOn( self.primaryweapon, "none" ); 

	// run to the spot where the gun is setup
	setup_anim = get_turret_setup_anim( spot ); 
	org = GetStartOrigin( spot.origin, spot.angles, setup_anim ); 
	self SetruntoPos( org ); 
	assertex( Distance( org, self.goalpos ) < self.goalradius, "Tried to set the run pos outside the goalradius" ); 
	
	self waittill( "runto_arrived" ); 
	
	use_the_turret( spot ); 
}

pickup_gun( spot )
{
	// spot is a bit of a misnomer as its actually a hidden gun we 
	// rematerialize when he runs to it
	
	self StopUSeturret(); 
	self.turret hide_turret(); 
}

get_turret_setup_anim( turret )
{
	spot_types = []; 
	spot_types[ "saw_bipod_stand" ] =			level.mg_animmg[ "bipod_stand_setup" ];
	spot_types[ "saw_bipod_crouch" ] =			level.mg_animmg[ "bipod_crouch_setup" ];
	spot_types[ "saw_bipod_prone" ] =			level.mg_animmg[ "bipod_prone_setup" ];
	
	return spot_types[turret.weaponinfo]; 
}

run_to_new_spot_and_setup_gun( spot )
{
	assert( spot.reserved == self ); 
	
	oldhealth = self.health; 
	spot endon( "turret_deactivate" ); 
	
	self.mg42 = spot; // used in the animscript exceptions
	self endon( "death" ); 
	self endon( "dropped_gun" ); 

	setup_anim = get_turret_setup_anim( spot ); 
	
	self.turretModel = "weapon_mg42_carry"; 
	
	// guys are meant to get their gun back automatically when they ditch an mg
	self notify( "kill_get_gun_back_on_killanimscript_thread" ); 
	self animscripts\shared::placeWeaponOn( self.weapon, "none" ); 
	if( self.team == "axis" )
	{
		self.health = 1; 
	}

	// set the run anim
	self.run_noncombatanim = %saw_gunner_run_slow;
	self.run_combatanim = %saw_gunner_run_fast;
	self.crouchrun_combatanim = %saw_gunner_run_fast;

	// attach the carry version of the gun		
	self Attach( self.turretModel, level.portable_mg_gun_tag ); 
	thread turretDeathDetacher(); 

	// run to the spot where the gun is going to be setup
	org = GetStartOrigin( spot.origin, spot.angles, setup_anim ); 
	self SetruntoPos( org ); 
	assertex( Distance( org, self.goalpos ) < self.goalradius, "Tried to set the run pos outside the goalradius" ); 
	
	wait( 0.05 ); // must figure out what this wait is needed for
	self set_all_exceptions( animscripts\combat::exception_exposed_mg42_portable ); 
	clear_exception( "move" ); 
	set_exception( "cover_crouch", ::hold_indefintely ); 
	
	while( Distance( self.origin, org ) > 16 )
	{
		self SetruntoPos( org ); 
		wait( 0.05 ); 
	}
//	self waittill( "runto_arrived" ); 
		
	self notify( "kill_turret_detach_thread" ); 
	
	if( self.team == "axis" )
	{
		self.health = oldhealth; 
	}

	
	if( SoundExists( "weapon_setup" ) )
	{
		thread play_sound_in_space( "weapon_setup" ); 
	}
		
	self AnimScripted( "setup_done", spot.origin, spot.angles, setup_anim ); 
	
	restoreDefaults(); // reset the run anims
	
	self waittillmatch( "setup_done", "end" ); 
	spot notify( "restore_default_drop_pitch" ); 
	spot show_turret(); 
	
	self animscripts\shared::placeWeaponOn( self.primaryweapon, "right" ); 

	use_the_turret( spot ); 
	self Detach( self.turretModel, level.portable_mg_gun_tag ); 
	self set_all_exceptions( animscripts\init::empty ); 

	self notify( "bcs_portable_turret_setup" ); 
}

move_to_run_pos()
{
	self SetruntoPos( self.runpos ); 
}

hold_indefintely()
{
	self endon( "killanimscript" ); 
	self waittill( "death" ); 
}

using_a_turret()
{
	if( !IsDefined( self.turret ) )
	{
		return false; 
	}
		
	return self.turret.owner == self; 
}
	

turret_user_moves()
{
	// we've been forced to move by goalradius change or becoming exposed
	if( !using_a_turret() )
	{
		clear_exception( "move" ); 
		return; 
	}

	array = find_connected_turrets( "connected" ); 
	new_spots = array["spots"]; 
	
	if( !new_spots.size )
	{
		// none of the turrets in the area we're moving to are connected to the 
		// one we were at so we turn back to normal guy now
		clear_exception( "move" ); 
		return; 
	}
	
	// lets see if we have a new node, and if we do, if its a compatible turret node
	turret_node = self.node; 

	// if its not, then lets use a random node from the connected nodes that are
	// within our goal radius	
	if( !IsDefined( turret_node ) || !is_in_array( new_spots, turret_node ) )
	{
		taken_nodes = getTakenNodes(); 
		for( i = 0; i < new_spots.size; i++ )
		{
			turret_node = random( new_spots ); 
	
			// some random AI has this node already, probably doing cover there
			// if we get the ability to push AI off their node then we'll do that here later
			if( IsDefined( taken_nodes[turret_node.origin + ""] ) )
			{
				return; 
			}
		}
	}
	
	turret = turret_node.turret; 
	
	if( IsDefined( turret.reserved ) )
	{
		assert( turret.reserved != self ); 
		return; 
	}
		
	reserve_turret( turret ); 
	
	// we're not at the turret position so we have to run to it
	if( turret.isSetup )
	{
		// its already setup so just go there and use it
		leave_gun_and_run_to_new_spot( turret ); 
	}
	else
	{
		// its not setup yet so go there and set it up then use it
		run_to_new_spot_and_setup_gun( turret ); 
	}
		
	maps\_mg_penetration::gunner_think( turret_node.turret ); 
}

use_the_turret( spot )
{
	turretWasUsed = self USeturret( spot ); 

	if( turretWasUsed )
	{	
		set_exception( "move", ::turret_user_moves ); // run this before running move so we might move the turret

		self.turret = spot; 
		self thread mg42_firing( spot ); // does the burst fire timings
		spot SetMode( "manual_ai" ); 
		spot thread restorePitch(); 
		self.turret = spot; 
		spot.owner = self; 
//		self USeturret( spot ); // dude should be near the mg42
//		spot SetMode( "manual_ai" ); // auto, auto_ai, manual
//		self.turret = spot; 
		return true; 
	}
	else
	{
		spot RestoreDefaultDropPitch(); 
		return false; 
	}

}

get_portable_mg_spot( ent )
{
	find_spot_funcs = []; 
	find_spot_funcs[find_spot_funcs.size] = ::find_different_way_to_attack_last_seen_position; 
	find_spot_funcs[find_spot_funcs.size] = ::find_good_ambush_spot; 

	find_spot_funcs = array_randomize( find_spot_funcs ); 
	
	for( i = 0; i < find_spot_funcs.size; i++ )
	{
		array = [[find_spot_funcs[i]]]( ent ); 
		
		if( !IsDefined( array["spots"] ) )
		{
			continue; 
		}
		
		array["spot"] = random( array["spots"] ); 
		return array; 
	}
}

getTakenNodes()
{
	// returns an array of node origins owned by AI
	array = []; 
	ai = GetAiArray(); 
	
	for( i = 0; i < ai.size; i++ )
	{
		if( !IsDefined( ai[i].node ) )
		{
			continue; 
		}
		
		array[ai[i].node.origin + ""] = true; 
	}
	
	return array; 
}

find_connected_turrets( connection_type )
{
	spots = level.shared_portable_turrets; 	// an array of shared turrets, using their origin as the index
	usable_spots = []; 
	
	spot_exports = GetArrayKeys( spots ); 
	
	taken_nodes = getTakenNodes(); 
	taken_nodes[self.node.origin + ""] = undefined; 
	
	// find turrets that share the same keys
	for( i = 0; i < spot_exports.size; i++ )
	{
		export = spot_exports[i]; 
		if( spots[export] == self.turret )
			continue; 
			
		
		keys = GetArrayKeys( self.turret.shared_turrets[connection_type] ); 	
		for( p = 0; p < keys.size; p++ )
		{
			// go through each key that the turret the guy is currently on has, 
			// and see if any turrets share keys.
			// cast export as a string because arraykeys returns strings
			if( spots[export].export + "" != keys[p] )
			{
				continue; 
			}
				
			// somebody else has this one or they're running to it
			if( IsDefined( spots[export].reserved ) )
			{
				continue; 
			}
				
			// some random AI has this node already, probably doing cover there
			if( IsDefined( taken_nodes[spots[export].node.origin + ""] ) )
			{
				continue; 
			}
				
			// don't pick one that is outside the goalradius
			if( Distance( self.goalpos, spots[export].origin ) > self.goalradius )
			{
				continue; 
			}
				
			// this spot is usable				
			usable_spots[usable_spots.size] = spots[export]; 
		}
	}

	array = []; 
	// store it so we can figure out the best place for an ambusher to aim
	array["type"] = connection_type; 
	array["spots"] = usable_spots; 
	return array; 	
}

find_good_ambush_spot( ent )
{
	return find_connected_turrets( "ambush" ); 
}

find_different_way_to_attack_last_seen_position( ent )
{
	array = find_connected_turrets( "connected" ); 
	usable_spots = array["spots"]; 
	
	if( !usable_spots.size )
	{
		return; 
	}

	good_spot = []; 
	
	// find a spot that has a good fov and LOS on the target spot
	for( i = 0; i < usable_spots.size; i++ )
	{
			
		if( !within_fov( usable_spots[i].origin, usable_spots[i].angles, ent.origin, 0.75 ) )
		{
			continue; 
		}
		
		/*
		normal = VectorNormalize( ent.origin -( usable_spots[i].origin + offset ) ); 
		forward = AnglesToForward( usable_spots[i].angles ); 
		dot = VectorDot( forward, normal ); 

		thread linetime( usable_spots[i].origin + offset, usable_spots[i].origin + offset + vectorscale( forward, 1000 ), ( 1, 0, 0 ), 10 ); 
		thread linetime( ent.origin, usable_spots[i].origin + offset, ( 0, 0, 1 ), 10 ); 
		*/
			
		if( !SightTracePassed( ent.origin, usable_spots[i].origin +( 0, 0, 16 ), 0, undefined ) )
		{
			continue; 
		}
	
		good_spot[good_spot.size] = usable_spots[i]; 
	}
	
	array["spots"] = good_spot; 
	return array; 
}

portable_mg_spot()
{
	save_turret_sharing_info(); 	
	
	turret_preplaced = 1; 
	self.isSetup = true; 
	assert( !IsDefined( self.reserved ) ); 
	self.reserved = undefined; 
	if( IsDefined( self.isvehicleattached ) )
	{
		return; 	//nate
	}
	if( self.spawnflags & turret_preplaced )
	{
		return; 
	}
		
	// a spot where a gun could be placed
	hide_turret(); 
	
}


hide_turret()
{
	assert( self.isSetup ); 
	self notify( "stop_checking_for_flanking" ); 
	self.isSetup = false; 
	self Hide(); 
	self.solid = false; 
	self MakeTurretUnusable(); 
	self SetDefaultDropPitch( 0 ); 
	self thread restoreDefaultPitch(); 
}

show_turret()
{
	self Show(); 
	self.solid = true; 
	self MakeTurretUsable(); 
	assert( !self.isSetup ); 
	self.isSetup = true; 
	thread stop_mg_behavior_if_flanked(); 
}

stop_mg_behavior_if_flanked()
{
	self endon( "stop_checking_for_flanking" ); 
	
	self waittill( "turret_deactivate" ); 
	if( IsAlive( self.owner ) )
	{
		self.owner notify( "end_mg_behavior" ); 
	}
}

turret_is_mine( turret )
{
	owner = turret GetTurretOwner(); 
	if( !IsDefined( owner ) )
	{
		return false; 
	}
	
	return owner == self; 
}

end_turret_reservation( turret )
{
	waittill_turret_is_released( turret ); 
	turret.reserved = undefined; 
}

waittill_turret_is_released( turret )
{
	turret endon( "turret_deactivate" ); 
	self endon( "death" ); 
	self waittill( "end_mg_behavior" ); 
}
	
reserve_turret( turret )
{
	turret.reserved = self; 
	thread end_turret_reservation( turret ); 
}


// -- LINKING TURRETS -- (SRS 05/02/07)
// - for vehicles, or other ents that have their own turret groups.

// GSCDOC needed
// link the turrets so they fire together.
// self = the vehicle
link_turrets( turretArray )
{
	self endon( "death" );
	
	level.print3d_ran_already = false;  // TEMP for testing
	
	// don't run it if there aren't enough turrets to justify its use
	if( !IsDefined( turretArray ) || turretArray.size <= 1 )
	{
		return;
	}
	
	// wait for a turret to fire
	while( 1 )
	{
		for( i = 0; i < turretArray.size; i++ )
		{
			if( turretArray[i] IsFiringTurret() )
			{
				// the turret that's firing becomes the "leader" that others will match
				self link_turrets_fireall( turretArray[i], turretArray );
			}
		}
		
		// run this every frame
		wait( 0.05 );
	}
}

// When we detect a turret is firing, this function fires the others at the same time.
// self = the vehicle
link_turrets_fireall( leaderTurret, turretArray )
{
	self endon( "death" );
	
	self.leadTurretState = 0;
	
	// set up each turret to be manual
	for( i = 0; i < turretArray.size; i++ )
	{
		if( turretArray[i] != leaderTurret && !turretArray[i] IsFiringTurret() )
		{
			turretArray[i] SetMode( "manual" );
		}
	}
	
	// wait for the first turret to stop firing
	while( leaderTurret IsFiringTurret() )
	{
		// make sure we're not in a burst fire wait state
		if( leaderTurret.script_shooting )
		{
			// fire all other turrets while the first turret is still firing
			for( i = 0; i < turretArray.size; i++ )
			{
				if( turretArray[i] != leaderTurret && !turretArray[i] IsFiringTurret() )
				{
					turretArray[i] ShootTurret();
				}
			}
		}
		
		wait( 0.1 );
	}
	
	// stop waiting for state changes
	self notify( "lead_turret_stopped" );
	
	// turn off the other turrets
	for( i = 0; i < turretArray.size; i++ )
	{
		if( turretArray[i] != leaderTurret && !turretArray[i] IsFiringTurret() )
		{
			//turretArray[i] StopFiring();
			turretArray[i] SetMode( "auto_nonai" );
		}
	}
}

// MikeD (4/12/2008): Added the ability for MG Guns to animate an entity near it like a tarp/net/curtains when it fires
init_mg_animent()
{
/#
	if( !IsDefined( level.scr_anim ) )
	{
		assertMsg( "You must put \"init_mg_animent\" after " + tolower( GetDvar( "mapname" ) ) + "_anim::main() so the level.scr_anim is defined." );
	}
#/

	mg42s = GetEntArray( "misc_mg42", "classname" );
	turrets = GetEntArray( "misc_turret", "classname" );

	turrets = array_combine( mg42s, turrets );

	for( i = 0; i < turrets.size; i++ )
	{
		if( IsDefined( turrets[i].script_animent ) )
		{
			turrets[i] thread mg_anim_ent();
		}
	}
}

mg_anim_ent()
{
	self endon( "stop_mg_anim_ent" );
	self endon( "death" );

	anim_ent = GetEnt( self.script_animent, "targetname" );

/#
	if( !IsDefined( anim_ent ) )
	{
		assertMsg( "Could not GetEnt( " + self.script_animent + ", \"targetname\" ) to animate the object for the given Turret" );
	}
#/

	if( IsDefined( anim_ent.script_animname ) )
	{
		anim_ent.animname = anim_ent.script_animname;
	}
	else
	{
		anim_ent.animname = anim_ent.targetname;
	}

	delay = 0.2;
	intro_time = GetAnimLength( level.scr_anim[anim_ent.animname]["intro"] ) - delay;

	anim_ent maps\_anim::SetAnimTree();

	state = "outro";
	for( ;; )
	{
		owner = self GetTurretOwner();
		if( !IsDefined( owner ) )
		{
			if( state != "outro" )
			{
				state = "outro";
				anim_ent SetFlaggedAnimKnobRestart( "mg_animent_anim", level.scr_anim[anim_ent.animname][state], 1.0, 0.2, 1.0 );
			}

			self waittill( "turretownerchange" );
			owner = self GetTurretOwner();
		}

		if( self mg_is_firing( owner ) )
		{
			if( state == "outro" )
			{
				state = "intro";
				anim_ent SetFlaggedAnimKnobRestart( "mg_animent_anim", level.scr_anim[anim_ent.animname][state], 1.0, 0.2, 1.0 );
				wait( intro_time );
			}
			else if( state == "intro" || state == "loop" )
			{
				state = "loop";
				anim_ent SetFlaggedAnimKnob( "mg_animent_anim", level.scr_anim[anim_ent.animname][state], 1.0, 0.2, 1.0 );
			}
		}
		else if( state != "outro" )
		{
			state = "outro";
			anim_ent SetFlaggedAnimKnobRestart( "mg_animent_anim", level.scr_anim[anim_ent.animname][state], 1.0, 0.2, 1.0 );
		}

		wait( delay );
	}
}

mg_is_firing( owner )
{
	if( !IsDefined( owner ) )
	{
		return false;
	}

	if( IsPlayer( owner ) )
	{
		return IsTurretFiring( self );
	}
	else
	{
		if( IsDefined( self.doFiring ) && self.doFiring )
		{
			return true;
		}
	
		if( IsDefined( self.script_shooting ) && self.script_shooting )
		{
			return true;
		}
	}

	return false;
}