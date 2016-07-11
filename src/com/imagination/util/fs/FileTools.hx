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
		
		public static function saveContentWithConfirm(path:String, content:String, confirm:String -> String -> Bool):Void
		{
			var temp:String = path + ".tmp";
			saveContent(temp, content);
			var savedContent:String = getContent(temp);
			if (confirm(content, savedContent)) {
				var file:File = new File(path);
				var temp:File = new File(temp);
				temp.copyTo(file, true);
			}
			else {
				trace("failed to save content to: " + path);
			}
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
			listenerTracker.addEventListener(Event.COMPLETE, readSuccessHandler.bind(_, stream, listenerTracker, onComplete) );
			listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, readFailHandler.bind(_, stream, listenerTracker, onFail) );
			stream.openAsync(file, FileMode.READ);
		}
		
		static private function readSuccessHandler(e:Event, stream:FileStream, listenerTracker:EventListenerTracker, onComplete:String->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			var ret:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			onComplete(ret);
		}
		
		static private function readFailHandler(e:Event, stream:FileStream, listenerTracker:EventListenerTracker, onFail:String->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			stream.close();
			onFail(e.toString());
		}
		
		public static function saveContentAsyncWithConfirm(path:String, content:String, confirm:String -> String -> Bool, onComplete:Void->Void, ?onFail:String->Void):Void
		{
			var temp = path + ".tmp";
			FileTools.saveContentAsync(temp, content, function() {
				FileTools.getContentAsync(temp, function (savedContent:String) {
					if (confirm(content, savedContent)) {
						var file:File = new File(path);
						var temp:File = new File(temp);
						temp.copyToAsync(file, true);
						if (onComplete != null) onComplete();
					}
					else {
						trace("failed to save content to: " + path);
						if (onFail != null) {
							onFail("failed to save content to: " + path);
						}
					}
				}, onFail);
			}, onFail);
		}
		
		public static function saveContentAsync(path:String, content:String, onComplete:Void->Void, ?onFail:String->Void):Void
		{
			var file:FlFile = new FlFile(path);
			var stream:FileStream =  new FileStream();
			var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
			listenerTracker.addEventListener(Event.CLOSE, writeSuccessHandler.bind(_, listenerTracker, onComplete) );
			listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, writeFailHandler.bind(_, listenerTracker, onFail) );
			stream.openAsync(file, FileMode.WRITE);
			stream.writeUTFBytes(content);
			stream.close();
		}
		
		static private function writeSuccessHandler(e:Event, listenerTracker:EventListenerTracker, onComplete:Void->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			if (onComplete != null) onComplete();
		}
		
		static private function writeFailHandler(e:Event, listenerTracker:EventListenerTracker, onFail:String->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			if (onFail != null) onFail(e.toString());
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