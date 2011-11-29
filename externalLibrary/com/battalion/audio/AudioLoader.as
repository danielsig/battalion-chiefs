package com.battalion.audio
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	/**
	 * A class for loading audio, caching and partioning.
	 * Asssign the AudioData object loaded by this loader to an AudioPlayer object to play the audio.
	 * 
	 * @see AudioData
	 * @see AudioPlayer
	 * 
	 * @author Battalion Chiefs
	 */
	public final class AudioLoader 
	{
		
		private static var _cache : Object = { };//contains AudioData objects
		
		private var _sound : Sound;
		private var _bytes : ByteArray;
		private var _originalData : AudioData;
		private var _data : AudioData;
		
		/**
		 * The AudioData loaded by this AudioLoader. The AudioData is available immediately after instantiating the AudioLoader object.
		 * The sound data will be then loaded into the AudioData object on the fly (streaming).
		 */
		public function get audioData() : AudioData
		{
			return _data;
		}
		/**
		 * Load an AudioData object
		 * @param	url, the url of the audio file
		 * @param	startInMilliseconds, the millisecond in the file where the resulting AudioData will start
		 * @param	endInMilliseconds, the millisecond in the file where the resulting AudioData will end
		 */
		public static function load(url : String, startInMilliseconds : uint, endInMilliseconds : uint) : AudioLoader
		{
			return new AudioLoader(url + "~" + startInMilliseconds + "-" + endInMilliseconds + "~");
		}
		
		/**
		 * Loads an AudioData from an url.
		 * You can specify a range inside the audio file, that the
		 * AudioData should span using the folowing url syntax:
			 * "myMP3file.mp3~start-end~"
		 * Where the start is an integer reprisenting the beginning
		 * of the AudioData to load in milliseconds, and the end is
		 * an integer reprisenting the end of the AudioData to load
		 * in milliseconds.
		 * Or you can just use the static method <code>Load()</code>
		 * 
		 * @see #load()
		 * 
		 * @param	url, the url of the audio file
		 */
		public function AudioLoader(url : String)
		{
			//identifying the range
			var tildeIndex2 : int = url.lastIndexOf("~");
			var tildeIndex1 : int = url.lastIndexOf("~", tildeIndex2 - 1);
			if (tildeIndex1 > -1)
			{
				var range : String = url.slice(tildeIndex1+1, tildeIndex2);
				var delimIndex : int = range.indexOf("-");
				var start : Number = Number(range.slice(0, delimIndex)) / 2;
				var end : Number = Number(range.slice(delimIndex + 1)) / 2;
				url = url.slice(0, tildeIndex1);
			}
			else
			{
				start = 0;
				end = Number.MAX_VALUE;
			}
			
			//cheching for cache
			var cachedURL : String = "_" + url.replace(/[^a-zA-Z0-9_]/g, "");
			if (_cache.hasOwnProperty(cachedURL))
			{
				//It's cached
				if (start != 0 || end != Number.MAX_VALUE)
				{
					_data = new AudioData(_cache[cachedURL], start, end);
				}
				else
				{
					_data = _cache[cachedURL];
				}
			}
			else
			{
				//It's not cached
				_sound = new Sound(new URLRequest(url));
				_sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
				_sound.addEventListener(Event.COMPLETE, onDone);
				
				_originalData = _cache[cachedURL] = new AudioData(null);
				_originalData._id3 = _sound.id3;
				_originalData._length = 0;
				_originalData._bytes = _bytes = new ByteArray();
				
				if (start != 0 || end != Number.MAX_VALUE)
				{
					_data = new AudioData(_originalData, start, end);
					_data._length = 0;
				}
				else
				{
					_data = _originalData;
				}
			}
		}
		private function onProgress(e : ProgressEvent) : void
		{
			_sound.extract(_bytes, Number.MAX_VALUE);
			_data._id3 = _sound.id3;
			_originalData._id3 = _sound.id3;
			_originalData._length = _data._length = _sound.length;
		}
		private function onDone(e : Event) : void
		{
			_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_sound.removeEventListener(Event.COMPLETE, onDone);
			_sound = null;
			_bytes = null;
			_originalData = null;
		}
	}

}