package zui;

import iron.App;
import kha.Font;
import armory.system.Event;
import iron.data.Data;
import iron.Trait;
import iron.system.Input;
import zui.Zui;
import zui.Ext;
import zui.Themes;
import zui.NewCanvasScript;
import armory.trait.physics.bullet.RigidBody;

class ItemOps // static
{
	public static function pushItems(ncs_1: NewCanvasScript, rigidToPush: RigidBody): Bool // returns if container is full
	{
		// check capacity:
		var amountBeforePush: Int = 0;
		var containerPointer: Int = null;
		for(a in 0...ncs_1.canvas_1.elements.length)
		{
			if(ncs_1.canvas_1.elements[a].type == DragAble)
			{
				amountBeforePush++;
			}
			else if(ncs_1.canvas_1.elements[a].type == Container)
			{
				containerPointer = a;
			}
		}
		if(amountBeforePush >= (ncs_1.canvas_1.elements[containerPointer].alignment * ncs_1.canvas_1.elements[containerPointer].alignment)) return false;

		var element_0: Telement = rigidToPush.object.properties["Telement"];

		var asset_0: Tasset = {id: null, name: null, file: null};
		asset_0.file = "../../Assets/" + rigidToPush.object.name.toLowerCase() + ".png";

		pushElements(ncs_1, element_0, asset_0);
		return true;
	}

	public static function pushElements(ncs_1: NewCanvasScript, element_0: Telement, asset_0: Tasset): Void
	{
		// find empty position for element:

		if(element_0.type == DragAble)
		{
			if(ncs_1.canvas_1.elements != null)
			{
				var container_0: Telement = null;
				for(a in 0...ncs_1.canvas_1.elements.length)
				{
					if(ncs_1.canvas_1.elements[a].type == Container) container_0 = ncs_1.canvas_1.elements[a];
				}
				var canvasX = Std.int(ncs_1.canvas_1.x);
				var canvasY = Std.int(ncs_1.canvas_1.y);
				var upperLineX = Std.int(ncs_1.canvas_1.x + container_0.width * (container_0.alignment - 1));
				var upperLineY = Std.int(ncs_1.canvas_1.y + container_0.height * (container_0.alignment - 1));
				var posExists: Bool = true;
				var x: Int = canvasX;
				var y: Int = canvasY;
				while(y <= upperLineY)
				{
					while(x <= upperLineX)
					{
						for(a in 0...ncs_1.canvas_1.elements.length)
						{
							if((ncs_1.canvas_1.elements[a].x == x) && (ncs_1.canvas_1.elements[a].y == y)) posExists = true;
						}
						if(!posExists)
						{
							element_0.x = x;
							element_0.y = y;
							break;
						}
						x = x + 100;
					}
					if(!posExists) break;
					y = y + 100;
				}
			}
			else
			{
				element_0.x = ncs_1.canvas_1.x;
				element_0.y = ncs_1.canvas_1.y;
			}
		}
		
		// find out if asset file name already exists:
		var fileExists: Bool = false;
		if(ncs_1.canvas_1.assets != null)
		{
			for(a in 0...ncs_1.canvas_1.assets.length)
			{
				if(ncs_1.canvas_1.assets[a].file == asset_0.file)
				{
					fileExists = true;
					element_0.asset = ncs_1.canvas_1.assets[a].name;
				}
			}
		}

		if(!fileExists)
		{
			if(ncs_1.canvas_1.assets != null)
			{
				// create smallest possible id:
				var idExists: Bool = false;
				for(b in 0...128)
				{
					for(c in 0...ncs_1.canvas_1.assets.length)
					{
						if(ncs_1.canvas_1.assets[c].id == b) idExists = true;
					}
					if(!idExists)
					{
						asset_0.id = b;
						asset_0.name = "asset_" + asset_0.id;
						break;
					}
					idExists = false;
				}
			}
			else
			{
				asset_0.id = 0;
				asset_0.name = "asset_0";
				ncs_1.canvas_1.assets = new Array<Tasset>();
			}
			element_0.asset = asset_0.name;
			ncs_1.canvas_1.assets.push(asset_0);
		}
		
		if(ncs_1.canvas_1.elements != null)
		{
			// create element id and name:
			var idExists: Bool = false;
			for(d in 0...128)
			{
				for(e in 0...ncs_1.canvas_1.elements.length)
				{
					if(ncs_1.canvas_1.elements[e].id == d) idExists = true;
				}
				if(!idExists)
				{
					element_0.id = d;
					element_0.name = "element_" + element_0.id;
					break;
				}
				idExists = false;
			}
		}
		else
		{
			element_0.id = 0;
			element_0.name = "element_0";
			ncs_1.canvas_1.elements = new Array<Telement>();
		}

		ncs_1.canvas_1.elements.push(element_0);

		iron.data.Data.getFont("C:/Windows/Fonts/Arial.ttf", function(f: kha.Font)
		{
			ncs_1.zui_options_1 = {font: f, theme: zui.Themes.light};

			if(ncs_1.zui_1 == null) ncs_1.zui_1 = new Zui(ncs_1.zui_options_1);

			iron.data.Data.getImage(asset_0.file, function(image: kha.Image)
			{
				ncs_1.setAsset(asset_0, image);
			});
		});
	}

	public static function popItems(idToPush: Int, canvas_1: Tcanvas): Tcanvas
	{
		// get item pos...
		return null;
	}

	static function getItemPos(nameToLocate, canvas_1): Int
	{
		return 5;
	}
}