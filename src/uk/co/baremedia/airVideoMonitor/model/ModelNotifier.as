package uk.co.baremedia.airVideoMonitor.model
{
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.MediaBroadcastEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.vo.BroadcasterVo;
	import com.projectcocoon.p2p.vo.MediaVO;
	import com.projectcocoon.p2p.vo.MessageVO;
	
	import org.as3.mvcsInjector.interfaces.IDispose;
	import org.as3.mvcsInjector.utils.Tracer;
	import org.osflash.signals.Signal;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.airVideoMonitor.enums.EnumsP2PComm;
	import uk.co.baremedia.airVideoMonitor.vo.VOBroadcaster;
	import uk.co.baremedia.gnomo.utils.UtilsDate;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class ModelNotifier implements IDispose
	{
		public const EVENT_LISTENER:String = "EventListener";
		
		private static var _instance:ModelNotifier;
		
		private var _channel			:LocalNetworkDiscovery;
		private var _model				:ModelAIRMonitor;
		
		public var updateNotifierSignal	:Signal;
		public var clientUpdateSignal	:Signal;
		
		private var _lastOrder			:String;
		private var _lastMessage		:Object;
		
		/******************************** LOGIC ********************************/
		
		public function set channel(value:LocalNetworkDiscovery):void
		{
			if(!_channel)
			{
				_channel = value;
				observerChannel();
			}
		}
		
		public function set model(value:ModelAIRMonitor):void
		{
			_model = value;
		}
		
		public function set updateNotifierText(value:String):void
		{
			updateNotifierSignal.dispatch(value); 
		}
		
		private function clientUpdated(addedNotRemoevd:Boolean):void
		{
			var text:String = (addedNotRemoevd) ? getText(EnumsLanguage.CLIENT_ADDED) : getText(EnumsLanguage.CLIENT_REMOVED);
			clientUpdateSignal.dispatch( text + " " + getFormattedTime() );
		}
		
		private function handleNetworkMessage(message:MessageVO, mediaInfo:MediaVO):void
		{
			if(message)
			{
				_lastOrder 		= VOBroadcaster(message.data).request
				_lastMessage 	= message;
			}
			else
			{
				_lastOrder  	= mediaInfo.order;
				_lastMessage 	= mediaInfo; 
			}
			
			//Tracer.log(this, "handleNetworkMessage - order: "+order);
			handleOrder(_lastOrder, _lastMessage);
		}
		
		private function handleOrder(order:String, message:Object):void
		{
			switch(order)
			{
				case(EnumsP2PComm.REQUEST_FRONT_CAM_AND_MIC):
					if( VOBroadcaster(message.data).broadcasterUID == _model.appId )
						updateNotifierText = getText(EnumsLanguage.CAMERA_REQUESTED);
					break;
				
				case(EnumsP2PComm.BROADCAST_STOPPED):
					if( VOBroadcaster(message.data).broadcasterUID == _model.appId ) 
						updateNotifierText = getText(EnumsLanguage.STOP_PLAYING_STOPPED_BROADCAST);
					break;
				
				case(EnumsP2PComm.BROADCAST_STOPPED_USER_TO_USER):
					if( VOBroadcaster(message.data).broadcasterUID == _model.appId )
						updateNotifierText = getText(EnumsLanguage.BROADCAST_STOPPED);
					break;
				
				case(EnumsP2PComm.RELEASE_CAM_AND_MIC):
					if( VOBroadcaster(message.data).broadcasterUID == _model.appId )
						updateNotifierText = getText(EnumsLanguage.BROADCAST_STOPPED);
					break;
				
				case(EnumsP2PComm.SENDING_STREAM):
					if( message.requesterUID == _model.appId )
						updateNotifierText = getText(EnumsLanguage.CAMERA_AND_MIC_ARRIVED);
					break;
				
				//both from message and mediaInfo
				case(EnumsP2PComm.SWAP_CAMERA):
					if( _model.broadcasting )
						var notificationKey:String = (message) ? EnumsLanguage.SWAP_CAMERA_REQUEST : EnumsLanguage.BROADCAST_SWAP_CAMERA;
					updateNotifierText = getText(notificationKey);
					break;
				
				case(EnumsP2PComm.VIDEO_QUALITY_CHANGE_HIGH):
					if( _model.broadcasting )
						updateNotifierText = getText(EnumsLanguage.CHANGE_CAMERA_QUALITY) + getText( EnumsLanguage.HIGH_QUALITY );
					break;
				
				case(EnumsP2PComm.VIDEO_QUALITY_CHANGE_DEFAULT):
					if( _model.broadcasting )
						updateNotifierText = getText(EnumsLanguage.CHANGE_CAMERA_QUALITY) + getText( EnumsLanguage.DEFAULT_QUALITY );
					break; 
			}
			
		}
		
		private function getText(key:String):String
		{
			return UtilsResources.getKey(key);
		}
		
		private function getFormattedTime():String
		{
			return "("+UtilsDate.getReabeableTime( new Date().getTime() , false) +")";
		}
		
		/******************************** HANDLERS ********************************/
		
		protected function onNetworkMessage(event:MessageEvent):void
		{
			handleNetworkMessage(event.message, null);
		}
		
		protected function onMediaBroadcast(event:MediaBroadcastEvent):void
		{
			handleNetworkMessage(null, event.mediaInfo)
		}
		
		protected function onClientAdded(event:ClientEvent):void
		{
			clientUpdated(true);
		}
		
		protected function onClientRemoved(event:ClientEvent):void
		{
			clientUpdated(false);
		}
		
		/******************************** SETUP ********************************/
		
		private function observerChannel(subscribeNotRemove:Boolean = true):void
		{
			var addOrRemove:String = (subscribeNotRemove) ? "add" : "remove";
			
			UtilsResources.bundleChange[addOrRemove](onBundleChange);
			
			_channel[addOrRemove+EVENT_LISTENER](MediaBroadcastEvent.MEDIA_BROADCAST, onMediaBroadcast);
			_channel[addOrRemove+EVENT_LISTENER](ClientEvent.CLIENT_ADDED, onClientAdded);
			_channel[addOrRemove+EVENT_LISTENER](ClientEvent.CLIENT_REMOVED, onClientRemoved);
			_channel[addOrRemove+EVENT_LISTENER](MessageEvent.DATA_RECEIVED, onNetworkMessage);
		}
		
		protected function onBundleChange():void
		{
			//Tracer.log(this, "onBundleChange");
			handleOrder(_lastOrder, _lastMessage);
		}
		
		
		public function ModelNotifier(blocker:SingletonBlocker)
		{
			if(!blocker) throw new Error("use ModelNotifier.instance");
		}
		
		public static function get instance():ModelNotifier
		{
			if(!_instance) 
			{
				_instance = new ModelNotifier(new SingletonBlocker());
				initialize();
			}
			return _instance;	
		}
		
		
		private static function initialize():void
		{
			_instance.updateNotifierSignal = new Signal(String);
			_instance.clientUpdateSignal   = new Signal(String);
			
		}

		public function dispose(recursive:Boolean=true):void
		{
			observerChannel(false);
		}
	}
}

class SingletonBlocker{}