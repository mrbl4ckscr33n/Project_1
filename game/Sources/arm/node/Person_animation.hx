package arm.node;

@:keep class Person_animation extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _PlayActionFrom = new armory.logicnode.PlayActionFromNode(this);
		var _InvertOutput = new armory.logicnode.InverseNode(this);
		var _Keyboard = new armory.logicnode.MergedKeyboardNode(this);
		_Keyboard.property0 = "Down";
		_Keyboard.property1 = "w";
		var _SetActionSpeed = new armory.logicnode.SetActionSpeedNode(this);
		_SetActionSpeed.addInput(_Keyboard, 0);
		_SetActionSpeed.addInput(new armory.logicnode.ObjectNode(this, "Armature.001"), 0);
		_SetActionSpeed.addInput(new armory.logicnode.FloatNode(this, 1.399999976158142), 0);
		_SetActionSpeed.addOutputs([new armory.logicnode.NullNode(this)]);
		_Keyboard.addOutputs([_InvertOutput, _SetActionSpeed]);
		_Keyboard.addOutputs([new armory.logicnode.BooleanNode(this, false)]);
		_InvertOutput.addInput(_Keyboard, 0);
		_InvertOutput.addOutputs([_PlayActionFrom]);
		_PlayActionFrom.addInput(_InvertOutput, 0);
		_PlayActionFrom.addInput(new armory.logicnode.ObjectNode(this, "Armature.001"), 0);
		_PlayActionFrom.addInput(new armory.logicnode.StringNode(this, "walk.002"), 0);
		_PlayActionFrom.addInput(new armory.logicnode.IntegerNode(this, 0), 0);
		_PlayActionFrom.addInput(new armory.logicnode.FloatNode(this, 0.20000000298023224), 0);
		_PlayActionFrom.addOutputs([new armory.logicnode.NullNode(this)]);
		_PlayActionFrom.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}