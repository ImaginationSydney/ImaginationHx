package com.imagination.util.log.cli;
import com.imagination.util.log.Log.LogLevel;
import com.imagination.util.log.customTrace.CustomTrace;

/**
 * ...
 * @author Thomas Byrne
 */
class DefaultCliLog
{
	private static var installed:Bool;
	
	public static function install():Void
	{
		if (installed) return;
		installed = true;
		
		Log.mapHandler(new EchoLogger(), Log.ALL_LEVELS);
		
		//CustomTrace.install();
	}
	
}