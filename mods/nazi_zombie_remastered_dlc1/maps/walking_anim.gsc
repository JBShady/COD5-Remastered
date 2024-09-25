#include common_scripts\utility; 
#include maps\_utility;

main()
{	
	self thread walk_main();
	self thread rot_main();
	self thread prone_checks();
}

walk_main()
{
	self endon("disconnect");

	self SetClientDvar("cg_bobWeaponMax", 5);

	while(1)
	{
		if( self ADSButtonPressed())
		{
			self setClientDvar("cg_bobweaponamplitude", "0.16");	
			self setClientDvar("bg_bobAmplitudeStanding", "0.007 0.007");	
		}
		else
		{
			self setClientDvar("cg_bobweaponamplitude", "0.9");
			self setClientDvar("bg_bobAmplitudeStanding", "0.012 0.005");
		}
		wait(0.05);
	}
}

rot_main()
{
	self endon("disconnect");

	for(;;)
	{
		roll = self GetVelocity() * anglestoright(self GetPlayerAngles());
		roll = roll/28;

		self SetClientDvar("cg_gun_rot_r",roll[0]+roll[1]+roll[2]);

		wait(0.05);
	}
}

prone_checks()
{
	self endon("disconnect");
	
	self SetClientDvar("bg_bobAmplitudeProne", "0.08 0.04");

	if(getDvarInt( "cg_lowerGun" ) == 1 && GetPlayers().size == 1 )
	{
		self SetClientDvar("cg_gun_move_minspeed", 0);
		return;
	}

	while(1)
	{
		if( self GetStance() == "prone" || self GetStance() == "crouch" )
		{
			self SetClientDvar("cg_gun_move_minspeed", 0);
		}
		else
		{
			self SetClientDvar("cg_gun_move_minspeed", 100000);
		}
		wait(0.1);
	}
}
