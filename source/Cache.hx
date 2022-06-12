#if sys
package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import flixel.input.keyboard.FlxKey;

using StringTools;

class Cache extends MusicBeatState
{
	public static var bitmapData:Map<String,FlxGraphic>;
	public static var bitmapData2:Map<String,FlxGraphic>;

	var images = [];
	var music = [];

	var shitz:FlxText;

	override function create()
	{
		FlxG.mouse.visible = true;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();
		bitmapData2 = new Map<String,FlxGraphic>();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loadingscreen'+ FlxG.random.int(1, 3)));
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		menuBG.screenCenter();
		add(menuBG);

		FlxG.sound.play(Paths.sound('loading'));
		FlxG.camera.flash(FlxColor.WHITE, 2);
		trace('Loading...');

		var skipText:FlxText = new FlxText(12, FlxG.height - 64, 0, "Skip with Enter, Backspace, or Escape",12);
		skipText.scrollFactor.set();
		skipText.setFormat("", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(skipText);

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
			trace('Loading "assets/shared/images/characters"...');
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
			trace('Loading "assets/songs"...');
		}
		#end

		sys.thread.Thread.create(() -> {
			cache();
		});

		super.create();
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		{
			if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if (FlxG.keys.justPressed.BACKSPACE)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new TitleState());
				}
				if (FlxG.keys.justPressed.ESCAPE)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new TitleState());
				}
				if (FlxG.keys.justPressed.ENTER)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new TitleState());
				}
			}
		}
	}

	function cache()
	{
		#if !linux

		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			trace(i);
		}



		for (i in music)
		{
			trace(i);
		}


		#end
		FlxG.switchState(new TitleState());
	}

}
#end