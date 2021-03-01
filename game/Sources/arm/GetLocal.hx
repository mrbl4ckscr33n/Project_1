package arm;

import iron.math.Vec4;
import iron.math.Quat;
import iron.math.Mat4;
import iron.system.Input;
import iron.object.Object;
import iron.object.BoneAnimation;
import iron.data.SceneFormat;
import iron.Scene;
import Math;

class GetLocal extends iron.Trait
{
	// for setting goal to armature space:
	var goal: Vec4;
	var m: Mat4;
	var a: Float;
	var b: Float;
	var c: Float;
	var goal_armature = new Vec4();

	// for kinematic:
	var armature: Object;
	var animation: BoneAnimation;
	var bone_0: TObj;
	var bone_1: TObj;
	var bone_0_armature: Mat4;
	var bone_1_armature: Mat4;
	var fromVec = new Vec4(); // the vector from bone to child in armature space
	var toVec = new Vec4();   // the new vector from bone to goal in armature space

	var loc_0 = new Vec4(); // for decomposing and composing
	var loc_1 = new Vec4();
	var scale_0 = new Vec4();
	var scale_1 = new Vec4();
	var quat_0 = new Quat();
	var quat_1 = new Quat();

	var quat_0_init = new Quat();

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			//object.animation.play();
			armature = Scene.active.getChild("Armature");
			animation = findAnimation(armature);
			animation.notifyOnUpdate(updateBones);

			bone_0 = animation.getBone("bone_0");
			bone_1 = animation.getBone("bone_1");

			// transform location of goal to local coordinates of armature itself:
			goal = Scene.active.getChild("goal").transform.loc;
			a = goal.x;
			b = goal.y;
			c = goal.z;

			m = object.transform.local.getInverse(armature.transform.local);

			// x = xAxis.x * a + yAxis.x * b + zAxis.x * c + loc.x; // multiply goal in worldspace by inverse of armature matrix to get goal in armature space
			// y = xAxis.y * a + yAxis.y * b + zAxis.y * c + loc.y;
			// z = xAxis.z * a + yAxis.z * b + zAxis.z * c + loc.z;
			// w = 1;

			// x = right.x * a + look.x * b + up.x * c + translate.x;
			// y = right.y * a + look.y * b + up.y * c + translate.y;
			// z = right.z * a + look.z * b + up.z * c + translate.z;
			// w = 1;

			goal_armature.x = m._00 * a + m._10 * b + m._20 * c + m._30;
			goal_armature.y = m._01 * a + m._11 * b + m._21 * c + m._31;
			goal_armature.z = m._02 * a + m._12 * b + m._22 * c + m._32;
			goal_armature.w = 1;

			animation.getWorldMat(bone_0).decompose(loc_0, quat_0_init, scale_0); // to get initial rotation of bone_0
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}

	function updateBones()
	{
		fromVec = animation.getWorldMat(bone_1).clone().getLoc().sub(animation.getWorldMat(bone_0).getLoc()); // bone_1_armature - bone_0_armature locations
		toVec = goal_armature.clone().sub(animation.getWorldMat(bone_0).getLoc()); // goal_armature - bone_0_armature locations

		quat_0.fromTo(fromVec.normalize(), toVec.normalize()).mult(quat_0_init); // multiply by initial rotation so bones can be rotated in blender

		animation.getBoneMat(bone_0).compose(loc_0, quat_0, scale_0);

		object.transform.buildMatrix();
		armature.transform.buildMatrix();
	}

	// copied from example :(
	public static function findAnimation(o:Object):BoneAnimation
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
