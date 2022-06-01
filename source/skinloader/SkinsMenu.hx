package skinloader;

import skinloader.SkinList;
import skinloader.SkinHandler;
import skinloader.SkinMenuOption;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import lime.utils.Assets;

class SkinsMenu extends MusicBeatState
{
	#if MODS
	var curSelected:Int = 0;

	var page:FlxTypedGroup<SkinMenuOption> = new FlxTypedGroup<SkinMenuOption>();

	public static var instance:SkinsMenu;

	public static var enabledSkins = [];

	public static var coolId:String;
	public static var disableButton:FlxButton;
	public static var enableButton:FlxButton;

	var bgtwo:FlxSprite;
	var bg:FlxSprite;

	var infoText:FlxText;
	var infoTextcool:FlxText;

	override function create()
	{
		LoggingUtil.writeToLogFile('In The Skins Menu!');

		var menuBG:FlxSprite;

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

		menuBG.color = FlxColor.MAGENTA;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		infoText = new FlxText(0, 0, 0, "NO SKIN PACKS INSTALLED!", 12);
		infoText.scrollFactor.set();
		infoText.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.screenCenter();
		infoText.visible = false;
		infoText.antialiasing = true;
		add(infoText);

		infoTextcool = new FlxText(340, 340, Std.int(FlxG.width * 0.9), "", 12);
		infoTextcool.scrollFactor.set();
		infoTextcool.setFormat(Paths.font("funkin.otf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoTextcool.borderSize = 2;
		infoTextcool.screenCenter(Y);

		super.create();

		SkinHandler.loadModMetadata();

		add(page);

		loadSkins();
		FlxG.mouse.visible = true;
	}

	function loadSkins()
	{
		page.forEachExists(function(option:SkinMenuOption)
		{
			page.remove(option);
			option.kill();
			option.destroy();
		});

		var optionLoopNum:Int = 0;

		for (SkinId in SkinHandler.metadataArrays)
		{
			var SkinOption = new SkinMenuOption(SkinList.skinMetadatas.get(SkinId).title, SkinId, optionLoopNum);
			page.add(SkinOption);
			optionLoopNum++;
			coolId = SkinId;
		}

		if (optionLoopNum > 0)
		{
			buildUI();
		}

		infoText.visible = (page.length == 0);
	}

	function buildUI()
	{
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("modbg"));
		// bg.screenCenter(Y);

		bgtwo = new FlxSprite(720, 0).loadGraphic(Paths.image("modbg"));
		bgtwo.screenCenter(Y);

		SkinsMenu.enableButton = new FlxButton(bg.x + 1120, 309, "Enable Skin Pack", function()
		{
			page.members[curSelected].Skin_Enabled = true;
			if (!enabledSkins.contains(page.members[curSelected].Option_Value))
			{
				enabledSkins.push(page.members[curSelected].Option_Value);
			}

			SkinList.setskinEnabled(page.members[curSelected].Option_Value, page.members[curSelected].Skin_Enabled);
		});

		SkinsMenu.disableButton = new FlxButton(bg.x + 1120, 380, "Disable Skin Pack", function()
		{
			page.members[curSelected].Skin_Enabled = false;
			if (enabledSkins.contains(page.members[curSelected].Option_Value))
			{
				enabledSkins.remove(page.members[curSelected].Option_Value);
			}
			SkinList.setskinEnabled(page.members[curSelected].Option_Value, page.members[curSelected].Skin_Enabled);
		});

		enableButton.setGraphicSize(150, 70);
		enableButton.updateHitbox();
		enableButton.color = FlxColor.GREEN;
		enableButton.label.setFormat(Paths.font("pixel.otf"), 12, FlxColor.WHITE);
		enableButton.label.fieldWidth = 135;
		setLabelOffset(enableButton, 5, 22);

		disableButton.setGraphicSize(150, 70);
		disableButton.updateHitbox();
		disableButton.color = FlxColor.RED;
		disableButton.label.setFormat(Paths.font("pixel.otf"), 12, FlxColor.WHITE);
		disableButton.label.fieldWidth = 135;
		setLabelOffset(disableButton, 5, 22);

		add(bgtwo);
		add(infoTextcool);
		add(disableButton);
		add(enableButton);
	}

	override function update(elapsed:Float)
	{
		#if desktop
		if (FlxG.keys.justPressed.SEVEN)
		{
			MusicBeatState.switchState(new skinloader.SkinDownloadState());
		}
		#end

		super.update(elapsed);

		// a bit ugly but i was in a hurry
		if (page.length > 0)
		{
			infoTextcool.text = SkinList.skinMetadatas.get(SkinHandler.metadataArrays[curSelected]).description;
			infoTextcool.visible = true;
			infoTextcool.antialiasing = true;
		}

		if (page.length > 0)
		{
			if (controls.UP_P)
			{
				curSelected--;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.DOWN_P)
			{
				curSelected++;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}
		}

		if (controls.BACK)
		{
			SkinHandler.loadMods();
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new MainMenuState());
		}

		if (curSelected < 0)
			curSelected = page.length - 1;

		if (curSelected >= page.length)
			curSelected = 0;

		var bruh = 0;

		for (x in page.members)
		{
			x.Alphabet_Text.targetY = bruh - curSelected;
			bruh++;
		}
	}

	// haxeflixel bro why
	function setLabelOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}
	#end
}
