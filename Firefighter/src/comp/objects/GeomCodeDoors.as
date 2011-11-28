package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	import flash.geom.Matrix;
	
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
			Renderer.drawBox(GRAPHICS[0], 80, 140, 0xFF0000);
			Renderer.drawBox(GRAPHICS[1], 80, 140, 0xFFFFFF);
			Renderer.drawBox(GRAPHICS[2], 20, 140, 0x00FF00);
			Renderer.drawBox(GRAPHICS[3], 20, 140, 0x0000FF);
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
			portal.height = 140;
			portal.width = 100;
			portal.locked = params.locked;
			portal.strength = params.strength;
			portal.target = world.player.transform;
			
			var graphics : Renderer = door.addComponent(Renderer) as Renderer;
			graphics.setBitmapByName(GRAPHICS[params.dir]);
			graphics.sendToBack();
			if (params.dir > 1) graphics.offset = new Matrix(1, 0, 0, 1, ((params.dir * 2) - 5) * 40);
			
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