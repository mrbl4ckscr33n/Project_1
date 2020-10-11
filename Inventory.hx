package arm;

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
import zui.NewCanvasScript;
import zui.ItemOps;

class Inventory extends Sight
{
	var inventoryOpen: Bool = false;
	var pickUpHit: Hit;
	var pickedUp: Bool = false;
	//var itemContainer = new Array<RigidBody>();
	var ncs_1: NewCanvasScript;
	var background_1: Telement = {id: null, type: Container, name: null, x: null, y: null, width: 100, height: 100, alignment: 5, visible: false};
	var asset_1: Tasset = {id: null, file: "../../Assets/inventory_background.png", name: null};

	public function new()
	{
		super();

		ncs_1 = new NewCanvasScript();
		ItemOps.pushElements(ncs_1, background_1, asset_1);

		notifyOnInit(function()
		{

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
			ncs_1.setCanvasVisibility(true);
			inventoryOpen = true;
			Input.getMouse().unlock(); // unlock mouse while in inventory
		}

		else if(!Input.getMouse().locked)
		{
			ncs_1.setCanvasVisibility(false);
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
					//itemContainer.push(pickUpHit.rb);
					pickUpHit.rb.object.remove();
					ItemOps.pushItems(ncs_1, pickUpHit.rb);
				}
			}
			pickedUp = false;
		}
	}

	function placeDown()
	{
		/*if (Input.getKeyboard().started("q") && (itemContainer.length > 0))
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

				//o.properties = drop.object.properties;
							
				var dropped = o.getTrait(RigidBody);
				dropped.syncTransform();
			});
		}*/

		if (Input.getKeyboard().started("q"))
		{
			//find first DragAble in canvas:
			var nameToDrop: String = null;
			if(ncs_1.canvas_1.elements != null)
			{
				var a: Int = ncs_1.canvas_1.elements.length - 1;
				while(a >= 0)
				{
					if(ncs_1.canvas_1.elements[a].type == DragAble) 
					{
						for(b in 0...ncs_1.canvas_1.assets.length)
						{
							if(ncs_1.canvas_1.assets[b].name == ncs_1.canvas_1.elements[a].asset)
							{
								nameToDrop = ncs_1.canvas_1.assets[b].file.substring(13, 14).toUpperCase()
								+ ncs_1.canvas_1.assets[b].file.substring(14, ncs_1.canvas_1.assets[b].file.length - 4);
								ncs_1.canvas_1.elements.remove(ncs_1.canvas_1.elements[a]);
							}
						}
						break;
					}
					a--;
				}
			}

			var currentDir = new Vec4(0.0);
			var currentLoc = new Vec4(0.0);
	
			currentLoc.x = object.transform.worldx();
			currentLoc.y = object.transform.worldy();
			currentLoc.z = object.transform.worldz();
	
			// get look vector (3m long):
			currentDir = object.transform.up();
			currentDir.mult(-3);
	
			currentDir.add(currentLoc);
	
			iron.Scene.active.spawnObject(nameToDrop, null, function(o:Object)
			{
				o.transform.loc = currentDir.add(new Vec4(0,0,1));
				o.transform.buildMatrix();
							
				var dropped = o.getTrait(RigidBody);
				dropped.syncTransform();
			});
		}
	}
}