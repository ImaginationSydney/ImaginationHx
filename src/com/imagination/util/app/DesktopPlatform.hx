package com.imagination.util.app;
import com.imagination.util.app.Platform.SystemName;

#if openfl
import openfl.system.Capabilities;
#elseif flash
import flash.system.Capabilities;
#end


/**
 * ...
 * @author Thomas Byrne
 */
class DesktopPlatform
{
	static var _inited:Bool;
	static var _systemName:SystemName;
	static var _systemVersion:String;
	
	static var _is64Bit:Bool;


	static public function init() 
	{
		if (_inited) return;
		
		_inited = true;
		
		#if sys
		var os = Sys.systemName();
		#else
		var os = Capabilities.os;
		#end
		
		if (os.indexOf("Win") !=-1){
			_systemName = SystemName.Windows;
			#if openfl
			_systemVersion = os.substr(8);
			#end
			
		}else if (os.indexOf("Mac") !=-1){
			_systemName = SystemName.Mac;
			#if openfl
			_systemVersion = os.substr(7);
			#end
			
		}else if (os.indexOf("Linux") !=-1){
			_systemName = SystemName.Linux;
			
		}else{
			_systemName = SystemName.Other;
		}
		
		#if sys
		_is64Bit = _isMac;
		#else 
		_is64Bit = Capabilities.supports64BitProcesses;
		#end
	}
	
	public static function systemName() : SystemName
	{
		return _systemName;
	}
	public static function systemVersion() : String
	{
		return _systemVersion;
	}
	
	public static function isWindows():Bool 
	{
		init();
		return _systemName == SystemName.Windows;
	}
	public static function isMac():Bool 
	{
		init();
		return _systemName == SystemName.Mac;
	}
	
	public static function is64Bit():Bool 
	{
		init();
		return _is64Bit;
	}
	
	public static function isMobile():Bool 
	{
		return false;
	}
}