package com.imagination.util.time;
import openfl.Lib;

/**
 * ...
 * @author P.J.Shand
 * @author Tom Byrne
 */
class GlobalTime
{
	static private inline var MINUTE = (1000 * 60);
	static private inline var HOUR = (MINUTE * 60);
	static private inline var DAY = (HOUR * 24);
	
	@:isVar static public var offset:Float = 0;						// in Milliseconds
	@:isVar static public var timezoneOffset:Float = 0;   			// In Minutes
	@:isVar static public var pause(default, set):Bool = false;
	
	@:isVar static public var defaultTimezoneOffset(get, null):Float; // This can be used to reset the timezone to match the system, In Minutes
	
	static private var _initTimeUtc:Float;
	static private var _startTimer:Float;
	static private var _pausedElapsed:Float = 0;
	static private var _defaultTimezoneOffset:Float = 0;
	static private var _dummyDate:Date;
	
	static public var inited:Bool = false;
	public static function init():Void
	{
		if (inited) return;
		
		_dummyDate = Date.now();
		_initTimeUtc = _dummyDate.getTime();
		_startTimer = Lib.getTimer();
		
		#if (flash || js)
			_defaultTimezoneOffset = untyped _dummyDate.getTimezoneOffset();
			timezoneOffset = _defaultTimezoneOffset;
		#end
		
		inited = true;
	}
	
	
	public static function localToGlobal(time:Float, ?timezoneOffset:Float):Float
	{
		if (timezoneOffset == null) timezoneOffset = GlobalTime.timezoneOffset;
		return time + timezoneOffset * MINUTE;
	}
	public static function globalToLocal(time:Float, ?timezoneOffset:Float):Float
	{
		if (timezoneOffset == null) timezoneOffset = GlobalTime.timezoneOffset;
		return time - timezoneOffset * MINUTE;
	}
	
	public static function now(?ret:Date):Date
	{
		return dateFromTime(nowTimeUtc(), timezoneOffset, ret);
	}
	public static function nowInTimezone(timezoneOffset:Float, ?ret:Date):Date
	{
		return dateFromTime(nowTimeUtc(), timezoneOffset, ret);
	}
	public static function dateFromTime(utcTime:Float, ?timezoneOffset:Float, ?ret:Date) : Date
	{
		init();
		if (timezoneOffset == null) timezoneOffset = GlobalTime.timezoneOffset;
		utcTime += -(timezoneOffset - _defaultTimezoneOffset) * MINUTE;
		
		#if (flash || js)
			if (ret == null) ret = _dummyDate;
			untyped ret.setTime(utcTime);
			return ret;
		#else
			return Date.fromTime(utcTime);
		#end
	}
	
	public static function nowTime():Float
	{
		init();
		return nowTimeUtc() - timezoneOffset * MINUTE;
	}
	public static function nowTimeInTimezone(timezoneOffset:Float):Float
	{
		init();
		return nowTimeUtc() - timezoneOffset * MINUTE;
	}
	
	public static function nowTimeUtc():Float
	{
		init();
		return _initTimeUtc + (pause ? _pausedElapsed : Lib.getTimer() - _startTimer) + offset;
	}
	
	public static function getToday(?timezoneOffset:Float, ?createDate:Bool):Date 
	{
		if (timezoneOffset == null) timezoneOffset = GlobalTime.timezoneOffset;
		var todayTime:Float = nowTimeInTimezone(timezoneOffset);
		todayTime -= todayTime % DAY;
		todayTime = localToGlobal(todayTime, timezoneOffset);
		
		#if (flash || js)
		if (createDate){
			return Date.fromTime(todayTime);
		}else{
			untyped _dummyDate.setTime(todayTime);
			return _dummyDate;
		}
		#else
			return Date.fromTime(todayTime);
		#end
	}
	
	static function set_pause(value:Bool):Bool 
	{
		if (pause == value) return value;
		pause = value;
		if (value){
			_pausedElapsed = Lib.getTimer() - _startTimer;
		}else{
			_startTimer = Lib.getTimer() - _pausedElapsed;
		}
		return value;
	}
	
	static function get_defaultTimezoneOffset():Float 
	{
		return _defaultTimezoneOffset;
	}
}