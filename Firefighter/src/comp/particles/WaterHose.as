package comp.particles 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import flash.geom.Point;
	
	/**
	 * @author Battalion Chiefs
	 */
	public final class WaterHose extends Component implements IExclusiveComponent 
	{
		
		public static function createWaterHose(x : Number = 0, y : Number = 0, parent : GameObject = null) : GameObject
		{
			var hose : GameObject = new GameObject("waterHose", parent, WaterHose, ParticleGenerator);
			hose.transform.x = x;
			hose.transform.y = y;
			return hose;
		}
		
		public var thrust : Number = 200;
		
		private var _gen : ParticleGenerator;
		private var _tr : Transform;
		private var _prev : Renderer;
		private static var _init : Boolean = true;
		
		public function awake() : void
		{
			_tr = gameObject.transform;
			if (_init)
			{
				_init = false;
				Animation.load("WaterAnimation", "assets/img/water.png~0-71~");
				Animation.addLabel("WaterAnimation", "destroyer", 71);
			}
			_gen = requireComponent(ParticleGenerator) as ParticleGenerator;
			_gen.graphicsName = "WaterAnimation";
			_gen.isAnimation = true;
			_gen.radius = 8;
			_gen.mass = 20;
			_gen.hz = 48;
			_gen.maxParticleCount = uint.MAX_VALUE;
		}
		
		public function emitting(particle : GameObject) : void
		{
			particle.addComponent(WaterParticle);
			particle.addConcise(Destroyer, "destroyer");
			var renderer : Renderer = particle.renderer as Renderer;
			if (_prev)
			{
				renderer.putBehind(_prev);
			}
			_prev = renderer;
		}
		public function fixedUpdate() : void
		{
			var dir : Point = _tr.forward;
			dir.x *= thrust;
			dir.y *= thrust;
			_gen.velocity = dir;
			_prev = null;
		}
		
	}

}