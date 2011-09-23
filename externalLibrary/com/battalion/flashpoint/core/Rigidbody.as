package com.battalion.flashpoint.core 
{
	
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.Math.b2XForm;
	import Box2D.Dynamics.b2BodyDef;
	import com.battalion.flashpoint.core.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * A Rigidbody, add this and a Collider to a GameObject to make it react to collisions.
	 * @author Battalion Chiefs
	 */
	public final class Rigidbody extends PhysicsSyncable implements IExclusiveComponent
	{
		/**
		 * Should the rigidbody interpolate between fixedUpdate frames?
		 */
		public var interpolate : Boolean = true;
		
		/** @private **/
		internal var _center : b2Vec2 = new b2Vec2();
		/** @private **/
		internal var _mass : Number = 1;
		/** @private **/
		internal var _drag : Number = 0.05;
		/** @private **/
		internal var _freezeRotation : Boolean = false;
		
		private var _torqueToAdd : Number = 0;
		private var _prevInertia : Number;
		
		private var _interpolateNow : Boolean = true;
		private var _interpolationMatrix : Matrix;
		private var _transform : Transform;
		private var _xPos : Number = 0;
		private var _yPos : Number = 0;
		private var _rotation : Number = 0;
		private var _angleStep : Number = 0;
		private var _xScale : Number = 1;
		private var _yScale : Number = 1;
		
		/**
		 * The rigidbody's center of mass.
		 */
		public function get centerOfMass() : Point
		{
			return new Point(_center.x * Physics._pixelsPerMeter, _center.y * Physics._pixelsPerMeter);
		}
		public function set centerOfMass(value : Point) : void
		{
			_center = new b2Vec2(value.x * Physics._pixelsPerMeterInverse, value.y * Physics._pixelsPerMeterInverse);
			if (_body)
			{
				var massData : b2MassData = new b2MassData();
				massData.mass = _mass;
				massData.center = _center;
				_body.SetMass(massData);
			}
		}
		/**
		 * Set this to true, in order to freeze rotation.
		 */
		public function get freezeRotation() : Boolean
		{
			return _freezeRotation;
		}
		public function set freezeRotation(value : Boolean) : void
		{
			if (_body)
			{
				if (value && !_freezeRotation)
				{
					_prevInertia = _body.m_I;
					_body.m_I = Number.POSITIVE_INFINITY;
					_body.m_invI = 0;
				}
				else if(!value && _freezeRotation)
				{
					_body.m_I = _prevInertia;
					_body.m_invI = 1 / _prevInertia;
				}
			}
			_freezeRotation = value;
		}
		/**
		 * The rigidbody's mass.
		 */
		public function get mass() : Number
		{
			return _mass;
		}
		public function set mass(value : Number) : void
		{
			_mass = value;
			if (_body)
			{
				_body.m_mass = _mass;
				_body.m_invMass = 1 / _mass;
			}
		}
		
		/**
		 * The rigidbody's drag.
		 */
		public function get drag() : Number
		{
			return _drag;
		}
		public function set drag(value : Number) : void
		{
			_drag = value;
			if (_body) _body.m_linearDamping = _drag;
		}
		
		/** @private **/
		public function fixedUpdate() : void
		{
			_interpolateNow = interpolate && !_body.IsSleeping();
			if (_interpolateNow)
			{
				var pos : b2Vec2 = _body.GetPosition();
				_xPos = (pos.x * Physics._pixelsPerMeter - _transform.x);
				_yPos = (pos.y * Physics._pixelsPerMeter - _transform.y);
				_rotation = _transform.rotation * 0.0174532925;
				_angleStep = _body.GetAngle() - _transform.rotation * 0.0174532925;
				_xScale = _transform.scaleX;
				_yScale = _transform.scaleY;
			}
		}
		/** @private **/
		public function update() : void 
		{
			if (_interpolateNow && !_transform._changed)
			{
				_interpolationMatrix.identity();
				_interpolationMatrix.rotate(_rotation + _angleStep * FlashPoint.frameInterpolationRatio)
				_interpolationMatrix.a *= _xScale;
				_interpolationMatrix.d *= _yScale;
				_interpolationMatrix.tx = _transform.x + _xPos * FlashPoint.frameInterpolationRatio;
				_interpolationMatrix.ty = _transform.y + _yPos * FlashPoint.frameInterpolationRatio;
			}
		}
		
		/** @private **/
		public override function start() : void 
		{
			_transform = gameObject.transform;
			_interpolationMatrix = _transform.matrix;
			super.start();
			updateRigidbody();
		}
		public function addTorque(torque : Number) : void
		{
			if (_body) _body.ApplyTorque(torque);
			else _torqueToAdd = torque;
		}
		public function addForceX(force : Number, mode : uint = ForceMode.FORCE) : void
		{
			addForce(new Point(force, 0));
		}
		public function addForceY(force : Number, mode : uint = ForceMode.FORCE) : void
		{
			addForce(new Point(0, force));
		}
		public function addForce(force : Point, mode : uint = ForceMode.FORCE) : void
		{
			var forceVector : b2Vec2 = new b2Vec2(force.x, force.y);
			switch(mode)
			{
				case ForceMode.FORCE:
					_body.ApplyForce(forceVector, _center);
					break;
				case ForceMode.ACCELLERATION:
					forceVector.x *= _body.m_invMass;
					forceVector.y *= _body.m_invMass;
					_body.ApplyForce(forceVector, _center);
					break;
				case ForceMode.IMPULSE:
					_body.ApplyImpulse(forceVector, _center);
					break;
				case ForceMode.VELOCITY_CHANGE:
					forceVector.x *= _body.m_invMass;
					forceVector.y *= _body.m_invMass;
					_body.ApplyImpulse(forceVector, _center);
					break;
			}
		}
		public function addForceAtPosition(force : Point, position : Point, mode : uint = ForceMode.FORCE) : void
		{
			var forceVector : b2Vec2 = new b2Vec2(force.x, force.y);
			var pointVector : b2Vec2 = new b2Vec2(position.x * Physics._pixelsPerMeterInverse, position.y * Physics._pixelsPerMeterInverse);
			switch(mode)
			{
				case ForceMode.FORCE:
					_body.ApplyForce(forceVector, pointVector);
					break;
				case ForceMode.ACCELLERATION:
					forceVector.x *= _body.m_invMass;
					forceVector.y *= _body.m_invMass;
					_body.ApplyForce(forceVector, pointVector);
					break;
				case ForceMode.IMPULSE:
					_body.ApplyImpulse(forceVector, pointVector);
					break;
				case ForceMode.VELOCITY_CHANGE:
					forceVector.x *= _body.m_invMass;
					forceVector.y *= _body.m_invMass;
					_body.ApplyImpulse(forceVector, pointVector);
					break;
			}
		}
		/** @private **/
		protected override function constructBodyDef() : b2BodyDef
		{
			var def : b2BodyDef = super.constructBodyDef();
			def.massData.mass = _mass;
			def.massData.center = _center;
			def.fixedRotation = _freezeRotation;
			return def;
		}
		/** @private **/
		internal function updateRigidbody() : void
		{
			_center = _body.GetLocalCenter();
			var massData : b2MassData = new b2MassData();
			massData.mass = _mass;
			massData.center = _center;
			_body.SetMass(massData);
			_body.m_linearDamping = _drag;
			_body.ApplyTorque(_torqueToAdd);
			_torqueToAdd = 0;
			_prevInertia = _body.m_I;
		}
		/** @private **/
		public override function onDestroy() : Boolean 
		{
			var massData : b2MassData = new b2MassData();
			massData.mass = 0;
			massData.center = _center;
			_body.SetMass(massData);
			return super.onDestroy();
		}
	}
	
}