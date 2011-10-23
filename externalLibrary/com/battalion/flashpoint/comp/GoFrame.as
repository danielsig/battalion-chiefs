package com.battalion.flashpoint.comp 
{
	/**
	 * @private
	 * If you're reading this, go away! LEAVE ME ALONE!!!
	 * @author Battalion Chiefs
	 */
	internal final class GoFrame 
	{
		
		public var angles : Vector.<Number>;
		public var xPos : Vector.<Number>;
		public var yPos : Vector.<Number>;
		
		public function GoFrame(length : uint)
		{
			angles = new Vector.<Number>(length, true);
			xPos = new Vector.<Number>(length, true);
			yPos = new Vector.<Number>(length, true);
		}
		
	}

}