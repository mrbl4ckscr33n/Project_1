package arm;

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
import zui.NewCanvasScript;
import zui.ItemOps;

class Inventory extends Sight
{
	var inventoryOpen: Bool = false;
	var pickUpHit: Hit;
	var pickedUp: Bool = false;
	//var itemContainer = new Array<RigidBody>();
	var ncs_1: NewCanvasScript;
	var background_1: Telement = {id: null, type: Container, name: "background", x: 700, y: 200, width: 100, height: 100, alignment: 5, visible: false};
	var itemDescription: Telement = {id: null, type: Text, name: "itemDescription", x: 0, y: 0, width: 150, height: 25, visible: false, color_text: 0xffffffff, text: "this is your inventory."};
	var descriptionBox: Telement = {id: null, type: FRectangle, name: "descriptionBox", x: 0, y: 0, width: 150, height: 25, visible: false, color: 0xff000000};
	var select: Telement = {id: null, type: Image, name: "select", x: 700, y: 200, width: 100, height: 100, visible: false};
	var asset_1: Tasset = {id: null, file: "../../Assets/inventory_background.png", name: null};
	var asset_2: Tasset = {id: null, file: "../../Assets/select.png", name: null};

	public function new()
	{
		super();

		ncs_1 = new NewCanvasScript();
		ItemOps.pushElements(ncs_1, background_1, asset_1);
		ItemOps.pushElements(ncs_1, itemDescription);
		ItemOps.pushElements(ncs_1, select, asset_2);
		ItemOps.pushElements(ncs_1, descriptionBox);

		notifyOnInit(function()
		{

		});

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("tab")) toggleInventory();
			lockMouse();
			placeDown();
			if(inventoryOpen)
			{
				displayDescription();
			}
			else
			{
				pickUp();
			}
		});

		Event.add("btn_1_pressed", toggleInventory);

		// notifyOnRemove(function() {
		// });
	}

	function displayDescription()
	{
		ncs_1.canvas_1.elements.remove(select);
		ncs_1.canvas_1.elements.push(select);

		for(a in 0...ncs_1.canvas_1.elements.length)
		{
			if(ncs_1.canvas_1.elements[a].drag && a < ncs_1.canvas_1.elements.length - 1)
			{
				var remove: Telement = ncs_1.canvas_1.elements[a];
				ncs_1.canvas_1.elements.remove(remove);
				ncs_1.canvas_1.elements.push(remove);
			}
		}

		ncs_1.canvas_1.elements.remove(descriptionBox);
		ncs_1.canvas_1.elements.push(descriptionBox);

		ncs_1.canvas_1.elements.remove(itemDescription);
		ncs_1.canvas_1.elements.push(itemDescription);

		if(Input.getMouse().down("right"))
		{
			ncs_1.canvas_1.elements.remove(itemDescription);
			ncs_1.canvas_1.elements.remove(descriptionBox);
			return;
		}

		else if(Input.getMouse().down())
		{
			ncs_1.canvas_1.elements.remove(itemDescription);
			ncs_1.canvas_1.elements.remove(descriptionBox);
			return;
		}

		var mouseX = Input.getMouse().lastX;
		var mouseY = Input.getMouse().lastY;
		var hover = false;

		for(a in 0...ncs_1.canvas_1.elements.length)
		{
			if(ncs_1.canvas_1.elements[a].type == DragAble)
			{
				if ((mouseX >= ncs_1.canvas_1.elements[a].x) && (mouseX <= (ncs_1.canvas_1.elements[a].x + ncs_1.canvas_1.elements[a].width)) && (mouseY >= ncs_1.canvas_1.elements[a].y) && (mouseY <= (ncs_1.canvas_1.elements[a].y + ncs_1.canvas_1.elements[a].height)))
				{
					hover = true;
					for(b in 0...ncs_1.canvas_1.assets.length)
					{
						if(ncs_1.canvas_1.assets[b].name == ncs_1.canvas_1.elements[a].asset)
						{
							ncs_1.canvas_1.elements[ncs_1.canvas_1.elements.length - 1].text = ncs_1.canvas_1.assets[b].file.substring(13, 14)
							+ ncs_1.canvas_1.assets[b].file.substring(14, ncs_1.canvas_1.assets[b].file.length - 4);
							hover = true;
							ncs_1.canvas_1.elements[ncs_1.canvas_1.elements.length - 1].x = mouseX;
							ncs_1.canvas_1.elements[ncs_1.canvas_1.elements.length - 1].y = mouseY;
							ncs_1.canvas_1.elements[ncs_1.canvas_1.elements.length - 2].x = mouseX + 10;
							ncs_1.canvas_1.elements[ncs_1.canvas_1.elements.length - 2].y = mouseY + 14;
							break;
						}
					}
					break;
				}
			}
		}
		if(!hover) //ncs_1.canvas_1.elements[ncs_1.canvas_1.elements.length - 1].text = "";
		{
			ncs_1.canvas_1.elements.remove(itemDescription);
			ncs_1.canvas_1.elements.remove(descriptionBox);
		}
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
					if(ItemOps.pushItems(ncs_1, pickUpHit.rb)) pickUpHit.rb.object.remove();
				}
			}
			pickedUp = false;
		}
	}

	function placeDown()
	{
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
								a = -1;

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
								
								break;
							}
						}
					}
					a--;
				}
			}
		}
	}
}