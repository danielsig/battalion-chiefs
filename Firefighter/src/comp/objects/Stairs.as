package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Stairs extends Component implements IExclusiveComponent 
	{
		
		private static var _init : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.drawBox("stairGraphics", WIDTH, HEIGHT);
			return true;
		}
		
		public static const WIDTH : Number = 256;
		public static const HEIGHT : Number = 192;
		
		public var rightGoesUp : Boolean = true;
		
		public function awake() : void
		{
			var col : TriangleCollider = requireComponent(TriangleCollider) as TriangleCollider;
			col.defineSizeAndAnchor(WIDTH, int(rightGoesUp) - 0.5, -HEIGHT / WIDTH);
			col.layers = Layers.ALL;
			var ren : Renderer = requireComponent(Renderer) as Renderer;
			ren.setBitmapByName("stairGraphics");
			ren.setOffset(-WIDTH / 6, -HEIGHT / 6);
		}
		public function fixedUpdate() : void
		{
			
		}
	}

}