package zui;

import haxe.macro.Tools.TMacroStringTools;
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
	
	public function new()
	{
		super();
	
		callOnRender2D(function(g: kha.graphics2.Graphics)
		{
			if (canvas_1 == null || canvas_1.elements == null || zui_1 == null) return;

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
		trace(canvas.elements);
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

					if (currentState == zui.Zui.State.Started)
					{
						if (element.event != null && element.event != "") events.push(element.event);
						element.drag = true;
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
				for(k in 0...element.alignment)
				{
					for(h in 0...canvas.elements.length)
					{
						if((canvas.elements[h].type == DragAble) && (!canvas.elements[h].drag))
						{
							var currentX = element.x;
							var currentY = element.y;
							var used: Bool = false;
							var break_1: Bool = false;

							// initial alignment in container:
							if(canvas.elements[h].lastX == null)
							{
								while(currentY < element.height * element.alignment + element.y)
								{
									currentX = element.x;
									while(currentX < element.width * element.alignment + element.x)
									{
										used = false;
										for(c in 0...canvas.elements.length)
										{
											if((currentX == canvas.elements[c].x) && (currentY == canvas.elements[c].y) && (canvas.elements[h].id != canvas.elements[c].id) && (canvas.elements[c].type == DragAble))
											{
												used = true;
												break;
											}
										}
										if(!used)
										{
											canvas.elements[h].x = currentX;
											canvas.elements[h].lastX = currentX;
											canvas.elements[h].y = currentY;
											canvas.elements[h].lastY = currentY;
											break_1 = true;
											break;
										}
										currentX += element.width;
									}
									if(break_1) break;
									currentY += element.height;
								}
							}
							// alignment if DragAble is let go:
							else
							{
								var totalSizeX: Int = (element.width * element.alignment - element.width + Std.int(element.x));
								var totalSizeY: Int = (element.height * element.alignment - element.height + Std.int(element.y));

								canvas.elements[h].x = Math.round(canvas.elements[h].x/100) * 100;
								canvas.elements[h].y = Math.round(canvas.elements[h].y/100) * 100;
								
								if(canvas.elements[h].x > totalSizeX) canvas.elements[h].x = totalSizeX;
								else if(canvas.elements[h].x < element.x) canvas.elements[h].x = element.x;
								if(canvas.elements[h].y > totalSizeY) canvas.elements[h].y = totalSizeY;
								else if(canvas.elements[h].y < element.y) canvas.elements[h].y = element.y;
	
								var used: Bool = false;
								for(a in 0...canvas.elements.length)
								{
									if((canvas.elements[h].x == canvas.elements[a].x) && (canvas.elements[h].y == canvas.elements[a].y) && (canvas.elements[h].id != canvas.elements[a].id) && (canvas.elements[a].type == DragAble))
									{
										used = true;
										break;
									}
								}
								if(!used)
								{
									canvas.elements[h].lastX = canvas.elements[h].x;
									canvas.elements[h].lastY = canvas.elements[h].y;
								}
								else
								{
									canvas.elements[h].x = canvas.elements[h].lastX;
									canvas.elements[h].y = canvas.elements[h].lastY;
								}
							}
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
	@:optional var anchor: Null<Bool>;
	@:optional var parent: Null<Int>; // id
	@:optional var children: Array<Int>; // ids
	@:optional var asset: String;
	@:optional var visible: Null<Bool>;
	@:optional var drag: Null<Bool>;
	@:optional var lastX: Null<Float>;
	@:optional var lastY: Null<Float>;
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