package arm;

import zui.NewCanvasScript; 

class Interactive extends iron.Trait
{
	public function new()
	{
		super();

		notifyOnInit(function()
		{
			var element_1: Telement = {id: null, type: DragAble, name: null, x: null, y: null, width: 100, height: 100, asset: null, visible: false, drag: false};
			// asset is null because the asset does not exist yet
			object.properties = new Map();
			object.properties["pickUpAble"] = true;
			object.properties["amountInventory"] = 0;
			object.properties["Telement"] = element_1;
		});

		// notifyOnUpdate(function() {
		//});

		// notifyOnRemove(function() {
		// });
	}
}