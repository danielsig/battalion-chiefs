package com.battalion.flashpoint.core 
{
	import com.aw.utils.AccurateTimer;
	import com.aw.events.AccurateTimerEvent;
	import com.battalion.audio.AudioPlayer;
	import com.battalion.Input;
	import com.battalion.flashpoint.comp.tools.Console;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	CONFIG::flashPlayer11
	{
		import com.battalion.flashpoint.display.StageFlash11;
		import starling.core.Starling;
		import flash.display3D.Context3DRenderMode;
	}
	
	
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
		 * This value is the square root of the timeScale.
		 * WARNING For performance reasons, this property is not a getter function but a public varible,
		 * you gain nothing but bad luck from assigning a value to this.
		 */
		public static var timeScaleSqrt : Number = 1;
		/**
		 * Setting the fixedFPS (fixed frames per second) will take effect on the next fixed update.
		 * This is the number of FixedUpdate() calls per second.
		 * This effects the <code>fixedInterval</code> property.
		 * @see #fixedInterval
		 */
		public static function get fixedFPS() : Number
		{
			var val : Number = 1.0 / fixedInterval;
			var distFromRounded : Number = int(val + 0.5) - val;
			if (distFromRounded < 0.0000000001 && distFromRounded > -0.0000000001) return int(val + 0.5);
			return val;
		}
		public static function set fixedFPS(value : Number) : void
		{
			fixedInterval = 1.0 / value;
		}
		/**
		 * Setting the fixedInterval will take effect on the next fixed update.
		 * This interval is the amount of seconds between FixedUpdate() calls
		 * on Components ignoring timeScale, in other words, the
		 * fixedInterval will stay the same even if timeScale changes.
		 * @see #fixedFPS
		 */
		public static var fixedInterval : Number = 0.02;
		/**
		 * [Read Only] 
		 * A ratio between 0 and 1 determining how much the current <code>update</code>
		 * frame is between the last <code>fixedUpdate</code> frame and the next estimated <code>fixedUpdate</code> frame.
		 * <p>
		 * consider the folowing graphical explanation:
		 * </p>
<p style="font-family:courier;font-size:12px">
fixedInterval...|-- 0.0 --|-- 0.2 --|-- 0.4 --|-- 0.6 --|-- 0.8 --|-- 0.0 --|-- 0.2 --|...<pre>
</pre>fixedUpdate....|--- x ---|---------|---------|---------|----------|--- x ---|---------|...<pre>
</pre>update...........|--- x ---|--- x ---|--- x ----|--- x ---|--- x ---|--- x ----|--- x ---|...
</p>
		 * WARNING For performance reasons, this property is not a getter function but a public varible,
		 * you gain nothing but bad luck from assigning a value to this.
		 */
		public static var frameInterpolationRatio : Number = 0;
		
		/**
		 * [Read Only] Seconds since the last fixedUpdate ignoring timeScale
		 * (basicly the real-time seconds since last fixedUpdate).
		 * During a fixedUpdate, this is the real-time seconds
		 * since the previous fixedUpdate not the current one.
		 * @see #realDeltaTime
		 * @see #fixedDeltaTime
		 */
		public static var realFixedDeltaTime : Number = 0;
		/**
		 * [Read Only] Seconds since the last fixedUpdate relative to timeScale
		 * (basicly the in-game seconds since last fixedUpdate).
		 * During a fixedUpdate, this is the in-game seconds
		 * since the previous fixedUpdate not the current one.
		 * @see #deltaTime
		 * @see #realFixedDeltaTime
		 */
		public static var fixedDeltaTime : Number = 0;
		
		/**
		 * [Read Only] Seconds since the last update ignoring timeScale
		 * (basicly the real-time seconds since last update).
		 * @see #realFixedDeltaTime
		 * @see #deltaTime
		 */
		public static var realDeltaTime : Number = 0;
		/**
		 * [Read Only] Seconds since the last update relative to timeScale
		 * (basicly the in-game seconds since last update).
		 * @see #fixedDeltaTime
		 * @see #realDeltaTime
		 */
		public static var deltaTime : Number = 0;
		
		/**
		 * [Read Only] A number between 0 and 1 and it's is basicly
		 * the amount of time this update frame will probably take
		 * relative to the amount of time this fixed update frame
		 * will probably take. In other words, it's much like
		 * <code>deltatime</code> / (<code>fixedInterval</code> &#42; <code>timeScale</code>).
		 */
		public static var deltaRatio : Number = 0;
		
		/**
		 * [Read Only] Seconds since FlashPoint initialized.
		 */
		public static var time : Number = 0;
		
		private static var _timer : AccurateTimer = new AccurateTimer(1000 * fixedInterval / timeScale);
		private static var _prevTime : Number = new Date().time;
		private static var _prevTime2 : Number = _prevTime;
		private static var _prevUpdateTime : Number = _prevTime;
		private static var _initTime : Number;
		private static var _dynamicInterval : Number = 1000 * fixedInterval / timeScale;
		private static var _stage : Stage;
		private static var _prevTimeScale : Number = 1;
		
		private static var _deltaRatioSum : Number = 0;
		private static var _updatesPerFixedUpdates : Number = 0;
		private static var _deltaMultiplier : Number = 1;
		private static var _useDynamicInterval : Boolean = false;
		
		CONFIG::flashPlayer11
		{
			private static var _starling : Starling = null;
		}
		
		/**
		 * Use this to initialize the FlashPoint engine.
		 * @param	stage, the Stage object.
		 */
		public static function init(stage : Stage) : void
		{
			_initTime =  new Date().time;
			Physics.setHz(fixedFPS);
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
			
			CONFIG::flashPlayer11
			{
				_starling = new Starling(StageFlash11, stage);
				_starling.start();
			}
		}
		
		private static function update(event : Event = null) : void
		{
			if (timeScale == 1) timeScaleSqrt = 1;
			else if (timeScaleSqrt * timeScaleSqrt != timeScale) timeScaleSqrt = Math.sqrt(timeScale);
			if (frameInterpolationRatio > 1) frameInterpolationRatio = 1;
			var now : Number = new Date().time;
			
			//fixedDeltaTime
			realFixedDeltaTime = (now - _prevTime2) * 0.001;
			fixedDeltaTime = realFixedDeltaTime * timeScale;
			//time
			time = (now - _initTime) * 0.001;
			
			GameObject.updateAll();
			Transform.flushGlobal();
			
			//frameInterpolationRatio
			now = new Date().time;
			if (_useDynamicInterval) var estimatedInterval : Number = _dynamicInterval;
			else estimatedInterval = _timer.currentDelay * _deltaMultiplier;
			frameInterpolationRatio = (now - _prevTime) / estimatedInterval;
			if (frameInterpolationRatio > 1) frameInterpolationRatio = 1;
			
			//deltaTime
			realDeltaTime = (now - _prevUpdateTime) * 0.001;
			deltaTime = realDeltaTime * timeScale;
			_prevUpdateTime = now;
			//deltaRatio
			deltaRatio = realDeltaTime / estimatedInterval;
			if (deltaRatio > 1) deltaRatio = 1;
			_deltaRatioSum += deltaRatio;
			_updatesPerFixedUpdates++;
		}
		private static function fixedUpdate(event : Event = null) : void
		{
			var interval : Number = fixedInterval / timeScale;
			Physics.step(fixedInterval);
			
			var now : Number = new Date().time;
			realFixedDeltaTime = (now - _prevTime2) * 0.001;
			fixedDeltaTime = realFixedDeltaTime * timeScale;
			time = (now - _initTime) * 0.001;
			_prevTime2 = now;
			
			//AudioPlayer.globalTimeScale = timeScale;
			GameObject.fixedUpdateAll();
			
			_dynamicInterval = new Date().time - _prevTime;
			frameInterpolationRatio = 0;
			_prevTime = new Date().time;
			
			if (_updatesPerFixedUpdates > 0) _deltaMultiplier = 1 + (_deltaRatioSum / _updatesPerFixedUpdates)
			else _deltaMultiplier = 1;
			_deltaRatioSum = _updatesPerFixedUpdates = 0;
			_deltaMultiplier *= _timer.currentDelay / _dynamicInterval;
			_useDynamicInterval = (60 % (1.0 / fixedInterval)) < 0.001;

			if (interval != _timer.delay)
			{
				_timer.delay = 1000 * fixedInterval / timeScale;
				_timer.start();
				Physics.setHz(fixedFPS);
			}
		}
		
	}

}