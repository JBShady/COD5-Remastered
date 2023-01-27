#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	precacheShader( "zombie_stopwatchneedle" );
	precacheShader( "zombie_stopwatch" );
	precacheShader( "zombie_stopwatch_glass" );
	
	if( !isDefined( level.stopwatch_length_width ) )
	{
		level.stopwatch_length_width = 96;
	}
}

start_timer( time, stop_notify )
{
	self notify ("stop_prev_timer");
	self endon ("stop_prev_timer");

	if( !isDefined( self.stopwatch_elem ) )
	{
		self.stopwatch_elem = newClientHudElem(self);
		self.stopwatch_elem.horzAlign = "left";
		self.stopwatch_elem.vertAlign = "top";
		self.stopwatch_elem.alignX = "left";
		self.stopwatch_elem.alignY = "top";
		self.stopwatch_elem.x = 10;
		self.stopwatch_elem.y = 20;
		self.stopwatch_elem.alpha = 0;
		self.stopwatch_elem.sort = 2;
		
		self.stopwatch_elem_glass = newClientHudElem(self);
		self.stopwatch_elem_glass.horzAlign = "left";
		self.stopwatch_elem_glass.vertAlign = "top";
		self.stopwatch_elem_glass.alignX = "left";
		self.stopwatch_elem_glass.alignY = "top";
		self.stopwatch_elem_glass.x = 10;
		self.stopwatch_elem_glass.y = 20;
		self.stopwatch_elem_glass.alpha = 0;
		self.stopwatch_elem_glass.sort = 3;
		self.stopwatch_elem_glass setShader( "zombie_stopwatch_glass", level.stopwatch_length_width, level.stopwatch_length_width );
	}

	if( isDefined( stop_notify ) )
	{
		self thread wait_for_stop_notify( stop_notify );
	}
	if( time > 60 )
	{
		time = 0;
	}
	self.stopwatch_elem setClock( time, 60, "zombie_stopwatch", level.stopwatch_length_width, level.stopwatch_length_width );
	self.stopwatch_elem.alpha = 1;
	self.stopwatch_elem_glass.alpha = 1;
	wait( time );
	self notify( "countdown_finished" );
	wait( 1 );
	self.stopwatch_elem.alpha = 0;
	self.stopwatch_elem_glass.alpha = 0;
	
}

wait_for_stop_notify( stop_notify )
{
	self endon ("stop_prev_timer");
	self endon( "countdown_finished" );
	
	self waittill( stop_notify );
	
	self.stopwatch_elem.alpha = 0;
	self.stopwatch_elem_glass.alpha = 0;
}
