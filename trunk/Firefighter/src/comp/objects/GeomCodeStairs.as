package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeStairs extends Component implements IExclusiveComponent 
	{	
		/** @private **/
		public function awake() : void
		{
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: STAIRS ::::::::::::::::::::::::::
		public function geomLeftStairs(stairs : GameObject, params : Object) : void
		{
			(stairs.addComponent(Stairs) as Stairs).rightGoesUp = false;
		}
		public function geomRightStairs(stairs : GameObject, params : Object) : void
		{
			(stairs.addComponent(Stairs) as Stairs).rightGoesUp = true;
		}
	}
}