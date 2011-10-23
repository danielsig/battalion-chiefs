package com.battalion.flashpoint.core 
{
	import com.battalion.powergrid.AbstractRigidbody;
	/**
	 * Assign a PhysicMaterial to Colliders, and see what happens.
	 * The PhysicMaterial is immutable.
	 * @see Collider
	 * @see BoxCollider
	 * @author Battalion Chiefs
	 */
	public final class PhysicMaterial
	{
		
		public static const DEFAULT_MATERIAL : PhysicMaterial = new PhysicMaterial();
		
		/** @private */
		internal var _friction : Number;
		/** @private */
		internal var _bounciness : Number;
		
		public function get friction() : Number { return _friction; }
		public function get bounciness() : Number { return _bounciness; }
		
		public function PhysicMaterial(friction : Number = 0.5, bounciness : Number = 0)
		{
			_friction = friction;
			_bounciness = bounciness;
		}
		
	}

}