package;

import openfl.events.IOErrorEvent;
import openfl.events.ErrorEvent;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.system.System;
import flixel.FlxState;
import sys.io.Process;
import openfl.events.Event;
import cpp.vm.Thread;
import openfl.events.ProgressEvent;
import flixel.ui.FlxBar;
import flixel.FlxG;
import openfl.net.URLLoader;
import openfl.net.URLStream;
import flixel.addons.ui.FlxUIInputText;
import openfl.net.URLRequest;
import lime.app.Application;
import openfl.utils.ByteArray;
import sys.FileSystem;
import flixel.util.FlxTimer;
import haxe.Json;
import flixel.ui.FlxBar;
import haxe.format.JsonParser;
import sys.io.FileInput;
import sys.io.File;
import haxe.io.BytesInput;
import sys.io.FileOutput;
import flixel.FlxSprite;
import flixel.FlxCamera;
import haxe.zip.Entry;
import haxe.zip.Uncompress;
import haxe.zip.Writer;
import haxe.io.Bytes;
import flixel.ui.FlxButton;
import haxe.io.Input;
import flixel.addons.ui.FlxUITabMenu;

using StringTools;

class UpdateState extends MusicBeatState
{
	public static var coolText:FlxText;
	public static var finishedFiles:Int = 0;

	var fileArray:Array<String> = [];

	var firstFileDownloaded:Bool = false;

	override public function create()
	{
		LoggingUtil.writeToLogFile('Starting Update...');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF665AFF;
		add(bg);

		var swagBG:FlxSprite = new FlxSprite().makeGraphic(1000, 500, FlxColor.BLACK, false);
		swagBG.screenCenter();
		swagBG.scrollFactor.set();
		swagBG.alpha = 0.5;
		add(swagBG);

		coolText = new FlxText(0, 0, 1000);
		coolText.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		coolText.borderSize = 1;
		coolText.scrollFactor.set();
		coolText.text = "Starting Update...";
		coolText.screenCenter(X);
		coolText.y += 200;
		add(coolText);

		requestData();

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			initUpdate();
		});

		super.create();
	}

	public function requestData()
	{
		var remoteList = new haxe.Http("https://raw.githubusercontent.com/magnumsrtisswag/MagEngine-Public/main/updateFiles.txt");
		remoteList.onData = function(swagDat:String)
		{
			fileArray = swagDat.trim().split('\n');
		}
		remoteList.onError = function(error)
		{
			LoggingUtil.writeToLogFile('Update Failed! Error: ' + error);
			coolText.text = "Error: " + error;
		}

		remoteList.request();
	}

	public function initUpdate()
	{
		var fileDownload = new URLLoader();
		fileDownload.dataFormat = BINARY;

		if (fileArray != null)
		{
			coolText.text = "Gathering Update Files...";

			LoggingUtil.writeToLogFile('Recieved Update Data!');

			var progressBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, this, "finishedFiles", 0, fileArray.length);
			progressBar.createFilledBar(FlxColor.GRAY, FlxColor.GREEN, true, FlxColor.BLACK);
			progressBar.screenCenter(X);
			progressBar.y = coolText.y + 100;
			progressBar.scrollFactor.set(0, 0);
			add(progressBar);

			coolText.text = "Downloading Update Files... (" + finishedFiles + "/" + fileArray.length + ")";

			var firstReturnedFile = fileArray.shift();

			for (i in 0...fileArray.length)
			{
				fileArray[i] = fileArray[i].trim();
			}

			if (FileSystem.exists('./updateCache/$firstReturnedFile') && FileSystem.stat('./updateCache/$firstReturnedFile').size > 0)
			{
				finishedFiles++;
				initUpdate();
				return;
			}

			var fileLocation = "https://raw.githubusercontent.com/magnumsrtisswag/MagEngine-Public/main/compiledFiles/";

			var emptyArray:Array<Dynamic> = [];

			var fileLoader = new URLRequest('$fileLocation/$firstReturnedFile'.replace(" ", "%20"));

			var emptyArray:Array<Dynamic> = [];
			var cleanedDirectory = [
				for (i => o in (emptyArray = firstReturnedFile.replace("\\", "/").split("/")))
					if (i < emptyArray.length - 1) o
			].join("/");
			FileSystem.createDirectory('updateCache/' + cleanedDirectory);

			var writtenFile:FileOutput = File.write('updateCache/$firstReturnedFile', true);

			fileDownload.addEventListener(IOErrorEvent.IO_ERROR, function(exceptionThrown)
			{
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					coolText.text = "Error! Could not download file! This is\nusually because you don't have an internet connection!";
				});
			});

			fileDownload.addEventListener(Event.COMPLETE, function(e)
			{
				var bytes:ByteArray = new ByteArray();
				fileDownload.data.readBytes(bytes, 0, fileDownload.data.length - fileDownload.data.position);
				writtenFile.writeBytes(bytes, 0, bytes.length);
				writtenFile.flush();

				writtenFile.close();
				finishedFiles++;
				if (fileArray.length > 0)
				{
					initUpdate();
				}
				else
				{
					coolText.text = "Update Finished! Restarting...";

					File.copy('Mag Engine.exe', 'Updater.exe');

					new Process('start /B Updater.exe startUpdate');

					System.exit(0);
				}
			});

			fileDownload.load(fileLoader);
		}
	}
}
