package arm;

import bullet.Bt.Vector3;
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
	var ground_b = new Vec4(0, 0, 0);
	var ground_f = new Vec4(0, 0, 0);
	var ground_r = new Vec4(0, 0, 0);
	var ground_l = new Vec4(0, 0, 0); // position of the end of the vector that checks if player touching the ground
	var rayf : Hit;
	var rayb : Hit;
	var rayl : Hit;
	var rayr : Hit;

	var l:String;
	var r:String;
	var f:String;
	var b:String;

	var a : Int = 0;

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
			if (Input.getKeyboard().started("c")) crouching();
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
		if(PhysicsWorld.active.getContacts(object.getTrait(RigidBody)) != null) // change direction only when touching the ground
		{
			current_dir.set(0, 0, 0);

			if ((Input.getKeyboard().down("shift")) && (a != 1)) speed = 0.1;
			else if (a != 1) speed = 0.05;

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
		ground_f.x = object.transform.loc.x;
		ground_f.y = object.transform.loc.y + 0.8;
		ground_f.z = object.transform.loc.z; //distance from middle of body to ground P

		ground_b.x = object.transform.loc.x; 
		ground_b.y = object.transform.loc.y - 0.8;
		ground_b.z = object.transform.loc.z; //distance from middle of body to ground P

		ground_l.x = object.transform.loc.x - 0.8; 
		ground_l.y = object.transform.loc.y;
		ground_l.z = object.transform.loc.z; // distance from middle of body to ground probe idk
	
		ground_r.x = object.transform.loc.x + 0.8; 
		ground_r.y = object.transform.loc.y;
		ground_r.z = object.transform.loc.z; // distance from middle of body to ground probe idk
		
		// test if there is object between the coordinates:
		var rayf = PhysicsWorld.active.rayCast(object.transform.loc, ground_f);
		var rayb = PhysicsWorld.active.rayCast(object.transform.loc, ground_b);
		var rayl = PhysicsWorld.active.rayCast(object.transform.loc, ground_l);
		var rayr = PhysicsWorld.active.rayCast(object.transform.loc, ground_r);
		
		 //(PhysicsWorld.active.rayCast(object.transform.loc, ground_probe) != null)
		if (Input.getKeyboard().started("space") && ((rayf == null) && (rayb == null) && (rayr == null) && (rayl == null)) && PhysicsWorld.active.getContacts(body)[0] != null)
		{
			body.applyImpulse(new Vec4(0, 0, 5));
		}

		if (Input.getKeyboard().started("b"))
		{
			if (rayl != null) l = "true-l";
			if (rayr != null) r = "true-r";
			if (rayf != null) f = "true-f";
			if (rayb != null) b = "true-b";

			//if (PhysicsWorld.active.getContacts(body)[0] != null ) trace(PhysicsWorld.active.getContacts(body));
			trace (l);
			trace (r);
			trace (f);
			trace (b);
			trace ("------");
		}

		l = "false-l";
		r = "false-r";
		f = "false-f";
		b = "false-b";
	}

	function crouching()
	{
		switch (a) 
		{
			case 0:
				speed = 0.025;
				a = 1;
				
				
				//body.transform.scale.set(0.8,0.8,0.8);
				//object.transform.scale.set(0.8, 0.8, 0.8);
				body.btshape.setLocalScaling(new Vector3(0.8, 0.8, 0.8));
				//body.body.setCcdMotionThreshold(0);
				body.transform.buildMatrix();
				body.syncTransform();
				body.activate();
				body.transform.update();

				object.transform.move(new Vec4(0,0,-0.2));

				body.transform.buildMatrix();
				body.syncTransform();
				body.activate();
				body.transform.update();

			case 1:
				a = 0;
				object.transform.scale.set(1, 1, 1);
				body.transform.buildMatrix();
				body.syncTransform();
				body.activate();
				body.transform.update();
				//body.btshape.setLocalScaling(new Vector3(1.25, 1.25, 1.25));
				//body.btshape.setLocalScaling(new Vector3(1, 1, 1));
				//object.transform.scale.set(1,1,1);
				//object.transform.move(new Vec4(0,0,0.5));
		}
	}
}