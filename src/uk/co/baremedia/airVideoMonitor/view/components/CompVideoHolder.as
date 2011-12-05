package uk.co.baremedia.airVideoMonitor.view.components
{
	
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.Resize;
	
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.view.elements.ElementVideoHolder;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideo;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideoPresenter;
	
	public class CompVideoHolder extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var videoHolder			:	ElementVideoHolder;
		
		[SkinPart(required="true")]
		public var videoButtonBar		:	CompVideoButtonBar;
		
		[Bindable] 
		public var model				: 	ModelAIRMonitor;
		
		[Bindable] 
		public var videoButtonBarScale	: 	Number;
		
		private var _videoInfo			:	VOVideo;
		
		protected var _fullScreenResize : 	Resize;
		
		public var videoPresenter		:	VOVideoPresenter;
		public var allPartsAdded:Boolean;
		
		public function CompVideoHolder()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			super();
		}

		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		}
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if(instance == videoButtonBar)
			{
				videoButtonBar.videoPresenter = videoPresenter;
			}
			if(videoHolder && videoButtonBar)
			{
				allPartsAdded = true;
				udpateUI();
			}
		}
		
		public function udpateUI():void
		{
			_videoInfo.video.smoothing = true;
			videoHolder.addChild(_videoInfo.video);
			videoButtonBar.videoInfo = _videoInfo;
			videoButtonBar.model 	 = model;
			
			setSizes(_videoInfo.video.width, _videoInfo.video.height);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		private function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			videoButtonBar.videoButtonBarScale = videoButtonBarScale;
		}
		
		public function set videoInfo(value:VOVideo):void
		{
			_videoInfo = value;
			_videoInfo.changeDimensionsSignal.add(onChangeDimensions);
		}
		
		public function get videoInfo():VOVideo
		{
			return _videoInfo;
		}
		
		private function onChangeDimensions(rect:Rectangle, animated:Boolean):void
		{
			setSizes(rect.width, rect.height, animated);
		}
		
		public function setSizes(width:Number, height:Number, animated:Boolean = false):void
		{
			if(videoButtonBar && _videoInfo)
			{
				if(!animated)
				{
					_videoInfo.video.width  = videoHolder.width  = width;
					_videoInfo.video.height = videoHolder.height = height;
					updateButtonsScale();
				}
				else
				{
					videoButtonBar.visible = false;
					if(!_fullScreenResize) 
					{
						_fullScreenResize = new Resize();
						_fullScreenResize.targets = [_videoInfo.video, videoHolder];
					}
					
					_fullScreenResize.widthFrom  = _videoInfo.video.width;
					_fullScreenResize.heightFrom = _videoInfo.video.height;
					
					_fullScreenResize.widthTo	 = width;
					_fullScreenResize.heightTo	 = height;
					
					_fullScreenResize.addEventListener(EffectEvent.EFFECT_END, onVideoResized);
					_fullScreenResize.play();
				}
			}
		}
		
		protected function onVideoResized(event:EffectEvent):void
		{
			_fullScreenResize.removeEventListener(EffectEvent.EFFECT_END, onVideoResized);
			updateButtonsScale();
			videoButtonBar.visible = true;
		}
		
		private function updateButtonsScale():void
		{
			//Tracer.log(this, "updateButtonsScale() - width: "+_videoInfo.video.width+ " getVideoButtonBarScaleValue(width): "+UtilsVideoPresenter.getVideoButtonBarScaleValue(_videoInfo.video.width) );
			videoButtonBarScale = UtilsVideoPresenter.getVideoButtonBarScaleValue(_videoInfo.video.width);
			if(videoButtonBar) videoButtonBar.videoButtonBarScale = videoButtonBarScale;
		}
	}
}