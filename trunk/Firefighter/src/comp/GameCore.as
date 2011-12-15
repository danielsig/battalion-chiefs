package comp
{
	import com.danielsig.ChanceGenerator;
	import com.danielsig.StringUtilPro;
	import com.danielsig.DeletionType;
	import comp.particles.*;
	import comp.human.*;
	import comp.objects.*;
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.display.ColorMatrix;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.display.PixelSnapping;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.flashpoint.comp.tools.*;
	import flash.utils.*;
	
	/**
	 * @author Battalion Chiefs
	 */
	public class GameCore extends Component implements IExclusiveComponent
	{
		
		public static const EASY : uint = 0;
		public static const NORMAL : uint = 1;
		public static const HARD : uint = 2;
		
		public static var difficulty : uint = EASY;
		
		public function start() : void 
		{
			//Audio.useHeadphones = true;
			
			Physics.maxSize = 600;
			Physics.restingSpeed = 0.2;
			Physics.gravityVector = new Point(0, 3000);
			Physics.iterations = 2;
			
			TileRenderer.loadMap("level1", "assets/maps/tilemap1.png");
			TileRenderer.loadSet("level1Set", "assets/tiles/tileset1.png~0-63~");
			var tileRenderer : TileRenderer = addComponent(TileRenderer) as TileRenderer;
			tileRenderer.setTileMapByName("level1");
			tileRenderer.setTileSetByName("level1Set");
			const ALL : uint = uint.MAX_VALUE;
			tileRenderer.setAsCollisionMap(new Point( -200, -200),
				0,   ALL, ALL, ALL, ALL, ALL, 0,   0,
				ALL, ALL, ALL, ALL, ALL, ALL, ALL, ALL,
				0,   0,   0,   0,   0,   0,   0,   0,
				0,   0,   0,   0
			);
			
			
			
			var geomCode : GeomCodeRuntime = world.addComponent(GeomCodeRuntime) as GeomCodeRuntime;
			world.addComponent(GeomCodePrimitives);
			world.addComponent(GeomCodeDoors);
			world.addComponent(GeomCodeStairs);
			world.addComponent(GeomCodeProps);
			geomCode.source = "assets/geomcode/Level1.gmc";
			
			geomCode.construct("Level1");
			//geomCode.construct("TV", {pos:new Point(180, 150), mass:10});
			
			
			
			
			/*
			var samusObj : GameObject = new GameObject("samus", Renderer, Animation, Audio, PlayerController, BoxCollider, Rigidbody);
			Audio.load("samusSound", "assets/sound/samus.mp3~100-2000~");
			Animation.load("samusRunning", "assets/img/samus.png~0-9~");
			
			Animation.filterWhite("samusRunning");
			
			samusObj.animation.play("samusRunning");
			Animation.addLabel("samusRunning", "Audio_gotoAndPlay", 0, 200, "samusSound");
			Animation.addLabel("samusRunning", "Audio_gotoAndPlay", 5, 200, "samusSound");
			samusObj.boxCollider.dimensions = new Point(62, 126);
			samusObj.boxCollider.material = new PhysicMaterial(0.3, 0);
			samusObj.rigidbody.mass = 50;
			samusObj.rigidbody.drag = 0;
			samusObj.rigidbody.freezeRotation = true;
			samusObj.transform.x = 4200;
			samusObj.transform.y = 1260;
			*/
		}
		public function tilesLoaded() : void 
		{
			//MouseLocation.create();
			var player : GameObject = PlayerController.createPlayer(2500, 330);
			var human1 : GameObject = CivilianController.createCivilian(6200, 400);
			var human2 : GameObject = CivilianController.createCivilian(4200, 400);
			/*
			var box : GameObject = new GameObject("myBox", Rigidbody, BoxCollider, Renderer, Heat);
			(box.renderer as Renderer).setBitmapByName("tv0");
			(box.renderer as Renderer).setOffset(0, -20);
			(box.boxCollider as BoxCollider).dimensions = new Point(120, 100);
			(box.boxCollider as BoxCollider).layers = Layers.OBJECTS_VS_OBJECTS | Layers.OBJECTS_VS_HUMANS | Layers.OBJECTS_VS_WATER | Layers.OBJECTS_VS_FIRE;
			box.transform.x = 150;
			box.transform.y = 150;*/
		}
	}
}