package com.imagination.util.log;
import com.imagination.util.log.Log.LogLevel;

/**
 * @author Thomas Byrne
 */

interface ILogHandler 
{
	function log(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):Void;
}