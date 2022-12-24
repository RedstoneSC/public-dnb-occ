package options;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', // Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', // Description
			'lowQuality', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing', 'bool', true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		var option:Option = new Option('Green Screen', // Name
			'If checked, makes all backgrounds in-game a green screen.', // Description
			'greenScreen', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);
		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate', "Pretty self explanatory, isn't it?", 'framerate', 'int', 60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 120; // shit hits the fan if higher cuz no-one bothered to link things to framerate and im too lazy
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end
		var option:Option = new Option('Shaders', // Name
			'If checked, enables shaders (AND FLASHING LIGHTS!) to be used in-game.', // Description
			'shaders', // Save data variable name
			'bool', // Variable type
			true); // Default value
		addOption(option);
		option.onChange = function name()
		{
			ClientPrefs.flashing = true;
			ClientPrefs.saveSettings();
			reloadCheckboxes();
		}
		var option:Option = new Option('Wavy Backgrounds', "Uncheck this if your pc is laggy with this on.", 'wavyBGs', 'bool', true);
		addOption(option);
		var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool', true);
		option.onChange = function name()
		{
			ClientPrefs.shaders = if (ClientPrefs.flashing) ClientPrefs.shaders else false;
			ClientPrefs.saveSettings();
			reloadCheckboxes();
		}
		addOption(option);
		/*
			var option:Option = new Option('Persistent Cached Data',
				'If checked, images loaded will stay in memory\nuntil the game is closed, this increases memory usage,\nbut basically makes reloading times instant.',
				'imagesPersist',
				'bool',
				false);
			option.onChange = onChangePersistentData; //Persistent Cached Data changes FlxGraphic.defaultPersist
			addOption(option);
		 */

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; // Don't judge me ok
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
			{
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if (ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
}
