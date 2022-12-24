package;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var altCharSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var altCharSection:Bool = false;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new()
	{
	}
}
