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
	public final class GeomCodeProps extends Component implements IExclusiveComponent 
	{
				
		private static var _init : Boolean = init();
		private static function init() : Boolean
		{
			
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
	}
}