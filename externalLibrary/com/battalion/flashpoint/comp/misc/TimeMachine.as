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
		public var lowerLimit : Number = 0.06;
		public var upperLimit : Number = 1;
		
		/** @private **/
		public function awake() : void 
		{
			Input.assignButton("slowDown", Keyboard.PAGE_DOWN);
			Input.assignButton("speedUp", Keyboard.PAGE_UP);
		}
		
		/** @private **/
		public function fixedUpdate() : void 
		{
			CONFIG::debug
			{
				if (lowerLimit <= 0) throw new Error("lowerLimit must be greater than 0");
				if (upperLimit <= lowerLimit) throw new Error("upperLimit must be greater than lowerLimit");
			}
			
			if (Input.pressButton("slowDown") && FlashPoint.timeScale >= lowerLimit)
			{
				FlashPoint.timeScale /= 1.5;
			}
			else if (Input.pressButton("speedUp") && FlashPoint.timeScale <= upperLimit)
			{
				FlashPoint.timeScale *= 1.5;
			}
			
			if (FlashPoint.timeScale < lowerLimit) FlashPoint.timeScale = lowerLimit;
			if (FlashPoint.timeScale > upperLimit) FlashPoint.timeScale = upperLimit;
		}
		
	}
	
}