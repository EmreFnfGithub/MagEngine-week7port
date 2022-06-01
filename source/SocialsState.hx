package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.math.FlxMath;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class SocialsState extends MusicBeatState
{
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['youtube', 'twitter'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		LoggingUtil.writeToLogFile('In The Socials Menu!');

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.scale.x = 0.8;
			menuItem.scale.y = 0.8;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				switch (optionShit[curSelected])
				{
					case 'youtube':
						if (FileSystem.exists(Paths.modTxt('data/youtube')) && FileSystem.exists(Paths.txt('data/youtube')))
						{
							CoolUtil.openURL(File.getContent(Paths.modTxt('data/youtube')));
						}
						else
						{
							CoolUtil.openURL(OpenFlAssets.getText(Paths.txt('data/youtube')));
						}
					case 'twitter':
						if (FileSystem.exists(Paths.modTxt('data/twitter')) && FileSystem.exists(Paths.txt('data/twitter')))
						{
							CoolUtil.openURL(File.getContent(Paths.modTxt('data/twitter')));
						}
						else
						{
							CoolUtil.openURL(OpenFlAssets.getText(Paths.txt('data/twitter')));
						}
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			FlxTween.tween(spr.scale, {x: 0.8}, 0.1, {ease: FlxEase.linear});
			FlxTween.tween(spr.scale, {y: 0.8}, 0.1, {ease: FlxEase.linear});

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				FlxTween.tween(spr.scale, {x: 1}, 0.1, {ease: FlxEase.linear});
				FlxTween.tween(spr.scale, {y: 1}, 0.1, {ease: FlxEase.linear});
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
