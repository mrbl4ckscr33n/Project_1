package arm;

import iron.Trait;
import iron.system.Input;
import iron.math.Vec4;
import iron.object.Transform;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;
import armory.trait.internal.CanvasScript;

class Movement extends Trait
{
	var body: RigidBody;
	var transform_movement: Transform;
	var rotationSpeed = 1;
	var speed = 0.1;
	var ground_probe = new Vec4(0, 0, 0); // position of the end of the vector that checks if player touching the ground
	var current_dir = new Vec4(0, 0, 0);

	public function new() 
	{
		super();
		iron.Scene.active.notifyOnInit(function () {
			body = object.getTrait(RigidBody);
		});

		notifyOnUpdate (function()
		{
			walking();
			jumping();
			look_horizontal();
		});
	}

	function look_horizontal()
	{
		if (Input.getMouse().moved) object.transform.rotate(Vec4.zAxis(),-Input.getMouse().movementX / 250 * rotationSpeed);
		body.syncTransform();
	}

	function walking()
	{
		if((PhysicsWorld.active.rayCast(object.transform.loc, ground_probe) != null) && (PhysicsWorld.active.getContacts(body) != null)) // change direction only when touching the ground
		{
			current_dir.set(0, 0, 0);

			if (Input.getKeyboard().down("shift")) speed = 0.2;
			else speed = 0.1;

			if (Input.getKeyboard().down("w"))
			{
				current_dir = object.transform.look();
			}
			else if (Input.getKeyboard().down("s"))
			{
				current_dir = current_dir.addvecs(current_dir, object.transform.look().mult(-1)); // all inputs are added together
			}
			if (Input.getKeyboard().down("d"))
			{
				current_dir = current_dir.addvecs(current_dir, object.transform.right());
			}
			else if (Input.getKeyboard().down("a"))
			{
				current_dir = current_dir.addvecs(current_dir, object.transform.right().mult(-1));
			}
		}

		object.transform.move(current_dir.normalize(), speed);
		
		body.setAngularFactor(0, 0, 0);
		
		var btvec = body.getLinearVelocity();
		body.setLinearVelocity(0.0, 0.0, btvec.z);
	}

	function jumping()
	{
		ground_probe.x = object.transform.loc.x; // take coordinates from the middle of the player
		ground_probe.y = object.transform.loc.y;
		ground_probe.z = object.transform.loc.z - 1.3; // distance from middle of body to ground probe idk

		 // test if there is object between the coordinates:
		if (Input.getKeyboard().started("space") && (PhysicsWorld.active.rayCast(object.transform.loc, ground_probe) != null))
		{
			body.applyImpulse(new Vec4(0, 0, 5.25));
		}
	}
}