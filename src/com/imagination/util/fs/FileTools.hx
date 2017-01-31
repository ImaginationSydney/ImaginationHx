package com.imagination.util.fs;

#if sys
import sys.FileSystem;
#else
import com.imagination.air.util.EventListenerTracker;
#end

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
		static var temp:FlFile = new FlFile();

		public static function getContent(path:String):String
		{
			temp.nativePath = path;
			var stream:FileStream =  new FileStream();
			stream.open(temp, FileMode.READ);
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
				//trace("failed to save content to: " + path);
			}
		}
		
		public static function saveContent(path:String, content:String):Void
		{
			temp.nativePath = path;
			confirmParent(temp);
			var stream:FileStream =  new FileStream();
			stream.open(temp, FileMode.WRITE);
			stream.writeUTFBytes(content);
			stream.close();
		}
		
		public static function getContentAsync(path:String, onComplete:String->Void, ?onFail:String->Void):Void
		{
			temp.nativePath = path;
			var stream:FileStream =  new FileStream();
			var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
			listenerTracker.addEventListener(Event.COMPLETE, readSuccessHandler.bind(_, stream, listenerTracker, onComplete) );
			listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, readFailHandler.bind(_, stream, listenerTracker, onFail) );
			stream.openAsync(temp, FileMode.READ);
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
			if(onFail != null) onFail(e.toString());
		}
		
		public static function saveContentAsyncWithConfirm(path:String, content:String, confirm:String -> String -> Bool, ?onComplete:Void->Void, ?onFail:String->Void):Void
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
						//trace("failed to save content to: " + path);
						if (onFail != null) {
							onFail("failed to save content to: " + path);
						}
					}
				}, onFail);
			}, onFail);
		}
		
		public static function saveContentAsync(path:String, content:String, ?onComplete:Void->Void, ?onFail:String->Void):Void
		{
			try{
				temp.nativePath = path;
				confirmParent(temp);
				var stream:FileStream =  new FileStream();
				var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
				listenerTracker.addEventListener(Event.CLOSE, writeSuccessHandler.bind(_, listenerTracker, onComplete) );
				listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, writeFailHandler.bind(_, listenerTracker, onFail) );
				stream.openAsync(temp, FileMode.WRITE);
				stream.writeUTFBytes(content);
				stream.close();
			}catch (e:Dynamic){
				if (onFail != null) onFail(Std.string(e));
			}
		}
		static private function writeSuccessHandler(e:Event, listenerTracker:EventListenerTracker, onComplete:Void->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			if(onComplete != null) onComplete();
		}
		static private function writeFailHandler(e:Event, listenerTracker:EventListenerTracker, onFail:String->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			if(onFail != null) onFail(e.toString());
		}
		
		static public function exists(path:String) : Bool
		{
			try{
				temp.nativePath = path;
			}
			catch (e:Dynamic) {
				return false;
			}
			return temp.exists;
		}
		
		static public function rename(path:String, newPath:String) : Bool
		{
			temp.nativePath = path;
			temp.moveTo(new FlFile(newPath));
			return temp.exists;
		}
		inline public static function deleteFile(path : String):Void
		{
			if (!exists(path)) return;
			temp.nativePath = path;
			temp.deleteFile();
		}
		
		static public function deleteDirectory(path : String, deleteDirectoryContents:Bool = false) :Void
		{
			if (!exists(path)) return;
			temp.nativePath = path;
			temp.deleteDirectory(deleteDirectoryContents);
		}
		
		static public function deleteDirectoryAsync(path : String, deleteDirectoryContents:Bool = false) :Void
		{
			if (!exists(path)) return;
			temp.nativePath = path;
			temp.deleteDirectoryAsync(deleteDirectoryContents);
		}
		
		static public function createDirectory(path : String) :Void
		{
			temp.nativePath = path;
			temp.createDirectory();
		}
		
		static public function isDirectory(path : String) 
		{
			temp.nativePath = path;
			return temp.isDirectory;
		}
		
		static public function platformPathToUri(path:String) : String
		{
			temp.nativePath = path;
			return temp.url;
		}
		
		
		
		
		static private function confirmParent(temp:FlFile) 
		{
			if (!temp.parent.exists){
				temp.parent.createDirectory();
			}
		}
	}

	
#elseif sys

	abstract FileTools(sys.io.File) to sys.io.File
	{

		public inline static function getContent(path:String):String
		{
			return sys.io.File.getContent(path);
		}
		public static function getContentAsync(path:String, onComplete:String->Void):Void
		{
			onComplete(sys.io.File.getContent(path));
		}
		public inline static function saveContent(path:String, content:String):Void
		{
			return sys.io.File.saveContent(path, content);
		}
		public static function saveContentAsync(path:String, content:String, onComplete:Void->Void):Void
		{
			sys.io.File.saveContent(path, content);
			onComplete();
		}
		inline public static function exists(path:String):Bool
		{
			return FileSystem.exists(path);
		}
		inline public static function rename(path : String, newPath : String):Void
		{
			FileSystem.rename(path, newPath);
		}
		inline public static function deleteFile(path : String):Void
		{
			FileSystem.deleteFile(path);
		}
		
		inline public static function deleteDirectory(path : String, deleteDirectoryContents:Bool = false) :Void
		{
			if (!deleteDirectoryContents && FileSystem.readDirectory(path).length > 0){
				throw "Couldn't delete folder, contains items";
			}
			FileSystem.deleteDirectory(path);
		}
		
		inline public static function createDirectory(path : String) :Void
		{
			FileSystem.createDirectory(path);
		}
		
	}

#end