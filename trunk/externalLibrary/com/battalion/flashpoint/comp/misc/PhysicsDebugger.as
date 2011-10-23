package com.battalion.flashpoint.comp.misc 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.Physics;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.powergrid.*;
	import com.battalion.Input;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
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
		
		/** @private */
		public function update() : void
		{
			if (debugSprite)
			{
				_debugGraphics = debugSprite.graphics;
				_debugGraphics.clear();
				if (Input.hold(Keyboard.SPACE))
				{
					debugSprite.scaleX = debugSprite.scaleY = 1 / world.cam.transform.scale;
					debugSprite.x = 400 + (Physics.gridOffset.x - world.cam.transform.x) * debugSprite.scaleX;
					debugSprite.y = 225 + (Physics.gridOffset.y - world.cam.transform.y) * debugSprite.scaleX;
					
					_debugGraphics.beginFill(0x22BB22, 0.3);
					_debugGraphics.lineStyle(0);
					PowerGrid.forEachCircle(drawCircle);
					//PowerGrid.forEachTriangle(drawTriangle);
					//PowerGrid.forEachGroup(drawGroup);
					_debugGraphics.endFill();
					//drawGrid(false);
				}
			}
		}
		/** @private */
		public function drawCircle(circle : Circle, sleeping : Boolean = false) : void
		{
			_debugGraphics.beginFill(sleeping ? 0x666666 : 0x22BB22, 0.3);
			_debugGraphics.drawCircle(circle.x, circle.y, circle.radius);
			/*_debugGraphics.beginFill(0x00FF00);
			for each(var contact : Contact in circle.contacts)
			{
				_debugGraphics.drawCircle(contact.x, contact.y, 4);
			}
			_debugGraphics.beginFill(0x22BB22, 0.3);*/
		}
		/** @private */
		public function drawTriangle(triangle : Triangle, sleeping : Boolean = false) : void
		{
			_debugGraphics.beginFill(sleeping ? 0x666666 : 0x22BB22, 0.3);
			_debugGraphics.moveTo(triangle.gx1 + triangle.x, triangle.gy1 + triangle.y);
			_debugGraphics.lineTo(triangle.gx2 + triangle.x, triangle.gy2 + triangle.y);
			_debugGraphics.lineTo(triangle.gx3 + triangle.x, triangle.gy3 + triangle.y);
			_debugGraphics.lineTo(triangle.gx1 + triangle.x, triangle.gy1 + triangle.y);
			_debugGraphics.beginFill(0x00FF00);
			for each(var contact : Contact in triangle.contacts)
			{
				_debugGraphics.drawCircle(contact.x, contact.y, 4);
			}
			_debugGraphics.beginFill(0x22BB22, 0.3);
		}
		/** @private */
		public function drawGroup(group : Group) : void
		{
			_debugGraphics.drawRect(group.x - 8, group.y - 8, 16, 16);
			var length : int = group.length;
			for (var i : uint = 0; i < length; i++)
			{
				var member : AbstractRigidbody = group.getBodyAt(i);
			}
			_debugGraphics.beginFill(0x00FF00);
			for each(var contact : Contact in group.contacts)
			{
				_debugGraphics.drawCircle(contact.x, contact.y, 4);
			}
			_debugGraphics.beginFill(0x22BB22, 0.3);
		}
		private function drawGrid(onlySleepingBodies : Boolean) : void
		{
			var gridWidth : Number = PowerGrid.gridWidth;
			if (!onlySleepingBodies)
			{
				_debugGraphics.lineStyle(1, 0, 0.3);
				
				var i : int;
				var lineStart : Point = new Point();
				var lineEnd : Point = lineStart.clone();
				lineEnd.y += PowerGrid.gridHeight * PowerGrid.unitSize;
				
				for (i = 0; i < gridWidth; i++)
				{
					_debugGraphics.moveTo(lineStart.x, lineStart.y);
					_debugGraphics.lineTo(lineEnd.x, lineEnd.y);
					lineStart.x += PowerGrid.unitSize;
					lineEnd.x += PowerGrid.unitSize;
				}
				_debugGraphics.moveTo(lineStart.x, lineStart.y);
				_debugGraphics.lineTo(lineEnd.x, lineEnd.y);
				lineEnd = lineStart;
				lineStart = new Point();
				for (i = 0; i <= PowerGrid.gridHeight; i++)
				{
					_debugGraphics.moveTo(lineStart.x, lineStart.y);
					_debugGraphics.lineTo(lineEnd.x, lineEnd.y);
					lineStart.y += PowerGrid.unitSize;
					lineEnd.y += PowerGrid.unitSize;
				}
			}
			for (var y : uint = 0; y < PowerGrid.gridHeight; y++)
			{
				for (var x : uint = 0; x < gridWidth; x++)
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