package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;

class MenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;

		var tex = Paths.getSparrowAtlas('campaign_menu_UI_characters');
		frames = tex;

		animation.addByPrefix(weekCharacters(), 24);
		animation.addByPrefix(weekCharactersAccepted(), 24, false);
		// Parent Christmas Idle

		animation.play(character);
		updateHitbox();
	}

	function weekCharacters():String
	{
		var fullText:String = Assets.getText(Paths.txt('menuCharacters'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	function weekCharactersAccepted():String
	{
		var fullText:String = Assets.getText(Paths.txt('menuCharactersHEY'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}
}
