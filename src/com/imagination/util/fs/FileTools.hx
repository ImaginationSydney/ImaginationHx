package com.imagination.util.fs;
import com.imagination.util.data.JSON;
import haxe.io.Bytes;
import haxe.io.BytesData;

#if sys
import sys.FileSystem;
#else
import openfl.utils.ByteArray;
import com.imagination.air.util.EventListenerTracker;
#end

using StringTools;

/**
 * ...
 * @author Thomas Byrne
 */
#if air

	import flash.filesystem.File as FlFile;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	class FileTools
	{
		static public var DEFAULT_WRITE_CONFIRM:String -> String -> Bool = function(str1:String, str2:String) : Bool return str1 == str2;
		static public var DEFAULT_READ_CONFIRM:String -> Bool = function(str:String) : Bool return str != "";
		
		static public var JSON_READ_CONFIRM:String -> Bool = function(str:String) : Bool try { JSON.parse(str); return true; } catch (e:Dynamic){ return false; };
		
		static var temp:FlFile;
		
		static function __init__():Void
		{
			temp = new FlFile();
		}
		
		static public function getBytes(path:String) : Bytes
		{
			temp.nativePath = path;
			var stream:FileStream =  new FileStream();
			stream.open(temp, FileMode.READ);
			var ret = new BytesData();
			stream.readBytes(ret);
			stream.close();
			return Bytes.ofData(ret);
		}
		public static function getContent(path:String):String
		{
			temp.nativePath = path;
			var stream:FileStream =  new FileStream();
			stream.open(temp, FileMode.READ);
			var ret:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			return ret;
		}
		
		public static function getContentWithConfirm(path:String, ?confirm:String -> Bool):String
		{
			if (confirm == null) confirm = DEFAULT_READ_CONFIRM;
			
			try{
				var ret = getContent(path);
				if (confirm(ret)) return ret;
			}catch (e:Dynamic){}
			
			var temp:String = path + ".tmp";
			if(exists(temp)){
				try{
					var ret = getContent(temp);
					if (confirm(ret)) return ret;
				}catch (e:Dynamic){}
			}
			
			return null;
		}
		
		public static function saveContentWithConfirm(path:String, content:String, ?confirm:String -> String -> Bool):Void
		{
			if (confirm == null) confirm = DEFAULT_WRITE_CONFIRM;
			
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
		
		public static function getBinaryAsync(path:String, onComplete:Bytes->Void, ?onFail:String->Void):Void
		{
			temp.nativePath = path;
			var stream:FileStream =  new FileStream();
			var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
			listenerTracker.addEventListener(Event.COMPLETE, readSuccessHandlerBytes.bind(_, stream, listenerTracker, onComplete) );
			listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, readFailHandler.bind(_, stream, listenerTracker, onFail) );
			stream.openAsync(temp, FileMode.READ);
		}
		
		static private function readSuccessHandlerBytes(e:Event, stream:FileStream, listenerTracker:EventListenerTracker, onComplete:Bytes->Void):Void 
		{
			listenerTracker.removeAllEventListeners();
			var ret:BytesData = new BytesData(); 
			stream.readBytes(ret, 0, stream.bytesAvailable);
			stream.close();
			onComplete(Bytes.ofData(ret));
		}
		
		public static function getContentAsync(path:String, onComplete:String->Void, ?onFail:String->Void):Void
		{
			temp.nativePath = path;
			var stream:FileStream =  new FileStream();
			var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
			listenerTracker.addEventListener(Event.COMPLETE, readSuccessHandlerStr.bind(_, stream, listenerTracker, onComplete) );
			listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, readFailHandler.bind(_, stream, listenerTracker, onFail) );
			stream.openAsync(temp, FileMode.READ);
		}
		
		static private function readSuccessHandlerStr(e:Event, stream:FileStream, listenerTracker:EventListenerTracker, onComplete:String->Void):Void 
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
		
		public static function saveContentAsyncWithConfirm(path:String, content:String, ?confirm:String -> String -> Bool, ?onComplete:Void->Void, ?onFail:String->Void):Void
		{
			if (confirm == null) confirm = DEFAULT_WRITE_CONFIRM;
			var temp = path + ".tmp";
			FileTools.saveContentAsync(temp, content, function() {
				FileTools.getContentAsync(temp, function (savedContent:String) {
					var pass = false;
					try{
						pass = confirm(content, savedContent);
					}catch (e:Dynamic){}
					
					if (pass) {
						try{
							var file:File = new File(path);
							var temp:File = new File(temp);
							temp.copyToAsync(file, true);
						}catch (e:Dynamic){
							if (onFail != null) onFail(Std.string(e));
						}
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
		
		public static function saveBinary(path:String, binary:ByteArray):Bool
		{
			try{
				temp.nativePath = path;
				confirmParent(temp);
				var stream:FileStream =  new FileStream();
				stream.open(temp, FileMode.WRITE);
				binary.position = 0;
				stream.writeBytes(binary);
				stream.close();
				return true;
			}catch (e:Dynamic){
				return false;
			}
		}
		
		public static function saveBinaryAsync(path:String, binary:ByteArray, ?onComplete:Void->Void, ?onFail:String->Void):Void
		{
			try{
				temp.nativePath = path;
				confirmParent(temp);
				var stream:FileStream =  new FileStream();
				var listenerTracker:EventListenerTracker = new EventListenerTracker(stream);
				listenerTracker.addEventListener(Event.CLOSE, writeSuccessHandler.bind(_, listenerTracker, onComplete) );
				listenerTracker.addEventListener(IOErrorEvent.IO_ERROR, writeFailHandler.bind(_, listenerTracker, onFail) );
				stream.openAsync(temp, FileMode.WRITE);
				binary.position = 0;
				stream.writeBytes(binary);
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
		
		
		static public function findExistingPath(paths:Array<String>) : Null<String>
		{
			for (path in paths){
				if (FileTools.exists(path)){
					return path;
				}
			}
			return null;
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
		inline public static function deleteFile(path : String) : Bool
		{
			if (!exists(path)) return true;
			try{
				temp.nativePath = path;
				temp.deleteFile();
				return true;
			}catch (e:Dynamic){
				// failed to delete
				return false;
			}
		}
		
		static public function deleteDirectory(path : String, deleteDirectoryContents:Bool = false) :Void
		{
			if (!exists(path)) return;
			temp.nativePath = path;
			temp.deleteDirectory(deleteDirectoryContents);
		}
		
		static public function deleteDirectoryAsync(path : String, deleteDirectoryContents:Bool = false, ?onComplete:Bool->Void) :Void
		{
			if (!exists(path)) return;
			temp.nativePath = path;
			if (onComplete != null){
				var eventTracker = new EventListenerTracker(temp);
				eventTracker.addEventListener(Event.COMPLETE, function(e){
					eventTracker.removeAllEventListeners();
					onComplete(false);
				});
				eventTracker.addEventListener(IOErrorEvent.IO_ERROR, function(e){
					eventTracker.removeAllEventListeners();
					onComplete(false);
				});
			}
			try{
				temp.deleteDirectoryAsync(deleteDirectoryContents);
			}catch (e:Dynamic){
				if (onComplete != null){
					onComplete(false);
				}
			}
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
		
		static public function uriToPlatformPath(path:String) : String
		{
			temp.url = path;
			return temp.nativePath;
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
		public static function getContentAsync(path:String, onComplete:String->Void, ?onFail:String->Void):Void
		{
			var data:String;
			try{
				data = sys.io.File.getContent(path);
			}catch (e:Dynamic){
				if (onFail != null) onFail(e);
				return;
			}
			onComplete(data);
		}
		public inline static function saveContent(path:String, content:String):Void
		{
			return sys.io.File.saveContent(path, content);
		}
		public static function saveContentAsync(path:String, content:String, ?onComplete:Void->Void, ?onFail:String->Void):Void
		{
			try{
				sys.io.File.saveContent(path, content);
			}catch (e:Dynamic){
				if (onFail != null) onFail(e);
				return;
			}
			if(onComplete != null) onComplete();
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