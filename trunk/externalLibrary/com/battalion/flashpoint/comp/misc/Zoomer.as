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
		
		private var _zoom : Number = 1;
		
		public function update() : void 
		{
			if (_zoom > Input.scroll * 0.1 && Input.scroll > 0 || _zoom < 10 + Input.scroll * 0.1 && Input.scroll < 0)
			{
				_zoom -= Input.scroll * 0.05;
				TweenMax.to(world.cam.transform, 0.3, { scale:_zoom } );
			}
		}
		public function zoom(amount : Number) : void
		{
			_zoom = amount;
			TweenMax.to(world.cam.transform, 0.3, { scale:_zoom } );
		}
		
	}
	
}