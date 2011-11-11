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
		
		public static var timeMachineKey : * = "e";
		
		public var lowerLimit : Number = 0.06;
		public var upperLimit : Number = 1;
		public var step : Number = 0.05;
		
		/** @private **/
		public function awake() : void 
		{
			Input.assignButton("timeButton", timeMachineKey);
		}
		/** @private **/
		public function fixedUpdate() : void 
		{
			CONFIG::debug
			{
				if (step <= 0) throw new Error("step must be greater than 0");
				if (lowerLimit <= step) throw new Error("lowerLimit must be greater than step");
				if (upperLimit < lowerLimit) throw new Error("upperLimit must be greater than lowerLimit");
			}
			if (Input.toggledButton("timeButton"))
			{
				if (FlashPoint.timeScale > lowerLimit && Input.scroll < 0 || FlashPoint.timeScale < upperLimit && Input.scroll > 0)
				{
					FlashPoint.timeScale += Input.scroll * step;
				}
				if (FlashPoint.timeScale < lowerLimit) FlashPoint.timeScale = lowerLimit + step * 0.1;
				if (FlashPoint.timeScale > upperLimit) FlashPoint.timeScale = upperLimit - step * 0.1;
			}
		}
		
	}
	
}