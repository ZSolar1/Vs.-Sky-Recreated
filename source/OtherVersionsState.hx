package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

class OtherVersionsState extends MusicBeatState
{

	override function create()
	{

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG_paperiee'));
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		menuBG.screenCenter();
		add(menuBG);

		super.create();
	}
	override function update(elapsed:Float)
		{
			if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			var keyName:String = Std.string(keyPressed);
			if (FlxG.keys.justPressed.BACKSPACE)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

		}
	}
}