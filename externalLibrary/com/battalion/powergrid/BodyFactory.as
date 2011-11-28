package com.battalion.powergrid 
{
	/**
	 * A static class for creating common primitive rigidbody shapes.
	 * @author Battalion Chiefs
	 */
	public final class BodyFactory 
	{
		
		private static const ONE_SIXTH : Number = 1.0 / 6;
		
		public static function createBox(width : Number, height : Number) : Group 
		{
			var triangle1 : Triangle = new Triangle();
			triangle1.defineForm(width, 0.5, height / width);
			var triangle2 : Triangle = new Triangle();
			triangle2.defineForm(width, -0.5, -height / width);
			
			triangle1.x = width * ONE_SIXTH;
			triangle1.y = -height * ONE_SIXTH;
			triangle2.x = -width * ONE_SIXTH;
			triangle2.y = height * ONE_SIXTH;
			
			PowerGrid.addBody(triangle1, triangle2)
			return new Group(0, 0, triangle1, triangle2);
		}
		public static function redefineBox(box : Group, width : Number, height : Number, triangle1 : Triangle = null, triangle2 : Triangle = null) : void 
		{
			
			var triangle1 : Triangle = triangle1 || box.getBodyAt(0) as Triangle;
			triangle1.defineForm(width, 0.5, height / width);
			var triangle2 : Triangle = triangle2 || box.getBodyAt(1) as Triangle;
			triangle2.defineForm(width, -0.5, -height / width);
			
			triangle1.relativeX = width * ONE_SIXTH;
			triangle1.relativeY = -height * ONE_SIXTH;
			triangle2.relativeX = -width * ONE_SIXTH;
			triangle2.relativeY = height * ONE_SIXTH;
			
			triangle1.x = width * ONE_SIXTH;
			triangle1.y = -height * ONE_SIXTH;
			triangle2.x = -width * ONE_SIXTH;
			triangle2.y = height * ONE_SIXTH;
		}
	}

}