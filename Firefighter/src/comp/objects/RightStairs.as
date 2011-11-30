package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.powergrid.PowerGrid;
	import flash.geom.Point;
	import comp.human.HumanBody;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class RightStairs extends Component implements IExclusiveComponent 
	{
		
		private static var _init : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.load("stairs", "assets/img/stairs.png");
			return true;
		}
		
		private var _bottom : Boolean = false;
		
		public function awake() : void
		{
			var ren : Renderer = requireComponent(Renderer) as Renderer;
			ren.setBitmapByName("stairs");
			ren.sendToFront();
			ren.setOffset(0, -50);
			ren.offset.b = 0.5;
			ren.offset.a = -1;
			sendAfter("afterInit", "fixedUpdate");
		}
		public function afterInit() : void
		{
			if (PowerGrid.getTile(Physics.toTileX(gameObject.transform.x), Physics.toTileY(gameObject.transform.y + LeftStairs.HEIGHT)))
			{
				_bottom = true;
			}
			//log(_bottom);
		}
		public function fixedUpdate() : void
		{
			var collisions : Vector.<Collider> = Physics.getInArea
			(
				new Rectangle(
					gameObject.transform.x - LeftStairs.WIDTH * 0.5,
					gameObject.transform.y - LeftStairs.HEIGHT * 0.5,
					LeftStairs.WIDTH, LeftStairs.HEIGHT
				)
			);
			//log("frame");
			for each(var col : Collider in collisions)
			{
				if (col.gameObject.humanBody && col.gameObject.boxCollider.layers & Layers.STAIRS_RIGHT) onHuman(col.gameObject.humanBody);
			}
		}
		public function onHuman(human : HumanBody) : void
		{
			var tr : Transform = gameObject.transform;
			var humanTr : Transform = human.gameObject.transform;
			if (humanTr.x + 31 > tr.x - LeftStairs.HEIGHT * 0.5 && humanTr.x - 31 < tr.x + LeftStairs.HEIGHT * 0.5)
			{
				var height : Number = (tr.y - LeftStairs.HEIGHT * 0.5 - (humanTr.x - tr.x) * LeftStairs.RATIO) - humanTr.y;
				//log(height);
				if (height < 5 && height > -50)
				{
					var dy : Number = gameObject.transform.y + LeftStairs.HEIGHT * 0.5 - (human.gameObject.transform.y + 63);
					//log(height, human.verticalDirection);
					var useTheseStairs : Boolean = (dy < LeftStairs.HEIGHT && dy > 5)
						|| _bottom || (human.verticalDirection < 0 && dy > 0);
					if (useTheseStairs)
					{
						human.gameObject.boxCollider.removeLayers(Layers.STAIRS_LEFT);
						human.gameObject.boxCollider.addLayers(Layers.STAIRS_RIGHT);
						
						if (human.verticalDirection > 1 || human.verticalDirection < -1)
						{
							human.gameObject.rigidbody.addForceX(-human.verticalDirection * human.speed, ForceMode.ACCELLERATION);
						}
						var v : Point = human.gameObject.rigidbody.velocity;
						v.x += human.currentVelocity * 0.003;
						v.y = -v.x * 0.73;
						human.gameObject.rigidbody.velocity = v;
						humanTr.y += height;
					}
					else
					{
						human.gameObject.boxCollider.removeLayers(Layers.STAIRS_RIGHT);
						human.gameObject.boxCollider.addLayers(Layers.STAIRS_LEFT);
					}
					human.gameObject.rigidbody.affectedByGravity = false;
					human.grounded = true;
				}
				else human.gameObject.boxCollider.addLayers(Layers.STAIRS);
			}
			else human.gameObject.boxCollider.addLayers(Layers.STAIRS);
		}
	}

}