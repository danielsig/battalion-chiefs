package comp
{
	import com.battalion.flashpoint.core.*;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.display.PixelSnapping;
	import com.greensock.TweenMax;
	import factory.BoxFactory;
	import com.greensock.easing.Strong;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class GameCore extends Component implements IExclusiveComponent
	{
		
		public function start() : void 
		{
			Physics.grid = new BitmapData(25, 18, true, 0);
			Physics.unitSize = 64;
			Physics.maxSize = 100;
			Physics.gravityVector = new Point(0, 0.3);
			Physics.gridOffset = new Point( -800, -800);
			Physics.iterations = 2;
			Physics.init();
			
			world.cam.transform.scale = 5;
			
			/*
			addConcise(ExampleConcise, "sayHello");
			sendMessage("sayHello");//will be recieved, but the concise component will destroy itself afterwards.
			sendMessage("sayHello");//will NOT be recieved, because concise component has already destroyed itself.
			
			addComponent(ExampleComponent);
			sendMessage("sayThis", "YAHOO!");
			sendMessage("sayThis", "YAHOO!");//normal components do not destroy themselves like concise components.
			gameObject.exampleComponent.destroy();
			sendMessage("sayThis", "YAHOO!");//no reciever, ExampleComponent has been destroyed.
			
			addComponent(TutorialComponent);
			*/
			//var box2 : GameObject = BoxFactory.create( { x:400, y:100, name:"box2", url:"assets/img/test.png" } );
			//var box3 : GameObject = BoxFactory.create( { x:600, y:100, name:"box3", url:"assets/img/test.png" } );
			//var box1 : GameObject = BoxFactory.create( { x:450, y:100, name:"box1", url:["assets/img/samus.png~0-9~"] } );
			//var box4 : GameObject = BoxFactory.create( { x:100, y:100, name:"box4", url:["assets/img/samus.png~9-0~"] } );
			//box4.transform.scaleX = -(box4.transform.scaleY = box1.transform.scale = 8);
			//box4.animation.reverse();
			//box1.transform.rotation = 90;
			/*
			world.box1.transform.log();
			world.box2.transform.log();
			world.box3.transform.log();
			
			TweenMax.to(box1.transform, 2, { scaleX:1, rotation:-90 } );
			TweenMax.to(box2.transform, 2, { scaleX:2 } );
			TweenMax.to(box3.transform, 2, { scaleX:2, rotation: -90, onComplete:complete } );
			*/
			/*var loader : MP3Loader = new MP3Loader("http://www.emotionreports.com/music/2001-_A_Space_Odyssey_-_Also_sprach_zarathustra.mp3");
			loader.load();
			*/
			/*
			for (var i : int = 0; i < 60; i++)
			{
				for (var j : int = 0; j < 34; j++)
				{
					var samus : GameObject = BoxFactory.create( { x:i * 50, y:j * 50, name:"samus" + i + "_" +  j, url:["assets/img/samus.png~0-9~"] } );
					samus.animation.gotoAndPlay(int(Math.random() * 9));
				}
			}
			*/
			//world.cam.transform.x = 1500;
			//world.cam.transform.y = 875.5;
			//world.cam.transform.scale = 0.005;
			//TweenMax.to(world.cam.transform, 95.6, { x:1480, y:830, delay:5, scale:3.8, ease:Strong.easeIn } );
			
			Renderer.draw("box",
				"fill", { color:"0x555555" },
				-7, -10,
				7, -10,
				7, 10,
				-7, 10
			);
			
			var samusObj : GameObject = new GameObject("samus", Renderer, Animation, Audio, DummyController, BoxCollider, Rigidbody);
			Audio.load("samusSound", "assets/sound/samus.mp3~100-2000~");
			Animation.load("samusRunning", "assets/img/samus.png~0-9~");
			//Animation.filterWhite("samusRunning");
			samusObj.animation.play("samusRunning");
			Animation.addLabel("samusRunning", "Audio_gotoAndPlay", 0, 0, "samusSound");
			//Animation.addLabel("samusRunning", "Audio_reverse", 0);
			Animation.addLabel("samusRunning", "Audio_gotoAndPlay", 5, 0, "samusSound");
			//Animation.addLabel("samusRunning", "Audio_reverse", 5);
			//samusObj.audio.reverse();
			samusObj.boxCollider.dimensions = new Point(22, 44);
			samusObj.rigidbody.mass = 5000;
			samusObj.rigidbody.freezeRotation = true;
			samusObj.boxCollider.material = new PhysicMaterial(1, 0);
			//samusObj.circleCollider.radius = 20;
			samusObj.transform.y = -100;
			
			
			var head : GameObject = new GameObject("test", samusObj, Renderer, LookAtMouse);
			head.renderer.setBitmapByName("box");
			head.transform.y = -14;
			head.renderer.offset = new Matrix(1, 0, 0, 1, 1, -7);
			head.renderer.putInFrontOf(samusObj.renderer);
			/*
			var floor : GameObject = new GameObject("floor", Renderer, BoxCollider);
			Renderer.draw("floorGraphics",
			"fill", { color:"0x555555" },
				-700, -100,
				700, -100,
				700, 100,
				-700, 100
			);
			floor.renderer.offset = new Matrix(1, 0, 0, 1, 0, 0);
			floor.renderer.setBitmapByName("floorGraphics");
			floor.transform.y = 250;
			floor.boxCollider.width = 1400;
			floor.boxCollider.height = 200;
			floor.boxCollider.material = new PhysicMaterial(1, 0);*/
			/*
			samusObj.boxCollider.material = new PhysicMaterial(1, 0, 1);
			samusObj.rigidbody.drag = 0.0;
			samusObj.rigidbody.mass = 1;
			samusObj.rigidbody.freezeRotation = true;*/
			//samusObj.rigidbody.interpolate = false;
			
			
			
			//door - bara test
			
			Renderer.draw("doorGraphics",
			"fill", { color:"0x885555" },
				-15, -30,
				15, -30,
				15, 30,
				-15, 30
			);
			
			var door : GameObject = new GameObject("door", Renderer, PortalStatusNotifier);
			door.transform.x = 400;
			door.transform.y = 20;
			door.renderer.setBitmapByName("doorGraphics");
			//door.renderer.putInFrontOf(floor.renderer);
			
			
			
			var door2 : GameObject = new GameObject("door2", Renderer, PortalStatusNotifier);
			door2.transform.x = 200;
			door2.transform.y = 20;
			door2.renderer.setBitmapByName("doorGraphics");
			//door2.renderer.putInFrontOf(floor.renderer);
			
			Portal.addPortal(door, door2, 40, 60, samusObj.transform, true, 100);
			
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
			Renderer.draw("aYellowBallGraph",
			"fill", { color:"0xFFAA00" },
			"circle", {radius:30}
			);
			Renderer.draw("anOrangeBallGraph",
			"fill", { color:"0xFF7700" },
			"circle", {radius:30}
			);
			
			var amount : uint = 300;
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
						abox.transform.x = (c * 25) - 300;
						abox.transform.y = -(i * 25);
					}
					else
					{
						var aball : GameObject = new GameObject("aball" + c, Renderer, Rigidbody, RigidbodyInterpolator, CircleCollider);
						aball.renderer.setBitmapByName(i > squareAmount * 0.3 ? (i > squareAmount * 0.6 ? "aballGraph" : "anOrangeBallGraph") : "aYellowBallGraph");
						
						aball.rigidbody.mass = i > squareAmount * 0.3 ? (i > squareAmount * 0.6 ? 16 : 4) : 1;
						aball.circleCollider.layers = 2;
						aball.circleCollider.radius = 20;
						aball.transform.x = (c * 25) - 300;
						aball.transform.y = -(i * 25);
					}
				}
			}
			
			BoneAnimation.define("foo", 5, { bone1A:[0, -90, 180, 90, 0], bone1X:[ -100, -100, -100, -100, -100], bonesA:[0, 90, 180, -90, 0], bone1Y:[ 100, 100, 100, 100, 100]});
			
			var myBones : GameObject = new GameObject("bones", BoneAnimation, Renderer);
			var bone1 : GameObject = new GameObject("bone1", myBones, Renderer);
			myBones.renderer.setBitmapByName("doorGraphics");
			//bone1.renderer.setBitmapByName("doorGraphics");
			myBones.boneAnimation.play("foo");
			myBones.boneAnimation.localTimeScale = 1;
			myBones.transform.x += 50;
			
			var collider : GameObject = new GameObject("collider", Stalker, BoxCollider, Renderer);
			collider.boxCollider.dimensions = new Point(30, 60);
			collider.boxCollider.material = new PhysicMaterial(1, 0);
			collider.stalker.target = bone1.transform;
			collider.renderer.setBitmapByName("doorGraphics");
			collider.boxCollider.layers = 3;
			
			//collider.boxCollider.destroy();
			//samusObj.boxCollider.destroy();
		}
		public function complete() : void
		{
			/*
			world.box1.transform.log();
			world.box2.transform.log();
			world.box3.transform.log();
			*/
		}
		
	}
}