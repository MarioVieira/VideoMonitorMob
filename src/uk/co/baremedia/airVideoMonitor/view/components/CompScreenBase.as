package uk.co.baremedia.airVideoMonitor.view.components
{
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenterOwner;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	
	public class CompScreenBase extends SkinnableComponent  implements IVideoPresenterOwner
	{
		[SkinPart(required="true")]
		public var videoPresenter	:CompVideoPresenter;
		
		[Bindable]
		public var model			:ModelAIRMonitor;
		
		public function CompScreenBase()
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
		
		public function get videoPresenterComp():CompVideoPresenter
		{
			return videoPresenter;
		}
	}
}