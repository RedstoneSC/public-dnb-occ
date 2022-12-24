package options;

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Controller Mode', 'Check this if you want to play with\na controller instead of using your keyboard.',
			'controllerMode', 'bool', false);
		addOption(option);
		var option:Option = new Option("Enable BG Songs in OST",
			"If checked, you can play songs in the ost menu and have them continue playing when you go out of the game. (Don't close the game, the song will stop if you do.)",
			"ostBgMusicMode", 'bool', true);
		addOption(option);
		var option:Option = new Option('Section Memory Cleaner',
			'Cleans up memory every two sections but it can cause lag.\nRecommended off for low to mid-end PCs.', 'gcSection', 'bool', false);
		addOption(option);
		var option:Option = new Option('Story Cutscenes', 'Uncheck this if you don\'t want to see cutscenes in story mode.', 'storyCutscenes', 'bool', true);
		addOption(option);
		var option:Option = new Option('Freeplay Cutscenes', 'Check this if you want to see cutscenes in freeplay.', 'freeplayCutscenes', 'bool', false);
		addOption(option);

		var option:Option = new Option('Character select: ', "When should the character select screen appear?", 'charSelect', 'string', 'Freeplay',
			['Freeplay', 'Story Mode', 'Freeplay, Story', 'Disabled']);

		addOption(option);
		// I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', // Name
			'If checked, notes go Down instead of Up, simple enough.', // Description
			'downScroll', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Middlescroll', 'If checked, your notes get centered.', 'middleScroll', 'bool', false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping', "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping', 'bool', true);
		addOption(option);
		var option:Option = new Option('Anti-Mash', 'If enabled, anti-mash will be on, making it harder to beat spammy songs.', 'antiMash', "bool", false);
		addOption(option);
		var option:Option = new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", 'noReset', 'bool', false);
		addOption(option);
		var option:Option = new Option('Help on Spammy Songs',
			"If checked, you will get double the health per note\nand lose half per note on certain songs (with certain difficulties).", 'assistanceSpam',
			'bool', true);
		addOption(option);
		var option:Option = new Option('Mechanics', "If checked, mechanics will be enabled.", 'mechanics', 'bool', true);
		addOption(option);
		var option:Option = new Option('Modcharts', "If checked, song modcharts will be enabled.", 'modcharts', 'bool', true);
		addOption(option);

		var option:Option = new Option('Hitsounds', "If checked, it will play a sound every time you hit a note.", 'hitsounds', 'bool', false);
		addOption(option);
		var option:Option = new Option('Osu Hitsound', "If checked, it will use the osu hitsound instead of the D&B one. (Hitsounds must be enabled!!)",
			'osuHitsound', 'bool', false);
		addOption(option);

		var option:Option = new Option('Hitsound Volume: ', 'Changes the volume of hitsounds.', 'hitSoundVol', 'float', 1);

		option.scrollSpeed = 1;
		option.minValue = 0.2;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.onChange = function()
		{
			flixel.FlxG.sound.play(Paths.sound("hitsound"), ClientPrefs.hitSoundVol);
		};
		addOption(option);
		var option:Option = new Option('Instrumental Volume: ', 'Changes the volume of the instrumental in songs.', 'instVol', 'float', 1);
		option.scrollSpeed = 1;
		option.minValue = 0.1;
		option.maxValue = 1;
		option.changeValue = 0.1;
		addOption(option);
		var option:Option = new Option('Vocal Volume: ', 'Changes the volume of the vocals in songs.', 'vocalsVol', 'float', 1);
		option.scrollSpeed = 1;
		option.minValue = 0.1;
		option.maxValue = 1;
		option.changeValue = 0.1;
		addOption(option);
		var option:Option = new Option('Rating Offset: ', 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset', 'int', 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window: ', 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', 'sickWindow',
			'int', 45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 60;
		addOption(option);

		var option:Option = new Option('Good Hit Window: ', 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', 'goodWindow', 'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 115;
		addOption(option);

		var option:Option = new Option('Bad Hit Window: ', 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', 'badWindow', 'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 160;
		addOption(option);

		var option:Option = new Option('Safe Frames: ', 'Changes how many frames you have for\nhitting a note earlier or late.', 'safeFrames', 'float', 10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 15;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}
}
