package com.battalion.flashpoint.core 
{
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	import com.aw.utils.AccurateTimer;
	import com.aw.events.AccurateTimerEvent;
	import com.battalion.audio.AudioPlayer;
	import com.battalion.Input;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import flash.geom.Rectangle;
	
	
	/**
	 * This class is the core of the FlashPoint Engine.
	 * To Initialize it, call the <code>init</code> method and pass the stage to it as a parameter.
	 * @author Battalion Chiefs
	 */
	public final class FlashPoint 
	{
		/**
		 * Setting the timeScale will take effect on the next fixed update.
		 */
		public static var timeScale : Number = 1;
		/**
		 * Setting the fixedInterval will take effect on the next fixed update.
		 * This interval is the amount of milliseconds between FixedUpdate() calls on Components.
		 */
		public static var fixedInterval : Number = 20;
		/**
		 * A ratio between 0 and 1 determining how much the current <code>update</code>
		 * frame is between the last <code>fixedUpdate</code> frame and the next estimated <code>fixedUpdate</code> frame.
		 * <p>
		 * consider the folowing graphical explanation:
		 * </p>
<p style="font-family:courier;font-size:12px">
fixedInterval...|-- 0.0 --|-- 0.2 --|-- 0.4 --|-- 0.6 --|-- 0.8 --|-- 0.0 --|-- 0.2 --|...<br/>
fixedUpdate.....|--- x ---|---------|---------|---------|---------|--- x ---|---------|...<br/>
update..........|--- x ---|--- x ---|--- x ---|--- x ---|--- x ---|--- x ---|--- x ---|...
</p>
		 * @warning For performance reasons, this property is not a getter function but a public varible,
		 * If gain nothing but bad luck from assigning a value to this.
		 */
		public static var frameInterpolationRatio : Number = 0;
		
		private static var _timer : AccurateTimer = new AccurateTimer(fixedInterval / timeScale);
		private static var _prevTime : Number = new Date().time;
		private static var _stage : Stage;
		
		/**
		 * Use this to initialize the FlashPoint engine.
		 * @param	stage, the Stage object.
		 * @param	physicsBounds, omit this to exclude physics.
		 */
		public static function init(stage : Stage, physicsBounds : Rectangle = null) : void
		{
			if (physicsBounds)
			{
				Physics.init(physicsBounds);
				
				var debugSprite : Sprite = new Sprite();
				debugSprite.x = 400;
				debugSprite.y = 225;
				stage.addChild(debugSprite);
				
				CONFIG::debug
				{
					var dbgDraw : b2DebugDraw = new b2DebugDraw();
					dbgDraw.m_sprite = debugSprite;
					dbgDraw.m_drawScale = Physics._pixelsPerMeter;
					dbgDraw.m_fillAlpha = 0.4;
					dbgDraw.m_lineThickness = 1.0;
					dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;
					Physics._physicsWorld.SetDebugDraw(dbgDraw);
				}
				
			}
			
			GameObject.WORLD = new GameObject("WORLD");
			GameObject.WORLD._parent = GameObject.WORLD;
			CONFIG::release
			{
				GameObject.world = GameObject.WORLD;
				Component.world = GameObject.WORLD;
			}
			_timer.addEventListener(AccurateTimerEvent.TIMER, fixedUpdate);
			Input.init(stage, _timer, AccurateTimerEvent.TIMER);
			_timer.start();
			
			stage.addEventListener(Event.ENTER_FRAME, update);
			_stage = stage;
		}
		
		private static function update(event : Event = null) : void
		{
			//trace("update:" + frameInterpolationRatio);
			if (frameInterpolationRatio > 1) frameInterpolationRatio = 1;
			
			GameObject.WORLD.update();
			Transform.flushGlobal();
			var now : Number = new Date().time;
			frameInterpolationRatio = ((now - _prevTime) * timeScale / fixedInterval);
			if (frameInterpolationRatio > 1) frameInterpolationRatio = 1;
		}
		private static function fixedUpdate(event : Event = null) : void
		{
			_prevTime = new Date().time;
			frameInterpolationRatio = 0;
			
			var interval : Number = fixedInterval / timeScale;
			Physics.step(interval * 0.001 * timeScale);
			
			AudioPlayer.globalTimeScale = timeScale;
			GameObject.WORLD.fixedUpdate();
			
			if (interval != _timer.delay)
			{
				_timer.delay = fixedInterval / timeScale;
				_timer.start();
			}
		}
		
	}

}