package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.display.View;
	import com.danielsig.LoaderMax;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.events.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class Renderer extends Component 
	{
		
		/**
		 * in case you don't want the bitmap to be centered about the GameObject's center.
		 */
		public var offset : Matrix = null;
		
		/**
		 * set this property right before adding the component, in order for it to work.
		 */
		public var pixelSnapping : String = PixelSnapping.NEVER;
		
		/**
		 * set this property right before adding the component, in order for it to work.
		 */
		public var smoothing : Boolean = false;
		
		/**
		 * setting this property will not take effect until you set the updateBitmap property to true.
		 * it is recommended to use the url property insteaad.
		 */
		public var bitmapData : BitmapData = null;
		
		/**
		 * setting the bitmapData property will not take effect until you set this property to true.
		 * it is recommended to use the url property insteaad.
		 */
		public var updateBitmap : Boolean = false;
		
		private var _url : String = null;
		private var _loader : LoaderMax;
		private var _transform : Transform;//just for convenience
		
		public function awake() : void
		{
			_transform = gameObject.transform;
			View.addToView(this);
		}
		public function get url() : String
		{
			return _url;
		}
		public function set url(value : *) : void
		{
			_url = value;
			load();
		}
		private function load() : void 
		{
			_loader = new LoaderMax();
			_loader.addEventListener(Event.COMPLETE, onLoaded);
			_loader.load(new URLRequest(_url), null, true);
		}
		private function onLoaded(e : Event) : void
		{
			_loader.removeEventListener(Event.COMPLETE, onLoaded);
			bitmapData = (_loader.content as Bitmap).bitmapData;
			_loader = null;//free resources
			updateBitmap = true;
		}
		/**
		 * This method is not correct when any other transformation other than translation has been applied to the GameObject or it's parents.
		 */
		public function get bounds() : Rectangle
		{
			return bitmapData == null ? new Rectangle(Infinity, Infinity) : new Rectangle(_transform.x - bitmapData.width * 0.5, _transform.y - bitmapData.height * 0.5,
								 _transform.x + bitmapData.width * 0.5, _transform.y + bitmapData.height * 0.5);
		}
	}
	
}