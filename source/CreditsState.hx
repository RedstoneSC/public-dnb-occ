package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(MainMenuState.randomBG());
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			['Occurrence Team'],
			[
				"YT_GD",
				"ytgd",
				"Former owner and Musician Of Dave and Bambi's Occurrence. | \"heheheha grrr\"",
				"https://www.youtube.com/channel/UCJwJrgSkeFjwcoZ8iwdl0-w",
				"91007e"
			],
			[
				"kstr743",
				"sleep",
				"Former Co-owner and Musician. | \"i haet fl studio trial\"",
				"https://www.youtube.com/channel/UCWRK7ciAd1U5XULI8xXR2fQ",
				"9999ff"
			],
			[
				"bruj",
				"amognusd",
				"Owner, Playtester, Animator, Musician, Charter, Artist and 3D character modelling. | \"help raf is putting me on the spot for a quote\"",
				"https://www.youtube.com/channel/UC3wbCxmOlJbPvpPrRAagvtA",
				"0033ff"
			],
			[
				"RafPlayz69",
				"raf",
				"Co-owner, Programmer, Playtester, Charter, Musician, Animated joke bambi, and drew joke bambi's farm. | \"visual studio code best B)\"",
				"https://www.youtube.com/channel/UCmXh1HTaH_KRwisl0892KLA",
				"666666"
			],

			[
				"dzub",
				"dzub",
				"Co-owner, Composed Real-Corn, Artist, Charter, Animator, 3D modeller and 3D character modelling. | \"i yeeted a child to space\"",
				"https://gamebanana.com/members/2003782",
				"009999"
			],
			[

				"enivindre",
				"eni",
				"Artist and Character concept creator. | \"Never comin' back again\"",
				"https://twitter.com/archedore",
				"d33734"
			],
			[
				"Aiden Does Stuff",
				"aiden",
				'Did character concepts and animated some of them. | "im not the blue pokemon guy get out of my head getoutgetoutgetoutgetoutgetoutgetoutgetoutgetout"',
				"https://www.youtube.com/channel/UC2E2o-4FHVEqGcp-PaII5tQ",
				"66ffff"
			],
			[
				"ToxicFlame",
				"toxic",
				"Composer (song not added yet) and Charter. | \"im toxic in every possible way\"",
				"https://www.youtube.com/channel/UCKBgCgsxSpdqFPryS7NAWWQ",
				"ffd800"
			],
			[
				"Lastremains",
				"mains",
				"Composer and drew his own credit icon. | \n\"47\"\n\"i dont know\"",
				"https://www.youtube.com/c/Lastremains",
				"0094ff"
			],
			[
				"That Pizza Tower Fan",
				"tptf",
				"Composed Phones. (We're serious, she asked for the elf emoji from discord as her credit icon.) | \"sorry i argued with peopel\"",
				"https://www.youtube.com/c/ThatPizzaTowerFan",
				"ffdc5d"
			],
			[''],
			['Some Shoutouts!'],
			[
				"Used Napkin",
				"napkin",
				"Playing our streamer build and giving feedback!",
				'https://www.youtube.com/c/UsedNapkin',
				'003366'
			],
			[
				"Clone High",
				"clonehero",
				"Made the Gandhi character.",
				"https://clonehigh.fandom.com",
				"ffffff"
			],
			[
				"Online VS",
				"onlinevs",
				"Made the Edd/Eduardo chromatics and sprites.",
				"https://gamebanana.com/mods/286594",
				"fefefe"
			],
			[
				"Cotiles",
				"floortiles",
				"Made the Bamburai chromatic. (Which we used for Rephonu.)",
				"https://www.youtube.com/c/cotiles",
				"0cffa5"
			],
			[
				"Eddsworld",
				"eddsworld",
				"Made the Edd/Eduardo characters.",
				"https://eddsworld.co.uk",
				"00cc33"
			],
			[
				'Lancey',
				'goldenapple',
				'Gave us permission to use Bandu in this mod.',
				'https://sites.google.com/view/lanceymods/home',
				"ded764"
			],
			[
				"OS Engine",
				"os",
				"Made the colorblind code that was used in this mod.",
				'https://github.com/notweuz/FNF-OSEngine',
				"fefefe"
			],
			[
				'Izzy Engine',
				'izzy',
				"Modified the crash handler loader of the engine!",
				'https://github.com/gedehari/IzzyEngine',
				'fd14a9'
			],
			[
				'Rembulous',
				'rem',
				"Created the Nightmare Bambi assets (except jumpscare).",
				'https://www.youtube.com/channel/UCqf5Okxr3dTFmjbknU2A32g',
				'1e1e1e'
			],
			[''],
			['Dave n\' Bambi Original Mod'],
			[
				'Check it out by pressing enter!',
				'daveandbamber',
				'Support the Original Mod!',
				'https://gamebanana.com/mods/43201',
				"0xFF613BE0"
			],
			[''],
			['Vs Dave And Bambi Team'],
			[
				'MoldyGH',
				'moldy',
				'Creator/Main Dev.',
				'https://www.youtube.com/channel/UCHIvkOUDfbMCv-BEIPGgpmA',
				"0xFF0066ff"
			],
			[
				'MissingTextureMan101',
				'missingtexture',
				'Secondary Dev.',
				'https://www.youtube.com/channel/UCCJna2KG54d1604L2lhZINQ',
				"0xFFFF00ff"
			],
			[
				'rapparep lol',
				'lol',
				'Main Artist.',
				'https://www.youtube.com/channel/UCKfdkmcdFftv4pFWr0Bh45A',
				"0xFFFFffff"
			],
			[
				'TheBuilderXD',
				'builderman',
				'Page Manager, Tristan Sprite Creator, and more.',
				'https://www.youtube.com/user/99percentMember',
				"0xFFcc6600"
			],
			[
				'Erizur',
				'erizur',
				'Programmer, Week Icon Artist.',
				'https://www.youtube.com/channel/UCdCAaQzt9yOGfFM0gJDJ4bQ',
				"0xFFFFffff"
			],
			[
				'T5mpler',
				'nothing',
				'Dev/Programmer & Supporter.',
				'https://www.youtube.com/channel/UCgNoOsE_NDjH6ac4umyADrw',
				"0xFFFF0000"
			],
			[
				'Stats45',
				'stats',
				'Minor programming, Moral support.',
				'https://www.youtube.com/channel/UClb4YjR8i74G-ue2nyiH2DQ',
				"0xFFFFffff"
			],
			[
				'Alexander Cooper 19',
				'cooper',
				'Mealie song, Beta Tester.',
				'https://www.youtube.com/channel/UCNz20AHJq41rkBUsq8RmUfQ',
				"0xFF0066ff"
			],
			[
				"Chromasen",
				"capsaicin",
				"Programming help.",
				"https://www.youtube.com/channel/UCgGk4oZt3We-ktkEOV9HY1Q",
				"0xff94decb"
			],
			[
				'Zmac',
				'zmac',
				'3D Background, Intro text help, EMFNF2 help.',
				'https://www.youtube.com/channel/UCl50Xru1nLBENuLiQBt6VRg',
				"0xFF00ffff"
			],
			[''],
			['Psych Engine Team'],
			[
				'Shadow Mario',
				'shadowmario',
				'Main Programmer of Psych Engine.',
				'https://twitter.com/Shadow_Mario_',
				'444444'
			],
			[
				'RiverOaken',
				'riveroaken',
				'Main Artist/Animator of Psych Engine.',
				'https://twitter.com/river_oaken',
				'C30085'
			],
			[
				'shubs',
				'shubs',
				'Additional Programmer of Psych Engine.',
				'https://twitter.com/yoshubs',
				'4494E6'
			],
			[''],
			['Former Engine Members'],
			[
				'bb-panzu',
				'bb-panzu',
				'Ex-Programmer of Psych Engine.',
				'https://twitter.com/bbsub3',
				'389A58'
			],
			[''],
			['Engine Contributors'],
			[
				'SqirraRNG',
				'gedehari',
				'Chart Editor\'s Sound Waveform base.',
				'https://twitter.com/gedehari',
				'FF9300'
			],
			[
				'iFlicky',
				'iflicky',
				'Delay/Combo Menu Song Composer\nand Dialogue Sounds.',
				'https://twitter.com/flicky_i',
				'C549DB'
			],
			[
				'PolybiusProxy',
				'polybiusproxy',
				'.MP4 Video Loader Extension.',
				'https://twitter.com/polybiusproxy',
				'FFEAA6'
			],
			[
				'Keoiki',
				'keoiki',
				'Note Splash Animations.',
				'https://twitter.com/Keoiki_',
				'FFFFFF'
			],
			[
				'Smokey',
				'smokey',
				'Spritemap Texture Support.',
				'https://twitter.com/Smokey_5_',
				'0033CC'
			],
			[''],
			["Funkin' Crew"],
			[
				'ninjamuffin99',
				'ninjamuffin99',
				"Programmer of Friday Night Funkin'.",
				'https://twitter.com/ninja_muffin99',
				'F73838'
			],
			[
				'PhantomArcade',
				'phantomarcade',
				"Animator of Friday Night Funkin'.",
				'https://twitter.com/PhantomArcade3K',
				'FFBB1B'
			],
			[
				'evilsk8r',
				'evilsk8r',
				"Artist of Friday Night Funkin'.",
				'https://twitter.com/evilsk8r',
				'53E52C'
			],
			[
				'kawaisprite',
				'kawaisprite',
				"Composer of Friday Night Funkin'.",
				'https://twitter.com/kawaisprite',
				'6475F3'
			]
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if (isSelectable)
			{
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			// optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				if (curSelected == -1)
					curSelected = i;
			}
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		// descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT)
			{
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new ExtraMenuState());
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if (!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menu", "Currently on: " + creditsStuff[curSelected][0] + ".");
		#end
		var newColor:Int = getCurrentBGColor();
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

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null)
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function getCurrentBGColor()
	{
		var bgColor:String = creditsStuff[curSelected][4];

		if (!bgColor.startsWith('0x'))
		{
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}
}
