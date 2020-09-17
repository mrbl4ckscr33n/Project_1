package arm;

import iron.Scene;
import iron.App;
import iron.system.Input;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;

class Inventory extends Sight
{
	public function new() {
		super();

		var canvas: CanvasScript;

		notifyOnInit(function()
		{
			canvas = object.getTrait(CanvasScript);

			canvas.setCanvasVisibility(true);
			canvas.setUiScale(1.0);

			canvas.notifyOnInit(function()
				{
					trace("init");
				});
		});

		function inventory_mouselock()
		{
			if (Input.occupied) return;

			if(Input.getKeyboard().started("e") && Input.getMouse().locked)
			{
				canvas.setCanvasVisibility(true);
				Input.getMouse().unlock();
			}

			else if(Input.getKeyboard().started("e") && !Input.getMouse().locked)
				{
					canvas.setCanvasVisibility(false);
					Input.getMouse().lock();
				}
		};

		notifyOnUpdate(function()
		{
			inventory_mouselock();
		});

		// notifyOnRemove(function() {
		// });
	}
}

