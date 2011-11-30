package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeStairs extends Component implements IExclusiveComponent 
	{	
		/** @private **/
		/*private static function init() : Boolean
		{
			Renderer.load("stairs", "assets/img/stairs.png");
			return true;

		}*/
		
		public function awake() : void
		{
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: STAIRS ::::::::::::::::::::::::::
		public function geomLeftStairs(stairs : GameObject, params : Object) : void
		{
			stairs.addComponent(LeftStairs);
			/*var ren : Renderer = stairs.addComponent(Renderer) as Renderer;
			var col : BoxCollider = stairs.addComponent(BoxCollider) as BoxCollider;
			ren.setBitmapByName("stairs");
			ren.setOffset(0, -22);
			col.dimensions = new Point(32, 32);*/

		}
		public function geomRightStairs(stairs : GameObject, params : Object) : void
		{
			stairs.addComponent(RightStairs);
			/*var ren : Renderer = stairs.addComponent(Renderer) as Renderer;
			
			var col : BoxCollider = stairs.addComponent(BoxCollider) as BoxCollider;
			ren.setBitmapByName("stairs");
			ren.offset.a = -ren.offset.a;
			
			ren.setOffset(0, -22);
			col.dimensions = new Point(32, 32);*/
		}
	}
}