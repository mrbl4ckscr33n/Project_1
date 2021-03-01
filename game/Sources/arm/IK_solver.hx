package arm;

import kha.FastFloat;
import iron.object.BoneAnimation;
import iron.data.SceneFormat;
import iron.object.Object;
import iron.math.Mat4;
import iron.math.Vec4;
import iron.math.Quat;
import iron.Scene;
import iron.data.SceneFormat.TObj;

class IK_solver
{
	var ready: Bool = false;
	// for goal:
	var a: Float = 0;
	var b: Float = 0;
	var c: Float = 0;
	var m: Mat4;
	var goal_armature = new Vec4();
	var i: Int = 0;

	var maxBones: Int = 0;
	var inaccuracy: FastFloat = 0;
	var maxIterations: Int = 0;

	var armature: Object;
	var animation: BoneAnimation;
	var mesh: Object;
	var bones = new Array<TObj>();

	var loc = new Vec4();
	var quat = new Quat();
	var scale = new Vec4();

	var reach: Float = 0;
	var distance: Float = 0;
	var bottom = new Vec4();

	var quats_init = new Array<Quat>();
	var locs_init_local = new Array<Vec4>();
	var scales_init = new Array<Vec4>();
	var fromVec = new Vec4();
	var toVecs = new Array<Vec4>();
	var points = new Array<Vec4>();
	var lengths = new Array<Float>();

	var nameOfBone: String;

	public function new(nameOfArmature: String, nameOfEffector: String, done: IK_solver -> Void, ?numberOfBonesToSolve: Int = 999, ?inaccuracyFinal: FastFloat = 0.01, ?maximalIterations: Int = 4)
	{
		trace("helo am ik solver"); nameOfBone = nameOfEffector;

		armature = Scene.active.getChild(nameOfArmature); if(armature == null) trace("no armature found with this name!");
		animation = GetLocal.findAnimation(armature);	  if(armature == null) trace("no animation found on the armature!");
		mesh = armature.children[0];

		// search for TObj of the effector's name:
		maxBones = numberOfBonesToSolve;
		inaccuracy = inaccuracyFinal;
		maxIterations = maximalIterations;
		ready = true;
		done(this);
	}

	public function solve(goal: Vec4)
	{
		if(!ready)
		{
			trace("constructor not done!, will not solve!");
			return;
		}

		// transform location of goal to local coordinates of armature itself:
		a = goal.x;
		b = goal.y;
		c = goal.z;

		m = armature.transform.world.getInverse(armature.transform.world);

		goal_armature.x = m._00 * a + m._10 * b + m._20 * c + m._30; // multiply goal in worldspace by inverse of armature matrix to get goal in armature space
		goal_armature.y = m._01 * a + m._11 * b + m._21 * c + m._31;
		goal_armature.z = m._02 * a + m._12 * b + m._22 * c + m._32;
		goal_armature.w = 1;

		// fill arrays:
		bones.push(null);
		scales_init.push(null);
		lengths.push(null);
		toVecs.push(null);
		points.push(null);
		quats_init.push(null);
		locs_init_local.push(null);

		var count: Int = 0;
		var currentBone = animation.getBone(nameOfBone);
		while(true)
		{
			count++;
			bones.push(currentBone);

			animation.getWorldMat(currentBone).decompose(loc, quat, scale);
			bottom.setFrom(loc);
			scales_init.push(scale.clone());
			lengths.push(animation.getBoneLen(currentBone));
			toVecs.push(loc.clone());
			points.push(loc.clone());

			animation.getBoneMat(currentBone).decompose(loc, quat, scale);
			locs_init_local.push(loc.clone());
			quats_init.push(Reflect.copy(quat));
			
			if(count >= maxBones) break;
			if(currentBone.parent != null)
			{
				if(currentBone.parent.name != null)
				{
					currentBone = currentBone.parent;
				}
			}
			else break; // array 0 is now child and end is parent
		}

		points[0] = new Vec4();

		// FABRIK algorithm:
		// if goal too far away to reach:
		distance = 0;
		reach = 0;
		for (i in 0...lengths.length)
		{
			reach += lengths[i];
		}
		distance = goal_armature.clone().sub(bottom).length();

		if(distance >= reach)
		{
			var toVec = new Vec4();
			toVec.setFrom(goal_armature);
			toVec.sub(bottom);
			toVec.normalize();
			
			i = points.length - 1;
			while(true)
			{
				if(i > 0)
				{
					toVecs[i].setFrom(toVec);
					toVecs[i].mult(lengths[i]);
				}
				if(i >= points.length - 1)
				{
					points[points.length - 1].setFrom(bottom);
				}
				else
				{
					points[i].setFrom(points[i + 1]);
					points[i].add(toVecs[i + 1]);
				}
				if(i <= 0) break;
				i--;
			}
		}
		else
		{
			for(k in 0...maxIterations)
			{
				// backwards:
				points[0].setFrom(goal_armature); // last point is no child and has no toVec
				for (i in 1...points.length)
				{
					toVecs[i].setFrom(points[i - 1]);
					toVecs[i].sub(points[i]);
					toVecs[i].normalize();
					toVecs[i].mult(lengths[i]);
					points[i].setFrom(points[i - 1]);
					points[i].sub(toVecs[i]);
				}
				// forwards:
				var i: Int = points.length - 1;
				points[points.length - 1].setFrom(bottom);
				while(true)
				{
					if(points[i + 1] != null) // is already set above
					{
						points[i].setFrom(points[i + 1]);
						points[i].add(toVecs[i + 1]);
					}

					if(points[i - 1] != null) // last point is no child
					{
						toVecs[i].setFrom(points[i - 1]);
						toVecs[i].sub(points[i]);
						toVecs[i].normalize();
						toVecs[i].mult(lengths[i]);
					}

					if(i <= 0) break;
					i--;
				}
				// test if accuracy is reached:
				if(goal_armature.clone().sub(points[0]).length() <= inaccuracy) break;
			}
		}

		var finalRot = new Quat();

		i = points.length - 1; // i is at parent

		while(true)
		{
			// use the parent's space to find out the location of this tail in relation to parent:
			// calculate tail of this to parent'S space:

			m = animation.getWorldMat(bones[i]);

			m.getInverse(m);

			a = points[i - 1].x;
			b = points[i - 1].y;
			c = points[i - 1].z;

			var tailFinal_local = new Vec4(); // wanted tail position of this in parent's space

			tailFinal_local.x = m._00 * a + m._10 * b + m._20 * c + m._30;
			tailFinal_local.y = m._01 * a + m._11 * b + m._21 * c + m._31;
			tailFinal_local.z = m._02 * a + m._12 * b + m._22 * c + m._32;
			tailFinal_local.w = 1; // works fine

			m = animation.getBoneMat(bones[i]);

			var pos = new Vec4();
			pos.setFrom(m.getLoc());

			fromVec.setFrom(m.look()); // this is the from vector in parent's space

			a = tailFinal_local.x;
			b = tailFinal_local.y;
			c = tailFinal_local.z;

			var tailFinal_parent = new Vec4();

			tailFinal_parent.x = m._00 * a + m._10 * b + m._20 * c + m._30;
			tailFinal_parent.y = m._01 * a + m._11 * b + m._21 * c + m._31;
			tailFinal_parent.z = m._02 * a + m._12 * b + m._22 * c + m._32;
			tailFinal_parent.w = 1;

			tailFinal_parent.sub(pos); // now this is the toVec

			finalRot.fromTo(fromVec.normalize(), tailFinal_parent.normalize()).mult(quats_init[i]);

			animation.getBoneMat(bones[i]).compose(locs_init_local[i], finalRot, scales_init[i]);

			if(i <= 1) break;
			i--;			
		}

		mesh.transform.buildMatrix();
		armature.transform.buildMatrix();

		for (i in 0...points.length) // clear all arrays
		{
			bones.pop();
			scales_init.pop();
			lengths.pop();

			toVecs.pop();
			points.pop();
			locs_init_local.pop();
			quats_init.pop();
		}
	}
}