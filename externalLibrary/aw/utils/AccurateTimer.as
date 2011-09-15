package aw.utils{
	import aw.events.AccurateTimerEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * 
	 * @author Galaburda Oleg http://actualwave.com
	 * 
	 */
	public class AccurateTimer extends Timer{
		protected var _delay:Number = 0;
		protected var _paused:Boolean;
		private var _startTime:Number = 0;
		private var _position:Number = 0;
		private var _missedIterations:uint = 0;
		private var _currentlyMissedIterations:uint = 0;
		private var _lastUsedDelay:Number = 0;
		private var _willRestartByTimer:Boolean;
		public function AccurateTimer(delay:Number, repeatCount:int=0):void{
			super(delay, repeatCount);
			addEventListener(TimerEvent.TIMER, timerHandler, false, int.MAX_VALUE);
			addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler, false, int.MAX_VALUE);
			_delay = delay;
		}
		override public function get delay():Number{
			return this._delay;
		}
		override public function set delay(value:Number):void{
			this._delay = value;
		}
		public function get missedIterations():uint{
			return this._missedIterations;
		}
		public function get position():Number{
			if(this._paused) return this._position;
			else{
				return this.running ? getTimer()-this._startTime : 0;
			}
			
		}
		public function set position(value:Number):void{
			if(this._paused) this._position = value;
			else{
				if(this.running){
					super.stop();
					this._startTime = getTimer()-value;
					super.delay = this._lastUsedDelay-value;
					super.start();
				}
			}
		}
		override public function start():void{
			this._currentlyMissedIterations = 0;
			if(this._willRestartByTimer){
				var difference:Number = getTimer()-this._startTime-this._lastUsedDelay;
				if(difference>this._delay){
					this._currentlyMissedIterations = difference/this._delay;
					difference = difference%this._delay;
					this._lastUsedDelay = this._delay-difference;
				}else{
					this._lastUsedDelay = this._delay-difference;
				}
				super.delay = this._lastUsedDelay;
			}else{
				this._missedIterations = 0;
				this._currentlyMissedIterations = 0;
				this._lastUsedDelay = this._delay;
				super.delay = this._delay;
			}
			this._missedIterations += this._currentlyMissedIterations;
			this._willRestartByTimer = false;
			this._startTime = getTimer();
			super.start();
		}
		protected function timerHandler(event:TimerEvent):void{
			if(event is AccurateTimerEvent) return;
			event.stopImmediatePropagation();
			super.delay = this._delay;
			this._willRestartByTimer = true;
			this.dispatchEvent(new AccurateTimerEvent(event.type, event.bubbles, event.cancelable, this._currentlyMissedIterations));
		}
		protected function timerCompleteHandler(event:TimerEvent):void{
			if(event is AccurateTimerEvent) return;
			event.stopImmediatePropagation();
			this.dispatchEvent(new AccurateTimerEvent(event.type, event.bubbles, event.cancelable, this._missedIterations));
		}
		public function resume():void{
			if(this._paused){
				this._lastUsedDelay = this._delay;
				super.delay = this._delay-this._position;
				this._startTime = getTimer()-this._position;
				this._paused = false;
				this._position = 0;
				super.start();
			}else this.start();
		}
		public function pause():void{
			this._paused = true;
			this._position = getTimer()-this._startTime;
			super.stop();
		}
		override public function stop():void{
			this._paused = false;
			this._position = 0;
			if(!this._willRestartByTimer){
				this._startTime = 0;
			}
			super.stop();
		}
		public function get paused():Boolean{
			return this._paused;
		}
	}
}