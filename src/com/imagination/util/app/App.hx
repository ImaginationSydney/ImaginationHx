package com.imagination.util.app;
import com.imagination.util.app.AppExit.ExitContinue;
import haxe.macro.Compiler;
import haxe.macro.Context;

#if openfl
import openfl.Lib;
import openfl.display.Stage;
#end

#if flash
import flash.desktop.NativeApplication;
import flash.events.Event;

#elseif js
import js.html.Event;

#end

/**
 * ...
 * @author Thomas Byrne
 */
@:access(com.imagination.util.app.AppWindows)
class App
{
	static private var appId:String;
	static private var version:String;
	static private var appFilename:String;
	
	#if flash
	@:isVar static public var windows(get, null):AppWindows = new AppWindows();
	static function get_windows():AppWindows 
	{
		checkManifest();
		return windows;
	}
	#end
	
	static private var isSetup:Bool;
	
	public static function getAppId():String 
	{
		checkManifest();
		return appId;
	}
	
	static public function getAppFilename() : String
	{
		checkManifest();
		return appFilename;
	}
	
	static public function getVersion() : String
	{
		checkManifest();
		return version;
	}
	
	static private function setup() 
	{
		if (isSetup) return;
		isSetup = true;
		
		AppExit.setup();
	}
	
	static public function exit(errorCode:Int = 0) 
	{
		AppExit.exit(errorCode);
	}
	
	static public function addExitConfirmer(handler:Int -> ExitContinue -> Void) 
	{
		AppExit.addExitConfirmer(handler);
		
	}
	static public function removeExitConfirmer(handler:Int -> ExitContinue -> Void) 
	{
		AppExit.removeExitConfirmer(handler);
	}
	
	
	static public function addExitCleanup(handler:Int -> (Void -> Void) -> Void) 
	{
		AppExit.addExitCleanup(handler);
		
	}
	static public function removeExitCleanup(handler:Int -> (Void -> Void) -> Void) 
	{
		AppExit.removeExitCleanup(handler);
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
		windows.checkManifest(appXml);
		
		#elseif openfl
			var stage:Stage = Lib.current.stage;
			if (stage == null || stage.window == null) return;
			
			appId = stage.window.application.config.packageName;
			appFilename = stage.window.application.config.name;
			version = stage.window.application.config.version;
		#end
		
	}
}