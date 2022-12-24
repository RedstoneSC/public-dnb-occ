package;

import options.OptionsState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxSprite;

class SaveFileThing extends MusicBeatState
{
	var bg:FlxSprite;
	var magenta:FlxSprite;
	var curSelected = 0;
	var inDelMode = false;
	var savesUsed:Array<Bool> = [];
	var initSavesUsed:Bool = false;
	var initSavesUsedArray:Array<Bool> = [];
	var ease = FlxEase.quintInOut;
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems = ['NEW SAVE FILE 1', 'NEW SAVE FILE 2', 'NEW SAVE FILE 3', 'DELETE SAVE'];
	var canMove = true;
	var text:FlxText;

	override public function create()
	{
		refreshSavesUsed();
		initSavesUsed = checkforsaves();
		initSavesUsedArray = savesUsed;
		var yes = MainMenuState.randomBG();
		bg = new FlxSprite(-40).loadGraphic(yes);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.color = 0xFFFDE871;
		add(bg);

		magenta = new FlxSprite(-40).loadGraphic(yes);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		refreshText();
		text = new FlxText(0, FlxG.height * 0.89, FlxG.width,
			"Current save file: " + ((ClientPrefs.curSaveFileNum == null) ? "NONE" : Std.string(ClientPrefs.curSaveFileNum + 1)) +
			"\nPress R to reset all save files.",
			22).setFormat(Paths.font("comic.ttf"), 22, 0xFFFFFFFF, LEFT, OUTLINE, 0xff000000);
		text.borderSize = 2;
		text.screenCenter(X);
		text.x += 10;
		add(text);
		super.create();
	}

	var selectedSomethin:Bool = false;

	function checkforsaves()
	{
		for (i in savesUsed)
		{
			if (i)
				return true;
		}
		return false;
	}

	function refreshText()
	{
		if (grpMenuShit.members.length > 0)
		{
			for (member in grpMenuShit)
			{
				grpMenuShit.remove(member);
			}
		}
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (30 * i) - 70, menuItems[i], true, false);
			songText.yMult = 120;
			songText.yAdd = -250;
			songText.screenCenter(X);
			songText.forceX = songText.x;
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.ID = i;
			grpMenuShit.add(songText);
		}
		changeSelection();
	}

	function refreshSavesUsed()
	{
		if (savesUsed.length > 0)
			savesUsed = [];
		for (i in 0...3)
		{
			FlxG.save.bind('funkin' + i, ClientPrefs.saveLocation());
			if (FlxG.save.data != null)
			{
				if (FlxG.save.data.exists != null)
				{
					savesUsed.push(FlxG.save.data.exists); // should be true
				}
				else
					savesUsed.push(false);
			}
			else
				savesUsed.push(false);
		}
		for (i in 0...savesUsed.length)
		{
			if (inDelMode)
			{
				if (savesUsed[i])
					menuItems[i] = "DELETE SAVE FILE " + (i + 1);
				else
					menuItems[i] = "NO SAVE FILE " + (i + 1);
			}
			else
			{
				if (savesUsed[i])
					menuItems[i] = "LOAD SAVE FILE " + (i + 1);
				else
					menuItems[i] = "NEW SAVE FILE " + (i + 1);
			}
		}
		if (inDelMode)
			menuItems[3] = "LOAD SAVE";
		else
			menuItems[3] = "DELETE SAVE";
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE]) && canMove)
		{
			if (inDelMode)
			{
				inDelMode = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				refreshSavesUsed();
				refreshText();
			}
			else if (initSavesUsed && checkforsaves())
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (initSavesUsed)
					FlxG.save.bind('funkin' + ClientPrefs.curSaveFileNum, ClientPrefs.saveLocation());
				MusicBeatState.switchState(new options.OptionsState(OptionsState.instance.inPlayState));
			}
		}
		else if (FlxG.keys.anyJustPressed([ENTER, SPACE]) && canMove)
		{
			refreshSavesUsed();
			if (curSelected == 3)
			{
				var init = inDelMode;
				inDelMode = (!inDelMode) ? checkforsaves() : false;
				if (!inDelMode && !init)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.camera.shake(0.01, 0.05);
				}
				else
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					canMove = false;
					flash(0.5, grpMenuShit.members[curSelected], 0.1, function(hi)
					{
						grpMenuShit.members[3].visible = true;
						canMove = true;
						refreshSavesUsed();
						refreshText();
					});
				}
			}
			else
			{
				refreshSavesUsed();
				if (!inDelMode)
				{
					text.text = "Current save file: " + (curSelected + 1) + "\nPress R to reset all save files.";
					flash(1, grpMenuShit.members[curSelected], 0.08, function pee(rell)
					{
						ClientPrefs.curSaveFileNum = curSelected;
						if (initSavesUsed)
						{
							ClientPrefs.saveGlobalPrefs();
							ClientPrefs.loadGlobalPrefs();
							MusicBeatState.switchState(new TitleState());
						}
						else
							TitleState.nextState();
					});
				}
				else if (inDelMode && savesUsed[curSelected])
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					openSubState(new AreYouSure(false, function()
					{
						FlxG.save.bind('funkin' + curSelected, ClientPrefs.saveLocation());
						FlxG.save.erase();
						FlxG.save.bind('controls_v2' + curSelected, ClientPrefs.saveLocation());
						FlxG.save.erase();
						FlxG.save.bind('global', ClientPrefs.saveLocation());
						inDelMode = false;
						refreshSavesUsed();
						refreshText();
					}));
				}
				else if (inDelMode)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.camera.shake(0.01, 0.05);
				}
			}
		}
		else if (FlxG.keys.anyJustPressed([UP, W]) && canMove)
			changeSelection(-1);
		else if (FlxG.keys.anyJustPressed([DOWN, S]) && canMove)
			changeSelection(1);
		else if (FlxG.keys.justPressed.R && canMove && checkforsaves())
		{
			openSubState(new AreYouSure(true, function()
			{
				for (i in 0...3)
				{
					FlxG.save.bind('funkin' + i, ClientPrefs.saveLocation());
					FlxG.save.erase();
					FlxG.save.bind('controls_v2' + i, ClientPrefs.saveLocation());
					FlxG.save.erase();
				}
				FlxG.save.bind('global', ClientPrefs.saveLocation());
				inDelMode = false;
				refreshSavesUsed();
				refreshText();
			}));
		}
		else if (FlxG.keys.justPressed.R && canMove)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.shake(0.01, 0.05);
		}
	}

	function flash(duration:Float, spr:FlxSprite, interval:Float, ?done:FlxFlicker->Void)
	{
		FlxFlicker.flicker(spr, duration, interval, false, false, done);
		if (ClientPrefs.flashing)
			FlxFlicker.flicker(magenta, duration, interval, false, false);
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected >= grpMenuShit.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = grpMenuShit.length - 1;
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		for (item in grpMenuShit.members)
		{
			if (item.ID != curSelected)
			{
				FlxTween.tween(item, {alpha: 0.6}, 0.15);
			}
			else
			{
				item.alpha = 1;
			}
		}
	}
}

class AreYouSure extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var leaving = false;
	var alphabetArray:Array<Alphabet> = [];
	var sure = false;
	var yesText:Alphabet;
	var noText:Alphabet;
	var onYes:Bool;
	var callback:Void->Void;

	public function new(superSure:Bool = false, ?dothis:Void->Void)
	{
		super();
		callback = dothis;
		sure = superSure;
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		var text:Alphabet = new Alphabet(0, 180, "Are you sure?", true);
		text.screenCenter(X);
		text.scrollFactor.set(0, 0);
		alphabetArray.push(text);
		add(text);
		yesText = new Alphabet(0, text.y + 300, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text.y + 300, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6)
			bg.alpha = 0.6;

		for (i in 0...alphabetArray.length)
		{
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (FlxG.keys.anyJustPressed([LEFT, A, RIGHT, D]))
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE]))
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		else if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
		{
			if (onYes)
			{
				if (sure)
				{
					remove(alphabetArray[0]);
					var text:Alphabet = new Alphabet(0, 180, "Are you really sure?", true);
					text.screenCenter(X);
					text.scrollFactor.set(0, 0);
					alphabetArray.push(text);
					add(text);
					FlxG.sound.play(Paths.sound('confirmMenu'), 1);
					sure = false;
					yesText.y = noText.y = text.y + 300;
					onYes = false;
					updateOptions();
				}
				else
				{
					FlxG.sound.play(Paths.sound('confirmMenu'), 1);
					close();
					if (callback != null)
						callback();
				}
			}
			else
				close();
		}
		super.update(elapsed);
	}

	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}
