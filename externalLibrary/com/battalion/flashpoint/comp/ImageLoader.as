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
		public function onNamedBitmapLoaded(e : Event = null) : void
		{
			if (e)
			{
				e.target.removeEventListener(Event.COMPLETE, onNamedBitmapLoaded);
				Renderer._bitmaps[name] = (e.target.content as Bitmap).bitmapData;
			}
			
			if (Renderer._filterQueue[name])
			{
				for each(var obj : Object in Renderer._filterQueue[name])
				{
					Renderer.filter(name, obj.t, obj.r);
				}
				delete Renderer._filterQueue[name];
			}
			if (Renderer._splitVerticalQueue[name])
			{
				for each(obj in Renderer._splitVerticalQueue[name])
				{
					Renderer.splitVertical(name, obj.d1, obj.d2, obj.c);
				}
				delete Renderer._splitVerticalQueue[name];
			}
			if (Renderer._splitHorizontalQueue[name])
			{
				for each(obj in Renderer._splitHorizontalQueue[name])
				{
					Renderer.splitHorizontal(name, obj.d1, obj.d2, obj.c);
				}
				delete Renderer._splitHorizontalQueue[name];
			}
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