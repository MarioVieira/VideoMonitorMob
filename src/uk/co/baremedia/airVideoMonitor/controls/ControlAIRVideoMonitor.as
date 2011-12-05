package uk.co.baremedia.airVideoMonitor.controls
{
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.MediaBroadcastEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.util.ClassRegistry;
	import com.projectcocoon.p2p.util.Tracer;
	import com.projectcocoon.p2p.vo.MediaVO;
	
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.as3.mvcsInjector.interfaces.IDispose;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsP2PComm;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.model.ModelNotifier;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsNetworkMessenger;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoReceiver;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsViewMenuItems;
	import uk.co.baremedia.airVideoMonitor.view.components.CompMonitor;
	import uk.co.baremedia.airVideoMonitor.vo.VOBroadcaster;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;
	
	[Bindable]
	public class ControlAIRVideoMonitor implements IDispose
	{
		private var _view				:CompMonitor;
		private var _model				:ModelAIRMonitor;
		private var _modelNotification	:ModelNotifier;
		private var _sharedObjectControl:ControlSharedObject;
		
		public function get filmReelVisible():Boolean
		{
			return _model.filmReelVisible; 
		}
		
		public function get receiving():Boolean 	{return _model.receiving};
		public function get broadcasting():Boolean  {return _model.broadcasting};
		
		public function ControlAIRVideoMonitor(view:CompMonitor) 
		{
			//Tracer.log(this, "AIRVideoMonitorControl - Capabilities.version: "+Capabilities.version);
			ClassRegistry.registerClass("uk.co.baremedia.airVideoMonitor.vo.BroadcasterVO", VOBroadcaster);
			
			_model = ModelAIRMonitor.instance;
			_view  = view;
			_sharedObjectControl = new ControlSharedObject("uk.co.baremedia.airVideoMonitor");
			
			setup();
			observe();
		}

		private function setup():void
		{
			Multitouch.inputMode 			= MultitouchInputMode.GESTURE;
			_modelNotification 				= ModelNotifier.instance;
			_modelNotification.channel 		= _model.channel;
			_modelNotification.model 		= _model;
			
			_model.mainScreen 				= _view; 
			//was not in use before adding ModelVideoPresenter logic
			//_model.videoPresenterContainer 	= _view.videoPresenter;
			_view.model 					= _model;
			//used to access button bar width for full screen buttons scaling
		
			UtilsViewMenuItems.setupStaticButtons(this);
			updateViewMenuItems();
		}


		private function observe():void
		{
			_model.channel.addEventListener(ClientEvent.CLIENT_REMOVED, onClientRemoved);
			//_view.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			_model.channel.addEventListener(MediaBroadcastEvent.MEDIA_BROADCAST, channel_mediaBroadcastHandler);
			_model.channel.addEventListener(MessageEvent.DATA_RECEIVED, channel_dataReceived);
			_model.hdQualitySignal.add(onVideoResolutionQuality);
		}
		
		public function dispose(recursive:Boolean=true):void
		{
			_model.channel.removeEventListener(ClientEvent.CLIENT_REMOVED, onClientRemoved);
			//_view.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			_model.channel.removeEventListener(MediaBroadcastEvent.MEDIA_BROADCAST, channel_mediaBroadcastHandler);
			_model.channel.removeEventListener(MessageEvent.DATA_RECEIVED, channel_dataReceived);
			_model.hdQualitySignal.remove(onVideoResolutionQuality);
		}

		protected function onClientRemoved(event:ClientEvent):void
		{
			// 1- stop broadcasting if removed client was requester
			var foundVideoInfo:VOVideo   = UtilsVideoReceiver.stopBroadcastByPeerId(event.client.peerID, _model.videosModel, _model.appScreens);
			//the P2P network is keeping the last client cause the groupIdentifier is server / persistent mode :( - won't see the correct disconnected client
			var canStopBroadcast:Boolean = (_model.broadcasting) ? _model.channel.mediaInfo.requesterUID == event.client.clientName : false;
			
			//Tracer.log(this, "onClientRemoved - clientName: "+event.client.clientName);
			
			if(foundVideoInfo) 	 stopPlayingBroadcaster(foundVideoInfo.broadcasterUID);
			if(canStopBroadcast) stopBroadcast(_model.appId, true);
			
			updateReceivingInAccordanceWithModelLength();
			UtilsVideoPresenter.updateCameraOnScreen(_model);
			
			debugIt = "client removed - type: "+event.client.deviceType;
		}
		
		private function set debugIt(message:String):void
		{
			_model.debugIt = message;
		}
		
		/************************************ CLASS VIDEO CONTROL ***********************************/
		
		public function get model():ModelAIRMonitor
		{
			return _model;
		}
		
		public function get fullScreen():Boolean
		{
			return _model.fullScreen;
		}
		
		public function stopPlayingAllVideos(stopBroadcasters:Boolean = true):void
		{
			UtilsVideoReceiver.stopPlayingAllVideos(_model.videosModel, _model.appScreens, _model.channel, _model.appId);
			UtilsNetworkMessenger.releaseRequestedBroadcasts(_model.appId, _model.videosModel, _model.channel);
			updateReceivingInAccordanceWithModelLength();
			
			//Tracer.log(this, "stopPlayingAllVideos - hasVideoChats: "+UtilsVideoPresenter.hasVideoChats(model.videosModel));
			UtilsVideoPresenter.updateCameraOnScreen(model, !UtilsVideoPresenter.hasVideoChats(model.videosModel));
		}
		
		/**
		 *
		 * Here the broadcasterID that requested the broadcast via the messages to group will be passed over (broadcasterUID) as the
		 * 	requesterUID, so when the actual net stream started the message to broadcast this media info will be received the requesterUID
		 *  
		 * @param backNotFront
		 * @param sendingStream
		 * @param toRequesterID
		 * 
		 */		
		public function broadcast(backNotFront:Boolean, toRequesterID:String = null, swapCamera:Boolean = false, setupBroadcasterVideo:Boolean = false, changeQuality:Boolean = false):void
		{
			//Tracer.log(this, "broadcast - toRequesterID: "+toRequesterID);
			if(!_model.channel.mediaInfo.broadcasting || swapCamera || changeQuality)
			{
				//setup the camera (Camera and Mic are Singletons so get again if rolling)
				_model.setBroadcasterCamera(backNotFront, false, swapCamera, _model.micMuted, (setupBroadcasterVideo || changeQuality) );
				
				//broadcasting was false, only place accessing this broadacst method is the P2P group requests 
				//So, first broadccast and therefore send camero to main screen!
				if(!swapCamera) UtilsVideoPresenter.sendCameraToMainScreen(_model);
				
				//it has the appId / broadcast id localy
				_model.startBroadcast(backNotFront, swapCamera, changeQuality, toRequesterID, UtilsDeviceInfo.isMobileAndHasTwoCameras);
				
				UtilsVideoPresenter.setWasCameraOnScreen(_model);
				UtilsVideoPresenter.updateCameraOnScreen(_model);
			}
			else
			{
				//in this case camera is broadcasting, no need to remove it from scren again
				_model.channel.broadcastCurrentMediaInfo(toRequesterID);
			}
			
			updateReceivingInAccordanceWithModelLength();
		}
		
		public function stopBroadcast(broadcasterId:String, sendMessageToGroup:Boolean = false):void
		{
			//Tracer.log(this, "stopBroadcast - broadcasterId: "+broadcasterId+" appId: "+_model.appId+" _model.broadcasting: "+_model.broadcasting);
			
			if(_model.appId == broadcasterId && _model.broadcasting)
			{
				//Tracer.log(this, "STOP BROADCASTING");
				_model.broadcasting = false;
				_model.setupBroadcasterVideo(false);
				_model.channel.stopBroadcast();
				if(sendMessageToGroup) stopBroadcastingToGroup(_model.appId);
				
				UtilsVideoPresenter.checkBroadcastCameraPlacement(_model, true);
				UtilsVideoPresenter.updateCameraOnScreen(_model);
			}
			else
			{
				UtilsVideoPresenter.checkBroadcastCameraPlacement(_model);
			}
			
			updateReceivingInAccordanceWithModelLength();
		}
		
		private function stopPlayingBroadcaster(broadcasterUID:String):void
		{
			if(UtilsVideoReceiver.stopVideoIfPlaying(broadcasterUID, _model.videosModel, _model.appScreens))
			{
				UtilsVideoPresenter.updateCameraOnScreen(_model);
			}
			
			updateReceivingInAccordanceWithModelLength();
		}
		
		private function updateReceivingInAccordanceWithModelLength():void
		{
			//Tracer.log(this, "stopPlayingBroadcaster - _model.videosModel.length: "+_model.videosModel.length);
			UtilsVideoPresenter.updateReceivingInAccordanceWithModelLength(_model);
			updateViewMenuItems();
		}
		
		private function watchVideoStream(mediaInfo:MediaVO, forceWatch:Boolean = false):void
		{
			//Tracer.log(this, "watchVideoStream - mediaInfo.requesterUID: "+mediaInfo.requesterUID+"  broadcasterUID / appId: "+_model.appId);
			if(mediaInfo.requesterUID == _model.appId || mediaInfo.requesterUID == null || forceWatch)
			{
				//UtilsVideoReceiver.watchBroadcaster(mediaInfo, _model.videosModel, _view.videoPresenter, _model.channel.groupNetConnection(), new Rectangle(0, 0, _view.width, _view.height), _model);
				UtilsVideoReceiver.watchBroadcaster(mediaInfo, _model.videosModel, _model.channel.groupNetConnection(), _model);
				_model.receiving = true;
				
				updateReceivingInAccordanceWithModelLength();
				UtilsVideoPresenter.updateCameraOnScreen(_model);
				
				//debugIt = "receive stream";	
			}
			else
			{
				//debugIt = "receive stream to other client (not playing it)";
			}
		}
		
		private function watchStreamIfItWasPlaying(mediaInfo:MediaVO):void
		{
			var wasWatchinBroadcast:VOVideo = _model.getVideoInfoByBroadcastUID(mediaInfo.broadcasterUID);
			if(wasWatchinBroadcast)
			{
				//Tracer.log(this, "DO WATCH STREAM IT WAS PLAYING");
				watchVideoStream(mediaInfo, true);
			}
		}
		
		/************************************ CLASS P2P CONTROL ***********************************/
		
		public function channel_mediaBroadcastHandler(event:MediaBroadcastEvent):void
		{
			model.debugIt = "mediaBroadcastHandler: "+event.mediaInfo.order;
			
			if(event.mediaInfo.order == EnumsP2PComm.SENDING_STREAM)
			{
				//Tracer.log(this, "channel_mediaBroadcastHandler - SENDING_STREAM");
				watchVideoStream(event.mediaInfo);
			}
			else if(event.mediaInfo.order == EnumsP2PComm.SWAP_CAMERA)
			{
				//Tracer.log(this, "channel_mediaBroadcastHandler - SWAP_CAMERA");
				watchStreamIfItWasPlaying(event.mediaInfo);
			}
			else if(event.mediaInfo.order == EnumsP2PComm.VIDEO_QUALITY_CHANGE_DEFAULT || event.mediaInfo.order == EnumsP2PComm.VIDEO_QUALITY_CHANGE_HIGH)
			{
				//Tracer.log(this, "channel_mediaBroadcastHandler - SWAP_CAMERA");
				watchStreamIfItWasPlaying(event.mediaInfo);
			}
		}
		
		/**
		 *
		 * Conditions to exection not in function for readiability purpose
		 *  
		 * @param e
		 * 
		 */		
		public function channel_dataReceived(e:MessageEvent):void
		{
			var vo:VOBroadcaster = VOBroadcaster(e.message.data);
			model.debugIt = "dataReceived: "+vo.request;
			
			if(vo.request == EnumsP2PComm.REQUEST_FRONT_CAM_AND_MIC)
			{
				//Tracer.log(this, "channel_dataReceived - REQUEST_FRONT_CAM_AND_MIC");
				broadcast(false, vo.requesterUID);
			}
			else if(vo.request == EnumsP2PComm.REQUEST_BACK_CAM_AND_MIC)
			{
				broadcast(true, vo.requesterUID);	
			}
			else if(vo.request == EnumsP2PComm.RELEASE_CAM_AND_MIC)
			{
				//Tracer.log(this, "channel_dataReceived - RELEASE_CAM_AND_MIC - can release: "+_model.canNetworkRequesterStopBroadcast(vo) );
				if(_model.canNetworkRequesterStopBroadcast(vo.requesterUID)) stopBroadcast(vo.broadcasterUID, true);
			}
			else if(vo.request == EnumsP2PComm.BROADCAST_STOPPED)
			{
				stopPlayingBroadcaster(vo.broadcasterUID);	
			}
			else if(vo.request == EnumsP2PComm.BROADCAST_STOPPED_USER_TO_USER && _model.appId == vo.requesterUID)
			{
				stopPlayingBroadcaster(vo.broadcasterUID);	
			}
			else if(vo.request == EnumsP2PComm.SWAP_CAMERA)
			{
				swapCameraIfBroadcasting(vo);
			}
			else if(vo.request == EnumsP2PComm.VIDEO_QUALITY_CHANGE_DEFAULT || vo.request == EnumsP2PComm.VIDEO_QUALITY_CHANGE_HIGH)
			{
				changeVideoQualityIfBroadcasting(vo);
			}
		}
		
		private function changeVideoQualityIfBroadcasting(vo:VOBroadcaster):void
		{
			if(_model.broadcasting)
			{
				//Tracer.log(this, "changeVideoQualityIfBroadcasting - vo.requesterUID: "+ vo.requesterUID);
				//NO NEED for this, Camera is a static ref in memory, changing the quality will cause the stream to automatically change the quality
				//broadcast(_model.channel.mediaInfo.backNotFrontCamera, _model.channel.mediaInfo.requesterUID, false, true, true);
				_model.hdQuality = (vo.request == EnumsP2PComm.VIDEO_QUALITY_CHANGE_HIGH);
				_model.updateStreamQuality(_model.hdQuality);
			}
		}
		
		private function swapCameraIfBroadcasting(vo:VOBroadcaster):void
		{
			//Tracer.log(this,"swapCameraIfBroadcasting");
			if(_model.broadcasting && vo.broadcasterUID == _model.appId)
			{
				//Tracer.log(this,"swapCameraIfBroadcasting - DO SWAP - backNotFront: "+_model.channel.mediaInfo.backNotFrontCamera); 
				broadcast(!_model.channel.mediaInfo.backNotFrontCamera, vo.broadcasterUID, true, true);
			}
		}
		
		public function requestNetworkCameras(backNotFront:Boolean, requesterID:String = null):void
		{
			//debugIt = "request cameras";
			UtilsNetworkMessenger.requestAllNetworkCameras(backNotFront, requesterID, _model.channel);
		}
		
		public function stopBroadcastingToGroup(appId:String):void
		{
			//debugIt = "stop camera and notify group";
			UtilsNetworkMessenger.stopBroadcastingToGroup(appId, _model.channel);
		}
		
		/************************************ CLASS PRESENTATION MODEL ***********************************/
		
		private function onVideoResolutionQuality(hdQuality:Boolean):void
		{
			updateViewMenuItems();	
		}
		
		public function updateViewMenuItems():void
		{
			_view.viewContainer.viewMenu = UtilsViewMenuItems.getViewMenuItems(this);
		}
		
		public function onStopPlaying(e:MouseEvent):void
		{
			stopPlayingAllVideos();
			stopBroadcast(_model.appId, true);
		}
		
		public function onStopSending(event:MouseEvent):void
		{
			stopBroadcast(_model.appId, true);
		}
		
		public function onGetFrontCam(event:MouseEvent):void
		{
			requestNetworkCameras(false, _model.appId);
		}
		
		public function onSendFrontCam(event:MouseEvent):void
		{
			broadcast(false, null);
		}
		
		public function onRequestDefaultQuality(e:MouseEvent):void
		{
			_model.setHDVideo(false);
		}
		
		public function onRequestHDQuality(e:MouseEvent):void
		{
			_model.setHDVideo(true);
		}
		
		/************************************ TOUCH AND GESTURE ***********************************/
		
		/*protected function onZoom(e:TransformGestureEvent):void
		{
			if(_model.receiving && !_model.fullScreen)
			{	
				_view.videoPresenter.scaleX *= e.scaleX;
				_view.videoPresenter.scaleY *= e.scaleX;
				
				//_view.videoPresenter.scaleY *= e.scaleY;
			}
		}*/
		/*private function onTouchBegin(e:TouchEvent) 
		{
		e.target.startTouchDrag(e.touchPointID, false, _view.videoPresenter.getRect(_video));
		}
		
		private function onTouchEnd(e:TouchEvent) 
		{
		e.target.stopTouchDrag(e.touchPointID);
		}*/
	}
}