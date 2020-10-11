package zui;

using kha.graphics2.GraphicsExtension;

import iron.App;
import kha.Font;
import armory.system.Event;
import iron.data.Data;
import iron.Trait;
import iron.system.Input;
import zui.Zui;
import zui.Ext;
import zui.Themes;

@:access(zui.Zui)
class NewCanvasScript extends iron.Trait
{
	var render2D: Array<kha.graphics2.Graphics->Void> = null;

	public var zui_1: Zui;
	public var zui_options_1: ZuiOptions;
	public var canvas_1: Tcanvas = {name: "canvas_1", x: 0, y: 0, width: 1920, height: 1080, elements: null, theme: "Default Light", assets: null};
	
	public var ready(get, null): Bool;
	function get_ready(): Bool { return canvas_1 != null; }
	
	public static var assetMap = new Map<Int, Dynamic>(); // kha.Image | kha.Font
	public static var themes = new Array<zui.Themes.TTheme>();
	static var events:Array<String> = [];
	
	public static var screenW = -1;
	public static var screenH = -1;
	static var zui_2: Zui;
	static var h = new zui.Zui.Handle(); // TODO: needs one handle per canvas
	
	/*var element_1: Telement;
	var element_2: Telement;
	var element_3: Telement;
	var element_4: Telement;

	var element_array_1 = new Array<Telement>();
	var asset_array_1 = new Array<Tasset>();
	var asset_1: Tasset;
	var asset_2: Tasset;*/
	
	public function new()
	{
		super();

		// create element array for canvas:
		/*element_1 = {id: 0, type: DragAble, name: "img_1", x: 720, y: 120, width: 100, height: 100, text: null, asset: "asset_1", event: "trace"};
		element_2 = {id: 1, type: Button, name: "btn_1", x: 0, y: 0, width: 200, height: 50, text: "push to move", event: "trace", color: 0xffff0000, color_text: 0xffffffff, color_hover: 0xff800080, color_press: 0xff000000};
	    element_3 = {id: 2, type: DragAble, name: "DragAble_1", x: 200, y: 200, width: 100, height: 100, text: null, asset: "asset_1", event: "trace"};
		element_4 = {id: 3, type: Container, name: "Container_1", x: 200, y: 400, width: 100, height: 100, asset: "asset_2", alignment: 5};

		//saveElement = null;
		element_array_1[1] = element_1;
		element_array_1[2] = element_2;
		element_array_1[3] = element_3;
		element_array_1[0] = element_4;
		element_array_1[4] = {id: 4, type: null, name: null, x: null, y: null, width: null, height: null};

		// create asset array for canvas:
		asset_1 = {id: 0, name: "asset_1", file: "../../Assets/icosphere.png"};
		asset_2 = {id: 1, name: "asset_2", file: "../../Assets/inventory_background.png"};
		asset_array_1[0] = asset_1;
		asset_array_1[1] = asset_2;

		// setup canvas and elements:
		iron.data.Data.getFont("C:/Windows/Fonts/Arial.ttf", function(f: kha.Font)
		{
			canvas_1.elements = element_array_1;
			canvas_1.assets = asset_array_1;

			// tell the zui which fonts and theme to use:
			zui_options_1 = {font: f, theme: zui.Themes.light};

			zui_1 = new Zui(zui_options_1);

			iron.data.Data.getImage("E:/Blender/Projects/Assets/icosphere.png", function(image: kha.Image)
			{
				assetMap.set(canvas_1.assets[0].id, image);
			});
			iron.data.Data.getImage("E:/Blender/Projects/Assets/inventory_background.png", function(image: kha.Image)
			{
				assetMap.set(canvas_1.assets[1].id, image);
			});
		});*/
	
		callOnRender2D(function(g: kha.graphics2.Graphics)
		{
			if (canvas_1 == null) return; if (canvas_1.elements == null) return;

			//canvas_1.width = kha.System.windowWidth()
			//canvas_1.height = kha.System.windowHeight()
			//setCanvasDimensions(kha.System.windowWidth(), kha.System.windowHeight());

			var eventNameArray = draw(zui_1, canvas_1, g);
	
			for (e in eventNameArray)
			{
				var eventArray = armory.system.Event.get(e);
				if (eventArray != null)
				{
					for (event in eventArray)
					{
						event.onEvent();
					}
				}
			}
		});
	}




//_____________________________________________________________________________________________________________________________________________________________________________




	static public function draw(zui_1: Zui, canvas: Tcanvas, g: kha.graphics2.Graphics): Array<String>
	{
		screenW = kha.System.windowWidth();
		screenH = kha.System.windowHeight();
	
		events = [];
	
		zui_2 = zui_1;
	
		g.end();
		zui_1.begin(g); // Bake elements
		g.begin(false);
	
		zui_2.g = g;
	
		// draw every single element:
		for (elem in canvas.elements)
		{
			if (elem.parent == null) drawElement(zui_2, canvas, elem);
		}
	
		g.end();
		zui_2.end(); // Finish drawing
		g.begin(false);
	
		return events;
	}
	
	static public function drawElement(ui: Zui, canvas: Tcanvas, element: Telement, px = 0.0, py = 0.0)
	{
		if (element == null || element.visible == false) return;

		ui._x = canvas.x + scaled(element.x) + px;
		ui._y = canvas.y + scaled(element.y) + py;
		ui._w = scaled(element.width);

		var rotated = element.rotation != null && element.rotation != 0;
		if (rotated) ui.g.pushRotation(element.rotation, ui._x + scaled(element.width) / 2, ui._y + scaled(element.height) / 2);

		switch (element.type)
		{
			case Text:
				var font = ui.ops.font;
				var size = ui.fontSize;

				var fontAsset = element.asset != null && StringTools.endsWith(element.asset, ".ttf");
				if (fontAsset) ui.ops.font = getAsset(canvas, element.asset);
				ui.fontSize = scaled(element.height);
				ui.t.TEXT_COL = element.color_text;
				ui.text(getText(canvas, element), element.alignment);

				ui.ops.font = font;
				ui.fontSize = size;

			case Button:
				var eh = ui.t.ELEMENT_H;
				var bh = ui.t.BUTTON_H;
				ui.t.ELEMENT_H = element.height;
				ui.t.BUTTON_H = element.height;
				ui.t.BUTTON_COL = element.color;
				ui.t.BUTTON_TEXT_COL = element.color_text;
				ui.t.BUTTON_HOVER_COL = element.color_hover;
				ui.t.BUTTON_PRESSED_COL = element.color_press;
				if (ui.button(getText(canvas, element), element.alignment))
				{
					var e = element.event;
					if (e != null && e != "") events.push(e);
				}
				ui.t.ELEMENT_H = eh;
				ui.t.BUTTON_H = bh;

			case Image:
				var image = getAsset(canvas, element.asset);
				var fontAsset = element.asset != null && StringTools.endsWith(element.asset, ".ttf");
				if (image != null && !fontAsset)
					{
					ui.imageScrollAlign = false;
					var tint = element.color != null ? element.color : 0xffffffff;
					if (ui.image(image, tint, scaled(element.height)) == zui.Zui.State.Released)
					{
						var e = element.event;
						if (e != null && e != "") events.push(e);
					}
					ui.imageScrollAlign = true;
				}

			case FRectangle:
				var col = ui.g.color;
				ui.g.color = element.color;
				ui.g.fillRect(ui._x, ui._y, ui._w, scaled(element.height));
				ui.g.color = col;

			case FCircle:
				var col = ui.g.color;
				ui.g.color = element.color;
				ui.g.fillCircle(ui._x + (scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), ui._w / 2);
				ui.g.color = col;

			case Rectangle:
				var col = ui.g.color;
				ui.g.color = element.color;
				ui.g.drawRect(ui._x, ui._y, ui._w, scaled(element.height), element.strength);
				ui.g.color = col;

			case Circle:
				var col = ui.g.color;
				ui.g.color = element.color;
				ui.g.drawCircle(ui._x+(scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), ui._w / 2, element.strength);
				ui.g.color = col;

			case FTriangle:
				var col = ui.g.color;
				ui.g.color = element.color;
				ui.g.fillTriangle(ui._x + (ui._w / 2), ui._y, ui._x, ui._y + scaled(element.height), ui._x + ui._w, ui._y + scaled(element.height));
				ui.g.color = col;

			case Triangle:
				var col = ui.g.color;
				ui.g.color = element.color;
				ui.g.drawLine(ui._x + (ui._w / 2), ui._y, ui._x, ui._y + scaled(element.height), element.strength);
				ui.g.drawLine(ui._x, ui._y + scaled(element.height), ui._x + ui._w, ui._y + scaled(element.height), element.strength);
				ui.g.drawLine(ui._x + ui._w, ui._y + scaled(element.height), ui._x + (ui._w / 2), ui._y, element.strength);
				ui.g.color = col;

			case Check:
				ui.t.TEXT_COL = element.color_text;
				ui.t.ACCENT_COL = element.color_progress;
				ui.t.ACCENT_HOVER_COL = element.color_hover;
				ui.check(h.nest(element.id), getText(canvas, element));

			case Radio:
				ui.t.TEXT_COL = element.color_text;
				ui.t.ACCENT_COL = element.color_progress;
				ui.t.ACCENT_HOVER_COL = element.color_hover;
				Ext.inlineRadio(ui, h.nest(element.id), getText(canvas, element).split(";"));

			case Combo:
				ui.t.TEXT_COL = element.color_text;
				ui.t.LABEL_COL = element.color_text;
				ui.t.ACCENT_COL = element.color_progress;
				ui.t.SEPARATOR_COL = element.color;
				ui.t.ACCENT_HOVER_COL = element.color_hover;
				ui.combo(h.nest(element.id), getText(canvas, element).split(";"));

			case Slider:
				ui.t.TEXT_COL = element.color_text;
				ui.t.LABEL_COL = element.color_text;
				ui.t.ACCENT_COL = element.color_progress;
				ui.t.ACCENT_HOVER_COL = element.color_hover;
				ui.slider(h.nest(element.id), getText(canvas, element), 0.0, 1.0, true, 100, true, element.alignment);

			case TextInput:
				ui.t.TEXT_COL = element.color_text;
				ui.t.LABEL_COL = element.color_text;
				ui.t.ACCENT_COL = element.color_progress;
				ui.t.ACCENT_HOVER_COL = element.color_hover;
				ui.textInput(h.nest(element.id), getText(canvas, element), element.alignment);
				if (h.nest(element.id).changed) {
					var e = element.event;
					if (e != null && e != "") events.push(e);
				}

			case KeyInput:
				ui.t.TEXT_COL = element.color_text;
				ui.t.LABEL_COL = element.color_text;
				ui.t.ACCENT_COL = element.color_progress;
				ui.t.ACCENT_HOVER_COL = element.color_hover;
				Ext.keyInput(ui, h.nest(element.id), getText(canvas, element));

			case ProgressBar:
				var col = ui.g.color;
				var progress = element.progress_at;
				var totalprogress = element.progress_total;
				ui.g.color = element.color_progress;
				ui.g.fillRect(ui._x, ui._y, ui._w / totalprogress * Math.min(progress, totalprogress), scaled(element.height));
				ui.g.color = element.color;
				ui.g.drawRect(ui._x, ui._y, ui._w, scaled(element.height), element.strength);
				ui.g.color = col;

			case CProgressBar:
				var col = ui.g.color;
				var progress = element.progress_at;
				var totalprogress = element.progress_total;
				ui.g.color = element.color_progress;
				ui.g.drawArc(ui._x + (scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), ui._w / 2, -Math.PI / 2, ((Math.PI * 2) / totalprogress * progress) - Math.PI / 2, element.strength);
				ui.g.color = element.color;
				ui.g.fillCircle(ui._x + (scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), (ui._w / 2) - 10);
				ui.g.color = col;

			case DragAble:
				var image = getAsset(canvas, element.asset);
				var fontAsset = element.asset != null && StringTools.endsWith(element.asset, ".ttf");
				if (image != null && !fontAsset)
				{
					ui.imageScrollAlign = false;
					var tint = element.color != null ? element.color : 0xffffffff;

					var currentState = ui.image(image, tint, scaled(element.height));

					/*if (currentState == zui.Zui.State.Started)	
					{
						element.drag = true;

						if(element.name != canvas.elements[canvas.elements.length - 1].name)
						{
							if (element.event != null && element.event != "") events.push(element.event);

							var kaka: Telement = canvas.elements.pop();

							for (x in 0...(canvas.elements.length))
							{
								if(canvas.elements[x].type == Empty)
								{
									if(canvas.elements[x].name != element.name)
									{
										canvas.elements[x] = kaka;
									}
								}
							}

							var koko: Telement = {id: element.id, type: DragAble, name: element.name, x: element.x, y: element.y, width: element.width, height: element.height, asset: element.asset, event: element.event, drag: element.drag};
							
							element.type = Empty;
							canvas.elements.push(koko);
						}
					}*/
					if (currentState == zui.Zui.State.Started)
					{
						element.drag = true;

						if(element.name != canvas.elements[canvas.elements.length - 1].name)
						{
							if (element.event != null && element.event != "") events.push(element.event);
							
							var kaka: Telement = canvas.elements.pop();//canvas.elements[canvas.elements.length - 1];
							canvas.elements[canvas.elements.indexOf(element)] = kaka;
							canvas.elements.push(element);
						}
					}
					else if(!Input.getMouse().down()) element.drag = false;
					
					if(element.drag)
					{
						element.x += ui.inputDX;
						element.y += ui.inputDY;
					}
					ui.imageScrollAlign = true;
				}

			case Container:
				var totalSizeX: Int = (element.width * element.alignment - element.width + Std.int(element.x));
				var totalSizeY: Int = (element.height * element.alignment - element.height + Std.int(element.y));

				for(k in 0...element.alignment)
				{
					for(h in 0...canvas.elements.length)
					{
						if((canvas.elements[h].type == DragAble) && (!canvas.elements[h].drag))
						{
							canvas.elements[h].x = Math.round(canvas.elements[h].x/100) * 100;
							canvas.elements[h].y = Math.round(canvas.elements[h].y/100) * 100;
							if(canvas.elements[h].x > totalSizeX) canvas.elements[h].x = totalSizeX;
							else if(canvas.elements[h].x < element.x) canvas.elements[h].x = element.x;
							if(canvas.elements[h].y > totalSizeY) canvas.elements[h].y = totalSizeY;
							else if(canvas.elements[h].y < element.y) canvas.elements[h].y = element.y;
						}
					}
				}
				var image = getAsset(canvas, element.asset);
				var fontAsset = element.asset != null && StringTools.endsWith(element.asset, ".ttf");
				if (image != null && !fontAsset)
					{
					ui.imageScrollAlign = false;
					var tint = element.color != null ? element.color : 0xffffffff;
					if (ui.image(image, tint, scaled(element.height * element.alignment)) == zui.Zui.State.Released)
					{
						var e = element.event;
						if (e != null && e != "") events.push(e);
					}
					ui.imageScrollAlign = true;
				}
			
			case Empty:
		}

		if (element.children != null)
		{
			for (id in element.children)
			{
				drawElement(ui, canvas, elemById(canvas, id), scaled(element.x) + px, scaled(element.y) + py);
			}
		}

		if (rotated) ui.g.popTransformation();
	}
	
	static inline function getText(canvas: Tcanvas, e: Telement): String
	{
		return e.text;
	}

	public static function getAsset(canvas: Tcanvas, asset: String): Dynamic // kha.Image | kha.Font
	{
		for (a in canvas.assets) if (a.name == asset) return assetMap.get(a.id);
		return null;
	}

	public function setAsset(asset: Tasset, image: kha.Image): Void
	{
		assetMap.set(asset.id, image);
	}

	static var elemId = -1;
	public static function getElementId(canvas: Tcanvas): Int
	{
		if (elemId == -1) for (e in canvas.elements) if (elemId < e.id) elemId = e.id;
		return ++elemId;
	}

	static var assetId = -1;
	public static function getAssetId(canvas: Tcanvas): Int
	{
		if (assetId == -1) for (a in canvas.assets) if (assetId < a.id) assetId = a.id;
		return ++assetId;
	}

	static function elemById(canvas: Tcanvas, id: Int): Telement
	{
		for (e in canvas.elements) if (e.id == id) return e;
		return null;
	}

	static inline function scaled(f: Float): Int
	{
		return Std.int(f * zui_2.SCALE());
	}

	public static inline function getColor(color: Null<Int>, defaultColor: Int): Int
	{
		return color != null ? color : defaultColor;
	}

	public static function getTheme(theme: String): zui.Themes.TTheme
	{
		for (t in themes)
		{
			if (t.NAME == theme) return t;
		}

		return null;
	}

	public function setCanvasVisibility(visible: Bool)
	{ 
		if(canvas_1.elements == null) return;
		for(i in 0...canvas_1.elements.length)
		{
			canvas_1.elements[i].visible = visible;
		}
	}

	public function callOnRender2D(f: kha.graphics2.Graphics->Void)
	{
		if (render2D == null) render2D = [];
		render2D.push(f);
		App.notifyOnRender2D(f);
	}
}



//_____________________________________________________________________________________________________________________________________________________________________________




typedef Tcanvas = {
	var name: String;
	var x: Float;
	var y: Float;
	var width: Int;
	var height: Int;
	var elements: Array<Telement>;
	var theme: String;
	@:optional var assets: Array<Tasset>;
	@:optional var locales: Array<Tlocale>;
}

typedef Telement = {
	var id: Int;
	var type: TelementType;
	var name: String;
	var x: Float;
	var y: Float;
	var width: Int;
	var height: Int;
	@:optional var rotation: Null<kha.FastFloat>;
	@:optional var text: String;
	@:optional var event: String;
	// null = follow theme settings
	@:optional var color: Null<Int>;
	@:optional var color_text: Null<Int>;
	@:optional var color_hover: Null<Int>;
	@:optional var color_press: Null<Int>;
	@:optional var color_progress: Null<Int>;
	@:optional var progress_at: Null<Int>;
	@:optional var progress_total: Null<Int>;
	@:optional var strength: Null<Int>;
	@:optional var alignment: Null<Int>;
	@:optional var anchor: Null<Int>;
	@:optional var parent: Null<Int>; // id
	@:optional var children: Array<Int>; // ids
	@:optional var asset: String;
	@:optional var visible: Null<Bool>;
	@:optional var drag: Null<Bool>;
}

typedef Tasset =
{
	var id: Int;
	var name: String;
	var file: String;
}

typedef Tlocale =
{
	var name: String; // "en"
	var texts: Array<TtranslatedText>;
}

typedef TtranslatedText =
{
	var id: Int; // element id
	var text: String;
}

@:enum abstract TelementType(Int) from Int to Int
{
	var Text = 0;
	var Image = 1;
	var Button = 2;
	var Empty = 3;
	// var HLayout = 4;
	// var VLayout = 5;
	var Check = 6;
	var Radio = 7;
	var Combo = 8;
	var Slider = 9;
	var TextInput = 10;
	var KeyInput = 11;
	var FRectangle = 12;
	var Rectangle = 13;
	var FCircle = 14;
	var Circle = 15;
	var FTriangle = 16;
	var Triangle = 17;
	var ProgressBar = 18;
	var CProgressBar = 19;
	var DragAble = 20;
	var Container = 21;
}

@:enum abstract Tanchor(Int) from Int to Int
{
	var TopLeft = 0;
	var Top = 1;
	var TopRight = 2;
	var CenterLeft = 3;
	var Center = 4;
	var CenterRight = 5;
	var BottomLeft = 6;
	var Bottom = 7;
	var BottomRight = 8;
}