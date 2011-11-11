package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.Input;
	import com.greensock.TweenMax;
	
	/**
	 * Add this Component to anything, then use the scroll wheel to zoom in and out. Works only with one camera.
	 * @author Battalion Chiefs
	 */
	public class Zoomer extends Component implements IExclusiveComponent
	{
		
		public static var zoomKey : * = "e";
		private var _zoom : Number = 1;
		
		/** @private **/
		public function awake() : void 
		{
			Input.assignButton("zoomButton", zoomKey);
		}
		
		/** @private **/
		public function update() : void 
		{
			if (!Input.toggledButton("zoomButton"))
			{
				if (_zoom > Input.scroll * 0.1 && Input.scroll > 0 || _zoom < 20 + Input.scroll * 0.1 && Input.scroll < 0)
				{
					_zoom -= Input.scroll * 0.06;
					TweenMax.to(world.cam.transform, 0.3, { scale:_zoom } );
				}
			}
		}
		public function zoom(amount : Number) : void
		{
			_zoom = amount;
			TweenMax.to(world.cam.transform, 0.3, { scale:_zoom } );
		}
		
	}
	
}