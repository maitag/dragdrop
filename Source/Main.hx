package;

/**
 * by Sylvio Sell - Rostock 2018
 * 
 * Drag and Drop Sample with haxe-lime and whatformat
 * 
*/

import haxe.io.Bytes;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import openfl.text.TextField;
import openfl.display.Stage;

import DragDropApp;
import WhatFormat;

class Main extends DragDropApp {
	
	var logText:TextField;
	
	public function new () super();

	/*
	 * create log output
	 * 
	*/
	override function onWindowCreate ():Void {
		
		// allowed fileformats to load:
		// look here for what can be detected by "whatformat"-haxelib: 
		// https://github.com/maitag/whatformat/blob/master/src/formats/Magic.hx#L7
		
		// checkOnlyFormats = ["png"];
		
		
		var stage:Stage = new Stage (window, 0xF8F8F8);
		
		var helpText = new TextField();
		helpText.width = window.width / 2;
		helpText.height = 40;
		helpText.scaleX = helpText.scaleY = 2;
		helpText.selectable = false;
		helpText.text = "Drag Files into Window to load a file and detect fileformat!\n";
		if (checkOnlyFormats != null) helpText.text += 'Allowed Fileformats: ' + checkOnlyFormats.join(", ") + "  ";
		helpText.text += '(press "x" to clear output)';
		stage.addChild (helpText);
		
		logText = new TextField();
		logText.y = 74; logText.x = 2;
		logText.border = true;
		logText.width = window.width-4;
		logText.height = window.height - helpText.height - 10;
		stage.addChild (logText);
		
		addModule (stage);
		#if html5
		// put link to supported fileformats
		var link:js.html.AnchorElement = js.Browser.document.createAnchorElement();
		link.href = "https://github.com/maitag/whatformat/blob/master/src/formats/Magic.hx#L7";
		link.textContent = "--> supported formats"; link.target = "_blank";
		link.style.position = "absolute"; link.style.top = "40px"; link.style.right = "30%";
		link.style.zIndex = "2020";
		link.style.backgroundColor = "#aaaaff";
		js.Browser.document.body.appendChild(link);
		#end
	}
	
	/*
	 * if File data comes in
	 * 
	*/
	override function onWindowDropFileCross(filename:String, bytes:Bytes, wtf:WhatFormat, window:Window):Void {
		log('\nLoaded: $filename, filesize: ${bytes.length} Bytes');
		
		if (wtf.byName.found) {
			log('\ndetected by filename ending:');
			log('   format: ${wtf.byName.format} - ${wtf.byName.description}');
			if (wtf.byName.subtype != null) log('   subtype: ${wtf.byName.subtype} - ${wtf.byName.subtypeDescription}');
		}
		if (wtf.byHeader.found) {
			log('\ndetected by parsing header-data:');
			log('   format: ${wtf.byHeader.format} - ${wtf.byHeader.description}');
			if (wtf.byHeader.subtype != null) log('   subtype: ${wtf.byHeader.subtype} - ${wtf.byHeader.subtypeDescription}');
		}
		log('');
		log('WhatFormat:');
		log('   format: ${wtf.format} - ${wtf.description}');
		if (wtf.subtype != null) log('   subtype: ${wtf.subtype} - ${wtf.subtypeDescription}');
		log("-----------------------------------------------------");
	}
	
	/*
	 * simple log into app-window
	 * 
	*/
	override function log(s:Dynamic):Void {
		logText.appendText("\n" + s);
		logText.scrollV = logText.maxScrollV;
		trace(s);
	}
	
	/*
	 * to clear the log-output
	 * 
	*/
	override function onKeyUp (key:KeyCode, modifier:KeyModifier):Void {
		switch (key) {
			case KeyCode.X: logText.scrollV = 1; logText.text = '';
			default:			
		};		
	}	


}