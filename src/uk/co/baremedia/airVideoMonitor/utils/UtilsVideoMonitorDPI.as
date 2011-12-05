package uk.co.baremedia.airVideoMonitor.utils
{
	import mx.core.DPIClassification;
	
	public class UtilsVideoMonitorDPI
	{
		public function UtilsVideoMonitorDPI()
		{
			
		}
		
		public static function languageContainer(widthNotHeight:Boolean):Number
		{
			var appDPI:Number = UtilsDimensions.applicationDPI;
			
			if(appDPI <= DPIClassification.DPI_160)
			{
				return (widthNotHeight) ? 240 : 145;
			}
			else if(appDPI <= DPIClassification.DPI_240)
			{
				return (widthNotHeight) ? 340 : 210;	
			}
			else //appDPI <= DPIClassification.DPI_320
			{
				return (widthNotHeight) ? 400 : 280;
			}
		}
		
		public static function get helpPageHeight():Number
		{
			var screenHeight:Number = UtilsDimensions.applicationHeigth;
			var appDPI:Number = UtilsDimensions.applicationDPI;
			
			return (screenHeight >= 620) ? 400 : screenHeight; 
		}
	}
}