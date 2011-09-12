package com.battalion.flashpoint.core 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class FlashPoint 
	{
		
		public static var timeScale : Number = 1;
		public static var fixedInterval : Number = 20;
		
		private static var _timer : Timer = new Timer(fixedInterval / timeScale);
		
		/**
		 * just think of it as a funtion and add it as an even listener to the ENTER_FRAME event of the stage. e.g
		 * 	stage.addEventListener(Event.ENTER_FRAME, FlashPoint.updateHandler);
		 */
		public static function get updateHandler() : Function
		{
			GameObject.WORLD = new GameObject("WORLD");
			GameObject.WORLD._parent = GameObject.WORLD;
			CONFIG::release
			{
				GameObject.world = GameObject.WORLD;
			}
			_timer.addEventListener(TimerEvent.TIMER, fixedUpdate);
			_timer.start();
			return update;// hehe the ultimate power of a black box :P
		}
		private static function update(event : Event = null) : void
		{
			GameObject.WORLD.update();
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