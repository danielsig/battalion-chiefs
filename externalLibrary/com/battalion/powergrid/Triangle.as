package com.battalion.powergrid 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * A simple triangle rigidbody.
	 * @author Battalion Chiefs
	 */
	public final class Triangle extends AbstractRigidbody 
	{
		
		private var _volume : Number = NaN;
		
		public override function get volume() : Number
		{
			if (isNaN(_volume))
			{
				var dx : Number = x1 - x2;
				var dy : Number = y1 - y2;
				return _volume = Math.sqrt(dx * dx + dy * dy) * (n12x * x3 + n12y * y3) * 0.5;
			}
			return _volume;
		}
		
		public function Triangle(original : Triangle = null)
		{
			if (original)
			{
				copyFrom(original);
				
				_extents = original._extents;
				_prevAngle = original._prevAngle;
				_prevAngularVelocity = original._prevAngularVelocity;
				cos = original.cos;
				sin = original.sin;
				
				x1 = original.x1;
				x2 = original.x2;
				x3 = original.x3;
				y1 = original.y1;
				y2 = original.y2;
				y3 = original.y3;
				
				n12x = original.n12x;
				n12y = original.n12y;
				n12d = original.n12d;
				
				n23x = original.n23x;
				n23y = original.n23y;
				n23d = original.n23d;
				
				n31x = original.n31x;
				n31y = original.n31y;
				n31d = original.n31d;
				
				gx1 = original.gx1;
				gx2 = original.gx2;
				gx3 = original.gx3;
				gy1 = original.gy1;
				gy2 = original.gy2;
				gy3 = original.gy3;
				
				gn12x = original.gn12x;
				gn12y = original.gn12y;
				
				gn23x = original.gn23x;
				gn23y = original.gn23y;
				
				gn31x = original.gn31x;
				gn31y = original.gn31y;
			}
		}
		
		//--------------  VERTICES  ---------------
		
		//vertex 1
		
		/**
		 * local x position of the 1st vertex
		 */
		public var x1 : Number;
		/**
		 * local y position of the 1st vertex
		 */
		public var y1 : Number;
		
		//vertex 2
		
		/**
		 * local x position of the 2nd vertex
		 */
		public var x2 : Number;
		/**
		 * local y position of the 2nd vertex
		 */
		public var y2 : Number;
		
		//vertex 3
		
		/**
		 * local x position of the 3rd vertex
		 */
		public var x3 : Number;
		/**
		 * local y position of the 3rd vertex
		 */
		public var y3 : Number;
		
		
		
		// ------------  NORMALS  --------------
		
		// NORMAL TO THE LINE 1,2
		/**
		 * local x of the normal to the line between the 1st and the 2nd vertex
		 */
		public var n12x : Number;
		
		/**
		 * local y of the normal to the line between the 1st and the 2nd vertex
		 */
		public var n12y : Number;
		
		/**
		 * distance of the line 1 - 2 from the triangle's center.
		 */
		public var n12d : Number;
		
		
		
		// NORMAL TO THE LINE 2,3
		/**
		 * local x of the normal to the line between the 2nd and the 3rd vertex
		 */
		public var n23x : Number;
		
		/**
		 * local y of the normal to the line between the 2nd and the 3rd vertex
		 */
		public var n23y : Number;
		
		/**
		 * distance of the line 2 - 3 from the triangle's center.
		 */
		public var n23d : Number;
		
		
		
		
		// NORMAL TO THE LINE 3,1
		/**
		 * local x of the normal to the line between the 3rd and the 2nd vertex
		 */
		public var n31x : Number;
		
		/**
		 * local y of the normal to the line between the 3rd and the 2nd vertex
		 */
		public var n31y : Number;
		
		/**
		 * distance of the line 3 - 1 from the triangle's center.
		 */
		public var n31d : Number;
		
		
		/** @private **/
		internal var _extents : Number;
		
		/** @private **/
		internal var _prevAngularVelocity : Number = NaN;
		
		/** @private **/
		internal var _prevAngle : Number = NaN;
		
		/** @private **/
		internal var cos : Number;
		/** @private **/
		internal var sin : Number;
		
		//--------------  VERTICES  ---------------
		/** @private **/
		public var gx1 : Number;
		/** @private **/
		public var gy1 : Number;
		
		/** @private **/
		public var gx2 : Number;
		/** @private **/
		public var gy2 : Number;
		
		/** @private **/
		public var gx3 : Number;
		/** @private **/
		public var gy3 : Number;
		
		// ------------  NORMALS  --------------
		/** @private **/
		public var gn12x : Number;
		/** @private **/
		public var gn12y : Number;
		
		/** @private **/
		public var gn23x : Number;
		/** @private **/
		public var gn23y : Number;
		
		/** @private **/
		public var gn31x : Number;
		/** @private **/
		public var gn31y : Number;
		
		/**
		 * scale the vertices by <code>scalar</code>.
		 * @param	scalar
		 */
		public function scale(scalar : Number) : void
		{
			var m : Matrix = new Matrix();
			m.scale(scalar, scalar);
			transform(m);
		}
		
		/**
		 * rotate the vertices by <code>degrees</code>.
		 * @param	degrees
		 */
		public function rotate(degrees : Number) : void
		{
			var m : Matrix = new Matrix();
			m.rotate(degrees * 0.0174532925);
			transform(m);
		}
		
		/**
		 * Changes the shape of the Triangle by transforming the vertices using the matrix <code>m</code>.
		 * @param	m
		 */
		public function transform(m : Matrix) : void
		{
			var point : Point = new Point(x1, y1);
			point = m.transformPoint(point);
			x1 = point.x; y1 = point.y;
			
			point.x = x2; point.y = y2;
			point = m.transformPoint(point);
			x2 = point.x; y2 = point.y;
			
			point.x = x3; point.y = y3;
			point = m.transformPoint(point);
			x3 = point.x; y3 = point.y;
			
			updateVertices();
		}
		
		/**
		 * Define the Triangle's form by specifying a size and then the position
		 * of the first point (anchorX and anchorY) relative to the line between the other two points.
		 * @param	size
		 * @param	anchorX
		 * @param	anchorY
		 */
		public function defineForm(size : Number, anchorX : Number, anchorY : Number) : void
		{
			anchorX *= size;
			anchorY *= size;
			x1 = -(size * 0.5 + anchorX * 0.333333333333);
			x2 = size * 0.5 - anchorX * 0.333333333333;
			x3 = anchorX * 0.666666666666;
			
			y1 = -anchorY * 0.333333333333;
			y2 = -anchorY * 0.333333333333;
			y3 = anchorY * 0.666666666666;
			
			if (anchorY < 0)
			{
				var temp : Number = x1;
				x1 = x2;
				x2 = temp;
				temp = y1;
				y1 = y2;
				y2 = temp;
			}
			computeNormals();
		}
		/**
		 * Call this method to update the vertices <b>after</b> the Triangle has been added to the grid
		 * (using the <code>PowerGrid.addBody()</code> static method).
		 * It is not necessary to call this method before adding the Triangle to the grid.
		 */
		public function updateVertices() : void
		{
			
			// NORMALIZING
			var centerX : Number = (x1 + x2 + x3) * 0.33333333333333333;
			var centerY : Number = (y1 + y2 + y3) * 0.33333333333333333;
			
			x1 -= centerX;
			x2 -= centerX;
			x3 -= centerX;
			
			y1 -= centerY;
			y2 -= centerY;
			y3 -= centerY;
			
			// LET THE POWERGRID UPDATE ON NEXT STEP
			
			_prevAngle = NaN;
			_prevAngularVelocity = NaN;
		}
		/**
		 * Call this method after making changes to the Triangle's shape.
		 * If you don't it will result in unwanted behavior.
		 * An exception is when you call the <code>defineForm()</code>
		 * method which calls this method for you.
		 */
		public function computeNormals() : void
		{
			_extents = x1 * x1 + y1 * y1;
			var temp : Number = x2 * x2 + y2 * y2;
			if (temp > _extents) _extents = temp;
			temp = x3 * x3 + y3 * y3;
			if (temp > _extents) _extents = temp;
			_extents = Math.sqrt(_extents);
			
			var nx : Number = y2 - y1;
			var ny : Number = x1 - x2;
			var invLength : Number = 1 / Math.sqrt(nx * nx + ny * ny);
			n12x = nx * invLength;
			n12y = ny * invLength;
			n12d = x1 * n12x + y1 * n12y;
			
			nx = y3 - y2;
			ny = x2 - x3;
			invLength = 1 / Math.sqrt(nx * nx + ny * ny);
			n23x = nx * invLength;
			n23y = ny * invLength;
			n23d = x2 * n23x + y2 * n23y;
			
			nx = y1 - y3;
			ny = x3 - x1;
			invLength = 1 / Math.sqrt(nx * nx + ny * ny);
			n31x = nx * invLength;
			n31y = ny * invLength;
			n31d = x3 * n31x + y3 * n31y;
			_volume = NaN;
		}
	}

}