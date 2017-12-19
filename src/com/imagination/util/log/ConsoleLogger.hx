package com.imagination.util.log;
import com.imagination.util.log.Log.LogLevel;
import haxe.Constraints.Function;
import js.Browser;
import js.Lib;
import haxe.extern.Rest;

/**
 * ...
 * @author Thomas Byrne
 */
class ConsoleLogger implements ILogHandler 
{

	public function new() 
	{
		
	}
	
	public function log(source:Dynamic, level:String, rest:Array<Dynamic>, time:Date):Void 
	{
		var sourceStr:String = LogFormatImpl.getType(source) + ":";
		sourceStr = StringTools.lpad(sourceStr, " ", 30);
		
		var logHandler:Rest<Dynamic> -> Void = null;
		switch(level){
			case LogLevel.ERROR | LogLevel.UNCAUGHT_ERROR | LogLevel.CRITICAL_ERROR:
				logHandler = Browser.console.error;
			case LogLevel.INFO:
				logHandler = Browser.console.info;
			case LogLevel.WARN:
				logHandler = Browser.console.warn;
			default:
				logHandler = Browser.console.log;
		}
		switch(rest.length){
			case  0: logHandler(sourceStr);
			case  1: logHandler(sourceStr, rest[0]);
			case  2: logHandler(sourceStr, rest[0], rest[1]);
			case  3: logHandler(sourceStr, rest[0], rest[1], rest[2]);
			case  4: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3]);
			case  5: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3], rest[4]);
			case  6: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);
			case  7: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);
			case  8: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7]);
			case  9: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8]);
			case 10: logHandler(sourceStr, rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9]);
		}
	}
	
}