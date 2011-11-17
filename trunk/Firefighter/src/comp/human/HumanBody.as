package comp.human 
{
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.comp.BoneAnimation;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class HumanBody 
	{
		
		public static const BODY_HEIGHT : Number = 140;
		public static const HEAD_HEIGHT : Number = 20;
		
		public static const TORSO_HALF_HEIGHT : Number = ((BODY_HEIGHT * 0.5) - HEAD_HEIGHT) * 0.5;
		public static const LEG_HALF_HEIGHT : Number = BODY_HEIGHT * 0.25;
		
		private static var _initializer : Boolean = defineAnimations();
		
		private static function defineAnimations() : Boolean
		{
			//TODO: add animations
			BoneAnimation.define("humanIdle", 2, { torsoY:[ -TORSO_HALF_HEIGHT] } );
			BoneAnimation.define("humanRun", 2, { torsoY:[-TORSO_HALF_HEIGHT], headA:[0], headY:[-TORSO_HALF_HEIGHT]} );
			return true;
		}
		
		public function HumanBody() 
		{
			throw new Error("This is a static class, do not instantiate it");
		}
		
		public static function addBody(gameObject : GameObject,
			torsoBitmapName : String = null, headBitmapName : String = null,
			leftLegBitmapName : String = null, rightLegBitmapName : String = null
		) : void
		{
			//TORSO
			var torso : GameObject = gameObject.torso as GameObject || new GameObject("torso", gameObject, BoneAnimation);
			if (torsoBitmapName) (torso.renderer as Renderer || torso.addComponent(Renderer) as Renderer).setBitmapByName(torsoBitmapName);
			
			//HEAD
			var head : GameObject = torso.head as GameObject || new GameObject("head", torso);
			if (headBitmapName)
			{
				(head.renderer as Renderer || head.addComponent(Renderer) as Renderer).setBitmapByName(headBitmapName);
				head.renderer.offset = new Matrix(1, 0, 0, 1, 0, -HEAD_HEIGHT * 0.5);
			}
			head.transform.y = -TORSO_HALF_HEIGHT;
			
			//LEFT LEG
			var left : GameObject = torso.leftLeg as GameObject || new GameObject("leftLeg", torso);
			if (leftLegBitmapName)
			{
				(left.renderer as Renderer || left.addComponent(Renderer) as Renderer).setBitmapByName(leftLegBitmapName);
				left.renderer.offset = new Matrix(1, 0, 0, 1, 0, LEG_HALF_HEIGHT);
			}
			
			//RIGHT LEG
			var right : GameObject = torso.rightLeg as GameObject || new GameObject("rightLeg", torso);
			if (rightLegBitmapName)
			{
				(right.renderer as Renderer || right.addComponent(Renderer) as Renderer).setBitmapByName(rightLegBitmapName);
				right.renderer.offset = new Matrix(1, 0, 0, 1, 0, LEG_HALF_HEIGHT);
			}
			
			torso.log();
		}
		
	}

}