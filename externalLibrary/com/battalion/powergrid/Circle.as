package com.battalion.powergrid 
{
	/**
	 * A simple circle rigidbody.
	 * @author Battalion Chiefs
	 */
	public final class Circle extends AbstractRigidbody 
	{
		
		public override function get volume() : Number { return radius * radius * 3.1415926535; }
		
		public var radius : Number = 1;
		
		public function Circle(original : Circle = null)
		{
			if (original)
			{
				copyFrom(original);
				radius = original.radius;
			}
		}
		
	}

}