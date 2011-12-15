package com.danielsig
{
	
	public class StringUtilPro
	{	
		public static function fixed(number : Number, length : uint = 5) : String
		{
			return toLength("$" + number.toPrecision(length), length, "0", 3);
		}
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
		public static function splice(string : String, index : int, deleteCount : uint, fill : String = "") : String
		{
			if (!string) return null;
			if (index > string.length) index %= string.length;
			if (index + deleteCount > string.length) return string.slice((index + deleteCount) % string.length, index) + fill;
			if(index == 0) return fill + string.slice(index + deleteCount);
			if(index == string.length) return string + fill;
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
		 * Please add a wildcard (default is $) to the string where you want the fillIn to be placed in order to ensure a minimum length.
		 * The Length of the string without the wildcard is taken into account which means that toMinLength("AA$", 3, "B")
		 * will return "AAB" since the length of "AA$" without the dollar sign is 2 and therefor less than the minLength 3.
		 * You can change the wildcard in order to use the $ sign as a normal character. For an example
		 * toMinLength("AA$BB!?", 8, "C", "!?") will return "AA$BBCCC".
		 * @param string, the string to be checked and lengthened if required.
		 * @param minLength, the minimum length of the string.
		 * @param fillIn, a string that will be used to fill in the gap to ensure the minimum length.
		 * @param wildcard, a string that will be used to reprisent the location to place the fillIn.
		 * @return a string with the specified minimum length.
		 * 
		 */		
		public static function toMinLength(obj : *, minLength : int, fillIn : String = " ", wildcard : String = "$") : String
		{
			var string : String = obj;
			if(!string) return null;
			if(fillIn && fillIn.length > 0)
			{
				var stringLength : int = string.length - 1;
				string = string.replace(wildcard, multiply(fillIn, minLength - stringLength / fillIn.length));
			}
			return string;
		}
		/**
		 * Just like toMinLength() except that if the given string is longer than the spcecified length,
		 * then the string will be trimmed by deleting specific characters according to the deletionType
		 * 
		 * @see DeletionType
		 * 
		 * @param	obj, the string (or object to be converted to string) to be checked and lengthened if required.
		 * @param	length, the desired length for the string.
		 * @param	fillIn, a string that will be used to fill in the gap to ensure the forced length.
		 * @param	deleteType, the deletion type to use if deletion is required.
		 * @return  a string with the specified length.
		 */
		public static function toLength(obj : *, length : int, fillIn : String = " ", deletionType : uint = 0, wildcard : String = "$") : String
		{
			var string : String = obj;
			if (!string) return null;
			if(string.length < length && fillIn && fillIn.length > 0)
			{
				var stringLength : int = string.length - 1;
				string = string.replace(wildcard, multiply(fillIn, length - stringLength / fillIn.length));
			}
			else
			{
				stringLength = string.length;
				var index : int = string.indexOf("$");
				if (index < 0)
				{
					var dollar : int = 0;
					index = (stringLength >> 1);
				}
				else
				{
					dollar = 1;
					stringLength--;
				}
				
				var start : int = 0;
				var end : int = 0;
				var trim : int = 0;
				
				var amountToDelete : uint = stringLength - length;
				
				if (deletionType & DeletionType.DELETE_UNEVENLY)//uneven deletion
				{
					if (deletionType & DeletionType.RIGHT_SIDE_FIRST)
					{
						if ((stringLength - index) > amountToDelete)
						{
							var delRight : uint = amountToDelete;
							var delLeft : uint = 0;
						}
						else
						{
							delRight = stringLength - index;
							delLeft = amountToDelete - (stringLength - index);
						}
					}
					else
					{
						if (index > amountToDelete)
						{
							delLeft = amountToDelete;
							delRight = 0;
						}
						else
						{
							delLeft = index;
							delRight = amountToDelete - index;
						}
					}
					if (deletionType == 1)
					{
						start = index - delLeft;
						end = index + dollar;
						trim = -delRight;
					}
					else if (deletionType == 3) trim = -amountToDelete - (amountToDelete > delRight ? dollar : 0);
					else if (deletionType == 13) trim = amountToDelete;
					else if (deletionType == 5 || deletionType == 11)
					{
						start = 0;
						end = delLeft;
						trim = -delRight;
					}
					else if (deletionType == 7 || deletionType == 9)
					{
						start = index - delLeft;
						end = index + delRight + dollar;
					}
					else if (deletionType == 15)
					{
						start = index;
						end = index + delRight + dollar;
						trim = delLeft;
					}
				}
				else//even deletion
				{
					if (deletionType & DeletionType.RIGHT_SIDE_FIRST)
					{
						delLeft = amountToDelete >> 1;
						delRight = amountToDelete - delLeft;
					}
					else
					{
						delRight = amountToDelete >> 1;
						delLeft = amountToDelete - delRight;
					}
					if (deletionType == 0 || deletionType == 2)
					{
						start = index - delRight;
						end = index + dollar;
						trim = -delLeft;
					}
					else if (deletionType == 4 || deletionType == 10)
					{
						start = 0;
						end = delLeft;
						trim = -delRight;
					}
					else if (deletionType == 8 || deletionType == 6)
					{
						start = index - delLeft;
						end = index + delRight + dollar;
					}
					else if (deletionType == 12 || deletionType == 14)
					{
						start = index;
						end = index + delRight + dollar;
						trim = delLeft;
					}
				}
				if (start >= string.length) start = 0;
				else if (start < 0)
				{
					if (trim > start) trim = start;
					start = 0;
				}
				
				if (dollar &&
					(
							(index >= end && index - (end - start) < string.length + trim)
						||  (index < start && index < string.length + trim)
					)
				)
				{
					string = splice(string, index, 1);
				}
				if (start + end)
				{
					string = splice(string, start, end - start);
				}
				if (trim)
				{
					if (trim > 0) string = string.slice(trim);
					else string = string.slice(0, trim);
				}
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
		private static var tester : Boolean = test();
		private static function test() : Boolean
		{
			var type0 : uint = DeletionType.create(true, true, true, false);
			var type2 : uint = DeletionType.create(true, false, true, false);
			var type4 : uint = DeletionType.create(true, true, false, false);
			var type6 : uint = DeletionType.create(true, false, false, false);
			var type8 : uint = DeletionType.create(true, true, true, true);
			var type10 : uint = DeletionType.create(true, false, true, true);
			var type12 : uint = DeletionType.create(true, true, false, true);
			var type14 : uint = DeletionType.create(true, false, false, true);
			var type1 : uint = DeletionType.create(false, true, true, false);
			var type3 : uint = DeletionType.create(false, false, true, false);
			var type5 : uint = DeletionType.create(false, true, false, false);
			var type7 : uint = DeletionType.create(false, false, false, false);
			var type9 : uint = DeletionType.create(false, true, true, true);
			var type11 : uint = DeletionType.create(false, false, true, true);
			var type13 : uint = DeletionType.create(false, true, false, true);
			var type15 : uint = DeletionType.create(false, false, false, true);
			
			var types : Vector.<uint> = new <uint>
			[
			type8, type8, type8, type8, type8, type8, type8,
			type6, type6, type6, type6, type6, type6, type6,
			type2, type2, type0, type0, type4, type4,
			type10, type10, type12, type12, type14, type14,
			type1, type1, type3, type3, type3, type3,
			type5, type5, type7, type7, type9, type9,
			type11, type11, type13, type13, type15, type15
			];
			var lengths : Vector.<uint> = new <uint>
			[
			10, 9, 8, 7, 4, 3, 4,
			10, 9, 8, 7, 4, 3, 4,
			8, 5, 8, 5, 8, 5,
			8, 5, 8, 5, 8, 5,
			
			8, 3, 8, 3, 8, 3,
			8, 3, 8, 3, 8, 3,
			8, 3, 8, 3, 8, 3
			];
			var inputs : Vector.<String> = new <String>
			[
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "$abcde", "$abcde", "abcde$",
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "$abcde", "$abcde", "abcde$",
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345",
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345",
			
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "$abcde12345", "abcde12345$",
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345",
			"abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345", "abcde$12345"
			];
			var outputs : Vector.<String> = new <String>
			[
			"abcde12345", "abcd12345", "abcd2345", "abc2345", "abcd", "bcd", "abcd",
			"abcde12345", "abcde2345", "abcd2345", "abcd345", "bcde", "bcd", "bcde",
			"abcd1234", "ab123", "abcd1234", "abc12", "bcde1234", "de123",
			"bcde1234", "cde12", "bcde2345", "de345", "bcde2345", "cde45",
			
			"abc12345", "123", "abcde123", "abc", "abcde123", "abc",
			"cde12345", "123", "abcde345", "abc", "abc12345", "345",
			"abcde123", "cde", "cde12345", "345", "abcde345", "cde"
			];
			
			var withSign : Boolean = false;
			var string : String = "";
			var failure : Boolean = false;
			for (var i : int = 0; i < inputs.length; i++)
			{
				var output : String = toLength(inputs[i], lengths[i], " ", types[i]);
				string += (outputs[i] != output ? "3:" : "") + "input: " + toMinLength(inputs[i] + "?", 12, " ", "?") + 
					"was expecting: " + toMinLength(outputs[i] + "?", 12, " ", "?") +
					"got: " + toMinLength(output + "?", 12, " ", "?") +
					"| " + (outputs[i] == output) +
					"\n";
				if (outputs[i] != output) failure = true;
				if (!withSign && i == inputs.length - 1)
				{
					withSign = true;
					i++
					while (i--)
					{
						inputs[i] = inputs[i].replace("$", "");
						if (inputs[i] == "abcde")
						{
							inputs.splice(i, 1);
							outputs.splice(i, 1);
							lengths.splice(i, 1);
							types.splice(i, 1);
						}
					}
				}
			}
			if (failure) trace(string);
			return !failure;
		}
	}
}