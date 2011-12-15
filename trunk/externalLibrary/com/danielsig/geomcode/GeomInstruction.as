package com.danielsig.geomcode
{
	import com.danielsig.*;
	import flash.geom.Point;
	
	/**
	 * @private
	 * @author Daniel Sig
	 */
	internal final class GeomInstruction 
	{
		
		internal static const UNDEFINED : uint = uint.MAX_VALUE;
		internal static const CONSTRUCTOR : uint = 0;
		internal static const CREATE : uint = 1;
		internal static const CLONE : uint = 2;
		internal static const SET : uint = 3;
		internal static const IF : uint = 4;
		internal static const ELSE : uint = 5;
		internal static const ELSE_IF : uint = 6;
		internal static const DISCRETE : uint = 7;
		internal static const DISCRETE_IF : uint = 8;
		internal static const TRACE : uint = 9;
		internal static const LOAD_IMAGE : uint = 10;
		
		internal var type : uint = UNDEFINED;
		internal var eval : Function = null;
		internal var evalEval : SimpleEval = null;
		internal var name : String = null;
		internal var constructor : GeomInstruction = null;
		
		internal var params : Vector.<GeomInstruction> = null;
		internal var loopCondition : Function = null;//eval function
		internal var loopConditionEval : SimpleEval = null;//eval
		internal var loopParams : Vector.<GeomInstruction> = null;
		
		internal var root : GeomCode = null;
		
		internal var instructions : Vector.<GeomInstruction> = null;
		
		public function run(parameters : Object = null) : void
		{
			parameters = parameters || { };
			var stackCounter : Vector.<uint> = new <uint>[0];
			var stackGeom : Vector.<GeomInstruction> = new <GeomInstruction>[this];
			var stackLocal : Vector.<Object> = new <Object>[{thisObj:null, geom:{iterating:0}}];
			var height : uint = 0;
			var elseTrue : Boolean = false;
			while (stackGeom.length)
			{
				var target : GeomInstruction = stackGeom[height];
				var counter : uint = stackCounter[height];
				var local : Object = stackLocal[height];
				if (!counter)
				{
					switch(target.type)
					{
						case UNDEFINED:
							elseTrue = false;
							break;
						case CONSTRUCTOR:
							elseTrue = false;
							var paramsObj : Object = {};
							for each(var param : GeomInstruction in target.params)
							{
								paramsObj[param.name] = param.eval(paramsObj);
							}
							for (var paramName : String in parameters)
							{
								paramsObj[paramName] = parameters[paramName];
							}
							var parentLocal : Object = local;
							
							var newLocal : Object = { };
							for (paramName in paramsObj) { newLocal[paramName] = paramsObj[paramName]; }
							newLocal.thisObj = root.create(target.name, paramsObj, local.thisObj);
							newLocal.prev = null;
							newLocal.geom = { name:target.name, iterating:int(local.geom.iterating > 0) };
							local = stackLocal[height] = newLocal;
							
							
							if (parentLocal.geom.first && parentLocal.geom.iterating > 0) local.geom.first = parentLocal.geom.first;
							else local.geom.first = local.thisObj;
							if (parentLocal.geom.iterating < 0) parentLocal.geom.iterating = 1;
							
							
							if (height)
							{
								stackLocal[height - 1].targetObj = local.thisObj;
								stackLocal[height - 1].geom.targetName = local.geom.name;
							}
							if (local.pos.x != 0 || local.pos.y != 0)
							{
								local.thisObj.x = local.pos.x;
								local.thisObj.y = local.pos.y;
							}
							local.thisObj.rotation = local.rotation;
							if (root.update != null) root.update(local.thisObj, local.geom.name);
							
							if (local.geom.iterating == 0)
							{
								local.pos = new Point();
								local.rotation = 0;
							}
							break;
						case CREATE:
							elseTrue = false;
							stackCounter[height++]++;
							stackCounter.push(0);
							stackGeom.push(target.constructor);
							stackLocal.push(local);
							if(local.geom.iterating > 0) local.geom.iterating = -1;
							
							parameters = new Object();
							for each(param in target.params)
							{
								parameters[param.name] = param.eval(local);
							}
							continue;
							break;
						case CLONE:
							elseTrue = false;
							local.targetObj = root.clone(target.eval != null ? target.eval(local) || local.prev : local.prev);
							break;
						case SET:
							elseTrue = false;
							assignment(target.name, target.eval, local);
							break;
						case IF:
							elseTrue = false;
							if (!target.eval(local)) counter = target.instructions.length;
							else elseTrue = true;
							break;
						case ELSE:
							if (!elseTrue) counter = target.instructions.length;
							elseTrue = false;
							break;
						case ELSE_IF:
							if (!elseTrue || !target.eval(local)) counter = target.instructions.length;
							else elseTrue = false;
							break;
						case DISCRETE:
							elseTrue = false;
							local.geom.discrete = true;
							break;
						case DISCRETE_IF:
							elseTrue = false;
							if (target.eval(local)) local.geom.discrete = true;
							break;
						case LOAD_IMAGE:
							elseTrue = false;
							if (target.root.loadImage != null) target.root.loadImage(target.eval(local), target.loopCondition(local));
							break;
						case TRACE:
							elseTrue = false;
							trace("0:" + target.evalEval + " = " + target.eval(local));
							break;
						default: break;
					}
				}
				//process instructions
				if (target.instructions && counter < target.instructions.length)
				{
					stackCounter[height]++;
					stackCounter.push(0);
					stackGeom.push(target.instructions[counter]);
					stackLocal.push(stackLocal[height++]);
				}
				else
				{
					if (target.type == DISCRETE || target.type == DISCRETE_IF) local.geom.discrete = false;
					else if (target.type == CREATE || target.type == CLONE)
					{
						if(root.complete != null) root.complete(local.targetObj, local.geom.targetName, local.geom.discrete);
						local.prev = local.targetObj;
						local.targetObj = null;
						local.geom.targetName = null;
					}
					else if (target.type == CONSTRUCTOR)
					{
						if (target.loopParams)
						{
							for each(param in target.loopParams)
							{
								if (param.type == SET) param.assignment(param.name, param.eval, local);
							}
						}
						if (target.loopCondition != null)
						{
							if(target.loopCondition(local))
							{
								local.geom.iterating = 1;
								stackCounter[height] = 0;
								local.thisObj = local.geom.first;
								if (height) local.geom.discrete = stackLocal[height - 1].geom.discrete;
								
								parameters = new Object();
								for each(param in target.params)
								{
									parameters[param.name] = local[param.name];
								}
								continue;
							}
						}
						if(root.complete != null && !height) root.complete(local.thisObj, local.geom.name, false);
					}
					stackCounter.pop();
					stackGeom.pop();
					stackLocal.pop();
					height--;
				}
			}
		}
		private function assignment(name : String, value : Function, local : Object) : void
		{
			if (!name)
			{
				value(local);
				return;
			}
			var object : * = local;
			var objectNames : Array = name.split(".");
			var update : int = 0;
			var first : String = objectNames[0];
			if (first == "thisObj") throw new Error("The variable name 'thisObj' is reserved. Please use another variable name.");
			else if (first == "targetObj") throw new Error("The variable name 'targetObj' is reserved. Please use another variable name.");
			else if (first == "prev") throw new Error("The variable name 'prev' is reserved. Please use another variable name.");
			else if (first == "geom") throw new Error("The variable name 'geom' is reserved. Please use another variable name.");
			var isLocal : Boolean = object.hasOwnProperty(first);
			if (object.thisObj && (!isLocal || first == "this"))
			{
				if (objectNames.length > 1 && object.thisObj.hasOwnProperty(objectNames[1]))
				{
					objectNames[0] = "thisObj";
					update = 1;
				}
				else if (!isLocal)
				{
					objectNames.unshift("thisObj");
					update = 1;
				}
				else objectNames.shift();
			}
			else if (object.targetObj)
			{
				if (object.targetObj.hasOwnProperty(first))
				{
					objectNames[0] = "targetObj";
					update = -1;
				}
				else if (!isLocal)
				{
					objectNames.unshift("targetObj");
					update = -1;
				}
			}
			var c : uint = 0;
			var length : uint = objectNames.length - 1;
			while(c < length)
			{
				if(object == null && c > 0)
				{
					trace("2:     .+=================================================+.");
					trace("2:    || GeomCode: Warning! null object reference.       ||");
					trace("2:    || " + StringUtilPro.toMinLength("'" + objectNames[c - 1] + "' is null in the following expression:$||", 52, " "));
					trace("2:    || " + StringUtilPro.toMinLength("\t" + objectNames.join(".") + "$||", 46, " "));
					trace("2:     '+=================================================+'");
					return;
				}
				object = object[objectNames[c++]];
			}
			object[objectNames[length]] = value(local);
			if (update && root.update != null)
			{
				if (update > 0) root.update(local.thisObj, local.geom.name);
				else root.update(local.targetObj, local.geom.targetName);
			}
		}
		public function GeomInstruction(source : String = null, root : GeomCode = null)
		{
			if (source && root) apply(source, root);
		}
		public function apply(source : String, root : GeomCode, isAtRoot : Boolean = false) : void
		{
			if (type != UNDEFINED) throw new Error("do not call apply() more than once per instruction!");
			this.root = root;
			var code : Array = source.split(/[\({ ="']/, 1);
			code.push(source.slice(code[0].length));
			switch(code[0])
			{	
				case "if":
					type = IF;
					var head : Array = getBlock(code[1], "(", ")", true);
					evalEval = new SimpleEval(head[0], true);
					eval = evalEval.call;
					makeInstructions(removeBlockContainer(code[1].slice(head[2]+1), "{", "}", " ", ";"));
					break;
				case "else":
					if (source.charAt(code[0].length) == " " && StringUtilPro.startsWith(code[1], " if"))
					{
						type = ELSE_IF;
						head = getBlock(code[1], "(", ")", true);
						evalEval = new SimpleEval(head[0], true);
						eval = evalEval.call;
						makeInstructions(removeBlockContainer(code[1].slice(head[2]+1), "{", "}", " ", ";"));
					}
					else
					{
						type = ELSE;
						makeInstructions(removeBlockContainer(code[1], "{", "}", " ", ";"));
					}
					break;
				case "discrete":
					if (source.charAt(code[0].length) == " " && StringUtilPro.startsWith(code[1], " if"))
					{
						type = DISCRETE_IF;
						head = getBlock(code[1], "(", ")", true);
						evalEval = new SimpleEval(head[0], true);
						eval = evalEval.call;
						makeInstructions(removeBlockContainer(code[1].slice(head[2]+1), "{", "}", " ", ";"));
					}
					else
					{
						type = DISCRETE;
						makeInstructions(removeBlockContainer(code[1], "{", "}", " ", ";"));
					}
					break;
				case "clone":
					type = CLONE;
					head = getBlock(code[1], "(", ")", true);
					if (head[0].length)
					{
						evalEval = new SimpleEval(head[0], true);
						eval = evalEval.call;
					}
					makeInstructions(removeBlockContainer(code[1].slice(head[2]+1), "{", "}", " ", ";"));
					break;
				case "trace":
					type = TRACE;
					evalEval = new SimpleEval(getBlock(code[1], "(", ")", true)[0], true);
					eval = evalEval.call;
					break;
				case "load":
					type = LOAD_IMAGE;
					head = getAs(code[1]);
					evalEval = new SimpleEval(head[1], true);
					eval = evalEval.call;
					//cheating, using loopContition for the url
					loopConditionEval = new SimpleEval(head[0], true);
					loopCondition = loopConditionEval.call;
					break;
				default:
					var separator : String = code[1].charAt(0);
					if (separator == "=")//is it assignment?
					{
						type = SET;
						name = code[0];
						var char : String = name.charAt(name.length - 1);
						if (char == "+" || char == "-" || char == "*" || char == "/" || char == "%" || char == "&&" || char == "||")
						{
							evalEval = new SimpleEval(name + code[1].slice(1), true);
							name = name.slice(0, name.length - 1);
						}
						else evalEval = new SimpleEval(code[1].slice(1), true);
						eval = evalEval.call;
					}
					else if (/^(\+\+|--)[^-+]|[^-+](\+\+|--)$/.test(code[0]))//is it a unary operator
					{
						type = SET;
						name = code[0];
						char = name.charAt(0);
						if (char == "+" || char == "-") name = name.slice(2);
						else name = null;
						evalEval = new SimpleEval(code[0], true);
						eval = evalEval.call;
					}
					else if(!isAtRoot)// creating
					{
						type = CREATE;
						name = code[0];
						head = getBlock(code[1], "(", ")", true);
						makeParams(head[0]);
						makeInstructions(removeBlockContainer(code[1].slice(head[2] + 1), "{", "}", " ", ";"));
						var geomIndex : int = root.geometryNames.indexOf(name);
						CONFIG::debug
						{
							if (geomIndex < 0)
							{
								name = "ERROR";
								return;
							}
						}
						constructor = root.geometries[geomIndex];
					}
					else// constructor
					{
						type = CONSTRUCTOR;
						name = code[0];
						head = getBlock(code[1], "(", ")", true);
						makeParams(head[0]);
						makeInstructions(removeBlockContainer(code[1].slice(head[2] + 1), "{", "}", " ", ";"));
					}
					break;
			}
		}
		private function getAs(source : String) : Array
		{
			var block : int = 0;
			var parenthesis : int = 0;
			var brackets : int = 0;
			var quotes : int = 0;
			var length : uint = source.length;
			for (var i : uint = 0; i < length; i++)
			{
				var char : String = source.charAt(i);
				if (char == "{") block++;
				else if (char == "(") parenthesis++;
				else if (char == "[") brackets++;
				else if (char == "}") block--;
				else if (char == ")") parenthesis--;
				else if (char == "]") brackets--;
				else if (char == '"' && quotes >= 0) quotes = int(!Boolean(quotes));
				else if (char == "'" && quotes <= 0) quotes = -int(!Boolean(quotes));
				else if (char == "a" && source.charAt(i + 1) == "s")
				{
					if (!(block | parenthesis | brackets | quotes) && i+2 < length)
					{
						return [source.slice(0, i), source.slice(i + 2)];
					}
				}
			}
			source = source.slice(0, source.indexOf(";"));
			return [source, source];
		}
		private function parseList(source : String) : Vector.<String>
		{
			var length : uint = source.length;
			var list : Vector.<String> = new Vector.<String>();
			var prevIndex : uint = 0;
			var openParenthesis : uint = 0;
			for (var i : uint = 0; i < length; i++)
			{
				var char : String = source.charAt(i);
				if (char == "," && !openParenthesis)
				{
					list.push(source.slice(prevIndex, i));
					prevIndex = i + 1;
				}
				else if (char == "(") openParenthesis++;
				else if (char == ")" && openParenthesis) openParenthesis--;
			}
			list.push(source.slice(prevIndex, i));
			return list;
		}
		private function makeParams(source : String) : void
		{
			if (!source.length) source = "pos=(0,0),rotation=0";
			var src : Array = source.split(";");
			var paramSrc : Vector.<String> = parseList(src[0]);
			var length : uint = paramSrc.length;
			var found : int = 3;
			params = new Vector.<GeomInstruction>(length);
			for (var i : uint = 0; i < length; i++)
			{
				params[i] = new GeomInstruction(paramSrc[i], root);
				if (params[i].type == SET)
				{
					if (params[i].name == "pos") found &= 2;
					if (params[i].name == "rotation") found &= 1;
				}
			}
			if (type == CONSTRUCTOR)
			{
				if (found & 1) params.push(new GeomInstruction("pos=(0,0)", root));
				if (found & 2) params.push(new GeomInstruction("rotation=0", root));
			}
			
			if (src.length > 1)
			{
				loopConditionEval = new SimpleEval(src[1], true);
				loopCondition = loopConditionEval.call;
			}
			if (src.length > 2)
			{
				paramSrc = parseList(src[2]);
				length = paramSrc.length;
				loopParams = new Vector.<GeomInstruction>(length);
				for (i = 0; i < length; i++)
				{
					loopParams[i] = new GeomInstruction(paramSrc[i], root);
				}
			}
		}
		private function makeInstructions(source : String) : void
		{
			if (source.length < 2) return;
			//splitting up into strings
			var code : Vector.<String> = new Vector.<String>();
			var index : int = 0;
			var lastIndex : int = 0;
			var length : int = source.length;
			var block : int = 0;
			var simpleBlock : int = 0;
			var isSimpleBlock : Boolean = false;
			do
			{
				var char : String = source.charAt(index);
				if (char == "{")
				{
					block++;
					isSimpleBlock = false;
				}
				else if (char == "}") block--;
				else if (!block)
				{
					if (char == "(") simpleBlock++;
					else if (char == ")")
					{
						simpleBlock--;
						if (!simpleBlock) isSimpleBlock = true;
					}
					else if (char == " " && !(index > 7 && source.slice(index-8, index+3) == "discrete if")) isSimpleBlock = true;
				}
				if (!block && (char == ";" || char == "}" && source.length > 1))
				{
					code.push(source.slice(lastIndex, char == ";" && !isSimpleBlock ? index : index + 1));
					lastIndex = index + 1;
					simpleBlock = 0;
					isSimpleBlock = false;
				}
			}
			while (++index < length);
			if(lastIndex < source.length) code.push(source.slice(lastIndex));
			
			//parsing each string and create geom instructions
			length = code.length;
			if (length > 0)
			{
				instructions = new Vector.<GeomInstruction>(length);
				for (var i : uint = 0; i < length; i++)
				{
					
					if ((instructions[i] = new GeomInstruction(code[i], root)).name == "ERROR")
					{
						index = code[i].search(/[\({ ="']/);
						if (index < 0) index = int.MAX_VALUE;
						else
						{
							lastIndex = code[i].lastIndexOf(" ", index);
							if (lastIndex >= 0) index = lastIndex;
						}
						char = code[i].slice(0, index);
						throw new Error("GeomCode Syntax Error: DERP DERP! what is " + char + "?\n\n");
					}
				}
			}
		}
		public static function removeBlockContainer(source : String, open : String, close : String, openAlt : String = null, closeAlt : String = null) : String
		{
			var openIndex : int = source.indexOf(open);
			if (openIndex < 0) openIndex = int.MAX_VALUE;
			if (openAlt)
			{
				var openAltIndex : int = source.indexOf(openAlt);
				if (openAltIndex < 0) openAltIndex = int.MAX_VALUE;
				if (openAltIndex < openIndex)
				{
					openIndex = openAltIndex;
					var closeIndex : int = source.lastIndexOf(closeAlt)
				}
				else closeIndex = source.lastIndexOf(close);
			}
			
			if (openIndex == Infinity || closeIndex < 0) return source;
			else return source.slice(openIndex+1, closeIndex);
		}
		internal static function getBlock(string : String, open : String, close : String, onlyContent : Boolean = false) : Array
		{
			var counter : uint = 0;
			var index : int = string.indexOf(open);
			if (index < 0) return ["", -1, -1];
			else
			{
				counter = 1;
				var start : int = index;
				while (counter)
				{
					var openIndex : int = string.indexOf(open, index+1);
					var closeIndex : int = string.indexOf(close, index+1);
					if (openIndex < 0)
					{
						if (closeIndex < 0) return ["", -1, -1];
						openIndex = int.MAX_VALUE;
					}
					if (closeIndex < 0) closeIndex = int.MAX_VALUE;
					
					if (openIndex < closeIndex)
					{
						counter++;
						index = openIndex;
					}
					else
					{
						counter--;
						index = closeIndex;
					}
				}
				if (onlyContent) start++;
				else index++;
				return [string.slice(start, index), start, index];
			}
			return ["", -1, -1];
		}
		public function toString(height : String = "") : String
		{
			var string : String = "";
			switch(type)
			{
				case UNDEFINED: break;
				case CONSTRUCTOR:
				case CREATE:
					string = name + "(" + (params ? params.join(", ") : "")
					+ (loopConditionEval != null ? "; " + loopConditionEval : "")
					+ (loopParams ? "; " + loopParams.join(", ") : "") + ")"
					+ (instructions && instructions.length > 1 || type == CONSTRUCTOR ? "\n" : "") + instructionsToString(height);
				    break;
				case SET:
					if(name && name.length) string = name + " = " + evalEval;
					break;
				case IF:
					string = "if(" + evalEval + ")" + (instructions && instructions.length > 1 ? "\n" : "") + instructionsToString(height);
					break;
				case ELSE:
					string = "else" + (instructions && instructions.length > 1 ? "\n" : " ") + instructionsToString(height);
					break;
				case ELSE_IF:
					string = "else if(" + evalEval + ")" + (instructions && instructions.length > 1 ? "\n" : " ") + instructionsToString(height);
					break;
				case DISCRETE:
					string = "discrete" + (instructions && instructions.length > 1 ? "\n" : " ") + instructionsToString(height);
					break;
				case DISCRETE_IF:
					string = "discrete if(" + evalEval + ")" + (instructions && instructions.length > 1 ? "\n" : " ") + instructionsToString(height);
					break;
				case LOAD_IMAGE:
					string = "load " + loopConditionEval + " as " + evalEval + ";";
					break;
				case TRACE:
					string = "trace(" + evalEval + ");";
				default: break;
				
			}
			return string;
		}
		public function instructionsToString(height : String = "") : String
		{
			if (type != CONSTRUCTOR)
			{
				if (!instructions || !instructions.length) return ";";
				else if(instructions.length == 1 && (!instructions[0].instructions || !instructions[0].instructions.length))
				{
					return instructions[0].toString() + ";";
				}
			}
			var nextHeight : String = height + "\t";
			var string : String = height + "{\n";
			for each(var instruction : GeomInstruction in instructions)
			{
				string += nextHeight + instruction.toString(nextHeight) + (instruction.type == SET ? ";\n" : "\n");
			}
			return string + height + "}";
		}
	}

}