#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
/*
#include maps\_zombiemode_net;
/*
/*------------------------------------
JBird632's Zombie sticky
Version 1.0
------------------------------------*/

init()
{
	level thread sticky_on_player_connect(); 
}

sticky_on_player_connect()
{
		iPrintLnBold ( "test!");

	for( ;; )
	{
		level waittill( "connecting", player ); 
		iPrintLnBold ( "Grenade thrown!");

		player thread wait_for_sticky_fired(); 
	}
}

wait_for_sticky_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 
	
	for( ;; )
	{
		self waittill( "grenade_fire", gren, weap );
		if( weap == "st_grenade" )
		{
			self thread zomb_stick(gren);
		}
/*		if( weap == "bo_m67" )
		{
			self thread zom_hit(gren);
		}*/
	}
}

zomb_stick(sticky)
{
	PlayFXOnTag( level._effect["blink_grn"], sticky, "tag_fx" );
	velocitySq = 10000 * 10000;
	oldPos = sticky.origin;
	
	sticky_pos = [];
	while( velocitySq != 0 )
	{
		wait( 0.05 );
		velocitySq = distanceSquared( sticky.origin, oldPos );
		oldPos = sticky.origin;
		sticky_pos = array_add(sticky_pos, sticky.origin);
	}
	
	zom = GetAiSpeciesArray( "axis", "all" );
	index = -1;
	
	for(i=0;i<zom.size;i++)
	{
		ri_arm = zom[i] gettagorigin("j_elbow_ri");
		le_arm = zom[i] gettagorigin("j_elbow_le");
		if(distance2d(sticky.origin, zom[i].origin) < 20 || distance(sticky.origin, ri_arm) < 15 || distance(sticky.origin, le_arm) < 15)
		{
			index = i;
			break;
		}
	}
	
	sticky hide();
	spawnorig = sticky_pos[sticky_pos.size - 1];
	sticky_model = Spawn("script_model", spawnorig);
	sticky_model.angles = sticky.angles;
	sticky_model setModel("weapon_mp_sticky_grenade");
	sticky Delete();
	
	if(index != -1)
	{
		sticky_model EnableLinkTo();
		sticky_model LinkTo(zom[index], "J_MainRoot");
		zom[index] DoDamage( 10, zom[index].origin, self );
	}
	
	sticky_hud = undefined;
	count = 0;
	
	max_dist = 200;
	
	while(count < 2)
	{
		dist = Distance( self.origin, sticky_model.origin );
		
/*		if(dist < max_dist && !IsDefined(sticky_hud))
		{
			sticky_hud = newClientHudElem(self);
			sticky_hud SetTargetEnt( sticky_model );
			sticky_hud setShader( "hud_sticky", 4, 4 );
			sticky_hud setWaypoint( true,"hud_sticky");
		}
		else if(dist > max_dist && IsDefined(sticky_hud))
		{
			sticky_hud Destroy();
			sticky_hud = undefined;
		}*/
		
		if( count == 0.25 || count == 0.5 || count == 0.75 || count == 1 || count == 1.25 || count == 1.35 || count == 1.45 || count == 1.55 || count == 1.65 || count == 1.75 || count == 1.85 || count == 1.95 )
		{
			//PlayFXOnTag( level._effect["blink_grn"], sticky_model, "tag_fx" );
			//sticky_model playsound("sticky_alert");
		}
		
		count = count + 0.05;
		wait(0.05);
	}
	
/*	if(IsDefined(sticky_hud))
	{
		sticky_hud Destroy();
		sticky_hud = undefined;
	}*/
	
	earthquake(1, .4, sticky_model.origin, 512);
	
	sticky_model.owner = self;
	playfx(level._effect["betty_explode"], sticky_model.origin);
	radiusdamage(sticky_model.origin,256,300,75,sticky_model.owner, "MOD_GRENADE_SPLASH");

	//playsoundatposition("claymore_explode", sticky_model.origin);
	wait(.05);
	
	sticky_model Delete();
	
}

zom_hit(gren)
{
	velocitySq = 10000 * 10000;
	oldPos = gren.origin;
	
	zom = GetAiSpeciesArray( "axis", "all" );
	index = -1;
	
	while(1)
	{
		for(i=0;i<zom.size;i++)
		{
			if(gren IsTouching(zom[i]))
			{
				index = i;
				break;
			}
		}
		
		if(index >= 0)
			break;
	
		wait( 0.05 );
		velocitySq = distanceSquared( gren.origin, oldPos );
		oldPos = gren.origin;
	}
	
	if(	index != -1 && isdefined(gren))
	{
		zom[index] DoDamage( 10, zom[index].origin, self );
	}
}