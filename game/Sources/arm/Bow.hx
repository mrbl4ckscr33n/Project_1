package arm;

import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import Math;
import iron.system.Input;
import iron.object.Object;
import iron.object.BoneAnimation;
import iron.data.SceneFormat;
import iron.Scene;

class Bow extends iron.Trait
{
	var thread: TObj;
	var bow_armature: Object;
	var anim:BoneAnimation;
	var m1: Mat4;
	var quat_1: Quat;

	var x: Float;
	var y: Float;
	var z: Float;

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			object.animation.play("wiggle");

			bow_armature = Scene.active.getChild("Bow_armature");
			anim = findAnimation(bow_armature);

			anim.notifyOnUpdate(updateBones);
		});

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().started("o")) y += 0.1;
		});

		// notifyOnRemove(function() {
		// });
	}

	function updateBones()
	{
		thread = anim.getBone("thread");
		var thread_2 = anim.getBone("bone_5");

		//trace(thread_2);

		m1 = anim.getBoneMat(thread);

		var loc_1 = new Vec4(x, y, z);
		m1.setLoc(loc_1);

		object.transform.buildMatrix();
	}

	// copied from example i dunno man :(
	function findAnimation(o:Object):BoneAnimation
	{
		if (o.animation != null) return cast o.animation;
		for (c in o.children)
		{
			var co = findAnimation(c);
			if (co != null) return co;
		}
		return null;
	}
}