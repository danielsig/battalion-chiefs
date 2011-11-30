package comp.human 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.powergrid.PowerGrid;
	import comp.objects.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class CivilianController extends Component implements IExclusiveComponent 
	{
		
		public static function createCivilian(x : Number = 0, y : Number = 0) : GameObject
		{
			var civ : GameObject = new GameObject("human", CivilianController);
			civ.transform.x = x;
			civ.transform.y = y;
			return civ;
		}
		
		private var _tr : Transform;
		private var _player : Transform;
		private var _followPlayer : Boolean = false;
		internal var _doorQueue : Vector.<Portal> = null;
		
		public function awake() : void 
		{
			//BODY
			
			HumanBodyFactory.createCivilian(gameObject);
			
			//COMPONENTS
			_tr = gameObject.transform;
			_player = world.player.transform;
			requireComponent(Audio);
			var trigger : Trigger = (requireComponent(Trigger) as Trigger);
			trigger.target = _player;
			trigger.width = 500;
			trigger.height = 500;
		}
		public function targetOnTrigger(player : GameObject, trigger : Trigger) : void 
		{
			_doorQueue = new Vector.<Portal>();
			_followPlayer = true;
			releaseComponent(Trigger).destroy();
			(_player.addComponent(DoorQueue) as DoorQueue)._civilian = this;
		}
		public function fixedUpdate() : void 
		{
			if (_followPlayer)
			{
				var target : Transform = _player;
				var minDist : Number = 100;
				if (_doorQueue.length)
				{
					target = _doorQueue[0].gameObject.transform;
					minDist = 10;
				}
				
				if (target.y - _tr.y > 200 || target.y - _tr.y < -200)
				{
					sendMessage("HumanBody_faceRight");
					sendMessage("HumanBody_goRight");
				}
				else if (target.x - _tr.x > minDist)
				{
					sendMessage("HumanBody_faceRight");
					sendMessage("HumanBody_goRight");
				}
				else if (target.x - _tr.x < -minDist)
				{
					sendMessage("HumanBody_faceLeft");
					sendMessage("HumanBody_goLeft");
				}
				else if (_doorQueue.length)
				{
					if (_doorQueue[0].transport(_tr))
					{
						_doorQueue.shift();
					}
				}
				else
				{
					var v : Number = _player.gameObject.rigidbody.velocity.x;
					if ((v > 3 || v < -3) && (gameObject.rigidbody as Rigidbody).touching(_player.gameObject.boxCollider))
					{
						var destination : Number = _tr.x + (v < 0 ? 64 : -64);
						if(!(PowerGrid.getTile(Physics.toTileX(destination), Physics.toTileY(_tr.y)) & gameObject.boxCollider.layers)) _tr.x = destination;
					}
				}
				if (target.y > _tr.y)
				{
					sendMessage("HumanBody_goDown");
				}
				else if (target.y < _tr.y)
				{
					sendMessage("HumanBody_goUp");
				}
			}
		}
	}

}