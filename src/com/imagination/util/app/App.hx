package com.imagination.util.app;
import haxe.macro.Compiler;
import haxe.macro.Context;

#if openfl
import openfl.Lib;
import openfl.display.Stage;
#end

#if flash
import flash.desktop.NativeApplication;
import flash.events.Event;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class App
{
	static private var appId:String;
	static private var version:String;
	static private var appFilename:String;
	
	static private var exitHandlers:Array<ExitHandler>;
	static private var ignoreExit:Bool;
	
	public static function getAppId():String 
	{
		checkManifest();
		return appId;
	}
	
	static public function getAppFilename() 
	{
		checkManifest();
		return appFilename;
	}
	
	static public function getVersion() 
	{
		checkManifest();
		return version;
	}
	
	static public function exit() 
	{
		#if flash
		NativeApplication.nativeApplication.exit();
		#else
			// NativeApplication not supported
		#end
	}
	
	static public function addExitHandler(handler:ExitContinue -> Void) 
	{
		
		if (exitHandlers == null) {
			exitHandlers = [];
			#if flash
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			#else
				// NativeApplication not supported
			#end
		}
		exitHandlers.push(handler);
		
	}
	
	static public function removeExitHandler(handler:ExitContinue -> Void) 
	{
		exitHandlers.remove(handler);
	}
	
	#if flash
	static private function onExiting(e:Event):Void 
	{
		if (ignoreExit) return;
		if (exitHandlers.length > 0) {
			e.preventDefault();
			
			callExitHandler(0);
		}
	}
	#end
	
	static private function callExitHandler(ind:Int) 
	{
		if (ind >= exitHandlers.length) {
			#if flash
				ignoreExit = true;
				NativeApplication.nativeApplication.exit();
				ignoreExit = false;
			#else
				// NativeApplication not supported
			#end
		}else {
			var exitHandler:ExitHandler = exitHandlers[ind];
			exitHandler(doExitContinue.bind(_, ind + 1));
		}
	}
	
	static private function doExitContinue(cont:Bool, ind:Int) 
	{
		if (!cont) return;
		callExitHandler(ind);
	}
	
	
	static private function checkManifest() 
	{
		if (appId != null) return;
		
		
		#if flash
		var appXml:Xml = Xml.parse(flash.desktop.NativeApplication.nativeApplication.applicationDescriptor.toXMLString());
		var idNode = appXml.firstChild().elementsNamed("id");
		while(idNode.hasNext()){
			appId = idNode.next().firstChild().nodeValue;
			break;
		}
		var filenameNode = appXml.firstChild().elementsNamed("filename");
		while(filenameNode.hasNext()){
			appFilename = filenameNode.next().firstChild().nodeValue;
			break;
		}
		var versionNode = appXml.firstChild().elementsNamed("versionNumber");
		while(versionNode.hasNext()){
			version = versionNode.next().firstChild().nodeValue;
			break;
		}
		#elseif openfl
			var stage:Stage = Lib.current.stage;
			if (stage == null || stage.window == null) return;
			
			appId = stage.window.application.config.packageName;
			appFilename = stage.window.application.config.name;
			version = stage.window.application.config.version;
		#end
	}
}


typedef ExitHandler = ExitContinue -> Void;
typedef ExitContinue = Bool -> Void;