package;

import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

using StringTools;

class BGSprite extends FlxSprite
{
	public var spriteName:String;

	public function new(spriteName:String, posX:Float, posY:Float, path:FlxGraphic, scrollX:Float = 1, scrollY:Float = 1, antialiasing:Bool = true,
			active:Bool = false)
	{
		super(posX, posY);

		this.spriteName = spriteName;

		loadGraphic(path); // some issues with the dnb Paths.image returning an actual path and this not
		this.antialiasing = antialiasing;
		scrollFactor.set(scrollX, scrollY);
		this.active = active;
	}

	public static function getBGSprite(spriteGroup:FlxTypedGroup<BGSprite>, spriteName:String):BGSprite
	{
		for (bgSprite in spriteGroup.members)
		{
			if (bgSprite.spriteName == spriteName)
			{
				return bgSprite;
			}
		}
		return null;
	}
}
