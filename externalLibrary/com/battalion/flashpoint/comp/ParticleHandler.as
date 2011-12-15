package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.core.IHiddenComponent;
	
	/**
	 * @private
	 * If you're reading this, GO AWAY!!!
	 * @author Battalion Chiefs
	 */
	internal final class ParticleHandler extends Component implements IExclusiveComponent, IHiddenComponent
	{
		internal var _generator : ParticleGenerator;
		internal var _next : ParticleHandler = null;
		internal var _prev : ParticleHandler = null;
		
		public function awake() : void
		{
			setFunctionPointer("fixedUpdate", active);
		}
		
		public var fixedUpdate : Function = active;
		private function active() : void
		{
			if (!_next && _generator._counter > _generator.maxParticleCount)
			{
				if(_prev) _prev._next = null;
				if (_generator.recycle)
				{
					sendMessage("recycleParticle");
				}
				else gameObject.destroy();
			}
		}
		public function recycleParticle() : void
		{
			if (_generator)
			{
				_generator._counter--;
				_generator = null;
				_next = _prev = null;
				setFunctionPointer("fixedUpdate", null);
			}
		}
		public function onDestroy() : Boolean
		{
			_generator._counter--;
			_generator = null;
			_next = _prev = null;
			return false;
		}
	}

}