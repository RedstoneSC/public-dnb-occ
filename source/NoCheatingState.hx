package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class NoCheatingState extends MusicBeatState
{
	var allCheatingLines = ["go touch grass.", "cheater.", "skill issue."];

	override function create()
	{
		var text = new FlxText(0, 0, 1280, FlxG.random.getObject(allCheatingLines).toUpperCase(), 32);
		text.setFormat(Paths.font("comic.ttf"), 32, 0xff470000, CENTER);
		text.borderSize = 3;
		text.borderStyle = OUTLINE;
		text.borderColor = 0xffffffff;
		add(text);
        text.screenCenter();
		new FlxTimer().start(3, function(_)
		{
			Sys.exit(0);
		});
		super.create();
	}

	public static function calcIfShouldGoHere()
	{
		var ret = true;
		if (FlxG.save.data.cheaterFNFBool == null || !FlxG.save.data.cheaterFNFBool)
		{
			ret = false;
		}
		else if (Date.now().getTime() - FlxG.save.data.cheaterFNFTime >= 600000) // hopefully (10)
		{
			ret = false;
			FlxG.save.data.cheaterFNFBool = false;
			FlxG.save.data.cheaterFNFTime = null;
			FlxG.save.flush();
		}
		return ret;
	}
}
