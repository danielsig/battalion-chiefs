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
		public function transformInSight(t : Transform, tWidth : Number, tHeight : Number) : Boolean
		{
			tWidth *= 0.5;
			tHeight *= 0.5;
			var left : Number = _tr.x - _bounds.width * 0.5 * _tr.scaleX;
			var right : Number = _tr.x + _bounds.width * 0.5 * _tr.scaleX;
			var top : Number = _tr.y - _bounds.height * 0.5 * _tr.scaleY;
			var bottom : Number = _tr.y + _bounds.height * 0.5 * _tr.scaleY;
			
			return t.x + tWidth > left && t.x - tWidth < right
				&& t.y + tHeight > top && t.y - tHeight < bottom;
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