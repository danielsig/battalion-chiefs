package com.battalion.flashpoint.comp.tools 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	
	/**
	 * 
	 * @author Battalion Chiefs
	 */
	public final class GeomCodePrimitives extends Component implements IExclusiveComponent 
	{
		
		/** @private **/
		public function awake() : void
		{
			requireComponent(GeomCodeRuntime);
		}
		//{::::::::::::::::::::::::: BOX ::::::::::::::::::::::::::
		public function geomBox(box : GameObject, params : Object) : void
		{
			box.width = params.width || 0;
			box.height = params.height || 0;
			box.layers = uint(params.layers || uint.MAX_VALUE);
			box.color = params.color;
			box.outline = params.outline;
		}
		public function geomBoxComplete(box : GameObject) : void
		{
			if (box.color || box.outline)
			{
				var name : String = "box" + box.color.toString(32) + box.outline.toString(32) + box.width.toString(32) + box.height.toString(32);
				if (!Renderer.getBitmap(name))
				{
					if (box.color && !box.outline)
					{
						Renderer.draw(name, "fill", { color:"0x" + box.color.toString(16) },
						-box.width * 0.5, -box.height * 0.5,
						box.width * 0.5, -box.height * 0.5,
						box.width * 0.5, box.height * 0.5,
						-box.width * 0.5, box.height * 0.5);
					}
					else if (!box.color && box.outline)
					{
						Renderer.draw(name, "line", { thickness:1, color:"0x" + box.outline.toString(16) },
						-box.width * 0.5, -box.height * 0.5,
						box.width * 0.5, -box.height * 0.5,
						box.width * 0.5, box.height * 0.5,
						-box.width * 0.5, box.height * 0.5,
						-box.width * 0.5, -box.height * 0.5);
					}
					else
					{
						Renderer.draw(name,
						"line", { thickness:1, color:"0x" + box.outline.toString(16) },
						"fill", { color:"0x" + box.color.toString(16) },
						-box.width * 0.5, -box.height * 0.5,
						box.width * 0.5, -box.height * 0.5,
						box.width * 0.5, box.height * 0.5,
						-box.width * 0.5, box.height * 0.5,
						-box.width * 0.5, -box.height * 0.5);
					}
				}
				box.addComponent(Renderer);
				box.renderer.setBitmapByName(name);
			}
			if (box.width && box.height)
			{
				var col : BoxCollider = box.addComponent(BoxCollider) as BoxCollider;
				col.width = box.width;
				col.height = box.height;
				col.layers = box.layers;
			}
			delete box.width;
			delete box.height;
			delete box.layers;
			delete box.color;
			delete box.outline;
		}
		//}
		
		//{:::::::::::::::::::::::: CIRCLE ::::::::::::::::::::::::
		public function geomCircle(circle : GameObject, params : Object) : void
		{
			circle.radius = params.radius || 0;
			circle.layers = uint(params.layers || uint.MAX_VALUE);
			circle.color = params.color;
			circle.outline = params.outline;
		}
		public function geomCircleComplete(circle : GameObject) : void
		{
			if (circle.color || circle.outline)
			{
				var name : String = "circle" + circle.color.toString(32) + circle.outline.toString(32) + circle.radius.toString(32);
				if (!Renderer.getBitmap(name))
				{
					if (circle.color && !circle.outline)
					{
						Renderer.draw(name, "fill", { color:"0x" + circle.color.toString(16) },
						"circle", { x:0, y:0, radius:circle.radius})
					}
					else if (!circle.color && circle.outline)
					{
						Renderer.draw(name, "line", { thickness:1, color:"0x" + circle.outline.toString(16) },
						"circle", { x:0, y:0, radius:circle.radius})
					}
					else
					{
						Renderer.draw(name,
						"line", { thickness:1, color:"0x" + circle.outline.toString(16) },
						"fill", { color:"0x" + circle.color.toString(16) },
						"circle", { x:0, y:0, radius:circle.radius})
					}
				}
				(circle.addComponent(Renderer) as Renderer).setBitmapByName(name);
			}
			if (circle.radius)
			{
				var col : CircleCollider = circle.addComponent(CircleCollider) as CircleCollider;
				col.radius = circle.radius;
				col.layers = circle.layers;
			}
			delete circle.radius;
			delete circle.layers;
			delete circle.color;
			delete circle.outline;
		}
		//}
		
		//{::::::::::::::::::::::: TRIANGLE :::::::::::::::::::::::
		public function geomTriangle(triangle : GameObject, params : Object) : void
		{
			var col : TriangleCollider = triangle.addComponent(TriangleCollider) as TriangleCollider;
			triangle.anchorX = params.anchorX || 1;
			triangle.anchorY = params.anchorY || 1;
			triangle.size = params.size || 1;
			col.defineSizeAndAnchor(triangle.size, triangle.anchorX, triangle.anchorY);
			col.layers = triangle.layers = uint(params.layers || uint.MAX_VALUE);
		}
		public function geomTriangleUpdate(triangle : GameObject) : void
		{
			triangle.triangleCollider.defineSizeAndAnchor(triangle.size, triangle.anchorX, triangle.anchorY);
		}
		public function geomTriangleComplete(triangle : GameObject) : void
		{
			triangle.triangleCollider.layers = triangle.layers;
			delete triangle.anchorX;
			delete triangle.anchorY;
			delete triangle.size;
			delete triangle.layers;
		}
		//}
	}

}