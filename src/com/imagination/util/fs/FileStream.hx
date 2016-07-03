package com.imagination.util.fs;
import com.imagination.util.fs.File;


/**
 * ...
 * @author Thomas Byrne
 */
#if air3


	typedef FileStream = flash.filesystem.FileStream;
	
#elseif js
	
	class FileStream
	{
		private var openFile:File;
		public function new()
		{
			
		}
		
		public function open(openFile:File, fileMode:Dynamic) 
		{
			this.openFile = openFile;
			
		}
		
		public function writeUTFBytes(jsonStr:String):String
		{
			if (openFile == null) return null;
			return cast Reflect.setProperty(openFile.sharedObject.data, "data", jsonStr);
		}
		
		public function close() 
		{
			if (openFile != null) {
				openFile.sharedObject.flush();
			}
			openFile = null;
		}
	}
	
#end