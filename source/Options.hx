package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;

class OptionCategory
{
	private var _options:Array<Option> = [];

	public function new(catName:String, ?options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";

	public final function getName()
	{
		return _name;
	}
}

class Option
{
	private var display:String;
	private var acceptValues:Bool = false;

	public var isBool:Bool = true;
	public var daValue:Bool = false;

	public function new()
	{
		display = updateDisplay();
	}

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return true;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}
}

class DownscrollOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.downscroll;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		daValue = FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Downscroll";
	}
}

class LogsOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.logsAllowed;
	}

	public override function press():Bool
	{
		FlxG.save.data.logsAllowed = !FlxG.save.data.logsAllowed;
		daValue = FlxG.save.data.logsAllowed;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Save Logs";
	}
}

class MiddlescrollOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.middlescroll;
	}

	public override function press():Bool
	{
		FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
		daValue = FlxG.save.data.middlescroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Middlescroll";
	}
}

class PhotoSensitivityOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.PhotoSensitivity;
	}

	public override function press():Bool
	{
		FlxG.save.data.PhotoSensitivity = !FlxG.save.data.PhotoSensitivity;
		daValue = FlxG.save.data.PhotoSensitivity;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "PhotoSensitivity Mode";
	}
}

class GhostTappingOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.ghostTapping;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghostTapping = !FlxG.save.data.ghostTapping;
		daValue = FlxG.save.data.ghostTapping;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Ghost Tapping";
	}
}

class AccuracyOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.accuracy;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracy = !FlxG.save.data.accuracy;
		daValue = FlxG.save.data.accuracy;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Display";
	}
}

class OpponentNotesGlowOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.cpuNotesGlow;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuNotesGlow = !FlxG.save.data.cpuNotesGlow;
		daValue = FlxG.save.data.cpuNotesGlow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Opponent Notes Glow";
	}
}

class SplooshOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.splooshes;
	}

	public override function press():Bool
	{
		FlxG.save.data.splooshes = !FlxG.save.data.splooshes;
		daValue = FlxG.save.data.splooshes;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Splashes";
	}
}

class ModChartOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.modchart;
	}

	public override function press():Bool
	{
		FlxG.save.data.modchart = !FlxG.save.data.modchart;
		daValue = FlxG.save.data.modchart;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "ModCharts";
	}
}

class CacheOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.cache;
	}

	public override function press():Bool
	{
		FlxG.save.data.cache = !FlxG.save.data.cache;
		daValue = FlxG.save.data.cache;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Cache At Start";
	}
}

class RatingOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.ratingCntr;
	}

	public override function press():Bool
	{
		FlxG.save.data.ratingCntr = !FlxG.save.data.ratingCntr;
		daValue = FlxG.save.data.ratingCntr;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Rating Counter";
	}
}

class FPSCapOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.fpsCap;
	}

	public override function press():Bool
	{
		FlxG.save.data.fpsCap = !FlxG.save.data.fpsCap;
		daValue = FlxG.save.data.fpsCap;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap";
	}
}

class FPSOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.fps;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		daValue = FlxG.save.data.fps;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter";
	}
}

class MEMOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.mem;
	}

	public override function press():Bool
	{
		FlxG.save.data.mem = !FlxG.save.data.mem;
		(cast(Lib.current.getChildAt(0), Main)).toggleMem(FlxG.save.data.mem);
		daValue = FlxG.save.data.mem;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Memory Info";
	}
}

class VerOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.v;
	}

	public override function press():Bool
	{
		FlxG.save.data.v = !FlxG.save.data.v;
		(cast(Lib.current.getChildAt(0), Main)).toggleVers(FlxG.save.data.v);
		daValue = FlxG.save.data.v;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Version Display";
	}
}

class TransparentNotesOption extends Option
{
	public function new()
	{
		super();
		daValue = FlxG.save.data.transparentNotes;
	}

	public override function press():Bool
	{
		FlxG.save.data.transparentNotes = !FlxG.save.data.transparentNotes;
		daValue = FlxG.save.data.transparentNotes;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Transparent Strums";
	}
}
