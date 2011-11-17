package com.battalion.flashpoint.display 
{
	import starling.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.geom.Rectangle;
	
	/**
	 * @private
	 * @author Battalion Chiefs
	 */
	public final class StageFlash11 extends starling.display.Sprite 
	{
		
		public static var starlingStage : StageFlash11;
		internal static var queue : Vector.<ViewFlash11> = new Vector.<ViewFlash11>();
		
		public function StageFlash11()
		{
			starlingStage = this;
			if (queue.length)
			{
				for each(var view : ViewFlash11 in queue)
				{
					addChild(view);
				}
				queue.length = 0;
			}
		}
		
	}

}