package arm;

import iron.Trait;
import iron.Scene;
import iron.system.Input;
import iron.math.Vec4;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;

class Movement extends Trait
{
	var body: RigidBody;
	var rotationSpeed = 1;
	var speed = 0.1;
	var ground_vl = new Vec4(0, 0, 0);
	var ground_hl = new Vec4(0, 0, 0);
	var ground_vr = new Vec4(0, 0, 0);
	var ground_hr = new Vec4(0, 0, 0); // position of the end of the vector that checks if player touching the ground

	var current_dir = new Vec4(0, 0, 0);
	var moveLegal: Bool = true;

	public function new() 
	{
		super();

		iron.Scene.active.notifyOnInit(function ()
		{
			body = object.getTrait(RigidBody);
		});

		notifyOnUpdate (function()
		{
			walking();
			jumping();
			look_horizontally();
		});
	}

	function look_horizontally()
	{
		if (Input.getMouse().moved && Input.getMouse().locked) object.transform.rotate(Vec4.zAxis(),-Input.getMouse().movementX / 250 * rotationSpeed);
		body.syncTransform();
	}

	function walking()
	{
		if((PhysicsWorld.active.rayCast(object.transform.loc, ground_vl) != null) || (PhysicsWorld.active.rayCast(object.transform.loc, ground_vr) != null) || (PhysicsWorld.active.rayCast(object.transform.loc, ground_hl) != null) || (PhysicsWorld.active.rayCast(object.transform.loc, ground_hr) != null) && (PhysicsWorld.active.getContacts(body) != null)) // change direction only when touching the ground
		{
			current_dir.set(0, 0, 0);

			if (Input.getKeyboard().down("shift")) speed = 0.1;
			else speed = 0.05;

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
		
		//var btvec = body.getLinearVelocity();
		//body.setLinearVelocity(0.0, 0.0, btvec.z);
	}

	function jumping()
	{	
		ground_vl.x = object.transform.loc.x - 0.5; 
		ground_vl.y = object.transform.loc.y + 0.5;
		ground_vl.z = object.transform.loc.z - 1.3; // distance from middle of body to ground probe idk
	
		ground_vr.x = object.transform.loc.x + 0.5; 
		ground_vr.y = object.transform.loc.y + 0.5;
		ground_vr.z = object.transform.loc.z - 1.3; // distance from middle of body to ground probe idk
	
		ground_hl.x = object.transform.loc.x - 0.5; 
		ground_hl.y = object.transform.loc.y - 0.5;
		ground_hl.z = object.transform.loc.z - 1.3; // distance from middle of body to ground probe idk
	
		ground_hr.x = object.transform.loc.x + 0.5; 
		ground_hr.y = object.transform.loc.y - 0.5;
		ground_hr.z = object.transform.loc.z - 1.3; // distance from middle of body to ground probe idk
		
		var rayvl = PhysicsWorld.active.rayCast(object.transform.loc, ground_vl);
		var rayhl = PhysicsWorld.active.rayCast(object.transform.loc, ground_hl);
		var rayvr = PhysicsWorld.active.rayCast(object.transform.loc, ground_vr);
		var rayhr = PhysicsWorld.active.rayCast(object.transform.loc, ground_hr);
		 // test if there is object between the coordinates:
		 //(PhysicsWorld.active.rayCast(object.transform.loc, ground_probe) != null)
		if (Input.getKeyboard().started("space") && ((rayhr != null) || rayvr != null || rayhl != null || rayvl != null))
		{
			body.applyImpulse(new Vec4(0, 0, 5));
		}
	}
}