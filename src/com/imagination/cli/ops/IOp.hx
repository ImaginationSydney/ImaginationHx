package com.imagination.cli.ops;
import com.imagination.cli.OpArg;

/**
 * @author Thomas Byrne
 */

interface IOp 
{
	var name:String;
	var aliases:Array<String>;
	
	function getHelp():String;
	function getArgInfo():Array<OpArg>;
	function doOp(name:String, args:Args):Void;
}


typedef Args = 
{
	public function get(key:String) : String;
	
	public function string(key:String, ?def:String) : String;
	public function bool(key:String, def:Bool) : Bool;
}