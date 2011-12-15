package 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.flashpoint.comp.tools.Console;
	import com.battalion.flashpoint.comp.tools.PhysicsDebugger;
	import com.battalion.flashpoint.comp.TextRenderer;
	import com.battalion.flashpoint.display.ViewFlash11;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.TweenLite;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
    import flash.utils.*;
	import comp.*;
	
	CONFIG::flashPlayer11
	import starling.core.Starling;

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
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Console.mode = Console.MODE_NEVER;
			stage.tabChildren = false;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.quality = "low";
			FlashPoint.fixedFPS = 24;
			FlashPoint.timeScale = 1;
			FlashPoint.init(stage);
			GameObject.world.addComponent(GameCore);
			
			var viewPort : Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			CONFIG::flashPlayer10
			{
				addChild(new com.battalion.flashpoint.display.View(viewPort));
			}
			CONFIG::flashPlayer11
			{
				new com.battalion.flashpoint.display.ViewFlash11(viewPort);
			}
			//CONFIG::debug
			{
				GameObject.world.addComponent(PhysicsDebugger);
				GameObject.world.physicsDebugger.debugSprite = addChild(new Sprite()) as Sprite;
			}
			//stage.tabChildren = stage.tabEnabled = false;
			//stage.focus = this;
		}
		public var val : Number = 1;
		public var obj : GameObject;
	}
}