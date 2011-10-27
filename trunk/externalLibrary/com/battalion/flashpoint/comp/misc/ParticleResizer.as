package com.battalion.flashpoint.comp.misc 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.IConciseComponent;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	
	/**
	 * Use this to resize particles made by the particle emitter
	 * @author Battalion Chiefs
	 */
	public final class ParticleResizer extends Component implements IExclusiveComponent 
	{
		public var scale : Number = 1;
		
		/** @private **/
		public function emitting(particle : GameObject) : void
		{
			particle.transform.scale = scale;
		}
		
	}

}