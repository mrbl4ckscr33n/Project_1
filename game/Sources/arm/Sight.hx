package arm;

import kha.FastFloat;
import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import iron.system.Input;
import iron.object.Object;
import iron.object.BoneAnimation;
import iron.system.Time;
import iron.system.Audio;
import armory.trait.physics.PhysicsWorld;
import armory.trait.internal.CameraController;
import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import iron.system.Input;
import iron.object.Object;
import iron.object.BoneAnimation;
import iron.data.SceneFormat;
import iron.Scene;

class Sight extends iron.Trait {

	var theoreticalRotation:FastFloat = 0.0;

	var rotation_1 = new Quat(0, 0, 0);

	public function new()
	{
		super();

		//notifyOnInit(function(){});

		notifyOnUpdate(function()
		{
			look_vertically();
		});

		// notifyOnRemove(function() {
		// });
	}

	function look_vertically()
	{
		var xAxis = new Vec4(1, 0, 0);

		if(Input.getMouse().moved && Input.getMouse().locked) // unneccessary steps are skipped
		{
			theoreticalRotation = -Input.getMouse().movementY/250; // function can only be called once before the movement value resets

			rotation_1.fromEuler(theoreticalRotation, 0, 0);

			if(object.transform.rot.w - theoreticalRotation < 0) // upper limit
			{
				object.transform.rotate(xAxis, object.transform.rot.w); // part of the movement is still executed
				return; // no further movement is executed
			}
				
			if(object.transform.rot.x + theoreticalRotation < 0) // lower limit
			{
				object.transform.rotate(xAxis, -object.transform.rot.x); // part of the movement is still executed
				return;
			}
			object.transform.rotate(xAxis, theoreticalRotation); // execution is only possible when not returned
		}
	}
}


