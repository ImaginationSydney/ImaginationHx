package com.imagination.util.log.js;
import com.imagination.util.app.App;
import com.imagination.util.log.Log.LogLevel;
import com.imagination.util.log.customTrace.CustomTrace;

/**
 * ...
 * @author Thomas Byrne
 */
class DefaultJsLog
{
	public static function install():Void
	{
		
		Log.mapHandler(new TraceLogger(LogFormatImpl.cleanFormat), Log.ALL_LEVELS);
		
		CustomTrace.install();
	}
	
	/*public static function installSentry(sentryDsn:String, ?terminalName:String):Void
	{
		if(terminalName==null)Logger.log(DefaultJsLog, "No 'terminalName' found, will track using IP address (set this up with global config in ~/Docs/imagination/_global/config.json)");
		Log.mapHandler(new SentryLogger(App.getAppId(), sentryDsn, terminalName), untyped(LogLevel.UNCAUGHT_ERROR | LogLevel.ERROR | LogLevel.WARN));
	}*/
	
}