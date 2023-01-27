#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

init()
{
    zombie_double_doors = GetEntArray( "zombie_double_door", "targetname" );
    
    for( i = 0; i < zombie_double_doors.size; i++ )
	{
		zombie_double_doors[i] thread double_door_init(); 
	}
	
	level thread dog_clip_watcher();
}

double_door_init()
{
    hinges = GetEntArray( self.target, "targetname" );
    doors = GetEntArray( self.target + "_door", "targetname" );
    
    if( isDefined(self.script_flag) && !IsDefined( level.flag[self.script_flag] ) ) 
	{
		flag_init( self.script_flag ); 
	}
	
	self.hinges = [];
	for( i = 0; i < hinges.size; i++)
	{
        if(hinges[i].script_noteworthy == "clip")
        {
            self.clip = hinges[i];
            continue;
        }
        
        for( j = 0; j < doors.size; j++)
        {
            if(doors[j].script_noteworthy == hinges[i].script_noteworthy)
            {
                doors[j] linkto(hinges[i]);
                doors[j] disconnectpaths();
            }
        }
        self.hinges[(self.hinges).size] = hinges[i];    
    }
    self.doors = doors;
	
	cost = 1000;
	if( IsDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	
	self set_hint_string( self, "default_buy_door_" + cost );
	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();

	self thread double_door_think();
}

double_door_think()
{
    while(1)
    {
        self waittill( "trigger", who );
        
        if( !who UseButtonPressed() )
		{
			continue;
		}

		if( who in_revive_trigger() )
		{
			continue;
		}
		
		if( is_player_valid( who ) )
		{
			if( who.score >= self.zombie_cost )
			{
				// set the score
				who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
                
                for( i = 0; i < (self.doors).size; i++)
                {
                    self.doors[i] connectpaths();
                    playsoundatposition( "door_rotate_open", self.doors[i].origin );
                }
                
                play_sound_at_pos( "purchase", self.doors[0].origin );
                
                for( i = 0; i < (self.hinges).size; i++)
                {
                    struct = getstruct(self.hinges[i].script_linkto, "script_linkname");
                    self.hinges[i] thread swing_door(struct);
                }
                
                if( IsDefined( self.script_flag ) )
				{
					flag_set( self.script_flag );
				}
				
				all_trigs = getentarray( self.target, "target" ); 
				for( i = 0; i < all_trigs.size; i++ )
				{
					all_trigs[i] delete(); 
				}
				
				if(isdefined(self.clip))
				{
                    self.clip delete();
                }
				
				break;
		    }
		    else // Not enough money
			{
				playsoundatposition( "no_purchase_door", self.doors[0].origin );
				who thread play_no_money_purchase_dialog();
			}
		}
    }
}
play_no_money_purchase_dialog()
{
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	
	player_index = "plr_" + index + "_";
	if(!IsDefined (self.vox_gen_sigh))
	{
		num_variants = maps\_zombiemode_spawner::get_number_variants(player_index + "vox_gen_sigh");
		self.vox_gen_sigh = [];
		for(i=0;i<num_variants;i++)
		{
			self.vox_gen_sigh[self.vox_gen_sigh.size] = "vox_gen_sigh_" + i;	
		}
		self.vox_gen_sigh_available = self.vox_gen_sigh;		
	}
	rand = randomintrange(0,6);
	if(rand < 3)
	{
		sound_to_play = random(self.vox_gen_sigh_available);		
		self.vox_gen_sigh_available = array_remove(self.vox_gen_sigh_available,sound_to_play);
		if (self.vox_gen_sigh_available.size < 1 )
		{
			self.vox_gen_sigh_available = self.vox_gen_sigh;
		}
		wait(0.25);
		self maps\_zombiemode_spawner::do_player_playdialog(player_index, sound_to_play, 0.25);
	}
	
		
	
}
swing_door(struct)
{
    time = 0.5;
	if( IsDefined( self.script_transition_time ) )
	{
		time = self.script_transition_time; 
	}
	
	self MoveTo( struct.origin, time, time * 0.5 );
	self RotateTo( struct.angles, time * 0.75 );

    self waittill( "movedone" );
    
    self delete();
}

dog_clip_watcher()
{
    zombie_dog_clip = [];
    zombie_dog_clip = getentarray("zombie_dog_clip", "targetname");
    
    while(1)
    {
        for( i = 0; i < zombie_dog_clip.size; i++)
        {
            zombie_dog_clip[i] notsolid();
            zombie_dog_clip[i] connectpaths();
        }
        
        level waittill("dog_round_starting");
        
        for( i = 0; i < zombie_dog_clip.size; i++)
        {
            zombie_dog_clip[i] solid();
            zombie_dog_clip[i] disconnectpaths();
            zombie_dog_clip[i] notsolid();
        }
        
        level waittill("dog_round_ending");
    }
}