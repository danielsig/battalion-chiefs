package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	
	/**
	 * @private
	 * If you're reading this, GO AWAY!!!
	 * @author Battalion Chiefs
	 */
	internal final class ParticleHandler extends Component implements IExclusiveComponent 
	{
		internal var _generator : ParticleGenerator;
		internal var _next : ParticleHandler = null;
		internal var _prev : ParticleHandler = null;
		
		public function fixedUpdate() : void
		{
			if (!_next && _generator._counter > _generator.maxParticleCount)
			{
				if(_prev) _prev._next = null;
				_generator._counter--;
				gameObject.destroy();
			}
			else if (_generator._counter == Infinity)
			{
				_prev._next = null;
				destroy();
			}
		}
	}

}