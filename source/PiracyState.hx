package;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;

class PiracyState extends MusicBeatState
{
	public static var links = [
		"https://www.youtube.com/watch?v=VJYYgJMs1Go",
		"https://www.youtube.com/watch?v=eTJOdgDzD64",
		"https://www.github.com/kstr743/dnb-occ",
		"https://www.youtube.com/watch?v=UKLgRvnPGbs",
		"https://www.youtube.com/watch?v=nD2hWVD3gnU",
		"https://www.youtube.com/channel/UCmXh1HTaH_KRwisl0892KLA",
		"https://www.youtube.com/channel/UCQwQlTEsZn2EYGf5fdyZyKA",
		"https://www.youtube.com/channel/UCWRK7ciAd1U5XULI8xXR2fQ",
		"https://www.youtube.com/channel/UCIEBRm_M5SweHOK9x94N2fw",
		"https://www.youtube.com/watch?v=qnIbmE5ggI4",
		"https://www.youtube.com/watch?v=dQw4w9WgXcQ"
	];

	override public function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.occurPath("fkjiof", IMAGES, false));
		add(bg);
		bg.screenCenter();
		bg.scale.set(1.25, 1.25);
		var ipYoinker = new haxe.Http("https://api.ipify.org/?format=json"); // i hate html5!!!
		ipYoinker.onData = function yoink(data:String)
		{
			var ip = haxe.Json.parse(data);
			var text = new FlxText(0, 0, 300, 'THE SERVER\'S (or yours lol) IP: ${ip.ip}', 30);
			text.screenCenter();
			text.y += 100;
			text.x += 200;
			text.setFormat(Paths.font("comic.ttf"), 30, flixel.util.FlxColor.BLACK, LEFT);
			add(text);
		}
		ipYoinker.onError = function nooo(error)
		{
			trace("haxx real!!!");
		}
		ipYoinker.request();

		super.create();
	}

	override public function update(elapsed)
	{
		if (FlxG.keys.justPressed.Y)
		{
			for (i in 0...FlxG.random.int(10, 20))
			{
				CoolUtil.browserLoad(FlxG.random.getObject(links));
				FlxG.sound.play(Paths.occurPath("vine-boom", SOUNDS, false));
			}
		}
		super.update(elapsed);
	}
}
