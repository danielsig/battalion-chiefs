package com.battalion.flashpoint.core 
{
	import adobe.utils.CustomActions;
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2AABB;
	import Box2D.Dynamics.b2World;
	/**
	 * Physics management, interacts with the Box2D Physics Engine.
	 * @author Battalion Chiefs
	 */
	public final class Physics 
	{
		
		/** @private **/
		internal static var _pixelsPerMeter : Number = 30;
		/** @private **/
		internal static var _pixelsPerMeterInverse : Number = 1 / Physics._pixelsPerMeter;
		
		private static var _collisionHandler : CollisionHandler = new CollisionHandler();
		
		public static function get pixelsPerMeter() : Number
		{
			return _pixelsPerMeter;
		}
		public static function set pixelsPerMeter(value : Number) : void
		{
			_pixelsPerMeter = value;
			_pixelsPerMeterInverse = 1 / value;
		}
		
		/**
		 * The number of physics iterations. The greater this value is, the more accurate the simulation will be at the cost of speed.
		 */
		public static var iterations : uint = 5;
		/**
		 * The direction and magnitude of gravity. Defauld is (0, 294)
		 */
		public static function get gravityVector() : Point
		{
			return new Point(_gravity.x, _gravity.y);
		}
		public static function set gravityVector(value : Point) : void
		{
			_gravity = new b2Vec2(value.x, value.y);
			_physicsWorld.SetGravity(_gravity);
		}
		
		private static var _gravity : b2Vec2 = new b2Vec2 (0.0, 9.8);
		/** @private **/
		internal static var _physicsWorld : b2World;
		
		/** @private **/
		internal static function init(bounds : Rectangle) : void 
		{
			var worldAABB : b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(bounds.x, bounds.y);
			worldAABB.upperBound.Set(bounds.right, bounds.bottom);
			var doSleep : Boolean = true;
			_physicsWorld = new b2World(worldAABB, _gravity, doSleep);
			_physicsWorld.SetContactListener(_collisionHandler);
		}
		/** @private **/
		internal static function step(interval : Number) : void 
		{
			PhysicsSyncable.processPhysics();
			_physicsWorld.Step(interval, iterations);
		}
		
	}

}