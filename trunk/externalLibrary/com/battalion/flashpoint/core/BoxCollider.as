package com.battalion.flashpoint.core 
{
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import com.battalion.flashpoint.core.*;
	import flash.geom.Point;
	
	/**
	 * A Box Collider
	 * @author Battalion Chiefs
	 */
	public final class BoxCollider extends Collider
	{
		public function get width() : Number
		{
			return _width;
		}
		public function set width(value : Number) : void
		{
			_width = value;
			if (_body)
			{
				(_def as b2PolygonDef).SetAsBox(width * Physics._pixelsPerMeterInverse * 0.5, height * Physics._pixelsPerMeterInverse * 0.5);
				updateCollider();
			}
		}
		public function get height() : Number
		{
			return _height;
		}
		public function set height(value : Number) : void
		{
			_height = value;
			if (_body)
			{
				(_def as b2PolygonDef).SetAsBox(width * Physics._pixelsPerMeterInverse * 0.5, height * Physics._pixelsPerMeterInverse * 0.5);
				updateCollider();
			}
		}
		public function get dimensions() : Point
		{
			return new Point(_width, _height);
		}
		public function set dimensions(value : Point) : void
		{
			_width = value.x;
			_height = value.y;
			if (_body)
			{
				(_def as b2PolygonDef).SetAsBox(width * Physics._pixelsPerMeterInverse * 0.5, height * Physics._pixelsPerMeterInverse * 0.5);
				updateCollider();
			}
		}
		
		private var _width : Number = 1;
		private var _height : Number = 1;
		
		/** @private **/
		public override function start() : void
		{
			_def = new b2PolygonDef();
			_def.type = 1;
			_def.density = 1;
			(_def as b2PolygonDef).SetAsBox(width * Physics._pixelsPerMeterInverse * 0.5, height * Physics._pixelsPerMeterInverse * 0.5);
			super.start();
			updateCollider();
		}
	}
	
}