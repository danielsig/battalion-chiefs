package com.battalion.flashpoint.comp 
{
	
	import com.danielsig.BitmapLoader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	
	/**
	 * @private
	 * @author Battalion Chiefs
	 */
	internal final class AnimationLoader
	{
		public var name : String;
		public var frames : Vector.<BitmapData>;
		public var frameMask : Vector.<Boolean>;
		public var prevQueueLength : uint = 0;
		public var loader : BitmapLoader;
		private function onProgress(e : ProgressEvent) : void
		{
			step();
		}
		private function onComplete(e : Event) : void
		{
			step();
			delete Animation._filterQueue[name];
			loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.removeEventListener(Event.COMPLETE, onComplete);
		}
		private function step() : void
		{
			var length : uint = frames.length;
			var queueLength : uint = Animation._filterQueue[name].length;
			var queue : Vector.<Object> = Animation._filterQueue[name];
			for (var i : uint = 0; i < length; i++)
			{
				if (!frameMask[i] && frames[i])
				{
					frameMask[i] = true;
					for each(var obj : Object in queue)
					{
						Animation.filterFrame(frames[i], obj.t, obj.r);
					}
				}
				else if (frames[i] && queueLength > prevQueueLength)
				{
					for (var j : uint = prevQueueLength; j < queueLength; j++ )
					{
						Animation.filterFrame(frames[i], queue[j].t, queue[j].r);
					}
				}
			}
			prevQueueLength = queueLength;
		}
		public function AnimationLoader(name : String, loader : BitmapLoader)
		{
			this.name = name;
			this.loader = loader;
			frames = loader.bitmaps;
			frameMask = new Vector.<Boolean>(frames.length);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(Event.COMPLETE, onComplete);
		}
	}

}