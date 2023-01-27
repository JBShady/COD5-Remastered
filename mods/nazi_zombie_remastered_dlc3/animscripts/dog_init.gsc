#include common_scripts\utility;
#using_animtree( "dog" );

main()
{
	self useAnimTree( #animtree );
	self.animSet = "zombie";
	
	initDogAnimations();
	animscripts\init::firstInit();
	
	self.ignoreSuppression = true;
	
	self.chatInitialized = false;
	self.noDodgeMove = true;
	self.root_anim = %root;

	self.meleeAttackDist = 0;
	self thread setMeleeAttackDist();

	level.dogTurnAroundAngle = 135;  // if the turn delta is greater then this it will play the 180 anim
	level.dogTurnAngle = 70; // if the turn delta is greater then this it will play the 90 anim

	level.dogRunTurnSpeed = 20; // if the speed is greater then play the run turns
	level.dogRunPainSpeed = 20; // if the speed is greater then play the run pains
	level.dogTurnMinDistanceToGoal = 60; // if the distance to goal is under this then no turn anims play

	self.a = spawnStruct();
	self.a.pose = "stand";					// to use DoNoteTracks()
	self.a.nextStandingHitDying = false;	// to allow dogs to use bullet shield
	self.a.movement = "walk";

	animscripts\init::set_anim_playback_rate();

	self.suppressionThreshold = 1;
	self.disableArrivals = false;

	// MikeD (1/25/2008): We do not have Flash Grenades in CoD5, maybe we can use this technique for smoke?
	//self thread animscripts\combat_utility::monitorFlash();

	self.pathEnemyFightDist = 512;
	self setTalkToSpecies( "dog" );
	
	self.health = int( anim.dog_health * self.health );
}

change_anim_set( animset )
{
	//assert( animset == "shepherd" || animset == "zombie" );
	//self.animSet = animset;
	self.stopAnimDistSq = anim.dogAnims[self.animSet].dogStoppingDistSq;
}

setMeleeAttackDist()
{
	self endon( "death" );

	while ( 1 )
	{
		if ( isdefined( self.enemy ) && IsPlayer(self.enemy) )
		{
			self.meleeAttackDist = anim.dogAnims[self.animSet].dogAttackPlayerDist;
		}
		else
		{
			//self.meleeAttackDist = 102;
			self.meleeAttackDist = anim.dogAttackAIDist;
		}

		self waittill( "enemy" );
	}
}

initDogAnimations()
{
	if ( !isdefined( level.dogsInitialized ) )
	{
		level.dogsInitialized = true;
		precachestring( &"SCRIPT_PLATFORM_DOG_DEATH_DO_NOTHING" );
		precachestring( &"SCRIPT_PLATFORM_DOG_DEATH_TOO_LATE" );
		precachestring( &"SCRIPT_PLATFORM_DOG_DEATH_TOO_SOON" );
		precachestring( &"SCRIPT_PLATFORM_DOG_HINT" );		
	}
	
	// Initialization that should happen once per level
	if ( isDefined (anim.NotFirstTimeDogs) ) // Use this to trigger the first init
		return;

	anim.NotFirstTimeDogs = 1;
		
	// Dog start move animations
	// number indexes correspond to keyboard number directions
	anim.dogStartMoveAngles[8] = 0;
	anim.dogStartMoveAngles[6] = 90;
	anim.dogStartMoveAngles[4] = -90;
	anim.dogStartMoveAngles[3] = 180;
	anim.dogStartMoveAngles[1] = -180;
	
	initZombieDogAnimations();
	
	offset = getstartorigin( (0, 0, 0), (0, 0, 0), %german_shepherd_attack_AI_01_start_a );
	anim.dogAttackAIDist = length( offset );

	// effects used by dog
	level._effect[ "dog_bite_blood" ] = loadfx( "impacts/fx_deathfx_bloodpool_view" );
	level._effect[ "deathfx_bloodpool" ] = loadfx( "impacts/fx_deathfx_dogbite" );
	
	// setup random timings for dogs attacking the player
	slices = 5;
	array = [];
	for ( i = 0; i <= slices; i++ )
	{
		array[ array.size ] = i / slices;
	}

	level.dog_melee_index = 0;
	level.dog_melee_timing_array = maps\_utility::array_randomize( array );
	
	level.lastDogMeleePlayerTime = 0;
	level.dogMeleePlayerCounter = 0;
	
	setdvar( "friendlySaveFromDog", "0" );
}

calcAnimLengthVariables(animset)
{
	anim.dogAnims[animset].dogStoppingDistSq = lengthSquared( getmovedelta( anim.dogAnims[animset].move["run_stop"], 0, 1 ) * 1.2 ) ;
	anim.dogAnims[animset].dogStartMoveDist = length( getmovedelta( anim.dogAnims[animset].move["run_start"], 0, 1 ) );
}

initZombieDogAnimations()
{
	anim.dogAnims["zombie"] = spawnstruct();

	anim.dogAnims["zombie"].lookKnob[2] = %zombie_dog_look_2;
	anim.dogAnims["zombie"].lookKnob[4] = %zombie_dog_look_4;
	anim.dogAnims["zombie"].lookKnob[6] = %zombie_dog_look_6;
	anim.dogAnims["zombie"].lookKnob[8] = %zombie_dog_look_8;	

	anim.dogAnims["zombie"].traverse = [];
	anim.dogAnims["zombie"].traverse["wallhop"]		= %zombie_dog_run_jump_40;
	anim.dogAnims["zombie"].traverse[ "window_40" ]		 = %zombie_dog_run_jump_window_40;
	anim.dogAnims["zombie"].traverse["jump_down_40"]	= %zombie_dog_traverse_down_40;
	anim.dogAnims["zombie"].traverse["jump_down_190"]	= %zombie_dog_traverse_down_190;
	anim.dogAnims["zombie"].traverse["jump_down_120"]	= %zombie_dog_traverse_down_126;
	anim.dogAnims["zombie"].traverse["jump_up_40"]		= %zombie_dog_traverse_up_40;
	anim.dogAnims["zombie"].traverse[ "jump_up_80" ]		 = %zombie_dog_traverse_up_80;

	anim.dogAnims["zombie"].look["attackIdle"][2] = %zombie_dog_attack_look_down;
	anim.dogAnims["zombie"].look["attackIdle"][4] = %zombie_dog_attack_look_left;
	anim.dogAnims["zombie"].look["attackIdle"][6] = %zombie_dog_attack_look_right;
	anim.dogAnims["zombie"].look["attackIdle"][8] = %zombie_dog_attack_look_up;	

	anim.dogAnims["zombie"].look["normal"][2] = %zombie_dog_look_down;
	anim.dogAnims["zombie"].look["normal"][4] = %zombie_dog_look_left;
	anim.dogAnims["zombie"].look["normal"][6] = %zombie_dog_look_right;
	anim.dogAnims["zombie"].look["normal"][8] = %zombie_dog_look_up;

	anim.dogAnims["zombie"].pain["pain"][2] = %zombie_dog_pain_hit_front;
	anim.dogAnims["zombie"].pain["pain"][4] = %zombie_dog_pain_hit_left;
	anim.dogAnims["zombie"].pain["pain"][6] = %zombie_dog_pain_hit_right;
	anim.dogAnims["zombie"].pain["pain"][8] = %zombie_dog_pain_hit_back;
	anim.dogAnims["zombie"].pain["pain_run"][2] = %zombie_dog_run_pain_front;
	anim.dogAnims["zombie"].pain["pain_run"][4] = %zombie_dog_run_pain_front;
	anim.dogAnims["zombie"].pain["pain_run"][6] = %zombie_dog_run_pain_front;
	anim.dogAnims["zombie"].pain["pain_run"][8] = %zombie_dog_run_pain_front;

	anim.dogAnims["zombie"].death[2] = %zombie_dog_death_front;
	anim.dogAnims["zombie"].death[4] = %zombie_dog_death_hit_left;
	anim.dogAnims["zombie"].death[6] = %zombie_dog_death_hit_right;
	anim.dogAnims["zombie"].death[8] = %zombie_dog_death_hit_back;

	anim.dogAnims["zombie"].turn["90_left"] = %zombie_dog_turn_90_left;
	anim.dogAnims["zombie"].turn["90_right"] = %zombie_dog_turn_90_right;
	anim.dogAnims["zombie"].turn["180_left"] = %zombie_dog_turn_180_left;
	anim.dogAnims["zombie"].turn["180_right"] = %zombie_dog_turn_180_right;
	anim.dogAnims["zombie"].turn["turn_knob"] = %zombie_dog_turn_knob;

	anim.dogAnims["zombie"].runTurn["90_left"] = %zombie_dog_run_turn_90_left;
	anim.dogAnims["zombie"].runTurn["90_right"] = %zombie_dog_run_turn_90_right;
	anim.dogAnims["zombie"].runTurn["180_left"] = %zombie_dog_run_turn_180_left;
	anim.dogAnims["zombie"].runTurn["180_right"] = %zombie_dog_run_turn_180_right;

	anim.dogAnims["zombie"].combatIdle["attackidle"] = %zombie_dog_attackidle;
	anim.dogAnims["zombie"].combatIdle["attackidle_bark"] = %zombie_dog_attackidle_bark;
	anim.dogAnims["zombie"].combatIdle["attackidle_growl"] = %zombie_dog_attackidle_growl;

	anim.dogAnims["zombie"].idle = %zombie_dog_idle;

	anim.dogAnims["zombie"].attack["attackidle_knob"] = %zombie_dog_attackidle_knob;
	anim.dogAnims["zombie"].attack["attack_player_miss"] = %zombie_dog_run_attack_miss;
	anim.dogAnims["zombie"].attack["attack_player_miss_turnR"] = %zombie_dog_attack_player_miss_turnR;
	anim.dogAnims["zombie"].attack["attack_player_miss_turnL"] = %zombie_dog_attack_player_miss_turnL;
	anim.dogAnims["zombie"].attack["run_attack"] = %zombie_dog_run_attack;
	anim.dogAnims["zombie"].attack["attack_player_late"] = %zd_attack_player_late;

	anim.dogAnims["zombie"].move["run_attack_low"] = %zombie_dog_run_attack_low;
	anim.dogAnims["zombie"].move["run_stop"] = %zombie_dog_run_stop;
	anim.dogAnims["zombie"].move["run_start"] = %zombie_dog_run;
	anim.dogAnims["zombie"].move["run_start_knob"] = %zombie_dog_run;
	anim.dogAnims["zombie"].move["run"] = %zombie_dog_run;
	anim.dogAnims["zombie"].move["run_lean_L"] = %zombie_dog_run_lean_l;
	anim.dogAnims["zombie"].move["run_lean_R"] = %zombie_dog_run_lean_r;
	anim.dogAnims["zombie"].move["run_knob"] = %zombie_dog_run_knob;
	anim.dogAnims["zombie"].move["walk"] = %zombie_dog_trot;

	calcAnimLengthVariables("zombie");

	anim.dogAnims["zombie"].dogAttackPlayerDist = 64;
}
