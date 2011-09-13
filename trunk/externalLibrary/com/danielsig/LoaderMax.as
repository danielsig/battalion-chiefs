package com.danielsig
{
	
	import com.danielsig.ArrayUtilPro;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	
	/**
	 * @author Daniel Sig
	 */
	public class LoaderMax extends EventDispatcher
	{
		public static function createSheetURL(sheetImageURL : String, spriteIndex : int, backupImageURL : String = "") : String
		{
			if(sheetImageURL == null || sheetImageURL == "" || spriteIndex < 0)
			{
				return backupImageURL;
			}
			return sheetImageURL + "~" + spriteIndex + "~" + backupImageURL;
		}
		public static function getSheetURL(url : String) : String
		{
			if(url != null)
			{
				var urls : Array = url.split(/~\d+~/);
				if(urls.length > 1)
				{
					return urls[0]
				}
			}
			return null;
		}
		public static function getSpriteIndex(url : String) : int
		{
			if(url != null)
			{
				var index : Array = url.match(/~\d+~/);
				if(index != null && index.length > 0)
				{
					url = index[0];
					return int(url.slice(1, url.length-1));
				}
			}
			return -1;
		}
		public static function getBackupURL(url : String) : String
		{
			if(url != null)
			{
				var urls : Array = url.split(/~\d+~/);
				url = urls[urls.length-1];
				return url == "" ? null : url;
			}
			return null;
		}
		public static function isSheet(url : String) : Boolean
		{
			return url.search(/~\d+~.*/) != -1;
		}
		public static function get amountTotal() : int
		{
			return _totalLoads;
		}
		public static function get amountLoading() : int
		{
			return _totalLoads - amountDone;
		}
		public static function get amountDone() : int
		{
			return _totalComplete + _totalFailed;
		}
		public static function get amountComplete() : int
		{
			return _totalComplete;
		}
		public static function get amountFailed() : int
		{
			return _totalFailed;
		}
		public static function get amountStatus() : String
		{
			return "amount loading: " + amountLoading
				 + "\namount done: " + amountDone
				 + "\namount complete: " + amountComplete
				 + "\namount failed: " + amountFailed
				 + "\ntotal amount: " + amountTotal;
		}
		public static function get currentURLs() : String
		{
			return ArrayUtilPro.getProperties(_currentLoaders, "url").join("\n");
		}
		public function load(request : URLRequest, context : LoaderContext = null, noError : Boolean = false) : void
		{
			_totalLoads++;
			_currentLoaders.push(this);
			
			_noError = noError;
			if(request == null || request.url == null || request.url == "")
			{
				dispatchError();
				return;
			}
			_context = context;
			_sheetIndex = -1;
			var url : String = request.url;
			var index : int = url.search(/~\d+~.*/);
			if(index != -1)
			{//this is a sprite sheet
				
				_index = getSpriteIndex(url);
				_backupURL = getBackupURL(url);
				request.url = getSheetURL(url);
				//_backupURL = "";
				//MonsterDebugger.trace(this, "loading sprite #" + _index + " from " + request.url);
				//MonsterDebugger.trace(this, "      but with " + _backupURL + " as backup.");
				
				_sheetIndex = ArrayUtilPro.matchString(request.url, _sheetURLs);
				if(_sheetIndex != -1)
				{//sheet has already begun loading or is loaded
					if(_sheetLoaders[_sheetIndex] == null)
					{//sheet has already been loaded
						//Tracer.TraceArgs("already loaded");
						if(!loadSprite())
						{//and it failed loading
							loadBackup();
						}
						else
						{//and it was a success
							dispatchSuccess();
						}
					}
					else
					{//sheet has begun loading
						//Tracer.TraceArgs("is already loading");
						_info = _sheetLoaders[_sheetIndex];
						addListeners();
					}
					return;
				}
				else
				{
					//sheet is not loaded
					//Tracer.TraceArgs("init loading...");
					_sheetIndex = _sheets.length;
					_sheets.length++;
					_sheetURLs.length++;
					_sheetURLs[_sheetIndex] = request.url;
				}
			}
			else
			{// this is not a sprite sheet
				_loadingBackup = true;
				request.url = getBackupURL(url);
			}
			//trace("url:      " + request.url + " index: " + _index);
			var loader : Loader = new Loader();
			_info = loader.contentLoaderInfo;
			if(_sheetIndex != -1)
			{
				_sheetLoaders[_sheetIndex] = _info;
			}
			//Tracer.TraceArgs("sheetIndex: " + _sheetIndex);
			addListeners();
			try
			{
				loader.load(request, _context);
			}
			catch(error : Error)
			{
				onFail(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
		}
		public function get content() : DisplayObject
		{
			return _content;
		}
		public function get bytesTotal() : int
		{
			return _info ? _info.bytesTotal : (_content == null ? 0 : 1);
		}
		public function get bytesLoaded() : int
		{
			return _info ? _info.bytesLoaded : (_content == null ? 0 : 1);
		}
		public function get url() : String
		{
			if(_loadingBackup)
			{
				return _backupURL;
			}
			return _sheetURLs[_sheetIndex] + "~" + _index + "~";
		}
		private var _index : int = -1;
		private var _sheetIndex : int = -1;
		private var _noError : Boolean = false;
		private var _content : DisplayObject = null;
		private var _context : LoaderContext = null;
		private var _backupURL : String = null;
		private var _loadingBackup : Boolean = false;
		private var _info : LoaderInfo;
		
		private static var _sheetURLs : Vector.<String> = new Vector.<String>();
		private static var _sheetLoaders : Vector.<LoaderInfo> = new Vector.<LoaderInfo>();
		private static var _sheets : Vector.<Vector.<BitmapData>> = new Vector.<Vector.<BitmapData>>();
		private static var _totalLoads : int = 0;
		private static var _totalComplete : int = 0;
		private static var _totalFailed : int = 0;
		private static var _currentLoaders : Vector.<LoaderMax> = new Vector.<LoaderMax>();
		
		private function onComplete(e : Event) : void
		{
			try
			{
				//Tracer.DisplayArgs(_info.content);
				if(!updateContent())
				{
					removeListeners();
					loadBackup();
				}
				else
				{
					removeListeners();
					dispatchSuccess();
				}
			}
			catch(loadError : Error)
			{
				dispatchError();
			}
		}
		private function onFail(e : IOErrorEvent) : void
		{
			//Tracer.DisplayArgs(_info.content);
			if(!_loadingBackup)
			{
				removeSheet();
			}
			if(_backupURL != null && !_loadingBackup)
			{
				removeListeners();
				loadBackup();
			}
			else
			{
				updateContent();
				removeListeners();
				dispatchError();
			}
		}
		private function dispatchError() : void
		{
			_totalFailed++;
			_currentLoaders.splice(_currentLoaders.indexOf(this), 1);
			if(_noError)
			{
				dispatchSuccess();
			}
			else
			{
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
		}
		private function dispatchSuccess() : void
		{
			_totalComplete++;
			_currentLoaders.splice(_currentLoaders.indexOf(this), 1);
			//Tracer.Trace("Done: " + _backupURL);
			//Tracer.DisplayArgs(_content);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function addListeners() : void
		{
			_info.addEventListener(Event.COMPLETE, onComplete);
			_info.addEventListener(IOErrorEvent.IO_ERROR, onFail);
			_info.addEventListener(IOErrorEvent.DISK_ERROR, onFail);
			_info.addEventListener(IOErrorEvent.NETWORK_ERROR, onFail);
			_info.addEventListener(IOErrorEvent.VERIFY_ERROR, onFail);
		}
		private function removeListeners() : void
		{
			_info.removeEventListener(Event.COMPLETE, onComplete);
			_info.removeEventListener(IOErrorEvent.IO_ERROR, onFail);
			_info.removeEventListener(IOErrorEvent.DISK_ERROR, onFail);
			_info.removeEventListener(IOErrorEvent.NETWORK_ERROR, onFail);
			_info.removeEventListener(IOErrorEvent.VERIFY_ERROR, onFail);
		}
		private function removeSheet() : void
		{
			if(_sheetIndex >= 0 && _sheetURLs != null && _sheetURLs.length > _sheetIndex)
			{
				if(_sheetLoaders[_sheetIndex] == _info)
				{
					_sheetLoaders[_sheetIndex] = null;
					_sheets[_sheetIndex] = null;
					//_sheetURLs.splice(_sheetIndex, 1);
					//_sheets.splice(_sheetIndex, 1);
					//_sheetLoaders.splice(_sheetIndex, 1);
				}
			}
		}
		private function updateContent() : Boolean
		{
			//Tracer.TraceLine(_sheetIndex, _info.content, _info.content is Bitmap, _sheetIndex != -1 ? _sheets[_sheetIndex] : null, "length: " + _sheets.length);
			if(_sheetIndex != -1 && _info.content != null && _info.content is Bitmap && !_loadingBackup)
			{
				//Tracer.TraceArgs("sheet before: " + _sheets[_sheetIndex], (_info.content as Bitmap).bitmapData);
				if(_sheets[_sheetIndex] == null)
				{
					_sheets[_sheetIndex] = SpriteSheet.decompose((_info.content as Bitmap).bitmapData);
					_sheetLoaders[_sheetIndex] = null;
					(_info.content as Bitmap).bitmapData.dispose();
					//Tracer.DisplayBitmap(_sheets[_sheetIndex]);
				}
				return loadSprite();
			}
			else
			{
				_content = _info.content;
			}
			return true;
		}
		private function loadBackup() : void
		{
			_loadingBackup = true;
			var loader : Loader = new Loader();
			_info = loader.contentLoaderInfo;
			addListeners();
			try
			{
				loader.load(new URLRequest(_backupURL), _context);
			}
			catch(error : Error)
			{
				onFail(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
		}
		private function loadSprite() : Boolean
		{
			if(_index < 0 || _sheetIndex < 0 || _sheetIndex >= _sheets.length || _sheets[_sheetIndex] == null || _index >= _sheets[_sheetIndex].length)
			{
				//Tracer.TraceLine("FALSE", _index, _sheetIndex, _sheets[_sheetIndex], _sheets[_sheetIndex].length);
				return false;
			}
			
			if(_sheets[_sheetIndex][_index] != null)
			{
				_content = new Bitmap(_sheets[_sheetIndex][_index]) as DisplayObject;
			}
			else
			{
				_content = null;
			}
			//Tracer.DisplayArgs(_content);
			return true;
		}
	}
}