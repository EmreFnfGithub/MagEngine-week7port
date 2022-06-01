package;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class OffsetsState extends MusicBeatState
{
	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var camOther:FlxCamera;

	var infoText:FlxText;

	var coolText:FlxText;
	var rating:FlxSprite;
	var createdLayer:FlxSpriteGroup;

	var startMousePos:FlxPoint = new FlxPoint();
	var startComboOffset:FlxPoint = new FlxPoint();
	var holdingObjectType:Null<Bool> = null;

	var gf:Character;
	var boyfriend:Boyfriend;

	override function create()
	{
		// STOLEN FROM PLAYSTATE LMAO!!!!
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camHUD;
		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'preload'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'preload'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		coolText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		rating = new FlxSprite(300, 300).loadGraphic(Paths.image('sick', 'preload'));
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.cameras = [camHUD];
		add(rating);

		createdLayer = new FlxSpriteGroup();
		createdLayer.cameras = [camHUD];
		add(createdLayer);

		var seperatedScore:Array<Int> = [];
		for (i in 0...3)
		{
			seperatedScore.push(FlxG.random.int(0, 9));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite(43 * daLoop).loadGraphic(Paths.image("num" + i));
			numScore.cameras = [camHUD];
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.antialiasing = true;
			createdLayer.add(numScore);
			daLoop++;
		}

		repositionCombo();

		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		boyfriend = new Boyfriend(770, 450);
		add(boyfriend);

		infoText = new FlxText(5, FlxG.height - 28, 0, "Drag and drop the ratings and numbers to change the offsets. Press RESET to reset the offsets.", 12);
		infoText.scrollFactor.set();
		infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.cameras = [camHUD];
		infoText.antialiasing = true;
		add(infoText);

		Conductor.changeBPM(128);
		FlxG.sound.playMusic(Paths.music('breakfast', 'shared'));

		FlxG.mouse.visible = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.save.data.comboOffset == null)
			FlxG.save.data.comboOffset = [0, 0, 0, 0];

		// mouse dragging code from psych engine
		if (FlxG.mouse.justPressed)
		{
			holdingObjectType = null;
			FlxG.mouse.getScreenPosition(camHUD, startMousePos);
			if (startMousePos.x - createdLayer.x >= 0
				&& startMousePos.x - createdLayer.x <= createdLayer.width
				&& startMousePos.y - createdLayer.y >= 0
				&& startMousePos.y - createdLayer.y <= createdLayer.height)
			{
				holdingObjectType = true;
				startComboOffset.x = FlxG.save.data.comboOffset[2];
				startComboOffset.y = FlxG.save.data.comboOffset[3];
			}
			else if (startMousePos.x - rating.x >= 0
				&& startMousePos.x - rating.x <= rating.width
				&& startMousePos.y - rating.y >= 0
				&& startMousePos.y - rating.y <= rating.height)
			{
				holdingObjectType = false;
				FlxG.mouse.getScreenPosition(camHUD, startMousePos);
				startComboOffset.x = FlxG.save.data.comboOffset[0];
				startComboOffset.y = FlxG.save.data.comboOffset[1];
			}
		}
		if (FlxG.mouse.justReleased)
			holdingObjectType = null;

		if (holdingObjectType != null && FlxG.mouse.justMoved)
		{
			var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(camHUD);
			var addNum:Int = holdingObjectType ? 2 : 0;
			FlxG.save.data.comboOffset[addNum + 0] = Math.round((mousePos.x - startMousePos.x) + startComboOffset.x);
			FlxG.save.data.comboOffset[addNum + 1] = -Math.round((mousePos.y - startMousePos.y) - startComboOffset.y);
			repositionCombo();
		}

		if (controls.RESET)
		{
			for (i in 0...FlxG.save.data.comboOffset.length)
			{
				FlxG.save.data.comboOffset[i] = 0;
			}
			repositionCombo();
		}

		if (controls.BACK)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.save.flush();
			// double shit for double fix
			CustomFadeTransition.nextCamera = camHUD;
			MusicBeatState.switchState(new OptionsMenu());
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			gf.dance();
			boyfriend.dance();
		}
	}

	function repositionCombo()
	{
		rating.screenCenter();
		rating.x = coolText.x - 40 + FlxG.save.data.comboOffset[0];
		rating.y -= 60 + FlxG.save.data.comboOffset[1];

		createdLayer.screenCenter();
		createdLayer.x = coolText.x - 90 + FlxG.save.data.comboOffset[2];
		createdLayer.y += 80 - FlxG.save.data.comboOffset[3];
		// reloadTexts();
	}
}
