package com.imagination.util.log.js;
import com.imagination.util.log.ConsoleLogger;
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
		
		//Log.mapHandler(new TraceLogger(LogFormatImpl.cleanFormat), Log.ALL_LEVELS);
		Log.mapHandler(new ConsoleLogger(), Log.ALL_LEVELS);
		
		Log.mapHandler(new ReloadPageLogger(), [LogLevel.CRITICAL_ERROR]);
		
		CustomTrace.install();
	}
	
}