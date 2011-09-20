package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.display.View;
	import com.danielsig.LoaderMax;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
		
		/** @private **/
		internal static var _bitmaps : Object = { };
		
		/**
		 * Use this to bake a <code>DisplayObject</code> or a <code>BitmapData</code> object to a <code>BitmapData</code> with the name <code>bitmapName</code>.
		 * The results can be rendererd by a <code>Renderer</code> instance by calling the <code>setBitmapByName()</code> method
		 * and passing the name of the bitmap as a parameter.
		 * <p>
		 * This method uses the <code>BitmapData.draw()</code> method to draw the <code>bitmapDrawable</code> onto a <code>BitmapData</code> object.
		 * The params object represents the optional parameters of the <code>BitmapData.draw()</code> method.
		 * </p>
		 * @example Here's an example of how to turn on smoothing (the last parameter of the <code>BitmapData.draw()</code> method):<listing version="3.0">
		 * Renderer.bake("myBakeName", myBitmapDrawable, {smoothing:true});
		 * </listing>
		 * @see BitmapData.draw()
		 * @param	bitmapName
		 * @param	bitmapDrawable
		 * @param	params, the optional parameters to be passed with the BitmapData.draw().
		 */
		public static function bake(bitmapName : String, bitmapDrawable : IBitmapDrawable, params : Object = null) : void
		{
			params = params || { };
			if (bitmapDrawable is BitmapData)
			{
				var dimensions : Point = new Point((bitmapDrawable as BitmapData).width, (bitmapDrawable as BitmapData).height);
			}
			else
			{
				dimensions = new Point((bitmapDrawable as DisplayObject).width, (bitmapDrawable as DisplayObject).height);
			}
			var data : BitmapData = new BitmapData(dimensions.x, dimensions.y, true, 0);
			data.draw(bitmapDrawable, null || params.matrix, null || params.colorTransform, null || params.blendMode, null || params.clipRect, null || params.smoothing);
			_bitmaps[bitmapName] = data;
		}
		public static function draw(bitmapName : String, ...instructions) : void
		{
			var shape : Shape = new Shape();
			var graphics : Graphics = shape.graphics;
			var moveTo : Boolean = true;
			var fill : Boolean = false;
			var line : Boolean = false;
			var curve : Boolean = false
			var curveAnchor : Point = null;
			var prevNumber : Number = NaN;
			for each(var instruction : * in instructions)
			{
				if (instruction is Number)
				{
					if (isNaN(prevNumber))
					{
						prevNumber = instruction as Number;
						continue;
					}
					else
					{
						instruction = new Point(prevNumber, instruction as Number);
					}
				}
				prevNumber = NaN;
				var point : Point = instruction as Point;
				if (instruction is String)
				{
					switch(instruction as String)
					{
						case "move":
							moveTo = true;
							break;
						case "fill":
							fill = true;
							break;
						case "end":
							graphics.endFill();
							break;
						case "line":
							line = true;
							break;
						case "curve":
							curve = true;
							break;
					}
				}
				else if (point)
				{
					if (moveTo)
					{
						moveTo = false;
						graphics.moveTo(point.x, point.y);
					}
					else if (curve)
					{
						if (!curveAnchor)
						{
							curveAnchor = point;
						}
						else
						{
							graphics.curveTo(point.x, point.y, curveAnchor.x, curveAnchor.y);
							curveAnchor = null;
							curve = false;
						}
					}
					else
					{
						graphics.lineTo(point.x, point.y);
					}
				}
				else if (line)
				{
					line = false;
					graphics.lineStyle(null || instruction.thickness, 0 || instruction.color, instruction.alpha || 1, false || instruction.pixelHinting, instruction.scaleMode || "normal", null || instruction.caps, null || instruction.joints, instruction.miterLimit || 3)
				}
				else if (fill)
				{
					fill = false;
					if (instruction.bitmap)
					{
						graphics.beginBitmapFill(instruction.bitmap, null || instruction.matrix, instruction.repeat as Boolean, false || instruction.smooth);
					}
					else if (instruction.type)
					{
						graphics.beginGradientFill(instruction.type, instruction.colors || [0, 1], instruction.alphas || [1, 1], instruction.ratios || [0, 1], null || instruction.matrix, instruction.spreadMethod || "pad", instruction.interpolationMethod || "rgb", 0 || instruction.focalPointRatio);
					}
					else
					{
						graphics.beginFill(0 || instruction.color, instruction.alpha || 1);
					}
				}
			}
			bake(bitmapName, shape, { smoothing:true } );
		}
		
		public static function load(bitmapName : String, url : String) : void
		{
			var imageLoader : ImageLoader = new ImageLoader();
			imageLoader.name = bitmapName;
			_bitmaps[bitmapName] = imageLoader;
			
			var loader : LoaderMax = new LoaderMax();
			loader.addEventListener(Event.COMPLETE, imageLoader.onNamedBitmapLoaded);
			loader.load(new URLRequest(url), null, true);
		}
		
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
		
		/** @private **/
		public var rendererInFrontOfThis : Renderer = null;
		/** @private **/
		public var sprites : Object = {};

		
		private var _url : String = null;
		private var _transform : Transform;//just for convenience
		
		/** @private **/
		public function awake() : void
		{
			var front : Renderer = gameObject.findComponentUpwards(Renderer);
			if (front) putInFrontOf(front);
			
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
			startLoading();
		}
		/**
		 * Changes the bitmap to a bitmap that is loading or has been loaded with the static <code>load()</code> method.
		 * @see load()
		 * @param	bitmapName, the name of the bitmap
		 */
		public function setBitmapByName(bitmapName : String) : void
		{
			if (_bitmaps[bitmapName] is BitmapData)
			{
				bitmapData = _bitmaps[bitmapName];
				updateBitmap = true;
			}
			else
			{
				_bitmaps[bitmapName].subscribe(this);
			}
		}
		
		public function putInFrontOf(renderer : Renderer) : void
		{
			renderer.putBehind(this);
		}
		public function putBehind(renderer : Renderer) : void
		{
			if (rendererInFrontOfThis)
			{
				renderer.putBehind(rendererInFrontOfThis);
			}
			rendererInFrontOfThis = renderer;
		}
		
		private function startLoading() : void 
		{
			var loader : LoaderMax = new LoaderMax();
			loader.addEventListener(Event.COMPLETE, onLoaded);
			loader.load(new URLRequest(_url), null, true);
		}
		private function onLoaded(e : Event) : void
		{
			e.target.removeEventListener(Event.COMPLETE, onLoaded);
			bitmapData = (e.target.content as Bitmap).bitmapData;
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