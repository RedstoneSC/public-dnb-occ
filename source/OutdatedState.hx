package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var infos:Array<String> = [];

	var warnText:FlxText;
	var link:String = "";

	override function create()
	{
		super.create();
		var http = new haxe.Http("https://raw.githubusercontent.com/brosomethingwrongwithyothing/dnb-occ-public/gameLink.txt");
		http.onData = function(data:String)
		{
			link = data;
		}

		http.onError = function(error)
		{
			trace('error: $error');
		}

		http.request();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width, "A update is available! Current version: "
			+ infos[0]
			+ ",\n
			Latest version: "
			+ infos[1]
			+ " \nRecommended to update!\nNew changes: "
			+ infos[2]
			+ "\n\nPress Enter to go to the page, Backspace to continue.", 32);
		warnText.setFormat("Comic Sans MS Bold", Std.int(CoolUtil.boundTo(33 / (warnText.text.length / 40), 24, 38)), FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		warnText.y -= 50;
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (controls.ACCEPT)
			{
				leftState = true;
				CoolUtil.browserLoad(link);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
			else if (controls.BACK)
			{
				leftState = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
			super.update(elapsed);
		}
	}
}
