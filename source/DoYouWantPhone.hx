package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;

class DoYouWantPhone // i might use this tbh
{
	public static function yes()
	{
		trace("Okay, here is your phone!");
	}

	public static function no()
	{
		trace("Fine, no phone for you!");
	}
}

// for discord rpc lmao (not really cuz i have the thing off for testing most of the time, might turn it on)

class NightMareBambiJumpScareSubState extends MusicBeatSubstate
{
	var bamberframes = null;

	override public function new(bamberframes)
	{
		this.bamberframes = bamberframes;
		FlxG.sound.play(Paths.sound("Lights_Turn_On", "shared"));
		super();
	}

	override public function create()
	{
		var bambijumpscare = new FlxSprite(-300, -350);
		bambijumpscare.frames = bamberframes;
		bambijumpscare.animation.addByPrefix("harharhar", "bambinmjumpscare", 21);
		bambijumpscare.animation.play("harharhar");
		new FlxTimer().start(1, function(_)
		{
			Sys.exit(0);
		});
		add(bambijumpscare);
		super.create();
	}
}
