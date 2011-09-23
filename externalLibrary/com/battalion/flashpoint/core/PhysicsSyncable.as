package com.battalion.flashpoint.core 
{
	
	import Box2D.Collision.b2AABB;
	import com.battalion.flashpoint.core.*;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Common.Math.b2Vec2;
	import flash.geom.Point;
	
	/**
	 * @private
	 * @author Battalion Chiefs
	 */
	internal class PhysicsSyncable extends Component 
	{
		private static var _head : PhysicsSyncable;
		
		private var _next : PhysicsSyncable;
		private var _prev : PhysicsSyncable;
		
		/** @private **/
		protected var _body : b2Body;
		private var _transform : Transform;//for speed;
		private var _this : Object;
		private var _name : String;
		
		public function get contactPoints() : Vector.<ContactPoint>
		{
			var contacts : Object = _body.m_userData.contacts;
			var points : Vector.<ContactPoint> = new Vector.<ContactPoint>();
			for each(var point : ContactPoint in contacts)
			{
				points.push(point);
			}
			return points;
		}
		public function touchingInDirection(normal : Point, thresholdSquared : Number) : Vector.<ContactPoint>
		{
			thresholdSquared = 1 - thresholdSquared;
			var contacts : Object = _body.m_userData.contacts;
			var points : Vector.<ContactPoint> = new Vector.<ContactPoint>();
			for each(var point : ContactPoint in contacts)
			{
				if (point.normal.x * normal.x + point.normal.y * normal.y > thresholdSquared)
				{
					points.push(point);
				}
			}
			if (points.length) return points;
			return null;
		}
		public function touching(collider : Collider) : Vector.<ContactPoint>
		{
			var contacts : Object = _body.m_userData.contacts;
			var points : Vector.<ContactPoint> = new Vector.<ContactPoint>();
			for each(var point : ContactPoint in contacts)
			{
				if (point.otherCollider == collider)
				{
					points.push(point);
				}
			}
			if (points.length) return points;
			return null;
		}
		
		/** @private **/
		public function start() : void 
		{

			_transform = gameObject.transform;
			
			if (gameObject._physicsComponents) _this = gameObject._physicsComponents;
			else _this = gameObject._physicsComponents = { length:0 };
			
			_name = this is Rigidbody ? "rigidbody" : "collider" + _this.length++;
			_this[_name] = this;
			
			if(_this.body)
			{
				_body = _this.body;
				if (this is Rigidbody) (this as Rigidbody).updateRigidbody();
			}
			else
			{
				_body = _this.body = Physics._physicsWorld.CreateBody(constructBodyDef());
				_body.SetUserData( { name:gameObject._name, contacts:{}} );
				if (gameObject.rigidbody) gameObject.rigidbody.updateRigidbody();
				addPhysics();
			}
		}
		/** @private **/
		public function onDestroy() : Boolean 
		{
			if (this is Collider)
			{
				
				/* here's an example of how the folowing code would work, including the delete statement.
				 * 
				 * _this = { collider0:this, collider1:other, length:2 }, end = undefined, name = "collider0", other.name = "collider1"
				 * _this = { collider0:this, collider1:other, length:1 }, end = "collider1", name = "collider0", other.name = "collider1"
				 * _this = { collider0:other, collider1:other, length:1 }, end = "collider1", name = "collider0", other.name = "collider1"
				 * _this = { collider0:other, collider1:other, length:1 }, end = "collider1", name = "collider0", other.name = "collider0"
				 * _this = { collider0:other, collider1:other, length:1 }, end = "collider1", name = "collider1", other.name = "collider0"
				 * 
				 * _this = { collider0:other, length:1 }, end = "collider1", name = "collider1", other.name = "collider0"
				*/
				var end : String = "collider" + (--_this.length);
				_this[_name] = _this[end];
				_this[_name]._name = _name;
				_name = end;
			}
			delete _this[_name];
			removePhysics();
			if (!_this.length && !_this.rigidbody)
			{
				Physics._physicsWorld.DestroyBody(_body);
			}
			else if(_this.rigidbody)
			{
				_this.rigidbody.addPhysics();
			}
			else if(_this.collider0)
			{
				_this.collider0.addPhysics();
			}
			return false;
		}
		
		/** @private **/
		internal static function processPhysics() : void 
		{
			var target : PhysicsSyncable = _head;
			while (target)
			{
				target = target.syncPhysics();
			}
		}
		
		/** @private **/
		internal final function addPhysics() : void 
		{
			if (_head)
			{
				_head._next = this;
				_prev = _head;
			}
			_head = this;
		}
		/** @private **/
		internal final function removePhysics() : void 
		{
			if (_head == this) _head = _prev;
			if (_prev) _prev._next = _next;
			if (_next) _next._prev = _prev;
			
		}
		/** @private **/
		internal final function syncPhysics() : PhysicsSyncable 
		{
			var changed : int = _transform._changed;
			var pos : b2Vec2 = _body.GetPosition();
			pos.x *= Physics._pixelsPerMeter;
			pos.y *= Physics._pixelsPerMeter;
			var rotation : Number = _body.GetAngle() * 57.2957795;
			
			if (changed && 1) rotation = _transform.rotation;
			else _transform.rotation = rotation;
			if (changed && 2) pos.x = _transform.x;
			else _transform.x = pos.x;
			if (changed && 4) pos.y = _transform.y;
			else _transform.y = pos.y;
			
			_transform._physicsX = pos.x;
			_transform._physicsY = pos.y;
			_transform._physicsRotation = rotation;
			_transform._changed = 0;
			
			pos.x *= Physics._pixelsPerMeterInverse;
			pos.y *= Physics._pixelsPerMeterInverse;
			if (changed)
			{
				_body.WakeUp();
				_body.SetXForm(pos, rotation * 0.0174532925);
			}
			
			return _prev;
		}
		protected final function updateAll() : void
		{
			_body = _this.body = Physics._physicsWorld.CreateBody(constructBodyDef());
			for each(var collider : * in _this)
			{
				if(collider is Collider) collider.updateCollider();
			}
			if (gameObject.rigidbody) gameObject.rigidbody.updateRigidbody();
		}
		/**
		 * Overridden by Rigidbody.
		 * @return b2BodyDef
		 */
		protected function constructBodyDef() : b2BodyDef
		{
			var def : b2BodyDef = new b2BodyDef();
			def.position.x = _transform.x * Physics._pixelsPerMeterInverse;
			def.position.y = _transform.y * Physics._pixelsPerMeterInverse;
			def.angle = _transform.rotation * 0.0174532925;
			return def;
		}
		
	}
	
}