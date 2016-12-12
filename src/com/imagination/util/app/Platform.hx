package com.imagination.util.app;

/**
 * ...
 * @author Thomas Byrne
 */
#if html5
typedef RealPlatform = BrowserPlatform;
#else
typedef RealPlatform = DesktopPlatform;
#end

class Platform
{
	public static function isWindows():Bool 
	{
		return RealPlatform.isWindows();
	}
	
	public static function isMac():Bool 
	{
		return RealPlatform.isMac();
	}
	
	public static function isMobile():Bool 
	{
		return RealPlatform.isMobile();
	}
}