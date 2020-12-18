package arm;

import kha.FastFloat;
import iron.system.Time;
import iron.system.Input;
import iron.object.Object;
import iron.object.Transform;
import iron.object.Animation;
import iron.object.BoneAnimation;

class CharacterAnimation extends iron.Trait
{
	var currentTime: FastFloat = 0;
	var currentFrame: Int = 0;

	var timeOnChange: FastFloat = 0;
	var length: FastFloat = 0;

	var w: Bool;
	var s: Bool;
	var shift: Bool;
	var space: Bool;

	public function new() {
		super();
		
		notifyOnInit(function()
		{
			object.animation.play("idle");
		});

		notifyOnUpdate(function()
		{
			w = Input.getKeyboard().down("w");
			s = Input.getKeyboard().down("s");
			shift = Input.getKeyboard().down("shift");
			space = Input.getKeyboard().started("space");

			if(Time.time() - timeOnChange > length)
			{
				if(space)
				{
					object.animation.loop = false;
					object.animation.speed = 2;

					if(w || s)
					{
						if(object.animation.action != "jump_jog")
						{
							length = 2;
							timeOnChange = Time.time();
							object.animation.play("jump_jog", 0.5);
						}
					}
					else if(object.animation.action != "jump_idle")
					{
						length = 4/6;
						timeOnChange = Time.time();
						object.animation.play("jump_idle", 0.5);
					}
				}
				else
				{
					currentTime = object.animation.time;
					currentFrame = object.animation.frameIndex;

					object.animation.loop = true;

					if(w || s)
					{
						if(w) object.animation.speed = 2;
						else object.animation.speed = -2;

						if(shift)
						{
							if(object.animation.action != "jog") object.animation.play("jog", 0.5);
						}
						else if(object.animation.action != "walk") object.animation.play("walk", 0.5);
					}
					else if(object.animation.action != "idle") object.animation.play("idle", 0.5);
					
					object.animation.time = currentTime;
					object.animation.frameIndex = currentFrame;
				}
			}
		});

		// notifyOnRemove(function() {
		// });
	}
}
