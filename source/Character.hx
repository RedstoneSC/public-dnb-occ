package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;
import haxe.Json;

using StringTools;

typedef CharacterFile =
{
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; // Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; // Character use "danceLeft" and "danceRight" instead of "idle"
	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	var isAltChar:Bool = false;

	// Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	var idleLooped = false;

	public static var DEFAULT_CHARACTER:String = 'bf'; // In case a character is missing, it will use BF on its place

	function isCurAnimName(name:String)
	{
		if (animation.curAnim == null)
			return false;
		if (animation.curAnim.name.toLowerCase().startsWith(name.toLowerCase()))
			return true;
		else
			return false;
	}

	public function tryIdle(idle:Bool)
	{
		if ((isCurAnimName("sing") && holdTimer < Conductor.stepCrochet * 0.001 * singDuration) || (idleLooped && isCurAnimName("idle")))
		{
			return false;
		}
		if (danceIdle)
		{
			dance();
			return true;
		}
		else if (idle)
		{
			dance();
			return true;
		}
		return false;
	}

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?isAltChar:Bool = false)
	{
		super(x, y);

		animOffsets = new Map();
		curCharacter = character;
		this.isPlayer = isPlayer;
		this.isAltChar = isAltChar;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		switch (curCharacter)
		{
			// case 'your character name in case you want to hardcode them instead':

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';

				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				{
					if (!curCharacter.startsWith("gf"))
						path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER +
							'.json'); // If a character couldn't be found, change him to BF just to prevent a crash
					else
						path = Paths.getPreloadPath('characters/gf.json');
				}

				var rawJson = Assets.getText(path);

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				// sparrow
				// packer
				// texture

				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
				{
					spriteType = "packer";
				}

				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
				{
					spriteType = "texture";
				}

				switch (spriteType)
				{
					case "packer":
						frames = Paths.getPackerAtlas(json.image);

					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
				}

				imageFile = json.image;

				if (json.scale != 1)
				{
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if (json.no_antialiasing)
				{
					antialiasing = false;
					noAntialiasing = true;
				}

				if (json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if (!ClientPrefs.globalAntialiasing)
					antialiasing = false;

				animationsArray = json.animations;
				if (animationsArray != null && animationsArray.length > 0)
				{
					for (anim in animationsArray)
					{
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; // Bruh
						var animIndices:Array<Int> = anim.indices;
						if (animAnim.toLowerCase() == "idle" && animLoop)
						{
							idleLooped = true;
						}
						if (animIndices != null && animIndices.length > 0)
						{
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						}
						else
						{
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}
						if (anim.offsets != null && anim.offsets.length > 1)
						{
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				}
				else
				{
					quickAnimAdd('idle', 'BF idle dance');
				}
				// trace('Loaded file to character ' + curCharacter);
		}
		originalFlipX = flipX;

		if (animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss'))
			hasMissAnimations = true;
		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;
		}
		if (!PlayState.floatBois.contains(curCharacter.toLowerCase()))
			floatMult = 0;
		switch (curCharacter.toLowerCase())
		{
			case "cosmic" | "cosmicnew":
				floatMult = 1.7;
			case "redacted":
				floatMult = 0.2;
			case "dollarmbi" | "dollarmbimove":
				floatMult = 0.4;
			case "gerald":
				floatMult = 0.5;
			case "expunged":
				floatMult = 0.825;
		}
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (heyTimer > 0)
			{
				heyTimer -= elapsed;
				if (heyTimer <= 0)
				{
					if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			}
			else if (specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}
			else if (isAltChar)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}
				else
					holdTimer = 0;
				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				{
					playAnim('idle', true, false, 0);
				}
			}
			if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		if ((!isPlayer && color == 0xff6f0b5f) || (isPlayer && color != 0xff6f0b5f)) // not overriding miss
			if (PlayState.instance != null
				&& color != PlayState.instance.characterColor
				&& !(curCharacter.toLowerCase().contains("cosmic") && isPlayer && PlayState.instance.endingSong))
				color = PlayState.instance.characterColor;
			else if (color != 0xff000000 && PlayState.instance == null) // fix for locked chars charselect
				color = 0xffffffff; // fallback for character select
		super.update(elapsed);
	}

	public var danced:Bool = false;

	var floatMult = 0.9;

	public function float(dimeadozen:Float)
	{
		if (curCharacter == "flumbo" && PlayState.instance.triangle != null && !isPlayer)
		{
			var flumbo = Math.sin(dimeadozen * 1.75) * 500;
			x = (PlayState.instance.triangle.getGraphicMidpoint().x + flumbo) - 300;
			y += (Math.sin(dimeadozen) * 0.5);
			flumbo = FlxMath.roundDecimal(flumbo / 500, 3);
			if (Math.abs(flumbo) == 1)
				PlayState.instance.flipTriangleDadIndex(flumbo);
		}
		else
			y += (Math.sin(dimeadozen) * (floatMult + FlxG.elapsed / 2));
		if (curCharacter == "expunged" && !isPlayer)
			x += (Math.sin(dimeadozen * 1.6) * (2.15 + FlxG.elapsed / 2));
	}

	public function dance()
	{
		if (!debugMode && !specialAnim)
		{
			if (danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix, true);
				else
					playAnim('danceLeft' + idleSuffix, true);
			}
			else if (animation.getByName('idle' + idleSuffix) != null)
			{
				playAnim('idle' + idleSuffix, true);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);
		if (color == 0xff6f0b5f)
			color = PlayState.instance.characterColor;

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function recalculateDanceIdle()
	{
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
