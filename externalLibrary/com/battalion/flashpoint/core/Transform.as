package com.battalion.flashpoint.core 
{
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Transform extends Component implements IExclusiveComponent
	{
		public var scaleX : Number = 1;
		public var scaleY : Number = 1;
		public var shearX : Number = 0;
		public var shearY : Number = 0;
		public var x : Number = 0;
		public var y : Number = 0;
		public var rotation : Number = 0;
		
		private var _scaleX : Number = scaleX;
		private var _scaleY : Number = scaleY;
		private var _shearX : Number = shearX;
		private var _shearY : Number = shearY;
		private var _x : Number = x;
		private var _y : Number = y;
		private var _rotation : Number = rotation;
		
		CONFIG::debug
		private var _matrix : Matrix = new Matrix();
		
		CONFIG::debug
		public function get matrix() : Matrix
		{
			return _matrix;
		}
		CONFIG::release
		public var matrix : Matrix = new Matrix();
		
		public function get position() : Point
		{
			return new Point(x, y);
		}
		public function set position(value : Point) : void
		{
			x = value.x;
			y = value.y;
		}
		internal function flush() : void
		{
			if (rotation != _rotation || shearX != _shearX || shearY != _shearY || scaleX != _scaleX || scaleY != _scaleY)
			{
				_rotation = rotation;
				_shearX = shearX;
				_shearY = shearY;
				_scaleX = scaleX;
				_scaleY = scaleY;
				
				var angle : Number = (180 - ((180 - rotation) % 360)) * 0.0174532925;
				
				if(angle < 0.7854){
					if(angle < -1.571){
						if(angle < -2.3562) var cos:Number = 0.475 * angle * angle + angle * 2.9831 + 3.687;
						else cos = 1.2711 * angle + 0.0915 * angle * angle + 1.764;
					}else if(angle < -0.7854) cos = 0.676 * angle - 0.0921 * angle * angle + 1.302;
					else cos = -0.482 * angle * angle + 1;
				}else if(angle < 2.3562){
					if(angle < 1.5708) cos = -0.676 * angle - 0.0921 * angle * angle + 1.302
					else cos = -1.2711 * angle + 0.0915 * angle * angle + 1.764;
				}else cos = 0.475 * angle * angle + angle * -2.9831 + 3.687;
				
				if(angle < -1.57079632) angle += 4.71238899;
				else angle -= 1.57079632;
				
				if(angle < 0.7854){
					if(angle < -1.571){
						if(angle < -2.3562) var sin:Number = 0.475 * angle * angle + angle * 2.9831 + 3.687;
						else sin = 1.2711 * angle + 0.0915 * angle * angle + 1.764;
					}else if(angle < -0.7854) sin = 0.676 * angle - 0.0921 * angle * angle + 1.302;
					else sin = -0.482 * angle * angle + 1;
				}else if(angle < 2.3562){
					if(angle < 1.5708) sin = -0.676 * angle - 0.0921 * angle * angle + 1.302
					else sin = -1.2711 * angle + 0.0915 * angle * angle + 1.764;
				}else sin = 0.475 * angle * angle + angle * -2.9831 + 3.687;
				
				CONFIG::debug
				{
					_matrix.a = cos * scaleX;
					_matrix.b = -sin * shearX;
					_matrix.c = sin * shearY;
					_matrix.d = cos * scaleY;
				}
				CONFIG::release
				{
					matrix.a = cos * scaleX;
					matrix.b = -sin * shearX;
					matrix.c = sin * shearY;
					matrix.d = cos * scaleY;
				}
			}
			CONFIG::debug
			{
				if (x != _x) _x = _matrix.tx = x;
				if (y != _y) _y = _matrix.ty = y;
			}
			CONFIG::release
			{
				if (x != _x) _x = matrix.tx = x;
				if (y != _y) _y = matrix.ty = y;
			}
		}
		
	}
	
}