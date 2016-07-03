package com.imagination.cli.utils;

/**
 * ...
 * @author Thomas Byrne
 */
class CmdTools
{

	public static function hasCmd(cmd:String) : Bool
	{
		return Sys.command("WHERE "+cmd+"  > nul")==0;
	}
	
}