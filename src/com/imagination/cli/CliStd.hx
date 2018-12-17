package com.imagination.cli;

/**
 * ...
 * @author Thomas Byrne
 */
class CliStd 
{
	public static function writeOut(string:String, ?callback:Void->Void)
	{
		#if sys
		
		var out = Sys.stdout();
		out.writeString(string);
		callback();
		
		#else
		
		var out:js.node.stream.Writable.IWritable = js.Node.process.stdout;
		out.write(string, 'utf8', callback);
		
		#end
		
	}
	
	public static function readAll():String
	{
		#if sys
		
		var stdin = Sys.stdin();
		return stdin.readLine();
		
		#else
		
		var stdin:js.node.stream.Readable.IReadable = js.Node.process.stdin;
		stdin.setEncoding('utf8');
		return stdin.read();
		
		#end
	}
	
}