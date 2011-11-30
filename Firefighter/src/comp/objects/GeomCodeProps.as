package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import comp.particles.Heat;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeProps extends Component implements IExclusiveComponent 
	{
				
		private static var _init : Boolean = init();
		private static function init() : Boolean
		{
			Renderer.load("sofa0", "assets/img/props.png~20~")
			Renderer.load("sofa1", "assets/img/props.png~21~")
			Renderer.load("sofa2", "assets/img/props.png~22~")
			Renderer.load("sofa3", "assets/img/props.png~23~")
			Renderer.load("sofa4", "assets/img/props.png~24~")
			Renderer.load("sofa5", "assets/img/props.png~25~")
			Renderer.load("sofa6", "assets/img/props.png~26~")
			Renderer.load("sofa7", "assets/img/props.png~27~")
			Renderer.load("table0", "assets/img/props.png~18~")
			Renderer.load("table1", "assets/img/props.png~19~")
			Renderer.load("table2", "assets/img/props.png~28~")
			Renderer.load("fridge0", "assets/img/props.png~6~")
			Renderer.load("fridge1", "assets/img/props.png~7~")
			Renderer.load("painting0", "assets/img/props.png~14~")
			Renderer.load("painting1", "assets/img/props.png~15~")
			Renderer.load("painting2", "assets/img/props.png~16~")
			Renderer.load("painting3", "assets/img/props.png~17~")
			Renderer.load("chair0", "assets/img/props.png~1~")
			Renderer.load("chair1", "assets/img/props.png~2~")
			Renderer.load("chair2", "assets/img/props.png~3~")
			Renderer.load("chair3", "assets/img/props.png~4~")
			Renderer.load("chair4", "assets/img/props.png~5~")
			Renderer.load("bed0", "assets/img/props.png~0~")
			Renderer.load("tv0", "assets/img/props.png~29~")
			Renderer.load("tv1", "assets/img/props.png~30~")
			Renderer.load("tv2", "assets/img/props.png~31~")
			Renderer.load("lamp0", "assets/img/props.png~8~")
			Renderer.load("lamp1", "assets/img/props.png~9~")
			Renderer.load("lamp2", "assets/img/props.png~32~")
			Renderer.load("lamp3", "assets/img/props.png~11~")
			Renderer.load("closet0", "assets/img/props.png~32~")
			Renderer.load("closet1", "assets/img/props.png~12~")
			Renderer.load("closet2", "assets/img/props.png~13~")
			Renderer.load("closet3", "assets/img/props.png~33~")
			Renderer.load("closet4", "assets/img/props.png~34~")
			Renderer.load("closet5", "assets/img/props.png~35~")
			Renderer.load("misc0", "assets/img/props.png~36~")
			Renderer.load("misc1", "assets/img/props.png~37~")
			Renderer.load("misc2", "assets/img/props.png~38~")
			Renderer.load("misc3", "assets/img/props.png~39~")
			Renderer.load("misc4", "assets/img/props.png~40~")
			Renderer.load("misc5", "assets/img/props.png~43~")
			Renderer.load("misc6", "assets/img/props.png~44~")
			Renderer.load("misc7", "assets/img/props.png~45~")
			Renderer.load("misc8", "assets/img/props.png~46~")
			Renderer.load("misc9", "assets/img/props.png~47~")
			Renderer.load("misc10", "assets/img/props.png~48~")
			Renderer.load("misc11", "assets/img/props.png~49~")
			Renderer.load("misc12", "assets/img/props.png~50~")
			Renderer.load("misc13", "assets/img/props.png~51~")
			Renderer.load("misc14", "assets/img/props.png~52~")
			Renderer.load("misc15", "assets/img/props.png~53~")
			Renderer.load("misc16", "assets/img/props.png~54~")
			Renderer.load("misc17", "assets/img/props.png~55~")
			Renderer.load("misc18", "assets/img/props.png~56~")
			Renderer.load("misc19", "assets/img/props.png~57~")
			Renderer.load("misc20", "assets/img/props.png~58~")
			Renderer.load("misc21", "assets/img/props.png~59~")
			Renderer.load("misc22", "assets/img/props.png~60~")
			Renderer.load("misc23", "assets/img/props.png~61~")
			Renderer.load("misc24", "assets/img/props.png~62~")
			Renderer.load("misc25", "assets/img/props.png~52~")
			Renderer.load("closet6", "assets/img/props.png~13~")
			Renderer.load("misc26", "assets/img/props.png~63~")
			Renderer.load("misc27", "assets/img/props.png~64~")
			Renderer.load("misc28", "assets/img/firetruck.png")
			Renderer.load("misc29", "assets/img/props.png~66~")
			Renderer.load("misc30", "assets/img/props.png~67~")

			return true;
		}
		
		/** @private **/
		public function awake() : void
		{
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: LAMPS ::::::::::::::::::::::::::
		public function geomLamp(lamp : GameObject, params : Object) : void
		{
			lamp.addComponent(Heat);
			var ren : Renderer = lamp.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("lamp" + params.type);
			ren.sendToBack();
			var col : BoxCollider = lamp.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 3:
					ren.setOffset(0, -25);
					col.dimensions = new Point(32, 32);
					break;
				case 2:
					ren.setOffset(-5, -20);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, -22);
					col.dimensions = new Point(32, 32);
					break;
				default:
					ren.setOffset(2, -20);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		//{::::::::::::::::::::::::: TVs ::::::::::::::::::::::::::
		public function geomTV(tv : GameObject, params : Object) : void
		{
			tv.addComponent(Heat);
			var ren : Renderer = tv.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("tv" + params.type);
			ren.sendToBack();
			var col : BoxCollider = tv.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 2:
					ren.setOffset(0, -28);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, -20);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, -13);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		
		//{::::::::::::::::::::::::: Closets ::::::::::::::::::::::::::
		public function geomCloset(closet : GameObject, params : Object) : void
		{
			closet.addComponent(Heat);
			var ren : Renderer = closet.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("closet" + params.type);
			ren.sendToBack();
			var col : BoxCollider = closet.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 6:
					ren.setOffset(0, 0, 0.6);
					col.dimensions = new Point(32, 32);
					break;
				case 5:
					ren.setOffset(0, 0, 1.4);
					col.dimensions = new Point(32, 32);
					break;
				case 4:
					ren.setOffset(0, 0, 1.4);
					col.dimensions = new Point(32, 32);
					break;
				case 3:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 2:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 1.2);
					col.dimensions = new Point(32, 32);
					break;
			}
			if (params.flipped == true)
			{
				ren.offset.rotate(Math.PI / 2);
			}
			
		}
		
		//{::::::::::::::::::::::::: Chairs ::::::::::::::::::::::::::
		public function geomChair(chair : GameObject, params : Object) : void
		{
			chair.addComponent(Heat);
			var ren : Renderer = chair.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("chair" + params.type);
			ren.sendToBack();
			var col : BoxCollider = chair.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 4:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 3:
					ren.setOffset(0, 0, 0.75);
					col.dimensions = new Point(32, 32);
					break;
				case 2:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
			}
			if (params.flipped == true)
			{
				ren.offset.a = -ren.offset.a;
			}
		}
		
		//{::::::::::::::::::::::::: Painting ::::::::::::::::::::::::::
		public function geomPainting(painting : GameObject, params : Object) : void
		{
			painting.addComponent(Heat);
			var ren : Renderer = painting.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("painting" + params.type);
			ren.sendToBack();
			var col : BoxCollider = painting.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 3:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 2:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		
		//{::::::::::::::::::::::::: Beds ::::::::::::::::::::::::::
		public function geomBed(bed : GameObject, params : Object) : void
		{
			bed.addComponent(Heat);
			var ren : Renderer = bed.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("bed" + params.type);
			ren.sendToBack();
			var col : BoxCollider = bed.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 0: 
				default:
					ren.setOffset(0, 0, 1.5);
					col.dimensions = new Point(32, 32);
					break;
			}
			if (params.flipped == true)
			{
				ren.offset.a = -ren.offset.a;
			}
		}
		
		//{::::::::::::::::::::::::: Fridge ::::::::::::::::::::::::::
		public function geomFridge(fridge : GameObject, params : Object) : void
		{
			fridge.addComponent(Heat);
			var ren : Renderer = fridge.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("fridge" + params.type);
			ren.sendToBack();
			var col : BoxCollider = fridge.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 1:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 1.5);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		
		//{::::::::::::::::::::::::: Tables ::::::::::::::::::::::::::
		public function geomTable(table : GameObject, params : Object) : void
		{
			table.addComponent(Heat);
			var ren : Renderer = table.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("table" + params.type);
			ren.sendToBack();
			var col : BoxCollider = table.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 2:
					ren.setOffset(0, 0, 1.5);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, 0, 1.5);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 1.2);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		
		//{::::::::::::::::::::::::: Sofas ::::::::::::::::::::::::::
		public function geomSofa(sofa : GameObject, params : Object) : void
		{
			sofa.addComponent(Heat);
			var ren : Renderer = sofa.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("sofa" + params.type);
			ren.sendToBack();
			var col : BoxCollider = sofa.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(params.type)
			{
				case 7:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 6:
					ren.setOffset(0, 0, 0.9);
					col.dimensions = new Point(32, 32);
					break;
				case 5:
					ren.setOffset(0, 0, 1.65);
					col.dimensions = new Point(32, 32);
					break;
				case 4:
					ren.setOffset(0, 0, 1.8);
					col.dimensions = new Point(32, 32);
					break;
				case 3:
					ren.setOffset(0, 0, 2);
					col.dimensions = new Point(32, 32);
					break;
				case 2:
					ren.setOffset(0, 0, 1.3);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 1.7);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		
		//{::::::::::::::::::::::::: Misc ::::::::::::::::::::::::::
		public function geomMisc(misc : GameObject, params : Object) : void
		{
			misc.addComponent(Heat);
			var ren : Renderer = misc.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("misc" + params.type);
			ren.sendToBack();
			var col : BoxCollider = misc.addComponent(BoxCollider) as BoxCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			/*
			 * 0  - Tecup
			 * 1  - BeerBottle
			 * 2  - CoffeeMachine
			 * 3  - Computer1
			 * 4  - Computer2
			 * 5  - Microwave1
			 * 6  - Microwave2
			 * 7  - Mirror1
			 * 8  - ComputerMonitor
			 * 9  - Plant
			 * 32 - Toaster
			 * 11 - ComputerMonitorSide
			 * 12 - WindowOpen
			 * 13 - WindowClosed
			 * 14 - Mirror2
			 * 15 - Mirror3
			 * 16 - ShoeStand1
			 * 17 - ShoeStand2
			 * 18 - Sink
			 * 19 - Toilet
			 * 20 - WindowOutside
			 * 21 - Tub
			 * 22 - BedDouble1
			 * 23 - BedDouble2
			 * 24 - Shower
			 * 25 - Mirror2 resized
			 * 26 - Painting 4
			 * 27 - FiretruckPart1 - not used
			 * 28 - FiretruckPart2
			 * 29 - Towelrack1
			 * 30 - Towelrack2
			 * */
			switch(params.type)
			{
				case 30:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 29:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 28:
					ren.setOffset(0, 0, 1.3);
					col.dimensions = new Point(32, 32);
					break;
				case 27:
					ren.setOffset(0, 0, 2.5);
					col.dimensions = new Point(32, 32);
					break;
				case 26:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 25:
					ren.setOffset(0, 0, 0.7);
					col.dimensions = new Point(32, 32);
					break;
				case 24:
					ren.setOffset(0, 0, 1.6);
					col.dimensions = new Point(32, 32);
					break;
				case 23:
					ren.setOffset(0, 0, 2.0);
					col.dimensions = new Point(32, 32);
					break;
				case 22:
					ren.setOffset(0, 0, 2.0);
					col.dimensions = new Point(32, 32);
					break;
				case 21:
					ren.setOffset(0, 0, 1.5);
					col.dimensions = new Point(32, 32);
					break;
				case 20:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 19:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 18:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 17:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 16:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 15:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 14:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 13:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 12:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 11:
					ren.setOffset(0, 0, 0.7);
					col.dimensions = new Point(32, 32);
					break;
				case 32:
					ren.setOffset(0, 0, 0.6);
					col.dimensions = new Point(32, 32);
					break;
				case 9:
					ren.setOffset(0, 0);
					col.dimensions = new Point(32, 32);
					break;
				case 8:
					ren.setOffset(0, 0, 0.7);
					col.dimensions = new Point(32, 32);
					break;
				case 7:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 6:
					ren.setOffset(0, 0, 0.7);
					col.dimensions = new Point(32, 32);
					break;
				case 5:
					ren.setOffset(0, 0, 0.65);
					col.dimensions = new Point(32, 32);
					break;
				case 4:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(32, 32);
					break;
				case 3:
					ren.setOffset(0, 0, 0.47);
					col.dimensions = new Point(32, 32);
					break;
				case 2:
					ren.setOffset(0, 0, 0.5);
					col.dimensions = new Point(32, 32);
					break;
				case 1:
					ren.setOffset(0, 0, 0.3);
					col.dimensions = new Point(32, 32);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 0.2);
					col.dimensions = new Point(32, 32);
					break;
			}
		}
		
		/*
		//{::::::::::::::::::::::::: Closets ::::::::::::::::::::::::::
		public function geomCloset(closet : GameObject, params : Object) : void
		{
			closet.addComponent(Heat);
			var ren : Renderer = closet.addComponent(Renderer) as Renderer;
			ren.setBitmapByName("closet" + params.type);
			ren.sendToBack();
			switch(params.type)
			{
				case 0: 
				default:
					ren.setOffset(0, -13);
					break;
			}
			closet.type = params.type;
		}
		public function geomClosetComplete(closet : GameObject) : void
		{
			var col : TriangleCollider = closet.addComponent(TriangleCollider) as TriangleCollider;
			col.layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_FIRE;
			switch(closet.type)
			{
				case 0: 
				default:
					col.defineSizeAndAnchor(32, 0.5, -1);
					break;
			}
			delete closet.type;
		}
		*/
	}
}