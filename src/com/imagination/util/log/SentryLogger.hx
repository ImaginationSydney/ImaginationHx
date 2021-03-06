package com.imagination.util.log;
import com.imagination.util.app.App;
import com.imagination.util.log.Log.LogLevel;
import haxe.ds.Map;
import raven.Raven;
import raven.types.RavenCallData;
import raven.types.RavenConfig;

/**
 * ...
 * @author Thomas Byrne
 */
@:access(raven.Raven)
class SentryLogger implements ILogHandler
{
	public function new(appId:String, sentryDsn:String, ?terminalName:String) 
	{
		Raven.config(sentryDsn);
		
		if (Raven.globalOptions.tags == null) Raven.globalOptions.tags = new Map();
		Raven.globalOptions.tags.set("ApplicationID", appId);
		Raven.globalOptions.tags.set("ApplicationVersion", App.getVersion());
		
		if (terminalName != null) {
			Raven.globalUser = { id:terminalName };
		}
	}
	
	public function log(source:Dynamic, level:String, rest:Array<Dynamic>, time:Date):Void {
		var msg:String = Std.string(source)+": "+rest.join(" ");
		var levelCode:Int;
		var attemptErr:Bool = false;
		switch(level) {
			case LogLevel.INFO:
				levelCode = 10;
			case LogLevel.WARN:
				levelCode = 30;
			case LogLevel.ERROR | LogLevel.CRITICAL_ERROR:
				levelCode = 40;
				attemptErr = true;
			case LogLevel.UNCAUGHT_ERROR:
				levelCode = 50;
				attemptErr = true;
				
			default: // | LogLevel.LOG
				levelCode = 20;
		}
		var options:RavenCallData = { level:levelCode };
		if (attemptErr && rest.length >= 3) {
			Raven.captureException(rest[0], rest[1], null, rest[2], 0, options);
		}else {
			Raven.captureMessage(msg, options);
		}
	}
}