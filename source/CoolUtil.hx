package;

import flixel.FlxG;
import lime.utils.Assets;
#if sys
import sys.FileSystem;
#end

using StringTools;

class CoolUtil
{
	public static var difficultyStuff:Array<Dynamic> = [['Easy'], ['Normal'], ['Hard']];

	public static function difficultyString(uppercase:Bool = true):String
	{
		if (uppercase)
			return difficultyStuff[PlayState.storyDifficulty][0].toUpperCase();
		else
			return difficultyStuff[PlayState.storyDifficulty][0];
	}

	public static function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url]);
		#else
		FlxG.openURL(url);
		#end
	}

	// code used in psych engine
	public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		var newValue:Float = value;
		if (newValue < min)
			newValue = min;
		else if (newValue > max)
			newValue = max;
		return newValue;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function evenCoolerTextFile(path:String):Array<String>
	{
		#if MODS
		var daList:Array<String> = sys.io.File.getContent(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
		#else
		return [];
		#end
	}

	public static function coolOptions(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			#if sys
			var daList:Array<String> = sys.io.File.getContent(path).trim().split('\n');

			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
			#end
			return daList;
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0;
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function deleteFolderContents(deletedFile:String)
	{
		#if sys
		if (!FileSystem.exists(deletedFile))
			return;
		for (file in FileSystem.readDirectory(deletedFile))
		{
			if (FileSystem.isDirectory(deletedFile + "/" + file))
			{
				deleteFolderContents(deletedFile + "/" + file);
				FileSystem.deleteDirectory(deletedFile + "/" + file);
			}
			else
			{
				FileSystem.deleteFile(deletedFile + "/" + file);
			}
		}
		#end
	}
}
