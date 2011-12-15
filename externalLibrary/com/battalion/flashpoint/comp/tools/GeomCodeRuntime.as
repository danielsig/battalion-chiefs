package com.battalion.flashpoint.comp.tools 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Renderer;
	import com.danielsig.geomcode.GeomCode;
	
	/**
	 * Use this component to run GeomCode within FlashPoint.
	 * @author Battalion Chiefs
	 */
	public final class GeomCodeRuntime extends Component implements IExclusiveComponent
	{
		
		private static var _sources : Object = { };
		private static var _sourceSettings : Object = { };
		private var _sourceURL : String;
		private var _sourceID : String;
		
		public function get source() : String
		{
			return _sourceURL;
		}
		public function set source(value : String) : void
		{
			_sourceURL = value;
			_sourceID = "_" + value.replace(/[^a-zA-Z0-9_]/g, "");
			if (!_sources[_sourceID])
			{
				_sources[_sourceID] = new GeomCode(value, create, clone, updateGeomProps, onConstructionComplete, Renderer.load);
				_sourceSettings[_sourceID] = this;
			}
		}
		public function construct(geometryName : String, params : Object = null) : void
		{
			if (_sourceID)
			{
				if (_sourceSettings[_sourceID] != this)
				{
					_sources[_sourceID].resetFunctions(create, clone, updateGeomProps, onConstructionComplete, Renderer.load);
					_sourceSettings[_sourceID] = this;
				}
				_sources[_sourceID].construct(geometryName, params);
			}
		}
		private function clone(original : GameObject) : GameObject
		{
			return original.clone();
		}
		private function create(name : String, params : Object, parent : GameObject) : GameObject
		{
			var obj : GameObject = new GameObject(name, parent);
			if (params.pos)
			{
				obj.transform.x = params.pos.x;
				obj.transform.y = params.pos.y;
			}
			if (params.rotation) obj.transform.rotation = params.rotation;
			
			obj.density = params.density;
			obj.massDistribution = params.massDistribution;
			obj.mass = params.mass;
			obj.inertia = params.inertia;
			
			obj.texture = params.texture;
			
			obj.x = obj.transform.x;
			obj.y = obj.transform.y;
			obj.rotation = obj.transform.rotation;
			
			delete params.pos;
			delete params.rotation;
			delete params.density;
			delete params.massDistribution;
			delete params.mass;
			delete params.inertia;
			
			sendMessage("geom" + name, obj, params);
			
			return obj;
		}
		private function updateGeomProps(obj : GameObject, name : String) : void
		{
			obj.transform.x = obj.x;
			obj.transform.y = obj.y;
			obj.transform.rotation = obj.rotation;
			
			sendMessage("geom" + name + "Update", obj);
		}
		private function onConstructionComplete(obj : GameObject, name : String, discrete : Boolean = false) : void
		{
			if (discrete)
			{
				var gx : Number = obj.parent.transform.x;
				var gy : Number = obj.parent.transform.y;
				var ga : Number = obj.parent.transform.rotation;
				obj.parent = null;
				obj.transform.x += gx;
				obj.transform.y += gy;
				obj.transform.rotation += ga;
			}
			if (obj.density || obj.massDistribution || obj.mass || obj.inertia)
			{
				if (obj.parent)
				{
					var parent : GameObject = obj;
					while (parent.parent) parent = parent.parent;
					parent.addComponent(Rigidbody);
				}
				else
				{
					obj.addComponent(Rigidbody);
					if (obj.density == obj.density) obj.rigidbody.density = obj.density;
					if (obj.massDistribution == obj.massDistribution) obj.rigidbody.massDistribution = obj.massDistribution;
					if (obj.mass == obj.mass) obj.rigidbody.mass = obj.mass;
					if (obj.inertia == obj.inertia) obj.rigidbody.inertia = obj.inertia;
				}
			}
			if (obj.texture)
			{
				(obj.addComponent(Renderer) as Renderer).setBitmapByName(obj.texture);
			}
			
			delete obj.x;
			delete obj.y;
			delete obj.rotation;
			delete obj.density;
			delete obj.massDistribution;
			delete obj.mass;
			delete obj.inertia;
			delete obj.texture;
			
			sendMessage("geom" + name + "Complete", obj);
		}
	}

}