package comp
{
	import com.battalion.flashpoint.core.*;
	import com.danielsig.MP3Player;
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
				-15, -20,
				15, -20,
				15, 20,
				-15, 20
			);
			
			var samusObj : GameObject = new GameObject("samus", Renderer, Animation, Audio, DummyController);
			Audio.load("samusSound", "assets/sound/samus.mp3~00-2000~");
			Animation.addLabel("samusRunning", "Audio_play", 0, "samusSound", 1);
			Animation.addLabel("samusRunning", "Audio_play", 5, "samusSound", 1);
			
			var head : GameObject = new GameObject("test", samusObj, Renderer, LookAtMouse);
			head.renderer.setBitmapByName("box");
			head.transform.y = -15;
			head.renderer.offset = new Matrix(1, 0, 0, 1, 7.5, 0);
			head.renderer.putInFrontOf(samusObj.renderer);
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