package
{
	import AbstractStar;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	/* 
	*  Windows Hyperspace Screensaver Blit Demo
	* * * * * * * * * * * * * * * * * * * * * * * *
	*  Concept:
	*  		Have a Bitmap that you write to the screen - this is your "canvas".
	*  Each frame...
	*  		Calculate the positions of all 'Stars' that will be on screen - store them in a Vector of Points
	*  		Clear the "canvas"
	*      	Redraw all stars to the "canvas" using blitting (bit-block transfer)
	*/

	[SWF(backgroundColor="0x000000", frameRate="120", width="640", height="480")]
	public class HyperspaceDemo extends Sprite
	{
		public static const STARS_ON_SCREEN:uint = 200;
		public static const STAR_COLOR:uint = 0x00FF00;
		public static const STAR_DIMENSION_PIXELS:uint = 5;
		public static const STAR_SPEED:Number = 0.075;
		
		private var stars:Vector.<AbstractStar>;		
		private var stage_bitmap:Bitmap;
		private var stage_bitmap_data:BitmapData;
		private var star_bitmap_data:BitmapData;

		// Convenience/optimization vars.
		private var stage_quarter_width:uint;
		private var stage_quarter_height:uint;
		private var stage_half_width:uint;
		private var stage_half_height:uint;
		private var stage_quarter_distance:Number;
		
		public function HyperspaceDemo()
		{
			if (this.stage != null)
			{
				init();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
				
		private function init(event:Event = null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
			
			stage_half_width = this.stage.stageWidth * 0.5;
			stage_half_height = this.stage.stageHeight * 0.5;
			stage_quarter_width = this.stage.stageWidth * 0.25;
			stage_quarter_height = this.stage.stageHeight * 0.25;
			stage_quarter_distance = Math.sqrt(stage_quarter_width * stage_quarter_width + stage_quarter_height * stage_quarter_height);
			stars = new Vector.<AbstractStar>();

			// Create the star Tilesheet, with different alpha values (1, 0.75, 0.5, 0.25)
			var star_shape:Shape = new Shape();
			star_shape.graphics.beginFill(STAR_COLOR);
			star_shape.graphics.drawRect(0, 0, STAR_DIMENSION_PIXELS, STAR_DIMENSION_PIXELS);
			
			star_shape.graphics.beginFill(STAR_COLOR, 0.75);
			star_shape.graphics.drawRect(STAR_DIMENSION_PIXELS, 0, STAR_DIMENSION_PIXELS, STAR_DIMENSION_PIXELS);

			star_shape.graphics.beginFill(STAR_COLOR, 0.5);
			star_shape.graphics.drawRect(2 * STAR_DIMENSION_PIXELS, 0, STAR_DIMENSION_PIXELS, STAR_DIMENSION_PIXELS);

			star_shape.graphics.beginFill(STAR_COLOR, 0.25);
			star_shape.graphics.drawRect(3 * STAR_DIMENSION_PIXELS, 0, STAR_DIMENSION_PIXELS, STAR_DIMENSION_PIXELS);
		
			star_shape.graphics.endFill();
			
			star_bitmap_data = new BitmapData(4 * STAR_DIMENSION_PIXELS, STAR_DIMENSION_PIXELS, true, 0x00000000);
			star_bitmap_data.draw(star_shape);

			// Create the Bitmap that will be the Canvas for the animation.			
			stage_bitmap_data = new BitmapData(this.stage.stageWidth, this.stage.stageHeight, true, 0xFFFFFF);
			stage_bitmap = new Bitmap(stage_bitmap_data);
			this.stage.addChild(stage_bitmap);

			init_stars();
			
			this.stage.addEventListener(Event.ENTER_FRAME, fly_through_hyperspace);		
		}
		
		// Create new stars if necessary, and store in a Vector.
		private function init_stars():void
		{
			var num_stars_to_create:Number = STARS_ON_SCREEN;
			
			while (num_stars_to_create-- > 0)
			{
				var current_star:AbstractStar = init_star();
				this.stars.push(current_star);
			}			
		}
		
		// If an AbstractStar is passed in, effectively re-initializes it (object pooling).
		// Places the star in a random location in the middle half-area of the stage.
		private function init_star(star:AbstractStar = null):AbstractStar
		{
			var x_direction:int = (Math.random() >= 0.5) ? 1 : -1;
			var y_direction:int = (Math.random() >= 0.5) ? 1 : -1;
			
			if (star == null)
			{
				star = new AbstractStar();
			}
				
			star.location = new Point(x_direction * Math.random() * this.stage_quarter_width,
									  y_direction * Math.random() * this.stage_quarter_height);
									  
			return star;
		}
		
		private function fly_through_hyperspace(event:Event):void
		{
			// Clear the 'canvas.'
			stage_bitmap_data.fillRect(stage_bitmap_data.rect, 0x000000);
			
			// Move the stars, then redraw them to the canvas with the correct alpha value.
			var half_stage_offset:Point = new Point(this.stage_half_width, this.stage_half_height);
			
			var desired_alpha_value:Number;
			var tilesheet_x_offset:Number;
			var source_image_rect:Rectangle = new Rectangle(0, 0, STAR_DIMENSION_PIXELS, STAR_DIMENSION_PIXELS);
			
			for each(var star:AbstractStar in stars)
			{
				star.x += star.dx * STAR_SPEED;
				star.y += star.dy * STAR_SPEED;

				if (Math.abs(star.x) > stage_half_width || Math.abs(star.y) > stage_half_height)
				{
					init_star(star);
				}
				
				desired_alpha_value = star.location.length / this.stage_quarter_distance;
				tilesheet_x_offset = get_star_tilesheet_x_offset(desired_alpha_value);
				source_image_rect.x = tilesheet_x_offset;
				
				stage_bitmap_data.copyPixels(star_bitmap_data, source_image_rect, star.location.add(half_stage_offset));
			}
		}
		
		// Given the input (desired) alpha value, returns the x offset in the star_bitmap_data Tilesheet
		// that (loosely) corresponds to the input value; I've used a granularity of 4 (0.25, 0.5, 0.75, 1)
		// for the sake of simplicity/proof of concept.
		private function get_star_tilesheet_x_offset(alpha_value:Number):Number
		{
			if (alpha_value <= 0.25)
			{
				return 3 * STAR_DIMENSION_PIXELS;
			}
			else if (alpha_value <= 0.5)
			{
				return 2 * STAR_DIMENSION_PIXELS;
			}
			else if (alpha_value <= 0.75)
			{
				return STAR_DIMENSION_PIXELS;
			}
			else return 0;
		}
	}
	
}