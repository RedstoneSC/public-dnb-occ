package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class UnlockedNewSongSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;

	var icon:HealthIcon;
	var song:String;
	var leaving = false;
	var alphabetArray:Array<Alphabet> = [];
	var callback:Void->Void;

	public function new(song:String, character:String, ?callback:Void->Void)
	{
		this.callback = callback;
		ClientPrefs.loadPrefs();
		if (!ClientPrefs.songsLoaded.exists(song.toLowerCase()))
		{
			ClientPrefs.songsLoaded.set(song.toLowerCase(), true);
			if (song.toLowerCase() == "snacker-eduardo")
				ClientPrefs.songsLoaded.set("snacker-eduardo-old", true);
			if (song.toLowerCase() == "snacker-eduardo")
				ClientPrefs.songsLoaded.set("snacker-eduardo-older", true);
		}
		else
		{
			trace('reunlocked ${song}????');
		}

		ClientPrefs.saveSettings();
		this.song = song;

		super();
		FlxG.sound.play(Paths.sound("secretSound"), 1.5);
		var name:String = song;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var tooLong:Float = (name.length > 18) ? (name.length > 26) ? 0.6 : 0.8 : 1;
		var text:Alphabet = new Alphabet(0, 180, "You just unlocked", true);
		text.screenCenter(X);
		text.scrollFactor.set(0, 0);
		alphabetArray.push(text);
		add(text);
		var text:Alphabet = new Alphabet(0, text.y + 90, name, true, false, 0.05, tooLong);
		text.screenCenter(X);
		text.scrollFactor.set(0, 0);
		alphabetArray.push(text);
		add(text);

		icon = new HealthIcon(character);
		icon.setGraphicSize(Std.int(icon.width * (tooLong - 0.1)));
		icon.updateHitbox();
		icon.setPosition(text.x - icon.width + (10 * (tooLong - 1.5)), text.y - (26 * 1.75 - tooLong));
		var woo = new Alphabet(0, text.y + 150, 'YEAH!', true);
		woo.screenCenter(X);
		woo.scrollFactor.set(0, 0);
		alphabetArray.push(woo);
		add(woo);
		var woo = new Alphabet(0, text.y + 225, '(Press Enter to continue)', true);
		woo.screenCenter(X);
		woo.scrollFactor.set(0, 0);
		add(woo);
		alphabetArray.push(woo);
		icon.animation.curAnim.curFrame = 2;
		add(icon);
	}

	override function update(elapsed:Float)
	{
		if (!leaving)
		{
			bg.alpha += elapsed * 1.5;
			if (bg.alpha > 0.6)
				bg.alpha = 0.6;
		}
		for (i in 0...alphabetArray.length)
		{
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		icon.alpha += elapsed * 2.5;
		if (icon.alpha > 1)
			icon.alpha = 1;
		if (controls.ACCEPT)
		{
			leaving = true;
			FlxG.sound.play(Paths.sound('confirmMenu'), 1);
			for (spr in members)
			{
				if (Std.isOfType(spr, HealthIcon))
				{
					FlxTween.tween(spr, {alpha: 0}, 0.7, {
						ease: FlxEase.smoothStepIn,
						onComplete: function bye(cool:FlxTween)
						{
							close();
							if (callback != null)
								callback();
						}
					});
				}
				else
				{
					FlxTween.tween(spr, {alpha: 0}, 0.7, {ease: FlxEase.smoothStepIn});
				}
			}
		}
		super.update(elapsed);
	}
}
