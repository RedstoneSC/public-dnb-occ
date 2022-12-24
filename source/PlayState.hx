package;

import flixel.graphics.frames.FlxFrame;
import flixel.util.typeLimit.OneOfTwo;
import Achievements;
import DialogueBoxPsych;
import GameplayChangersSubstate.GameplayOption;
import Note.EventNote;
import Section.SwagSection;
import Shaders.PulseEffect;
import Song.SwagSong;
import StageData;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Sprite;
import openfl.utils.Assets;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.Assets as OpenFlAssets;
import sys.io.File;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
#if sys
import sys.FileSystem;
#end

class NewDate
{
	public function new()
	{
		new FlxTimer().start(1.25, remove);
	}

	function remove(sus:FlxTimer)
	{
		@:privateAccess
		{
			PlayState.notesHitArray.remove(this);
			PlayState.instance.updateScoreText();
		}
		sus.destroy();
	}
}

class PlayState extends MusicBeatState // hi guys
{
	// cosmic eye stuff
	var cosmicEye:FlxSprite;
	var keysEyePressed:Int = 0;
	var shownUpEye:Int = 4;
	var cosmicStatic:FlxSound;
	var cosmicEyeTimerD:FlxTimer = new FlxTimer(); // death

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
	public static var STRUM_Y = 50;
	public static var STRUM_Y_DOWNSCROLL = 570;

	public static var ratingStuff:Array<Dynamic> = [
		[
			['you suck really bad lol', 0.1], // From 0% to 9%
			['horrible', 0.2], // From 10% to 19%
			['why', 0.4], // From 20% to 39%
			['real bambi is better', 0.5], // From 40% to 49%
			['bruhh', 0.6], // From 50% to 59%
			['fair', 0.69], // From 60% to 68%
			['primix is coming to your location in 1-3 days', 0.7], // 69%
			['nice', 0.8], // From 70% to 79%
			['banger', 0.9], // From 80% to 89%
			['hot', 0.95], // From 90% to 99%
			['hits hard', 1] // The value on this one isn't used
		],
		[
			['SDCB', 1], // single digit combo break if you wondering what sdcb means
			['Clear', 10],
			['Skill issue', 25],
			['oof', 100],
			['big yikes', 500],
			['bruh', 1000],
			[':sigh:', 10000]
		]
	];

	// var curSection:Int = 0;
	var cameraMoveOffset = 40;
	// event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var altCharMap:Map<String, Character> = new Map();
	public var altChar2Map:Map<String, Character> = new Map();

	public static var diffBf = ["false", "default"];

	public var altCharInfo = {
		name: "nothing",
		withPlayer: true,
		exists: false
	} // helps keeps everything in 1 var

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";

	var credits = "";
	var songName = '';

	public static var screenshader:PulseEffect = new PulseEffect();
	public static var shaderOn = false;
	public static var songHasShaders = false;
	public static var forceShadersOn = false; // dialogue
	public static var dialogueshader:PulseEffect = new PulseEffect();

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var altCharGroup:FlxSpriteGroup;
	public var altChar2Group:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;
	public var dad:Character;
	public var altChar:Character;
	public var altChar2:Character; // for splitathon occurrence (idk name)
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var eventNotes:Array<EventNote> = [];

	// so we can format time with hours
	public static function formatTime(secs:Float)
	{
		var timeString = "";
		var mins = Std.int(secs / 60);
		var hours = Std.int(mins / 60);
		if (hours > 0)
		{
			if (hours < 10)
				timeString += "0";
			timeString += hours % 24 + ":";
			if (mins % 60 < 10)
				timeString += "0";
		}
		timeString += mins % 60 + ":";
		if (Std.int(secs) % 60 < 10)
			timeString += "0";
		timeString += Std.int(secs) % 60;
		return timeString;
	}

	var judgementCounter:FlxText;
	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = ClientPrefs.camZooms;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;

	function set_health(v:Float):Float
	{
		health = CoolUtil.boundTo(v, 0, 2);
		if (health <= 0)
			doDeathCheck();
		if (healthBar.percent <= 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 2;
			if (altCharInfo.exists)
			{
				iconAlt.animation.curAnim.curFrame = 1 + ((altCharInfo.withPlayer) ? 0 : 1);
				iconAlt2.animation.curAnim.curFrame = 2;
			}
		}
		else if (healthBar.percent >= 80)
		{
			iconP2.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 2;
			if (altCharInfo.exists)
			{
				iconAlt.animation.curAnim.curFrame = 1 + ((altCharInfo.withPlayer) ? 1 : 0);
				iconAlt2.animation.curAnim.curFrame = 1;
			}
		}
		else
		{
			iconP2.animation.curAnim.curFrame = 0;
			iconP1.animation.curAnim.curFrame = 0;
			if (altCharInfo.exists)
			{
				iconAlt.animation.curAnim.curFrame = 0;
				iconAlt2.animation.curAnim.curFrame = 0;
			}
		}
		return v;
	}

	public var combo:Int = 0;
	public var bgs:FlxTypedGroup<FlxSprite>;
	public var triangle:FlxSprite;

	private var healthBarBG:AttachedSprite;

	public var healthBar:FlxBar;

	var songPercent:Float = 0;
	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = true;

	private var startingSong:Bool = false;
	private var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconAlt:HealthIcon;
	public var iconAlt2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camPause:FlxCamera;
	public var cameraSpeed:Float = 1;

	var notesHit = 0;
	var dialogueJson:DialogueFile = null;
	var elapsedtime = 0.0;
	var camFollowX:Int = 0;
	var camFollowY:Int = 0;
	var dadCamFollowX(default, set):Int = 0;
	var dadCamFollowY(default, set):Int = 0;
	var heyTimer:Float;

	function set_dadCamFollowY(v:Int):Int
	{
		if (dad.curCharacter != "redacted")
			dadCamFollowY = v;
		return v;
	}

	function set_dadCamFollowX(v:Int):Int
	{
		if (dad.curCharacter != "redacted")
			dadCamFollowX = v;
		return v;
	}

	static var notesHitArray:Array<NewDate> = [];

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var isFreeplay = false;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float = 0;
	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	var keysPressed = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;
	var textSong:FlxText;

	public static var instance:PlayState;

	var songMaker = "";

	public static var floatBois:Array<String> = [
		"flumbo", "cosmic", "bandusnacker", "bandupoppin", "redacted", "bandusnackerold", "bandupoppinold", "poppin", "snacker", "dave3d", "dollarmbi",
		"gerald", "poppin-new", "rephonu", "cosmicnew", "dave3d-confident", "expunged", "flumboold", "dollarmbimove"
	]; // float

	var boisThatAre3D:Array<String> = [
		"brick", "flumbo", "cosmic", "darkenu", "bandusnacker", "bandupoppin", "redacted", "darkenuangle", "bandusnackerold", "bandupoppinold", "poppin",
		"snacker", "dave3d", "poppin-new", "rephonu", "cosmicnew", "dave3d-confident", "expunged", "flumboold"
	]; // 3d

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	var stageData:StageFile;

	var jumpscareFrames:Dynamic;

	// cool colors thing
	var nightColor:FlxColor = 0xFF878787;
	var sunsetColor:FlxColor = FlxColor.fromRGB(255, 143, 178);

	public var characterColor = 0xffffffff;

	public var keyboardsPresses:Array<Bool> = [false, false, false, false];

	override public function create()
	{
		endingSong = false;
		notesHitArray = [];

		cheater = ClientPrefs.getGameplaySetting("botplay", false) || ClientPrefs.getGameplaySetting("practice", false) || chartingMode;
		ClientPrefs.loadPrefs();
		if (!ClientPrefs.songsLoaded.exists(SONG.song.toLowerCase()) && !cheater && !chartingMode)
			ClientPrefs.songsLoaded.set(SONG.song.toLowerCase(), true);
		ClientPrefs.saveSettings();
		Paths.clearStoredMemory();
		if (diffBf[0] == "true")
			diffBf[0] = FreeplayState.skipCharSelectSongs.contains(SONG.song.toLowerCase()) ? "maybe" : "true";
		// for lua
		instance = this;
		Achievements.loadAchievements();

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camPause = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camPause.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		FlxG.cameras.add(camPause);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camPause;

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (!isFreeplay && WeekData.getCurrentWeek() != null)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
		{
			switch (songName)
			{
				default:
					curStage = "triangles";
			}
		}
		stageData = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.7,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				altChar: [890, 80],
				hideGF: true
			}
		}
		if (diffBf[0] == "true")
		{
			switch (diffBf[1])
			{
				case "bf-pixel":
					GameOverSubstate.characterName = 'bf-pixel-dead';
					GameOverSubstate.deathSoundName = "fnf_loss_sfx-pixel";
				case "bruj":
					GameOverSubstate.characterName = 'bruj';
					GameOverSubstate.deathSoundName = "fnf_loss_sfx_bruj";
				case "shadow-bf":
					GameOverSubstate.characterName = 'shadow-bf-death';
					GameOverSubstate.deathSoundName = "fnf_loss_sfx_shadow";
				case "tristan-golden" | "tristan-golden-glowing":
					GameOverSubstate.characterName = 'tristan-golden-death';
					GameOverSubstate.deathSoundName = "fnf_loss_sfx-tristan";
				case "tristan-playable":
					GameOverSubstate.characterName = 'tristan-death';
					GameOverSubstate.deathSoundName = "fnf_loss_sfx-tristan";
			}
		}

		if (defaultCamZoom == 1.05)
			defaultCamZoom = stageData.defaultZoom;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		altCharInfo = {
			name: "nothing",
			withPlayer: true,
			exists: false
		} // no crashes in sight!
		switch (SONG.song.toLowerCase())
		{
			case 'snacker-eduardo' | "snacker-eduardo-old" | "snacker-eduardo-older":
				altCharInfo.name = "edd";
				altCharInfo.exists = true;
			case "wheelchair" | "wheelchair-old" | "occurathon":
				altCharInfo.exists = true;
				altCharInfo.withPlayer = false;
		}
		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		if (altCharInfo.exists)
		{
			var xyalt2 = [0, 0];
			altCharGroup = new FlxSpriteGroup((stageData.altChar != null) ? stageData.altChar[0] : (altCharInfo.withPlayer) ? 890 : 100,
				(stageData.altChar != null) ? stageData.altChar[1] : (altCharInfo.withPlayer) ? 80 : 120);
			altChar2Group = new FlxSpriteGroup(xyalt2[0], xyalt2[1]);
		}
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		bgs = new FlxTypedGroup();
		add(bgs);
		add(gfGroup);

		add(dadGroup);
		if (altCharInfo.exists)
		{
			add(altCharGroup);
			add(altChar2Group);
		}
		add(boyfriendGroup);

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = 'gf';
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}
		if (diffBf[1].startsWith("bf") && diffBf[1].length > 2 && diffBf[0] == "true")
			gfVersion = "gf" + diffBf[1].substr(2);
		else if (diffBf[1] == "bf" || SONG.player1 == "bf")
			gfVersion = "gf";
		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		gf.visible = if (!stageData.hideGF || stageData.hideGF /*null detect*/) !stageData.hideGF else true;
		gf.active = gf.visible;
		if (altCharInfo.exists)
		{
			altChar = new Character(0, 0, altCharInfo.name, altCharInfo.withPlayer, true);
			startCharacterPos(altChar);
			altCharGroup.add(altChar);
			altChar.visible = altCharInfo.exists;
			altChar.active = altChar.visible;

			altChar2 = new Character(0, 0, "nothing", false, true);
			startCharacterPos(altChar2);
			altChar2Group.add(altChar2);
			altChar2.visible = altChar2.curCharacter != "nothing";
			altChar2.active = altChar2.visible;
		}
		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		boyfriend = new Boyfriend(0, 0, if (diffBf[0] != "true") SONG.player1 else diffBf[1]);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		boyfriend.curCharacter = boyfriend.curCharacter.replace("-player", "");
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];
		if (SONG.song.toLowerCase() == "occurathon")
			jumpscareFrames = Paths.occurSparrow("cosmic_jumpscare");
		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		makeBG(curStage); // needed to be moved

		var file:String = Paths.json(songName + '/dialogue'); // Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file))
		{
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, STRUM_Y).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = STRUM_Y_DOWNSCROLL;
		strumLine.scrollFactor.set();
		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = ClientPrefs.laneUnderlaything;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = ClientPrefs.laneUnderlaything;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
		if (ClientPrefs.laneUnderlayenabled && SONG.song.toLowerCase() != "errorless")
		{
			add(laneunderlay);
			add(laneunderlayOpponent);
		}

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.visible = !ClientPrefs.hideHud;
		judgementCounter.text = 'Combo: ${combo}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}';
		judgementCounter.text += '\nTotal notes hit: ${notesHit}';
		judgementCounter.text += '\n';
		if (ClientPrefs.judgementCounter)
		{
			add(judgementCounter);
		}

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 44;

		updateTime = showTime;
		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;

			timeTxt.size = 24;
			timeTxt.y += 3;
			updateTime = false;
		}
		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		var fill = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		fill.brightness = 0.85;
		timeBar.createFilledBar(0xFF000000, (ClientPrefs.timeColorBar) ? fill : 0xFFFFFFFF);
		timeBar.numDivisions = 600;
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		if (ClientPrefs.timeBarType == "Disabled")
		{
			timeBar.destroy();
			timeTxt.destroy();
			timeBarBG.destroy();
			timeBar = null;
			timeTxt = null;
			timeBarBG = null;
		}
		else
		{
			timeBar.cameras = [camHUD];
			timeBarBG.cameras = [camHUD];
			timeTxt.cameras = [camHUD];
		}
		strumLineNotes = new FlxTypedGroup<StrumNote>();

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);
		curPart = 0;
		if (ClientPrefs.mechanics)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'demise' | 'phase':
					cosmicEye = new FlxSprite().loadGraphic(Paths.occurPath("cosmiceyemechanic", IMAGES, false));
					cosmicEye.cameras = [camOther];
					add(cosmicEye);
					cosmicStatic = new FlxSound().loadEmbedded(Paths.occurPath("cosmicstatic", SOUNDS));
					killEye(false);
					cosmicEye.screenCenter();
					switch (SONG.song.toLowerCase())
					{
						case 'demise':
							shownUpEye = 6;
					}
			}
		}
		healthBarBG = new AttachedSprite('healthBars/' + ClientPrefs.healthBarTexture.toLowerCase());
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		healthBarBG.active = false;
		add(healthBarBG);
		if (ClientPrefs.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud || boyfriend.healthIcon == "";
		iconP1.active = iconP1.visible;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false, true);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud || dad.healthIcon == "";
		iconP2.active = iconP2.visible;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		if (altCharInfo.exists)
		{
			iconAlt = new HealthIcon(altChar.healthIcon, altCharInfo.withPlayer, true);
			iconAlt.sprTracker = (altCharInfo.withPlayer) ? iconP1 : iconP2;
			iconAlt.offsets[0] = altCharInfo.withPlayer ? 70 : -70;
			iconAlt.offsets[1] = -50;
			iconAlt.visible = !ClientPrefs.hideHud || altChar.healthIcon == "";
			iconAlt.active = iconAlt.visible;
			iconAlt.alpha = ClientPrefs.healthBarAlpha;
			add(iconAlt);

			iconAlt2 = new HealthIcon(altChar2.healthIcon, false, true);
			iconAlt2.sprTracker = iconP2;
			iconAlt2.offsets[0] = -85;
			iconAlt2.offsets[1] = 20;
			iconAlt2.visible = !ClientPrefs.hideHud || altChar2.healthIcon == "";
			iconAlt2.active = iconAlt2.visible;
			iconAlt2.alpha = ClientPrefs.healthBarAlpha;
			add(iconAlt2);
		}
		reloadHealthBarColors();

		scoreTxt = new FlxText(100, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		credits = "";
		this.songName = '${SONG.song} - ${CoolUtil.normalDifficultyString()} - ${MainMenuState.gameVersion}';
		switch (SONG.song.toLowerCase())
		{
			case "quingen":
				FlxG.mouse.visible = true;
				credits = 'https://www.change.org/p/president-of-the-united-states-put-bambi-on-the-50-dollar-bill \nClick that.';
				var underline = new FlxSprite(5, 697).makeGraphic(680, 3, FlxColor.WHITE);
				underline.cameras = [camHUD];
				underline.active = false;
				var blackunderline = new FlxSprite(3, 695).makeGraphic(684, 7, FlxColor.BLACK);
				blackunderline.cameras = [camHUD];
				blackunderline.active = false;
				var button = new FlxButton(5, 673, "", function()
				{
					pause();
					CoolUtil.browserLoad('https://www.change.org/p/president-of-the-united-states-put-bambi-on-the-50-dollar-bill');
				});
				button.cameras = [camHUD];
				button.loadGraphic("shared:assets/shared/images/characters/nothing.png");
				button.setGraphicSize(680, 28);
				button.updateHitbox();
				add(button);
				add(blackunderline);
				add(underline);

				button.label.active = false;
				button.label.visible = false;
			case "errorless":
				credits = "modchart not finshed yet";
			case "budget-quingen":
				credits = "we have quingen at home guys";
			case "ultramarathon":
				credits = "2 hours. Get ready.";
			case 'console':
				credits = "HOW YOU BEAT ME IN AMOGN US????";
			case "snacker-eduardo" | "snacker-eduardo-old" | "snacker-eduardo-older":
				credits = "WELL WELL WELL";
			case "poppin" | "poppin-old" | "poppin-older" | "poppin-oldest":
				credits = "Hitsounds are forced on\nwith a special sound!";
			case "heheheha":
				credits = "HEHEHEHA";
			case "demise":
				credits = "You're in trouble now.";
			case "real-corn":
				credits = "corn is real, bambi is real, farm is real";
			case "[redacted]":
				credits = "Error: Null Object Reference";
			case "brick":
				credits = '"please stop throwing bricks at my head!" :nerd:';
			case "that-guy":
				credits = "we needed this to use bandu in our mod";
			case "breaking-madness":
				credits = "\"HOW YOU DO THAT?\" -cheating expunged fnf 2021";
			case "pebble":
				credits = "the pimble glober!!!!!";
			case "short-stalk" | "short-stalk-old":
				credits = "not made for this mod lolololol";
			case "ascension":
				credits = "kstr made like first part (befor he leaft) and\nafter a while bruj recreated and finised off";
		}
		switch (SONG.song.toLowerCase())
		{
			case "snacker" | "snacker-eduardo" | "snacker-eduardo-older" | "snacker-old" | "quingen" | "console" | "magicians-work" | "short-stalk" |
				"short-stalk-old" | "snacker-eduardo-old" | "snacker-older" | "fury":
				songMaker = "kstr743";
			case "poppin" | "poppin-oldest" | "breaking-madness" | "bambino" | "shucked" | "poppin-older" | "heheheha" | "brick" | "poppin-old" |
				"alien-language" | "wilderness" | "mechanical" | "pebble" | "[redacted]" | "triangles" | "budget-quingen":
				songMaker = "bruj";
				if (SONG.song.toLowerCase() == "alien-language")
					songMaker += " & dzub";
				else if (SONG.song.toLowerCase() == "[redacted]")
					songMaker += " & YT_GD";
			case "phase" | "demise" | "darker" | "occurathon":
				songMaker = "YT_GD";
				if (SONG.song.toLowerCase() == "demise")
					songMaker += " & kstr743";
			case "real-corn":
				songMaker = "dzub";
			case "phones" | "phones-old":
				songMaker = "ThatPizzaTowerFan";
			case "cubic" | "cubic-old" | "gate" | "that-guy" | "shadowed" | "icicles":
				songMaker = "RafPlayz69";
			case "wheelchair" | "wheelchair-old" | "ascension":
				songMaker = "bruj & kstr743";
			case "ultramarathon":
				songMaker = "bruj, RafPlayz69, kstr743, YT_GD & ToxicFlame";
			case "hard-candies":
				songMaker = "ToxicFlame";
			case "errorless":
				songMaker = "lastremains";
		}

		textSong = new FlxText(5, ((ClientPrefs.downScroll) ? FlxG.height * 0.04 : FlxG.height * 0.92)
			- ((credits != "") ? 25 : 0), 0,
			((ClientPrefs.downScroll) ? "\n\n" : "")
			+ 'By $songMaker\n'
			+ this.songName);
		textSong.text += '\n$credits';
		textSong.text += '\n';
		textSong.cameras = [camHUD];
		textSong.scrollFactor.set();
		textSong.setFormat(Paths.font("comic.ttf"), if (credits.length > 28 || songName.length > 28) if (credits.length > 42 || songName.length > 42)
			14
		else
			15 else 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textSong.borderSize = 1.25;
		add(textSong);
		// note for bruj, this doesn't need to be uppercase and \n means new line also please no swear :sob:
		var botplayTexts = [
			"YOU CHEATER",
			"STOP MOLDY\nHE'S DEAD",
			"GET OUT NOW",
			"why :sob:",
			"you don't",
			"...",
			"cringne",
			"what, who, why,\nwhere and how",
			"i will block you",
			"botplay binted?",
			"stop doing that",
			"the j is funny",
			"tf2 referecnecen????!?!?!??!"
		];
		if (SONG.song.toLowerCase() == "ultramarathon")
			botplayTexts = ["i mean,\nyou won't get\n the achievement\nbut fair"];
		botplayTxt = new FlxText(395, timeBarBG.y + 55, FlxG.width - 800, FlxG.random.getObject(botplayTexts), 28);
		botplayTxt.setFormat(Paths.font("comic.ttf"), 24, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 30;
		}
		if (ClientPrefs.middleScroll)
		{
			botplayTxt.x -= 435 * (FlxG.random.bool(50) ? 1 : -1);
		}
		add(strumLineNotes);
		generateSong(SONG.song);
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		add(grpNoteSplashes);
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		if (altCharInfo.exists)
		{
			iconAlt.cameras = [camHUD];
			iconAlt2.cameras = [camHUD];
		}
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		var chars:Array<Character> = [dad, boyfriend];
		if (altCharInfo.exists)
		{
			chars.push(altChar);
			chars.push(altChar2);
		}
		for (char in chars)
		{
			if (floatBois.contains(char.curCharacter))
				char.y -= 0.54 / FlxG.elapsed;
		}

		startingSong = true;
		if (["fury", "phase", "demise", "ultramarathon"].contains(SONG.song.toLowerCase()) && !ClientPrefs.disableFX)
		{
			var vignette = new FlxSprite().loadGraphic(Paths.image("vignette"));
			vignette.cameras = [camPause];
			add(vignette);
			vignette.color.brightness = -50;
			vignette.screenCenter();
			vignette.active = false;
		}

		var daSong:String = Paths.formatToSongPath(curSong);

		RecalculateRating();
		if (ClientPrefs.hitsounds)
		{
			precacheList.set('hitsound', 'sound');
		}
		else if (SONG.song.toLowerCase().startsWith("poppin"))
		{
			precacheList.set('hitsoundPop', 'sound');
		}
		if (SONG.song.toLowerCase() == "ultramarathon")
		{
			precacheList.set("ultramarathon$-0", "inst");
			precacheList.set("ultramarathon$-1", "inst");
			precacheList.set("ultramarathon$-2", "inst");
			precacheList.set("ultramarathon$-0", "vocals");
			precacheList.set("ultramarathon$-1", "vocals");
			precacheList.set("ultramarathon$-2", "vocals");
		}
		if (!ClientPrefs.ghostTapping || ClientPrefs.antiMash)
		{
			precacheList.set('missnote1', 'sound');
			precacheList.set('missnote2', 'sound');
			precacheList.set('missnote3', 'sound');
		}
		precacheList.set('breakfast', "music");

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), null, null,
			'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
		#end

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressListen);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;

		super.create();

		Paths.clearUnusedMemory();
		for (key => type in precacheList)
		{
			// trace('Key $key is type $type');
			switch (type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case "inst":
					Paths.inst(key.split("$-")[0], Std.parseInt(key.split("$-")[1]));
				case "vocals":
					Paths.voices(key.split("$-")[0], Std.parseInt(key.split("$-")[1]));
				case 'occimage':
					Paths.occurPath(key, IMAGES);
				case 'occsound':
					Paths.occurPath(key, SOUNDS);
				case 'occmusic':
					Paths.occurPath(key, MUSIC);
			}
		}

		CustomFadeTransition.nextCamera = camPause;

		if (songHasShaders)
		{
			screenshader.waveAmplitude = 1.1;
			screenshader.waveFrequency = 2.1;
			screenshader.waveSpeed = 1.0;
			screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);
			dialogueshader.waveAmplitude = 1.1;
			dialogueshader.waveFrequency = 2.1;
			dialogueshader.waveSpeed = 1.0;
			dialogueshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);
			FlxG.camera.setFilters([new ShaderFilter(screenshader.shader)]);
			camHUD.setFilters([new ShaderFilter(dialogueshader.shader)]);
		}

		if (dialogueJson != null && !seenCutscene && isStoryMode)
		{
			var song = "homeBop";
			switch (SONG.song.toLowerCase())
			{
				case "[redacted]":
					song = "redacteddialogue";
				case "cubic":
					song = "geometricDisturbance";
				case "darker" | "shadowed":
					song = "dim";
				case "demise" | "phase":
					song = "instability";
				case "shucked" | "short-stalk" | "short-stalk-old":
					song = "farmLand";
				case "fury":
					song = "huffy";
				case "triangles" | "icicles":
					song = "threeSided";
			}
			startDialogue(dialogueJson, song);
			seenCutscene = true;
			laneunderlay.visible = false;
			laneunderlayOpponent.visible = false;
		}
		else
		{
			startCountdown();
		}
	}

	function getBackgroundColor(stageName:String = "")
	{
		switch (stageName.toLowerCase())
		{
			case 'farm-night' | "house-night":
				return nightColor;
			case 'farm-sunset' | "farm-sunrise" | 'house-sunset' | "house-sunrise":
				return sunsetColor; // arround same color sooo why not?
		}
		return 0xffffffff;
	}

	function makeBG(curStage:String, preloadingStuff:Bool = false)
	{
		if (bgs.members.length > 0 && !preloadingStuff)
		{
			for (bg in bgs)
			{
				bgs.remove(bg, true);
				bg.destroy();
			}
		}
		var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
		switch (curStage)
		{
			case "rephonman":
				var bg:FlxSprite = new FlxSprite(-400, -510).loadGraphic(Paths.occurPath("phoneu_re_bg", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.1, 1.1);
				if (!preloadingStuff)
					bgs.add(bg);
			case "pibbleglober":
				var bg:FlxSprite = new FlxSprite(-400, -510).loadGraphic(Paths.occurPath("jilly_bob_pimbo", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.1, 1.1);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 3.5;
				testshader.waveSpeed = 3;
				bg.shader = testshader.shader;
				if (!preloadingStuff)
					bgs.add(bg);
			case "clonehero":
				var bg:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.occurPath("ghandifromclonebg", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.15, 1.15);
				if (!preloadingStuff)
					bgs.add(bg);
			case "firefarmfr":
				var bg:FlxSprite = new FlxSprite(-270, -175);
				bg.frames = Paths.occurSparrow("firefr");
				bg.animation.addByPrefix("bg", "imagine-getting-set-on-fire", 24);
				bg.animation.play("bg");
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.25, 1.25);
				if (!preloadingStuff)
					bgs.add(bg);
				songHasShaders = true;
			case 'gerlad':
				var bg:FlxSprite = new FlxSprite(-300, -510).loadGraphic(Paths.occurPath("gerladbg", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.1, 1.1);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'console':
				var bg:FlxSprite = new FlxSprite();
				bg.frames = Paths.occurSparrow("console/consolesingposes");
				bg.animation.addByPrefix("no", "nosing", 1, true);
				bg.animation.addByPrefix("bambi", "bambising", 1, true);
				bg.animation.addByPrefix("bf", "bfsing", 1, true);
				bg.animation.addByPrefix("both", "bothsing", 1, true);
				bg.animation.play("no");
				bg.cameras = [camHUD]; // so it no move :smiley:
				bgs.add(bg);
			case 'grantfromfnf':
				var bg:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.occurPath('thegrantguyonthe50bill', IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'untiedstate':
				var bg:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.occurPath('americanhdrtx', IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'nightbambg':
				var bg:FlxSprite = new FlxSprite(-1067, -505);
				bg.frames = Paths.occurSparrow("nightbambg");
				bg.animation.addByPrefix("bg", "bg", 24);
				bg.animation.play("bg");
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'bluecubes':
				var bg:FlxSprite = new FlxSprite(-1067, -505);
				bg.loadGraphic(Paths.occurPath("bluecubesbg", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 3.5;
				testshader.waveSpeed = 3;
				bg.shader = testshader.shader;
				songHasShaders = true;

			case 'house' | "house-night" | "house-sunrise" | "house-sunset":
				var skyType:String = '';
				var assetType:String = '';
				switch (curStage)
				{
					case 'house':
						skyType = 'sky';
					case 'house-night':
						skyType = 'sky_night';
						assetType = 'night/';
					case 'house-sunset':
						skyType = 'sky_sunset';
					case "house-sunrise":
						skyType = "sky_sunrise";
				}
				var bg:BGSprite = new BGSprite('bg', -600, -300, Paths.image('backgrounds/${skyType}'), 0.6, 0.6);
				bgs.add(bg);

				var stageHills:BGSprite = new BGSprite('stageHills', -834, -159, Paths.image('backgrounds/dave-house/${assetType}hills'), 0.7, 0.7);
				bgs.add(stageHills);

				var grassbg:BGSprite = new BGSprite('grassbg', -1205, 580, Paths.image('backgrounds/dave-house/${assetType}grass bg'));
				bgs.add(grassbg);

				var gate:BGSprite = new BGSprite('gate', -755, 250, Paths.image('backgrounds/dave-house/${assetType}gate'));
				bgs.add(gate);

				var stageFront:BGSprite = new BGSprite('stageFront', -832, 505, Paths.image('backgrounds/dave-house/${assetType}grass'));
				bgs.add(stageFront);

			case "farm" | "farm-night" | "farm-sunrise" | "farm-sunset":
				var skyType:String = '';
				switch (curStage)
				{
					case 'farm':
						skyType = 'sky';
					case 'farm-night':
						skyType = 'sky_night';
					case 'farm-sunset':
						skyType = 'sky_sunset';
					case "farm-sunrise":
						skyType = "sky_sunrise";
				}
				var bg:BGSprite = new BGSprite('bg', -600, -200, Paths.image('backgrounds/' + skyType), 0.6, 0.6);
				bgs.add(bg);

				var flatgrass:BGSprite = new BGSprite('flatgrass', 350, 75, Paths.image('backgrounds/farm/gm_flatgrass'), 0.65, 0.65);
				flatgrass.setGraphicSize(Std.int(flatgrass.width * 0.34));
				flatgrass.updateHitbox();
				bgs.add(flatgrass);

				var hills:BGSprite = new BGSprite('hills', -173, 100, Paths.image('backgrounds/farm/orangey hills'), 0.65, 0.65);
				bgs.add(hills);

				var farmHouse:BGSprite = new BGSprite('farmHouse', 100, 125, Paths.image('backgrounds/farm/funfarmhouse', 'shared'), 0.7, 0.7);
				farmHouse.setGraphicSize(Std.int(farmHouse.width * 0.9));
				farmHouse.updateHitbox();
				bgs.add(farmHouse);

				var grassLand:BGSprite = new BGSprite('grassLand', -600, 500, Paths.image('backgrounds/farm/grass lands', 'shared'));
				bgs.add(grassLand);

				var cornFence:BGSprite = new BGSprite('cornFence', -400, 200, Paths.image('backgrounds/farm/cornFence', 'shared'));
				bgs.add(cornFence);

				var cornFence2:BGSprite = new BGSprite('cornFence2', 1100, 200, Paths.image('backgrounds/farm/cornFence2', 'shared'));
				bgs.add(cornFence2);

				var bagType = FlxG.random.int(0, 1000) == 0 ? 'popeye' : 'cornbag';
				var cornBag:BGSprite = new BGSprite('cornFence2', 1200, 550, Paths.image('backgrounds/farm/$bagType', 'shared'));
				bgs.add(cornBag);

				var sign:BGSprite = new BGSprite('sign', 0, 350, Paths.image('backgrounds/farm/sign', 'shared'));
				bgs.add(sign);
				if (FlxG.random.int(0, 4) == 0)
				{
					var baldi = new BGSprite('baldi', 400, 110, Paths.image('backgrounds/farm/baldo', 'shared'), 0.65, 0.65);
					baldi.setGraphicSize(Std.int(baldi.width * 0.31));
					baldi.updateHitbox();
					bgs.insert(bgs.members.indexOf(hills), baldi);
				}
				if (curStage == "farm-night")
				{
					var picnic:BGSprite = new BGSprite('picnic', 1050, 650, Paths.image('backgrounds/farm/picnic_towel_thing', 'shared'));
					bgs.insert(bgs.members.indexOf(cornBag), picnic);
				}
			case "fusionreal":
				var bg = new FlxSprite(-690, -500);
				bg.loadGraphic(Paths.occurPath("fusionflumcosdark", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.25;
				testshader.waveFrequency = 1;
				testshader.waveSpeed = 0.5;
				bg.shader = testshader.shader;
			case "errorfullness":
				testshader.waveAmplitude = 0.02;
				testshader.waveFrequency = 1;
				testshader.waveSpeed = 1;
				var posiotnoining = [-450, -250];

				var bg:FlxSprite = new FlxSprite(posiotnoining[0], posiotnoining[1]);
				bg.loadGraphic(Paths.occurPath("errorlessbg/xbackgroundoohneoes", IMAGES));
				bgs.add(bg);
				bg.shader = testshader.shader;

				var triangleation:FlxSprite = new FlxSprite(posiotnoining[0], posiotnoining[1]);
				triangleation.loadGraphic(Paths.occurPath("errorlessbg/triangeleslikeflumbose", IMAGES));
				bgs.add(triangleation);
				triangleation.shader = testshader.shader;

				var donuts:FlxSprite = new FlxSprite(posiotnoining[0], posiotnoining[1]);
				donuts.loadGraphic(Paths.occurPath("errorlessbg/blurrydonuts", IMAGES));
				bgs.add(donuts);
				donuts.shader = testshader.shader;

				var chainswithdonutsyum:FlxSprite = new FlxSprite(posiotnoining[0], posiotnoining[1]);
				chainswithdonutsyum.loadGraphic(Paths.occurPath("errorlessbg/chainanddocnuts", IMAGES));
				bgs.add(chainswithdonutsyum);
				chainswithdonutsyum.shader = testshader.shader;
				canPause = false;

				var ease = FlxEase.quartInOut;
				FlxTween.num(0.02, 0.3, 172.8, {ease: ease}, function(v:Float)
				{
					for (bgthing in bgs)
					{
						cast(bgthing.shader, Shaders.GlitchShader).uWaveAmplitude.value[0] = v;
					}
				});
				FlxTween.num(1, 3, 172.8, {ease: ease}, function(v:Float)
				{
					for (bgthing in bgs)
					{
						cast(bgthing.shader, Shaders.GlitchShader).uFrequency.value[0] = v;
					}
				});
				FlxTween.num(1, 2.5, 172.8, {ease: ease}, function(v:Float)
				{
					for (bgthing in bgs)
					{
						cast(bgthing.shader, Shaders.GlitchShader).uSpeed.value[0] = v;
					}
				});

			case 'baseplate':
				var bg:FlxSprite = new FlxSprite(-400, -200);
				bg.loadGraphic(Paths.occurPath("baseplate", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'redacted':
				var bg:FlxSprite = new FlxSprite(-600, -350);
				bg.loadGraphic(Paths.occurPath("redactedbgs/redactedbg", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.15;
				testshader.waveFrequency = 4;
				testshader.waveSpeed = 3;
				bg.shader = testshader.shader;
				songHasShaders = true;

			case 'heheheha':
				var bg:FlxSprite = new FlxSprite(-500, -50);
				bg.loadGraphic(Paths.occurPath("heheheha", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 4;
				testshader.waveSpeed = 2.8;
				bg.shader = testshader.shader;
			case 'amogusPopit':
				var bg:FlxSprite = new FlxSprite(-1000, -290);
				bg.loadGraphic(Paths.occurPath("amogusPopit", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.15, 1.15);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
			case 'shadowCubes':
				var bg:FlxSprite = new FlxSprite(-900, -375);
				bg.scrollFactor.set(0.9, 0.9);
				bg.loadGraphic(Paths.occurPath("shadowyfigure", IMAGES));
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
			case 'cosmic':
				var bg:FlxSprite = new FlxSprite(-1100, -375);
				bg.loadGraphic(Paths.occurPath("redcosmo", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.6, 1.6);
				if (!preloadingStuff)
					bgs.add(bg);

				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
			case 'finalCosmic':
				var bg:FlxSprite = new FlxSprite(-960, -375);
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.6, 1.6);
				bg.loadGraphic(Paths.occurPath("darkcosmo", IMAGES));
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
			case 'daPizza':
				var bg = new FlxSprite(-800, -300);
				bg.loadGraphic(Paths.occurPath("pizzas", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
			case 'daPizzaOld':
				var bg = new FlxSprite(-800, -300);
				bg.loadGraphic(Paths.occurPath("pizzasOld", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;

			case 'bambiCoolCorn':
				var bg = new FlxSprite(-200, -200);
				bg.loadGraphic(Paths.occurPath("bambi_cool_cornfield", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.2, 1.2);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'realfarm':
				var bg = new FlxSprite(-200, -210);
				bg.loadGraphic(Paths.occurPath("the_very_real_farm", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bg.scale.set(1.2, 1.2);
				if (!preloadingStuff)
					bgs.add(bg);
			case 'wildWest':
				var bg = new FlxSprite(-800, -300);
				bg.loadGraphic(Paths.occurPath("wildwest_bg", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				if (!preloadingStuff)
					bgs.add(bg);
				testshader.waveAmplitude = 0.2;
				testshader.waveFrequency = 3;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
			case 'triangles':
				var bg = new FlxSprite(-950, -400);
				bg.loadGraphic(Paths.occurPath("icytriangles", IMAGES));
				bg.scrollFactor.set(0.9, 0.9);
				bgs.add(bg);
				triangle = new FlxSprite();
				triangle.frames = Paths.occurSparrow("flumboTriangle");
				triangle.animation.addByPrefix("spin", "speen", 5);
				triangle.animation.play("spin");
				triangle.scrollFactor.set(0.9, 0.9);
				triangle.screenCenter();
				triangle.x -= 345;
				triangle.y -= 90;
				add(triangle);
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 4;
				testshader.waveSpeed = 1.5;
				bg.shader = testshader.shader;
		}
		var bgColour = getBackgroundColor(curStage);
		for (bg in bgs)
		{
			if (bgColour != 0xffffffff)
				bg.color = bgColour;

			bg.antialiasing = ClientPrefs.globalAntialiasing;
			bg.shader = if (ClientPrefs.wavyBGs && (!preloadingStuff)) bg.shader else null;
		}
		if (bgColour != 0xffffffff)
		{
			characterColor = bgColour;
			dad.color = characterColor;
			gf.color = characterColor;
			boyfriend.color = characterColor;
		}
		testshader = null;
		if (songHasShaders && !ClientPrefs.shaders)
			songHasShaders = false;
	}

	function debugCharMove()
	{
		#if debug
		if (FlxG.keys.justPressed.J)
		{
			if (FlxG.keys.pressed.SHIFT)
				dadGroup.x -= 5;
			else if (FlxG.keys.pressed.CONTROL)
				gfGroup.x -= 5;
			else
				boyfriendGroup.x -= 5;
		}
		if (FlxG.keys.justPressed.K)
		{
			if (FlxG.keys.pressed.SHIFT)
				dadGroup.y += 5;
			else if (FlxG.keys.pressed.CONTROL)
				gfGroup.y += 5;
			else
				boyfriendGroup.y += 5;
		}
		if (FlxG.keys.justPressed.I)
		{
			if (FlxG.keys.pressed.SHIFT)
				dadGroup.y -= 5;
			else if (FlxG.keys.pressed.CONTROL)
				gfGroup.y -= 5;
			else
				boyfriendGroup.y -= 5;
		}
		if (FlxG.keys.justPressed.L)
		{
			if (FlxG.keys.pressed.SHIFT)
				dadGroup.x += 5;
			else if (FlxG.keys.pressed.CONTROL)
				gfGroup.x += 5;
			else
				boyfriendGroup.x += 5;
		}
		if (FlxG.keys.justPressed.O)
			trace("dadGroup: " + dadGroup.x + " - " + dadGroup.y + "\ngfGroup: " + gfGroup.x + " - " + gfGroup.y + "\nboyfriendGroup: " + boyfriendGroup.x
				+ " - " + boyfriendGroup.y);
		#end
	}

	override public function update(elapsed:Float)
	{
		if (!endingSong && (Conductor.songPosition - extraPart) >= FlxG.sound.music.length && !startingSong)
			endSong(); // kstr having problems
		elapsedtime += elapsed;
		dad.float(elapsedtime);
		boyfriend.float(elapsedtime);
		if (altCharInfo.exists)
		{
			altChar.float(elapsedtime);
			altChar2.float(elapsedtime);
		}
		if (bgs.members[0] != null && bgs.members[0].shader != null)
		{
			shad = cast(bgs.members[0].shader);
			shad.uTime.value[0] += elapsed;
		}
		if (SONG.song.toLowerCase() == "occurathon")
		{
			if (bgs.members[0].shader == null && curStage == "triangles") // occurathon is being super screwed
			{
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 4;
				testshader.waveSpeed = 1.5;
				bgs.members[0].shader = testshader.shader;
			}
		}
		#if debug
		debugCharMove();
		#end
		if (songHasShaders)
		{
			screenshader.Enabled = shaderOn;
			if (screenshader.Enabled)
				FlxG.camera.shake(0.01, 0.33);
			dialogueshader.Enabled = inCutscene && forceShadersOn;
			if (dialogueshader.Enabled)
				camHUD.shake(0.01, 0.33);
			screenshader.update(elapsed);
			dialogueshader.update(elapsed);
		}

		if (!inCutscene)
		{
			lerpValCamera = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpValCamera), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpValCamera));
		}
		super.update(elapsed);
		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.8)), Std.int(FlxMath.lerp(150, iconP1.height, 0.8)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.8)), Std.int(FlxMath.lerp(150, iconP2.height, 0.8)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		if (altCharInfo.exists)
		{
			iconAlt.setGraphicSize(Std.int(FlxMath.lerp(150, iconAlt.width, 0.8)), Std.int(FlxMath.lerp(150, iconAlt.height, 0.8)));
			iconAlt.updateHitbox();
			iconAlt2.setGraphicSize(Std.int(FlxMath.lerp(150, iconAlt2.width, 0.8)), Std.int(FlxMath.lerp(150, iconAlt2.height, 0.8)));
			iconAlt2.updateHitbox();
		}
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
				if (updateTime)
				{
					songPercent = (Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset) / songLength);
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					var songCalc:Float = Math.max(songLength - curTime, 0);
					if (ClientPrefs.timeBarType == 'Time Elapsed' || ClientPrefs.timeBarType == "Whole Time")
						songCalc = curTime;

					timeTxt.text = formatTime(Math.floor(songCalc / 1000));
					if (ClientPrefs.timeBarType == "Whole Time")
						timeTxt.text += " / " + formatTime(songLength / 1000);
				}
			}
			Conductor.lastSongPos = FlxG.sound.music.time + extraPart;
		}
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		if (unspawnNotes.length > 0)
		{
			if (Math.abs(unspawnNotes[0].strumTime - Conductor.songPosition) < 2350)
			{
				unspawnNotes[0].active = true;
				unspawnNotes[0].visible = true;
				notes.insert(0, unspawnNotes[0]);
				unspawnNotes.remove(unspawnNotes[0]);
			}
		}
		if (generatedMusic)
		{
			if (ClientPrefs.modcharts)
			{
				if (SONG.song.toLowerCase() == "ultramarathon")
				{
					opponentStrums.forEachAlive(function(spr:StrumNote)
					{
						spr.x += Math.sin(elapsedtime * (1 + ((spr.ID + 1) / 10))) * 0.0525;
						spr.y += Math.cos(elapsedtime * (1 + ((spr.ID + 1) / 10))) * 0.0525;
					});
					playerStrums.forEachAlive(function(spr:StrumNote)
					{
						spr.x += Math.sin(elapsedtime * (1 + ((spr.ID + 1) / 10))) * 0.0525;
						spr.y += Math.cos(elapsedtime * (1 + ((spr.ID + 1) / 10))) * 0.0525;
					});
				}
			}
			if (SONG.song.toLowerCase() == "[redacted]") // i think redacted the only one lol forced sooo
			{
				opponentStrums.forEachAlive(function(spr:StrumNote)
				{
					spr.y += (Math.sin(elapsedtime * Math.floor((((spr.ID + if (spr.ID == 0) 0.785 else 0) + 1.36) / 1.656)) * 2.357) * (0.2713
						+ (spr.ID + if (spr.ID == 0) 0.7785 else 0)) * ((spr.downScroll) ? -0.92 : 1.1));
				});
				playerStrums.forEachAlive(function(spr:StrumNote)
				{
					spr.y += (Math.sin(elapsedtime * Math.floor((((spr.ID + if (spr.ID == 0) 0.8971 else if (spr.ID == 1) 1.23 else 0)
						+ 1.34) / 1.756)) * 2.457) * (0.2613
							+ (spr.ID + if (spr.ID == 0) 0.8971 else if (spr.ID == 1) 1.23 else 0)) * ((spr.downScroll) ? -0.92 : 1.1));
				});
			}
			notes.forEachAlive(function(daNote:Note)
			{
				var strumNum = strumLineNotes.members[daNote.myStrum].thisStrumIs;
				var strumX = strumLineNotes.members[strumNum].x + daNote.offsetX;
				var strumY = strumLineNotes.members[strumNum].y + daNote.offsetY;
				var strumDir = strumLineNotes.members[strumNum].direction;
				var strumAng = strumLineNotes.members[strumNum].angle;

				daNote.distance = ((strumLineNotes.members[strumNum].downScroll ? 0.45 : -0.45) * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
				daNote.flipX = strumLineNotes.members[strumNum].flipX;
				daNote.flipY = if (ClientPrefs.downScroll && daNote.isSustainNote) !strumLineNotes.members[strumNum].flipY else
					strumLineNotes.members[strumNum].flipY;
				daNote.angle = strumDir - 90 + strumAng + daNote.offsetAngle;
				daNote.x = strumX + (Math.cos(strumDir * Math.PI / 180) * daNote.distance);
				daNote.y = strumY + (Math.sin(strumDir * Math.PI / 180) * daNote.distance);

				if (strumLineNotes.members[strumNum].downScroll && daNote.isSustainNote)
				{
					if (daNote.animation.curAnim.name.endsWith('end'))
					{
						daNote.y += 10.5 * (((60 / SONG.bpm) * 1000) / 400) * 1.5 * daNote.scrollSpeed + (46 * (daNote.scrollSpeed - 1));
						daNote.y -= 46 * (1 - ((60 / SONG.bpm) * 1000) / 600) * daNote.scrollSpeed;

						daNote.y -= 19;
					}
					daNote.y += (Note.swagWidth / 2) - (60.5 * (daNote.scrollSpeed - 1));
					daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (daNote.scrollSpeed - 1);
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if (!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit)
				{
					if (daNote.isSustainNote)
					{
						if (daNote.canBeHit)
						{
							goodNoteHit(daNote);
						}
					}
					else if (daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote)
					{
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if (daNote.isSustainNote
					&& (daNote.mustPress || !daNote.ignoreNote)
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumLineNotes.members[strumNum].downScroll)
					{
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							daNote.clipRect = new FlxRect(0, daNote.frameHeight - ((center - daNote.y) / daNote.scale.y), daNote.frameWidth,
								(center - daNote.y) / daNote.scale.y);
							return;
						}
					}

					if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						daNote.clipRect = new FlxRect(0, (center - daNote.y) / daNote.scale.y, daNote.width / daNote.scale.x,
							(daNote.height / daNote.scale.y) - ((center - daNote.y) / daNote.scale.y));
				}
				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > 350 / daNote.scrollSpeed + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();
		if (!inCutscene)
		{
			if (!cpuControlled && (keysPressed.contains(true) || ClientPrefs.controllerMode))
			{
				keyShit();
			}
			handleAnimationsIdle();
		}
		if (expungedIsFlying && windowExpunged != null)
			transferSpriteToWindow();
	}

	function refreshCreditText(add:String = "")
	{
		textSong.text = ((ClientPrefs.downScroll) ? "\n\n" : "") + 'By $songMaker\n' + songName;
		textSong.text += '\n${credits + add}';
		textSong.text += '\n';
	}

	function jumpScareLikeFNAFreal()
	{
		var cosmicJumpscare = new FlxSprite();
		cosmicJumpscare.frames = jumpscareFrames;
		cosmicJumpscare.animation.addByPrefix("jumpscare", "cosmic jumpscare jumpscare", 24, false);
		cosmicJumpscare.cameras = [camOther];
		cosmicJumpscare.updateHitbox();
		add(cosmicJumpscare);
		cosmicJumpscare.screenCenter();
		cosmicJumpscare.animation.play("jumpscare");
		FlxG.camera.shake(0.025, 1);
		camHUD.shake(0.025, 1);
		cosmicJumpscare.animation.finishCallback = function(_)
		{
			remove(cosmicJumpscare, true);
			cosmicJumpscare.destroy();
			cosmicJumpscare = null;
			jumpscareFrames = null;
			if (ClientPrefs.gcSection) // bruh
				System.gc();
		};
	}

	static var cheater = false;

	var precacheList:Map<String, String> = new Map<String, String>();

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			for (note in notes)
			{
				note.scrollSpeed = value;
			}
			for (note in unspawnNotes)
			{
				note.scrollSpeed = value;
			}
		}
		songSpeed = value;
		return value;
	}

	public function reloadHealthBarColors()
	{
		if (!ClientPrefs.ogHpBar)
		{
			if (!iconP1.isOldIcon)
				healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
					FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			else
				healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), 0xffe9ff48);
		}
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateBar();
		if (ClientPrefs.timeColorBar)
		{
			var fill = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
			fill.brightness = 0.85;
			timeBar.createFilledBar(0xFF000000, fill);
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if (!gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
			case 3:
				if (!altCharMap.exists(newCharacter) && altCharInfo.exists)
				{
					var newAltChar:Character = new Character(0, 0, newCharacter, altCharInfo.withPlayer, true);
					newAltChar.scrollFactor.set(0.95, 0.95);
					altCharMap.set(newCharacter, newAltChar);
					altCharGroup.add(newAltChar);
					startCharacterPos(newAltChar);
					newAltChar.alpha = 0.00001;
				}
			case 4:
				if (!altChar2Map.exists(newCharacter) && altCharInfo.exists)
				{
					var newAltChar:Character = new Character(0, 0, newCharacter, false, true);
					newAltChar.scrollFactor.set(0.95, 0.95);
					altChar2Map.set(newCharacter, newAltChar);
					altChar2Group.add(newAltChar);
					startCharacterPos(newAltChar);
					newAltChar.alpha = 0.00001;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	#if VIDEOS_ALLOWED
	public function startVideo(name:String):Void
	{
		var foundFile:Bool = false;
		var fileName:String = '';

		if (!foundFile)
		{
			fileName = Paths.video(name);
			#if sys
			if (FileSystem.exists(fileName))
			{
				foundFile = true;
			}
			if (foundFile)
			{
				inCutscene = true;
				var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				bg.scrollFactor.set();
				bg.cameras = [camHUD];
				add(bg);

				(new FlxVideo(fileName)).finishCallback = function()
				{
					remove(bg, true);
					startAndEnd();
				}
				return;
			}
			else
			{
				FlxG.log.warn('Couldnt find video file: ' + fileName);
				startAndEnd();
			}
			#end
			startAndEnd();
		}
	}
	#end

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, song:String = "homeBop"):Void
	{
		if (psychDialogue != null)
			return;

		if (dialogueFile == null)
		{
			startAndEnd();
			return;
		}

		if (dialogueFile.dialogue.length > 0)
		{
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();

			psychDialogue.finishThing = function()
			{
				psychDialogue = null;
				startAndEnd();
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
			FlxG.sound.playMusic(Paths.music(song), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public function startCountdown():Void
	{
		laneunderlay.visible = true;
		laneunderlayOpponent.visible = true;
		var colorBox = "000000";
		var textSize = 23;
		switch (SONG.song.toLowerCase())
		{
			case "wilderness":
				colorBox = "441b00";
			case "wheelchair" | "gate" | "wheelchair-old":
				colorBox = "0f6fff";
			case "cubic" | "cubic-old":
				colorBox = "0000aa";
			case "snacker" | "snacker-eduardo" | "snacker-eduardo-old" | "snacker-eduardo-older" | "snacker-old" | "snacker-older":
				colorBox = "FF9300";
			case 'console':
				colorBox = "5eea54";
			case "poppin" | "poppin-old" | "poppin-older" | "poppin-oldest":
				colorBox = "FF000f";
			case "phase" | "demise":
				colorBox = "a60017";
			case "heheheha":
				colorBox = "FFFFFF";
			case "real-corn" | "phones-old" | "breaking-madness" | "alien-language":
				colorBox = "00FF00";
			case "phones":
				colorBox = "00cc33";
			case "[redacted]":
				colorBox = "2c0704";
			case "brick":
				colorBox = "afafaf";
			case "magicians-work":
				colorBox = "ff2d32";
			case "fury":
				colorBox = "e30101";
			case "ultramarathon":
				colorBox = "0f5fff";
				textSize = 18;
			case "that-guy":
				colorBox = "b58550";
			case "shucked" | "short-stalk" | "short-stalk-old":
				colorBox = "0cb500";
			case "pebble":
				colorBox = "5a6f7a";
			case "icicles" | "triangles" | "occurathon":
				colorBox = "d1ffff";
			case "errorless":
				colorBox = "470000";
			case "bambino":
				colorBox = "bb0000";
		}

		var box = new FlxSprite(0, 200).makeGraphic(450, 110, FlxColor.fromString("0x99" + colorBox));
		add(box);
		box.cameras = [camOther];
		var text = new FlxText(50, 225, box.width - 50, '${SONG.song}\nComposer(s): $songMaker');
		text.setFormat(Paths.font("comic.ttf"), textSize, if (Std.int((FlxColor.fromString("0xff" + colorBox))) > -250000) FlxColor.BLACK else FlxColor.WHITE);
		add(text); // dnb occ made
		text.cameras = [camOther];
		FlxTween.tween(box, {x: -600}, (SONG.bpm / 60), {
			ease: FlxEase.circInOut,
			onComplete: function bye(pee:FlxTween)
			{
				remove(box, true);
				box.destroy();
				box = null;
			}
		});
		FlxTween.tween(text, {x: -600}, (SONG.bpm / 60), {
			ease: FlxEase.circInOut,
			onComplete: function bye(pee:FlxTween)
			{
				remove(text, true);
				text.destroy();
				text = null;
			}
		});
		if (startedCountdown)
		{
			return;
		}
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;
		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);
		var swagCounter:Int = 0;

		if (skipCountdown)
		{
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet;
			swagCounter = 3;
		}
		var suffix = "_" + FlxG.random.getObject(["bambi", "dave"]);
		var threedsuffix = "";
		if ((boisThatAre3D.contains(boyfriend.curCharacter) || boisThatAre3D.contains(dad.curCharacter))
			&& (FlxG.random.bool(50) || boisThatAre3D.contains(boyfriend.curCharacter) && boisThatAre3D.contains(dad.curCharacter)))
			threedsuffix = "3d";
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned)
			{
				gf.tryIdle(true);
			}
			dad.tryIdle(tmr.loopsLeft % 2 == 0);
			boyfriend.tryIdle(tmr.loopsLeft % 2 == 0);
			if (altCharInfo.exists)
			{
				altChar.tryIdle(tmr.loopsLeft % 2 == 0);
				altChar2.tryIdle(tmr.loopsLeft % 2 == 0);
			}
			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + suffix), 0.6);
				case 1:
					var countdownReady = new FlxSprite().loadGraphic(Paths.image('ready' + threedsuffix));
					countdownReady.scrollFactor.set();
					countdownReady.updateHitbox();

					countdownReady.screenCenter();
					countdownReady.antialiasing = ClientPrefs.globalAntialiasing;
					add(countdownReady);
					FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownReady, true);
							countdownReady.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + suffix), 0.6);
				case 2:
					var countdownSet = new FlxSprite().loadGraphic(Paths.image('set' + threedsuffix));
					countdownSet.scrollFactor.set();

					countdownSet.screenCenter();
					countdownSet.antialiasing = ClientPrefs.globalAntialiasing;
					add(countdownSet);
					FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownSet, true);
							countdownSet.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + suffix), 0.6);
				case 3:
					if (!skipCountdown)
					{
						var countdownGo = new FlxSprite().loadGraphic(Paths.image('go' + threedsuffix));
						countdownGo.scrollFactor.set();

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = ClientPrefs.globalAntialiasing;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo, true);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + suffix), 0.6);
					}
				case 4:
					tmr.destroy();
			}
			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	function startNextDialogue()
	{
		dialogueCount++;
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song, curPart), ClientPrefs.instVol, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if (paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		if (timeTxt != null)
		{
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}
		if (SONG.song.toLowerCase() == "ultramarathon")
		{
			songLength = 3663000;
			moreThanOnePart = true;
			extraPart = 0;
			curPart = 0;
			maxParts = 2;
		}
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength,
			'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
		#end
	}

	var note3D2DThingHelp = FlxG.random.int(5, 6);

	private function generateSong(dataPath:String):Void
	{
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, curPart));
		else
		{
			vocals = new FlxSound();
			vocals.active = false;
		}
		vocals.volume = ClientPrefs.vocalsVol;
		vocals.looped = false;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song, curPart)));
		FlxG.sound.list.members[FlxG.sound.list.length - 1].volume = ClientPrefs.instVol;

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');

		if (FileSystem.exists(file))
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					if (subEvent.event.toLowerCase() == "cosmic eye") // use this to skip a summon timer var
					{
						subEvent.strumTime += FlxG.random.float(newEventNote[2], newEventNote[3]) * 1000;
					}
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}
		else if (!FileSystem.exists(file) || chartingMode)
		{
			for (event in songData.events) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];

					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		var lastDadSwap = dad.curCharacter.toLowerCase();
		var lastEventStrum = 0.0;
		var coolEvents = eventNotes.copy();
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				if (coolEvents.length > 0 && daStrumTime > coolEvents[0].strumTime)
				{
					lastEventStrum = coolEvents[0].strumTime;
					if (coolEvents[0].event.toLowerCase() == "change character"
						&& (coolEvents[0].value1.toLowerCase() == 'dad'
							|| coolEvents[0].value1.toLowerCase() == 'opponent'
							|| coolEvents[0].value1 == '0')
						&& dadMap.exists(coolEvents[0].value2))
					{
						lastDadSwap = coolEvents[0].value2;
					}
					coolEvents.remove(coolEvents[0]);
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.myStrum = daNoteData + (gottaHitNote ? 4 : 0);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.altCharNote = (section.altCharSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]];
				swagNote.scrollFactor.set();
				swagNote.active = false;
				swagNote.visible = false;
				var susLength:Float = swagNote.sustainLength;
				var char:String = lastDadSwap.toLowerCase();
				if (gottaHitNote)
					char = boyfriend.curCharacter.toLowerCase();

				swagNote.setNoteTexture3D2D(true, true, boisThatAre3D.contains(char));

				swagNote.noteSplashDisabled = !ClientPrefs.noteSplashes;
				var threednotestextureflicker = !(boisThatAre3D.contains(boyfriend.curCharacter.toLowerCase())
					|| ClientPrefs.note3Dwhen == "3D")
					&& (boisThatAre3D.contains(lastDadSwap.toLowerCase()) && ClientPrefs.note3Dwhen != "2D")
					&& ClientPrefs.note3D2Dtransform
					&& gottaHitNote
					&& ((swagNote.strumTime / 50) % 20 > 15);
				if (threednotestextureflicker)
					swagNote.setNoteTexture3D2D(true, true, true);

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(swagNote.scrollSpeed, 2)),
							daNoteData, oldNote, true);

						//	trace(sustainNote.strumTime);
						sustainNote.myStrum = daNoteData + (gottaHitNote ? 4 : 0);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.altCharNote = swagNote.altCharNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.setNoteTexture3D2D(true, true, boisThatAre3D.contains(char));
						sustainNote.active = false;
						sustainNote.visible = false;
						unspawnNotes.push(sustainNote);

						if (threednotestextureflicker)
							sustainNote.setNoteTexture3D2D(true, true, true);

						sustainNote.hitHealth = swagNote.hitHealth;
						sustainNote.missHealth = swagNote.missHealth;
						sustainNote.antialiasing = swagNote.antialiasing;
						sustainNote.noteSplashDisabled = swagNote.noteSplashDisabled;
					}
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	var xboxachievements = ["soapcat", "amogus", "bnabi", "fitnesstest"];
	var xboximages:Map<String, FlxAtlasFrames> = [];

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'alt2' | 'alt char2' | '3':
						charType = 4;
					case 'alt' | 'alt char' | '2':
						charType = 3;
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}
				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			case "Xbox Achievement":
				if (xboxachievements.length == 0)
					xboxachievements = ["soapcat", "amogus", "bnabi", "fitnesstest"]; // so we actually have enough
				var achievement = FlxG.random.getObject(xboxachievements);
				xboxachievements.remove(achievement);
				eventNotes[eventNotes.length - 1].value1 = achievement;
				if (!xboximages.exists(achievement))
					xboximages.set(achievement, Paths.occurSparrow("console/" + achievement + "achievement"));
			case "Make BG":
				makeBG(event.value1, true);
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = ClientPrefs.noteStrumAlpha;
			if (player == 0 && ClientPrefs.middleScroll)
				targetAlpha = 0.35 * ClientPrefs.noteStrumAlpha;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {
				ease: FlxEase.circOut,
				startDelay: 0.5 + (0.2 * i)
			});
			babyArrow.thisStrumIs = i;

			babyArrow.y += Note.swagWidth * 0.225;
			var isDad = player == 0;
			var funniChar = isDad ? dad : boyfriend;
			if ((boisThatAre3D.contains(funniChar.curCharacter.toLowerCase()) && ClientPrefs.note3Dwhen != "2D")
				|| ClientPrefs.note3Dwhen == "3D")
				babyArrow.texture = "NOTE_assets_3D";
			if (player == 1)
			{
				babyArrow.thisStrumIs += 4;
				playerStrums.add(babyArrow);
			}
			else
			{
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if (i > 1)
					{ // Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}
			switch (SONG.song.toLowerCase()) // some songs are forced :troll:
			{
				case '[redacted]':
					babyArrow.y += (ClientPrefs.downScroll) ? -100 : 100;
			}
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;
			if (cosmicStatic != null)
			{
				cosmicStatic.pause();
				cosmicEyeTimerD.active = false;
			}
			if (barTimer != null)
			{
				barTimer.active = false;
			}
		}
		if (FlxG.sound.music != null && FlxG.sound.music.playing) // bruj & me having some issues with it not pausing so yea
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;
			@:privateAccess
			if (cosmicStatic != null && cosmicStatic._paused)
			{
				cosmicEyeTimerD.active = true;
				cosmicStatic.play();
			}
			paused = false;
			if (barTimer != null)
			{
				barTimer.active = true;
			}
			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset,
					'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), null, null,
					'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
			}
			#end
		}
		if (FlxG.sound.music != null && !FlxG.sound.music.playing && !startingSong) // idk just in case
		{
			FlxG.sound.music.play();
			vocals.play();
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset,
					'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), null, null,
					'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
			}
		}
		#end
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + extraPart;
		vocals.time = FlxG.sound.music.time;
		if (songTime > 1000 && vocals.time < 1000)
			return; // ??? fix???
		vocals.play();
	}

	function updateScoreText()
	{
		scoreTxt.text = "NPS: " + Math.floor(notesHitArray.length / 2);
		if (SONG.song.toLowerCase() == "[redacted]")
		{
			scoreTxt.text = "[DATA_UNAVAILABLE]";
			return;
		}
		if (!cpuControlled)
		{
			if (ratingName == "?")
				scoreTxt.text += ' | Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
			else
				scoreTxt.text += ' | Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' ('
					+ Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;

			if (practiceMode)
				scoreTxt.text += " | Practice Mode";
		}
		else
		{
			scoreTxt.text += " | Cheater! | Botplay";
		}
		scoreTxt.size = Std.int(CoolUtil.boundTo(32 / (scoreTxt.text.length / 45), 15, 24));

		#if desktop // sorry about this but best way i could think of
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength,
			'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
		#end
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var triangleInFront = false;
	var prevTriangleFlip = 0.0;

	@:allow(Character)
	function flipTriangleDadIndex(a)
	{
		if (prevTriangleFlip == a)
			return;
		remove(triangle, true);
		if (!triangleInFront)
			insert(4, triangle);
		else
			insert(2, triangle);
		triangleInFront = !triangleInFront;
		prevTriangleFlip = a;
	}

	var shad:Dynamic;

	var lerpValCamera:Float;

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; // Don't mess with this on Lua!!! -- no u lmao

	function doDeathCheck()
	{
		if (!practiceMode && !isDead && !cpuControlled)
		{
			boyfriend.stunned = true;
			deathCounter++;
			#if windows
			if (windowExpunged != null)
			{
				expungedIsFlying = false;
				windowExpunged.close();
				// x,y, width, height
				FlxTween.tween(Application.current.window, {
					x: windowProperties[0],
					y: windowProperties[1],
					width: windowProperties[2],
					height: windowProperties[3]
				}, 1, {ease: FlxEase.circInOut});
			}
			#end
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			persistentUpdate = false;
			persistentDraw = false;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0],
				boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

			// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), null, null,
				'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
			#end
			isDead = true;
			return true;
		}
		return false;
	}

	public function checkEventNote()
	{
		if (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				return;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	var swearingRn = false;

	var barTimer:FlxTimer;

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName) // gonna add more modcharty stuff!! (yippe)
		{
			case "firebars": // ignore this
				var size = 180;
				var time = Std.parseFloat(value1);
				var topfirebar = new FlxSprite(0, -size).makeGraphic(FlxG.width, size, 0xff000000);
				var bottomfirebar = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, size, 0xff000000);
				add(topfirebar);
				add(bottomfirebar);
				topfirebar.cameras = [camOther];
				bottomfirebar.cameras = [camOther];
				FlxTween.tween(topfirebar, {y: 0}, 0.3, {
					ease: FlxEase.circIn,
					onComplete: function(_)
					{
						barTimer = new FlxTimer().start(time - 0.6, function(a) // optimized for one var!
						{
							FlxTween.tween(topfirebar, {y: -size}, 0.3, {
								ease: FlxEase.circOut,
								onComplete: function(_)
								{
									remove(topfirebar, true);
									topfirebar.destroy();
									topfirebar = null;
								}
							});
							FlxTween.tween(bottomfirebar, {y: FlxG.height}, 0.3, {
								ease: FlxEase.circOut,
								onComplete: function(_)
								{
									remove(bottomfirebar, true);
									bottomfirebar.destroy();
									bottomfirebar = null;
								}
							});
						});
						if (paused)
						{
							barTimer.active = false;
						}
					}
				});
				FlxTween.tween(bottomfirebar, {y: FlxG.height - size}, 0.3, {
					ease: FlxEase.circIn
				});
			case "moveChar": // for occurathon!!1
				var char:Dynamic = dadGroup;
				switch (value1)
				{
					case "i":
						char = altCharGroup;
					case "hi":
						char = altChar2Group;
					case "bye":
						char = boyfriendGroup;
				}
				char.setPosition(Std.parseInt(value2.split(",")[0].trim()), Std.parseInt(value2.split(",")[1].trim()));
			case "Swap scroll":
				var cancelTweens = Std.parseInt(value1) == 1;
				var downscroll = strumLineNotes.members[0].downScroll;
				var newy = STRUM_Y_DOWNSCROLL;
				if (downscroll)
					newy = STRUM_Y;
				strumLine.y = newy;
				for (strum in 0...strumLineNotes.members.length)
				{
					if (cancelTweens)
					{
						FlxTween.completeTweensOf(strumLineNotes.members[strum]);
					}
					strumLineNotes.members[strum].downScroll = !downscroll;
					strumLineNotes.members[strum].angle = 0;
					FlxTween.angle(strumLineNotes.members[strum], strumLineNotes.members[strum].angle, strumLineNotes.members[strum].angle + 360, 0.4,
						{ease: FlxEase.expoOut});
					FlxTween.tween(strumLineNotes.members[strum], {y: strumLine.y}, 0.6, {ease: FlxEase.backOut});
				}
			case "swap strum side":
			case "multiply screen":
				SystemUtils.multiplyScreen();
			case "clone expunged window":
			// SystemUtils.cloneWindow(Std.parseInt(value1), Std.parseInt(value2));
			// doesnt clone transparency (not a suprise when i think about it tho)
			case "invert screen temp":
				if (ClientPrefs.flashing) // doesnt do as much as expected :/
					SystemUtils.invertScreenColor();
			case "Change Default Zoom":
				if (value1 == "" || Math.isNaN(Std.parseFloat(value1)))
					defaultCamZoom = stageData.defaultZoom;
				defaultCamZoom = Std.parseFloat(value1);
			case "Change Credits":
				refreshCreditText(value1.trim());
			case "Swear Vocal Toggle hehehehheha":
				if (!ClientPrefs.swearing)
				{
					vocals.volume = (vocals.volume == 0) ? ClientPrefs.vocalsVol : 0;
					swearingRn = !swearingRn;
				}
			case "Swap Strums":
				var backup = strumLineNotes.members[Std.parseInt(value1)].thisStrumIs; // when override this stays
				strumLineNotes.members[Std.parseInt(value1)].thisStrumIs = strumLineNotes.members[Std.parseInt(value2)].thisStrumIs;
				strumLineNotes.members[Std.parseInt(value2)].thisStrumIs = backup;
			case "Set Property":
				Reflect.setProperty(this, value1, value2); // idk if works lol too lazy to check
			case "expunged de-exists from the main window":
				if (SONG.song.toLowerCase() == "errorless")
					popupWindow();
			case "Make BG":
				makeBG(value1);
				curStage = value1;
				if (triangle != null)
				{
					remove(triangle, true);
					triangle.destroy();
					triangle = null;
					Paths.clearUnusedMemory();
				}
			case "Xbox Achievement":
				var thej = new FlxSprite();
				thej.frames = xboximages.get(value1);
				thej.screenCenter();
				thej.cameras = [camHUD];
				thej.animation.addByPrefix("xbox", value1, 24, false);
				thej.animation.play("xbox");
				thej.animation.finishCallback = function(_)
				{
					remove(thej, true);
					thej.animation.stop();
					thej.kill(); // destroying bad (grrr)
					thej = null;
				}
				add(thej);
			case 'Cosmic Eye':
				shownUpEye--;
				if (cosmicEye == null || cpuControlled)
					return;
				else if (shownUpEye == 0)
				{
					cosmicEye.destroy();

					cosmicEyeTimerD.destroy();
					cosmicStatic.destroy();
					return;
				}
				var val1:Int = Std.parseInt(value1);
				var val2:Int = Std.parseInt(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 1;
				keysEyePressed = 0;

				if (FlxG.save.data.cosmiceyehintAndDone == null || !FlxG.save.data.cosmiceyehintAndDone)
				{
					var murderYourSpaceBar = new FlxSprite(0, 880);
					murderYourSpaceBar.frames = Paths.occurSparrow("kill_your_spacebar");
					murderYourSpaceBar.animation.addByPrefix("spam", "AH", 24);
					murderYourSpaceBar.animation.play("spam");
					murderYourSpaceBar.cameras = [camOther];
					murderYourSpaceBar.screenCenter(X);
					add(murderYourSpaceBar);
					FlxTween.tween(murderYourSpaceBar, {y: 720 - murderYourSpaceBar.height - 8}, 0.5, {ease: FlxEase.cubeOut});
				}
				cosmicEye.visible = true;
				cosmicEye.revive();
				cosmicStatic.play(true);
				camOther.shake(0.01, 5);
				FlxTween.tween(cosmicEye, {alpha: 0.7}, 0.5, {ease: FlxEase.elasticInOut});

				cosmicEyeTimerD = new FlxTimer().start(5, function(timer:FlxTimer) // deatth
				{
					if (keysEyePressed <= 2)
						health -= 2;
					else if (keysEyePressed >= 5) // spaceBarAnim should be already gone
					{
						if (FlxG.save.data.cosmiceyehintAndDone == null || !FlxG.save.data.cosmiceyehintAndDone)
						{
							FlxG.save.data.cosmiceyehintAndDone = true;
							FlxG.save.flush();
						}
						return;
					}
					else
						health -= 1;
					killEye();
				});

			case 'Toggle Shaders':
				shaderOn = !shaderOn;
			case 'Hey!':
				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;
				boyfriend.playAnim('hey', true);
				boyfriend.specialAnim = true;
				boyfriend.heyTimer = time;
			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value))
					value = 1;
				gfSpeed = value;
			case 'Jumpscare':
				if (jumpscareFrames != null)
					jumpScareLikeFNAFreal();
			case 'Add Camera Zoom':
				if (camZooming)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case "alt":
						char = altChar;
					case "alt2":
						char = altChar2;
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;
				camFollow.x += val1;
				camFollow.y += val2;

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;
					targetsArray[i].shake(intensity, duration);
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1.toLowerCase())
				{
					case 'alt2' | 'alt char2' | '3':
						charType = 4;
					case 'alt' | 'alt char' | '2':
						charType = 3;
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0: // you shouldn't ever be 2d then go into 3d and vice versa
						if (boyfriend.curCharacter != value2.replace("-player", ""))
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf)
								{
									gf.visible = true;
								}
							}
							else
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
							if (boisThatAre3D.contains(dad.curCharacter.toLowerCase())
								&& opponentStrums.members[0].texture != "NOTE_assets_3D")
							{
								for (strum in opponentStrums)
									strum.texture = "NOTE_assets_3D";
							}
							else if (!boisThatAre3D.contains(dad.curCharacter.toLowerCase())
								&& opponentStrums.members[0].texture == "NOTE_assets_3D")
							{
								for (strum in opponentStrums)
									strum.texture = "NOTE_assets";
							}
						}

					case 2:
						if (gf.curCharacter != value2)
						{
							if (!gfMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = gf.alpha;
							gf.alpha = 0.00001;
							gf = gfMap.get(value2);
							gf.alpha = lastAlpha;
						}
					case 3:
						if (altCharInfo.exists && altChar.curCharacter != value2)
						{
							if (!altCharMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = altChar.alpha;
							altChar.alpha = 0.00001;
							altChar = altCharMap.get(value2);
							altChar.alpha = lastAlpha;
							iconAlt.changeIcon(altChar.healthIcon);
						}

					case 4:
						if (altCharInfo.exists && altChar2.curCharacter != value2)
						{
							if (!altChar2Map.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = altChar2.alpha;
							altChar2.alpha = 0.00001;
							altChar2 = altChar2Map.get(value2);
							altChar2.alpha = lastAlpha;
							iconAlt2.changeIcon(altChar2.healthIcon);
						}
				}
				dad.color = characterColor;
				gf.color = characterColor;
				boyfriend.color = characterColor;
				if (altCharInfo.exists)
				{
					altChar.color = characterColor;
					altChar2.color = characterColor;
				}
				health += 0.00001;
				reloadHealthBarColors();
			case "Camera Flash":
				switch (value1.toLowerCase())
				{
					case "hud" | "camhud":
						camHUD.flash(FlxColor.fromString("0xff" + value2.split(",")[0].trim()), Std.parseFloat(value2.split(",")[1].trim()));
					case "game" | "camgame":
						camGame.flash(FlxColor.fromString("0xff" + value2.split(",")[0].trim()), Std.parseFloat(value2.split(",")[1].trim()));
					case "other" | "camother":
						camOther.flash(FlxColor.fromString("0xff" + value2.split(",")[0].trim()), Std.parseFloat(value2.split(",")[1].trim()));
				}
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
	}

	function moveCameraSection(id:Null<Int> = null):Void
	{
		if (id == null)
			id = curSection;
		if (SONG.notes[id] == null)
			return;
		moveCamera(!SONG.notes[id].mustHitSection, SONG.notes[id].altCharSection);
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool, isAltChar:Bool = false)
	{
		if (!isAltChar)
		{
			if (isDad)
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0];
				camFollow.y += dad.cameraPosition[1];
				camFollow.y += dadCamFollowY;
				camFollow.x += dadCamFollowX;
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.y += camFollowY;
				camFollow.x += camFollowX;
				camFollow.x -= boyfriend.cameraPosition[0]; // what? why -=?
				camFollow.y += boyfriend.cameraPosition[1];
			}
		}
		else
		{
			camFollow.set(altChar.getMidpoint().x + (150 + (isDad ? 0 : -250)), altChar.getMidpoint().y - 100);
			camFollow.x += altChar.cameraPosition[0];
			camFollow.y += altChar.cameraPosition[1];
			if (altCharInfo.withPlayer)
			{
				camFollow.set(camFollow.x + camFollowX, camFollow.y + camFollowY);
				return;
			}
			camFollow.y += dadCamFollowY;
			camFollow.x += dadCamFollowX;
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		if (moreThanOnePart && curPart < maxParts)
		{
			curPart++;
			extraPart += FlxG.sound.music.length;
			FlxG.sound.playMusic(Paths.inst("ultramarathon", curPart), ClientPrefs.instVol, false);
			FlxG.sound.music.onComplete = finishSong;
			vocals = new FlxSound().loadEmbedded(Paths.voices("ultramarathon", curPart));
			vocals.volume = ClientPrefs.vocalsVol;
			for (sound in FlxG.sound.list)
			{
				FlxG.sound.list.remove(sound);
			}
			updateTime = true;
			FlxG.sound.list.add(vocals);
			try
			{
				FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst("ultramarathon", curPart)));
				FlxG.sound.list.members[FlxG.sound.list.length - 1].volume = ClientPrefs.instVol;
			}
			catch (e)
			{
			}
			return;
		}

		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					if (health > 0)
						health -= 0.05 * healthLoss;
				}
			}

			if (health <= 0)
			{
				return;
			}
		}
		if (timeTxt != null)
		{
			timeBarBG.visible = false;
			timeBar.visible = false;
			timeTxt.visible = false;
		}
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;
		#if windows
		if (windowExpunged != null)
		{
			expungedIsFlying = false;
			windowExpunged.close();
			// x,y, width, height
			FlxTween.tween(Application.current.window, {
				x: windowProperties[0],
				y: windowProperties[1],
				width: windowProperties[2],
				height: windowProperties[3]
			}, 1, {ease: FlxEase.circInOut});
		}
		#end
		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:String = checkForAchievement(['truegaming']);

			if (achieve != null)
			{
				startAchievement(achieve);
				return;
			}
		}
		#end

		if (SONG.validScore && !chartingMode && !cheater)
		{
			var percent:Float = ratingPercent;
			if (Math.isNaN(percent))
				percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
		}

		if (chartingMode)
		{
			openChartEditor();
			return;
		}

		if (!isFreeplay)
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}

				diffBf = ["false", "default"];
				MusicBeatState.switchState(new StoryMenuState());

				if (!cheater)
				{
					StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
					if (!chartingMode)
					{
						if (WeekData.weeksLoaded.get(WeekData.getWeekFileName()) != null
							&& WeekData.weeksLoaded.get(WeekData.getWeekFileName()).weekName == "Cosmic")
						{
							ClientPrefs.unlockCharacter("cosmic");
							ClientPrefs.unlockCharacter("cosmicnew");
						}
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
					}
					FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
				}
				changedDifficulty = false;
			}
			else
			{
				var difficulty:String = CoolUtil.getDifficultyFilePath();

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				prevCamFollow = camFollow;
				prevCamFollowPos = camFollowPos;
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				if (diffBf[0] == "true")
					PlayState.diffBf = diffBf;
				else if (diffBf[0] == "maybe")
					PlayState.diffBf = ["true", diffBf[1]];

				cancelMusicFadeTween();
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			cancelMusicFadeTween();
			if (FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;
			if (SONG.song.toLowerCase() == "heheheha" && !practiceMode)
				FreeplayState.pcOnFire = true;
			MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			changedDifficulty = false;
		}
		transitioning = true;
	}

	var achievementObj:AchievementObject = null;

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if (cheater)
			return null;

		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled)
			{
				var unlock:Bool = false;

				var songName = SONG.song.toLowerCase();
				switch (achievementName)
				{
					case "truegaming":
						if (songName == "console" && ClientPrefs.controllerMode && !keyboardsPresses.contains(true))
							unlock = true;
				}

				if (unlock)
				{
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}

	function startAchievement(achieve:String)
	{
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}
	#end

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	var msTiming:FlxText; // thanks kade engine :smile:
	var timeShown = 0;

	private function popUpScore(note:Note = null):Void
	{
		if (note.isSustainNote || !note.mustPress)
			return;
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		if (!swearingRn)
			vocals.volume = ClientPrefs.vocalsVol;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter(Y);
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);
		var msColor = 0xFF97FFFF;

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0.25;
				score = 50;
				shits++;
				msColor = 0xffdd2245;
			case "bad": // bad
				totalNotesHit += 0.5;
				score = 100;
				bads++;
				msColor = 0xffdc7487;
			case "good": // good
				totalNotesHit += 0.75;
				score = 200;
				goods++;
				msColor = 0xff81e689;
			case "sick": // sick
				totalNotesHit += 1;
				sicks++;
		}

		if (daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}
		totalPlayed++;
		judgementCounter.text = 'Combo: ${combo}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}';
		judgementCounter.text += '\nTotal notes hit: ${notesHit}';
		judgementCounter.text += '\n';
		songScore += score;
		songHits++;

		RecalculateRating();

		if (ClientPrefs.scoreZoom)
		{
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.125;
			scoreTxt.scale.y = 1.125;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}
		var comboSuffix = "";
		if (SONG.song.toLowerCase() == "[redacted]")
		{
			daRating += "-redacted";
			comboSuffix = "-redacted";
		}
		rating.loadGraphic(Paths.image(daRating));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;
		rating.x += ClientPrefs.comboOffset[2];
		rating.y -= ClientPrefs.comboOffset[3];
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo' + comboSuffix));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x - 115;
		comboSpr.y += 30;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.x += ClientPrefs.comboOffset[2];
		comboSpr.y -= ClientPrefs.comboOffset[3];
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if (msTiming != null)
			msTiming.destroy();
		msTiming = new FlxText(0, 0, FlxG.width, '${FlxMath.roundDecimal(noteDiff, 2)} ms');
		timeShown = 0;
		msTiming.setFormat(Paths.font('comic.ttf'), 34, msColor, LEFT, OUTLINE, 0xFF000000);
		msTiming.screenCenter();
		msTiming.x = coolText.x + 140;
		msTiming.y += 5;
		msTiming.x += ClientPrefs.comboOffset[4];
		msTiming.y -= ClientPrefs.comboOffset[5];
		msTiming.cameras = [camHUD];
		msTiming.borderSize = 3;
		msTiming.acceleration.set(0, 600);
		msTiming.velocity.set(0, -FlxG.random.int(140, 160));
		msTiming.velocity.x += comboSpr.velocity.x;
		msTiming.visible = !ClientPrefs.hideHud;
		if (msTiming.alpha != 1)
			msTiming.alpha = 1;
		insert(members.indexOf(strumLineNotes) - 1, rating);
		if (combo >= 10 || !ClientPrefs.ogCombo)
			insert(members.indexOf(strumLineNotes) - 1, comboSpr);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = ClientPrefs.globalAntialiasing;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = rating.antialiasing;
		msTiming.antialiasing = rating.antialiasing;

		comboSpr.updateHitbox();
		rating.updateHitbox();
		msTiming.updateHitbox();
		var seperatedScore:Array<Int> = [];
		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}

		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 95;
			numScore.y += 150;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			numScore.antialiasing = rating.antialiasing;

			numScore.setGraphicSize(Std.int(numScore.width * 0.5));

			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			if (combo >= 10 || !ClientPrefs.ogCombo)
				insert(members.indexOf(strumLineNotes) - 1, numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.0015
			});

			daLoop++;
		}
		insert(members.indexOf(strumLineNotes) - 1, msTiming);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.00125,
			onUpdate: function(tween:FlxTween)
			{
				if (msTiming != null)
					msTiming.alpha -= 0.045;
				timeShown++;
			}
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				if (msTiming != null && timeShown >= 8)
				{
					remove(msTiming, true);
					msTiming.destroy();
				}
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.00125
		});
	}

	private function onKeyPressListen(event:KeyboardEvent):Void // for console achievement
	{
		onKeyPress(event);
	}

	private function onKeyPress(event:KeyboardEvent, keyboard:Bool = true):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		// trace('Pressed: ' + eventKey);
		if (paused || endingSong || inCutscene)
			return;
		if (!cpuControlled && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (keyboard && !keyboardsPresses[key])
				keyboardsPresses[key] = true;
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time + extraPart;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && !daNote.wasGoodHit && !daNote.isSustainNote && daNote.mustPress && !daNote.blockHit)
					{
						if (daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
						}
						canMiss = ClientPrefs.antiMash; // option now
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else if (canMiss)
				{
					noteMissPress(key);
				}
				keysPressed[key] = true;

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if (spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
		switch (eventKey)
		{
			default:
				return;
			case FlxKey.NINE:
				iconP1.swapOldIcon();
				reloadHealthBarColors();
				return;
			#if !release
			case FlxKey.ONE:
				if (moreThanOnePart)
					return;
				KillNotes();
				FlxG.sound.music.time = songLength - 100;
				vocals.time = vocals.length - 100;
			case FlxKey.EIGHT:
				persistentUpdate = false;
				paused = true;
				cancelMusicFadeTween();
				FlxG.sound.music.stop();
				FlxG.sound.music.onComplete = null;
				MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
			#end
			case FlxKey.SEVEN:
				if (PlayState.SONG.song.toLowerCase() == "demise" && !PlayState.isFreeplay)
				{
					loadSecretSong("[redacted]", "qrngu");
				}
				else if (PlayState.SONG.song.toLowerCase() == "fury")
				{
					loadSecretSong("breaking-madness", "rage");
				}
				else
					openChartEditor();
				return;
			case FlxKey.SPACE:
				if (cosmicEye != null && !cosmicEye.alive)
					return;
				keysEyePressed++;
				camOther.shake(0.025, FlxG.elapsed * 2);
				if (keysEyePressed == 5)
					killEye();
			case FlxKey.R:
				if (ClientPrefs.noReset)
					return;
				health = 0;
			case FlxKey.ENTER | FlxKey.ESCAPE:
				pause();
		}
	}

	public function loadSecretSong(name:String, diff:String)
	{
		ClientPrefs.songsLoadedSecret.set(name, true);
		ClientPrefs.saveSettings();
		PlayState.SONG = Song.loadFromJson(name + "-" + diff, name); // you dun messed up
		shaderOn = false;
		screenshader.Enabled = false;
		MusicBeatState.switchState(new PlayState());
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		persistentUpdate = false;
	}

	public function pause()
	{
		if (!startedCountdown || !canPause)
			if (SONG.song.toLowerCase() == "errorless")
			{
				scoreTxt.text = "You can't pause!";
				return;
			}
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			if (SONG.needsVoices)
				vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), null, null,
			'Score: ${songScore} | Misses: ${songMisses} | Rating: ${ratingName} (${ratingPercent}%)');
		#end
	}

	function killEye(searchForSpaceBarAnim:Bool = true)
	{
		if (cosmicEye == null)
			return;
		if ((FlxG.save.data.cosmiceyehintAndDone == null || !FlxG.save.data.cosmiceyehintAndDone) && searchForSpaceBarAnim)
		{
			if (Std.isOfType(members[members.length - 1], FlxSprite))
			{
				var spaceBarAnim:FlxSprite = cast(members[members.length - 1], FlxSprite);
				FlxTween.tween(spaceBarAnim, {y: 720 + spaceBarAnim.height}, 0.5, {
					ease: FlxEase.cubeIn,
					onComplete: function(_) // hope we got the space bar (dont care if we didnt)
					{
						members.remove(spaceBarAnim);
						spaceBarAnim.destroy();
						spaceBarAnim = null;
					}
				});
			}
		}
		cosmicEye.kill();
		cosmicEye.alpha = 0;
		cosmicEye.visible = false;
		cosmicStatic.stop();
		cosmicStatic.time = cosmicStatic.length;
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (paused || inCutscene)
			return;
		if (!cpuControlled && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if (spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			keysPressed[key] = false;
		}
		// trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				if (keysArray[i].contains(key))
				{
					return i;
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [
				controls.NOTE_LEFT_P,
				controls.NOTE_DOWN_P,
				controls.NOTE_UP_P,
				controls.NOTE_RIGHT_P
			];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]), false);
				}
			}
		}
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress)
				{
					goodNoteHit(daNote);
				}
			});
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [
				controls.NOTE_LEFT_R,
				controls.NOTE_DOWN_R,
				controls.NOTE_UP_R,
				controls.NOTE_RIGHT_R
			];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function handleAnimationsIdle()
	{
		if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
			&& boyfriend.animation.curAnim.name.startsWith('sing'))
		{
			boyfriend.tryIdle(true);
			makeDudeIdle(false);
		}
		if (altCharInfo.exists
			&& altChar.holdTimer > Conductor.stepCrochet * 0.001 * altChar.singDuration
			&& altChar.animation.curAnim.name.startsWith('sing'))
		{
			altChar.tryIdle(true);
			makeDudeIdle(false);
		}
	}

	public function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		// Dupe note remove

		combo = 0;
		health -= daNote.missHealth * healthLoss;

		if (instakillOnMiss)
			health = 0;

		songMisses++;
		vocals.volume = 0;
		if (!practiceMode)
			songScore -= 10;

		totalPlayed++;
		RecalculateRating();
		var char:Character = boyfriend;
		if (daNote.altCharNote)
			char = altChar;

		var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))];
		if (char.hasMissAnimations)
			animToPlay += "miss";
		animToPlay += daNote.animSuffix;
		char.playAnim(animToPlay, true);
		if (!char.hasMissAnimations)
			char.color = 0xff6f0b5f;
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (ClientPrefs.ghostTapping)
			return;
		if (!boyfriend.stunned)
		{
			if (instakillOnMiss)
			{
				vocals.volume = 0;
				health = 0;
			}
			else if (health > 0)
				health -= 0.05 * healthLoss;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong)
			{
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			var char:Character = boyfriend;
			if (SONG.notes[curSection].altCharSection)
				char = altChar;
			var animToPlay:String = singAnimations[direction];
			if (char.hasMissAnimations)
				animToPlay += "miss";
			char.playAnim(animToPlay, true);
			if (!char.hasMissAnimations)
				char.color = 0xff6f0b5f;
			vocals.volume = 0;
		}
	}

	public function opponentNoteHit(note:Note):Void
	{
		if (!note.noAnimation)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + note.animSuffix;
			var chars:Array<Character> = [dad];
			if (note.noteType == "Alt Char Sing" || SONG.notes[curSection].altCharSection)
				chars.remove(dad);
			if (note.altCharNote)
				chars.push(altChar);
			if (note.noteType.toLowerCase().contains("2nd") || note.noteType.toLowerCase().contains("all"))
				chars.push(altChar2);
			for (char in chars)
			{
				if (char == null)
					return;
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
			camFollow.x -= dadCamFollowX;
			camFollow.y -= dadCamFollowY;
			switch (Std.int(Math.abs(note.noteData)))
			{
				case 0:
					dadCamFollowY = 0;
					dadCamFollowX = -cameraMoveOffset;
				case 1:
					dadCamFollowY = cameraMoveOffset;
					dadCamFollowX = 0;
				case 2:
					dadCamFollowY = -cameraMoveOffset;
					dadCamFollowX = 0;
				case 3:
					dadCamFollowY = 0;
					dadCamFollowX = cameraMoveOffset;
			}

			camFollow.x += dadCamFollowX;
			camFollow.y += dadCamFollowY;
		}
		if (!swearingRn)
			vocals.volume = ClientPrefs.vocalsVol;

		var time:Float = 0.15;
		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
		{
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	public function goodNoteHit(note:Note):Void
	{
		if (!note.isSustainNote && !(note.ignoreNote || note.hitCausesMiss))
		{
			notesHit++;
			notesHitArray.push(new NewDate());
		}
		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;
			if (!note.noHitsound)
				playHitsound();
			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				switch (note.noteType)
				{
					case 'Hurt Note' | '3D Hurt Note': // Hurt note
						if (boyfriend.animation.getByName('hurt') != null)
						{
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if (combo > 9999)
					combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if (!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + note.animSuffix;
				var chars:Array<Character> = [boyfriend];
				if (note.noteType == "Alt Char Sing" || SONG.notes[curSection].altCharSection)
					chars.remove(boyfriend);
				if (note.altCharNote)
					chars.push(altChar);
				for (char in chars)
				{
					if (char == null)
						return;
					char.playAnim(animToPlay, true);
					char.holdTimer = 0;
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey') && !note.altCharNote)
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
				}
				camFollow.x -= camFollowX;
				camFollow.y -= camFollowY;
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						camFollowY = 0;
						camFollowX = -cameraMoveOffset;
					case 1:
						camFollowY = cameraMoveOffset;
						camFollowX = 0;
					case 2:
						camFollowY = -cameraMoveOffset;
						camFollowX = 0;
					case 3:
						camFollowY = 0;
						camFollowX = cameraMoveOffset;
				}
				camFollow.x += camFollowX;
				camFollow.y += camFollowY;
			}

			if (cpuControlled)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			}
			else
			{
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			if (!swearingRn)
				vocals.volume = ClientPrefs.vocalsVol;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
				note = null;
			}
		}
	}

	function playHitsound()
	{
		if (ClientPrefs.hitsounds && hitsoundsEnabled)
		{
			if (!SONG.song.toLowerCase().startsWith("poppin"))
			{
				FlxG.sound.play(Paths.sound('hitsound', 'shared'), ClientPrefs.hitSoundVol);
			}
			else
			{
				FlxG.sound.play(Paths.sound('hitsoundPop', 'shared'), ClientPrefs.hitSoundVol);
			}
		}
	}

	var curPart = 0;
	var maxParts = 0;
	var moreThanOnePart = false;
	var extraPart = 0.0;

	function spawnNoteSplashOnNote(note:Note)
	{
		spawnNoteSplash(playerStrums.members[note.noteData % 4].x, playerStrums.members[note.noteData % 4].y, note.noteData, note);
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, note:Note)
	{
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		skin = note.noteSplashTexture;
		hue = note.noteSplashHue;
		sat = note.noteSplashSat;
		brt = note.noteSplashBrt;
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	public function removeNoteSplash(splash:NoteSplash)
	{
		grpNoteSplashes.remove(splash, true);
		splash.destroy();
		splash = null;
	}

	override function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressListen);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		shaderOn = false;
		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20)
		{
			resyncVocals();
		}
		if (SONG.song.toLowerCase() != "[redacted]")
			return;
		switch (curStep) // too lazy to soft code
		{
			case 1408:
				bgs.members[0].loadGraphic(Paths.occurPath("redactedbgs/redactedpipes", IMAGES));
			case 2047:
				bgs.members[0].loadGraphic(Paths.occurPath("redactedbgs/redactedchains", IMAGES));
			case 3199:
				bgs.members[0].loadGraphic(Paths.occurPath("redactedbgs/redactedbrokenpipes", IMAGES));
			case 3712:
				bgs.members[0].loadGraphic(Paths.occurPath("redactedbgs/redactedglitchchain", IMAGES));
		}
	}

	override function sectionHit() // originally this was a diff thing but after the 0.6.2 conductor + charter editor merge yea
	{
		if (camZooming && SONG.song.toLowerCase() != "[redacted]")
		{
			FlxG.camera.zoom += 0.02;
			camHUD.zoom += 0.02;
		}
		updateScoreText(); // you cant pause thing not lasting for a long time
		if (curSection % 2 == 0 && ClientPrefs.gcSection)
			System.gc();
		if (SONG.song.toLowerCase().startsWith("console"))
		{
			var bambising = false;
			var bfsing = false;
			for (note in SONG.notes[curSection].sectionNotes)
			{
				var gottaHitNote = note[1] <= 3;
				if (!SONG.notes[curSection].mustHitSection)
					gottaHitNote = !gottaHitNote;
				if (!bambising)
					bambising = !gottaHitNote;
				if (!bfsing)
					bfsing = gottaHitNote;
				if (bambising && bfsing)
					break;
			}
			if (bambising && bfsing)
				bgs.members[0].animation.play("both");
			else if (bambising)
				bgs.members[0].animation.play("bambi");
			else if (bfsing)
				bgs.members[0].animation.play("bf");
			else
				bgs.members[0].animation.play("no");
		}
		if (!ClientPrefs.followarrow)
			moveCameraSection();
		super.sectionHit();
	}

	var idle = true;

	function makeDudeIdle(dadDoes:Bool)
	{
		if (!ClientPrefs.followarrow || SONG.notes[curSection] == null)
			return;
		if (dadDoes)
		{
			if ((!altCharInfo.withPlayer
				&& singAnimations.contains(altChar.animation.curAnim.name)
				&& SONG.notes[curSection].altCharSection))
				return;

			if (!singAnimations.contains(dad.animation.curAnim.name))
			{
				dadCamFollowX = 0;
				dadCamFollowY = 0;
			}
			return;
		}
		if (altCharInfo.exists
			&& (altCharInfo.withPlayer
				&& singAnimations.contains(altChar.animation.curAnim.name)
				&& SONG.notes[curSection].altCharSection))
			return;

		if (!singAnimations.contains(boyfriend.animation.curAnim.name))
		{
			camFollowX = 0;
			camFollowY = 0;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (SONG.song.toLowerCase() == "demise")
		{
			camHUD.angle = 10 * ((curBeat % 2 == 0) ? -1 : 1);
			FlxTween.tween(camHUD, {angle: 0}, Conductor.crochet / 1125, {ease: FlxEase.circOut});
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		if (SONG.notes[curSection] != null && SONG.notes[curSection].changeBPM)
			Conductor.changeBPM(SONG.notes[curSection].bpm);

		if (curBeat % gfSpeed == 0)
		{
			var turnangle = 25 * (curBeat % (gfSpeed * 2) == 0 ? -1 : 1);
			var ease = FlxEase.smootherStepOut;
			var dir = (Conductor.crochet / 1125) * gfSpeed;
			gf.tryIdle(idle);
			if (altCharInfo.exists)
			{
				FlxTween.angle(iconAlt, turnangle, 0, dir, {ease: ease});
				FlxTween.angle(iconAlt2, turnangle, 0, dir, {ease: ease});
			}
			FlxTween.angle(iconP1, turnangle, 0, dir, {ease: ease});
			FlxTween.angle(iconP2, turnangle, 0, dir, {ease: ease});
		}
		if (dad.tryIdle(idle))
			makeDudeIdle(true);
		if (boyfriend.tryIdle(idle))
			makeDudeIdle(false);
		if (altCharInfo.exists)
		{
			altChar.tryIdle(idle);
			altChar2.tryIdle(idle);
		}
		moveCameraSection();
		idle = !idle;
		var thej = ((healthBar.percent * 0.0125) + 0.2);
		var dadIconCalc = [0.0, 0.0];
		var bfIconCalc = [0.0, 0.0];
		dadIconCalc[0] = (Math.max(((0.25 + ((thej / (health + 0.4)))) / (thej * 2.07)), 0.47));
		dadIconCalc[1] = (Math.max(thej - 0.3, 0.625));
		bfIconCalc[0] = (Math.min(((0.25 + ((thej * (health + 0.4)))) * (thej / 2.07)), 1.6));
		bfIconCalc[1] = (Math.min(thej + 0.3, 1.1));
		iconP1.setGraphicSize(Std.int(iconP1.width * bfIconCalc[0]), Std.int(iconP1.height * bfIconCalc[1]));
		iconP2.setGraphicSize(Std.int(iconP2.width * dadIconCalc[0]), Std.int(iconP2.height * dadIconCalc[1]));
		if (!altCharInfo.exists)
		{
			dadIconCalc = null;
			bfIconCalc = null;
		}
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		if (altCharInfo.exists) // should be true if altchar2 exists!!!
		{
			if (altCharInfo.withPlayer)
				iconAlt.setGraphicSize(Std.int(iconAlt.width * bfIconCalc[0]), Std.int(iconAlt.height * bfIconCalc[1]));
			else
				iconAlt.setGraphicSize(Std.int(iconAlt.width * dadIconCalc[0]), Std.int(iconAlt.height * dadIconCalc[1]));
			iconAlt.updateHitbox();
			iconAlt2.setGraphicSize(Std.int(iconAlt2.width * dadIconCalc[0]), Std.int(iconAlt2.height * dadIconCalc[1]));
			iconAlt2.updateHitbox();
			dadIconCalc = null;
			bfIconCalc = null;
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;
		if (isDad)
		{
			spr = strumLineNotes.members[id % 4];
		}
		else
		{
			spr = playerStrums.members[id % 4];
		}

		spr.playAnim('confirm', true);
		spr.resetAnim = time;
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating()
	{
		// Rating Percent
		ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
		// Rating Name
		if (ratingPercent == 1)
			ratingName = ratingStuff[0][Std.int(ratingStuff[0].length - 1)][0];
		else
			for (i in 0...Std.int(ratingStuff[0].length - 1))
			{
				if (ratingPercent < ratingStuff[0][i][1])
				{
					ratingName = ratingStuff[0][i][0];
					break;
				}
			}

		if (songMisses == 0)
		{
			if (shits > 0)
				ratingFC = "FC";
			else if (bads > 0)
				ratingFC = "BFC";
			else if (goods > 0)
				ratingFC = "GFC";
			else
				ratingFC = "SFC";
		}
		else
		{
			for (i in 0...Std.int(ratingStuff[1].length - 1))
			{
				if (songMisses >= ratingStuff[1][i][1])
				{
					ratingFC = ratingStuff[1][i][0];
					if (songMisses < ratingStuff[1][Std.int(Math.min(i + 1, ratingStuff[1].length - 1))][1])
						break;
				}
			}
		}
		updateScoreText();
	}

	// multi windows stuffs / expunged hacking
	var hitsoundsEnabled:Bool = true; // a bug exists where it stops after a bit and plays on refocus
	var windowExpunged:Window;
	var expungedSpr = new Sprite();
	var expungedScroll = new Sprite();
	var expungedIsFlying = false;
	var expungedOffset:FlxPoint = new FlxPoint();
	var expungedMoving:Bool = true;
	var lastFrame:flixel.graphics.frames.FlxFrame;
	var windowProperties:Array<Dynamic> = new Array<Dynamic>();
	private var windowSteadyX:Float;
	var elapsedexpungedtime:Float = 0.0;
	var spriteThatIsFlying:FlxSprite;

	public var ExpungedWindowCenterPos:FlxPoint = new FlxPoint(0, 0);

	function popupWindow()
	{
		hitsoundsEnabled = false;
		spriteThatIsFlying = dad;
		windowProperties = [
			Application.current.window.x,
			Application.current.window.y,
			Application.current.window.width,
			Application.current.window.height
		];
		var screenwidth = Application.current.window.display.bounds.width;
		var screenheight = Application.current.window.display.bounds.height;

		// center
		Application.current.window.x = Std.int((screenwidth / 2) - (1280 / 2));
		Application.current.window.y = Std.int((screenheight / 2) - (720 / 2));
		Application.current.window.width = 1280;
		Application.current.window.height = 720;

		windowExpunged = Application.current.createWindow({
			title: "expunged.dat",
			width: 900,
			height: 900,
			borderless: true,
			alwaysOnTop: true
		});

		windowExpunged.stage.color = 0x00010101;

		SystemUtils.getWindowsTransparent();

		FlxG.mouse.useSystemCursor = true;

		generateWindowSprite();

		expungedScroll.scrollRect = new Rectangle();
		windowExpunged.stage.addChild(expungedScroll);
		expungedScroll.addChild(expungedSpr);
		expungedScroll.scaleX = 0.5;
		expungedScroll.scaleY = 0.5;

		expungedOffset.x = Application.current.window.x;
		expungedOffset.y = Application.current.window.y;

		dad.visible = false;

		var windowX = Application.current.window.x + ((Application.current.window.display.bounds.width) * 0.140625);

		windowSteadyX = windowX;

		FlxTween.tween(expungedOffset, {x: -20}, 2, {ease: FlxEase.elasticOut});

		FlxTween.tween(Application.current.window, {x: windowX}, 2.2, {
			ease: FlxEase.elasticOut,
			onComplete: function(tween:FlxTween)
			{
				ExpungedWindowCenterPos.x = expungedOffset.x;
				ExpungedWindowCenterPos.y = expungedOffset.y;
				expungedMoving = false;
			}
		});

		Application.current.window.onClose.add(function()
		{
			if (windowExpunged != null)
			{
				windowExpunged.close();
			}
		}, false, 100);

		Application.current.window.focus();
		expungedIsFlying = true;
		@:privateAccess
		lastFrame = dad._frame;
	}

	function generateWindowSprite()
	{
		var m = new Matrix();
		m.translate(0, 0);

		expungedSpr.graphics.beginBitmapFill(spriteThatIsFlying.pixels, m);
		expungedSpr.graphics.drawRect(0, 0, spriteThatIsFlying.pixels.width, spriteThatIsFlying.pixels.height);
		expungedSpr.graphics.endFill();
	}

	function transferSpriteToWindow()
	{
		var display = Application.current.window.display.currentMode;

		@:privateAccess
		var sprFrame = spriteThatIsFlying._frame;

		if (sprFrame == null || sprFrame.frame == null)
			return; // prevent crashes (i hope)
		var rect = new Rectangle(sprFrame.frame.x, sprFrame.frame.y, sprFrame.frame.width, sprFrame.frame.height);

		expungedScroll.scrollRect = rect;
		windowExpunged.x = Std.int(expungedOffset.x);
		windowExpunged.y = Std.int(expungedOffset.y);
		if (!expungedMoving)
		{
			elapsedexpungedtime += FlxG.elapsed * 9;
			var screenwidth = Application.current.window.display.bounds.width;
			var screenheight = Application.current.window.display.bounds.height;

			var toy = ((-Math.sin((elapsedexpungedtime / 9.5) * 2) * 30 * 5.1) / SystemUtils.getScreenSize()[1]) * screenheight;
			var tox = ((-Math.cos((elapsedexpungedtime / 9.5)) * 100) / SystemUtils.getScreenSize()[0]) * screenwidth;
			expungedOffset.x = ExpungedWindowCenterPos.x + tox;
			expungedOffset.y = ExpungedWindowCenterPos.y + toy;
			// center
			Application.current.window.y = Math.round(((screenheight / 2) - (720 / 2)) + (Math.sin((elapsedexpungedtime / 30)) * 80));
			Application.current.window.x = Std.int(windowSteadyX);
			Application.current.window.width = 1280;
			Application.current.window.height = 720;
		}
		if (lastFrame != null && sprFrame != null && lastFrame.name != sprFrame.name)
		{
			expungedSpr.graphics.clear();
			generateWindowSprite();
			lastFrame = sprFrame;
		}
		expungedScroll.x = (((sprFrame.offset.x) - (spriteThatIsFlying.offset.x)) * expungedScroll.scaleX) + 100;
		expungedScroll.y = (((sprFrame.offset.y) - (spriteThatIsFlying.offset.y)) * expungedScroll.scaleY) + 100;
	}

	#if debug
	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}
	#end
}
