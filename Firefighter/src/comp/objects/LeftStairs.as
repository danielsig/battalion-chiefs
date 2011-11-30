package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.powergrid.PowerGrid;
	import comp.human.HumanBody;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class LeftStairs extends Component implements IExclusiveComponent 
	{
		
		private static var _init : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.draw("leftStairGraphics",
				"fill", { color:0 },
				WIDTH * 0.5, HEIGHT * 0.5,
				-WIDTH * 0.5, -HEIGHT * 0.5,
				-WIDTH * 0.5, HEIGHT * 0.5
			);
			return true;
		}
		
		public static const WIDTH : Number = 256;
		public static const HEIGHT : Number = 192;
		public static const RATIO : Number = HEIGHT / WIDTH;
		
		private var _bottom : Boolean = false;
		
		public function awake() : void
		{
			var ren : Renderer = requireComponent(Renderer) as Renderer;
			ren.setBitmapByName("leftStairGraphics");
			sendAfter("afterInit", "fixedUpdate");
		}
		public function afterInit() : void
		{
			if (PowerGrid.getTile(Physics.toTileX(gameObject.transform.x), Physics.toTileY(gameObject.transform.y + LeftStairs.HEIGHT)))
			{
				_bottom = true;
			}
			log(_bottom);
		}
		public function fixedUpdate() : void
		{
			var collisions : Vector.<Collider> = Physics.getInArea
			(
				new Rectangle(
					gameObject.transform.x - WIDTH * 0.5,
					gameObject.transform.y - HEIGHT * 0.5,
					WIDTH, HEIGHT
				)
			);
			//log("frame");
			for each(var col : Collider in collisions)
			{
				if (col.gameObject.humanBody && col.gameObject.boxCollider.layers & Layers.STAIRS_LEFT) onHuman(col.gameObject.humanBody);
			}
		}
		public function onHuman(human : HumanBody) : void
		{
			var tr : Transform = gameObject.transform;
			var humanTr : Transform = human.gameObject.transform;
			if (humanTr.x + 31 > tr.x - LeftStairs.HEIGHT * 0.5 && humanTr.x - 31 < tr.x + LeftStairs.HEIGHT * 0.5)
			{
				var height : Number = (tr.y - HEIGHT * 0.5 + (humanTr.x - tr.x) * RATIO) - humanTr.y;
				//log(height);
				if (height < 5 && height > -50)
				{
					var dy : Number = gameObject.transform.y + HEIGHT * 0.5 - (human.gameObject.transform.y + 63);
					log(height, human.verticalDirection);
					var useTheseStairs : Boolean = (dy < HEIGHT && dy > 5)
						|| _bottom || (human.verticalDirection < 0 && dy > 0);
					if (useTheseStairs)
					{
						human.gameObject.boxCollider.removeLayers(Layers.STAIRS_RIGHT);
						human.gameObject.boxCollider.addLayers(Layers.STAIRS_LEFT);
						
						if (human.verticalDirection > 1 || human.verticalDirection < -1)
						{
							human.gameObject.rigidbody.addForceX(human.verticalDirection * human.speed, ForceMode.ACCELLERATION);
						}
						var v : Point = human.gameObject.rigidbody.velocity;
						v.x += human.currentVelocity * 0.003;
						v.y = v.x * 0.73
						human.gameObject.rigidbody.velocity = v;
						humanTr.y += height;
					}
					else
					{
						human.gameObject.boxCollider.removeLayers(Layers.STAIRS_LEFT);
						human.gameObject.boxCollider.addLayers(Layers.STAIRS_RIGHT);
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