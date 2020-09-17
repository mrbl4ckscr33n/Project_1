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

class Sight extends iron.Trait {

	var theoreticalRotation:FastFloat = 0.0;

	public function new() {
		super();

		// notifyOnInit(function() {
		// });

		notifyOnUpdate(function()
		{
			mouselock();
			look_vertically();
		});

		// notifyOnRemove(function() {
		// });
	}

	function mouselock()
	{
		if (Input.occupied) return;

		if (Input.getMouse().started() && !Input.getMouse().locked) Input.getMouse().lock();
		else if (Input.getKeyboard().started("escape") && Input.getMouse().locked) Input.getMouse().unlock();
	}

	function look_vertically()
	{
		if(Input.getMouse().moved) // unneccessary steps are skipped
		{
			theoreticalRotation = -Input.getMouse().movementY/250; // function can only be called once before the movement value resets

			if(object.transform.rot.w - theoreticalRotation < 0) // upper limit
			{
				object.transform.rotate(Vec4.xAxis(), object.transform.rot.w); // part of the movement is still executed
				return; // no further movement is executed
			}
				
			if(object.transform.rot.x + theoreticalRotation < 0) // lower limit
			{
				object.transform.rotate(Vec4.xAxis(), -object.transform.rot.x); // part of the movement is still executed
				return;
			}
			object.transform.rotate(Vec4.xAxis(), theoreticalRotation); // execution is only possible when not returned
		}
	}
}


