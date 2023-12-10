#include maps\_hud_util;
#include maps\_utility; 

init()
{
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );
		player thread initNotifyMessage();
	}
}

initNotifyMessage()
{

	titleSize = 2.5;
	textSize = 1.75;
	iconSize = 30;
	font = "objective";
	point = "TOP";
	relativePoint = "BOTTOM";
	yOffset = 35;
	xOffset = 0;

	
	// CODER_MOD - BNANDAKUMAR (7/16/08): Added the player as the 4th argument to make sure the hudelem is created only for that player alone
	self.notifyTitle = createFontString( font, titleSize, self );
	self.notifyTitle setPoint( point, undefined, xOffset, yOffset );
	self.notifyTitle.glowAlpha = 1;
	self.notifyTitle.hideWhenInMenu = true;
	self.notifyTitle.archived = false;
	self.notifyTitle.alpha = 0;

	// CODER_MOD - BNANDAKUMAR (7/16/08): Added the player as the 4th argument to make sure the hudelem is created only for that player alone
	self.notifyText = createFontString( font, textSize, self );
	self.notifyText setParent( self.notifyTitle );
	self.notifyText setPoint( point, relativePoint, 0, 0 );
	self.notifyText.glowAlpha = 1;
	self.notifyText.hideWhenInMenu = true;
	self.notifyText.archived = false;
	self.notifyText.alpha = 0;

	// CODER_MOD - BNANDAKUMAR (7/16/08): Added the player as the 4th argument to make sure the hudelem is created only for that player alone
	self.notifyText2 = createFontString( font, textSize, self );
	self.notifyText2 setParent( self.notifyTitle );
	self.notifyText2 setPoint( point, relativePoint, 0, 0 );
	//self.notifyText2.glowColor = (0.2, 0.3, 0.7);
	self.notifyText2.glowAlpha = 1;
	self.notifyText2.hideWhenInMenu = true;
	self.notifyText2.archived = false;
	self.notifyText2.alpha = 0;

	// CODER_MOD - BNANDAKUMAR (7/16/08): Added the player as the 4th argument to make sure the hudelem is created only for that player alone
	self.notifyIcon = createIcon( "white", iconSize, iconSize, self );
	self.notifyIcon setParent( self.notifyText2 );
	self.notifyIcon setPoint( point, relativePoint, 0, 0 );
	self.notifyIcon.hideWhenInMenu = true;
	self.notifyIcon.archived = false;
	self.notifyIcon.alpha = 0;

	self.doingNotify = false;
	self.notifyQueue = [];
}

notifyMessage( notifyData )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	if ( !self.doingNotify )
	{
		self thread showNotifyMessage( notifyData );
		return;
	}
	
	self.notifyQueue[ self.notifyQueue.size ] = notifyData;
}


showNotifyMessage( notifyData )
{
	self endon("disconnect");
	
	self.doingNotify = true;

	if ( isDefined( notifyData.duration ) )
		duration = notifyData.duration;
	else
		duration = 4.0;
	

	if ( isDefined( notifyData.sound ) )
		self playLocalSound( notifyData.sound );

	//if ( isDefined( notifyData.leaderSound ) )
	//	self maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( notifyData.leaderSound );
	
	if ( isDefined( notifyData.glowColor ) )
		glowColor = notifyData.glowColor;
	else
		glowColor = (0.0, 0.0, 0.0);

	anchorElem = self.notifyTitle;

	if ( isDefined( notifyData.titleText ) )
	{
		if ( isDefined( notifyData.titleLabel ) )
			self.notifyTitle.label = notifyData.titleLabel;
		else
			self.notifyTitle.label = &"";

		if ( isDefined( notifyData.titleLabel ) && !isDefined( notifyData.titleIsString ) )
			self.notifyTitle setValue( notifyData.titleText );
		else
			self.notifyTitle setText( notifyData.titleText );
		
		self.notifyTitle setPulseFX( 100, int(duration*1000), 1000 );
		self.notifyTitle.glowColor = glowColor;	
		self.notifyTitle.alpha = 1;
/*		
		self.notifyTitle.alpha = 0;
		self.notifyTitle fadeOverTime( 1.25 );
		self.notifyTitle.alpha = 1;
*/
		self thread titleText(notifyData, glowColor, duration); //forces a fade
	}

	if ( isDefined( notifyData.notifyText ) )
	{
		if ( isDefined( notifyData.textLabel ) )
			self.notifyText.label = notifyData.textLabel;
		else
			self.notifyText.label = &"";

		if ( isDefined( notifyData.textLabel ) && !isDefined( notifyData.textIsString ) )
			self.notifyText setValue( notifyData.notifyText );
		else
			self.notifyText setText( notifyData.notifyText );
		self.notifyText setPulseFX( 100, int(duration*1000), 1000 );
		self.notifyText.glowColor = glowColor;	
		self.notifyText.alpha = 1;
/*		
		self.notifyText.alpha = 0;
		self.notifyText fadeOverTime( 1.25 );
		self.notifyText.alpha = 1;
*/
		self thread notifyText(notifyData, glowColor, duration); //forces a fade
		anchorElem = self.notifyText;
	}

	if ( isDefined( notifyData.notifyText2 ) ) //dummy text just for extra space
	{

		self.notifyText2 setParent( anchorElem );
		
		if ( isDefined( notifyData.text2Label ) )
			self.notifyText2.label = notifyData.text2Label;
		else
			self.notifyText2.label = &"";

		if ( isDefined( notifyData.text2Label ) && !isDefined( notifyData.textIsString ) )
			self.notifyText2 setValue( notifyData.notifyText2 );
		else
			self.notifyText2 setText( notifyData.notifyText2 );

		self.notifyText2 setText( notifyData.notifyText2 );
		//self.notifyText2 setPulseFX( 100, int(duration*1000), 1000 );
		//self.notifyText2.glowColor = glowColor;	
		self.notifyText2.alpha = 1;
		anchorElem = self.notifyText2;
	}

	if ( isDefined( notifyData.iconName ) )
	{
		self.notifyIcon setParent( anchorElem );
		self.notifyIcon setShader( notifyData.iconName, 60, 60 );
		self.notifyIcon.foreground = true;
		self.notifyIcon.alpha = 0;
		self.notifyIcon fadeOverTime( 1.25 );
		self.notifyIcon.alpha = 1;

		wait(duration);

		self.notifyIcon fadeOverTime( 0.75 );
		self.notifyIcon.alpha = 0;
	}

	//self notify ( "notifyMessageDone" );
	self.doingNotify = false;

	if ( self.notifyQueue.size > 0 )
	{
		nextNotifyData = self.notifyQueue[0];
		
		newQueue = [];
		for ( i = 1; i < self.notifyQueue.size; i++ )
			self.notifyQueue[i-1] = self.notifyQueue[i];
		self.notifyQueue[i-1] = undefined;
		wait(2);
		self thread showNotifyMessage( nextNotifyData );
	}
}


titleText(notifyData, glowColor, duration)
{
	wait(duration);

	self.notifyTitle fadeOverTime( 0.75 );
	self.notifyTitle.alpha = 0;
}

notifyText(notifyData, glowColor, duration)
{
	wait(duration);

	self.notifyText fadeOverTime( 0.75 );
	self.notifyText.alpha = 0;
}