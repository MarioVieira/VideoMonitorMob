package uk.co.baremedia.airVideoMonitor.utils
{
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsP2PComm;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	
	public class UtilsNetworkMessenger
	{
		public static function releaseRequestedBroadcasts(requesterUID:String, videosModel:Vector.<VOVideo>, channel:LocalNetworkDiscovery):void
		{
			for each(var broadcasterInfo:VOVideo in videosModel)
			{
				if(broadcasterInfo.requesterUID == requesterUID)
				{
					//Tracer.log(UtilsNetworkMessenger, "releaseAllBroadcastersCamAndMic - release a requested broadcast: "+broadcasterInfo.broadcasterUID);
					releaseBroadcasterCamAndMic(broadcasterInfo.broadcasterUID, requesterUID, channel);	
				}
			}
		}
		
		public static function releaseBroadcasterCamAndMic(broadcasterUID:String, requesterUID:String, channel:LocalNetworkDiscovery):void
		{
			channel.sendMessageToAll( UtilsGetBroadcasterMessage.getMessage(EnumsP2PComm.RELEASE_CAM_AND_MIC, broadcasterUID, requesterUID) );
		}
		
		public static function stopBroadcastingToUser(userUID:String, broadcasterUID:String, channel:LocalNetworkDiscovery):void
		{
			channel.sendMessageToAll( UtilsGetBroadcasterMessage.getMessage(EnumsP2PComm.BROADCAST_STOPPED_USER_TO_USER, broadcasterUID, userUID) );
		}
		
		public static function stopBroadcastingToGroup(appId:String, channel:LocalNetworkDiscovery, requesterUID:String = null):void
		{
			channel.sendMessageToAll( UtilsGetBroadcasterMessage.getMessage(EnumsP2PComm.BROADCAST_STOPPED, appId, requesterUID) );
		}
		
		public static function requestAllNetworkCameras(backNotFront:Boolean, requesterID:String, channel:LocalNetworkDiscovery):void
		{
			channel.sendMessageToAll( UtilsGetBroadcasterMessage.getMessage( (backNotFront) ? EnumsP2PComm.REQUEST_BACK_CAM_AND_MIC : EnumsP2PComm.REQUEST_FRONT_CAM_AND_MIC, null, requesterID) );	
		}
		
		public static function swapBroadcasterCameras(channel:LocalNetworkDiscovery, broadcasterUID:String, requesterUID:String):void
		{
			channel.sendMessageToAll( UtilsGetBroadcasterMessage.getMessage(EnumsP2PComm.SWAP_CAMERA, broadcasterUID, requesterUID) );
		}
		
		public static function requestHDCameras(channel:LocalNetworkDiscovery, hdQuality:Boolean, requesterUID:String):void
		{
			var message:String = (hdQuality) ? EnumsP2PComm.VIDEO_QUALITY_CHANGE_HIGH : EnumsP2PComm.VIDEO_QUALITY_CHANGE_DEFAULT;
			channel.sendMessageToAll( UtilsGetBroadcasterMessage.getMessage(message, null, requesterUID) );
		}
		
		public static function releaseBroadcasterIfApplicable(videoInfo:VOVideo, appId:String, channel:LocalNetworkDiscovery):void
		{
			if(videoInfo.requesterUID == appId) 
			{
				UtilsNetworkMessenger.releaseBroadcasterCamAndMic(videoInfo.broadcasterUID, appId, channel);
			}
		}
	}
}