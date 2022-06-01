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
import StoryMenuState.SwagWeek;
import StoryMenuState.Week;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class WeekEditor extends MusicBeatState
{
	var UI_character:FlxUITabMenu;

	public static var songInputText:FlxUIInputText;

	var swagWeek:SwagWeek = null;
	var ormaybeido:FlxButton;
	var idontcarelol:FlxButton;

	var UI__character:FlxUITabMenu;
	var alreadyPressed:Bool = false;
	var blackBox:FlxSprite;

	public static var unsavedChanges:Bool = false;

	public function new(swagWeek:SwagWeek = null)
	{
		super();
		this.swagWeek = Week.createWeek();
		if (swagWeek != null)
			this.swagWeek = swagWeek;
	}

	override public function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = FlxColor.GRAY;
		bg.scrollFactor.set();
		add(bg);

		FlxG.mouse.visible = true;

		var tabs = [{name: 'Songs', label: 'Songs'},];

		UI_character = new FlxUITabMenu(null, tabs, true);

		UI_character.resize(300, 250);
		UI_character.scrollFactor.set();
		UI_character.screenCenter();
		add(UI_character);

		addWeekUI();
	}

	function addWeekUI()
	{
		songInputText = new FlxUIInputText(15, 20, 200, "", 8);
		var songlabel = new FlxText(15, songInputText.y + 20, 64, 'Week Songs');
		songlabel.screenCenter(X);
		songInputText.screenCenter(X);
		songInputText.y += 300;
		songlabel.y += 305;
		// there's no reason to put them in a tab group, since there's only one tab!
		add(songlabel);
		add(songInputText);

		var saveStuff:FlxButton = new FlxButton(songInputText.x + 10, songInputText.y + 50, "Save Week", function()
		{
			saveWeek(swagWeek);
		});

		var loadStuff:FlxButton = new FlxButton(songInputText.x + 100, saveStuff.y, "Load Week", function()
		{
			loadWeek();
		});

		add(saveStuff);
		add(loadStuff);
	}

	function reloadSongs()
	{
		for (i in 0...swagWeek.songs.length)
		{
			songInputText.text = swagWeek.songs.join(", ");
		}
	}

	override public function update(elapsed:Float)
	{
		var inputTexts:Array<FlxUIInputText> = [songInputText];
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
			swagWeek = loadedFile;
			loadedFile = null;

			unsavedChanges = false;

			reloadSongs();
		}

		super.update(elapsed);

		if (songInputText.text != "")
		{
			unsavedChanges = true;
		}

		swagWeek.songs = songInputText.text.trim().split(", ");

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (!unsavedChanges)
			{
				MusicBeatState.switchState(new tools.EditorMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.mouse.visible = true;
			}
			else
			{
				if (!alreadyPressed)
				{
					alreadyPressed = true;
					blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					add(blackBox);

					var label:FlxText = null;

					blackBox.alpha = 0.6;

					var tabss = [{name: 'Warning', label: 'Warning'},];

					UI__character = new FlxUITabMenu(null, tabss, true);

					UI__character.resize(350, 300);
					UI__character.scrollFactor.set();
					UI__character.screenCenter();
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
					add(label);

					add(ormaybeido);
					add(idontcarelol);
					FlxG.mouse.visible = true;
				}
			}
			return;
		}
	}

	private static var _file:FileReference;

	public static function saveWeek(weekFile:SwagWeek)
	{
		var data:String = Json.stringify(weekFile, "\t");
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

	public static function loadWeek()
	{
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadedFile:SwagWeek = null;
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
				if (loadedFile.songs != null)
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					loadError = false;

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
