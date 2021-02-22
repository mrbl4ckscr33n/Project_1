package arm;

import Math;
import iron.math.Quat;

class Bone extends iron.Trait
{
	public var loc: Cartesian; // location of head
	public var rot: Euler; // rotation in Euler angles
	public var r: Float; // radius / bone length

	public function new(?locX = 0, ?locY = 0, ?locZ = 0, ?rotPhi = 0, ?rotTheta = 0, ?rotPsi = 0, ?radius = 0)
	{
		super();

		loc = new Cartesian(locX, locY, locZ);
		rot = new Euler(rotPhi, rotTheta, rotPsi);
		r = radius;

		//notifyOnInit(function() {
		//});

		// notifyOnUpdate(function() {
		//});

		// notifyOnRemove(function() {
		// });
	}

	public function copy()
	{
		var copy = new Bone();
		copy.loc = loc.copy();
		copy.rot = rot.copy();
		copy.r = r;
		return copy;
	}

	public function getHeadAbs()
	{
		return loc;
	}

	public function getHeadRel()
	{
		var head = new Cartesian();
		return head;
	}

	public function getTailAbs()
	{
		var tail = new Cartesian();
		tail.x = r * Math.sin(rot.theta) * Math.cos(rot.psi) + loc.x;
		tail.y = r * Math.sin(rot.theta) * Math.sin(rot.psi) + loc.y;
		tail.z = r * Math.cos(rot.theta) + loc.z;
		return tail;
	}

	public function getTailRel()
	{
		var tail = new Cartesian();
		tail.x = r * Math.sin(rot.theta) * Math.cos(rot.psi);
		tail.y = r * Math.sin(rot.theta) * Math.sin(rot.psi);
		tail.z = r * Math.cos(rot.theta);
		return tail;
	}

	public function pointAt(target: Cartesian) // absolute position to point at
	{
		var targetCopy: Cartesian = target.copy();
		targetCopy.subtract(loc); // relative position to poiint at
		rot = cartesianToEuler(targetCopy, rot.phi);
		return null;
	}

	public function setLocByTailAbs(location: Cartesian)
	{
		loc = location.copy();
		loc.subtract(getTailRel());
	}

	public function cartesianToEuler(targetRel: Cartesian, roll: Float)
	{
		var rotation = new Euler();
		rotation.phi = roll;
		rotation.theta = Math.acos(targetRel.z/(Math.sqrt(Math.pow(targetRel.x, 2) + Math.pow(targetRel.y, 2) + Math.pow(targetRel.z, 2))));
		rotation.psi = Math.atan2(targetRel.y, targetRel.x);
		return rotation;
	}
}

class Euler
{
	public var phi: Float; // roll
	public var theta: Float; // pitch
	public var psi: Float; // yaw

	public function new(?roll: Float = 0, ?pitch: Float = 0, ?yaw: Float = 0)
	{
		phi = roll;
		theta = pitch;
		psi = yaw;
	}

	public function copy()
	{
		var copy = new Euler();
		copy.phi = phi;
		copy.theta = theta;
		copy.psi = psi;
		return copy;
	}

	public static function toEuler(q: Quat)
	{
		var a = 2 * (q.w * q.x + q.y * q.z);
		var b = 1 - 2 * (q.x * q.x + q.y * q.y);
		var roll = Math.atan2(a, b);

		var c = 2 * (q.w * q.y - q.z * q.x);
		var pitch = Math.asin(c);

		var d = 2 * (q.w * q.z + q.x * q.y);
		var e = 1 - 2 * (q.y * q.y + q.z * q.z);
		var yaw = Math.atan2(d, e);

		return new Euler(roll, pitch, yaw);
	}

	public static function toQuat(roll: Float, pitch: Float, yaw: Float)
	{
		var cy = Math.cos(yaw * 0.5);
		var sy = Math.sin(yaw * 0.5);
		var cp = Math.cos(pitch * 0.5);
		var sp = Math.sin(pitch * 0.5);
		var cr = Math.cos(roll * 0.5);
		var sr = Math.sin(roll * 0.5);

		var q = new Quat();

		q.w = cr * cp * cy + sr * sp * sy;
		q.x = sr * cp * cy - cr * sp * sy;
		q.y = cr * sp * cy + sr * cp * sy;
		q.z = cr * cp * sy - sr * sp * cy;

		return q;
	}
}

class Cartesian
{
	public var x: Float;
	public var y: Float;
	public var z: Float;

	public function new(?x1: Float = 0, ?y1: Float = 0, ?z1: Float = 0)
	{
		x = x1;
		y = y1;
		z = z1;
	}

	public function add(location: Cartesian) // add location to this
	{
		x = x + location.x;
		y = y + location.y;
		z = z + location.z;
	}

	public function subtract(location: Cartesian) // subtract location from this
	{
		x = x - location.x;
		y = y - location.y;
		z = z - location.z;
	}

	public function copy()
	{
		var copy = new Cartesian();
		copy.x = x;
		copy.y = y;
		copy.z = z;
		return copy;
	}
}