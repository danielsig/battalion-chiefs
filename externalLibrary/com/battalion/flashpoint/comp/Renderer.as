package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.display.View;
	import com.danielsig.LoaderMax;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.events.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Renderer extends Component 
	{
		
		private var _url : String = null;
		private var _loader : LoaderMax;
		private var _bitmapData : BitmapData;
		private var _transform : Transform;//just for convenience
		
		public function get bitmapData() : BitmapData
		{
			return _bitmapData;
		}
		
		public function get url() : String
		{
			return _url;
		}
		public function set url(value : String) : void
		{
			_url = value;
			load();
		}
		
		private function load() : void 
		{
			_transform = gameObject.transform;
			_loader = new LoaderMax();
			_loader.addEventListener(Event.COMPLETE, onLoaded);
			_loader.load(new URLRequest(_url), null, true);
		}
		private function onLoaded(e : Event) : void
		{
			_loader.removeEventListener(Event.COMPLETE, onLoaded);
			_bitmapData = (_loader.content as Bitmap).bitmapData;
			_loader = null;//free resources
			View.addToView(this);
		}
		public function get bounds() : Rectangle
		{
			return new Rectangle(_transform.x - _bitmapData.rect.width * 0.5, _transform.y - _bitmapData.height * 0.5,
								 _transform.x + _bitmapData.rect.width * 0.5, _transform.y + _bitmapData.height * 0.5);
		}
	}
	
}