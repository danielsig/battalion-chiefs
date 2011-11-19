package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeDoors extends Component implements IExclusiveComponent 
	{
		
		private static var _initialized : Boolean = false;
		private static var _counter : uint = 0;
		
		/** @private **/
		public function awake() : void
		{
			if (!_initialized)
			{
				Renderer.drawBox("doorGraphics", 80, 140);
			}
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: DOORS ::::::::::::::::::::::::::
		public function geomDoor(door : GameObject, params : Object) : void
		{
			var portal : Portal = door.addComponent(Portal) as Portal;
			portal.height = 140;
			portal.width = params.dir < 2 ? 80 : 40;//can change
			portal.locked = params.locked;
			portal.strength = params.strength;
			portal.target = world.player.transform;
			
			var graphics : Renderer = door.addComponent(Renderer) as Renderer;
			graphics.setBitmapByName("doorGraphics");
			
			if (params.other && params.other.portal)
			{
				portal.otherPortal = params.other.portal;
				params.other.portal.otherPortal = portal;
				sendAfter("logALL", "fixedUpdate");
				
				door.name = portal.otherPortal.gameObject.name + "B";
				portal.otherPortal.gameObject.name += "A";
			}
			else
			{
				door.name = "door" + ++_counter;
			}
		}
		public function logALL() : void
		{
			world.door1A.log();
			world.door1B.log();
		}
	}
}