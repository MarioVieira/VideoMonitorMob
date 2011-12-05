package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.media.Video;
	
	import mx.core.UIComponent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	import uk.co.baremedia.gnomo.utils.DecreaseIncreaseRate;
	import uk.co.baremedia.gnomo.utils.RateVO;
	import uk.co.baremedia.gnomo.utils.Resizer;
	
	public class UtilsVideoPresenter
	{
		public static const VIDEO_OPEN_BUTTON_BAR_WIDTH:Number = 400;
		
		public static function updateReceivingInAccordanceWithModelLength(model:ModelAIRMonitor):Boolean
		{
			//Tracer.log(UtilsVideoPresenter, "updateReceivingInAccordanceWithModelLength - model.videosModel.length: "+model.videosModel.length);
			
			if(model.videosModel.length >= 1) 
			{
				model.receiving = true;
				model.defineFilmReelVisible();
				return true;
			}
			else
			{
				model.receiving = false;
				model.defineFilmReelVisible();
				return false;
			}
		}
		
		public static function numOfVideoChats(videoModel:Vector.<VOVideo>):int
		{
			var foundChats:int;
			
			for each(var videoInfo:VOVideo in videoModel)
			{
				if(videoInfo.videoChatOn) foundChats++;
			}
			
			return foundChats;
		}
		
		public static function updateCameraOnScreen(model:ModelAIRMonitor, forceRemove:Boolean = false):void
		{
			var isScreenOneEmpty:Boolean = isScreenOneEmpty(model.videosModel); 
			
			if( forceRemove || isScreenOneEmpty )
			{
				//Tracer.log(UtilsVideoPresenter, "updateCameraOnScreen - removeNotAddCameraToMainScreen FALSE");
				model.removeNotAddCameraToMainScreen = false;	
			}

			else
			{
				//Tracer.log(UtilsVideoPresenter, "updateCameraOnScreen - removeNotAddCameraToMainScreen TRUE");
				model.removeNotAddCameraToMainScreen = true;
			}
		}
		
		public static function hasVideoChats(videoModel:Vector.<VOVideo>):Boolean
		{
			return numOfVideoChats(videoModel) > 0;
		}
		
		public static function isPlayingVideos(videosModel:Vector.<VOVideo>):Boolean
		{
			return videosModel.length > 0;
		}
		
		public static function setWasCameraOnScreen(model:ModelAIRMonitor):void
		{
			//Tracer.log(UtilsVideoPresenter, "isPlayingVideos: "+isPlayingVideos(model.videosModel)+" model.broadcasting: "+model.broadcasting); 
			if( !isPlayingVideos(model.videosModel) && model.broadcasting ) model.cameraWasOnMainScreen = true;
		}
		
		public static function checkBroadcastCameraPlacement(model:ModelAIRMonitor, forceRemove:Boolean = false):void
		{
			if(forceRemove)
			{
				//Tracer.log(this, "STOP VIDEO CAMERA IN MAIN SCREEN");
				model.cameraRequestedFromMainScreen = true;
			}
			else if(!UtilsVideoPresenter.hasVideoChats(model.videosModel) && model.broadcasting)
			{
				//Tracer.log(this, "SEND VIDEO CAMERA TO MAIN SCREEN");
				model.cameraRequestedFromMainScreen = false;
			}
		}
		
		public static function sendCameraToMainScreen(model:ModelAIRMonitor):void
		{
			//Tracer.log(UtilsVideoPresenter, "sendCameraToMainScreen");
			model.firstCameraBroadcastSignal.dispatch();
		}
		
		public static function getVideoButtonBarScaleValue(videoWidth:Number):Number
		{
			var minimumWidth:Number = VIDEO_OPEN_BUTTON_BAR_WIDTH;
			
			var scale:RateVO = DecreaseIncreaseRate.findRates(minimumWidth * 100, videoWidth * 100);
			
			if(videoWidth < minimumWidth)
			{
				return 1 - scale.rate;
			}
			else
			{
				return 1 + scale.rate;
			}
			
			//return 1;
		}
		
		public static function swapBroadcastsQuality(model:ModelAIRMonitor, hdQualityNotDefault:Boolean, requesterUID:String):void
		{
			if( isPlayingVideos(model.videosModel) )
			{
				//Tracer.log(UtilsVideoPresenter, "swapBroadcastsQuality - hdQualityNotDefault: "+hdQualityNotDefault);
				UtilsNetworkMessenger.requestHDCameras(model.channel, hdQualityNotDefault, requesterUID);
			}
		}
		
		protected static function isScreenOneEmpty(videos:Vector.<VOVideo>):Boolean
		{
			for each(var videoInfo:VOVideo in videos)
			{
				if(videoInfo.screenIndex == 0)
					return false;
			}
			
			return true;
		}
		
		public static function resetScale(presenter:UIComponent):void
		{
			presenter.scaleX = 1;
			presenter.scaleY = 1;
		}
	}
}