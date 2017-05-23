package com.imagination.util.window;
import com.imagination.core.type.Notifier;
import com.imagination.util.app.App;
import com.imagination.util.signals.Signal.Signal1;
import com.imagination.util.signals.Signal.Signal2;
import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
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
	
	@:isVar public var list(default, null) : Array<AirAppWindow> = [];
	
	var app:NativeApplication;
	var autoExit:Bool;

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
	public function windowAdded(nativeWindow:NativeWindow) : AirAppWindow
	{
		var window = new AirAppWindow(nativeWindow);
		list.push(window);
		onAdded.dispatch(window);
		
		window.closing.add(onWindowClose);
		return window;
	}
	
	private function onWindowClose(from:AirAppWindow, cancel:Void->Void):Void 
	{
		if (autoExit && app.openedWindows.length == 0){
			var exitCode = from.pendingError;
			from.pendingError = 0;
			App.exit(exitCode);
		}
		
		list.remove(from);
		onRemoved.dispatch(from);
	}
	
	function get_hideSupported():Bool 
	{
		return true;
	}
	
	function get_createSupported():Bool 
	{
		return true;
	}
	
	public function create():AirAppWindow{
		var options = new NativeWindowInitOptions();
		var window = new NativeWindow(options);
		return windowAdded(window);
	}
	
	public function hideAll():Void
	{
		for (window in list){
			window.visible.value = false;
		}
	}
	
	public function closeAll():Void
	{
		for (window in list){
			window.close();
		}
	}
	
	public function exit(exitCode:Int) 
	{
		NativeApplication.nativeApplication.exit(exitCode);
	}
}

class AirAppWindow
{
	public var closing:Signal2<AirAppWindow, Void->Void> = new Signal2<AirAppWindow, Void->Void>();
	
	public var focused:Notifier<Bool> = new Notifier(false);
	public var visible:Notifier<Bool> = new Notifier(false);
	public var title:Notifier<String> = new Notifier();
	public var alwaysInFront:Notifier<Bool> = new Notifier(false);
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	
	public var nativeWindow(get, null):NativeWindow;
	
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
		
		title.value = window.title;
		alwaysInFront.value= window.alwaysInFront;
		
		focused.change.add(onFocusedChanged);
		visible.change.add(onVisibleChanged);
		title.change.add(onTitleChanged);
		alwaysInFront.change.add(onAlwaysInFrontChanged);
		
		onWindowStateChange();
	}
	
	function onAlwaysInFrontChanged() 
	{
		window.alwaysInFront = alwaysInFront.value;
	}
	
	function onTitleChanged() 
	{
		window.title = title.value;
	}
	
	public function close():Void
	{
		window.close();
	}
	
	public function activate():Void
	{
		window.activate();
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
		if (!e.isDefaultPrevented()){
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
	
	function get_x():Float 
	{
		return window.x;
	}
	function set_x(value:Float):Float 
	{
		return window.x = value;
	}
	
	function get_y():Float 
	{
		return window.y;
	}
	function set_y(value:Float):Float 
	{
		return window.y = value;
	}
	
	function get_width():Float 
	{
		return window.width;
	}
	function set_width(value:Float):Float 
	{
		return window.width = value;
	}
	
	function get_height():Float 
	{
		return window.height;
	}
	function set_height(value:Float):Float 
	{
		return window.height = value;
	}
	
	function get_nativeWindow():NativeWindow 
	{
		return window;
	}
}