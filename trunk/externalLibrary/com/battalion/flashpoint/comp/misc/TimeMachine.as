package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.Input;
	import flash.ui.Keyboard;
	
	/**
	 * Add this component to anything and then use the up arrow key to speed up time, and down arrow key to slow down time.
	 * @author Battalion Chiefs
	 */
	public class TimeMachine extends Component implements IExclusiveComponent
	{
		/** @private **/
		public function start() : void 
		{
			Input.assignButton("slower", Keyboard.DOWN);
			Input.assignButton("faster", Keyboard.UP);
		}
		/** @private **/
		public function fixedUpdate() : void 
		{
			if (FlashPoint.timeScale > 0.08 && Input.pressButton("slower"))
			{
				FlashPoint.timeScale -= 0.05;
			}
			if (FlashPoint.timeScale < 10 && Input.pressButton("faster"))
			{
				FlashPoint.timeScale += 0.1;
			}
		}
		
	}
	
}