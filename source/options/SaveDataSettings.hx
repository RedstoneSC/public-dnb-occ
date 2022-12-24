package options;

import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class SaveDataSettings extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Save Data';
		rpcTitle = 'Save Data Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Reset Scores'); // Default value
		addOption(option);
		super();
	}

	override function create()
	{
		super.create();
		descBox.visible = false;
		descText.visible = false;
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		persistentDraw = true;
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		if (controls.ACCEPT)
		{
			if (optionsArray[curSelected].text == "Reset Scores")
			{
				persistentUpdate = false;
				persistentDraw = true;
				openSubState(new SaveFileThing.AreYouSure(false, function()
				{
					FlxG.save.data.songRating = null;
					FlxG.save.data.songScores = null;
					FlxG.save.data.weekScores = null;
					FlxG.save.flush();
				}));
			}
		}
		doUpdate(elapsed);
	}

	function doUpdate(elapsed:Float)
	{
		var i:Int = 0;
		var basic:FlxBasic = null;

		while (i < length)
		{
			basic = members[i++];

			if (basic != null && basic.exists && basic.active)
			{
				basic.update(elapsed);
			}
		}
	}
}
