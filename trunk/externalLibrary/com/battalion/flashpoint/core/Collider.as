package com.battalion.flashpoint.core 
{
	
	import Box2D.Collision.Shapes.b2ShapeDef;
	import com.battalion.flashpoint.core.*;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.b2Shape;
	
	/**
	 * A Base Collider, do not extend or instantiate this Component. Instead use any of the other Colliders, the Components extending this Component.
	 * @see BoxCollider
	 * @author Battalion Chiefs
	 */
	public class Collider extends PhysicsSyncable
	{
		
		private var _material : PhysicMaterial = new PhysicMaterial();
		
		private var _shape : b2Shape;
		/** @private **/
		protected var _def : b2ShapeDef;
		
		/** @private **/
		public function Collider()
		{
			CONFIG::debug
			{
				if (!(this is BoxCollider))
				{
					throw new Error("Do not extend the Collider component!");
				}
			}
		}
		
		public function get material() : PhysicMaterial
		{
			return _material;
		}
		public function set material(value : PhysicMaterial) : void
		{
			_material = value;
			if (_shape)
			{
				_shape.m_friction = _material.friction;
				_shape.m_restitution = _material.bounciness;
				if (!isNaN(_material.density))
				{
					_shape.m_density = _material.density;
				}
			}
		}
		/** @private **/
		internal final function updateCollider() : void
		{
			if (_shape)
			{
				_body.DestroyShape(_shape);
			}
			_shape = _body.CreateShape(_def);
			_shape.SetUserData( { collider:this } );
			_shape.m_friction = _material.friction;
			_shape.m_restitution = _material.bounciness;
			if (!isNaN(_material.density))
			{
				_shape.m_density = _material.density;
			}
			else _shape.m_density = 0;
			_body.SetMassFromShapes();
		}
		/** @private **/
		public final override function onDestroy() : Boolean 
		{
			_body.DestroyShape(_shape);
			return super.onDestroy();
		}
		
	}
	
}