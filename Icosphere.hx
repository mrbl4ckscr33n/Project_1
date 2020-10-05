package arm;

import iron.Scene;
import iron.App;
import iron.math.Vec4;
import iron.system.Input;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;
import iron.object.Object;
import iron.object.MeshObject;
import armory.trait.PhysicsBreak;

class Icosphere extends iron.Trait
{
	public function new()
	{
		super();

		notifyOnInit(function()
		{
			object.properties = new Map();
			object.properties["pickUpAble"] = true;
			object.properties["amountInventory"] = 0;
			object.properties["graphicsName"] = "icosphere.png";
		});

		// notifyOnUpdate(function() {
		//});

		// notifyOnRemove(function() {
		// });
	}
}