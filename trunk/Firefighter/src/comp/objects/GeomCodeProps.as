package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import comp.particles.Heat;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeProps extends Component implements IExclusiveComponent 
	{
				
		private static var _init : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.load("tv0", "assets/img/props.png~30~")
			return true;
		}
		
		/** @private **/
		public function awake() : void
		{
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: LAMPS ::::::::::::::::::::::::::
		public function geomLamp(lamp : GameObject, params : Object) : void
		{
			var ren : Renderer = lamp.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("lamp" + params.type);
		}
		//{::::::::::::::::::::::::: TVs ::::::::::::::::::::::::::
		public function geomTV(tv : GameObject, params : Object) : void
		{
			tv.addComponent(Heat);
			var ren : Renderer = tv.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("tv" + params.type);
			ren.sendToBack();
			var col : BoxCollider = tv.addComponent(BoxCollider) as BoxCollider;
			col.dimensions = new Point(128, 128);
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
		}
	}
}