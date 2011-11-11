package com.battalion.flashpoint.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * A Tile View class, Use this class to render tiles
	 * @author Battalion Chiefs
	 */
	public final class TileView extends Sprite 
	{
		
		public var scrollX : Number = 0;
		public var scrollY : Number = 0;
		public var viewWidth : Number = 400;
		public var viewHeight : Number = 300;
		
		public function get tileSet() : Vector.<BitmapData> { return _tileSet; }
		public function get tileMap() : BitmapData { return _tileMap; }
		
		private var _tileSet : Vector.<BitmapData>;
		private var _tileMap : BitmapData;
		
		private var _prevScrollX : Number = 0;
		private var _prevScrollY : Number = 0;
		private var _prevViewWidth : Number = 0;
		private var _prevViewHeight : Number = 0;
		
		private var _pixelsPerTile : uint = 1;
		
		private var _tiles : Vector.<Vector.<Bitmap>>;
		
		public function setTiles(tileMap : BitmapData, tileSet : Vector.<BitmapData>) : void
		{
			_pixelsPerTile = tileSet[0].width;
			_tileMap = tileMap;
			_tileSet = tileSet;
			while (numChildren) removeChildAt(0);
			
			var width : uint = tileMap.width;
			var height : uint = tileMap.height;
			
			if (!_tiles) _tiles = new Vector.<Vector.<Bitmap>>(width);
			else _tiles.length = width;
			for (var i : uint = 0; i < width; i++)
			{
				if (!_tiles[i]) _tiles[i] = new Vector.<Bitmap>(height);
				else _tiles[i].length = height;
				
				for (var j : uint = 0; j < height; j++)
				{
					if (!_tiles[i][j]) _tiles[i][j] = new Bitmap();
					var tileIndex : uint = tileMap.getPixel(i, j);
					if (tileIndex >= tileSet.length) tileIndex = tileSet.length - 1;
					var bitmap : Bitmap = _tiles[i][j];
					bitmap.bitmapData = tileSet[tileIndex];
					bitmap.x = i * _pixelsPerTile;
					bitmap.y = j * _pixelsPerTile;
				}
			}
			_prevScrollX = _prevScrollY = -1;
			_prevViewWidth = _prevViewHeight = 0;
			//addChild(_tiles[0][0]);
		}
		
		public function update() : void
		{
			if (scrollX < 0) scrollX = 0;
			if (scrollY < 0) scrollY = 0;
			if (viewWidth < 1) viewWidth = 1;
			if (viewHeight < 1) viewHeight = 1;
			
			var width : uint = _tiles.length - 1;
			var height : uint = _tiles[0].length - 1;
			
			var left : uint = scrollX / _pixelsPerTile;
			var top : uint = scrollY / _pixelsPerTile;
			var right : uint = (scrollX + viewWidth + _pixelsPerTile) / _pixelsPerTile;
			var bottom : uint = (scrollY + viewHeight + _pixelsPerTile) / _pixelsPerTile;
			
			if (right > width)
			{
				right = width;
				if (left > width) left = width;
			}
			if (bottom > height)
			{
				bottom = height;
				if (top > height) top = height;
			}
			
			var prevLeft : uint = _prevScrollX / _pixelsPerTile;
			var prevTop : uint = _prevScrollY / _pixelsPerTile;
			var prevRight : uint = (_prevScrollX + _prevViewWidth + _pixelsPerTile) / _pixelsPerTile;
			var prevBottom : uint = (_prevScrollY + _prevViewHeight + _pixelsPerTile) / _pixelsPerTile;
			
			if (prevRight > width)
			{
				prevRight = width;
				if (prevLeft > width) prevLeft = width;
			}
			if (prevBottom > height)
			{
				prevBottom = height;
				if (prevTop > height) prevTop = height;
			}
			
			/*
			while (numChildren) removeChildAt(0);
			
			for (var x : uint = left; x < right; x++)
			{
				for (var y : uint = top; y < bottom; y++)
				{
					addChild(_tiles[x][y]);
				}
			}*/
			
			if (prevLeft < left)
			{
				for (var x : uint = prevLeft; x < left; x++)
				{
					for (var y : uint = prevTop; y < prevBottom; y++)
					{
						removeChild(_tiles[x][y]);
					}
				}
				prevLeft = left;
			}
			else if (left < prevLeft)
			{
				for (x = left; x < prevLeft; x++)
				{
					for (y = top; y < bottom; y++)
					{
						addChild(_tiles[x][y]);
					}
				}
			}
			
			
			if (prevRight > right)
			{
				for (x = right; x < prevRight; x++)
				{
					for (y = prevTop; y < prevBottom; y++)
					{
						removeChild(_tiles[x][y]);
					}
				}
				prevRight = right;
			}
			else if (right > prevRight)
			{
				for (x = prevRight; x < right; x++)
				{
					for (y = top; y < bottom; y++)
					{
						addChild(_tiles[x][y]);
					}
				}
			}
			
			if (prevTop < top)
			{
				for (y = prevTop; y < top; y++)
				{
					for (x = prevLeft; x < prevRight; x++)
					{
						removeChild(_tiles[x][y]);
					}
				}
				prevTop = top;
			}
			else if (top < prevTop)
			{
				for (y = top; y < prevTop; y++)
				{
					for (x = left; x < right; x++)
					{
						addChild(_tiles[x][y]);
					}
				}
			}
			
			
			if (prevBottom > bottom)
			{
				for (y = bottom; y < prevBottom; y++)
				{
					for (x = prevLeft; x < prevRight; x++)
					{
						removeChild(_tiles[x][y]);
					}
				}
				prevBottom = bottom;
			}
			else if (bottom > prevBottom)
			{
				for (y = prevBottom; y < bottom; y++)
				{
					for (x = left; x < right; x++)
					{
						addChild(_tiles[x][y]);
					}
				}
			}
			
			_prevScrollX = scrollX;
			_prevScrollY = scrollY;
			_prevViewWidth = viewWidth;
			_prevViewHeight = viewHeight;
		}
		private function traceTiles() : void
		{
			var height : uint = _tiles[0].length;
			for (var y : uint = 0; y < height; y++)
			{
				var line : String = "";
				for (var x : uint = 0; x < _tiles.length; x++)
				{
					line += contains(_tiles[x][y]) ? "@" : " ";
				}
				trace(line);
			}
		}
	}

}