package arm;

import iron.Trait;
import iron.system.Input;
import iron.math.Vec4;
import iron.object.Transform;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;

class Movement extends Trait
{
	var body: RigidBody;
	var transform_movement:Transform;
	var rotationSpeed = 1;
	var speed = 0.1;
	public function new() 
	{
		super();
		iron.Scene.active.notifyOnInit(function () {
			transform_movement = object.transform;
			body = object.getTrait(RigidBody);
			PhysicsWorld.active.notifyOnPreUpdate(mouselock);
		});

		notifyOnUpdate (function()
		{
			walking();
			jumping();
		});
	}

	function mouselock()
	{
		if (Input.occupied || !body.ready) return;

		if (Input.getMouse().started() && !Input.getMouse().locked) Input.getMouse().lock();
		else if (Input.getKeyboard().started("escape") && Input.getMouse().locked) Input.getMouse().unlock();

		if (Input.getMouse().moved) transform_movement.rotate(Vec4.zAxis(),-Input.getMouse().movementX / 250 * rotationSpeed);
		body.syncTransform();
	}

	function walking()
	{
		if (Input.getKeyboard().down("shift")) speed = 0.2;
		else speed = 0.1;

		if (Input.getKeyboard().down("w")) transform_movement.move(object.transform.look(),speed);
		if (Input.getKeyboard().down("s")) transform_movement.move(object.transform.look().mult(-1),speed);
		if (Input.getKeyboard().down("d")) transform_movement.move(object.transform.right(),speed);
		if (Input.getKeyboard().down("a")) transform_movement.move(object.transform.right().mult(-1),speed); 
		body.setAngularFactor(0, 0, 0);
		
		var btvec = body.getLinearVelocity();
		body.setLinearVelocity(0.0, 0.0, btvec.z - 0.0);
		
	}

	function jumping()
	{
		if (Input.getKeyboard().started("space"))
		{
			body.applyImpulse(new Vec4(0, 0, 5.25));
		}
	}
}
