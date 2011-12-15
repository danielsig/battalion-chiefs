package com.battalion.flashpoint.comp.tools 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.Input;
	import flash.ui.Keyboard;
	
	/**
	 * Add this component to anything and then use the up arrow key to speed up time, and down arrow key to slow down time.
	 * @author Battalion Chiefs
	 */
	public class HzController extends Component implements IExclusiveComponent
	{
		public var lowerLimit : Number = 4;
		public var upperLimit : Number = 60;
		
		/** @private **/
		public function awake() : void 
		{
			Input.assignButton("hzDown", Keyboard.NUMPAD_SUBTRACT);
			Input.assignButton("hzUp", Keyboard.NUMPAD_ADD);
		}
		
		/** @private **/
		public function fixedUpdate() : void 
		{
			CONFIG::debug
			{
				if (lowerLimit <= 0) throw new Error("lowerLimit must be greater than 0");
				if (upperLimit <= lowerLimit) throw new Error("upperLimit must be greater than lowerLimit");
			}
			
			if (Input.pressButton("hzDown") && FlashPoint.fixedFPS >= lowerLimit)
			{
				FlashPoint.fixedFPS /= 1.5;
			}
			else if (Input.pressButton("hzUp") && FlashPoint.fixedFPS <= upperLimit)
			{
				FlashPoint.fixedFPS *= 1.5;
			}
			
			if (FlashPoint.fixedFPS < lowerLimit) FlashPoint.fixedFPS = lowerLimit;
			if (FlashPoint.fixedFPS > upperLimit) FlashPoint.fixedFPS = upperLimit;
		}
		
	}
	
}