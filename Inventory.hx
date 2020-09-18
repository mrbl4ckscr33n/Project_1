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
	public function new()
	{
		super();

		var canvas: CanvasScript;
		var inventoryOpen: Bool = false;

		notifyOnInit(function()
		{
			canvas = object.getTrait(CanvasScript);

			canvas.setCanvasVisibility(false);
			canvas.setUiScale(1.0);

			canvas.notifyOnInit(function()
				{
					trace("init");
				});
		});

		function toggleInventory()
		{
			if (Input.occupied) return;

				if(Input.getMouse().locked)
				{
					canvas.setCanvasVisibility(true);
					inventoryOpen = true;
					Input.getMouse().unlock(); // unlock mouse while in inventory
				}

				else if(!Input.getMouse().locked)
				{
					canvas.setCanvasVisibility(false);
					inventoryOpen = false;
					Input.getMouse().lock(); // lock mouse when inventory is closed
				}
		};

		function lockMouse()
		{
			if (Input.occupied) return;
		
			if (Input.getMouse().started() && !Input.getMouse().locked && !inventoryOpen) Input.getMouse().lock();
			else if (Input.getKeyboard().started("escape") && Input.getMouse().locked) Input.getMouse().unlock();
		}

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("e")) toggleInventory();
			lockMouse();
		});

		Event.add("btn_1_pressed", toggleInventory);

		// notifyOnRemove(function() {
		// });
	}
}

