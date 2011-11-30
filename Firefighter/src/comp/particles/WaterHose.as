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
		private static var _init : Boolean = init();
		
		private static function init() : Boolean
		{
			Audio.load("hose", "assets/sound/sounds.mp3~150-750~");
			Animation.load("WaterAnimation", "assets/img/water.png~0-71~");
			Animation.addLabel("WaterAnimation", "destroyer", 71);
			Animation.load("SteamAnimation", "assets/img/steam.png~0-62~");
			Animation.addLabel("SteamAnimation", "destroyer", 62);
			return true;
		}
		public static function createWaterHose(x : Number = 0, y : Number = 0, parent : GameObject = null) : GameObject
		{
			var hose : GameObject = new GameObject("waterHose", parent, WaterHose, ParticleGenerator);
			hose.transform.x = x;
			hose.transform.y = y;
			return hose;
		}
		
		public var thrust : Number = 500;
		
		private var _gen : ParticleGenerator;
		private var _tr : Transform;
		private var _prev : Renderer;
		
		private var _emitting : Boolean = false;
		
		public function awake() : void
		{
			(requireComponent(Audio) as Audio).volume = 0.1;
			_tr = gameObject.transform;
			_gen = requireComponent(ParticleGenerator) as ParticleGenerator;
			_gen.graphicsName = "WaterAnimation";
			_gen.isAnimation = true;
			_gen.radius = 8;
			_gen.mass = 5;
			_gen.hz = 100;
			_gen.maxParticleCount = uint.MAX_VALUE;
		}
		
		public function onEmit(particle : GameObject) : void
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
			
			if (!_emitting && _gen.emitting)
			{
				gameObject.audio.play("hose");
				_emitting = true;
			}
			else if (_emitting && !_gen.emitting)
			{
				gameObject.audio.stop();
				_emitting = false;
			}
		}
		
	}

}