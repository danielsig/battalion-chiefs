package com.danielsig.geomcode
{
	import com.danielsig.StringUtilPro;
	import flash.display.Loader;
	import flash.net.*;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * A GeomCode parser. Use this class in order to parse and execute GeomCode.
	 * GeomCode files have a <b>.gmc</b> extension.
	 * In Debug mode, the syntax is roughly checked for common syntax errors.
	 * In Release mode, the syntax is <b>not</b> checked for any errors.
	 * 
	 * GeomCode is a programming language designed specifically for the creation of solid geometry.
	 * Every method you specify in GeomCode creates and returns a geometry.
	 * Even an empty method still returns a geometry; an empty geometry.
	 * GeomCode basicly does not create the actual geometry, it will call the <code>create()</code>
	 * method for every geometry it wants to be created and uses the returned value as the object.
	 * You can then change that object's properties within GeomCode.
	 * 
	 * <b>Syntax</b>
	 * The syntax is pretty simple, it has almost every operator that actionscript has except bitwise operators.
	 * Here's a list of operators and their operation:
		 * +	addition
		 * -	subtraction
		 * *	multiplication
		 * /	division
		 * %	modulo
		 * ++	increment (both post increment and pre increment)
		 * --	decrement (both post decrement and pre decrement)
		 * =	assignment
		 * +=	addition assignment
		 * -=	subtraction assignment
		 * *=	multiplication assignement
		 * /=	division assignment
		 * %=	modulo assignemnt
		 * &&	logical and
		 * ||	logical or
		 * &&=	logical and assignment
		 * ||=	logical or assignment
		 * !	logical not
		 * ==	equality
		 * !=	inequality
		 * >	greater than
		 * <	less than
		 * >=	greater than or equals
		 * <=	less than or equals
	 * Parameters in GeomCode work like assignements, so every parameter must have a default value.
	 * Here's an example of a geometry made in GeomCode:
		* <example>
		* Stick( length = 10, width = 1 ) { }
		* </example>
	 * And here's an example of how you use it:
		 * <example>
		 * Fence(numSticks = 10; numSticks > 0; numSticks--)
		 * {
		 * 	Stick;
		 * 	pos.x++;
		 * }
		 * </example>
	 * Basicly the Fence geometry...
		 * creates a Stick at it's position
		 * moves itself one unit to the right
		 * repeats until 10 sticks have been made
	 * Does that header remind you something?... for-loops maybe? That's what's called a geometry loop
	 * There are only two ways to create loops in GeomCode, recursions and geometry loops.
	 * While recursions will make every subsequent geometry a child of it's preceding geometry,
	 * a geometry loop will make every geometry a child of the first iteration.
	 * example:
		 * Recursion:
			 * World
			 * 	Fence
			 * 		Stick
			 * 		Fence
			 * 			Stick
			 * 			Fence
			 * 				Stick
			 * 				Fence
			 * 					Stick
			 * 					...
		 * Geometry loop:
			 * World
			 * 	Fence
			 * 		Stick
			 * 		Fence
			 * 			Stick
			 * 		Fence
			 * 			Stick
			 * 		Fence
			 * 			Stick
			 * 		...
			 * 		
	 * @author Daniel Sig
	 */
	public final class GeomCode
	{
		
		/** @private **/
		internal var geometries : Vector.<GeomInstruction>;
		/** @private **/
		internal var geometryNames : Vector.<String>;
		
		private var _source : String;
		
		private var _constructionQueue : Vector.<String>;
		private var _constructionQueueParams : Vector.<Object>;
		
		private var _urls : Dictionary = new Dictionary();
		
		/** @private **/
		internal var create : Function;
		/** @private **/
		internal var update : Function;
		/** @private **/
		internal var complete : Function;
		/** @private **/
		internal var clone : Function;
		/** @private **/
		internal var loadImage : Function;
		/** @private **/
		internal var tileMap : Function;
		/** @private **/
		internal var tileMapOffset : Function;
		/** @private **/
		internal var tileSet : Function;
		
		public static function checkSyntax(sourceCode : String) : String
		{
			sourceCode = sourceCode.replace(/\r/g, "\n");
			sourceCode = sourceCode.replace(/\/\/[^\n\r\v]*/g, "");//remove comments
			sourceCode = sourceCode.replace(/(\/\*(?:[^\*]|\*[^\/])*\*\/)/g, removeComments);//remove block comments
			sourceCode = sourceCode.replace(/[\t ]+/g, " ");//remove extra spaces
			sourceCode = sourceCode.replace(/( ?)([^0-9a-zA-Z ])( ?)/g, removeSpace);//remove unnecessary spaces
			var blocks : Vector.<String> = getBlocks(sourceCode, true);
			var newBlocks : Vector.<String> = new Vector.<String>();
			for each(var block : String in blocks)
			{
				if (StringUtilPro.reverseCharAt(block, 0) == ")") newBlocks.push(block);
				else newBlocks = newBlocks.concat(splitSyntax(block));
			}
			return verifySyntax(newBlocks);
		}
		private static function removeComments() : String
		{
			return (arguments[1] as String).replace(/[^\n]/g, "");
		}
		private static function verifySyntax(blocks : Vector.<String>) : String
		{
			var line : uint = 1;
			for (var i : uint = 0; i < blocks.length; i++)
			{
				var block : String = blocks[i];
				if (/[{}]/.test(block))
				{
					return "\nSyntax Error:\t" + (i ? blocks[i-1] : block) + "\nLine:\t\t" + line + "\nFile:\t\t";
				}
				else if (block == "/" && i + 1 < blocks.length && blocks[i + 1] == "*")
				{
					return "\nSyntax Error:\t /* \nLine:\t\t" + line + "\nFile:\t\t";
				}
				else if(block != "\n")
				{
					var char : String = block.slice(0, block.search(/[\({ ="']/));
					if (block.charAt(char.length) != "=")
					{
						if (!(/[A-Z].*/.test(char) || char == "if" || char == "else" || char == "discrete" || char == "clone" || char == "load" || char == "using"))
						{
							return "\nSyntax Error:\t" + block + "\nLine:\t\t" + line + "\nFile:\t\t";
						}
					}
					char = block.charAt(block.length - 1);
					if(!(char == ")" || char == ";" || block == "\n")) return "\nSyntax Error:\t" + block + "\nLine:\t\t" + line + "\nFile:\t\t";
				}
				
				var parenthesis : int = 0;
				var quotes : int = 0;
				var length : uint = block.length;
				for (var j : uint = 0; j < length; j++)
				{
					char = block.charAt(j);
					if (!quotes && char == "(" || char == "," || char == "=")
					{
						var chars : String = block.slice(j, j + 2);
						if (!/\([\-\+\(\)a-z0-9'"! \n]|,[\-\+\(a-z0-9'"! \n]|=[=\-\+\(a-z0-9'"! \n]/.test(chars))
						{
							parenthesis = -10;
						}
					}
					if (char == "(") parenthesis++;
					else if (char == ")") parenthesis--;
					else if (char == '"' && quotes >= 0) quotes = int(!Boolean(quotes));
					else if (char == "'" && quotes <= 0) quotes = -int(!Boolean(quotes));
					else if (char == "\n") line++;
					else if (char == "/" && j && block.charAt(j - 1) == "*") parenthesis = -1;
					else if (!quotes)
					{
						if (/[^_\-\+\*\/\%\?\:;!<>=\.\,\|\(\){}a-zA-Z0-9\t\v\r ]/.test(char)) parenthesis = -1;
					}
					if (parenthesis < 0) break;
				}
				if (parenthesis)
				{
					block = block.slice(block.lastIndexOf("\n", j) + 1, block.indexOf("\n", j));
					return "\nSyntax Error:\t" + block + "\nLine:\t\t" + line;
				}
			}
			return null;
		}
		private static function splitSyntax(sourceCode : String, safety : int = 16) : Vector.<String>
		{
			if (sourceCode.indexOf("using ")) sourceCode = GeomInstruction.removeBlockContainer(sourceCode, "{", "}", " ", ";");
			var blocks : Vector.<String> = getBlocks(sourceCode, false);
			if (!safety) return blocks;
			var newBlocks : Vector.<String> = new Vector.<String>();
			for each(var block : String in blocks)
			{
				if (StringUtilPro.reverseCharAt(block, 0) == ")") newBlocks.push(block);
				else newBlocks = newBlocks.concat(splitSyntax(block, safety-1));
			}
			return newBlocks;
		}
		private static function getBlocks(sourceCode : String, root : Boolean = false) : Vector.<String>
		{
			var blocks : Vector.<String> = new Vector.<String>();
			var block : int = 0;
			var parenthesis : int = 0;
			var quotes : int = 0;
			var length : uint = sourceCode.length;
			var prevIndex : uint = 0;
			for (var i : uint = 0; i < length; i++)
			{
				var char : String = sourceCode.charAt(i);
				if (!block && parenthesis < 0)
				{
					if (!blocks.length)
					{
						blocks.push(i ? sourceCode.slice(0, i) : "");
					}
					else blocks[blocks.length - 1] += sourceCode.charAt(i-1);
					parenthesis = 0;
					continue;
				}
				if (char == "{") block++;
				else if (char == "}") block--;
				if (!block)
				{
					if (char == "(") parenthesis++;
					else if (char == ")") parenthesis--;
					else if (char == '"' && quotes >= 0) quotes = int(!Boolean(quotes));
					else if (char == "'" && quotes <= 0) quotes = -int(!Boolean(quotes));
					if (!(block | parenthesis | quotes))
					{
						var charCode : int = char.charCodeAt(0);
						if (root)
						{
							if (charCode > 64 && charCode < 91)
							{
								i = sourceCode.indexOf("(", i) - 1;
								continue;
							}
							else if (charCode > 96 && charCode < 123) i = sourceCode.indexOf(";", i);
						}
						else if ((charCode > 64 && charCode < 91) || (charCode > 96 && charCode < 123))
						{
							var end : int = sourceCode.indexOf("(", i);
							if (end < 0) end = int.MAX_VALUE;
							i = sourceCode.indexOf("{", i);
							if (i < 0) i = int.MAX_VALUE;
							if (end < i) i = end;
							if (end == int.MAX_VALUE && i == int.MAX_VALUE) i = sourceCode.indexOf(";", prevIndex);
							i--;
							continue;
						}
						if (i + 1 < length && sourceCode.charAt(i + 1) == ";") i++;
						blocks.push(sourceCode.slice(prevIndex, i+1));
						prevIndex = i+1;
					}
				}
			}
			if(prevIndex < length) blocks.push(sourceCode.slice(prevIndex));
			return blocks;
		}
		
		/**
		 * Instantiate a GeomCode parser.
		 * @param	source, either the source code or an url to the source code.
		 * @param	create, the function that's called to create a geometry
		 * @param	clone, the function that's called to dublicate a geometry
		 * @param	update, the function that's called every time a geometry's properties are changed.
		 * @param	complete, the function that's called when creation of a geometry is complete.
		 * @param	loadImage, the function that's called when the load command is executed.
		 */
		public function GeomCode(source : String, create : Function, clone : Function,
		update : Function = null, complete : Function = null, loadImage : Function = null,
		tileMap : Function = null, tileMapOffset : Function = null, tileSet : Function = null)
		{
			this.create = create;
			this.clone = clone;
			this.update = update;
			this.complete = complete;
			this.loadImage = loadImage;
			this.tileMap = tileMap;
			this.tileMapOffset = tileMapOffset;
			this.tileSet = tileSet;
			
			if (StringUtilPro.endsWith(source, ".gmc"))
			{
				_source = "";
				load(source);
			}
			else
			{
				_source = source;
				verifyRequirements();
			}
		}
		public function resetFunctions(create : Function, clone : Function,
		update : Function = null, complete : Function = null, loadImage : Function = null,
		tileMap : Function = null, tileMapOffset : Function = null, tileSet : Function = null) : void
		{
			this.create = create;
			this.clone = clone;
			this.update = update;
			this.complete = complete;
			this.loadImage = loadImage;
			this.tileMap = tileMap;
			this.tileMapOffset = tileMapOffset;
			this.tileSet = tileSet;
		}
		public function construct(geometry : String, params : Object = null) : void
		{
			if (geometries)
			{
				var index : uint = geometryNames.indexOf(geometry);
				geometries[index].run(params);
			}
			else 
			{
				if (!_constructionQueue)
				{
					_constructionQueue = new <String>[geometry];
					_constructionQueueParams = new <Object>[params];
				}
				else
				{
					_constructionQueue.push(geometry);
					_constructionQueueParams.push(params);
				}
			}
		}
		private function load(url : String) : void
		{
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			_urls[loader] = url;
			loader.load(new URLRequest(url));
		}
		private function onLoadComplete(e : Event) : void
		{
			e.target.removeEventListener(Event.COMPLETE, onLoadComplete);
			CONFIG::debug
			{
				var errorMessage : String = checkSyntax(e.target.data);
				if (errorMessage) throw new Error(errorMessage + _urls[e.target] + "\nFile:\t\t\n\n");
				delete _urls[e.target];
			}
			_source += String(e.target.data);
			verifyRequirements();
			//trace(this);
		}
		private function verifyRequirements() : void
		{
			var using : Vector.<String> = new Vector.<String>();
			var index : int = 0;
			while (index != -1)
			{
				index = _source.indexOf("using ", index);
				if (index < 0) break;
				var end : int = _source.indexOf(";", index);
				var start : int = _source.lastIndexOf(" ", end)+1;
				if (end != -1 && start != -1)
				{
					using.push(_source.slice(start, end).replace(/\./g, "/") + ".gmc");
				}
				else break;
				index = end;
			}
			if (using.length)
			{
				_source = _source.replace(/using [^;]+;[ \t\n\r\v]*/g, "");
				for each(var url : String in using)
				{
					load(url);
				}
			}
			else compile();
		}
		private function compile() : void
		{
			_source = _source.replace(/\/\*([^\*]|\*[^\/])*\*\/|\/\/[^\n\r\v]*/g, "");//remove comments
			_source = _source.replace(/[\t\n\r\v ]+/g, " ");//remove extra spaces
			_source = _source.replace(/( ?)([^0-9a-zA-Z ])( ?)/g, removeSpace);//remove unnecessary spaces
			var geoms : Vector.<String> = new Vector.<String>();
			var preloads : Vector.<String> = new Vector.<String>();
			while (_source.length)
			{
				var block : Array = GeomInstruction.getBlock(_source, "{", "}");
				var start : int = _source.indexOf("(");
				if (start > block[1]) start = block[1];
				start = _source.lastIndexOf(";", start);
				if (start > -1)
				{
					var preload : Array = _source.slice(0, start).split(";");
					for each(var geom : String in preload) preloads.push(geom);
				}
				geom = _source.slice(start + 1, block[2]);
				geoms.push(geom);
				_source = _source.slice(block[2]);
			}
			var length : uint = geoms.length;
			geometries = new Vector.<GeomInstruction>(length);
			geometryNames = new Vector.<String>(length);
			for (var i : uint = 0; i < length; i++)
			{
				geometries[i] = new GeomInstruction();
				geometryNames[i] = geoms[i].slice(0, geoms[i].search(/\(|{/));
			}
			for (i = 0; i < length; i++)
			{
				geometries[i].apply(geoms[i], this, true);
			}
			for each(geom in preloads)
			{
				(new GeomInstruction(geom, this)).run();
			}
			//trace(this);
			if (_constructionQueue)
			{
				for (i = 0; i < _constructionQueue.length; i++)
				{
					construct(_constructionQueue[i], _constructionQueueParams[i]);
				}
				_constructionQueue = null;
				_constructionQueueParams = null;
			}
		}
		private static function removeSpace() : String
		{
			//trace("[" + arguments[1] + "][" + arguments[2] + "][" + arguments[3] + "]");
			return arguments[2];
		}
		public function toString() : String
		{
			var string : String = "";
			for each(var constructor : GeomInstruction in geometries)
			{
				string += constructor.toString() + "\n";
			}
			return string;
		}
	}

}