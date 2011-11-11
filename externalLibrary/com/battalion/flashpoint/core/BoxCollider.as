package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.*;
	import flash.geom.Point;
	
	/**
	 * A simple Box Collider.
	 * @author Battalion Chiefs
	 */
	public final class BoxCollider extends Collider 
	{
		
		private var _width : Number = 1;
		private var _height : Number = 1;
		
		/** @private **/
		internal var triangle1 : Triangle;
		/** @private **/
		internal var triangle2 : Triangle;
		
		public override function get layers() : uint
		{
			return triangle1.layers;
		}
		public override function set layers(value : uint) : void
		{
			triangle1.layers = triangle2.layers = value;
		}
		
		public override function set material(value : PhysicMaterial) : void
		{
			triangle1.friction = value._friction;
			triangle1.bounciness = value._bounciness;
			triangle2.friction = value._friction;
			triangle2.bounciness = value._bounciness;
			super.material = value;
		}
		
		public function get dimensions() : Point
		{
			return new Point(_width, _height);
		}
		public function set dimensions(value : Point) : void
		{
			_width = value.x;
			_height = value.y;
			if (body)
			{
				BodyFactory.redefineBox(body as Group, _width, _height, triangle1, triangle2);
			}
			if (_width * _width + _height * _height > Physics._maxSizeSquared) Physics.maxSize = Math.sqrt(_width * _width + _height * _height) * 1.2;
		}
		
		public function get width() : Number
		{
			return _width;
		}
		public function set width(value : Number) : void
		{
			_width = value;
			if (body)
			{
				BodyFactory.redefineBox(body as Group, _width, _height, triangle1, triangle2);
			}
			if (_width * _width + _height * _height > Physics._maxSizeSquared) Physics.maxSize = Math.sqrt(_width * _width + _height * _height) * 1.2;
		}
		public function get height() : Number
		{
			return _height;
		}
		public function set height(value : Number) : void
		{
			_height = value;
			if (body)
			{
				BodyFactory.redefineBox(body as Group, _width, _height, triangle1, triangle2);
			}
			if (_width * _width + _height * _height > Physics._maxSizeSquared) Physics.maxSize = Math.sqrt(_width * _width + _height * _height) * 1.2;
		}
		
		/** @private */
		protected override function makeCollider(material : PhysicMaterial) : void 
		{
			body = BodyFactory.createBox(_width, _height);
			triangle1 = (body as Group).getBodyAt(0) as Triangle;
			triangle2 = (body as Group).getBodyAt(1) as Triangle;
			triangle1.userData = triangle2.userData = this;
			
			triangle1.friction = material._friction;
			triangle1.bounciness = material._bounciness;
			triangle2.friction = material._friction;
			triangle2.bounciness = material._bounciness;
		}
		/** @private */
		protected override function destroyCollider() : void
		{
			(body as Group).releaseBody(triangle1, triangle2);
			PowerGrid.removeBody(triangle1);
			PowerGrid.removeBody(triangle2);
		}
	}

}