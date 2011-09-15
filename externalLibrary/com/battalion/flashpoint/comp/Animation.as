package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import com.danielsig.BitmapLoader;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class Animation extends Renderer 
	{
		
		private var _p : int = 0;
		private var _playing : Boolean = true;
		private var _next : Vector.<int>;
		private var _frames : Vector.<BitmapData>;
		private var _urls : Vector.<String>;
		private var _loader : BitmapLoader;
		
		public function get urls() : Vector.<String>
		{
			return _urls;
		}
		public function setFrameURLs(...newURLs) : void
		{
			//this method is a lil complicated, understand at your own risk.
			var index : int = 0;
			_urls = new Vector.<String>(newURLs.length);
			_next = new Vector.<int>(newURLs.length);
			_frames = new Vector.<BitmapData>();
			for each(var url : String in newURLs)
			{
				var tildeIndex2 : int = url.lastIndexOf("~");
				var tildeIndex1 : int = url.lastIndexOf("~", tildeIndex2 - 1);
				if (tildeIndex1 > -1)
				{
					tildeIndex1++;
					var spriteIndexes : String = url.slice(tildeIndex1, tildeIndex2);
					var delimIndex : int = spriteIndexes.indexOf("-");
					var start : int = int(spriteIndexes.slice(0, delimIndex));
					var end : int = int(spriteIndexes.slice(delimIndex + 1));
					var rawURL : String = url.slice(0, tildeIndex1);
					if (end >= start)//e.g. 0-9, 2-2, 6-11
					{
						_urls.length += end - start;//adds one less to the length than number of sprites added.
						while (start <= end)
						{
							_next[index] = index + 1;
							_urls[index++] = rawURL + start++ + "~";
						}
					}
					else//e.g. 9-0, 11-6
					{
						_urls.length += start - end;
						while (start >= end)
						{
							_next[index] = index + 1;
							_urls[index++] = rawURL + (start--) + "~";
						}
					}
				}
				else
				{
					_next[index] = index + 1;
					_urls[index++] = url;
				}
			}
			_next[index - 1] = 0;
			_loader = new BitmapLoader(_urls, _frames, CONFIG::debug, null, false);
			_loader.addEventListener(Event.COMPLETE, doneLoading);
			_loader.start();
		}
		public function doneLoading(e : Event) : void
		{
			_loader.removeEventListener(Event.COMPLETE, doneLoading);
			_loader = null;
		}
		public function fixedUpdate() : void
		{
			if (_playing)
			{
				bitmapData = _frames[_p = _next[_p]];
				updateBitmap = bitmapData != null;
			}
		}
		
		
		public function stop() : void
		{
			_playing = false;
		}
		public function gotoAndStop(frame : int) : void
		{
			CONFIG::debug
			{
				if (frame < 0 || frame > _next.length) throw new Error("frame " + frame + " is out of bounds [0-" + _next.length + "]");
			}
			_p = frame;
			_playing = false;
		}
		public function gotoAndPlay(frame : int) : void
		{
			CONFIG::debug
			{
				if (frame < 0 || frame > _next.length) throw new Error("frame " + frame + " is out of bounds [0-" + _next.length + "]");
			}
			_p = frame;
			_playing = true;
		}
		public function play() : void
		{
			_playing = true;
		}
		public function reverse() : void
		{
			var i : int = _next.length;
			while (i--)
			{
				_next[i] -= (_next[i] - i) * 2;
			}
			if (_next[_next.length - 1] >= _next.length)
			{
				_next[_next.length - 1] -= _next.length;
			}
			if (_next[0] < 0)
			{
				_next[0] += _next.length;
			}
		}
	}
	
}