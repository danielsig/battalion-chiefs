package comp
{
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
			Physics.maxSize = 300;
			Physics.restingSpeed = 0.002;
			Physics.gravityVector = new Point(0, 0.9);
			Physics.iterations = 3;
			
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
			world.addComponent(GeomCodeProps);
			geomCode.source = "assets/geomcode/Level1.gmc";
			
			geomCode.construct("Level1");
			
			
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
			var player : GameObject = PlayerController.createPlayer(4200, 1200);
			//Renderer.sendGameObjectToFront(player);
			//var human : GameObject = Civilian.createCivilian(4600, 1200);
		}
	}
}