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
			Renderer.load("lamp2", "assets/img/props.png~10~")
			Renderer.load("lamp3", "assets/img/props.png~11~")
			Renderer.load("closet0", "assets/img/props.png~32~")
			Renderer.load("closet1", "assets/img/props.png~12~")
			Renderer.load("closet2", "assets/img/props.png~13~")
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
					col.dimensions = new Point(60, 115);
					break;
				case 2:
					ren.setOffset(-5, -20);
					col.dimensions = new Point(50, 128);
					break;
				case 1:
					ren.setOffset(0, -22);
					col.dimensions = new Point(20, 128);
					break;
				default:
					ren.setOffset(2, -20);
					col.dimensions = new Point(60, 128);
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
					col.dimensions = new Point(128, 74);
					break;
				case 1:
					ren.setOffset(0, -20);
					col.dimensions = new Point(128, 90);
					break;
				case 0: 
				default:
					ren.setOffset(0, -13);
					col.dimensions = new Point(128, 102);
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
				case 2:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 90);
					break;
				case 1:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 90);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
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
					col.dimensions = new Point(128, 128);
					break;
				case 3:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
				case 2:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
				case 1:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
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
					col.dimensions = new Point(128, 128);
					break;
				case 2:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
				case 1:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
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
					ren.setOffset(0, 0, 2);
					col.dimensions = new Point(128, 128);
					break;
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
					col.dimensions = new Point(128, 128);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0);
					col.dimensions = new Point(128, 128);
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
					col.dimensions = new Point(128, 128);
					break;
				case 1:
					ren.setOffset(0, 0, 1.5);
					col.dimensions = new Point(128, 128);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 1.2);
					col.dimensions = new Point(128, 128);
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
					col.dimensions = new Point(128, 128);
					break;
				case 6:
					ren.setOffset(0, 0, 0.9);
					col.dimensions = new Point(128, 128);
					break;
				case 5:
					ren.setOffset(0, 0, 1.65);
					col.dimensions = new Point(128, 128);
					break;
				case 4:
					ren.setOffset(0, 0, 1.8);
					col.dimensions = new Point(128, 128);
					break;
				case 3:
					ren.setOffset(0, 0, 2);
					col.dimensions = new Point(128, 128);
					break;
				case 2:
					ren.setOffset(0, 0, 1.4);
					col.dimensions = new Point(128, 128);
					break;
				case 1:
					ren.setOffset(0, 0, 0.8);
					col.dimensions = new Point(128, 128);
					break;
				case 0: 
				default:
					ren.setOffset(0, 0, 1.7);
					col.dimensions = new Point(128, 128);
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
					col.defineSizeAndAnchor(128, 0.5, -1);
					break;
			}
			delete closet.type;
		}
		*/
	}
}