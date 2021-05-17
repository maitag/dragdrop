package;

/**
 * by Sylvio Sell - Rostock 2018
 * 
 * html5 drag&drop events for Lime Application
 * 
 * reads the dragged Files in and checks what format is
 */

import haxe.io.Bytes;
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

	public var checkOnlyFormats:Array<String> = null;
	public var preferHeader:Bool = true;
	
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
		
		var wtf:WhatFormat = new WhatFormat(checkOnlyFormats, preferHeader);
		wtf.checkFilenameEnding(file.name); // detect by filename at first
		
		fileReader.onload = function(e) { onHeaderLoaded(file, fileReader, wtf); }
		
		if (wtf.found || file.type != "" || file.size % 4096 != 0) // hack for filefolders (window os only?)
		{
			fileReader.readAsArrayBuffer( file.slice(0, Std.int(Math.max(wtf.maxHeaderLength, file.size))) );
		} else log('\nERROR reading File "${file.name}" (windows-os filefolder?)');
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
		else log('\nCan\'t detect fileformat of "${file.name}"');
	}	
	
	#else
	
	/*
	 * Lime window-event (not html5)
	 *
	*/
	override public function onWindowDropFile(filename:String):Void
	{
		trace('\n=========== DRAGGED IN: winwow.id:${window.id}, filename:$filename ========');
		/*
		lime.utils.Bytes.loadFromFile(fname).onComplete (function (bytes) {
			onFileInput(bytes, window);
		});
		*/
		var wtf:WhatFormat = new WhatFormat(checkOnlyFormats, preferHeader);
		wtf.checkFilenameEnding(filename); // detect by filename at first
		
		try {
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
			catch ( ex:haxe.io.Eof ) {}
			file.close();
			
			// found byHeader or byName
			if (wtf.found) {
				// TODO: Attributes
				onWindowDropFileCross(filename, cache.getBytes(), wtf, window);
			}
			else log('\ncan\'t detect fileformat of "${filename}"');
		}
		catch (err:Dynamic) { log('\nERROR reading File "${filename}"'); log(err); }
	}

	#end

	/*
	 * new event for DragDropApp
	 * 
	*/
	function onWindowDropFileCross(filename:String, bytes:Bytes, wtf:WhatFormat, window:Window) {
	};
	

	/*
	 * simple log into app-window
	 * 
	*/
	function log(s:Dynamic):Void {
		trace(s);
	}

}