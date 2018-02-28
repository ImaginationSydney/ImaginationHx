package com.imagination.util.window;
import com.imagination.core.type.Notifier;
import com.imagination.util.signals.Signal;
import com.imagination.util.window.AppWindows.WindowDisplayState;
import lime.app.Config.WindowConfig;

import lime.app.Application;
import lime.ui.Window;
import lime.system.System;

/**
 * ...
 * @author Thomas Byrne
 */
//@:access(com.imagination.util.app.AppExit)
class LimeAppWindows
{
	public var createSupported(get, null): Bool;
	public var hideSupported(get, null): Bool;
	public var lastWindowClosing:Signal1<Void->Void> = new Signal1<Void->Void>();
	
	public var onAdded = new Signal1<LimeAppWindow>();
	public var onRemoved = new Signal1<LimeAppWindow>();
	
	@:isVar public var list(default, null) : Array<LimeAppWindow> = [];
	
	var app:Application;

	public function new() 
	{
		app = Application.current;
		for (window in app.windows){
			windowAdded(window);
		}
		//app.addEventListener("exiting", onAppExiting);
	}
	
	/*private function onAppExiting(e:Event):Void 
	{
		AppExit.onLastWindowClosing(e.preventDefault);
	}*/
	
	/**
	 * Must manually call this method when a new window is opened.
	 * There is no event fired when a new window is opened.
	 */
	public function windowAdded(nativeWindow:Window) : LimeAppWindow
	{
		var window = new LimeAppWindow(nativeWindow);
		list.push(window);
		onAdded.dispatch(window);
		
		window.closing.add(onWindowClose);
		return window;
	}
	
	private function onWindowClose(from:LimeAppWindow):Void 
	{
		/*if (autoExit && app.openedWindows.length == 0){
			//var exitCode = from.pendingError;
			//from.pendingError = 0;
			App.exit(0);
		}*/
		
		list.remove(from);
		onRemoved.dispatch(from);
		
		if (list.length == 0){
			lastWindowClosing.dispatch(function(){});
		}
	}
	
	function get_hideSupported():Bool 
	{
		return false;
	}
	
	function get_createSupported():Bool 
	{
		return true;
	}
	
	public function create():LimeAppWindow{
		var window = new Window();
		window.create(app);
		return windowAdded(window);
	}
	
	public function hideAll():Void
	{
		// ignore
	}
	
	public function closeAll():Void
	{
		for (window in list){
			window.close();
		}
	}
	
	public function exit(exitCode:Int) 
	{
		System.exit(exitCode);
	}
}

class LimeAppWindow
{
	public var closing:Signal1<LimeAppWindow> = new Signal1<LimeAppWindow>();
	
	public var onMove(get, null):Signal0;
	public var onResize(get, null):Signal0;
	
	public var focused:Notifier<Bool> = new Notifier(false);
	//public var visible:Notifier<Bool> = new Notifier(false);
	public var title:Notifier<String> = new Notifier();
	//public var alwaysInFront:Notifier<Bool> = new Notifier(false);
	
	public var x(get, null):Float;
	public var y(get, null):Float;
	public var width(get, null):Float;
	public var height(get, null):Float;
	
	public var nativeWindow(get, null):Window;
	
	public var contentsScaleFactor(get, null):Float;
	
	@:isVar public var displayState(default, null):Notifier<WindowDisplayState> = new Notifier<WindowDisplayState>();
	
	public var stage(get, null):openfl.display.Stage;
	
	var window:Window;
	var windowActive:Bool;
	var ignoreChanges:Bool;
	
	//public var pendingError:Int = 0;
	
	
	public function new(window:Window) 
	{
		this.window = window;
		
		
		window.onClose.add(onWindowClose);
		window.onActivate.add(onWindowActivate);
		window.onDeactivate.add(onWindowDeactivate);
		window.onMinimize.add(onWindowStateChange);
		window.onFullscreen.add(onWindowStateChange);
		window.onRestore.add(onWindowStateChange);
		
		title.value = window.title;
		//alwaysInFront.value= window.alwaysInFront;
		
		focused.change.add(onFocusedChanged);
		//visible.change.add(onVisibleChanged);
		title.change.add(onTitleChanged);
		//alwaysInFront.change.add(onAlwaysInFrontChanged);
		
		onWindowStateChange();
	}
	
	/*function onAlwaysInFrontChanged() 
	{
		window.alwaysInFront = alwaysInFront.value;
	}*/
	
	function onTitleChanged() 
	{
		window.title = title.value;
	}
	
	/*inline public function startMove():Void
	{
		window.startMove();
	}
	inline public function startResize(resize:WindowResize):Void
	{
		window.startResize(resize);
	}*/
	
	public function restore():Void
	{
		if(window.minimized)
			window.minimized = false;
		else if (window.maximized)
			window.maximized = false;
	}
	
	public function close():Void
	{
		window.close();
	}
	
	/*public function activate():Void
	{
		window.activate();
	}*/
	
	function onFocusedChanged() 
	{
		if (ignoreChanges) return;
		/*if (focused.value){
			window.activate();
		}*/
	}
	
	/*function onVisibleChanged() 
	{
		if (ignoreChanges) return;
		if (!windowActive){
			onWindowDeactivate();
			return;
		}
		
		//if (!visible.value) return;
		window.visible = visible.value;
	}*/
	
	private function onWindowStateChange():Void 
	{
		ignoreChanges = true;
		if (windowActive) windowActive = true;
		//visible.value = windowActive && !window.minimized;
		focused.value = windowActive;
		ignoreChanges = false;
		
		if (window.minimized){
			displayState.value = WindowDisplayState.MINIMIZED;
		}else if(window.maximized){
			displayState.value = WindowDisplayState.MAXIMIZED;
		}else{
			displayState.value = WindowDisplayState.NORMAL;
		}
	}
	function onWindowActivate() 
	{
		windowActive = true;
		onWindowStateChange();
	}
	private function onWindowDeactivate():Void 
	{
		ignoreChanges = true;
		windowActive = false;
		//visible.value = false;
		ignoreChanges = false;
	}
	
	/*private function onWindowClosing(e:Event):Void 
	{
		pendingError = (window.systemChrome == WindowSystemChrome.NONE ? 1 : 0);
	}*/
	
	private function onWindowClose():Void 
	{
		closing.dispatch(this);
		removeListeners();
	}
	
	function removeListeners() 
	{
		window.onClose.remove(onWindowClose);
		window.onActivate.remove(onWindowStateChange);
		window.onMinimize.remove(onWindowStateChange);
		window.onFullscreen.remove(onWindowStateChange);
		window.onRestore.remove(onWindowStateChange);
		window.onDeactivate.remove(onWindowDeactivate);
		window.onMove.remove(onNativeMove);
		window.onResize.remove(onNativeResize);
	}
	
	function get_x():Float 
	{
		return window.x * window.scale;
	}
	
	function get_contentsScaleFactor():Float 
	{
		return window.scale;
	}
	
	function get_y():Float 
	{
		return window.y * window.scale;
	}
	
	function get_width():Float 
	{
		return window.width * window.scale;
	}
	
	function get_height():Float 
	{
		return window.height * window.scale;
	}
	
	function get_stage():openfl.display.Stage 
	{
		return window.stage;
	}
	
	public function moveTo(x:Float, y:Float):Void
	{
		var scale = window.scale;
		
		window.x = Math.round(x / scale);
		window.y = Math.round(y / scale);
		
		if (scale != window.scale){
			// moved to a different density screen
			scale = window.scale;
			window.x = Math.round(x / scale);
			window.y = Math.round(y / scale);
		}
		
		onMove.dispatch();
	}
	
	function get_nativeWindow():Window 
	{
		return window;
	}
	
	public function resizeTo(width:Float, height:Float):Void
	{
		var scale = window.scale;
		
		window.width = Math.round(width / scale);
		window.height = Math.round(height / scale);
		
		if (scale != window.scale){
			// moved to a different density screen
			scale = window.scale;
			window.width = Math.round(width / scale);
			window.height = Math.round(height / scale);
		}
		
		onResize.dispatch();
	}
	
	public function setBounds(x:Float, y:Float, width:Float, height:Float):Void
	{
		var scale = window.scale;
		
		window.x = Math.round(x / scale);
		window.y = Math.round(y / scale);
		window.width = Math.round(width / scale);
		window.height = Math.round(height / scale);
		
		if (scale != window.scale){
			// moved to a different density screen
			scale = window.scale;
			window.x = Math.round(x / scale);
			window.y = Math.round(y / scale);
			window.width = Math.round(width / scale);
			window.height = Math.round(height / scale);
		}
		
		onMove.dispatch();
		onResize.dispatch();
	}
	
	function get_onMove():Signal0 
	{
		if (onMove == null){
			onMove = new Signal0();
			window.onMove.add(onNativeMove);
		}
		return onMove;
	}
	function get_onResize():Signal0 
	{
		if (onResize == null){
			onResize = new Signal0();
			window.onResize.add(onNativeResize);
		}
		return onResize;
	}
	
	private function onNativeMove(x:Float, y:Float):Void 
	{
		onMove.dispatch();
	}
	private function onNativeResize(w:Float, h:Float):Void 
	{
		onResize.dispatch();
	}
}