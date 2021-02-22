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

	var transition: FastFloat = 0;

	var w: Bool;
	var s: Bool;
	var shift: Bool;
	var space: Bool;

	public function new()
	{
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
					object.animation.speed = 1;

					if(w || s)
					{
						if(object.animation.action != "jump_jog")
						{
							length = 2;
							timeOnChange = Time.time();
							object.animation.play("jump_jog", transition);
						}
					}
					else if(object.animation.action != "jump_idle_2")
					{
						length = 1/3;
						timeOnChange = Time.time();
						object.animation.play("jump_idle_2", transition);
					}
				}
				else
				{
					currentTime = object.animation.time;
					currentFrame = object.animation.frameIndex;

					object.animation.loop = true;

					if(w || s)
					{
						if(w) object.animation.speed = 1;
						else object.animation.speed = -1;

						if(shift)
						{
							length = 2/3;
							if(object.animation.action != "jog") object.animation.play("jog", transition);
						}
						else if(object.animation.action != "walk")
						{
							length = 2;
							object.animation.play("walk", transition);
						}
					}
					else if(object.animation.action != "idle")
					{
						length = 1;
						object.animation.play("idle", transition);
					}
					
					object.animation.time = currentTime;
					object.animation.frameIndex = currentFrame;
				}
			}
		});

		// notifyOnRemove(function() {
		// });
	}
}
