package uk.co.baremedia.airVideoMonitor.utils
{
	import uk.co.baremedia.airVideoMonitor.vo.VOBroadcaster;
	
	public class UtilsGetBroadcasterMessage
	{
		public static function getMessage(request:String, broadcasterUID:String, requesterUID:String):VOBroadcaster
		{
			var vo:VOBroadcaster = new VOBroadcaster();
			
			vo.broadcasterUID	= broadcasterUID;
			vo.requesterUID     = requesterUID;
			vo.request 			= request;
			
			return vo;
		}
	}
}