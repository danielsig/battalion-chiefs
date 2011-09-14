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
			if (args.name)
			{
				var obj : GameObject = new GameObject(args.name, Renderer);
			}
			else
			{
				obj = new GameObject(Renderer);
			}
			if (args.x) obj.transform.x = args.x;
			if (args.y) obj.transform.y = args.y;
			if (args.url) obj.renderer.url = args.url;
			if (args.smoothing) obj.renderer.smoothing = args.smoothing;
			if (args.pixelSnapping) obj.renderer.pixelSnapping = args.pixelSnapping;
			if (args.children) obj.addChildren.apply(obj, args.children);
			return obj;
		}
		
	}

}