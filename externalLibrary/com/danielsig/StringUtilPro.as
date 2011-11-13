package com.danielsig
{
	public class StringUtilPro
	{
		public static function getNumeral(number : uint) : String
		{
			var end : uint = number % 10;
			if (!end && end > 3) return number + "th";
			if (end == 1) return number + "st";
			if (end == 2) return number + "nd";
			return number + "rd"
		}
		public static function getHash16(string : String) : int
		{
			return getHashRaw(string) % 0xFFFF;
		}
		public static function getHash8(string : String) : int
		{
			return getHashRaw(string) % 0xFF;
		}
		public static function startsWith(string : String, pattern : *, i : uint = 0) : Boolean
		{
			if(i) return string.slice(i).search(pattern) == 0;
			return string.search(pattern) == 0;
		}
		public static function endsWith(string : String, pattern : *) : Boolean
		{
			if(string is RegExp)
			{
				trace("This feature hasn't been tested throughly. Using the regular expression /"
					+ pattern.source + "/" + (pattern.ignoreCase ? "i" : "") + (pattern.multiline ? "m" : "")
					+ (pattern.extended ? "x" : "") + " I " + (regx.test(string) ? "" : "do NOT ") + "detect a match at the end of the folowing string:\n" + string);
				var regx : RegExp = pattern as RegExp;
				regx = new RegExp("(" + regx.source.replace(/\$/g, "") + ")$", (regx.ignoreCase ? "i" : "") + (regx.multiline ? "m" : "") + (regx.extended ? "x" : "") + "g");
				return regx.test(string);
			}
			return string.lastIndexOf(pattern) == string.length - pattern.length;
		}
		public static function reverseCharAt(string : String, index : int = 0) : String
		{
			return string.charAt(string.length - (index + 1));
		}
		public static function reverseCharCodeAt(string : String, index : int = 0) : Number
		{
			return string.charCodeAt(string.length - (index + 1));
		}
		public static function getBetween(string : String, start : String = null, end : String = null) : String
		{
			if(!string) return null;
			var startIndex : int = start ? string.indexOf(start) : -1;
			var endIndex : int = end ? string.indexOf(end, startIndex + (start || "").length) : string.length;
			if(startIndex < 0)
			{
				return "";
			}
			if(endIndex < 0)
			{
				endIndex = string.length;
			}
			return string.slice(startIndex + (start ? start.length : 0), endIndex);
		}
		public static function getRange(string : String, start : String = null, end : String = null) : String
		{
			if(!string) return null;
			var startIndex : int = start ? string.indexOf(start) : 0;
			var endIndex : int = end ? string.indexOf(end, startIndex + (start || "").length) : string.length;
			if(startIndex == -1 && endIndex == -1)
			{
				return "";
			}
			if(endIndex < 0)
			{
				endIndex = string.length;
			}
			return string.slice(startIndex, endIndex + end.length);
		}
		public static function getFromTo(string : String, start : String = null, end : String = null) : String
		{
			if(!string) return null;
			var startIndex : int = start ? string.indexOf(start) : 0;
			if(startIndex == -1)
			{
				return "";
			}
			var endIndex : int = end ? string.indexOf(end, startIndex + (start || "").length) : string.length;
			if(endIndex < 0)
			{
				endIndex = string.length;
			}
			return string.slice(startIndex, endIndex);
		}
		public static function deleteBetween(string : String, start : String = null, end : String = null) : String
		{
			if(!string) return null;
			var startIndex : int = start ? string.indexOf(start) : -1;
			var endIndex : int = end ? string.indexOf(end, startIndex + (start || "").length) : string.length;
			if(startIndex == -1 && endIndex == -1)
			{
				return string;
			}
			if(endIndex < 0)
			{
				endIndex = string.length;
			}
			return splice(string, startIndex + start.length, endIndex - (startIndex + 1));
		}
		public static function deleteRange(string : String, start : String = null, end : String = null) : String
		{
			if(!string) return null;
			var startIndex : int = start ? string.indexOf(start) : 0;
			var endIndex : int = end ? string.indexOf(end, startIndex + (start || "").length) : string.length;
			if(startIndex == -1 && endIndex == -1)
			{
				return string;
			}
			if(endIndex < 0)
			{
				endIndex = string.length;
			}
			return splice(string, startIndex, endIndex + end.length - startIndex);
		}
		public static function deleteFromTo(string : String, start : String = null, end : String = null) : String
		{
			if(!string) return null;
			var startIndex : int = start ? string.indexOf(start) : 0;
			if(startIndex == -1)
			{
				return string;
			}
			var endIndex : int = end ? string.indexOf(end, startIndex + (start || "").length) : string.length;
			if(endIndex < 0)
			{
				endIndex = string.length;
			}
			return splice(string, startIndex, endIndex - startIndex);
		}
		public static function splice(string : String, index : int, deleteCount : int, fill : String = "") : String
		{
			if(!string) return null;
			return string.slice(0, index) + fill + string.slice(index + deleteCount);
		}
		public static function multiply(string : String, times : int) : String
		{
			if(!string) return null;
			var results : String = "";
			if(times < 0)
			{
				times = 0;
			}
			while(times--)
			{
				results += string;
			}
			return results;
		}
		/**
		 * Please add a dollar sign $ to the string where you want the fillIn to be placed in order to ensure a minimum length.
		 * The Length of the string without the $ is taken into account which means that toMinLength("AA$", 3, "B")
		 * will return "AAB" since the length of "AA$" without the dollar sign is 2 and therefor less than the minLength 3.
		 * @param string the string to be checked and lengthened if required.
		 * @param minLength the minimum length of the string.
		 * @param fillIn a string that will be used to fill in the gap to ensure the minimum length.
		 * @return a string with the specified minimum length.
		 * 
		 */		
		public static function toMinLength(string : String, minLength : int, fillIn : String = " ") : String
		{
			if(!string) return null;
			if(fillIn is String && fillIn.length > 0)
			{
				var stringLength : int = string.length - 1;
				string = string.replace("$", multiply(fillIn, minLength - stringLength / fillIn.length));
			}
			return string;
		}
		public static function replaceAll(string : String, target : *, replacement : *, startIndex : Number = 0, replArgs : Array = null) : String
		{
			if(!string) return null;
			if(target is RegExp && (target as RegExp).global)
			{
				var source : String = (target as RegExp).source;
				source = splice(source, source.lastIndexOf("g"), 1);
				target = new RegExp(source);
			}
			var start : Number = target is RegExp ? string.slice(startIndex).search(target) : string.indexOf(target, startIndex);
			if(start > -1)
			{
				if(replArgs && replArgs.length > 0)
				{
					var args : Array = replArgs.concat([start, string, target])
					args.forEach(
						function(value : *, i : int, arr : Array) : void
						{
							var start : int = arr[arr.length - 3];
							var string : String = arr[arr.length - 2];
							var target : * = arr[arr.length - 1];
							
							if(value == "arg:index")
							{
								arr[i] = start;
							}
							else if(value == "arg:target")
							{
								arr[i] = string.slice(start).match(target)[0];
							}
						}
					);
					args.length -= 3;
				}
				else
				{
					args = [];
				}
				var replacementString : String = replacement is Function ? replacement.apply(null, args) : (replacement + "");
				return replaceAll(string.slice(0, start) + string.slice(start).replace(target, replacementString), target, replacement, start + replacementString.length);
			}
			return string;
		}
		public static function removeOnContent(string : String, open : String, content : RegExp, close : String, startIndex : int = 0) : String
		{
			if(!string) return null;
			var level : int = 0;
			var openIndex : int = -1;
			var nextIterationIndex : int = string.length;
			var subString : String = "";
			for(var i : int = startIndex; i < string.length; i++)
			{
				if(string.charAt(i) == open)
				{
					level++;
					if(level == 2 && nextIterationIndex == string.length)
					{
						nextIterationIndex = i;
					}
					else if(level == 1 && openIndex < 0)
					{
						openIndex = i;
					}
				}
				else if(string.charAt(i) == close)
				{
					level--;
				}
				else if(level == 1)
				{
					subString += string.charAt(i);
				}
				
				if(level == 0 && openIndex >= 0)
				{
					if(content.test(subString))
					{
						var correctedString : String = string.slice(0, openIndex) + string.slice(openIndex+1, i) + string.slice(i+1);
						return removeOnContent(correctedString, open, content, close, nextIterationIndex);
					}
				}
			}
			return string;
		}
		private static function getHashRaw(string : String) : int
		{
			if(!string) return -1;
			var hash : int = 0;
			var i : int = string.length;
			while(i--)
			{
				hash += string.charCodeAt(i);
			}
			return hash;
		}
	}
}