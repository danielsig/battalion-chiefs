package com.battalion.flashpoint.comp.tools 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.Physics;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.comp.Camera;
	import com.battalion.powergrid.*;
	import com.battalion.Input;
	import com.danielsig.ColorFactory;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * Add this component anywhere to see what's happening in your physics engine.
	 * @author Battalion Chiefs
	 */
	public final class PhysicsDebugger extends Component implements IExclusiveComponent 
	{	
		/**
		 * This is the Sprite object that debug data will be drawn to.
		 */
		public var debugSprite : Sprite;
		
		private var _debugGraphics : Graphics;
		
		private var _maxDensity : Number = 1;
		private var _maxInvDensity : Number;
		
		private var _left : Number;
		private var _right : Number;
		private var _top : Number;
		private var _bottom : Number;
		
		public var alpha : Number = 0.7;
		
		/** @private */
		public function awake() : void
		{
			Input.assignButton("physicsDebug", "<", "~", "\\");;
		}
		
		/** @private */
		public function update() : void
		{
			if (debugSprite)
			{
				var cam : Camera = Camera.mainCamera;
				_left = cam.gameObject.transform.x - cam.width * 0.5 * cam.gameObject.transform.scaleX - Physics.gridOffset.x;
				_right = cam.gameObject.transform.x + cam.width * 0.5 * cam.gameObject.transform.scaleX - Physics.gridOffset.x;
				_top = cam.gameObject.transform.y - cam.height * 0.5 * cam.gameObject.transform.scaleY - Physics.gridOffset.y;
				_bottom = cam.gameObject.transform.y + cam.height * 0.5 * cam.gameObject.transform.scaleY - Physics.gridOffset.y;
				
				_debugGraphics = debugSprite.graphics;
				_debugGraphics.clear();
				if (Input.toggledButton("physicsDebug"))
				{
					drawGrid(false);
					_maxInvDensity = 1 / _maxDensity;
					_maxDensity = 0;
					debugSprite.scaleX = debugSprite.scaleY = 1 / world.cam.transform.scale;
					debugSprite.x = 400 + (Physics.gridOffset.x - world.cam.transform.x) * debugSprite.scaleX;
					debugSprite.y = 225 + (Physics.gridOffset.y - world.cam.transform.y) * debugSprite.scaleX;
					
					_debugGraphics.lineStyle(0);
					PowerGrid.forEachCircle(drawCircle);
					PowerGrid.forEachTriangle(drawTriangle);
					PowerGrid.forEachGroup(drawGroup);
					_debugGraphics.endFill();
				}
			}
		}
		/** @private */
		public function drawCircle(circle : Circle, sleeping : Boolean = false) : void
		{
			if (circle.x + circle.radius > _left && circle.x - circle.radius < _right
			&&  circle.y + circle.radius > _top && circle.y - circle.radius < _bottom)
			{
				var density : Number = circle.mass / circle.volume;
				if (density > _maxDensity) _maxDensity = density;
				if (circle.parent) density = circle.parent.mass / circle.parent.volume;
				
				_debugGraphics.beginFill(sleeping ? 0x666666 : ColorFactory.CreateRGBThermalScale(density * _maxInvDensity), alpha);
				_debugGraphics.drawCircle(circle.x, circle.y, circle.radius);
				_debugGraphics.endFill();
				
				_debugGraphics.lineStyle(3, 0xFF0000, 1);
				_debugGraphics.moveTo(circle.x, circle.y);
				_debugGraphics.lineTo(circle.x + circle.vx * 0.06, circle.y + circle.vy * 0.05);
				
				_debugGraphics.beginFill(ColorFactory.CreateRGBThermalScale(density * _maxInvDensity), alpha);
				_debugGraphics.lineStyle(1, 0x00FFFF);
				for each(var contact : Contact in circle.contacts)
				{
					_debugGraphics.drawCircle(contact.x, contact.y, 1);
					_debugGraphics.moveTo(contact.x, contact.y);
					_debugGraphics.lineTo(contact.x + contact.nx * 10, contact.y + contact.ny * 10);
				}
				_debugGraphics.lineStyle(1, 0, 0);
				_debugGraphics.endFill();
			}
		}
		/** @private */
		public function drawTriangle(triangle : Triangle, sleeping : Boolean = false) : void
		{
			if (triangle.x + triangle.radius > _left && triangle.x - triangle.radius < _right
			&&  triangle.y + triangle.radius > _top && triangle.y - triangle.radius < _bottom)
			{
				var density : Number = triangle.mass / triangle.volume;
				if (density > _maxDensity) _maxDensity = density;
				if (triangle.parent) density = triangle.parent.mass / triangle.parent.volume;
				
				_debugGraphics.lineStyle(3, 0xFF0000, 1);
				_debugGraphics.moveTo(triangle.x, triangle.y);
				_debugGraphics.lineTo(triangle.x + triangle.vx * 0.05, triangle.y + triangle.vy * 0.05);
				
				_debugGraphics.lineStyle(0, 0x000000);
				_debugGraphics.beginFill(sleeping ? 0x666666 : ColorFactory.CreateRGBThermalScale(density * _maxInvDensity), alpha);
				_debugGraphics.moveTo(triangle.gx1 + triangle.x, triangle.gy1 + triangle.y);
				_debugGraphics.lineTo(triangle.gx2 + triangle.x, triangle.gy2 + triangle.y);
				_debugGraphics.lineTo(triangle.gx3 + triangle.x, triangle.gy3 + triangle.y);
				_debugGraphics.lineTo(triangle.gx1 + triangle.x, triangle.gy1 + triangle.y);
				
				_debugGraphics.moveTo(triangle.x + (triangle.gx1 + triangle.gx2) * 0.5					   , triangle.y + (triangle.gy1 + triangle.gy2) * 0.5);
				_debugGraphics.lineStyle(1, 0xFF0000, 1);
				_debugGraphics.lineTo(triangle.x + (triangle.gx1 + triangle.gx2) * 0.5 + triangle.gn12x * 5, triangle.y + (triangle.gy1 + triangle.gy2) * 0.5 + triangle.gn12y * 5);
				_debugGraphics.moveTo(triangle.x + (triangle.gx2 + triangle.gx3) * 0.5					   , triangle.y + (triangle.gy2 + triangle.gy3) * 0.5);
				_debugGraphics.lineStyle(1, 0x00FF00, 1);
				_debugGraphics.lineTo(triangle.x + (triangle.gx2 + triangle.gx3) * 0.5 + triangle.gn23x * 5, triangle.y + (triangle.gy2 + triangle.gy3) * 0.5 + triangle.gn23y * 5);
				_debugGraphics.moveTo(triangle.x + (triangle.gx3 + triangle.gx1) * 0.5					   , triangle.y + (triangle.gy3 + triangle.gy1) * 0.5);
				_debugGraphics.lineStyle(1, 0x0000FF, 1);
				_debugGraphics.lineTo(triangle.x + (triangle.gx3 + triangle.gx1) * 0.5 + triangle.gn31x * 5, triangle.y + (triangle.gy3 + triangle.gy1) * 0.5 + triangle.gn31y * 5);
				
				_debugGraphics.endFill();
				_debugGraphics.lineStyle(1, 0x00FFFF);
				for each(var contact : Contact in triangle.contacts)
				{
					var x : Number = contact.x + (triangle.x - (triangle.parent || triangle).x);
					var y : Number = contact.y + (triangle.y - (triangle.parent || triangle).y);
					_debugGraphics.drawCircle(x, y, 1);
					_debugGraphics.moveTo(x, y);
					_debugGraphics.lineTo(x + contact.nx * 10, y + contact.ny * 10);
				}
				_debugGraphics.lineStyle(1, 0, 0);
			}
		}
		/** @private */
		public function drawGroup(group : Group) : void
		{
			var density : Number = group.mass / group.volume;
 			if (density > _maxDensity) _maxDensity = density;
			
			_debugGraphics.lineStyle(1, 0, 1);
			_debugGraphics.drawRect(group.x - 8, group.y - 8, 16, 16);
			var length : int = group.length;
			for (var i : uint = 0; i < length; i++)
			{
				var member : AbstractRigidbody = group.getBodyAt(i);
			}
			_debugGraphics.lineStyle(3, 0xFF0000, 1);
			_debugGraphics.moveTo(group.x, group.y);
			_debugGraphics.lineTo(group.x + group.vx * 0.05, group.y + group.vy * 0.05);
			_debugGraphics.lineStyle(1, 0, 1);
			
			
			_debugGraphics.beginFill(ColorFactory.CreateRGBThermalScale(density * _maxInvDensity), alpha);
			_debugGraphics.lineStyle(1, 0x00FFFF);
			for each(var contact : Contact in group.contacts)
			{
				_debugGraphics.drawCircle(contact.x, contact.y, 1);
				_debugGraphics.moveTo(contact.x, contact.y);
				_debugGraphics.lineTo(contact.x + contact.nx * 10, contact.y + contact.ny * 10);
			}
			_debugGraphics.lineStyle(1, 0, 0);
			_debugGraphics.endFill();
		}
		private function drawGrid(onlySleepingBodies : Boolean) : void
		{
			var gridLeft : int = _left / PowerGrid.unitSize;
			var gridRight : int = 1 + _right / PowerGrid.unitSize;
			var gridTop : int = _top / PowerGrid.unitSize;
			var gridBottom : int = 1 + _bottom / PowerGrid.unitSize;
			
			if (gridLeft < 0) gridLeft = 0;
			if (gridTop < 0) gridTop = 0;
			if (gridRight > PowerGrid.gridWidth) gridRight = PowerGrid.gridWidth;
			if (gridBottom > PowerGrid.gridHeight) gridBottom = PowerGrid.gridHeight;
			
			var gridWidth : Number = PowerGrid.gridWidth;
			if (!onlySleepingBodies)
			{
				_debugGraphics.lineStyle(1, 0, 0.3);
				
				var i : int;
				var lineStart : Point = new Point(gridLeft * PowerGrid.unitSize, gridTop * PowerGrid.unitSize);
				var lineEnd : Point = new Point(gridLeft * PowerGrid.unitSize, gridBottom * PowerGrid.unitSize);
				
				for (i = gridLeft; i < gridRight; i++)
				{
					_debugGraphics.moveTo(lineStart.x, lineStart.y);
					_debugGraphics.lineTo(lineEnd.x, lineEnd.y);
					lineStart.x += PowerGrid.unitSize;
					lineEnd.x += PowerGrid.unitSize;
				}
				_debugGraphics.moveTo(lineStart.x, lineStart.y);
				_debugGraphics.lineTo(lineEnd.x, lineEnd.y);
				lineEnd = lineStart;
				lineStart = new Point(gridLeft * PowerGrid.unitSize, gridTop * PowerGrid.unitSize);
				for (i = gridTop; i <= gridBottom; i++)
				{
					_debugGraphics.moveTo(lineStart.x, lineStart.y);
					_debugGraphics.lineTo(lineEnd.x, lineEnd.y);
					lineStart.y += PowerGrid.unitSize;
					lineEnd.y += PowerGrid.unitSize;
				}
			}
			for (var y : uint = gridTop; y < gridBottom; y++)
			{
				for (var x : uint = gridLeft; x < gridRight; x++)
				{
					//trace(PowerGrid.getBucket(x, y));
					var node : BodyNode = PowerGrid.getBucket(x, y);
					if (node &&  node.body)
					{
						if (!onlySleepingBodies)
						{
							if (node.next &&  node.next.body)
							{
								_debugGraphics.beginFill(0xFF0000, 0.2);
								_debugGraphics.drawRect(x * PowerGrid.unitSize, y * PowerGrid.unitSize, PowerGrid.unitSize, PowerGrid.unitSize);
							}
							else
							{
								_debugGraphics.beginFill(0x0000FF, 0.2);
								_debugGraphics.drawRect(x * PowerGrid.unitSize, y * PowerGrid.unitSize, PowerGrid.unitSize, PowerGrid.unitSize);
							}
							
							_debugGraphics.moveTo((x + 0.5) * PowerGrid.unitSize, (y + 0.5) * PowerGrid.unitSize)
							_debugGraphics.lineTo(node.body.x, node.body.y);
							_debugGraphics.endFill();
						}
						_debugGraphics.lineStyle(1, 0xFF0000, 0.3);
						
						for (; node; node = node.next)
						{
							if (node.body.isSleeping())
							{
								if (node.body is Triangle) drawTriangle(node.body as Triangle, true);
								else if (node.body is Circle) drawCircle(node.body as Circle, true);
							}
						}
						
						_debugGraphics.lineStyle(1, 0, 0.3);
					}
					if (!onlySleepingBodies)
					{
						var tile : uint = PowerGrid.getTile(x, y);
						if (tile > 0)
						{
							_debugGraphics.beginFill(0x00FF00, 0.2);
							_debugGraphics.drawRect(x * PowerGrid.unitSize, y * PowerGrid.unitSize, PowerGrid.unitSize, PowerGrid.unitSize);
						}
					}
				}
			}
		}
	}

}