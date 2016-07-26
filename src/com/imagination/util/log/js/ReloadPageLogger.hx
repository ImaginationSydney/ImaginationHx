package com.imagination.util.log.js;

import com.imagination.util.log.ILogHandler;
import com.imagination.util.log.Log.LogLevel;

/**
 * Reloads the page when a certain log level happens.
 * 
 * @author Thomas Byrne
 */
class ReloadPageLogger implements ILogHandler
{

	public function new() 
	{
		
	}
	
	
	public function log(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):Void 
	{
		js.Browser.location.reload();
	}
	
}