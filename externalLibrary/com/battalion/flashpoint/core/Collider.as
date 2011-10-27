package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.*;
	
	/**
	 * @author Battalion Chiefs
	 */
	public class Collider extends Component implements IPhysicsSyncable
	{
		CONFIG::debug
		public function Collider()
		{
			if (!(this is BoxCollider || this is CircleCollider || this is TriangleCollider))
			{
				throw new Error("You can not instantiate a Component directly nor extend it. Please use the BoxCollider, TriangleCollider or the CircleCollider");
			}
		}
		
		/**
		 * A bitmask indicating what layers this collider can collide with.
		 * Each bit is a single layer.
		 */
		public function get layers() : uint { return body.layers; }
		public function set layers(value : uint) : void { body.layers = value; }
		
		public function get material() : PhysicMaterial { return _material; }
		public function set material(value : PhysicMaterial) : void
		{
			if (body && !(this is BoxCollider))
			{
				body.friction = value._friction;
				body.bounciness = value._bounciness;
			}
			
			_material = value;
		}
		
		private var _material : PhysicMaterial = PhysicMaterial.DEFAULT_MATERIAL;
		
		/** @private */
		internal static var _head : IPhysicsSyncable;
		/** @private */
		internal var _next : IPhysicsSyncable;
		/** @private */
		internal var _prev : IPhysicsSyncable;
		
		/** @private */
		internal var body : AbstractRigidbody;
		private var _transform : Transform;//for speed;
		private var _this : Object;//for speed;
		private var _name : String;//for speed;
		
		/**
		 * Applies movement to this GameObject and friction to all the colliders
		 * attached to it but only if there's no rigidbody attached.
		 * This lets you simulate moving platforms with rigidbodies sitting on top of it.
		 * After adding a collider to a GameObject, a dynamic function with the
		 * same name and functionality as this one is applied to that GameObject.
		 * @param	x, new global position along the x axis.
		 * @param	y, new global position along the y axis.
		 */
		public function beginMovement() : void
		{
			if (!_this.rigidbody)
			{
				_this.prevX = _transform.x;
				_this.prevY = _transform.y;
				_this.prevA = _transform.rotation;
			}
		}
		public function endMovement() : void 
		{
			if (!_this.rigidbody)
			{
				if (!_this.body.moved)
				{
					_this.body.vx = _this.body.vy = _this.body.va = 0;
				}
				_this.body.vx += (_transform.x - _this.prevX);
				_this.body.vy += (_transform.y - _this.prevY);
				_this.body.va += (_transform.rotation - _this.prevA);
				_this.body.moved = true;
			}
		}
		
		/** @private */
		internal static function processPhysics() : void 
		{
			var target : IPhysicsSyncable = _head;
			while (target)
			{
				target = (target as Collider || target as Rigidbody).syncPhysics();
			}
		}
		
		/** @private */
		public function awake() : void 
		{
			CONFIG::debug
			{
				if (_gameObject.parent) throw new Error("Colliders can only be added to GameObjects with no parent.");
			}
			
			_transform = _gameObject.transform;
			
			if (_gameObject._physicsComponents) _this = _gameObject._physicsComponents;
			else _this = _gameObject._physicsComponents = { length:0, hasBox:false, added:null, updated:false, originalX:_transform.x, originalY:_transform.y, originalA:_transform.rotation};
			
			if (this is BoxCollider) _this.hasBox = true;
			_name = "collider" + _this.length++;
			_this[_name] = this;
			
			makeCollider(_material);
			if (!(this is BoxCollider))
			{
				body.friction = _material._friction;
				body.bounciness = _material._bounciness;
			}
			
			if (!_this.updated)
			{
				_this.updated = true;
				addConcise(UpdatePhysics, "updatePhysics");
				sendBefore("updatePhysics", "update");
			}
		}
		/** @private */
		public final function onDestroy() : Boolean
		{
			var end : String = "collider" + (--_this.length);
			_this[_name] = _this[end];
			_this[_name]._name = _name;
			_name = end;
			delete _this[_name];
			
			if (_this && _this.added == this) removePhysics();
			destroyCollider();
			if(body.added) PowerGrid.removeBody(body);
			if (!_this.updated)
			{
				_this.updated = true;
				addConcise(UpdatePhysics, "updatePhysics");
				sendBefore("updatePhysics", "update");
			}
			return false;
		}
		
		/** @private */
		internal final function addPhysics() : void 
		{
			_this.added = true;
			if (_head)
			{
				(_head as Collider || _head as Rigidbody)._prev = this;
				_next = _head;
			}
			_head = this;
		}
		/** @private */
		internal final function removePhysics() : void 
		{
			_this.added = false;
			if (_head == this) _head = _next;
			if (_prev) (_prev as Collider || _prev as Rigidbody)._next = _next;
			if (_next) (_next as Collider || _next as Rigidbody)._prev = _prev;
		}
		/** @private */
		internal final function syncPhysics() : IPhysicsSyncable 
		{
			var bod : AbstractRigidbody = _this.body;
			var changed : int = _transform._changed;
			
			if (changed & 1) bod.a = _transform.rotation;
			else _transform.rotation = bod.a;
			if (changed & 2) bod.x = _transform.x - Physics._offsetX;
			else _transform.x = bod.x + Physics._offsetX;
			if (changed & 4) bod.y = _transform.y - Physics._offsetY;
			else _transform.y = bod.y + Physics._offsetY;
			
			_transform._physicsX = bod.x + Physics._offsetX;
			_transform._physicsY = bod.y + Physics._offsetY;
			_transform._physicsRotation = bod.a;
			_transform._changed = 0;
			
			if (changed && bod.isSleeping()) bod.wakeUp();
			
			return _next;
		}
		/** @private */
		protected function makeCollider(material : PhysicMaterial) : void 
		{
			body = new Group();
		}
		protected function destroyCollider() : void 
		{
			
		}
	}

}