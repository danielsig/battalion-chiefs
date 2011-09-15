package com.danielsig
{
	import com.formatlos.as3.lib.display.BitmapDataUnlimited;
	import com.formatlos.as3.lib.display.events.BitmapDataUnlimitedEvent;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Daniel Sig
	 */
	public class SpriteSheet
	{
		
		private static const NULL : uint = 0x88000000;
		private static const END : uint = 0x00000000;
		
		private var _bitmapData : BitmapData;
		private var _sprites : Vector.<BitmapData>;
		
		private var _unplacedRects : Array;
		private var _placedRects : Array;
		private var _dimensions : Rectangle;
		
		private var _infoLines : int;
		private var _onDone : Function;
		private var _onDoneParams : Array;
		
		private var _nextSheet : SpriteSheet;
		private var _prevSheet : SpriteSheet;
		
		private static var _head : SpriteSheet = null;
		
		public static function generate(sprites : Vector.<BitmapData>, onDone : Function, ...onDoneParams) : void
		{
			var sheet : SpriteSheet = new SpriteSheet(sprites, onDone, onDoneParams);
			if(_head == null)
			{
				_head = sheet;
			}
			else
			{
				_head._prevSheet = sheet;
				sheet._nextSheet = _head;
				_head = sheet;
			}
		}
		
		private function dispose() : void
		{
			if(_nextSheet != null)
			{
				_nextSheet._prevSheet = _prevSheet;
			}
			if(_prevSheet != null)
			{
				_prevSheet._nextSheet = _nextSheet;
			}
			else
			{
				_head = null;
			}
		}
		
		public function SpriteSheet(sprites : Vector.<BitmapData>, onDone : Function, onDoneParams : Array)
		{
			if(sprites == null || sprites.length == 0 || onDone == null)
			{
				return;
			}
			_onDone = onDone;
			_onDoneParams = onDoneParams;
			var area : uint = 0;
			var maxWidth : uint = 0;
			var allNull : Boolean = true;
			for(var i : int = 0; i < sprites.length; i++)
			{
				if(sprites[i] != null)
				{
					//MonsterDebugger.r.trace(sprites[i], sprites[i].width + ", " + sprites[i].height);
					area += sprites[i].width * sprites[i].height;
					maxWidth = Math.max(maxWidth, sprites[i].width);
					allNull = false;
				}
			}
			if(allNull || maxWidth == 0)
			{
				return;
			}
			maxWidth = Math.max(maxWidth, Math.sqrt(area));
			_dimensions = new Rectangle(0, 0, maxWidth, 0xFFFFFF / maxWidth)//MonsterDebugger.ebugger.trace(_dimensions, maxWidth);
			_unplacedRects = new Array();
			_placedRects = new Array();
			_sprites = sprites;
			start();
		}
		public static function decompose(sheet : BitmapData) : Vector.<BitmapData>
		{
			var sprites : Vector.<BitmapData> = new Vector.<BitmapData>();
			var xPos : int = 0;
			var yPos : int = 0;
			if (sheet.getPixel(0, 0) == END)
			{
				var columns : int = sheet.getPixel(1, 0);
				columns++;
				var rows : int = sheet.getPixel(2, 0);
				if (!rows) rows++;
				var width : int = sheet.width / columns;
				var height : int = (sheet.height - 1) / rows;
				for (var row : int = 0; row < rows; row++)
				{
					for (var col : int = 0; col < columns; col++)
					{
						var bitmap : BitmapData = new BitmapData(width, height);
						bitmap.copyPixels(sheet, new Rectangle(col * width, 1 + row * height, width, height), new Point());
						sprites.push(bitmap);
					}
				}
			}
			else
			{
				for(var i : int = 0; i < 0xFFF; i++)
				{
					var infoX : int = i % sheet.width;
					var infoY : int = i / sheet.width;
					var pixel : uint = sheet.getPixel32(infoX, infoY);

					if(pixel == NULL)
					{
						//Tracer.TraceLine("#" + i, "NULL");
						sprites.push(null);
					}
					else if(pixel == END || infoY == sheet.height)
					{
						break;
					}
					else
					{
						width = pixel & 0x00000FFF;
						var nextYPos : int = (pixel & 0x00FFF000) >>> 12;
						if(nextYPos != yPos)//if not same row
						{
							//go to next row
							xPos = 0;
							yPos = nextYPos;
						}
						height = getHeight(sheet, infoX, infoY, xPos);
						bitmap = new BitmapData(width, height);
						bitmap.copyPixels(sheet, new Rectangle(xPos, yPos, width, height), new Point());
						//Tracer.TraceLine("#" + i, xPos, yPos, width, height);
						//Tracer.DisplayBitmapArgs(bitmap);
						//Tracer.DisplayBitmapArgs(bitmap);
						sprites.push(bitmap);
						xPos += width;
					}
				}
			}
			//Tracer.DisplayBitmap(sprites);
			return sprites;
		}
		private static function getHeight(sheet : BitmapData, infoX : int, infoY : int, xPos : int) : int
		{
			var pixel : uint = sheet.getPixel32(infoX, infoY);
			var nextPixel : uint = pixel;
			var yPos : int = (pixel & 0x00FFF000) >>> 12;
			var height : int = sheet.height - yPos;
			while((nextPixel & 0xFF000000) != END)
			{
				infoX++;
				if(infoX >= sheet.width)
				{
					infoY++;
					infoX = 0;
				}
				nextPixel = sheet.getPixel32(infoX, infoY);
				var nextYPos : int = (nextPixel & 0x00FFF000) >>> 12;
				if(nextYPos > yPos && nextPixel != NULL)
				{
					height = nextYPos - yPos;
					break;
				}
			}
			for(var i : int = 1; i < height; i++)
			{
				if(sheet.getPixel32(xPos, yPos + i) == NULL)
				{
					height = i;
					break;
				}
			}
			return height;
		}
		private function start() : void
		{
			var numSprites : int = _sprites.length;
			var numNonNullSprites : int = 0;
			for(var i : int = 0; i < numSprites; i++)
			{
				if(_sprites[i] != null)
				{
					numNonNullSprites++;
				}
				_unplacedRects.push(_sprites[i] == null ? new Rectangle(0, 0, 0, 0) : _sprites[i].rect);
			}
			//_unplacedRects.sort(SortOnArea, Array.NUMERIC | Array.DESCENDING);
			var rect : Rectangle = _unplacedRects[0];
			var xPos : int = 0;
			var yPos : int = 0;
			var rowHeight : Number = rect.height;
			rect.x = xPos;
			rect.y = yPos;
			var maxWidth : int = 1;
			var currentRowWidth : int = 0;
			while (_unplacedRects.length > 0)
			{
				rect = _unplacedRects.shift();
				if (xPos + rect.width <= _dimensions.width)
				{
					currentRowWidth += rect.width;
				}
				else
				{
					currentRowWidth = rect.width;
					xPos = 0;
					yPos += rowHeight;
					rowHeight = rect.height;
				}
				maxWidth = Math.max(maxWidth, currentRowWidth);
				rowHeight =  Math.max(rowHeight, rect.height);
				rect.x = xPos;
				rect.y = yPos;

				xPos += rect.width;
				
				_placedRects.push(rect);
			}
			 _dimensions.width = maxWidth;
			yPos += rowHeight;
			yPos = yPos >= _dimensions.height ? _dimensions.height : yPos;
			_infoLines = Math.ceil(numNonNullSprites / _dimensions.width);
			var hugeBitmapData : BitmapDataUnlimited = new BitmapDataUnlimited();
			hugeBitmapData.addEventListener(BitmapDataUnlimitedEvent.COMPLETE, Continue);
			hugeBitmapData.create(_dimensions.width, yPos + _infoLines, true, NULL);
		}
		private function Continue(e : Event) : void
		{
			e.target.removeEventListener(BitmapDataUnlimitedEvent.COMPLETE, Continue);
			_bitmapData = (e.target as BitmapDataUnlimited).bitmapData;
			var infoX : int = 0;
			var infoY : int = 0;
			for (var i : int = 0; i < _placedRects.length; i++)
			{
				var rect : Rectangle = _placedRects[i];
				var success : Boolean = rect.width * rect.height > 1;
				
				if(success)
				{
					var bd : BitmapData = _sprites[i];
					var sourceRect : Rectangle = new Rectangle(0, 0, rect.width, rect.height);
					_bitmapData.copyPixels(bd, sourceRect, new Point(rect.x, rect.y + _infoLines), null, null, false);
				}
				_bitmapData.setPixel32(infoX, infoY, success ? ((rect.width & 0xFFF) + (((rect.y + _infoLines) * 0x001000) & 0xFFF000) + 0xFF000000) : NULL);
				infoX++;
				if(infoX >= _dimensions.width)
				{
					infoX = 0;
					infoY++;
				}
			}
			
			_bitmapData.setPixel32(infoX, infoY, END);
			_onDone.apply(this, [_bitmapData].concat(_onDoneParams));
			dispose();
		}
		
		private static function SortOnArea(a:Rectangle, b:Rectangle):Number {
			var aArea:Number = a.height * a.width;
			var bArea:Number = b.height * b.width;
		
			if(aArea > bArea)
				return 1;
			else if(aArea < bArea)
				return -1;
			else
				return 0;
		}
	}
}
