package com.battalion.flashpoint.display 
{
	import com.battalion.flashpoint.core.Transform;
	import com.danielsig.BitmapLoader;
	import com.danielsig.SpriteSheet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.TextRenderer;
	import com.battalion.flashpoint.comp.TileRenderer;
	import com.battalion.flashpoint.comp.Camera;
	import com.battalion.flashpoint.core.GameObject;
	import flash.text.TextFormat;
	import com.demonsters.debugger.MonsterDebugger;
	
	/**
	 * View, FlashPoint's display object manager.<br/>
	 * For every View instance there's a GameObject with a Camera component.
	 * Every frame has only one bitmap.
	 * Can be both individual image urls and/or spritesheet urls. Can also read spritesheet ranges.
	 * @see com.battalion.flashpoint.comp.Camera
	 * @see com.battalion.flashpoint.comp.Renderer
	 * @see com.battalion.flashpoint.comp.Animation
	 * @author Battalion Chiefs
	 */
	public final class View extends Sprite 
	{
		
		private static var _texts : Vector.<TextRenderer> =  new Vector.<TextRenderer>();
		private static var _tiles : Vector.<TileRenderer> =  new Vector.<TileRenderer>();
		
		private static var _views : Vector.<View> =  new Vector.<View>();
		private static var _viewCounter : int = 0;
		
		private var _textFields : Vector.<TextField> = new Vector.<TextField>();
		private var _tileViews : Vector.<TileView> = new Vector.<TileView>();
		
		private var _bounds : Rectangle;
		private var _cam : Camera;
		private var _colorMatrix : ColorMatrix;
		private var _content : Sprite = new Sprite();//to center things
		private var _layers : Sprite = new Sprite();//to perferm transformation on all layers
		private var _tileLayer : Sprite = new Sprite();
		private var _dynamicLayer : Sprite = new Sprite();
		private var _textLayer : Sprite = new Sprite();
		private var _name : String;
		
		/** @private **/
		public static function addTilesToView(tiles : TileRenderer) : void
		{
			_tiles.push(tiles);
			for each(var view : View in _views)
			{
				view._tileViews.push(null);
			}
		}
		/** @private **/
		public static function addTextToView(text : TextRenderer) : void
		{
			_texts.push(text);
			for each(var view : View in _views)
			{
				view._textFields.push(null);
			}
		}
		/** @private **/
		public static function removeFromView(renderer : Renderer) : void
		{
			for each(var view : View in _views)
			{
				var sprite : Sprite = renderer.sprites[view._name];
				if (sprite && sprite.parent)
				{
					sprite.removeChildAt(0);
					sprite.parent.removeChild(sprite);
				}
			}
		}
		/** @private **/
		public static function removeTilesFromView(tiles : TileRenderer) : void
		{
			var index : int = _tiles.indexOf(tiles);
			if (index < 0) return;
			
			if (index < _tiles.length - 1)
			{
				_tiles[index] = _tiles.pop();
			}
			else if (_tiles.length)
			{
				_tiles.length--;
			}
			tiles.tileMap = null;
			tiles.tileSet = null;
			
			for each(var view : View in _views)
			{
				if(view._tileViews[index] && view._tileViews[index].parent.contains(view._tileViews[index])) view._tileViews[index].parent.removeChild(view._tileViews[index]);
				if (index < view._tileViews.length - 1)
				{
					view._tileViews[index] = view._tileViews.pop();
				}
				else if (view._tileViews.length)
				{
					view._tileViews.length--;
				}
			}
		}
		/** @private **/
		public static function removeTextFromView(text : TextRenderer) : void
		{
			var index : int = _texts.indexOf(text);
			if (index < 0) return;
			
			if (index < _texts.length - 1)//not the last element
			{
				_texts[index] = _texts.pop();
			}
			else if (_texts.length)//the last element
			{
				_texts.length--;
			}
			for each(var view : View in _views)
			{
				var textField : TextField = view._textFields[index];
				if(textField && textField.parent) textField.parent.removeChild(textField);
				if (index < view._textFields.length - 1)
				{
					view._textFields[index] = view._textFields.pop();
				}
				else if (view._textFields.length)
				{
					view._textFields.length--;
				}
			}
		}
		public function View(bounds : Rectangle, camName : String = "cam")
		{
			CONFIG::debug
			{
				if (!GameObject.world)
				{
					throw new Error("You can not instantiate a view before you initilize the flashpoint engine.");
				}
			}
			_name = "view" + _viewCounter;
			_bounds = bounds || new Rectangle;
			_layers.addChild(_tileLayer);
			_layers.addChild(_dynamicLayer);
			_layers.addChild(_textLayer);
			_content.addChild(_layers);
			_content.x = bounds.width * 0.5;
			_content.y = bounds.height * 0.5;
			addChild(_content);
			addEventListener(Event.ENTER_FRAME, onEveryFrame);
			_cam = new GameObject(camName || "cam", Camera).camera;
			_cam.setBounds(_bounds);
			_views.push(this);
			mouseChildren = mouseEnabled = false;
		}
		private function onEveryFrame(e : Event) : void
		{
			if (!_cam.gameObject || _cam.gameObject.destroyed)
			{
				_cam = null;
				parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onEveryFrame);
				return;
			}
			//_dynamicLayer.graphics.clear();
			var tr : Transform = _cam.gameObject.transform;
			var m : Matrix = _cam.gameObject.transform.matrix.clone();
			m.invert();
			_layers.transform.matrix = m;
			
			if (_cam.colorMatrix)
			{
				if (!_colorMatrix || !_colorMatrix.equals(_cam.colorMatrix))
				{
					_layers.filters = [_cam.colorMatrix.filter];
					_colorMatrix = _cam.colorMatrix.clone();
				}
			}
			else if (_colorMatrix)
			{
				_layers.filters = null;
				_colorMatrix = null;
			}
			
			var left : Number = tr.x - _bounds.width * 0.5 * tr.scaleX;
			var right : Number = tr.x + _bounds.width * 0.5 * tr.scaleX;
			var top : Number = tr.y - _bounds.height * 0.5 * tr.scaleY;
			var bottom : Number = tr.y + _bounds.height * 0.5 * tr.scaleY;
			
			var i : uint = 0;
			var renderer : Renderer = Renderer.tail;
			if (renderer)
			{
				do
				{
					var rendererSprite : Sprite = renderer.sprites[_name];
					if (renderer.bitmapData)
					{
						var rect : Rectangle = renderer.bounds;
						if (rect.right > left && rect.left < right && rect.bottom > top && rect.top < bottom)
						{
							if (rendererSprite && !rendererSprite.visible)
							{
								_dynamicLayer.addChild(rendererSprite);
								rendererSprite.visible = true;
							}
							if (renderer.updateBitmap)
							{
								if (!rendererSprite)
								{
									rendererSprite = renderer.sprites[_name] = new Sprite();
									var bitmap : Bitmap = new Bitmap((renderer.bitmapData as BitmapData), renderer.pixelSnapping, renderer.smoothing)
									bitmap.x = -bitmap.width * 0.5;
									bitmap.y = -bitmap.height * 0.5;
									rendererSprite.addChild(bitmap);
									if (_dynamicLayer.numChildren > i) _dynamicLayer.addChildAt(rendererSprite, i);
									else _dynamicLayer.addChild(rendererSprite);
								}
								else
								{
									(rendererSprite.getChildAt(0) as Bitmap).bitmapData = renderer.bitmapData;
									if (_dynamicLayer.numChildren > i) _dynamicLayer.setChildIndex(rendererSprite, i);
									else _dynamicLayer.addChild(rendererSprite);
								}
								renderer.updateBitmap = false;
							}
							if (renderer.optimized)
							{
								rendererSprite.x = renderer.gameObject.transform.globalMatrix.tx;
								rendererSprite.y = renderer.gameObject.transform.globalMatrix.ty;
							}
							else
							{
								if (renderer.offset)
								{
									var matrix : Matrix = renderer.offset.clone();
									matrix.concat(renderer.gameObject.transform.globalMatrix);
									rendererSprite.transform.matrix = matrix;
								}
								else
								{
									rendererSprite.transform.matrix = renderer.gameObject.transform.globalMatrix;
								}
							}
						}
						else if (rendererSprite && rendererSprite.visible)
						{
							_dynamicLayer.removeChild(rendererSprite);
							rendererSprite.visible = false;
						}
					}
					else if(rendererSprite && rendererSprite.parent)
					{
						rendererSprite.removeChildAt(0);
						_dynamicLayer.removeChild(rendererSprite);
						delete renderer.sprites[_name];
					}
					i++;
				}
				while ((renderer = renderer.rendererInFrontOfThis));
			}
			i = _texts.length;
			while (i--)
			{
				var text : TextRenderer = _texts[i];
				if (text.text || text.htmlText)
				{
					var field : TextField = _textFields[i];
					if (!field) field = _textFields[i] = new TextField();
					if (text.htmlText) field.htmlText = text.htmlText;
					else
					{
						field.text = text.text;
						//Set format for text
						var format : TextFormat = field.defaultTextFormat;
						format.font = text.font;
						format.size = text.size;
						format.color = text.color;
						format.bold = text.bold;
						format.italic = text.italic;
						format.underline = text.underline;
						field.defaultTextFormat = format;
					}
					field.wordWrap = text.wordWrap;
					field.width = text.width;
					field.height = text.height;
					field.autoSize = TextFieldAutoSize.CENTER;
					field.selectable = false;
					
					m = text.gameObject.transform.globalMatrix;
					if (text.offset)
					{
						var sx : Number = m.a * text.offset.a + m.c * text.offset.c;
						var sy : Number = m.b * text.offset.b + m.d * text.offset.d;
						field.scaleX = field.scaleY = Math.sqrt(sx * sx + sy * sy);
						field.x = m.tx + text.offset.tx - field.textWidth * 0.5 * field.scaleX;
						field.y = m.ty + text.offset.ty - field.textHeight * 0.5 * field.scaleY;
					}
					else
					{
						field.scaleX = field.scaleY = Math.sqrt((m.a + m.c) * (m.a + m.c) + (m.b + m.d) * (m.b + m.d));
						field.x = m.tx - field.textWidth * 0.5 * field.scaleX;
						field.y = m.ty - field.textHeight * 0.5 * field.scaleY;
					}
					_textLayer.addChild(_textFields[i]);
				}
				else if (_textFields[i])
				{
					_textLayer.removeChild(_textFields[i]);
					_textFields[i] = null;
				}
			}
			i = _tiles.length;
			tilesLoop: while (i--)
			{
				var tileRenderer : TileRenderer = _tiles[i];
				var tileView : TileView = _tileViews[i];
				if (tileRenderer.tileMap && tileRenderer.tileSet)
				{
					if (!tileView || tileView.tileMap != tileRenderer.tileMap || tileView.tileSet != tileRenderer.tileSet)
					{
						var tileSet : Vector.<BitmapData> = tileRenderer.tileSet;
						if (!tileSet.length) continue;
						var tileIndex : uint = tileSet.length;
						while(tileIndex--)
						{
							if (!tileSet[tileIndex]) continue tilesLoop;
						}
						if (!tileView) tileView = _tileViews[i] = new TileView();
						tileView.setTiles(tileRenderer.tileMap, tileSet);
						_tileLayer.addChild(tileView);
					}
					if(tileView)
					{
						tileView.scrollX = left;
						tileView.scrollY = top;
						tileView.viewWidth = _bounds.width * tr.scaleX;
						tileView.viewHeight = _bounds.height * tr.scaleY;
						if (tileRenderer.offset)
						{
							matrix = tileRenderer.offset.clone();
							matrix.concat(tileRenderer.gameObject.transform.globalMatrix);
							tileView.transform.matrix = matrix;
							tileView.scrollX -= tileRenderer.offset.tx;
							tileView.scrollY -= tileRenderer.offset.ty;
						}
						else
						{
							tileView.transform.matrix = tileRenderer.gameObject.transform.globalMatrix;
						}
						tileView.update();
					}
				}
				else if(tileView)
				{
					_tileLayer.removeChild(tileView);
				}
			}
		}
	}

}