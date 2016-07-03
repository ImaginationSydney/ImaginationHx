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

#elseif js
import js.html.Event;

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
	
	static private var exitConfirmers:Array<ExitConfirmer>;
	static private var exitCleanups:Array<ExitCleanup>;
	static private var ignoreExit:Bool;
	static private var callingExit:Bool;
	static private var isSetup:Bool;
	
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
	
	static private function setup() 
	{
		if (isSetup) return;
		isSetup = true;
	
		exitConfirmers = [];
		exitCleanups = [];
		
		#if flash
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onBeginExit);
		#elseif js
			js.Browser.window.addEventListener("beforeunload", onBeginExit);
			js.Browser.window.addEventListener("unload", onExit);
		#else
			// NativeApplication not supported
		#end
	}
	
	static public function exit() 
	{
		#if flash
			NativeApplication.nativeApplication.exit();
		#else
			// NativeApplication not supported
		#end
	}
	
	static public function addExitConfirmer(handler:ExitContinue -> Void) 
	{
		
		if (exitConfirmers == null) {
			setup();
		}
		exitConfirmers.push(handler);
		
	}
	static public function removeExitConfirmer(handler:ExitContinue -> Void) 
	{
		exitConfirmers.remove(handler);
	}
	
	
	static public function addExitCleanup(handler:Void -> Void) 
	{
		
		if (exitCleanups == null) {
			setup();
		}
		exitCleanups.push(handler);
		
	}
	static public function removeExitCleanup(handler:Void -> Void) 
	{
		exitCleanups.remove(handler);
	}
	
	#if flash
	static private function onBeginExit(e:Event):Void 
	{
		handleExitEvent(e.preventDefault);
	}
	#elseif js
	static private function onBeginExit(e:Event):Bool 
	{
		if (!handleExitEvent(e.preventDefault)){
			var res = js.Browser.window.confirm("You will loose unsaved work"); // This message will be replaced by most browsers
			return res;
		}else{
			return true;
		}
	}
	static private function onExit(e:Event) 
	{
		doCleanup();
	}
	#end
	
	
	
	static private function handleExitEvent(preventDefault:Void->Void) :Bool
	{
		if (ignoreExit) return false;
		if (exitConfirmers.length > 0) {
			callingExit = true;
			callExitConfirmer(0);
			if(callingExit) preventDefault();
			return callingExit;
		}else{
			return true;
		}
	}
	
	static private function callExitConfirmer(ind:Int) 
	{
		if (ind >= exitConfirmers.length) {
			callingExit = false;
			#if flash
				ignoreExit = true;
				doCleanup();
				NativeApplication.nativeApplication.exit();
				ignoreExit = false;
			#else
				// NativeApplication not supported
			#end
		}else {
			var ExitConfirmer:ExitConfirmer = exitConfirmers[ind];
			ExitConfirmer(doExitContinue.bind(_, ind + 1));
		}
	}
	
	static private function doExitContinue(cont:Bool, ind:Int) 
	{
		if (!cont){
			return;
		}
		callExitConfirmer(ind);
	}
	
	static private function doCleanup() 
	{
		for (cleanup in exitCleanups){
			try{
			cleanup();
			}catch(e:Dynamic){}
		}
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


typedef ExitConfirmer = ExitContinue -> Void;
typedef ExitContinue = Bool -> Void;
typedef ExitCleanup = Void -> Void;