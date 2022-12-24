package;

import haxe.Json;
import lime.utils.Assets;
import flixel.FlxCamera;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;

using StringTools;

class CharacterSelectState extends MusicBeatState
{
	var normal:String = PlayState.SONG.player1;
	var defaultText = "Default (" + "" + ")";

	var chars:Array<Array<String>> = [
		["default"],
		["bf", "bfold", "bf-christmas", "bf-pixel", "bf-poppin", "scaredbf"],
		["dave-player", "dave3dconfident-player"],
		["bambi-player", "redbambi-player", "redbambiold-player"],
		["tristan-playable", "tristan-golden", "tristan-golden-glowing"],
		["edd", "eduardo-player"],
		["awesomebambi-playernew", "awesomebambi-player", "realbambi-player"],
		["snacker-player", "poppin-new-player", "poppin-player"],
		["cosmicnew-player", "cosmic-player"],
		["flumbonew-player","flumbo-player"],
		["darkenu-player"],
		["gerald-player"],
		["rephonu-player"],
		["pimble-player"],
		["bogosbruj", "bruj", "dzubbogos-player"],
		["shadow-bf"]
	]; // must have idle and singUP or hey!
	var names:Array<Array<String>> = [
		[""],
		[
			"BF (Reanimated)",
			"BF (Original)",
			"BF (Christmas)",
			"BF (Pixel)",
			"BF (Poppin')",
			"BF (Scared)"
		],
		["Dave", "Dave 3D (Confident)"],
		["Bambi", "Angered Bambi", "Angered Bambi (Old)"],
		["Tristan", "Tristan (Golden)", "Tristan (Golden & Glowing)"],
		["Edd", "Eduardo"],
		["Bambi But Awesome", "Bambi But Awesome (Old)", "Real Bambi"],
		["Bandu (Snacker)", "Bandu (Poppin')", "Bandu (Poppin') Old"],
		["Cosmic", "Cosmic (Old)"],
		["Flumbo","Flumbo (Old)"],
		["Darkenu"],
		["Gerald"],
		["Rephonu"],
		["Pimble Glob"],
		["bruj (Bogos)", "Fun-sized bruj", "dzub"],
		["Fun-sized Shadow", "Shadow"]
	];
	var offsets:Array<Array<Array<Int>>> = [
		[[0, 0]], // defualt
		[[0, 0], [2, 1], [-7, -2], [193, 150], [33, 4], [-28, -30]], // boif
		[[0, -26], [158, 1]], // dave
		[[-15, 90], [73, 109], [-272, -266]], /// bambs
		[[-74, -8], [-73, -7], [-10, 51]], // tristans
		[[15, -50], [5, -34]], // edd/educadro
		[[-40, -110], [-54, -110], [-29, 23]], // joke bambs
		[[320, -68], [155, 30], [153, 14]], // bandus
		[[-118, -120], [230, 200]], // cosmics
		[[75,-9],[141, -11]], // flum
		[[231, 93]], // darking
		[[-384, -373]], // gerald
		[[0, -25]], // rephonu
		[[80, 640]], // pimble globber!!!
		[[30, -50], [9, 20], [32, 0]], // bruj and dzub
		[[28, -17], [0, 0]] // shadows
	];
	var zoomsSettings:Array<Array<Float>> = [
		[1], // defualt
		[1, 1, 1, 1, 1, 1], // boif
		[0.8, 0.7], // dave
		[1, 1, 1], // bambis
		[1, 1, 1], // trisnan
		[0.76, 0.72], // eddwordls
		[1, 1, 1], // joker bam
		[0.69, 0.7, 0.67], // bandus
		[0.65, 0.65], // cosmicing
		[0.85,0.85], // flambose
		[0.55], // dareker guy fnf
		[0.9], // gerlad
		[0.79], // rephonuin
		[1], // gimble plobber!!!
		[1, 1, 1], // brujs and the zdub
		[0.9, 1] // shdows
	];

	public static var backColor:FlxColor = 0xFFFDE871;

	var curCharLocked = false;
	var icon:HealthIcon;
	var healthBarBG:FlxSprite;

	public var healthBar:FlxBar;

	var lockedChars = ["cosmicnew-player", "cosmic-player"];
	var lockedCharsDesc = ["Beat Cosmic's week.", "Beat Cosmic's week."];
	var curSelected:Int = 0;
	var curForm:Int = 0;
	var name:FlxText;
	var info:FlxText;
	var character:Boyfriend;
	var entering:Bool = false;
	var chartest = false;
	var anims = ["LEFT", "DOWN", "UP", "RIGHT"];
	var keys = [
		ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
		ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
		ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
		ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
	];
	var tutorialThing:FlxSprite;
	var camCharacter:FlxCamera;
	var camFade:FlxCamera; // for the transitions

	function findFormattedDefault()
	{
		for (i in 0...chars.length)
		{
			for (j in 0...chars[i].length)
			{
				if (chars[i][j] == normal && chars[i][j] != "default")
				{
					return names[i][j];
				}
			}
		}
		return normal;
	}

	function giveCharTestThingy(ben:Bool)
	{
		if (ben)
			return "enabled.";
		else
			return "disabled.";
	}

	override function beatHit()
	{
		if (curBeat % 2 == 0 && character.animation.curAnim != null && character.animation.curAnim.finished)
			character.tryIdle(true);
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		defaultText = "Default (" + findFormattedDefault() + ")";
		FlxG.sound.playMusic(Paths.music('charselect'), 0.5);
		Conductor.changeBPM(145);
		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(MainMenuState.randomBG());
		tutorialThing = new FlxSprite(50, 50).loadGraphic(Paths.image('charSelectGuide')); // thx for img d&b
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.2));
		tutorialThing.antialiasing = FlxG.save.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.color = backColor;
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);
		add(tutorialThing);

		camCharacter = new FlxCamera();
		camCharacter.bgColor = 0x00ffffff;
		camFade = new FlxCamera();
		camFade.bgColor = 0x00ffffff;
		FlxG.cameras.add(camCharacter, false);
		FlxG.cameras.add(camFade, false);

		name = new FlxText(0, 10, 0, defaultText);
		name.setFormat(Paths.font("comic.ttf"), 24, FlxColor.BLACK);
		name.screenCenter(X);
		add(name);
		info = new FlxText(0, 595, 0, 'Press Control to toggle character testing!');
		info.text += '\nCharacter testing is ${giveCharTestThingy(chartest)}';
		info.text += "\n";
		info.setFormat(Paths.font("comic.ttf"), 16, FlxColor.BLACK, CENTER);
		info.screenCenter(X);
		add(info);
		icon = new HealthIcon("bf", true, true);
		healthBarBG = new AttachedSprite('healthBars/' + ClientPrefs.healthBarTexture.toLowerCase());
		healthBarBG.scrollFactor.set();
		healthBarBG.y = FlxG.height / 2 - 10;
		healthBarBG.x = 900;
		healthBarBG.angle = 90;
		healthBarBG.active = false;
		add(healthBarBG);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),
			Conductor, 'bpm', 144, 145);
		healthBar.scrollFactor.set();
		healthBar.angle = 90;
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		add(icon);
		icon.sprTracker = healthBarBG;
		icon.offsets[0] = 219;
		icon.offsets[1] = -350;
		character = new Boyfriend(0, 0, normal);
		character.screenCenter();
		add(character);
		character.playAnim("idle", true);
		character.cameras = [camCharacter];
		reloadCharacter();
		CustomFadeTransition.nextCamera = camFade;
		super.create();
	}

	function refreshCharInfo()
	{
		character.screenCenter();
		if (chars[curSelected][curForm] == "default")
			for (i in 0...chars.length)
			{
				for (j in 0...chars[i].length)
				{
					if (chars[i][j] == normal && chars[i][j] != "default")
					{
						character.x += offsets[i][j][0];
						character.y += offsets[i][j][1];
						camCharacter.zoom = zoomsSettings[i][j];
					}
				}
			}
		else
		{
			character.x += offsets[curSelected][curForm][0];
			character.y += offsets[curSelected][curForm][1];
			camCharacter.zoom = zoomsSettings[curSelected][curForm];
		}
	}

	override function update(elapsed:Float)
	{
		if (!chartest)
		{
			if (FlxG.keys.justPressed.LEFT)
				changeSelection(-1);
			else if (FlxG.keys.justPressed.RIGHT)
				changeSelection();
			if (FlxG.keys.justPressed.UP)
				changeForm(-1);
			else if (FlxG.keys.justPressed.DOWN)
				changeForm();
		}
		else
		{
			for (i in 0...4)
			{
				if (FlxG.keys.anyJustPressed(keys[i]))
				{
					character.playAnim("sing" + anims[i], true);
				}
			}
		}
		#if debug
		debugStuffs();
		#end
		if (FlxG.keys.anyJustPressed(ClientPrefs.copyKey(ClientPrefs.keyBinds.get('back'))))
		{
			CustomFadeTransition.nextCamera = camFade;
			LoadingState.loadAndSwitchState(if (!PlayState.isFreeplay) new StoryMenuState() else new FreeplayState());
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.sound.playMusic(Paths.music("freakyMenu"));
			Conductor.changeBPM(160);
		}
		if (FlxG.keys.justPressed.CONTROL && !curCharLocked)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			chartest = (chartest) ? false : true;
			tutorialThing.visible = (chartest) ? false : true;
			info.text = 'Press Control to toggle character testing!';
			info.text += '\nCharacter testing is ${giveCharTestThingy(chartest)}';
			info.text += "\n";
		}
		else if (FlxG.keys.justPressed.CONTROL && curCharLocked)
			FlxG.sound.play(Paths.sound("cancelMenu"));

		if (FlxG.keys.anyJustPressed(ClientPrefs.copyKey(ClientPrefs.keyBinds.get('accept'))) && !entering && !curCharLocked)
		{
			if (character.animOffsets.exists("hey"))
				character.playAnim("hey", true);
			else
				character.playAnim("singUP", true);
			entering = true;

			FlxG.sound.play(Paths.sound('confirmMenu'));
			if (chars[curSelected][curForm] != "default" && chars[curSelected][curForm] != normal)
			{
				PlayState.diffBf = ["true", chars[curSelected][curForm]];
			}
			else
			{
				PlayState.diffBf = ["false", "default"];
			}
			new FlxTimer().start(0.5, function(flx:FlxTimer)
			{
				CustomFadeTransition.nextCamera = camFade;
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		else if (FlxG.keys.anyJustPressed(ClientPrefs.copyKey(ClientPrefs.keyBinds.get('accept'))) && !entering && curCharLocked)
			FlxG.sound.play(Paths.sound("cancelMenu"));
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	function changeSelection(amount:Int = 1)
	{
		if (entering)
			return;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += amount;
		if (curSelected < 0)
			curSelected = chars.length - 1;
		if (curSelected > chars.length - 1)
			curSelected = 0;
		changeForm(0 - curForm);
		reloadCharacter();
	}

	function changeForm(amount:Int = 1)
	{
		if (entering)
			return;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curForm += amount;
		if (curForm < 0)
			curForm = chars[curSelected].length - 1;
		if (curForm > chars[curSelected].length - 1)
			curForm = 0;
		reloadCharacter();
	}

	function reloadCharacter()
	{
		var scharacter:Boyfriend;
		if (chars[curSelected][curForm] != "default")
		{
			scharacter = new Boyfriend(0, 0, chars[curSelected][curForm]);
			name.text = names[curSelected][curForm];
		}
		else
		{
			scharacter = new Boyfriend(0, 0, normal);
			name.text = defaultText;
		}
		if (lockedChars.contains(chars[curSelected][curForm]) && !ClientPrefs.unlockedChars.exists(chars[curSelected][curForm]))
		{
			scharacter.color = 0xff000000;
			icon.color = 0xff000000;
			healthBar.color = 0xff000000;
			curCharLocked = true;
			info.text = lockedCharsDesc[lockedChars.indexOf(chars[curSelected][curForm])];
			name.text = "???";
			name.size = 32;
			info.size = 28;
			info.screenCenter(X);
			name.screenCenter(X);
		}
		else
		{
			icon.color = 0xffffffff;
			healthBar.color = 0xffffffff;
			name.size = 24;
			info.size = 20;
			curCharLocked = false;
			info.text = 'Press Control to toggle character testing!';
			info.text += '\nCharacter testing is ${giveCharTestThingy(chartest)}';
			info.text += "\n";
			info.screenCenter(X);
			name.screenCenter(X);
		}
		remove(character, true);
		scharacter.cameras = [camCharacter];
		character = scharacter;
		refreshCharInfo();
		insert(0, character);
		icon.changeIcon(character.healthIcon);
		healthBar.createFilledBar(FlxColor.fromRGB(character.healthColorArray[0], character.healthColorArray[1], character.healthColorArray[2]),
			FlxColor.fromRGB(character.healthColorArray[0], character.healthColorArray[1], character.healthColorArray[2]));
	}

	function debugStuffs()
	{
		if (FlxG.keys.justPressed.Y)
		{
			zoomsSettings[curSelected][curForm] -= (FlxG.keys.pressed.SHIFT) ? 0.05 : 0.01;
			refreshCharInfo();
		}
		if (FlxG.keys.justPressed.P)
		{
			zoomsSettings[curSelected][curForm] += (FlxG.keys.pressed.SHIFT) ? 0.05 : 0.01;
			refreshCharInfo();
		}
		if (FlxG.keys.justPressed.J)
		{
			offsets[curSelected][curForm][0] -= (FlxG.keys.pressed.SHIFT) ? 10 : 1;
			refreshCharInfo();
		}
		if (FlxG.keys.justPressed.K)
		{
			offsets[curSelected][curForm][1] += (FlxG.keys.pressed.SHIFT) ? 10 : 1;
			refreshCharInfo();
		}
		if (FlxG.keys.justPressed.I)
		{
			offsets[curSelected][curForm][1] -= (FlxG.keys.pressed.SHIFT) ? 10 : 1;
			refreshCharInfo();
		}
		if (FlxG.keys.justPressed.L)
		{
			offsets[curSelected][curForm][0] += (FlxG.keys.pressed.SHIFT) ? 10 : 1;
			refreshCharInfo();
		}
		if (FlxG.keys.justPressed.O)
		{
			trace(offsets[curSelected][curForm]);
		}
		if (FlxG.keys.justPressed.U)
		{
			trace(zoomsSettings[curSelected][curForm]);
		}
	}
}
