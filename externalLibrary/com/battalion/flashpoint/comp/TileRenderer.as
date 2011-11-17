package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.Physics;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.danielsig.LoaderMax;
	import com.danielsig.BitmapLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	CONFIG::flashPlayer10
	{
		import com.battalion.flashpoint.display.View;
	}
	CONFIG::flashPlayer11
	{
		import com.battalion.flashpoint.display.ViewFlash11;
	}
	
	/**
	 * Use this component in order to render tiles maps
	 * @author Battalion Chiefs
	 */
	public final class TileRenderer extends Component implements IExclusiveComponent 
	{
		
		public var offset : Matrix = null;
		public var tileMap : BitmapData;
		public var tileSet : Vector.<BitmapData>;
		
		/**
		 * A Boolean indicating if the TileMap and TileSet of this TileRenderer have been loaded
		 */
		public function get loaded() : Boolean { return _loaded > 1; }
		
		private var _loaded : uint = 0;
		
		private static var _mapLoaders : Dictionary = new Dictionary();
		private static var _setLoaders : Dictionary = new Dictionary();
		private static var _subscribers : Object = new Object();
		private static var _tilesetSubscribers : Object = new Object();
		private static var _maps : Object = new Object();
		private static var _sets : Object = new Object();
		
		private static var _layerMask : Array = null;
		private static var _collisionMap : TileRenderer = null;
		
		/**
		 * Call this method in order to load a tile map and use it multiple times in your game
		 * by simply giving it a name, and referencing that name.
		 * After you have called this method, it's safe to call the <code>setTileMapByName()</code> method on a TileRenderer instance.
		 * It will wait for the tile map and tile set to load and then display them as soon as they're both loaded.
		 * @see #setTileMapByName()
		 * @see #setTileSetByName()
		 * @see #loadSet()
		 * @param	mapName, the name that you will use for the tile map. If a tile map already has this name, it will be overridden.
		 * @param	url, the url of the tile map to load.
		 */
		public static function loadMap(mapName : String, url : String) : void
		{
			var loader : LoaderMax = new LoaderMax();
			loader.addEventListener(Event.COMPLETE, onMapLoaded);
			loader.load(new URLRequest(url), null, true);
			_maps[mapName] = loader;
			_mapLoaders[loader] = mapName;
		}
		public static function onMapLoaded(e:Event) : void
		{
			e.target.removeEventListener(Event.COMPLETE, onMapLoaded);
			var name : String = _mapLoaders[e.target];
			delete _mapLoaders[e.target];
			_maps[name] = ((e.target as LoaderMax).content as Bitmap).bitmapData;
			if (_subscribers[name])
			{
				for each(var tileRenderer : TileRenderer in _subscribers[name])
				{
					tileRenderer.tileMap = _maps[name];
					if (++tileRenderer._loaded > 1) tileRenderer.onComplete();
					
				}
				delete _subscribers[name];
			}
		}
		/**
		 * Call this method in order to load a tile set and use it multiple times in your game
		 * by simply giving it a name, and referencing that name.
		 * After you have called this method, it's safe to call the <code>setTileSetByName()</code> method on a TileRenderer instance.
		 * It will wait for the tile map and tile set to load and then display them as soon as they're both loaded.
		 * Can be both individual image urls and/or spritesheet urls. Can also read spritesheet ranges.
		 * </p>
		 * <strong>See also</strong>
<pre>   <a href="../../../danielsig/BitmapLoader.html">BitmapLoader</a>
   <a href="../../../danielsig/SpriteSheet.html">SpriteSheet</a></pre>
		 * @example A spritesheet url is written in the folowing format: <listing version="3.0">"imageURL.imageFormat~spriteSheetIndex~alternativeURL"</listing>
		 * @example To get the second bitmap of a sritesheet at "imgages/mySpriteSheet.png" you should write:<listing version="3.0">"images/mySpriteSheet.png~2~"</listing>
		 * @example A spritesheet url with a range is written in the folowing format: <listing version="3.0">"imageURL.imageFormat~fromIndex-toIndex~alternativeURL"</listing>
		 * @example To get the bitmaps of index 0, 1, 2, 3 and 4 of a sritesheet at "imgages/mySpriteSheet.png" you should write:<listing version="3.0">"images/mySpriteSheet.png~0-4~"</listing>
		 * 
		 * @example <strong>Hint:</strong> to get the tiles in a reverse order just swap the indexes.<listing version="3.0">"images/mySpriteSheet.png~4-0~"</listing>
		 * 
		 * @see #setTileMapByName()
		 * @see #setTileSetByName()
		 * @see #loadMap()
		 * 
		 * @param	setName, the name that you will use for the tile set. If a tile set already has this name, it will be overridden.
		 * @param	...tileURLs, a list of urls to load
		 */
		public static function loadSet(setName : String, ...tileURLs) : void
		{
			var index : int = 0;
			var urls : Vector.<String> = new Vector.<String>(tileURLs.length);
			var tiles : Vector.<BitmapData> = new Vector.<BitmapData>();
			for each(var url : String in tileURLs)
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
						urls.length += end - start;//adds one less to the length than number of sprites added.
						while (start <= end)
						{
							urls[index++] = rawURL + start++ + "~";
						}
					}
					else//e.g. 9-0, 11-6
					{
						urls.length += start - end;
						while (start >= end)
						{
							urls[index++] = rawURL + (start--) + "~";
						}
					}
				}
				else
				{
					urls[index++] = url;
				}
			}
			
			_sets[setName] = tiles;
			var loader : BitmapLoader = new BitmapLoader(urls, tiles, CONFIG::debug, null, true);
			_setLoaders[loader] = setName;
			_tilesetSubscribers[setName] = new Vector.<TileRenderer>();
			loader.addEventListener(Event.COMPLETE, onSetLoaded);
			loader.start();
		}
		private static function onSetLoaded(e:Event) : void
		{
			e.target.removeEventListener(Event.COMPLETE, onSetLoaded);
			var name : String = _setLoaders[e.target];
			delete _setLoaders[e.target];
			if (_tilesetSubscribers[name])
			{
				for each(var tileRenderer : TileRenderer in _tilesetSubscribers[name])
				{
					if (++tileRenderer._loaded > 1) tileRenderer.onComplete();
				}
				delete _tilesetSubscribers[name];
			}
		}
		
		public function setTileMapByName(name : String) : void
		{
			if (_maps[name] is BitmapData)
			{
				tileMap = _maps[name];
			}
			else
			{
				if (_loaded > 0) _loaded--;
				if (!_subscribers[name]) _subscribers[name] = new <TileRenderer>[this];
				else _subscribers[name].push(this);
			}
		}
		public function setTileSetByName(name : String) : void
		{
			CONFIG::debug
			{
				if (!_sets.hasOwnProperty(name)) throw new Error("The tile set you are trying to use has not been loaded.");
			}
			tileSet = _sets[name];
			if (_tilesetSubscribers[name])
			{
				if (_loaded > 0) _loaded--;
				_tilesetSubscribers[name].push(this);
			}
		}
		
		public function setOffset(x : Number, y : Number, scale : Number = 1) : void
		{
			offset = new Matrix(scale, 0, 0, scale, x, y);
		}
		
		public function setAsCollisionMap(offset : Point, ...layerMasks) : void
		{
			Physics.gridOffset = offset;
			this.offset = new Matrix(1, 0, 0, 1, offset.x, offset.y);
			_layerMask = layerMasks;
			_collisionMap = this;
			if (_loaded > 1) onComplete();
		}
		
		/** @private **/
		public function start() : void
		{
			CONFIG::flashPlayer10
			{
				View.addTilesToView(this);
			}
			CONFIG::flashPlayer11
			{
				ViewFlash11.addTilesToView(this);
			}
		}
		/** @private **/
		public function onDestroy() : Boolean
		{
			CONFIG::flashPlayer10
			{
				View.removeTilesFromView(this);
			}
			CONFIG::flashPlayer11
			{
				ViewFlash11.removeTilesFromView(this);
			}
			return false;
		}
		
		private function onComplete() : void
		{
			if (_collisionMap == this)
			{
				var map : BitmapData = new BitmapData(tileMap.width, tileMap.height, true, 0);
				for (var index : uint = 0; index < _layerMask.length; index++)
				{
					map.threshold(tileMap, tileMap.rect, new Point(), "==", 0xFF000000 | index, _layerMask[index]);
				}
				Physics.gridSetup(map, tileSet[0].width, Physics.maxSize);
				Physics.init();
				
				var unitSize : Number = Physics.unitSize;
				for (index = 0; index < tileSet.length; index++)
				{
					if (tileSet[index].width != unitSize)
					{
						var original : BitmapData = tileSet[index];
						var newTile : BitmapData = new BitmapData(unitSize, unitSize, original.transparent, 0x00000000);
						newTile.draw(tileSet[index], new Matrix(unitSize / original.width, 0, 0, unitSize / original.height, 0, 0));
						original.dispose();
						tileSet[index] = newTile;
					}
				}
			}
			sendMessage("tilesLoaded");
		}
	}

}