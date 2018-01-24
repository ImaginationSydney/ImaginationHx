package com.imagination.util.time;

/**
 * ...
 * @author P.J.Shand
 */
#if !sys
class GlobalTime
{
	static public var offset:Float = 0;
	static public var pause:Bool = false;
	static private var _nowDate:Date;
	static private var _nowTime:Null<Float>;
	static private var _nowTimeWithOffset:Null<Float>;
	static private var init:Void -> Void = RealInit;
	
	static inline function EmptyInit():Void { }	
	static inline function RealInit():Void
	{
		EnterFrame.add(OnTick);
		init = EmptyInit;
	}
	
	static private function OnTick():Void
	{
		// clear now data
		_nowDate = null;
		if (!pause){
			_nowTime = null;
		}
	}
	
	public static function now():Date
	{
		init();
		if (_nowDate == null) {
			if (!pause || _nowTime == null) _nowTime = Date.now().getTime();
			//_nowTimeWithOffset = _nowTime + offset;
			_nowDate = Date.fromTime(_nowTime + offset);
		}
		
		return _nowDate;
	}
	
	public static function nowTime():Float
	{
		init();
		if (!pause || _nowTime == null) {
			_nowTime = Date.now().getTime();
		}
		_nowTime += offset;
		return _nowTime;
	}
}
#else
class GlobalTime
{
	static public var offset:Float = 0;
	
	public static function now():Date
	{
		var now = Date.now();
		if (offset != 0){
			return Date.fromTime(now.getTime() + offset);
		}else{
			return now;
		}
	}
	
	public static function nowTime():Float
	{
		return Date.now().getTime();
	}
}
#end
