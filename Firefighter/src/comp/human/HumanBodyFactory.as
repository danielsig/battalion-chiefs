package comp.human 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class HumanBodyFactory 
	{
		
		private static var _init : Boolean = init();
		
		private static function init() : Boolean
		{
			//FIRE FIGHTER
			Renderer.load("calfs", "assets/img/suit.png~0~");
			Renderer.load("limb", "assets/img/suit.png~1~");
			Renderer.load("helmet", "assets/img/suit.png~2~");
			Renderer.load("gloves", "assets/img/suit.png~3~");
			Renderer.load("torso", "assets/img/suit.png~4~");
			Renderer.load("boot", "assets/img/suit.png~5~");
			Renderer.load("head", "assets/img/suit.png~6~");
			Renderer.load("capsule", "assets/img/suit.png~7~");
			
			Renderer.splitVertical("gloves", "leftGlove", "rightGlove");
			Renderer.splitVertical("calfs", "rightCalf", "leftCalf", 0.6);
			
			Renderer.drawBox("armRight", 16, 36, 0x00FF00);
			Renderer.drawBox("forearmRight", 16, 36, 0x00FFFF);
			Renderer.drawBox("armLeft", 16, 36, 0x008800);
			Renderer.drawBox("forearmLeft", 16, 36, 0x008888);
			
			// CIVILIAN
			Renderer.drawBox("civShoe", 20, 12, 0x222F38);
			Renderer.drawBox("civGlove", 12, 20, 0x222F38);
			Renderer.drawBox("civTorso", 28, 44, 0x222F38);
			Renderer.drawBox("civHead", 20, 26, 0xEECC99);
			
			//pants
			Renderer.load("jeans01", "assets/img/civilians.png~0~");
			Renderer.splitVertical("jeans01", "jeansLower01", "jeansUpper01");
			Renderer.load("jeansBase", "assets/img/civilians.png~1~");
			Renderer.splitVertical("jeansBase", "jeansBaseLeft", "jeansBaseRight");
			Renderer.splitHorizontal("jeansBaseLeft", "jeansBase01", "jeansBase02");
			
			//shoes
			Renderer.load("shoes", "assets/img/civilians.png~2~");
			Renderer.splitVertical("shoes", "maleShoes", "femaleShoes");
			Renderer.splitHorizontal("maleShoes", "maleShoes", "shoes");
			Renderer.splitHorizontal("maleShoes", "maleShoes01", "maleShoes02");
			Renderer.splitHorizontal("shoes", "maleShoes03", "maleShoes04");
			
			//shirts and sweaters
			Renderer.load("blackJacket", "assets/img/civilians.png~3~");
			Renderer.load("sleeve", "assets/img/civilians.png~4~");
			Renderer.splitVertical("sleeve", "upperSleeve", "lowerSleeve");
			
			//faces
			Renderer.load("george", "assets/img/civilians.png~5~");
			Renderer.load("necks", "assets/img/civilians.png~6~");
			Renderer.splitVertical("necks", "necksLeft", "necksRight");
			Renderer.splitHorizontal("necksLeft", "georgeNeck", "neck02");
			Renderer.splitHorizontal("necksRight", "neck03", "neck04");
			
			//hands
			Renderer.load("georgeHands", "assets/img/civilians.png~7~");
			Renderer.splitVertical("georgeHands", "georgeLeftHand", "georgeRightHand");
			
			return true;
		}
		
		public function HumanBodyFactory()
		{
			throw new Error("This is a static class, do not instantiate it");
		}
		
		public static function createFireFighter(gameObject : GameObject) : void
		{
			var body : HumanBody = gameObject.addComponent(HumanBody) as HumanBody;
			body.defineAppearance("torso", "head", "limb", "limb", "leftCalf", "rightCalf", "boot", "boot", "limb", "limb", "limb", "limb", "leftGlove", "rightGlove", 0, 60, 3, 20, 17, -36, 0, 40, 0, 70, 3, 0);
			
			//torso
			gameObject.torso.renderer.offset = new Matrix( -0.45, 0, 0, 0.45, 2, 6);
			gameObject.torso.renderer.putInFrontOf(gameObject.torso.rightLeg.renderer);
			//head
			gameObject.torso.head.renderer.offset = new Matrix( -0.2, 0.03, 0.03, 0.2, 4, -2);
			//legs
			(gameObject.torso.rightLeg.renderer.offset as Matrix).scale(0.43, 0.36);
			(gameObject.torso.leftLeg.renderer.offset as Matrix).scale(0.43, 0.36);
			//calfs
			var m : Matrix = (gameObject.torso.rightLeg.rightCalf.renderer.offset as Matrix);
			m.a = 0.4;
			m.b = -0.02;
			m.c = 0.1;
			m.d = 0.28;
			m = (gameObject.torso.leftLeg.leftCalf.renderer.offset as Matrix);
			m.a = 0.4;
			m.b = -0.01;
			m.c = 0.01;
			m.d = 0.28;
			m.tx -= 3;
			//boots
			(gameObject.torso.rightLeg.rightCalf.rightFoot.renderer.offset as Matrix).scale(0.33, 0.33);
			(gameObject.torso.leftLeg.leftCalf.leftFoot.renderer.offset as Matrix).scale(0.33, 0.33);
			(gameObject.torso.rightLeg.rightCalf.rightFoot.renderer as Renderer).putBehind(gameObject.torso.rightLeg.rightCalf.renderer);
			(gameObject.torso.leftLeg.leftCalf.leftFoot.renderer as Renderer).putBehind(gameObject.torso.leftLeg.leftCalf.renderer);
			//arms
			(gameObject.torso.rightArm.renderer.offset as Matrix).scale(0.37, 0.36);
			(gameObject.torso.leftArm.renderer.offset as Matrix).scale(0.37, 0.36);
			(gameObject.torso.rightArm.rightForearm.renderer.offset as Matrix).scale(0.3, 0.2);
			(gameObject.torso.leftArm.leftForearm.renderer.offset as Matrix).scale(0.37, 0.2);
			//hands
			m = (gameObject.torso.rightArm.rightForearm.rightHand.renderer.offset as Matrix);
			m.a = -0.3;
			m.d = -0.3;
			m.b = 0.05;
			m.c = -0.05;
			m = (gameObject.torso.leftArm.leftForearm.leftHand.renderer.offset as Matrix);
			m.a = -0.3;
			m.d = -0.3;
			m.b = -0.05;
			m.c = 0.05;
			
			(gameObject.torso.rightArm.rightForearm.rightHand.renderer as Renderer).putBehind(gameObject.torso.rightArm.rightForearm.renderer);
			(gameObject.torso.leftArm.leftForearm.leftHand.renderer as Renderer).putBehind(gameObject.torso.leftArm.leftForearm.renderer);
			
			//helmet
			var helmet : GameObject = new GameObject("helmet", gameObject.torso.head, Renderer);
			helmet.renderer.setBitmapByName("helmet");
			(helmet.renderer as Renderer).offset = new Matrix(0.25, -0.2, 0.2, 0.25, -5, -10);
			//capsule
			var capsule : GameObject = new GameObject("capsule", gameObject.torso, Renderer);
			capsule.renderer.setBitmapByName("capsule");
			(capsule.renderer as Renderer).offset = new Matrix(-0.18, 0.22, 0.22, 0.18, -23, 0);
			capsule.renderer.putBehind(gameObject.torso.renderer);
		}
		public static function createCivilian(gameObject : GameObject) : void
		{
			var body : HumanBody = gameObject.addComponent(HumanBody) as HumanBody;
			body.defineAppearance
			(
				"blackJacket", "george",
				"jeansUpper01", "jeansUpper01",
				"jeansLower01", "jeansLower01",
				"maleShoes01", "maleShoes01",
				"upperSleeve", "upperSleeve",
				"lowerSleeve", "lowerSleeve",
				"georgeLeftHand", "georgeRightHand",
				1, 20,
				3, 16,
				20, 0,
				-9, 43,
				-10, 25,
				-2, 0
			);
			
			//torso
			gameObject.torso.renderer.offset = new Matrix(0.43, -0.1, -0.05, 0.38, 0, -3);
			gameObject.torso.renderer.putInFrontOf(gameObject.torso.rightLeg.renderer);
			
			//neck
			var neck : GameObject = new GameObject("neck", gameObject.torso, Renderer);
			neck.renderer.setBitmapByName("georgeNeck");
			(neck.renderer as Renderer).offset = new Matrix(0.39, 0, 0, 0.32, -2, -22);
			neck.renderer.putBehind(gameObject.torso.head.renderer);
			
			//head
			gameObject.torso.head.renderer.offset = new Matrix( 0.2, 0, 0, 0.2, 2, -11);
			
			//legs
			var m : Matrix = (gameObject.torso.rightLeg.renderer.offset as Matrix);
			m.a = 0.52;
			m.b = -0.02;
			m.c = 0.1;
			m.d = 0.36;
			
			m = (gameObject.torso.leftLeg.renderer.offset as Matrix);
			m.a = 0.52;
			m.b = -0.02;
			m.c = 0.1;
			m.d = 0.36;
			
			//calfs
			m = (gameObject.torso.rightLeg.rightCalf.renderer.offset as Matrix);
			m.a = 0.44;
			m.b = -0.02;
			m.c = 0.1;
			m.d = 0.33;
			
			m = (gameObject.torso.leftLeg.leftCalf.renderer.offset as Matrix);
			m.a = 0.44;
			m.b = -0.01;
			m.c = 0.01;
			m.d = 0.33;
			m.tx -= 3;
			
			//shoes
			(gameObject.torso.rightLeg.rightCalf.rightFoot.renderer.offset as Matrix).scale(0.45, 0.45);
			(gameObject.torso.leftLeg.leftCalf.leftFoot.renderer.offset as Matrix).scale(0.45, 0.45);
			(gameObject.torso.rightLeg.rightCalf.rightFoot.renderer as Renderer).putBehind(gameObject.torso.rightLeg.rightCalf.renderer);
			(gameObject.torso.leftLeg.leftCalf.leftFoot.renderer as Renderer).putBehind(gameObject.torso.leftLeg.leftCalf.renderer);
			(gameObject.torso.rightLeg.rightCalf.rightFoot.renderer.offset as Matrix).tx += 2;
			
			//pants base
			var base : GameObject = new GameObject("pantsBase", gameObject.torso, Renderer);
			base.renderer.setBitmapByName("jeansBase01");
			(base.renderer as Renderer).offset = new Matrix(0.38, 0, 0.1, 0.4, 0, 20);
			base.renderer.putBehind(gameObject.torso.rightLeg.renderer);
			
			//arms
			(gameObject.torso.rightArm.renderer.offset as Matrix).scale(0.3, 0.33);
			(gameObject.torso.leftArm.renderer.offset as Matrix).scale(0.3, 0.33);
			(gameObject.torso.rightArm.rightForearm.renderer.offset as Matrix).scale(0.3, 0.3);
			(gameObject.torso.leftArm.leftForearm.renderer.offset as Matrix).scale(0.3, 0.3);
			
			//hands
			m = (gameObject.torso.rightArm.rightForearm.rightHand.renderer.offset as Matrix);
			m.a = 0.15;
			m.d = 0.15;
			m.b = -0.03;
			m.c = 0.03;
			m = (gameObject.torso.leftArm.leftForearm.leftHand.renderer.offset as Matrix);
			m.a = 0.17;
			m.d = 0.17;
			m.b = 0.03;
			m.c = -0.03;
			m.tx -= 2;
			gameObject.torso.rightArm.rightForearm.rightHand.renderer.putBehind(gameObject.torso.rightArm.rightForearm.renderer);
			gameObject.torso.leftArm.leftForearm.leftHand.renderer.putBehind(gameObject.torso.leftArm.leftForearm.renderer);
		}
	}

}