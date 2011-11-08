package com.danielsig
{
	import com.danielsig.MathLite;
	import com.demonsters.debugger.MonsterDebugger;
	
	public class ColorFactory
	{
		public static const RGBA_RED : uint = 0xFF000000;
		public static const RGBA_GREEN : uint = 0x00FF0000;
		public static const RGBA_BLUE : uint = 0x0000FF00;
		public static const RGBA_CYAN : uint = 0x00FFFF00;
		public static const RGBA_MAGENTA : uint = 0xFF00FF00;
		public static const RGBA_YELLOW : uint = 0xFFFF0000;
		public static const RGBA_ORANGE : uint = 0xFF880000;
		public static const RGBA_PURPLE : uint = 0x8800FF00;
		public static const RGBA_PINK : uint = 0xFF888800;
		public static const RGBA_BROWN : uint = 0x88440000;
		public static const RGBA_WHITE : uint = 0xFFFFFF00;
		public static const RGBA_GRAY : uint = 0x88888800;
		public static const RGBA_GREY : uint = 0x88888800;
		public static const RGBA_BLACK : uint = 0x00000000;
		public static const RGBA_OPAQUE : uint = 0xFF;
		public static const RGBA_TRANSLUCENT : uint = 0x88;
		public static const RGBA_CLEAR : uint = 0x00;
		
		public static const RGB_RED : uint = 0xFF0000;
		public static const RGB_GREEN : uint = 0x00FF00;
		public static const RGB_BLUE : uint = 0x0000FF;
		public static const RGB_CYAN : uint = 0x00FFFF;
		public static const RGB_MAGENTA : uint = 0xFF00FF;
		public static const RGB_YELLOW : uint = 0xFFFF00;
		public static const RGB_ORANGE : uint = 0xFF8800;
		public static const RGB_PURPLE : uint = 0x8800FF;
		public static const RGB_PINK : uint = 0xFF8888;
		public static const RGB_BROWN : uint = 0x884400;
		public static const RGB_WHITE : uint = 0xFFFFFF;
		public static const RGB_GRAY : uint = 0x888888;
		public static const RGB_GREY : uint = 0x888888;
		public static const RGB_BLACK : uint = 0x000000;
		
		public static const DIVIDE_BY_255 : Number = 1 / 255;
		
		public static function CreateRGB(r : Number, g : Number, b : Number) : uint
		{
			r = MathLite.Clamp01(r);
			g = MathLite.Clamp01(g);
			b = MathLite.Clamp01(b);
			return (uint(r * 255) << 16)
				 + (uint(g * 255) << 8)
				 + (uint(b * 255));
		}
		public static function CreateRGBA(r : Number, g : Number, b : Number, a : Number) : uint
		{
			r = MathLite.Clamp01(r);
			g = MathLite.Clamp01(g);
			b = MathLite.Clamp01(b);
			return (uint(r * 255) << 24)
				+ (uint(g * 255) << 16)
				+ (uint(b * 255) << 8)
				+ uint(a * 255);
		}
		public static function CreateRGBThermalScale(heat : Number) : uint
		{
			heat = MathLite.Clamp01(heat);
			var redHeat : Number = Math.cos(heat*1.64);
			var red : uint = (1 - redHeat * redHeat * redHeat * redHeat) * 255;
			var green : uint = heat * heat * heat * 255;
			var blue : uint = (Math.sin(heat * 6.8068) * 0.5 + heat * 0.75) * 255;
			return (red << 16) + (green << 8) + blue;
		}
		public static function CreateRGBGrayscale(brightness : Number) : uint
		{
			brightness = uint(MathLite.Clamp01(brightness) * 255);
			return (brightness << 16)
				 + (brightness << 8)
				 + (brightness);
		}
		public static function RGBDesturate(color : uint) : uint
		{
			var channels : Vector.<uint> = ParseRGB(color);
			var brightness : uint = uint((channels[0] + channels[1] + channels[2]) * 0.3333333333333333);
			return (brightness << 16)
				+ (brightness << 8)
				+ (brightness);
		}
		public static function RGBToGrayscale(color : uint) : uint
		{
			var channels : Vector.<uint> = ParseRGB(color);
			var brightness : uint = uint(channels[0] * 0.3 + channels[1] * 0.59 + channels[2] * 0.11);
			return (brightness << 16)
				+ (brightness << 8)
				+ (brightness);
		}
		public static function ParseRGBA(color : uint) : Vector.<uint>
		{
			return new <uint>[(color >>> 24) & 0xFF, (color >>> 16) & 0xFF, (color >>> 8) & 0xFF, color & 0xFF];
		}
		public static function ParseRGB(color : uint) : Vector.<uint>
		{
			color &= RGB_WHITE;
			return new <uint>[(color >>> 16) & 0xFF, (color >>> 8) & 0xFF, color & 0xFF];
		}
		public static function CombineChannels(color : Vector.<uint>) : uint
		{
			if(color.length > 3)
			{
				return (color[0] << 24) + (color[1] << 16) + (color[2] << 8) + color[3];
			}
			return (color[0] << 16) + (color[1] << 8) + color[2];
		}
		public static function GetRGBFromString(colorString : String) : uint
		{
			switch(colorString)
			{
				case RED_STRING:
					return RGB_RED;
				case GREEN_STRING:
					return RGB_GREEN;
				case BLUE_STRING:
					return RGB_BLUE;
				case CYAN_STRING:
					return RGB_CYAN;
				case MAGENTA_STRING:
					return RGB_MAGENTA;
				case YELLOW_STRING:
					return RGB_YELLOW;
				case ORANGE_STRING:
					return RGB_ORANGE;
				case PURPLE_STRING:
					return RGB_PURPLE;
				case PINK_STRING:
					return RGB_PINK;
				case BROWN_STRING:
					return RGB_BROWN;
				case WHITE_STRING:
					return RGB_WHITE;
				case GRAY_STRING:
					return RGB_GRAY;
				case GREY_STRING:
					return RGB_GREY;
				case BLACK_STRING:
					return RGB_BLACK;
				default:
					return uint(colorString);
			}
		}
		public static function GetRGBAFromString(colorString : String, transparency : uint = RGBA_OPAQUE) : uint
		{
			if(transparency > RGBA_OPAQUE)
			{
				transparency = RGBA_OPAQUE;
			}
			return (GetRGBFromString(colorString)<<8) + transparency;
		}
		public static function RGBToString(color : uint) : String
		{
			switch(color & RGB_WHITE)
			{
				case RGB_RED:
					return RED_STRING;
				case RGB_GREEN:
					return GREEN_STRING;
				case RGB_BLUE:
					return BLUE_STRING;
				case RGB_CYAN:
					return CYAN_STRING;
				case RGB_MAGENTA:
					return MAGENTA_STRING;
				case RGB_YELLOW:
					return YELLOW_STRING;
				case RGB_ORANGE:
					return ORANGE_STRING;
				case RGB_PURPLE:
					return PURPLE_STRING;
				case RGB_PINK:
					return PINK_STRING;
				case RGB_BROWN:
					return BROWN_STRING;
				case RGB_WHITE:
					return WHITE_STRING;
				case RGB_GRAY:
					return GRAY_STRING;
				case RGB_GREY:
					return GREY_STRING;
				case RGB_BLACK:
					return BLACK_STRING;
				default:
					return ToRGBChannelString(color);
			}
		}
		public static function RGBAToString(color : uint) : String
		{
			var rgb : String = RGBToString(color);
			if(rgb.charAt(rgb.length - 1) == ")")
			{
				return AddAlpha(rgb, color);
			}
			return AddAlpha2(rgb, color);
		}
		public static function ToRGBChannelString(color : uint) : String
		{
			return "(" + RedOfRGB(color).toFixed(2) + ", " + GreenOfRGB(color).toFixed(2) + ", " + BlueOfRGB(color).toFixed(2) + ")";
		}
		public static function ToRGBAChannelString(color : uint) : String
		{
			var rgb : String = ToRGBChannelString(color);
			return AddAlpha(rgb, color);
		}
		public static function RedOfRGB(color : uint) : Number
		{
			return ((color >>> 16) & 0xFF) * DIVIDE_BY_255;
		}
		public static function GreenOfRGB(color : uint) : Number
		{
			return ((color >>> 8) & 0xFF) * DIVIDE_BY_255;
		}
		public static function BlueOfRGB(color : uint) : Number
		{
			return (color & 0xFF) * DIVIDE_BY_255;
		}
		public static function RedOfRGBA(color : uint) : Number
		{
			return ((color >>> 24) & 0xFF) * DIVIDE_BY_255;
		}
		public static function GreenOfRGBA(color : uint) : Number
		{
			return ((color >>> 16) & 0xFF) * DIVIDE_BY_255;
		}
		public static function BlueOfRGBA(color : uint) : Number
		{
			return ((color >>> 8) & 0xFF) * DIVIDE_BY_255;
		}
		public static function AlphaOfRGBA(color : uint) : Number
		{
			return (color & 0xFF) * DIVIDE_BY_255;
		}
		public static function NoAlphaOfRGBA(color : uint) : uint
		{
			return color & RGBA_WHITE;
		}
		public static function ToRGBA(color : uint) : uint
		{
			return (color & RGB_WHITE) << 8;
		}
		public static function ToRGB(color : uint) : uint
		{
			return (color >>> 8) & RGB_WHITE;
		}
		public static function NormalizeRGBA(color : uint) : uint
		{
			return (NormalizeRGB(color >>> 8) << 8) + (color & RGBA_OPAQUE);
		}
		public static function NormalizeRGB(color : uint) : uint
		{
			color &= RGB_WHITE;
			var channels : Vector.<uint> = ParseRGB(color);
			var maxChannel : uint = MaxChannel(channels);
			if(maxChannel == 255)
			{
				return color;
			}
			else
			{
				if(maxChannel == 0)
				{
					return RGB_WHITE;
				}
				var ratio : Number = 255.0 / maxChannel;
								
				channels[0] *= ratio;
				channels[1] *= ratio;
				channels[2] *= ratio;
				
				return CombineChannels(channels);
			}
		}
		public static function TintOfRGBA(color : uint) : uint
		{
			return (TintOfRGB(color >>> 8) << 8) + (color & RGBA_OPAQUE);
		}
		public static function TintOfRGB(color : uint) : uint
		{
			color &= RGB_WHITE;
			var channels : Vector.<uint> = ParseRGB(color);
			var maxChannel : uint = MaxChannel(channels);
			
			if(maxChannel == 255)
			{
				return color;
			}
			else
			{
				if(maxChannel == 0)
				{
					return RGB_WHITE;
				}
				var ratio : Number = 255 - maxChannel;
								
				channels[0] += ratio;
				channels[1] += ratio;
				channels[2] += ratio;
				
				return CombineChannels(channels);
			}
		}
		
		private static const RED_STRING : String = "red";
		private static const GREEN_STRING : String = "green";
		private static const BLUE_STRING : String = "blue";
		private static const CYAN_STRING : String = "cyan";
		private static const MAGENTA_STRING : String = "magenta";
		private static const YELLOW_STRING : String = "yellow";
		private static const ORANGE_STRING : String = "orange";
		private static const PURPLE_STRING : String = "purple";
		private static const PINK_STRING : String = "pink";
		private static const BROWN_STRING : String = "brown";
		private static const WHITE_STRING : String = "white";
		private static const GRAY_STRING : String = "gray";
		private static const GREY_STRING : String = "grey";
		private static const BLACK_STRING : String = "black";
		private static const OPAQUE_STRING : String = "opaqe";
		private static const TRANSLUCENT_STRING : String = "translucent";
		private static const CLEAR_STRING : String = "clear";
		
		private static function MaxChannel(channels : Vector.<uint>) : uint
		{
			var maxChannel : uint = channels[0];
			if(channels[1] > maxChannel)
			{
				maxChannel = channels[1]
			}
			if(channels[2] > maxChannel)
			{
				maxChannel = channels[2]
			}
			return maxChannel;
		}
		
		private static function AddAlpha(rgb : String, color : uint) : String
		{
			return rgb.slice(0, rgb.length-1) + ", " + AlphaOfRGBA(color).toFixed(2) + ")";
		}
		private static function AddAlpha2(rgb : String, color : uint) : String
		{
			return rgb + "*" + AlphaOfRGBA(color).toFixed(2);
		}
	}
}