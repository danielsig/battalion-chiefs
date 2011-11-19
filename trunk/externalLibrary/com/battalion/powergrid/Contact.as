package com.battalion.powergrid 
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Contact extends Point 
	{
		
		public var other : Contact;
		public var next : Contact;
		public var prev : Contact;
		public var entering : Boolean = true;
		
		public var nx : Number;
		public var ny : Number;
		
		public var thisBody : AbstractRigidbody;
		
		private var _nextPoint : Contact;
		private var _prevPoint : Contact;
		private var _contactStay : Boolean = true;
		
		private static var _pool : Contact;
		private static var _head : Contact;
		
		public function get staying() : Boolean
		{
			return _contactStay;
		}
		
		/*
		public static function get poolArr() : Vector.<Contact>
		{
			var arr : Vector.<Contact> = new Vector.<Contact>();
			var safety : int = 0;
			for (var currentPoint : Contact = _pool; currentPoint; currentPoint = currentPoint.other)
			{
				if (safety++ > 50) return arr;
				arr.push(currentPoint);
			}
			return arr;
		}
		public static function get headArr() : Vector.<Contact>
		{
			var arr : Vector.<Contact> = new Vector.<Contact>();
			var safety : int = 0;
			for (var currentPoint : Contact = _head; currentPoint; currentPoint = currentPoint._nextPoint)
			{
				if (safety++ > 50) return arr;
				arr.push(currentPoint);
			}
			return arr;
		}
		*/
		public function Contact(x : Number, y : Number, nx : Number, ny : Number, other : Contact, thisBody : AbstractRigidbody) 
		{
			this.x = x;
			this.y = y;
			this.nx = nx;
			this.ny = ny;
			this.other = other;
			this.thisBody = thisBody;
			if(thisBody._contacts) thisBody._contacts.prev = this;
			next = thisBody._contacts;
			thisBody._contacts = this;
		}
		public function dispose() : void
		{
			if (thisBody.group) thisBody.group.numContacts--;
			if (other.thisBody.group) other.thisBody.group.numContacts--;
			
			//this removal from the linked list of ALL contacts
			if (_nextPoint) _nextPoint._prevPoint = _prevPoint;
			if (_prevPoint) _prevPoint._nextPoint = _nextPoint;
			else _head = _nextPoint;
			
			//other removal from linked list of contacts
			if (other.next) other.next.prev = other.prev;
			if (other.prev) other.prev.next = other.next;
			else other.thisBody._contacts = other.next;
			
			//this removal from linked list of contacts
			if (next) next.prev = prev;
			if (prev) prev.next = next;
			else thisBody._contacts = next;
			
			//adding to the pool
			other.other = _pool;
			other.thisBody = thisBody = null;
			other._nextPoint = other._prevPoint = _nextPoint = _prevPoint = null;
			other.nx = other.ny = other.x = other.y = nx = ny = x = y = NaN;
			other.next = other.prev = next = prev = null;
			_pool = this;
		}
		public function get vector() : Vector.<Contact>
		{
			var vec : Vector.<Contact> = new Vector.<Contact>();
			for (var currentPoint : Contact = this; currentPoint; currentPoint = currentPoint.next)
			{
				vec.push(currentPoint);
			}
			return vec;
		}
		public static function removeOldContacts() : void
		{
			for (var currentPoint : Contact = _head; currentPoint; currentPoint = next)
			{
				var next : Contact = currentPoint._nextPoint;
				var b1 : AbstractRigidbody = currentPoint.thisBody;
				var b2 : AbstractRigidbody = currentPoint.other.thisBody;
				if (b1.sleeping > PowerGrid.sleepTime && b2.sleeping > PowerGrid.sleepTime)
				{
					currentPoint._contactStay = true;
					currentPoint.entering = false;
				}
				if (!currentPoint._contactStay) currentPoint.dispose();
				currentPoint._contactStay = false;
			}
		}
		public static function makeContact(x : Number, y : Number, nx : Number, ny : Number, first : AbstractRigidbody, second : AbstractRigidbody) : Boolean
		{
			for (var search : Contact = first._contacts; search; search = search.next)
			{
				if (search.other.thisBody == second)
				{
					//the contact already exists.
					search._contactStay = true;
					search.other._contactStay = true;
					search.x = search.other.x = x;
					search.y = search.other.y = y;
					search.other.nx = -(search.nx = nx);
					search.other.ny = -(search.ny = ny);
					return false;
				}
			}
			
			
			if (_pool)
			{
				var firstPoint : Contact = _pool;
				_pool = _pool.other;
				firstPoint.thisBody = first;
				firstPoint.x = x;
				firstPoint.y = y;
				firstPoint.nx = nx;
				firstPoint.ny = ny;
				
				if(first._contacts) first._contacts.prev = firstPoint;
				firstPoint.next = first._contacts;
				first._contacts = firstPoint;
			}
			else
			{
				firstPoint = new Contact(x, y, nx, ny, null, first);
			}
			if (_pool)
			{
				var secondPoint : Contact = _pool;
				_pool = _pool.other;
				secondPoint.thisBody = second;
				secondPoint.other = firstPoint;
				secondPoint.x = x;
				secondPoint.y = y;
				secondPoint.nx = -nx;
				secondPoint.ny = -ny;
				
				if(second._contacts) second._contacts.prev = secondPoint;
				secondPoint.next = second._contacts;
				second._contacts = secondPoint;
			}
			else
			{
				secondPoint = new Contact(x, y, -nx, -ny, firstPoint, second);
			}
			
			
			firstPoint._contactStay = true;
			firstPoint._nextPoint = _head;
			if(_head) _head._prevPoint = firstPoint;
			_head = firstPoint;
			firstPoint.other = secondPoint;
			
			if (first.group) first.group.numContacts++;
			if (second.group) second.group.numContacts++;
			
			return true;
		}
	}

}