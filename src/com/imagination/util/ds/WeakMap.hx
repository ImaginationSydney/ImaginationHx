package com.imagination.util.ds;
import com.imagination.util.ds.WeakMap.NativeWeakMap;

#if js

/**
 * ...
 * @author Thomas Byrne
 */
class WeakMap<K: { },V> implements haxe.Constraints.IMap<K,V>
{
	var innerMap:NativeWeakMap<K, V>;

	/**
		Creates a new WeakMap.
	**/
	public function new():Void {
		innerMap = new NativeWeakMap<K, V>();
	}

	/**
		See `Map.set`
	**/
	public function set(key:K, value:V):Void {
		innerMap.set(key, value);
	}

	/**
		See `Map.get`
	**/
	public function get(key:K):Null<V> {
		return innerMap.get(key);
	}

	/**
		See `Map.exists`
	**/
	public function exists(key:K):Bool {
		return innerMap.has(key);
	}

	/**
		See `Map.remove`
	**/
	public function remove(key:K):Bool {
		return innerMap.delete(key);
	}

	/**
		See `Map.keys`
	**/
	public function keys():Iterator<K> {
		var keys:Array<K> = [];
		untyped{
			for (i in innerMap){
				keys.push(i);
			}
		}
		return keys.iterator();
	}

	/**
		See `Map.iterator`
	**/
	public function iterator():Iterator<V> {
		var values:Array<V> = [];
		untyped{
			for (i in innerMap){
				values.push(innerMap[i]);
			}
		}
		return values.iterator();
	}

	/**
		See `Map.toString`
	**/
	public function toString():String {
		var res:String = cast(innerMap);
		return res;
	}
	
}
@:native("WeakMap")
extern class NativeWeakMap<K: { },V> {
	
	public function new(?iterable:Dynamic):Void;
	public function set(key:K, value:V):NativeWeakMap<K, V>;
	public function get(key:K):Null<V>;
	public function delete(key:K):Bool;
	public function has(key:K):Bool;
}

#else 
typedef WeakMap<K: { },V> = haxe.ds.WeakMap<K,V>;
#end