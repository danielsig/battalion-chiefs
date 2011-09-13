package com.battalion.flashpoint.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import com.battalion.flashpoint.comp.Renderer;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class View extends Sprite 
	{
		
		private static var _renderers : Vector.<Renderer> =  new Vector.<Renderer>();
		
		private var _sprites : Vector.<Sprite> =  new Vector.<Sprite>();
		private var _dynamicLayer : Sprite = new Sprite();
		private var _bounds : Rectangle;
		
		public static function addToView(renderer : Renderer) : void
		{
			_renderers.push(renderer);
		}
		public function View(bounds : Rectangle)
		{
			_bounds = bounds || new Rectangle;
			addChild(_dynamicLayer);
			addEventListener(Event.ENTER_FRAME, onEveryFrame);
		}
		private function onEveryFrame(e : Event) : void
		{
			_sprites.length = _renderers.length;
			var i : int = _renderers.length;
			while(i--)
			{
				var renderer : Renderer = _renderers[i];
				if (_bounds.intersects(renderer.bounds))
				{
					if (!_sprites[i])
					{
						_sprites[i] = new Sprite();
						_sprites[i].addChild(new Bitmap((renderer.bitmapData as BitmapData)));
					}
					_dynamicLayer.addChild(_sprites[i]);
					_sprites[i].transform.matrix = renderer.gameObject.transform.matrix;
				}
				else if(_sprites[i] && _dynamicLayer.contains(_sprites[i]))
				{
					_dynamicLayer.removeChild(_sprites[i]);
					_sprites[i] = null;
				}
			}
		}
	}

}