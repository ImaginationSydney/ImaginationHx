package com.imagination.util.screen;

/**
 * ...
 * @author Thomas Byrne
 */
class ScreenInfo
{
	var initPixelDensity:Bool;
	var pixelDensity:Float = 1.0;
	public function getPixelDensity() 
	{
		
		#if html5
			if (!initPixelDensity){
				initPixelDensity = true;
				var pixelDensityScale:Null<Float> = js.Browser.window.devicePixelRatio;
				if (pixelDensityScale != null)pixelDensity = pixelDensityScale;
			}
		#end
		
		return pixelDensity;
	}
	
}