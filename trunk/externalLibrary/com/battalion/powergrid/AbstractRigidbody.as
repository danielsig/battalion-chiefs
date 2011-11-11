package com.battalion.powergrid 
{
	import flash.geom.Point;
	/**
	 * The Abstract class for the Cirlce, Triangle and Group classes.
	 * @author Battalion Chiefs
	 */
	public class AbstractRigidbody 
	{
		
		public function get volume() : Number { return 1; }
		
		/**
		 * The group this rigidbody belongs to.
		 */
		public function get parent() : Group { return group; }
		/**
		 * True if this Rigidbody has been added to the Powergrid.
		 */
		public function get added() : Boolean { return _added; }
		
		public function get contacts() : Vector.<Contact> { return _contacts ? _contacts.vector : null; }
		/**
		 * must be more than 0 for dynamic rigidbodies, 0 makes it static.
		 */
		public function get mass() : Number { return _mass; }
		public function set mass(value : Number) : void { _mass = value; _invMass = 1 / value; }
		/** @private **/
		internal var _mass : Number = 1;
		/** @private **/
		internal var _invMass : Number = 1;
		
		/** @private **/
		internal var _contacts : Contact = null;
		/** @private **/
		internal var _added : Boolean = false;
		/**
		 * If it's a static body (mass is 0), setting this to true will prevent the PowerGrid
		 * from resetting vx, vy and va to 0 on the next step.
		 */
		public var moved : Boolean = false;
		/**
		 * Determines if this rigidbody is affected by gravity or not, default is true.
		 */
		public var affectedByGravity : Boolean = true;
		
		/**
		 * Defines how easy is it to rotate this rigidbody. Must be more than 0. Set this to Infinity to freeze further rotation.
		 */
		public function get inertia() : Number { return _inertia; }
		public function set inertia(value : Number) : void { _inertia = value; _invInertia = 1 / value; }
		/** @private **/
		internal var _inertia : Number = 1;
		/** @private **/
		internal var _invInertia : Number = 1;
		
		/**
		 * must be between 0 and 1.
		 */
		public var friction : Number = 0;
		/**
		 * must be between 0 and 1.
		 */
		public var bounciness : Number = 0.5;
		/**
		 * must be between 0 and 1. This works like <code>angularDrag</code> but only on collision (less performance intensive than <code>angularDrag</code>).
		 */
		public var angularDragOnCollision : Number = 0.0;
		/**
		 * must be between 0 and 1.
		 */
		public var drag : Number = 0;
		/**
		 * must be between 0 and 1. <b>Hint:</b> keeping this as 0 on Triangles can boost performance.
		 */
		public var angularDrag : Number = 0;
		/**
		 * must be more than 0, read about the Van der Waals force <a href="http://en.wikipedia.org/wiki/Van_der_Waals_force">here</a>.
		 */
		public var vanDerWaals : Number = 0;
		
		/**
		 * x position.
		 */
		public var x : Number = 0;
		
		/**
		 * y position.
		 */
		public var y : Number = 0;
		/**
		 * angle in degrees.
		 */
		public var a : Number = 0;
		
		/**
		 * x velocity.
		 */
		public var vx : Number = 0;
		/**
		 * y velocity.
		 */
		public var vy : Number = 0;
		/**
		 * angular velocity in degrees.
		 */
		public var va : Number = 0;
		
		/**
		 * A bitmask indicating what layers to collide with.
		 */
		public var layers : uint = 1;
		
		/**
		 * A property to store user data
		 */
		public var userData : Object = {};
		
		/** @private **/
		internal var nodes : BodyNode;
		
		/** @private **/
		internal var group : Group = null;
		/** If this body is in a group than this is the x-position relative to the group's position and rotation. **/
		public var relativeX : Number = 0;
		/** If this body is in a group than this is the y-position relative to the group's position and rotation. **/
		public var relativeY : Number = 0;
		/** If this body is in a group than this is the rotation relative to the group's rotation. **/
		public var relativeA : Number = 0;
		
		/** @private **/
		internal var prevLower : uint = uint.MAX_VALUE;
		/** @private **/
		internal var prevUpper : uint = uint.MAX_VALUE;
		
		/** @private **/
		internal var prevX : uint = 0;
		/** @private **/
		internal var prevY : uint = 0;
		/** @private **/
		internal var prevA : uint = 0;
		
		/** @private **/
		internal var sleeping : Number = 0;
		/** @private **/
		internal var sleepTotalPenetration : Number = 0;
		
		/** @private **/
		internal var resting : Number = 1;
		
		/** @private **/
		internal var lastX : Number = 0;
		/** @private **/
		internal var lastY : Number = 0;
		
		/**
		 * If the rigidbody is sleeping, call this method before changing the velocity or angular velocity directly.
		 */
		public function wakeUp() : void
		{
			if (group && group.sleeping > PowerGrid.sleepTime)
			{
				group.wakeUp();
			}
			else if (sleeping > PowerGrid.sleepTime)
			{
				sleeping = -1;
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
				newBody.body = this;
				
				if (this is Circle)
				{
					newBody.next = PowerGrid._circles;
					if(PowerGrid._circles) PowerGrid._circles.prev = newBody;
					PowerGrid._circles = newBody;
				}
				else if (this is Triangle)
				{
					newBody.next = PowerGrid._triangles;
					if(PowerGrid._triangles) PowerGrid._triangles.prev = newBody;
					PowerGrid._triangles = newBody;
				}
				else if (this is Group)
				{
					newBody.next = PowerGrid._groups;
					if(PowerGrid._groups) PowerGrid._groups.prev = newBody;
					PowerGrid._groups = newBody;
					for (var child : BodyNode = (this as Group).bodies; child; child = child.next)
					{
						child.body.wakeUp();
					}
				}
			}
			/*
			for (var contact : Contact = _contacts; contact; contact = contact.next)
			{
				if ((contact.y - y) * PowerGrid.gravityY + (contact.x - x) * PowerGrid.gravityX <= 0)
				{
					var rigidbody : AbstractRigidbody = contact.other.thisBody;
					if (!rigidbody.group && rigidbody.sleeping > PowerGrid.sleepTime) rigidbody.wakeUp();
					else if (rigidbody.group && rigidbody.group.sleeping > PowerGrid.sleepTime) rigidbody.group.wakeUp();
				}
			}
			*/
		}
		public function sleep() : void
		{
			if (group && group.sleeping < PowerGrid.sleepTime)
			{
				group.sleep();
			}
			sleeping = PowerGrid.sleepTime + 1;
			vx = 0;
			vy = 0;
			va = 0;
		}
		/**
		 * Is the rigidbody moving and therefor being checked for collisions?
		 * This will become true when the velocity becomes less than <code>PowerGrid.sleepVelocity</code>
		 * AND the angular velocity becomes less than <code>PowerGrid.sleepAngularVelocity</code>.
		 * @return
		 */
		public function isSleeping() : Boolean
		{
			return sleeping > PowerGrid.sleepTime;
		}
		protected function copyFrom(original : AbstractRigidbody) : void
		{
			x = original.x;
			y = original.y;
			a = original.a;
			_mass = original._mass;
			_invMass = original._invMass;
			_inertia = original._inertia;
			_invInertia = original._invInertia;
			friction = original.friction;
			bounciness = original.bounciness;
			vanDerWaals = original.vanDerWaals;
			angularDrag = original.angularDrag;
			angularDragOnCollision = original.angularDragOnCollision;
			drag = original.drag;
			group = original.group;
			relativeX = original.relativeX;
			relativeY = original.relativeY;
			relativeA = original.relativeA;
			prevLower = original.prevLower;
			prevUpper = original.prevUpper;
			sleeping = original.sleeping;
			vx = original.vx;
			vy = original.vy;
			va = original.va;
			if (PowerGrid.contains(original))
			{
				PowerGrid.addBody(this);
			}
		}

	}

}