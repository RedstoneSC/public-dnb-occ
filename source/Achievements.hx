import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef AchievementFile =
{
	var unlocksAfter:String;
	var icon:String;
	var name:String;
	var description:String;
	var hidden:Bool;
	var customGoal:Bool;
}

class Achievements
{
	public static var achievementShits:Array<Dynamic> = [
		// Name, Description, Achievement save tag, Hidden achievement
		["You know how to spell!", "Spell DAVE on the main menu.", "spell_dave", true],
		[
			"Too scared?",
			"Exit the song when Cosmic is in its final form in story mode.",
			"too_scared",
			false
		],
		[
			"True Gamer.",
			"Beat Console with on controller mode and no keyboard input.",
			"truegaming",
			false
		],
		[
			"Banger songs!",
			"Listen to songs in the OST for 20 minutes with a good amount of volume.",
			"banger_songs",
			false
		],
		[
			"Isn't your PC on fire?",
			"Beat HEHEHEHA without your game crashing.",
			"pc_fire",
			true
		]
	];

	public static var achievementsStuff:Array<Dynamic> = [
		// Gets filled when loading achievements
	];

	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static function unlockAchievement(name:String):Void
	{
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		ClientPrefs.saveSettings();
	}

	public static function lockAchievement(name:String):Void
	{
		achievementsMap.set(name, false);
		ClientPrefs.saveSettings();
	}

	public static function isAchievementUnlocked(name:String)
	{
		if (achievementsMap.exists(name))
		{
			return achievementsMap.get(name);
		}
		return false;
	}

	public static function getAchievementIndex(name:String)
	{
		for (i in 0...achievementsStuff.length)
		{
			if (achievementsStuff[i][2] == name)
			{
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void
	{
		achievementsStuff = [];
		achievementsStuff = achievementShits;

		if (FlxG.save.data != null)
		{
			if (FlxG.save.data.achievementsMap != null)
			{
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if (FlxG.save.data.achievementsUnlocked != null)
			{
				FlxG.log.add("Trying to load stuff");
				var savedStuff:Array<String> = FlxG.save.data.achievementsUnlocked;
				for (i in 0...savedStuff.length)
				{
					achievementsMap.set(savedStuff[i], true);
				}
			}
		}

		// shut
	}

	private static function getAchievementInfo(path:String):AchievementFile
	{
		var rawJson:String = null;

		if (OpenFlAssets.exists(path))
		{
			rawJson = Assets.getText(path);
		}

		if (rawJson != null && rawJson.length > 0)
		{
			return cast Json.parse(rawJson);
		}
		return null;
	}
}

class AttachedAchievement extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var tag:String;

	public function new(x:Float = 0, y:Float = 0, name:String)
	{
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String)
	{
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage()
	{
		if (Achievements.isAchievementUnlocked(tag))
		{
			loadGraphic(Paths.image('achievements/' + tag));
		}
		else
		{
			loadGraphic(Paths.image('lockedachievement'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;

	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achieveName:String = Achievements.achievementsStuff[id][0];
		var text:String = Achievements.achievementsStuff[id][1];

		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10,
			achievementBG.y + 10).loadGraphic(Paths.image('achievements/' + name), true, 150, 150);
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, achieveName, 16);
		achievementName.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();
		var size = 16;
		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, text, 16);
		achievementText.setFormat(Paths.font("comic.ttf"), size, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);
		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if (camera != null)
		{
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {
			onComplete: function(twn:FlxTween)
			{
				alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
					startDelay: 2.5,
					onComplete: function(twn:FlxTween)
					{
						alphaTween = null;
						remove(this);
						if (onFinish != null)
							onFinish();
					}
				});
			}
		});
	}

	override function destroy()
	{
		if (alphaTween != null)
		{
			alphaTween.cancel();
		}
		super.destroy();
	}
}
