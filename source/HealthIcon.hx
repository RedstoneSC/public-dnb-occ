package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var offsets = [0, 0];
	public var isOldIcon:Bool = false;

	private var isPlayer:Bool = false;
	private var char:String = null;
	private var alwaysChar:String = null;
	private var inPlayState = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, inPlayState = false)
	{
		super();
		this.inPlayState = inPlayState;
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sprTracker != null)
		{
			if (inPlayState)
				setPosition(sprTracker.x + offsets[0], sprTracker.y + offsets[1]);
			else
				setPosition(sprTracker.x + sprTracker.width + 10 + offsets[0], sprTracker.y - 30 + offsets[1]);
		}
	}

	public function swapOldIcon()
	{
		isOldIcon = (isOldIcon) ? false : true;
		if (isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon(alwaysChar); // fixed
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			var name:String = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/icons/icon-' + char + '.png', IMAGE))
			{
				name = 'icons/icon-face'; // Prevents crash from missing icon
				if (char != "lock")
					char = "face";
			}

			var file:Dynamic = Paths.image(name);

			if (char == "lock")
			{
				loadGraphic(Paths.image("locked"));
				loadGraphic(Paths.image("locked"), true, Math.floor(width), Math.floor(height));
				iconOffsets[0] = (width - 150);
				iconOffsets[1] = (width - 150);
				animation.add(char, [0, 0, 0]);
			}
			else if ([
				"redacted",
				"music",
				"brick",
				"leanman",
				"",
				"_",
				"trioiconig",
				"moneymbi",
				"boypal"
			].contains(char))
			{
				loadGraphic(file); // Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width), Math.floor(height)); // Then load it fr
				iconOffsets[0] = (width - 150) / 3;
				iconOffsets[1] = (width - 150) / 3;
				updateHitbox();
				animation.add(char, [0, 0, 0], 0, false, isPlayer);
			}
			else if (["expunged", "bambianger"].contains(char))
			{
				loadGraphic(file); // Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); // Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();
				animation.add(char, [0, 1, 0], 0, false, isPlayer);
			}
			else
			{
				loadGraphic(file); // Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width / 3), Math.floor(height)); // Then load it fr
				iconOffsets[0] = (width - 150) / 3;
				iconOffsets[1] = (width - 150) / 3;
				updateHitbox();
				animation.add(char, [0, 1, 2], 0, false, isPlayer);
			}
		}
		animation.play(char);
		this.char = char;
		if (alwaysChar == null)
			alwaysChar = char;
		isOldIcon = (char == 'bf-old');
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}
}
