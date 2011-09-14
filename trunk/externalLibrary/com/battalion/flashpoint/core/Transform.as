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
		
		private var _shearXTan : Number = 0;
		private var _shearYTan : Number = 0;
		private var _cos : Number = 1;
		private var _sin : Number = 0;
		
		CONFIG::debug
		{
			private var _matrix : Matrix = new Matrix();
			private var _globalMatrix : Matrix = new Matrix();
			public function get matrix() : Matrix
			{
				return _matrix;
			}
			public function get globalMatrix() : Matrix
			{
				return _globalMatrix;
			}
		}
		CONFIG::release
		{
			public var matrix : Matrix = new Matrix();
			public var globalMatrix : Matrix = new Matrix();
		}
		
		public function get scale() : Number
		{
			return (scaleX + scaleY) * 0.5;
		}
		
		public function set scale(value : Number) : void
		{
			scaleX = value;
			scaleY = value;
		}
		
		public function get position() : Point
		{
			return new Point(x, y);
		}
		public function set position(value : Point) : void
		{
			x = value.x;
			y = value.y;
		}
		internal static function flushGlobal() : void
		{
			world.transform.flushGlobalRecursive(new Matrix());
		}
		CONFIG::debug
		private function flushGlobalRecursive(parent : Matrix) : void
		{
			_globalMatrix = _matrix.clone();
			_globalMatrix.concat(parent);
			
			for each(var child : GameObject in _gameObject._children)
			{
				child.transform.flushGlobalRecursive(_globalMatrix);
			}
		}
		CONFIG::release
		private function flushGlobalRecursive(parent : Matrix) : void
		{
			globalMatrix = matrix.clone();
			globalMatrix.concat(parent);
			
			for each(var child : GameObject in _gameObject._children)
			{
				child.transform.flushGlobalRecursive(globalMatrix);
			}
		}
		internal function flush() : void
		{
			var redo : int = 0;
			if (rotation != _rotation)
			{
				redo = 15;
				_rotation = rotation;
				
				var angle : Number = (180 - ((180 - rotation) % 360)) * 0.0174532925;
				
				if(angle < 0.7854){
					if(angle < -1.571){
						if(angle < -2.3562) _cos = 0.475 * angle * angle + angle * 2.9831 + 3.687;
						else _cos = 1.2711 * angle + 0.0915 * angle * angle + 1.764;
					}else if(angle < -0.7854) _cos = 0.676 * angle - 0.0921 * angle * angle + 1.302;
					else _cos = -0.482 * angle * angle + 1;
				}else if(angle < 2.3562){
					if(angle < 1.5708) _cos = -0.676 * angle - 0.0921 * angle * angle + 1.302
					else _cos = -1.2711 * angle + 0.0915 * angle * angle + 1.764;
				}else _cos = 0.475 * angle * angle + angle * -2.9831 + 3.687;
				
				if(angle < -1.57079632) angle += 4.71238899;
				else angle -= 1.57079632;
				
				if(angle < 0.7854){
					if(angle < -1.571){
						if(angle < -2.3562) _sin = 0.475 * angle * angle + angle * 2.9831 + 3.687;
						else _sin = 1.2711 * angle + 0.0915 * angle * angle + 1.764;
					}else if(angle < -0.7854) _sin = 0.676 * angle - 0.0921 * angle * angle + 1.302;
					else _sin = -0.482 * angle * angle + 1;
				}else if(angle < 2.3562){
					if(angle < 1.5708) _sin = -0.676 * angle - 0.0921 * angle * angle + 1.302
					else _sin = -1.2711 * angle + 0.0915 * angle * angle + 1.764;
				}else _sin = 0.475 * angle * angle + angle * -2.9831 + 3.687;
			}
			if (shearX != _shearX)
			{
				redo |= 12;
				_shearXTan = Math.tan(_shearX = shearX);
			}
			if (shearY != _shearY)
			{
				redo |= 3;
				_shearYTan = Math.tan(_shearY = shearY);
			}
			if (scaleX != _scaleX)
			{
				redo |= 3;
				_scaleX = scaleX;
			}
			if (scaleY != _scaleY)
			{
				redo |= 12;
				_scaleX = scaleX;
			}
			CONFIG::debug
			{
				if(redo & 1)
					_matrix.a = _cos * scaleX - _sin * _shearYTan;
				if(redo & 2)
					_matrix.b = _sin * scaleX + _cos * _shearYTan;
				if(redo & 4)
					_matrix.c = -_sin * scaleY + _cos * _shearXTan;
				if(redo & 8)
					_matrix.d = _cos * scaleY + _sin * _shearXTan;
					
				if (x != _x) _x = _matrix.tx = x;
				if (y != _y) _y = _matrix.ty = y;
			}
			CONFIG::release
			{
				if(redo & 1)
					matrix.a = _cos * scaleX - _sin * _shearYTan;
				if(redo & 2)
					matrix.b = _sin * scaleX + _cos * _shearYTan;
				if(redo & 4)
					matrix.c = -_sin * scaleY + _cos * _shearXTan;
				if(redo & 8)
					matrix.d = _cos * scaleY + _sin * _shearXTan;
					
				if (x != _x) _x = matrix.tx = x;
				if (y != _y) _y = matrix.ty = y;
			}
		}
		
	}
	
}