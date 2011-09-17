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
	 * Basic Renderer component. Renders a Bitmap image.<br/>
	 * Use the <code>url</code> property to load an image from an url.
	 * Interacts with the <code>View</code> class.
	 * @see View
	 * @author Battalion Chiefs
	 */
	public final class Renderer extends Component implements IExclusiveComponent
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
		
		/** @private **/
		public function awake() : void
		{
			_transform = gameObject.transform;
			View.addToView(this);
		}
		/**
		 * URL of the bitmap image to render. Can be both an individual image url or a spritesheet url.
		 * 
		 * A spritesheet url is written in the folowing format:
		 * @usage "imageURL.imageFormat~spriteSheetIndex~alternativeURL"
		 * To get the second bitmap of a spritesheet at "imgages/mySpriteSheet.png" one should write:
		 * @example "images/mySpriteSheet.png~2~"
		 * To make "images/fallback.png" an alternative to the bitmap mentioned above one should write:
		 * @example "images/mySpriteSheet.png~2~images/fallback.png"
		 * @see LoaderMax
		 * @see SpriteSheet
		 */
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
			sendMessage("rendererLoaded", this);
		}
		/** @private **/
		public function onDestroy() : Boolean
		{
			bitmapData = null;
			return false;
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