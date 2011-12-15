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
			Renderer.load("stairs", "assets/img/stairs.png");
			return true;
		}
		
		public static const WIDTH : Number = 256;
		public static const HEIGHT : Number = 192;
		public static const RATIO : Number = HEIGHT / WIDTH;
		
		public static const SPEED : Number = 0.0015;
		public static const FRICTION : Number = 0.35;
		public static const THRESHOLD : Number = 5;
		public static const WALK_THRESHOLD_FACTOR : Number = 0.5;
		
		private var _bottom : Boolean = false;
		
		public function awake() : void
		{
			//var ren : Renderer = requireComponent(Renderer) as Renderer;
			var ren2 : Renderer = requireComponent(Renderer) as Renderer;
			//ren.setBitmapByName("leftStairGraphics");
			ren2.setBitmapByName("stairs");
			ren2.sendToFront();
			ren2.setOffset(0, -50);
			ren2.offset.b = 0.5;
			
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
				var v : Point = human.gameObject.rigidbody.velocity;
				var height : Number = ((tr.y - HEIGHT * 0.5 + (humanTr.x - tr.x) * RATIO) - humanTr.y);
				//log(height);
				var threshold : Number = THRESHOLD;
				if (v.x > 0) threshold += v.x * RATIO * WALK_THRESHOLD_FACTOR;
				if (height < threshold && height > -50)
				{
					var dy : Number = gameObject.transform.y + HEIGHT * 0.5 - (human.gameObject.transform.y + 63);
					//log(height, human.verticalDirection);
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
						v.x = v.x * FRICTION + human.currentVelocity * SPEED;
						v.y = v.x * RATIO;
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