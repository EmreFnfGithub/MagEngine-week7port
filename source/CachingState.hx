package;

#if desktop
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class CachingState extends MusicBeatState
{
	public static var bitmapData:Map<String, FlxGraphic>;
	public static var bitmapData2:Map<String, FlxGraphic>;

	var images:Array<String> = [];
	var music:Array<String> = [];
	var filesLoaded:Int = 0;

	var logoBg:FlxSprite;
	var logo:FlxSprite;

	var daText:FlxText;

	override function create()
	{
		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		if (!FlxG.save.data.fpsCap)
		{
			FlxG.updateFramerate = 999;
		}
		else
		{
			FlxG.updateFramerate = 120;
		}

		bitmapData = new Map<String, FlxGraphic>();
		bitmapData2 = new Map<String, FlxGraphic>();

		logoBg = new FlxSprite().loadGraphic(Paths.image('bg'));
		logoBg.screenCenter();
		add(logoBg);

		logo = new FlxSprite().loadGraphic(Paths.image('melogo'));
		logo.screenCenter();
		logo.antialiasing = true;
		add(logo);

		daText = new FlxText(0, FlxG.height - 80, FlxG.width, 'Loading...', 12);
		daText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		daText.borderSize = 2;
		daText.antialiasing = true;
		add(daText);

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
		#end

		#if sys
		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#end

		super.create();
	}

	function updateText()
	{
		daText.text = "Loading... (" + filesLoaded + "/" + (images.length + music.length) + ")";
	}

	function cache()
	{
		#if !linux
		var sound1:FlxSound;
		sound1 = new FlxSound().loadEmbedded(Paths.voices('fresh'));
		sound1.play();
		sound1.volume = 0.00001;
		FlxG.sound.list.add(sound1);

		var sound2:FlxSound;
		sound2 = new FlxSound().loadEmbedded(Paths.inst('fresh'));
		sound2.play();
		sound2.volume = 0.00001;
		FlxG.sound.list.add(sound2);
		for (i in images)
		{
			var replaced = i.replace(".png", "");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced, graph);
			filesLoaded++;
			updateText();
			trace(i);
		}

		for (i in music)
		{
			trace(i);
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
			filesLoaded++;
			updateText();
		}
		daText.text = 'Done!';
		#end
		MusicBeatState.switchState(new TitleState());
	}
}
#end
