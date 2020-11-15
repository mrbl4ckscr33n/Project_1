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
import armory.data.Config;
import armory.renderpath.RenderPathCreator; 

class Inventory extends iron.Trait
{
	var pickUpHit: Hit;
	var pickedUp: Bool = false;
	var ncs_1: NewCanvasScript;
	// inventory:
	var background_1: Telement = {id: null, type: Container, name: "background", x: 700, y: 200, width: 100, height: 100, alignment: 5, visible: false};
	var itemDescription: Telement = {id: null, type: Text, name: "itemDescription", x: 0, y: 0, width: 150, height: 25, visible: false, color_text: 0xffffffff, text: "this is your inventory."};
	var descriptionBox: Telement = {id: null, type: FRectangle, name: "descriptionBox", x: 0, y: 0, width: 150, height: 25, visible: false, color: 0xff000000};
	var select: Telement = {id: null, type: Image, name: "select", x: 700, y: 200, width: 100, height: 100, visible: false};
	var asset_1: Tasset = {id: null, file: "../../Assets/inventory_background.png", name: null};
	var asset_2: Tasset = {id: null, file: "../../Assets/select.png", name: null};
	// escape_menu:
	var option_1: Telement = {id: null, type: Combo, name: "kacktangle", x: 0, y: 0, width: 150, height: 25, visible: false, color: 0xff000000, color_text: 0xffff0000, color_progress: 0xffffff00, color_hover: 0xffffa500, text: "hallo;Fettsack!;Pimmelbirne"};
	
	public function new()
	{
		super();

		ncs_1 = new NewCanvasScript();
		ncs_1.canvas_array[0] = {name: "inventory", x: 0, y: 0, width: 1920, height: 1080, elements: null, theme: "Default Light", assets: null};
		ncs_1.canvas_array[1] = {name: "menu", x: 0, y: 0, width: 1920, height: 1080, elements: null, theme: "Default Light", assets: null};
		ItemOps.pushElements(ncs_1, ncs_1.canvas_array[0], background_1, asset_1);
		ItemOps.pushElements(ncs_1, ncs_1.canvas_array[0], itemDescription);
		ItemOps.pushElements(ncs_1, ncs_1.canvas_array[0], select, asset_2);
		ItemOps.pushElements(ncs_1, ncs_1.canvas_array[0], descriptionBox);
		ItemOps.pushElements(ncs_1, ncs_1.canvas_array[1], option_1);

		notifyOnInit(function()
		{
			Input.getMouse().lock();
		});

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("tab")) toggleVisibility(ncs_1.canvas_array[0]);
			if(Input.getKeyboard().started("escape")) toggleVisibility(ncs_1.canvas_array[1]);
			if(Input.getKeyboard().started("y"))
			{
				Config.raw.rp_ssr = !Config.raw.rp_ssr;
				RenderPathCreator.applyConfig();
				Config.save();
			}
			
			placeDown();
			if(ncs_1.canvas_array[0].elements[0].visible)
			{
				displayDescription();
			}
			else
			{
				pickUp();
			}
		});

		// notifyOnRemove(function() {
		// });
	}

	function displayDescription()
	{
		ncs_1.canvas_array[0].elements.remove(select);
		ncs_1.canvas_array[0].elements.push(select);

		for(a in 0...ncs_1.canvas_array[0].elements.length)
		{
			if(ncs_1.canvas_array[0].elements[a].drag && a < ncs_1.canvas_array[0].elements.length - 1)
			{
				var remove: Telement = ncs_1.canvas_array[0].elements[a];
				ncs_1.canvas_array[0].elements.remove(remove);
				ncs_1.canvas_array[0].elements.push(remove);
			}
		}

		ncs_1.canvas_array[0].elements.remove(itemDescription);
		ncs_1.canvas_array[0].elements.remove(descriptionBox);

		if(Input.getMouse().down() || Input.getMouse().down("right"))
		{
			/*for(a in 0...ncs_1.canvas_array[0].elements.length)
			{
				if(ncs_1.canvas_array[0].elements[a].type == DragAble)
				{
					for(b in 0...ncs_1.canvas_array[0].elements.length)
					{
						if(ncs_1.canvas_array[0].elements[b].name == "select")
						{
							ncs_1.canvas_array[0].elements[b].x = ncs_1.canvas_array[0].elements[a].x;
							ncs_1.canvas_array[0].elements[b].y = ncs_1.canvas_array[0].elements[a].y;
						}
					}
				}
			}*/
			return;
		}
		else
		{
			ncs_1.canvas_array[0].elements.push(descriptionBox);
			ncs_1.canvas_array[0].elements.push(itemDescription);
		}

		var mouseX = Input.getMouse().lastX;
		var mouseY = Input.getMouse().lastY;
		var hover = false;

		for(a in 0...ncs_1.canvas_array[0].elements.length)
		{
			if(ncs_1.canvas_array[0].elements[a].type == DragAble)
			{
				if ((mouseX >= ncs_1.canvas_array[0].elements[a].x) && (mouseX <= (ncs_1.canvas_array[0].elements[a].x + ncs_1.canvas_array[0].elements[a].width)) && (mouseY >= ncs_1.canvas_array[0].elements[a].y) && (mouseY <= (ncs_1.canvas_array[0].elements[a].y + ncs_1.canvas_array[0].elements[a].height)))
				{
					hover = true;
					for(b in 0...ncs_1.canvas_array[0].assets.length)
					{
						if(ncs_1.canvas_array[0].assets[b].name == ncs_1.canvas_array[0].elements[a].asset)
						{
							ncs_1.canvas_array[0].elements[ncs_1.canvas_array[0].elements.length - 1].text = ncs_1.canvas_array[0].assets[b].file.substring(13, 14)
							+ ncs_1.canvas_array[0].assets[b].file.substring(14, ncs_1.canvas_array[0].assets[b].file.length - 4);
							hover = true;
							ncs_1.canvas_array[0].elements[ncs_1.canvas_array[0].elements.length - 1].x = mouseX;
							ncs_1.canvas_array[0].elements[ncs_1.canvas_array[0].elements.length - 1].y = mouseY;
							ncs_1.canvas_array[0].elements[ncs_1.canvas_array[0].elements.length - 2].x = mouseX + 10;
							ncs_1.canvas_array[0].elements[ncs_1.canvas_array[0].elements.length - 2].y = mouseY + 14;
							break;
						}
					}
					break;
				}
			}
		}
		if(!hover) //ncs_1.canvas_array[0].elements[ncs_1.canvas_array[0].elements.length - 1].text = "";
		{
			ncs_1.canvas_array[0].elements.remove(itemDescription);
			ncs_1.canvas_array[0].elements.remove(descriptionBox);
		}
	}

	function toggleVisibility(canvas_1: Tcanvas)
	{
		if (Input.occupied) return;

		if(canvas_1.elements[0].visible)
		{
			ncs_1.setCanvasVisibility(canvas_1, false);
			var visible: Bool = false;
			for(a in 0...ncs_1.canvas_array.length)
			{
				if(ncs_1.canvas_array[a].elements[0].visible) visible = true;
			}
			if(!visible) Input.getMouse().lock();
		}
		else
		{
			ncs_1.setCanvasVisibility(canvas_1, true);
			Input.getMouse().unlock();
		}
	};

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
					if(ItemOps.pushItems(ncs_1, ncs_1.canvas_array[0], pickUpHit.rb)) pickUpHit.rb.object.remove();
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
			if(ncs_1.canvas_array[0].elements != null)
			{
				var a: Int = ncs_1.canvas_array[0].elements.length - 1;
				while(a >= 0)
				{
					if(ncs_1.canvas_array[0].elements[a].type == DragAble)
					{
						for(b in 0...ncs_1.canvas_array[0].assets.length)
						{
							if(ncs_1.canvas_array[0].assets[b].name == ncs_1.canvas_array[0].elements[a].asset)
							{
								nameToDrop = ncs_1.canvas_array[0].assets[b].file.substring(13, 14).toUpperCase()
								+ ncs_1.canvas_array[0].assets[b].file.substring(14, ncs_1.canvas_array[0].assets[b].file.length - 4);
								ncs_1.canvas_array[0].elements.remove(ncs_1.canvas_array[0].elements[a]);
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