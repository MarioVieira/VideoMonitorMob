package uk.co.baremedia.airVideoMonitor.utils 
{ 
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.mx_internal;
	import mx.managers.SystemManager;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.preloaders.SplashScreen;
	
	import uk.co.baremedia.airVideoMonitor.assets.Assets;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;

	use namespace mx_internal; 
	
	public class UtilsSplashScreen extends SplashScreen 
	{ 
		private static const imageClassInstanceNameWithouthDimensions:String = "splash_";
		
		private static const N_1280:Number 	= 1024;
		private static const N_800:Number 	= 800;
		private static const N_768:Number = 768;
		private static const N_680:Number = 600;
		private static const N_960:Number = 960;
		private static const N_640:Number = 640;
		private static const N_480:Number = 480;
		private static const N_320:Number = 320;
		
		public function UtilsSplashScreen() 
		{ 
			super(); 
		} 
		
		override mx_internal function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class
		{ 
			//Tracer.log(this, "Capabilities.screenResolutionX: "+
			//Tracer.log(this, "getImageClass - isARMDevice: "+UtilsDeviceInfo.isARMDevice+"  width: "+stageWidth+" width: "+stageHeight);
			
			if(stageWidth == 1024 && stageHeight == 912 && UtilsDeviceInfo.isARMDevice)
			{
				return Assets.splash_SonyP;
			}
			
			if(dpi <= 140)
			{
				return Assets.splash_130DPI;
			}
			else if(dpi >140 && dpi <=240)
			{	
				if(stageWidth > 1000)
					return Assets.splash_200DPI
				else
					return Assets.splash_160DPI;
			}
			else
			{
				return Assets.splash_200DPI;
			}
			 
			
			
			/*if ( isMetrics(N_1280, N_800) ) 		return getSplashScreen(N_1280, N_800);
			else if ( isMetrics(N_1280, N_768) ) 	return getSplashScreen(N_1280, N_768);
			else if ( isMetrics(N_1280, N_680) ) 	return getSplashScreen(N_1280, N_680);
			else if ( isMetrics(N_960, N_640) ) 	return getSplashScreen(N_960, N_640);
			else if ( isMetrics(N_800, N_480) ) 	return getSplashScreen(N_800, N_480);
			else if ( isMetrics(N_480, N_320) ) 	return getSplashScreen(N_800, N_320);
			
			return getSplashScreen(N_960, N_640);*/
		} 
		
		/*protected function isMetrics(width:Number, height:Number):Boolean
		{
			Tracer.log(this, "isMetrics - width:"+width+" height: "+height+" stageHeight: "+stageHeight+" stageWidth: "+stageWidth);
			return (stageWidth == width || stageHeight == width && stageHeight == height || stageHeight == width);
		}
		
		protected function getSplashScreen(width:Number, height:Number):Class
		{
			return Assets[imageClassInstanceNameWithouthDimensions+width + "x" + height];
		}*/
	} 
}