package options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.ui.FlxBar;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	var onBar = false;
	var onNotes = false;
	var barBG:AttachedSprite;
	var bar:FlxBar;
	var health:Float = 1; // here as a dummy var
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	var i1T:FlxTween;
	var i2T:FlxTween;
	var notes:FlxTypedGroup<OptionNote>;
	var noteS:FlxTypedGroup<StrumNote>;

	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", 'noteSplashes', 'bool', true);
		addOption(option);
		var option:Option = new Option('Note texture: ', "What texture should the notes be?\n(Default is if the character is 3D)", 'note3Dwhen', 'string',
			'Default', ['2D', '3D', 'Default']);
		addOption(option);
		option.onChange = function()
		{
			for (note in notes)
			{
				note.is3D = ClientPrefs.note3Dwhen == "3D";
			}
			for (note in noteS)
			{
				note.is3D = ClientPrefs.note3Dwhen == "3D";
			}
		}
		var option:Option = new Option('Note opacity:', "Changes how opaque the notes are.\n(Press space to switch between 2D and 3D!)", "noteAlpha", "float",
			1);
		option.changeValue = 0.05;
		option.minValue = 0.75;
		option.scrollSpeed = 0.6;
		option.maxValue = 1.0;
		option.decimals = 2;
		option.onChange = function()
		{
			for (note in notes)
			{
				@:privateAccess
				note.refreshAlpha();
			}
		}
		addOption(option);
		var option:Option = new Option('Strum note opacity:', "Changes how opaque the strum notes are.\n(Press space to switch between 2D and 3D!)",
			"noteStrumAlpha", "float", 1);
		option.changeValue = 0.05;
		option.minValue = 0.5;
		option.scrollSpeed = 1.4;
		option.maxValue = 1.0;
		option.decimals = 2;
		option.onChange = function()
		{
			for (note in noteS)
			{
				note.reloadAlpha();
			}
		}
		addOption(option);

		var option:Option = new Option("3D Note Transforming",
			"If enabled, and your notes are 2D and the enemy's is 3D, then,\nthere is a chance for your notes to be 3D.", "note3D2Dtransform",
			"note3D2Dtransform", true);
		addOption(option);
		var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool', false);
		addOption(option);
		var option:Option = new Option('Colorblind Filter: ', 'You can set colorblind filter (makes the game more playable for colorblind people)',
			'colorblindMode', 'string', 'None', ['None', 'Deuteranopia', 'Protanopia', 'Tritanopia']);
		option.onChange = ColorblindFilters.applyFiltersOnGame;
		addOption(option);
		var option:Option = new Option('Disable Visual Effects', "If checked, extra visual effects will be removed.", 'disableFX', 'bool', false);
		addOption(option);
		var option:Option = new Option("Swearing", "If unchecked, swears will be muted out. (NOT IN THE OST MENU!!!)", "swearing", 'bool', true);
		addOption(option);
		var option:Option = new Option('Time Bar: ', "What should the Time Bar display?", 'timeBarType', 'string', 'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', "Whole Time", 'Disabled']);
		addOption(option);
		var option:Option = new Option('Colored Time Bar', "If checked, the time bar will be colored as\nthe opponent's health bar color.", 'timeColorBar',
			'bool', true);
		addOption(option);
		var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', 'bool', true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom',
			'bool', true);
		addOption(option);

		var option:Option = new Option('Health Bar Opacity: ', 'How opaque should the health bar and icons be.', 'healthBarAlpha', 'percent', 1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		var option:Option = new Option('OG Health Bar', 'Makes the colors of the health bar go back to the original style.', 'ogHpBar', 'bool', false);
		addOption(option);
		var option:Option = new Option('OG Combo Style', 'Makes the combo sprites not appear unless you have 10 or more hit combo.', 'ogCombo', 'bool', false);
		addOption(option);
		var option:Option = new Option("Lane Underlay", "Enables the lane underlay.", "laneUnderlayenabled", 'bool', false);
		addOption(option);
		var option:Option = new Option("Lane Underlay Opacity: ", "Changes how opaque the underlay is for the notes.", "laneUnderlaything", 'percent', 1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		var option:Option = new Option('Judgement Counter', // Name
			'If checked, enables the judgement counter which states all of your ratings.', // Description
			'judgementCounter', // Save data variable name
			'bool', // Variable type
			true); // Default value
		addOption(option);
		var option:Option = new Option('Camera Note Movement', // Name
			'If checked, it will enable a camera movement on a Note Hit.', // Description
			'followarrow', // Save data variable name
			'bool', // Variable type
			true); // Default value
		addOption(option);
		var option:Option = new Option('Health Bar Texture:', "Selects the texture of the health bar.\nPress Q & E to change the amount of health.",
			"healthBarTexture", 'string', "Default", ['Default', 'Shiny', '3D', 'Bronze', 'Silver', 'Gold']);
		option.onChange = refreshHealthBar;
		option.displayFormat = "%v bar";
		addOption(option);
		var option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', 'showFPS', 'bool', true);
		addOption(option);
		option.onChange = onChangeFPSCounter;

		super();
	}

	override function create()
	{
		super.create();
		barBG = new AttachedSprite('healthBars/default');
		barBG.y = 0.22 * FlxG.height;
		barBG.screenCenter(X);
		barBG.scrollFactor.set();
		barBG.visible = onBar;
		barBG.xAdd = -4;
		barBG.yAdd = -4;
		add(barBG);
		notes = new FlxTypedGroup(12);
		noteS = new FlxTypedGroup(4);
		for (i in 0...4) // not the best code but again works
		{
			var note = new OptionNote(199.4, i, END, ClientPrefs.note3Dwhen == "3D");
			notes.add(note);
		}
		for (i in 0...4)
		{
			var note = new OptionNote(90, i, HOLD, ClientPrefs.note3Dwhen == "3D");
			notes.add(note);
		}
		for (i in 0...4)
		{
			var note = new OptionNote(20, i, NONE, ClientPrefs.note3Dwhen == "3D");
			notes.add(note);
		}
		for (i in 0...4)
		{
			var note = new StrumNote(0, i, ClientPrefs.note3Dwhen == "3D");
			noteS.add(note);
		}
		add(notes);
		notes.visible = false;
		add(noteS);
		noteS.visible = false;
		for (note in notes)
		{
			@:privateAccess
			note.refreshAlpha();
		}
		for (note in noteS)
		{
			note.reloadAlpha();
		}
		bar = new FlxBar(barBG.x + 4, barBG.y + 4, RIGHT_TO_LEFT, Std.int(barBG.width - 8), Std.int(barBG.height - 8), this, 'health', 0, 2);
		bar.scrollFactor.set();
		bar.visible = onBar;
		bar.alpha = ClientPrefs.healthBarAlpha;
		bar.createFilledBar(FlxColor.fromRGB(161, 161, 161), FlxColor.fromRGB(49, 176, 209));
		add(bar);
		barBG.sprTracker = bar;
		iconP1 = new HealthIcon("bf", true);
		iconP1.y = bar.y - 75;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);
		iconP2 = new HealthIcon("face", false);
		iconP2.y = bar.y - 75;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		iconP2.animation.curAnim.curFrame = 0;
		iconP1.animation.curAnim.curFrame = 0;
		refreshHealthBar();
		Conductor.songPosition = FlxG.sound.music.time;
	}

	function refreshHealthBar()
	{
		barBG.visible = onBar;
		bar.visible = onBar;
		iconP1.visible = onBar;
		iconP2.visible = onBar;
		barBG.loadGraphic(Paths.image('healthBars/' + ClientPrefs.healthBarTexture.toLowerCase()));
		barBG.screenCenter(X);
		bar.setPosition(barBG.x + 4, barBG.y + 4);
		bar.setGraphicSize(Std.int(barBG.width - 8), Std.int(barBG.height - 8));
	}

	override function beatHit()
	{
		if (iconP2 != null && onBar)
		{
			var thej = ((bar.percent * 0.0125) + 0.2);
			iconP1.setGraphicSize(Std.int(iconP1.width * Math.min(((0.25 + ((thej * (health + 0.4)))) * (thej / 2.07)), 1.6)),
				Std.int(iconP1.height * Math.min(thej + 0.3, 1.1)));
			iconP2.setGraphicSize(Std.int(iconP2.width * Math.max(((0.25 + ((thej / (health + 0.4)))) / (thej * 2.07)), 0.47)),
				Std.int(iconP2.height * Math.max(thej - 0.3, 0.625)));
			iconP1.updateHitbox();
			iconP2.updateHitbox();
			var turnangle = 25 * (curBeat % 2 == 0 ? -1 : 1);
			var ease = FlxEase.smootherStepOut;
			i1T = FlxTween.angle(iconP1, turnangle, 0, Conductor.crochet / 1125, {ease: ease});
			i2T = FlxTween.angle(iconP2, turnangle, 0, Conductor.crochet / 1125, {ease: ease});
		}
		super.beatHit();
	}

	function refreshVars()
	{
		onBar = optionsArray[curSelected].name == "Health Bar Texture:";
		refreshHealthBar();
		onNotes = optionsArray[curSelected].name == "Note opacity:" || optionsArray[curSelected].name == "Strum note opacity:";
		notes.visible = onNotes;
		noteS.visible = onNotes;
	}

	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}

	override function update(elapsed)
	{
		if (controls.BACK)
		{
			if (i1T != null && i2T != null)
			{
				i1T.cancel();
				i2T.cancel();
			}
			i1T = null;
			i2T = null;
		}
		if (FlxG.keys.justPressed.SPACE && (curSelected == 2 || curSelected == 3) && ClientPrefs.note3Dwhen == "Default")
		{
			for (note in notes)
			{
				note.is3D = !note.is3D;
			}
			for (note in noteS)
			{
				note.is3D = !note.is3D;
			}
		}
		if (FlxG.keys.justPressed.E)
		{
			health = Math.max(0, health - 0.05);
		}
		else if (FlxG.keys.justPressed.Q)
		{
			health = Math.min(2, health + 0.05);
		}
		if (FlxG.keys.anyJustPressed([Q, E]))
		{
			if (bar.percent < 20)
			{
				iconP1.animation.curAnim.curFrame = 1;
				iconP2.animation.curAnim.curFrame = 2;
			}
			else if (bar.percent > 80)
			{
				iconP2.animation.curAnim.curFrame = 1;
				iconP1.animation.curAnim.curFrame = 2;
			}
			else
			{
				iconP2.animation.curAnim.curFrame = 0;
				iconP1.animation.curAnim.curFrame = 0;
			}
		}
		if (iconP2 != null && onBar)
		{
			Conductor.songPosition = FlxG.sound.music.time;
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.8)), Std.int(FlxMath.lerp(150, iconP1.height, 0.8)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.8)), Std.int(FlxMath.lerp(150, iconP2.height, 0.8)));
			iconP1.updateHitbox();
			iconP2.updateHitbox();
			iconP1.x = bar.x + (bar.width * (FlxMath.remapToRange(bar.percent, 0, 100, 100, 0) * 0.01) - 26);
			iconP2.x = bar.x + (bar.width * (FlxMath.remapToRange(bar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);
		}
		super.update(elapsed);
	}

	override function changeSelection(change:Int = 0) // changed for health bar and will clean up later so dont complain before i backhand you
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;
		if (iconP2 != null)
			refreshVars();
		var bullShit:Int = 0;
		if (!onBar && !onNotes)
		{
			for (item in grpOptions.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;
				item.xAdd = optionsArray[grpOptions.members.indexOf(item)].type == "bool" ? 200 : 120;
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
			for (text in grpTexts)
			{
				text.alpha = 0.6;
				if (text.ID == curSelected)
				{
					text.alpha = 1;
				}
			}
		}
		else
		{
			for (item in grpOptions.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;
				item.xAdd = optionsArray[grpOptions.members.indexOf(item)].type == "bool" ? 50 : -40;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
				else if (Math.abs(item.targetY) == 1)
				{
					item.alpha = 0.6;
				}
				else
				{
					item.alpha = 0;
				}
			}
			for (text in grpTexts)
			{
				if (text.ID == curSelected)
				{
					text.alpha = 1;
				}
				else if (curSelected + Math.abs(text.ID) == curSelected + 1)
				{
					text.alpha = 0.6;
				}
				else
				{
					text.alpha = 0;
				}
			}
		}
		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		if (boyfriend != null)
		{
			boyfriend.visible = optionsArray[curSelected].showBoyfriend;
		}
		curOption = optionsArray[curSelected]; // shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

class OptionNote extends FlxSprite
{
	public var is3D(default, set):Null<Bool> = null;
	public var noteData:Int = 0;
	public var holdNoteType:HoldNoteTypes = NONE;
	public var colorSwap:ColorSwap;
	public var swagWidth:Float = 160 * 0.7;

	var holdNotesThings = ["", " hold piece", " hold end"];
	var suffix = " instance 1";
	var notes = ["purple", "blue", "green", "red"];
	var fakeX = 0.0;

	public function new(y:Float, noteData:Int = 0, holdNoteType:HoldNoteTypes = NONE, is3D = false)
	{
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
		super(0, y + 100);
		this.noteData = noteData;
		this.holdNoteType = holdNoteType;
		this.is3D = is3D;
	}

	function holdTypeToInt()
	{
		switch (holdNoteType)
		{
			case NONE:
				return 0;
			case HOLD:
				return 1;
			case END:
				return 2;
		}
	}

	function refreshAlpha()
	{
		switch (holdNoteType)
		{
			default:
				alpha = ClientPrefs.noteAlpha * 0.6;
			case NONE:
				alpha = ClientPrefs.noteAlpha;
		}
	}

	function set_is3D(v:Bool):Bool
	{
		switch (holdNoteType == END && fakeX != 0) // reverting them as it causes an ascension glitch lmao
		{
			case true:
				switch (is3D)
				{
					case true:
						switch (noteData)
						{
							case 1 | 2:
								y += 0.025;
						}
					case false:
						y += 2;
						switch (noteData)
						{
							case 1 | 2:
								y -= 0.09;
						}
				}
			default:
		}
		is3D = v;
		fakeX = 0;
		x = 810;
		x += swagWidth * (noteData % 4);
		scale.y = 1;
		loadAnimation();
		return v;
	}

	function loadAnimation()
	{
		if (!is3D)
			frames = Paths.getSparrowAtlas("optionnotes/2dnotes");
		else
			frames = Paths.getSparrowAtlas("optionnotes/3dnotes");
		animation.addByPrefix("note", notes[noteData] + holdNotesThings[holdTypeToInt()] + suffix, 0, true);
		var lastScaleY = scale.y;
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		switch (holdNoteType)
		{
			default:
				animation.play("note");
				alpha = ClientPrefs.noteAlpha;
			case END | HOLD:
				alpha = 0.6 * ClientPrefs.noteAlpha;
				fakeX += width / 2;
				animation.play("note");
				scale.y = lastScaleY * 2.5;
				updateHitbox();
				fakeX -= width / 2;
				fakeX += 33;
				switch (holdNoteType)
				{
					case END:
						switch (is3D)
						{
							case true:
								switch (noteData)
								{
									case 1 | 2:
										y -= 0.025;
								}
							case false:
								if (noteData == 2)
									fakeX += 3;
								y -= 2;
								fakeX += 0.25;
								switch (noteData)
								{
									case 1 | 2:
										y += 0.09;
								}
						}
					case HOLD:
						if (noteData == 2 && !is3D) fakeX += 3.25;
					default:
				}
		}
		x += fakeX;
		antialiasing = ClientPrefs.globalAntialiasing;
	}
}

enum HoldNoteTypes
{
	NONE;
	HOLD;
	END;
}

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;

	public var resetAnim:Float = 0;

	private var noteData:Int = 0;

	public var is3D(default, set) = false;

	function set_is3D(v:Bool):Bool
	{
		is3D = v;
		reloadNote();
		return v;
	}

	public function new(y:Float, leData:Int, is3D:Bool)
	{
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		super(810, y + 10);
		this.is3D = is3D;
		x += (160 * 0.7) * noteData;
		reloadNote();
		scrollFactor.set();
	}

	public function reloadAlpha()
	{
		alpha = ClientPrefs.noteStrumAlpha;
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null)
			lastAnim = animation.curAnim.name;
		if (!is3D)
			frames = Paths.getSparrowAtlas("optionnotes/2dstrumline");
		else
			frames = Paths.getSparrowAtlas("optionnotes/3dstrumline");
		animation.addByPrefix('green', 'arrow static instance 4');
		animation.addByPrefix('blue', 'arrow static instance 2');
		animation.addByPrefix('purple', 'arrow static instance 1');
		animation.addByPrefix('red', 'arrow static instance 3');

		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		animation.play(["purple", "blue", "green", "red"][noteData]);
	}
}
