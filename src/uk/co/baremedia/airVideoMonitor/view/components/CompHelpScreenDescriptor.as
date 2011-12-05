package uk.co.baremedia.airVideoMonitor.view.components
{
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.view.elements.ButtonAction;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	
	
	public class CompHelpScreenDescriptor extends SkinnableComponent
	{
		private var _model:ModelAIRMonitor;
		
		[SkinPart(required="true")]
		public var currentIcon		:ButtonAction;
		
		[Bindable]
		public var currentItemId	:int;
		
		[Bindable] 
		public var itemName			:String;
		
		[Bindable] 
		public var itemFunction		:String = "";
		
		[Bindable] 
		public var itemAvailability	:String = "";
		
		[Bindable] 
		public var itemNotes		:String = "";
		
		public function CompHelpScreenDescriptor()
		{
			super();
			_model = ModelAIRMonitor.instance;
			
			update();
			
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(instance == currentIcon)
			{
				if(_model.helpScreenCurrentItemIcon) placeIcon(_model.helpScreenCurrentItemIcon);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public function set helpScreenItem(value:int):void
		{
			if(value != 0)
			{
				//if(!visible) visible = includeInLayout = true;
				currentItemId 		= _model.helpScreenCurrentItemId = value;
				itemName 			= resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.FUNCTION_NAME+"_"+value); 
				itemFunction 		= resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.FUNCTION+"_"+value);
				itemAvailability 	= resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.AVAILABILITY+"_"+value); 
				var tmpNotes:String = resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.NOTES+"_"+value);
				itemNotes 			= (tmpNotes) ? tmpNotes : "";
			}
			else
			{
				itemName = resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.HIT_BUTTONS_FOR_INFO);		
			}
		}
		
		public function placeIcon(icon:Class):void
		{
			//Tracer.log(this, "placeIcon - icon: "+icon);
			_model.helpScreenCurrentItemIcon = icon;
			currentIcon.iconActivate = icon;
			currentIcon.setActive(true);
		}
		
		public function update():void
		{
			helpScreenItem = _model.helpScreenCurrentItemId;
		}
	}
}