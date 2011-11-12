package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.Circle;
	/**
	 * A simple Circle Collider.
	 * @author Battalion Chiefs
	 */
	public final class CircleCollider extends Collider 
	{
		
		private var _radius : Number = 1;
		
		public function get radius() : Number
		{
			return _radius;
		}
		public function set radius(value : Number) : void
		{
			_radius = value;
			if (body) (body as Circle).radius = value;
			if (_radius * 2 > Physics._maxSize) Physics.maxSize = _radius * 2.4;
		}
		
		/** @private */
		protected override function makeCollider(material : PhysicMaterial) : void 
		{
			body = new Circle();
			(body as Circle).radius = _radius;
			(body as Circle).userData = this;
		}
	}

}