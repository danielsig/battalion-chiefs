package com.battalion.powergrid 
{
	
	import com.battalion.flashpoint.comp.TextRenderer;
	import com.battalion.flashpoint.core.GameObject;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * The main class of the PowerGrid physics engine. Call the init method before anything else.
	 * @author Battalion Chiefs
	 */
	public final class PowerGrid 
	{
		/**
		 * The height of the grid.
		 */
		public static function get gridHeight() : uint
		{
			return _length / _width;
		}
		/**
		 * The width of the grid.
		 */
		public static function get gridWidth() : uint
		{
			return _widthUint;
		}
		/**
		 * The Unit Size.
		 */
		public static function get unitSize() : uint
		{
			return 1 << _unitLog2;
		}
		/**
		 * The maximum velocity magnitude that a rigidbody can have when falling asleep.
		 */
		public static function get sleepVelocity() : Number
		{
			return Math.sqrt(_sleepVelocity);
		}
		public static function set sleepVelocity(value : Number) : void
		{
			_sleepVelocity = value * value;
		}
		/**
		 * The maximum angular velocity magnitude that a rigidbody can have when falling asleep.
		 */
		public static function get sleepAngularVelocity() : Number
		{
			return Math.sqrt(_sleepAngularVelocity);
		}
		public static function set sleepAngularVelocity(value : Number) : void
		{
			_sleepAngularVelocity = value * value;
		}
		/**
		 * The number of steps per second.
		 */
		public static function get hz() : uint
		{
			return _hz;
		}
		public static function set hz(value : uint) : void
		{
			_hz = value;
			_milliHz = value * 0.001;
			_invHz = 1.0 / value;
		}
		/**
		 * The amount of time in seconds that a rigidbody must be still in order to fall asleep.
		 */
		public static var sleepTime : Number = 2;
		/**
		 * The amount of penetration required to wake up a rigidbody.
		 */
		public static var minPenetration : Number = 3;
		public static var gravityX : Number = 0;
		public static var gravityY : Number = 1;
		public static var maxVelocityX : Number = Number.POSITIVE_INFINITY;
		public static var maxVelocityY : Number = Number.POSITIVE_INFINITY;
		public static var maxVelocityA : Number = Number.POSITIVE_INFINITY;
		public static var maxIterations : uint = 2;
		/**
		 * Determines how fast a rigidbody will start resting, resting is used to minimize jitter in an efficient way.
		 * Consider using this instead of more iterations.
		 */
		public static var restingSpeed : Number = 0.005;
		
		//public static var stage:Sprite;
		
		
		/** @private **/
		internal static var _circles : BodyNode = null;
		/** @private **/
		internal static var _triangles : BodyNode = null;
		/** @private **/
		internal static var _groups : BodyNode = null;
		
		private static var _unitLog2 : uint;
		/** @private **/
		internal static var _buckets : Vector.<BodyNode>;
		private static var _tiles : Vector.<uint>;
		
		private static var _length : uint;
		private static var _width : Number;
		private static var _widthUint : uint;
		
		private static var _physicalWidth : Number;
		private static var _physicalHeight : Number;
		
		private static var _sleepVelocity : Number = 0;
		private static var _sleepAngularVelocity : Number = 0;
		
		private static var _hz : uint = 30;
		private static var _milliHz : Number = _hz * 0.001;
		private static var _invHz : Number = 1.0 / _hz;
		
        private static var sqrtTable:Vector.<Number>;
        private static var sqrtPow:Number;
        private static var maxSize:Number;
		
		private static var _wallLeft : AbstractRigidbody = new AbstractRigidbody();
		private static var _wallRight : AbstractRigidbody = new AbstractRigidbody();
		private static var _wallTop : AbstractRigidbody = new AbstractRigidbody();
		private static var _wallBottom : AbstractRigidbody = new AbstractRigidbody();
		
		private static var colInfo : Vector.<Number> = new Vector.<Number>(4);
		
		/**
		 * Call this to initiate the PowerGrid.
		 * @param	grid
		 * @param	unitSize
		 * @param	maxSizePromise, must be a number between 1 and 3861 (which is sqrt(int.MAX_VALUE) / 12)
		 */
		public static function init(grid : BitmapData, unitSize : uint, maxSizePromise : Number) : void
		{
			CONFIG::debug
			{
				if (!grid) throw new Error("grid must be non null");
				if (isNaN(maxSizePromise)) throw new Error("maxSizePromise is NaN (Not a Number)");
			}
			generateSqrtTable(2, 0.01, maxSizePromise * 1.2);
			maxSize = sqrtTable.length / sqrtPow;
			_unitLog2 = 0;
			while (unitSize >>> _unitLog2)
			{
				_unitLog2++;
			}
			if(unitSize - (1 << --_unitLog2) >= (1 << (_unitLog2-1))) _unitLog2++;
		
			
			if (unitSize != 1 << _unitLog2)
			{
				trace("Warning! The unitSize " + unitSize + " is not a power of 2.\nInsted the unitSize will be rounded to " + (1 << _unitLog2) + ".");
			}
			
			_wallLeft.x = Number.NEGATIVE_INFINITY;
			_wallLeft.y = grid.height * unitSize * 0.5;
			_wallRight.x = Number.POSITIVE_INFINITY;
			_wallRight.y = grid.height * unitSize * 0.5;
			_wallTop.x = grid.width * unitSize * 0.5;
			_wallTop.y = Number.NEGATIVE_INFINITY;
			_wallBottom.x = grid.width * unitSize * 0.5;
			_wallBottom.y = Number.POSITIVE_INFINITY;
			
			grid = grid || new BitmapData(1, 1);
			_widthUint = _width = grid.rect.width;
			_tiles = grid.getVector(grid.rect);
			_length = _tiles.length;
			_buckets = new Vector.<BodyNode>(_length, true);
			
			_physicalWidth = _width << _unitLog2;
			_physicalHeight = grid.rect.height << _unitLog2;
		}
		
		/**
        *   Make the look up table for square root
        *   @param max Maximum value to cache
        *   @param numDigits Number of digits places of precision
        *   @param func Function to call to generate stored values.
        *               Must be valid on [0,max).
        *   @throws Error If func is null or invalid on [0,max)
        */
        private static function generateSqrtTable(numDigits:Number, min:Number, max:Number) : void
        {
            var pow:Number = sqrtPow = Math.pow(10, numDigits);
            var round:Number = 1.0 / pow;
            var len:uint = 1 + (max * pow) << 6;
            var table:Vector.<Number> = sqrtTable = new Vector.<Number>(len);
 
            var val:Number = 0;
            for (var i:uint = 0; i < len; ++i)
            {
                table[i] = Math.sqrt(val);
				if (table[i] < min) table[i] = min;
                val += round;
            }
        }
		
		/**
		 * Call this method on every physics step.
		 * @param	timeElapsed, the time elapsed since the last step in milliseconds.
		 */
		public static function step(timeElapsed : Number = 33.3333333) : void
		{
			var timeScale : Number = timeElapsed * _milliHz;
			var deltaTimeElapsed : Number = timeScale * _invHz;
			if ((gravityX > 0 ? gravityX : -gravityX) < (gravityY > 0 ? gravityY : -gravityY))
			{
				if (gravityY > 0) var bottomWall : AbstractRigidbody = _wallBottom;
				else bottomWall = _wallTop;
			}
			else if (gravityX > 0) bottomWall = _wallRight
			else bottomWall = _wallLeft;
				
			var typeCount : uint = 3;
			var bodies : BodyNode = _circles;
			while (typeCount--)
			{
				for(var body : BodyNode = bodies; body;)
				{
					var rigidbody : AbstractRigidbody = body.body;
					rigidbody.sleepTotalPenetration = 0;
					
					if (rigidbody.group && rigidbody is Circle)
					{
						body = body.next;
						continue;
					}
					var xMove : Number = rigidbody.vx;
					var yMove : Number = rigidbody.vy;
					var aMove : Number = rigidbody.va;
					
					if (!rigidbody.group)
					{
						for (var contact : Contact = rigidbody._contacts; contact; contact = contact.next)
						{
							if (contact.other.thisBody.sleeping > _sleepVelocity && (contact.nx * gravityX + contact.ny * gravityY) > -0.5
							|| contact.other.thisBody == bottomWall) break;
						}
					}
					
					if (
						(rigidbody.group && rigidbody.group.sleeping > sleepTime) ||
						(!rigidbody.group
						&& xMove * xMove + yMove * yMove < _sleepVelocity
						&& aMove * aMove < _sleepAngularVelocity
						&& rigidbody.sleeping >= 0 && (contact || rigidbody.sleeping == sleepTime + 500)
						&& (rigidbody.sleeping += deltaTimeElapsed) > sleepTime)
					)
					{
						// sleep if still
						rigidbody.sleep();
						
						var next : BodyNode = body.next;
						
						if (body.next) body.next.prev = body.prev;
						if (body.prev) body.prev.next = body.next;
						else if (rigidbody is Circle) _circles = body.next;
						else if (rigidbody is Triangle) _triangles = body.next;
						else if (rigidbody is Group) _groups = body.next;
						
						body.next = BodyNode.pool;
						BodyNode.pool = body;
						
						BodyNode.pool.brother = BodyNode.pool.prev = null;
						BodyNode.pool.body = null;
						BodyNode.pool.index = uint.MAX_VALUE;
						
						for (contact = rigidbody._contacts; contact; contact = contact.next)
						{
							if (contact.nx * gravityX + contact.ny * gravityY < 0)
							{
								rigidbody = contact.other.thisBody;
								rigidbody.sleep();
								rigidbody.sleeping = sleepTime + 500;
								for (var contact2 : Contact = rigidbody._contacts; contact2; contact2 = contact2.next)
								{
									if (contact2.nx * gravityX + contact2.ny * gravityY < 0)
									{
										rigidbody = contact2.other.thisBody;
										rigidbody.sleep();
										rigidbody.sleeping = sleepTime + 500;
										for (var contact3 : Contact = rigidbody._contacts; contact3; contact3 = contact3.next)
										{
											if (contact3.nx * gravityX + contact3.ny * gravityY < 0)
											{
												rigidbody = contact3.other.thisBody;
												if (rigidbody.sleeping < sleepTime)
												{
													rigidbody.sleep();
													rigidbody.sleeping = sleepTime + 500;
												}
											}
										}
									}
								}
							}
						}
						
						body = next;
					}
					else
					{
						if (!rigidbody.group)
						{
							if(rigidbody.sleeping < 0) rigidbody.sleeping = 0;
							// apply gravity
							if (rigidbody.mass > 0)
							{
								if (rigidbody.affectedByGravity)
								{
									rigidbody.vx += gravityX * timeScale / rigidbody.resting;
									rigidbody.vy += gravityY * timeScale / rigidbody.resting;
								}
							}
							else if (!rigidbody.moved)
							{
								rigidbody.vx = rigidbody.vy = rigidbody.va = 0;
							}
							else rigidbody.moved = false;
						}
						var triangle : Triangle = rigidbody as Triangle;
						if (triangle)
						{
							if (triangle._prevAngle != triangle.a)
							{
								//change in angle
								triangle._prevAngle = triangle.a;
								var cos : Number = Math.cos(triangle.a * 0.0174532925);
								var sin : Number = Math.sin(triangle.a * 0.0174532925);
								
								triangle.gx1 = cos * triangle.x1 - triangle.y1 * sin;
								triangle.gy1 = cos * triangle.y1 + triangle.x1 * sin;
								
								triangle.gx2 = cos * triangle.x2 - triangle.y2 * sin;
								triangle.gy2 = cos * triangle.y2 + triangle.x2 * sin;
								
								triangle.gx3 = cos * triangle.x3 - triangle.y3 * sin;
								triangle.gy3 = cos * triangle.y3 + triangle.x3 * sin;
								
								triangle.gn12x = cos * triangle.n12x - triangle.n12y * sin;
								triangle.gn12y = cos * triangle.n12y + triangle.n12x * sin;
								
								triangle.gn23x = cos * triangle.n23x - triangle.n23y * sin;
								triangle.gn23y = cos * triangle.n23y + triangle.n23x * sin;
								
								triangle.gn31x = cos * triangle.n31x - triangle.n31y * sin;
								triangle.gn31y = cos * triangle.n31y + triangle.n31x * sin;
							}
							if (triangle._prevAngularVelocity != triangle.va)
							{
								//change in angular velocity
								triangle._prevAngularVelocity = triangle.va;
								triangle.cos = Math.cos(triangle.va * 0.0174532925);
								triangle.sin = Math.sin(triangle.va * 0.0174532925);
							}
							if (triangle.va != 0)
							{
								cos = triangle.cos;
								sin = triangle.sin;
								
								var temp : Number = triangle.gx1;
								triangle.gx1 = cos * temp - triangle.gy1 * sin;
								triangle.gy1 = cos * triangle.gy1 + temp * sin;
								temp = triangle.gx2;
								triangle.gx2 = cos * temp - triangle.gy2 * sin;
								triangle.gy2 = cos * triangle.gy2 + temp * sin;
								temp = triangle.gx3;
								triangle.gx3 = cos * temp - triangle.gy3 * sin;
								triangle.gy3 = cos * triangle.gy3 + temp * sin;
								temp = triangle.gn12x;
								triangle.gn12x = cos * temp - triangle.gn12y * sin;
								triangle.gn12y = cos * triangle.gn12y + temp * sin;
								temp = triangle.gn23x;
								triangle.gn23x = cos * temp - triangle.gn23y * sin;
								triangle.gn23y = cos * triangle.gn23y + temp * sin;
								temp = triangle.gn31x;
								triangle.gn31x = cos * temp - triangle.gn31y * sin;
								triangle.gn31y = cos * triangle.gn31y + temp * sin;
								
								triangle._prevAngle += triangle.va * timeScale;
							}
							if (triangle.group)
							{
								body = body.next;
								continue;
							}
						}
						
						rigidbody.prevX = rigidbody.x;
						rigidbody.prevY = rigidbody.y;
						rigidbody.prevA = rigidbody.a;
						
						if (rigidbody.mass > 0)
						{
							rigidbody.vx *= 1 - rigidbody.drag * timeScale;
							rigidbody.vy *= 1 - rigidbody.drag * timeScale;
							rigidbody.va *= 1 - rigidbody.angularDrag * timeScale;
							
							var absVelocityX : Number = rigidbody.vx;
							if (absVelocityX < 0) absVelocityX = -absVelocityX;
							var absVelocityY : Number = rigidbody.vy;
							if (absVelocityY < 0) absVelocityY = -absVelocityY;
							
							if (absVelocityX > absVelocityY)
							{
								if (absVelocityX > maxVelocityX)
								{
									var delta : Number = maxVelocityX / absVelocityX;
									rigidbody.vx *= delta;
									rigidbody.vy *= delta;
								}
							}
							else if (absVelocityY > maxVelocityY)
							{
								delta = maxVelocityY / absVelocityY;
								rigidbody.vx *= delta;
								rigidbody.vy *= delta;
							}
							
							if (rigidbody.va > maxVelocityA) rigidbody.va = maxVelocityA;
							else if (rigidbody.va < -maxVelocityA) rigidbody.va = -maxVelocityA;
							
							
							rigidbody.x += rigidbody.vx * timeScale;
							rigidbody.y += rigidbody.vy * timeScale;
							rigidbody.a += rigidbody.va * timeScale;
							
							if (rigidbody.vx > 1000) rigidbody.vx = 1000;
							if (rigidbody.vx < -1000) rigidbody.vx = -1000;
							if (rigidbody.vy > 1000) rigidbody.vy = 1000;
							if (rigidbody.vy < -1000) rigidbody.vy = -1000;
							
							if (rigidbody.a > 180 || rigidbody.a < -180) rigidbody.a = ((rigidbody.a + 180) % 360) - 180;
						}
						body = body.next;
					}
				}
				if (typeCount > 1) bodies = _triangles;
				else bodies = _groups;
			}
			var lowerIndex : uint;
			var upperIndex : uint;
			
			var iterations : uint = maxIterations;
			body = _circles;
			var triangleBody : BodyNode = _triangles;
			
			while (iterations--)
			{
				//stage.graphics.lineStyle(1, 0x0000FF, ((iterations + 1) / maxIterations * 1.0));
				var nextCircles : BodyNode = null;
				var nextTriangles : BodyNode = null;
				
				for(; body; body = body.next)
				{
					
					var circle : Circle = body.body as Circle;
					
					//get bounds
					var left : Number = circle.x - circle.radius;
					var right : Number = circle.x + circle.radius;
					var top : Number = circle.y - circle.radius;
					var bottom : Number = circle.y + circle.radius;
					
					//correct position so it's inside the grid
					if (right >= _physicalWidth)
					{
						if (circle.group)
						{
							circle.group.x += _physicalWidth - circle.radius - circle.x;
						}
						circle.x = _physicalWidth - circle.radius;
						left = circle.x - circle.radius - 0.1;
						right = _physicalWidth - 0.1;
						resolveWallCollision(circle, circle.radius, 0, -1, 0, timeScale);
					}
					else if (left <= 0)
					{
						if (circle.group)
						{
							circle.group.x += circle.radius - circle.x;
						}
						circle.x = circle.radius;
						left = 0;
						right = circle.x + circle.radius;
						resolveWallCollision(circle, -circle.radius, 0, 1, 0, timeScale);
					}
					if (bottom >= _physicalHeight)
					{
						if (circle.group)
						{
							circle.group.y += _physicalHeight - circle.radius - circle.y;
						}
						circle.y = _physicalHeight - circle.radius;
						top = circle.y - circle.radius - 0.1;
						bottom = _physicalHeight - 0.1;
						resolveWallCollision(circle, 0, circle.radius, 0, -1, timeScale);
					}
					else if (top <= 0)
					{
						if (circle.group)
						{
							circle.group.y += circle.radius - circle.y;
						}
						circle.y = circle.radius;
						top = 0;
						bottom = circle.y + circle.radius;
						resolveWallCollision(circle, 0, -circle.radius, 0, 1, timeScale);
					}
					//get indexes
					lowerIndex = (left >> _unitLog2) + (top >> _unitLog2) * _width;
					upperIndex = (right >> _unitLog2) + 1 + (bottom >> _unitLog2) * _width;
					
					if (lowerIndex != circle.prevLower || upperIndex != circle.prevUpper)
					{
						var collision : Boolean = false;
						var touching : Boolean = false;
						//remove previous nodes
						for (var node : BodyNode = circle.nodes; node;)
						{
							//node.remove();
							//------ this is because of the function call bottle neck in flash -----
							if (node.next) node.next.prev = node.prev;
							if (node.prev) node.prev.next = node.next;
							else _buckets[node.index] = node.next;
							
							node.next = BodyNode.pool;
							BodyNode.pool = node;
							node = node.brother;
							
							BodyNode.pool.brother = BodyNode.pool.prev = null;
							BodyNode.pool.body = null;
							BodyNode.pool.index = uint.MAX_VALUE;
							//----------------------------------------------------------------------
						}
						circle.nodes = null;
						
						//create new nodes for circle and add to buckets
						var width : uint = (right >> _unitLog2) - (left >> _unitLog2) + 1;
						var nextRow : uint = _widthUint - width;
						var c : uint = width;
						var brother : BodyNode = null;
						var prev : AbstractRigidbody = null;
						var tileCollision : Boolean = false;
						
						for (var i : uint = lowerIndex; i < upperIndex; i++)
						{
							if (!c--)
							{
								//next row
								c = width - 1;
								if((i += nextRow) >= upperIndex) break;
							}
							//the actual add
							
							//brother = _buckets[i] = BodyNode.create(circle, _buckets[i], brother, i);
							//------ this is because of the function call bottle neck in flash -----
							if (BodyNode.pool)
							{
								var newBody : BodyNode = BodyNode.pool;
								BodyNode.pool = BodyNode.pool.next;
							}
							else
							{
								//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
								newBody = new BodyNode();
							}
							newBody.brother = brother;
							newBody.body = circle;
							newBody.next = _buckets[i];
							newBody.index = i;
							if (_buckets[i]) _buckets[i].prev = newBody;
							brother = _buckets[i] = newBody;
							node = brother;
							//-----------------------------------------------------------------------
							
							//check for collisions with tiles
							
							if (circle.layers & _tiles[i])
							{
								if (resolveCircleVsTile(circle, i, timeScale))
								{
									tileCollision = collision = true;
								}
							}
							
							for (; node.next;node = node.next )
							{
								collision = true;
								var other : AbstractRigidbody = node.next.body;
								if (other && other != prev && other.layers & circle.layers)
								{
									prev = other;
									var otherCircle : Circle = other as Circle;
									var otherTriangle : Triangle = other as Triangle;
									var contact1x:Number = NaN;
									if (otherCircle && otherCircle != circle)
									{
										var dx : Number = circle.x - otherCircle.x;
										var dy : Number = circle.y - otherCircle.y;
										var r : Number = circle.radius + otherCircle.radius;
										var distSquare : Number = dx * dx + dy * dy;
										if (distSquare <= r * r)
										{
											var length : Number;
											
											CONFIG::debug
											{
												if (distSquare < maxSize) length = sqrtTable[int(distSquare * sqrtPow)];
												else
												{
													length = Math.sqrt(distSquare);
													trace("WARNING! maxSizePromise is not large enough!!!");
												}
											}
											CONFIG::release
											{
												length = sqrtTable[int(distSquare * sqrtPow)];
											}
											var invLength : Number = 1.0 / length;
											var nx : Number = dx * invLength;
											var ny : Number = dy * invLength;
											length -= r;
											var invMass : Number = circle._mass + otherCircle._mass;
											if (invMass > 0) invMass = length / invMass
											else invMass = length;
											
											circle.x -= nx * otherCircle._mass * invMass;
											circle.y -= ny * otherCircle._mass * invMass;
											
											otherCircle.x += nx * circle._mass * invMass;
											otherCircle.y += ny * circle._mass * invMass;
											
											invMass = length * (circle._invMass + otherCircle._invMass);
											
											contact1x = nx * otherCircle._mass * invMass;
											var contact1y:Number = ny * otherCircle._mass * invMass;
											var contact2x:Number = nx * circle._mass * invMass;
											var contact2y:Number = ny * circle._mass * invMass;
										}
										else if (circle.vanDerWaals + otherCircle.vanDerWaals)
										{
											invMass = (circle.vanDerWaals + otherCircle.vanDerWaals) / (circle._mass + otherCircle._mass);
											length = Math.sqrt(distSquare);
											invLength = 2 / (length * length + length);
											nx = dx * invLength;
											ny = dy * invLength;
											
											circle.vx -= nx * otherCircle._mass * invMass;
											circle.vy -= ny * otherCircle._mass * invMass;
											
											otherCircle.vx += nx * circle._mass * invMass;
											otherCircle.vy += ny * circle._mass * invMass;
										}
									}
									else if (otherTriangle)
									{
										resolveTriangleVsCircle(otherTriangle, circle, timeScale);
										if (colInfo)
										{
											contact1x = colInfo[0] - circle.x;
											contact1y = colInfo[1] - circle.y;
											contact2x = colInfo[0] - otherTriangle.x;
											contact2y = colInfo[1] - otherTriangle.y;
											nx = colInfo[2];
											ny = colInfo[3];
										}
									}
									if (!isNaN(contact1x))
									{
										touching = true;
										resolveCollision(circle, other, contact1x, contact1y, contact2x, contact2y, nx, ny, timeScale);
									}
								}
							}
						}
						circle.nodes = brother;
						if (!collision)
						{
							circle.prevLower = lowerIndex;
							circle.prevUpper = upperIndex;
						}
						if (!tileCollision)
						{
							circle.lastX = circle.x;
							circle.lastY = circle.y;
						}
						if (!touching)
						{
							circle.resting += (1 - circle.resting) * timeScale * 0.5;
						}
					}
					if (iterations && collision)
					{
						if (BodyNode.pool)
						{
							newBody = BodyNode.pool;
							BodyNode.pool = BodyNode.pool.next;
						}
						else
						{
							//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
							newBody = new BodyNode();
						}
						newBody.body = circle;
						newBody.next = nextCircles;
						nextCircles = newBody;
					}
				}
				
				
				for(body = triangleBody; body; body = body.next)
				{
					if(!body.body) continue;
					triangle = body.body as Triangle;
					
					//get bounds
					left = triangle.x + Math.min(triangle.gx1, triangle.gx2, triangle.gx3);
					right = triangle.x + Math.max(triangle.gx1, triangle.gx2, triangle.gx3);
					top = triangle.y + Math.min(triangle.gy1, triangle.gy2, triangle.gy3);
					bottom = triangle.y + Math.max(triangle.gy1, triangle.gy2, triangle.gy3);
					
					nx = 0;
					ny = 0;
					
					//correct position so it's inside the grid
					if (right >= _physicalWidth)
					{
						if (triangle.group)
						{
							triangle.group.x -= right - _physicalWidth;
						}
						triangle.x -= right - _physicalWidth;
						left -= (right + 0.1) - _physicalWidth;
						right -= (right + 0.1) - _physicalWidth;
						nx = -1;
					}
					else if (left < 0)
					{
						if (triangle.group)
						{
							triangle.group.x -= left;
						}
						triangle.x -= left;
						right -= left;
						left -= left;
						nx = 1;
					}
					if (bottom >= _physicalHeight)
					{
						if (triangle.group)
						{
							triangle.group.y -= bottom - _physicalHeight;
						}
						triangle.y -= bottom - _physicalHeight;
						top -= (bottom + 0.1) - _physicalHeight;
						bottom -= (bottom + 0.1) - _physicalHeight;
						ny = -1
					}
					else if (top < 0)
					{
						if (triangle.group)
						{
							triangle.group.y -= top;
						}
						triangle.y -= top;
						bottom -= top;
						top -= top;
						ny = 1;
					}
					if (nx || ny)
					{
						if (nx < 0)
						{
							if (triangle.gx1 > triangle.gx2 && triangle.gx1 > triangle.gx3) var pos : Number = triangle.gy1;
							else if (triangle.gx2 > triangle.gx3) pos = triangle.gy2;
							else pos = triangle.gy3;
							resolveWallCollision(triangle, right - triangle.x, pos, -1, 0, timeScale);
						}
						else if (nx > 0)
						{
							if (triangle.gx1 < triangle.gx2 && triangle.gx1 < triangle.gx3) pos = triangle.gy1;
							else if (triangle.gx2 < triangle.gx3) pos = triangle.gy2;
							else pos = triangle.gy3;
							resolveWallCollision(triangle, left - triangle.x, pos, 1, 0, timeScale);
						}
						if (ny < 0)
						{
							if (triangle.gy1 > triangle.gy2 && triangle.gy1 > triangle.gy3) pos = triangle.gx1;
							else if (triangle.gy2 > triangle.gy3) pos = triangle.gx2;
							else pos = triangle.gx3;
							resolveWallCollision(triangle, pos, bottom - triangle.y, 0, -1, timeScale);
						}
						else if (ny > 0)
						{
							if (triangle.gy1 < triangle.gy2 && triangle.gy1 < triangle.gy3) pos = triangle.gx1;
							else if (triangle.gy2 < triangle.gy3) pos = triangle.gx2;
							else pos = triangle.gx3;
							resolveWallCollision(triangle, pos, top - triangle.y, 0, 1, timeScale);
						}
					}
					
					//get indexes
					lowerIndex = (left >> _unitLog2) + (top >> _unitLog2) * _width;
					upperIndex = (right >> _unitLog2) + 1 + (bottom >> _unitLog2) * _width;
					if (upperIndex > _length) upperIndex = _length;
					
					if ((triangle.vx || triangle.vy || triangle.va) && (lowerIndex != triangle.prevLower || upperIndex != triangle.prevUpper))
					{
						
						collision = false;
						touching = false;
						
						//remove previous nodes
						for (node = triangle.nodes; node;)
						{
							//node.remove();
							//------ this is because of the function call bottle neck in flash -----
							if (node.next) node.next.prev = node.prev;
							if (node.prev) node.prev.next = node.next;
							else _buckets[node.index] = node.next;
							
							node.next = BodyNode.pool;
							BodyNode.pool = node;
							node = node.brother;
							
							BodyNode.pool.brother = BodyNode.pool.prev = null;
							BodyNode.pool.body = null;
							BodyNode.pool.index = uint.MAX_VALUE;
							//----------------------------------------------------------------------
						}
						triangle.nodes = null;
						
						//create new nodes for triangle and add to buckets
						width = (right >> _unitLog2) - (left >> _unitLog2) + 1;
						nextRow = _widthUint - width;
						c = width;
						brother = null;
						prev = null;
						tileCollision = false;
						
						for (i = lowerIndex; i < upperIndex; i++)
						{
							if (!c--)
							{
								//next row
								c = width - 1;
								if((i += nextRow) >= upperIndex) break;
							}
							//the actual add
							
							//brother = _buckets[i] = BodyNode.create(triangle, _buckets[i], brother, i);
							//------ this is because of the function call bottle neck in flash -----
							if (BodyNode.pool)
							{
								newBody = BodyNode.pool;
								BodyNode.pool = BodyNode.pool.next;
							}
							else
							{
								//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
								newBody = new BodyNode();
							}
							newBody.brother = brother;
							newBody.body = triangle;
							newBody.next = _buckets[i];
							newBody.index = i;
							if (_buckets[i]) _buckets[i].prev = newBody;
							brother = _buckets[i] = newBody;
							node = brother;
							//-----------------------------------------------------------------------
							
							//check for collisions with tiles
							
							if (triangle.layers & _tiles[i])
							{
								collision = true;
								tileCollision ||= resolveTriangleVsTile(triangle, i, timeScale);
							}
							
							//check for collisions with other rigidbodies
							for (; node.next;node = node.next )
							{
								collision = true;
								other = node.next.body;
								if (other && other != prev)
								{
									prev = other;
									otherCircle = other as Circle;
									otherTriangle = other as Triangle;
									contact1x = NaN;
									
									if (otherCircle)
									{
										resolveTriangleVsCircle(triangle,otherCircle, timeScale);
										if (colInfo)
										{
											contact1x = colInfo[0] - triangle.x;
											contact1y = colInfo[1] - triangle.y;
											contact2x = colInfo[0] - other.x;
											contact2y = colInfo[1] - other.y;
											nx = colInfo[2];
											ny = colInfo[3];
										}
									}
									else if (otherTriangle && otherTriangle != triangle)
									{
										resolveTriangles(triangle, otherTriangle, timeScale);
										if (colInfo)
										{
											//the other triangle is sleeping, let's wake it up											
											contact1x = colInfo[0] - triangle.x;
											contact1y = colInfo[1] - triangle.y;
											contact2x = colInfo[0] - other.x;
											contact2y = colInfo[1] - other.y;
											nx = colInfo[2];
											ny = colInfo[3];
										}
									}
									if (!isNaN(contact1x))
									{
										touching = true;
										/*
										stage.graphics.beginFill(0x00FF00);
										stage.graphics.drawCircle(contact1x + triangle.x, contact1y + triangle.y, 4);
										stage.graphics.endFill();
										*/
										if(other.mass > 0) resolveCollision(triangle, other, contact1x, contact1y, contact2x, contact2y, nx, ny, timeScale);
										else resolveWallCollision(triangle, contact1x, contact1y, -nx, -ny, timeScale);
									}
								}
							}
						}
						triangle.nodes = brother;
						if (!collision)
						{
							triangle.prevLower = lowerIndex;
							triangle.prevUpper = upperIndex;
						}
						if (!tileCollision)
						{
							triangle.lastX = triangle.x;
							triangle.lastY = triangle.y;
						}
						if (!touching)
						{
							triangle.resting += (1 - triangle.resting) * timeScale * 0.5;
						}
					}
					if (iterations && collision)
					{
						if (BodyNode.pool)
						{
							newBody = BodyNode.pool;
							BodyNode.pool = BodyNode.pool.next;
						}
						else
						{
							//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
							newBody = new BodyNode();
						}
						newBody.body = triangle;
						newBody.next = nextTriangles;
						nextTriangles = newBody;
					}
					if (triangle.group) triangle.group.contacts;
				}
				for(body = _groups; body; body = body.next)
				{
					var group : Group = body.body as Group;
					group.cos = Math.cos(group.a * 0.0174532925);
					group.sin = Math.sin(group.a * 0.0174532925);
					group.syncBodies();
				}
				
				
				if (!nextCircles && !nextTriangles)
				{
					break;
				}
				
				body = nextCircles;
				triangleBody = nextTriangles;
				
				//Contact.removeOldContacts();
				/*
				for (contact = Contact._head; contact; contact = contact._nextPoint)
				{
					stage.graphics.beginFill(0x00FF00);
					stage.graphics.drawCircle(contact.x, contact.y, 2);
					stage.graphics.endFill();
					
					stage.graphics.lineStyle(0, 0x00FF00);
					stage.graphics.moveTo(contact.thisBody.x, contact.thisBody.y);
					stage.graphics.lineTo(contact.x, contact.y);
					
					stage.graphics.lineStyle(0, 0x0000FF);
					stage.graphics.moveTo(contact.other.thisBody.x, contact.other.thisBody.y);
					stage.graphics.lineTo(contact.x, contact.y);
				}
				*/
			}
			Contact.removeOldContacts();
		}
		private static function resolveWallCollision(
			body : AbstractRigidbody,
			contactx : Number, contacty : Number,
			nx : Number, ny : Number, timeScale : Number, staticBody : AbstractRigidbody = null) : void
		{
			var original : AbstractRigidbody = body;
			var originalStatic : AbstractRigidbody = staticBody;
			
			if (!staticBody)
			{
				if (ny > 0) var wall : AbstractRigidbody = _wallTop;
				else if (ny < 0) wall = _wallBottom;
				else if (nx > 0) wall = _wallLeft;
				else if (nx < 0) wall = _wallRight;
				else wall = null;
			}
			else
			{
				wall = null;
				if (staticBody.group)
				{
					staticBody = staticBody.group;
				}
			}
			
			if (!nx && !ny) ny = 1;
			if (nx * gravityX + ny * gravityY < 0) body.resting += timeScale * restingSpeed;
			if (body.group)
			{
				body.group.syncBodies();
				body = body.group;
			}
			var invMass : Number = body._invMass;
			var invInertia : Number = body._invInertia;
			
			var len : Number = 1 / Math.sqrt(contactx * contactx + contacty * contacty);
			var contactPerpNorm : Number = contactx * len * ny - contacty * len * nx;
			
			var impulseDenominator : Number = 1 + contactPerpNorm * contactPerpNorm * invInertia;
			
			var velocityAtContactx : Number = body.vx - contacty * body.va * 0.0174532925;
			var velocityAtContacty : Number = body.vy + contactx * body.va * 0.0174532925;
			if (staticBody)
			{
				// changing the velocityAtContact to a relative velocity
				velocityAtContactx -= staticBody.vx + (contacty + body.y - staticBody.y) * staticBody.va * 0.0174532925;
				velocityAtContacty -= staticBody.vy + (contactx + body.x - staticBody.x) * staticBody.va * 0.0174532925;
			}
			var rvNorm : Number = nx * velocityAtContactx + ny * velocityAtContacty;
			
			var impulse : Number = (originalStatic ? originalStatic.bounciness  + original.bounciness * 0.5 : original.bounciness);
			if (velocityAtContactx * velocityAtContactx + velocityAtContacty * velocityAtContacty < 2) impulse = 0;
			impulse = -( 1 + impulse) * rvNorm / impulseDenominator;
			
			var dlv1x : Number = nx * impulse;
			var dlv1y : Number = ny * impulse;
			var dav1 : Number = contactPerpNorm * impulse * invInertia;
			
			/***** frictional impulse *****/
			
			var contactPerpTangent : Number = nx * contactx * len + ny * contacty * len;
			
			impulseDenominator = 1 + contactPerpTangent * contactPerpTangent * invInertia;
			
			rvNorm = -ny * velocityAtContactx + nx * velocityAtContacty;
			
			impulse = -(rvNorm / impulseDenominator) * (originalStatic ? original.friction * originalStatic.friction : original.friction);
			
			dlv1x -= ny * impulse;
			dlv1y += nx * impulse;
			dav1 += contactPerpTangent * impulse * invInertia;
			
			body.vx += dlv1x;
			body.vy += dlv1y;
			body.va += dav1;
			
			body.va *= 1 - body.angularDragOnCollision * timeScale;
			
			if(wall) Contact.makeContact(contactx + body.x, contacty + body.y, nx, ny, original, wall);
		}
		private static function resolveCollision(
			first : AbstractRigidbody, second : AbstractRigidbody,
			contact1x : Number, contact1y : Number,
			contact2x : Number, contact2y : Number,
			nx : Number, ny : Number, timeScale : Number) : void
		{
			if (!(nx & ny)) ny = 1;
			
			var originalFirst : AbstractRigidbody = first;
			var originalSecond : AbstractRigidbody = second;
			
			var restingAmount : Number = (first.x - second.x) * gravityX + (first.y - second.y) * gravityY;
			if (restingAmount > 0) first.resting += timeScale * restingSpeed * restingAmount;
			else second.resting -= timeScale * restingSpeed * restingAmount;
			
			if (first.group)
			{
				first.group.syncBodies();
				first = first.group;
			}
			if (second.group)
			{
				second.group.syncBodies();
				second = second.group;
			}
			
			var dx : Number = first.x - first.prevX;
			var dy : Number = first.y - first.prevY;
			first.sleepTotalPenetration += dx * dx + dy * dy;
			dx = second.x - second.prevX;
			dy = second.y - second.prevY;
			second.sleepTotalPenetration += dx * dx + dy * dy;
			if (Contact.makeContact(first.x + contact1x, first.y + contact1y, nx, ny, originalFirst, originalSecond) || first.sleepTotalPenetration > minPenetration * minPenetration || second.sleepTotalPenetration > minPenetration * minPenetration)
			{
				if (first.sleeping > sleepTime && first.sleepTotalPenetration > minPenetration * minPenetration)
				{
					first.wakeUp();
				}
				if (second.sleeping > sleepTime && second.sleepTotalPenetration > minPenetration * minPenetration)
				{
					second.wakeUp();
				}
			}
			else if(first.sleeping > sleepTime && second.sleeping < sleepTime)
			{
				second.vx = second.vy = second.va = 0;
				return;
			}
			else if(second.sleeping > sleepTime && first.sleeping < sleepTime)
			{
				first.vx = first.vy = first.va = 0;
				return;
			}
			
			if (first._mass == 0)//is the first one static?
			{
				resolveWallCollision(originalSecond, contact2x, contact2y, nx, ny, timeScale, originalFirst);
				return;
			}
			else if (second._mass == 0)//is the second one static?
			{
				resolveWallCollision(originalFirst, contact1x, contact1y, -nx, -ny, timeScale, originalSecond);
				return;
			}
			
			var invMass1 : Number = first._invMass;
			var invMass2 : Number = second._invMass;
			var invInertia1 : Number = first._invInertia;
			var invInertia2 : Number = second._invInertia;
			
			var invMass : Number = invMass1 + invMass2;
			
			var contactPerpNorm1 : Number = -contact1y * nx + contact1x * ny;
			var contactPerpNorm2 : Number = -contact2y * nx + contact2x * ny;
			
			var impulseDenominator : Number = nx * nx * invMass + ny * ny * invMass;
			impulseDenominator += contactPerpNorm1 * contactPerpNorm1 * invInertia1;
			impulseDenominator += contactPerpNorm2 * contactPerpNorm2 * invInertia2;
			
			var velocityAtContact1x : Number = -contact1y * first.va * 0.0174532925 + first.vx;
			var velocityAtContact1y : Number = contact1x * first.va * 0.0174532925 + first.vy;
			var velocityAtContact2x : Number = -contact2y * second.va * 0.0174532925 + second.vx;
			var velocityAtContact2y : Number = contact2x * second.va * 0.0174532925 + second.vy;
			
			var relativeVelocityX : Number = velocityAtContact1x - velocityAtContact2x;
			var relativeVelocityY : Number = velocityAtContact1y - velocityAtContact2y;
			
			var rvNorm : Number = nx * relativeVelocityX + ny * relativeVelocityY;
			
			var impulse : Number = (originalFirst.bounciness + originalSecond.bounciness) * 0.5;
			if (relativeVelocityX * relativeVelocityX + relativeVelocityY * relativeVelocityY < 2) impulse = 0;
			impulse = -( 1 + impulse ) * rvNorm / impulseDenominator;
			
			var dlv1x : Number = nx * impulse * invMass1;
			var dlv1y : Number = ny * impulse * invMass1;
			var dav1 : Number = (contact1x * ny - contact1y * nx) * impulse * invInertia1;
			
			var dlv2x : Number = nx * (-impulse) * invMass2;
			var dlv2y : Number = ny * (-impulse) * invMass2;
			var dav2 : Number = -(contact2x * ny - contact2y * nx) * impulse * invInertia2;
			
			
			/***** frictional impulse *****/
			
			
			var contactPerpTangent1 : Number = ny * contact1y + nx * contact1x;
			var contactPerpTangent2 : Number = ny * contact2y + nx * contact2x;
			
			impulseDenominator = nx * nx * invMass + ny * ny * invMass;
			impulseDenominator += contactPerpTangent1 * contactPerpTangent1 * invInertia1;
			impulseDenominator += contactPerpTangent2 * contactPerpTangent2 * invInertia2;
			
			impulse = -((-ny * relativeVelocityX + nx * relativeVelocityY) / impulseDenominator) * originalFirst.friction * originalSecond.friction;
			
			dlv1x -= ny * impulse * invMass1;
			dlv1y += nx * impulse * invMass1;
			dav1 += (-contact1y * -ny * impulse + contact1x * nx * impulse) * invInertia1;
			
			dlv2x -= ny * (-impulse) * invMass2;
			dlv2y += nx * (-impulse) * invMass2;
			dav2 += ( -contact2y * -ny * ( -impulse) + contact2x * nx * ( -impulse)) * invInertia2;
			
			if (first.sleeping < sleepTime && first.mass > 0.0)
			{
				first.vx += dlv1x;
				first.vy += dlv1y;
				first.va += dav1;
				first.va *= 1 - first.angularDragOnCollision * timeScale;
			}
			
			if (second.sleeping < sleepTime && second.mass > 0.0)
			{
				second.vx += dlv2x;
				second.vy += dlv2y;
				second.va += dav2;
				second.va *= 1 - second.angularDragOnCollision * timeScale;
			}
		}
		private static function resolveCircleVsTile(circle : Circle, tile : uint, timeScale : Number) : Boolean
		{
			var unit : uint = 1 << _unitLog2;
			var tileX : uint = tile % _widthUint;
			var tileY : uint = tile / _widthUint;
			var tileLeft : Number = tileX * unit;
			var tileTop : Number = tileY * unit;
			var tileRight : Number = tileLeft + unit;
			var tileBottom : Number = tileTop + unit;
			
			var onLeftBound : Boolean = tileX <= 0;
			var onRightBound : Boolean = tileX >= _widthUint - 1;
			var onTopBound : Boolean = tileY <= 0;
			var onBottomBound : Boolean = tile + _widthUint >= _length;
			
			var tileOnLeft : uint = (onLeftBound ? uint.MAX_VALUE : (onRightBound ? 0 : _tiles[tile-1])) & circle.layers;
			var tileOnRight : uint = (onRightBound ? uint.MAX_VALUE : (onLeftBound ? 0 : _tiles[tile+1])) & circle.layers;
			var tileOnTop : uint = (onTopBound ? uint.MAX_VALUE : (onBottomBound ? 0 : _tiles[tile-_widthUint])) & circle.layers;
			var tileOnBottom : uint = (onBottomBound ? uint.MAX_VALUE : (onTopBound ? 0 : _tiles[tile + _widthUint])) & circle.layers;
			
			var dx : Number = (tileLeft + tileRight) * 0.5 - circle.x;
			var dy : Number = (tileTop + tileBottom) * 0.5 - circle.y;
			
			if ((dx > 0 ? tileOnLeft : tileOnRight) && (dy > 0 ? tileOnTop : tileOnBottom))
			{
				if (circle.group)
				{
					circle.group.x += circle.lastX - circle.x;
					circle.group.y += circle.lastY - circle.y;
				}
				else
				{
					circle.x = circle.lastX;
					circle.y = circle.lastY;
					//circle.vx = circle.vy = 0;
				}
				return true;
			}
			
			
			var posX : Number = circle.x;
			var posY : Number = circle.y;
			var radius : Number = circle.radius;
			
			if (posX + radius >= tileLeft && posX - radius <= tileRight && posY + radius >= tileTop && posY - radius <= tileBottom)
			{
				var prevX : Number = circle.prevX;
				var prevY : Number = circle.prevY;
				var colX : Number = posX, colY : Number = posY
				var doSide : Boolean = !(dx > 0 ? tileOnLeft : tileOnRight) && (dy > 0 ? tileOnTop : tileOnBottom);
				
				if ((doSide && tileOnTop && tileOnBottom) || (!doSide && tileOnLeft && tileOnBottom) || (prevX + radius <= tileLeft || prevX - radius >= tileRight || prevY + radius <= tileTop || prevY - radius >= tileBottom))
				{
					//can calculate time of impact.
					dx = posX - prevX;
					dy = posY - prevY;
					if (!doSide)
					{
						if (dy > 0 && !tileOnTop)//falling down meaning it crosses tileTop
						{
							var toi : Number = (tileTop - (prevY + radius)) / dy;
							colX = prevX + dx * toi;
							if ((tileOnLeft || colX >= tileLeft) && (tileOnRight || colX <= tileRight))//colliding with top
							{
								circle.x = colX;
								circle.y = tileTop - radius;
								resolveWallCollision(circle, 0, radius, 0, -1, timeScale);
								circle.prevX = circle.x += dx * (1 - toi);
								circle.prevY = circle.y -= dy * (1 - toi);
								circle.prevA = circle.a;
								return true;
							}
						}
						else if (!tileOnBottom)//rising up meaning it crosses tileBottom
						{
							toi = (tileBottom - (prevY - radius)) / dy;
							colX = prevX + dx * toi;
							if ((tileOnLeft || colX >= tileLeft) && (tileOnRight || colX <= tileRight))//colliding with bottom
							{
								circle.x = colX;
								circle.y = tileBottom + radius;
								resolveWallCollision(circle, 0, -radius, 0, 1, timeScale);
								circle.prevX = circle.x += dx * (1 - toi);
								circle.prevY = circle.y -= dy * (1 - toi);
								circle.prevA = circle.a;
								return true;
							}
						}
					}
					else
					{
						if (dx > 0 && !tileOnLeft)//going right meaning it crosses tileLeft
						{
							toi = (tileLeft - (prevX + radius)) / dx;
							colY = prevY + dy * toi;
							if ((tileOnTop || colY >= tileTop) && (tileOnBottom || colY <= tileBottom))//colliding with left
							{
								circle.x = tileLeft - radius;
								circle.y = colY;
								resolveWallCollision(circle, radius, 0, -1, 0, timeScale);
								circle.prevX = circle.x -= dx * (1 - toi);
								circle.prevY = circle.y += dy * (1 - toi);
								circle.prevA = circle.a;
								return true;
							}
						}
						else if(!tileOnRight)//going left meaning it crosses tileRight
						{
							toi = (tileRight - (prevX - radius)) / dx;
							colY = prevY + dy * toi;
							if ((tileOnTop || colY >= tileTop) && (tileOnBottom || colY <= tileBottom))//colliding with left
							{
								circle.x = tileRight + radius;
								circle.y = colY;
								resolveWallCollision(circle, -radius, 0, 1, 0, timeScale);
								circle.prevX = circle.x -= dx * (1 - toi);
								circle.prevY = circle.y += dy * (1 - toi);
								circle.prevA = circle.a;
								return true;
							}
						}
					}
					return false;
				}
				// time of impact is not possible or it's colliding with a corner
				
				if (posX < tileLeft) colX = tileLeft
				else if (posX > tileRight) colX = tileRight;
				
				if (posY < tileTop) colY = tileTop;
				else if (posY > tileBottom) colY = tileBottom;
				
				if (colX == posX && colY == posY || (doSide && (tileOnTop && tileOnBottom)) || (doSide && (tileOnLeft && tileOnRight)))
				{	
					//circle's center is inside the tile OR it's NOT touching a corner
					
					colX = tileLeft; colY = tileTop;
					if (dx < 0) colX = tileRight;
					if (dy < 0) colY = tileBottom;
					
					if (doSide)
					{
						resolveWallCollision(circle, 0, colY - posY, dx < 0 ? 1 : -1, 0, timeScale);
					}
					else
					{
						resolveWallCollision(circle, colX - posX, 0, 0, dy < 0 ? 1 : -1, timeScale);
					}
					return true;
				}
				
				if (colX && colY && !(colX == posX && colY == posY))
				{
					//the circle is touching corners
					dx = posX - colX; dy = posY - colY;
					var dist : Number = Math.sqrt(dx * dx + dy * dy);
					var invDist : Number = 1 / dist;
					dx *= invDist; dy *= invDist;
					
					circle.x += dx * (radius - dist);
					circle.y += dy * (radius - dist);
					
					resolveWallCollision(circle, colX - posX, colY - posY, -dx, -dy, timeScale);
					
					return true;
				}
			}
			return false;
		}
		private static function resolveTriangleVsTile(triangle : Triangle, tile : uint, timeScale : Number) : Boolean
		{
			var unit : uint = 1 << _unitLog2;
			var tileX : uint = tile % _widthUint;
			var tileY : uint = tile / _widthUint;
			var tileLeft : Number = tileX * unit;
			var tileTop : Number = tileY * unit;
			var tileRight : Number = tileLeft + unit;
			var tileBottom : Number = tileTop + unit;
			
			var onLeftBound : Boolean = tileX <= 0;
			var onRightBound : Boolean = tileX >= _widthUint - 1;
			var onTopBound : Boolean = tileY <= 0;
			var onBottomBound : Boolean = tile + _widthUint >= _length;
			
			var tileOnLeft : uint = (onLeftBound ? uint.MAX_VALUE : (onRightBound ? 0 : _tiles[tile-1])) & triangle.layers;
			var tileOnRight : uint = (onRightBound ? uint.MAX_VALUE : (onLeftBound ? 0 : _tiles[tile+1])) & triangle.layers;
			var tileOnTop : uint = (onTopBound ? uint.MAX_VALUE : (onBottomBound ? 0 : _tiles[tile-_widthUint])) & triangle.layers;
			var tileOnBottom : uint = (onBottomBound ? uint.MAX_VALUE : (onTopBound ? 0 : _tiles[tile + _widthUint])) & triangle.layers;
			
			
			var dx : Number = (tileLeft + tileRight) * 0.5 - triangle.x;
			var dy : Number = (tileTop + tileBottom) * 0.5 - triangle.y;
			
			if ((dx > 0 ? tileOnLeft : tileOnRight) && (dy > 0 ? tileOnTop : tileOnBottom))
			{
				if (triangle.group)
				{
					triangle.group.x += triangle.lastX - triangle.x;
					triangle.group.y += triangle.lastY - triangle.y;
				}
				else
				{
					triangle.x = triangle.lastX;
					triangle.y = triangle.lastY;
				}
				return true;
			}
			
			var p1x : Number = triangle.gx1 + triangle.x;
			var p1y : Number = triangle.gy1 + triangle.y;
			var p2x : Number = triangle.gx2 + triangle.x;
			var p2y : Number = triangle.gy2 + triangle.y;
			var p3x : Number = triangle.gx3 + triangle.x;
			var p3y : Number = triangle.gy3 + triangle.y;
			
			var doSide : Boolean = !(dx > 0 ? tileOnLeft : tileOnRight) && (dy > 0 ? tileOnTop : tileOnBottom);
			
			if (doSide)
			{
				if (dx > 0)
				{
					if(p1x < tileLeft && p2x < tileLeft && p3x < tileLeft) return false;
				}
				else if(p1x > tileRight && p2x > tileRight && p3x > tileRight) return false;
			}
			else
			{
				if (dy > 0)
				{
					if(p1y < tileTop && p2y < tileTop && p3y < tileTop) return false;
				}
				else if(p1y > tileBottom && p2y > tileBottom && p3y > tileBottom) return false;
			}
			
			var moveX : Number = 0, moveY : Number = 0, move : Number = Number.NEGATIVE_INFINITY;
			var axisX : Number = 0, axisY : Number = 0;
			var pointX : Number = 0, pointY : Number = 0;
			
			var absDx : Number = dx > 0 ? dx : -dx;
			var absDy : Number = dy > 0 ? dy : -dy;
			
			
			if (p1x > tileLeft && p1x <= tileRight && p1y >= tileTop && p1y <= tileBottom)
			{
				var colX : Number = tileLeft, colY : Number = tileTop;
				if (dx < 0) colX = tileRight;
				if (dy < 0) colY = tileBottom;
				
				var currentMoveX : Number = colX - p1x, currentMoveY : Number = colY - p1y;
				if (currentMoveX < 0) currentMoveX = -currentMoveX;
				if (currentMoveY < 0) currentMoveY = -currentMoveY;
				
				if (absDx > absDy && currentMoveX > move && doSide)
				{
					move = currentMoveX;
					moveX = colX - p1x;
					moveY = axisY = 0; axisX = colX >= p1x ? 1 : -1;
					pointX = p1x; pointY = p1y;
				}
				else if(currentMoveY > move && !doSide)
				{
					move = currentMoveY;
					moveY = colY - p1y;
					moveX = axisX = 0; axisY = colY >= p1y ? 1 : -1;
					pointX = p1x; pointY = p1y;
				}
			}
			if (p2x > tileLeft && p2x <= tileRight && p2y >= tileTop && p2y <= tileBottom)
			{
				colX = tileLeft; colY = tileTop;
				if (dx < 0) colX = tileRight;
				if (dy < 0) colY = tileBottom;
				
				currentMoveX = colX - p2x; currentMoveY = colY - p2y;
				if (currentMoveX < 0) currentMoveX = -currentMoveX;
				if (currentMoveY < 0) currentMoveY = -currentMoveY;
				
				if (absDx > absDy && currentMoveX > move && doSide)
				{
					move = currentMoveX;
					moveX = colX - p2x;
					moveY = axisY = 0; axisX = colX >= p2x ? 1 : -1;
					pointX = p2x; pointY = p2y;
				}
				else if (currentMoveY > move && !doSide)
				{
					move = currentMoveY;
					moveY = colY - p2y;
					moveX = axisX = 0; axisY = colY >= p2y ? 1 : -1;
					pointX = p2x; pointY = p2y;
				}
			}
			if (p3x > tileLeft && p3x <= tileRight && p3y >= tileTop && p3y <= tileBottom)
			{
				colX = tileLeft; colY = tileTop;
				if (dx < 0) colX = tileRight;
				if (dy < 0) colY = tileBottom;
				
				currentMoveX = colX - p3x; currentMoveY = colY - p3y;
				if (currentMoveX < 0) currentMoveX = -currentMoveX;
				if (currentMoveY < 0) currentMoveY = -currentMoveY;
				
				if (absDx > absDy && currentMoveX > move && doSide)
				{
					move = currentMoveX;
					moveX = colX - p3x;
					moveY = axisY = 0; axisX = colX >= p3x ? 1 : -1;
					pointX = p3x; pointY = p3y;
				}
				else if (currentMoveY > move && !doSide)
				{
					if ((triangle.group || triangle).vy < -50)
					{
						var n : Number = 5;
					}
					move = currentMoveY;
					moveY = colY - p3y;
					moveX = axisX = 0; axisY = colY >= p3y ? 1 : -1;
					pointX = p3x; pointY = p3y;
				}
			}
			
			if (move == -Infinity)
			{
				
				var left : Number = tileLeft - triangle.x;
				var right : Number = tileRight - triangle.x;
				var top : Number = tileTop - triangle.y;
				var bottom : Number = tileBottom - triangle.y;
				
				var dot1a : Number = triangle.gn12x * left + triangle.gn12y * top - triangle.n12d;
				var dot2a : Number = triangle.gn23x * left + triangle.gn23y * top - triangle.n23d;
				var dot3a : Number = triangle.gn31x * left + triangle.gn31y * top - triangle.n31d;
				
				var dot1b : Number = triangle.gn12x * right + triangle.gn12y * top - triangle.n12d;
				var dot2b : Number = triangle.gn23x * right + triangle.gn23y * top - triangle.n23d;
				var dot3b : Number = triangle.gn31x * right + triangle.gn31y * top - triangle.n31d;
				
				var dot1c : Number = triangle.gn12x * left + triangle.gn12y * bottom - triangle.n12d;
				var dot2c : Number = triangle.gn23x * left + triangle.gn23y * bottom - triangle.n23d;
				var dot3c : Number = triangle.gn31x * left + triangle.gn31y * bottom - triangle.n31d;
				
				var dot1d : Number = triangle.gn12x * right + triangle.gn12y * bottom - triangle.n12d;
				var dot2d : Number = triangle.gn23x * right + triangle.gn23y * bottom - triangle.n23d;
				var dot3d : Number = triangle.gn31x * right + triangle.gn31y * bottom - triangle.n31d;
				
				var aInside : Boolean = dot1a < 0 && dot2a < 0 && dot3a < 0;
				var bInside : Boolean = dot1b < 0 && dot2b < 0 && dot3b < 0;
				var cInside : Boolean = dot1c < 0 && dot2c < 0 && dot3c < 0;
				var dInside : Boolean = dot1d < 0 && dot2d < 0 && dot3d < 0;
				
				//if (move == -Infinity && !(aInside || bInside || cInside || dInside)) return false;
				if (dot1a > 0 && dot1b > 0 && dot1c > 0 && dot1d > 0) return false;
				if (dot2a > 0 && dot2b > 0 && dot2c > 0 && dot2d > 0) return false;
				if (dot3a > 0 && dot3b > 0 && dot3c > 0 && dot3d > 0) return false;
				
				
				if (dot1a < dot1b && dot1a < dot1c && dot1a < dot1d)
				{
					if (dot1a > move && aInside)
					{
						axisX = -triangle.gn12x; axisY = -triangle.gn12y; move = dot1a;
						pointX = tileLeft; pointY = tileTop; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot1b < dot1c && dot1b < dot1d)
				{
					if (dot1b > move && bInside)
					{
						axisX = -triangle.gn12x; axisY = -triangle.gn12y; move = dot1b;
						pointX = tileRight; pointY = tileTop; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot1c < dot1d)
				{
					if (dot1c > move && cInside)
					{
						axisX = -triangle.gn12x; axisY = -triangle.gn12y; move = dot1c;
						pointX = tileLeft; pointY = tileBottom; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot1d > move && dInside)
				{
					axisX = -triangle.gn12x; axisY = -triangle.gn12y; move = dot1d;
					pointX = tileRight; pointY = tileBottom; moveX = -axisX * move; moveY = -axisY * move;
				}
				
				
				if (dot2a < dot2b && dot2a < dot2c && dot2a < dot2d)
				{
					if (dot2a > move && aInside)
					{
						axisX = -triangle.gn23x; axisY = -triangle.gn23y; move = dot2a;
						pointX = tileLeft; pointY = tileTop; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot2b < dot2c && dot2b < dot2d)
				{
					if (dot2b > move && bInside)
					{
						axisX = -triangle.gn23x; axisY = -triangle.gn23y; move = dot2b;
						pointX = tileRight; pointY = tileTop; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot2c < dot2d)
				{
					if (dot2c > move && cInside)
					{
						axisX = -triangle.gn23x; axisY = -triangle.gn23y; move = dot2c;
						pointX = tileLeft; pointY = tileBottom; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot2d > move && dInside)
				{
					axisX = -triangle.gn23x; axisY = -triangle.gn23y; move = dot2d;
					pointX = tileRight; pointY = tileBottom; moveX = -axisX * move; moveY = -axisY * move;
				}
				
				
				if (dot3a < dot3b && dot3a < dot3c && dot3a < dot3d)
				{
					if (dot3a > move && aInside)
					{
						axisX = -triangle.gn31x; axisY = -triangle.gn31y; move = dot3a;
						pointX = tileLeft; pointY = tileTop; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot3b < dot3c && dot3b < dot3d)
				{
					if (dot3b > move && bInside)
					{
						axisX = -triangle.gn31x; axisY = -triangle.gn31y; move = dot3b;
						pointX = tileRight; pointY = tileTop; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot3c < dot3d)
				{
					if (dot3c > move && cInside)
					{
						axisX = -triangle.gn31x; axisY = -triangle.gn31y; move = dot3c;
						pointX = tileLeft; pointY = tileBottom; moveX = -axisX * move; moveY = -axisY * move;
					}
				}
				else if (dot3d > move && dInside)
				{
					axisX = -triangle.gn31x; axisY = -triangle.gn31y; move = dot3d;
					pointX = tileRight; pointY = tileBottom; moveX = -axisX * move; moveY = -axisY * move;
				}
			}
			
			if (move != -Infinity)
			{
				if (triangle.group)
				{
					triangle.group.x += moveX;
					triangle.group.y += moveY;
				}
				triangle.x += moveX;
				triangle.y += moveY;
				var body : AbstractRigidbody = triangle.group || triangle;
				if ((axisX == 1 || axisX == -1) && body.vx * axisX > 0 || (axisY == 1 || axisY == -1) && body.vy * axisY > 0) return true;
				resolveWallCollision(triangle, pointX - triangle.x, pointY - triangle.y, axisX, axisY, timeScale);
				return true;
			}
			
			return false;
		}
		private static function resolveTriangleVsCircle(triangle : Triangle, circle : Circle, timeScale : Number) : Vector.<Number>
		{
			if (!(circle.layers & triangle.layers) || circle.group == triangle.group && triangle.group) return null;//in the same group;
			var dx : Number = circle.x - triangle.x;
			var dy : Number = circle.y - triangle.y;
			var nx : Number, ny : Number, length : Number;
			var r : Number = triangle._extents + circle.radius;
			var distSquare : Number = dx * dx + dy * dy;
			if (distSquare < r * r - 1)
			{
				
				var posX : Number = dx;
				var posY : Number = dy;
				
				var dot1 : Number = triangle.gn12x * posX + triangle.gn12y * posY;
				var dot2 : Number = triangle.gn23x * posX + triangle.gn23y * posY;
				var dot3 : Number = triangle.gn31x * posX + triangle.gn31y * posY;
				
				if(dot1 - circle.radius < triangle.n12d && dot2 - circle.radius < triangle.n23d && dot3 - circle.radius < triangle.n31d)
				{
					if(dot1 > triangle.n12d) var dist1 : Number = dot1 - triangle.n12d;
					else dist1 = triangle.n12d - dot1;
					if(dot2 > triangle.n23d) var dist2 : Number = dot2 - triangle.n23d;
					else dist2 = triangle.n23d - dot2;
					if(dot3 > triangle.n31d) var dist3 : Number = dot3 - triangle.n31d;
					else dist3 = triangle.n31d - dot3;
					
					r = circle.radius;
					
					if (dist3 < r && dist1 < r && (posX - triangle.x1) * triangle.x1 + (posY - triangle.y1) * triangle.y1 > 0)
					{
						nx = posX - triangle.x1;
						ny = posY - triangle.y1;
						CONFIG::debug
						{
							if (distSquare < maxSize) length = sqrtTable[int((nx * nx + ny * ny) * sqrtPow)];
							else
							{
								length = Math.sqrt(nx * nx + ny * ny);
								trace("WARNING! maxSizePromise is not large enough!!!");
							}
						}
						CONFIG::release
						{
							length = sqrtTable[int((nx * nx + ny * ny) * sqrtPow)];
						}
						nx /= length;
						ny /= length;
					}
					else if (dist1 < r && dist2 < r && (posX - triangle.x2) * triangle.x2 + (posY - triangle.y2) * triangle.y2 > 0)
					{
						nx = posX - triangle.x2;
						ny = posY - triangle.y2;
						CONFIG::debug
						{
							if (distSquare < maxSize) length = sqrtTable[int((nx * nx + ny * ny) * sqrtPow)];
							else
							{
								length = Math.sqrt(nx * nx + ny * ny);
								trace("WARNING! maxSizePromise is not large enough!!!");
							}
						}
						CONFIG::release
						{
							length = sqrtTable[int((nx * nx + ny * ny) * sqrtPow)];
						}
						nx /= length;
						ny /= length;
					}
					else if (dist2 < r && dist3 < r && (posX - triangle.x3) * triangle.x3 + (posY - triangle.y3) * triangle.y3 > 0)
					{
						nx = posX - triangle.x3;
						ny = posY - triangle.y3;
						CONFIG::debug
						{
							if (distSquare < maxSize) length = sqrtTable[int((nx * nx + ny * ny) * sqrtPow)];
							else
							{
								length = Math.sqrt(nx * nx + ny * ny);
								trace("WARNING! maxSizePromise is not large enough!!!");
							}
						}
						CONFIG::release
						{
							length = sqrtTable[int((nx * nx + ny * ny) * sqrtPow)];
						}
						nx /= length;
						ny /= length;
					}
					else if (dist1 < dist2 && dist1 < dist3)
					{
						length = dot1 - triangle.n12d; nx = triangle.n12x; ny = triangle.n12y;
					}
					else if (dist2 < dist3)
					{
						length = dot2 - triangle.n23d; nx = triangle.n23x; ny = triangle.n23y;
					}
					else
					{
						length = dot3 - triangle.n31d; nx = triangle.n31x; ny = triangle.n31y;
					}
					
					
					var triangleMass : Number = triangle._mass;
					var circleMass : Number = circle._mass;
					
					var invMass : Number = triangleMass + circleMass;
					if (invMass > 0) invMass = 1 / invMass;
					else invMass = 1;
					
					length -= circle.radius;
					
					if (triangleMass == 0)
					{
						circleMass = 0;
						triangleMass = invMass = 1;
					}
					else if (circleMass == 0)
					{
						triangleMass = 0;
						circleMass = invMass = 1;
					}
					
					if (triangle.group)
					{
						triangle.group.x += nx * length * circleMass * invMass;
						triangle.group.y += ny * length * circleMass * invMass;
					}
					triangle.x += nx * length * circleMass * invMass;
					triangle.y += ny * length * circleMass * invMass;
					
					if (circle.group)
					{
						circle.group.x -= nx * length * triangleMass * invMass;
						circle.group.y -= ny * length * triangleMass * invMass;
					}
					circle.x -= nx * length * triangleMass * invMass;
					circle.y -= ny * length * triangleMass * invMass;
					
					/*
					stage.graphics.beginFill(0x00FF00);
					stage.graphics.drawCircle(-nx * circle.radius + circle.x,  -ny * circle.radius + circle.y, 4);
					stage.graphics.endFill();
					*/
					colInfo[0] = -nx * circle.radius + circle.x;
					colInfo[1] = -ny * circle.radius + circle.y;
					colInfo[2] = nx;
					colInfo[3] = ny;
					return colInfo;
				}
			}
			return null;
		}
		private static function resolveTriangles(triangle : Triangle, other : Triangle, timeScale : Number) : Vector.<Number>
		{
			if (!(other.layers & triangle.layers) || other.group == triangle.group && triangle.group) return null;//not in the same layers or in the same group
			var dot1 : Number, dot2 : Number, dot3 : Number;
			var minDot : Number = Number.NEGATIVE_INFINITY;
			var axisX : Number, axisY : Number;
			var colX : Number, colY : Number;
			
			var dx : Number = triangle.x - other.x;
			var dy : Number = triangle.y - other.y;
			
			var p1X : Number = triangle.gx1 + dx;
			var p1Y : Number = triangle.gy1 + dy;
			var p2X : Number = triangle.gx2 + dx;
			var p2Y : Number = triangle.gy2 + dy;
			var p3X : Number = triangle.gx3 + dx;
			var p3Y : Number = triangle.gy3 + dy;
			
			//edge 1-2 of OTHER
			
		 	dot1 = p1X * other.gn12x + p1Y * other.gn12y - other.n12d;
			dot2 = p2X * other.gn12x + p2Y * other.gn12y - other.n12d;
			dot3 = p3X * other.gn12x + p3Y * other.gn12y - other.n12d;
			if (dot1 > 0 && dot2 > 0 && dot3 > 0) return null;//if they're separated along this axis, there's no collision.
			if (dot1 < dot2 && dot1 < dot3)
			{
				if (dot1 > minDot) { minDot = dot1; axisX = -other.gn12x; axisY = -other.gn12y; colX = p1X + other.x; colY = p1Y + other.y; }
			}
			else if (dot2 < dot3)
			{
				if (dot2 > minDot) { minDot = dot2; axisX = -other.gn12x; axisY = -other.gn12y; colX = p2X + other.x; colY = p2Y + other.y; }
			}
			else if (dot3 > minDot) { minDot = dot3; axisX = -other.gn12x; axisY = -other.gn12y; colX = p3X + other.x; colY = p3Y + other.y; }
			
			//edge 2-3 of OTHER
			
			dot1 = p1X * other.gn23x + p1Y * other.gn23y - other.n23d;
			dot2 = p2X * other.gn23x + p2Y * other.gn23y - other.n23d;
			dot3 = p3X * other.gn23x + p3Y * other.gn23y - other.n23d;
			if (dot1 > 0 && dot2 > 0 && dot3 > 0) return null;//if they're separated along this axis, there's no collision.
			if (dot1 < dot2 && dot1 < dot3)
			{
				if (dot1 > minDot) { minDot = dot1; axisX = -other.gn23x; axisY = -other.gn23y; colX = p1X + other.x; colY = p1Y + other.y; }
			}
			else if (dot2 < dot3)
			{
				if (dot2 > minDot) { minDot = dot2; axisX = -other.gn23x; axisY = -other.gn23y; colX = p2X + other.x; colY = p2Y + other.y; }
			}
			else if (dot3 > minDot) { minDot = dot3; axisX = -other.gn23x; axisY = -other.gn23y; colX = p3X + other.x; colY = p3Y + other.y; }
			
			
			//edge 3-1 of OTHER
			
			dot1 = p1X * other.gn31x + p1Y * other.gn31y - other.n31d;
			dot2 = p2X * other.gn31x + p2Y * other.gn31y - other.n31d;
			dot3 = p3X * other.gn31x + p3Y * other.gn31y - other.n31d;
			if (dot1 > 0 && dot2 > 0 && dot3 > 0) return null;//if they're separated along this axis, there's no collision.
			if (dot1 < dot2 && dot1 < dot3)
			{
				if (dot1 > minDot) { minDot = dot1; axisX = -other.gn31x; axisY = -other.gn31y; colX = p1X + other.x; colY = p1Y + other.y; }
			}
			else if (dot2 < dot3)
			{
				if (dot2 > minDot) { minDot = dot2; axisX = -other.gn31x; axisY = -other.gn31y; colX = p2X + other.x; colY = p2Y + other.y; }
			}
			else if (dot3 > minDot) { minDot = dot3; axisX = -other.gn31x; axisY = -other.gn31y; colX = p3X + other.x; colY = p3Y + other.y; }
			
			
			p1X = other.gx1 - dx;
			p1Y = other.gy1 - dy;
			p2X = other.gx2 - dx;
			p2Y = other.gy2 - dy;
			p3X = other.gx3 - dx;
			p3Y = other.gy3 - dy;
			
			//edge 1-2 of TRIANGLE
			
		 	dot1 = p1X * triangle.gn12x + p1Y * triangle.gn12y - triangle.n12d;
			dot2 = p2X * triangle.gn12x + p2Y * triangle.gn12y - triangle.n12d;
			dot3 = p3X * triangle.gn12x + p3Y * triangle.gn12y - triangle.n12d;
			if (dot1 > 0 && dot2 > 0 && dot3 > 0) return null;//if they're separated along this axis, there's no collision.
			if (dot1 < dot2 && dot1 < dot3)
			{
				if (dot1 > minDot) { minDot = dot1; axisX = triangle.gn12x; axisY = triangle.gn12y; colX = p1X + triangle.x; colY = p1Y + triangle.y; }
			}
			else if (dot2 < dot3)
			{
				if (dot2 > minDot) { minDot = dot2; axisX = triangle.gn12x; axisY = triangle.gn12y; colX = p2X + triangle.x; colY = p2Y + triangle.y; }
			}
			else if (dot3 > minDot) { minDot = dot3; axisX = triangle.gn12x; axisY = triangle.gn12y; colX = p3X + triangle.x; colY = p3Y + triangle.y; }
			
			//edge 2-3 of TRIANGLE
			
			dot1 = p1X * triangle.gn23x + p1Y * triangle.gn23y - triangle.n23d;
			dot2 = p2X * triangle.gn23x + p2Y * triangle.gn23y - triangle.n23d;
			dot3 = p3X * triangle.gn23x + p3Y * triangle.gn23y - triangle.n23d;
			if (dot1 > 0 && dot2 > 0 && dot3 > 0) return null;//if they're separated along this axis, there's no collision.
			if (dot1 < dot2 && dot1 < dot3)
			{
				if (dot1 > minDot) { minDot = dot1; axisX = triangle.gn23x; axisY = triangle.gn23y; colX = p1X + triangle.x; colY = p1Y + triangle.y; }
			}
			else if (dot2 < dot3)
			{
				if (dot2 > minDot) { minDot = dot2; axisX = triangle.gn23x; axisY = triangle.gn23y; colX = p2X + triangle.x; colY = p2Y + triangle.y; }
			}
			else if (dot3 > minDot) { minDot = dot3; axisX = triangle.gn23x; axisY = triangle.gn23y; colX = p3X + triangle.x; colY = p3Y + triangle.y; }
			
			
			//edge 3-1 of TRIANGLE
			
			dot1 = p1X * triangle.gn31x + p1Y * triangle.gn31y - triangle.n31d;
			dot2 = p2X * triangle.gn31x + p2Y * triangle.gn31y - triangle.n31d;
			dot3 = p3X * triangle.gn31x + p3Y * triangle.gn31y - triangle.n31d;
			if (dot1 > 0 && dot2 > 0 && dot3 > 0) return null;//if they're separated along this axis, there's no collision.
			if (dot1 < dot2 && dot1 < dot3)
			{
				if (dot1 > minDot) { minDot = dot1; axisX = triangle.gn31x; axisY = triangle.gn31y; colX = p1X + triangle.x; colY = p1Y + triangle.y; }
			}
			else if (dot2 < dot3)
			{
				if (dot2 > minDot) { minDot = dot2; axisX = triangle.gn31x; axisY = triangle.gn31y; colX = p2X + triangle.x; colY = p2Y + triangle.y; }
			}
			else if (dot3 > minDot) { minDot = dot3; axisX = triangle.gn31x; axisY = triangle.gn31y; colX = p3X + triangle.x; colY = p3Y + triangle.y; }
			
			
			//SEPERATION
			
			//if (minDot < 0) minDot = -minDot;
			var triangleMass : Number = triangle.group ? triangle.group._mass : triangle._mass;
			var otherMass : Number = other.group ? other.group._mass : other._mass;
			
			if (triangleMass == 0)
			{
				otherMass = 0;
				triangleMass = 1;
				var invMass : Number = minDot;
			}
			else if (otherMass == 0)
			{
				triangleMass = 0;
				otherMass = 1;
				invMass = minDot;
			}
			else invMass = minDot / (triangleMass + otherMass);
			
			if (triangle.group)
			{
				triangle.group.x += axisX * otherMass * invMass;
				triangle.group.y += axisY * otherMass * invMass;
			}
			triangle.x += axisX * otherMass * invMass;
			triangle.y += axisY * otherMass * invMass;
			
			if (other.group)
			{
				other.group.x -= axisX * triangleMass * invMass;
				other.group.y -= axisY * triangleMass * invMass;
			}
			other.x -= axisX * triangleMass * invMass;
			other.y -= axisY * triangleMass * invMass;
			
			/*
			stage.graphics.beginFill(0x00FF00);
			stage.graphics.drawCircle(colX, colY, 4);
			stage.graphics.endFill();
			
			stage.graphics.lineStyle(2);
			stage.graphics.moveTo( colX - axisY * 100, colY + axisX * 100);
			stage.graphics.lineTo( colX + axisY * 100, colY - axisX * 100);
			*/
			colInfo[0] = colX;
			colInfo[1] = colY;
			colInfo[2] = axisX;
			colInfo[3] = axisY;
			return colInfo;
			
		}
		public static function addBody(body : AbstractRigidbody, ...rest) : void
		{
			CONFIG::debug
			{
				if (!(body is Group || body is Triangle || body is Circle)) throw new Error("Do not instantiate the AbstractRigidbody.");
				if (body._added) throw new Error("Rigidbody has already been added.");
			}
			body._added = true;
			
			if (BodyNode.pool)
			{
				var newBody : BodyNode = BodyNode.pool;
				BodyNode.pool = BodyNode.pool.next;
			}
			else
			{
				//THIS SIMPLE LINE IS THE SLOWEST PART OF THE WHOLE ENGINE
				newBody = new BodyNode();
			}
			newBody.body = body;
			
			if (body is Circle)
			{
				newBody.next = _circles;
				if(_circles) _circles.prev = newBody;
				_circles = newBody;
			}
			else if (body is Triangle)
			{
				newBody.next = _triangles;
				if(_triangles) _triangles.prev = newBody;
				_triangles = newBody;
				
				var triangle : Triangle = body as Triangle;
				
				var dist1 : Number = triangle.x1 * triangle.x1 + triangle.y1 * triangle.y1;
				var dist2 : Number = triangle.x2 * triangle.x2 + triangle.y2 * triangle.y2;
				var dist3 : Number = triangle.x3 * triangle.x3 + triangle.y3 * triangle.y3;
				(body as Triangle)._extents = Math.sqrt(Math.max(dist1, dist2, dist3));
				
				var nx : Number = triangle.y2 - triangle.y1;
				var ny : Number = triangle.x1 - triangle.x2;
				var invLength : Number = 1 / Math.sqrt(nx * nx + ny * ny);
				triangle.n12x = nx * invLength;
				triangle.n12y = ny * invLength;
				triangle.n12d = triangle.x1 * triangle.n12x + triangle.y1 * triangle.n12y;
				
				nx = triangle.y3 - triangle.y2;
				ny = triangle.x2 - triangle.x3;
				invLength = 1 / Math.sqrt(nx * nx + ny * ny);
				triangle.n23x = nx * invLength;
				triangle.n23y = ny * invLength;
				triangle.n23d = triangle.x2 * triangle.n23x + triangle.y2 * triangle.n23y;
				
				nx = triangle.y1 - triangle.y3;
				ny = triangle.x3 - triangle.x1;
				invLength = 1 / Math.sqrt(nx * nx + ny * ny);
				triangle.n31x = nx * invLength;
				triangle.n31y = ny * invLength;
				triangle.n31d = triangle.x3 * triangle.n31x + triangle.y3 * triangle.n31y;
				
				triangle._prevAngle = NaN;
				triangle._prevAngularVelocity = NaN;
			}
			else if (body is Group)
			{
				newBody.next = _groups;
				if(_groups) _groups.prev = newBody;
				_groups = newBody;
			}
			if (rest.length) addBody.apply(null, rest);
			body.lastX = body.x;
			body.lastY = body.y;
		}
		public static function removeBody(body : AbstractRigidbody) : void
		{
			CONFIG::debug
			{
				if (!body._added) throw new Error("Rigidbody is not in the powergrid, perhaps it has already been removed.");
			}
			body._added = false;

			//remove previous nodes
			for (var node : BodyNode = body.nodes; node;)
			{
				//node.remove();
				//------ this is because of the function call bottle neck in flash -----
				if (node.next) node.next.prev = node.prev;
				if (node.prev) node.prev.next = node.next;
				else _buckets[node.index] = node.next;
				
				node.next = BodyNode.pool;
				BodyNode.pool = node;
				node = node.brother;
				
				BodyNode.pool.brother = BodyNode.pool.prev = null;
				BodyNode.pool.body = null;
				BodyNode.pool.index = uint.MAX_VALUE;
				//----------------------------------------------------------------------
			}
			body.nodes = null;
			//if the other body is NOT sleeping, it's in the simulation.
			if (!(body.sleeping > sleepTime))
			{
				if (body is Circle) var bodies : BodyNode = _circles;
				else if (body is Triangle) bodies = _triangles;
				else if (body is Group)
				{
					if (_circles)
					{
						bodies = _circles;
						do
						{
							if (bodies.body.group == body)
							{
								if (bodies.next) bodies.next.prev = bodies.prev;
								if (bodies.prev) bodies.prev.next = bodies.next;
								else _circles = bodies.next;
								
								bodies.next = BodyNode.pool;
								BodyNode.pool = bodies;
								
								BodyNode.pool.brother = BodyNode.pool.prev = null;
								BodyNode.pool.body = null;
								BodyNode.pool.index = uint.MAX_VALUE;
							}
						}
						while ((bodies = bodies.next));
					}
					if (_triangles)
					{
						bodies = _triangles;
						do
						{
							if (bodies.body.group == body)
							{
								if (bodies.next) bodies.next.prev = bodies.prev;
								if (bodies.prev) bodies.prev.next = bodies.next;
								else _triangles = bodies.next;
								
								bodies.next = BodyNode.pool;
								BodyNode.pool = bodies;
								
								BodyNode.pool.brother = BodyNode.pool.prev = null;
								BodyNode.pool.body = null;
								BodyNode.pool.index = uint.MAX_VALUE;
							}
						}
						while ((bodies = bodies.next));
					}
					
					bodies = _groups;
				}
				
				if (bodies)
				{
					do
					{
						if (bodies.body == body)
						{
							if (body.group) body.group.releaseBody(body);
							if (bodies.next) bodies.next.prev = bodies.prev;
							if (bodies.prev) bodies.prev.next = bodies.next;
							else if (body is Circle) _circles = bodies.next;
							else if (body is Triangle) _triangles = bodies.next;
							else if (body is Group) _groups = bodies.next;
							
							bodies.next = BodyNode.pool;
							BodyNode.pool = bodies;
							
							BodyNode.pool.brother = BodyNode.pool.prev = null;
							BodyNode.pool.body = null;
							BodyNode.pool.index = uint.MAX_VALUE;
							break;
						}
					}
					while ((bodies = bodies.next));
				}
			}
		}
		/**
		 * Sets the <code>maxVelocityX</code> and <code>maxVelocityY</code> to a the <code>unitSize</code>
		 * This will prevent many situations where the rigidbody would otherwise pass through a solid tile.
		 * This also sets the <code>maxVelocityA</code> to 120° per timestep.
		 * The reason for 120° is because the direction of rotation generally becomes harder to perceive beyond that limit.
		 * 120 * 3 = 360 meaning it would take 3 timesteps for a full 360° rotation.
		 */
		public static function setOptimalMaxVelocity() : void
		{
			maxVelocityX = maxVelocityY = unitSize;
			maxVelocityA = 120;
		}
		public static function getBucket(xIndex : uint, yIndex : uint) : BodyNode
		{
			return _buckets[xIndex + (yIndex * _width)];
		}
		public static function getTile(xIndex : uint, yIndex : uint) : uint
		{
			return _tiles[xIndex + (yIndex * _width)];
		}
		public static function forEachCircle(callback : Function) : void
		{
			forEachBody(callback, true, false);
		}
		public static function forEachTriangle(callback : Function) : void
		{
			forEachBody(callback, false, true);
		}
		public static function forEachGroup(callback : Function) : void
		{
			forEachBody(callback, false, false, true);
		}
		private static function forEachBody(callback : Function, includeCircles : Boolean = true, includeTriangles : Boolean = true, includeGroups : Boolean = false) : void
		{
			if (includeCircles && _circles)
			{
				var target : BodyNode = _circles;
				do
				{
					callback(target.body);
				}
				while ((target = target.next));
			}
			if (includeTriangles && _triangles)
			{
				target = _triangles;
				do
				{
					callback(target.body);
				}
				while ((target = target.next));
			}
			if (includeGroups && _groups)
			{
				target = _groups;
				do
				{
					callback(target.body);
				}
				while ((target = target.next));
			}
		}
		/**
		 * Searches for the specified non sleeping body, that is, the body will not be found if it's sleeping.
		 * @param	body, the body to search for.
		 * @return true, if the PowerGrid contains the specified body and the body is not sleeping, otherwise, false.
		 */
		public static function contains(body : AbstractRigidbody) : Boolean
		{
			if (body is Circle && _circles)
			{
				var target : BodyNode = _circles;
				do
				{
					if (body == target.body) return true;
				}
				while ((target = target.next));
			}
			if (body is Triangle && _triangles)
			{
				target = _triangles;
				do
				{
					if (body == target.body) return true;
				}
				while ((target = target.next));
			}
			if (body is Group && _groups)
			{
				target = _groups;
				do
				{
					if (body == target.body) return true;
				}
				while ((target = target.next));
			}
			return false;
		}
	}

}