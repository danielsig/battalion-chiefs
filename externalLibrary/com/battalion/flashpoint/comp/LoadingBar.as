package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.core.Transform;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class LoadingBar extends Component implements IExclusiveComponent 
	{
		
		private static var _initializer : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.draw("loadingBarGraphics",
			"fill", { color:"0x00FF00" },
				0, 0,
				1, 0,
				1, 9,
				0, 9
			);
			Renderer.draw("loadingBarBackground",
			"line", { thickness:1, color:"0x000000" },
				0, 0,
				50, 0,
				50, 10,
				0, 10,
				0, 0
			);
			return true;
		}
		
		public var value : Number = 0;
		private var _bar : Transform;

		public function awake () : void
		{
			var bar : GameObject = new GameObject("bar", gameObject, Renderer);
			(bar.renderer as Renderer).setBitmapByName("loadingBarGraphics");
			_bar = bar.transform;
			var renderer : Renderer = requireComponent(Renderer) as Renderer;
			renderer.setBitmapByName("loadingBarBackground");
		}
		public function update () : void
		{
			_bar.scaleX = 50 * value;
			_bar.x = -(1 - value) * 25 - 0.5;
			_bar.y = -1;
		}
		public function onDestroy () : Boolean
		{
			_bar.gameObject.destroy()
			return false;
		}
	}

}