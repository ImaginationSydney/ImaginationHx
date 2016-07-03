package com.imagination.util.log.air;
import com.imagination.delay.Delay;
import com.imagination.util.app.App;
import com.imagination.util.fs.Files;
import com.imagination.util.log.Log.LogLevel;
import com.imagination.util.log.customTrace.CustomTrace;
import flash.display.DisplayObject;
import flash.errors.Error;
import flash.events.UncaughtErrorEvent;
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
	
	public static function install(root:DisplayObject, ?restartApp:Void->Void):Void
	{
		if (installed) return;
		installed = true;
		
		var docsDir:String  = Files.appDocsDir();
		
		// Must be runtime conditional because of SWC packaging
		//if(Capabilities.isDebugger){
			Log.mapHandler(new TraceLogger(LogFormatImpl.fdFormat), Log.ALL_LEVELS);
		//}
		
		Log.mapHandler(new AirFileLogger(docsDir + "log", true), Log.ALL_LEVELS);
		
		Log.mapHandler(new AirFileLogger(docsDir + "errorLog", false), untyped(LogLevel.UNCAUGHT_ERROR | LogLevel.ERROR));
		
		root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError.bind(_, restartApp));
		
		CustomTrace.install();
	}
	
	public static function installSentry(sentryDsn:String, ?terminalName:String):Void
	{
		if(terminalName==null)Logger.log(DefaultAirLog, "No 'terminalName' found, will track using IP address (set this up with global config in ~/Docs/imagination/_global/config.json)");
		Log.mapHandler(new SentryLogger(App.getAppId(), sentryDsn, terminalName), untyped(LogLevel.UNCAUGHT_ERROR | LogLevel.ERROR | LogLevel.WARN));
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
			Logger.error(e.target, message, err.errorID, err.getStackTrace());
			
			if (restartApp!=null && criticalErrorCodes.indexOf(err.errorID) != -1){
				Logger.info(e.target, "Critical error "+err.errorID+" caught, attempting restart");
				Delay.byFrames(1, restartApp);
			}
		}else {
			Logger.error(e.target, message);
		}
		e.preventDefault();
		
	}
	
}