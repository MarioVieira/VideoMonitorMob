package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.IViewCursor;
	import mx.events.FlexEvent;
	import mx.managers.ICursorManager;
	
	import org.as3.mvcsInjector.utils.Tracer;
	import org.osmf.metadata.CuePoint;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.SpinnerList;
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.utils.UtilsLanguage;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class CompLanguagePanel extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var languageOptions:SpinnerList;
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == languageOptions)
			{
				languageOptions.addEventListener(Event.CHANGE, onLanguageChange);
			}
			else if(instance == languageOptions)
			{
				Tracer.log(this, "partAdded - languageOptions");
				updateLocale();
			}
		}
		
		public function onLanguageChange(event:Event):void
		{
			locale = event.currentTarget.selectedItem.key.toString();
		}

		private function set locale(value:String):void
		{
			UtilsResources.bundleName = value;
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if(instance == languageOptions)
			{
				languageOptions.removeEventListener(Event.CHANGE, onLanguageChange);
			}
		}
		
		public function updateLocale():void
		{
			setLocale = UtilsResources.bundleName;
		}
		
		public function onCheckIsSelected(e:Event):void
		{
			checkSelectedLanguage();
		}
		
		public function checkSelectedLanguage(forceLanguageSelection:String = null):void
		{
			var cursor:IViewCursor = UtilsLanguage.languages.createCursor();
			var index:int;
			var language:String = (!forceLanguageSelection) ? UtilsResources.bundleName : forceLanguageSelection;
			
			while(!cursor.afterLast)
			{
				if(cursor.current.key == UtilsResources.bundleName)
				{
					languageOptions.selectedIndex = index;
					break;	
				}
				
				index++;
				cursor.moveNext();
			}
		}
		
		public function set setLocale(locale:String):void
		{
			var cursor:IViewCursor = UtilsLanguage.languages.createCursor();
			var index:int;
			
			while(!cursor.afterLast)
			{
				if(cursor.current.key == locale)
				{
					languageOptions.selectedIndex = index;
					break;	
				}
				
				index++;
				cursor.moveNext();
			}
		}
	}
}