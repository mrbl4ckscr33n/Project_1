package arm;

import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import iron.system.Input;
import iron.object.Object;
import iron.object.BoneAnimation;
import iron.data.SceneFormat;
import iron.Scene;
import arm.Bone.Cartesian;
import arm.Bone.Euler;
import Math;
import arm.AnimationOps;

class IK_test extends iron.Trait
{
	var armature: Object;
	var animation: BoneAnimation;
	var firstBone: TObj;
	var bone_1: TObj;
	var bone_0: TObj;
	var bone_2: TObj;
	var target = new Cartesian();

	var loc = new Vec4();
	var quat = new Quat();
	var scale = new Vec4(1,1,1);

	var roll: Float = 0;
	var pitch: Float = 0;
	var yaw: Float = 0;

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			object.animation.play("shit");
			armature = Scene.active.getChild("Armature");
			animation = AnimationOps.findAnimation(armature);
			animation.notifyOnUpdate(fun_1);

			bone_0 = animation.getBone("bone_0");
			bone_1 = animation.getBone("bone_1");
			bone_2 = animation.getBone("bone_2");
		});

		notifyOnUpdate(function()
		{
		});

		// notifyOnRemove(function() {
		// });
	}

	function fun_1()
	{
		var euler_1 = new Vec4(0, Math.PI/2, 0);
		quat.fromEuler(euler_1.x, euler_1.y, euler_1.z);
		animation.getBoneMat(bone_0).compose(loc, quat, scale);
		//animation.applyParent[animation.getBoneIndex(bone_0)] = true;
		trace(quat);
		object.transform.buildMatrix();
		armature.transform.buildMatrix();
	}
}
