package com.imagination.util.log.air;
import com.imagination.util.app.App;
import com.imagination.util.fs.Files;
import com.imagination.util.log.Log.LogLevel;
import com.imagination.util.log.customTrace.CustomTrace;
import com.imagination.util.time.EnterFrame;
import flash.display.DisplayObject;
import flash.errors.Error;
import flash.events.PermissionEvent;
import flash.events.UncaughtErrorEvent;
import flash.filesystem.File;
import flash.permissions.PermissionStatus;
import flash.system.Capabilities;

/**
 * ...
 * @author Thomas Byrne
 */
class DefaultAirLog
{
	private static var installed:Bool;
	public static var criticalErrorCodes:Array<Int> = [
					3691 // Resource limit exceeded
					];
					
	private static var restartRequested:Bool;
	private static var permissionFile:File;
	
	public static function install(root:DisplayObject, ?restartApp:Void->Void):Void
	{
		if (installed) return;
		installed = true;
		
		#if debug
			Log.mapHandler(new TraceLogger(LogFormatImpl.fdFormat), Log.ALL_LEVELS);
		#end
		
		Log.mapHandler(new MassErrorQuitLogger(), [LogLevel.UNCAUGHT_ERROR, LogLevel.CRITICAL_ERROR]);
		
		if(restartApp != null) Log.mapHandler(new MethodCallLogger(restartApp), [LogLevel.CRITICAL_ERROR]);
		
		root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError.bind(_, restartApp));
		
		checkFilePermission(null);
	}
	
	static private function checkFilePermission(e:PermissionEvent) 
	{
		if (File.permissionStatus == PermissionStatus.GRANTED){
			installFileLoggers();
		}else{
			if (File.permissionStatus == PermissionStatus.DENIED){
				// Add listener anyway as overlapping 'requestPermission' calls can sometimes report 'denied' while user is being prompted
				Logger.warn(DefaultAirLog, "Failed to install AIR file loggers, file permission was denied");
			}
			if (permissionFile == null){
				permissionFile = new File();
				permissionFile.addEventListener(PermissionEvent.PERMISSION_STATUS, checkFilePermission);
				Reflect.field(permissionFile, "requestPermission")();
			}
		}
	}
	
	static function installFileLoggers() 
	{
		if (permissionFile != null){
			permissionFile.removeEventListener(PermissionEvent.PERMISSION_STATUS, checkFilePermission);
			permissionFile = null;
		}
		
		var docsDir:String  = Files.appDocsDir();
		
		Log.mapHandler(new HtmlFileLogger(docsDir + "log" + Files.slash(), true), Log.ALL_LEVELS);
		
		Log.mapHandler(new HtmlFileLogger(docsDir + "errorLog" + Files.slash(), false), [LogLevel.UNCAUGHT_ERROR, LogLevel.ERROR, LogLevel.CRITICAL_ERROR]);
	}
	
	#if raven
	public static function installSentry(sentryDsn:String, ?terminalName:String):Void
	{
		if(terminalName==null)Logger.log(DefaultAirLog, "No 'terminalName' found, will track using IP address (set this up with global config in ~/Docs/imagination/_global/config.json)");
		Log.mapHandler(new SentryLogger(App.getAppId(), sentryDsn, terminalName), [LogLevel.UNCAUGHT_ERROR, LogLevel.ERROR, LogLevel.CRITICAL_ERROR, LogLevel.WARN]);
	}
	#end
	
	
	public static function installIdmLog():Void
	{
		var docsDir:String  = Files.appDocsDir();
		var jsonLogger:SimpleJsonLogger = new SimpleJsonLogger(docsDir + "idm/log", false);
		Log.mapHandler(jsonLogger, [LogLevel.UNCAUGHT_ERROR, LogLevel.ERROR, LogLevel.CRITICAL_ERROR]);
	}
	
	private static function onUncaughtError(e:UncaughtErrorEvent, ?restartApp:Void->Void):Void 
	{
		var message:String;
		if (Reflect.hasField(e.error, "message"))
		{
			message = Reflect.field(e.error, "message");
		}
		else if (Reflect.hasField(e.error, "text"))
		{
			message = Reflect.field(e.error, "text");
		}
		else
		{
			message = Std.string(e.error);
		}
		var err:Error = cast(e.error);
		if (err != null) {
			Log.log(e.target, LogLevel.UNCAUGHT_ERROR, [criticalErrorCodes.indexOf(err.errorID), "\n"+err.getStackTrace()]);
			
			if (!restartRequested && restartApp!=null && criticalErrorCodes.indexOf(err.errorID) != -1){
				Logger.error(e.target, "Critical error "+err.errorID+" caught, attempting restart");
				EnterFrame.delay(restartApp);
				restartRequested = true;
			}
		}else {
			Logger.error(e.target, message);
		}
		e.preventDefault();
		
	}
	
}