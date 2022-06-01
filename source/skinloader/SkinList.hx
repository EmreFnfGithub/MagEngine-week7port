package skinloader;

import polymod.Polymod;
import flixel.FlxG;

class SkinList
{
	#if MODS
	public static var skinList:Map<String, Bool> = new Map<String, Bool>();

	public static var skinMetadatas:Map<String, ModMetadata> = new Map();

	public static function setskinEnabled(skin:String, enabled:Bool):Void
	{
		skinList.set(skin, enabled);
		FlxG.save.data.skinList = skinList;
		FlxG.save.flush();
	}

	public static function getskinEnabled(skin:String):Bool
	{
		if (!skinList.exists(skin))
			setskinEnabled(skin, false);

		return skinList.get(skin);
	}

	public static function getActiveskins(skinsToCheck:Array<String>):Array<String>
	{
		var activeskins:Array<String> = [];

		for (skinName in skinsToCheck)
		{
			if (getskinEnabled(skinName))
				activeskins.push(skinName);
		}

		return activeskins;
	}

	public static function load():Void
	{
		if (FlxG.save.data.skinList != null)
			skinList = FlxG.save.data.skinList;
	}
	#end
}
