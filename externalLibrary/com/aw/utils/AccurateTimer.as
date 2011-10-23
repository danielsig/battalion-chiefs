package com.aw.utils
{
	import com.aw.events.AccurateTimerEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * 
	 * @author Galaburda Oleg http://actualwave.com
	 * @author DanielSig
	 * 
	 */
	public class AccurateTimer extends Timer
	{
		
		protected var _delay : Number = 0;
		protected var _paused : Boolean;
		private var _startTime : Number = 0;
		private var _position : Number = 0;
		private var _missedIterations : uint = 0;
		private var _currentlyMissedIterations : uint = 0;
		private var _lastUsedDelay : Number = 0;
		private var _willRestartByTimer : Boolean;
		
		public function AccurateTimer(delay : Number, repeatCount : int = 0) : void
		{
			super(delay, repeatCount);
			addEventListener(TimerEvent.TIMER, timerHandler, false, int.MAX_VALUE);
			addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler, false, int.MAX_VALUE);
			_delay = delay;
		}
		/**
		 * The current delay
		 */
		public function get currentDelay() : Number
		{
			return super.delay;
		}
		override public function get delay() : Number
		{
			return _delay;
		}
		override public function set delay(value : Number) : void
		{
			_delay = value;
		}
		public function get missedIterations() : uint
		{
			return _missedIterations;
		}
		public function get position() : Number
		{
			if(_paused) return _position;
			else
			{
				return running ? getTimer() - _startTime : 0;
			}
			
		}
		public function set position(value : Number) : void
		{
			if(_paused) _position = value;
			else
			{
				if (running)
				{
					super.stop();
					_startTime = getTimer() - value;
					super.delay = _lastUsedDelay - value;
					super.start();
				}
			}
		}
		override public function start() : void
		{
			_currentlyMissedIterations = 0;
			if (_willRestartByTimer)
			{
				var difference : Number = getTimer() - _startTime - _lastUsedDelay;
				if (difference > _delay)
				{
					_currentlyMissedIterations = difference / _delay;
					difference = difference % _delay;
					_lastUsedDelay = _delay - difference;
				}
				else
				{
					_lastUsedDelay = _delay - difference;
				}
				super.delay = _lastUsedDelay;
			}
			else
			{
				_missedIterations = 0;
				_currentlyMissedIterations = 0;
				super.delay = _lastUsedDelay = _delay;
			}
			_missedIterations += _currentlyMissedIterations;
			_willRestartByTimer = false;
			_startTime = getTimer();
			super.start();
		}
		protected function timerHandler(event : TimerEvent) : void
		{
			if(event is AccurateTimerEvent) return;
			event.stopImmediatePropagation();
			dispatchEvent(new AccurateTimerEvent(event.type, event.bubbles, event.cancelable, _currentlyMissedIterations));
			super.delay = _delay;
			_willRestartByTimer = true;
		}
		protected function timerCompleteHandler(event : TimerEvent) : void
		{
			if(event is AccurateTimerEvent) return;
			event.stopImmediatePropagation();
			dispatchEvent(new AccurateTimerEvent(event.type, event.bubbles, event.cancelable, _missedIterations));
		}
		public function resume() : void
		{
			if (_paused)
			{
				_lastUsedDelay = _delay;
				super.delay = _delay - _position;
				_startTime = getTimer() - _position;
				_paused = false;
				_position = 0;
				super.start();
			}
			else this.start();
		}
		public function pause() : void
		{
			_paused = true;
			_position = getTimer() - _startTime;
			super.stop();
		}
		override public function stop() : void
		{
			_paused = false;
			_position = 0;
			if (!_willRestartByTimer)
			{
				_startTime = 0;
			}
			super.stop();
		}
		public function get paused() : Boolean
		{
			return _paused;
		}
	}
}