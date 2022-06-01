package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import haxe.Json;
import flixel.util.FlxColor;
import animateatlas.AtlasFrameMaker;
#if sys
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end

using StringTools;

// im using these things a lot lol
typedef SwagCharacter =
{
	var animations:Array<AnimationCool>;
	var image:String;
	var healthbarColor:Array<Int>;
	var cameraPosition:Array<Float>;
	var scale:Float;
	var flipX:Bool;
	var flipY:Bool;
}

typedef AnimationCool =
{
	var anim:String;
	var name:String;
	var offsets:Array<Int>;
	var loop:Bool;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var danceIdle:Bool = false;
	public var disabledDance:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var anim:String;
	public var name:String;
	public var swagOffsets:Bool;
	public var loop:Bool;
	public var animations:Array<AnimationCool>;
	public var image:String;

	public var healthbarColor:Array<Int>;

	public var scalecool:Float;

	public var varflipX:Bool;

	public var varflipY:Bool;

	public var cameraPosition:Array<Float>;

	public var stunned:Bool = false;

	public var singDuration:Float = 4;
	public var holding:Bool = false;
	public var holdTimer:Float = 0;

	public var imagePNG:String = '';
	public var barColor:FlxColor;
	public var animationsthing:Array<AnimationCool> = [];

	public var charArray:Array<String>;

	public var imageDir:String = "BOYFRIEND";

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				imageDir = 'GF_assets';
				if (FileSystem.exists(Paths.skinFolder('girlfriend/GF_assets.png')))
				{
					tex = Paths.getSkinsSparrowAtlas('girlfriend/' + imageDir);
				}
				else
				{
					tex = Paths.getSparrowAtlas(imageDir, 'shared');
				}
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFromFile(curCharacter);
				barColor = FlxColor.fromRGB(165, 0, 77);
				playAnim('danceRight');

			case 'gf-christmas':
				imageDir = 'characters/gfChristmas';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFromFile(curCharacter);
				barColor = 0xA5004D;
				playAnim('danceRight');

			case 'gf-car':
				imageDir = 'characters/gfCar';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				loadOffsetFromFile(curCharacter);
				barColor = FlxColor.fromRGB(165, 0, 77);
				playAnim('danceRight');

			case 'gf-pixel':
				imageDir = 'characters/gfPixel';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFromFile(curCharacter);

				playAnim('danceRight');
				barColor = FlxColor.fromRGB(165, 0, 77);
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				imageDir = 'DADDY_DEAREST';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFaf66ce;
				playAnim('idle');
			case 'spooky':
				imageDir = 'characters/spooky_kids_assets';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFd57e00;
				playAnim('danceRight');
			case 'mom':
				imageDir = 'characters/Mom_Assets';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFd8558e;
				playAnim('idle');

			case 'mom-car':
				imageDir = 'characters/momCar';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFd8558e;

				playAnim('idle');
			case 'monster':
				imageDir = 'characters/Monster_Assets';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFf3ff6e;
				playAnim('idle');
			case 'monster-christmas':
				imageDir = 'characters/monsterChristmas';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFf3ff6e;
				playAnim('idle');
			case 'pico':
				imageDir = 'characters/Pico_FNF_assetss';
				tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFb7d855;
				playAnim('idle');

				flipX = true;

			case 'bf':
				imageDir = 'BOYFRIEND';
				var tex:FlxAtlasFrames;
				if (FileSystem.exists(Paths.skinFolder('boyfriend/BOYFRIEND.png')))
				{
					tex = Paths.getSkinsSparrowAtlas('boyfriend/' + imageDir);
				}
				else
				{
					tex = Paths.getSparrowAtlas(imageDir, 'shared');
				}
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFromFile(curCharacter);

				playAnim('idle');
				barColor = 0xFF31b0d1;
				flipX = true;

			case 'bf-christmas':
				imageDir = 'characters/bfChristmas';
				var tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFF31b0d1;
				playAnim('idle');

				flipX = true;
			case 'bf-car':
				imageDir = 'characters/bfCar';
				var tex = Paths.getSparrowAtlas(imageDir, 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFF31b0d1;
				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				imageDir = 'characters/bfPixel';
				frames = Paths.getSparrowAtlas(imageDir, 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				loadOffsetFromFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				barColor = 0xFF31b0d1;
				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				imageDir = 'characters/bfPixelsDEAD';
				frames = Paths.getSparrowAtlas(imageDir, 'shared');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				loadOffsetFromFile(curCharacter);

				playAnim('firstDeath');
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				barColor = 0xFF31b0d1;
				flipX = true;

			case 'senpai':
				imageDir = 'characters/senpai';
				frames = Paths.getSparrowAtlas(imageDir, 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsetFromFile(curCharacter);

				playAnim('idle');
				barColor = 0xFFffaa6f;
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				imageDir = 'characters/senpai';
				frames = Paths.getSparrowAtlas(imageDir, 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFFffaa6f;
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				imageDir = 'characters/spirit';
				frames = Paths.getPackerAtlas(imageDir, 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFromFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				barColor = 0xFFff3c6e;
				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				imageDir = 'characters/mom_dad_christmas_assets';
				frames = Paths.getSparrowAtlas(imageDir, 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				loadOffsetFromFile(curCharacter);
				barColor = 0xFF9a00f8;
				playAnim('idle');

				case 'tankman':
					tex = Paths.getSparrowAtlas('characters/tankmanCaptain');
					frames = tex;
					animation.addByPrefix('idle', "Tankman Idle Dance", 24);
					animation.addByPrefix('oldSingUP', 'Tankman UP note ', 24, false);
					animation.addByPrefix('singUP', 'Tankman UP note ', 24, false);
					animation.addByPrefix('oldSingDOWN', 'Tankman DOWN note ', 24, false);
					animation.addByPrefix('singDOWN', 'Tankman DOWN note ', 24, false);
					animation.addByPrefix('singLEFT', 'Tankman Right Note ', 24, false);
					animation.addByPrefix('singRIGHT', 'Tankman Note Left ', 24, false);
		
					animation.addByPrefix('ughAnim', 'TANKMAN UGH', 24, false);
					animation.addByPrefix('prettyGoodAnim', 'PRETTY GOOD', 24, false);
					addOffset('idle', 0, 0);
					addOffset('singRIGHT', -23, -30);
					addOffset('singDOWN', 58, -100);
					addOffset('singUP', 48, 49);
					addOffset('singLEFT', 83, -13);
					addOffset('prettyGoodAnim', -2, -10);
					playAnim('idle');

					y += 300;
					
					flipX = true;

					barColor = 0x303030;
				case 'bf-holding-gf':
				
					frames = Paths.getSparrowAtlas('characters/bfAndGF');
					animation.addByPrefix('idle', 'BF idle dance w gf0', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS0', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS0', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS0', 24, false);
		
					addOffset('idle', 0, 0);
					addOffset("singUP", -29, 10);
					addOffset("singRIGHT", -41, 23);
					addOffset("singLEFT", 12, 7);
					addOffset("singDOWN", -10, -10);
					addOffset("singUPmiss", -29, 10);
					addOffset("singRIGHTmiss", -41, 23);
					addOffset("singLEFTmiss", 12, 7);
					addOffset("singDOWNmiss", -10, -10);
				
					playAnim('idle');
			
					flipX = true;
				case 'pico-speaker':
				
					tex = Paths.getSparrowAtlas('characters/picoSpeaker');
					frames = tex;
							
					animation.addByIndices('idle', 'Pico shoot 1', [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], "", 24, true);
			
					animation.addByIndices('shoot1', 'Pico shoot 1', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, true);
					animation.addByIndices('shoot2', 'Pico shoot 2', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, false);
					animation.addByIndices('shoot3', 'Pico shoot 3', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, false);
					animation.addByIndices('shoot4', 'Pico shoot 4', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, false);
		
					addOffset('shoot1', 0, 0);
					addOffset('shoot2', -1, -128);
					addOffset('shoot3', 412, -64);
					addOffset('shoot4', 439, -19);
			
					playAnim('shoot1');
		    case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen');
				animation.addByIndices('sad', 'GF Crying at Gunpoint ', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);
					
	
				playAnim('danceRight');

			default:
				#if MODS
				var charKey:String = Paths.modFolder('custom_characters/' + curCharacter + '.json');
				var rawJson = File.getContent(charKey);
				var parsedJson:SwagCharacter = cast Json.parse(rawJson);
				frames = Paths.getModsSparrowAtlas(parsedJson.image);
				imagePNG = parsedJson.image;
				imageDir = imagePNG;
				animationsthing = parsedJson.animations;
				varflipY = parsedJson.flipY;
				varflipX = parsedJson.flipX;
				flipY = varflipY;
				flipX = varflipX;
				if (parsedJson.scale != 1)
				{
					scalecool = parsedJson.scale;
					setGraphicSize(Std.int(width * scalecool));
					updateHitbox();
				}
				cameraPosition = parsedJson.cameraPosition;
				healthbarColor = parsedJson.healthbarColor;
				barColor = FlxColor.fromRGB(parsedJson.healthbarColor[0], parsedJson.healthbarColor[1], parsedJson.healthbarColor[2]);
				if (Paths.fileExists(Paths.modFolder("images/characters/") + parsedJson.image + ".json", TEXT))
				{
					frames = AtlasFrameMaker.construct(Paths.modFolder("custom_characters/") + parsedJson.image);
				}
				else if (animationsthing != null && animationsthing.length > 0)
				{
					for (anim in animationsthing)
					{
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animLoop:Bool = !!anim.loop;
						if (anim.offsets != null && anim.offsets.length > 1)
						{
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
						animation.addByPrefix(animAnim, animName, 24, animLoop);
					}
				}
				#end
		}

		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadOffsetFromFile(character:String, library:String = 'shared')
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	public function loadOffsetFromthecoolFile(character:String)
	{
		var offset:Array<String> = CoolUtil.evenCoolerTextFile(Paths.modFolder('images/characters/' + character + "Offsets.txt"));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
				playAnim(animation.curAnim.name + '-loop');
		}
		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (!debugMode && !disabledDance)
		{
			holding = false;
			if (danceIdle)
			{
				if (!animation.curAnim.name.startsWith('hair'))
				{
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}
			else if (animation.getByName("idle") != null)
				playAnim("idle");
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function recalculateDanceIdle()
	{
		danceIdle = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
