package factory 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class BoxFactory
	{
		
		public static function create(args : Object = null) : GameObject
		{
			args = args || { };
			var obj : GameObject = new GameObject(Renderer);
			if(args.x) obj.transform.x = args.x;
			if(args.y) obj.transform.y = args.y;
			if(args.url) obj.renderer.url = args.url;
			return obj;
		}
		
	}

}