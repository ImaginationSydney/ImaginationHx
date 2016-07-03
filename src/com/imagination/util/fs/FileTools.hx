package com.imagination.util.fs;
import com.imagination.air.util.EventListenerTracker;

/**
 * ...
 * @author Thomas Byrne
 */
#if flash

	import flash.filesystem.File as FlFile;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	class FileTools
	{

		public static function getContent(path:String):String
		{
			var file:FlFile = new FlFile(path);
			var stream:FileStream =  new FileStream();
			stream.open(file, FileMode.READ);
			var ret:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			return ret;
		}
		
		public static function saveContent(path:String, content:String):Void
		{
			var file:FlFile = new FlFile(path);
			var stream:FileStream =  new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(content);
			stream.close();
		}
		
		public static function getContentAsync(path:String, onComplete:String->Void, ?onFail:String->Void):Void
		{
			var file:FlFile = new FlFile(path);
			var stream:FileStream =  new FileStream();
			var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
			listenerTracker.addEventListener(Event.COMPLETE, successHandler.bind(_, stream, listenerTracker, onComplete) );
			listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, failHandler.bind(_, stream, listenerTracker, onFail) );
			stream.openAsync(file, FileMode.READ);
		}
		
		static private function successHandler(e:Event, stream:FileStream, listenerTracker:EventListenerTracker, onComplete:String->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			var ret:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			onComplete(ret);
		}
		
		static private function failHandler(e:Event, stream:FileStream, listenerTracker:EventListenerTracker, onFail:String->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			stream.close();
			onFail(e.toString());
		}
	}

	
#elseif sys

	@:forward()
	abstract FileTools(sys.io.File) to sys.io.File
	{

		public static function getContentAsync(path:String, onComplete:String->Void):Void
		{
			onComplete(sys.io.File.getContent(path);
		}
		
	}

#end