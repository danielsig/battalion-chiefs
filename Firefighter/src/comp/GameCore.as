package comp
{
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
	import factory.BoxFactory;
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
		public function start() : void 
		{
			var color : ColorMatrix  = (world.cam.camera as Camera).colorMatrix = new ColorMatrix();
			
			//color.saturate( -1);
			//color.tint(0x80FF80, 1);
			trace(color);
			
			
			/*var grid : BitmapData = new BitmapData(20, 10, true, 0xFF000007);
			grid.fillRect(new Rectangle(0, 0, 20, 9), 0);
			grid.fillRect(new Rectangle(4, 8, 3, 2), 0xFF000007);
			Physics.grid = grid;
			Physics.unitSize = 64;*/
			Physics.maxSize = 300;
			Physics.gravityVector = new Point(0, 0.9);
			Physics.iterations = 1;
			//Physics.init();
			
			//FlashPoint.timeScale = 0.05;
			//world.cam.transform.scale = 15;
			
			TileRenderer.loadMap("level1", "assets/maps/tilemap1.png");
			TileRenderer.loadSet("level1Set", "assets/tiles/tileset1.png~0-63~");
			
			var tileRenderer : TileRenderer = addComponent(TileRenderer) as TileRenderer;
			tileRenderer.setTileMapByName("level1");
			tileRenderer.setTileSetByName("level1Set");
			
			const ALL : uint = uint.MAX_VALUE;
			tileRenderer.setAsCollisionMap(new Point( -200, -200),
			0, ALL, ALL, ALL, ALL, ALL, 0, 0,
			ALL, ALL, ALL, ALL, ALL, ALL, ALL, ALL,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			
			var geomCode : GeomCodeRuntime = world.addComponent(GeomCodeRuntime) as GeomCodeRuntime;
			world.addComponent(GeomCodePrimitives);
			geomCode.source = "assets/geomcode/Main.gmc";
			//geomCode.construct("BrickWall", { pos:new Point(223.5, 311.9), broken:false, height:6} );
			
			Renderer.draw("head",
				"fill", { color:"0x555555" },
				-7, -10,
				7, -10,
				7, 10,
				-7, 10
			);
			Renderer.draw("aboxGraph",
			"fill", { color:"0xBB0000" },
				0, 0,
				20, 0,
				20, 20,
				0, 20
			);
			Renderer.draw("aballGraph",
			"fill", { color:"0xBB0000" },
			"circle", {radius:30}
			);
			
			var samusObj : GameObject = new GameObject("samus", Renderer, Animation, Audio, DummyController, BoxCollider, Rigidbody);
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
			/*
			Fire.createFire(4200, 520);
			Fire.createFire(4200, 1260);
			Fire.createFire(4200, 1900);
			
			Fire.createFire(6120, 500);
			Fire.createFire(6000, 1000);
			
			Fire.createFire(7410, 850);
			*/
			
			/*
			var mouse : GameObject = new GameObject("mouse" + c, Renderer, FollowMouse);
			mouse.renderer.setBitmapByName("aballGraph");
			*/
			
			var amount : uint = 0;
			var makeBox : Boolean = false;
			
			var squareAmount : uint = Math.sqrt(amount);
			var i : int = squareAmount;
			while (i--)
			{
				var c : int = squareAmount;
				while (c--)
				{
					if (makeBox)
					{
						var abox : GameObject = new GameObject("abox" + c, Renderer, Rigidbody, RigidbodyInterpolator, BoxCollider);
						abox.boxCollider.material = new PhysicMaterial(0.5, 0.4);
						abox.rigidbody.mass = 1;
						abox.renderer.setBitmapByName("aboxGraph");
						
						abox.boxCollider.dimensions = new Point(20, 20);
						abox.transform.x = Physics.gridOffset.x + (c * 40);
						abox.transform.y = Physics.gridOffset.y + (i * 40);
					}
					else
					{
						var aball : GameObject = new GameObject("aball" + c, Renderer, Rigidbody, RigidbodyInterpolator, CircleCollider);
						aball.renderer.setBitmapByName("aballGraph");
						
						aball.rigidbody.mass = i > squareAmount * 0.3 ? (i > squareAmount * 0.6 ? 0.8 : 0.4) : 0.2;
						aball.circleCollider.radius = 20;
						aball.transform.x = Physics.gridOffset.x + (c * 40);
						aball.transform.y = Physics.gridOffset.y + (i * 40);
					}
				}
			}
		}
	}
}