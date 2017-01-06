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
	static var tempFile:File = new File();
	
	public static inline function slash():String 
	{
		if (Platform.isWindows()) {
			return "\\";
		}else {
			return "/";
		}
	}
	public static inline function ensure(path:String):String 
	{
		if (Platform.isWindows()) {
			return path.split("/").join("\\");
		}else {
			return path;
		}
	}
	
	public static function documentsDir():String 
	{
		return File.documentsDirectory.nativePath + slash();
	}
	
	public static function imagDocsDir():String 
	{
		return documentsDir() + "imagination" + slash();
	}
	
	public static function applicationDir():String 
	{
		return File.applicationDirectory.nativePath + slash();
	}

	public static function appDocsDir(?appId:String):String 
	{
		
		#if sys
		
		var path:String = Sys.executablePath();
		var ind = path.lastIndexOf(slash());
		return path.substr(0, ind + 1);
		
		#elseif air3
		
		if (appId == null) appId = App.getAppId();
		return imagDocsDir() + appId + slash();
		
		#end
	}
	
	static var reourcePath:String;
	public static function resourcesDir(?appId:String):String 
	{
		if (reourcePath != null) return reourcePath;
		if (appId == null) appId = App.getAppId();
		reourcePath = imagDocsDir() + appId + "+resources" + slash();
		return reourcePath;
	}
	public static function resourcesUri(resource:String):String 
	{
		return resourcesDir() + resource;
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
			return File.applicationDirectory.nativePath + slash() + App.getAppFilename() + ".exe";
		}else {
			return File.applicationDirectory.nativePath + slash() + App.getAppFilename();
		}
		#end
	}
	
	public static function getUserDir():String 
	{
		#if air3
		return File.userDirectory.nativePath;
		#end
	}
	
	public static function findInstalled(appPath:String) : String
	{
		if(Platform.isWindows()){
			tempFile.nativePath = ("C:\\Program Files (x86)\\" + appPath);
			if (!tempFile.exists) {
				tempFile.nativePath = ("C:\\Program Files\\" + appPath);
			}
		}else{
			tempFile.nativePath = ("/Applications/"+appPath);
		}
		return tempFile.nativePath;
	}
	
}
#else
class Files
{
	static var resourceLocation:String;
	public static function setResourceLocation(uri:String):Void 
	{
		if (uri.charAt(uri.length - 1) != "/") uri += "/";
		resourceLocation = uri;
	}
	public static function resourcesUri(resource:String):String 
	{
		return resourceLocation + resource;
	}
}
#end