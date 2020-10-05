package arm;

import armory.system.Event;
import armory.trait.internal.CanvasScript;
import armory.trait.physics.bullet.PhysicsWorld;
import armory.trait.physics.bullet.RigidBody;
import iron.App;
import iron.Scene;
import iron.data.Data;
import iron.math.Vec4;
import iron.object.Object;
import iron.system.Input;
import iron.data.Data;

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

		//var rawObject: TObj;
		//var format: TSceneFormat;

		//iron.Scene.active.createObject();

		notifyOnInit(function()
		{
			canvas = object.getTrait(CanvasScript);
			canvas.setCanvasVisibility(false);
			canvas.setUiScale(0.5);
			/*var file = "icosphere.png";
			iron.data.Data.getImage(file, function(image: kha.Image) {trace(image);});*/
		});

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("tab")) toggleInventory();
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
		if(Input.getKeyboard().started("e"))
		{
			//var raw_objs = Scene.active.raw.objects;
			//var raw_obj = TObj;
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
		if (Input.getKeyboard().started("q") && (itemContainer.length > 0))
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

				o.properties = drop.object.properties;
							
				var dropped = o.getTrait(RigidBody);
				dropped.syncTransform();
			});
		}
	}
}