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

using StringTools;

class MainMenuState extends MusicBeatState
{

	public static var psychEngineVersion:String = '0.5.2h';
	public static var modVersion:String = '0.2';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<MenuObject>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var background2:FlxSprite;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options',
		'otherv'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var scrollEffect:Bool = false;
	var keysAllowed:Array<String> = ['S', 'C', 'R', 'O', 'L'];
	var keysBuffer:String = '';

	var char:FlxSprite;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		scrollEffect = true;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var background:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		background.scrollFactor.set();
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);

		var bgScroll:FlxBackdrop = new FlxBackdrop(Paths.image('mainBG'), 5, 5, true, true, -33, -32);
		bgScroll.scrollFactor.set();
		bgScroll.screenCenter();
		bgScroll.velocity.set(50, 50);
		bgScroll.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgScroll);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		//add(magenta);
	
		background2 = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		background2.scrollFactor.set();
		background2.screenCenter();
		background2.visible = false;
		background2.antialiasing = ClientPrefs.globalAntialiasing;
		background2.color = FlxColor.MAGENTA;
		add(background2);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<MenuObject>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			if (scrollEffect == true){
			var offset:Float = 10 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:MenuObject = new MenuObject(0, (i * 140)  + offset);
			//menuItem.scale.x = scale;
			//menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (i != 0)
			{
				menuItem.scale.set(0.7, 0.7);
			}
			else
			{
				menuItem.scale.set(1, 1);
				menuItem.animation.play('selected');
			}
		}
		else{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:MenuObject = new MenuObject(100, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}
	}
	position();{
		for (i in menuItems.members){
			i.y = (FlxG.height) + (i.position) * 300;
			i.angle = (i.position * 0.3) * -55;
			FlxTween.tween(i, {x: i.position + 50}, 0.6, {ease: FlxEase.smoothStepInOut});
		}
	}
		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Vs. Sky Recreated v0.1",12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();

		switch (FlxG.random.int(1, 6))
            {
            case 1:
				char = new FlxSprite(600, 0).loadGraphic(Paths.image('ski_iii'));
				char.frames = Paths.getSparrowAtlas('ski_iii');
				char.animation.addByPrefix('idleA', 'sky idle', 24, true);
				char.animation.play('idleA');
				char.scrollFactor.set();
				char.antialiasing = ClientPrefs.globalAntialiasing;
				add(char);

            case 2:
				char = new FlxSprite(600, 0).loadGraphic(Paths.image('ska_aaaaa'));
				char.frames = Paths.getSparrowAtlas('ska_aaaaa');
				char.animation.addByPrefix('idleB', 'sky annoyed idle', 24, true);
				char.animation.play('idleB');
				char.scrollFactor.set();
				char.antialiasing = ClientPrefs.globalAntialiasing;
				add(char);

			case 3:
				char = new FlxSprite(600, 0).loadGraphic(Paths.image('ska_aaaaa'));
				char.frames = Paths.getSparrowAtlas('ska_aaaaa');
				char.animation.addByPrefix('idleD', 'sky annoyed alt idle', 24, true);
				char.animation.play('idleD');
				char.scrollFactor.set();
				char.antialiasing = ClientPrefs.globalAntialiasing;
				add(char);

			case 4:
				char = new FlxSprite(600, 0).loadGraphic(Paths.image('ska_aaaaa'));
				char.frames = Paths.getSparrowAtlas('ska_aaaaa');
				char.animation.addByPrefix('leftA', 'sky annoyed alt left', 24, true);
				char.animation.play('leftA');
				char.scrollFactor.set();
				char.antialiasing = ClientPrefs.globalAntialiasing;
				add(char);

			case 5:
				char = new FlxSprite(600, 0).loadGraphic(Paths.image('ska_aaaaa'));
				char.frames = Paths.getSparrowAtlas('ska_aaaaa');
				char.animation.addByPrefix('rightA', 'sky annoyed alt right', 24, true);
				char.animation.play('rightA');
				char.scrollFactor.set();
				char.antialiasing = ClientPrefs.globalAntialiasing;
				add(char);
				
			case 6:
				char = new FlxSprite(600, 0).loadGraphic(Paths.image('ska_aaaaa'));
				char.frames = Paths.getSparrowAtlas('ska_aaaaa');
				char.animation.addByPrefix('oh', 'sky annoyed oh', 24, true);
				char.animation.play('oh');
				char.scrollFactor.set();
				char.antialiasing = ClientPrefs.globalAntialiasing;
				add(char);
		
		}

	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if (keysAllowed.contains(keyName))
				keysBuffer += keyName;
				if (FlxG.keys.justPressed.BACKSPACE)
				keysBuffer = '';
				switch(keysBuffer){
				case 'SCROLL':
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.camera.shake(0.005, 1);
				keysBuffer = '';
				scrollEffect = true;
				changeItem();
			}
				trace(keysBuffer);
			}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(background2, 1.1, 0.15, false);
					if(ClientPrefs.flashing) FlxFlicker.flicker(char, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
									case 'otherv':
										MusicBeatState.switchState(new OtherVersionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (scrollEffect == true){
			spr.screenCenter(X);
			spr.x -= 350;
			}
			else{
			//spr.screenCenter(X);
			}
		});
	}

	function position(){
	var bullShit:Int = 0;
	for (item in menuItems.members)
		{
		item.prevPos = item.position;
		item.position = bullShit - curSelected;
		bullShit++;
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		position();
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
				if (scrollEffect == true){
				switch (spr.ID)
				{
					case 0:
						spr.offset.x -= 80;
					case 1:
						spr.offset.x -= 10;
					case 2:
						spr.offset.x -=10;
				}
			}
			}
		});
		if (scrollEffect == true){
		for (spr in menuItems){
			FlxTween.cancelTweensOf(spr);
			spr.y = (FlxG.height / 2) + (spr.position + huh) * 300 - (spr.height / 2);
			spr.angle = (spr.position + huh) * -15;
			FlxTween.tween(spr, {y: (FlxG.height / 2) + spr.position * 300 - (spr.height / 2), angle: spr.position * -15}, 0.6, {ease: FlxEase.quartOut});
			if (spr.ID == curSelected)
			FlxTween.tween(spr.scale, {x: 0.9, y: 0.9}, 0.3, {ease: FlxEase.quadOut});
			else
			FlxTween.tween(spr.scale, {x: 0.7, y: 0.7}, 0.3, {ease: FlxEase.quadOut});
	}
}
}
}

class MenuObject extends FlxSprite{
	public var position:Int = 0;
	public var prevPos:Int = 0;
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
	}
}