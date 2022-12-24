package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import Controls;

class ClientPrefs
{
	public static var wavyBGs:Bool = true;
	public static var colorblindMode:String = "None";
	public static var swearing = true;
	public static var disableFX = false;
	public static var gcSection = false;
	public static var timeColorBar = true;
	public static var instVol = 1.0;
	public static var vocalsVol = 1.0;
	public static var mechanics = true;
	public static var noteAlpha = 1.0;
	public static var noteStrumAlpha = 1.0;
	public static var healthBarTexture = "Default";
	public static var antiMash = false;
	public static var note3D2Dtransform = true;
	/* public static var note3D2Dflicking = true;
		rip old 3d note flickering;
		killed due to occurathon being too laggy;
		dead but not forgotten;
		2022-2022;
	 */
	public static var laneUnderlaything = 0.0;
	public static var laneUnderlayenabled = false;
	public static var unlockedChars:Map<String, Bool> = [];
	public static var note3Dwhen = "Default";
	public static var greenScreen = false;
	public static var modcharts = true;
	public static var assistanceSpam = true;
	public static var osuHitsound = false;
	public static var ogHpBar = false;
	public static var ogCombo = false;
	public static var hitSoundVol = 1.0;
	public static var songsLoaded:Map<String, Bool> = [];
	public static var songsLoadedSecret:Map<String, Bool> = [];
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Null<Bool> = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var shaders:Bool = true;
	public static var followarrow:Bool = true;
	public static var framerate:Int = 60;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var storyCutscenes:Bool = true;
	public static var freeplayCutscenes:Bool = false;
	public static var noteOffset:Int = 0;
	public static var judgementCounter:Bool = true;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Left';
	public static var charSelect:String = 'Freeplay';
	public static var scoreZoom:Bool = true;
	public static var hitsounds:Bool = false;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var ostBgMusicMode:Bool = true;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;
	public static var curSaveFileNum:Null<Int> = null; // only when no save files detected
	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
	}

	public static function saveLocation()
	{
		#if (flixel >= "5.0.0")
		return "OccurrenceTeam/davesHouse";
		#else
		return "davesHouse";
		#end
	}

	public static function loadGlobalPrefs()
	{
		FlxG.save.bind('global', saveLocation());
		if (FlxG.save.data.curSaveFile != null)
		{
			curSaveFileNum = FlxG.save.data.curSaveFile;
			FlxG.save.bind('funkin' + ClientPrefs.curSaveFileNum, saveLocation());
			PlayerSettings.init();
			loadPrefs();
			var save = new FlxSave();
			save.bind('global', saveLocation());
			if (save.data != null && save.data.fullscreen)
				FlxG.fullscreen = save.data.fullscreen;
			TitleState.reloadStoryProgress();
			Highscore.load();
		}
	}

	public static function saveGlobalPrefs()
	{
		FlxG.save.bind('global', saveLocation());
		FlxG.save.data.curSaveFile = curSaveFileNum;
		var yes = curSaveFileNum;
		if (yes == null)
			return; // should never happen but just in case
		FlxG.save.bind('funkin' + ClientPrefs.curSaveFileNum, saveLocation());
	}

	public static function saveSettings()
	{
		FlxG.save.data.wavyBGs = wavyBGs;
		FlxG.save.data.swearing = swearing;
		FlxG.save.data.colorblindMode = colorblindMode;
		FlxG.save.data.disableFX = disableFX;
		FlxG.save.data.gcSection = gcSection;
		FlxG.save.data.timeColorBar = timeColorBar;
		FlxG.save.data.instVol = instVol;
		FlxG.save.data.vocalsVol = vocalsVol;
		FlxG.save.data.mechanics = mechanics;
		FlxG.save.data.exists = true;
		FlxG.save.data.noteAlpha = noteAlpha;
		FlxG.save.data.noteStrumAlpha = noteStrumAlpha;
		FlxG.save.data.antiMash = antiMash;
		FlxG.save.data.healthBarTexture = healthBarTexture;
		FlxG.save.data.laneUnderlaything = laneUnderlaything;
		FlxG.save.data.laneUnderlayenabled = laneUnderlayenabled;
		FlxG.save.data.note3D2Dtransform = note3D2Dtransform;
		FlxG.save.data.note3Dwhen = note3Dwhen;
		FlxG.save.data.greenScreen = greenScreen;
		FlxG.save.data.modcharts = modcharts;
		FlxG.save.data.assistanceSpam = assistanceSpam;
		FlxG.save.data.osuHitsound = osuHitsound;
		#if !STREAMER
		FlxG.save.data.songsLoaded = songsLoaded;
		#end
		FlxG.save.data.songsLoadedSecret = songsLoadedSecret;
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.ogHpBar = ogHpBar;
		FlxG.save.data.ogCombo = ogCombo;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.hitsounds = hitsounds;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.charSelect = charSelect;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.hitSoundVol = hitSoundVol;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.followarrow = followarrow;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.storyCutscenes = storyCutscenes;
		FlxG.save.data.freeplayCutscenes = freeplayCutscenes;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.judgementCounter = judgementCounter;
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2' + ClientPrefs.curSaveFileNum,
			saveLocation()); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
	}

	public static function loadPrefs()
	{
		if (FlxG.save.data.wavyBGs != null)
		{
			wavyBGs = FlxG.save.data.wavyBGs;
		}
		if (FlxG.save.data.swearing != null)
		{
			swearing = FlxG.save.data.swearing;
		}
		if (FlxG.save.data.disableFX != null)
		{
			disableFX = FlxG.save.data.disableFX;
		}
		if (FlxG.save.data.gcSection != null)
		{
			gcSection = FlxG.save.data.gcSection;
		}
		if (FlxG.save.data.timeColorBar != null)
		{
			timeColorBar = FlxG.save.data.timeColorBar;
		}
		if (FlxG.save.data.instVol != null)
		{
			instVol = FlxG.save.data.instVol;
		}
		if (FlxG.save.data.vocalsVol != null)
		{
			vocalsVol = FlxG.save.data.vocalsVol;
		}
		if (FlxG.save.data.mechanics != null)
		{
			mechanics = FlxG.save.data.mechanics;
		}
		if (FlxG.save.data.noteStrumAlpha != null)
		{
			noteStrumAlpha = FlxG.save.data.noteStrumAlpha;
		}
		if (FlxG.save.data.colorblindMode != null)
		{
			colorblindMode = FlxG.save.data.colorblindMode;
		}
		if (FlxG.save.data.noteAlpha != null)
		{
			noteAlpha = FlxG.save.data.noteAlpha;
		}
		if (FlxG.save.data.antiMash != null)
		{
			antiMash = FlxG.save.data.antiMash;
		}
		if (FlxG.save.data.healthBarTexture != null)
		{
			healthBarTexture = FlxG.save.data.healthBarTexture;
		}
		if (FlxG.save.data.ogCombo != null)
		{
			ogCombo = FlxG.save.data.ogCombo;
		}
		if (FlxG.save.data.note3D2Dtransform != null)
		{
			note3D2Dtransform = FlxG.save.data.note3D2Dtransform;
		}
		if (FlxG.save.data.laneUnderlaything != null)
		{
			laneUnderlaything = FlxG.save.data.laneUnderlaything;
		}
		if (FlxG.save.data.laneUnderlayenabled != null)
		{
			laneUnderlayenabled = FlxG.save.data.laneUnderlayenabled;
		}
		if (FlxG.save.data.unlockedChars != null)
		{
			unlockedChars = FlxG.save.data.unlockedChars;
		}
		if (FlxG.save.data.note3Dwhen != null)
		{
			note3Dwhen = FlxG.save.data.note3Dwhen;
		}
		if (FlxG.save.data.greenScreen != null)
		{
			greenScreen = FlxG.save.data.greenScreen;
		}
		if (FlxG.save.data.modcharts != null)
		{
			modcharts = FlxG.save.data.modcharts;
		}
		if (FlxG.save.data.assistanceSpam != null)
		{
			assistanceSpam = FlxG.save.data.assistanceSpam;
		}
		if (FlxG.save.data.downScroll != null)
		{
			downScroll = FlxG.save.data.downScroll;
		}
		if (FlxG.save.data.middleScroll != null)
		{
			middleScroll = FlxG.save.data.middleScroll;
		}
		if (FlxG.save.data.showFPS != null)
		{
			showFPS = FlxG.save.data.showFPS;
			if (Main.fpsVar != null)
			{
				Main.fpsVar.visible = showFPS;
			}
		}
		if (FlxG.save.data.hitSoundVol != null)
		{
			hitSoundVol = FlxG.save.data.hitSoundVol;
		}

		if (FlxG.save.data.osuHitsound != null)
		{
			osuHitsound = FlxG.save.data.osuHitsound;
		}
		#if !STREAMER
		if (FlxG.save.data.songsLoaded != null)
		{
			songsLoaded = FlxG.save.data.songsLoaded;
		}
		#end
		if (FlxG.save.data.songsLoadedSecret != null)
		{
			songsLoadedSecret = FlxG.save.data.songsLoadedSecret;
		}
		if (FlxG.save.data.flashing != null)
		{
			flashing = FlxG.save.data.flashing;
		}
		if (FlxG.save.data.judgementCounter != null)
		{
			judgementCounter = FlxG.save.data.judgementCounter;
		}
		if (FlxG.save.data.globalAntialiasing != null)
		{
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if (FlxG.save.data.ogHpBar != null)
		{
			ogHpBar = FlxG.save.data.ogHpBar;
		}
		if (FlxG.save.data.followarrow != null)
		{
			followarrow = FlxG.save.data.followarrow;
		}
		if (FlxG.save.data.noteSplashes != null)
		{
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if (FlxG.save.data.lowQuality != null)
		{
			lowQuality = FlxG.save.data.lowQuality;
		}
		if (FlxG.save.data.lowQuality != null)
		{
			lowQuality = FlxG.save.data.lowQuality;
		}
		if (FlxG.save.data.shaders != null)
		{
			shaders = FlxG.save.data.shaders;
		}
		if (FlxG.save.data.hitsounds != null)
		{
			hitsounds = FlxG.save.data.hitsounds;
		}
		if (FlxG.save.data.storyCutscenes != null)
		{
			storyCutscenes = FlxG.save.data.storyCutscenes;
		}
		if (FlxG.save.data.freeplayCutscenes != null)
		{
			freeplayCutscenes = FlxG.save.data.freeplayCutscenes;
		}
		if (FlxG.save.data.framerate != null)
		{
			framerate = FlxG.save.data.framerate;
			if (framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			}
			else
			{
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}

		if (FlxG.save.data.camZooms != null)
		{
			camZooms = FlxG.save.data.camZooms;
		}
		if (FlxG.save.data.hideHud != null)
		{
			hideHud = FlxG.save.data.hideHud;
		}
		if (FlxG.save.data.noteOffset != null)
		{
			noteOffset = FlxG.save.data.noteOffset;
		}
		if (FlxG.save.data.arrowHSV != null)
		{
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if (FlxG.save.data.ghostTapping != null)
		{
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if (FlxG.save.data.timeBarType != null)
		{
			timeBarType = FlxG.save.data.timeBarType;
		}

		if (FlxG.save.data.charSelect != null)
		{
			charSelect = FlxG.save.data.charSelect;
		}
		if (FlxG.save.data.scoreZoom != null)
		{
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if (FlxG.save.data.noReset != null)
		{
			noReset = FlxG.save.data.noReset;
		}
		if (FlxG.save.data.healthBarAlpha != null)
		{
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if (FlxG.save.data.comboOffset != null)
		{
			comboOffset = FlxG.save.data.comboOffset;
		}

		if (FlxG.save.data.ratingOffset != null)
		{
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if (FlxG.save.data.sickWindow != null)
		{
			sickWindow = FlxG.save.data.sickWindow;
		}
		if (FlxG.save.data.goodWindow != null)
		{
			goodWindow = FlxG.save.data.goodWindow;
		}
		if (FlxG.save.data.badWindow != null)
		{
			badWindow = FlxG.save.data.badWindow;
		}
		if (FlxG.save.data.safeFrames != null)
		{
			safeFrames = FlxG.save.data.safeFrames;
		}
		if (FlxG.save.data.controllerMode != null)
		{
			controllerMode = FlxG.save.data.controllerMode;
		}
		if (FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2' + ClientPrefs.curSaveFileNum, saveLocation());
		if (save != null && save.data.customControls != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls)
			{
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic
	{
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls()
	{
		if (PlayerSettings.player1 != null && PlayerSettings.player1.controls != null)
			PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}

	public static function unlockCharacter(character:String)
	{
		unlockedChars.set(character + "-player", true);
		FlxG.save.data.unlockedChars = unlockedChars;
		FlxG.save.flush();
	}
}
