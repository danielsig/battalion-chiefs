package com.battalion.flashpoint.core 
{
	import com.aw.utils.AccurateTimer;
	import com.aw.events.AccurateTimerEvent;
	import com.battalion.audio.AudioPlayer;
	import com.battalion.Input;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	
	
	/**
	 * This class is the core of the FlashPoint Engine.
	 * To Initialize it, add the updateHandler as an event listener to the Event.ENTER_FRAME event of the stage.
	 * @author Battalion Chiefs
	 */
	public final class FlashPoint 
	{
		/**
		 * Setting the timeScale will take effect on the next fixed update.
		 */
		public static var timeScale : Number = 3;
		/**
		 * Setting the fixedInterval will take effect on the next fixed update.
		 * This interval is the amount of milliseconds between FixedUpdate() calls on Components.
		 */
		public static var fixedInterval : Number = 20;
		
		private static var _timer : AccurateTimer = new AccurateTimer(fixedInterval / timeScale);
		
		/**
		 * Use this to initialize the FlashPoint engine.
		 * @param	stage, the Stage object.
		 */
		public static function init(stage : Stage) : void
		{
			Input.init(stage);
			
			GameObject.WORLD = new GameObject("WORLD");
			GameObject.WORLD._parent = GameObject.WORLD;
			CONFIG::release
			{
				GameObject.world = GameObject.WORLD;
				Component.world = GameObject.WORLD;
			}
			_timer.addEventListener(AccurateTimerEvent.TIMER, fixedUpdate);
			_timer.start();
			
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private static function update(event : Event = null) : void
		{
			GameObject.WORLD.update();
			Transform.flushGlobal();
		}
		private static function fixedUpdate(event : Event = null) : void
		{
			AudioPlayer.globalTimeScale = timeScale;
			GameObject.WORLD.fixedUpdate();
			if (fixedInterval / timeScale != _timer.delay)
			{
				_timer.delay = fixedInterval / timeScale;
				_timer.start();
			}
		}
		
	}

}