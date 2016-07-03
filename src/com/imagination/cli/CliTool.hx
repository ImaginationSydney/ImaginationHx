package com.imagination.cli;
import com.imagination.cli.ops.HelpOp;
import com.imagination.cli.ops.IOp;
import com.imagination.cli.OpArg;
import com.imagination.cli.utils.PrintTools;
import com.imagination.util.log.cli.DefaultCliLog;
import haxe.ds.StringMap;
import sys.FileSystem;

/**
 * ...
 * @author Thomas Byrne
 */
class CliTool
{
	private var opNames:Array<String>;
	private var opMap:StringMap<IOp>;
	
	private var options:CliToolOptions;
	
	function new(?options:CliToolOptions) 
	{
		if (options == null){
			options = {
					checkLastArgForCWD:false
				}
		}
		this.options = options;
		
		#if cpp
		Sys.command("echo off");
		#end
		DefaultCliLog.install();
		
		opMap = new StringMap();
		opNames = [];
		
		addOps();
		
		opNames.sort(function(a:String, b:String):Int
		{
			a = a.toLowerCase();
			b = b.toLowerCase();
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		} );
		
		var pendingOp:IOp = null;
		var pendingArgs:Array<String> = [];
		var pendingVars:Map<String, String> = new StringMap();
		var pendingVarName:String = null;
		
		var args = Sys.args();
		if(options.checkLastArgForCWD && args.length>0){
			var lastArg = args[args.length - 1];
			if (FileSystem.isDirectory(lastArg)){
				Sys.setCwd(lastArg);
				args.pop();
			}
		}
		for (arg in args) {
			if (pendingOp == null) {
				if (!opMap.exists(arg)) {
					PrintTools.error("Failed: operation "+arg+" not recognised");
					exit(1);
					return;
				}
				pendingOp = opMap.get(arg);
				
			}else if (arg == "=") {
				if (pendingArgs.length == 0 || pendingVarName!=null) {
					PrintTools.error("Failed: '=' sign must follow variable name");
					exit(1);
					return;
				}
				pendingVarName = pendingArgs.pop();
				
			}else if (arg == "--") {
				if (pendingVarName != null) {
					PrintTools.error("Failed: '=' sign must be followed by variable value");
					exit(1);
					return;
				}
				executePending(pendingOp, pendingArgs, pendingVars, pendingVarName);
				pendingOp = null;
				pendingArgs = [];
				pendingVars = new StringMap();
				
			}else if (pendingVarName != null) {
				pendingVars.set(pendingVarName, arg);
				pendingVarName = null;
			
			}else {
				var eqInd = arg.indexOf("=") ;
				if (eqInd != -1) {
					pendingVars.set(arg.substr(0, eqInd), arg.substr(eqInd+1));
				}else{
					pendingArgs.push(arg);
				}
			}
		}
		if (pendingOp != null) {
			executePending(pendingOp, pendingArgs, pendingVars, pendingVarName);
		}else {
			var keys:Array<String> = [];
			PrintTools.print("Use one of the following operations", PrintStyle.MENU_HEADING);
			for (key in opMap.keys()) {
				PrintTools.print(key, PrintStyle.MENU_OPTION);
			}
		}
	}
	
	private function addOps() 
	{
		addOp(HelpOp.NAME, new HelpOp(opNames, opMap));
	}
	
	private function addOp(opName:String, op:IOp) 
	{
		opMap.set(opName, op);
		opNames.push(opName);
	}
	
	private function executePending(op:IOp, args:Array<String>, vars:Map<String, String>, pendingVarName:String) 
	{
		if (pendingVarName != null) {
			PrintTools.error("Failed: '=' sign must be followed by variable value");
			exit(1);
			return;
		}
		var argInfos:Array<OpArg> = op.getArgInfo();
		var assumedInd:Int = 0;
		for (arg in args) {
			var found = false;
			while (assumedInd < argInfos.length) {
				var argInfo:OpArg = argInfos[assumedInd];
				assumedInd++;
				if (argInfo.assumed && !vars.exists(argInfo.name)) {
					vars.set(argInfo.name, arg);
					found = true;
					break;
				}
			}
			if (!found) {
				PrintTools.error("Failed: Couldn't interpret unnamed argument '"+arg+"'");
				exit(1);
			}
		}
		for (argInfo in argInfos) {
			if(!vars.exists(argInfo.name)){
				if (argInfo.def == null) {
					if (argInfo.prompt != null){
						PrintTools.progressInfo(argInfo.prompt);
						vars.set(argInfo.name, Sys.stdin().readLine());
					}else{
						PrintTools.error("Failed: Required argument '"+argInfo.name+"'");
						exit(1);
					}
				}else {
					vars.set(argInfo.name, argInfo.def);
				}
			}
		}
		op.doOp(vars);
	}
	
	
	public static function exit(code:Int = 0) 
	{
		#if cpp
		Sys.command("echo on");
		#end
		Sys.exit(code);
	}
}

typedef CliToolOptions =
{
	?checkLastArgForCWD:Bool
}