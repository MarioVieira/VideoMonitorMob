package uk.co.baremedia.airVideoMonitor.view.components
{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextLineMetrics;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.core.IVisualElement;
	import mx.events.EffectEvent;
	
	import org.as3.mvcsInjector.interfaces.IDispose;
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.HGroup;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.Resize;
	import spark.effects.easing.Sine;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.airVideoMonitor.model.ModelNotifier;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class CompNotifier extends SkinnableComponent implements IDispose
	{
		[SkinPart(required="true")]
		public var middleBarHolder		:HGroup;
		
		[SkinPart(required="true")]
		public var mainGroup			:HGroup;
		
		[SkinPart(required="true")]
		public var leftBar				:Image;
		
		[SkinPart(required="true")]
		public var middleBarImage		:IVisualElement;			
		
		/*[SkinPart(required="true")]
		public var middleBar			:HGroup;*/
		
		[SkinPart(required="true")]
		public var rightBar				:Image;
		
		[SkinPart(required="true")]
		public var notificationText		:Label;
		
		[SkinPart(required="true")]
		public var arrowOpen			:IVisualElement;
		
		protected var defaultText		:String;
		
		
		/*
		a. user click (make click disabled)
		a.1 get (set first if text is message from Network)tex and set text it in text area to get the width 
		a.1 arrow Fade out
		a.3 middle image resize to text width on Move effect (mxml Move 1st)
		a.4 effect end:  animate text in (when all is done)
		a.4.1 timer of 4sec Fade text out
		a.4.2 time end: resize middle image (to original size) on Move
		a.4.3 effect end:  Fade arrow
		a.5 Fade arrow in AND enable click
		*/
		protected var _middleBarResize  :Resize;
		private var _notification		:String;
		private var _timeOut			:Timer;
		private var _textAdded			:Boolean;
		private var _model				:ModelNotifier;
		
		private var TIMER_OUT			:Number = 5000;
		private var _lastKey			:String = EnumsLanguage.NOTIFIER_START_TEXT;
		private var _firstNotificationArrived:Boolean;
		
		public function CompNotifier()
		{
			super();
			_model = ModelNotifier.instance;
			
			_model.updateNotifierSignal.add(onNotificationUpdate);
			_model.clientUpdateSignal.add(onClientUpdate);
			
			UtilsResources.bundleChange.add(onBundleChange);
		}
		
		private function onBundleChange():void
		{
			//a bit of a way around, but no resouces of time though...
			if( _notification == resourceManager.getString(UtilsResources.ENGLISH, EnumsLanguage.NOTIFIER_START_TEXT) )
			{
				_notification = resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.NOTIFIER_START_TEXT);
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(leftBar && rightBar && middleBarHolder && notificationText && mainGroup && middleBarImage && arrowOpen)
			{
				setDefaultText();
				notifierOut();
				/*middleBarImage.width = 43;
				contractMiddleBar();*/
			}
		}
		
		private function setupMiddelBarResizeEffect(newWidth:Number, play:Boolean = false):void
		{
			if(!_middleBarResize)
			{
				_middleBarResize 		= new Resize();
				_middleBarResize.target = middleBarImage;
			}
			
			_middleBarResize.widthFrom = middleBarImage.width;
			_middleBarResize.widthTo   = newWidth;
			if(play) _middleBarResize.play();
		}
		
		private function setDefaultText():void
		{
			updateNotificationText = "     ";
			_notification = resourceManager.getString(UtilsResources.bundleName, _lastKey);
			//Tracer.log(this, "setDefaultText - bundleName: "+UtilsResources.bundleName+" text: "+resourceManager.getString(UtilsResources.bundleName, EnumsLanguage.NOTIFIER_START_TEXT) );
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public function set updateNotificationText(value:String):void
		{
			_notification = value;
			notifierIn();
		}
		
		private function resetTextOutTimeout(startOnReset:Boolean = true):void
		{
			if(_timeOut)
			{
				_timeOut.reset();
				if(startOnReset) _timeOut.start();
			}
		}
		
		protected function set notificationTextValue(value:String):void
		{
			updateLabelWidth();
			notificationText.text 	= value;
			//Tracer.log(this, "notificationTextValue() - value: "+value);
		}
		
		private function updateLabelWidth(width:Number = -1):void
		{
			if(_middleBarResize) notificationText.width = (width != -1 ) ? width : _middleBarResize.widthTo;
		}
		
		protected function observeMiddleBarResizeCompletion(handler:Function, addNoRemoveHandler:Boolean = true):void
		{
			if(addNoRemoveHandler) middleBarImage.addEventListener(EffectEvent.EFFECT_END, handler);
			else				   middleBarImage.removeEventListener(EffectEvent.EFFECT_END, handler);
		}
		
		private function set textVisible(value:Boolean):void
		{
			notificationText.visible = value;
		}
		
		private function onNotifierClick(event:MouseEvent):void
		{
			if(!_textAdded)	notifierIn();
			else			notifierOut();
		}
		
		protected function getTextWidth(text:String):int 
		{
			return notificationText.measureText(text).width + (leftBar.width * 2) + rightBar.width;
		}
		
		private function addClickHandler(addNotRemove:Boolean):void
		{
			if(addNotRemove) addEventListener(MouseEvent.CLICK, onNotifierClick, false, 999);
			else 			 removeEventListener(MouseEvent.CLICK, onNotifierClick);
		}
		
		private function onNotificationUpdate(value:String):void
		{
			//Tracer.log(this, "onNotificationUpdate - value: "+value);
			_firstNotificationArrived = true;
			updateNotificationText = value;
		}
		
		private function onClientUpdate(message:String):void
		{
			if(!_textAdded) 
			{
				//Tracer.log(this, "onClientUpdate");
				updateNotificationText = message;
			}
		}
		
		/************************************ NOTIFIER IN ************************************/
		
		public function notifierIn():void
		{
			if(!_textAdded)
			{
				_textAdded = true;
				addClickHandler(false);
				notificationVisible 	= false;
				arrowIn 				= false;
				observeMiddleBarResizeCompletion(onTextAdded);
				expandMiddleBar();
			}
			else
			{
				resetTextOutTimeout(false);
				observeMiddleBarResizeCompletion(onTextAdded);
				expandMiddleBar();
			}
		}
		
		private function onTextAdded(e:Event):void
		{
			//Tracer.log(this, "onTextAdded - _notification: "+_notification);
			
			observeMiddleBarResizeCompletion(onTextAdded, false);
			notificationTextValue = _notification;
			notificationVisible	  = true;
			textVisible = true;
			startNotifierTimeOut();
			addClickHandler(true);
		}
		
		private function expandMiddleBar():void
		{
			setupMiddelBarResizeEffect( getTextWidth(_notification), true );
		}
		
		private function set notificationVisible(value:Boolean):void
		{
			notificationText.visible = value;
		}
		
		private function startNotifierTimeOut():void
		{
			//weird display list no identified issue, tricking first text to go in an out (Time to 10 milisec)
			if(!_timeOut) _timeOut = new Timer(1, 1);
			_timeOut.addEventListener(TimerEvent.TIMER, onNotiferTimeOut);
			_timeOut.start();
		}
		
		protected function onNotiferTimeOut(event:TimerEvent):void
		{
			_timeOut.removeEventListener(TimerEvent.TIMER_COMPLETE, onNotiferTimeOut);
			_timeOut.stop();
			_timeOut.delay = TIMER_OUT;
			notifierOut();
		}
		
		/************************************ NOTIFIER OUT ************************************/
		
		protected function notifierOut():void
		{
			//Tracer.log(this, "notifierOut");
			addClickHandler(false);
			notificationVisible = false;
			updateLabelWidth(arrowOpen.width);
			observeMiddleBarResizeCompletion(onTextRemoved);
			contractMiddleBar();
		}
		
		private function contractMiddleBar():void
		{
			setupMiddelBarResizeEffect(arrowOpen.width, true);
		}
		
		private function onTextRemoved(e:Event):void
		{
			//Tracer.log(this, "onTextRemoved");
			_textAdded = false;
			observeMiddleBarResizeCompletion(onTextRemoved, false);
			arrowIn = true;
			addClickHandler(true);
		}
		
		protected function set arrowIn(value:Boolean):void  
		{
			arrowOpen.visible = value;
		}	

		public function dispose(recursive:Boolean=true):void
		{
			// TODO Auto-generated method stub
		}
	}
}