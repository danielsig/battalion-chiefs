package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.*;
	import flash.geom.Point;
	/**
	 * @private
	 * @author Battalion Chiefs
	 */
	internal final class UpdatePhysics extends Component implements IExclusiveComponent, IConciseComponent 
	{
		public function updatePhysics() : void
		{
			var physics : Object = _gameObject._physicsComponents;
			var body : AbstractRigidbody;
			if (physics)
			{
				if (!(physics.rigidbody || physics.collider0))
				{
					if (_gameObject.beginMovement)
					{
						delete _gameObject.beginMovement;
						delete _gameObject.endMovement;
					}
					return;
				}
				
				var dx : Number = _gameObject.transform.x - physics.originalX;
				var dy : Number = _gameObject.transform.y - physics.originalY;
				var da : Number = _gameObject.transform.rotation - physics.originalA;
				
				delete physics.originalX;
				delete physics.originalY;
				delete physics.originalA;
				
				if (physics.length != 1 || physics.hasBox)//should it have a group?
				{
					if (!physics.group)//does it NOT have a group?
					{
						//it does not have a group... yet
						body = physics.group = new Group(_gameObject.transform.x, _gameObject.transform.y);//make a new group
						for each(var col : * in physics)
						{
							if (col is Collider)//for each collider
							{
								//add the collider to the group
								col.body.x += dx;
								col.body.y += dy;
								col.body.a += da;
								if (col.body is Group)
								{
									(col.body as Group).syncBodies();
									(body as Group).join(col.body as Group);
								}
								else (body as Group).addBody(col.body);
							}
						}
					}
					else body = physics.group;
				}
				else// it should not have a group
				{
					if (physics.group)//but DOES it have a group?
					{
						//yes it does
						physics.group.ungroup();
						delete physics.group;
					}
					body = physics.collider0.body;
				}
				
				for each(col in physics)
				{
					if (col is Collider)//for each collider
					{
						if(!(col.body is Group || col.body.added)) PowerGrid.addBody(col.body);
					}
				}
				
				if (physics.rigidbody)
				{	
					body.angularDrag = physics.rigidbody.angularDrag;
					body.drag = physics.rigidbody.drag;
					body.mass = physics.rigidbody.mass;
					body.affectedByGravity = physics.rigidbody.affectedByGravity;
					var v : Point = physics.rigidbody.velocity;
					body.vx = v.x;
					body.vy = v.y;
					body.va = physics.rigidbody.angularVelocity;
					body.inertia = physics.rigidbody.freezeRotation ? Infinity : physics.rigidbody.inertia;
					
					physics.rigidbody.body = body;
					
					if (_gameObject.beginMovement)
					{
						delete _gameObject.beginMovement;
						delete _gameObject.endMovement;
					}
				}
				else
				{
					body.angularDrag = 0;
					body.drag = 0;
					body.mass = 0;
					body.inertia = Infinity;
					
					if (body is Group)
					{
						var bodies : Vector.<AbstractRigidbody> = (body as Group).bodyList;
						for each(var child : AbstractRigidbody in bodies)
						{
							child.mass = 0;
						}
					}
					_gameObject.beginMovement = physics.collider0.beginMovement;
					_gameObject.endMovement = physics.collider0.endMovement;
				}
				body.x = _gameObject.transform.x - Physics._offsetX;
				body.y = _gameObject.transform.y - Physics._offsetY;
				body.a = _gameObject.transform.rotation;
				
				if (physics.group) physics.group.syncBodies();
				
				physics.body = body;
				
				if (!body.added) PowerGrid.addBody(body);
				
				if (!physics.added)
				{
					if (physics.rigidbody)
					{
						physics.rigidbody.addPhysics();
					}
					else
					{
						physics.collider0.addPhysics();
					}
				}
				physics.updated = false;
			}
		}
		
	}

}