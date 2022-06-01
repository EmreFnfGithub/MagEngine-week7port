package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if MODS
import polymod.format.ParseRules.TargetSignatureElement;
#end
import hscript.Expr;
import hscript.Parser;
import haxe.Json;
import hscript.Interp;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var noteType:Int = 0;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var isDangerousNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public var customNote:String = "";

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?pixelNote:Bool = false, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:Int = 0,
			?customNote:String = "")
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += (FlxG.save.data.middlescroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (isSustainNote && prevNote.noteType == 1)
			noteType == 1;
		else if (isSustainNote && prevNote.noteType == 2)
			noteType == 2;

		this.noteData = noteData;

		this.noteType = noteType;

		this.customNote = customNote;

		this.isDangerousNote = (this.noteType == 1 || this.noteType == 2);

		if (pixelNote)
		{
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

			animation.add('greenScroll', [6]);
			animation.add('redScroll', [7]);
			animation.add('blueScroll', [5]);
			animation.add('purpleScroll', [4]);

			if (isSustainNote)
			{
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

				animation.add('purpleholdend', [4]);
				animation.add('greenholdend', [6]);
				animation.add('redholdend', [7]);
				animation.add('blueholdend', [5]);

				animation.add('purplehold', [0]);
				animation.add('greenhold', [2]);
				animation.add('redhold', [3]);
				animation.add('bluehold', [1]);
			}

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		}
		else
		{
			antialiasing = true;
			switch (noteType)
			{
				case 1:
					{
						frames = Paths.getSparrowAtlas('HURT_NOTE_assets');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						setGraphicSize(Std.int(width * 0.7));
					}
				case 2:
					{
						frames = Paths.getSparrowAtlas('KILL_NOTE_assets');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						setGraphicSize(Std.int(width * 0.7));
					}
				default:
					{
						if (FileSystem.exists(Paths.skinFolder('notes/NOTE_assets.png')))
						{
							frames = Paths.getSkinsSparrowAtlas('notes/NOTE_assets');
						}
						else
						{
							frames = Paths.getSparrowAtlas('NOTE_assets');
						}
						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');

						setGraphicSize(Std.int(width * 0.7));
					}
			}
			if (customNote != null && customNote != "" && Math.isNaN(Std.parseFloat(customNote)))
			{
				{
					var interp = new Interp();
					var expr = File.getContent(Paths.note(customNote + ".hx"));
					var parser = new hscript.Parser();
					parser.allowTypes = true;
					parser.allowJSON = true;
					parser.allowMetadata = true;
					var ast = parser.parseString(expr);
					interp.variables.set("update", function(elapsed:Float)
					{
					});
					interp.variables.set("create", function()
					{
					});
					interp.variables.set("CustomState", CustomState);
					interp.variables.set("PlayState", PlayState);
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
					interp.variables.set("note", this);

					interp.execute(ast);

					setGraphicSize(Std.int(width * 0.7));
				}
			}
		}
		updateHitbox();

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;
			if (FlxG.save.data.downscroll)
				flipY = true;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.isPixelStage)
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isSustainNote && prevNote.noteType == 1)
		{
			this.kill();
		}

		if (isSustainNote && prevNote.noteType == 2)
		{
			this.kill();
		}

		if (mustPress)
		{
			if (noteType != 1 && noteType != 2)
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.6)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.4))
					canBeHit = true;
				else
					canBeHit = false;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
