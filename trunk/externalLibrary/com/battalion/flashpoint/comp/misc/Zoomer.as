package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import flash.ui.Keyboard;
	import com.battalion.Input;
	import com.greensock.TweenMax;
	
	/**
	 * Add this Component to anything, then use the scroll wheel to zoom in and out. Works only with one camera.
	 * @author Battalion Chiefs
	 */
	public class Zoomer extends Component implements IExclusiveComponent
	{
		private var _zoom : Number = 1;
		
		public var lowerLimit : Number = 0.1;
		public var upperLimit : Number = 10;
		
		/** @private **/
		public function fixedUpdate() : void 
		{
			var scroll : int = Input.scroll;
			if (scroll)
			{
				CONFIG::debug
				{
					if (lowerLimit <= 0) throw new Error("lowerLimit must be greater than 0");
					if (upperLimit <= lowerLimit) throw new Error("upperLimit must be greater than lowerLimit");
				}
				while (scroll)
				{
					if (scroll < 0 && _zoom >= lowerLimit)
					{
						_zoom *= 1.1;
						scroll++;
					}
					else if (scroll > 0 && _zoom <= upperLimit)
					{
						_zoom /= 1.1;
						scroll--;
					}
				}
				if (_zoom < lowerLimit) _zoom = lowerLimit;
				if (_zoom > upperLimit) _zoom = upperLimit;
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