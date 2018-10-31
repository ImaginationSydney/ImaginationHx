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
					//forceUpper = true;
					
				case HELP:
					textColor = White;
					bgColor = Blue;
					
				case HINT:
					textColor = LightGray;
					
				case INFO:
					textColor = DarkGray;
					
				case PROGRESS_INFO:
					textColor = White;
					
				case WARNING:
					textColor = LightYellow;
					//forceUpper = true;
					
				case ASK_QUESTION:
					textColor = LightYellow;
					
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
		newline();
		print(msg, PrintStyle.ASK_QUESTION);
		
		var input = Sys.stdin();
		var i = 0;
		while (true){
			i += 50;
			if (timeout!=null && i > timeout * 1000){
				return false;
			}
			var chars:String = input.readString(1);
			if (chars == null || chars.length == 0){
				Sys.sleep(0.25);
				continue;
			}
			chars = chars.toUpperCase();
			if (chars == "N") return false;
			if (chars == "Y") return true;
			
			Sys.sleep(0.25);
		}
		return false;
	}
	
	
	#if sys
	static public function selectSync(msg:String, options:Array<String>, ?timeout:Float) : Int
	{
		newline();
		print(msg, PrintStyle.ASK_QUESTION);
		
		for (i in 0 ... options.length){
			print((i + 1)+") " + options[i]);
		}
		
		var input = Sys.stdin();
		var i = 0;
		var chars:String = "";
		while (true){
			i += 250;
			if (timeout!=null && i > timeout * 1000){
				return ( -1);
			}
			var read:String = input.readString(1);
			if (read != null) chars = chars + read;
			
			if (chars.charAt(chars.length - 1) != "\n"){
				Sys.sleep(0.25);
				continue;
			}
			var index = Std.parseInt(chars);
			index -= 1;
			if (index >= 0 && index < options.length){
				return (index);
			}
			chars = "";
			Sys.sleep(0.25);
		}
		return (-1);
	}
	static public function askSync(msg:String, ?def:String, ?timeout:Float) : String
	{
		newline();
		print(msg, PrintStyle.ASK_QUESTION);
		if (def != null) print('Default: ${def} [Hit Enter]', PrintStyle.HINT);
		
		var input = Sys.stdin();
		var i = 0;
		var chars:String = input.readString(1);
		if (chars == "\n") chars = '';
		while (true){
			i += 250;
			if (timeout!=null && i > timeout * 1000){
				return null;
			}
			var read:String = input.readString(1);
			if (read != null) chars = chars + read;
			
			if (chars.length == 0 || chars.charAt(chars.length - 1) != "\n"){
				Sys.sleep(0.25);
				continue;
			}
			var ret = chars.substr(0, chars.length - 1);
			if (ret == '') ret = null;
			return ret;
		}
		return null;
	}
	#end
	
	static public function select(msg:String, options:Array<String>, complete:(Int->Void), ?timeout:Float) : Void
	{
		#if sys
		
		complete(selectSync(msg, options, timeout));
		
		#elseif hxnodejs
		
		for (i in 0 ... options.length){
			msg += ("\n" + (i + 1)+") " + options[i]);
		}
		
		var rl:js.node.readline.Interface = js.node.Readline.createInterface({
		  input: js.Node.process.stdin,
		  output: js.Node.process.stdout
		});

		rl.question(msg, function(answer) {
		  var index = options.indexOf(answer);
		  if (index == -1) index = Std.parseInt(answer);
		  complete(index);
		  rl.close();
		});
		
		#end
	}
	
}

enum PrintStyle{
	HELP;
	HINT;
	ERROR;
	WARNING;
	INFO;
	PROGRESS_INFO;
	MENU_HEADING;
	MENU_OPTION;
	ASK_QUESTION;
}