package comp.particles 
{
	import com.battalion.flashpoint.comp.TextRenderer;
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.danielsig.ColorFactory;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Heat extends Component implements IExclusiveComponent 
	{
		public static var debug : Boolean = true;
		
		public static const HEAT_DECREASE_PER_MILLI_SECOND : Number = 0.01;

		public static const WOOD : uint = 1;
		public static const FABRIC : uint = 2;
		public static const PLASTIC : uint = 3;
		
		private static const WOOD_FLASH_POINT : Number = 300;
		private static const FABRIC_FLASH_POINT : Number = 250;
		private static const PLASTIC_FLASH_POINT : Number = 400;
		
		private static const WOOD_FIRE_POINT : Number = 1000;
		private static const FABRIC_FIRE_POINT : Number = 1300;
		private static const PLASTIC_FIRE_POINT : Number = 600;
		
		private static const WOOD_COMBUSTION_RATE : Number = 12;
		private static const FABRIC_COMBUSTION_RATE : Number = 16;
		private static const PLASTIC_COMBUSTION_RATE : Number = 8;
		
		public function get materialType() : uint
		{
			return _material;
		}
		public function set materialType(value : uint) : void
		{
			_material = value;
			switch(value)
			{
				case FABRIC:
					flashPoint = FABRIC_FLASH_POINT;
					firePoint = FABRIC_FIRE_POINT;
					combustionRate = FABRIC_COMBUSTION_RATE;
					break;
				case PLASTIC:
					flashPoint = PLASTIC_FLASH_POINT;
					firePoint = PLASTIC_FIRE_POINT;
					combustionRate = PLASTIC_COMBUSTION_RATE;
					break;
				case WOOD:
				default:
					flashPoint = WOOD_FLASH_POINT;
					firePoint = WOOD_FIRE_POINT;
					combustionRate = WOOD_COMBUSTION_RATE;
					break;
			}
		}
		
		private var _material : uint = WOOD;
		
		internal var flashPoint : uint = WOOD_FLASH_POINT;
		internal var firePoint : uint = WOOD_FIRE_POINT;
		internal var combustionRate : uint = WOOD_COMBUSTION_RATE;
		
		public var heat : Number = 0;
		public var time : Number = new Date().time;
		
		public function ignite() : void
		{
			if (!gameObject.fire) Fire.createFire(0, 0, gameObject);
		}
		public function addHeat(amount : Number) : void
		{
			if (amount < 0 || heat < flashPoint)
			{
				if (heat < flashPoint)
				{
					var now : Number = new Date().time;
					heat -= (now - time) * HEAT_DECREASE_PER_MILLI_SECOND;
					time = now;
				}
				
				if (heat < 0) heat = amount;
				else heat += amount;
				
				if (heat >= flashPoint)
				{
					ignite();
				}
				else if (gameObject.fire is Fire)
				{
					gameObject.fire.destroy();
				}
				else if (heat < 0)
				{
					heat = 0;
				}
			}
		}
		CONFIG::debug
		public function fixedUpdate() : void
		{
			if (debug)
			{
				var now : Number = new Date().time;
				var currentHeat : Number = heat > flashPoint ? heat : heat - (now - time) * HEAT_DECREASE_PER_MILLI_SECOND;
				if (currentHeat < 0) currentHeat = 0;
				
				var textRenderer : TextRenderer = (gameObject.textRenderer || addComponent(TextRenderer)) as TextRenderer;
				if (!textRenderer.offset) textRenderer.setOffset(0, -80);
				textRenderer.font = "Arial";
				textRenderer.text = int(currentHeat) + "";
				textRenderer.color = ColorFactory.CreateRGBThermalScale(currentHeat < flashPoint ? currentHeat / flashPoint : (currentHeat - flashPoint) / firePoint);
			}
		}
	}

}