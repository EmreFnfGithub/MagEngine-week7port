package tools;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import flixel.group.FlxSpriteGroup;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;
import flash.net.FileFilter;
import Character;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CharacterEditor extends MusicBeatState
{
	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;
	private var camTips:FlxCamera;
	private var camGrid:FlxCamera;
	private var camPeople:FlxCamera;
	private var camshit:FlxCamera;
	private var camhidden:FlxCamera;
	private var camG:FlxCamera;

	var alreadyPressed:Bool = false;
	var UI__character:FlxUITabMenu;
	var blackBox:FlxSprite;

	var ormaybeido:FlxButton;
	var idontcarelol:FlxButton;

	public static var unsavedChanges:Bool = false;

	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	var curSelected:Int = 0;

	var scaleStepper:FlxUINumericStepper;

	var UI_box:FlxUITabMenu;
	var UI_character:FlxUITabMenu;

	public static var curSelectedCharStepper:FlxUINumericStepper;

	var confirmAdded:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public var health:Float = 1;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public static var nameInputText:FlxUIInputText;
	public static var directoryInputText:FlxUIInputText;
	public static var directoryInputTextcool:FlxUIInputText;
	public static var xInputText:FlxUIInputText;
	public static var yInputText:FlxUIInputText;
	public static var bfInputText:FlxUIInputText;
	public static var opponentinputtext:FlxUIInputText;
	public static var zoominputtext:FlxUIInputText;
	public static var coolInputText:FlxUIInputText;
	public static var fInputText:FlxUIInputText;
	public static var yoInputText:FlxUIInputText;
	public static var goToPlayState:Bool = true;

	var actuallyCoolOffsetFile:String;

	public static var swagCharacter:SwagCharacter;

	public static var createdCharacter:Character;

	var cameraFollowPointer:FlxSprite;

	var isflippedX:FlxUICheckBox;

	var isflipY:FlxUICheckBox;

	var isflipX:FlxUICheckBox;

	override function create()
	{
		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		bg.antialiasing = true;
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		add(stageCurtains);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.1).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.WHITE, FlxColor.WHITE);

		FlxG.camera.follow(camFollow);

		var tabs = [
			{name: 'Animations', label: 'Animations'},
			{name: 'Settings', label: 'Settings'},
		];

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;
		camTips = new FlxCamera();
		camTips.bgColor.alpha = 0;
		camGrid = new FlxCamera();
		camGrid.bgColor.alpha = 0;
		camPeople = new FlxCamera();
		camPeople.bgColor.alpha = 0;
		camshit = new FlxCamera();
		camshit.bgColor.alpha = 0;
		camG = new FlxCamera();
		camG.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camshit);
		FlxG.cameras.add(camPeople);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxG.cameras.add(camTips);
		FlxG.cameras.add(camGrid);
		FlxG.cameras.add(camG);

		FlxCamera.defaultCameras = [camEditor];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		UI_character = new FlxUITabMenu(null, tabs, true);
		UI_character.cameras = [camEditor];

		UI_character.resize(350, 300);
		UI_character.x = UI_box.x - 100;
		UI_character.y = UI_box.y + UI_box.height;
		UI_character.scrollFactor.set();
		add(UI_character);

		var tipText:FlxText = new FlxText(FlxG.width - FlxG.width + 430, FlxG.height - 150, 0, "E/Q - Camera Zoom In/Out
        \nW/S - Next/Last Animation
		\nArrow Keys - Move Offsets
		\nSpace - Play The Current Animation
		\nShift - Multiply The Speed In\nWhich You Move The Offsets
        \nR - Reset Current Zoom", 12);
		tipText.cameras = [camTips];
		tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.x -= 420; // LMAO
		tipText.y -= tipText.height - 10;
		add(tipText);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		createdCharacter = new Character(0, 0, 'dad');
		add(createdCharacter);

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

		iconP1 = new HealthIcon('bf', true);
		iconP1.y = healthBarBG.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon('dad', false);
		iconP2.y = healthBarBG.y - (iconP2.height / 2);
		add(iconP2);

		healthBarBG.color = FlxColor.fromRGB(175, 102, 206);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		UI_character.selected_tab_id = 'Settings';

		addCharUI();
		addSettingsUI();
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	function addCharUI()
	{
		// heavily based off of addlayersui for stages but if it aint broke dont fix it i guess
		nameInputText = new FlxUIInputText(15, 50, 200, "", 8);
		var namelabel = new FlxText(15, nameInputText.y + 20, 64, 'Animation On .XML');
		coolInputText = new FlxUIInputText(15, nameInputText.y + 50, 200, "", 8);
		var coollabel = new FlxText(15, coolInputText.y + 20, 64, 'Animation Name');

		scaleStepper = new FlxUINumericStepper(240, coolInputText.y, 0.1, 1, 0, 10, 1);

		var scalelabel = new FlxText(240, scaleStepper.y + 20, 64, 'Scale');

		curSelectedCharStepper = new FlxUINumericStepper(15, scaleStepper.y + 150, 1, 0, 0, 0, 1);

		isflippedX = new FlxUICheckBox(240, scaleStepper.y + 50, null, null, "Looped", 100);

		isflippedX.checked = false;

		var addCharacter:FlxButton = new FlxButton(140, 20, "Add", function()
		{
			var lastAnim:String = '';
			if (createdCharacter.animationsthing[curSelected] != null)
			{
				lastAnim = createdCharacter.animationsthing[curSelected].anim;
			}

			var lastOffsets:Array<Int> = [0, 0];
			for (anim in createdCharacter.animationsthing)
			{
				if (coolInputText.text == anim.anim)
				{
					lastOffsets = anim.offsets;
					if (createdCharacter.animation.getByName(coolInputText.text) != null)
					{
						createdCharacter.animation.remove(coolInputText.text);
					}
					createdCharacter.animationsthing.remove(anim);
				}
			}

			var swaggyAnim:AnimationCool = {
				anim: coolInputText.text,
				name: nameInputText.text,
				loop: isflippedX.checked,
				offsets: lastOffsets
			};

			createdCharacter.animation.addByPrefix(swaggyAnim.anim, swaggyAnim.name, 24, swaggyAnim.loop);

			if (!createdCharacter.animOffsets.exists(swaggyAnim.anim))
			{
				createdCharacter.addOffset(swaggyAnim.anim, 0, 0);
			}
			createdCharacter.animationsthing.push(swaggyAnim);

			if (lastAnim == coolInputText.text)
			{
				var leAnim:FlxAnimation = createdCharacter.animation.getByName(lastAnim);
				if (leAnim != null && leAnim.frames.length > 0)
				{
					createdCharacter.playAnim(lastAnim, true);
				}
				else
				{
					for (i in 0...createdCharacter.animationsthing.length)
					{
						if (createdCharacter.animationsthing[i] != null)
						{
							leAnim = createdCharacter.animation.getByName(char.animationsthing[i].anim);
							if (leAnim != null && leAnim.frames.length > 0)
							{
								char.playAnim(createdCharacter.animationsthing[i].anim, true);
								curSelected = i;
								break;
							}
						}
					}
				}
			}
			unsavedChanges = true;
			genBoyOffsets();
		});

		var removeLayer:FlxButton = new FlxButton(40, 20, "Remove", function()
		{
			for (anim in createdCharacter.animationsthing)
			{
				if (coolInputText.text == anim.anim
					&& nameInputText.text != null
					&& coolInputText.text == anim.name
					&& nameInputText.text != null
					&& createdCharacter.animation.curAnim.finished)
				{
					var resetAnim:Bool = false;
					if (createdCharacter.animation.curAnim != null && anim.anim == createdCharacter.animation.curAnim.name)
						resetAnim = true;

					if (createdCharacter.animation.getByName(anim.anim) != null)
					{
						createdCharacter.animation.remove(anim.anim);
					}
					if (createdCharacter.animOffsets.exists(anim.anim))
					{
						createdCharacter.animOffsets.remove(anim.anim);
					}
					createdCharacter.animationsthing.remove(anim);

					if (resetAnim && createdCharacter.animationsthing.length > 0)
					{
						createdCharacter.playAnim(createdCharacter.animationsthing[0].anim, true);
					}
					genBoyOffsets();
					break;
				}
			}
			unsavedChanges = true;
		});

		removeLayer.color = FlxColor.RED;
		removeLayer.label.color = FlxColor.WHITE;

		var tab_group_anims = new FlxUI(null, UI_character);
		tab_group_anims.name = "Animations";
		tab_group_anims.add(nameInputText);
		tab_group_anims.add(isflippedX);
		tab_group_anims.add(addCharacter);
		tab_group_anims.add(removeLayer);
		tab_group_anims.add(namelabel);
		tab_group_anims.add(scalelabel);
		tab_group_anims.add(coollabel);
		tab_group_anims.add(coolInputText);
		tab_group_anims.add(scaleStepper);

		UI_character.addGroup(tab_group_anims);

		UI_character.scrollFactor.set();
	}

	function addSettingsUI()
	{
		directoryInputTextcool = new FlxUIInputText(15, 20, 200, "", 8);
		var directlabel = new FlxText(15, directoryInputTextcool.y + 20, 64, 'Image Directory');
		bfInputText = new FlxUIInputText(15, directoryInputTextcool.y + 50, 200, "", 8);
		var xlabel = new FlxText(15, bfInputText.y + 20, 64, 'HealthBar Color');
		fInputText = new FlxUIInputText(15, bfInputText.y + 50, 200, Std.string(cameraFollowPointer.x + ", " + cameraFollowPointer.y), 8);
		var flabel = new FlxText(15, fInputText.y + 20, 64, 'Camera Position');
		yoInputText = new FlxUIInputText(15, fInputText.y + 50, 200, "", 8);
		var yolabel = new FlxText(15, yoInputText.y + 20, 64, 'Icon Name');

		isflipX = new FlxUICheckBox(15, yoInputText.y + 50, null, null, "Flip X", 100);

		isflipY = new FlxUICheckBox(15, isflipX.y + 20, null, null, "Flip Y", 100);

		isflipX.checked = false;
		isflipY.checked = false;

		var saveStuff:FlxButton = new FlxButton(240, 20, "Save Character", function()
		{
			savecharacter();
		});

		var loadStuff:FlxButton = new FlxButton(240, 70, "Load Character", function()
		{
			loadcharacter();
			unsavedChanges = false;
		});

		var reloadStuff:FlxButton = new FlxButton(240, 120, "Reload Image", function()
		{
			createdCharacter.visible = false;
			var assetName:String = directoryInputTextcool.text.trim();
			if (assetName != null && assetName.length > 0)
			{
				if (FileSystem.exists(Paths.modsImages(assetName)))
				{
					createdCharacter.frames = Paths.getModsSparrowAtlas(assetName);
					createdCharacter.image = directoryInputTextcool.text.trim();
					createdCharacter.visible = true;
				}
				else if (FileSystem.exists("assets/shared/images/" + assetName + ".png"))
				{
					createdCharacter.frames = Paths.getSparrowAtlas(assetName);
					createdCharacter.image = directoryInputTextcool.text.trim();
					createdCharacter.visible = true;
				}
			}
			unsavedChanges = true;
		});

		var aiColor:FlxButton = new FlxButton(240, 170, "Get Icon Color", function()
		{
			var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(iconP2));
			bfInputText.text = coolColor.red + ", " + coolColor.green + ", " + coolColor.blue;
			createdCharacter.healthbarColor = [coolColor.red, coolColor.green, coolColor.blue];
			healthBarBG.color = coolColor;
			unsavedChanges = true;
		});

		var reloadStuffi:FlxButton = new FlxButton(240, 220, "Reload Icon", function()
		{
			iconP2.visible = false;
			var assetName:String = yoInputText.text.trim();
			if (assetName != null && assetName.length > 0)
			{
				if (FileSystem.exists(Paths.modsImages('icons/icon-' + assetName)))
				{
					remove(iconP2);
					iconP2 = new HealthIcon(assetName, false);
					add(iconP2);
					iconP2.visible = true;
				}
				else if (FileSystem.exists("assets/images/icons/icon-" + assetName + ".png"))
				{
					remove(iconP2);
					iconP2 = new HealthIcon(assetName, false);
					add(iconP2);
					iconP2.visible = true;
				}
			}
			unsavedChanges = true;
		});

		var tab_group_settings = new FlxUI(null, UI_character);
		tab_group_settings.name = "Settings";
		tab_group_settings.add(saveStuff);
		tab_group_settings.add(loadStuff);
		tab_group_settings.add(reloadStuff);
		tab_group_settings.add(reloadStuffi);
		tab_group_settings.add(aiColor);
		tab_group_settings.add(fInputText);
		tab_group_settings.add(yoInputText);
		tab_group_settings.add(flabel);
		tab_group_settings.add(yolabel);
		tab_group_settings.add(xlabel);
		tab_group_settings.add(bfInputText);
		tab_group_settings.add(directoryInputTextcool);
		tab_group_settings.add(directlabel);
		tab_group_settings.add(isflipX);
		tab_group_settings.add(isflipY);

		UI_character.addGroup(tab_group_settings);

		UI_character.scrollFactor.set();
	}

	function reloadCharacters()
	{
		directoryInputTextcool.text = swagCharacter.image;
		bfInputText.text = swagCharacter.healthbarColor[0] + ", " + swagCharacter.healthbarColor[1] + ", " + swagCharacter.healthbarColor[2];
		fInputText.text = swagCharacter.cameraPosition[0] + ", " + swagCharacter.cameraPosition[1];
		isflipX.checked = swagCharacter.flipX;
		isflipY.checked = swagCharacter.flipY;
		scaleStepper.value = swagCharacter.scale;
		if (FileSystem.exists(Paths.txt('images/characters/' + createdCharacter.curCharacter + "Offsets")))
		{
			createdCharacter.loadOffsetFromFile(createdCharacter.curCharacter, 'shared');
		}
		else if (FileSystem.exists(Paths.modFolder('images/characters/' + createdCharacter.curCharacter + "Offsets.txt")))
		{
			createdCharacter.loadOffsetFromthecoolFile(createdCharacter.curCharacter);
		}
		dumbTexts.clear();
		genBoyOffsets();

		createdCharacter.animationsthing = swagCharacter.animations;

		createdCharacter.visible = false;
		var assetName:String = directoryInputTextcool.text.trim();
		if (assetName != null && assetName.length > 0)
		{
			if (FileSystem.exists(Paths.modsImages(assetName)))
			{
				createdCharacter.frames = Paths.getModsSparrowAtlas(assetName);
				createdCharacter.image = directoryInputTextcool.text.trim();
				createdCharacter.visible = true;
			}
			else if (FileSystem.exists("assets/shared/images/" + assetName + ".png"))
			{
				createdCharacter.frames = Paths.getSparrowAtlas(assetName);
				createdCharacter.image = directoryInputTextcool.text.trim();
				createdCharacter.visible = true;
			}
		}
		iconP2.visible = false;
		var assetName:String = yoInputText.text.trim();
		if (assetName != null && assetName.length > 0)
		{
			if (FileSystem.exists(Paths.modsImages('icons/icon-' + assetName)))
			{
				remove(iconP2);
				iconP2 = new HealthIcon(assetName, false);
				add(iconP2);
				iconP2.visible = true;
			}
			else if (FileSystem.exists("assets/images/icons/icon-" + assetName + ".png"))
			{
				remove(iconP2);
				iconP2 = new HealthIcon(assetName, false);
				add(iconP2);
				iconP2.visible = true;
			}
		}
		for (char in createdCharacter.animationsthing)
		{
			curSelectedCharStepper.value++;
			curSelectedCharStepper.max++;

			coolInputText.text = char.anim;
			nameInputText.text = char.name;
			isflippedX.checked = char.loop;
			createdCharacter.animation.addByPrefix(char.anim, char.name, 24, char.loop);
			createdCharacter.addOffset(char.anim, char.offsets[0], char.offsets[1]);
		}
	}

	function genBoyOffsets():Void
	{
		var daLoop:Int = 0;

		var i:Int = dumbTexts.members.length - 1;
		while (i >= 0)
		{
			var memb:FlxText = dumbTexts.members[i];
			if (memb != null)
			{
				memb.kill();
				dumbTexts.remove(memb);
				memb.destroy();
			}
			--i;
		}
		dumbTexts.clear();

		for (anim => offsets in createdCharacter.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(null, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 1;
			dumbTexts.add(text);
			text.cameras = [camHUD];

			daLoop++;
		}

		textAnim.visible = true;
		if (dumbTexts.length < 1)
		{
			var text:FlxText = new FlxText(10, 38, 0, "No animations found!", 15);
			text.scrollFactor.set();
			text.borderSize = 1;
			dumbTexts.add(text);
			textAnim.visible = false;
		}
	}

	override public function update(elapsed:Float)
	{
		var inputTexts:Array<FlxUIInputText> = [nameInputText, directoryInputTextcool, bfInputText, coolInputText, fInputText];
		for (i in 0...inputTexts.length)
		{
			if (inputTexts[i].hasFocus)
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
				{ // Copy paste
					inputTexts[i].text = clipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if (FlxG.keys.justPressed.ENTER)
				{
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}

		if (loadedFile != null)
		{
			swagCharacter = loadedFile;
			loadedFile = null;

			reloadCharacters();
		}

		if (createdCharacter.animationsthing.length > 0)
		{
			if (FlxG.keys.justPressed.W)
			{
				curSelected -= 1;
			}

			if (FlxG.keys.justPressed.S)
			{
				curSelected += 1;
			}

			if (curSelected < 0)
				curSelected = createdCharacter.animationsthing.length - 1;

			if (curSelected >= createdCharacter.animationsthing.length)
				curSelected = 0;

			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
			{
				updateTexts();
				coolInputText.text = createdCharacter.animationsthing[curSelected].anim;
				nameInputText.text = createdCharacter.animationsthing[curSelected].name;
				isflippedX.checked = createdCharacter.animationsthing[curSelected].loop;
				createdCharacter.playAnim(createdCharacter.animationsthing[curSelected].anim, false);
				genBoyOffsets();
			}

			var controlArray:Array<Bool> = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN
			];

			for (i in 0...controlArray.length)
			{
				if (controlArray[i])
				{
					var holdShift = FlxG.keys.pressed.SHIFT;
					var multiplier = 1;
					if (holdShift)
						multiplier = 10;

					var arrayVal = 0;
					if (i > 1)
						arrayVal = 1;

					var negaMult:Int = 1;
					if (i % 2 == 1)
						negaMult = -1;
					createdCharacter.animationsthing[curSelected].offsets[arrayVal] += negaMult * multiplier;

					createdCharacter.addOffset(createdCharacter.animationsthing[curSelected].anim, createdCharacter.animationsthing[curSelected].offsets[0],
						createdCharacter.animationsthing[curSelected].offsets[1]);

					createdCharacter.playAnim(createdCharacter.animationsthing[curSelected].anim, false);

					unsavedChanges = true;

					genBoyOffsets();
				}
			}
		}

		super.update(elapsed);

		createdCharacter.image = directoryInputTextcool.text;
		createdCharacter.flipX = isflipX.checked;
		createdCharacter.flipY = isflipY.checked;
		createdCharacter.varflipX = isflipX.checked;
		createdCharacter.varflipY = isflipY.checked;
		createdCharacter.scalecool = scaleStepper.value;

		createdCharacter.setGraphicSize(Std.int(createdCharacter.width * createdCharacter.scalecool));

		var STRING = fInputText.text.trim().split(", ");
		var x = Std.parseInt(STRING[0].trim());
		var y = Std.parseInt(STRING[1].trim());
		createdCharacter.cameraPosition = [x, y];
		cameraFollowPointer.x = x;
		cameraFollowPointer.y = y;

		var STRING2 = bfInputText.text.trim().split(", ");
		var x2 = Std.parseInt(STRING2[0].trim());
		var y2 = Std.parseInt(STRING2[1].trim());
		var y3 = Std.parseInt(STRING2[2].trim());
		createdCharacter.healthbarColor = [x2, y2, y3];

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1;
		}
		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (!unsavedChanges)
			{
				MusicBeatState.switchState(new tools.EditorMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.mouse.visible = false;
			}
			else
			{
				if (!alreadyPressed)
				{
					alreadyPressed = true;
					blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackBox.cameras = [camG];
					add(blackBox);

					var label:FlxText = null;

					blackBox.alpha = 0.6;

					var tabss = [{name: 'Warning', label: 'Warning'},];

					UI__character = new FlxUITabMenu(null, tabss, true);

					UI__character.resize(350, 300);
					UI__character.scrollFactor.set();
					UI__character.screenCenter();
					UI__character.cameras = [camG];
					add(UI__character);

					idontcarelol = new FlxButton(140, 20, "Yes", function()
					{
						alreadyPressed = false;

						MusicBeatState.switchState(new tools.EditorMenuState());

						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					});

					idontcarelol.y += 400;
					idontcarelol.screenCenter(X);
					idontcarelol.color = FlxColor.RED;
					idontcarelol.label.color = FlxColor.WHITE;

					ormaybeido = new FlxButton(140, 20, "No", function()
					{
						alreadyPressed = false;
						remove(ormaybeido);
						remove(idontcarelol);
						remove(UI__character);
						remove(blackBox);
						remove(label);
					});

					ormaybeido.screenCenter(X);
					ormaybeido.y += 370;
					ormaybeido.color = FlxColor.GREEN;
					ormaybeido.label.color = FlxColor.WHITE;

					label = new FlxText(15, ormaybeido.y - 120, 260, 'You have unsaved changes!\nWould you like to exit anyways?\nOr not?');
					label.setFormat(null, 12, FlxColor.WHITE, CENTER);
					label.screenCenter(X);
					label.cameras = [camG];
					add(label);

					idontcarelol.cameras = [camG];
					ormaybeido.cameras = [camG];
					add(ormaybeido);
					add(idontcarelol);
					FlxG.mouse.visible = true;
				}
			}

			return;
		}

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
	}

	private static var _file:FileReference;

	public static function savecharacter()
	{
		var json = {
			"animations": createdCharacter.animationsthing,
			"image": createdCharacter.image,
			"scale": createdCharacter.scalecool,
			"cameraPosition": createdCharacter.cameraPosition,

			"flipX": createdCharacter.flipX,
			"flipY": createdCharacter.flipY,
			"healthbarColor": createdCharacter.healthbarColor
		};

		var data:String = Json.stringify(json, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, ".json");
		}
	}

	private static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
		unsavedChanges = false;
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	public static function loadcharacter()
	{
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadedFile:SwagCharacter = null;
	public static var loadError:Bool = false;

	private static function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			var rawJson:String = File.getContent(fullPath);
			if (rawJson != null)
			{
				loadedFile = cast Json.parse(rawJson);
				if (loadedFile.animations != null && loadedFile.cameraPosition != null)
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					loadError = false;

					createdCharacter.curCharacter = cutName;

					_file = null;
					return;
				}
			}
		}
		loadError = true;
		loadedFile = null;
		_file = null;
		#else
		trace("Error Loading File!");
		#end
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private static function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private static function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	public static function clipboardAdd(prefix:String = ''):String
	{
		if (prefix.toLowerCase().endsWith('v'))
		{
			prefix = prefix.substring(0, prefix.length - 1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}
