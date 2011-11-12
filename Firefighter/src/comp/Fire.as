package comp 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class Fire extends Component implements IExclusiveComponent 
	{
		
		public static function createFire(x : Number = 0, y : Number = 0) : GameObject
		{
			var fire : GameObject = new GameObject("fire", Fire, ParticleGenerator);
			fire.transform.x = x;
			fire.transform.y = y;
			return fire;
		}
		
		private var _gen : ParticleGenerator;
		private static var _init : Boolean = true;
		
		public function awake() : void
		{
			if (_init)
			{
				_init = false;
				Animation.load("FireAnimation", "assets/img/fire.png~0-80~");
				Animation.addLabel("FireAnimation", "destroyer", 80);
			}
			_gen = requireComponent(ParticleGenerator) as ParticleGenerator;
			_gen.graphicsName = "FireAnimation";
			_gen.isAnimation = true;
			_gen.randomVelocity = new Point(1, 1);
			//_gen.velocity = new Point(0, -50);
			_gen.radius = 20;
			_gen.mass = 10;
			_gen.hz = 24;
			_gen.maxParticleCount = uint.MAX_VALUE;
		}
		public function emitting(particle : GameObject) : void
		{
			particle.addComponent(FlameParticle);
			particle.addConcise(Destroyer, "destroyer");
		}
		
	}

}