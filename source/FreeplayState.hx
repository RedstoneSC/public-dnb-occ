package;

import openfl.media.Sound;
import flixel.util.FlxTimer;
import Achievements.AchievementObject;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	public static var curSelected:Int = 0;

	var curDifficulty:Int = 1;

	private static var lastDifficultyName:String = '';

	public static var initGoTo = false;

	public static var noMove = false;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var onRedacted = false;
	var redactedSong:FlxSound = null;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var categories = ["main", "extra", "joke", "secret", "og"];

	public static var curCategory = 0;

	var inCategory = true;

	var categoryIcons:Array<FlxSprite> = [];
	var stuffs:Array<FlxSprite> = [];

	public static var lockedSongs = [
		#if !STREAMER
		"snacker-eduardo", "snacker-eduardo-old", "snacker-eduardo-older", "heheheha", "breaking-madness"
		#end
	];

	var lockedSongsDesc = [
		#if !STREAMER
		"WELL WELL WELL", "WELL WELL WELL but old", "WELL WELL WELL but older", "HEHEHEHA GRR", "PHONE PHONE PHONE PH7NE!!!"
		#end
	];

	public static var skipCharSelectSongs = [
		"poppin", "darker", "shadowed", "[redacted]", "bogos-binted", "alien-language", "poppin-old", "poppin-older", "breaking-madness", "console",
		"budget-quingen", "poppin-oldest"
	];

	var text:FlxText;
	var menuStuffs:Array<FlxSprite> = [];
	var newDaveSong = false;
	var loops = 0;
	var justUnlocked = false;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	public static var pcOnFire = false;

	function giveAchievement()
	{
		var achieveID:Int = Achievements.getAchievementIndex('pc_fire');
		if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
		{
			Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
			add(new AchievementObject('pc_fire'));
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			pcOnFire = false;
			ClientPrefs.saveSettings();
		}
		else
		{
			return;
		}
	}

	var bgimage = null;
	var categoryText:FlxText;

	override function create()
	{
		if (FlxG.save.data.newDaveSong != null) // lmfaooooooo i forgor about this (raf from like 5 months later or something)
			newDaveSong = false; // FlxG.save.data.newDaveSong;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isFreeplay = true;
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bgimage = MainMenuState.randomBG();
		bg = new FlxSprite().loadGraphic(bgimage);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		scoreText = new FlxText(FlxG.width * 0.7, -5, 0, "", 32);
		scoreText.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 22);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);
		stuffs.push(scoreText);
		stuffs.push(scoreBG);
		stuffs.push(diffText);
		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = 0xFF4965FF;
		intendedColor = 0xFF4965FF;

		if (lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		stuffs.push(textBG);

		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow = new FlxSprite(4, 20);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.scale.set(0.95, 0.95);
		add(leftArrow);
		leftArrow.screenCenter(Y);
		rightArrow = new FlxSprite(leftArrow.x + FlxG.width - 55, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.scale.set(0.95, 0.95);
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.screenCenter(Y);
		add(rightArrow);
		categoryText = new FlxText(0, FlxG.height - 60, FlxG.width, '${curCategory + 1}/${categories.length}', 40);
		categoryText.setFormat(Paths.font("comic.ttf"), 40, FlxColor.BLACK, CENTER);
		categoryText.screenCenter(X);
		add(categoryText);
		text = new FlxText(textBG.x, textBG.y, FlxG.width, leText, size);
		text.setFormat(Paths.font("comic.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		stuffs.push(text);
		for (stuff in stuffs)
		{
			stuff.visible = false;
		}
		for (i in 0...categories.length)
		{
			var categoryIcon = new FlxSprite().loadGraphic(Paths.image("freeplayCategories/" + categories[i]));
			categoryIcon.screenCenter();
			categoryIcon.x += i * 1280;
			add(categoryIcon);
			categoryIcons.push(categoryIcon);
		}
		for (icon in categoryIcons)
		{
			FlxTween.tween(icon, {x: ((categoryIcons.indexOf(icon) - curCategory) * 1280) + ((FlxG.width - icon.width) / 2)}, theDurationOfTween, {
				ease: easeingInTween
			});
		}
		if (pcOnFire)
		{
			giveAchievement();
		}
		if (initGoTo)
		{
			var lol = curSelected;
			curSelected = 0;
			getSongs(categories[curCategory]);
			changeSelection(lol);
			changeDiff();
			inCategory = false;
			for (icon in categoryIcons)
			{
				icon.visible = false;
			}
			rightArrow.visible = false;
			leftArrow.visible = false;
			categoryText.visible = false;
		}
		super.create();
	}

	override function closeSubState()
	{
		if (songs.length > 0)
			changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, ?diff:Array<String>)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, (diff != null) ? diff : null));
	}

	function removeSongs()
	{
		songs = [];
		for (member in grpSongs.members)
		{
			remove(member);
		}
		for (icon in iconArray)
		{
			remove(icon);
		}
		iconArray = [];
		grpSongs.members = [];
	}

	function getSongs(fileName:String)
	{
		removeSongs();
		for (stuff in stuffs)
		{
			stuff.visible = true;
		}

		var leWeek:WeekData = new WeekData(WeekData.getWeekFile("assets/weeks/freeplay/" + fileName + ".json"));
		var leSongs:Array<String> = [];
		var leChars:Array<String> = [];
		for (j in 0...leWeek.songs.length)
		{
			leSongs.push(leWeek.songs[j][0]);
			leChars.push(leWeek.songs[j][1]);
		}
		for (song in leWeek.songs)
		{
			var colors:Array<Int> = song[2];
			if (colors == null || colors.length < 3)
			{
				colors = [146, 113, 253];
			}
			var songName:String = song[0];
			if (["[redacted]"].contains(songName.toLowerCase()))
			{
				if (newDaveSong && curCategory == 0)
					addSong("Roses", 0, "face", 0xffee69aa);
				if (!ClientPrefs.songsLoadedSecret.exists(songName.toLowerCase()))
					continue;
			}
			addSong(song[0], 0, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), if (song[3] != null) song[3] else ["Easy", "Normal", "Hard"]);
		}
		for (i in 0...songs.length)
		{
			if (lockedSongs.contains(songs[i].songName.toLowerCase()) && !ClientPrefs.songsLoaded.exists(songs[i].songName.toLowerCase()))
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, "Hidden Song", true, false);
				songText.inFreeplay = true;
				songText.isMenuItem = true;
				songText.targetY = i;
				grpSongs.add(songText);

				var icon:HealthIcon = new HealthIcon("lock");
				icon.sprTracker = songText;
				icon.offsets[0] += 40;
				songs[i].color = CoolUtil.dominantColor(icon);
				iconArray.push(icon);
				add(icon);
			}
			else
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
				songText.inFreeplay = true;
				songText.isMenuItem = true;
				songText.targetY = i;
				grpSongs.add(songText);

				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;

				iconArray.push(icon);
				add(icon);
			}
		}
		if (curCategory == 0 && newDaveSong && justUnlocked)
		{
			var thing = songs.length - curSelected;

			changeSelection(thing - 1);
			changeDiff();
		}
		reloadColor();
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
		{
			if (songCharacters == null)
				songCharacters = ['bf'];

			var num:Int = 0;
			for (song in songs)
			{
				addSong(song, weekNum, songCharacters[num]);
				this.songs[this.songs.length-1].color = weekColor;

				if (songCharacters.length != 1)
					num++;
			}
	}*/
	var holdTime:Float = 0;

	var easeingInTween = FlxEase.cubeInOut;
	var easeingOutTween = FlxEase.cubeInOut;
	var theDurationOfTween = 0.2;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;
		if (!inCategory && iconArray.length > 0)
		{
			if (!noMove)
			{
				if (songs.length > 1)
				{
					if (upP)
					{
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (downP)
					{
						changeSelection(shiftMult);
						holdTime = 0;
					}

					if (controls.UI_DOWN || controls.UI_UP)
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10); // what the hell is this

						if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						{
							changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
						}
					}
				}

				if (controls.UI_LEFT_P)
					changeDiff(-1);
				else if (controls.UI_RIGHT_P)
					changeDiff(1);
				else if (upP || downP)
					changeDiff();

				if (controls.BACK)
				{
					for (stuff in stuffs)
					{
						stuff.visible = false;
					}
					inCategory = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					categoryIcons[curCategory].visible = true;
					categoryIcons[curCategory].alpha = 0;
					rightArrow.visible = true;
					leftArrow.visible = true;
					categoryText.visible = true;
					changeSelection(0 - curSelected, false);
					for (icon in categoryIcons)
					{
						FlxTween.tween(icon, {alpha: 1, y: categoryIcons[curCategory].y - 200}, theDurationOfTween, {ease: easeingOutTween});
					}

					if (colorTween != null)
					{
						colorTween.cancel();
					}
					intendedColor = 0xFF4965FF;
					colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
						onComplete: function(twn:FlxTween)
						{
							colorTween = null;
						}
					});
					removeSongs();
					return;
				}

				if (ctrl)
				{
					persistentUpdate = false;
					openSubState(new GameplayChangersSubstate());
				}
				else if (accepted)
				{
					if (iconArray[curSelected] == null
						|| (iconArray[curSelected] != null) ? iconArray[curSelected].getCharacter() != "lock" : true)
					{
						persistentUpdate = false;
						var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
						var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

						PlayState.storyPlaylist = [];
						PlayState.SONG = Song.loadFromJson(poop, songLowercase);
						PlayState.isStoryMode = ClientPrefs.freeplayCutscenes;
						PlayState.isFreeplay = true;
						PlayState.storyDifficulty = curDifficulty;
						PlayState.diffBf = ["false", "default"];
						if (colorTween != null)
						{
							colorTween.cancel();
						}
						#if !release
						if (FlxG.keys.pressed.SHIFT)
						{
							LoadingState.loadAndSwitchState(new ChartingState());
						}
						else
						#end
						{
							if (ClientPrefs.charSelect.contains("Freeplay")
								&& !skipCharSelectSongs.contains(songs[curSelected].songName.toLowerCase()))
							{
								CharacterSelectState.backColor = songs[curSelected].color;
								LoadingState.loadAndSwitchState(new CharacterSelectState(), true);
							}
							else
								LoadingState.loadAndSwitchState(new PlayState());
						}
					}
				}
				else if (accepted)
					FlxG.sound.play(Paths.sound("cancelMenu"));
				else if (FlxG.keys.justPressed.R && iconArray[curSelected].getCharacter() != "lock")
				{
					openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else if (FlxG.keys.justPressed.R)
					FlxG.sound.play(Paths.sound("cancelMenu"));
			}
		}
		else
		{
			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');
			if (controls.UI_LEFT_P && !noMove)
			{
				if (curCategory == 0)
				{
					curCategory = categories.length - 1;
					for (icon in categoryIcons)
					{
						FlxTween.tween(icon, {x: (((categoryIcons.length - 1) - categoryIcons.indexOf(icon)) * -1280) + ((FlxG.width - icon.width) / 2)},
							theDurationOfTween, {
								ease: easeingInTween
							});
					}
				}
				else
				{
					curCategory--;
					for (icon in categoryIcons)
					{
						FlxTween.tween(icon, {x: ((curCategory - categoryIcons.indexOf(icon)) * -1280) + ((FlxG.width - icon.width) / 2)}, theDurationOfTween,
							{
								ease: easeingInTween,
							});
					}
				}
				categoryText.text = '${curCategory + 1}/${categories.length}';
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.UI_RIGHT_P && !noMove)
			{
				if (curCategory == categories.length - 1)
				{
					curCategory = 0;
					for (icon in categoryIcons)
					{
						FlxTween.tween(icon, {x: (categoryIcons.indexOf(icon) * 1280) + ((FlxG.width - icon.width) / 2)}, theDurationOfTween, {
							ease: easeingInTween
						});
					}
				}
				else
				{
					curCategory++;
					for (icon in categoryIcons)
					{
						FlxTween.tween(icon, {x: ((categoryIcons.indexOf(icon) - curCategory) * 1280) + ((FlxG.width - icon.width) / 2)}, theDurationOfTween, {
							ease: easeingInTween
						});
					}
				}
				categoryText.text = '${curCategory + 1}/${categories.length}';
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (accepted)
			{
				FlxTween.tween(categoryIcons[curCategory], {alpha: 0, y: categoryIcons[curCategory].y + 200}, theDurationOfTween / 1.25, {
					ease: easeingOutTween,
					onComplete: function(_)
					{
						getSongs(categories[curCategory]);
						changeSelection();
						changeDiff();
						inCategory = false;
						noMove = false;
						categoryText.visible = false;
					}
				});
				noMove = true;
				rightArrow.visible = false;
				leftArrow.visible = false;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.BACK)
			{
				persistentUpdate = false;
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}
		super.update(elapsed);
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;

		if (curSelected >= songs.length)
		{
			curSelected = 0;
			if (curCategory == 0 && !newDaveSong)
			{
				loops++;
				if (loops > 1000000000)
				{
					newDaveSong = true;
					justUnlocked = true;
					FlxG.save.data.newDaveSong = true;
					FlxG.save.flush();
					getSongs(categories[curCategory]);
					FlxG.sound.play(Paths.sound("confirmMenu"));
				}
			}
		}

		reloadColor();

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5
		if (iconArray[curSelected].getCharacter() == "lock")
			CoolUtil.difficulties = ["LOCKED"];
		else if (songs[curSelected].difficulties.length > 0 && songs[curSelected].difficulties != null)
			CoolUtil.difficulties = songs[curSelected].difficulties;
		else if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if (songs[curSelected].songName.toLowerCase() == "[redacted]") // this was pain
		{
			onRedacted = true;
			FlxG.sound.music.pause();
			if (redactedSong == null)
			{
				redactedSong = new FlxSound().loadEmbedded(Paths.music("redacteddialogue"));
				FlxG.sound.list.add(redactedSong);
			}
			redactedSong.play();
		}
		else if (onRedacted)
		{
			FlxG.sound.music.resume();
			onRedacted = false;
			redactedSong.stop();
		}
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		text.text = "Press CTRL to open the Gameplay Changers Menu / ";
		if (lockedSongs.contains(songs[curSelected].songName.toLowerCase())
			&& !ClientPrefs.songsLoaded.exists(songs[curSelected].songName.toLowerCase()))
			text.text += lockedSongsDesc[lockedSongs.indexOf(songs[curSelected].songName.toLowerCase())];
		else
		{
			text.size = 18;
			text.text += "Press RESET to Reset your Score and Accuracy.";
			if (Main.loudSongs.contains(songs[curSelected].songName.toLowerCase()))
			{
				text.text += " / LOUD WARNING!";
				text.size -= 1;
			}
		}
		if (songs[curSelected].songName == "[REDACTED]")
		{
			text.text = "Cerff PGEY gb bcra gur Tnzrcynl Punatref Zrah / Cerff ERFRG gb Erfrg lbhe Fpber naq Npphenpl.";
			bg.loadGraphic(Paths.occurPath("unknown", IMAGES, false));
		}
		else
			bg.loadGraphic(bgimage);
	}

	function reloadColor()
	{
		var newColor:Int = songs[curSelected].color;

		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var difficulties = [];

	public function new(song:String, week:Int, songCharacter:String, color:Int, ?difficulties:Array<String>)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		if (difficulties != null)
			this.difficulties = difficulties;
	}
}
