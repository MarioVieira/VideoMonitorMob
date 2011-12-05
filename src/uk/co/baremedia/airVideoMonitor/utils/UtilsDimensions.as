package uk.co.baremedia.airVideoMonitor.utils
{
	import mx.core.FlexGlobals;
	
	import uk.co.baremedia.gnomo.utils.DecreaseIncreaseRate;
	import uk.co.baremedia.gnomo.utils.RateVO;
	
	public class UtilsDimensions
	{
		public static const PADDING_LEFT_RIGHT:int	= 14;
		public static const OPEN_VIDEO_BUTTON_BAR:int = 282;
		public static const OPEN_BUTTON_BAR_WITH_PADDING:int = OPEN_VIDEO_BUTTON_BAR + PADDING_LEFT_RIGHT;
		
		public static function getVideoButtonBarScaleValue(videoWidth:Number)
		{
			var appDPI:Number 		  = applicationDPI;
			var appWidth:Number 	  = applicationWidth;
			
			
			return getScaleValue( getScaledUpVideoBarWidthInRelationToVideoWidth(appDPI, videoWidth - PADDING_LEFT_RIGHT) );
			//find increase rate from it's own size
			//return getScaleValue(videoWidth - PADDING_LEFT_RIGHT);
			
			/*if(appWidth <= 480 && appDPI <= 160)
			{
				  
			}
			//find increase rate from video width size
			else
			{
				return getScaleValue( getScaledUpVideoBarWidthInRelationToVideoWidth(appDPI, videoWidth) );
			}*/
		}
		
		private static function getScaledUpVideoBarWidthInRelationToVideoWidth(dpi:Number, videoWidth:Number):Number
		{
			
			return videoWidth * .75
				
			//always > bar original size
			//85% on playbook, htc, ip4 (> 320 &&)
			//iPads and Motorolas 
			/*if(dpi >= 150 && dpi < 170) 
			{
				return videoWidth * .75
			}
			else if(dpi >= 170 && dpi < 300) 
			{
				return videoWidth * .85;
			}
			else if(dpi >= 300) 
			{
				return videoWidth * .9;
			}*/
			
			/*if(width > 320 && width <= 480)
			{
				return width * .85;
			}
			else if( && dpi)
			{
				return width * .85;
			}*/
			
			return 1;
		}
		
		protected static function getScaleValue(newWidth:Number):Number
		{
			var vo:RateVO = DecreaseIncreaseRate.findRates(OPEN_BUTTON_BAR_WITH_PADDING * 100, newWidth * 100);
			if(!vo.increaseNotDecrease) return 1 - vo.rate;
			else						return 1 + vo.rate;
		}
		
		/*public static function isAppWidth(smallerWidth:Number = -1):Boolean
		{
			var width:Number (appWidth != -1) ? width : appWidth;
			return (width > 320 && width <= 480);
		}*/
		
		public static function get applicationWidth():Number
		{
			var width:Number = -1;
			try{ width = FlexGlobals.topLevelApplication.systemManager.screen.width }catch(er:Error){}; 
			return width;
		}
		
		public static function get applicationHeigth():Number
		{
			var height:Number = -1;
			try{ height = FlexGlobals.topLevelApplication.systemManager.screen.height }catch(er:Error){}; 
			return height;
		}
		
		public static function get applicationDPI():Number
		{
			var dpi:Number = -1;
			try{ dpi = FlexGlobals.topLevelApplication.applicationDPI }catch(er:Error){ }; 
			return dpi;
		}
	}
}