package com.imagination.cli.ops;
import com.imagination.cli.OpArg;

/**
 * @author Thomas Byrne
 */

interface IOp 
{
	function getHelp():String;
	function getArgInfo():Array<OpArg>;
	function doOp(args:Map<String, String>):Void;
}