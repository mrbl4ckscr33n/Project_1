package arm;

import armory.trait.physics.bullet.PhysicsWorld;
import armory.trait.physics.bullet.RigidBody;
import iron.math.Vec4;

class Tree extends iron.Trait
{
	public function new()
	{
		super();

		notifyOnInit(function()
		{
			object.properties = new Map();
			object.properties["pickUpAble"] = true;
			object.properties["amountInventory"] = 0;
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
}
