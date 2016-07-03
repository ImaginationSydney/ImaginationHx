package com.imagination.cli;

/**
 * @author Thomas Byrne
 */

typedef OpArg =
{
	name:String,
	desc:String,
	?def:String,
	?assumed:Bool,
	?options:Array<String>,
	?hidden:Bool,
	?prompt:String	
}