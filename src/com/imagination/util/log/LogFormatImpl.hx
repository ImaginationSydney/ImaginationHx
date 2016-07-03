package com.imagination.util.log;
import com.imagination.util.log.Log.LogLevel;

/**
 * ...
 * @author Thomas Byrne
 */
class LogFormatImpl
{

	
	public static function cleanFormat(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):String
	{
		return getType(source)+" " + rest.join(" ");
	}

	
	public static function format(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):String
	{
		var msg:String;
		switch(level) {
			case LogLevel.INFO:
				msg = "INF: ";
				
			case LogLevel.LOG:
				msg = "LOG: ";
				
			case LogLevel.WARN:
				msg = "WRN: ";
				
			case LogLevel.ERROR:
				msg = "ERR: ";
				
			case LogLevel.UNCAUGHT_ERROR:
				msg = "UNC: ";
		}
		return msg + getType(source)+" " + rest.join(" ");
	}
	
	public static function htmlFormat(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):String
	{
		var color:String;
		switch(level) {
			case LogLevel.INFO:
				color = "444";
				
			case LogLevel.LOG:
				color = "000";
				
			case LogLevel.WARN:
				color = "e59400";
				
			case LogLevel.ERROR:
				color = "f00";
				
			case LogLevel.UNCAUGHT_ERROR:
				color = "d00";
		}
		var timestamp:String = padNum(time.getHours(), 2) + ":" + padNum(time.getMinutes(), 2) + ":" + padNum(time.getSeconds(), 2);
		var content = StringTools.htmlEscape(rest.join(" "));
		var msg:String = '<div style="color:#fff;background:#'+color+';min-width: 350px;display:inline-block;">'+timestamp+" "+getType(source)+"</div> " + content;
		msg = msg.split("\n").join("<br/>");
		msg = msg.split("\t").join("&nbsp;&nbsp;&nbsp;&nbsp;");
		return "<div><code style='font-size:12px;color:#"+color+"'>" + msg + "</code></div>";
	}
	
	public static function flashHtmlFormat(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):String
	{
		var color:String;
		switch(level) {
			case LogLevel.INFO:
				color = "777777";
				
			case LogLevel.LOG:
				color = "000000";
				
			case LogLevel.WARN:
				color = "e59400";
				
			case LogLevel.ERROR:
				color = "ff0000";
				
			case LogLevel.UNCAUGHT_ERROR:
				color = "dd0000";
		}
		var timestamp:String = padNum(time.getHours(), 2) + ":" + padNum(time.getMinutes(), 2) + ":" + padNum(time.getSeconds(), 2);
		var msg:String = '<font color="#555555">'+timestamp+" "+getType(source)+"</font> " + StringTools.htmlEscape(rest.join(" "));
		msg = msg.split("\n").join("<br/>");
		msg = msg.split("\t").join("&nbsp;&nbsp;&nbsp;&nbsp;");
		return "<font color='#"+color+"'>" + msg + "</font>";
	}
	
	static private function padNum(num:Int, length:Int):String 
	{
		var ret:String = Std.string(num);
		while (ret.length < length) ret = "0" + ret;
		return ret;
	}
	static private function padStr(str:String, length:Int):String 
	{
		while (str.length < length) str += " ";
		return str;
	}
	
	public static function fdFormat(source:Dynamic, level:LogLevel, rest:Array<Dynamic>, time:Date):String
	{
		var msg:String;
		switch(level) {
			case LogLevel.INFO:
				msg = "0:";
				
			case LogLevel.LOG:
				msg = "1:";
				
			case LogLevel.WARN:
				msg = "2:";
				
			case LogLevel.ERROR:
				msg = "3:";
				
			case LogLevel.UNCAUGHT_ERROR:
				msg = "4:";
		}
		
		
		return msg + padStr(getType(source), 35)+" " + rest.join(" ");
	}
	
	private static function getType(source:Dynamic):String
	{
		if (Std.is(source, String)) {
			return source;
		}else if (Std.is(source, Class)) {
			return getClassName(Type.getClassName(source));
		}else{
			var type = Type.getClass(source);
			if (type != null) {
				return getClassName(Type.getClassName(type));
			}else {
				return source.toString();
			}
		}
	}
	
	static private function getClassName(classPath:String) : String
	{
		var lastDot:Int = classPath.lastIndexOf(".");
		if (lastDot == -1) return classPath;
		
		return classPath.substr(lastDot + 1);
	}
		
	
}