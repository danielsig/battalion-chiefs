package com.battalion.flashpoint.core 
{
	import com.aw.utils.AccurateTimer;
	import com.aw.events.AccurateTimerEvent;
	import com.battalion.audio.AudioPlayer;
	import com.battalion.flashpoint.comp.misc.TimeMachine;
	import com.battalion.Input;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
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
		 * Setting the fixedFPS (fixed frames per second) will take effect on the next fixed update.
		 * This is the number of FixedUpdate() calls per second.
		 * This effects the <code>fixedInterval</code> property.
		 * @see fixedInterval
		 */
		public static function get fixedFPS() : Number
		{
			return 1000.0 / fixedInterval;
		}
		public static function set fixedFPS(value : Number) : void
		{
			fixedInterval = 1000.0 / value;
		}
		/**
		 * Setting the fixedInterval will take effect on the next fixed update.
		 * This interval is the amount of milliseconds between FixedUpdate() calls
		 * on Components with respect to timeScale.
		 * @see fixedFPS
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
		 * WARNING For performance reasons, this property is not a getter function but a public varible,
		 * If gain nothing but bad luck from assigning a value to this.
		 */
		public static var frameInterpolationRatio : Number = 0;
		
		
		/**
		 * Milliseconds since the last fixedUpdate.
		 * During a fixedUpdate frame, this is the milliseconds
		 * since the last fixedUpdate not the current one.
		 */
		public static var deltaTime : Number = 0;
		
		/**
		 * Milliseconds since FlashPoint initialized.
		 */
		public static var time : Number = 0;
		
		private static var _timer : AccurateTimer = new AccurateTimer(fixedInterval / timeScale);
		private static var _prevTime : Number = new Date().time;
		private static var _prevTime2 : Number = _prevTime;
		private static var _initTime : Number;
		private static var _dynamicInterval : Number = fixedInterval / timeScale;
		private static var _stage : Stage;
		
		/**
		 * Use this to initialize the FlashPoint engine.
		 * @param	stage, the Stage object.
		 * @param	physicsBounds, omit this to exclude physics.
		 */
		public static function init(stage : Stage) : void
		{
			_initTime =  new Date().time;
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
			if (frameInterpolationRatio > 1) frameInterpolationRatio = 1;
			var now : Number = new Date().time;
			deltaTime = now - _prevTime2;
			time = now - _initTime;
			
			GameObject.WORLD.update();
			Transform.flushGlobal();
			now = new Date().time;
			frameInterpolationRatio = (now - _prevTime) / _dynamicInterval;
			if (frameInterpolationRatio > 1) frameInterpolationRatio = 1;
			//trace(frameInterpolationRatio);
		}
		private static function fixedUpdate(event : Event = null) : void
		{
			//_dynamicInterval = new Date().time - _prevTime;
			//frameInterpolationRatio = 0;
			
			var interval : Number = fixedInterval / timeScale;
			Physics.step(interval * 0.001 * timeScale);
			
			var now : Number = new Date().time;
			deltaTime = now - _prevTime2;
			time = now - _initTime;
			_prevTime2 = now;
			
			AudioPlayer.globalTimeScale = timeScale;
			GameObject.WORLD.fixedUpdate();
			
			if (interval != _timer.delay)
			{
				_timer.delay = fixedInterval / timeScale;
				_timer.start();
			}
			_dynamicInterval = new Date().time - _prevTime;
			frameInterpolationRatio = 0;
			_prevTime = new Date().time;
			//trace("------------ " + _dynamicInterval + " / " + fixedInterval + " -------------");
		}
		
	}

}