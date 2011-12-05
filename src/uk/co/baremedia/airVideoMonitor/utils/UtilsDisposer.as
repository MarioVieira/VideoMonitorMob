package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.net.NetStream;
	
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	
	public class UtilsDisposer
	{
		public static function disposeVideoInfo(videoInfo:VOVideo):Boolean
		{
			if(!videoInfo);
				return false;
				
			videoInfo.dispose();
			disposeNetStream(videoInfo.netStream);
			videoInfo.video = null;
			
			return true;
		}
		
		public static function disposeNetStream(netStream:NetStream):Boolean
		{
			if(!netStream);
				return false;
			
			netStream.attachCamera(null);
			netStream.close();
			
			return true;
		}
	}
}