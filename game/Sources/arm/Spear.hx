package arm;

import iron.math.Quat;
import armory.trait.physics.bullet.PhysicsWorld;
import iron.math.Vec4;
import bullet.Bt;
import iron.Scene;
import bullet.Bt.RigidBody;

class Spear extends iron.Trait
{
	var array_1: Array<RigidBody -> Void> = [];

	var loc = new Vec4();
	var v = new Vec4();

	var quat_1: Quat;
	var isPassive:Bool;

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			isPassive = false;
		});

		notifyOnUpdate(function()
		{
			if(isPassive) return;
			if(object.getTrait(armory.trait.physics.bullet.RigidBody) == null) return;

			var rot_init = object.transform.rot;
			var vec_init = object.transform.local.look().clone();
			var vec_final = object.getTrait(armory.trait.physics.bullet.RigidBody).getLinearVelocity().clone();
			var rot_final = new Quat();
			rot_final.fromTo(vec_init.normalize(), vec_final.normalize()).mult(rot_init);

			object.transform.rot.setFrom(rot_final);

			object.transform.buildMatrix();
			object.getTrait(armory.trait.physics.bullet.RigidBody).syncTransform();

			var contacts = PhysicsWorld.active.getContacts(object.getTrait(armory.trait.physics.bullet.RigidBody));
			
			if((contacts != null) && (contacts[0] != null))
			{
				for(contact in contacts)
				{
					if("Spear" == contact.object.name)
					{

					}
					else
					{
						isPassive = true;

						object.getTrait(armory.trait.physics.bullet.RigidBody).setLinearVelocity(0,0,0);
						object.getTrait(armory.trait.physics.bullet.RigidBody).setAngularVelocity(0,0,0);
						object.getTrait(armory.trait.physics.bullet.RigidBody).setLinearFactor(0,0,0);
						object.getTrait(armory.trait.physics.bullet.RigidBody).setAngularFactor(0,0,0);
					}
				}
			}
		});

		// notifyOnRemove(function() {
		// });
	}
}