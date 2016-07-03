package com.imagination.util.log;
import com.imagination.util.time.GlobalTime;
import haxe.PosInfos;

/**
 * ...
 * @author Thomas Byrne
 */
class Log
{
	static public var ALL_LEVELS:Int = untyped (LogLevel.INFO | LogLevel.LOG | LogLevel.WARN | LogLevel.ERROR | LogLevel.UNCAUGHT_ERROR);
	static private var INDICES:Array<LogLevel> = [LogLevel.INFO , LogLevel.LOG , LogLevel.WARN , LogLevel.ERROR , LogLevel.UNCAUGHT_ERROR];
	
	private static var handlers:Array<Array<ILogHandler>>;

	/**
	 * Set exclusiveSource to an object to ignore any log events from other objects.
	 */
	static public var exclusiveSource:Dynamic;
	
	static private function setup():Void 
	{
		if (handlers!=null) return;
		
		handlers = new Array<Array<ILogHandler>>();
		for (i in 0 ...INDICES.length) {
			handlers.push(new Array<ILogHandler>());
		}
	}
	
	
	public static function log(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, ?pos:PosInfos):Void {
		if (handlers==null) return;
		
		if (exclusiveSource != null && exclusiveSource != source) return;
		else if (Reflect.hasField(source, "verbose")) {
			try {
				if (Reflect.field(source, "verbose") == false) {
					return;
				}
			}catch (e:Dynamic) {}
		}
		
		var params:Array<Dynamic> = [source, level];
		params = params.concat(rest);
		
		var ind:Int = INDICES.indexOf(level);
		
		var time:Date = GlobalTime.now();
		var handlerList:Array<ILogHandler> = handlers[ind];
		for(logger in handlerList) {
			logger.log(source, level, rest, time);
		}
	}
	
	public static function mapHandler(handler:ILogHandler, levels:Int):Void {
		setup();
		mapHandlerToLevel(handler, levels, LogLevel.INFO, INDICES.indexOf(LogLevel.INFO));
		mapHandlerToLevel(handler, levels, LogLevel.LOG, INDICES.indexOf(LogLevel.LOG));
		mapHandlerToLevel(handler, levels, LogLevel.WARN, INDICES.indexOf(LogLevel.WARN));
		mapHandlerToLevel(handler, levels, LogLevel.ERROR, INDICES.indexOf(LogLevel.ERROR));
		mapHandlerToLevel(handler, levels, LogLevel.UNCAUGHT_ERROR, INDICES.indexOf(LogLevel.UNCAUGHT_ERROR));
	}
	
	static private function mapHandlerToLevel(handler:ILogHandler, levels:Int, levelMatch:LogLevel, ind:Int):Void 
	{
		if (!untyped(levels & levelMatch)) return;
		
		var list:Array<ILogHandler> = handlers[ind];
		list.push(handler);
	}
	
}

@:enum
abstract LogLevel(Int) {
	var INFO = 1;
	var LOG = 2;
	var WARN = 4;
	var ERROR = 8;
	var UNCAUGHT_ERROR = 16;
}