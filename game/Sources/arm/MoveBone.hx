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

class MoveBone extends iron.Trait
{
	var armature: Object;
	var animation: BoneAnimation;
	var boneArray = new Array<Bone>(); // own bone class
	var targetBone: Bone;
	var pos = new Cartesian();

	public function new()
	{
		super();

		notifyOnInit(function()
		{
			var rotation = new Euler();
			var location_0 = new Cartesian();
			var bone_0 = new Bone(location_0, rotation, 2.0);
			var bone_1 = new Bone(bone_0.getTailAbs(), rotation, 2.0);
			var bone_2 = new Bone(bone_1.getTailAbs(), rotation, 2.0);

			var location_1 = new Cartesian(1, 1, 1);
			targetBone = new Bone(location_1, rotation, 1.0);

			boneArray.push(bone_0);
			boneArray.push(bone_1);
			boneArray.push(bone_2);

			Scene.active.spawnObject("Head_0", null, function(o: Object)
			{
			});

			Scene.active.spawnObject("Tail_0", null, function(o: Object)
			{
			});

			Scene.active.spawnObject("Head_1", null, function(o: Object)
			{
			});

			Scene.active.spawnObject("Tail_1", null, function(o: Object)
			{
			});

			Scene.active.spawnObject("Head_2", null, function(o: Object)
			{
			});

			Scene.active.spawnObject("Tail_2", null, function(o: Object)
			{
			});
			
			//object.animation.play("nothing");
			//armature = Scene.active.getChild("Bow_armature");
			//animation = findAnimation(armature);

			//animation.notifyOnUpdate(updateBones);
		});

		notifyOnUpdate(function()
		{
			if (Input.getKeyboard().started('o'))
			{
				pos.x += 0.5;
				AnimationOps.solveFABRIK(boneArray, targetBone);
			}
			else if (Input.getKeyboard().started('l'))
			{
				pos.x -= 0.5;
				AnimationOps.solveFABRIK(boneArray, targetBone);
			}
			targetBone.loc.x = pos.x;

			trace(boneArray[2].getTailAbs());

			Scene.active.getChild("Head_0").transform.loc.x = boneArray[0].loc.x;
			Scene.active.getChild("Head_0").transform.loc.y = boneArray[0].loc.y;
			Scene.active.getChild("Head_0").transform.loc.z = boneArray[0].loc.z;
			Scene.active.getChild("Head_0").transform.buildMatrix();

			Scene.active.getChild("Tail_0").transform.loc.x = boneArray[0].getTailAbs().x;
			Scene.active.getChild("Tail_0").transform.loc.y = boneArray[0].getTailAbs().y;
			Scene.active.getChild("Tail_0").transform.loc.z = boneArray[0].getTailAbs().z;
			Scene.active.getChild("Tail_0").transform.buildMatrix();

			Scene.active.getChild("Head_1").transform.loc.x = boneArray[1].loc.x;
			Scene.active.getChild("Head_1").transform.loc.y = boneArray[1].loc.y;
			Scene.active.getChild("Head_1").transform.loc.z = boneArray[1].loc.z;
			Scene.active.getChild("Head_1").transform.buildMatrix();

			Scene.active.getChild("Tail_1").transform.loc.x = boneArray[1].getTailAbs().x;
			Scene.active.getChild("Tail_1").transform.loc.y = boneArray[1].getTailAbs().y;
			Scene.active.getChild("Tail_1").transform.loc.z = boneArray[1].getTailAbs().z;
			Scene.active.getChild("Tail_1").transform.buildMatrix();

			Scene.active.getChild("Head_2").transform.loc.x = boneArray[2].loc.x;
			Scene.active.getChild("Head_2").transform.loc.y = boneArray[2].loc.y;
			Scene.active.getChild("Head_2").transform.loc.z = boneArray[2].loc.z;
			Scene.active.getChild("Head_2").transform.buildMatrix();

			Scene.active.getChild("Tail_2").transform.loc.x = boneArray[2].getTailAbs().x;
			Scene.active.getChild("Tail_2").transform.loc.y = boneArray[2].getTailAbs().y;
			Scene.active.getChild("Tail_2").transform.loc.z = boneArray[2].getTailAbs().z;
			Scene.active.getChild("Tail_2").transform.buildMatrix();
		});

		// notifyOnRemove(function() {
		// });
	}

	function updateBones()
	{
		//var bone_0 = animation.getBone("Bone_0");
	}
}
