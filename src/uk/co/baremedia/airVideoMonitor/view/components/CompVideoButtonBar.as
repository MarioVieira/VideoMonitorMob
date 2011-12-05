package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Microphone;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.ImageSnapshot;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.HGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsNetworkMessenger;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoReceiver;
	import uk.co.baremedia.airVideoMonitor.view.elements.ButtonAction;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideoPresenter;
	import uk.co.baremedia.gnomo.utils.Resizer;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;
	import uk.co.baremedia.gnomo.utils.UtilsMedia;
	
	public class CompVideoButtonBar extends SkinnableComponent
	{
		[DefaultProperty("noBroadcast")]
		[SkinStates("noBroadcast", "onlyOneCam", "backAndFrontCam")]

		[SkinPart(required="true")]
		public var sendVideoButton			:ButtonAction;
		
		[SkinPart(required="true")]
		public var muteButton				:ButtonAction;
		
		[SkinPart(required="true")]
		public var fullScreenButton			:ButtonAction;
		
		[SkinPart(required="true")]
		public var removeVideoButton		:ButtonAction;
		
		[SkinPart(required="true")]
		public var muteMicButton			:ButtonAction;
		
		[SkinPart(required="true")]
		public var changeCameraButton		:ButtonAction;
		
		[SkinPart(required="true")]
		public var changeBroadcastCam		:ButtonAction;
	
		[SkinPart(required="true")]
		public var broadcasterVideoHolder 	:UIComponent;
		
		[SkinPart(required="true")]
		public var buttonHolder 			:HGroup;
		
		[SkinPart(required="true")]
		public var cameraOn					:IVisualElement;
		
		public var videoPresenter			:VOVideoPresenter; 
		
		public var BACK_AND_FRONT_CAM		:String = "backAndFrontCam"; 
		public var ONLY_ONE_CAM				:String = "onlyOneCam"; 
		public var NO_BROADCAST				:String = "noBroadcast";
		
		[Bindable] public var videoInfo   	:VOVideo;
		[Bindable(event="broadcastChange")] 
		public var broadcasting  			:Boolean;
		[Bindable] public var hasVideoCamera:Boolean;
		
		protected var _model				:ModelAIRMonitor;
		private var _formerVideoSize		:Rectangle;
		private var _cameraRequester		:Boolean;
		private var _cameraIsBackNotFront	:Boolean;
		private var _micRequester			:Boolean;
		private var _videoButtonBarScale	:Number = 0;
		
		[Bindable(event="broadcastCameraChange")] 
		public var hasTwoBroadcastCams		:Boolean;
		
		public function CompVideoButtonBar()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		[Bindable]
		public function set videoButtonBarScale(value:Number):void
		{
			//Tracer.log(this, "videoButtonBarScale - value: "+value);
			_videoButtonBarScale = value;
		}
		
		public function get videoButtonBarScale():Number
		{
			return _videoButtonBarScale;
		}

		protected function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			//Tracer.log(this, "MUTE - model.micMuted: "+model.micMuted);
			if(model) updateView();
			updateSkinState();
		}
		
		private function setBroadcasting(value:Boolean):void
		{
			broadcasting = value;
			dispatchEvent(new Event("broadcastChange"));
		}
		
		private function setHasTwoBroadcastCameras(value:Boolean):void
		{
			//Tracer.log(this, "setHasTwoBroadcastCameras - value: "+value);
			hasTwoBroadcastCams = value;
			dispatchEvent(new Event("broadcastChange"));
		}
		
		private function updateSkinState():void
		{
			//Tracer.log(this, "updateSkinState - videoInfo.videoChatOn: "+videoInfo.videoChatOn); 
			setBroadcasting( videoInfo.videoChatOn );
			setHasTwoBroadcastCameras( videoInfo.hasTwoBroadcastCameras );
		}
		
		private function updateView():void
		{
			if(model)
			{
				if(muteMicButton) muteMicButton.setActive(model.micMuted);
				if(muteButton && videoInfo) muteButton.setActive(videoInfo.volumeMuted);
				if(sendVideoButton) sendVideoButton.setActive(videoInfo.videoChatOn);
				
				updateBroacasterCam();
				updateHasCamera();
			}
		}
		
		private function updateHasCamera():void
		{
			if(videoInfo.hasCamera) broadcastCamera(true, _cameraIsBackNotFront);
		}
		
		private function updateBroacasterCam():void
		{
			if(changeBroadcastCam && videoInfo) 
				changeBroadcastCam.visible = changeBroadcastCam.includeInLayout = videoInfo.hasTwoBroadcastCameras;
			
		}
		
		override protected function getCurrentSkinState():String
		{
			if(broadcasting)  return (hasTwoCameras) ? BACK_AND_FRONT_CAM : ONLY_ONE_CAM;
			else			  return NO_BROADCAST;
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(instance == sendVideoButton || instance == muteButton || instance == fullScreenButton || instance == muteMicButton || 
				instance == changeCameraButton || instance == removeVideoButton || instance == changeBroadcastCam)
			{
				instance.addEventListener(MouseEvent.CLICK, onButtonClick);
			}
			else if(instance == cameraOn)
			{
				cameraOn.addEventListener(MouseEvent.CLICK, onCamerOnClick);	
			}
			else if(instance == muteMicButton)
			{
				//Tracer.log(this, "MUTE BUTTON ADDED TO STAGE - model.micMuted: "+model.micMuted);
				instance.addEventListener(MouseEvent.CLICK, onButtonClick);
				muteMicButton.active = model.micMuted;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			
			if(instance == sendVideoButton || instance == muteButton || instance == fullScreenButton || instance == muteMicButton || 
			   instance == changeCameraButton || instance == removeVideoButton || instance == changeBroadcastCam)
			{
				instance.removeEventListener(MouseEvent.CLICK, onButtonClick);
			}
			else if(instance == cameraOn)
			{
				cameraOn.removeEventListener(MouseEvent.CLICK, onCamerOnClick);	
			}
			else if(instance == broadcasterVideoHolder)
			{
				model.cameraRequestedFromMainScreenSignal.remove(onCameraRequested);
				model.micMutedSignal.remove(onMicMuted);
				model.swapBroadcastCameraSignal.remove(onUpdateCameraOnScreen);	
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			invalidateDisplayList();
			updateVideoDimensions();
		}
		
		
		[Bindable]
		public function set model(value:ModelAIRMonitor):void
		{
			_model = value;
			if(_model)
			{
				model.cameraRequestedFromMainScreenSignal.add(onCameraRequested);
				model.micMutedSignal.add(onMicMuted);
				model.swapBroadcastCameraSignal.add(onUpdateCameraOnScreen);
				setBroadcasting( videoInfo.videoChatOn );
				setHasTwoBroadcastCameras( videoInfo.hasTwoBroadcastCameras );
				updateBroacasterCam();
			}
		}
		
		public function get model():ModelAIRMonitor
		{
			return _model;
		}
		
		private function onUpdateCameraOnScreen(value:Boolean):void
		{
			if(hasVideoCamera) setCameraFromModelOnScreen();
			else			   removeBroadcasterVideoFromContainer();		
				
		}
		
		private function onCamerOnClick(e:Event):void
		{
			broadcastCamera(true, _cameraIsBackNotFront);
		}
	
		//when other video snd camera are hit, if this is the requester in this 
		//time it still keeps the hasVideoCamera true, next it was someone that asked for it
		private function onCameraRequested(value:Boolean):void
		{
			if(_cameraRequester)
			{	
				_cameraRequester = false
			}
			else
			{
				hasVideoCamera = videoInfo.hasCamera = false;	
			}
		}
		
		public function onButtonClick(event:MouseEvent):void
		{
			var button:ButtonAction = ButtonAction(event.target);
			
			if(button == muteButton) 				setMuted(button.active);
			else if(button == sendVideoButton) 		broadcastCamera(button.active, false);
			else if(button == fullScreenButton) 	setFullScreen(button.active);
			else if(button == removeVideoButton)	removeVideo();
			else if(button == muteMicButton) 		muteMic(!button.active);
			else if(button == changeCameraButton) 	swapCamera();
			else if(button == changeBroadcastCam) 	swapBroadcastCamera();
		
		}
		
		private function swapBroadcastCamera():void
		{
			UtilsNetworkMessenger.swapBroadcasterCameras(model.channel, videoInfo.broadcasterUID, model.appId);
		}
		
		private function swapCamera():void
		{
			//Tracer.log(this, "swapCamera()");
			setupBroadcasterCamera(!model.channel.mediaInfo.backNotFrontCamera, true);
		}		
		
		private function onMicMuted(muted:Boolean):void
		{
			if(muteMicButton && !_micRequester) 
			{
				//Tracer.log(this, "onMicMuted - muted: "+muted+" videoInfo.broadcasterUID: "+videoInfo.broadcasterUID);
				muteMicButton.setActive(muted);
			}
			else if(muteMicButton)
			{
				_micRequester = false;
			}
		}
		
		private function removeVideo():void
		{
			//Tracer.log(this, "removeVideo");
			//1 - if this client has requested the video send the broadcaster a release / stop cam and mic message
			//Tracer.log(this, "removeVideo - (videoInfo.requesterUID == model.appId): "+(videoInfo.requesterUID == model.appId) );
			if(videoInfo.requesterUID == model.appId) UtilsNetworkMessenger.releaseBroadcasterCamAndMic(videoInfo.broadcasterUID, model.appId, model.channel);
			
			//2 - clear video if it was not on main screen
			model.removeVideo(videoInfo);
			
			//2 - unmount the video player (send it back to the main screen if it was broadcasting)
			broadcastCamera(false, false);
			
			//4 -  if no more videos make sure the film reel stripes goes away, and camera image comes back to main screen
			UtilsVideoPresenter.updateReceivingInAccordanceWithModelLength(model);
		}
		
		
		private function broadcastCamera(startNotStop:Boolean, backNotFront:Boolean):void
		{
			//Tracer.log(this, "broadcastCamera - stopNotStart: "+stopNotStart+" model.broadcasting: "+model.broadcasting);
			if(startNotStop)
			{
				_cameraRequester 		= true;
				
				//1st - CAMERA IMAGE is gone out of screen when first playing (this comp is inside of a playing video)
				
				//Tracer.log(this, "broadcastCamera - TRUE A - model.broadcasting: "+model.broadcasting);
				if(!model.broadcasting || broadcasting)
				{
					setupBroadcasterCamera(backNotFront);
				}
				else
				{
					//cameraWasOnScreen because a get video was requested, so the 1st broadcast call set cameraWasOnScreen
					//UtilsVideoPresenter.setWasCameraOnScreen(model);
					grabMainScreenCamera(true, backNotFront);
					model.channel.broadcastCurrentMediaInfo(videoInfo.broadcasterUID);
				}
				
				//Tracer.log(this, "broadcastCamera - TRUE B - hasNoVideoChats: "+hasNoVideoChats);
				videoInfo.videoChatOn = true;
				invalidateSkinState();
			}
			else
			{
				//1 - always stop broadcasting to the user 
				videoInfo.videoChatOn = false;
				stopBroadcastToUser(videoInfo.broadcasterUID);
				stopBroadcastIfRemovedVideoIsTheRequester(videoInfo.broadcasterUID);
				
				//Tracer.log(this, "broadcastCamera - model.cameraWasOnMainScreen: "+model.cameraWasOnMainScreen+" hasNoVideoChats: "+hasNoVideoChats);
				//2 - if no video chats, and camera was on main screen (no videos were being played, and it was broadcasting via a network get cam request)
				if(hasNoVideoChats && model.cameraWasOnMainScreen)
				{
					grabMainScreenCamera(false, backNotFront);
					model.cameraWasOnMainScreen = false;
				}
				//3 - if no other clients are receiving the camera
				else if(hasNoVideoChats)
				{
					stopBroadcasterCamera();
					UtilsVideoPresenter.checkBroadcastCameraPlacement(model);
				}
			
				invalidateSkinState();
				
				UtilsVideoPresenter.updateCameraOnScreen(_model);
			}
			
			setBroadcasting(startNotStop);
			hasVideoCamera = videoInfo.hasCamera = startNotStop;
		}

		private function stopBroadcastToUser(broadcasterUID:String):void
		{
			UtilsNetworkMessenger.stopBroadcastingToUser(broadcasterUID, model.appId, model.channel);
		}

		private function stopBroadcastIfRemovedVideoIsTheRequester(broadcasterUID:String):void
		{
			if(_model.broadcasting && broadcasterUID == model.channel.mediaInfo.requesterUID)
			{
				model.channel.stopBroadcast();
				UtilsNetworkMessenger.stopBroadcastingToGroup(model.appId, model.channel);
				UtilsVideoPresenter.updateReceivingInAccordanceWithModelLength(model);
			}
		}
		
		protected function get hasTwoCameras():Boolean
		{
			return UtilsDeviceInfo.isMobileAndHasTwoCameras;
		}
		
		private function stopBroadcasterCamera():void
		{
			//Tracer.log(this, "stopBroadcasterCamera");
			model.setBroadcasterCamera(false, true);
			if(!model.cameraWasOnMainScreen) model.broadcasting = false;
			removeBroadcasterVideoFromContainer();
		}
	
		public function muteMic(muteNotUnMute:Boolean):void
		{
			var mic:Microphone = (model.channel.camAndMic) ? model.channel.camAndMic.microphone : null;
			//Tracer.log(this, "muteMic - muteNotUnMute: "+muteNotUnMute+" mic: "+mic+" videoInfo.broadcasterUID: "+videoInfo.broadcasterUID);
			if(mic) 
			{
				_micRequester = true;
				UtilsMedia.muteMic(mic, muteNotUnMute);
				model.micMuted = muteNotUnMute;
			}
		}
		
		private function get notPlayingVideos():Boolean
		{
			return (model.videosModel.length == 0);
		}
		
		private function get hasNoVideoChats():Boolean
		{
			return UtilsVideoPresenter.numOfVideoChats(model.videosModel) == 0;
		}
		
		private function get hasMoreVideoChats():Boolean
		{
			return UtilsVideoPresenter.numOfVideoChats(model.videosModel) >= 1;
		}
		
		private function grabMainScreenCamera(grabNotRelease:Boolean, backNotFront:Boolean):void
		{
			model.cameraRequestedFromMainScreen = grabNotRelease;
			
			if(grabNotRelease)
			{
				setupBroadcasterCamera(backNotFront);
			}
			else
			{
				removeBroadcasterVideoFromContainer();
			}
		}
		
		private function removeBroadcasterVideoFromContainer():void
		{
			var numChildren:int = broadcasterVideoHolder.numChildren;
			for(var i:int; i < numChildren; i++)
			{
				try{ broadcasterVideoHolder.removeChildAt(i); } catch(er:Error){ };
			}
		}
		
		private function setupBroadcasterCamera(backNotFront:Boolean, cameraSwap:Boolean = false):void
		{
			if(!model.broadcasting || cameraSwap) 
			{
				//Tracer.log(this, "setupBroadcasterCamera - cameraSwap: "+cameraSwap);
				_cameraIsBackNotFront = backNotFront;
				model.setBroadcasterCamera(backNotFront, false, cameraSwap, model.micMuted);
				
				
				//other wise there will be a signal dispatched that will cause this component to get the camera from the model once it's swaped
				if(!cameraSwap)
				{
					setCameraFromModelOnScreen();
				}
				
				//Tracer.log( "setupBroadcasterCamera - has 2 cameras"+ UtilsDeviceInfo.isMobileAndHasTwoCameras); 
				model.startBroadcast(backNotFront, cameraSwap, false, videoInfo.broadcasterUID, UtilsDeviceInfo.isMobileAndHasTwoCameras);
			}
			
			broadcasterVideoHolder.addChild(model.broadcasterVideo);
			updateVideoDimensions();
		}
		
		private function setCameraFromModelOnScreen():void
		{
			if(broadcasterVideoHolder.numChildren > 0) removeBroadcasterVideoFromContainer();
			model.setupBroadcasterVideo(true);
		}
		
		private function updateVideoDimensions():void
		{
			if(model && model.broadcasterVideo && broadcasterVideoHolder)
			{
				var reductionFactor:Number = (height <= 480) ? 3 : 4;
				var rect:Rectangle = Resizer.scaleByAspectRatio(1280, 960, height / reductionFactor);
				broadcasterVideoHolder.height = model.broadcasterVideo.height = rect.height 
				broadcasterVideoHolder.width  = model.broadcasterVideo.width  = rect.width;
			}
		}
		
		private function takePhoto():void
		{
			Tracer.log(this, "takePhoto(): "+getPhoto());
			//shotScreen.source = getPhoto();
			//videoInfo.video.visible = false;
		}
		
		private function getPhoto(saveInCameraRool:Boolean = false):BitmapData
		{
			return ImageSnapshot.captureBitmapData( parent );	
		}
		
		protected function setFullScreen(active:Boolean):void
		{
			Tracer.log(this, "setFullScreen: "+videoPresenter);
			if(!videoPresenter)
				return;
			
			videoPresenter.presenter.resetVideoPresenterScale();
			
			if(active) 
			{
				videoPresenter.presenter.fullScreen = true;
				_formerVideoSize = new Rectangle(0, 0, videoInfo.video.width, videoInfo.video.height);
				videoInfo.broadcastDimensionsChange( UtilsVideoReceiver.getFullScreenDimensions(_model.mainScreen), true );
				videoPresenter.presenter.updateFilmReelVisible();
			}
			else
			{
				videoPresenter.presenter.fullScreen = false;
				videoInfo.broadcastDimensionsChange( _formerVideoSize, true );
				videoPresenter.presenter.updateFilmReelVisible();
			}
		}
		
		protected function setMuted(muted:Boolean):void
		{
			Tracer.log(this, "setMuted - muted: "+muted);
			videoInfo.netStream.soundTransform = (muted) ? UtilsMedia.noSound : UtilsMedia.fullSound;
			videoInfo.volumeMuted = muted;
		}
	}
}