package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import editors.ChartingState;

using StringTools;

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var noHitsound:Bool = false;
	public var animSuffix:String = "";
	public var blockHit:Bool = false;
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var tooLate:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;
	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	public var altCharNote:Bool = false;
	public var earlyMissMult:Float = 1.5;

	private var earlyHitMult:Float = 0.5;
	private var cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

	public static var swagWidth:Float = 160 * 0.7;

	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var myStrum:Int = 0;
	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var scrollSpeed(default, set):Float = 0; // funni unfairness reference
	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000;

	public function refreshBotplay()
	{
		cpuControlled = PlayState.instance.cpuControlled;
	}

	private function set_scrollSpeed(value:Float)
	{
		var ratio:Float = value / scrollSpeed;
		if (isSustainNote && animation.curAnim != null)
		{
			if (!animation.curAnim.name.endsWith('end'))
			{
				scale.y *= ratio;
				updateHitbox();
			}
		}
		scrollSpeed = value;
		return value;
	}

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String
	{
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Green Corn Note':
					ignoreNote = mustPress;
					reloadNote('GHURT');
					noteSplashTexture = 'GHURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if (isSustainNote)
					{
						missHealth = 0.1;
					}
					else
					{
						missHealth = 0.3;
					}
					hitCausesMiss = true;
					earlyMissMult = 1;
				case '3D Hurt Note':
					ignoreNote = mustPress;
					reloadNote("COSMIC");
					noteSplashTexture = 'COSMICnotesplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if (isSustainNote)
					{
						missHealth = 0.1;
					}
					else
					{
						missHealth = 0.3;
					}
					hitCausesMiss = true;
					earlyMissMult = 1;
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if (isSustainNote)
					{
						missHealth = 0.1;
					}
					else
					{
						missHealth = 0.3;
					}
					earlyMissMult = 1;
					hitCausesMiss = true;
				case 'No Animation':
					noAnimation = true;
				case 'Alt Char Sing'  | "Both Sing" | "All Three Sing":
					altCharNote = true;
				case "Alt Animation":
					animSuffix = "-alt";
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();
		active = !inEditor;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		noHitsound = isSustainNote;
		this.inEditor = inEditor;
		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if (!inEditor)
		{
			this.strumTime += ClientPrefs.noteOffset;
		}
		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = 'NOTE_assets'; // did this to fix bug
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % 4);
			if (!isSustainNote)
			{ // Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);
		if (scrollSpeed == 0 && !inEditor)
		{
			scrollSpeed = PlayState.instance.songSpeed;
			if (PlayState.SONG.song.toLowerCase() == "[redacted]")
				scrollSpeed = FlxG.random.float(1.5, 3.75);
			else if (PlayState.SONG.song.toLowerCase() == "errorless")
				scrollSpeed = FlxG.random.float(3, 3.6);
		}
		if (isSustainNote && prevNote != null)
		{
			scrollSpeed = prevNote.scrollSpeed;
			alpha = 0.6;
			if (ClientPrefs.downScroll)
				flipY = true;

			offsetX += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			offsetX -= width / 2;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;

				prevNote.scale.y *= scrollSpeed;

				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}
		x += offsetX;
		alpha *= ClientPrefs.noteAlpha;
		if (ClientPrefs.middleScroll && !mustPress)
		{
			alpha *= 0.5;
		}
	}

	var lastNoteScaleToo:Float = 1;

	public var originalHeightForCalcs:Float = 6;

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (animation == null)
			return;
		else
		{
			if (prefix == null)
				prefix = '';
			if (texture == null)
				texture = '';
			if (suffix == null)
				suffix = '';
			var skin:String = texture;
			if (texture.length < 1)
			{
				skin = PlayState.SONG.arrowSkin;
				if (skin == null || skin.length < 1)
				{
					skin = 'NOTE_assets';
				}
			}

			var animName:String = null;

			if (animation.curAnim != null)
			{
				animName = animation.curAnim.name;
			}

			var arraySkin:Array<String> = skin.split('/');
			arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

			var lastScaleY:Float = scale.y;
			var blahblah:String = arraySkin.join('/');

			frames = Paths.getSparrowAtlas(blahblah);

			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;

			if (isSustainNote)
			{
				scale.y = lastScaleY;
			}
			updateHitbox();

			if (animName != null)
				animation.play(animName, true);

			if (inEditor)
			{
				setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
				updateHitbox();
			}
		}
	}

	function loadNoteAnims()
	{
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		setGraphicSize(Std.int(swagWidth));
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * earlyMissMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function setNoteTexture3D2D(changeSplash:Bool = true, changeTexture:Bool = true, force3D:Bool = false)
	{
		if ((noteType == null || noteType == "" || noteType.toLowerCase().contains("alt"))
			&& texture.startsWith("NOTE_assets")) // should work now
		{
			if (ClientPrefs.note3Dwhen == "3D" || force3D)
			{
				if (changeTexture)
					texture = "NOTE_assets_3D";
				if (changeSplash)
					noteSplashTexture = "noteSplashes_3D";
			}
			else
			{
				if (changeTexture)
					texture = "NOTE_assets";
				if (changeSplash)
					noteSplashTexture = "noteSplashes";
			}
		}
	}
}
