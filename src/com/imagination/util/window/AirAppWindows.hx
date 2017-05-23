package com.imagination.util.window;
import com.imagination.core.type.Notifier;
import com.imagination.util.signals.Signal.Signal1;
import com.imagination.util.signals.Signal.Signal2;
import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.display.NativeWindowSystemChrome;
import flash.events.NativeWindowDisplayStateEvent;
import flash.display.NativeWindowDisplayState;
import openfl.events.Event;

/**
 * Currently only supported in AIR
 * 
 * @author Pete Shand
 * @author Thomas Byrne
 */
class AirAppWindows
{
	public var createSupported(get, null): Bool;
	public var hideSupported(get, null): Bool;
	public var lastWindowClosing:Signal1<Void->Void> = new Signal1<Void->Void>();
	
	public var onAdded = new Signal1<AirAppWindow>();
	public var onRemoved = new Signal1<AirAppWindow>();
	
	//private var _initialWindow:InitialWindow;
	//@:isVar public var initialWindow(default, null):InitialWindow;
	
	var app:NativeApplication;
	var autoExit:Bool;
	//var windowToError:Map<NativeWindow, Int> = new Map();
	var _list:Array<AirAppWindow> = [];

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
	public function windowAdded(nativeWindow:NativeWindow) 
	{
		var window = new AirAppWindow(nativeWindow);
		_list.push(window);
		onAdded.dispatch(window);
		
		window.closing.add(onWindowClose);
	}
	
	private function onWindowClose(from:AirAppWindow, cancel:Void->Void):Void 
	{
		var nativeWindow:NativeWindow = untyped e.currentTarget;
		if (autoExit && app.openedWindows.length == 0){
			//var exitCode = (windowToError.exists(window) ? windowToError.get(window) : 1);
			var exitCode = from.pendingError;
			from.pendingError = 0;
			App.exit(exitCode);
		}
		
		_list.remove(from);
		onRemoved.dispatch(from);
	}
	
	
	/*private function checkManifest(appXml:Xml) 
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
	}*/
	
	function get_hideSupported():Bool 
	{
		return true;
	}
	
	function get_createSupported():Bool 
	{
		return true;
	}
	
	public function create():NativeWindow{
		var window = new NativeWindow();
		windowAdded(window);
		return window;
	}
	
	public function hideAll():Void
	{
		for (window in _list){
			window.visible.value = false;
		}
	}
	
	public function exit(exitCode:Int) 
	{
		NativeApplication.nativeApplication.exit(errorCode);
	}
}

/*typedef InitialWindow =
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
}*/

class AirAppWindow
{
	public var closing:Signal2 = new Signal2<AirAppWindow, Void->Void>();
	
	public var focused:Notifier<Bool> = new Notifier(false);
	public var visible:Notifier<Bool> = new Notifier(false);
	
	var window:NativeWindow;
	var wasActive:Bool;
	var ignoreChanges:Bool;
	
	public var pendingError:Int = 0;
	
	
	public function new(window:NativeWindow) 
	{
		this.window = window;
		
		window.addEventListener(Event.CLOSING, onWindowClosing);
		window.addEventListener(Event.CLOSE, onWindowClose);
		window.addEventListener(Event.DEACTIVATE, onWindowDeactivate);
		
		window.addEventListener(Event.ACTIVATE, onWindowStateChange);
		window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowStateChange);
		
		focused.add(onFocusedChanged);
		visible.add(onVisibleChanged);
		
		onWindowStateChange();
	}
	
	function onFocusedChanged() 
	{
		if (ignoreChanges) return;
		if (focused.value){
			window.activate();
		}
	}
	
	function onVisibleChanged() 
	{
		if (ignoreChanges) return;
		if (!wasActive){
			onWindowDeactivate();
			return;
		}
		
		window.visible = visible.value;
	}
	
	private function onWindowStateChange(?e:Event):Void 
	{
		ignoreChanges = true;
		if (window.active) wasActive = true;
		visible.value = wasActive && window.displayState != NativeWindowDisplayState.MINIMIZED;
		focused.value = window.active;
		ignoreChanges = false;
	}
	
	private function onWindowDeactivate(?e:Event):Void 
	{
		ignoreChanges = true;
		visible.value = false;
		ignoreChanges = false;
	}
	
	private function onWindowClosing(e:Event):Void 
	{
		pendingError = (window.systemChrome == NativeWindowSystemChrome.NONE ? 1 : 0);
	}
	
	private function onWindowClose(e:Event):Void 
	{
		closing.dispatch(this, e.preventDefault);
		if (!e.isDefaultPrevented){
			removeListeners();
		}
	}
	
	function removeListeners() 
	{
		window.removeEventListener(Event.CLOSING, onWindowClosing);
		window.removeEventListener(Event.CLOSE, onWindowClose);
		window.removeEventListener(Event.DEACTIVATE, onWindowDeactivate);
		
		window.removeEventListener(Event.ACTIVATE, onWindowStateChange);
		window.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowStateChange);
	}
}