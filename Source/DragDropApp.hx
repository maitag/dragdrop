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

class DragDropApp extends Application {

	#if html5

	override public function onPreloadComplete():Void {
		initHtml5DropEvent('content');
	}
	
	/*
	 * set up webbroser for drag and drop events
	 *
	*/
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
			loadBytes(file);  // < -------------------- load file
		}
	}
	
	function loadBytes(file:File):Void
	{
		//trace("loadBytes from "+file.name);
		var fileReader:FileReader = new FileReader();
		
		var wtf:WhatFormat = new WhatFormat();
		wtf.checkFilenameEnding(file.name); // detect by filename at first
		
		fileReader.onload = function(e) { onHeaderLoaded(file, fileReader, wtf); }
		fileReader.readAsArrayBuffer( file.slice(0, Std.int(Math.max(wtf.maxHeaderLength, file.size))) );
	}
	
	function onHeaderLoaded( file:File, fileReader:FileReader, wtf:WhatFormat):Void
	{
		var header:Bytes = Bytes.ofData(fileReader.result);
		wtf.checkHeaderBytes(header);
		
		if (wtf.found) { // found byHeader or byName
			// load full file
			// TODO: Attributes -> trace(Date.fromTime(file.lastModified).toString());
			fileReader.onload = function(e) {
				onWindowDropFileCross(file.name, Bytes.ofData(fileReader.result), wtf, this.window); 
			}
			fileReader.readAsArrayBuffer(file);
		}
		else trace('can\'t detect fileformat of ${file.name}');
	}
	#else

	
	/*
	 * Lime window-event (not html5)
	 *
	*/
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
			// TODO: Attributes
			onWindowDropFileCross(filename, cache.getBytes(), wtf, window);
		}
		else trace('can\'t detect fileformat of ${filename}');
	}

	#end

	/*
	 * new event for DragDropApp
	 * 
	*/
	function onWindowDropFileCross(filename:String, bytes:Bytes, wtf:WhatFormat, window:Window) {};
}