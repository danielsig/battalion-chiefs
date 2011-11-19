package comp.human 
{
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.comp.BoneAnimation;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
		
		public static var legOffsetX : Number = 0;
		public static var calfOffsetX : Number = 0;
		public static var footOffsetX : Number = 0;
		
		public static var legOffsetY : Number = 0;
		public static var calfOffsetY : Number = 0;
		public static var footOffsetY : Number = 0;
		
		private static var _initializer : Boolean = defineAnimations();
		
		private static function defineAnimations() : Boolean
		{			
			var t : Number = -TORSO_HALF_HEIGHT;
			var c : Number = LEG_HALF_HEIGHT;
			var h : Number = 15;
			
			BoneAnimation.define("humanIdle", 2,
				{
					torsoY:[ -TORSO_HALF_HEIGHT],
					torsoA:[ 0],
					
					leftLegA:[ 20],
					rightLegA:[ -20],
					leftLegY:[h],
					rightLegY:[h],
					
					leftCalfA: [0],
					rightCalfA:[10],
					leftCalfY:[c],
					rightCalfY:[c],
					
					leftFootA:[-20],
					rightFootA:[ 10],
					leftFootY:[c],
					rightFootY:[c]
				}
			);
			
			var ta : Number = 8;
			var leg1 : Number = -26;
			var leg2 : Number = -55;
			var leg3 : Number = -20;
			var leg4 : Number = 26;
			var leg5 : Number = 33;
			var leg6 : Number = 7;
			
			var c1 : Number = 70;
			var c2 : Number = 10;
			var c3 : Number = -6;
			var c4 : Number = -3;
			var c5 : Number = 45;
			var c6 : Number = 66;
			
			var f1 : Number = -20;
			var f2 : Number = -20;
			var f3 : Number = 10;
			var f4 : Number = -20;
			var f5 : Number = 40;
			var f6 : Number = 10;
			
			BoneAnimation.define("humanWalk", 10,
				{
					torsoY:[ t, t, t, t, t, t, t],
					torsoA:[ ta, ta, ta, ta, ta, ta, ta],
					headY:[ t, t, t, t, t, t, t],
					headA:[0, 0, 0, 0, 0, 0, 0],
					
					leftLegA:[ leg1, leg2, leg3, leg4, leg5, leg6, leg1],
					rightLegA:[ leg4, leg5, leg6, leg1, leg2, leg3, leg4],
					leftLegY:[h, h, h, h, h, h, h],
					rightLegY:[h, h, h, h, h, h, h],
					
					leftCalfA: [ c1, c2, c3, c4, c5, c6, c1],
					rightCalfA:[ c4, c5, c6, c1, c2, c3, c4],
					leftCalfY:[c, c, c, c, c, c, c],
					rightCalfY:[c, c, c, c, c, c, c],
					
					leftFootA: [ f1, f2, f3, f4, f5, f6, f1],
					rightFootA:[ f4, f5, f6, f1, f2, f3, f4],
					leftFootY:[c, c, c, c, c, c, c],
					rightFootY:[c, c, c, c, c, c, c]
				}
			);
			
			ta = 16;
			leg1 = -40;
			leg2 = -90;
			leg3 = -30;
			leg4 = 40;
			leg5 = 50;
			leg6 = 10;
			c1 = 110;
			c2 = 70;
			c3 = -8;
			c4 = -4;
			c5 = 75;
			c6 = 100;
			
			f1 = 40;
			f2 = -20;
			f3 = 10;
			f4 = -20;
			f5 = 40;
			f6 = 10;
			
			BoneAnimation.define("humanRun", 16,
				{
					torsoY:[ t, t, t, t, t, t, t],
					torsoA:[ ta, ta, ta, ta, ta, ta, ta],
					headY:[ t, t, t, t, t, t, t],
					headA:[0, 0, 0, 0, 0, 0, 0],
					
					leftLegA:[ leg1, leg2, leg3, leg4, leg5, leg6, leg1],
					rightLegA:[ leg4, leg5, leg6, leg1, leg2, leg3, leg4],
					leftLegY:[h, h, h, h, h, h, h],
					rightLegY:[h, h, h, h, h, h, h],
					
					leftCalfA: [ c1, c2, c3, c4, c5, c6, c1],
					rightCalfA:[ c4, c5, c6, c1, c2, c3, c4],
					leftCalfY:[c, c, c, c, c, c, c],
					rightCalfY:[c, c, c, c, c, c, c],
					
					leftFootA: [ f1, f2, f3, f4, f5, f6, f1],
					rightFootA:[ f4, f5, f6, f1, f2, f3, f4],
					leftFootY:[c, c, c, c, c, c, c],
					rightFootY:[c, c, c, c, c, c, c]
				}
			);
			
			ta = 10;
			
			BoneAnimation.define("humanJump", 8,
				{
					torsoY:[ t, t],
					torsoA:[ 0, ta],
					headY:[ t, t],
					headA:[0, 0,],
					
					leftLegA:[ -20, -60-ta],
					rightLegA:[ 20, 10-ta],
					leftLegY:[h, h],
					rightLegY:[h, h],
					
					leftCalfA: [ 10, 100],
					rightCalfA:[ 0, 20],
					leftCalfY:[c, c],
					rightCalfY:[c, c]
				}
			);
			ta = 20;
			BoneAnimation.define("humanLeap", 8,
				{
					torsoY:[ t, t],
					torsoA:[ 0, ta],
					headY:[ t, t],
					headA:[0, 0,],
					
					leftLegA:[ -20, 60-ta],
					rightLegA:[ 20, -90-ta],
					leftLegY:[h, h],
					rightLegY:[h, h],
					
					leftCalfA: [ 10, 60],
					rightCalfA:[ 0, 50],
					leftCalfY:[c, c],
					rightCalfY:[c, c]
				}
			);
			return true;
		}
		
		public function HumanBody() 
		{
			throw new Error("This is a static class, do not instantiate it");
		}
		
		public static function addBody(gameObject : GameObject,
			torsoBitmapName : String = null, headBitmapName : String = null,
			leftLegBitmapName : String = null, rightLegBitmapName : String = null,
			leftCalfBitmapName : String = null, rightCalfBitmapName : String = null,
			leftFootBitmapName : String = null, rightFootBitmapName : String = null
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
				left.renderer.offset = new Matrix(1, 0, 0, 1, legOffsetX, legOffsetY);
			}
			
			//RIGHT LEG
			var right : GameObject = torso.rightLeg as GameObject || new GameObject("rightLeg", torso);
			if (rightLegBitmapName)
			{
				(right.renderer as Renderer || right.addComponent(Renderer) as Renderer).setBitmapByName(rightLegBitmapName);
				right.renderer.offset = new Matrix(1, 0, 0, 1, legOffsetX, legOffsetY);
			}
			
			//LEFT CALF
			left = left.leftCalf as GameObject || new GameObject("leftCalf", left);
			if (leftCalfBitmapName)
			{
				(left.renderer as Renderer || left.addComponent(Renderer) as Renderer).setBitmapByName(leftCalfBitmapName);
				left.renderer.offset = new Matrix(1, 0, 0, 1, calfOffsetX, calfOffsetY);
			}
			left.transform.y = LEG_HALF_HEIGHT;
			
			//RIGHT CALF
			right = right.rightCalf as GameObject || new GameObject("rightCalf", right);
			if (rightCalfBitmapName)
			{
				(right.renderer as Renderer || right.addComponent(Renderer) as Renderer).setBitmapByName(rightCalfBitmapName);
				right.renderer.offset = new Matrix(1, 0, 0, 1, calfOffsetX, calfOffsetY);
			}
			right.transform.y = LEG_HALF_HEIGHT;
			
			//LEFT FOOT
			left = left.leftFoot as GameObject || new GameObject("leftFoot", left);
			if (leftFootBitmapName)
			{
				(left.renderer as Renderer || left.addComponent(Renderer) as Renderer).setBitmapByName(leftFootBitmapName);
				if(left.parent.renderer) left.renderer.putInFrontOf(left.parent.renderer);
				left.renderer.offset = new Matrix(1, 0, 0, 1, footOffsetX, footOffsetY);
			}
			left.transform.y = LEG_HALF_HEIGHT;
			
			//RIGHT FOOT
			right = right.rightFoot as GameObject || new GameObject("rightFoot", right);
			if (rightFootBitmapName)
			{
				(right.renderer as Renderer || right.addComponent(Renderer) as Renderer).setBitmapByName(rightFootBitmapName);
				if(right.parent.renderer) right.renderer.putInFrontOf(right.parent.renderer);
				right.renderer.offset = new Matrix(1, 0, 0, 1, footOffsetX, footOffsetY);
			}
			right.transform.y = LEG_HALF_HEIGHT;
		}
		
	}

}