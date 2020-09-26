package arm;

using kha.graphics2.GraphicsExtension;

import kha.Font;
import armory.system.Event;
import iron.data.Data;
import iron.Trait;
import zui.Zui;
import zui.Ext;
import zui.Themes;

class NewCanvasScript extends iron.Trait
{
	#if arm_ui
	
		var zui_1: Zui;
		var canvas_1: TCanvas;
		var zui_options_1: ZuiOptions;
		var element_1: TElement;
		var element_2: TElement;

		var element_array_1 = new Array<TElement>();
		var asset_array_1 = new Array<TAsset>();
		var asset_1: TAsset;
		var asset_2: TAsset;

		public var ready(get, null): Bool;
		function get_ready(): Bool { return canvas_1 != null; }
	
		public function new()
		{
			super();

			Event.add("trace", function()
			{
				canvas_1.elements[0].x += 10;
			});

			// idk:
			if (NewCanvas.themes.length == 0)
			{
				NewCanvas.themes.push(zui.Themes.light);
			}

			// create element array for canvas:
			element_1 = {id: 0, type: 1, name: "img_1", x: 720, y: 120, width: 256, height: 256, text: null, asset: "asset_1", event: "trace"};
			element_2 = {id: 1, type: 2, name: "btn_1", x: 0, y: 0, width: 50, height: 50, text: "push to move", asset: null, event: "trace"};
			element_array_1[0] = element_1;
			element_array_1[1] = element_2;

			// create asset array for canvas:
			asset_1 = {id: 0, name: "asset_1", file: "../../Assets/icosphere.png"};
			asset_array_1[0] = asset_1;

			// setup canvas and elements:
			iron.data.Data.getFont("font_default.ttf", function(f: kha.Font)
			{
				canvas_1 = {name: "canvas_1", x: 0, y: 0, width: 960, height: 540, elements: element_array_1, theme: "Default Light", assets: asset_array_1};

				// tell the zui which fonts and theme to use:
				zui_options_1 = {font: f, theme: zui.Themes.light};

				zui_1 = new Zui(zui_options_1);

				iron.data.Data.getImage("icosphere.png", function(image: kha.Image)
				{
					NewCanvas.assetMap.set(canvas_1.assets[0].id, image);
				});
			});
	
			notifyOnRender2D(function(g: kha.graphics2.Graphics)
			{
				if (canvas_1 == null) return;

				//canvas_1.width = kha.System.windowWidth()
				//canvas_1.height = kha.System.windowHeight()
				//setCanvasDimensions(kha.System.windowWidth(), kha.System.windowHeight());

				var eventNameArray = NewCanvas.draw(zui_1, canvas_1, g);
	
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

	#else
	
		public function new(canvasName: String) { super(); }
	
	#end
}




//_____________________________________________________________________________________________________________________________________________________________________________




@:access(zui.Zui)
class NewCanvas
{
	public static var assetMap = new Map<Int, Dynamic>(); // kha.Image | kha.Font
	public static var themes = new Array<zui.Themes.TTheme>();
	static var events:Array<String> = [];

	public static var screenW = -1;
	public static var screenH = -1;
	static var zui_2: Zui;
	static var h = new zui.Zui.Handle(); // TODO: needs one handle per canvas

	public static function draw(zui_1: Zui, canvas: TCanvas, g: kha.graphics2.Graphics): Array<String>
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
			if (elem.parent == null)
			{
				drawElement(zui_2, canvas, elem);
			}
		}

		g.end();
		zui_2.end(); // Finish drawing
		g.begin(false);

		return events;
	}

	static function drawElement(ui: Zui, canvas: TCanvas, element: TElement, px = 0.0, py = 0.0) {

		if (element == null || element.visible == false) return;

		ui._x = canvas.x + scaled(element.x) + px;
		ui._y = canvas.y + scaled(element.y) + py;
		ui._w = scaled(element.width);

		var rotated = element.rotation != null && element.rotation != 0;
		if (rotated) ui.g.pushRotation(element.rotation, ui._x + scaled(element.width) / 2, ui._y + scaled(element.height) / 2);

		switch (element.type) {
		case Text:
			var font = ui.ops.font;
			var size = ui.fontSize;

			var fontAsset = element.asset != null && StringTools.endsWith(element.asset, ".ttf");
			if (fontAsset) ui.ops.font = getAsset(canvas, element.asset);
			ui.fontSize = scaled(element.height);
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.text(getText(canvas, element), element.alignment);

			ui.ops.font = font;
			ui.fontSize = size;

		case Button:
			var eh = ui.t.ELEMENT_H;
			var bh = ui.t.BUTTON_H;
			ui.t.ELEMENT_H = element.height;
			ui.t.BUTTON_H = element.height;
			ui.t.BUTTON_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.BUTTON_TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).BUTTON_TEXT_COL);
			ui.t.BUTTON_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			ui.t.BUTTON_PRESSED_COL = getColor(element.color_press, getTheme(canvas.theme).BUTTON_PRESSED_COL);
			if (ui.button(getText(canvas, element), element.alignment)) {
				var e = element.event;
				if (e != null && e != "") events.push(e);
			}
			ui.t.ELEMENT_H = eh;
			ui.t.BUTTON_H = bh;

		case Image:
			var image = getAsset(canvas, element.asset);
			var fontAsset = element.asset != null && StringTools.endsWith(element.asset, ".ttf");
			if (image != null && !fontAsset) {
				ui.imageScrollAlign = false;
				var tint = element.color != null ? element.color : 0xffffffff;
				if (ui.image(image, tint, scaled(element.height)) == zui.Zui.State.Released) {
					var e = element.event;
					if (e != null && e != "") events.push(e);
				}
				ui.imageScrollAlign = true;
			}

		case FRectangle:
			var col = ui.g.color;
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.fillRect(ui._x, ui._y, ui._w, scaled(element.height));
			ui.g.color = col;

		case FCircle:
			var col = ui.g.color;
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.fillCircle(ui._x + (scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), ui._w / 2);
			ui.g.color = col;

		case Rectangle:
			var col = ui.g.color;
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.drawRect(ui._x, ui._y, ui._w, scaled(element.height), element.strength);
			ui.g.color = col;

		case Circle:
			var col = ui.g.color;
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.drawCircle(ui._x+(scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), ui._w / 2, element.strength);
			ui.g.color = col;

		case FTriangle:
			var col = ui.g.color;
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.fillTriangle(ui._x + (ui._w / 2), ui._y, ui._x, ui._y + scaled(element.height), ui._x + ui._w, ui._y + scaled(element.height));
			ui.g.color = col;

		case Triangle:
			var col = ui.g.color;
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.drawLine(ui._x + (ui._w / 2), ui._y, ui._x, ui._y + scaled(element.height), element.strength);
			ui.g.drawLine(ui._x, ui._y + scaled(element.height), ui._x + ui._w, ui._y + scaled(element.height), element.strength);
			ui.g.drawLine(ui._x + ui._w, ui._y + scaled(element.height), ui._x + (ui._w / 2), ui._y, element.strength);
			ui.g.color = col;

		case Check:
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.ACCENT_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.ACCENT_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			ui.check(h.nest(element.id), getText(canvas, element));

		case Radio:
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.ACCENT_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.ACCENT_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			Ext.inlineRadio(ui, h.nest(element.id), getText(canvas, element).split(";"));

		case Combo:
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.LABEL_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.ACCENT_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.SEPARATOR_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.ACCENT_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			ui.combo(h.nest(element.id), getText(canvas, element).split(";"));

		case Slider:
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.LABEL_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.ACCENT_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.ACCENT_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			ui.slider(h.nest(element.id), getText(canvas, element), 0.0, 1.0, true, 100, true, element.alignment);

		case TextInput:
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.LABEL_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.ACCENT_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.ACCENT_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			ui.textInput(h.nest(element.id), getText(canvas, element), element.alignment);
			if (h.nest(element.id).changed) {
				var e = element.event;
				if (e != null && e != "") events.push(e);
			}

		case KeyInput:
			ui.t.TEXT_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.LABEL_COL = getColor(element.color_text, getTheme(canvas.theme).TEXT_COL);
			ui.t.ACCENT_COL = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.t.ACCENT_HOVER_COL = getColor(element.color_hover, getTheme(canvas.theme).BUTTON_HOVER_COL);
			Ext.keyInput(ui, h.nest(element.id), getText(canvas, element));

		case ProgressBar:
			var col = ui.g.color;
			var progress = element.progress_at;
			var totalprogress = element.progress_total;
			ui.g.color = getColor(element.color_progress, getTheme(canvas.theme).TEXT_COL);
			ui.g.fillRect(ui._x, ui._y, ui._w / totalprogress * Math.min(progress, totalprogress), scaled(element.height));
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.drawRect(ui._x, ui._y, ui._w, scaled(element.height), element.strength);
			ui.g.color = col;

		case CProgressBar:
			var col = ui.g.color;
			var progress = element.progress_at;
			var totalprogress = element.progress_total;
			ui.g.color = getColor(element.color_progress, getTheme(canvas.theme).TEXT_COL);
			ui.g.drawArc(ui._x + (scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), ui._w / 2, -Math.PI / 2, ((Math.PI * 2) / totalprogress * progress) - Math.PI / 2, element.strength);
			ui.g.color = getColor(element.color, getTheme(canvas.theme).BUTTON_COL);
			ui.g.fillCircle(ui._x + (scaled(element.width) / 2), ui._y + (scaled(element.height) / 2), (ui._w / 2) - 10);
			ui.g.color = col;
		case Empty:
		}

		if (element.children != null) {
			for (id in element.children) {
				drawElement(ui, canvas, elemById(canvas, id), scaled(element.x) + px, scaled(element.y) + py);
			}
		}

		if (rotated) ui.g.popTransformation();
	}

	static inline function getText(canvas: TCanvas, e: TElement): String {
		return e.text;
	}

	public static function getAsset(canvas: TCanvas, asset: String): Dynamic { // kha.Image | kha.Font
		for (a in canvas.assets) if (a.name == asset) return assetMap.get(a.id);
		return null;
	}

	static var elemId = -1;
	public static function getElementId(canvas: TCanvas): Int {
		if (elemId == -1) for (e in canvas.elements) if (elemId < e.id) elemId = e.id;
		return ++elemId;
	}

	static var assetId = -1;
	public static function getAssetId(canvas: TCanvas): Int {
		if (assetId == -1) for (a in canvas.assets) if (assetId < a.id) assetId = a.id;
		return ++assetId;
	}

	static function elemById(canvas: TCanvas, id: Int): TElement {
		for (e in canvas.elements) if (e.id == id) return e;
		return null;
	}

	static inline function scaled(f: Float): Int { return Std.int(f * zui_2.SCALE()); }

	public static inline function getColor(color: Null<Int>, defaultColor: Int): Int {
		return color != null ? color : defaultColor;
	}

	public static function getTheme(theme: String): zui.Themes.TTheme {
		for (t in NewCanvas.themes) {
			if (t.NAME == theme) return t;
		}

		return null;
	}

	/**
	 * Returns the positional scaled offset of the given element based on its anchor setting.
	 * @param canvas The canvas object
	 * @param element The element
	 * @return Array<Float> [xOffset, yOffset]
	 */
	public static function getAnchorOffset(canvas: TCanvas, element: TElement): Array<Float> {
		var boxWidth, boxHeight: Float;
		var offsetX = 0.0;
		var offsetY = 0.0;

		if (element.parent == null) {
			boxWidth = canvas.width;
			boxHeight = canvas.height;
		} else {
			var parent = elemById(canvas, element.parent);
			boxWidth = scaled(parent.width);
			boxHeight = scaled(parent.height);
		}

		switch (element.anchor) {
			case Top:
				offsetX += boxWidth / 2 - scaled(element.width) / 2;
			case TopRight:
				offsetX += boxWidth - scaled(element.width);
			case CenterLeft:
				offsetY += boxHeight / 2 - scaled(element.height) / 2;
			case Center:
				offsetX += boxWidth / 2 - scaled(element.width) / 2;
				offsetY += boxHeight / 2 - scaled(element.height) / 2;
			case CenterRight:
				offsetX += boxWidth - scaled(element.width);
				offsetY += boxHeight / 2 - scaled(element.height) / 2;
			case BottomLeft:
				offsetY += boxHeight - scaled(element.height);
			case Bottom:
				offsetX += boxWidth / 2 - scaled(element.width) / 2;
				offsetY += boxHeight - scaled(element.height);
			case BottomRight:
				offsetX += boxWidth - scaled(element.width);
				offsetY += boxHeight - scaled(element.height);
		}

		return [offsetX, offsetY];
	}
}




//_____________________________________________________________________________________________________________________________________________________________________________




typedef TCanvas = {
	var name: String;
	var x: Float;
	var y: Float;
	var width: Int;
	var height: Int;
	var elements: Array<TElement>;
	var theme: String;
	@:optional var assets: Array<TAsset>;
	@:optional var locales: Array<TLocale>;
}

typedef TElement = {
	var id: Int;
	var type: ElementType;
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
}

typedef TAsset = {
	var id: Int;
	var name: String;
	var file: String;
}

typedef TLocale = {
	var name: String; // "en"
	var texts: Array<TTranslatedText>;
}

typedef TTranslatedText = {
	var id: Int; // element id
	var text: String;
}

@:enum abstract ElementType(Int) from Int to Int {
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
}

@:enum abstract Anchor(Int) from Int to Int {
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

