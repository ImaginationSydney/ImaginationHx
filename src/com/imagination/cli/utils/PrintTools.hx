package com.imagination.cli.utils;
import com.imagination.util.log.LogFormatImpl;
import com.imagination.util.log.cli.EchoLogger;

/**
 * ...
 * @author Thomas Byrne
 */
@:access(com.imagination.util.log.cli.EchoLogger)
@:access(com.imagination.util.log.LogFormatImpl)
class PrintTools
{
	// Shortcuts
	static inline public function error(msg:String) 
	{
		print(msg, PrintStyle.ERROR);
	}
	static inline public function help(msg:String) 
	{
		print(msg, PrintStyle.HELP);
	}
	
	static inline public function progressInfo(msg:String) 
	{
		print(msg, PrintStyle.PROGRESS_INFO);
	}
	
	static inline public function info(msg:String) 
	{
		print(msg, PrintStyle.INFO);
	}
	
	static inline public function newline() 
	{
		print("\r");
	}
	
	static public function warn(msg:String) 
	{
		print(msg, PrintStyle.WARNING);
	}
	
	// Check colors: http://misc.flogisoft.com/bash/tip_colors_and_formatting#colors
	public static function print(msg:String, ?style:PrintStyle){
		msg = msg.split("&").join("^&");
		if (msg.indexOf("\n") != -1){
			var parts = msg.split("\n");
			for (part in parts){
				print(part, style);
			}
			return;
		}
		
		EchoLogger.setup();
		var textColor:TextColor = null;
		var bgColor:BgColor = null;
		var prepend:String = "";
		var append:String = "";
		var forceUpper:Bool = false;
		if(style != null){
			switch(style){
				case ERROR:
					textColor = Red;
					forceUpper = true;
					
				case HELP:
					textColor = White;
					bgColor = Blue;
					
				case INFO:
					textColor = LightGray;
					textColor = DarkGray;
					
				case PROGRESS_INFO:
					textColor = White;
					
				case WARNING:
					textColor = LightYellow;
					forceUpper = true;
					
				case MENU_HEADING:
					textColor = LightBlue;
					prepend = " -- ";
					append = " -- ";
					forceUpper = true;
					
				case MENU_OPTION:
					textColor = LightGray;
					prepend = "   ";
			}
		}
		
		if (forceUpper) msg = msg.toUpperCase();
		
		if (EchoLogger.hasColorCmd && style != null){
			if(bgColor != null){
				Sys.command("echo \\033[" + textColor + ";" + bgColor + "m" + LogFormatImpl.padStr(prepend + msg + append, 100) + " | cmdcolor");
			}else{
				Sys.command("echo \\033[" + textColor + "m" + prepend + msg + append + " | cmdcolor");
			}
		}else{
			Sys.println(prepend + msg + append);
		}
	}
	
	static public function confirm(msg:String, ?timeout:Float) : Bool
	{
		print(msg);
		var input = Sys.stdin();
		var i = 0;
		while (true){
			i += 50;
			if (timeout!=null && i > timeout * 1000){
				return false;
			}
			var chars:String = input.readString(1);
			if (chars == null || chars.length == 0){
				Sys.sleep(50);
			}
			chars = chars.toUpperCase();
			if (chars == "N") return false;
			if (chars == "Y") return true;
			
			Sys.sleep(50);
		}
		return false;
	}
	
}

enum PrintStyle{
	HELP;
	ERROR;
	WARNING;
	INFO;
	PROGRESS_INFO;
	MENU_HEADING;
	MENU_OPTION;
}