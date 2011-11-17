package com.battalion.flashpoint.display 
{
	import com.battalion.flashpoint.core.Transform;
	import com.danielsig.BitmapLoader;
	import flash.display.BitmapData;
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
	import flash.utils.Dictionary;
	import starling.events.EnterFrameEvent;
	
	import com.demonsters.debugger.MonsterDebugger;
	
	import starling.text.TextField;
	import starling.display.*;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
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
	public final class ViewFlash11 extends starling.display.Sprite 
	{
		
		private static var _renderers : Vector.<Renderer> =  new Vector.<Renderer>();
		private static var _texts : Vector.<TextRenderer> =  new Vector.<TextRenderer>();
		private static var _tiles : Vector.<TileRenderer> =  new Vector.<TileRenderer>();
		
		private static var _views : Vector.<ViewFlash11> =  new Vector.<ViewFlash11>();
		private static var _viewCounter : int = 0;
		
		private static var textureDictionary : Dictionary = new Dictionary();
		
		private var _sprites : Vector.<Image> =  new Vector.<Image>();
		//private var _textFields : Vector.<TextField> = new Vector.<TextField>();
		private var _tileViews : Vector.<TileViewFlash11> = new Vector.<TileViewFlash11>();
		
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
		public static function addToView(renderer : Renderer) : void
		{
			_renderers.push(renderer);
		}
		/** @private **/
		public static function addTilesToView(tiles : TileRenderer) : void
		{
			_tiles.push(tiles);
		}
		/** @private **/
		public static function addTextToView(text : TextRenderer) : void
		{
			/*_texts.push(text);
			for each(var view : View in _views)
			{
				view._textFields.push(null);
			}*/
		}
		/** @private **/
		public static function removeFromView(renderer : Renderer) : void
		{
			var index : int = _renderers.indexOf(renderer);
			if (index < _renderers.length - 1 && index > 0)
			{
				_renderers[index] = _renderers.pop();
			}
			else if (_renderers.length > 0)
			{
				_renderers.length--;
			}
			renderer.bitmapData = null;
			
			for each(var view : ViewFlash11 in _views)
			{
				if(view._sprites[index] && view._sprites[index].parent.contains(view._sprites[index])) view._sprites[index].parent.removeChild(view._sprites[index]);
				if (index < view._sprites.length - 1 && index > 0)
				{
					view._sprites[index] = view._sprites.pop();
				}
				else if (view._sprites.length > 0)
				{
					view._sprites.length--;
				}
			}
		}
		/** @private **/
		public static function removeTextFromView(text : TextRenderer) : void
		{
			/*var index : int = _texts.indexOf(text);
			if (index < 0) return;
			if (index < _texts.length - 1 && index > 0)//not the last element
			{
				_texts[index] = _texts.pop();
			}
			else if (_texts.length > 0)//not the last element
			{
				_texts.length--;
			}
			for each(var view : ViewFlash11 in _views)
			{
				if(view._textFields[index] && view._textFields[index].parent.contains(view._textFields[index])) view._textFields[index].parent.removeChild(view._textFields[index]);
				if (index < view._textFields.length - 1 && index > 0)
				{
					view._textFields[index] = view._textFields.pop();
				}
				else if (view._textFields.length > 0)
				{
					view._textFields.length--;
				}
			}*/
		}
		/** @private **/
		public static function removeTilesFromView(tiles : TileRenderer) : void
		{
			var index : int = _tiles.indexOf(tiles);
			if (index < _tiles.length - 1 && index > 0)
			{
				_tiles[index] = _tiles.pop();
			}
			else if (_tiles.length > 0)
			{
				_tiles.length--;
			}
			tiles.tileMap = null;
			tiles.tileSet = null;
			
			for each(var view : ViewFlash11 in _views)
			{
				if(view._tileViews[index] && view._tileViews[index].parent.contains(view._tileViews[index])) view._tileViews[index].parent.removeChild(view._tileViews[index]);
				if (index < view._tileViews.length - 1 && index > 0)
				{
					view._tileViews[index] = view._tileViews.pop();
				}
				else if (view._tileViews.length > 0)
				{
					view._tileViews.length--;
				}
			}
		}
		public function ViewFlash11(bounds : Rectangle, camName : String = "cam")
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
			addEventListener(EnterFrameEvent.ENTER_FRAME, onEveryFrame);
			_cam = new GameObject(camName || "cam", Camera).camera;
			_cam.setBounds(_bounds);
			_views.push(this);
			if (StageFlash11.starlingStage) StageFlash11.starlingStage.addChild(this);
			else StageFlash11.queue.push(this);
		}
		private function onEveryFrame(e : EnterFrameEvent) : void
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
			_layers.rotation = -tr.rotation;
			_layers.scaleX = 1/tr.scaleX;
			_layers.scaleY = 1/tr.scaleY;
			_layers.x = m.tx;
			_layers.y = m.ty;
			
			/*
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
			*/
			_sprites.length = _renderers.length;
			_tileViews.length = _tiles.length;
			
			var left : Number = tr.x - _bounds.width * 0.5 * tr.scaleX;
			var right : Number = tr.x + _bounds.width * 0.5 * tr.scaleX;
			var top : Number = tr.y - _bounds.height * 0.5 * tr.scaleY;
			var bottom : Number = tr.y + _bounds.height * 0.5 * tr.scaleY;
			
			var i : int = _renderers.length;
			while(i--)
			{
				var renderer : Renderer = _renderers[i];
				if (renderer.bitmapData)
				{
					var rect : Rectangle = renderer.bounds;
					if (rect.right > left && rect.left < right && rect.bottom > top && rect.top < bottom)
					{
						if (_sprites[i] && !_sprites[i].visible)
						{
							_dynamicLayer.addChild(_sprites[i]);
							_sprites[i].visible = true;
						}
						if (renderer.updateBitmap)
						{
							if (!_sprites[i])
							{
								var texture : Texture = textureDictionary[renderer.bitmapData];
								if (!texture) texture = textureDictionary[renderer.bitmapData] = Texture.fromBitmapData(renderer.bitmapData as BitmapData, true, true);
								var bitmap : Image = _sprites[i] = new Image(texture);

								bitmap.mPivotX = bitmap.width * 0.5;
								bitmap.mPivotY = bitmap.height * 0.5;
								bitmap.smoothing = renderer.smoothing ? TextureSmoothing.BILINEAR : TextureSmoothing.NONE;
								
								_dynamicLayer.addChild(_sprites[i]);
								renderer.sprites[_name] = _sprites[i];
								
								if (renderer.rendererInFrontOfThis)
								{
									var onFront : Image = renderer.rendererInFrontOfThis.sprites[_name];
									if (onFront)
									{
										var back : int = _dynamicLayer.getChildIndex(_sprites[i]);
										var front : int = _dynamicLayer.getChildIndex(onFront);
										if (back > front)
										{
											_dynamicLayer.swapChildren(_sprites[i], onFront);
										}
									}
								}
							}
							else
							{
								texture = textureDictionary[renderer.bitmapData];
								if (!texture) texture = textureDictionary[renderer.bitmapData] = Texture.fromBitmapData(renderer.bitmapData as BitmapData, true, true);
								
								_sprites[i].texture = texture;
								if (renderer.rendererInFrontOfThis)
								{
									onFront = renderer.rendererInFrontOfThis.sprites[_name];
									if (onFront && onFront.parent == _dynamicLayer)
									{
										back = _dynamicLayer.getChildIndex(_sprites[i]);
										front = _dynamicLayer.getChildIndex(onFront);
										if (back > front)
										{
											_dynamicLayer.swapChildren(_sprites[i], onFront);
										}
									}
								}
							}
							renderer.updateBitmap = false;
						}
						var sprite : Image = _sprites[i];
						if (renderer.optimized)
						{
							sprite.x = renderer.gameObject.transform.globalMatrix.tx;
							sprite.y = renderer.gameObject.transform.globalMatrix.ty;
						}
						else
						{
							if (renderer.offset)
							{
								var matrix : Matrix = renderer.offset.clone();
								matrix.concat(renderer.gameObject.transform.globalMatrix);
							}
							else
							{
								matrix = renderer.gameObject.transform.globalMatrix;
							}
							
							var a : Number = matrix.a;
							var b : Number = matrix.b;
							var c : Number = matrix.c;
							var d : Number = matrix.d;
							
							
							//ROTATION
							var angle : Number = b / a;
							if (a < 0)
							{
								if(angle > 0) angle = -9.4 / ((angle + 2.44) * (angle + 2.44)) - 1.57079633;
								else angle = 9.4 / ((angle - 2.44) * (angle - 2.44)) + 1.57079633;
							}
							else if(angle > 0) angle = -9.4 / ((angle + 2.44) * (angle + 2.44)) + 1.57079633;
							else angle = 9.4 / ((angle - 2.44) * (angle - 2.44)) - 1.57079633;
							
							sprite.mRotation = 3.1415926535 - ((3.1415926535 - angle) % 6.28318531);
							
							//SCALE
							var sx : Number = a * a + b * b;
							var sy : Number = c * c + d * d;
							var signX : int = (b > 0) == (sprite.mRotation > 0) ? 1 : -1;
							var signY : int = (c > 0) == (sprite.mRotation < 0) ? 1 : -1;
							if (sprite.mScaleX * sprite.mScaleX != sx || (sprite.mScaleX ^ signX) < 0)
							{
								if (sx != 1) sx = Math.sqrt(sx);
								sprite.mScaleX = sx * ((b > 0) == (sprite.mRotation > 0) ? 1 : -1);
							}
							if (sprite.mScaleY * sprite.mScaleY != sy || (sprite.mScaleY ^ signY) < 0)
							{
								if (sy != 1) sy = Math.sqrt(sy);
								sprite.mScaleY = sy * ((c > 0) == (sprite.mRotation < 0) ? 1 : -1);// * ((d & int.MIN_VALUE) >> 30) + 1;
							}
							
							//TRANSLATION
							sprite.mX = matrix.tx;
							sprite.mY = matrix.ty;
						}
					}
					else if (_sprites[i] && _sprites[i].visible)
					{
						_dynamicLayer.removeChild(_sprites[i]);
						_sprites[i].visible = false;
					}
				}
				else if(_sprites[i] && _sprites[i].parent)
				{
					_sprites[i].parent.removeChild(_sprites[i]);
					delete renderer.sprites[_name];
					_sprites[i] = null;
				}
			}
			/*
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
			*/
			i = _tiles.length;
			tilesLoop: while (i--)
			{
				var tileRenderer : TileRenderer = _tiles[i];
				var tileView : TileViewFlash11 = _tileViews[i];
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
						if (!tileView) tileView = _tileViews[i] = new TileViewFlash11();
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
							tileView.mX = matrix.tx;
							tileView.mY = matrix.ty;
							tileView.scrollX -= tileRenderer.offset.tx;
							tileView.scrollY -= tileRenderer.offset.ty;
						}
						else
						{
							matrix = tileRenderer.gameObject.transform.globalMatrix
							tileView.mX = matrix.tx;
							tileView.mY = matrix.ty;
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