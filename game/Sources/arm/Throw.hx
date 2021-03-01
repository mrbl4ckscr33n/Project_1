package arm;

import kha.math.Vector4;
import iron.math.Quat;
import kha.graphics4.hxsl.Types.Vec;
import kha.Color;
import armory.system.Event;
import armory.trait.physics.bullet.PhysicsWorld;
import armory.trait.physics.bullet.RigidBody;
import iron.App;
import iron.Scene;
import iron.data.Data;
import iron.math.Vec4;
import iron.object.Object;
import iron.system.Input;
import iron.data.Data;
import arm.ItemOps;
import arm.NewCanvasScript;
import zui.Zui;
import armory.data.Config;
import armory.renderpath.RenderPathCreator;
import kha.Assets;

class Throw extends iron.Trait
{
	var look = new Vec4();

	var fromVec = new Vec4(0,1,0); // standard look vector
	var toVec = new Vec4();
	var finalRot = new Quat();

	public function new()
	{
		super();

		// notifyOnInit(function() {
		// });

		notifyOnUpdate(function()
		{
			if (Input.getKeyboard().started('t'))
			{
				var player = Scene.active.getChild("Player").transform;
				var camera = Scene.active.getChild("Camera").transform;

				trace("helo");

				iron.Scene.active.spawnObject("Spear", null, function(o: Object)
				{
					// get look vector:
					look = object.transform.up().mult(-10);
					
					// set location of spear:
					o.transform.loc.setFrom(player.loc);
					// for collision reasons set 1 meter in front of player:
					o.transform.loc.add(look);

					// impulse of 10:
					look.mult(10);

					// rotate spear:

					toVec.setFrom(camera.up().mult(-1));

					finalRot.fromTo(fromVec.normalize(), toVec.normalize());

					o.transform.rot.setFrom(finalRot);
					
					// sync:
					o.transform.buildMatrix();
					o.getTrait(RigidBody).syncTransform();
					
					o.getTrait(RigidBody).applyImpulse(look);
					
				}, false);
			}
		});

		// notifyOnRemove(function() {
		// });
	}
}
