package com.imagination.util.log.air;
import com.imagination.delay.EnterFrame;
import com.imagination.util.fs.FileTools;
import com.imagination.util.fs.Files;
import com.imagination.util.time.GlobalTime;
import com.imagination.worker.ext.FileSysTasks;
import com.imagination.util.log.Log.LogLevel;
import com.imagination.worker.WorkerSwitchboard;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.Lib;
import haxe.Timer;
import haxe.crypto.Md5;

using com.imagination.worker.ext.FileSysTasks;

/**
 * ...
 * @author Thomas Byrne
 */
class SimpleJsonLogger implements ILogHandler
{
	private var workerSwitch:WorkerSwitchboard;
	
	private var dir:String;
	private var fileExt:String;
	
	//private var lastFileInd:Int = 0;
	
	public function new(dir:String, viaWorker:Bool, fileExt:String="json"):Void
	{
		this.dir = dir;
		this.fileExt = fileExt;
		
		if (viaWorker) {
			workerSwitch = WorkerSwitchboard.getWorker();
		}else {
			workerSwitch = WorkerSwitchboard.getInstance();
		}
		
		var dirFile:File = new File(dir);
		if (dirFile.exists && !dirFile.isDirectory){
			dirFile.deleteFile();
		}else if (!dirFile.exists) {
			dirFile.createDirectory();
		}else{
			var list:Array<File> = dirFile.getDirectoryListing();
			for (file in list){
				var path = file.nativePath;
				var nameInd = path.lastIndexOf(Files.slash());
				var name = path.substr(nameInd + 1);
				var dotInd:Int = path.lastIndexOf(".");
				name = name.substr(0, dotInd);
				var ind:Int = Std.parseInt(name);
				/*if (lastFileInd < ind){
					lastFileInd = ind;
				}*/
			}
		}
	}
	
	
	public function log(source:Dynamic, level:String, rest:Array<Dynamic>, time:Date):Void 
	{
		var timezoneOffset:Float = 0;
		#if (flash || js)
			timezoneOffset = untyped time.getTimezoneOffset();
		#end
		
		var msg = rest.join("\n\n");
		var hash = Md5.encode(msg);
		msg = jsonEscape(msg);
		var ts = time.getTime();
		var write = '{\n\t"source":"' + LogFormatImpl.getType(source) + '",\n\t"level":"' + level + '",\n\t"msg":"' + msg + '",\n\t"time":' + ts + ',\n\t"timezoneOffset":' + timezoneOffset + '\n}';
		
		attemptWrite(write, hash, ts);
	}
	
	function attemptWrite(write:String, hash:String, time:Float) 
	{
		var path = dir + "/" + hash + "." + fileExt;
		if (FileTools.exists(path)){
			workerSwitch.appendTextToFile(path, "<" + time + ">", null, onError.bind(_, write, hash, time));
		}else{
			//lastFileInd++;
			workerSwitch.writeTextToFile(path, write, null, onError.bind(_, write, hash, time));
		}
	}
	
	function onError(err:String, write:String, hash:String, time:Float) 
	{
		attemptWrite(write, hash, time);
	}
	
	function jsonEscape(str  :String) : String  {
		str = str.split("\\").join("\\\\");
		str = str.split("\n").join("\\n");
		str = str.split("\r").join("\\r");
		str = str.split("\t").join("\\t");
		str = str.split('"').join('\\"');
		return str;
	}
}