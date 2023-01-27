#using_animtree ("dog");

main()
{
	self endon("killanimscript");
	if ( isdefined( self.a.nodeath ) )
	{
		assertex( self.a.nodeath, "Nodeath needs to be set to true or undefined." );
		
		// allow death script to run for a bit so it doesn't turn to corpse and get deleted too soon during melee sequence
		wait 3;
		return;
	}

	self unlink();

	if ( isdefined( self.enemy ) && isdefined( self.enemy.syncedMeleeTarget ) && self.enemy.syncedMeleeTarget == self )
	{
		self.enemy.syncedMeleeTarget = undefined;
	}

	if ( IsDefined( self.tesla_death ) && self.tesla_death == true )
	{
		death_anims = [];
		death_anims[death_anims.size] = %zombie_dog_tesla_death_a;
		death_anims[death_anims.size] = %zombie_dog_tesla_death_b;
		death_anims[death_anims.size] = %zombie_dog_tesla_death_c;
		death_anims[death_anims.size] = %zombie_dog_tesla_death_d;
		death_anims[death_anims.size] = %zombie_dog_tesla_death_e;
		
		self animMode( "gravity" );
		self clearanim(%root, 0.2);
		self setflaggedanimrestart("dog_anim", death_anims[ randomint( death_anims.size ) ], 1, 0.2, 1);
		self animscripts\shared::DoNoteTracks( "dog_anim" );
	}
	else
	{
		death_direction = animscripts\dog_pain::getAnimDirection( self.damageyaw );

		self animMode( "gravity" );
		self clearanim(%root, 0.2);
		self setflaggedanimrestart("dog_anim", anim.dogAnims[self.animSet].death[death_direction], 1, 0.2, 1);
		self animscripts\shared::DoNoteTracks( "dog_anim" );
	}
}
