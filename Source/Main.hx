package;

import haxe.io.Bytes;
//import lime.utils.Bytes;
import lime.app.Application;
import lime.ui.Window;


#if html5
import js.Browser;
import js.html.Element;
import js.html.File;
import js.html.FileList;
import js.html.FileReader;
#else
import sys.io.File;
import sys.io.FileInput;
import haxe.io.BytesOutput;
#end

import WhatFormat;

class Main extends Application {
	
	
	public function new () {
		
		super ();
		
	}

	//override public function onWindowCreate(window:Window):Void {
	override public function onPreloadComplete():Void {
		#if html5
		initHtml5DropEvent('content');
		#end
	}
	
	#if html5

	function initHtml5DropEvent(elementID:String):Void
	{
		var content:Element = Browser.document.getElementById(elementID);

		content.addEventListener( 'dragover',
			function handleDragOver(evt) {
				evt.stopPropagation();
				evt.preventDefault();
				evt.dataTransfer.dropEffect = 'copy';
			}, false
		);
		content.addEventListener( 'drop', onHtml5DropFile, false );
	}
	
	function onHtml5DropFile(evt:Dynamic):Void
	{
		evt.stopPropagation();
		evt.preventDefault();
		//trace(evt.dataTransfer.types);
		for (file in cast(evt.dataTransfer.files, FileList))
		{
			trace('\n=========== DRAGGED IN: winwow.id:${window.id}, filename:${file.name} ========');
			//trace(file.name, file.type);
			//var lastModified:Date = Date.fromTime(file.lastModified);
			//trace('file "${file.name}" (last modified ${lastModified.toString()} ):');

			// type detected by Browser (FF did by filename anyway)
			/*
			var t:Array<String> = file.type.split("/");
			var type:String   = t[0];
			var format:String = t[1];
			
			switch (type)
			{
				case "image" :
					switch (format)
					{	case "jpg" | "jpeg" | "png":
							trace('$format image found');
						default:
							trace('type $format $type not supported');
					}
					
				case "text" :
					switch (format)
					{	case "plain" | "html" | "xml":
							trace('$format text found');
						default:
							trace('type $format $type not supported');
					}
					
				case "" : // browser did not understand filetype
					if (file.size % 4096 == 0)
					{
						trace('folders not supported');
					}
					else
					{
						// check filename ending
						//checkByName(file.name);
					}
					
				default:
					trace('$type filetype not supported');
			}
			*/
			loadBytes(file);  // < -------------------- load file

		}
	}
	
	
	function loadBytes(file:File)
	{
		//trace("loadBytes from "+file.name);
		var fileReader:FileReader = new FileReader();
		
		var wtf:WhatFormat = new WhatFormat();
		wtf.checkFilenameEnding(file.name); // detect by filename at first
		
		fileReader.onload = function(e) { onHeaderLoaded(file, fileReader, wtf); }
		fileReader.readAsArrayBuffer(file.slice(0, Std.int(Math.max(wtf.maxHeaderLength, file.size))));
	}
	
	function onHeaderLoaded( file:File, fileReader:FileReader, wtf:WhatFormat):Void
	{
		var header:Bytes = Bytes.ofData(fileReader.result);
		wtf.checkHeaderBytes(header);
		
		if (wtf.found) { // found byHeader or byName
			// load full file
			fileReader.onload = function(e) { onFileInput(file.name, Bytes.ofData(fileReader.result), wtf, this.window); }
			fileReader.readAsArrayBuffer(file);
		}
		else trace('can\'t detect fileformat of ${file.name}');
	}
	
	
	#else

	// ---------------------------- window-event (Lime)
	
	override public function onWindowDropFile(window:Window, filename:String):Void
	{
		trace('\n=========== DRAGGED IN: winwow.id:${window.id}, filename:$filename ========');
		/*
		lime.utils.Bytes.loadFromFile(fname).onComplete (function (bytes) {
			onFileInput(bytes, window);
		});
		*/
		var wtf:WhatFormat = new WhatFormat();//var wtf:WhatFormat = new WhatFormat(['png','jpg','hx']);
		wtf.checkFilenameEnding(filename); // detect by filename at first
		
		var file:FileInput = File.read(filename);
		var cache:BytesOutput = new BytesOutput();
		var byte:Int;
		try // load file
		{
			do
			{
				byte = file.readByte();
				cache.writeByte(byte);
				//if (wtf.proceed) trace(StringTools.hex(byte,2));
			}
			while ( wtf.checkNextByte(byte) || wtf.found ); // do not stop after proceed or something found
		}
		catch( ex:haxe.io.Eof ) {}
		file.close();
		
		// found byHeader or byName
		if (wtf.found) { 
			onFileInput(filename, cache.getBytes(), wtf, window);
		}
		else trace('can\'t detect fileformat of ${filename}');
	}

	#end

	

	
	function onFileInput(filename:String, bytes:Bytes, wtf:WhatFormat, window:Window)
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