package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	import flash.geom.Matrix;
	import comp.particles.Heat;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeDoors extends Component implements IExclusiveComponent 
	{
		
		private static const GRAPHICS : Vector.<String> = new <String>["doorFront", "doorBack", "doorLeft", "doorRight"];
		
		private static var _init : Boolean = init();
		
		private static function init() : Boolean
		{
			Renderer.load(GRAPHICS[0], "assets/img/props.png~41~");
			Renderer.load(GRAPHICS[1], "assets/img/props.png~41~");
			Renderer.load(GRAPHICS[2], "assets/img/props.png~42~");
			Renderer.load(GRAPHICS[3], "assets/img/props.png~42~");
			return true;
		}
		private static var _counter : uint = 0;
		
		/** @private **/
		public function awake() : void
		{
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: DOORS ::::::::::::::::::::::::::
		public function geomDoor(door : GameObject, params : Object) : void
		{
			var portal : Portal = door.addComponent(Portal) as Portal;
			(portal.addComponent(Heat) as Heat).materialType = Heat.WOOD;
			
			var col : BoxCollider = door.addComponent(BoxCollider) as BoxCollider;
			col.width = 100;
			col.height = 166;
			col.layers = Layers.OBJECTS_VS_FIRE;
			
			portal.height = 140;
			portal.width = 100;
			portal.locked = params.locked;
			portal.strength = params.strength;
			portal.target = world.player.transform;
			(door.addComponent(DoorSounds) as DoorSounds).direction = params.dir;
			
			var graphics : Renderer = door.addComponent(Renderer) as Renderer;
			graphics.setBitmapByName(GRAPHICS[params.dir]);
			graphics.sendToBack();
			
			if (params.dir > 1)
			{
				graphics.setOffset(((params.dir * 2) - 5) * 40 -5 , -11, 1.3);
				if (params.dir == 3)
				{
					graphics.offset.a = -graphics.offset.a;
					graphics.offset.tx += 12;
				}
			}
			else graphics.setOffset(0 , -12, 1.3);
			
			if (params.other && params.other.portal)
			{
				portal.otherPortal = params.other.portal;
				params.other.portal.otherPortal = portal;
				
				door.name = portal.otherPortal.gameObject.name + "B";
				portal.otherPortal.gameObject.name += "A";
			}
			else
			{
				door.name = "door" + ++_counter;
			}
		}
	}
}