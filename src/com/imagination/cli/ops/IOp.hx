package com.imagination.cli.ops;
import com.imagination.cli.OpArg;
import haxe.ds.StringMap;

/**
 * @author Thomas Byrne
 */

interface IOp 
{
	function getHelp():String;
	//function getAssumedArgOrder():Array<String>;
	function getArgInfo():Array<OpArg>;
	function doOp(args:Map<String, String>):Void;
}