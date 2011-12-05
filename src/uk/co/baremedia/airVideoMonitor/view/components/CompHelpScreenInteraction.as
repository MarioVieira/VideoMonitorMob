package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsEmail;
	import uk.co.baremedia.airVideoMonitor.vo.VOHelpItem;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class CompHelpScreenInteraction extends SkinnableComponent
	{
		public static const URL_TYPE	:int = 1;
		public static const EMAIL_TYPE 	:int = 2;
		
		[SkinPart(required="true")]
		public var rateUs:CompHelpItem;
		
		[SkinPart(required="true")]
		public var feedback:CompHelpItem;
		
		[SkinPart(required="true")]
		public var reportProblem:CompHelpItem;
		
		public function CompHelpScreenInteraction()
		{
			super();
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			//rate us
			if( instance == rateUs && !UtilsDeviceInfo.isPC)
			{
				rateUs.addEventListener(MouseEvent.CLICK, onHelpScreenInteractiveItems);
			}
			else if(instance == feedback)
			{
				feedback.addEventListener(MouseEvent.CLICK, onHelpScreenInteractiveItems);
			}
			else if( instance == reportProblem )
			{
				reportProblem.addEventListener(MouseEvent.CLICK, onHelpScreenInteractiveItems);
			}
			
			if(rateUs && feedback && reportProblem)
			{
				updateLanguage();
			}
		}

		private function updateLanguage():void
		{
			feedback.info 		= new VOHelpItem(EMAIL_TYPE, resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.HELP_SCREEN_SEND_A_FEEDBACK), resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.EMAIL_HEADER_FEEDBACK), resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.EMAIL_BODY_FEEDBACK), null);
			rateUs.info 		= new VOHelpItem(URL_TYPE, resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.HELP_SCREEN_RATE_US), null, null, getUrl() );
			reportProblem.info 	= new VOHelpItem(EMAIL_TYPE, resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.HELP_SCREEN_REPORT_PROBLEM), resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.EMAIL_HEADER_PROBLEM), resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.EMAIL_BODY_PROBLEM), null);
		}
		
		private function getUrl():String
		{
			if(UtilsDeviceInfo.isIOS)
			{
				return resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.IOS_APP_LINK);	
			}
			else if(UtilsDeviceInfo.isAndroid)
			{
				CONFIG::AMAZON
				{
					return resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.AMAZON_APP_LINK);
				}
				return resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.ANDROID_APP_LINK);
			}
			else if(UtilsDeviceInfo.isPlaybook)
			{
				return resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.PLAYBOOK_APP_LINK);
			}
			
			return null;
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public function onHelpScreenInteractiveItems(event:MouseEvent):void
		{
			if(event.currentTarget is CompHelpItem) var info:VOHelpItem = CompHelpItem(event.currentTarget).info;
			//Tracer.log(this, "onHelpScreenInteractiveItems - info: "+info);
			
			if(info)
			{
				if(info.type == URL_TYPE)
				{
					navigateToURL( new URLRequest(info.url) );
				}
				else if(info.type == EMAIL_TYPE)
				{
					UtilsEmail.sendEmail( resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.APP_SUPPORT_EMAIL), info.subject, info.body );
				}
			}
		}
		
		public function update():void
		{
			updateLanguage();	
		}
	}
}