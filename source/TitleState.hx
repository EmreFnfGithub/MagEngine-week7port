package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import modloader.PolymodHandler;
import modloader.ModList;
import modloader.ModsMenu;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.TransitionData;
import skinloader.SkinList;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var updateAvailable:Bool = false;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		#if MODS
		if (sys.FileSystem.exists('mods/'))
		{
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/'))
			{
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path))
				{
					folders.push(file);
				}
			}
		}
		if (sys.FileSystem.exists('mods/' + ModsMenu.coolId + '/'))
		{
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/' + ModsMenu.coolId + '/'))
			{
				var path = haxe.io.Path.join(['mods/' + ModsMenu.coolId + '/', file]);
				if (sys.FileSystem.isDirectory(path))
				{
					folders.push(file);
				}
			}
		}
		#end

		var http = new haxe.Http("https://raw.githubusercontent.com/magnumsrtisswag/MagEngine-Public/main/gameVersion.txt");

		http.onData = function(data:String)
		{
			var updateVersion = data.split('\n')[0].trim();
			var curVersion:String = Application.current.meta.get('version');
			if (updateVersion != curVersion)
			{
				updateAvailable = true;
			}
		}

		http.request();

		if (!initialized)
		{
			#if MODS
			ModList.load();
			SkinList.load();
			#end

			#if desktop
			DiscordClient.initialize();

			Application.current.onExit.add(function(exitCode)
			{
				DiscordClient.shutdown();
			});
			#end

			// DEBUG BULLSHIT

			NGio.noLogin(APIStuff.API);

			#if ng
			var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
			trace('NEWGROUNDS LOL');
			#end

			LoggingUtil.makeLogFile();
			LoggingUtil.writeToLogFile('Initializing Mag Engine...');
			LoggingUtil.writeToLogFile('Checking For Updates...');

			Highscore.load();
		}

		super.create();

		remove(ngSpr);

		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
			LoggingUtil.writeToLogFile('Successfully Initialized Mag Engine!');
		});
		#end
	}

	var logoBl:FlxSprite;
	var titleText:FlxSprite;
	var logoBg:FlxSprite;
	var danceLeft:Bool = false;
	var gfDance:FlxSprite;

	function startIntro()
	{
		LoggingUtil.writeToLogFile('Starting Intro...');
		if (!initialized)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		logoBl = new FlxSprite(-150, -100);
		#if MODS
		if (FileSystem.exists('assets/images/logoBumpin.png') && FileSystem.exists(Paths.modIcon('logoBumpin')))
		{
			logoBl.frames = Paths.getModsSparrowAtlas('logoBumpin');
			LoggingUtil.writeToLogFile('Found A Modded Logo!');
		}
		else
		{
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		}
		#else
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		#end
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		logoBg = new FlxSprite().loadGraphic(Paths.image('bg', 'MagEngine'));
		logoBg.screenCenter();
		add(logoBg);

		#if MODS
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		if (FileSystem.exists('assets/images/gfDanceTitle.png') && FileSystem.exists(Paths.modIcon('gfDanceTitle')))
		{
			gfDance.frames = Paths.getModsSparrowAtlas('gfDanceTitle');
			LoggingUtil.writeToLogFile('Found A Modded Title Girlfriend!');
		}
		else
		{
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		}
		#else
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		#end
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		#if MODS
		titleText = new FlxSprite(150, FlxG.height * 0.8);
		if (FileSystem.exists('assets/images/titleEnter.png') && FileSystem.exists(Paths.modIcon('titleEnter')))
		{
			titleText.frames = Paths.getModsSparrowAtlas('titleEnter');
			LoggingUtil.writeToLogFile('Found A Modded Title Text!');
		}
		else
		{
			titleText.frames = Paths.getSparrowAtlas('titleEnter');
		}
		#else
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				if (updateAvailable)
				{
					MusicBeatState.switchState(new OutdatedSubState());
					LoggingUtil.writeToLogFile('Mag Engine Is Outdated!');
				}
				else
				{
					LoggingUtil.writeToLogFile('No Updates Found! Switching To The Main Menu...');
					MusicBeatState.switchState(new MainMenuState());
				}
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 2:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['mag engine', 'by']);
			case 7:
				addMoreText('magnumsrt');
				addMoreText('stilic');
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday Night');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Funkin');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Mag Engine'); // credTextShit.text += '\nFunkin';
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;

			// why tf was this removed
			#if MODS
			ModList.load();
			SkinList.load();
			#end
		}
	}
}
