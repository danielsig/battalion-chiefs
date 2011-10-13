package com.battalion.flashpoint.display 
{
	import com.battalion.flashpoint.core.Transform;
	import com.danielsig.BitmapLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.Text;
	import com.battalion.flashpoint.comp.Camera;
	import com.battalion.flashpoint.core.GameObject;
	
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
		
		private static var _renderers : Vector.<Renderer> =  new Vector.<Renderer>();
		private static var _texts : Vector.<Text> =  new Vector.<Text>();
		private static var _viewCounter : int = 0;
		
		private var _sprites : Vector.<Sprite> =  new Vector.<Sprite>();
		private var _textFields : Vector.<TextField> =  new Vector.<TextField>();
		private var _bounds : Rectangle;
		private var _cam : Camera;
		private var _content : Sprite = new Sprite();//to center things
		private var _layers : Sprite = new Sprite();//to perferm transformation on all layers
		private var _dynamicLayer : Sprite = new Sprite();
		private var _name : String;
		
		/** @private **/
		public static function addToView(renderer : Renderer) : void
		{
			_renderers.push(renderer);
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
		}
		public static function addTextToView(text : Text) : void
		{
			_texts.push(text);
			_textFields.push(null);
		}
		/** @private **/
		public static function removeTextFromView(text : Text) : void
		{
			var index : int = _texts.indexOf(text);
			if (index < _texts.length - 1 && index > 0)//not the last element
			{
				_texts[index] = _texts.pop();
				if (_dynamicLayer.contains(_textFields[index]))
				{
					_dynamicLayer.removeChild(_textFields[index]);
				}
				_textFields[index] = _textFields.pop();
			}
			else if (_texts.length > 0)//not the last element
			{
				_texts.length--;
				if (_dynamicLayer.contains(_textFields[index]))
				{
					_dynamicLayer.removeChild(_textFields[index]);
				}
				_textFields.length--;
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
			_layers.addChild(_dynamicLayer);
			_content.addChild(_layers);
			_content.x = bounds.width * 0.5;
			_content.y = bounds.height * 0.5;
			addChild(_content);
			addEventListener(Event.ENTER_FRAME, onEveryFrame);
			_cam = new GameObject(camName || "cam", Camera).camera;
			_cam.setBounds(_bounds);
		}
		private function onEveryFrame(e : Event) : void
		{
			if (!_cam.gameObject || _cam.gameObject.destroyed)
			{
				trace(_cam.gameObject);
				_cam = null;
				parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onEveryFrame);
				return;
			}
			/*var mat : Matrix = new Matrix();
			mat.invert()*/
			var tr : Transform = _cam.gameObject.transform;
			var m : Matrix = _cam.gameObject.transform.matrix.clone();
			m.invert();
			_layers.transform.matrix = m;
			
			_sprites.length = _renderers.length;
			var i : int = _renderers.length;
			while(i--)
			{
				var renderer : Renderer = _renderers[i];
				if (renderer.bitmapData)
				{
					if (renderer.updateBitmap)
					{
						if (!_sprites[i])
						{
							_sprites[i] = new Sprite();
							var bitmap : Bitmap = new Bitmap((renderer.bitmapData as BitmapData), renderer.pixelSnapping, renderer.smoothing)
							bitmap.x = -bitmap.width * 0.5;
							bitmap.y = -bitmap.height * 0.5;
							_sprites[i].addChild(bitmap);
							_dynamicLayer.addChild(_sprites[i]);
							renderer.sprites[_name] = _sprites[i];
							
							if (renderer.rendererInFrontOfThis)
							{
								var onFront : Sprite = renderer.rendererInFrontOfThis.sprites[_name];
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
							(_sprites[i].getChildAt(0) as Bitmap).bitmapData = renderer.bitmapData;
						}
						renderer.updateBitmap = false;
					}
					if (renderer.offset)
					{
						var matrix : Matrix = renderer.offset.clone();
						matrix.concat(renderer.gameObject.transform.globalMatrix);
						_sprites[i].transform.matrix = matrix;
					}
					else
					{
						_sprites[i].transform.matrix = renderer.gameObject.transform.globalMatrix;
					}
				}
				else if(_sprites[i])
				{
					_sprites[i].parent.removeChild(_sprites[i]);
					delete renderer.sprites[_name];
					_sprites[i] = null;
				}
			}
			i = _texts.length;
			while (i--)
			{
				var text : Text = _texts[i];
				if (text.text)
				{
					if (!_textFields[i])
					{
						_textFields[i] = new TextField();
						_textFields[i].replaceText(0, _textFields[i].getLineLength(), text.text);
						if (text.offset)
						{
							var matrix : Matrix = text.offset.clone();
							matrix.concat(renderer.gameObject.transform.globalMatrix);
							_textFields[i].transform.matrix = matrix;
						}
						else
						{
							_textFields[i].transform.matrix = renderer.gameObject.transform.globalMatrix;
						}
						_dynamicLayer.addChild(_textFields[i]);
					}
				}
			}
		}
	}

}