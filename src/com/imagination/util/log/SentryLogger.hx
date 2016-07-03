package com.imagination.util.log;
import com.imagination.util.log.Log.LogLevel;
import raven.Raven;
import raven.types.RavenCallData;
import raven.types.RavenConfig;

/**
 * ...
 * @author Thomas Byrne
 */
class SentryLogger implements ILogHandler
{
	//private var client:RavenClient;
	var appId:String;

	public function new(appId:String, sentryDsn:String, ?terminalName:String) 
	{
		Raven.config(sentryDsn);
		this.appId = appId;
		
		if (terminalName != null) {
			Raven.globalUser = { id:terminalName };
		}
	}
	
	public function log(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):Void {
		var msg:String = Std.string(source)+": "+rest.join(" ");
		var levelCode:Int;
		var attemptErr:Bool = false;
		switch(level) {
			case LogLevel.INFO:
				levelCode = 10;
				//Raven.captureMessage(msg);
			case LogLevel.LOG:
				levelCode = 20;
				//Raven.captureMessage(msg);
			case LogLevel.WARN:
				levelCode = 30;
				//Raven.captureMessage(msg);
			case LogLevel.ERROR:
				levelCode = 40;
				attemptErr = true;
			case LogLevel.UNCAUGHT_ERROR:
				levelCode = 50;
				attemptErr = true;
		}
		var options:RavenCallData = { level:levelCode };
		if (attemptErr && rest.length >= 3) {
			Raven.captureException(rest[0], rest[1], null, rest[2], 0, options);
		}else {
			Raven.captureMessage(msg, options);
		}
	}
}