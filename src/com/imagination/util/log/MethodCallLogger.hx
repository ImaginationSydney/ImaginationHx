package com.imagination.util.log;

/**
 * Used to call a method every time a certain log is fired.
 * 
 * @author Thomas Byrne
 */
class MethodCallLogger extends ILogHandler
{
	var method:Void->Void;

	public function new(method:Void->Void) 
	{
		this.method = method;
	}
	
	public function log(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):Void
	{
		method();
	}
}