package uk.co.baremedia.airVideoMonitor.view.components
{
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.vo.VOHelpItem;
	
	public class CompHelpItem extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var label			:Label;
		
		[Bindable] public var hasBottomRuler	:Boolean;
		
		private var _info			:VOHelpItem;
		
		public function CompHelpItem()
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
			
			if(instance == label)
			{
				setLabel();
			}
		}
		
		private function setLabel():void
		{
			if(_info && label) label.text = _info.label;
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public function set info(value:VOHelpItem):void
		{
			_info = value;
			setLabel();
		}
		
		public function get info():VOHelpItem
		{
			return _info;
		}
	}
}