package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsUpdater;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class CompUpdater extends SkinnableComponent
	{
		[DefaultProperty("empty")]
		[SkinStates("update","updating","empty")]
		
		private var _updater	:UtilsUpdater;
		private var UPDATE 		:String = "update";
		private var UPDATING 	:String = "updating";
		
		[SkinPart(required="true")]
		public var updateNow			:Button;
		
		[SkinPart(required="true")]
		public var updateLater			:Button;
		
		[SkinPart(required="true")]
		public var okRemoveWindow		:Button;
		
		[Bindable] public function get currentVersion()	:String { return _updater.currentVersion };
		[Bindable] public function get latestVersion()		:String { return _updater.latestVersion };
		[Bindable] public function get description()		:String	{ return _updater.description };
		[Bindable] public function get fileName()			:String	{ return _updater.fileName };
		
		[Bindable(event="updateState")]
		private var _updateState:int = 2; //0 updater, 1 updating, 2 empty 
		
		public function CompUpdater()
		{
			super();
			_updater = new UtilsUpdater();
			
			CONFIG::DESKTOP
			{
				checkForUpdates();
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			if(_updateState == 0)
			{
				//Tracer.log(this, "getCurrentSkinState: "+UPDATE);
				return UPDATE;
			}
			else if(_updateState == 1)
			{
				//Tracer.log(this, "getCurrentSkinState: "+UPDATING);
				return UPDATING;
			}
			else
			{
				//Tracer.log(this, "getCurrentSkinState: empty");
				return "empty";
			}
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if(instance == updateNow)
			{
				updateNow.addEventListener(MouseEvent.CLICK, onUpdateNow);
			}
			else if(instance == updateLater)
			{
				updateLater.addEventListener(MouseEvent.CLICK, onUpdateLater);	
			}
			else if(instance == okRemoveWindow)
			{
				okRemoveWindow.addEventListener(MouseEvent.CLICK, onRemoveWindow);	
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == updateNow)
			{
				updateNow.removeEventListener(MouseEvent.CLICK, onUpdateNow);
			}
			else if(instance == updateLater)
			{
				updateLater.removeEventListener(MouseEvent.CLICK, onUpdateLater);	
			}
			else if(instance == okRemoveWindow)
			{
				okRemoveWindow.removeEventListener(MouseEvent.CLICK, onRemoveWindow);	
			}
		}
		
		protected function checkForUpdates():void
		{
			//Tracer.log(this, "checkForUpdates- getUpdateURL(): "+getUpdateURL() );
			
			_updater.addOnce(onHasUpdate);
			
			_updater.checkForUpdate(  getUpdateURL() );
		}
		
		private function getUpdateURL():String
		{
			return (CONFIG::SIGNED_RELEASE) ? UtilsResources.getKey(EnumsLanguage.UPDATE_URL_SIGNED) : UtilsResources.getKey(EnumsLanguage.UPDATE_URL);
		}
		
		private function onHasUpdate(hasUpdate:Boolean):void
		{
			//Tracer.log(this, "onHasUpdate - hasUpdate: "+hasUpdate);
			
			if(hasUpdate)
			{
				//Tracer.log(this, "onHasUpdate - state update");
				updateState = 0;
			}
		}
		
		private function onUpdateLater(event:MouseEvent):void
		{
			updateState = 2;
		}
		
		protected function onUpdateNow(event:MouseEvent):void
		{
			updateState = 1;
			_updater.downloadUpdate();
		}
		
		protected function onRemoveWindow(event:MouseEvent):void
		{
			updateState = 2;
		}
		
		private function set updateState(value:int):void
		{
			_updateState = value;
			dispatchEvent(new Event("updateState"));
			invalidateSkinState();
		}
		
		public function downloadUpdate():void
		{
			_updater.downloadUpdate();
		}
	}
}