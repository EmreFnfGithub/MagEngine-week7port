package;

import flixel.FlxCamera;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemswhyhaxe:Array<String> = [
		'Resume',
		'Restart Song',
		'Change Difficulty',
		'Toggle Botplay',
		'Toggle Practice Mode',
		'Exit to menu'
	];
	var practiceTxt:FlxText;
	var botplayTxt:FlxText;
	var difficultyChoices = [];
	var curSelected:Int = 0;

	public static var transCamera:FlxCamera;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();
		menuItems = menuItemswhyhaxe;

		for (i in 0...CoolUtil.difficultyStuff.length)
		{
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		CustomFadeTransition.nextCamera = transCamera;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, CoolUtil.difficultyString(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "Blueballed: " + PlayState.bbCounter, 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceTxt = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceTxt.scrollFactor.set();
		practiceTxt.setFormat(Paths.font('vcr.ttf'), 32);
		practiceTxt.updateHitbox();
		practiceTxt.visible = PlayState.practiceAllowed;
		add(practiceTxt);

		botplayTxt = new FlxText(20, FlxG.height - 35, 0, "BOTPLAY", 32);
		botplayTxt.scrollFactor.set();
		botplayTxt.setFormat(Paths.font('vcr.ttf'), 32);
		botplayTxt.updateHitbox();
		botplayTxt.visible = PlayState.cpuControlled;
		add(botplayTxt);

		levelInfo.alpha = 0;
		levelDifficulty.alpha = 0;
		blueballedTxt.alpha = 0;
		practiceTxt.alpha = 0;
		botplayTxt.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 10);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 10);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 10);
		practiceTxt.x = FlxG.width - (practiceTxt.width + 10);
		botplayTxt.x = FlxG.width - (botplayTxt.width + 10);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y - 4}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y - 4}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceTxt, {alpha: 1, y: practiceTxt.y - 8}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(botplayTxt, {alpha: 1, y: botplayTxt.y - 8}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			for (i in 0...difficultyChoices.length - 1)
			{
				if (difficultyChoices[i] == daSelected)
				{
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					return;
				}
			}
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenerateMenu();
				case "Toggle Practice Mode":
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					PlayState.practiceAllowed = !PlayState.practiceAllowed;
					practiceTxt.visible = PlayState.practiceAllowed;
				case "Toggle Botplay":
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					PlayState.cpuControlled = !PlayState.cpuControlled;
					botplayTxt.visible = PlayState.cpuControlled;
				case "Restart Song":
					MusicBeatState.resetState();
				case "Exit to menu":
					PlayState.bbCounter = 0;
					if (PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else
						MusicBeatState.switchState(new FreeplayState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				case "BACK":
					menuItems = menuItemswhyhaxe;
					regenerateMenu();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		if (PlayState.cpuControlled || PlayState.practiceAllowed)
			PlayState.usedPlayFeatures = true;

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenerateMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length)
		{
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
