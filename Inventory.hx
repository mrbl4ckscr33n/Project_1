package arm;

import iron.Scene;
import iron.App;
import iron.math.Vec4;
import iron.system.Input;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;

class Inventory extends Sight
{
	var canvas: CanvasScript;
	var inventoryOpen: Bool = false;
	var hit_1: Hit;
	var impili: Vec4 = new Vec4(0.0);
	var pickedUp: Bool = false;

	public function new()
	{
		super();

		impili.z = 10;

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

		function pickUp()
		{
			if(Input.getKeyboard().started("f"))
			{
				var currentDir = new Vec4(0.0);
				var currentLoc = new Vec4(0.0);

				currentLoc.x = object.transform.worldx();
				currentLoc.y = object.transform.worldy();
				currentLoc.z = object.transform.worldz();
			
				// get look vector (3m long):
				currentDir = object.transform.up();
				currentDir.mult(-3);

				hit_1 = PhysicsWorld.active.rayCast(currentLoc, currentDir.add(currentLoc));
				pickedUp = true;
			}

			if((hit_1 != null) && hit_1.rb.ready && pickedUp)
			{
				hit_1.rb.applyImpulse(impili);
				pickedUp = false;
			}

		}

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("e")) toggleInventory();
			pickUp();
			lockMouse();
		});

		Event.add("btn_1_pressed", toggleInventory);

		// notifyOnRemove(function() {
		// });
	}
}

class Item
{
	public var onGround: Bool = true;
	public var amountInventory: Int = 0;
	public var ready: Bool = false;

	public function new()
	{
		ready = true;
		//iron.Scene.active.spawnObject();
	}
}

class WeirdObject extends Item
{
	public function new()
	{
		super();
	}
}