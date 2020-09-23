package arm;

import iron.Scene;
import iron.App;
import iron.math.Vec4;
import iron.system.Input;
import armory.system.Event;
import armory.trait.internal.CanvasScript;
import armory.trait.physics.bullet.RigidBody;
import armory.trait.physics.bullet.PhysicsWorld;
import iron.object.Object;
import armory.trait.PhysicsBreak;

class Inventory extends Sight
{
	var canvas: CanvasScript;

	var inventoryOpen: Bool = false;
	var pickUpHit: Hit;
	var pickedUp: Bool = false;
	var itemContainer = new Array<RigidBody>();

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			canvas = object.getTrait(CanvasScript);
			canvas.setCanvasVisibility(false);
			canvas.setUiScale(0.5);
		});

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("e")) toggleInventory();
			pickUp();
			lockMouse();
			placeDown();
		});

		Event.add("btn_1_pressed", toggleInventory);

		// notifyOnRemove(function() {
		// });
	}

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

			pickUpHit = PhysicsWorld.active.rayCast(currentLoc, currentDir.add(currentLoc));
			pickedUp = true;
		}

		if((pickUpHit != null) && pickUpHit.rb.ready && pickedUp)
		{
			if(pickUpHit.rb.object.properties != null)
			{
				if(pickUpHit.rb.object.properties["pickUpAble"])
				{
					itemContainer.push(pickUpHit.rb);
					pickUpHit.rb.object.remove();
					trace(itemContainer[0]);
				}
			}
			pickedUp = false;
		}
	}

	function placeDown()
	{
		if (Input.getKeyboard().started("i") && (itemContainer.length > 0))
		{
			var drop = itemContainer.pop();
	
			var currentDir = new Vec4(0.0);
			var currentLoc = new Vec4(0.0);
	
			currentLoc.x = object.transform.worldx();
			currentLoc.y = object.transform.worldy();
			currentLoc.z = object.transform.worldz();
	
			// get look vector (3m long):
			currentDir = object.transform.up();
			currentDir.mult(-3);
	
			currentDir.add(currentLoc);
	
			iron.Scene.active.spawnObject(drop.object.name, null, function(o:Object)
			{
				o.transform.loc = currentDir.add(new Vec4(0,0,1));
				o.transform.buildMatrix();
							
				var dropped = o.getTrait(RigidBody);
				dropped.syncTransform();
			});
		}
	}
}