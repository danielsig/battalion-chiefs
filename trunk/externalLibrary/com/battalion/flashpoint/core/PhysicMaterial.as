package com.battalion.flashpoint.core 
{
	/**
	 * Assign a PhysicMaterial to Colliders, and see what happens.
	 * @see Collider
	 * @see BoxCollider
	 * @author Battalion Chiefs
	 */
	public final class PhysicMaterial 
	{
		
		public var friction : Number;
		public var bounciness : Number;
		public var density : Number;
		
		public function PhysicMaterial(friction : Number = 0.5, bounciness : Number = 0, density : Number = NaN)
		{
			this.friction = friction;
			this.bounciness = bounciness;
			this.density = density;
		}
		
	}

}