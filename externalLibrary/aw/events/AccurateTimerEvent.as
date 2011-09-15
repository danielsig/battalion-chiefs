package aw.events{
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	/**
	 * 
	 * @author Galaburda Oleg http://actualwave.com
	 * 
	 */
	public class AccurateTimerEvent extends TimerEvent{
		static public const TIMER:String = TimerEvent.TIMER;
		static public const TIMER_COMPLETE:String = TimerEvent.TIMER_COMPLETE;
		protected var _missedIterations:uint;
		public function AccurateTimerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, missedIterations:uint=0):void{
			super(type, bubbles, cancelable);
			_missedIterations = missedIterations;
		}
		public function get missedIterations():uint{
			return this._missedIterations;
		}
		override public function clone():Event{
			return new AccurateTimerEvent(this.type, this.bubbles, this.cancelable, this._missedIterations);
		}
	}
}