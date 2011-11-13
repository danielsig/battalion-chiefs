package comp 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import flash.geom.Point;
	
	/**
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
		
		internal var heat : Number = 1000;
		private var _gen : ParticleGenerator;
		private var _emitting : Boolean = true;
		private static var _init : Boolean = true;
		private static var _fireMaterial : PhysicMaterial = new PhysicMaterial(0.0, 0.8);
		
		public function awake() : void
		{
			if (_init)
			{
				_init = false;
				Animation.load("FireAnimation", "assets/img/fire.png~0-80~");
				Animation.addLabel("FireAnimation", "destroyer", 80);
				Animation.load("SmokeAnimation", "assets/img/smoke.png~0-62~");
				Animation.addLabel("SmokeAnimation", "destroyer", 62);
			}
			_gen = requireComponent(ParticleGenerator) as ParticleGenerator;
			_gen.graphicsName = "FireAnimation";
			_gen.isAnimation = true;
			_gen.randomVelocity = new Point(10, 10);
			//_gen.velocity = new Point(0, -50);
			_gen.radius = 23;
			_gen.mass = 0.5;
			_gen.hz = 12;
			_gen.maxParticleCount = uint.MAX_VALUE;
		}
		
		public function emitting(particle : GameObject) : void
		{
			particle.addComponent(FlameParticle);
			particle.flameParticle.source = this;
			particle.circleCollider.material = _fireMaterial;
			particle.addConcise(Destroyer, "destroyer");
			if (heat < 1000) heat += 50;
		}
		public function fixedUpdate() : void
		{
			_gen.emitting = (world.cam.camera as Camera).transformInSight(gameObject.transform, 400, 800) && _emitting;
			if (heat < 300)
			{
				_gen.destroy();
				destroy();
			}
		}
		public function toggleFire() : void
		{
			_emitting = !_emitting;
		}
	}

}