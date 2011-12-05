package uk.co.baremedia.airVideoMonitor.model
{
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElementContainer;
	
	import net.mariovieira.mobile.sony.vo.DeviceScreenVO;
	
	import org.as3.mvcsInjector.utils.Tracer;
	import org.as3.mvcsInjector.vo.VOScreen;
	import org.osflash.signals.Signal;
	
	import spark.components.ViewNavigator;
	import spark.components.supportClasses.GroupBase;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsP2PComm;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoReceiver;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;
	import uk.co.baremedia.gnomo.utils.UtilsMedia;
	
	[Bindable]
	public class ModelAIRMonitor extends EventDispatcher
	{
		public static const BROADCASTER_VIDE_WIDTH 			:Number = 160;
		public static const BROADCASTER_VIDE_HEIGHT			:Number = 120;
		public static const DEVICE_SCREEN_INFO				:String = "deviceScreenInfo";
		
		public var debugText								:String = "";
		
		public var channel									:LocalNetworkDiscovery;
		public var videosModel								:Vector.<VOVideo>;
		public var appScreens								:ModelVideoPresenter = new ModelVideoPresenter();
		
		public var broadcasterVideo							:Video;
		public var camera									:Camera;
		public var appId									:String;
		
		public var mainScreen								:Object;
		public var firstCameraBroadcastSignal				:Signal;
		public var stageDimensionsSignal					:Signal;
		public var hdQualitySignal							:Signal;
		public var cameraRequestedFromMainScreenSignal		:Signal;
		public var micMutedSignal							:Signal;
		public var swapBroadcastCameraSignal				:Signal;
		public var removeNotAddCameraToMainScreenSignal		:Signal;
		public var receivingSignal							:Signal;
		public var broadcastingSignal						:Signal;
		public var openHelpPageSignal						:Signal;
		
		public var cameraWasOnMainScreen					:Boolean;
		public var wasBroadcasting							:Boolean;
		
		[Bindable(event="filmReelVisisble")]
		public var filmReelVisible							:Boolean;
		//[Bindable(event="filmReelVisisble")]
		[Bindable]
		public var filmReelScreenTwoVisible					:Boolean = true;
		
		private var _deviceScreenInfo						:DeviceScreenVO;
		private var _receiving								:Boolean;
		private var _fullScreen								:Boolean;
		private var _videoPresenterContainer				:IVisualElementContainer;
		
		protected static var _instance						:ModelAIRMonitor;
		private var _micMuted		  						:Boolean;
		private var _removeNotAddCameraToMainScreen			:Boolean;
		private var _hdQuality								:Boolean;
		
		public var viewNavigator							:ViewNavigator;
		private var _broadcasting:Boolean;
		
		public var helpScreenCurrentItemId					:int;
		public var helpScreenCurrentItemIcon				:Class;
		
		
		public function ModelAIRMonitor(blocker:SingletonBlocker)
		{
			if(!blocker) throw new Error("use ModelAIRMonitor.instance");
		}
		
		[Bindable(event="deviceScreenInfo")]
		public function get isDualScreen():Boolean
		{
			return (deviceScreenInfo) ? deviceScreenInfo.isDualScreen : false;	
		}
		
		[Bindable(event="deviceScreenInfo")]
		public function set deviceScreenInfo(value:DeviceScreenVO):void
		{
			_deviceScreenInfo = value;
			dispatchEvent(new Event(DEVICE_SCREEN_INFO));
		}
		
		public function get deviceScreenInfo():DeviceScreenVO
		{
			return _deviceScreenInfo;
		}
		
		public function set broadcasting(value:Boolean):void
		{
			_broadcasting = value;
			broadcastingSignal.dispatch(value);
		}
		
		public function get broadcasting():Boolean
		{
			return _broadcasting;
		}
		
		public function set videoPresenterContainer(value:IVisualElementContainer):void
		{
			_videoPresenterContainer = value;
		}
		
		public function resetVideoPresenterScale():void
		{
			GroupBase(_videoPresenterContainer).scaleX = 1;
			GroupBase(_videoPresenterContainer).scaleY = 1;
		}
		
		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}
		
		public function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
			defineFilmReelVisible();
		}
		
		public function set micMuted(value:Boolean):void
		{
			_micMuted = value;
			micMutedSignal.dispatch(value);	
		}
		
		public function get micMuted():Boolean
		{
			return _micMuted;	
		}
		
		/*public function set lensOnScreen(value:Boolean):void
		{
			lensOnScreenSignal.dispatch(value);
		}*/

		public function get receiving():Boolean
		{
			return _receiving;
		}
		
		public function set hdQuality(value:Boolean):void
		{
			_hdQuality = value;
			hdQualitySignal.dispatch(value);
		}
		
		public function get hdQuality():Boolean
		{
			return _hdQuality;
		}
		
		public function set cameraRequestedFromMainScreen(value:Boolean):void
		{
			cameraRequestedFromMainScreenSignal.dispatch(value);
		}
		
		public function set removeNotAddCameraToMainScreen(value:Boolean):void
		{
			_removeNotAddCameraToMainScreen = value;
			removeNotAddCameraToMainScreenSignal.dispatch(value);
		}
		
		public function get removeNotAddCameraToMainScreen():Boolean
		{
			return _removeNotAddCameraToMainScreen;
		}

		public function set receiving(value:Boolean):void
		{
			_receiving = value;
			receivingSignal.dispatch(value);
			defineFilmReelVisible();
		}
		public function defineFilmReelVisible():void
		{
			filmReelVisible = (_receiving && !_fullScreen);	
			//Tracer.log(this, "defineFilmReelVisible - filmReelVisible: "+filmReelVisible);
			dispatchEvent(new Event("filmReelVisisble"));
		}
		
		public function set openHelpPage(value:Boolean):void
		{
			openHelpPageSignal.dispatch(value);
		}
		
		public function setBroadcasterCamera(backNotFront:Boolean, releaseCamera:Boolean = false, cameraSwap:Boolean = false, muted:Boolean = false, updateBroadcasterVideo:Boolean = false):void
		{
			if(!releaseCamera)
			{
				//Tracer.log(this, "setBroadcasterCamera - hdQuality: "+hdQuality);
				//debugIt = "setBroadcasterCamera - AND: "+ UtilsDeviceInfo.isMobileAndHasTwoCameras+"\n";
				
				camera 			   = UtilsMedia.getCamera(backNotFront, hdQuality);
				channel.microphone = UtilsMedia.getMicrophone(muted);
				channel.camera     = camera;
				if(updateBroadcasterVideo) setupBroadcasterVideo(true);
				swapBroadcastCamera= cameraSwap;
				
				debugIt = "GET CAM: "+ camera;
			}
			else
			{
				channel.stopBroadcast();
				camera = null;
			}
		}
		
		public function setupBroadcasterVideo(startNotStop:Boolean):void
		{
			if(startNotStop)
			{
				broadcasterVideo = new Video();
				broadcasterVideo.visible = true;
				broadcasterVideo.attachCamera(camera);
			}
			else
			{
				if(broadcasterVideo)
				{
					broadcasterVideo.visible = false;
					broadcasterVideo.attachCamera(null);
					broadcasterVideo.attachNetStream(null);
				}
				broadcasterVideo = null;
				camera = null;
			}
		}
		
		public function set swapBroadcastCamera(value:Boolean):void
		{
			if(value) 
			{
				Tracer.log(this, "BROADCAST swapBroadcastCamera");
				swapBroadcastCameraSignal.dispatch(value);
			}
		}
		
		public function startBroadcast(backNotFront:Boolean, swapCams:Boolean, changeQuality:Boolean = false, toRequesterID:String = null, broadcasterHasTwoCameras:Boolean = false):void
		{
			this.broadcasting = true;
			if(swapCams) channel.stopBroadcast();
			channel.startBrodcast( getBroadcastOrder(swapCams, changeQuality), appId, toRequesterID, backNotFront, broadcasterHasTwoCameras );
		}
		
		protected function getBroadcastOrder(swapCam:Boolean, changeQuality:Boolean):String
		{
			if(!swapCam && !changeQuality)
			{
				return EnumsP2PComm.SENDING_STREAM;
			}
			else if(swapCam)
			{
				return EnumsP2PComm.SWAP_CAMERA;
			}
			else
			{
				return (hdQuality) ? EnumsP2PComm.VIDEO_QUALITY_CHANGE_HIGH : EnumsP2PComm.VIDEO_QUALITY_CHANGE_DEFAULT;
			}
		}
		
		public function updateVideoInfoInModel(videoInfo:VOVideo):void
		{
			var length:int = videosModel.length;
			for(var i:int; i < length; i++)
			{
				if(videosModel[i].broadcasterUID == videoInfo.broadcasterUID)
				{
					//Tracer.log(this, "updateVideoInfoInModel videoInfo.videoChatOn: "+videoInfo.videoChatOn+" length: "+length);
					videosModel[i] = videoInfo; 
				}
			}	
		}
		
		public function getVideoInfoByBroadcastUID(broadcastUID:String):VOVideo
		{
			for each (var videoInfo:VOVideo in videosModel) 
			{
				//Tracer.log(ModelAIRMonitor, "videoInfo - videoInfo.broadcasterUID: "+videoInfo.broadcasterUID+" broadcastUID: "+broadcastUID);
				if(videoInfo.broadcasterUID == broadcastUID) 
					return videoInfo;
			}
			
			return null;
			
		}
		
		public function set debugIt(value:String):void
		{
			debugText += (debugText == "") ? "["+getTimer()+"] - "+value+" " : "\n["+getTimer()+"] - "+value;
		}
		
		public function resetDebug():void
		{
			debugText = "";
		}
		
		public static function get instance():ModelAIRMonitor
		{
			if(!_instance) 
			{
				_instance = new ModelAIRMonitor(new SingletonBlocker());
				initialize();
			}
			return _instance;	
		}
		
		protected static function initialize():void
		{
			Tracer.log(ModelAIRMonitor, "initialize()");
			
			_instance.appId 								 = String( new Date().getTime() );
			_instance.videosModel 							 = new Vector.<VOVideo>;
			_instance.channel 	  							 = new LocalNetworkDiscovery();
			_instance.channel.clientName					= _instance.appId;
			_instance.channel.connect();
			_instance.cameraRequestedFromMainScreenSignal	 = new Signal(Boolean);
			_instance.micMutedSignal						 = new Signal(Boolean);
			_instance.swapBroadcastCameraSignal				 = new Signal(Boolean);
			_instance.removeNotAddCameraToMainScreenSignal	 = new Signal(Boolean);
			_instance.receivingSignal						 = new Signal(Boolean);
			_instance.broadcastingSignal					 = new Signal(Boolean);
			_instance.openHelpPageSignal					 = new Signal(Boolean);
			_instance.firstCameraBroadcastSignal			 = new Signal();
			_instance.stageDimensionsSignal					 = new Signal();
			_instance.hdQualitySignal						 = new Signal();
			
		}
		
		public function removeVideo(videoInfo:VOVideo):void
		{
			UtilsVideoReceiver.removeVideo(videoInfo, appScreens, videosModel);
		}
		
		public function canNetworkRequesterStopBroadcast(requesterUID:String):Boolean
		{
			//Tracer.log(this, "canNetworkRequesterStopBroadcast - requesterUID: "+requesterUID+" mediaInfo.requesterUID: "+channel.mediaInfo.requesterUID);
			if(!channel.mediaInfo.requesterUID || channel.mediaInfo.requesterUID == requesterUID || !requesterUID) return true;
			return false;
		}
		
		public function setHDVideo(active:Boolean):void
		{
			hdQuality = active;
			UtilsVideoPresenter.swapBroadcastsQuality(this, hdQuality, appId);
			
			if(broadcasting)
			{
				updateStreamQuality(hdQuality);			
			}
		}
		
		public function updateStreamQuality(hdQuality:Boolean):void
		{
			channel.updateCameraSettingsToStream( UtilsMedia.getCamera(channel.mediaInfo.backNotFrontCamera, hdQuality) );
			hdQualitySignal.dispatch(hdQuality);
		}
	}
}
	
class SingletonBlocker{}