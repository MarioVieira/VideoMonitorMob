package uk.co.baremedia.airVideoMonitor.view.elements
{
	
	import spark.components.Button;
	
	
	
	public class ButtonClose extends Button
	{
		
		public function ButtonClose()
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
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}