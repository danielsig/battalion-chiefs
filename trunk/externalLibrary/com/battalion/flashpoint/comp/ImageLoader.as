package com.battalion.flashpoint.comp 
{
	
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	
	/**
	 * @private
	 * @author Battalion Chiefs
	 */
	internal final class ImageLoader
	{
		public var name : String;
		private var subscribers : Vector.<Renderer> = new Vector.<Renderer>();
		public function onNamedBitmapLoaded(e : Event) : void
		{
			e.target.removeEventListener(Event.COMPLETE, onNamedBitmapLoaded);
			Renderer._bitmaps[name] = (e.target.content as Bitmap).bitmapData;
			for each(var subscriber : Renderer in subscribers)
			{
				subscriber.setBitmapByName(name);
			}
			subscribers = null;
		}
		public function subscribe(renderer : Renderer) : void
		{
			subscribers.push(renderer);
		}
	}

}