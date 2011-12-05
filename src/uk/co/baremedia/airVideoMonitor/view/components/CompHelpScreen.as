package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.utils.NavigationUtil;
	
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.Button;
	import spark.components.Image;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableComponent;
	
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsViewNavigator;
	import uk.co.baremedia.airVideoMonitor.view.elements.ButtonAction;
	
	public class CompHelpScreen extends SkinnableComponent
	{
		/*[SkinPart(required="true")]
		public var scroller			:Scroller;*/
		
		[SkinPart(required="true")]
		public var buttonBar		:GroupBase;
		
		[SkinPart(required="true")]
		public var descriptorComp	:CompHelpScreenDescriptor;
		
		[SkinPart(required="true")]
		public var interactionComp	:CompHelpScreenInteraction;
		
		public static const MAX_BAR_BUTTONS_WIDTH:Number = 650;
		
		private var removeButton	:Button;
		/*[Bindable] private var _helpScreenOpen:Boolean;*/
		
		
		[Bindable]
		public var videoButtonBarScale	:Number;
		
		[Bindable]
		public var padding				:Number = 5;
		
		[Bindable] 
		protected var _model			:ModelAIRMonitor;
		
		public function set model(value:ModelAIRMonitor):void
		{
			//Tracer.log(this, "model: "+value);
			if(value)
			{
				_model = value;
				/*_model.openHelpPageSignal.add(onOpenHelpPage);		*/		
			}
		}
		
		/*override protected function getCurrentSkinState():String
		{
			return (_helpScreenOpen) ? "open" : "closed";
		} */
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(instance == descriptorComp)
			{
				updateVideoButtonBar();
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == buttonBar)
			{
				stage.removeEventListener(ResizeEvent.RESIZE, onResize);
			}
			/*else if(instance == removeButton)
			{
				_model.openHelpPageSignal.remove(onOpenHelpPage);
			}*/
		}
		
		public function CompHelpScreen()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		protected function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			updateVideoButtonBar();
		}
		
		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(ResizeEvent.RESIZE, onResize);
		}
		
		protected function onResize(event:Event):void
		{
			if(descriptorComp)
			{
				updateVideoButtonBar();
			}
		}
		
		public function onButtonClick(button:ButtonAction, helpItemId:int):void
		{
			updatePadding();
			
			//bug fix for AIR 3.0
			descriptorComp.placeIcon(button.iconInactive);
			helpScreenItem = helpItemId;
		}
		
		private function updateLanguage():void
		{
			if(descriptorComp) descriptorComp.update();
			if(interactionComp) interactionComp.update();
		}
		
		private function updatePadding():void
		{
			padding = (videoButtonBarScale > 1) ? videoButtonBarScale * 5 : 5;
		}
		
		public function onCircledButtonClick(button:Button):void
		{
			helpScreenItem = int(button.label);
		}
		
		public function set helpScreenItem(value:int):void
		{
			descriptorComp.helpScreenItem = value;
		}
		
		public function updateVideoButtonBar():void
		{
			var tmpWidth:Number = (width < MAX_BAR_BUTTONS_WIDTH) ? width - (padding*4) : MAX_BAR_BUTTONS_WIDTH; 
			videoButtonBarScale = UtilsVideoPresenter.getVideoButtonBarScaleValue(tmpWidth);
		}
	}
}