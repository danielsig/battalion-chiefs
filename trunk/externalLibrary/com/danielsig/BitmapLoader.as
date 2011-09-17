package com.danielsig
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	/**
	 * This class is useful for loading a vector of bitmaps with only one line of code.
	 * @author Daniel Sig
	 */
	public dynamic class BitmapLoader extends EventDispatcher
	{
		
		private var _start : uint;
		private var _end : uint;
		private var _amount : uint;
		private var _amountLoaded : uint = 0;
		private var _amountFailed : uint = 0;
		private var _failSafe : Boolean;
		private var _bitmaps : Vector.<BitmapData>;
		private var _loaders : Vector.<LoaderMax>;
		private var _urls : Vector.<String>;
		private var _otherFormats : Vector.<String>;
		private var _otherFormatChecks : Vector.<int>;
		private var _noError : Boolean;
		
		/**
		 * @example A spritesheet url is written in the folowing format:<listing version="3.0">"imageURL.imageFormat~spriteSheetIndex~alternativeURL"</listing>
		 * @example To get the second bitmap of a spritesheet at "imgages/mySpriteSheet.png" you should write:<listing version="3.0">"images/mySpriteSheet.png~2~"</listing>
		 * @example To make "images/fallback.png" an alternative to the bitmap mentioned above you should write:<listing version="3.0">"images/mySpriteSheet.png~2~images/fallback.png"</listing>
		 * @example To get a pizza, simply yell at the person to your left:<listing version="3.0">"GIVE ME A PIZZA!!!"</listing>But please check if someone is on your left first. We don't want a null reference exception now do we?

		 * 
		 * @see LoaderMax
		 * 
		 * @param	urls, urls of the bitmap images. Can be both individual image urls or spritesheet urls.
		 * @param	bitmaps, an empty BitmapData vector. This vector will be populated with the loaded bitmaps, in the same order as their urls.
		 * @param	failSafe, if you happen to encounter unexplainable errors at runtime, try setting this to true.
		 * @param	otherFormats, alternative image formats.
		 * @param	noError, true will make this loader dispatch Event.COMPLETE instead of IOErrorEvent.IO_ERROR on failure.
		 */
		public function BitmapLoader(urls : Vector.<String>, bitmaps : Vector.<BitmapData>, failSafe : Boolean = false, otherFormats : Vector.<String> = null, noError : Boolean = false)
		{
			_urls = urls;
			_bitmaps = bitmaps;
			_amount = _urls.length;
			_start = _bitmaps.length;
			_bitmaps.length += _amount;
			_end = _bitmaps.length;
			_failSafe = failSafe;
			_noError = noError;
			_otherFormats = otherFormats;
			
			if(_otherFormats)
			{
				_otherFormatChecks = new Vector.<int>(_urls.length);
				for(var i : uint = 0; i < _otherFormats.length; i++)
				{
					if(_otherFormats[i].length > 0)
					{
						if(_otherFormats[i].charAt(0) != ".")
						{
							_otherFormats[i] = "." + _otherFormats[i];
						}
					}
					else
					{
						_otherFormats.splice(i, 1);
						i--;
					}
				}
			}
		}
		public function start() : void
		{
			if(_failSafe)
			{
				try
				{
					load();
				}
				catch(someError : Error)
				{
					//MonsterDebugger.trace(this, someError.message);
				}
			}
			else
			{
				load();
			}
		}
		private function load() : void
		{
			_loaders = new Vector.<LoaderMax>(_amount);
			for(var i : uint = 0; i < _amount; i++)
			{
				
				if(_urls[i] != null && _urls[i] != "" && _loaders != null)
				{
					var imageUrl : URLRequest = new URLRequest(_urls[i]);
					var newLoader : LoaderMax = new LoaderMax();
					newLoader.addEventListener(Event.COMPLETE, bitmapLoaded);
					if(true)
					{
						newLoader.addEventListener(IOErrorEvent.IO_ERROR, bitmapFailedLoading);
					}
					_loaders[i] = newLoader;
					newLoader.load(imageUrl);
				}
				else
				{
					_amountFailed++;
					complete();
				}
			}
		}
		public function get bitmaps() : Vector.<BitmapData>
		{
			return _bitmaps;
		}
		public function get urls() : Vector.<String>
		{
			return _urls;
		}
		private function bitmapLoaded(e:Event) : void
		{
			wrapUp(e.target as LoaderMax);
		}
		private function bitmapFailedLoading(e:IOErrorEvent) : void
		{
			var index : int = _loaders.indexOf(e.target as LoaderMax);
			var tryAgain : Boolean = false;
			if(_otherFormats)
			{
				if(index >= 0)
				{
					if(_otherFormatChecks[index] < _otherFormats.length)
					{
						var url : String = LoaderMax.getBackupURL(_urls[index].slice(0, _urls[index].lastIndexOf(".")));
						url	+= _otherFormats[_otherFormatChecks[index]];
						var imageUrl : URLRequest = new URLRequest(url);
						_loaders[index].load(imageUrl);
						_otherFormatChecks[index]++;
						tryAgain = true;
					}
				}
			}
			if(!tryAgain)
			{
				wrapUp(e.target as LoaderMax);
			}
		}
		private function wrapUp(target : LoaderMax) : void
		{
			//trace(LoaderMax.amountStatus);
			//trace("=============\n" + LoaderMax.currentURLs + "\n-------------");
			progress();
			target.removeEventListener(Event.COMPLETE, bitmapLoaded);
			target.removeEventListener(IOErrorEvent.IO_ERROR, bitmapFailedLoading);
					
			if(target.content && target.bytesTotal != 0)
			{
				for(var i : int = 0; i < _amount; i++)
				{
					if(_loaders[i] == target)
					{
						if(_urls != null)
						{
							var url : String = _urls[i];
						}
						//MonsterDebugger.snapshot(this, target.content);
						_bitmaps[_start + i] = (target.content as Bitmap).bitmapData;
						break;
					}
				}
			}
			else
			{
				_amountFailed++;
			}
			complete();
		}
		private function complete() : void
		{
			_amountLoaded++;//Tracerracer.TraceLine("URLs: ", _urls, "\nComplete: ", _bitmaps, ", success: ", _amountLoaded, ", failure: ", _amountFailed, ", total: ", _amount)//TracerTracer.DisplayBitmap(_bitmaps);
			
			if(_amountLoaded == _amount)
			{
				/*MonsterDebugger.trace(this, "====== START =======");
				for(var i : int = 0; i < _urls.length; i++)
				{
					MonsterDebugger.trace(this, _urls[i]);
					MonsterDebugger.snapshot(this, new Bitmap(_bitmaps[i]) as DisplayObject);
				}
				MonsterDebugger.trace(this, "====== END =======");*/
				_loaders = null;
				//_bitmaps = null;
				
				//_urls = null;
				
				if(_amountFailed == _amount && !_noError)
				{
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				}
				else
				{
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		private function progress() : void
		{
			var bytesTotal : uint = 0;
			var bytesLoaded : uint = 0;
			for(var i : int = 0; i < _amount; i++)
			{
				if(_loaders[i] != null)
				{
					bytesTotal += _loaders[i].bytesTotal;
					bytesLoaded += _loaders[i].bytesLoaded;
				}
			}
			if(bytesTotal > 0)
			{
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
			}
		}
		private function getLoaderIndex(loader : LoaderMax) : int
		{
			for(var i : int = 0; i < _amount; i++)
			{
				if(_loaders[i] == loader)
				{
					return i;
				}
			}
			return -1;
		}
		public static function toRefNumber(number:uint) : String
		{
			if(number > 99) return String(number);
			if(number > 9) return "0" + String(number);
			return "00" + String(number);
		}
	}
}