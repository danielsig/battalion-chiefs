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
				if (!((physics.rigidbody && _gameObject.rigidbody) || physics.collider0))
				{
					if (_gameObject.beginMovement)
					{
						delete _gameObject.beginMovement;
						delete _gameObject.endMovement;
					}
					return;
				}
				
				if (physics.originalX != undefined)
				{
					var dx : Number = _gameObject.transform.x - physics.originalX;
					var dy : Number = _gameObject.transform.y - physics.originalY;
					var da : Number = _gameObject.transform.rotation - physics.originalA;
					
					delete physics.originalX;
					delete physics.originalY;
					delete physics.originalA;
				}
				else
				{
					dx = _gameObject.transform.x;
					dy = _gameObject.transform.y;
					da = _gameObject.transform.rotation;
				}
				
				if (physics.length != 1 || physics.hasBox || (!physics.collider0.enabled && physics.rigidbody))//should it have a group?
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
					else body = physics.group;//ok it already had a group
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
					var collider : Collider = col as Collider;
					if (collider)//for each collider
					{
						if (!(collider.body is Group || collider.body.added))
						{
							PowerGrid.addBody(collider.body);
							collider.body.enabled = collider.enabled;
						}
					}
				}
				
				if (physics.rigidbody)
				{	
					if (_gameObject.rigidbody)
					{
						if (_gameObject.rigidbody != physics.rigidbody) physics.rigidbody = _gameObject.rigidbody;
						var rigidbody : Rigidbody = physics.rigidbody;
						
						body.angularDrag = rigidbody.angularDrag;
						body.drag = rigidbody.drag;
						body.mass = isNaN(rigidbody._density) ? rigidbody.mass : rigidbody.density * body.volume;
						body.inertia = isNaN(rigidbody._massDistribution) ? (rigidbody.freezeRotation ? Infinity : rigidbody.inertia) : (rigidbody.massDistribution * body.volume);
						body.affectedByGravity = rigidbody.affectedByGravity;
						body.vanDerWaals = rigidbody.vanDerWaals;
						var v : Point = rigidbody.velocity;
						body.vx = v.x;
						body.vy = v.y;
						body.va = rigidbody.angularVelocity;
						v = rigidbody.gameObject.transform.position;
						body.lastX = v.x - Physics.gridOffset.x;
						body.lastY = v.y - Physics.gridOffset.y;
						body.enabled = rigidbody.enabled;
						
						rigidbody.body = body;
						
						if (_gameObject.beginMovement)
						{
							delete _gameObject.beginMovement;
							delete _gameObject.endMovement;
						}
					}
					else delete physics.rigidbody;
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
							child.inertia = Infinity;
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
				if (physics.rigidbody && physics.group) physics.group.computeCenterOfMass();
				physics.updated = false;
			}
		}
		
	}

}