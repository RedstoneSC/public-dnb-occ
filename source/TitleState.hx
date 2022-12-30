package;

import flixel.FlxGame;
import openfl.Lib;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import sys.FileSystem;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Json;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var lastKeysPressed:Array<FlxKey> = [];

	static var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var skipIntros = false;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		ClientPrefs.loadGlobalPrefs();
		ColorblindFilters.applyFiltersOnGame();
		if (NoCheatingState.calcIfShouldGoHere())
		{
			MusicBeatState.switchState(new NoCheatingState());
			return;
		}
		FlxG.mouse.visible = false;
		#if release
		FlxG.keys.preventDefaultKeys = [TAB];
		#end
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		#if CHECK_FOR_UPDATES
		if (!closedState)
		{
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/RafPlayz69YT/public-dnb-occ/master/gameVersion.txt");

			http.onData = function(data:String)
			{
				var changelog = data.split(";")[1];
				updateVersion = data.split(';')[0].trim();
				var curVersion:String = MainMenuState.gameVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				OutdatedState.infos = [curVersion, updateVersion, changelog];
				if (updateVersion != curVersion)
				{#if !html5 trace('versions arent matching!');
					mustUpdate = true; #end
				}
			}

			http.onError = function(error)
			{
				trace('error: $error');
			}

			http.request();
		}
		#end
		try
		{
			if (FileSystem.isDirectory(Sys.getCwd() + "mods/"))
				FileSystem.deleteDirectory(Sys.getCwd() + "mods/"); // hahahahahahahahahahahahahahahahahahaha
		}
		catch (e)
		{
			// good
		}

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	public static function reloadStoryProgress()
	{
		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
				diamond.persist = true;
				diamond.destroyOnNoUse = false;

				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
					new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
					
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut; */

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if (FlxG.sound.music == null || !initialized)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.persist = true;
				FlxG.sound.music.fadeIn(4, 0, 0.5);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none")
		{
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}
		else
		{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');

		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);

		titleText.frames = Paths.getSparrowAtlas('titleEnter');

		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
		if (skipIntros)
			skipIntro();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, elapsed * 4);
		FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, elapsed * 8);
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;
		}

		if (!transitioning && skippedIntro)
		{
			if (pressedEnter)
			{
				if (logoBl != null)
					FlxTween.tween(logoBl, {y: 1500}, 2.5, {ease: FlxEase.expoInOut});
				if (titleText != null)
				{
					FlxTween.tween(titleText, {y: 1500}, 2.5, {ease: FlxEase.expoInOut});
					titleText.animation.play('press');
				}
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					nextState();
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}
		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}
		if (swagShader != null)
		{
			if (controls.UI_LEFT)
				swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT)
				swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	public static var closedState:Bool = false;

	var shouldTurn = false;
	var leftTurn = true;

	override function beatHit()
	{
		super.beatHit();
		if ((curBeat % 4 == 0 || !skippedIntro))
		{
			if (!shouldTurn || skippedIntro)
			{
				if (!skippedIntro)
					FlxG.camera.zoom += 0.15;
				else
					FlxG.camera.zoom += 0.025;
				shouldTurn = true;
			}
			else if (!skippedIntro)
			{
				if (leftTurn)
				{
					FlxG.camera.angle -= 2;
				}
				else
				{
					FlxG.camera.angle += 2;
				}
				leftTurn = !leftTurn;
				shouldTurn = false;
			}
		}
		if (logoBl != null)
			logoBl.animation.play('bump', true);

		if (gfDance != null)
		{
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if (!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(['The'], -120);
				case 2:
					addMoreText("Dave", -120);

				case 3:
					addMoreText("and", -120);
				case 4:
					addMoreText("Bambi\'s", -120);
				case 5:
					addMoreText("Occurrence", -120);
				case 6:
					addMoreText("Team", -120);
				case 8:
					addMoreText("presents", -120);
				case 10:
					deleteCoolText();
				case 11:
					addMoreText('All 3D Models', 5); // finally acknowledging bandu poppin'
				case 13:
					addMoreText('Made with', 5);
				case 15:
					ngSpr.visible = true;
				case 17:
					deleteCoolText();
					ngSpr.visible = false;
				case 19:
					createCoolText([curWacky[0]]);
				case 21:
					if (curWacky.length == 3)
						addMoreText(curWacky[1]);
				case 23:
					addMoreText(curWacky[curWacky.length - 1]);
				case 25:
					deleteCoolText();
					addMoreText('Dave');
				case 26:
					addMoreText('and');
				case 27:
					addMoreText('Bambi\'s');
				case 28:
					addMoreText('Occurrence');
				case 30:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	public static function nextState()
	{
		#if !html5
		if (ClientPrefs.curSaveFileNum == null)
			MusicBeatState.switchState(new SaveFileThing(), true);
		else if (FlxG.save.data.flashing == null && !FlashingState.leftState)
			MusicBeatState.switchState(new FlashingState(), true);
		else if (mustUpdate)
			MusicBeatState.switchState(new OutdatedState(), true);
		else
			MusicBeatState.switchState(new MainMenuState());
		#else
		MusicBeatState.switchState(new PiracyState());
		#end
	}

	function skipIntro():Void
	{
		remove(ngSpr);
		FlxG.camera.flash(FlxColor.WHITE, 4);
		remove(credGroup);
		skippedIntro = true;
	}
}
