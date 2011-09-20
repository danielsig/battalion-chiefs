package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A camera component. There's one camera for every View instance.
	 * @see View
	 * @author Battalion Chiefs
	 */
	public final class Camera extends Component implements IExclusiveComponent
	{
		private var _bounds : Rectangle = null;
		
		/**
		 * Transform a point in screen coordinates to a point in world coordinates.
		 * @param	point, a point relative to the screen.
		 * @return a new Point relative to the world.
		 */
		public function screenToWorld(point : Point) : Point
		{
			point.x -= _bounds.width * 0.5;
			point.y -= _bounds.height * 0.5;
			return (gameObject.transform.globalMatrix as Matrix).transformPoint(point);
		}
		
		/** @private **/
		public function setBounds(bounds : Rectangle) : void
		{
			if(!_bounds) _bounds = bounds;
		}
	}
	
}