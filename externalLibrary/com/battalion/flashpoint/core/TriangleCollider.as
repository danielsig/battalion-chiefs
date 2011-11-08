package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.Triangle;
	import flash.geom.Point;
	/**
	 * A simple Triangle Collider.
	 * @author Battalion Chiefs
	 */
	public final class TriangleCollider extends Collider 
	{
		/**
		 * The 1st point in the Triangle.
		 */
		public function get p1() : Point
		{
			return new Point((body as Triangle).x1, (body as Triangle).y1);
		}
		public function set p1(value : Point) : void
		{
			(body as Triangle).x1 = value.x;
			(body as Triangle).y1 = value.y;
			(body as Triangle).updateVertices();
		}
		/**
		 * The 2nd point in the Triangle.
		 */
		public function get p2() : Point
		{
			return new Point((body as Triangle).x2, (body as Triangle).y2);
		}
		public function set p2(value : Point) : void
		{
			(body as Triangle).x2 = value.x;
			(body as Triangle).y2 = value.y;
			(body as Triangle).updateVertices();
		}
		/**
		 * The 3rd point in the Triangle.
		 */
		public function get p3() : Point
		{
			return new Point((body as Triangle).x3, (body as Triangle).y3);
		}
		public function set p3(value : Point) : void
		{
			(body as Triangle).x3 = value.x;
			(body as Triangle).y3 = value.y;
			(body as Triangle).updateVertices();
		}
		
		/**
		 * Define the Triangle's form by specifying a size and then the position
		 * of the first vertex (anchorX and anchorY) relative to the line between the other two vertices.
		 * Optionally you can define the rotation of the Triangle by it's center.
		 * @param	size
		 * @param	anchorX
		 * @param	anchorY
		 * @param	rotation, rotation offset, default is 0.
		 */
		public function defineSizeAndAnchor(size : Number, anchorX : Number, anchorY : Number, rotation : Number = 0) : void
		{
			(body as Triangle).defineForm(size, anchorX, anchorY);
			if(rotation != 0) (body as Triangle).rotate(rotation);
		}
		
		/**
		 * Define the Triangle's form by specifying 3 vertices.
		 * @param	p1
		 * @param	p2
		 * @param	p3
		 */
		public function defineVertices(p1 : Point, p2 : Point, p3 : Point) : void
		{
			var triangle : Triangle = body as Triangle;
			
			triangle.x1 = p1.x;
			triangle.x2 = p2.x;
			triangle.x3 = p3.x;
			
			triangle.y1 = p1.y;
			triangle.y2 = p2.y;
			triangle.y3 = p3.y;
			
			triangle.updateVertices();
		}
		/**
		 * Define the Triangle's form by specifying x and y of 3 vertices.
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	x3
		 * @param	y3
		 */
		public function define(x1 : Number, y1 : Number, x2 : Number, y2: Number, x3 : Number, y3 : Number) : void
		{
			var triangle : Triangle = body as Triangle;
			
			triangle.x1 = x1;
			triangle.x2 = x2;
			triangle.x3 = x3;
			
			triangle.y1 = y1;
			triangle.y2 = y2;
			triangle.y3 = y3;
			
			triangle.updateVertices();
		}
		
		/**
		 * rotate the vertices by <code>degrees</code>.
		 * @param	degrees
		 */
		public function rotate(degrees : Number) : void
		{
			(body as Triangle).rotate(degrees);
		}
		/**
		 * scale the vertices by <code>scalar</code>.
		 * @param	scalar
		 */
		public function scale(scalar : Number) : void
		{
			(body as Triangle).scale(scalar);
		}
		
		/** @private */
		protected override function makeCollider(material : PhysicMaterial) : void 
		{
			body = new Triangle();
			
			var triangle : Triangle = body as Triangle;
			triangle.userData = this;
			
			triangle.x1 = -1;
			triangle.x2 = 0;
			triangle.x3 = 1;
			
			triangle.y1 = 0.7;
			triangle.y2 = -0.7;
			triangle.y3 = 0.7;
		}
	}

}