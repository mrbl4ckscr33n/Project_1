package arm;

import kha.FastFloat;
import iron.system.Input;
import iron.object.Object;
import iron.object.Transform;
import iron.object.Animation;
import iron.object.BoneAnimation;

class CharacterAnimation extends iron.Trait
{
	var currentTime: FastFloat = 0;
	var currentFrame: Int = 0;

	var w: Bool;
	var s: Bool;
	var shift: Bool;

	public function new() {
		super();
		
		notifyOnInit(function()
		{
			object.animation.play("idle", 1);
		});

		notifyOnUpdate(function()
		{
			w = Input.getKeyboard().down("w");
			s = Input.getKeyboard().down("s");
			shift = Input.getKeyboard().down("shift");

			currentTime = object.animation.time;
			currentFrame = object.animation.frameIndex;

			if(w || s)
			{
				if(w) object.animation.speed = 2;
				else object.animation.speed = -2;

				if(shift)
				{
					if(object.animation.action != "jog")
					{
						object.animation.play("jog", 0.5);
					}
				}
				else if(object.animation.action != "walk")
				{
					object.animation.play("walk", 0.5);
				}
			}
			else if(object.animation.action != "idle")
			{
				object.animation.speed = 1;
				object.animation.play("idle", 0.5);
			}

			object.animation.time = currentTime;
			object.animation.frameIndex = currentFrame;
		});

		// notifyOnRemove(function() {
		// });
	}
}
