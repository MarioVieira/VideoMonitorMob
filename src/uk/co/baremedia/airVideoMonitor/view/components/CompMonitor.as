package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.Button;
	import spark.components.CalloutButton;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.DropDownEvent;
	
	import uk.co.baremedia.airVideoMonitor.controls.ControlAIRVideoMonitor;
	import uk.co.baremedia.airVideoMonitor.interfaces.IDualScreen;
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenterOwner;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsDimensions;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoReceiver;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsViewNavigator;
	import uk.co.baremedia.airVideoMonitor.view.elements.ButtonAction;
	import uk.co.baremedia.airVideoMonitor.view.elements.ButtonMobileToggle;
	import uk.co.baremedia.airVideoMonitor.view.interfaces.IViewMenuItems;
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;
	
	public class CompMonitor extends SkinnableComponent implements IDualScreen, IVideoPresenterOwner
	{
		/*[SkinPart(required="true")]
		public var videoPresenter	 :HGroup;*/
		
		[SkinPart(required="true")]
		public var topScreenVideoPresenter  :CompVideoPresenter;
		
		[SkinPart(required="true")]
		public var userCamera		 		:CompVideoBroadcaster;
		
		[SkinPart(required="true")]
		public var getCameraButton	 		:Button;
		
		[SkinPart(required="true")]
		public var helpButton	 	 		:ButtonMobileToggle;
		
		[SkinPart(required="true")]
		public var hdButton			 		:ButtonMobileToggle;
		
		[SkinPart(required="true")]
		public var getCameraButtonOverlay:IVisualElement;
		
		[SkinPart(required="true")]
		public var helpButtonOverlay 	 :IVisualElement;
		
		[SkinPart(required="true")]
		public var hdButtonOverlay		 :IVisualElement;
		
		[SkinPart(required="true")]
		public var mainButtons	 	  	 :GroupBase;
		
		[SkinPart(required="true")]
		public var buttonsOverlay		 :GroupBase;
		
		[SkinPart(required="true")]
		public var helpCallOut			 :CalloutButton;
		
		[SkinPart(required="true")]
		public var languagesCallout		 :CalloutButton;
		
		[Bindable]
		public var control			 	 :ControlAIRVideoMonitor;
		
		[Bindable]
		public var languagesOverlay		 :Group;
		
		[Bindable] 
		public var overlayButtonsVisible :Boolean = true;
		
		[Bindable]
		public var getCameraButtonPadding	:int;
		
		[Bindable]
		public var viewContainer	 :IViewMenuItems;
		
		protected var _model		 :ModelAIRMonitor;
		
		/*protected var _measureLarger :Number;
		protected var _measureSmaller:Number;*/
		
		private var _helpScreenOpen		:Boolean;
		private var _helpPageCallOutOpen:Boolean;
		private var _languageCallOutOpen:Boolean;
		
		public function CompMonitor()
		{
			super();
			var appHeight:Number = UtilsDimensions.applicationHeigth;
			var appWidth :Number = UtilsDimensions.applicationWidth;
			
			/*_measureLarger  = (appHeight > appWidth) ? appHeight : appWidth;
			_measureSmaller = (appHeight > appWidth) ? appWidth : appHeight;*/
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		protected function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			updateHDActive();
			//logic used for when moving to a different view, and recreating it when coming back (removed due to using one screen)
			//UtilsVideoReceiver.watchAlreadyConnectedBroadcasters(model, videoPresenter);
		}
		
		public function setupLayout():void
		{
			IDualScreen(userCamera).setupLayout();
		}
		
		public function set model(value:ModelAIRMonitor):void
		{
			_model = value;
			userCamera.model = value;
			_model.hdQualitySignal.add(onHDQuality);
			_model.stageDimensionsSignal.add(onScreenDimensionChange);
			updatePresenterModel();
		}
		
		public function get videoPresenterComp():CompVideoPresenter
		{
			return topScreenVideoPresenter;
		}
		
		[Bindable]
		public function get model():ModelAIRMonitor
		{
			return _model;
		}
		
		public function get languageHeight():Number
		{
			var placement:Number = height / 2 - 30;
			return placement;
			//return (placement < mainButtons.height + 10) ? placement : placement + mainButtons.height;
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState(); //(_helpScreenOpen) ? "helpScreen" : "";
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if(instance == getCameraButton)
			{
				getCameraButton.addEventListener(MouseEvent.CLICK, onGetCamera);
			}
			else if(instance == hdButton)
			{
				hdButton.addEventListener(MouseEvent.CLICK, onHDClick);
			}
			else if(instance == getCameraButtonOverlay)
			{
				getCameraButtonOverlay.addEventListener(MouseEvent.CLICK, onGetCamera);
			}
			else if(instance == hdButtonOverlay)
			{
				hdButtonOverlay.addEventListener(MouseEvent.CLICK, onHDOverlayButtonClick);
				updateHDActive();
			}
			else if(instance == helpButtonOverlay)
			{
				helpButtonOverlay.addEventListener(MouseEvent.CLICK, onHelpButton);
			}
			else if(instance == languagesCallout)
			{
				languagesCallout.addEventListener(DropDownEvent.OPEN, onLanguageCallOutOpen);
				languagesCallout.addEventListener(DropDownEvent.CLOSE, onLanguageCallOutClose);
			}
			else if(instance == topScreenVideoPresenter)
			{
				updatePresenterModel();
			}
			if(userCamera && topScreenVideoPresenter && mainButtons && buttonsOverlay && helpCallOut && helpButtonOverlay)
			{
				if(!control) 
					control = new ControlAIRVideoMonitor(this);
				setCameraButtonScale();
				updateHelpCallOutPostion();
			}
		}
		
		private function updatePresenterModel():void
		{
			if(topScreenVideoPresenter)
				topScreenVideoPresenter.model = _model;
			
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == getCameraButton)
			{
				getCameraButton.removeEventListener(MouseEvent.CLICK, onGetCamera);
			}
			else if(instance == hdButton)
			{
				hdButton.removeEventListener(MouseEvent.CLICK, onHDClick);
			}
			else if(instance == getCameraButtonOverlay)
			{
				getCameraButtonOverlay.removeEventListener(MouseEvent.CLICK, onGetCamera);
			}
			else if(instance == hdButtonOverlay)
			{
				hdButtonOverlay.removeEventListener(MouseEvent.CLICK, onHDOverlayButtonClick);
			}
			else if(instance == languagesCallout)
			{
				languagesCallout.removeEventListener(DropDownEvent.OPEN, onLanguageCallOutOpen);
				languagesCallout.removeEventListener(DropDownEvent.CLOSE, onLanguageCallOutClose);
			}
			else if(instance == helpButton)
			{
				helpButton.removeEventListener(MouseEvent.CLICK, onHelpButton);
				_model.hdQualitySignal.remove(onHDQuality);
			}
		}
		
		public function onHelpPopupClosed():void
		{
			_helpPageCallOutOpen = false;
			updateHelpPageButtonActive();
		}
		
		protected function onLanguageCallOutOpen(event:DropDownEvent):void
		{
			_languageCallOutOpen = true;
		}
		
		protected function onLanguageCallOutClose(event:DropDownEvent):void
		{
			_languageCallOutOpen = false;
		}
		
		private function onScreenDimensionChange():void
		{
			_model.debugIt = "onScreenDimensionChange";
							
			if(helpCallOut && buttonsOverlay && languagesCallout)
			{
				//width = stage.width;
				if(stage)
				{
					_model.debugIt = "CompMonitor - onScreenDimensionChange - stage.width: "+stage.width+ "width: "+width+" height: "+height; 
					width = stage.width;
				}
				updateHelpCallOutPostion();	
			    updateLanguageCalloutPosition();
			}
			
		}
		
		
		protected function onOptionsClick(event:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.viewMenuOpen = true;
		}

		private function onHDOverlayButtonClick(e:MouseEvent):void
		{
			_model.setHDVideo(!hdButton.active);
		}
		
		protected function onHelpButton(event:MouseEvent):void
		{
			if(!_helpPageCallOutOpen)
			{
				_helpPageCallOutOpen = true;
				helpCallOut.openDropDown();
			}
			else
			{
				helpCallOut.closeDropDown();
				_helpPageCallOutOpen = false;
			}
			
			updateHelpPageButtonActive();
		}
		
		public function onLanguageCallOut(event:MouseEvent):void
		{
			//Tracer.log(this, "onLanguageCallOut - _languageCallOutOpen: "+_languageCallOutOpen);
			if(!_languageCallOutOpen)
			{
				_languageCallOutOpen = true;
				languagesCallout.openDropDown();
			}
			else
			{
				languagesCallout.closeDropDown();
				_languageCallOutOpen = false;
			}
		}
		
		private function onHDQuality(hdQuality:Boolean):void
		{
			if(hdButton) hdButton.setActive(hdQuality);
		}
		
		private function onGetCamera(e:MouseEvent):void
		{
			control.onGetFrontCam(e);
		}
		
		protected function onHDClick(event:MouseEvent):void
		{
			Tracer.log(this, "onHDClick - hd: "+hdButton.active);
			_model.setHDVideo(hdButton.active);
		}
		
		public function skinCreated():void
		{
			onScreenDimensionChange();
		}
		
		public function updateViewMenuItems():void
		{
			control.updateViewMenuItems();
		}
		private function updateHDActive():void
		{
			if(model && hdButton) hdButton.setActive(model.hdQuality);
		}
		
		private function updateHelpPageButtonActive():void
		{
			helpButton.setActive(_helpPageCallOutOpen);
		}
		
		public function updateHelpCallOutPostion():void
		{
			//Tracer.log(this, "updateHelpCallOutPostion() - width - helpCallOut.width - getCameraButtonPadding: "+(width - helpCallOut.width - getCameraButtonPadding));
			helpCallOut.x = width - (helpButtonOverlay.width );
			
		}
		
		private function updateLanguageCalloutPosition():void
		{
			//languagesCallout.y = int(height / 2 - languagesCallout.height / 2 + (languagesCallout.height / 2) );
		}
		
		private function setCameraButtonScale():Number
		{
			var appDPI:Number = UtilsDimensions.applicationDPI;
			
			switch(true)
			{
				case appDPI <= 160:
					getCameraButtonPadding = 5;
					return (UtilsDeviceInfo.isAndroid) ? 1.4 : 1.2;
					break;
				
				case appDPI > 160 && appDPI < 170:
					getCameraButtonPadding = 6;
					return 1.6;
					break;
				
				case appDPI > 170 && appDPI <= 240:
					getCameraButtonPadding = 8;
					return 1.8;
					break;
				
				case appDPI > 240:
					getCameraButtonPadding = 10;
					return 2.2;
					break;
			}
			
			return 1;
		}
	}
}