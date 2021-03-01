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
	var bone: TObj;

	var ik_solver_1 = new IK_solver("Armature", "lower_arm.r", function(i: IK_solver)
	{

	}, 2);

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			//GetLocal.findAnimation(Scene.active.getChild("Armature")).play("idle");

			goal = Scene.active.getChild("Cone.004").transform.loc;
			anim = GetLocal.findAnimation(Scene.active.getChild("Armature"));
			bone = anim.getBone("index_4.r");

			GetLocal.findAnimation(Scene.active.getChild("Armature")).notifyOnUpdate(function()
			{
				ik_solver_1.solve(goal);
			});
		});

		notifyOnUpdate(function()
		{
			
		});

		// notifyOnRemove(function() {
		// });
	}
}
