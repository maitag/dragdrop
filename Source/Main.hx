package;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import lime.app.Application;
import lime.ui.Window;

//import lime.utils.Bytes;

#if html5
import js.Browser;
import js.html.Element;
import js.html.File;
import js.html.FileList;
import js.html.FileReader;
import js.html.Blob;
import js.html.Uint8Array;
#else
import sys.io.File;
import sys.io.FileInput;
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

	public function initHtml5DropEvent(elementID:String):Void
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
	
	public function onHtml5DropFile(evt):Void
	{
		evt.stopPropagation();
		evt.preventDefault();
		//trace(evt.dataTransfer.types);
		for (file in cast(evt.dataTransfer.files, FileList))
		{
			//trace(file.name, file.type);
			var t:Array<String> = file.type.split("/");
			var type:String   = t[0];
			var format:String = t[1];
			var lastModified:Date = Date.fromTime(file.lastModified);
			trace('file "${file.name}" (last modified ${lastModified.toString()} ):');
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
						checkByName(file.name);
					}
					
				default:
					trace('$type filetype not supported');
			}
			
			loadBytes(file);  // < -------------------- load file

		}
	}
	
	
	public function loadBytes(file:File)
	{
		trace("loadBytes from "+file.name);
		var fileReader:FileReader = new FileReader();
		
		var wtf:WhatFormat = new WhatFormat(); //trace(KnownFormats.MagicNumbers);
		
		fileReader.onload = function(evt) {
			var header:Uint8Array = new Uint8Array(fileReader.result);
			trace(header);
		};
		
		var blob:Blob = file.slice(0, Std.int(Math.max(wtf.maxHeaderLength, file.size)));
		fileReader.readAsArrayBuffer(blob);
		//onFileInput(bytes, this.window);
	}
	
	
	#else

	// ---------------------------- window-event (Lime)
	
	override public function onWindowDropFile(window:Window, filename:String):Void
	{
		trace("\ndragged in ", window, filename);
		/*
		lime.utils.Bytes.loadFromFile(fname).onComplete (function (bytes) {
			onFileInput(bytes, window);
		});
		*/
		
		
		
		var wtf:WhatFormat = new WhatFormat();
		//var wtf:WhatFormat = new WhatFormat(['png','jpg','hx']);
		
		// test
		//if (wtf.checkHeaderBytes(File.getBytes(filename)).found) trace("FOUND");
		//wtf.reset();
		
		// detect by filename
		if (wtf.checkFilenameEnding(filename).found) trace('format detected by filename ending:\n', wtf.byName);
		
		var input:Bytes;
		var cache:BytesOutput = new BytesOutput();
		var file:FileInput = File.read(filename);
		var byte:Int;
		try // load file
		{
			do
			{
				byte = file.readByte();

				// store it into Bytes or do whatever with that byte
				cache.writeByte(byte);
				// ...
				
				//if (wtf.proceed) trace(StringTools.hex(byte,2));
				//wtf.checkNextByte(byte); // proceed formatcheck
			}
			while ( wtf.checkNextByte(byte) || wtf.found ); // do not stop after proceed or something found
			//while ( wtf.proceed || wtf.byHeader.found || wtf.byName.found); // do not stop after proceed or something found
		}
		catch( ex:haxe.io.Eof ) {}
		file.close();
		
		if (wtf.byHeader.found) trace('format detected by parsing header:\n', wtf.byHeader);

		if (wtf.found) { // found byHeader or byName
			input = cache.getBytes();
			trace('format of $filename found.');
			trace('filesize: ${input.length}');
			trace('format: ${wtf.format} - ${wtf.description}');
			if (wtf.subtype != null) trace('subtype:${wtf.subtype} - ${wtf.subtypeDescription}');
		}
		else trace("can't detect fileformat");
		
		wtf.byHeader.reset();
		wtf.byName.reset();
		wtf.reset();
	}

	#end

	

	/*
	public function onFileInput(bytes:Bytes, window:Window)
	{
		trace('onFileInput');
		//trace(bytes.);
	}
	*/

}