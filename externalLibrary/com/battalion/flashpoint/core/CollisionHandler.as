package com.battalion.flashpoint.core 
{
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Dynamics.Contacts.b2CircleContact;
	import flash.geom.Point;
	
	/**
	 * @private
	 * @author Battalion Chiefs
	 */
	internal final class CollisionHandler extends b2ContactListener 
	{
		
		public override function Add(point : b2ContactPoint) : void
		{
			//trace("Collision between " + point.shape1.GetBody().GetUserData().name + " and " + point.shape2.GetBody().GetUserData().name);
			
			var contact1 : ContactPoint = new ContactPoint();
			var contact2 : ContactPoint = new ContactPoint();
			
			contact1.point = (contact2.point = new Point(point.position.x, point.position.y)).clone();
			contact1.normal = (contact2.normal = new Point(point.normal.x, point.normal.y)).clone();
			contact1.relativeVelocity = (contact2.relativeVelocity = new Point(point.velocity.x, point.velocity.y)).clone();
			
			contact1.thisCollider = contact2.otherCollider = point.shape1.m_userData.collider;
			contact1.otherCollider = contact2.thisCollider = point.shape1.m_userData.collider;
			
			contact1.friction = contact2.friction = point.friction;
			contact1.bounce = contact2.bounce = point.restitution;
			contact1.separation = contact2.separation = point.separation;
			
			point.shape1.m_body.m_userData.contacts["p" + point.id._key] = contact1;
			point.shape2.m_body.m_userData.contacts["p" + point.id._key] = contact2;
		}
		public override function Persist(point : b2ContactPoint) : void
		{
			//trace("Collision stays between " + point.shape1.GetBody().GetUserData().name + " and " + point.shape2.GetBody().GetUserData().name);
			
			var contact1 : ContactPoint = point.shape1.m_body.m_userData.contacts["p" + point.id._key];
			var contact2 : ContactPoint = point.shape2.m_body.m_userData.contacts["p" + point.id._key];
			
			if (contact1 == null || contact2 == null)
			{
				Add(point);
			}
			else
			{
				contact1.point.x = contact2.point.x = point.position.x;
				contact1.point.y = contact2.point.y = point.position.y;
				contact1.normal.x = contact2.normal.x = point.normal.x;
				contact1.normal.y = contact2.normal.y = point.normal.y;
				contact1.relativeVelocity.x = contact2.relativeVelocity.x = point.velocity.x;
				contact1.relativeVelocity.y = contact2.relativeVelocity.y = point.velocity.y;
				
				contact1.thisCollider = contact2.otherCollider = point.shape1.m_body.m_userData.collider;
				contact1.otherCollider = contact2.thisCollider = point.shape1.m_body.m_userData.collider;
				
				contact1.friction = contact2.friction = point.friction;
				contact1.bounce = contact2.bounce = point.restitution;
				contact1.separation = contact2.separation = point.separation;
			}
		}
		public override function Remove(point : b2ContactPoint) : void
		{
			//trace("Collision ends between " + point.shape1.GetBody().GetUserData().name + " and " + point.shape2.GetBody().GetUserData().name);
			delete point.shape1.m_body.m_userData.contacts["p" + point.id._key];
			delete point.shape2.m_body.m_userData.contacts["p" + point.id._key];
		}
		
	}

}