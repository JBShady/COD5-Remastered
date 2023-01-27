#using_animtree ("dog");

main()
{
	self endon("killanimscript");

	if ( isdefined( self.enemy ) && isdefined( self.enemy.syncedMeleeTarget) && self.enemy.syncedMeleeTarget == self )
	{
		self unlink();
		self.enemy.syncedMeleeTarget = undefined;
	}
	
	speed = length( self getaivelocity() );
	 
	pain_set = "pain";
	pain_direction = getAnimDirection( self.damageyaw );

	// should only do this while running because the anim is supposed to while running
	if ( speed > level.dogRunPainSpeed )
	{
			pain_set = "pain_run";
	}
	
	self clearanim(%root, 0.2);
	self setflaggedanimrestart("dog_pain_anim",  anim.dogAnims[self.animSet].pain[pain_set][pain_direction], 1, 0.2, 1);
	
	self animscripts\shared::DoNoteTracksForTime( 0.2, "dog_pain_anim" );
}

getAnimDirection( damageyaw )
{
	if( ( damageyaw > 135 ) ||( damageyaw <= -135 ) )	// Front quadrant
	{
		return 2; // "front";
	}
	else if( ( damageyaw > 45 ) &&( damageyaw <= 135 ) )		// Right quadrant
	{
		return 6; // "right";
	}
	else if( ( damageyaw > -45 ) &&( damageyaw <= 45 ) )		// Back quadrant
	{
		return 8; // "back";
	}
	else
	{															// Left quadrant
		return 4; //"left";
	}
	return "front";
}
