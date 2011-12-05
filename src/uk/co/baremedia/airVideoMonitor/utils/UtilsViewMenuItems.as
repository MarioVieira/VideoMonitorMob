package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.events.MouseEvent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.ViewMenuItem;
	
	import uk.co.baremedia.airVideoMonitor.controls.ControlAIRVideoMonitor;
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class UtilsViewMenuItems
	{
		
		private static var getCameras				:ViewMenuItem;
		private static var stopSending				:ViewMenuItem;
		private static var stopPlaying				:ViewMenuItem;
		private static var requestDefaultQuality	:ViewMenuItem;
		private static var requestHDQuality			:ViewMenuItem;
		
		//if it have never been initialized
		public static function setupStaticButtons(control:ControlAIRVideoMonitor):void
		{
			if(!getCameras) createAllButtons(control);
		}
		
		public static function getViewMenuItems(control:ControlAIRVideoMonitor):Vector.<ViewMenuItem>
		{
			updateTexts();
			
			var menuItems:Vector.<ViewMenuItem> = new Vector.<ViewMenuItem>;
			if(control.receiving)
			{
				menuItems.push( stopPlaying );
			}
			if(control.broadcasting)
			{
				menuItems.push( stopSending );
			}
			if(control.receiving || control.broadcasting)
			{
				//Tracer.log(UtilsViewMenuItems, "hdQuality: "+control.model.hdQuality);
				menuItems.push( (control.model.hdQuality) ? requestDefaultQuality : requestHDQuality );
			}
			
			menuItems.push( getCameras );
			return menuItems;
		}
		
		
		protected static function createAllButtons(control:ControlAIRVideoMonitor):void
		{
			getCameras	= new ViewMenuItem();
			getCameras.addEventListener(MouseEvent.CLICK, control.onGetFrontCam);
			
			stopSending = new ViewMenuItem();
			stopSending.addEventListener(MouseEvent.CLICK, control.onStopSending);
			
			stopPlaying = new ViewMenuItem();
			stopPlaying.addEventListener(MouseEvent.CLICK, control.onStopPlaying);
			
			requestHDQuality  = new ViewMenuItem();
			requestHDQuality.addEventListener(MouseEvent.CLICK, control.onRequestHDQuality);
			
			requestDefaultQuality  = new ViewMenuItem();
			requestDefaultQuality.addEventListener(MouseEvent.CLICK, control.onRequestDefaultQuality);	
			
			updateTexts();
		}
		
		protected static function updateTexts():void
		{
			requestDefaultQuality.label = UtilsResources.getKey(EnumsLanguage.REQUEST_DEFAULT_QUALITY);
			requestHDQuality.label = UtilsResources.getKey(EnumsLanguage.REQUEST_HD_QUALITY);
			stopPlaying.label = UtilsResources.getKey(EnumsLanguage.STOP_PLAYING);
			getCameras.label = UtilsResources.getKey(EnumsLanguage.GET_CAMERAS);
			stopSending.label = UtilsResources.getKey(EnumsLanguage.STOP_SENDING);
		}
	}
}