package 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.display.View;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.TweenLite;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
			stage.quality = "low";
			removeEventListener(Event.ADDED_TO_STAGE, init);
			FlashPoint.fixedInterval = 30;
			FlashPoint.timeScale = 1;
			FlashPoint.init(stage, new Rectangle(-10000, -10000, 20000, 20000));
			GameObject.world.addComponent(GameCore);
			addChild(new com.battalion.flashpoint.display.View(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight)));
			
		}
		public var val : Number = 1;
		public var obj : GameObject;
	}
}