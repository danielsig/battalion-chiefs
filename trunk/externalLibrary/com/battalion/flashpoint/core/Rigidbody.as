package com.battalion.flashpoint.core 
{
	
	import com.battalion.powergrid.*;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import com.battalion.flashpoint.comp.TextRenderer;
	
	/**
	 * A Rigidbody, add this alone with a Collider to a GameObject to make it react to collisions.
	 * @author Battalion Chiefs
	 */
	public final class Rigidbody extends Component implements IExclusiveComponent, IPhysicsSyncable
	{
		/** @private */
		internal var _next : IPhysicsSyncable;
		/** @private */
		internal var _prev : IPhysicsSyncable;
		
		/** @private */
		internal var body : AbstractRigidbody;
		private var _transform : Transform;//for speed;
		private var _this : Object;//for speed;
		
		private var _angularDrag : Number = 0;
		private var _drag : Number = 0;
		private var _mass : Number = 1;
		private var _inertia : Number = 1;
		private var _vanDerWaals : Number = 1;
		private var _freeze : Boolean = false;
		private var _afffectedByGravity : Boolean = true;
		private var _vx : Number = 0;
		private var _vy : Number = 0;
		private var _va : Number = 0;
		/** @private **/
		internal var _density : Number = NaN;
		/** @private **/
		internal var _massDistribution : Number = NaN;
		
		/**
		 * Determines if this rigidbody is affected by gravity or not, default is true.
		 */
		public function get affectedByGravity() : Boolean { return _afffectedByGravity; }
		public function set affectedByGravity(value : Boolean) : void
		{
			_afffectedByGravity = value;
			if (body) body.affectedByGravity = _afffectedByGravity;
		}
		
		/**
		 * Determines how hard is it to move the Rigidbody.
		 * This value is not the same as the mass.
		 * The density can be found using the formula: density = mass / volume.
		 */
		public function get density() : Number
		{
			if (body) return _mass / body.volume;
			return isNaN(_density) ? 1 : _density;
		}
		public function set density(value : Number) : void
		{
			_density = value;
			if (body) body.mass = _mass = value * body.volume;
		}
		
		/**
		 * Determines how hard is it to rotate the Rigidbody.
		 * This is similar to inertia but not the same thing.
		 * The difference between this and the actual inertia
		 * is similar to the difference between density and mass.
		 * In other words: massDistribution = inertia / volume.
		 * for comparison: density = mass / volume.
		 */
		public function get massDistribution() : Number
		{
			if (body) return _inertia / body.volume;
			return isNaN(_massDistribution) ? 1 : _massDistribution;
		}
		public function set massDistribution(value : Number) : void
		{
			_massDistribution = value;
			if (body) body.inertia = _inertia = value * body.volume;
		}
		
		/**
		 * Must be 0 or more, works only when there's only one Circle collider.
		 * Read about this force <a href="http://en.wikipedia.org/wiki/Van_der_Waals_force">here</a>.
		 * Basicly, this is the "mini-gravity" between molecules found in e.g. water.
		 * Good for foam effects.
		 */
		public function get vanDerWaals() : Number { return _vanDerWaals; }
		public function set vanDerWaals(value : Number) : void
		{
			_vanDerWaals = value;
			if (body) body.vanDerWaals = value;
		}
		/**
		 * The velocity of the rigidbody in pixels per fixedUpdate.
		 */
		public function get velocity() : Point
		{
			if(body) return new Point(body.vx, body.vy);
			return new Point(_vx, _vy);
		}
		public function set velocity(value : Point) : void
		{
			_vx = value.x;
			_vy = value.y;
			if (body)
			{
				body.vx = _vx;
				body.vy = _vy;
			}
		}
		/**
		 * The angular velocity of the rigidbody in degrees per fixedUpdate.
		 */
		public function get angularVelocity() : Number
		{
			if (body) return body.va;
			return _va;
		}
		public function set angularVelocity(value : Number) : void
		{
			_va = value;
			if (body) body.va = _va;
		}
		
		public function get angularDrag() : Number
		{
			return _angularDrag;
		}
		public function set angularDrag(value : Number) : void
		{
			_angularDrag = value;
			if (body) body.angularDrag = value;
		}
		public function get drag() : Number
		{
			return _drag;
		}
		public function set drag(value : Number) : void
		{
			_drag = value;
			if (body) body.drag = value;
		}
		public function get mass() : Number
		{
			return _mass;
		}
		public function set mass(value : Number) : void
		{
			_mass = value;
			if (body) body.mass = value;
		}
		
		public function get inertia() : Number
		{
			return _inertia;
		}
		public function set inertia(value : Number) : void
		{
			_inertia = value;
			if (body && !_freeze) body.inertia = value;
		}
		public function get freezeRotation() : Boolean
		{
			return _freeze;
		}
		public function set freezeRotation(value : Boolean) : void
		{
			_freeze = value;
			if (body) body.inertia = value ? Infinity : _inertia;
		}
		
		public function touchingInDirection(normal : Point, thresholdSquared : Number) : Vector.<ContactPoint>
		{
			if (!body) return null;
			var contacts : Vector.<Contact> = body.contacts;
			if (!contacts) return null;
			thresholdSquared = 1 - thresholdSquared;
			var nx : Number = -normal.x;
			var ny : Number = -normal.y;
			var insert : uint = 0;
			var length : uint = contacts.length;
			for (var i : uint = 0; i < length; i++)
			{
				if (contacts[i].nx * nx + contacts[i].ny * ny > thresholdSquared)
				{
					contacts[insert++] = contacts[i];
				}
			}
			if (!insert) return null;
			var points : Vector.<ContactPoint> = new Vector.<ContactPoint>(insert);
			while(insert--)
			{
				points[insert] = new ContactPoint(contacts[insert]);
			}
			return points;
		}
		public function touching(collider : Collider) : Vector.<ContactPoint>
		{
			if (!body) return null;
			var contacts : Vector.<Contact> = body.contacts;
			if (!contacts) return null;
			var insert : uint = 0;
			var length : uint = contacts.length;
			for (var i : uint = 0; i < length; i++)
			{
				if (contacts[i].other.thisBody.userData == collider)
				{
					contacts[insert++] = contacts[i];
				}
			}
			if (!insert) return null;
			var points : Vector.<ContactPoint> = new Vector.<ContactPoint>(insert);
			while(insert--)
			{
				points[insert] = new ContactPoint(contacts[insert]);
			}
			return points;
		}
		
		public function addTorque(torque : Number, mode : uint = ForceMode.FORCE) : void
		{
			if (!body) return;
			switch(mode)
			{
				case ForceMode.VELOCITY_CHANGE:
					body.va += torque;
				case ForceMode.IMPULSE:
					body.va += torque / _inertia;
				case ForceMode.ACCELLERATION:
					body.va += torque * FlashPoint.fixedInterval * 0.001;
				case ForceMode.FORCE:
				default:
					body.va += torque * FlashPoint.fixedInterval * 0.001 / _inertia;
			}
		}
		public function addForceX(force : Number, mode : uint = ForceMode.FORCE) : void
		{
			if (!body) return;
			switch(mode)
			{
				case ForceMode.VELOCITY_CHANGE:
					body.vx += force;
				case ForceMode.IMPULSE:
					body.vx += force / _mass;
				case ForceMode.ACCELLERATION:
					body.vx += force * FlashPoint.fixedInterval * 0.001;
				case ForceMode.FORCE:
				default:
					body.vx += force * FlashPoint.fixedInterval * 0.001 / _mass;
			}
		}
		public function addForceY(force : Number, mode : uint = ForceMode.FORCE) : void
		{
			if (!body) return;
			switch(mode)
			{
				case ForceMode.VELOCITY_CHANGE:
					body.vy += force;
				case ForceMode.IMPULSE:
					body.vy += force / _mass;
				case ForceMode.ACCELLERATION:
					body.vy += force * FlashPoint.fixedInterval * 0.001;
				case ForceMode.FORCE:
				default:
					body.vy += force * FlashPoint.fixedInterval * 0.001 / _mass;
			}
		}
		public function addForce(force : Point, mode : uint = ForceMode.FORCE) : void
		{
			if (!body) return;
			switch(mode)
			{
				case ForceMode.VELOCITY_CHANGE:
					body.vx += force.x;
					body.vy += force.y;
				case ForceMode.IMPULSE:
					var invMass : Number = 1.0 / _mass;
					body.vx += force.x * invMass;
					body.vy += force.y * invMass;
				case ForceMode.ACCELLERATION:
					body.vx += force.x * FlashPoint.fixedInterval * 0.001;
					body.vy += force.y * FlashPoint.fixedInterval * 0.001;
				case ForceMode.FORCE:
				default:
					invMass = 1.0 / _mass;
					body.vx += force.x * invMass * FlashPoint.fixedInterval * 0.001;
					body.vy += force.y * invMass * FlashPoint.fixedInterval * 0.001;
			}
		}
		
		/** @private */
		public function awake() : void 
		{
			CONFIG::debug
			{
				if (_gameObject.parent) throw new Error("Rigidbodies can only be added to GameObjects with no parent.");
			}
			
			_transform = _gameObject.transform;
			
			if (_gameObject._physicsComponents) _this = _gameObject._physicsComponents;
			else _this = _gameObject._physicsComponents = { length:0, hasBox:false, added:null, updated:false, originalX:_transform.x, originalY:_transform.y, originalA:_transform.rotation};
			
			_this.rigidbody = this;
			
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
			if (body)
			{
				if (_this && _this.added == this) removePhysics();
				if(body.added) PowerGrid.removeBody(body);
				if (!_this.updated)
				{
					_this.updated = true;
					addConcise(UpdatePhysics, "updatePhysics");
					sendBefore("updatePhysics", "update");
				}
			}
			return false;
		}
		
		/** @private */
		internal final function addPhysics() : void 
		{
			_this.added = this;
			if (Collider._head)
			{
				(Collider._head as Collider || Collider._head as Rigidbody)._prev = this;
				_next = Collider._head;
			}
			Collider._head = this;
		}
		/** @private */
		internal final function removePhysics() : void 
		{
			_this.added = null;
			if (Collider._head == this) Collider._head = _next;
			if (_prev) (_prev as Collider || _prev as Rigidbody)._next = _next;
			if (_next) (_next as Collider || _next as Rigidbody)._prev = _prev;
		}
		/** @private */
		internal final function syncPhysics() : IPhysicsSyncable 
		{
			// updating the body
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
			
			//updating in case this collider is not on a root gameobject
			if (_this.subColliders)
			{
				var groupChange : Boolean = false;
				for each(var collider : Collider in _this.subColliders)
				{
					var transform : Transform = collider._gameObject.transform;
					changed = transform._changed;
					
					if (collider is BoxCollider)
					{
						var triangle1 : Triangle = (collider as BoxCollider).triangle1;
						var triangle2 : Triangle = (collider as BoxCollider).triangle2;
						var parent : GameObject = collider._gameObject._parent;
						var parentTransform : Transform = parent.transform;
						var grandParentTransform : Transform = parent._parent.transform;
						
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
					groupChange ||= changed & 6;
				}
				if (groupChange) _this.body.computeCenterOfMass();
			}
			//continue
			return _next;
		}
	}

}