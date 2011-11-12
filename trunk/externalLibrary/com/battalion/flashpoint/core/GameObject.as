package com.battalion.flashpoint.core 
{
	
	import com.battalion.flashpoint.comp.TextRenderer;
	import flash.sampler.NewObjectSample;
	import flash.utils.getQualifiedClassName;
	import flash.utils.*;
	
	/**
	 * GameObjects are the only physical entities in FlashPoint.
	 * Instantiate this class and then add components to it.
	 * All GameObjects have a Transform component by default and it can not be removed.
	 * All components of a specified type are accessable through the getComponents() method.
	 * When only one component of a specified type exists, you can use the getComponent() method
	 * but it is advisable to access it using the dot operator.
	 * @example An example on how to use the dot operator to access Components:<listing version="3.0">
var myGameObject : GameObject = new GameObject(Renderer);
trace(myGameObject.renderer);//WORLD.Untitled.renderer
	 * </listing>
	 * @example An Example of how to use the dot operator to access GameObjects:<listing version="3.0">
var myGameObject : GameObject = new GameObject("foo");
var myChild : GameObject = new GameObject("bar");
myGameObject.addChild(myChild);
trace(myChild);//WORLD.foo.bar
	 * </listing>
	 * @see Component
	 * @see Transform
	 * @author Battalion Chiefs
	 */
	public final dynamic class GameObject
	{
		/** @private **/
		internal static var WORLD : GameObject;
		
		/**
		 * The world GameObject.
		 */
		CONFIG::debug
		public static function get world() : GameObject
		{
			return WORLD;
		}
		CONFIG::debug
		public function get transform() : Transform
		{
			return _transform;
		}
		/** @private **/
		CONFIG::debug
		internal var _transform : Transform;
		
		/**
		 * The world GameObject.
		 */
		CONFIG::release
		public static var world : GameObject;
		CONFIG::release
		public var transform : Transform;
		
		/** @private **/
		internal var _name : String;
		/** @private **/
		internal var _parent : GameObject = WORLD;
		/** @private **/
		internal var _children : Vector.<GameObject> = new Vector.<GameObject>();
		/** @private **/
		internal var _components : Vector.<Component>;
		/** @private **/
		internal var _messages : Object = { };
		/** @private **/
		internal var _after : Object = { };
		/** @private **/
		internal var _before : Object = { };
		/** @private **/
		internal var _update : Vector.<Function> = new Vector.<Function>();
		/** @private **/
		internal var _fixedUpdate : Vector.<Function> = new Vector.<Function>();
		/** @private **/
		internal var _start : Vector.<Function> = new Vector.<Function>();
		/** @private **/
		internal var _physicsComponents : Object;
		
		/**
		 * This is clearly obvious.
		 */
		public function get isDestroyed() : Boolean
		{
			return _parent == null;
		}
		/**
		 * The parent GameObject.
		 */
		public function get parent() : GameObject
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			return _parent == WORLD ? null : _parent;
		}
		public function set parent(value : GameObject) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			(value || WORLD).addChild(this);
		}
		/**
		 * The name of this GameObject. The name is used for referencing it from it's parent.<pre></pre>
		 * @example A GameObject with the name "myGameObject" with no parent, can be accessed like this:<listing version="3.0">
		 * GameObject.world.myGameObject
		 * </listing>
		 */
		public function get name() : String
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			return _name;
		}
		public function set name(value : String) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (value == null) throw new Error("Name must be non-null.");
			}
			_parent.updateNameOf(this, value);
			_name = value;
		}
		/**
		 * Creates a GameObject.
		 * The arguements are Component types that should be instantiated and added to this GameObject.<pre></pre>
		 * Optionally, the first parameter can be a String denoting the name of the GameObject.<pre></pre>
		 * Also, if the first or second parameter is a GameObject instance, then that will become this GameObjet's parent.
		 * @param	...args the name of the GameObject, the parent GameObject and finally a list of Component class types to add.
		 */
		public function GameObject(...args)
		{
			if (args.length && args[0] is String)
			{
				_name = args.shift();
			}
			else
			{
				_name = "Untitled";
			}
			if (args.length && args[0] is GameObject)
			{
				parent = args.shift();
			}
			else if (WORLD)
			{
				parent = WORLD;
			}
			
			_components = new Vector.<Component>(args.length + 1);
			var index : int = 0;
			
			CONFIG::debug
			{
				_transform = (_components[index++] = new Transform()) as Transform;
				_transform._gameObject = this;
			}
			CONFIG::release
			{
				transform = (_components[index++] = new Transform()) as Transform;
				transform._gameObject = this;
			}
			var awakeCalls : Vector.<Function> = new Vector.<Function>(args.length);
			var awakeIndex : int = 0;
			for each(var comp : Class in args)
			{
				if (!comp) continue;
				CONFIG::debug
				{
					if (!Util.isComponent(comp)) throw new Error(comp + " does not extend " + Component + ".");
				}
				
				var component : Component = _components[index++] = new comp();//faster than push()
				component._gameObject = this;
				
				CONFIG::debug
				{
					if (component is IExclusiveComponent && getComponents(comp).length > 1) throw new Error(getQualifiedClassName(comp) + " is an exclusive component but you're trying to add two instances on one GameObject.");
				}
				
				var name : String = getQualifiedClassName(component);
				name = name.slice(name.lastIndexOf("::") + 2);
				name = name.charAt(0).toLowerCase() + name.slice(1);
				
				if (!(component is IConciseComponent))
				{
					this[name] = component;
					
					var compObj : Object = component;
					if (compObj.hasOwnProperty("update") && compObj.update is Function)
					{
						_update.push(compObj.update);
					}
					if (compObj.hasOwnProperty("fixedUpdate") && compObj.fixedUpdate is Function)
					{
						_fixedUpdate.push(compObj.fixedUpdate);
					}
					if (compObj.hasOwnProperty("awake") && compObj.awake is Function)
					{
						awakeCalls[awakeIndex++] = compObj.awake;
					}
					if (compObj.hasOwnProperty("start") && compObj.start is Function)
					{
						_start.push(compObj.start);
					}
				}
				else if (!_messages.hasOwnProperty(name))
				{
					_messages[name] = new <Function>[component[name]];
				}
				else
				{
					_messages[name].push(component[name]);
				}
			}
			_components.length = index;
			while (awakeIndex--)
			{
				awakeCalls[awakeIndex]();
				if (!_parent) return;
			}
		}
		
		private function updateNameOf(child : GameObject, newName : String) : void
		{
			var oldName : String = child._name;
			delete this[oldName];
			for each(var otherChild : GameObject in _children)
			{
				if (otherChild._name == oldName)
				{
					this[oldName] = otherChild;
					break;
				}
			}
		}
		/** Add multiple children.
		 * @see #addChild()
		public function addChildren(...children) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (!children.length) throw new Error("Expecting at least one child as parameter.");
				for each(var obj : * in children)
				{
					if (!obj || !(obj is GameObject))
					{
						throw new Error(obj + " is not a GameObject.");
					}
				}
			}
			for each(var child : GameObject in children)
			{
				_children.push(child);
				child._parent.unparentChild(child);
				child._parent = this;
				this[child._name] = child;
			}
		}
		/**
		 * Remove multiple children.
		 * @see #removeChild()
		 * @param	...children
		 */
		public function removeChildren(...children) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (!children.length) throw new Error("Expecting at least one child as parameter.");
				for each(var obj : * in children)
				{
					if (!obj || !(obj is GameObject))
					{
						throw new Error(obj + " is not a GameObject.");
					}
					else
					{
						if (obj._parent != this)
						{
							throw new Error("GameObject does not contain the specified child.");
						}
					}
				}
			}
			for each(var child : GameObject in children)
			{
				WORLD.addChild(child);
			}
		}
		/**
		 * Add a GameObject as a child. If the child already has a parent,
		 * then that parent will automatically lose the child before this one adds it.
		 * @param	child
		 */
		public function addChild(child : GameObject) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (child == null) throw new Error("Child must be non-null.");
			}
			child._parent.unparentChild(child);
			_children.push(child);
			child._parent = this;
			this[child._name] = child;
		}
		/**
		 * Remove a GameObject from this GameObject's children.
		 * @param	child, the child GameObject to remove.
		 */
		public function removeChild(child : GameObject) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (child == null) throw new Error("Child must be non-null.");
				if (child._parent != this) throw new Error("GameObject does not contain the specified child.");
			}
			WORLD.addChild(child);
		}
		private function unparentChild(child : GameObject) : void
		{
			var index : int = _children.indexOf(child);
			if (index > -1)
			{
				if (index < _children.length - 1)
				{
					_children[index] = _children.pop();
				}
				else
				{
					_children.length--;
				}
				delete this[child._name];
			}
		}
		/**
		 * Names of all the child GameObjects in this GameObject.
		 * @return	A vector of the names of all the child GameObjects in this GameObject.
		 */
		public function getChildrenNames() : Vector.<String>
		{
			var names : Vector.<String> = new Vector.<String>(_children.length);
			var c : int = _children.length;
			while (c--)
			{
				names[c] = _children[c].name;
			}
			return names;
		}
		/**
		 * Gets all components of s spcific type.
		 * @param	type, the type of the Components to get.
		 * @return	All components of s spcific type.
		 */
		public function getComponents(type : Class) : Vector.<Component>
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non-null.");
			}
			var results : Vector.<Component> = new Vector.<Component>();
			for each(var component : Component in _components)
			{
				if (component is type)
				{
					results.push(component);
				}
			}
			return results;
		}
		/**
		 * Does this GameObject have a component of type <code>type</code>?
		 * @param	type, the type of the component to search for.
		 * @return	true if a component of type <code>type</code> was found, otherwise false.
		 */
		public function haveComponent(type : Class) : Boolean
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non-null.");
			}
			var name : String = type + "";
			name = name.charAt(8).toLowerCase() + name.slice(8, name.length-1);
			return this.hasOwnProperty(name);
		}
		/**
		 * Find a component, upwards, untill a component is found or the world GameObject is reached.
		 * @param	type, the type of the Component to look for.
		 * @return	If the component was found, it returns that component, otherwise null.
		 */
		public function findComponentUpwards(type : Class) : *
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non-null.");
			}
			var name : String = type + "";
			name = name.charAt(8).toLowerCase() + name.slice(8, name.length - 1);
			return findComponentUpwardsRecursive(name);
		}
		private function findComponentUpwardsRecursive(type : String) : *
		{
			if (this.hasOwnProperty(type) && this[type] is Component)
				return this[type];
			if (this != WORLD)
				return _parent.findComponentUpwardsRecursive(type);
			return null;
		}
		/**
		 * Find a Component of a specific <code>type</code> in this and all the children, and children's children, etc.
		 * @param	type, the type of the Component to look for.
		 * @return	If the component was found, it returns that component, otherwise null.
		 */
		public function findComponentDownwards(type : Class) : *
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non-null.");
			}
			var name : String = type + "";
			name = name.charAt(8).toLowerCase() + name.slice(8, name.length - 1);
			if (this.hasOwnProperty(name) && this[name] is Component)
				return this[name];
			return findComponentDownwardsRecursive(name);
		}
		private function findComponentDownwardsRecursive(type : String) : *
		{
			for each(var obj : GameObject in _children)
			{
				if (obj.hasOwnProperty(type) && obj[type] is Component)
					return obj[type];
			}
			for each(obj in _children)
			{
				var results : * = obj.findComponentDownwardsRecursive(type);
				if (results) return results;
			}
			return null;
		}
		
		public function findGameObjectDownwards(goName : String): GameObject
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (goName == null) throw new Error("goName must be non-null.");
			}
			if (name == goName) return this;
			return findGameObjectDownwardsRecursive(goName, this);
			
		}
		
		private static function findGameObjectDownwardsRecursive(goName : String, currentTarget : GameObject) : GameObject
		{
			for each (var child : GameObject in currentTarget._children)
			{
				if (child.name == goName)
					return child;
			}
			for each (child in currentTarget._children)
			{
				var results : GameObject = findGameObjectDownwardsRecursive(goName, child);
				if (results) return results;
			}
			return null;
		}
		
		/**
		 * It's recommended that you use the dot operator to access components, not this method. It's only here for consistency.
		 * @example Here's an example of how to use the dot operator:<listing version="3.0">
var myGameObject : GameObject = new GameObject(Rigidbody, BoxCollider);
myGameObject.boxCollider.dimensions = new Point(10, 10);</listing>
		 * @param	type, The type of the Component to get.
		 * @return	If the Component exists, then it returns that Component, otherwise null.
		 */
		public function getComponent(type : Class) : Component
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non-null.");
			}
			var name : String = type + "";
			name = name.charAt(7).toLowerCase() + name.slice(8, name.length-1);
			if (this.hasOwnProperty(name))
			{
				return this[name];
			}
			return null;
		}
		
		
		
		/**
		 * Destroys the GameObject and all of it's components and child GameObjects.
		 */
		public function destroy() : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (this == WORLD) throw new Error("\r\tI was just chilling, minding my own business when suddenly you call this method:\r\t\t\"GameObject.world.destroy();\"\r\tOMG you're such a NOOB!");
			}
			/*for each(var compObj : Object in _components)
			{
				if (compObj.hasOwnProperty("onDestroy") && compObj.onDestroy is Function)
				{
					compObj.onDestroy();
				}
			}*/
			sendMessage("onDestroy");
			_parent.unparentChild(this);
			_parent = null;
		}
		
		public function clone() : GameObject
		{
			return cloneRecursive(parent);
		}
		private function cloneRecursive(newParent : GameObject) : GameObject
		{
			var copy : GameObject = new GameObject(name, newParent);
			for each(var comp : Component in _components)
			{
				copy.addComponent(Class(getDefinitionByName(getQualifiedClassName(comp)))).copyFrom(comp);
			}
			for each(var child : GameObject in _children)
			{
				child.cloneRecursive(copy);
			}
			return copy;
		}
		
		/**
		 * Just like addComponent except it's for concise components.
		 * 
		 * @see IConciseComponent
		 * @see IExclusiveComponent
		 * @see #addComponent()
		 * 
		 * @param	comp, the Component type to add.
		 * @param	lowerCaseName, (optional) mentioning the name of the class but starting with a lowercase letter is only to increase performance.
		 */
		public function addConcise(comp : Class, lowerCaseName : String = null) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non-null."); 
				if (!Util.isComponent(comp)) throw new Error(comp + " does not extend " + Component + ".");
				if (!Util.isConcise(comp)) throw new Error(comp + " does not implement the IConciseComponent interface.");
			}
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			//TODO: optimize, remove function call
			var precursor : Component = getComponent(comp);
			if (precursor && precursor is IExclusiveComponent)
			{
				return;
			}
			
			var instance : Component = new comp();
			instance._gameObject = this;
			_components.push(instance);
			
			if (!lowerCaseName)
			{
				lowerCaseName = getQualifiedClassName(instance);
				lowerCaseName = lowerCaseName.slice(lowerCaseName.lastIndexOf("::") + 2);
				lowerCaseName = lowerCaseName.charAt(0).toLowerCase() + lowerCaseName.slice(1);
			}
			
			CONFIG::debug
			{
				if (!instance.hasOwnProperty(lowerCaseName) || !(instance[lowerCaseName] is Function))
				{
					throw new Error(instance + " does not contain a function named " + lowerCaseName + "."); 
				}
			}
			
			if (!_after.hasOwnProperty(lowerCaseName))
			{
				_after[lowerCaseName] = { };
			}
			if (!_after[lowerCaseName].destroyConcise)
			{
				_after[lowerCaseName].destroyConcise = [instance.destroyConcise];
			}
			else
			{
				_after[lowerCaseName].destroyConcise.push(instance.destroyConcise);
			}
			
			if (!_messages.hasOwnProperty(lowerCaseName))
			{
				_messages[lowerCaseName] = new <Function>[instance[lowerCaseName]];
			}
			else
			{
				_messages[lowerCaseName].push(instance[lowerCaseName]);
			}
		}
		/**
		 * Use this to add a Component.<br/>
		 * Make sure the component is not concise.<br/>
		 * If so, use the addConcise method instead.
		 * 
		 * @see IExclusiveComponent
		 * @see #addConcise()
		 * 
		 * @param	comp, the Component type to add.
		 */
		public function addComponent(comp : Class) : Component
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non-null."); 
				if (!Util.isComponent(comp)) throw new Error(comp + " does not extend " + Component + ".");
				if (Util.isConcise(comp)) throw new Error(comp + " implements the IConciseComponent interface. Please use the addConcise() method instead.");
			}
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			//TODO: optimize, remove function call
			var precursor : Component = getComponent(comp);
			if (precursor && precursor is IExclusiveComponent)
			{
				return precursor;
			}
			var instance : Component = new comp();
			instance._gameObject = this;
			_components.push(instance);
			
			var name : String = getQualifiedClassName(instance);
			name = name.slice(name.lastIndexOf("::") + 2);
			name = name.charAt(0).toLowerCase() + name.slice(1);
			this[name] = instance;

			for (var message : String in _messages)
			{
				var indexOfUnderScore : int = message.indexOf("_");
				if (indexOfUnderScore > 0)
				{
					var functionName : String = message.slice(indexOfUnderScore + 1);
					var className : String = message.slice(0, indexOfUnderScore);
					className = className.charAt(0).toLowerCase() + className.slice(1);
					if (hasOwnProperty(className))
					{
						var targetClass : Class = getDefinitionByName(getQualifiedClassName(this[className])) as Class;
					}
					else
					{
						targetClass = null;
					}
				}
				else
				{
					functionName = message;
					targetClass = Component;
				}
				
				if (instance is targetClass && instance.hasOwnProperty(functionName))
				{
					CONFIG::debug
					{
						if (!(instance[functionName] is Function)) throw new Error("the property " + functionName + " of " + instance + " conflicts with a message with the same name."); 
					}
					_messages[message].push(instance[functionName]);
				}
			}
			
			var compObj : Object = instance;
			if (compObj.hasOwnProperty("update") && compObj.update is Function)
			{
				_update.push(compObj.update);
			}
			if (compObj.hasOwnProperty("fixedUpdate") && compObj.fixedUpdate is Function)
			{
				_fixedUpdate.push(compObj.fixedUpdate);
			}
			if (compObj.hasOwnProperty("start") && compObj.start is Function)
			{
				_start.push(compObj.start);
			}
			if (compObj.hasOwnProperty("awake") && compObj.awake is Function)
			{
				compObj.awake();
			}
			return instance;
		}
		/**
		 * Remove a Component instance from this GameObject. Essentially the same as to call the destroy method on the Component itself.
		 * Do not remove Components that are required by other Components.
		 * When this method is called, the <code>onDestroy()</code> method is called on the Component that is about to be removed. If that method returns true, the removal is cancelled.
		 * @param	instance, the Component on the GameObject that should be removed.
		 */
		public function removeComponent(instance : Component) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (instance == null) throw new Error("Instance must be non-null."); 
				if (_components.indexOf(instance) < 0) throw new Error("GameObject does not contain " + instance + "." );
				if (instance._requiredBy.length > 0)
				{
					throw new Error("Component " + instance + " can not be removed. It is required by "
					+ (instance._requiredBy.length > 1 ? "the following: [" + instance._requiredBy.join(", ") + "]." : instance._requiredBy[0]));
				}
				if (instance._require.length > 0)
				{
					for each(var requiredComponent : Component in instance._require)
					{
						requiredComponent._requiredBy = requiredComponent._requiredBy.filter(
							function(c : Component, i : int, v : Vector.<Component>) : Boolean
							{
								return c != instance;
							}
						);
					}
				}
			}
			
			var compObj : Object = instance;
			if (compObj.hasOwnProperty("onDestroy") && compObj.onDestroy is Function)
			{
				if (compObj.onDestroy())
				{
					return;
				}
			}
			if (compObj.hasOwnProperty("update"))
			{
				var index : int = _update.lastIndexOf(compObj.update);
				if (index < _update.length - 1)
				{
					_update[index] = _update.pop();
				}
				else
				{
					_update.length--;
				}
			}
			if (compObj.hasOwnProperty("fixedUpdate"))
			{
				index  = _fixedUpdate.lastIndexOf(compObj.fixedUpdate);
				if (index < _fixedUpdate.length - 1)
				{
					_fixedUpdate[index] = _fixedUpdate.pop();
				}
				else
				{
					_fixedUpdate.length--;
				}
			}
			
			for (var message : String in _messages)
			{
				var indexOfUnderScore : int = message.indexOf("_");
				if (indexOfUnderScore > 0)
				{
					var functionName : String = message.slice(indexOfUnderScore + 1);
					var className : String = message.slice(0, indexOfUnderScore);
					className = className.charAt(0).toLowerCase() + className.slice(1);
					if (hasOwnProperty(className))
					{
						var targetClass : Class = getDefinitionByName(getQualifiedClassName(this[className])) as Class;
					}
					else
					{
						targetClass = null;
					}
				}
				else
				{
					functionName = message;
					targetClass = Component;
				}
				
				if (instance is targetClass && instance.hasOwnProperty(functionName))
				{
					var rcv : Vector.<Function> = _messages[message];
					index = rcv.indexOf(instance[functionName]);
					if (index > -1)
					{
						if (index < rcv.length - 1)
						{
							rcv[index] = rcv.pop();
						}
						else
						{
							rcv.length--;
						}
					}
				}
			}
			var instanceIndex : int = _components.indexOf(instance);
			if (instanceIndex < _components.length - 1)
			{
				_components[instanceIndex] = _components.pop();
			}
			else
			{
				_components.length--;
			}
			instance._gameObject = null;
			
			var deleteComponent : Boolean = true;
			var type : Class = Class(getDefinitionByName(getQualifiedClassName(instance)))
			for each(var component : Component in _components)
			{
				if (component is type)
				{
					var name : String = getQualifiedClassName(component);
					name = name.slice(name.lastIndexOf("::") + 2);
					name = name.charAt(0).toLowerCase() + name.slice(1);
					this[name] = component;
					deleteComponent = false;
					break;
				}
			}
			if(deleteComponent)
			{
				delete this[name];
			}
		}
		/**
		 * Use this to communicate with Components in this GameObject.
		 * Calls every function named message on every Component in this GameObject.
		 * 
		 * @exampleText sendMessage("applyDamage", 10);
		 * ...
		 * public function applyDamage(amount : int) : void
		 * {
		 * 	log("Ouch! -" + amount + "Hp.");
		 * }
		 * @param	message, the function name to call on every Component in this GameObject.
		 * @param	...args, the parameters to pass along with the function call.
		 */
		public function sendMessage(message : String, ...args) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non-null.");
			}
			if (_components.length)
			{
				_components[0].sendMessage.apply(_components[0], [message].concat(args));
			}
		}
		/**
		 * Use this to communicate with Components in this GameObject.
		 * Like sendMessage() except it differs the call until the target message has been sent.
		 * 
		 * @see #sendMessage()
		 * @param	message, the function name to call on every Component in this GameObject.
		 * @param	target, the message that triggers this message, evidently preceding this message.
		 * @param	...args, the parameters to pass along with the function call.
		 */
		public function sendAfter(message : String, target : String, ...args) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non-null.");
				if (target == null) throw new Error("Target must be non-null.");
			}
			if (_components.length)
			{
				_components[0].sendAfter.apply(_components[0], [message, target].concat(args));
			}
		}
		/**
		 * Use this to communicate with Components in this GameObject.
		 * Like sendMessage() except it differs the call until right before the target message will been sent.
		 * 
		 * @see #sendMessage()
		 * @param	message, the function name to call on every Component in this GameObject.
		 * @param	target, the message that should succeed this message.
		 * @param	...args, the parameters to pass along with the function call.
		 */
		public function sendBefore(message : String, target : String, ...args) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non-null.");
				if (target == null) throw new Error("Target must be non-null.");
			}
			if (_components.length)
			{
				_components[0].sendBefore.apply(_components[0], [message, target].concat(args));
			}
		}
		/**
		 * Use this to communicate with Components in this GameObject.
		 * Chains together messages to be sent after the invoker message is sent.
		 * 
		 * @see #sendMessage()
		 * @param	invoker, the meessage name that triggers this chain of messages.
		 * @param	...messages, the messages to be chained.
		 */
		public function chain(invoker : String, ...messages) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			if (_components.length)
			{
				_components[0].chain.apply(_components[0], [invoker].concat(messages));
			}
		}
		/**
		 * Use this to communicate with Components in this GameObject.
		 * Like chain() except that the first parameter is the invoker, and it is called right after the chain has been made.
		 * 
		 * @see #chain()
		 * @see #sendMessage()
		 * @param	...messages, the messages to be chained and called.
		 */
		public function sequence(...messages) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			if (_components.length)
			{
				_components[0].sequence.apply(_components[0], messages);
			}
		}
		public function toString() : String
		{
			if (_parent != WORLD)
			{
				return _parent.toString() + "." + _name;
			}
			return _name;
		}
		/**
		 * The current state this GameObject's hierachy represented in XML.
		 */
		public function get hierachy() : XML
		{
			var root : XML = new XML("<" + _name + "/>");
			for each(var child : GameObject in _children)
			{
				root.appendChild(child.hierachy);
			}
			return root;
		}
		/**
		 * Just like <code>hierachy</code> but includes information about the components too.
		 */
		public function get description() : XML
		{
			var gameObjectNS : Namespace = new Namespace("GameObject");
			var componentNS : Namespace = new Namespace("Component");
			
			var root : XML = new XML("<" + _name + "/>");
			for each(var component : Component in _components)
			{
				var compName : String = getQualifiedClassName(component);
				compName = compName.slice(compName.lastIndexOf(":") + 1);
				root.appendChild(XML("<" + compName + "/>"))
			}
			for each(var child : GameObject in _children)
			{
				root.appendChild(child.description);
			}
			return root;
		}
		/**
		 * Use this to view the current GameObject hierachy.
		 * @param logComponents, true will trace out the component types currently added to each GameObject.
		 */
		public function logHierachy(logComponents : Boolean = false) : void
		{
			var components : String = "";
			if (logComponents)
			{
				var i : int = _components.length;
				var compNames : Vector.<String> = new Vector.<String>(i);
				while(i--)
				{
					compNames[i] = getQualifiedClassName(_components[i]);
					compNames[i] = compNames[i].slice(compNames[i].lastIndexOf(":") + 1);
				}
				components = ": [" + compNames.join(", ") + "]";
			}
			trace(_name + components + "\n{");
			
			var target : GameObject = this;
			var depth : String = "";
			var indexStack : Vector.<uint> = new <uint>[0];
			while (indexStack.length > 0)
			{
				var index : uint = indexStack[indexStack.length - 1];
				if (index < target._children.length)
				{
					target = target._children[index];
					indexStack[indexStack.length - 1]++;
					components = "";
					if (logComponents)
					{
						i = target._components.length;
						compNames = new Vector.<String>(i);
						while(i--)
						{
							compNames[i] = getQualifiedClassName(target._components[i]);
							compNames[i] = compNames[i].slice(compNames[i].lastIndexOf(":") + 1);
						}
						components = ": [" + compNames.join(", ") + "]";
					}
					
					if (target._children.length)
					{
						indexStack.push(0);
						trace((depth += "\t") + target.name + components + "\n" + depth + "{");
					}
					else
					{
						trace(depth + "\t" + target.name + components);
						target = target._parent;
					}
				}
				else
				{
					trace(depth + "}");
					indexStack.pop();
					target = target._parent;
					depth = depth.slice(0, -1);
				}
			}
		}
		/**
		 * Use this instead of trace when possible.
		 * @param	...args, if no arguments, the GameObject will list all of it's child GameObjects and Components' types, properties and variables.
		 */
		public function log(...args) : void
		{
			CONFIG::debug
			{
				if (log.length > 0)
				{
					trace(this + ": " + args.join(", "));
				}
				else
				{
					var i : int = _children.length;
					var names : Vector.<String> = new Vector.<String>(i);
					while(i--)
					{
						names[i] = _children[i].name;
					}
					trace(this + ": " + names.join(", "));
					for each(var comp : Component in _components)
					{
						var name : String = getQualifiedClassName(comp);
						name = name.slice(name.lastIndexOf("::") + 2);
						name = name.charAt(0).toLowerCase() + name.slice(1);
						trace("\t" + name + ": ");
						var info : XMLList = describeType(comp).children();
						for each(var member : XML in info)
						{
							if ((member.name() == "variable" || member.name() == "accessor"))
							{
								trace("\t\t" + member.@name + ": " + comp[member.@name]);
							}
						}
					}
				}
			}
		}
		/** @private **/
		internal function update() : void
		{
			//START
			if (_start.length)
			{
				for each(var f : Function in _start)
				{
					f();
					if (!_parent) return;
				}
				_start.length = 0;
			}
			//BEFORE UPDATE
			if (_before.update)
			{
				for each(var before : Array in _before.update)
				{
					sendMessage.apply(this, before);
					if (!_parent) return;
				}
				delete _before.update;
			}
			//UPDATE
			for each(f in _update)
			{
				f();
				if (!_parent) return;
			}
			//AFTER UPDATE
			if (_after.update)
			{
				for each(var after : Array in _after.update)
				{
					sendMessage.apply(this, after);
					if (!_parent) return;
				}
				delete _after.update;
			}
			//REPEAT ON CHILDREN
			for each(var child : GameObject in _children)
			{
				child.update();
				if (!_parent) return;
			}
			CONFIG::debug
			{
				_transform.flush();
			}
			CONFIG::release
			{
				transform.flush();
			}
		}
		/** @private **/
		internal function fixedUpdate() : void
		{
			//BEFORE FIXED UPDATE
			if (_before.fixedUpdate)
			{
				for each(var before : Array in _before.fixedUpdate)
				{
					sendMessage.apply(this, before);
					if (!_parent) return;
				}
				delete _before.fixedUpdate;
			}
			//FIXED UPDATE
			for each(var f : Function in _fixedUpdate)
			{
				f();
				if (!_parent) return;
			}
			//AFTER FIXED UPDATE
			if (_after.fixedUpdate)
			{
				for each(var after : Array in _after.fixedUpdate)
				{
					sendMessage.apply(this, after);
					if (!_parent) return;
				}
				delete _after.fixedUpdate;
			}
			//REPEAT ON CHILDREN
			for each(var child : GameObject in _children)
			{
				child.fixedUpdate();
				if (!_parent) return;
			}
		}
	}
}