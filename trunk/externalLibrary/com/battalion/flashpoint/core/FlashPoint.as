package com.battalion.flashpoint.core 
{
	import com.aw.utils.AccurateTimer;
	import com.aw.events.AccurateTimerEvent;
	import flash.events.Event;
	
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
		public static var timeScale : Number = 1;
		/**
		 * Setting the fixedInterval will take effect on the next fixed update.
		 * This interval is the amount of milliseconds between FixedUpdate() calls on Components.
		 */
		public static var fixedInterval : Number = 20;
		
		private static var _timer : AccurateTimer = new AccurateTimer(fixedInterval / timeScale);
		
		/**
		 * Add this as an event listener to the ENTER_FRAME event of the stage. e.g
		 * 	stage.addEventListener(Event.ENTER_FRAME, FlashPoint.updateHandler);
		 */
		public static function get updateHandler() : Function
		{
			GameObject.WORLD = new GameObject("WORLD");
			GameObject.WORLD._parent = GameObject.WORLD;
			CONFIG::release
			{
				GameObject.world = GameObject.WORLD;
				Component.world = GameObject.WORLD;
			}
			_timer.addEventListener(AccurateTimerEvent.TIMER, fixedUpdate);
			_timer.start();
			return update;// hehe the ultimate power of a black box :P
		}
		private static function update(event : Event = null) : void
		{
			GameObject.WORLD.update();
			Transform.flushGlobal();
		}
		private static function fixedUpdate(event : Event = null) : void
		{
			GameObject.WORLD.fixedUpdate();
			if (fixedInterval / timeScale != _timer.delay)
			{
				_timer.delay = fixedInterval / timeScale;
				_timer.start();
			}
		}
		
	}

}