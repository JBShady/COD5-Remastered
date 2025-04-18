#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;


/*------------------------------------
BOUNCING BETTY STUFFS - 
a rough prototype for now, needs a bit more polish

------------------------------------*/
purchase_bouncing_betties()
{
	trigs = getentarray("betty_purchase","targetname");
	for(i=0; i<trigs.size; i++)
	{
		model = getent( trigs[i].target, "targetname" ); 
		model hide(); 
	}

	array_thread(trigs,::buy_bouncing_betties);

	level thread give_betties_after_rounds();
	level thread update_betty_fires();
	level thread set_betty_visible();

}

buy_bouncing_betties()
{
	self.zombie_cost = 1000;
	self UseTriggerRequireLookAt(); // new
	self sethintstring( &"REMASTERED_ZOMBIE_BETTY_PURCHASE" );	
	self setCursorHint( "HINT_NOICON" );

	self.betties_triggered = false;

	while(1)
	{
		self waittill("trigger",who);
		if( who in_revive_trigger() || level.falling_down == true )
		{
			continue;
		}

		if( is_player_valid( who ) )
		{
			if( !who maps\_zombiemode_weapons_sumpf::can_buy_weapon() )
			{
				wait( 0.1 );
				continue;
			}

			if( who.score >= self.zombie_cost )
			{				
				if(!isDefined(who.has_betties))
				{
					who.has_betties = 1;
					play_sound_at_pos( "purchase", self.origin );

					//set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 
					who thread bouncing_betty_setup();
					who thread show_betty_hint("betty_purchased");

					// JMA - display the bouncing betties
					if( self.betties_triggered == false )
					{						
						model = getent( self.target, "targetname" ); 					
						model thread maps\_zombiemode_weapons::weapon_show( who ); 
						self.betties_triggered = true;
					}

					trigs = getentarray("betty_purchase","targetname");
					for(i = 0; i < trigs.size; i++)
					{
						trigs[i] SetInvisibleToPlayer(who);
					}
				}
				else
				{
					//who thread show_betty_hint("already_purchased");

				}
			}
			else if ( who.score < self.zombie_cost ) // new
			{	
				who play_sound_on_ent( "no_purchase" );
				who thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
			}
		}
	}
}

set_betty_visible()
{
	players = getplayers();	
	trigs = getentarray("betty_purchase","targetname");

	while(1)
	{
		for(j = 0; j < players.size; j++)
		{
			if( !isdefined(players[j].has_betties))
			{						
				for(i = 0; i < trigs.size; i++)
				{
					trigs[i] SetInvisibleToPlayer(players[j], false);
				}
			}
		}

		wait(1);
		players = getplayers();	
	}
}

bouncing_betty_watch() // does not try to end on death, stays running forever now
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 

	while(1)
	{

		self waittill("grenade_fire",betty,weapname);
		if(weapname == "mine_bouncing_betty")
		{
			betty.owner = self;
			betty thread betty_think(self);
			betty thread betty_death_think(); // why is this self, what is this function doing
		}
	}
}

betty_death_think()
{
	self waittill("death");

	if(isDefined(self.trigger))
	{
		self.trigger delete();
	}

	self delete();

}

bouncing_betty_setup()
{	
	// These two functions are threaded on spawn now. Endon("death") doesn't seem to actually end these functions, after we respawn they are still running
	// Thus, we should not thread every time we purchase or else players who have respawned will then have multiple betty threads running, which is unnecssary and leads to bugs
	//self thread bouncing_betty_watch();
	//self thread betty_no_weapons();

	self giveweapon("mine_bouncing_betty");
	self setactionslot(4,"weapon","mine_bouncing_betty");
	self setweaponammostock("mine_bouncing_betty",5);
}

betty_no_weapons() // does not try to end on death, stays running forever now
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 

	while(1)
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size == 0 && self getAmmoCount("mine_bouncing_betty") == 0 )
		{
			self takeweapon("mine_bouncing_betty");
		}
		wait(0.05);
	}
}

betty_think(player)
{
	wait(1); // wait is first, we do not do anything until it passes. this also ensures that the betty has been fully planted on the ground before setting up parameters

	if(!isdefined(player.mines))
	{
		player.mines = [];
	}
	
	player.mines = array_add( player.mines, self );

	//player iprintlnbold("Betties placed: ", player.mines.size);

	trigger = spawn("trigger_radius",self.origin,9,80,64); // why are there 9 flags set on spawn?
	self.trigger = trigger;

	if(player.mines.size <= 30)
	{
		while(1)
		{
			trigger waittill( "trigger", ent );

			if(player.mines.size > 30)
			{
				break;
			}

			if ( isdefined( player ) && ent == player )
			{
				continue;
			}

			if ( ent damageConeTrace(self.origin, self) == 0 )
			{
				continue;
			}

			break;
		}
	}

	wait_to_fire_betty(); //new, prevents crashing from betty spam, exploding all at once
	
    if(is_in_array(player.mines,self))
    {
    	if(player.mines.size == 1) // if we have worked our way down to just 1 betty on the map
    	{
    		player.mines = []; // lets reset because trying to remove last item from array
    	}
    	else // otherwise just remove 1
    	{
	        player.mines = array_remove_nokeys(player.mines,self);
    	}
    }

	if( isdefined( trigger ) ) // delete trigger as soon as we know it is actually triggered
	{
		trigger delete();
	}

	self playsound("betty_activated");
	wait(.1);	
	fake_model = spawn("script_model",self.origin);
	fake_model setmodel(self.model);
	self hide();
	tag_origin = spawn("script_model",self.origin);
	tag_origin setmodel("tag_origin");
	tag_origin linkto(fake_model);
	playfxontag(level._effect["betty_trail"], tag_origin,"tag_origin");
	fake_model moveto (fake_model.origin + (0,0,32),.2);
	fake_model waittill("movedone");
	playfx(level._effect["betty_explode"], fake_model.origin);
	earthquake(1, .4, fake_model.origin, 512);

	//CHris_P - betties do no damage to the players
	zombs = getaispeciesarray("axis");
	for(i=0;i<zombs.size;i++)
	{
		//PI ESM: added a z check so that it doesn't kill zombies up or down one floor
		if(zombs[i].origin[2] < fake_model.origin[2] + 80 && zombs[i].origin[2] > fake_model.origin[2] - 80 && DistanceSquared(zombs[i].origin, fake_model.origin) < 200 * 200)
		{
			zombs[i] thread maps\_zombiemode_spawner::zombie_damage( "MOD_ZOMBIE_BETTY", "none", zombs[i].origin, self.owner );
		}
	}
	//radiusdamage(self.origin,128,1000,75,self.owner);

	if( isdefined( fake_model ) )
	{
		fake_model delete();
	}
	if( isdefined( tag_origin ) )
	{
		tag_origin delete();
	}
	if( isdefined( self ) )
	{
		self delete();
	}
	//player iprintlnbold("Betties left: ", player.mines.size);

}

betty_smoke_trail()
{
	self.tag_origin = spawn("script_model",self.origin);
	self.tag_origin setmodel("tag_origin");
	playfxontag(level._effect["betty_trail"],self.tag_origin,"tag_origin");
	self.tag_origin moveto(self.tag_origin.origin + (0,0,100),.15);
}

give_betties_after_rounds()
{
	while(1)
	{
		level waittill( "between_round_over" );
		{
			players = get_players();
			for(i=0;i<players.size;i++)
			{
				if(isDefined(players[i].has_betties) && !players[i] maps\_laststand::player_is_in_laststand() )
				{
					players[i]  giveweapon("mine_bouncing_betty");
					players[i]  setactionslot(4,"weapon","mine_bouncing_betty");
					players[i]  setweaponammoclip("mine_bouncing_betty",2);
				}
			}
		}
	}
}

//betty hint stuff
init_hint_hudelem(x, y, alignX, alignY, fontscale, alpha)
{
	self.x = x;
	self.y = y;
	self.alignX = alignX;
	self.alignY = alignY;
	self.fontScale = fontScale;
	self.alpha = alpha;
	self.sort = 20;
	//self.font = "objective";
}

setup_client_hintelem()
{
	self endon("death");
	self endon("disconnect");

	if(!isDefined(self.hintelem))
	{
		self.hintelem = newclienthudelem(self);
	}
	self.hintelem init_hint_hudelem(320, 220, "center", "bottom", 1.3, 1.0);
}


show_betty_hint(string)
{
	self endon("death");
	self endon("disconnect");

	if(string == "betty_purchased")
		text = &"REMASTERED_ZOMBIE_BETTY_HOWTO";
	else
		text = &"ZOMBIE_BETTY_ALREADY_PURCHASED";

	self setup_client_hintelem();
	self.hintelem setText(text);
	wait(3.5);
	self.hintelem settext("");
	self.hintelem destroy();
	self.hintelem delete();
}

update_betty_fires()
{
	while(true)
	{
		level.hasBettyFiredRecently = 0;
		wait_network_frame();
	}
}

wait_to_fire_betty()
{
	while(level.hasBettyFiredRecently >= 4)
	{
		wait_network_frame();
	}

	level.hasBettyFiredRecently++;
}