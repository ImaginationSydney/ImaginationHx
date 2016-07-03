package com.imagination.util.sys;
import com.imagination.util.app.App;
import com.imagination.util.fs.File;


/**
 * ...
 * @author Thomas Byrne
 */
#if flash


	import flash.system.Capabilities;

	class SysTools
	{
		@:isVar public static var systemName(get, null):String;
		public static function get_systemName():String
		{
			if (systemName == null) {
				var os = Capabilities.os;
				if (os.indexOf("Windows") != -1) {
					systemName = SystemName.WINDOWS;
					
				}else if (os.indexOf("Linux") != -1) {
					systemName = SystemName.LINUX;
					
				}else if (os.indexOf("Android") != -1) {
					systemName = SystemName.ANDROID;
					
				}else if (os.indexOf("iPhone") != -1 || os.indexOf("iPad") != -1 || os.indexOf("iPod") != -1) {
					systemName = SystemName.IOS;
					
				}else if (os.indexOf("Mac") != -1) {
					systemName = SystemName.MAC;
					
				}else if (os.indexOf("BSD") != -1) { // This won't ever really match as flash doesn't run on BSD
					systemName = SystemName.BSD;
					
				}
			}
			return systemName;
		}
		
		@:isVar public static var executablePath(get, null):String;
		public static function get_executablePath():String
		{
			if (executablePath == null) {
				executablePath = File.applicationDirectory.nativePath + "/" + App.getAppFilename();
				if (SysTools.systemName == SystemName.WINDOWS) {
					executablePath += ".exe";
				}
			}
			return executablePath;
		}
	}
	
	
#elseif sys


	typedef SysTools = Sys;
	
	
#end


class SystemName
{
	public static var WINDOWS:String = "Windows";
	public static var LINUX:String = "Linux";
	public static var BSD:String = "BSD";
	public static var MAC:String = "Mac";
	
	// Not standard haxe
	public static var ANDROID:String = "Android";
	public static var IOS:String = "iOS";
}