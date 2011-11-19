package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.display.ColorMatrix;
	import flash.display.ColorCorrection;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	 * A camera component. There's one camera for every View instance.
	 * @see com.battalion.flashpoint.display.View
	 * @see com.battalion.flashpoint.comp.Renderer
	 * @see com.battalion.flashpoint.comp.Animation
	 * @author Battalion Chiefs
	 */
	public final class Camera extends Component implements IExclusiveComponent
	{
		public var colorMatrix : ColorMatrix = null;
		
		private var _bounds : Rectangle = null;
		private var _tr : Transform = null;
		
		/** @private **/
		public function onDestroy() : Boolean
		{
			colorMatrix = null;
			_bounds = null;
			_tr = null;
			return false;
		}
		
		/** @private **/
		public function awake() : void
		{
			_tr = gameObject.transform;
		}
		
		public function rectangleInSight(bounds : Rectangle) : Boolean
		{
			var left : Number = _tr.x - _bounds.width * 0.5 * _tr.scaleX;
			var right : Number = _tr.x + _bounds.width * 0.5 * _tr.scaleX;
			var top : Number = _tr.y - _bounds.height * 0.5 * _tr.scaleY;
			var bottom : Number = _tr.y + _bounds.height * 0.5 * _tr.scaleY;
			
			return bounds.x + bounds.width * 0.5 > left && bounds.x - bounds.width < right
				&& bounds.y + bounds.height > top && bounds.y - bounds.height < bottom;
		}
		public function rendererInSight(renderer : Renderer) : Boolean
		{
			return rectangleInSight(renderer.bounds);
		}
		/**
		 * Checks if a box with a certain center (x,y) and dimensions (width,height) is in sight from this camera in world space.
		 * @param	x, the x coordinate of the box in world space
		 * @param	y, the y coordinate of the box in world space
		 * @param	width, the width of the box to be checked
		 * @param	height, the height of the box to be checked
		 * @return	true if the box is in sight from this camera, otherwise false
		 */
		public function inSight(x : Number, y : Number, width : Number, height : Number) : Boolean
		{
			width *= 0.5;
			height *= 0.5;
			var left : Number = _tr.x - _bounds.width * 0.5 * _tr.scaleX;
			var right : Number = _tr.x + _bounds.width * 0.5 * _tr.scaleX;
			var top : Number = _tr.y - _bounds.height * 0.5 * _tr.scaleY;
			var bottom : Number = _tr.y + _bounds.height * 0.5 * _tr.scaleY;
			
			return x + width > left && x - width < right
				&& y + height > top && y - height < bottom;
		}
		
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