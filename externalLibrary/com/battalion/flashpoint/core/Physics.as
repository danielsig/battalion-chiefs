package com.battalion.flashpoint.core 
{
	import adobe.utils.CustomActions;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.battalion.powergrid.PowerGrid;
	
	/**
	 * Physics management, interacts with the PowerGrid Physics Engine.
	 * @author Battalion Chiefs
	 */
	public final class Physics 
	{
		private static var _grid : BitmapData = null;
		private static var _initialized : Boolean = false;
		/** @private  */
		internal static var _maxSize : Number = 512;
		/** @private  */
		internal static var _unitSize : Number = 32;
		/** @private  */
		internal static var _offsetX : Number = 0;
		/** @private  */
		internal static var _offsetY : Number = 0;
		
		/**
		 * The number of physics iterations. The greater this value is, the more accurate the simulation will be at the cost of speed.
		 */
		public static function get iterations() : uint
		{
			return PowerGrid.maxIterations;
		}
		public static function set iterations(value : uint) : void
		{
			CONFIG::debug
			{
				if (value == 0) throw new Error("iterations must be greater than 0");
			}
			PowerGrid.maxIterations = value;
		}
		
		/**
		 * Must be a power of 2.
		 */
		public static function get unitSize() : uint
		{
			return _unitSize;
		}
		public static function set unitSize(value : uint) : void
		{
			_unitSize = value;
			if (_initialized)
			{
				init();
				_unitSize = PowerGrid.unitSize;
			}
		}
		
		/**
		 * The maximum size for colliders in your game.
		 */
		public static function get maxSize() : Number
		{
			return _maxSize;
		}
		public static function set maxSize(value : Number) : void
		{
			_maxSize = value;
			if (_initialized)
			{
				init();
			}
		}
		
		/**
		 * The grid to be used.
		 */
		public static function get grid() : BitmapData
		{
			return _grid;
		}
		public static function set grid(value : BitmapData) : void
		{
			_grid = value;
			if (_initialized)
			{
				init();
			}
		}
		
		/**
		 * The direction and magnitude of gravity. Defauld is (0, 294)
		 */
		public static function get gravityVector() : Point
		{
			return new Point(PowerGrid.gravityX, PowerGrid.gravityY);
		}
		public static function set gravityVector(value : Point) : void
		{
			PowerGrid.gravityX = value.x;
			PowerGrid.gravityY = value.y;
		}
		
		/**
		 * The x and y offset of the grid in pixels
		 */
		public static function get gridOffset() : Point
		{
			return new Point(_offsetX, _offsetY);
		}
		public static function set gridOffset(value : Point) : void
		{
			_offsetX = value.x;
			_offsetY = value.y;
		}
		
		public static function setAll(grid : BitmapData, unitSize : uint, maxSize : Number) : void
		{
			_grid = grid;
			_unitSize = unitSize;
			_maxSize = maxSize;
		}
		
		public static function init() : void
		{
			_initialized = true;
			PowerGrid.sleepVelocity = 0.1;
			PowerGrid.restingSpeed = 0.03;
			PowerGrid.init(_grid, _unitSize, _maxSize);
			PowerGrid.setOptimalMaxVelocity();
		}
		
		/** @private **/
		internal static function step(interval : Number) : void 
		{
			if (_initialized)
			{
				Collider.processPhysics();
				PowerGrid.step(interval * 1000);
			}
		}
		
	}

}