package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.geom.Rectangle;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import uk.co.baremedia.airVideoMonitor.assets.Assets;
	import uk.co.baremedia.gnomo.utils.Resizer;
	
	public class UtilsCamera
	{
		public static const TWO_THIRDS:Number 	= 1.5;
		public static const QUARTER:Number 		= 4;
		
		public static function getImage(width:Number, screenReductionFactor:Number, heightForTest:Number = 0):Class
		{
			//Tracer.log(UtilsCamera, "width: "+width+" heightForTest: "+heightForTest+" getImage: "+getImageRespectiveImageWidth(width, screenReductionFactor) + " cameraWidth_"+getImageRespectiveImageWidth(width, screenReductionFactor) );
			return Assets["cameraWidth_"+getImageRespectiveImageWidth(width, screenReductionFactor)];
		}
		
		public static function getImageDimensions(width:Number, screenReductionFactor:Number):Rectangle
		{
			//Tracer.log(UtilsCamera, "getImageDimensions - width: "+width+"  found height: "+Resizer.scaleByAspectRatio(3200, 3540, 0, getImageRespectiveImageWidth(width, screenReductionFactor) ).height+"  found width: "+Resizer.scaleByAspectRatio(3200, 3540, 0, getImageRespectiveImageWidth(width, screenReductionFactor) ).width );
			//320 x 362.5 = x10 30000, 36250
			return Resizer.scaleByAspectRatio(128000, 145000, 0, getImageRespectiveImageWidth(width, screenReductionFactor) );
		}
		
		public static function getImageRespectiveImageWidth(requestedWidth:Number, screenReductionFactor:Number):Number
		{
			//80, 120, 135, 150, 192, 213, 240, 320, 360, 400, 512, 640
			//Tracer.log(UtilsCamera, "getImageRespectiveImageWidth - requestedWidth: "+requestedWidth);
			switch(true)
			{
				case requestedWidth <= 320:
					return (screenReductionFactor == TWO_THIRDS) ? 213 : 80;
					break;
																//Android often returns 442 for 480
				case requestedWidth > 320 && requestedWidth <= 480:
					//return (screenReductionFactor == TWO_THIRDS) ? 320 : 120;
					return (screenReductionFactor == TWO_THIRDS) ? 320 : 120;
					break;
				
				case requestedWidth > 480 && requestedWidth <= 540:
					//return (screenReductionFactor == TWO_THIRDS) ? 360  : 135;
					return (screenReductionFactor == TWO_THIRDS) ? 320  : 135;
					break;
				
				case requestedWidth > 540 && requestedWidth <= 600:
					//return (screenReductionFactor == TWO_THIRDS) ? 480 : 150;
					return (screenReductionFactor == TWO_THIRDS) ? 400 : 150;
					break;
				

				case requestedWidth > 600 && requestedWidth <= 768:
					//return (screenReductionFactor == TWO_THIRDS) ? 512 : 192;
					return (screenReductionFactor == TWO_THIRDS) ? 480 : 192;
					break;

				case requestedWidth >= 768:
					return (screenReductionFactor == TWO_THIRDS) ? 640 : 192;
					break;
			}
			
			return null;
		}
	}
}


/*
800x480
1.5 = 522.2 and 320
4 = 200 and 320

960x540
1.5 = 640 and 360
4 = 240and 135

960 x 640
1.5 = 640 and 426
4 = 240 and 160


1240x600
1.5 = 682 and 400
4 = 240 and 150

1024x768
1.5 = 682 and 512
4 = 256 and 192

1280x800
v1.5 = 853 and 512
4 = 320 and 200
*/