package
{
	import flash.geom.Point;
	
	internal class AbstractStar
	{
		// Preceding "_underscore" convention is not for all private members - only
		// for those that have a corresponding getter by the same ("underscore") name.
		private var _location:Point;
		private var _trajectory_angle:Number;
		private var trajectory_angle_sine:Number;
		private var trajectory_angle_cosine:Number;
		private var _dx:Number;
		private var _dy:Number;
		
		public function AbstractStar(location:Point = null)
		{
			if (location != null)
			{
				this.location = location;
			}
		}
		
		// Input Point is assumed to be the offset from the stage center (meaning the 
		// registration point is essentially the center of the parent DisplayObjectContainer.
		public function set location(point:Point)
		{
			if (this._location == null)
			{
				this._location = new Point(point.x, point.y);
			}
			else
			{
				if (point.x == 0)
				{
					point.x = 0.001;
				}
				if (point.y == 0)
				{
					point.y = 0.001;
				}
				
				this._location.x = point.x;
				this._location.y = point.y;
			}
			
			this.trajectory_angle = Math.atan2(point.y, point.x);
		}
		
		// The star's trajectory is effectively a vector from the
		// center of its parent DisplayObjectContainer to its starting
		// position.
		private function set trajectory_angle(angle:Number)
		{
			this._trajectory_angle = angle;
			this.trajectory_angle_sine = Math.sin(angle);
			this.trajectory_angle_cosine = Math.cos(angle);
			_dx = _location.length * this.trajectory_angle_cosine;
			_dy = _location.length * this.trajectory_angle_sine;
		}
		
		public function get dy():Number
		{
			return _dy;
		}
		
		public function get dx():Number
		{
			return _dx;
		}
		
		public function get location():Point
		{
			return this._location;
		}
		
		public function get x():Number
		{
			return this._location.x;
		}
		
		public function get y():Number
		{
			return this._location.y;
		}
		
		public function set x(x:Number)
		{
			if (x == 0)
			{
				x = 0.001;
			}
			this._location.x = x;
			_dx = _location.length * this.trajectory_angle_cosine;
		}
		
		public function set y(y:Number)
		{
			if (y == 0)
			{
				y = 0.001;
			}
			this._location.y = y;
			_dy = _location.length * this.trajectory_angle_sine;
		}
		
	}
}