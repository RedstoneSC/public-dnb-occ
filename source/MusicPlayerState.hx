package;

import Achievements.AchievementObject;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

// this is my code btw but it is inspired by dnb and has snippets from it (e.g. playdist)

class MusicPlayerState extends MusicBeatState
{
	public var bg:FlxSprite;

	var paused = false;
	var ease = FlxEase.quartOut;
	var healthBar:FlxBar;
	var healthBarBG:FlxSprite;
	var vocals:FlxSound;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	var iconWell:HealthIcon;
	var timeTxt:FlxText;
	var songsLoaded:Array<OSTSongMetadata> = [];
	var songsLoadedText:Array<Alphabet> = [];
	var songsLoadedIcon:Array<HealthIcon> = [];
	var colorTween:FlxTween;
	var curSelected:Int = 0;
	var isPlayingMusic:Bool = false;

	public var playdist:Float = 0;

	// yes i know its a bad idea but it gives me a bit more control
	// i just realized that i can copy the thing from the week json and it works i take back the comment above me (yes after like 4 months lololololol)
	var songsToLoad:Array<Array<Dynamic>> = [
		["Gate", "dave", [15, 95, 255]],
		["Wheelchair", "dave", [15, 95, 255]],
		["Cubic", "dave3dconfident", [248, 166, 165]],
		["Shucked", "bambi", [12, 181, 0]],
		["Short-stalk", "bambi", [12, 181, 0]],
		["Fury", "redbambinew", [228, 0, 60]],
		["Darker", "darkenu", [30, 30, 30]],
		["Shadowed", "darkenu", [30, 30, 30]],
		["Icicles", "flumbo", [209, 255, 255]],
		["Triangles", "flumbo", [209, 255, 255]],
		["Phase", "cosmicnew", [203, 86, 94]],
		["Demise", "cosmicnew", [203, 86, 94]],
		["Occurathon", "trioiconig", [209, 255, 255]],
		["Wilderness", "guve", [68, 27, 0], ["Hard"]],
		["Snacker", "bandusnacker", [57, 233, 32]],
		["Poppin", "poppin", [35, 215, 40]],
		["Quingen", "_", [230, 224, 188], ["$50"]],
		["Bambino", "tristanenemy", [255, 19, 15]],
		["Errorless", "expunged", [89, 5, 6]],
		["Mechanical", "rephonu", [56, 75, 124],],
		["Console", "consolebambi", [94, 234, 84]],
		["Magicians-Work", "gerald", [36, 42, 50]],
		["Real-Corn", "bambireal", [0, 255, 0]],
		["Phones", "bambibutawesomenew", [0, 204, 51]],
		["Budget-Quingen", "moneymbi", [181, 230, 29]],
		["Pebble", "pimbog", [184, 200, 233]],
		["Heheheha", "clashroyale", [239, 246, 247]],
		["Alien-Language", "aliendzub", [197, 209, 64]],
		["That-guy", "cloneheroguy", [181, 133, 80]],
		["Brick", "brick", [175, 175, 175]],
		["Snacker-Eduardo", "eduardo", [17, 113, 43]],
		["Breaking-Madness", "nightbambi", [0, 255, 0]],
		["Short-stalk-old", "bambi", [12, 181, 0]],
		["Snacker-old", "bandusnacker", [57, 233, 32]],
		["Snacker-older", "bandusnackerold", [67, 254, 35]],
		["Poppin-old", "poppin", [35, 215, 40]],
		["Poppin-older", "bandupoppin", [51, 127, 51]],
		["Poppin-oldest", "bandupoppinold", [51, 127, 51]],
		["Phones-old", "bambibutawesome", [0, 255, 0]],
		["Snacker-Eduardo-Old", "eduardo", [17, 113, 43]],
		["Snacker-Eduardo-Older", "eduardo", [17, 113, 43]],
		["Cubic-old", "3ddave", [173, 131, 131]]
	];
	var secretSongsToLoad:Array<Array<Dynamic>> = [["[REDACTED]", "redacted", [44, 7, 4]]];
	var otherSongsToLoad:Array<Array<String>> = [
		["Character Select", "charselect"],
		["Menu Music", "freakyMenu"],
		["Old Menu Music", "freakyMenuOld"],
		["Homebop", "homeBop"],
		["Geometric Disturbance", "geometricDisturbance"],
		["Farmland", "farmLand"],
		["Huffy", "huffy"],
		["Dim", "dim"],
		["Three Sided", "threeSided"],
		["Instability", "instability"]
	];
	var secretOtherSongsToLoad:Array<Array<String>> = [["Redacted Dialogue", "redacteddialogue", "[redacted]"]];
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	override function create()
	{
		if (FlxG.save.data.timeinOST == null)
		{
			FlxG.save.data.timeinOST = 0;
			FlxG.save.flush();
		}
		if (FlxG.sound.music == null)
		{
			resetMenuTheme();
		}
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];
		if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[Achievements.getAchievementIndex('banger_songs')][2]))
			ostChecker();
		bg = new FlxSprite().loadGraphic(MainMenuState.randomBG());
		bg.color = 0xFFFD719B;
		bg.screenCenter();
		add(bg);
		healthBarBG = new FlxSprite(0, 100).loadGraphic(Paths.image('healthBars/' + ClientPrefs.healthBarTexture.toLowerCase(), "shared"));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'playdist', 0, 1);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.numDivisions = 100;
		add(healthBar);
		healthBarBG.alpha = ClientPrefs.healthBarAlpha;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		timeTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 95, 0, "", 20);
		timeTxt.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(timeTxt);
		iconP1 = new HealthIcon("bf", true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);
		iconP2 = new HealthIcon("music", false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);
		iconWell = new HealthIcon("eduardo", false);
		iconWell.y = healthBar.y - 75;
		add(iconWell);

		for (songInfo in songsToLoad)
		{
			if (!ClientPrefs.songsLoaded.exists(songInfo[0].toLowerCase())
				&& FreeplayState.lockedSongs.contains(songInfo[0].toLowerCase()))
				songsLoaded.push(new OSTSongMetadata("Hidden Song", false, "lock", FlxColor.fromInt(-10066177)));
			else
			{
				var songMeta = new OSTSongMetadata(songInfo[0], false, songInfo[1], FlxColor.fromRGB(songInfo[2][0], songInfo[2][1], songInfo[2][2]),
					songInfo[3] != null ? songInfo[3] : NORMAL);
				songsLoaded.push(songMeta);
				var instMeta = new OSTSongMetadata(songInfo[0], true, songInfo[1], FlxColor.fromRGB(songInfo[2][0], songInfo[2][1], songInfo[2][2]),
					songInfo[3] != null ? songInfo[3] : NORMAL);
				songsLoaded.push(instMeta);
			}
		}
		for (songInfo in secretSongsToLoad)
		{
			if (ClientPrefs.songsLoadedSecret.exists(songInfo[0].toLowerCase()))
			{
				var songName:String = songInfo[0];
				var songMeta = new OSTSongMetadata(songName, false, songInfo[1], FlxColor.fromRGB(songInfo[2][0], songInfo[2][1], songInfo[2][2]),
					songInfo[3] != null ? songInfo[3] : NORMAL);
				songsLoaded.push(songMeta);
				var instMeta = new OSTSongMetadata(songName, true, songInfo[1], FlxColor.fromRGB(songInfo[2][0], songInfo[2][1], songInfo[2][2]),
					songInfo[3] != null ? songInfo[3] : NORMAL);
				songsLoaded.push(instMeta);
			}
			else
				continue;
		}
		for (songInfo in otherSongsToLoad)
		{
			var songMeta = new OSTSongMetadata(songInfo[0], false, songInfo[1], 0xff33ffff, MUSIC);
			songsLoaded.push(songMeta);
		}
		for (songInfo in secretOtherSongsToLoad)
		{
			if (ClientPrefs.songsLoadedSecret.exists(songInfo[2].toLowerCase()))
			{
				var songMeta = new OSTSongMetadata(songInfo[0], false, songInfo[1], 0xff33ffff, MUSIC);
				songsLoaded.push(songMeta);
			}
			else
				continue;
		}
		for (i in 0...songsLoaded.length)
		{
			var texttosay:String = (songsLoaded[i].songName + ((songsLoaded[i].isInst) ? " Inst" : ""));
			if (texttosay.startsWith("["))
				if (texttosay.endsWith("t"))
					texttosay = "REDACTED Inst";
				else
					texttosay = "REDACTED";
			var text = new Alphabet(0, 0, texttosay, true);
			text.targetY = i;
			text.inOST = true;
			text.isMenuItem = true;
			add(text);
			songsLoadedText.push(text);
			var iconName = songsLoaded[i].iconState != MUSIC ? songsLoaded[i].iconName : "music";
			var icon = new HealthIcon(iconName);
			icon.sprTracker = text;
			var iconFrame = 0;
			switch (songsLoaded[i].iconState)
			{
				case NORMAL | MUSIC:
					iconFrame = 0;
				case LOSING:
					iconFrame = 1;
				case WINNING:
					iconFrame = 2;
			}
			icon.animation.curAnim.curFrame = iconFrame;
			songsLoadedIcon.push(icon);
			add(icon);
		}
		hideBar();
		changeSelection();
		super.create();
	}

	function hideBar()
	{
		healthBarBG.alpha = 0;
		healthBar.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		iconWell.alpha = 0;
		timeTxt.alpha = 0;
		FlxG.mouse.visible = false;
	}

	function changeSelection(change:Int = 0)
	{
		if (isPlayingMusic)
			return;

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songsLoaded.length - 1;
		if (curSelected >= songsLoaded.length)
			curSelected = 0;

		var diff:Int = 0;
		if (colorTween != null)
			colorTween.cancel();
		colorTween = FlxTween.color(bg, 1, bg.color, songsLoaded[curSelected].iconColor, {
			onComplete: function(twn:FlxTween)
			{
				colorTween = null;
			},
			ease: ease
		});

		for (i in 0...songsLoadedIcon.length)
		{
			FlxTween.cancelTweensOf(songsLoadedIcon[i]);
			if (i != curSelected)
				songsLoadedIcon[i].alpha = 0.6;
			else
				songsLoadedIcon[i].alpha = 1;
		}

		for (item in songsLoadedText)
		{
			FlxTween.cancelTweensOf(item);
			item.targetY = diff - curSelected;
			diff++;
			if (item.targetY != 0)
			{
				item.alpha = 0.6;
			}
			else
			{
				item.alpha = 1;
			}
		}
	}

	function showBar()
	{
		FlxTween.tween(healthBarBG, {alpha: 1}, 0.15, {ease: ease});
		FlxTween.tween(healthBar, {alpha: 1}, 0.15, {ease: ease});
		FlxTween.tween(iconP2, {alpha: 1}, 0.15, {ease: ease});
		if (songsLoaded[curSelected].iconState != MUSIC)
			FlxTween.tween(iconP1, {alpha: 1}, 0.15, {ease: ease});
		if (songsLoaded[curSelected].songName.startsWith("Snacker") && !ClientPrefs.songsLoaded.exists("snacker-eduardo"))
		{
			FlxTween.tween(iconWell, {alpha: 0.02}, 0.15, {ease: ease});
			FlxG.mouse.visible = true;
		}
		FlxTween.tween(timeTxt, {alpha: 1}, 0.15, {ease: ease});
	}

	function completedSong()
	{
		vocals.time = 0;
		vocals.play(true);
		vocals.volume = ClientPrefs.vocalsVol;
	}

	public function ostChecker()
	{
		new FlxTimer().start(FlxG.elapsed, function(flxtimer:FlxTimer = null)
		{
			if (isPlayingMusic && !paused && (FlxG.sound.volume > 0.2 && !FlxG.sound.muted))
			{
				FlxG.save.data.timeinOST += FlxG.elapsed;
				FlxG.save.flush();
				if (Math.floor(FlxG.save.data.timeinOST / 60) == 20) // 20 minutes
				{
					var achieveID:Int = Achievements.getAchievementIndex('banger_songs');
					if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
					{
						Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
						giveAchievement();
						ClientPrefs.saveSettings();
					}
				}
			}
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[Achievements.getAchievementIndex('banger_songs')][2]))
				ostChecker();
		});
	}

	function giveAchievement()
	{
		add(new AchievementObject('banger_songs', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	function refreshText()
	{
		var curTime = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000);
		var endTime = FlxStringUtil.formatTime(FlxG.sound.music.length / 1000);
		timeTxt.text = '$curTime / $endTime';
		timeTxt.text += (paused ? "\nPAUSED" : "");
		timeTxt.text += "\n";
	}

	override function update(elapsed:Float)
	{
		FlxG.autoPause = !isPlayingMusic; // too lazy to make a better implentation
		Conductor.songPosition = FlxG.sound.music.time;
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var yes = controls.ACCEPT;
		var no = controls.BACK;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		refreshText();
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(iconWell) && iconWell.alpha > 0)
		{
			yes = !paused; // pause it manually
			openSubState(new UnlockedNewSongSubState("snacker-eduardo", "eduardo", function hi()
			{
				FlxG.resetState();
			}));
		}
		#if desktop
		if (isPlayingMusic)
		{
			if (songsLoaded[curSelected].isInst)
				DiscordClient.changePresence("In OST Menu", '${paused ? 'Paused on' : 'Listening to'} ${songsLoaded[curSelected].songName} Inst',
					iconP2.getCharacter(), !paused, paused ? null : (FlxG.sound.music.length - FlxG.sound.music.time));
			else
				DiscordClient.changePresence("In OST Menu", '${paused ? 'Paused on' : 'Listening to'} ${songsLoaded[curSelected].songName}',
					iconP2.getCharacter(), !paused, paused ? null : (FlxG.sound.music.length - FlxG.sound.music.time));
		}
		else
		{
			DiscordClient.changePresence("In OST Menu", 'Looking for next song...');
		}
		#end
		if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 2;
			iconWell.animation.curAnim.curFrame = 2;
		}
		else if (healthBar.percent > 80)
		{
			iconP2.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 2;
			iconWell.animation.curAnim.curFrame = 1;
		}
		else
		{
			iconP2.animation.curAnim.curFrame = 0;
			iconP1.animation.curAnim.curFrame = 0;
			iconWell.animation.curAnim.curFrame = 0;
		}
		if (iconP2.alpha == 1 && !isPlayingMusic)
			hideBar();
		if (yes && !isPlayingMusic && songsLoadedIcon[curSelected].getCharacter() != "lock")
		{
			isPlayingMusic = true;
			showBar();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			var iconp2char:String = songsLoaded[curSelected].iconName;
			if (songsLoaded[curSelected].iconState == MUSIC)
				iconp2char = "music";
			if (songsLoaded[curSelected].iconName == "pimbog")
				iconP2.setGraphicSize(150, 150);
			iconP2.changeIcon(iconp2char);
			if (!ClientPrefs.ogHpBar)
			{
				var bfColor = FlxColor.fromRGB(49, 176, 209);
				if (songsLoaded[curSelected].iconState == MUSIC)
					bfColor = 0xFFFF0000;
				healthBar.createFilledBar(songsLoaded[curSelected].iconColor, bfColor);
			}
			if (songsLoaded[curSelected].iconState == MUSIC)
			{
				FlxG.sound.playMusic(Paths.music(songsLoaded[curSelected].iconName));
				if (vocals != null)
				{
					vocals.stop();
					FlxG.sound.list.remove(vocals);
					vocals = null;
				}
			}
			else
			{
				if (!songsLoaded[curSelected].isInst)
					vocals = new FlxSound().loadEmbedded(Paths.voices(songsLoaded[curSelected].songName, 0));
				else
					vocals = new FlxSound();

				FlxG.sound.playMusic(Paths.inst(songsLoaded[curSelected].songName), ClientPrefs.instVol);
				vocals.play(true);
				vocals.volume = ClientPrefs.vocalsVol;
				FlxG.sound.list.add(vocals);
				FlxG.sound.music.onComplete = completedSong;
			}
			for (i in 0...songsLoadedText.length)
			{
				if (i == curSelected)
					songsLoadedText[i].alpha = 1;
				else
				{
					FlxTween.completeTweensOf(songsLoadedText[i]);
					FlxTween.tween(songsLoadedText[i], {alpha: 0.0}, 0.15, {ease: ease});
				}
			}
			for (i in 0...songsLoadedIcon.length)
			{
				if (i == curSelected)
					songsLoadedIcon[i].alpha = 1;
				else
				{
					FlxTween.completeTweensOf(songsLoadedIcon[i]);
					FlxTween.tween(songsLoadedIcon[i], {alpha: 0.0}, 0.15, {ease: ease});
				}
			}
			refreshText();
		}
		else if (yes && !isPlayingMusic)
			FlxG.sound.play(Paths.sound("cancelMenu"));
		else if (no)
		{
			if (!isPlayingMusic)
				MusicBeatState.switchState(new ExtraMenuState());
			else
			{
				resetMenuTheme();
			}
			paused = false;
			hideBar();
			changeSelection();
			FlxG.sound.play(Paths.sound("cancelMenu"));
		}
		else if (upP || downP)
			changeSelection((upP) ? -1 : 1);
		else if (yes && isPlayingMusic)
		{
			if (!paused)
			{
				if (vocals != null)
					vocals.pause();
				FlxG.sound.music.pause();
				paused = true;
			}
			else
			{
				if (vocals != null)
					vocals.resume();
				FlxG.sound.music.resume();
				paused = false;
			}
			refreshText();
		}
		else if ((leftP || rightP) && isPlayingMusic)
		{
			if (leftP)
			{
				if (FlxG.sound.music.time <= 5000)
				{
					if (vocals != null)
						vocals.time = 0;
					FlxG.sound.music.time = 0;
				}
				else
				{
					if (vocals != null)
						vocals.time -= 5000;
					FlxG.sound.music.time -= 5000;
				}
			}
			else if (rightP)
			{
				if ((FlxG.sound.music.length - FlxG.sound.music.time) <= 5000)
				{
					if (vocals != null)
						vocals.time = 0;
					FlxG.sound.music.time = 0;
				}
				else
				{
					if (vocals != null)
						vocals.time += 5000;
					FlxG.sound.music.time += 5000;
				}
			}
			refreshText();
		}
		playdist = 1 - (FlxG.sound.music.time / FlxG.sound.music.length);
		var iO = 26;
		if (songsLoaded[curSelected].iconState == MUSIC)
			iO = 52;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iO);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iO);
		iconWell.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (iconWell.width - iO + iconP2.width)
			+ 8;
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	function resetMenuTheme()
	{
		isPlayingMusic = false;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
		Conductor.bpmChangeMap = [];
		Conductor.changeBPM(160);
		if (vocals != null)
		{
			vocals.stop();
			FlxG.sound.list.remove(vocals);
		}
		FlxG.sound.music.onComplete = null;
		if (Main.fpsVar.memoryMegas > 1500)
			Paths.clearStoredMemory(false);
	}
}

class OSTSongMetadata
{
	public var songName:String;
	public var isInst:Bool;
	public var iconName:String;
	public var iconColor:FlxColor;
	public var iconState:IconState;

	public function new(songName:String, isInst:Bool = false, iconName:String = "music", iconColor:FlxColor = 0xff33ffff, iconState:IconState = NORMAL)
	{
		this.songName = songName;
		this.isInst = isInst;
		this.iconName = iconName;
		this.iconColor = iconColor;
		this.iconState = iconState;
	}
}

enum IconState
{
	NORMAL;
	LOSING;
	WINNING;
	MUSIC; // need to do this for other songs
}
