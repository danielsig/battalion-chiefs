package com.battalion.flashpoint.display 
{	
	import com.danielsig.StringUtilPro;
	import com.danielsig.ColorFactory;
	import flash.filters.ColorMatrixFilter;
	
	/**
	 * A Color Matrix class can be used to manipualte colors.
	 * In the FlashPoint engine, a ColorMatrix can be used on Cameras to render things differently.
	 * @author Battalion Chiefs
	 */
	public final class ColorMatrix
	{
		
		public function tint(color : uint, amount : Number) : void
		{
			var tintRed : Number = ColorFactory.RedOfRGB(color);
			var tintGreen : Number = ColorFactory.GreenOfRGB(color);
			var tintBlue : Number = ColorFactory.BlueOfRGB(color);
			
			red += (tintRed - red) * amount;
			green += (tintGreen - green) * amount;
			blue += (tintBlue - blue) * amount;
			
			redFromGreen += (tintRed - redFromGreen) * amount;
			redFromBlue += (tintRed - redFromBlue) * amount;
			
			greenFromRed += (tintGreen - greenFromRed) * amount;
			greenFromBlue += (tintGreen - greenFromBlue) * amount;
			
			blueFromRed += (tintBlue - blueFromRed) * amount;
			blueFromGreen += (tintBlue - blueFromGreen) * amount;
		}
		
		/**
		 * Use this method to increase lightness
		 * A valie of -2 will inverse the lightness.
		 * A value of -1 will make everything pitch black.
		 * A value of 0 will do nothing.
		 * A value of 1 will increase lightness twofold.
		 * etc.
		 * @param	amount, the amount to multiply the current saturation with
		 */
		public function lightness(amount : Number) : void
		{
			
			redOffset += amount * 256;
			greenOffset += amount * 256;
			blueOffset += amount * 256;
		}
		
		/**
		 * Use this method to increase saturation.
		 * A valie of -2 will inverse the colors.
		 * A value of -1 will desturate completely.
		 * A value of 0 will do nothing.
		 * A value of 1 will increase saturation twofold.
		 * etc.
		 * @param	amount, the amount to multiply the current saturation with
		 */
		public function saturate(amount : Number) : void
		{
			amount = -amount;
			
			red += (0.3 - red) * amount;
			green += (0.59 - green) * amount;
			blue += (0.11 - blue) * amount;
			
			greenFromRed += (0.3 - greenFromRed) * amount;
			blueFromRed += (0.3 - blueFromRed) * amount;
			
			redFromGreen += (0.59 - redFromGreen) * amount;
			blueFromGreen += (0.59 - blueFromGreen) * amount;
			
			redFromBlue += (0.11 - redFromBlue) * amount;
			greenFromBlue += (0.11 - greenFromBlue) * amount;
		}
		/**
		 * Use this method to increase contrast.
		 * A value of -2 negates the colors (should not be confused with inversing the colors)
		 * A value of -1 makes everything gray
		 * A value of 0 does nothing
		 * A value of 1 increases the contrast twofold
		 * etc.
		 * @param	amount
		 */
		public function contrast(amount : Number) : void
		{
			amount += 1;
			red *= amount;
			green *= amount;
			blue *= amount;
			redFromGreen *= amount;
			redFromBlue *= amount;
			greenFromRed *= amount;
			greenFromBlue *= amount;
			blueFromRed *= amount;
			blueFromGreen *= amount;
			redOffset += (128 - redOffset) * (1-amount);
			greenOffset += (128 - greenOffset) * (1-amount);
			blueOffset += (128 - blueOffset) * (1-amount);
		}
		/**
		 * Rotates the hue.
		 * e.g. 180 degree rotation would make red become cyan, green become magenta and blue become yellow
		 * @param	angle, angle in degrees
		 */
		public function rotateHue(angle : Number) : void
		{
			if (angle > 180)
			{
				while (angle > 180) angle -= 360;
			}
			else if (angle < -180)
			{
				while (angle < -180) angle += 360;
			}
			
			//LEFT RATIO
			if (angle < -120) angle += 360;
			if (angle > 0)
			{
				var leftRatio : Number = (120 - angle) / 120;
				if (leftRatio < 0) leftRatio = 1 + leftRatio;
				else leftRatio = 1 - leftRatio;
			}
			else leftRatio = 0;
			if (angle > 180) angle -= 360;
			
			
			//RIGHT RATIO
			if (angle > 120) angle -= 360;
			if (angle < 0)
			{
				var rightRatio : Number = (angle + 120) / 120;
				if (rightRatio < 0) rightRatio = 1 + rightRatio;
				else rightRatio = 1 - rightRatio;
			}
			else rightRatio = 0;
			if (angle < -180) angle += 360;
			
			
			//CENTER RATIO
			if (angle < 120 && angle > -120)
			{
				var centerRatio : Number = angle / 120;
				if (centerRatio < 0) centerRatio = 1 + centerRatio;
				else centerRatio = 1 - centerRatio;
			}
			else centerRatio = 0;
			
			var tempRed : Number = red;
			var tempRedFromGreen : Number = redFromGreen;
			var tempRedFromBlue : Number = redFromBlue;
			
			var tempGreen : Number = green;
			var tempGreenFromRed : Number = greenFromRed;
			var tempGreenFromBlue : Number = greenFromBlue;
			
			var tempBlue : Number = blue;
			var tempBlueFromRed : Number = blueFromRed;
			var tempBlueFromGreen : Number = blueFromGreen;
			
			
			red				= tempRed * centerRatio + tempRedFromBlue * leftRatio + tempRedFromGreen * rightRatio;
			green			= tempGreen * centerRatio + tempGreenFromRed * leftRatio + tempGreenFromBlue * rightRatio;
			blue			= tempRed * centerRatio + tempBlueFromGreen * leftRatio + tempBlueFromRed * rightRatio;
			
			redFromGreen	= tempRed * leftRatio + tempRedFromBlue * rightRatio + tempRedFromGreen * centerRatio;
			redFromBlue		= tempRed * rightRatio + tempRedFromBlue * centerRatio + tempRedFromGreen * leftRatio;
			
			greenFromRed	= tempGreen * rightRatio + tempGreenFromRed * centerRatio + tempGreenFromBlue * leftRatio;
			greenFromBlue	= tempGreen * leftRatio + tempGreenFromRed * rightRatio + tempGreenFromBlue * centerRatio;
			
			blueFromRed		= tempBlue * leftRatio + tempBlueFromRed * centerRatio + tempBlueFromGreen * rightRatio;			
			blueFromGreen	= tempBlue * rightRatio + tempBlueFromRed * leftRatio + tempBlueFromGreen * centerRatio;
			
		}
		
		/**
		 * A ColorMatrixFilter representation of this ColorMatrix
		 */
		public function get filter() : ColorMatrixFilter
		{
			return new ColorMatrixFilter([red, redFromGreen, redFromBlue, redFromAlpha, redOffset
										, greenFromRed, green, greenFromBlue, greenFromAlpha, greenOffset
										, blueFromRed, blueFromGreen, blue, blueFromAlpha, blueOffset
										, alphaFromRed, alphaFromGreen, alphaFromBlue, alpha, alphaOffset]);
		}
		public function set filter(value : ColorMatrixFilter) : void
		{
			matrix = value.matrix;
		}
		/**
		 * An Array representation of this ColorMatrix where each 5 values represent a row in the matrix
		 */
		public function get matrix() : Array
		{
			return [red, redFromGreen, redFromBlue, redFromAlpha, redOffset
										, greenFromRed, green, greenFromBlue, greenFromAlpha, greenOffset
										, blueFromRed, blueFromGreen, blue, blueFromAlpha, blueOffset
										, alphaFromRed, alphaFromGreen, alphaFromBlue, alpha, alphaOffset];
		}
		public function set matrix(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 20) throw new Error("The Array must have a length of 20!");
				for (var i : uint = 0; i < 20; i++)
				{
					if (!(value[i] is Number) || isNaN(value[i])) throw new Error("The " + StringUtilPro.getNumeral(i+1) + " value in the Array is not a Number!");
				}
			}
			red = value[0];
			redFromGreen = value[1];
			redFromBlue = value[2];
			redFromAlpha = value[3];
			redOffset = value[4];
			
			greenFromRed = value[5];
			green = value[6];
			greenFromBlue = value[7];
			greenFromAlpha = value[8];
			greenOffset = value[9];
			
			blueFromRed = value[10];
			blueFromGreen = value[11];
			blue = value[12];
			blueFromAlpha = value[13];
			blueOffset = value[14];
			
			alphaFromRed = value[15];
			alphaFromGreen = value[16];
			alphaFromBlue = value[17];
			alpha = value[18];
			alphaOffset = value[19];
		}
		
		/**
		 * The first row of the matrix, reprisenting the red channel
		 */
		public function get redOutput() : Array
		{
			return [red, redFromGreen, redFromBlue, redFromAlpha, redOffset];
		}
		public function set redOutput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 5) throw new Error("The Array must have a length of 5!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
				if (!(value[4] is Number) || isNaN(value[4])) throw new Error("The Fifth value in the Array is not a Number!");
			}
			red = value[0];
			redFromGreen = value[1];
			redFromBlue = value[2];
			redFromAlpha = value[3];
			redOffset = value[4];
		}
		/**
		 * The second row of the matrix, reprisenting the green channel
		 */
		public function get greenOutput() : Array
		{
			return [greenFromRed, green, greenFromBlue, greenFromAlpha, greenOffset];
		}
		public function set greenOutput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 5) throw new Error("The Array must have a length of 5!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
				if (!(value[4] is Number) || isNaN(value[4])) throw new Error("The Fifth value in the Array is not a Number!");
			}
			greenFromRed = value[0];
			green = value[1];
			greenFromBlue = value[2];
			greenFromAlpha = value[3];
			greenOffset = value[4];
		}
		
		/**
		 * The third row of the matrix, reprisenting the blue channel
		 */
		public function get blueOutput() : Array
		{
			return [blueFromRed, blueFromGreen, blue, blueFromAlpha, blueOffset];
		}
		public function set blueOutput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 5) throw new Error("The Array must have a length of 5!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
				if (!(value[4] is Number) || isNaN(value[4])) throw new Error("The Fifth value in the Array is not a Number!");
			}
			blueFromRed = value[0];
			blueFromGreen = value[1];
			blue = value[2];
			blueFromAlpha = value[3];
			blueOffset = value[4];
		}
		
		/**
		 * The fourth and final row of the matrix, reprisenting the alpha channel
		 */
		public function get alphaOutput() : Array
		{
			return [alphaFromRed, alphaFromGreen, alphaFromBlue, alpha, alphaOffset];
		}
		public function set alphaOutput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 5) throw new Error("The Array must have a length of 5!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
				if (!(value[4] is Number) || isNaN(value[4])) throw new Error("The Fifth value in the Array is not a Number!");
			}
			alphaFromRed = value[0];
			alphaFromGreen = value[1];
			alphaFromBlue = value[2];
			alpha = value[3];
			alphaOffset = value[4];
		}
		
		/**
		 * An Array representing the red channel <b>input</b>.
		 * This Array basicly represents the first column of every row in the matrix.
		 */
		public function get redInput() : Array
		{
			return [red, greenFromRed, blueFromRed, alphaFromRed];
		}
		public function set redInput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 4) throw new Error("The Array must have a length of 4!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
			}
			red = value[0];
			greenFromRed = value[1];
			blueFromRed = value[2];
			alphaFromRed = value[3];
		}
		
		/**
		 * An Array representing the green channel <b>input</b>.
		 * This Array basicly represents the second column of every row in the matrix.
		 */
		public function get greenInput() : Array
		{
			return [redFromGreen, green, blueFromGreen, alphaFromGreen];
		}
		public function set greenInput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 4) throw new Error("The Array must have a length of 4!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
			}
			redFromGreen = value[0];
			green = value[1];
			blueFromGreen = value[2];
			alphaFromGreen = value[3];
		}
		
		/**
		 * An Array representing the blue channel <b>input</b>.
		 * This Array basicly represents the third column of every row in the matrix.
		 */
		public function get blueInput() : Array
		{
			return [redFromBlue, greenFromBlue, blue, alphaFromBlue];
		}
		public function set blueInput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 4) throw new Error("The Array must have a length of 4!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
			}
			redFromBlue = value[0];
			greenFromBlue = value[1];
			blue = value[2];
			alphaFromBlue = value[3];
		}
		
		/**
		 * An Array representing the alpha channel <b>input</b>.
		 * This Array basicly represents the fourth column of every row in the matrix.
		 */
		public function get alphaInput() : Array
		{
			return [redFromAlpha, greenFromAlpha, blueFromAlpha, alpha];
		}
		public function set alphaInput(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 4) throw new Error("The Array must have a length of 4!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
			}
			redFromAlpha = value[0];
			greenFromAlpha = value[1];
			blueFromAlpha = value[2];
			alpha = value[3];
		}
		
		/**
		 * An Array representing the color offset of every channel.
		 * This Array basicly represents the fifth and last column of every row in the matrix.
		 */
		public function get offset() : Array
		{
			return [redOffset, greenOffset, blueOffset, alphaOffset];
		}
		public function set offset(value : Array) : void
		{
			CONFIG::debug
			{
				if (value.length != 4) throw new Error("The Array must have a length of 4!");
				if (!(value[0] is Number) || isNaN(value[0])) throw new Error("The First value in the Array is not a Number!");
				if (!(value[1] is Number) || isNaN(value[1])) throw new Error("The Second value in the Array is not a Number!");
				if (!(value[2] is Number) || isNaN(value[2])) throw new Error("The Third value in the Array is not a Number!");
				if (!(value[3] is Number) || isNaN(value[3])) throw new Error("The Fourth value in the Array is not a Number!");
			}
			redOffset = value[0];
			greenOffset = value[1];
			blueOffset = value[2];
			alphaOffset = value[3];
		}
		/**
		 * Checks if the values of this ColorMatrix and the given ColorMatrix are equal.
		 * @param	matrix, the ColorMatrix in which to check for equality
		 * @return true if every value of the given matrix is equal to the corresponding value of this matrix, otherwise false.
		 */
		public function equals(matrix : ColorMatrix) : Boolean
		{
			if (red != matrix.red) return false;
			if (redFromGreen != matrix.redFromGreen) return false;
			if (redFromBlue != matrix.redFromBlue) return false;
			if (redFromAlpha != matrix.redFromAlpha) return false;
			if (redOffset != matrix.redOffset) return false;
			
			if (green != matrix.green) return false;
			if (greenFromRed != matrix.greenFromRed) return false;
			if (greenFromBlue != matrix.greenFromBlue) return false;
			if (greenFromAlpha != matrix.greenFromAlpha) return false;
			if (greenOffset != matrix.greenOffset) return false;
			
			if (blue != matrix.green) return false;
			if (blueFromRed != matrix.blueFromRed) return false;
			if (blueFromGreen != matrix.blueFromGreen) return false;
			if (blueFromAlpha != matrix.blueFromAlpha) return false;
			if (blueOffset != matrix.blueOffset) return false;
			
			if (alpha != matrix.green) return false;
			if (alphaFromRed != matrix.alphaFromRed) return false;
			if (alphaFromGreen != matrix.alphaFromGreen) return false;
			if (alphaFromBlue != matrix.alphaFromBlue) return false;
			if (alphaOffset != matrix.alphaOffset) return false;
			
			return true;
		}
		/**
		 * Checks if the values of this ColorMatrix and the given matrix are equal.
		 * The Array must have a length of 20 where every 5 values represent a row in the matrix
		 * @param	matrix, the matrix in which to check for equality
		 * @return true if every value of the given matrix is equal to the corresponding value of this matrix, otherwise false.
		 */
		public function equalsArray(matrix : Array) : Boolean
		{
			if (red != matrix[0]) return false;
			if (redFromGreen != matrix[1]) return false;
			if (redFromBlue != matrix[2]) return false;
			if (redFromAlpha != matrix[3]) return false;
			if (redOffset != matrix[4]) return false;
			
			if (green != matrix[5]) return false;
			if (greenFromRed != matrix[6]) return false;
			if (greenFromBlue != matrix[7]) return false;
			if (greenFromAlpha != matrix[8]) return false;
			if (greenOffset != matrix[9]) return false;
			
			if (blue != matrix[10]) return false;
			if (blueFromRed != matrix[11]) return false;
			if (blueFromGreen != matrix[12]) return false;
			if (blueFromAlpha != matrix[13]) return false;
			if (blueOffset != matrix[14]) return false;
			
			if (alpha != matrix[15]) return false;
			if (alphaFromRed != matrix[16]) return false;
			if (alphaFromGreen != matrix[17]) return false;
			if (alphaFromBlue != matrix[18]) return false;
			if (alphaOffset != matrix[19]) return false;
			
			return true;
		}
		/**
		 * @return A clone of this ColorMatrix
		 */
		public function clone() : ColorMatrix
		{
			var c : ColorMatrix = new ColorMatrix();
			
			c.red = red;
			c.redFromGreen = redFromGreen;
			c.redFromBlue = redFromBlue;
			c.redFromAlpha = redFromAlpha;
			c.redOffset = redOffset;
			
			c.greenFromRed = greenFromRed;
			c.green = green;
			c.greenFromBlue = greenFromBlue;
			c.greenFromAlpha = greenFromAlpha;
			c.greenOffset = greenOffset;
			
			c.blueFromRed = blueFromRed;
			c.blueFromGreen = blueFromGreen;
			c.blue = blue;
			c.blueFromAlpha = blueFromAlpha;
			c.blueOffset = blueOffset;
			
			c.alphaFromRed = alphaFromRed;
			c.alphaFromGreen = alphaFromGreen;
			c.alphaFromBlue = alphaFromBlue;
			c.alpha = alpha;
			c.alphaOffset = alphaOffset;
			
			return c;
		}
		
		public function toString() : String
		{
			return "┌─                                          ─┐\n"
				 + "│" + f(red) + ", " + f(redFromGreen) + ", " + f(redFromBlue) + ", " + f(redFromAlpha) + ", " + f(redOffset) + " │\n"
				 + "│" + f(greenFromRed) + ", " + f(green) + ", " + f(greenFromBlue) + ", " + f(greenFromAlpha) + ", " + f(greenOffset) + " │\n"
				 + "│" + f(blueFromRed) + ", " + f(blueFromGreen) + ", " + f(blue) + ", " + f(blueFromAlpha) + ", " + f(blueOffset) + " │\n"
				 + "│" + f(alphaFromRed) + ", " + f(alphaFromGreen) + ", " + f(alphaFromBlue) + ", " + f(alpha) + ", " + f(alphaOffset) + " │\n"
				 + "└─                                          ─┘";
		}
		private function f(value : Number) : String//format
		{
			var string : String = value.toPrecision(4);
			if (string.length == 4) return "   " + string;
			if (string.length == 5) return "  " + string;
			if (string.length == 6) return " " + string;
			return string;
		}
		
		//ORIGNAL COLORS
		public var red : Number = 1;
		public var green : Number = 1;
		public var blue : Number = 1;
		public var alpha : Number = 1;
		
		//MULITPLIERS
		public var redFromGreen : Number = 0;
		public var redFromBlue : Number = 0;
		public var redFromAlpha : Number = 0;
		
		public var greenFromRed : Number = 0;
		public var greenFromBlue : Number = 0;
		public var greenFromAlpha : Number = 0;
		
		public var blueFromRed : Number = 0;
		public var blueFromGreen : Number = 0;
		public var blueFromAlpha : Number = 0;
		
		public var alphaFromRed : Number = 0;
		public var alphaFromGreen : Number = 0;
		public var alphaFromBlue : Number = 0;
		
		//OFFSETS
		public var redOffset : Number = 0;
		public var greenOffset : Number = 0;
		public var blueOffset : Number = 0;
		public var alphaOffset : Number = 0;
	}

}