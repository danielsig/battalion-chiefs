package comp.ui 
{
	/**
	 * @author Battalion Chiefs
	 */
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import comp.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.sampler.NewObjectSample;
	import flash.text.*;
	 
	public class MainMenu extends Component implements IExclusiveComponent
	{
		
		
		public function start() : void 
		{
			
		}
		
		private function displayActiveState(event:MouseEvent): void
		{
			event.currentTarget.getChildByName("over").alpha = 100;
		}
		
		private function displayInactiveState(event:MouseEvent):void
		{
			event.currentTarget.getChildByName("over").alpha = 50;
		}
		
		private function displayMessage(event:MouseEvent):void
		{
			trace(event.currentTarget);
		}
		
	}

}