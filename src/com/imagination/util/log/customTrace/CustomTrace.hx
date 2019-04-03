package com.imagination.util.log.customTrace;

import haxe.PosInfos;

/**
 * ...
 * @author Thomas Byrne
 */
class CustomTrace
{
	private static var originalTrace:String->PosInfos->Void;
	private static var installed:Bool;
	
	public static function install():Void
	{
		if (installed) return;
		installed = true;
		
		originalTrace = haxe.Log.trace;
		haxe.Log.trace = customTrace;
	}
	
	static private function customTrace( v : Dynamic, ?inf : haxe.PosInfos ) 
	{
		var classPath = inf.className;
		var lastDot:Int = classPath.lastIndexOf(".");
		if (lastDot != -1) classPath = classPath.substr(lastDot + 1);
		if(Log.hasHandlers){
			Logger.log(classPath, v);
		}else{
			originalTrace(v, inf);
		}
	}
}