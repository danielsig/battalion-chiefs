package com.battalion.powergrid 
{
	/**
	 * A group of other rigidbodies.
	 * @author Battalion Chiefs
	 */
	public final class Group extends AbstractRigidbody 
	{
		
		private var _volume : Number = 0;
		
		public function get bodyList() : Vector.<AbstractRigidbody>
		{
			if (!bodies) return new Vector.<AbstractRigidbody>();
			return bodies.vector;
		}
		
		public override function get volume() : Number
		{
			return _volume;
		}
		public override function get contacts() : Vector.<Contact>
		{
			var target : BodyNode = bodies;
			if (target)
			{
				var vector : Vector.<Contact> = (target.body._contacts ? target.body._contacts.vector : null) || new Vector.<Contact>();
				
				while ((target = target.next))
				{
					if(target.body._contacts) vector = vector.concat(target.body._contacts.vector);
				}
				if (!vector.length) return null;
				return vector;
			}
			return null;
		}
		
		/** @private **/
		internal var bodies : BodyNode = null;
		/** @private **/
		internal var cos : Number;
		/** @private **/
		internal var sin : Number;
		/** @private **/
		internal var numContacts : uint = 0;
		
		public function setCenter(centerX : Number = 0, centerY : Number = 0) : void
		{
			x = centerX;
			y = centerY;
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					var dx : Number = target.body.x - x;
					var dy : Number = target.body.y - y;
					target.body.relativeX = dx * cos + dy * sin;
					target.body.relativeY = dy * cos - dx * sin;
					target.body.relativeA = target.body.a - a;
				}
				while ((target = target.next));
			}
		}
		/**
		 * Call this in order to set the center of mass to the correct position
		 * based on each of the children's mass and position.
		 */
		public function computeCenterOfMass() : void
		{
			var centerX : Number = 0;
			var centerY : Number = 0;
			var target : BodyNode = bodies;
			if (target)
			{
				syncBodies();
				_mass = 0;
				do
				{
					var weight : Number = target.body.mass;
					_mass += weight;
					centerX += target.body.x * weight;
					centerY += target.body.y * weight;
				}
				while ((target = target.next));
				_invMass = 1 / _mass;
				centerX = centerX * _invMass;
				centerY = centerY * _invMass;
			}
			else
			{
				centerX = x;
				centerY = y;
			}
			setCenter(centerX, centerY);
		}
		
		/**
		 * Creates a Group object. To ungroup, use the <code>ungroup</code> method.
		 * @see #ungroup()
		 * @param	...bodies, the bodies to include in this group.
		 */
		public function Group(centerX : Number = 0, centerY : Number = 0, ...bodies)
		{
			cos = 1;
			sin = 0;
			x = centerX;
			y = centerY;
			if (bodies.length) addBody.apply(this, bodies);
		}
		
		/**
		 * Combines this group with one or more groups together into one group.
		 * @param	group, another group to be joined with this one.
		 * @param	...rest, the rest of the groups to be joined with this one.
		 */
		public function join(group : Group, ...rest) : void
		{
			CONFIG::debug
			{
				if (group == this) throw new Error("Unable to comply: Can not join a group with itself.");

			}
			/*if (isNaN(group.cos * group.sin))
			{
				group.cos = Math.cos(group.a * 0.0174532925);
				group.sin = Math.sin(group.a * 0.0174532925);
			}
			group.syncBodies();*/
			var target : BodyNode = group.bodies;
			if (target)
			{
				do
				{
					if (BodyNode.pool)
					{
						var newBody : BodyNode = BodyNode.pool;
						BodyNode.pool = BodyNode.pool.next;
					}
					else
					{
						//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
						newBody = new BodyNode();
					}
					newBody.body = target.body;
					newBody.next = bodies;
					if(bodies) bodies.prev = newBody;
					bodies = newBody;
					
					_volume += target.body.volume;
					_mass += target.body._mass;
					_invMass = 1 / _mass;
					_inertia += target.body.inertia;
					_invInertia = 1 / _inertia;
					
					var dx : Number = target.body.x - x;
					var dy : Number = target.body.y - y;
					target.body.relativeX = dx * cos + dy * sin;
					target.body.relativeY = dy * cos - dx * sin;
					target.body.relativeA = target.body.a - a;
					
					target.body.group = this;
				}
				while ((target = target.next));
				group.bodies = null;
			}
			if (group._added) PowerGrid.removeBody(group);
			if (rest.length) join.apply(this, rest);
		}
		
		public function getBodyAt(index : int) : AbstractRigidbody
		{
			CONFIG::debug
			{
				if(index < 0) throw new Error("specified index " + index + " is out of range " + length + ".");
			}
			if (!bodies)
			{
				CONFIG::debug
				{
					throw new Error("specified index " + index + " is out of range 0.");
				}
				return null;
			}
			var target : BodyNode = bodies;
			while ((index--) && (target = target.next)){}
			if (target) return target.body;
			CONFIG::debug
			{
				throw new Error("specified index " + (length + index) + " is out of range " + length + ".");
			}
			return null;
		}
		public function addLayers(layersToAdd : uint) : void
		{
			layers |= layersToAdd;
			if (!bodies) return;
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					target.body.layers |= layersToAdd;
				}
				while ((target = target.next));
			}
		}
		public function removeLayers(layersToRemove : uint) : void
		{
			layersToRemove = ~layersToRemove;
			layers &= layersToRemove;
			if (!bodies) return;
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					target.body.layers &= layersToRemove;
				}
				while ((target = target.next));
			}
		}
		/**
		 * The layer mask of every collider in this group merged together with a bitwize OR operator.
		 * Setting this property will assign that layer mask to every collider in this group.
		 */
		public function get groupLayers() : uint
		{
			if (!bodies) return layers;
			layers = 0;
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					layers |= target.body.layers;
				}
				while ((target = target.next));
			}
			return layers;
		}
		public function set groupLayers(value : uint) : void
		{
			layers = value;
			if (!bodies) return;
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					target.body.layers = value;
				}
				while ((target = target.next));
			}
		}
		public function get empty() : Boolean
		{
			return bodies == null;
		}
		public function get length() : int
		{
			if (!bodies) return 0;
			var target : BodyNode = bodies;
			for (var index : int = 0; target; index++) target = target.next;
			return index;
		}
		/**
		 * Adds a body to this group. Do not add groups to other groups. Use the <code>join()</code> method instead.
		 * @see #join()
		 * @see #releaseBody()
		 * @param	body, the body to add to this group.
		 * @param	...rest, the rest of the bodies to add to this group.
		 */
		public function addBody(body : AbstractRigidbody, ...rest) : void
		{
			if (body.group == this) return;
			if (body.group) body.group.releaseBody(body);
			body.group = this;
			
			CONFIG::debug
			{
				if (body is Group) throw new Error("You can not add groups to other groups, please use the join method instead.");
			}
			if (BodyNode.pool)
			{
				var newBody : BodyNode = BodyNode.pool;
				BodyNode.pool = BodyNode.pool.next;
			}
			else
			{
				//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
				newBody = new BodyNode();
			}
			newBody.body = body;
			newBody.next = bodies;
			if(bodies) bodies.prev = newBody;
			bodies = newBody;
			
			_volume += body.volume;
			_mass += body._mass;
			_invMass = 1.0 / _mass;
			_inertia += body.inertia;
			_invInertia = 1.0 / _inertia;
			
			var dx : Number = body.x - x;
			var dy : Number = body.y - y;
			body.relativeX = dx * cos + dy * sin;
			body.relativeY = dy * cos - dx * sin;
			body.relativeA = body.a - a;
			
			if (rest.length) addBody.apply(this, rest);
		}
		/**
		 * Releases a child body from this group.
		 * @see #addBody()
		 * @param	body, a body to release from this group.
		 * @param	...rest, the rest of the bodies to release from this group.
		 */
		public function releaseBody(body : AbstractRigidbody, ...rest) : void
		{
			CONFIG::debug
			if (!body) throw new Error("Body must be non-null!");
			
			if (!bodies) throw new Error("Group does not contain any of the rigidbodies specified in the arguements\nsince the group doesn't contain ANY rigidbodies at all!");
			var target : BodyNode = bodies;
			var lastBody : Boolean = !rest.length;
			var newMass : Number = 0;
			var newInertia : Number = 0;
			var newVolume : Number = 0;
			var index : int = 0;
			do
			{
				if (target.body == body)
				{
					while (body._contacts)
					{
						body._contacts.dispose();
					}
					
					target.body.group = null;
					if (target.prev) target.prev.next = target.next;
					if (target.next) target.next.prev = target.prev;
					
					target.next = BodyNode.pool;
					BodyNode.pool = target;
					
					BodyNode.pool.brother = BodyNode.pool.prev = null;
					BodyNode.pool.body = null;
					BodyNode.pool.index = uint.MAX_VALUE;
					
					if (!lastBody)
					{
						CONFIG::debug
						if (rest[index] is Circle || rest[index] is Triangle) throw new ArgumentError("All of the arguements must be of type Circle or Triangle!");
						
						body = rest[index++];
						target = bodies;
						lastBody = index >= rest.length;
						continue;
					}
				}
				else if(lastBody)
				{
					newMass += body._mass;
					newInertia += body.inertia;
					newVolume += body.volume;
				}
				target = target.next;
			}
			while (target);
			if (!lastBody) throw new Error("Group does not contain the rigidbody arguement at index: " + index);
			
			_mass = newMass;
			_inertia = newInertia;
			_volume = newVolume;
			
			_invMass = 1.0 / newMass;
			_invInertia = 1.0 / newInertia;
		}
		/**
		 * Releases all bodies and removes this Group object from the PowerGrid.
		 */
		public function ungroup() : void
		{
			if (!bodies)
			{
				PowerGrid.removeBody(this);
				return;
			}
			do
			{
				var next : BodyNode = bodies.next;
				while (bodies.body._contacts)
				{
					bodies.body._contacts.dispose();
				}
				
				bodies.body.group = null;
				bodies.next = BodyNode.pool;
				BodyNode.pool = bodies;
				
				BodyNode.pool.brother = BodyNode.pool.prev = null;
				BodyNode.pool.body = null;
				BodyNode.pool.index = uint.MAX_VALUE;
			}
			while ((bodies = next));
			PowerGrid.removeBody(this);
		}
		
		public function syncBodies() : void
		{
			if (!bodies) return;
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					var body : AbstractRigidbody = target.body;
					var prevX : Number = body.x;
					var prevY : Number = body.y;
					var prevA : Number = body.a;
					body.x += (x + (body.relativeX * cos - body.relativeY * sin) - body.x) * 1;
					body.y += (y + (body.relativeY * cos + body.relativeX * sin) - body.y) * 1;
					body.a = a - body.relativeA;
					body.vx = body.x - prevX + vx;
					body.vy = body.y - prevY + vy;
					resting = body.resting;
					//body.va = body.a - prevA + va;
				}
				while ((target = target.next));
			}
		}
		public function updateMassInertiaAndVolume() : void
		{
			_inertia = _mass = _volume = 0;
			if (!bodies)
			{
				_invMass = Infinity;
				_invInertia = Infinity;
				return;
			}
			var target : BodyNode = bodies;
			if (target)
			{
				do
				{
					var body : AbstractRigidbody = target.body;
					_mass += body._mass;
					_inertia += body.inertia;
					_volume += body.volume;
				}
				while ((target = target.next));
			}
			
			_invMass = 1.0 / _mass;
			_invInertia = 1.0 / _inertia;
		}
	}

}