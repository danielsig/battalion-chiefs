package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.Input;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class TimeMachine extends Component implements IExclusiveComponent
	{
		
		public function start() : void 
		{
			Input.assignButton("slower", Keyboard.DOWN);
			Input.assignButton("faster", Keyboard.UP);
			Input.listButtons();
		}
		public function update() : void 
		{
			if (FlashPoint.timeScale > 0.1 && Input.holdButton("slower"))
			{
				FlashPoint.timeScale -= 0.1;
			}
			if (FlashPoint.timeScale < 4 && Input.holdButton("faster"))
			{
				FlashPoint.timeScale += 0.1;
			}
		}
		
	}
	
}