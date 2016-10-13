package com.imagination.util.app;

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
 * @author P.J.Shand
 */
@:allow(com.imagination.util.app.App)
class AppExit
{
	static private var exitConfirmers:Array<ExitConfirmer> = [];
	static private var exitCleanups:Array<ExitCleanup> = [];
	static private var ignoreExit:Bool;
	static private var callingExit:Bool;
	static private var exitingErrorCode:Null<Int>;
	
	public function new() 
	{
		
	}
	
	static public function setup() 
	{
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
	
	static public function exit(errorCode:Int = 0) 
	{
		if (exitingErrorCode != null || ignoreExit){
			return;
		}
		exitingErrorCode = errorCode;
		handleExitEvent(errorCode, function(){});
		/*#if flash
			var event = new Event(Event.EXITING, false, true);
			NativeApplication.nativeApplication.dispatchEvent(event);
			if (!event.isDefaultPrevented()){
				finaliseExit(errorCode);
			}
		#else
			// NativeApplication not supported
		#end*/
		exitingErrorCode = null;
	}
	
	static private function checkConfirmers() 
	{
		
	}
	
	static public function addExitConfirmer(handler:Int -> ExitContinue -> Void) 
	{
		if (exitConfirmers == null) {
			setup();
		}
		exitConfirmers.push(handler);
		
	}
	static public function removeExitConfirmer(handler:Int -> ExitContinue -> Void) 
	{
		exitConfirmers.remove(handler);
	}
	
	static public function addExitCleanup(handler:Int -> (Void -> Void) -> Void) 
	{
		if (exitCleanups == null) {
			setup();
		}
		exitCleanups.push(handler);
		
	}
	static public function removeExitCleanup(handler:Int -> (Void -> Void) -> Void) 
	{
		exitCleanups.remove(handler);
	}
	
	#if flash
	static private function onBeginExit(e:Event):Void 
	{
		trace("onBeginExit: " + exitingErrorCode);
		var errorCode:Int;
		if (exitingErrorCode == null){
			errorCode = 1; // This exit wasn't triggered by App.exit, so we'll assume it's an error.
		}else{
			errorCode = exitingErrorCode;
		}
		trace("onBeginExit: "+errorCode+" "+exitingErrorCode);
		handleExitEvent(errorCode, e.preventDefault);
	}
	#elseif js
	static private function onBeginExit(e:Event):Bool 
	{
		var errorCode:Int;
		if (exitingErrorCode == null){
			errorCode = 1; // This exit wasn't triggered by App.exit, so we'll assume it's an error.
		}else{
			errorCode = exitingErrorCode;
		}
		if (!handleExitEvent(errorCode, e.preventDefault)){
			var res = js.Browser.window.confirm("You will loose unsaved work"); // This message will be replaced by most browsers
			return res;
		}else{
			return true;
		}
	}
	static private function onExit(e:Event) 
	{
		callExitCleanup(0, 0);
	}
	#end
	
	static private function handleExitEvent(errorCode:Int, preventDefault:Void->Void) :Bool
	{
		if (ignoreExit) return false;
		if (exitConfirmers.length > 0 || exitCleanups.length > 0) {
			callingExit = true;
			preventDefault();
			callExitConfirmer(errorCode, 0);
			return callingExit;
		}else{
			finaliseExit(errorCode);
			return true;
		}
	}
	
	static private function callExitConfirmer(errorCode:Int, ind:Int) 
	{
		if (ind >= exitConfirmers.length) {
			#if flash
				ignoreExit = true;
				// hide windows
				for (win in NativeApplication.nativeApplication.openedWindows){
					win.visible = false;
				}
				callExitCleanup(errorCode, 0);
			#else
				// NativeApplication not supported
			#end
		}else {
			var exitConfirmer:ExitConfirmer = exitConfirmers[ind];
			exitConfirmer(errorCode, doExitContinue.bind(_, errorCode, ind + 1));
		}
	}
	
	static private function doExitContinue(cont:Bool, errorCode:Int, ind:Int) 
	{
		if (!cont){
			return;
		}
		callExitConfirmer(errorCode, ind);
	}
	
	static private function callExitCleanup(errorCode:Int, ind:Int) 
	{
		if (ind >= exitCleanups.length) {
			callingExit = false;
			finaliseExit(errorCode);
		}else {
			var exitCleanup:ExitCleanup = exitCleanups[ind];
			exitCleanup(errorCode, callExitCleanup.bind(errorCode, ind + 1));
		}
	}
	
	static private function finaliseExit(errorCode:Int) 
	{
		#if flash
			for (window in NativeApplication.nativeApplication.openedWindows){
				window.close();
			}
			NativeApplication.nativeApplication.exit(errorCode);
		#else
			// NativeApplication not supported
		#end
	}
}

typedef ExitConfirmer = Int -> ExitContinue -> Void;
typedef ExitContinue = Bool -> Void;
typedef ExitCleanup = Int -> (Void -> Void) -> Void;