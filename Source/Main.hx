package;

import haxe.io.Bytes;
import lime.ui.Window;

import DragDropApp;
import WhatFormat;

class Main extends DragDropApp {
	
	
	public function new () {
		
		super ();
		
	}

	//override public function onWindowCreate(window:Window):Void {}
	//override public function onPreloadComplete():Void {}
	
	override function onWindowDropFileCross(filename:String, bytes:Bytes, wtf:WhatFormat, window:Window)
	{
		trace('Loaded: $filename, filesize: ${bytes.length}');
		if (wtf.byName.found) {
			trace('');
			trace('detected by filename ending:');
			trace('  format: ${wtf.byName.format} - ${wtf.byName.description}');
			if (wtf.byName.subtype != null) trace('  subtype: ${wtf.byName.subtype} - ${wtf.byName.subtypeDescription}');
		}
		if (wtf.byHeader.found) {
			trace('detected by parsing header-data:');
			trace('  format: ${wtf.byHeader.format} - ${wtf.byHeader.description}');
			if (wtf.byHeader.subtype != null) trace('  subtype: ${wtf.byHeader.subtype} - ${wtf.byHeader.subtypeDescription}');
		}
		trace('');
		trace('WhatFormat found:');
		trace('  format: ${wtf.format} - ${wtf.description}');
		if (wtf.subtype != null) trace('  subtype: ${wtf.subtype} - ${wtf.subtypeDescription}');
		trace("-------------------------------------\n");
	}
	

}