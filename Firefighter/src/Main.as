package 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.misc.*;
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

		private function init(e : Event = null) : void 
		{
			stage.quality = "low";
			removeEventListener(Event.ADDED_TO_STAGE, init);
			FlashPoint.fixedFPS = 30;
			FlashPoint.timeScale = 1;
			FlashPoint.init(stage);
			GameObject.world.addComponent(GameCore);
			GameObject.world.addComponent(PhysicsDebugger);
			addChild(new com.battalion.flashpoint.display.View(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight)));
			GameObject.world.physicsDebugger.debugSprite = addChild(new Sprite()) as Sprite;
		}
		public var val : Number = 1;
		public var obj : GameObject;
	}
}