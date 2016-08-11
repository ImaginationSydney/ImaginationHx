package com.imagination.util.app;
import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.display.NativeWindowSystemChrome;
import openfl.events.Event;

/**
 * Currently only supported in AIR
 * 
 * @author Pete Shand
 * @author Thomas Byrne
 */
class AppWindows
{
	
	private var _initialWindow:InitialWindow;
	@:isVar public var initialWindow(default, null):InitialWindow;
	
	var app:NativeApplication;
	var autoExit:Bool;
	var windowToError:Map<NativeWindow, Int> = new Map();

	public function new() 
	{
		app = NativeApplication.nativeApplication;
		autoExit = app.autoExit;
		app.autoExit = false;
		for (window in app.openedWindows){
			windowAdded(window);
		}
	}
	
	/**
	 * Must manually call this method when a new window is opened.
	 * There is no event fired when a new window is opened.
	 */
	public function windowAdded(window:NativeWindow) 
	{
		window.addEventListener(Event.CLOSE, onWindowClose);
		window.addEventListener(Event.CLOSING, onWindowClosing);
	}
	
	private function onWindowClosing(e:Event):Void 
	{
		var window:NativeWindow = untyped e.currentTarget;
		windowToError.set(window, window.systemChrome == NativeWindowSystemChrome.NONE ? 1 : 0);
	}
	
	private function onWindowClose(e:Event):Void 
	{
		var window:NativeWindow = untyped e.currentTarget;
		window.removeEventListener(Event.CLOSE, onWindowClose);
		window.removeEventListener(Event.CLOSING, onWindowClosing);
		if (autoExit && app.openedWindows.length == 0){
			var exitCode = (windowToError.exists(window) ? windowToError.get(window) : 1);
			App.exit(exitCode);
		}
	}
	
	
	private function checkManifest(appXml:Xml) 
	{
		initialWindow = {};
		#if flash
		for (child in appXml.elements()) 
		{
			for (child2 in child.elements()) 
			{
				if (child2.nodeName == "initialWindow") {
					for (child3 in child2.elements()) 
					{
						if (child3.nodeName == "content") initialWindow.content = child3.firstChild().nodeValue;
						if (child3.nodeName == "depthAndStencil") initialWindow.depthAndStencil = child3.firstChild().nodeValue == "true";
						if (child3.nodeName == "maximizable") initialWindow.maximizable = child3.firstChild().nodeValue == "true";
						if (child3.nodeName == "minimizable") initialWindow.minimizable = child3.firstChild().nodeValue == "true";
						if (child3.nodeName == "renderMode") initialWindow.renderMode = child3.firstChild().nodeValue;
						if (child3.nodeName == "resizable") initialWindow.resizable = child3.firstChild().nodeValue == "true";
						if (child3.nodeName == "systemChrome") initialWindow.systemChrome = child3.firstChild().nodeValue;
						if (child3.nodeName == "title") initialWindow.title = child3.firstChild().nodeValue;
						if (child3.nodeName == "transparent") initialWindow.transparent = child3.firstChild().nodeValue == "true";
						if (child3.nodeName == "visible") initialWindow.visible = child3.firstChild().nodeValue == "true";
					}
				}	
			}
		}
		#end
	}
}

typedef InitialWindow =
{
	?title:String,
	?content:String,
	?systemChrome:String,
	?transparent:Bool,
	?visible:Bool,
	?minimizable:Bool,
	?maximizable:Bool,
	?resizable:Bool,
	?renderMode:String,
	?depthAndStencil:Bool
}