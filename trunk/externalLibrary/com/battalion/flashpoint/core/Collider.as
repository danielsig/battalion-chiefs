package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
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
			_privateMemberNames.push("_material", "_next", "_prev", "body", "_transform", "_this", "_name");
		}
		CONFIG::debug
		protected override function getPrivate(name : String) : * { return this[name]; }
		
		/**
		 * A bitmask indicating what layers this collider can collide with.
		 * Each bit is a single layer.
		 * @see #groupLayers
		 */
		public function get layers() : uint { return body.layers; }
		public function set layers(value : uint) : void { body.layers = value; }
		
		/**
		 * A bitmask indicating all the layers on every collider on this GameObject and it's children.
		 * Each bit is a single layer.
		 * @see #layers
		 */
		public function get groupLayers() : uint { return _this.group ? _this.group.groupLayers : body.layers; }
		public function set groupLayers(value : uint) : void
		{
			if (_this.group) _this.group.groupLayers = value;
			else body.layers = value;
		}
		
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
		
		public function addLayers(layersToAdd : uint) : void
		{
			if (_this.group && _this.rigidbody) _this.group.addLayers(layersToAdd);
			else body.layers |= layersToAdd;
		}
		public function removeLayers(layersToRemove : uint) : void
		{
			if (_this.group && _this.rigidbody) _this.group.removeLayers(layersToRemove);
			else body.layers &= ~layersToRemove;
		}
		
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
				if (_gameObject._parent != world && _gameObject._parent._parent != world && _gameObject._parent._parent._parent != world) throw new Error("Can not add a collider to " + _gameObject + " because it has a great grandparent.");
			}
			
			var root : GameObject = _gameObject;
			while (root._parent != world) root = root._parent;
			
			_transform = root.transform;
			
			if (root._physicsComponents) _this = root._physicsComponents;
			else _this = root._physicsComponents = { length:0, hasBox:false, added:null, updated:false, subColliders:null, originalX:_transform.x, originalY:_transform.y, originalA:_transform.rotation };
			
			if (this is BoxCollider) _this.hasBox = true;
			if (_transform != _gameObject.transform)
			{
				if (_this.subColliders)  _this.subColliders.push(this);
				else  _this.subColliders = new <Collider>[this];
			}
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
				root.addConcise(UpdatePhysics, "updatePhysics");
				root.sendBefore("updatePhysics", "update");
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
				
				var root : GameObject = _gameObject;
				while (root._parent != world) root = root._parent;
				
				root.addConcise(UpdatePhysics, "updatePhysics");
				root.sendBefore("updatePhysics", "update");
			}
			
			_material = null;
			_name = null;
			_this = null;
			_transform = null;
			body = null;
			_next = null;
			_prev = null;
			
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
			// updating the body
			var bod : AbstractRigidbody = _this.body;
			bod.mass = 0;
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
			
			//updating in case this collider is not on a root gameobject
			if (_this.subColliders)
			{
				for each(var collider : Collider in _this.subColliders)
				{
					var transform : Transform = collider._gameObject.transform;
					changed = transform._changed;
					
					if (collider is BoxCollider)
					{
						var triangle1 : Triangle = (collider as BoxCollider).triangle1;
						var triangle2 : Triangle = (collider as BoxCollider).triangle2;
						var parentTransform : Transform = collider._gameObject._parent.transform;
						var grandParentTransform : Transform = collider._gameObject._parent._parent.transform;
						
						if (changed & 1)
						{
							triangle1.relativeA = triangle2.relativeA = transform.rotation;
						}
						else
						{
							transform.rotation = triangle1.relativeA;
						}
						if (changed & 6)
						{
							if (parentTransform == _transform)
							{
								var matrix : Matrix = transform.matrix;
							}
							else
							{
								matrix = transform.matrix.clone();
								matrix.concat(parentTransform.matrix);
							}
							var width : Number = (collider as BoxCollider).width;
							var height : Number = (collider as BoxCollider).height;
							
							triangle1.relativeX = matrix.tx + matrix.a * width * 0.16 + matrix.b * height * 0.16;
							triangle1.relativeY = matrix.ty + matrix.b * width * 0.16 - matrix.a * height * 0.16;
							triangle2.relativeX = matrix.tx - (matrix.a * width * 0.16 + matrix.b * height * 0.16);
							triangle2.relativeY = matrix.ty - (matrix.b * width * 0.16 - matrix.a * height * 0.16);
							bod.mass = Number.MAX_VALUE;
						}
						else if (parentTransform == _transform)
						{
							transform.x = (triangle1.relativeX + triangle2.relativeX) * 0.5;
							transform.y = (triangle1.relativeY + triangle2.relativeY) * 0.5;
						}
						else
						{
							var pos : Point = new Point((triangle1.relativeX + triangle2.relativeX) * 0.5, (triangle1.relativeY + triangle2.relativeY) * 0.5);
							matrix = parentTransform.matrix.clone();
							matrix.invert();
							pos = matrix.transformPoint(pos);
							
							transform.x = pos.x;
							transform.y = pos.y;
						}
					}
					else
					{
						bod = collider.body;
						if (changed & 1) bod.relativeA = transform.rotation;
						else transform.rotation = bod.relativeA;
						if (changed & 2) bod.relativeX = transform.x;
						else transform.x = bod.relativeX;
						if (changed & 4) bod.relativeY = transform.y;
						else transform.y = bod.relativeY;
						
						transform._physicsX = bod.relativeX;
						transform._physicsY = bod.relativeY;
						transform._physicsRotation = bod.relativeA;
					}
					transform._changed = 0;
				}
			}
			//continue
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