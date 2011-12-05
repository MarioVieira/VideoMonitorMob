package uk.co.baremedia.airVideoMonitor.vo
{
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.core.IVisualElementContainer;
	
	import org.as3.mvcsInjector.interfaces.IDispose;
	import org.osflash.signals.Signal;
	
	import uk.co.baremedia.airVideoMonitor.view.components.CompVideoHolder;
	
	[Bindable]
	public class VOVideo implements IDispose
	{
		public var changeDimensionsSignal:Signal;
		public var removeVideoChat		:Signal;
		public var defaultScreenWidth   :Number;
		public var videoChatOn			:Boolean;
		public var defaultScreenHeight  :Number;
		public var broadcasterUID		:String;
		public var requesterUID			:String;
		public var video				:Video;
		public var netStream			:NetStream;
		public var holder				:CompVideoHolder;
		public var displayContainer		:Object;
		public var publisherPeerId		:String;
		public var volumeMuted			:Boolean;
		public var hasTwoBroadcastCameras:Boolean;
		public var backNotFrontCamera	:Boolean;
		public var hasCamera			:Boolean;
		public var screenIndex			:int;
		
		public function VOVideo() 
		{
			changeDimensionsSignal = new Signal(Rectangle, Boolean);
			removeVideoChat		   = new Signal();
		}
		
		public function broadcastDimensionsChange(dimensions:Rectangle, animated:Boolean = false)
		{
			changeDimensionsSignal.dispatch(dimensions, animated);
		}

		public function dispose(recursive:Boolean=true):void
		{
			changeDimensionsSignal.removeAll();
			removeVideoChat.removeAll();
		}
	}
}