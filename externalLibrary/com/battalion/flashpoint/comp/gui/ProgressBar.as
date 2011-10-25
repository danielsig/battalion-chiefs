package com.battalion.flashpoint.comp.gui 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.core.Transform;
	import com.battalion.flashpoint.comp.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class ProgressBar extends Component implements IExclusiveComponent 
	{
		
		private static var _initializer : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.draw("progressBarGraphics",
			"fill", { color:"0x00FF00" },
				0, 0,
				1, 0,
				1, 9,
				0, 9
			);
			Renderer.draw("progressBarBackground",
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
			(bar.renderer as Renderer).setBitmapByName("progressBarGraphics");
			_bar = bar.transform;
			var renderer : Renderer = requireComponent(Renderer) as Renderer;
			renderer.setBitmapByName("progressBarBackground");
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