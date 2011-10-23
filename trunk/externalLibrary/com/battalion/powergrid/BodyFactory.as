package com.battalion.powergrid 
{
	/**
	 * A static class for creating common primitive rigidbody shapes.
	 * @author Battalion Chiefs
	 */
	public final class BodyFactory 
	{
		
		public static function createBox(width : Number, height : Number) : Group 
		{
			var triangle1 : Triangle = new Triangle();
			triangle1.defineForm(width, width * 0.5, height);
			var triangle2 : Triangle = new Triangle();
			triangle2.defineForm(width, -width * 0.5, -height);
			
			triangle1.x = width * 0.16;
			triangle1.y = -height * 0.16;
			triangle2.x = -width * 0.16;
			triangle2.y = height * 0.16;
			
			PowerGrid.addBody(triangle1, triangle2)
			return new Group(0, 0, triangle1, triangle2);
		}
		public static function redefineBox(box : Group, width : Number, height : Number, triangle1 : Triangle = null, triangle2 : Triangle = null) : void 
		{
			var triangle1 : Triangle = triangle1 || box.getBodyAt(0) as Triangle;
			triangle1.defineForm(width, width * 0.5, height);
			var triangle2 : Triangle = triangle2 || box.getBodyAt(1) as Triangle;
			triangle2.defineForm(width, -width * 0.5, -height);
			
			triangle1.relativeX = width * 0.16;
			triangle1.relativeY = -height * 0.16;
			triangle2.relativeX = -width * 0.16;
			triangle2.relativeY = height * 0.16;
			
			triangle1.x = width * 0.16;
			triangle1.y = -height * 0.16;
			triangle2.x = -width * 0.16;
			triangle2.y = height * 0.16;
		}
	}

}