package com.battalion.flashpoint.comp 
{
	
	CONFIG::flashPlayer10
	{
		import com.battalion.flashpoint.display.View;
	}
	CONFIG::flashPlayer11
	{
		import com.battalion.flashpoint.display.ViewFlash11;
	}
	
	import com.battalion.flashpoint.core.*;
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
	 * Use the <code>url</code> property to load an image from an url
	 * or the static <code>load()</code> method, in case you want to use the bitmap more than once.
	 * Interacts with the <code><a href="../display/View.html">View</a></code> class.
	 * @see com.battalion.flashpoint.comp.Animation
	 * @see com.battalion.flashpoint.comp.Camera
	 * @see com.battalion.flashpoint.display.View
	 * @author Battalion Chiefs
	 */
	public final class Renderer extends Component implements IExclusiveComponent
	{
		
		/** @private **/
		internal static var _bitmaps : Object = { };
		/** @private **/
		internal static var _filterQueue : Object = { };
		
		public static function filterWhite(bitmapName : String) : void
		{
			filter(bitmapName, 0xFFFEFEFE, 0x00000000);
		}
		
		public static function filter(bitmapName : String, targetColor : uint, replacementColor : uint ) : void
		{
			var bitmap : BitmapData = _bitmaps[bitmapName];
			if (bitmap) bitmap.threshold(bitmap, bitmap.rect, new Point(), "==", targetColor, replacementColor);
			else
			{
				if (!_filterQueue[bitmapName]) _filterQueue[bitmapName] = new <Object>[{t:targetColor, r:replacementColor}];
				else _filterQueue[bitmapName].push( { t:targetColor, r:replacementColor } );
			}
		}
		public static function getBitmap(bitmapName : String) : BitmapData
		{
			return _bitmaps[bitmapName];
		}
		
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
		 * @see #setBitmapByName()
		 * @see #load()
		 * @see #draw()
		 * @see BitmapData.draw()
		 * @param	bitmapName, the name of the bitmap.
		 * @param	bitmapDrawable, the IBitmapDrawable to draw into a bitmap.
		 * @param	params, the optional parameters to be passed with the BitmapData.draw().
		 */
		public static function bake(bitmapName : String, bitmapDrawable : IBitmapDrawable, params : Object = null) : void
		{
			params = params || { };
			var matrix : Matrix = new Matrix();
			if (bitmapDrawable is BitmapData)
			{
				var dimensions : Point = new Point((bitmapDrawable as BitmapData).width, (bitmapDrawable as BitmapData).height);
			}
			else
			{
				dimensions = new Point((bitmapDrawable as DisplayObject).width, (bitmapDrawable as DisplayObject).height);
				var offset : Rectangle = (bitmapDrawable as DisplayObject).getBounds(null);
				matrix.translate(-offset.x, -offset.y);
			}
			if (params.matrix) matrix.concat(params.matrix);
			var data : BitmapData = new BitmapData(dimensions.x, dimensions.y, params.transparent == undefined || params.transparent, params.backgroundColor || 0);
			data.draw(bitmapDrawable, matrix, params.colorTransform || null, params.blendMode || null, params.clipRect || null, params.smoothing || null);
			_bitmaps[bitmapName] = data;
		}
		
		/**
		 * A quick way for drawing a simple circle, good for placeholders.
		 * @see draw()
		 * @param	bitmapName, the name that you plan on using to reference this box
		 * @param	radius, the radius of the circle in pixels, default is 25
		 * @param	color, a color code denoting the color of the circle, default is 0xFF0000 (red)
		 * @param	alpha, a number between 0 and 1 denoting the transparency of the circle, 0 = invisible, 1 = solid, default is 1
		 * @param	outlineThickness, a number denoting the thickness of the circle's outline in pixels, default is -1 (no outline)
		 * @param	outlineColor, a color code denoting the color of the circle's outline, default is 0 (black)
		 * @param	outlineAlpha, a number between 0 and 1 denoting the transparency of the circle's outline, 0 = invisible, 1 = solid, default is 1
		 */
		public static function drawCircle
		(
			bitmapName : String,
			radius : Number = 25,
			color : uint = 0xFF0000, alpha : Number = 1,
			outlineThickness : int = -1, outlineColor : uint = 0, outlineAlpha : Number = 1
		) : void
		{
			if (alpha > 0 && (outlineThickness < 0 || outlineAlpha <= 0))
			{
				Renderer.draw(bitmapName, "fill", { color:"0x" + color.toString(16), alpha:alpha},
				"circle", {radius:radius});
			}
			else if (alpha <= 0 && outlineThickness > -1 && outlineAlpha > 0)
			{
				Renderer.draw(bitmapName, "line", { thickness:outlineThickness, color:"0x" + outlineColor.toString(16), alpha:outlineAlpha},
				"circle", {radius:radius});
			}
			else
			{
				Renderer.draw(bitmapName,
				"line", { thickness:outlineThickness, color:"0x" + outlineColor.toString(16), alpha:outlineAlpha},
				"fill", { color:"0x" + color.toString(16), alpha:alpha },
				"circle", {radius:radius});
			}
		}
		/**
		 * A quick way for drawing a simple box, good for placeholders.
		 * @see draw()
		 * @param	bitmapName, the name that you plan on using to reference this box
		 * @param	width, the width of the box in pixels, default is 50
		 * @param	height, the height of the box in pixels, default is 50
		 * @param	color, a color code denoting the color of the box, default is 0xFF0000 (red)
		 * @param	alpha, a number between 0 and 1 denoting the transparency of the box, 0 = invisible, 1 = solid, default is 1
		 * @param	outlineThickness, a number denoting the thickness of the box's outline in pixels, default is -1 (no outline)
		 * @param	outlineColor, a color code denoting the color of the box's outline, default is 0 (black)
		 * @param	outlineAlpha, a number between 0 and 1 denoting the transparency of the box's outline, 0 = invisible, 1 = solid, default is 1
		 */
		public static function drawBox
		(
			bitmapName : String,
			width : Number = 50, height : Number = 50,
			color : uint = 0xFF0000, alpha : Number = 1,
			outlineThickness : int = -1, outlineColor : uint = 0, outlineAlpha : Number = 1
		) : void
		{
			
			if (alpha > 0 && (outlineThickness < 0 || outlineAlpha <= 0))
			{
				if (alpha * outlineAlpha == 1)
				{
					Renderer.draw(bitmapName, "background", 0,
					"fill", { color:"0x" + color.toString(16), alpha:alpha},
					-width * 0.5, -height * 0.5,
					width * 0.5, -height * 0.5,
					width * 0.5, height * 0.5,
					-width * 0.5, height * 0.5);
				}
				else
				{
					Renderer.draw(bitmapName,
					"fill", { color:"0x" + color.toString(16), alpha:alpha},
					-width * 0.5, -height * 0.5,
					width * 0.5, -height * 0.5,
					width * 0.5, height * 0.5,
					-width * 0.5, height * 0.5);
				}
			}
			else if (alpha <= 0 && outlineThickness > -1 && outlineAlpha > 0)
			{
				if (alpha * outlineAlpha == 1)
				{
					Renderer.draw(bitmapName, "background", 0,
					"line", { thickness:outlineThickness, color:"0x" + outlineColor.toString(16), alpha:outlineAlpha},
					-width * 0.5, -height * 0.5,
					width * 0.5, -height * 0.5,
					width * 0.5, height * 0.5,
					-width * 0.5, height * 0.5,
					-width * 0.5, -height * 0.5);
				}
				else
				{
					Renderer.draw(bitmapName,
					"line", { thickness:outlineThickness, color:"0x" + outlineColor.toString(16), alpha:outlineAlpha},
					-width * 0.5, -height * 0.5,
					width * 0.5, -height * 0.5,
					width * 0.5, height * 0.5,
					-width * 0.5, height * 0.5,
					-width * 0.5, -height * 0.5);
				}
			}
			else
			{
				if (alpha * outlineAlpha == 1)
				{
					Renderer.draw(bitmapName, "background", 0,
					"line", { thickness:outlineThickness, color:"0x" + outlineColor.toString(16), alpha:outlineAlpha},
					"fill", { color:"0x" + color.toString(16), alpha:alpha },
					-width * 0.5, -height * 0.5,
					width * 0.5, -height * 0.5,
					width * 0.5, height * 0.5,
					-width * 0.5, height * 0.5,
					-width * 0.5, -height * 0.5);
				}
				else
				{
					Renderer.draw(bitmapName,
					"line", { thickness:outlineThickness, color:"0x" + outlineColor.toString(16), alpha:outlineAlpha},
					"fill", { color:"0x" + color.toString(16), alpha:alpha },
					-width * 0.5, -height * 0.5,
					width * 0.5, -height * 0.5,
					width * 0.5, height * 0.5,
					-width * 0.5, height * 0.5,
					-width * 0.5, -height * 0.5);
				}
			}
		}
		
		/**
		 * Use this to draw bitmaps, works similearly to the native drawing API of flash.
		 * Firstly, it takes a name <code>bitmapName</code> parameter to use as a reference to the drawn bitmap.
		 * After that, comes all the drawing instructions.
		 * The instructions map almost directly to methods of the 
		 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html"><code>Graphics</code></a>
		 * class. So if you're not familiar with them, it's recommended that you take a look at them first.
		 * <p>
		 * Instructions are either Strings, Objects, Points or Numbers.
		 * Every Point or every two Numbers represent drawing coordinates,
		 * such as those passed with the <code>moveTo()</code>, <code>lineTo()</code> and <code>curveTo()</code> methods.
		 * Strings tells the Renderer what to do with the next instruction(s).
		 * Here are valid instructions and their effect:
		 * <ul>
		 * <li><b>"background"</b>, must be followed by a color code value representing the background color.
		 * Note that having a background means that it will have no transparancy (and therefor faster).</li>
		 * <li><b>"circle"</b>, must be followed by an Object containing the properties to be used as parameters
		 * for a <code>drawCircle()</code> or a <code>drawEllipse()</code> call.
		 * Specifying either width or height makes it an ellipse.</li>
		 * <li><b>"line"</b>, must be followed by an Object containing the properties to be used as parameters
		 * for a <code>lineStyle()</code> call.</li>
		 * <li><b>"fill"</b>, must be followed by an Object containing the properties to be used as parameters
		 * for a <code>beginFill()</code>, <code>beginBitmapFill()</code> or <code>beginGradientFill()</code> call.
		 * If you specify a <code>bitmap</code> property, <code>beginBitmapFill()</code> will be used.
		 * If you specify a <code>type</code> property, <code>beginGradientFill()</code> will be used.
		 * Else <code>beginFill()</code> will be used.</li>
		 * <li><b>"end"</b>, maps directly to the <code>endFill()</code> method.</li>
		 * <li><b>"move"</b>, must be followed by a drawing coordinate for a <code>moveTo()</code> call.</li>
		 * <li><b>"curve"</b>, must be followed by 2 drawing coordinates to use for a <code>curveTo()</code> call.</li>
		 * <li><b>Point</b>, a single drawing coordinate.</li>
		 * <li><b>Number</b>, either the x or y coordinate of a drawing coordinate, depending on which came first.</li>
		 * <li><b>Object</b>, see the "fill", "line" and "circle" instructions.</li>
		 * </ul>
		 * </p>
		 * <p>
		 * <b>Note:</b> You do not have to begin with a "move" instruction.
		 * The first drawing coordinate always represent coordinates for a <code>moveTo()</code> call.
		 * Do not put "curve", "end" or "move" before your first drawing coordinates.
		 * </p>
		 * 
		 * @example here's how to draw a simple gray box:<listing version="3.0">
Renderer.draw("myBox",
	"fill", { color:"0x555555" },
	-15, -20,
	15, -20,
	15, 20,
	-15, 20
);
		 * </listing>
		 * @example here's how to draw a simple red circle:<listing version="3.0">
Renderer.draw("myCircle",
	"fill", { color:"0xFF0000" },
	"circle", { x:10, y:10, radius:10}
);
		 * </listing>
		 * @example The same circle can be drawn like this:<listing version="3.0">
Renderer.draw("myCircle",
	"circle", { x:10, y:10, radius:10, fill:{ color:"0xFF0000" } }
);
		 * </listing>
		 * 
		 * @example The default position of a circle is the last drawing coordinate.
		 * Here's an example that shows what happens if you omit the x and y:<listing version="3.0">
Renderer.draw("myWeirdArrow",
	"line", {thickness:2},
	
	-20, 10,
	"circle", { radius:5, fill:{ color:"0xFF0000" } },
	
	0, 10,
	"circle", { radius:5, fill:{ color:"0xFF0000" } },
	
	20, 0,
	"circle", { radius:5, fill:{ color:"0x0000FF" } },
	
	0, -10,
	"circle", { radius:5, fill:{ color:"0xFF0000" } },
	
	-20, -10,
	"circle", { radius:5, fill:{ color:"0xFF0000" } }
);
		 * </listing>
		 * @see #setBitmapByName()
		 * @see #load()
		 * @see #bake()
		 * @param	bitmapName, the name of the drawn bitmap.
		 * @param	...instructions,  the drawing instructions to use.
		 */
		public static function draw(bitmapName : String, ...instructions) : void
		{
			var shape : Shape = new Shape();
			var graphics : Graphics = shape.graphics;
			var backgroundColor : int = -1;
			
			var background : Boolean = false;
			var moveTo : Boolean = true;
			var fill : Boolean = false;
			var line : Boolean = false;
			var circle : Boolean = false
			var curve : Boolean = false
			var curveAnchor : Point = null;
			var prevNumber : Number = NaN;
			var prevPoint : Point = new Point(0, 0);
			var prevFill : Object = null;
			var prevLine : Object = { };
			
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
				else if (instruction is uint && background)
				{
					backgroundColor = instruction;
				}
				background = false;
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
							prevFill = null;
							break;
						case "line":
							line = true;
							break;
						case "curve":
							curve = true;
							break;
						case "circle":
							circle = true;
							break;
						case "background":
							background = true;
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
					prevPoint = point;
				}
				else if (line)
				{
					line = false;
					graphics.lineStyle(instruction.thickness || null, instruction.color || 0, instruction.alpha || instruction.alpha == undefined || 0, instruction.pixelHinting || false, instruction.scaleMode || "normal", instruction.caps || null, instruction.joints || null, instruction.miterLimit || 3)
					prevLine = instruction;
				}
				else if (fill)
				{
					fill = false;
					if (instruction.bitmap)
					{
						graphics.beginBitmapFill(instruction.bitmap, instruction.matrix || null, instruction.repeat as Boolean, instruction.smooth || false);
					}
					else if (instruction.type)
					{
						graphics.beginGradientFill(instruction.type, instruction.colors || [0, 1], instruction.alphas || [1, 1], instruction.ratios || [0, 1], instruction.matrix || null, instruction.spreadMethod || "pad", instruction.interpolationMethod || "rgb", instruction.focalPointRatio || 0);
					}
					else
					{
						graphics.beginFill(instruction.color || 0, instruction.alpha || instruction.alpha == undefined || 0);
					}
					prevFill = instruction;
				}
				else if (circle)
				{
					circle = false;
					if (instruction.fill)
					{
						var temp : Object = instruction;
						instruction = instruction.fill;
						if (instruction.bitmap)
							graphics.beginBitmapFill(instruction.bitmap, instruction.matrix || null, instruction.repeat as Boolean, instruction.smooth || false);
						else if (instruction.type)
							graphics.beginGradientFill(instruction.type, instruction.colors || [0, 1], instruction.alphas || [1, 1], instruction.ratios || [0, 1], instruction.matrix || null, instruction.spreadMethod || "pad", instruction.interpolationMethod || "rgb", instruction.focalPointRatio || 0);
						else
							graphics.beginFill(instruction.color || 0, instruction.alpha || instruction.alpha == undefined || 0);
						instruction = temp;
					}
					if (instruction.line)
					{
						temp = instruction;
						instruction = instruction.line;
						graphics.lineStyle(instruction.thickness || null, instruction.color || 0, instruction.alpha || instruction.alpha == undefined || 0, instruction.pixelHinting || false, instruction.scaleMode || "normal", instruction.caps || null, instruction.joints || null, instruction.miterLimit || 3)
						instruction = temp;
					}
					if (instruction.width || instruction.height)
					{
						graphics.drawEllipse(instruction.x || prevPoint.x, instruction.y || prevPoint.y, instruction.width || instruction.radius || (instruction.width == undefined && instruction.radius == undefined) || 0, instruction.height || instruction.radius || (instruction.height == undefined && instruction.radius == undefined) || 0);
					}
					else
					{
						graphics.drawCircle(instruction.x || prevPoint.x, instruction.y || prevPoint.y, instruction.radius || 1);
					}
					if (instruction.line)
					{
						temp = instruction;
						instruction = prevLine;
						graphics.lineStyle(instruction.thickness || null, instruction.color || 0, instruction.alpha || instruction.alpha == undefined || 0, instruction.pixelHinting || false, instruction.scaleMode || "normal", instruction.caps || null, instruction.joints || null, instruction.miterLimit || 3)
						instruction = temp;
					}
					if (instruction.color || instruction.alpha)
					{
						if (!prevFill)
						{
							graphics.endFill();
						}
						else
						{
							instruction = prevFill;
							if (instruction.bitmap)
								graphics.beginBitmapFill(instruction.bitmap, instruction.matrix || null, instruction.repeat as Boolean, instruction.smooth || false);
							else if (instruction.type)
								graphics.beginGradientFill(instruction.type, instruction.colors || [0, 1], instruction.alphas || [1, 1], instruction.ratios || [0, 1], instruction.matrix || null, instruction.spreadMethod || "pad", instruction.interpolationMethod || "rgb", instruction.focalPointRatio || 0);
							else
								graphics.beginFill(instruction.color || 0, instruction.alpha || instruction.alpha == undefined || 0);
						}
					}
				}
			}
			bake(bitmapName, shape, { smoothing:true , transparent:backgroundColor < 0, backgroundColor:backgroundColor < 0 ? null : backgroundColor} );
		}
		/**
		 * Call this method in order to load a bitmap and use it multiple times in your game
		 * by simply giving it a name, and referencing that name.
		 * After you have called this method, it's safe to call the <code>setBitmapByName()</code> method on a Renderer instance.
		 * It will wait for the bitmap to load and then display it as soon as it's loaded.
		 * @see #setBitmapByName()
		 * @see #bake()
		 * @see #draw()
		 * @param	bitmapName, the name that you will use for the bitmap. If a bitmap already has this name, it will be overridden.
		 * @param	url, the url of the bitmap to load.
		 */
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
		 * In case you don't want the bitmap to be centered about the GameObject's center.
		 */
		public var offset : Matrix = null;
		
		
		/**
		 * Set this property right before adding the component, in order for it to work.
		 */
		public var pixelSnapping : String = PixelSnapping.NEVER;
		
		/**
		 * Set this property right before adding the component, in order for it to work.
		 */
		public var smoothing : Boolean = false;
		
		/**
		 * Set this property to true in order to skip rotation, scaling and shearing
		 * transformations in the final rendered bitmap to improve performance.
		 */
		public var optimized : Boolean = false;
		
		/**
		 * Setting this property will not take effect until you set the updateBitmap property to true.
		 * It is recommended to use the <code>url</code> property or the <code>setBitmapByName()</code> method insteaad.
		 */
		public var bitmapData : BitmapData = null;
		
		/**
		 * Setting the bitmapData property will not take effect until you set this property to true.
		 * It is recommended to use the url property insteaad.
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
			CONFIG::flashPlayer10
			{
				View.addToView(this);
			}
			CONFIG::flashPlayer11
			{
				ViewFlash11.addToView(this);
			}
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
			CONFIG::debug
			{
				if (!_bitmaps[bitmapName])
				{
					throw new Error("the bitmap '" + bitmapName + "' is not defined, please load, draw or bake a bitmap with that name before calling this method.");
				}
			}
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
		/**
		 * Puts this Renderer in front of the <code>other</code> Renderer.
		 * @param	other, the Renderer that should be behind this.
		 */
		public function putInFrontOf(other : Renderer) : void
		{
			other.putBehind(this);
			updateBitmap = true;
		}
		/**
		 * Puts this Renderer behind the <code>other</code> Renderer.
		 * @param	other, the Renderer that should be in front of this.
		 */
		public function putBehind(other : Renderer) : void
		{
			if (rendererInFrontOfThis && rendererInFrontOfThis.isDestroyed)
			{
				other.putBehind(rendererInFrontOfThis);
			}
			rendererInFrontOfThis = other;
			updateBitmap = true;
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
			offset = null;
			pixelSnapping = null;
			_url = null;
			_transform = null;
			sprites = { };
			rendererInFrontOfThis = null;
			CONFIG::flashPlayer10
			{
				View.removeFromView(this);
			}
			CONFIG::flashPlayer11
			{
				ViewFlash11.removeFromView(this);
			}
			return false;
		}
		/**
		 * The bounding rectangle of the Renderer in world space.
		 */
		public function get bounds() : Rectangle
		{
			if (!bitmapData) return new Rectangle(NaN, NaN, NaN, NaN);
			var m : Matrix = _transform.globalMatrix;
			var cos : Number = m.a;
			var sin : Number = m.b;
			if (cos < 0) cos = -cos;
			if (sin < 0) sin = -sin;
			var width : Number = (cos * bitmapData.width) + (sin * bitmapData.height);
			var height : Number = (sin * bitmapData.width) + (cos * bitmapData.height);
			return new Rectangle(m.tx - width * 0.5, m.ty - height * 0.5, width, height);
		}
	}
	
}