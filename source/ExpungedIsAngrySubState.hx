import flixel.system.FlxSound;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;

using StringTools;

class ExpungedIsAngrySubState extends FlxSubState
{
	var textLines = [
		"A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€",
		"screw you cheater!",
		"you haven't learned your lesson?"
	];

	var curText = 0;

	override public function create()
	{
		FlxG.autoPause = false;
		FlxG.save.data.cheaterFNFBool = true;
		FlxG.save.data.cheaterFNFTime = Date.now().getTime();
		FlxG.save.flush();
		var text = new FlxTypeText(-255, -310, 1260, "", 36);
		text.font = Paths.font("comic.ttf");
		text.color = 0xff470000;
		text.borderSize = 3;
		text.borderStyle = OUTLINE;
		text.borderColor = 0xffffffff;
		// text.sounds = [Paths.sound("dialogueTextSounds/expungedDialogue", "shared")];
		text.cursorBlinkSpeed = 1.15;
		text.showCursor = true;
		text.resetText(FlxG.random.getObject(textLines).toUpperCase());
		@:privateAccess
		text.delay = CoolUtil.boundTo(0.0825 * (32 / (text._finalText.length)), 0.025, 0.1);
		add(text);
		new FlxTimer().start(0.55, function(_)
		{
			text.start(true, false, [], function()
			{
				new FlxTimer().start(0.55, function(_) // sorry that this code kinda sucks but it gets job done so idc
				{
					System.exit(0);
				});
			});
		});
		super.create();
	}
}
