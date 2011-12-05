package uk.co.baremedia.airVideoMonitor.utils
{
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	import com.projectcocoon.p2p.vo.MediaVO;
	
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	import net.mariovieira.utils.math.UtilsEvenNumber;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.HGroup;
	import spark.components.View;
	import spark.components.supportClasses.GroupBase;
	import spark.primitives.Rect;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsP2PComm;
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.model.ModelVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.view.components.CompVideoHolder;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideoPresenter;
	import uk.co.baremedia.gnomo.utils.Resizer;
	import uk.co.baremedia.gnomo.utils.UtilsMedia;
	
	public class UtilsVideoReceiver
	{
		private static var _firstVideoSize:Rectangle;
		
		public static function watchBroadcaster(mediaInfo:MediaVO, videosModel:Vector.<VOVideo>,  netConnection:NetConnection, model:ModelAIRMonitor):void
		{
			//Tracer.log(UtilsVideoReceiver, "watchBroadcaster - mediaInfo.broadcasterUID: "+mediaInfo.broadcasterUID);
			var videoIndexInModel:int = isPlayingVideo(mediaInfo.broadcasterUID, videosModel);
			var isVideoAlreadyPlaying:Boolean 	= (videoIndexInModel != -1);
			
			if(isVideoAlreadyPlaying)
				var foundVideoInfo:VOVideo = videosModel[videoIndexInModel];
			
			/*****  TRIPLE CHECK !!! - CHECING 14:17 / 5th Nov *****/
			//get respective video presenter
			var videoPresenter:VOVideoPresenter = getVideoPresenter(model, foundVideoInfo);
			
			////get the video presenter container dimensions | TIED to the first / top screen resolution
			if(!_firstVideoSize) 
				_firstVideoSize = getTransmissionVideoSize(videoPresenter.constainer);
			
			var added:Boolean = addVideoToModel( setupVideo(netConnection, mediaInfo, videoPresenter, videosModel, model, model.appScreens, foundVideoInfo)  , videosModel);
			
			if(added)
				videoPresenter.presenter.updateFilmReelVisible();
			
			//Tracer.log(UtilsVideoReceiver, "watchBroadcaster - video added to model - added: "+added+" videosModel.length: "+videosModel.length);
		}
		
		private static function addVideoToModel(videoItem:VOVideo, videoModel:Vector.<VOVideo>):Boolean
		{
			if( videoItem )
			{
				videoModel.push( videoItem );
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private static function setupVideo(netConnection:NetConnection, mediaInfo:MediaVO, videoPresenter:VOVideoPresenter, videos:Vector.<VOVideo>, model:ModelAIRMonitor, appScreens:ModelVideoPresenter, foundVideo:VOVideo):VOVideo
		{
			var isVideoAlreadyPlaying	:Boolean = (foundVideo != null);
			var currentVideoInfo		:VOVideo = (isVideoAlreadyPlaying) ? foundVideo : new VOVideo();
			var hasChanges				:Boolean = (!isVideoAlreadyPlaying) ? true : mediaInfo.backNotFrontCamera != foundVideo.backNotFrontCamera; 
			
			//if no changes (same broadcaster, same camera index, skip it all)
			if(!hasChanges)
				return null;
			
			//keep its location for removing it
			if(!isVideoAlreadyPlaying)
				currentVideoInfo.screenIndex = videoPresenter.screenIndex;
			
			//reset any zoom gestures
			UtilsVideoPresenter.resetScale(videoPresenter.presenter.videoPresenter as UIComponent);
			
			//video and nestream before "tranferMediaInfoToVideoInfo" otherwise it would not detect changes (back and fron cam)
			var video:Video = getVideo( getNewNetStreamIfAnyChanges(netConnection, mediaInfo, foundVideo, currentVideoInfo) );	
			
			currentVideoInfo = tranferMediaInfoToVideoInfo(mediaInfo,  currentVideoInfo);
			currentVideoInfo = updateVideoPlayer(video, currentVideoInfo);
			var tmpVideoHolder:CompVideoHolder = (!isVideoAlreadyPlaying) ? null : getExistingVideoHolder(currentVideoInfo, videoPresenter);
				
			currentVideoInfo.holder = getUpdatedVideoHolder(currentVideoInfo, videoPresenter, model, tmpVideoHolder);
			
			if(!isVideoAlreadyPlaying)
				videoPresenter.presenter.videoPresenter.addElement(currentVideoInfo.holder);
			
			return currentVideoInfo;
		}
		
		private static function getExistingVideoHolder(currentVideoInfo:VOVideo, videoPresenter:VOVideoPresenter):CompVideoHolder
		{
			for (var i:int; i < videoPresenter.presenter.videoPresenter.numElements; i++)
			{
				var comp:CompVideoHolder = CompVideoHolder( videoPresenter.presenter.videoPresenter.getElementAt(i) );
				Tracer.log(UtilsVideoReceiver, "comp: "+comp); 
				
				if(comp.videoInfo.broadcasterUID == currentVideoInfo.broadcasterUID)
				{
					return comp;
				}
			}
			
			return null;
		}
		
		private static function getUpdatedVideoHolder(currentVideoInfo:VOVideo, videoPresenter:VOVideoPresenter, model:ModelAIRMonitor, exstingVideoHolder:CompVideoHolder = null):CompVideoHolder
		{
			var tmpHolder:CompVideoHolder = (!exstingVideoHolder) ? new CompVideoHolder() : exstingVideoHolder;
			
			currentVideoInfo.holder					= tmpHolder;
			currentVideoInfo.displayContainer		= videoPresenter.presenter.videoPresenter;					
			currentVideoInfo.holder.videoInfo		= currentVideoInfo;
			currentVideoInfo.holder.model			= model;
			//ensures that the video gets updated in the UI
			if(tmpHolder.allPartsAdded)
				tmpHolder.udpateUI();
			
			//update video presenter for full screen 
			tmpHolder.videoPresenter = videoPresenter;
			
			return tmpHolder;
		}
		
		private static function updateVideoPlayer(newVideo:Video, currentVideoInfo:VOVideo):VOVideo
		{
			if(newVideo)
			{
				UtilsDisposer.disposeVideoInfo( currentVideoInfo );
				currentVideoInfo.video = newVideo;
				
				return currentVideoInfo;
			}
			
			return null;
		}
		
		private static function getNewNetStreamIfAnyChanges(netConnection:NetConnection, mediaInfo:MediaVO, tmpPreviousVideoInfo:VOVideo, currentVideoInfo:VOVideo):NetStream
		{
			var hasChanged	:Boolean = (!tmpPreviousVideoInfo) ? true : (mediaInfo.backNotFrontCamera != tmpPreviousVideoInfo.backNotFrontCamera);
			var muted		:Boolean;
			
			//needs closing previous stream to play a new one
			if(hasChanged && tmpPreviousVideoInfo)
			{
				UtilsDisposer.disposeNetStream(tmpPreviousVideoInfo.netStream);
				muted = tmpPreviousVideoInfo.volumeMuted;
			}
			
			//needs to play a new stream if changes
			if(hasChanged)
			{
				var validNetStream:NetStream 	= new NetStream(netConnection, mediaInfo.publisherGroupspecWithAuthorization);
				validNetStream.soundTransform 	= (muted) ? UtilsMedia.noSound : UtilsMedia.fullSound;
				validNetStream.play(mediaInfo.publisherStream);
				currentVideoInfo.netStream 		= validNetStream; 
				
				return validNetStream;
			}
			//regardless the case the caller of this operation can assign the returned result (less conditions)
			else
			{
				return null;	
			}
		}
		
		//returns null if no netStresm provided
		private static function getVideo(receiveStream:NetStream):Video
		{
			if(!receiveStream)
				return null;
			
			var video:Video = new Video(_firstVideoSize.width, _firstVideoSize.height);
			video.smoothing = true;
			video.attachNetStream(receiveStream);
			
			return video;
		}
		
		private static function tranferMediaInfoToVideoInfo(mediaInfo:MediaVO, videoInfo:VOVideo):VOVideo
		{
			var validVideoInfo:VOVideo = (videoInfo) ? videoInfo : new VOVideo();
			
			validVideoInfo.broadcasterUID			= mediaInfo.broadcasterUID;
			validVideoInfo.requesterUID				= mediaInfo.requesterUID;
			validVideoInfo.publisherPeerId			= mediaInfo.publisherFarID;
			validVideoInfo.hasTwoBroadcastCameras 	= mediaInfo.broadcasterHasTwoCameras;
			validVideoInfo.backNotFrontCamera 	   	= mediaInfo.backNotFrontCamera;
			
			return validVideoInfo;
		}
		
		public static function getVideoPresenter(model:ModelAIRMonitor, foundVideoInfo:VOVideo = null):VOVideoPresenter
		{
			if(foundVideoInfo)
			{
				//Tracer.log(UtilsVideoReceiver, "getVideoPresenter - "+foundVideoInfo);
				return model.appScreens.screens[foundVideoInfo.screenIndex];
			}
			else if(model.isDualScreen)
			{
				return getVideoItemPresenterScreen(model.videosModel.length, model.appScreens, false);
			}
			else
			{
				return model.appScreens.screens[0]; 
			}
		}		
		
		//first video (video presenter index 0) goes to first screen (if isDualScreen), second video to 2nd screen (video presenter index 1)
		private static function getVideoItemPresenterScreen(currentVideoModelLenght:Number, videoPresenterScreensModel:ModelVideoPresenter, isVideoAlreadyPlaying:Boolean):VOVideoPresenter
		{
			//increments one if new video (yet to be added to model at this point)
			//note: length is index +1, so current index is length - 1, and incremented is lenght (which is index + 1) 
			var videoIndexInModel:int = (isVideoAlreadyPlaying) ? currentVideoModelLenght - 1: currentVideoModelLenght; 
			//Tracer.log(UtilsVideoPresenter, "getVideoItemPresenterScreen - isEvenNumber: "+UtilsEvenNumber.isEvenNumber(videoIndexInModel)+" videoPresenterScreensModel: "+videoPresenterScreensModel);
			
			if(videoIndexInModel == -1 || !videoPresenterScreensModel)
				return null;
			
			var isDualScreen:Boolean = videoPresenterScreensModel.screens.length > 1;
			return ( UtilsEvenNumber.isEvenNumber(videoIndexInModel) || !isDualScreen) ? videoPresenterScreensModel.screens[0] : videoPresenterScreensModel.screens[1];
		}
		
		public static function isVideoAdded(videoId:String, videoModel:Vector.<VOVideo>):Boolean
		{
			for each(var videoItem:VOVideo in videoModel)
			{
				if(videoItem.broadcasterUID == videoId) return true;
			}
			
			return false;
		}
		
		public static function getTransmissionVideoSize(uiComponent:UIComponent):Rectangle
		{
			var tmpRect:Rectangle = new Rectangle(0, 0, uiComponent.width, uiComponent.height);
			return (uiComponent.height > uiComponent.width) ? Resizer.scaleByAspectRatio(320, 240, 0, getHeightOrWidth(false, tmpRect) ) : Resizer.scaleByAspectRatio(320, 240, 0, getHeightOrWidth(true, tmpRect) );
		}
		
		protected static function getHeightOrWidth(heightNotWidth:Boolean, mainContainerDimensions:Rectangle):Number
		{
			//var halfSize:Boolean = (FlexGlobals.topLevelApplication.applicationDPI <= DPIClassification.DPI_240 && (mainContainerDimensions.width >= 960 || mainContainerDimensions.height >= 960) );
			//Tracer.log(UtilsVideoPresenter, "getHeightOrWidth - mainContainerDimensions.height: "+mainContainerDimensions.height);
			
			var reductionFactor:Number = (heightNotWidth && mainContainerDimensions.height < 500) ? 1.15 : 1.5;
			
			if(heightNotWidth)  return (heightNotWidth) ? mainContainerDimensions.height / reductionFactor : mainContainerDimensions.height;
			else 				return (heightNotWidth) ? mainContainerDimensions.width  / reductionFactor : mainContainerDimensions.width;
		}
		
		public static function stopPlayingAllVideos(videos:Vector.<VOVideo>, appScreens:ModelVideoPresenter, channel:LocalNetworkDiscovery = null, appId:String = null):void
		{
			var isDualScreen		:Boolean = appScreens.screens.length > 1;
			
			var modelIndex:int = 0;
			var tmpVideos:Vector.<VOVideo> = getDuplicatedModel(videos);
			
			for each(var videoInfo:VOVideo in tmpVideos)
			{
				removeVideo(videoInfo, appScreens, videos);
				
				if(channel && appId)
					UtilsNetworkMessenger.releaseBroadcasterIfApplicable(videoInfo, appId, channel);
				
				modelIndex++;
			}
		}
		
		private static function getDuplicatedModel(videos:Vector.<VOVideo>):Vector.<VOVideo>
		{
			var tmpVideos:Vector.<VOVideo> = new Vector.<VOVideo>;
			
			for each(var videoInfo:VOVideo in videos)
			{
				tmpVideos.push(videoInfo);
			}
			
			return tmpVideos;
		}		
		
		private static function setupVideoAlreadyPlaying(videoItem:VOVideo, view:IVisualElementContainer):void
		{
			view.addElement(videoItem.holder);
		}
		
		private static function getBroadcasterName(mediInfo:MediaVO):String
		{
			return EnumsP2PComm.BROADCASTER + String(mediInfo.broadcasterUID);
		}
		 
		public static function stopVideoIfPlaying(broadcasterUID:String, videos:Vector.<VOVideo>, appScreens:ModelVideoPresenter, checksIfVideoIsPlayingBeforeRemoving:Boolean = true):Boolean
		{
			var videoRemovedFromModel:VOManagedVideoInfo;
			
			for each(var videoInfo:VOVideo in videos)
			{
				if(videoInfo.broadcasterUID == broadcasterUID)
				{
					videoRemovedFromModel = removeVideo(videoInfo, appScreens, videos);
				}
			}
			
			//if no other videos is playing in this videoPresenter then update filmReelVisible
			if(videoRemovedFromModel && !videoRemovedFromModel.isThereMoreVideosInThisPresenter)
				appScreens.screens[videoRemovedFromModel.screenIndex].presenter.updateFilmReelVisible();
			
			return videoRemovedFromModel;
		}
		
		public static function isPlayingVideo(broadcasterUID:String, videos:Vector.<VOVideo>):int 
		{
			for(var i:int; i < videos.length; i++) 
			{
				if(videos[i].broadcasterUID == broadcasterUID) 
					return i;
			}
			
			return -1;
		}
		
		public static function removeVideo(videoItem:VOVideo, appScreens:ModelVideoPresenter, videoModel:Vector.<VOVideo>):VOManagedVideoInfo
		{
			var videoRemovedFromModelInfo:VOManagedVideoInfo = new VOManagedVideoInfo();
			
			//Tracer.log(UtilsVideoReceiver,  "appScreens: "+appScreens);
			var foundVideoPresenter:VOVideoPresenter 	= appScreens.screens[videoItem.screenIndex];
			var foundView:IVisualElementContainer 		= foundVideoPresenter.presenter.videoPresenter;
			var videoModelIndex:int = getVideoIndexInModel(videoItem, videoModel);
			
			//1 - remove video from view
			if(foundView)
			{
				for(var i:int; i < foundView.numElements; i++) 
				{
					var iteratedItem:CompVideoHolder = CompVideoHolder( foundView.getElementAt(i) );
					
					//detects whether this presenter has more videos playing
					if(iteratedItem && iteratedItem.videoInfo.screenIndex == videoItem.screenIndex)
					{
						videoRemovedFromModelInfo.isThereMoreVideosInThisPresenter = true;
						videoRemovedFromModelInfo.screenIndex = videoItem.screenIndex;
					}
					
					
					//Tracer.log(UtilsVideoReceiver, "removeVideo - VIEW - iteratedItem from loop: "+iteratedItem);
					if(iteratedItem && iteratedItem.videoInfo.broadcasterUID == videoItem.broadcasterUID)
					{
						try{ foundView.removeElementAt(i) } catch(er:Error){ Tracer.log(UtilsVideoReceiver, "CAN'T remove video from view"); };	
					}
				}
			}
			
			//2 - dispose video instance
			if(videoModelIndex != -1)
			{
				videoRemovedFromModelInfo.videoRemoved = true;
				
				if(videoItem)
				{
					videoItem.dispose();
					videoItem.netStream.attachCamera(null);
					videoItem.netStream.close();
					videoItem.video = null;
					videoItem = null;
					//Tracer.log(UtilsVideoReceiver, "removeVideo - dispose videoItem");
				}
				else
				{
					//Tracer.log(UtilsVideoReceiver, "removeVideo - CAN't dispose videoItem");
				}
				
				//Tracer.log(UtilsVideoReceiver, "removeVideo - MODEL");
				
				//3 - remove video from model
				videoModel.splice(videoModelIndex, 1);
			}
			else
			{
				//Tracer.log(UtilsVideoReceiver, "removeVideo - MODEL - CAN'T REMOVE - index -1");
			}
			
			if(foundVideoPresenter)
				foundVideoPresenter.presenter.fullScreen = false;
				foundVideoPresenter.presenter.updateFilmReelVisible();
			
			return videoRemovedFromModelInfo;
		}
		
		private static function getVideoIndexInModel(videoItem:VOVideo, videosModel:Vector.<VOVideo>):int
		{
			var index:int = 0;
			for each(var videoInfo:VOVideo in videosModel)
			{
				if(videoInfo.broadcasterUID == videoItem.broadcasterUID)
				{
					return index;
				}
				
				index++;
			}
			
			return -1;
		}
		
		public static function get activeView():View
		{
			return FlexGlobals.topLevelApplication.navigator.activeView;
		}
		
		
		public static function getFullScreenDimensions(container:Object):Rectangle
		{
			return (container.height > container.width) ? Resizer.scaleByAspectRatio(640, 480, 0, container.width) : Resizer.scaleByAspectRatio(640, 480, container.height); 
		}
		
		public static function stopBroadcastByPeerId(peerID:String, videosModel:Vector.<VOVideo>, appScreens:ModelVideoPresenter):VOVideo
		{
			for(var i:int; i < videosModel.length; i++)
			{
				//Tracer.log(UtilsVideoReceiver, "stopBroadcastByPeerId - videosModel[i]: "+videosModel[i]+" videosModel[i]: "+videosModel[i].publisherPeerId);
				
				if(videosModel[i].publisherPeerId == peerID)  
				{
					var videoInfo:VOVideo = videosModel[i];
					
					removeVideo(videoInfo, appScreens, videosModel);
					
					return videoInfo;
				}
			}
			
			return null;
		}
	}
}