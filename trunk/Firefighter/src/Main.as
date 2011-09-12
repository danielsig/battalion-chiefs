package 
{
	import com.battalion.flashpoint.core.*;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
    import flash.utils.*;
	import comp.*;

	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	[Frame(factoryClass = "Preloader")]
	public class Main extends Sprite 
	{

		public function Main()
		{
			MonsterDebugger.initialize(this);
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			FlashPoint.fixedInterval = 31.25;
			stage.addEventListener(Event.ENTER_FRAME, FlashPoint.updateHandler);
			GameObject.world.addComponent(GameCore);
		}
		public var val : Number = 1;
		public var obj : GameObject;
	}
}