package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import Song.MidSongEvent;
import flixel.FlxCamera;
import shaders.ChromaticAberration;
import flixel.FlxG;
import tools.StageEditor;
import tools.StageEditor.LayerFile;
import tools.StageEditor.StageFile;
import tools.StageEditor.StageData;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import haxe.Exception;
import openfl.Lib;
import openfl.utils.Assets as OpenFlAssets;
#if sys
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
import modloader.ModsMenu;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isPixelStage:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<Dynamic> = [];
	public static var originalStoryPlaylistLength:Int = 0;
	public static var storyDifficulty:Int = 1;

	public static var eventName:String;
	public static var eventPosition:Float;

	var interp:Interp = new Interp();

	public static var usedPlayFeatures:Bool = false;
	public static var cpuControlled:Bool = false;
	public static var practiceAllowed:Bool = false;

	public var pauseHUD:FlxCamera;

	public var valueOne:Dynamic;
	public var valueTwo:Dynamic;

	public var stageKey:String;
	public var rawJson:String;

	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, FlxSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();

	var halloweenLevel:Bool = false;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var cameraSpeed:Float = 1;

	private var camFollow:FlxPoint;

	public var time:Float;

	private var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public static var babyArrow:FlxSprite;

	public static var noteTransparencyLevel:Float = 0.6;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public var misses:Int = 0;
	public var shits:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;

	public var accuracy:Float = 0;

	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public static var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	public static var bbCounter:Int = 0;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var ratingCntr:FlxText;

	var hihellothere = false;
	var chromeShit:ChromaticAberration;
	var chromeEnabled:Bool = false;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var scoreTxt:FlxText;
	var infoTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var dummyNote:Note;

	private var luaArray:Array<MagModChart> = [];

	override public function create()
	{
		callOnHscript("create");

		LoggingUtil.writeToLogFile('In The PlayState!');
		LoggingUtil.writeToLogFile('Searching For Modcharts...');
		LoggingUtil.writeToLogFile('Searching For Scripts...');
		LoggingUtil.writeToLogFile('Searching For Event Scripts...');
		LoggingUtil.writeToLogFile('Searching For Dialogues...');
		LoggingUtil.writeToLogFile('Loading Song...');

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!FlxG.save.data.fpsCap)
		{
			openfl.Lib.current.stage.frameRate = 999;
		}
		else
		{
			openfl.Lib.current.stage.frameRate = 120;
		}

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		CustomFadeTransition.nextCamera = camHUD;
		PauseSubState.transCamera = camHUD;

		persistentUpdate = true;
		persistentDraw = true;

		curStage = PlayState.SONG.stage;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad-battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
			default:
				var path:String = 'data/' + SONG.song.toLowerCase() + '/' + SONG.song.toLowerCase() + '-Dialogue';
				var daPath:String;
				#if MODS
				daPath = Paths.modTxt(path);
				if (FileSystem.exists(daPath))
				{
					LoggingUtil.writeToLogFile('Dialogue Found!');
					dialogue = CoolUtil.evenCoolerTextFile(daPath);
				}
				else
				{
					daPath = Paths.txt(path);
					if (FileSystem.exists(daPath))
						dialogue = CoolUtil.coolTextFile(daPath);
				}
				#else
				daPath = Paths.txt(path);
				if (OpenFlAssets.exists(daPath))
					dialogue = CoolUtil.coolTextFile(daPath);
				#end
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{
			stageData = {
				name: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				layerArray: []
			};
		}

		switch (SONG.stage)
		{
			case 'halloween':
				{
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'philly':
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();

					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					add(street);
				}
			case 'limo':
				{
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);
					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					// add(limo);
				}
			case 'mall':
				{
					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();

					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();

					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;

					add(santa);
				}
			case 'mallEvil':
				{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = true;
					add(evilSnow);
				}
			case 'school':
				{
					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();

					add(bgGirls);
				}
			case 'schoolEvil':
				{
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);
						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);
						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);
						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);
						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();
						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			case 'stage':
				{
					defaultCamZoom = 0.9;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
					add(stageCurtains);
				}
			case 'warzone':
				{
					defaultCamZoom = 0.9;
					
					var sky:FlxSprite = new FlxSprite(-400,-400).loadGraphic(Paths.image('warzone/tankSky'));
					sky.scrollFactor.set(0, 0);
					sky.antialiasing = true;
					sky.setGraphicSize(Std.int(sky.width * 1.5));
				    add(sky);

					
					var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('warzone/tankClouds'));
					clouds.scrollFactor.set(0.1, 0.1);
					clouds.velocity.x = FlxG.random.float(5, 15);
					clouds.antialiasing = true;
					clouds.updateHitbox();
					add(clouds);

					var mountains:FlxSprite = new FlxSprite(-300,-20).loadGraphic(Paths.image('warzone/tankMountains'));
					mountains.scrollFactor.set(0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					mountains.antialiasing = true;
					add(mountains);

					var buildings:FlxSprite = new FlxSprite(-200,0).loadGraphic(Paths.image('warzone/tankBuildings'));
					buildings.scrollFactor.set(0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					buildings.antialiasing = true;
					add(buildings);

					var ruins:FlxSprite = new FlxSprite(-200,0).loadGraphic(Paths.image('warzone/tankRuins'));
					ruins.scrollFactor.set(0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					ruins.antialiasing = true;
					add(ruins);

					var smokeLeft:FlxSprite = new FlxSprite(-200,-100);
								smokeLeft.frames = Paths.getSparrowAtlas('warzone/smokeLeft');
								smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft ', 24, true);
								smokeLeft.scrollFactor.set(0.4, 0.4);
								smokeLeft.antialiasing = true;
								smokeLeft.animation.play('idle');
								add(smokeLeft);
				
								var smokeRight:FlxSprite = new FlxSprite(1100,-100);
								smokeRight.frames = Paths.getSparrowAtlas('warzone/smokeRight');
								smokeRight.animation.addByPrefix('idle', 'SmokeRight ', 24, true);
								smokeRight.scrollFactor.set(0.4, 0.4);
								smokeRight.antialiasing = true;
								smokeRight.animation.play('idle');
								
								add(smokeRight);

								var tower:FlxSprite = new FlxSprite(100, 120);
								tower.frames = Paths.getSparrowAtlas('warzone/tankWatchtower');
								tower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
								tower.antialiasing = true;

					add(tower);

								var tankRolling:FlxSprite = new FlxSprite(300,300);
								tankRolling.frames = Paths.getSparrowAtlas('tankRolling');
								tankRolling.animation.addByPrefix('idle', 'BG tank w lighting ', 24, true);
								tankRolling.scrollFactor.set(0.5, 0.5);
								tankRolling.antialiasing = true;
								tankRolling.animation.play('idle');
								
								add(tankRolling);
				
								var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('warzone/tankGround'));
								ground.scrollFactor.set();
								ground.antialiasing = true;
								ground.setGraphicSize(Std.int(ground.width * 1.15));
								ground.scrollFactor.set(1, 1);

								ground.updateHitbox();
								add(ground);
				}
			case 'warzone-stress':
				{
					defaultCamZoom = 0.9;
						var sky:FlxSprite = new FlxSprite(-400,-400).loadGraphic(Paths.image('warzone/tankSky'));
						sky.scrollFactor.set(0, 0);
						sky.antialiasing = true;
						sky.setGraphicSize(Std.int(sky.width * 1.5));
						add(sky);
	
						
						var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('warzone/tankClouds'));
						clouds.scrollFactor.set(0.1, 0.1);
						clouds.velocity.x = FlxG.random.float(5, 15);
						clouds.antialiasing = true;
						clouds.updateHitbox();
						add(clouds);
	
						var mountains:FlxSprite = new FlxSprite(-300,-20).loadGraphic(Paths.image('warzone/tankMountains'));
						mountains.scrollFactor.set(0.2, 0.2);
						mountains.setGraphicSize(Std.int(1.2 * mountains.width));
						mountains.updateHitbox();
						mountains.antialiasing = true;
						add(mountains);
	
						var buildings:FlxSprite = new FlxSprite(-200,0).loadGraphic(Paths.image('warzone/tankBuildings'));
						buildings.scrollFactor.set(0.3, 0.3);
						buildings.setGraphicSize(Std.int(buildings.width * 1.1));
						buildings.updateHitbox();
						buildings.antialiasing = true;
						add(buildings);
	
						var ruins:FlxSprite = new FlxSprite(-200,0).loadGraphic(Paths.image('warzone/tankRuins'));
						ruins.scrollFactor.set(0.35, 0.35);
						ruins.setGraphicSize(Std.int(ruins.width * 1.1));
						ruins.updateHitbox();
						ruins.antialiasing = true;
						add(ruins);
	
						var smokeLeft:FlxSprite = new FlxSprite(-200,-100);
									smokeLeft.frames = Paths.getSparrowAtlas('warzone/smokeLeft');
									smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft ', 24, true);
									smokeLeft.scrollFactor.set(0.4, 0.4);
									smokeLeft.antialiasing = true;
									smokeLeft.animation.play('idle');
									add(smokeLeft);
					
									var smokeRight:FlxSprite = new FlxSprite(1100,-100);
									smokeRight.frames = Paths.getSparrowAtlas('warzone/smokeRight');
									smokeRight.animation.addByPrefix('idle', 'SmokeRight ', 24, true);
									smokeRight.scrollFactor.set(0.4, 0.4);
									smokeRight.antialiasing = true;
									smokeRight.animation.play('idle');
									
									add(smokeRight);
	
									var tower:FlxSprite = new FlxSprite(100, 120);
									tower.frames = Paths.getSparrowAtlas('warzone/tankWatchtower');
									tower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
									tower.antialiasing = true;
	
									add(tower);
	
									
					
									var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('warzone/tankGround'));
									ground.scrollFactor.set();
									ground.antialiasing = true;
									ground.setGraphicSize(Std.int(ground.width * 1.15));
									ground.scrollFactor.set(1, 1);
	
									add(ground);
				}
			default: // custom stages
				{
					defaultCamZoom = stageData.defaultZoom;
					for (layer in stageData.layerArray)
					{
						var loadedLayer:FlxSprite = new FlxSprite(layer.xAxis, layer.yAxis).loadGraphic(Paths.image(layer.directory));
						loadedLayer.scrollFactor.set(layer.scrollX, layer.scrollY);
						loadedLayer.setGraphicSize(Std.int(loadedLayer.width * layer.scale));
						loadedLayer.flipX = layer.flipX;
						loadedLayer.flipY = layer.flipY;
						add(loadedLayer);
					}
				}
		}

		isPixelStage = curStage.startsWith('school') || stageData.isPixelStage;

		var gfVersion:String = 'gf';

		switch (SONG.gfVersion)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
				}
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 175;

			default:
				if (curStage == stageData.name)
				{
					dad.x = stageData.opponent[0];
					dad.y = stageData.opponent[1];
				}
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			default:
				if (curStage == stageData.name)
				{
					boyfriend.x = stageData.boyfriend[0];
					boyfriend.y = stageData.boyfriend[1];
					gf.x = stageData.girlfriend[0];
					gf.y = stageData.girlfriend[1];
				}
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		if (chromeEnabled)
		{
			chromeShit = new ChromaticAberration();
			iconP1.shader = chromeShit;
			iconP2.shader = chromeShit;
			healthBar.shader = chromeShit;
			dad.shader = chromeShit;
			gf.shader = chromeShit;
			chromeShit.rOffset.value = [0.002, 0];
			chromeShit.gOffset.value = [-0.002, 0];
			chromeShit.bOffset.value = [0.002, 0];
		}
		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(FlxG.save.data.middlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X,
			FlxG.save.data.downscroll ? FlxG.height - 150 : 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		cpuStrums = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new FlxSprite(0, FlxG.height * (FlxG.save.data.downscroll ? 0.1 : 0.9)).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		infoTxt = new FlxText(4, 0, 0, SONG.song + " - " + CoolUtil.difficultyString(false), 16);
		infoTxt.y = FlxG.height - infoTxt.height;
		infoTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoTxt.scrollFactor.set();
		infoTxt.borderSize = 2;
		infoTxt.antialiasing = true;
		add(infoTxt);

		scoreTxt = new FlxText(0, healthBarBG.y + 40, FlxG.width, "", 18);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		scoreTxt.scrollFactor.set();
		scoreTxt.antialiasing = true;
		add(scoreTxt);

		ratingCntr = new FlxText(20, 0, 0, "", 20);
		ratingCntr.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ratingCntr.borderSize = 2;
		ratingCntr.borderQuality = 2;
		ratingCntr.scrollFactor.set();
		ratingCntr.cameras = [camHUD];
		ratingCntr.screenCenter(Y);
		if (FlxG.save.data.ratingCntr)
		{
			add(ratingCntr);
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		infoTxt.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		setOnLuas('startingSong', startingSong);

		var file:String = 'data/' + PlayState.SONG.song.toLowerCase() + '/modchart';

		if (Assets.exists(Paths.lua(file, 'preload')))
		{
			LoggingUtil.writeToLogFile('Modchart Found!');
			file = Paths.lua(file, 'preload');
			luaArray.push(new MagModChart(file));
		}
		#if MODS
		else if (FileSystem.exists(Paths.modLua(file)))
		{
			LoggingUtil.writeToLogFile('Modchart Found!');
			file = Paths.modLua(file);
			luaArray.push(new MagModChart(file));
		}
		#end

		var filesInserted:Array<String> = [];
		var folders:Array<String> = [Paths.getPreloadPath('scripts/')];
		folders.insert(0, Paths.modFolder('scripts/'));
		for (folder in folders)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesInserted.contains(file))
					{
						LoggingUtil.writeToLogFile('Global Modchart Found!');

						luaArray.push(new MagModChart(folder + file));

						filesInserted.push(file);
					}

					if (file.endsWith('.hx') && !filesInserted.contains(file))
					{
						LoggingUtil.writeToLogFile('Script Found!');

						var expr = File.getContent(Paths.hscript(file));
						var parser = new hscript.Parser();
						parser.allowTypes = true;
						parser.allowJSON = true;
						parser.allowMetadata = true;
						setDefaultVariables();
						var ast = parser.parseString(expr);

						interp.execute(ast);
						trace(interp.execute(ast));

						filesInserted.push(file);
					}
				}
			}
		}

		for (noteFile in FileSystem.readDirectory(Paths.modFolder('custom_notetypes/')))
		{
			if (noteFile != null)
			{
				var filesInserted:Array<String> = [];
				var folders:Array<String> = [Paths.getPreloadPath('custom_notetypes/')];
				folders.insert(0, Paths.modFolder('custom_notetypes/'));
				for (folder in folders)
				{
					if (FileSystem.exists(folder))
					{
						for (file in FileSystem.readDirectory(folder))
						{
							if (file.endsWith('.hx') && !filesInserted.contains(file))
							{
								// Dummy variable to prevent the note script from crashing
								var expr = File.getContent(Paths.note(file));
								var parser = new hscript.Parser();
								parser.allowTypes = true;
								parser.allowJSON = true;
								parser.allowMetadata = true;
								var ast = parser.parseString(expr);
								interp.variables.set("add", add);
								interp.variables.set("note", new FlxSprite());
								interp.variables.set("update", function(elapsed:Float)
								{
								});
								interp.variables.set("create", function()
								{
								});
								interp.variables.set("noteMiss", function(note:Note)
								{
								});
								interp.variables.set("goodNoteHit", function(note:Note)
								{
								});
								interp.variables.set("CustomState", CustomState);
								interp.variables.set("remove", remove);
								interp.variables.set("inCutscene", this.inCutscene);
								interp.variables.set("PlayState", PlayState);
								interp.variables.set("DiscordClient", DiscordClient);
								interp.variables.set("WiggleEffectType", WiggleEffect.WiggleEffectType);
								interp.variables.set("FlxBasic", flixel.FlxBasic);
								interp.variables.set("MidSongEvent", Song.MidSongEvent);
								interp.variables.set("FlxCamera", flixel.FlxCamera);
								interp.variables.set("ChromaticAberration", shaders.ChromaticAberration);
								interp.variables.set("FlxG", flixel.FlxG);
								interp.variables.set("FlxGame", flixel.FlxGame);
								interp.variables.set("FlxObject", flixel.FlxObject);
								interp.variables.set("FlxSprite", flixel.FlxSprite);
								interp.variables.set("FlxState", flixel.FlxState);
								interp.variables.set("FlxSubState", flixel.FlxSubState);
								interp.variables.set("FlxGridOverlay", flixel.addons.display.FlxGridOverlay);
								interp.variables.set("FlxTrail", flixel.addons.effects.FlxTrail);
								interp.variables.set("FlxTrailArea", flixel.addons.effects.FlxTrailArea);
								interp.variables.set("FlxEffectSprite", flixel.addons.effects.chainable.FlxEffectSprite);
								interp.variables.set("FlxWaveEffect", flixel.addons.effects.chainable.FlxWaveEffect);
								interp.variables.set("FlxTransitionableState", flixel.addons.transition.FlxTransitionableState);
								interp.variables.set("FlxAtlas", flixel.graphics.atlas.FlxAtlas);
								interp.variables.set("FlxAtlasFrames", flixel.graphics.frames.FlxAtlasFrames);
								interp.variables.set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
								interp.variables.set("FlxMath", flixel.math.FlxMath);
								interp.variables.set("FlxPoint", flixel.math.FlxPoint);
								interp.variables.set("FlxRect", flixel.math.FlxRect);
								interp.variables.set("FlxSound", flixel.system.FlxSound);
								interp.variables.set("FlxText", flixel.text.FlxText);
								interp.variables.set("FlxEase", flixel.tweens.FlxEase);
								interp.variables.set("FlxTween", flixel.tweens.FlxTween);
								interp.variables.set("FlxBar", flixel.ui.FlxBar);
								interp.variables.set("FlxCollision", flixel.util.FlxCollision);
								interp.variables.set("FlxSort", flixel.util.FlxSort);
								interp.variables.set("FlxStringUtil", flixel.util.FlxStringUtil);
								interp.variables.set("FlxTimer", flixel.util.FlxTimer);
								interp.variables.set("Json", Json);
								interp.variables.set("Assets", lime.utils.Assets);
								interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
								interp.variables.set("Exception", haxe.Exception);
								interp.variables.set("Lib", openfl.Lib);
								interp.variables.set("OpenFlAssets", openfl.utils.Assets);
								#if sys
								interp.variables.set("File", sys.io.File);
								interp.variables.set("FileSystem", sys.FileSystem);
								interp.variables.set("FlxGraphic", flixel.graphics.FlxGraphic);
								interp.variables.set("BitmapData", openfl.display.BitmapData);
								#end
								interp.variables.set("Parser", hscript.Parser);
								interp.variables.set("Interp", hscript.Interp);
								interp.variables.set("ModsMenu", modloader.ModsMenu);
								interp.variables.set("Paths", Paths);
								interp.variables.set("Note", Note);
								interp.variables.set("health", this.health);
								interp.variables.set("CurrentPlayState", this);

								interp.execute(ast);
								trace(interp.execute(ast));

								filesInserted.push(file);
							}
						}
					}
				}
			}
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						snapCamFollowToPos(400, -2050);
						FlxG.camera.focusOn(camFollow);
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					if (SONG.dialoguetoggle != 'true')
					{
						startCountdown();
					}
			}
			switch (SONG.dialoguetoggle)
			{
				case 'true':
					magengineIntro(doof);

				case 'false':
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
			}
			startCountdown();
		}

		super.create();
	}

	override public function destroy()
	{
		usedPlayFeatures = false;
		practiceAllowed = false;
		cpuControlled = false;
		super.destroy();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
			}
			remove(black);
		});
	}

	function magengineIntro(?dialogueBox:DialogueBox):Void
	{
		if (dialogueBox != null)
		{
			trace('cutsceneee');
			inCutscene = true;
			add(dialogueBox);
		}
	}

	public function idleCharShit(beat:Int)
	{
		if (beat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
			gf.dance();

		if (beat % 2 == 0)
		{
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.dance();

			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
				dad.dance();
		}
		else if (dad.danceIdle
			&& dad.animation.curAnim.name != null
			&& !dad.curCharacter.startsWith('gf')
			&& !dad.animation.curAnim.name.startsWith("sing")
			&& !dad.stunned)
		{
			dad.dance();
		}
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		if (startedCountdown)
		{
			callOnLuas('startCountdown', []);
			return;
		}
		var ret:Dynamic = callOnLuas('startCountdown', []);
		if (ret != MagModChart.functionStop)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);

			for (i in 0...playerStrums.length)
			{
				setOnLuas('defPlrStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defPlrStrumY' + i, playerStrums.members[i].y);
			}

			for (i in 0...cpuStrums.length)
			{
				setOnLuas('defOppStrumX' + i, cpuStrums.members[i].x);
				setOnLuas('defOppStrumY' + i, cpuStrums.members[i].y);
			}
			talking = false;
			startedCountdown = true;
			setOnLuas('startedCountdown', startedCountdown);
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				idleCharShit(tmr.loopsLeft);

				var introAlts:Array<String> = ['ready', "set", "go"];
				var altSuffix:String = "";

				if (isPixelStage)
				{
					introAlts = ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel'];
					altSuffix = '-pixel';
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.screenCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();
						go.screenCenter();

						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					case 4:
				}

				swagCounter++;
				// generateSong('fresh');
			}, 5);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		setOnLuas('startingSong', startingSong);

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		setOnLuas('songLength', songLength);

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
		callOnLuas('startSong', []);
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		// var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteType:Int = songNotes[3];
				var daCustomNote:String = songNotes[4];
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, isPixelStage, oldNote, false, daNoteType, daCustomNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, isPixelStage,
						oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats++;
		}

		// trace(unspawnNotes.length);
		// playerCounter++;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			babyArrow = new FlxSprite(FlxG.save.data.middlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y);

			if (isPixelStage)
			{
				babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
				babyArrow.animation.add('green', [6]);
				babyArrow.animation.add('red', [7]);
				babyArrow.animation.add('blue', [5]);
				babyArrow.animation.add('purplel', [4]);

				babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.add('static', [0]);
						babyArrow.animation.add('pressed', [4, 8], 12, false);
						babyArrow.animation.add('confirm', [12, 16], 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.add('static', [1]);
						babyArrow.animation.add('pressed', [5, 9], 12, false);
						babyArrow.animation.add('confirm', [13, 17], 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.add('static', [2]);
						babyArrow.animation.add('pressed', [6, 10], 12, false);
						babyArrow.animation.add('confirm', [14, 18], 12, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.add('static', [3]);
						babyArrow.animation.add('pressed', [7, 11], 12, false);
						babyArrow.animation.add('confirm', [15, 19], 24, false);
				}
			}
			else
			{
				if (FileSystem.exists(Paths.skinFolder('notes/NOTE_assets.png')))
				{
					babyArrow.frames = Paths.getSkinsSparrowAtlas('notes/NOTE_assets');
				}
				else
				{
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
				}
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = true;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', 'arrowLEFT');
						babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', 'arrowUP');
						babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
						babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
				}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (FlxG.save.data.transparentNotes)
				babyArrow.alpha = noteTransparencyLevel;

			if (!isStoryMode || storyPlaylist.length == originalStoryPlaylistLength)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: (FlxG.save.data.transparentNotes ? noteTransparencyLevel : 1)}, 1,
					{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if (FlxG.save.data.middlescroll)
					babyArrow.visible = false;
				cpuStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});
		}
	}

	function moveCameraSection(id:Int = 0):Void
	{
		if (SONG.notes[id] == null)
			return;

		moveCamera(!SONG.notes[id].mustHitSection);
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			if (dad.cameraPosition != null)
			{
				camFollow.x += dad.cameraPosition[0];
				camFollow.y += dad.cameraPosition[1];
			}
			switch (dad.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
				case 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			tweenCam();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			tweenCam(true);
		}
		setOnLuas('cameraX', camFollow.x);
		setOnLuas('cameraY', camFollow.y);
		setOnLuas('botPlay', cpuControlled);
	}

	function tweenCam(out:Bool = false)
	{
		var zoom:Float = 1.3;
		if (out)
			zoom = 1;
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != zoom)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: zoom}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			callOnLuas('resume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		callOnHscript("update", [elapsed]);

		if (!FlxG.save.data.fpsCap)
		{
			openfl.Lib.current.stage.frameRate = 999;
		}
		else
		{
			openfl.Lib.current.stage.frameRate = 120;
		}

		#if !debug
		perfectMode = false;
		#end

		time = elapsed;

		if (chromeEnabled)
		{
			if (chromeShit.rOffset.value[1] > 0)
			{
				chromeShit.rOffset.value[1] -= 0.01 * elapsed;
			}
			else if (chromeShit.rOffset.value[1] < 0)
			{
				chromeShit.rOffset.value[1] = 0;
			}

			if (chromeShit.gOffset.value[0] < 0)
			{
				chromeShit.gOffset.value[0] += 0.01 * elapsed;
			}
			else if (chromeShit.gOffset.value[0] > 0)
			{
				chromeShit.gOffset.value[0] = 0;
			}

			if (chromeShit.gOffset.value[1] < 0)
			{
				chromeShit.gOffset.value[1] += 0.01 * elapsed;
			}
			else if (chromeShit.gOffset.value[1] > 0)
			{
				chromeShit.gOffset.value[1] = 0;
			}

			if (chromeShit.bOffset.value[0] > 0)
			{
				chromeShit.bOffset.value[0] -= 0.01 * elapsed;
			}
			else if (chromeShit.bOffset.value[0] < 0)
			{
				chromeShit.bOffset.value[0] = 0;
			}

			if (chromeShit.bOffset.value[1] < 0)
			{
				chromeShit.bOffset.value[1] += 0.01 * elapsed;
			}
			else if (chromeShit.bOffset.value[1] > 0)
			{
				chromeShit.bOffset.value[1] = 0;
			}
		}
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		super.update(elapsed);
		callOnLuas('update', [elapsed]);

		ratingCntr.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';

		if (cpuControlled)
			scoreTxt.text = "BOTPLAY";
		else
			scoreTxt.text = 'Score: ${songScore} | Misses: ${misses}'
				+ (FlxG.save.data.accuracy ? ' | Accuracy: ' + CoolUtil.truncateFloat(accuracy, 2) + '%' : '');

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('pause', []);
			if (ret != MagModChart.functionStop)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
					MusicBeatState.switchState(new GitarooPause());
				else
				{
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
		var mult:Float;

		mult = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		mult = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// MusicBeatState.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// MusicBeatState.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health++;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			var ret:Dynamic = callOnLuas('gameOver', []);
			if (ret != MagModChart.functionStop)
			{
				boyfriend.stunned = true;

				bbCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if (roundedSpeed < 1)
				time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				if (FlxG.save.data.middlescroll && !dunceNote.mustPress)
					dunceNote.visible = false;
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumY:Float = 0;
				if (daNote.mustPress)
					strumY = playerStrums.members[daNote.noteData].y;
				else
					strumY = cpuStrums.members[daNote.noteData].y;
				var center:Float = strumY + Note.swagWidth / 2;

				if (FlxG.save.data.downscroll)
				{
					daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
							if (isPixelStage)
								daNote.y += 8;
							else
								daNote.y++;
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (daNote.mustPress && cpuControlled)
				{
					if (daNote.isSustainNote && daNote.canBeHit)
						goodNoteHit(daNote);
					else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
						goodNoteHit(daNote);
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					vocals.volume = 1;

					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					charSing(dad, Math.abs(daNote.noteData), altAnim);
					strumsPlay(cpuStrums, Math.abs(daNote.noteData));

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if (FlxG.save.data.downscroll)
					doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
						noteMiss(daNote);

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (cpuControlled)
			strumsPlay(playerStrums, null, true, true);

		strumsPlay(cpuStrums, null, true);

		if (!inCutscene)
		{
			if (!cpuControlled)
				keyShit();
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}

			interp.variables.set("health", health);
			setOnLuas('health', health);
			setOnLuas('botplayEnabled', cpuControlled);
			setOnLuas('downscrollEnabled', FlxG.save.data.downscroll);
			setOnLuas('middlescrollEnabled', FlxG.save.data.middlescroll);
			setOnLuas('accuracyEnabled', FlxG.save.data.accuracy);
			setOnLuas('noteSplashesEnabled', FlxG.save.data.splooshes);
			for (i in 0...playerStrums.length)
			{
				setOnLuas('defaultPlayerStrumXAxis' + i, 0);
				setOnLuas('defaultPlayerStrumYAxis' + i, 0);
			}

			for (i in 0...cpuStrums.length)
			{
				setOnLuas('defaultPlayer2StrumXAxis' + i, 0);
				setOnLuas('defaultPlayer2StrumYAxis' + i, 0);
			}

			callOnLuas('updateEnd', [elapsed]);
		}

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	private var preventLuaRemove:Bool = false;

	public function removeLua(lua:MagModChart)
	{
		if (luaArray != null && !preventLuaRemove)
		{
			luaArray.remove(lua);
		}
	}

	public function endSong():Void
	{
		#if SCRIPTS
		var ret:Dynamic = callOnLuas('endSong', []);
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		bbCounter = 0;
		if (!usedPlayFeatures && SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			if (!usedPlayFeatures)
				campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				MusicBeatState.switchState(new StoryMenuState());

				if (!usedPlayFeatures && SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				#if sys
				if (SONG.videotoggle == 'true')
				{
					var video:MP4Handler = new MP4Handler();
					video.playMP4(Paths.video(SONG.song.toLowerCase() + 'Video'));
					video.finishCallback = function()
					{
						switchSong(difficulty);
					}
				}
				else
					switchSong(difficulty);
				#else
				switchSong(difficulty);
				#end
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			if (FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			MusicBeatState.switchState(new FreeplayState());
		}
	}

	private function switchSong(difficulty:String)
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		prevCamFollow = camFollow;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		FlxG.sound.music.stop();

		LoadingState.loadAndSwitchState(new PlayState());
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.4;

		var rating:FlxSprite = new FlxSprite();

		var daRating:String = Conductor.judgeNote(note, noteDiff);

		var score:Int = 0;

		switch (daRating)
		{
			case "shit":
				shits++;
				score += 50;
			case "bad":
				bads++;
				totalNotesHit += 0.5;
				score += 100;
			case "good":
				goods++;
				totalNotesHit += 0.75;
				score += 200;
			case "sick":
				sicks++;
				totalNotesHit++;
				score += 350;
				if (FlxG.save.data.splooshes && note.noteType == 0)
				{
					var sploosh:NoteSplash = new NoteSplash(note.x, playerStrums.members[note.noteData].y, note.noteData, isPixelStage);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + note.noteData);
					sploosh.animation.finishCallback = function(name) sploosh.kill();
					add(sploosh);
				}
		}

		if (!cpuControlled)
			songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (isPixelStage)
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (FlxG.save.data.comboOffset == null)
			FlxG.save.data.comboOffset = [0, 0, 0, 0];

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.x += FlxG.save.data.comboOffset[0];
		rating.y -= FlxG.save.data.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.x += FlxG.save.data.comboOffset[0];
		comboSpr.y -= FlxG.save.data.comboOffset[1];

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += FlxG.save.data.comboOffset[2];
			numScore.y -= FlxG.save.data.comboOffset[3];

			if (!isPixelStage)
			{
				numScore.antialiasing = FlxG.save.data.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection++;
	}

	// stilic fixed this (thanks stilic)
	private function keyShit():Void
	{
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var controlHoldArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

		// FlxG.watch.addQuick('asdfa', upP);
		if (!cpuControlled && !boyfriend.stunned && generatedMusic)
		{
			// input system from psych
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					goodNoteHit(daNote);
				}
			});

			if (!endingSong)
			{
				if (!controlHoldArray.contains(true)
					&& boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
					&& boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();

				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !FlxG.save.data.ghostTapping;

				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if (controlArray[daNote.noteData])
						{
							sortedNotesList.push(daNote);
							// notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else if (canMiss)
				{
					for (i in 0...controlArray.length)
					{
						if (controlArray[i])
							noteMissPress(i);
					}
				}

				Conductor.songPosition = lastTime;
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.singDuration * 0.001
			&& !controlHoldArray.contains(true)
			&& (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')))
		{
			boyfriend.dance();
		}

		if (!cpuControlled)
			strumsPlay(playerStrums, null, true, true);
	}

	function noteMissPress(direction:Float = 1):Void
	{
		// note miss when player press where there are not any notes
		if (!boyfriend.stunned)
		{
			if (!practiceAllowed)
				health -= 0.05;

			if (FlxG.save.data.ghostTapping)
				return;

			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');
			combo = 0;

			if (!practiceAllowed)
				songScore -= 10;
			if (!endingSong)
				misses++;
			updateAccuracy();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			charSing(boyfriend, direction, "miss");
			vocals.volume = 0;
		}
	}

	function noteMiss(note:Note):Void
	{
		// miss when note is offscreen
		callOnHscript('noteMiss', [note]);

		if (!practiceAllowed && note.noteType != 1 && note.noteType != 2 && note.customNote == "")
		{
			health -= 0.0475;
			combo = 0;

			songScore -= 10;
			misses++;
			updateAccuracy();

			charSing(boyfriend, Math.abs(note.noteData), "miss");
			vocals.volume = 0;
		}
	}

	function strumsPlay(strums:FlxTypedGroup<FlxSprite>, ?direction:Float = 1, ?staticAnim:Bool = false, ?isPlayer:Bool = false)
	{
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var controlReleaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var controlHoldArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		strums.forEach(function(spr:FlxSprite)
		{
			if (!isPlayer && staticAnim && spr.animation.finished)
			{
				if (FlxG.save.data.transparentNotes)
					spr.alpha = noteTransparencyLevel;

				spr.animation.play('static');
				spr.centerOffsets();
			}

			if (!controlHoldArray[spr.ID] && isPlayer && staticAnim && spr.animation.finished)
			{
				if (FlxG.save.data.transparentNotes)
					spr.alpha = noteTransparencyLevel;

				spr.animation.play('static');
				spr.centerOffsets();
			}

			if (isPlayer && staticAnim)
			{
				if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				{
					if (FlxG.save.data.transparentNotes)
						spr.alpha = 1;

					spr.animation.play('pressed', true);
				}
				if (controlReleaseArray[spr.ID])
				{
					if (FlxG.save.data.transparentNotes)
						spr.alpha = noteTransparencyLevel;

					spr.animation.play('static', true);
				}
			}
			else if ((isPlayer || FlxG.save.data.cpuNotesGlow) && !staticAnim && direction == spr.ID)
			{
				if (FlxG.save.data.transparentNotes)
					spr.alpha = 1;

				spr.animation.play('confirm', true);
			}

			if (spr.animation.curAnim.name == 'confirm' && !isPixelStage)
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function charSing(char:Character, direction:Float, alt:String = '')
	{
		switch (direction)
		{
			case 0:
				char.playAnim('singLEFT' + alt, true);
			case 1:
				char.playAnim('singDOWN' + alt, true);
			case 2:
				char.playAnim('singUP' + alt, true);
			case 3:
				char.playAnim('singRIGHT' + alt, true);
		}

		char.holdTimer = 0;
	}

	public function updateAccuracy()
	{
		totalPlayed++;
		accuracy = totalNotesHit / totalPlayed * 100;
		setOnLuas('accuracy', accuracy);
		ratingCntr.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			callOnHscript('goodNoteHit', [note]);

			if (cpuControlled && note.isDangerousNote)
				return;

			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo++;
			}
			else
				totalNotesHit++;

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			charSing(boyfriend, Math.abs(note.noteData));

			if (note.noteType == 1)
			{
				if (!practiceAllowed)
					health -= 0.45;
				note.wasGoodHit = true;
				note.canBeHit = false;
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else if (note.noteType == 2)
			{
				health = 0;
				note.wasGoodHit = true;
				note.canBeHit = false;
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			strumsPlay(playerStrums, Math.abs(note.noteData), false, true);

			note.wasGoodHit = true;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			if (note.noteType != 1 && note.noteType != 2)
			{
				updateAccuracy();
			}
			setOnLuas('noteHits', totalNotesHit);
			setOnLuas('health', health);
			callOnLuas('noteHit', [note.noteData]);
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars--;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		if (gf.animation.curAnim.finished)
		{
			gf.playAnim('danceRight');
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		callOnHscript("stepHit");

		super.stepHit();

		if (SONG.events != null)
		{
			for (i in SONG.events)
			{
				if (curStep == i.eventPos)
				{
					#if sys
					if (i.events == 'video')
					{
						var sprite:FlxSprite = new FlxSprite(Std.parseFloat(i.valueOne), Std.parseFloat(i.valueTwo));

						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video(SONG.song.toLowerCase() + 'Video'), null, sprite);

						add(sprite);
					}
					#end
					if (i.events == 'image')
					{
						var coolCounter:Int = 0;
						new FlxTimer().start(Std.parseFloat(i.valueTwo), function(cool:FlxTimer)
						{
							var swagsprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(i.valueOne));
							add(swagsprite);
							coolCounter++;

							if (coolCounter == 1)
							{
								cool.active = false;
								remove(swagsprite);
								coolCounter = 0;
							}
						});
					}
					if (i.events == 'character-change')
					{
						remove(dad);
						dad = new Character(dad.x, Std.parseFloat(i.valueTwo), i.valueOne);
						add(dad);
					}
					if (i.events == 'play-animation')
					{
						dad.playAnim(i.valueOne);
					}

					if (i.events == 'none')
					{
					}

					#if (MODS && SCRIPTS)
					var filesInsertedcool:Array<String> = [];
					var folderscool:Array<String> = [Paths.getPreloadPath('custom_events/')];
					folderscool.insert(0, Paths.modFolder('custom_events/'));
					for (folder in folderscool)
					{
						if (FileSystem.exists(folder))
						{
							for (file in FileSystem.readDirectory(folder))
							{
								if (file.endsWith('.hx') && !filesInsertedcool.contains(file))
								{
									LoggingUtil.writeToLogFile('Event Script Found!');
									var expr = File.getContent(Paths.event(file));
									var parser = new hscript.Parser();
									parser.allowTypes = true;
									parser.allowJSON = true;
									parser.allowMetadata = true;
									var ast = parser.parseString(expr);
									interp.variables.set("add", add);
									interp.variables.set("CustomState", CustomState);
									interp.variables.set("remove", remove);
									interp.variables.set("update", function(elapsed:Float)
									{
									});
									interp.variables.set("stepHit", function()
									{
									});
									interp.variables.set("beatHit", function()
									{
									});
									interp.variables.set("inCutscene", this.inCutscene);
									interp.variables.set("valueOne", i.valueOne);
									interp.variables.set("valueTwo", i.valueTwo);
									interp.variables.set("eventPosition", i.eventPos);
									interp.variables.set("eventName", i.events);
									interp.variables.set("PlayState", PlayState);
									interp.variables.set("DiscordClient", DiscordClient);
									interp.variables.set("WiggleEffectType", WiggleEffect.WiggleEffectType);
									interp.variables.set("FlxBasic", flixel.FlxBasic);
									interp.variables.set("MidSongEvent", Song.MidSongEvent);
									interp.variables.set("FlxCamera", flixel.FlxCamera);
									interp.variables.set("ChromaticAberration", shaders.ChromaticAberration);
									interp.variables.set("FlxG", flixel.FlxG);
									interp.variables.set("FlxGame", flixel.FlxGame);
									interp.variables.set("FlxObject", flixel.FlxObject);
									interp.variables.set("FlxSprite", flixel.FlxSprite);
									interp.variables.set("FlxState", flixel.FlxState);
									interp.variables.set("FlxSubState", flixel.FlxSubState);
									interp.variables.set("FlxGridOverlay", flixel.addons.display.FlxGridOverlay);
									interp.variables.set("FlxTrail", flixel.addons.effects.FlxTrail);
									interp.variables.set("FlxTrailArea", flixel.addons.effects.FlxTrailArea);
									interp.variables.set("FlxEffectSprite", flixel.addons.effects.chainable.FlxEffectSprite);
									interp.variables.set("FlxWaveEffect", flixel.addons.effects.chainable.FlxWaveEffect);
									interp.variables.set("FlxTransitionableState", flixel.addons.transition.FlxTransitionableState);
									interp.variables.set("FlxAtlas", flixel.graphics.atlas.FlxAtlas);
									interp.variables.set("FlxAtlasFrames", flixel.graphics.frames.FlxAtlasFrames);
									interp.variables.set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
									interp.variables.set("FlxMath", flixel.math.FlxMath);
									interp.variables.set("FlxPoint", flixel.math.FlxPoint);
									interp.variables.set("FlxRect", flixel.math.FlxRect);
									interp.variables.set("FlxSound", flixel.system.FlxSound);
									interp.variables.set("FlxText", flixel.text.FlxText);
									interp.variables.set("FlxEase", flixel.tweens.FlxEase);
									interp.variables.set("FlxTween", flixel.tweens.FlxTween);
									interp.variables.set("FlxBar", flixel.ui.FlxBar);
									interp.variables.set("FlxCollision", flixel.util.FlxCollision);
									interp.variables.set("FlxSort", flixel.util.FlxSort);
									interp.variables.set("FlxStringUtil", flixel.util.FlxStringUtil);
									interp.variables.set("FlxTimer", flixel.util.FlxTimer);
									interp.variables.set("Json", Json);
									interp.variables.set("Assets", lime.utils.Assets);
									interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
									interp.variables.set("Exception", haxe.Exception);
									interp.variables.set("Lib", openfl.Lib);
									interp.variables.set("OpenFlAssets", openfl.utils.Assets);
									#if sys
									interp.variables.set("File", sys.io.File);
									interp.variables.set("FileSystem", sys.FileSystem);
									interp.variables.set("FlxGraphic", flixel.graphics.FlxGraphic);
									interp.variables.set("BitmapData", openfl.display.BitmapData);
									#end
									interp.variables.set("Parser", hscript.Parser);
									interp.variables.set("Interp", hscript.Interp);
									interp.variables.set("ModsMenu", modloader.ModsMenu);
									interp.variables.set("Paths", Paths);
									interp.variables.set("CurrentPlayState", this);
									for (cooli in 0...filesInsertedcool.length)
									{
										if (i.events == filesInsertedcool[cooli])
										{
											interp.execute(ast);
										}
									}
									trace(interp.execute(ast));

									filesInsertedcool.push(file);
								}
							}
						}
					}
					#end

					/*if (event.events == 'shake-screen'){
							var coolCounter:Int = 0;
							new FlxTimer().start(Std.parseFloat(event.valueOne), function(cool:FlxTimer)
							{
							FlxG.camera.shake(Std.parseFloat(event.valueTwo), (60 / Conductor.bpm));
							coolCounter++;

							if (coolCounter == 1){
							  cool.active = false;
							  coolCounter = 0;
						  }
						  });
							
						}

						if (event.events == 'shake-hud'){
							var coolCounter:Int = 0;
							new FlxTimer().start(Std.parseFloat(event.valueOne), function(cool:FlxTimer)
							{
							camHUD.shake(Std.parseFloat(event.valueTwo), (60 / Conductor.bpm));
							coolCounter++;

							if (coolCounter == 1){
							  cool.active = false;
							  coolCounter = 0;
						  }
						  });
							
						}
					 */
				}
			}
		}
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		#if desktop
		setOnLuas('songLength', songLength);
		#end
		setOnLuas('curStep', curStep);
		callOnLuas('stepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		callOnHscript("beat");

		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].changeBPM)
		{
			Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			FlxG.log.add('CHANGED BPM!');
			setOnLuas('curBPM', Conductor.bpm);
			setOnLuas('crochet', Conductor.crochet);
			setOnLuas('stepCrochet', Conductor.stepCrochet);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong)
			moveCameraSection(Std.int(curStep / 16));
		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		var daNum:Int = 35;
		iconP1.setGraphicSize(Std.int(iconP1.width + daNum));
		iconP2.setGraphicSize(Std.int(iconP2.width + daNum));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		idleCharShit(curBeat);

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown++;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			lightningStrikeShit();
		setOnLuas('curBeat', curBeat);
		callOnLuas('beatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic
	{
		var returnedValue:Dynamic = MagModChart.functionContinue;

		#if MODS
		for (i in 0...luaArray.length)
		{
			var ret:Dynamic = luaArray[i].call(event, args);

			if (ret != MagModChart.functionContinue)
				returnedValue = ret;
		}
		#end

		return returnedValue;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if MODS
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	public function callOnHscript(functionToCall:String, ?params:Array<Any>):Dynamic
	{
		if (interp == null)
		{
			return null;
		}
		if (interp.variables.exists(functionToCall))
		{
			var functionH = interp.variables.get(functionToCall);
			if (params == null)
			{
				var result = null;
				result = functionH();
				return result;
			}
			else
			{
				var result = null;
				result = Reflect.callMethod(null, functionH, params);
				return result;
			}
		}
		return null;
	}

	public function setDefaultVariables()
	{
		interp.variables.set("add", add);
		interp.variables.set("CustomState", CustomState);
		interp.variables.set("remove", remove);
		interp.variables.set("create", function()
		{
		});
		interp.variables.set("update", function(elapsed:Float)
		{
		});
		interp.variables.set("stepHit", function()
		{
		});
		interp.variables.set("beatHit", function()
		{
		});
		interp.variables.set("update", function(elapsed:Float)
		{
		});
		interp.variables.set("create", function()
		{
		});
		interp.variables.set("inCutscene", this.inCutscene);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("DiscordClient", DiscordClient);
		interp.variables.set("WiggleEffectType", WiggleEffect.WiggleEffectType);
		interp.variables.set("FlxBasic", flixel.FlxBasic);
		interp.variables.set("MidSongEvent", Song.MidSongEvent);
		interp.variables.set("FlxCamera", flixel.FlxCamera);
		interp.variables.set("ChromaticAberration", shaders.ChromaticAberration);
		interp.variables.set("FlxG", flixel.FlxG);
		interp.variables.set("FlxGame", flixel.FlxGame);
		interp.variables.set("FlxObject", flixel.FlxObject);
		interp.variables.set("FlxSprite", flixel.FlxSprite);
		interp.variables.set("FlxState", flixel.FlxState);
		interp.variables.set("FlxSubState", flixel.FlxSubState);
		interp.variables.set("FlxGridOverlay", flixel.addons.display.FlxGridOverlay);
		interp.variables.set("FlxTrail", flixel.addons.effects.FlxTrail);
		interp.variables.set("FlxTrailArea", flixel.addons.effects.FlxTrailArea);
		interp.variables.set("FlxEffectSprite", flixel.addons.effects.chainable.FlxEffectSprite);
		interp.variables.set("FlxWaveEffect", flixel.addons.effects.chainable.FlxWaveEffect);
		interp.variables.set("FlxTransitionableState", flixel.addons.transition.FlxTransitionableState);
		interp.variables.set("FlxAtlas", flixel.graphics.atlas.FlxAtlas);
		interp.variables.set("FlxAtlasFrames", flixel.graphics.frames.FlxAtlasFrames);
		interp.variables.set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
		interp.variables.set("FlxPoint", flixel.math.FlxPoint);
		interp.variables.set("FlxRect", flixel.math.FlxRect);
		interp.variables.set("FlxSound", flixel.system.FlxSound);
		interp.variables.set("FlxText", flixel.text.FlxText);
		interp.variables.set("FlxEase", flixel.tweens.FlxEase);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("FlxBar", flixel.ui.FlxBar);
		interp.variables.set("FlxCollision", flixel.util.FlxCollision);
		interp.variables.set("FlxSort", flixel.util.FlxSort);
		interp.variables.set("FlxStringUtil", flixel.util.FlxStringUtil);
		interp.variables.set("FlxTimer", flixel.util.FlxTimer);
		interp.variables.set("Json", Json);
		interp.variables.set("Assets", lime.utils.Assets);
		interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
		interp.variables.set("Exception", haxe.Exception);
		interp.variables.set("Lib", openfl.Lib);
		interp.variables.set("CurrentPlayState", this);
		interp.variables.set("OpenFlAssets", openfl.utils.Assets);
		#if sys
		interp.variables.set("File", sys.io.File);
		interp.variables.set("FileSystem", sys.FileSystem);
		interp.variables.set("FlxGraphic", flixel.graphics.FlxGraphic);
		interp.variables.set("BitmapData", openfl.display.BitmapData);
		#end
		interp.variables.set("Parser", hscript.Parser);
		interp.variables.set("Interp", hscript.Interp);
		interp.variables.set("ModsMenu", modloader.ModsMenu);
		interp.variables.set("Paths", Paths);
	}

	var curLight:Int = 0;
}
