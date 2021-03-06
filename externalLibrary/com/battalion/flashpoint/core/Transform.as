package com.battalion.flashpoint.core 
{
	import com.danielsig.StringUtilPro;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import com.battalion.Input;
	import com.greensock.TweenMax;
	import com.greensock.TweenLite;
	
	/**
	 * Every GameObject always has exactly one Transform component.<br />
	 * The Transform component determines the GameObject's position, rotation, scale and shearing.
	 * If you're used to work with <a href="http://unity3d.com/">Unity3D</a> then note that unlike Unity, all properties
	 * are in local space not world space. World space properties are:
	 * <ul>
	 * <li><a href="#gx">gx</a></li>
	 * <li><a href="#gy">gx</a></li>
	 * <li><a href="#globalRotation">globalRotation</a></li>
	 * <li><a href="#globalPosition">globalPosition</a></li>
	 * </ul>
	 * @see GameObject
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
		
		/** @private **/
		internal var _physicsX : Number = x;
		/** @private **/
		internal var _physicsY : Number = y;
		/** @private **/
		internal var _physicsRotation : Number = rotation;
		/** @private **/
		internal var _shearXTan : Number = 0;
		/** @private **/
		internal var _shearYTan : Number = 0;
		
		private var _cos : Number = 1;
		private var _sin : Number = 0;
		private var _cosSinCalculated : Boolean = false;
		
		public static function get mouseWorldX():Number { return (Input.mouseX - Input.stageWidth * 0.5) * world.cam.transform.scaleX + world.cam.transform.x; }
		public static function get mouseWorldY():Number { return (Input.mouseY - Input.stageHeight * 0.5) * world.cam.transform.scaleY + world.cam.transform.y; }
		
		public function get mouseRelativeX():Number { return (Input.mouseX - Input.stageWidth * 0.5 - globalMatrix.tx + world.cam.transform.gx) * world.cam.transform.scaleX; }
		public function get mouseRelativeY():Number { return (Input.mouseY - Input.stageHeight * 0.5 - globalMatrix.ty + world.cam.transform.gy) * world.cam.transform.scaleY; }
		
		/** @private **/
		internal var _changed : int = 0;
		
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
		/**
		 * The rotation in world space.
		 */
		public function get globalRotation() : Number
		{	
			
			var a : Number = globalMatrix.a;
			var b : Number = globalMatrix.b;
			var c : Number = globalMatrix.c;
			var d : Number = globalMatrix.d;
			
			var ad : Number = a * d;
			var bc : Number = b * c;
			
			if (ad > 0.0001 * bc) c = -c;
			if (bc * ( -ad) < 0) a = -a;
			
			return Math.atan2(c, a) * 57.2957795;
		}
		public function set globalRotation(value : Number) : void
		{
			rotation = (_gameObject.parent ? _gameObject.parent.transform.globalRotation : 0) + value;
		}
		/**
		 * The x position in world space. If you're assigning both gx and gy,
		 * it's recommended that you use the <code>globalPosition</code> property instead (faster).
		 */
		public function get gx() : Number
		{	
			return globalMatrix.tx;
		}
		public function set gx(value : Number) : void
		{
			if (_gameObject.parent)
			{
				var matrix : Matrix = _gameObject.parent.transform.globalMatrix;
				var p : Point = matrix.transformPoint(new Point(value, globalMatrix.ty));
				x = p.x;
				y = p.y;
			}
			else
			{
				x = value;
			}
		}
		/**
		 * The y position in world space. If you're assigning both gx and gy,
		 * it's recommended that you use the <code>globalPosition</code> property instead (faster).
		 */
		public function get gy() : Number
		{	
			return globalMatrix.ty;
		}
		public function set gy(value : Number) : void
		{
			if (_gameObject.parent)
			{
				var matrix : Matrix = _gameObject.parent.transform.globalMatrix;
				var p : Point = matrix.transformPoint(new Point(globalMatrix.tx, value));
				x = p.x;
				y = p.y;
			}
			else
			{
				y = value;
			}
		}
		/**
		 * The scale in global x-coordinates.
		 */
		public function get globalScaleX() : Number
		{
			
			var cos : Number = globalMatrix.a;
			var sin : Number = globalMatrix.b;
			if (cos < 0) cos = -cos;
			if (sin < 0) sin = -sin;
			return cos + sin;
		}
		public function set globalScaleX(value : Number) : void
		{
			if (_gameObject.parent)
			{
				var matrix : Matrix = _gameObject.parent.transform.globalMatrix;
				var p : Point = matrix.deltaTransformPoint(new Point(value, globalScaleY));
				scaleX = p.x;
				scaleY = p.y;
			}
			else
			{
				scaleX = value;
			}
		}
		/**
		 * The scale in global y-coordinates.
		 */
		public function get globalScaleY() : Number
		{
			
			var cos : Number = globalMatrix.a;
			var sin : Number = globalMatrix.b;
			if (cos < 0) cos = -cos;
			if (sin < 0) sin = -sin;
			return cos + sin;
		}
		public function set globalScaleY(value : Number) : void
		{
			if (_gameObject.parent)
			{
				var matrix : Matrix = _gameObject.parent.transform.globalMatrix;
				var p : Point = matrix.deltaTransformPoint(new Point(globalScaleX, value));
				scaleX = p.x;
				scaleY = p.y;
			}
			else
			{
				scaleY = value;
			}
		}
		/**
		 * The position in global coordinates.
		 */
		public function get globalPosition() : Point
		{
			
			return new Point(globalMatrix.tx, globalMatrix.ty);
		}
		public function set globalPosition(value : Point) : void
		{
			if (_gameObject.parent)
			{
				var matrix : Matrix = _gameObject.parent.transform.globalMatrix;
				value = matrix.transformPoint(value);
			}
			x = value.x;
			y = value.y;
		}
		/**
		 * The normalized up vector. Setting this will affect rotation. You do not have to normalize the point before assignment.
		 */
		public function get up() : Point
		{
			var vector : Point = forward;
			var temp : Number = vector.x;
			vector.x = vector.y;
			vector.y = -temp;
			return vector;
		}
		public function set up(value : Point) : void
		{
			var temp : Number = value.x;
			value.x = -value.y;
			value.y = temp;
			forward = value;
		}
		/**
		 * The normalized forward vector. Setting this will affect rotation. You do not have to normalize the point before assignment.
		 */
		public function get forward() : Point
		{
			if (!_gameObject._parent)
			{
				if (scaleX == 1 && scaleY == 1) return new Point(globalMatrix.a, globalMatrix.b)
				else return new Point(globalMatrix.a / scaleX, globalMatrix.b / scaleY);
			}
			var frw : Point = new Point(globalMatrix.a, globalMatrix.b);
			frw.normalize(1);
			return frw;
			/*
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
			
			_cosSinCalculated = true;
			_rotation = rotation;
			return globalMatrix.deltaTransformPoint(new Point(_cos, _sin));*/
		}
		public function set forward(value : Point) : void
		{
			if (gameObject.parent)
			{
				var matrix : Matrix = globalMatrix.clone();
				matrix.invert();
			}
			else matrix = new Matrix();
			value = matrix.deltaTransformPoint(value);
			var xPos : Number = value.x;
			var angle : Number = value.y / xPos;
			if (xPos < 0)
			{
				if(angle > 0) angle = -9.4 / ((angle + 2.44) * (angle + 2.44)) - 1.57079633;
				else angle = 9.4 / ((angle - 2.44) * (angle - 2.44)) + 1.57079633;
			}
			else if(angle > 0) angle = -9.4 / ((angle + 2.44) * (angle + 2.44)) + 1.57079633;
			else angle = 9.4 / ((angle - 2.44) * (angle - 2.44)) - 1.57079633;
			
			rotation = 180 - ((180 - angle * 57.2957795) % 360);
		}
		/**
		 * RotateTowards another globalPoint. Make sure the <code>point</code> has both an x property and an y property.
		 * @param	point, the global coordinates to look at.
		 * @param	angleOffset, the offset of rotation in degrees.
		 * @param	amount, the amount to rotate towards the point, 0 means no rotation, 1 means full rotation
		 */
		public function rotateTowards(globalPoint : *, angleOffset : Number = 0, amount : Number = 1) : void
		{
			CONFIG::debug
			{
				if (!globalPoint) throw new Error("globalPoint must be non-null.");
				if (!globalPoint.hasOwnProperty("x")) throw new Error("globalPoint does not have an x property.");
				if (!globalPoint.hasOwnProperty("y")) throw new Error("globalPoint does not have an y property.");
			}
			var localPoint : Point = new Point(globalPoint.x, globalPoint.y);
			if (gameObject.parent) var matrix : Matrix = gameObject.parent.transform.globalMatrix.clone();
			else matrix = new Matrix();
			matrix.invert();
			localPoint = matrix.transformPoint(localPoint);
			var xPos : Number = localPoint.x - x;
			var angle : Number = (localPoint.y - y) / xPos;
			if (xPos < 0)
			{
				if(angle > 0) angle = -9.4 / ((angle + 2.44) * (angle + 2.44)) - 1.57079633;
				else angle = 9.4 / ((angle - 2.44) * (angle - 2.44)) + 1.57079633;
			}
			else if(angle > 0) angle = -9.4 / ((angle + 2.44) * (angle + 2.44)) + 1.57079633;
			else angle = 9.4 / ((angle - 2.44) * (angle - 2.44)) - 1.57079633;
			
			if (amount == 1) rotation = 180 - ((180 - angle * 57.2957795 + angleOffset) % 360);
			else
			{
				angle = (180 - ((180 - angle * 57.2957795 + angleOffset) % 360)) - rotation;
				if (angle > 180) angle -= 360;
				else if (angle < -180) angle += 360;
				rotation += angle * amount;
			}
		}
		public function tweenPosition(x : Number, y : Number, duration : Number = 1) : void
		{
			TweenMax.to(this, duration, { x:x, y:y, overwrite:true} );
		}
		public function tweenRotation(rotation : Number, duration : Number = 1) : void
		{
			TweenMax.to(this, duration, { rotation:rotation, overwrite:true} );
		}
		public function tweenScale(scaleX : Number, scaleY : Number, duration : Number = 1) : void
		{
			TweenMax.to(this, duration, { scaleX:scaleX, scaleY:scaleY, overwrite:true} );
		}
		public function tweenAll(x : Number, y : Number, rotation : Number, scaleX : Number, scaleY : Number, duration : Number = 1) : void
		{
			TweenMax.to(this, duration, {  x:x, y:y, rotation:rotation, scaleX:scaleX, scaleY:scaleY, overwrite:true} );
		}
		public function setMatrix(a : Number = 1, b : Number = 0, c : Number = 0, d : Number = 1, tx : Number = 0, ty : Number = 0) : void
		{
			rotation = Math.atan2(b, a) * 57.2957795;
			scaleX = a * a + b * b;
			if (scaleX != 1) scaleX = Math.sqrt(scaleX);
			scaleY = c * c + d * d;
			if (scaleY != 1) scaleY = Math.sqrt(scaleY);
			x = tx;
			y = ty;
		}
		
		private static var _stackLength : uint = 1;
		private static var _countStack : Vector.<uint> = new Vector.<uint>(_stackLength);
		
		/** @private **/
		internal static function flushGlobal() : void
		{
			//world.transform.flushGlobalRecursive(new Matrix());
			var target : Transform = world.transform;
			var parent : Matrix = new Matrix();
			var height : int = _countStack[0] = 0;
			var globalMatrix : Matrix = null;
			var matrix : Matrix = null;
			
			while (height > -1)
			{
				if (!_countStack[height])
				{
					var tween : TweenMax = TweenLite.fastEaseLookup[target];
					if (tween && tween.cachedTimeScale != FlashPoint.timeScale)
					{
						tween.timeScale = FlashPoint.timeScale;
					}
					//FLUSH
					CONFIG::debug
					{
						globalMatrix = target._globalMatrix;
						matrix = target._matrix;
					}
					CONFIG::release
					{
						globalMatrix = target.globalMatrix;
						matrix = target.matrix;
					}
					
					globalMatrix.a = matrix.a;
					globalMatrix.b = matrix.b;
					globalMatrix.c = matrix.c;
					globalMatrix.d = matrix.d;
					globalMatrix.tx = matrix.tx;
					globalMatrix.ty = matrix.ty;
					
					globalMatrix.concat(parent);
				}
				CONFIG::debug
				{
					parent = target._globalMatrix;
				}
				CONFIG::release
				{
					parent = target.globalMatrix;
				}
				
				//REPEAT ON CHILDREN
				if (_countStack[height] < target._gameObject._children.length)
				{
					target = target._gameObject._children[_countStack[height++]++].transform;
					//ADDING TO STACK
					if (_stackLength <= height)
					{
						_stackLength = _countStack.push(0);
					}
					else
					{
						_countStack[height] = 0;
					}
				}
				else if(height-- > 0)
				{
					target = target._gameObject._parent.transform;
				}
			}
		}
		CONFIG::debug
		private function flushGlobalRecursive(parent : Matrix) : void
		{
			//_globalMatrix = _matrix.clone();
			_globalMatrix.a = _matrix.a;
			_globalMatrix.b = _matrix.b;
			_globalMatrix.c = _matrix.c;
			_globalMatrix.d = _matrix.d;
			_globalMatrix.tx = _matrix.tx;
			_globalMatrix.ty = _matrix.ty;
			
			_globalMatrix.concat(parent);
			
			for each(var child : GameObject in _gameObject._children)
			{
				child.transform.flushGlobalRecursive(_globalMatrix);
			}
		}
		CONFIG::release
		private function flushGlobalRecursive(parent : Matrix) : void
		{
			//globalMatrix = matrix.clone();
			globalMatrix.a = matrix.a;
			globalMatrix.b = matrix.b;
			globalMatrix.c = matrix.c;
			globalMatrix.d = matrix.d;
			globalMatrix.tx = matrix.tx;
			globalMatrix.ty = matrix.ty;
			
			globalMatrix.concat(parent);
			
			for each(var child : GameObject in _gameObject._children)
			{
				child.transform.flushGlobalRecursive(globalMatrix);
			}
		}
		/** @private **/
		internal function flush() : void
		{
			var redo : int = 0;
			if (_cosSinCalculated)
			{
				_cosSinCalculated = false;
				redo = 15;
				_changed |= 1;
			}
			if (rotation != _rotation)
			{
				
				redo = 15;
				if (_physicsRotation != rotation) _changed |= 1;
				_rotation = rotation = ((rotation + 180) % 360) - 180;
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
				
				if (x != _x)
				{
					_x = _matrix.tx = x;
					if(_physicsX != x) _changed |= 2;
				}
				if (y != _y)
				{
					_y = _matrix.ty = y;
					if(_physicsY != y) _changed |= 4;
				}
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
					
				if (x != _x)
				{
					_x = matrix.tx = x;
					if(_physicsX != matrix.tx) _changed |= 2;
				}
				if (y != _y)
				{
					_y = matrix.ty = y;
					if(_physicsY != matrix.ty) _changed |= 4;
				}
			}
		}
		
	}
	
}