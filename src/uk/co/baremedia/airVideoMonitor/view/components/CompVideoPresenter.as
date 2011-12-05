package uk.co.baremedia.airVideoMonitor.view.components
{
	
	import flash.events.TransformGestureEvent;
	
	import mx.core.IVisualElementContainer;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.HGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideoPresenter;
	
	public class CompVideoPresenter extends SkinnableComponent implements IVideoPresenter
	{
		[SkinPart(required="true")]
		public var presenter	:HGroup;
		
		[Bindable]
		public var model		:ModelAIRMonitor;
		
		[Bindable]
		public var filmReelVisible:Boolean;
		
		private var _fullScreen:Boolean;
		
		public function CompVideoPresenter()
		{
			super();
		}
		
		public function get videoPresenter():IVisualElementContainer
		{
			return presenter as IVisualElementContainer;
		}
		
		public function resetVideoPresenterScale():void
		{
			presenter.scaleX = presenter.scaleY = 1;
		}
		
		public function updateFilmReelVisible():void
		{
			 if(!presenter)
				 return;
			 
			filmReelVisible = (presenter.numElements > 0 && !_fullScreen);
		}
		
		public function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
		}
		
		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(instance == videoPresenter)
			{
				presenter.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			} 
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == videoPresenter)
			{
				presenter.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			}
		}
		
		protected function onZoom(e:TransformGestureEvent):void
		{
			//Tracer.log(this, "onZoom - "+model); 
			if(model.receiving && !_fullScreen)
			{	
				presenter.scaleX *= e.scaleX;
				presenter.scaleY *= e.scaleX;
			}
		}
	}
}