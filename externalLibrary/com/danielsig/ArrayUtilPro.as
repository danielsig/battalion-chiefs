package com.danielsig
{
	import flash.sampler.getMemberNames;
	
	/**
	 * @author Daniel Sig
	 */
	public class ArrayUtilPro
	{
		public static function matchString(string : String, strings : Vector.<String>, start : int = 0) : int
		{
			if(start >= 0 && start < strings.length)
			{
				if(strings[start] == string)
				{
					return start;
				}
				else
				{
					return matchString(string, strings, start + 1);
				}
			}
			return -1;
		}
		public static function replaceString(strings : Vector.<String>, target : *, replacement : *, start : int = 0) : void
		{
			if(strings != null && target != null && replacement != null && start < strings.length)
			{
				var currentTarget : String = target is Vector.<String> || target is Array ? (start < target.length ? target[start].toString() : null) : target.toString();
				var currentReplacement : String = replacement is Vector.<String> || replacement is Array ? (start < replacement.length ? replacement[start].toString() : null) : replacement.toString();
				if(currentTarget && currentReplacement)
				{
					strings[start] = StringUtilPro.replaceAll(strings[start], currentTarget, currentReplacement);
					replaceString(strings, target, replacement, start + 1);
				}
			}
		}
		public static function replace(arr : *, target : *, replacement : *, start : int = 0, amount : int = 1, replFunction : Boolean = false) : void
		{
			if(start-- < 0)
			{
				start = -1;
			}
			while(start++ < arr.length && amount > 0)
			{
				if(arr[start] == target)
				{
					amount--;
					arr[start] = replFunction && replacement is Function ? replacement() : replacement;
				}
			}
		}
		public static function joinDimensions(output : *, dimensions : Vector.<int> = null, ... args) : void
		{
			joinAllRecursive.apply(null, [output, dimensions.length, dimensions].concat(args));
		}
		public static function joinAll(output : *, ... args) : void
		{
			joinAllRecursive.apply(null, [output, 10, null].concat(args));
		}
		private static function joinAllRecursive(output : *, counter : int, dimensions :  Vector.<int>, ... args) : void
		{
			if(counter == 0)
			{
				return;
			}
			if(output as Vector.<*> == null || args == null)
			{
				return;
			}
			for each(var object : * in args)
			{
				if(object as Vector.<*>)
				{
					var dimLength : int = dimensions == null ? 0 : dimensions.length;
					var reverseCounter : int = dimLength - counter;
					if(dimensions == null || reverseCounter >= dimLength || (reverseCounter < dimLength && dimensions[reverseCounter] < 0))
					{
						for each(var elem : * in object)
						{
							if(elem as Vector.<*>)
							{
								joinAllRecursive(output, counter - 1, dimensions, elem);
							}
							else
							{
								output.push(elem);
							}
						}
					}
					else
					{
						var index : int = dimensions[reverseCounter];
						if(index < object.length)
						{
							joinAllRecursive(output, counter - 1, dimensions, object[index]);
						}
					}
				}
				else
				{
					output.push(object);
				}
			}
		}
		public static function joinVector(object : *) : Vector.<Object>
		{
			if(object as Vector.<Object> == null || object.length == 0 || object[0] as Vector.<Object> == null)
			{
				return object;
			}
			var joinedVector : Vector.<Object> = new Vector.<Object>;
			for each (var vector : * in object)
			{
				var counter : int = joinedVector.length;
				joinedVector.length += vector.length;
				for each (var elem : * in vector)
				{
					joinedVector[counter++] = elem;
				}
			}
			return joinedVector;
		}
		public static function join(object : *) : Array
		{
			var arr : Array = toArray(object);
			if(arr.length > 0)
			{
				var arr2 : Array = tryConvertToArray(arr[0]);
				if(arr2 != null)
				{
					for(var i : int = 1; i < arr.length; i++)
					{
						arr2 = arr2.concat(arr[i]);
					}
					return arr2;
				}
			}
			return arr;
		}
		public static function multiply(objectA : *, objectB : *, propertyNameA : String = null, propertyNameB : String = null) : Array
		{
			var arrA : Array = propertyNameA == null ? toArrayClone(objectA) :  getProperties(objectA, propertyNameA);
			var arrB : Array = propertyNameB == null ? toArray(objectB) :  getProperties(objectB, propertyNameB);
			var minLength : int = Math.min(arrA.length, arrB.length);
			arrA.length = minLength;
			for(var i : int = 0; i < minLength; i++)
			{
				var numberA : Number = Number(arrA[i]);
				var numberB : Number = Number(arrB[i]);
				if(numberA == numberA && numberB == numberB)
				{
					arrA[i] = numberA * numberB;
				}
				else
				{
					arrA[i] = Number.NaN;
				}
			}
			return arrA;
		}
		public static function getProperties(object : Object, propertyName : String) : Array
		{
			var arr : Array = toArrayClone(object);
			for(var i : int = 0; i < arr.length; i++)
			{
				if(arr[i].hasOwnProperty(propertyName))
				{
					arr[i] = arr[i][propertyName];
				}
				else
				{
					arr[i] = null;
				}
			}
			return arr;
		}
		public static function toVector(output : *, object : *) : void
		{
			if(output is Vector.<*>)
			{
				for each (var elem : * in object) {
					output.push(elem);
				}
			}
		}
		public static function toArrayClone(object : *) : Array
		{
			var array : Array = [];
			if(object is Vector.<*>)
			{
				for each (var elem : * in object)
				{
					array.push(elem);
				}
			}
			else if(!(object is Array))
			{
				array = [object];
			}
			else
			{
				array = (object as Array).concat();
			}
			return array;
		}
		public static function toArray(object : *) : Array
		{
			var array : Array = [];
			if(object is Vector.<*>)
			{
				for each (var elem : * in object)
				{
					array.push(elem);
				}
			}
			else if(!(object is Array))
			{
				array = [object];
			}
			else
			{
				array = object as Array;
			}
			return array;
		}
		public static function tryConvertToArray(object : *) : Array
		{
			var array : Array = [];
			if(object is Vector.<*>)
			{
				for each (var elem : * in object) {
					array.push(elem);
				}
			}
			else if(!(object is Array))
			{
				array = null;
			}
			else
			{
				array = object as Array;
			}
			return array;
		}
		public static function greedyFind(object : *, callback : Function) : *
		{
			var arr : Array = tryConvertToArray(object);
			var best : *;
			if(arr.length > 0)
			{
				best = arr[0];
				for each(var element : * in arr)
				{
					if(callback(element, best))
					{
						best = element;
					}
				}
			}
			return best;
		}
	}
}