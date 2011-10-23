package com.battalion.powergrid 
{
	import adobe.utils.CustomActions;
	/**
	 * A doubly linked list for Rigidbodies
	 * @author Battalion Chiefs
	 */
	public final class BodyNode 
	{
		/** @private **/
		internal static var pool : BodyNode;
		
		public var next : BodyNode;
		public var prev : BodyNode;
		public var body : AbstractRigidbody;
		public var index : uint;
		public var brother : BodyNode;//a node with the same body.
		
		private var _flag : Boolean = false;
		
		public function get vector() : Vector.<AbstractRigidbody>
		{
			var vector : Vector.<AbstractRigidbody> = new Vector.<AbstractRigidbody>();
			for (var node : BodyNode = this; node && !node._flag; node = node.next)
			{
				node._flag = true;
				vector.push(node.body);
			}
			for (node = this; node && node._flag; node = node.next)
			{
				node._flag = false;
			}
			return vector;
		}
		
		public function get length() : uint
		{
			var c : uint = 0;
			for (var node : BodyNode = this; node && !node._flag; node = node.next)
			{
				node._flag = true;
				c++;
			}
			for (node = this; node && node._flag; node = node.next)
			{
				node._flag = false;
			}
			return c;
		}
		public function find(body : AbstractRigidbody) : Boolean
		{
			var found : Boolean = false;
			for (var node : BodyNode = this; node && !node._flag && body; node = node.next)
			{
				if (node.body == body)
				{
					found = true;
					break;
				}
			}
			for (node = this; node && node._flag; node = node.next)
			{
				node._flag = false;
			}
			return found;
		}
		public static function create(body : AbstractRigidbody, next : BodyNode, brother : BodyNode, index : uint) : BodyNode
		{
			if (pool)
			{
				var newBody : BodyNode = pool;
				pool = pool.next;
			}
			else
			{
				newBody = new BodyNode();
			}
			newBody.brother = brother;
			newBody.body = body;
			newBody.next = next;
			newBody.index = index;
			if (next) next.prev = newBody;
			
			return newBody;
		}
		
	}

	
}