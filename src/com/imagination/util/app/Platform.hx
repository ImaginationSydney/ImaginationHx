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
	public static function systemName() : SystemName
	{
		#if js
			return null;
		#else
			return RealPlatform.systemName();
		#end
	}
	public static function systemVersion() : String
	{
		#if js
			return null;
		#else
			return RealPlatform.systemVersion();
		#end
	}
	public static function userAgent() : String
	{
		#if js
			return RealPlatform.userAgent();
		#else
			return null;
		#end
	}
	
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
	
	public static function is64Bit():Bool 
	{
		#if html5
			return false;
		#else
			return RealPlatform.is64Bit();
		#end
	}
}

@:enum
abstract SystemName(String) to String
{
	var Windows = "Windows";
	var Mac = "Mac";
	var Linux = "Linux";
	var Other = "Other";
}