package com.imagination.util.fs;
import com.imagination.util.app.App;
import com.imagination.util.app.Platform;

/**
 * ...
 * @author Thomas Byrne
 */

#if !html5
class Files
{
	
	public static function documentsDir():String 
	{
		return File.documentsDirectory.nativePath + "/";
	}
	
	public static function applicationDir():String 
	{
		return File.applicationDirectory.nativePath + "/";
	}

	public static function appDocsDir(?appId:String):String 
	{
		
		#if sys
		
		var path:String = Sys.executablePath();
		var ind:Int;
		if (_isWindows) {
			ind = path.lastIndexOf("\\");
		}else {
			ind = path.lastIndexOf("/");
		}
		return path.substr(0, ind + 1);
		
		#elseif air3
		
		if (appId == null) appId = App.getAppId();
		return documentsDir() + "imagination/" + appId + "/";
		
		#end
	}

	public static function globalDocsDir():String 
	{
		return documentsDir() + "imagination/_global/";
	}

	public static function getTempFilePath():String 
	{
		#if sys
		var ret:String = null;
		while (ret==null || sys.FileSystem.exists(ret)) {
			ret = appDocsDir() + "temp_" + (Math.random() * 10000000) + ".tmp";
		}
		return ret;
		
		#elseif air3
		
		return File.createTempFile().nativePath;
		
		#end
	}

	public static function getSelfExePath():String 
	{
		#if sys
		return Sys.executablePath();
		#elseif air3
		if(Platform.isWindows()){
			return File.applicationDirectory.nativePath + "//" + App.getAppFilename() + ".exe";
		}else {
			return File.applicationDirectory.nativePath + "//" + App.getAppFilename();
		}
		#end
	}
	
	public static function getUserDir():String 
	{
		#if air3
		return File.userDirectory.nativePath;
		#end
	}
	
}
#end