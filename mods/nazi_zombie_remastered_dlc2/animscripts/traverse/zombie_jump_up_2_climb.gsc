#include animscripts\traverse\shared; 
#include maps\_utility;
#include animscripts\Utility;

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie &&  self.type != "dog")
	{
		zombie_jump_up_to_climb(); 
	}
}

#using_animtree( "generic_human" ); 

zombie_jump_up_to_climb()
{

	anims = undefined;

	if( self.has_legs )
	{
		anims = %ai_zombie_jump_up_2_climb;
	}

	if(IsDefined(anims))
	{
		self advancedTraverse2( anims, 88 );;
	}
}


advancedTraverse2(traverseAnim, normalHeight)
{
	// do not do code prone in this script
	self.desired_anim_pose = "crouch";
	animscripts\utility::UpdateAnimPose();

	self.old_anim_movement = self.a.movement;
	self.old_anim_alertness = self.a.alertness;

	self endon("killanimscript");
	self traverseMode("nogravity");
	self traverseMode("noclip"); // So he doesn't get stuck if the wall is a little too high

	// orient to the Negotiation start node
	startnode = self getnegotiationstartnode();
	assert( isdefined( startnode ) );
	self OrientMode( "face angle", startnode.angles[1] );

	//	// DPG - in case a node doesn't have a traverse height set
	//	if( IsDefined( startnode.traverse_height ) )
	//	{
	//		realHeight = startnode.traverse_height - startnode.origin[2];	
	//		//self thread teleportThread(realHeight - normalHeight);
	//	}
	//	else
	//	{
	//		assertmsg( "traverse_height not defined for node at " + startnode.origin + ". the node needs a targetname of 'traverse' and a targeted script_origin" );
	//	}	

	self animscripts\traverse\shared::TraverseStartRagdollDeath();

	self setFlaggedAnimKnoballRestart("traverse", traverseAnim, %body, 1, 0.2, 1.1);
	self animscripts\shared::DoNoteTracks( "traverse" );

	self animscripts\traverse\shared::TraverseStopRagdollDeath();

	self setAnimRestart( %combatrun_forward_1, 1, 0.1 );
	/*
	timer = gettime();
	self thread animscripts\shared::DoNoteTracksForever( "traverse", "no clear", ::handle_death );

	if (!animhasnotetrack(traverseAnim, "gravity on"))
	{
	timer = 1.23;
	timerOffset = 0.2;
	//		wait (timer - timerOffset);
	wait 5.0;
	self traverseMode("gravity");
	wait (timerOffset);
	}
	else
	{
	self waittillmatch("traverse","gravity on");
	self traverseMode("gravity");
	if (!animhasnotetrack(traverseAnim, "blend"))
	wait (0.2);
	else
	self waittillmatch("traverse","blend");
	}

	if ( self.health == 1 )
	return;
	*/
	self.a.movement = self.old_anim_movement;
	self.a.alertness = self.old_anim_alertness;

	/*	
	runAnim = undefined;
	if (self.preCombatRunEnabled && !isInCombat())
	runAnim = %precombatrun1;
	else
	runAnim = self.a.combatrunanim;

	self setAnimKnobAllRestart(runAnim, %body, 1, 0.2, 1);
	wait (0.2);
	thread animscripts\run::MakeRunSounds ( "killSoundThread" );
	*/
}


handle_death( note )
{
	println( note );

	if ( note != "traverse_death" )
		return;

	self endon( "killanimscript" );

	if ( self.health == 1 )
	{
		self.a.nodeath = true;
		if ( self.traverseDeath > 1 )
		{
			if ( randomFloat( 1 ) > 0.5 )
				self setFlaggedAnimKnobAll( "deathanim", %traverse40_death_end_2, %body, 1, .2, 1 );
			else
				self setFlaggedAnimKnobAll( "deathanim", %traverse40_death_end, %body, 1, .2, 1 );
		}
		else
		{
			if ( randomFloat( 1 ) > 0.5 )
				self setFlaggedAnimKnobAll( "deathanim", %traverse40_death_start_2, %body, 1, .2, 1 );
			else
				self setFlaggedAnimKnobAll( "deathanim", %traverse40_death_start, %body, 1, .2, 1 );
		}

		self animscripts\face::SayGenericDialogue("death");
	}
	self.traverseDeath++;
}



