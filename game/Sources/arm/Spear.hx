package arm;

import iron.math.Quat;
import armory.trait.physics.bullet.PhysicsWorld;
import iron.math.Vec4;
import bullet.Bt;

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
			if(object.getTrait(armory.trait.physics.bullet.RigidBody) == null) return;

			v = object.getTrait(armory.trait.physics.bullet.RigidBody).getLinearVelocity().normalize();

			

			object.transform.buildMatrix();
			object.getTrait(armory.trait.physics.bullet.RigidBody).syncTransform();

			var contacts = PhysicsWorld.active.getContacts(object.getTrait(armory.trait.physics.bullet.RigidBody));
			
			if((contacts != null) && (contacts[0] != null) && isPassive == false){
				for(contact in contacts){
					if("Spear" == contact.object.name){
						trace('isn spear');
					}else{
						trace(contact.object.name);
						isPassive = true;

						object.getTrait(armory.trait.physics.bullet.RigidBody).setLinearVelocity(0,0,0);
						object.getTrait(armory.trait.physics.bullet.RigidBody).setAngularVelocity(0,0,0);
						object.getTrait(armory.trait.physics.bullet.RigidBody).setLinearFactor(0,0,0);
						object.getTrait(armory.trait.physics.bullet.RigidBody).setAngularFactor(0,0,0);
					}
				}
			}

			/*
			if((contacts != null) && (contacts[0] != null))
			{
				object.getTrait(armory.trait.physics.bullet.RigidBody).setLinearVelocity(0,0,0);
				object.getTrait(armory.trait.physics.bullet.RigidBody).setAngularVelocity(0,0,0);
				object.getTrait(armory.trait.physics.bullet.RigidBody).setLinearFactor(0,0,0);
				object.getTrait(armory.trait.physics.bullet.RigidBody).setAngularFactor(0,0,0);
			}*/
		});

		// notifyOnRemove(function() {
		// });
	}
}