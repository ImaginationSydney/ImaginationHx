package com.imagination.util.log;
import com.imagination.util.log.Log.LogLevel;

/**
 * @author Thomas Byrne
 */

interface ILogHandler 
{
	function log(source:Dynamic, level:String, rest:Array<Dynamic>, time:Date):Void;
}