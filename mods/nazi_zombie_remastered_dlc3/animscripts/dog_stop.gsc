#using_animtree ("dog");

main()
{
	self endon("killanimscript");
	
	self clearanim(%root, 0.2);
	self clearanim(anim.dogAnims[self.animSet].idle, 0.2);
	self clearanim(anim.dogAnims[self.animSet].attack["attackidle_knob"], 0.2);

	self thread lookAtTarget( "attackIdle" );

	while (1)
	{
		if ( shouldAttackIdle() )
		{
			self clearanim(anim.dogAnims[self.animSet].idle, 0.2);
			self randomAttackIdle();
		}
		else
		{
			self orientmode( "face current" );
			self clearanim(anim.dogAnims[self.animSet].attack["attackidle_knob"], 0.2);
			self setflaggedanimrestart("dog_idle", anim.dogAnims[self.animSet].idle, 1, 0.2, self.animplaybackrate );
		}

		animscripts\shared::DoNoteTracks("dog_idle", ::dogIdleNotetracks);
	}
}

dogIdleNotetracks(note)
{
	if ( note == "breathe_fire" )
	{
		if(IsDefined(level._effect["dog_breath"]))
		{
			self.breath_fx = Spawn( "script_model", self GetTagOrigin( "TAG_MOUTH_FX" ) );
			self.breath_fx.angles = self GetTagAngles( "TAG_MOUTH_FX" );
			self.breath_fx SetModel( "tag_origin" );
			self.breath_fx LinkTo( self, "TAG_MOUTH_FX" );
	
			PlayFxOnTag( level._effect["dog_breath"], self.breath_fx, "tag_origin" );
		}
	}
}


isFacingEnemy( toleranceCosAngle )
{
	assert( isdefined( self.enemy ) );
	
	vecToEnemy = self.enemy.origin - self.origin;
	distToEnemy = length( vecToEnemy );
	
	if ( distToEnemy < 1 )
		return true;
	
	forward = anglesToForward( self.angles );
	
	return ( ( forward[0] * vecToEnemy[0] ) + ( forward[1] * vecToEnemy[1] ) ) / distToEnemy > toleranceCosAngle;
}

randomAttackIdle()
{
	if ( isFacingEnemy( -0.5 ) )	// cos120
		self orientmode( "face current" );
	else
	self orientmode("face enemy");
	
	self clearanim(anim.dogAnims[self.animSet].attack["attackidle_knob"], 0.1);

	if ( IsDefined( self.enemy ) && IsPlayer( self.enemy ) && IsAlive( self.enemy ) )
	{
		range = GetDvarFloat( "ai_meleeRange" );

		distance_ok = DistanceSquared( self.origin, self.enemy.origin ) < ( range * range );

		if ( distance_ok == true )
		{
			self notify( "dog_combat" );
			self animscripts\dog_combat::meleeBiteAttackPlayer( self.enemy );
			return;
		}
	}
	
	if ( should_growl() )
	{
		// just growl
		self setflaggedanimrestart( "dog_idle", anim.dogAnims[self.animSet].combatIdle["attackidle_growl"], 1, 0.2, 1 );
		return;
	}

	idleChance = 33;
	barkChance = 66;

	if ( isdefined( self.mode ) )
	{
		if ( self.mode == "growl" )
		{
			idleChance = 15;
			barkChance = 30;
		}
		else if ( self.mode == "bark" )
		{
			idleChance = 15;
			barkChance = 85;
		}
	}

	rand = randomInt( 100 );
	if ( rand < idleChance )
		self setflaggedanimrestart( "dog_idle", anim.dogAnims[self.animSet].combatIdle["attackidle_growl"], 1, 0.2, self.animplaybackrate );
	else if ( rand < barkChance )
		self setflaggedanimrestart( "dog_idle", anim.dogAnims[self.animSet].combatIdle["attackidle_bark"], 1, 0.2, self.animplaybackrate );
	else
		self setflaggedanimrestart( "dog_idle", anim.dogAnims[self.animSet].combatIdle["attackidle_growl"], 1, 0.2, self.animplaybackrate );
}

shouldAttackIdle()
{
	return ( isdefined( self.enemy ) && isalive( self.enemy ) && distanceSquared( self.origin, self.enemy.origin ) < 1000000 );
}

should_growl()
{
	if ( isdefined( self.script_growl ) )
		return true;
	if ( !isalive( self.enemy ) )
		return true;
	return !( self cansee( self.enemy ) );
}

lookAtTarget( lookPoseSet )
{
	self endon( "killanimscript" );
	self endon( "stop tracking" );
	
	self clearanim( anim.dogAnims[self.animSet].lookKnob[2], 0 );
	self clearanim( anim.dogAnims[self.animSet].lookKnob[4], 0 );
	self clearanim( anim.dogAnims[self.animSet].lookKnob[6], 0 );
	self clearanim( anim.dogAnims[self.animSet].lookKnob[8], 0 );

	self.rightAimLimit = 90;
	self.leftAimLimit = -90;
	self.upAimLimit = 45;
	self.downAimLimit = -45;

	self setanimlimited( anim.dogAnims[self.animSet].look[lookPoseSet][2], 1, 0 );
	self setanimlimited( anim.dogAnims[self.animSet].look[lookPoseSet][4], 1, 0 );
	self setanimlimited( anim.dogAnims[self.animSet].look[lookPoseSet][6], 1, 0 );
	self setanimlimited( anim.dogAnims[self.animSet].look[lookPoseSet][8], 1, 0 );
	
	self animscripts\shared::setAnimAimWeight( 1, 0.2 );
	self animscripts\shared::trackLoop( anim.dogAnims[self.animSet].lookKnob[2],anim.dogAnims[self.animSet].lookKnob[4], anim.dogAnims[self.animSet].lookKnob[6], anim.dogAnims[self.animSet].lookKnob[8] );
}