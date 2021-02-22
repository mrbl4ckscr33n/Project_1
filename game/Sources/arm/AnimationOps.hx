package arm;

import armory.logicnode.RotateObjectAroundAxisNode;
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

class AnimationOps // static
{
    public static function solveIK(animation: BoneAnimation, effector: TObj, target: Cartesian, ?maxIterations: Int = 1, ?absError: Float = 0.1)
    {
        var currentBone = new Bone();
        var helpMat: Mat4;
        var boneArray = new Array<Bone>();
        var objectArray = new Array<TObj>();

        var loc = new Vec4();
        var quat = new Quat();
        var scale = new Vec4();
        var rot = new Euler();

        var currentObject = effector;
        while(true)
        {
            helpMat = animation.getWorldMat(currentObject);
            helpMat.decompose(loc, quat, scale);
            currentBone.r = animation.getBoneLen(currentObject);
            
            currentBone.loc.x = loc.x;
            currentBone.loc.y = loc.y;
            currentBone.loc.z = loc.z;

            rot = Euler.toEuler(quat);

            currentBone.rot = rot;

            boneArray.push(currentBone.copy());
            objectArray.push(currentObject);

            if(currentObject.parent != null)
            {
                if(currentObject.parent.name != null)
                {
                    currentObject = currentObject.parent;
                }
            } 
            else break;
        }

        // before: 0 is child and 1 is parent
        boneArray.reverse(); // now: 0 is parent and 1 is child
        objectArray.reverse();
        
        //solveFABRIK(boneArray, target); // solves right

        for (b in objectArray) animation.applyParent[animation.getBoneIndex(b)] = true;

        /*var k = boneArray.length - 1;
        for (i in 0...boneArray.length)
        {
            currentBone = boneArray[k];
            currentObject = objectArray[k];

            if(boneArray[i - 1] != null)
            {
                loc.x = boneArray[i - 1].getTailRel().x; // distance to parent
                loc.y = boneArray[i - 1].getTailRel().y;
                loc.z = boneArray[i - 1].getTailRel().z;
            }
            else
            {
                loc.x = 0; // distance to parent
                loc.y = 0;
                loc.z = 0;
            }

            quat = Euler.toQuat(currentBone.rot.phi, currentBone.rot.theta, currentBone.rot.psi);

            animation.getBoneMat(currentObject).compose(loc, quat, scale);
        }*/
    }

	public static function solveFABRIK(boneArray: Array<Bone>, target: Cartesian, ?maxIterations: Int = 1, ?absError: Float = 0.1)
    {
        // FABRIK algorithm:

        var bottom = new Cartesian(); // anchor point
        bottom = boneArray[0].loc.copy();

        for (i in 0...maxIterations)
        {
            // backwards:
            var k = boneArray.length;
            for (j in 0...boneArray.length)
            {
                k--;
                
                if(boneArray[k + 1] == null) // if bone is the last child of the chain, point at target
                {
                    // point bone at target's head:
                    boneArray[k].pointAt(target);

                    // set bone's tail to target's head:
                    boneArray[k].setLocByTailAbs(target);
                }
                else
                {
                    // point bone at child's head:
                    boneArray[k].pointAt(boneArray[k + 1].loc);
                    
                    // set bone's tail to child's head:
                    boneArray[k].setLocByTailAbs(boneArray[k + 1].loc);
                }
            }

            // forwards:
            for (k in 0...boneArray.length)
            {
                if (k == 0)
                {
                    // if first parent, set location to anchor point:
                    boneArray[k].loc = bottom.copy();
                }
                else
                {
                    // set bone to parent's tail:
                    boneArray[k].loc = boneArray[k - 1].getTailAbs();
                }

                if(boneArray[k + 1] == null)
                {
                    // point bone at target's head:
                    boneArray[k].pointAt(target);
                }
                else
                {
                    // point bone at child's head:
                    boneArray[k].pointAt(boneArray[k + 1].loc);
                }
            }
        }
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