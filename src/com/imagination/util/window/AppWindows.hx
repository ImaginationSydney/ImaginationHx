package com.imagination.util.window;
import com.imagination.util.signals.Signal.Signal1;

/**
 * @author Thomas Byrne
 */

#if js

typedef NativeAppWindows = JsAppWindows;
typedef NativeAppWindow = com.imagination.util.window.JsAppWindows.JsAppWindow;
@:forward(createSupported, hideSupported, hideAll, closeAll, exit, lastWindowClosing)

#elseif air

typedef NativeAppWindows = AirAppWindows;
typedef NativeAppWindow = com.imagination.util.window.AirAppWindows.AirAppWindow;
@:forward(createSupported, hideSupported, hideAll, closeAll, exit, lastWindowClosing)

#elseif (lime || openfl)

typedef NativeAppWindows = LimeAppWindows;
typedef NativeAppWindow = com.imagination.util.window.LimeAppWindows.LimeAppWindow;
@:forward(createSupported, hideSupported, hideAll, closeAll, exit, lastWindowClosing)

#end

abstract AppWindows(NativeAppWindows) from NativeAppWindows
{

	public var onAdded(get, never):Signal1<AppWindow>;
	public var onRemoved(get, never):Signal1<AppWindow>;

	@public public var list(get, never):Array<AppWindow>;

	public function new()
	{
		this = new NativeAppWindows();
	}

	function get_list():Array<AppWindow>
	{
		return this.list;
	}

	public function create():AppWindow
	{
		return this.create();
	}

	public function foreach (onAdd:AppWindow->Void, onRemove:AppWindow->Void):Void
	{
		this.onAdded.add(onAdd);
		this.onRemoved.add(onRemove);
		for (window in list)
		{
			onAdd(window);
		}
	}
	
	function get_onAdded():Signal1<NativeAppWindow> 
	{
		return untyped this.onAdded;
	}
	
	function get_onRemoved():Signal1<NativeAppWindow> 
	{
		return untyped this.onRemoved;
	}
}

@:forward()
abstract AppWindow(NativeAppWindow) from NativeAppWindow to NativeAppWindow
{

}

typedef MouseInfo =
{
	stageX:Float,
	stageY:Float,
	shift:Bool,
}


@:enum
abstract WindowDisplayState(String){
	var MAXIMIZED = "maximized";
	var MINIMIZED = "minimized";
	var NORMAL = "normal";
}