package arm;

import iron.math.Quat;
import iron.data.SceneFormat.TObj;
import iron.object.BoneAnimation;
import iron.Scene;
import iron.math.Vec4;
import iron.system.Input;
import iron.system.Time;

class MyTrait extends iron.Trait
{
	var time: Float;
	var goal: Vec4;
	var anim: BoneAnimation;
	var bone_4: TObj;
	var bone_9: TObj;

	var ik_solver_1 = new IK_solver("Armature_2", "bone_4", function(i: IK_solver)
	{

	}, 3);

	var ik_solver_2 = new IK_solver("Armature_2", "bone_9", function(i: IK_solver)
	{

	}, 3);

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			GetLocal.findAnimation(Scene.active.getChild("Armature_2")).play("bow");

			goal = Scene.active.getChild("Cone.004").transform.loc;
			anim = GetLocal.findAnimation(Scene.active.getChild("Armature_2"));
			bone_4 = anim.getBone("bone_4");
			bone_9 = anim.getBone("bone_9");

			GetLocal.findAnimation(Scene.active.getChild("Armature_2")).notifyOnUpdate(function()
			{
				ik_solver_1.solve(goal);
			});

			GetLocal.findAnimation(Scene.active.getChild("Armature_2")).notifyOnUpdate(function()
			{
				ik_solver_2.solve(goal);
			});
		});

		notifyOnUpdate(function()
		{
			if(Input.getKeyboard().down('up')) Scene.active.getChild("Cone.004").transform.loc.x += 0.01;
			else if(Input.getKeyboard().down('down')) Scene.active.getChild("Cone.004").transform.loc.x -= 0.01;
		});

		// notifyOnRemove(function() {
		// });
	}
}
