package com.imagination.cli.ops;
import com.imagination.cli.OpArg;
import com.imagination.cli.ops.IOp;
import com.imagination.cli.utils.PrintTools;
import haxe.ds.StringMap;
import haxe.Resource;

/**
 * ...
 * @author Thomas Byrne
 */
class HelpOp implements IOp
{
	public static var NAME:String = "help";
	
	public static var ARG_OP:String = "op";
	
	var ops:StringMap<IOp>;
	var opNames:Array<String>;
	
	
	public function new(opNames:Array<String>, ops:StringMap<IOp>) 
	{
		this.opNames = opNames;
		this.ops = ops;
	}
	
	public function getArgInfo():Array<OpArg> {
		return [{ name:ARG_OP, desc:"The operation to describe.", assumed:true, def:"*" }];
	}
	
	public function getHelp():String 
	{
		return "Dsiplays help on one or all operations";
	}
	
	public function doOp(args:Map<String, String>):Void 
	{
		var filterOp:String = cast args.get(ARG_OP);
		
		var version:String = Resource.getString("version");
		PrintTools.help("-----------------------------------------");
		PrintTools.help("Imagination Project Tools v" + version);
		PrintTools.help("-----------------------------------------");
		
		for (key in opNames) {
			if (filterOp != null && filterOp != "*" && filterOp != key) continue;
			
			var op:IOp = ops.get(key);
			
			PrintTools.help("\n"+key + ":");
			PrintTools.help(tabText(1, op.getHelp()));
			var argInfos:Array<OpArg> = op.getArgInfo();
			if(argInfos.length>0){
				PrintTools.help(tabText(1, "Arguments:"));
				for (argInfo in argInfos) {
					if (argInfo.hidden) continue;
					
					PrintTools.help(tabText(2, "- " + argInfo.name+(argInfo.assumed == true ? "*" : "") + ": " + argInfo.desc));
					if (argInfo.def != null) {
						if (argInfo.def == "") {
							PrintTools.help(tabText(2, "( Optional )") );
						}else{
							PrintTools.help(tabText(2, "( Optional. Default: " + argInfo.def + " )") );
						}
					}
					if(argInfo.options!=null){
						PrintTools.help(tabText(2, "( Options: " + argInfo.options.join(", ") + " )") );
					}
				}
			}
		}
		
		PrintTools.help(tabText(0,"\n\nUse double dash (--) to seperate multiple commands"));
		PrintTools.help(tabText(0, "* assumed arguments don't need argument names (but then must be entered in the shown order)"));
	}
	
	private static var MAX_WIDTH:Int = 80;
	private static var TAB_CHARS:String = "   ";
	
	function tabText(tabs:Int, str:String) 
	{
		var tabStr:String = "";
		for (i in 0 ... tabs) {
			tabStr += TAB_CHARS;
		}
		var maxWidth:Int = MAX_WIDTH - tabStr.length;
		
		var ret:String = "";
		var ind:Int = 0;
		var first:Bool = true;
		while (ind < str.length) {
			var end:Int = ind + maxWidth;
			while (end > ind && str.charAt(end) != " " && end<str.length) {
				end--;
			}
			if (ind == end) {
				end = ind + maxWidth;
			}
			if (!first) {
				ret += "\n";
			}else {
				first = false;
			}
			ret += tabStr + str.substr(ind, end);
			ind = end;
		}
		
		return ret;
		
	}
	
}