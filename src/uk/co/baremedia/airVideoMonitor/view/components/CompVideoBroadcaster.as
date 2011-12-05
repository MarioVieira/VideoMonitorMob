package uk.co.baremedia.airVideoMonitor.view.components
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.effects.Parallel;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.graphics.ImageSnapshot;
	
	import org.as3.mvcsInjector.interfaces.IDispose;
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.Image;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.effects.Move;
	import spark.effects.Resize;
	import spark.effects.easing.Power;
	import spark.primitives.BitmapImage;
	
	import uk.co.baremedia.airVideoMonitor.interfaces.IDualScreen;
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsCamera;
	import uk.co.baremedia.airVideoMonitor.utils.UtilsVideoPresenter;
	import uk.co.baremedia.gnomo.utils.Resizer;
	
	public class CompVideoBroadcaster extends SkinnableComponent implements IDispose, IDualScreen
	{
		public const CAMERA_PADDING		:Number = 5;
		
		[SkinPart(required="true")]
		public var contentHolder		:IVisualElement;
		
		[SkinPart(required="true")]
		public var userCamera			:UIComponent;
		
		[SkinPart(required="true")]
		public var camera		 	 	:Image;
		
		[SkinPart(required="true")]
		public var gestures		 	 	:BitmapImage;
		
		[SkinPart(required="true")]
		public var cameraFroozenFrame	:Image
		
		[Bindable]
		public var model			 	:ModelAIRMonitor;
		
		protected var _videoBroadcaster :Video;
		protected var _cameraParallel	:Parallel;
		protected var _cameraResize	 	:Resize;
		protected var _cameraMove	 	:Move;
		protected var _freezeFrameMove	:Move;
		protected var _freezeFrameResize:Resize;
		protected var _cameraNewSize	:Rectangle;
		protected var _imageWidth		:Number;
		
		protected var _currentScreenReductionFactor:Number;
		private var _cameraOutNotIn		:Boolean;
		private var _hasCamera:Boolean;
		private var _height:Object;
		private var _resizing:Boolean;
		
		public function CompVideoBroadcaster()
		{
			super();
			//addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		protected function onCreationComplete(event:FlexEvent):void
		{
			//removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			//FlexGlobals.topLevelApplication.addEventListener(FlexEvent.CREATION_COMPLETE, onAppCreationComplete);
		}
		
		public function setupLayout():void
		{
			setImageDimension();
			observe();
			updateCameraSettings();
		}
		
		private function updateCameraSettings():void
		{
			setupFreezeFrame(false);
			if( model.broadcasting && !UtilsVideoPresenter.hasVideoChats(model.videosModel) && !_videoBroadcaster)
			{
				clearVideo();
				setCameraFromOnScreen(model.broadcasterVideo);
			}
		}

		
		private function onSwapBroadcastCamera(value:Boolean):void
		{	
			if(model && model.broadcasterVideo && _hasCamera) 
			{
				clearVideo();
				setCameraFromOnScreen(model.broadcasterVideo);
				updateVideoBroadcasterMeasures(camera.width, camera.height, false, model.receiving);
			}
		}
		
		protected function onAppCreationComplete(event:FlexEvent):void
		{
			setImageDimension();
			observe();
		}
		
		private function onRemoveNotAddCameraOnScreen(removeNotAdd:Boolean):void
		{
			if(removeNotAdd != _cameraOutNotIn)
			{
				cameraOutNotIn(removeNotAdd);
			}
		}
		
		protected function get canAnimateCam():Boolean
		{
			return (_cameraResize && _freezeFrameMove && _cameraMove && !_freezeFrameMove.isPlaying && !_cameraMove.isPlaying && !_cameraResize.isPlaying);	
		}
		
		protected function onCameraResize(event:EffectEvent):void
		{
			_cameraMove.removeEventListener(EffectEvent.EFFECT_END, onCameraResize);
			setCameraImageClass(_currentScreenReductionFactor);	
			
			_resizing = false;
		}
		
		protected function onLensResized(event:EffectEvent):void
		{
			_freezeFrameMove.removeEventListener(EffectEvent.EFFECT_END, onLensResized)
			_videoBroadcaster.visible = true;
			setupFreezeFrame(false);
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(userCamera && camera && contentHolder && cameraFroozenFrame && gestures)
			{
				setupCameraEffects();
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == camera)
			{
				dispose();
			}
		}
		
		[Bindable]
		public function get fullScreen():Boolean
		{
			return model.fullScreen;
		}
		
		protected function setImageDimension():void
		{
			_imageWidth = (availableHeight > availableWidth) ? availableWidth : availableHeight;
		}
		
		private function observe():void
		{
			//Tracer.log(this, "observer");
			model.swapBroadcastCameraSignal.add(onSwapBroadcastCamera);
			model.removeNotAddCameraToMainScreenSignal.add(onRemoveNotAddCameraOnScreen);
			model.cameraRequestedFromMainScreenSignal.add(onCameraRequestFromNotToMainScreen);
			model.firstCameraBroadcastSignal.add(onFirstCamera);
			model.stageDimensionsSignal.add(onResize);
			model.broadcastingSignal.add(onBroadcastingChange);
			//model.receivingSignal.add(onReceivingVideo);
			
			//Tracer.log(this, "observer - updateCamMeasures");
			updateCameraMeasures();
		}
		
		private function onBroadcastingChange(value:Boolean):void
		{
			//Tracer.log(this, "onBroadcastingChange - value: "+value);
			if(!value) clearVideo(); 
		}

		public function dispose(recursive:Boolean=true):void
		{
			model.swapBroadcastCameraSignal.remove(onSwapBroadcastCamera);
			model.removeNotAddCameraToMainScreenSignal.remove(onRemoveNotAddCameraOnScreen);
			model.cameraRequestedFromMainScreenSignal.remove(onCameraRequestFromNotToMainScreen);
			model.firstCameraBroadcastSignal.remove(onFirstCamera);
			model.stageDimensionsSignal.remove(onResize);
		}
		
		protected function onResize():void
		{
			//Tracer.log(this, "onResize - updateCamMeasures");
			updateCameraMeasures();
		}
		
		private function onCameraRequestFromNotToMainScreen(value:Boolean):void
		{
			//Tracer.log(this, "onCameraRequestFromNotToMainScreen - value: "+value+" model.broadcasterVideo: "+model.broadcasterVideo);
			if(_hasCamera != value)
			{
				if(!value && model.broadcasterVideo)
				{
					video = model.broadcasterVideo;
					if(model.receiving) 
						updateVideoBroadcasterMeasures(camera.width, camera.height, false, true);
				}
				else
				{
					_hasCamera = false;
					clearVideo();
				}
			}
		}
		
		private function onFirstCamera():void
		{
			_hasCamera = true;
			model.setupBroadcasterVideo(true);
			//Tracer.log(this, "onFirstCamera - model.broadcasterVideo: "+model.broadcasterVideo);
			setCameraFromOnScreen(model.broadcasterVideo);
			updateVideoBroadcasterMeasures(camera.width, camera.height, false, model.receiving);
		}
		
		protected function get availableHeight():Number
		{
			//Tracer.log(this, "availableHeight - dualScreen: "+model.deviceScreenInfo.isDualScreen+" height: "+height);
			//model.debugIt = "CompBroadcaster - screen1Height : "+model.deviceScreenInfo.screen1Height+ " isDualScreen: "+model.deviceScreenInfo.isDualScreen;
			return (model.deviceScreenInfo.isDualScreen) ? model.deviceScreenInfo.screen1Height : systemManager.screen.height - (gestures.height /2);
			//return systemManager.screen.height - (gestures.height /2);
		}
		
		protected function get availableWidth():Number
		{
			return systemManager.screen.width;
		}
		
		private function setupFreezeFrame(addNotRemove:Boolean):void
		{
			//Tracer.log(this, "setupFreezeFrame addNotRemove - NO IMAGE: "+addNotRemove);
			cameraFroozenFrame.visible = addNotRemove;
			cameraFroozenFrame.source  = (addNotRemove) ? takePhoto() : null;
		}
		
		private function takePhoto(saveInCameraRool:Boolean = false):BitmapData
		{
			return ImageSnapshot.captureBitmapData(userCamera);
		}
		
		protected function cameraOutNotIn(outNotIn:Boolean):void
		{
			//Tracer.log(this, "cameraOutNotIn - outNotIn: "+outNotIn);
			if(camera && !_cameraMove.isPlaying && !_resizing)
			{
				_cameraOutNotIn = outNotIn;
				
				//Tracer.log(this, "cameraOutNotIn - outNotIn: "+outNotIn+" _resizing: "+_resizing);
				
				var cameraNewSize:Rectangle = updateSequence(outNotIn); 
				
				if(_videoBroadcaster && model.broadcasting && _hasCamera)
				{
					setupFreezeFrame(true);
					_videoBroadcaster.visible = false;
					_freezeFrameMove.addEventListener(EffectEvent.EFFECT_END, onLensResized);
					//Tracer.log(this, "cameraOutNotIn - outNotIn: "+outNotIn);
					updateVideoBroadcasterMeasures(cameraNewSize.width, cameraNewSize.height, true, outNotIn);
					_freezeFrameResize.play();
					_freezeFrameMove.play();
				}
				else
				{
					clearVideo();
					setupFreezeFrame(false);
				}
				
				_resizing = true;
				_cameraMove.addEventListener(EffectEvent.EFFECT_END, onCameraResize);
				_cameraMove.play();
				_cameraResize.play();
			}
		}
		
		/*private function hasCameraInModel():Boolean
		{
			if(model.broadcasterVideo && !_videoBroadcaster)
			{
				video = _videoBroadcaster;
			}
			
			return (model.broadcasterVideo);
		}*/
		
		protected function set video(value:Video):void
		{
			//Tracer.log(this, "video - PUT CAMERA ON AMIN SCREEN");
			if(!_hasCamera && model.broadcasting)
			{
				clearVideo();
				setCameraFromOnScreen(value);
				_hasCamera = true;
			}
			else if(!model.broadcasting)
			{
				clearVideo(true);
			}
			
			//Tracer.log(this, "set video");
			//updateVideoBroadcasterMeasures(camera.width, camera.height, false, model.receiving);
		}
		
		private function setCameraFromOnScreen(value:Video):void
		{
			//Tracer.log(this, "setCameraFromOnScreen - value: "+value);
			_videoBroadcaster = value;
			_videoBroadcaster.smoothing = true;
			_videoBroadcaster.visible = true;
			userCamera.visible = true;
			userCamera.addChild(_videoBroadcaster);
			//updateVideoBroadcasterMeasures(camera.width, camera.height);
		}
		
		//in case anything has been added more than once due to asyncronous calls mishandled (loop through it)
		protected function clearVideo(removeFromModel:Boolean = false):void
		{
			//Tracer.log(this, "clearVideo");
			if(_videoBroadcaster) 
			{
				_videoBroadcaster.attachCamera(null);
			}
			
			var children:int = userCamera.numChildren;
			if(children > 0)
			{
				for (var i:int; i < children; i++)
				{
					try{ userCamera.removeChildAt(i); }catch(er:Error){ }
				}
			}
			
			setupFreezeFrame(false);
			if(removeFromModel) model.startBroadcast(false, false);
			
			//Tracer.log(this, "model.broadcasterVideo: "+model.broadcasterVideo);
		}
		
		protected function getCameraDimensions(reductionFactor:Number = 1.5):Rectangle
		{
			return UtilsCamera.getImageDimensions(_imageWidth, reductionFactor);
		}
		
		protected function getBroadcasterVideoDimensions(lensSize:Number):Rectangle
		{
			return Resizer.scaleByAspectRatio(6400, 4800, lensSize);
		}
		
		protected function setCameraImageClass(reductionFactor:Number = 1.5):Rectangle
		{
			var imageSource:Class = UtilsCamera.getImage(_imageWidth, reductionFactor);
			
			if(imageSource) 
			{	
				camera.source = imageSource;
				camera.width  = camera.preliminaryWidth;
				camera.height = camera.preliminaryHeight;
				
				var rect:Rectangle = new Rectangle(0, 0, camera.preliminaryWidth, camera.preliminaryHeight);
			}
			
			return rect;
		}
		
		protected function updateSequence(outNotIn:Boolean):Rectangle
		{
			if(!outNotIn)
			{
				var rect:Rectangle 				= getCameraDimensions(UtilsCamera.TWO_THIRDS);
				
				if( !isNaN(camera.width) )
				{
					_cameraMove.xFrom 				= camera.x;
					_cameraMove.yFrom 				= camera.y;
					_cameraMove.xTo  				= availableWidth  / 2 - rect.width  / 2;
					_cameraMove.yTo  				= availableHeight / 2 - rect.height / 2;
					
					_cameraResize.widthFrom 	  	= camera.width;
					_cameraResize.widthTo   	  	= rect.width;
					_cameraResize.heightFrom	  	= camera.height;
					_cameraResize.heightTo  	  	= rect.height;
					_currentScreenReductionFactor 	= UtilsCamera.TWO_THIRDS;
				}
			}
			else
			{
				var rect:Rectangle 		= getCameraDimensions(UtilsCamera.QUARTER);
				
				if( !isNaN(camera.width) )
				{
					_cameraResize.widthFrom = camera.width;
					_cameraResize.widthTo   = rect.width;
					_cameraResize.heightFrom= camera.height;
					_cameraResize.heightTo  = rect.height;
				
					_cameraMove.xFrom 		= camera.x;
					_cameraMove.xTo  		= 5;
					_cameraMove.yFrom  		= camera.y;
					_cameraMove.yTo  		= 5;
					_currentScreenReductionFactor = UtilsCamera.QUARTER;
				
				}
			}
			
			//Tracer.log(this, "updateSequence - camera.x: "+camera.x + " camera.y: "+camera.y+" _cameraMove.xTo: "+_cameraMove.xTo+" _cameraMove.yTo: "+_cameraMove.yTo);
			//Tracer.log(this, "updateSequence - camera.width: "+camera.width + " rect.width: "+rect.width+" camera.height: "+camera.height+" rect.height: "+rect.height);
			
			return rect;
		}
		
		private function setupCameraEffects():void
		{
			var ease:Power = new Power();
			
			_cameraParallel			   = new Parallel();
			_cameraResize			   = new Resize();
			_cameraResize.easer		   = ease;
			_cameraMove				   = new Move();
			_cameraMove.easer		   = ease;
			_cameraMove.target		   = camera;
			_cameraResize.target	   = camera;
			
			
			_freezeFrameMove 	 	   = new Move();
			_freezeFrameMove.easer 	   = ease;
			_freezeFrameResize 	 	   = new Resize();
			_freezeFrameResize.easer   = ease;
			_freezeFrameMove.target    = contentHolder;
			_freezeFrameResize.targets = [cameraFroozenFrame, userCamera];
		}
		
		private function updateCameraMeasures():void
		{	
			//model.debugIt = "comp width: "+width+" comp height: "+height+" availableHeight: "+availableHeight+" availableWidth: "+availableWidth;
			
			if( !model.receiving && (!_cameraResize || !_cameraResize.isPlaying ) )
			{
				var camSize:Rectangle = getCameraDimensions();
				if( isValidMeasures(camSize) )
				{
					//model.debugIt = "cam width: "+camSize.width+" cam height: "+camSize.height+" availableHeight: "+availableHeight+" availableWidth: "+availableWidth;
					setCameraImageClass();
					
					updateVideoBroadcasterMeasures(camSize.width, camSize.height);
					
					camera.x = 	availableWidth  / 2 - camSize.width  / 2;
					camera.y = 	availableHeight / 2 - camSize.height  / 2;
				}
			}
			else if( model.receiving )
			{
				var camSize:Rectangle 			= getCameraDimensions(UtilsCamera.QUARTER);
				if( isValidMeasures(camSize) )
				{
					setCameraImageClass(UtilsCamera.QUARTER);
					camera.y = camera.x 		= CAMERA_PADDING;
					updateVideoBroadcasterMeasures(camSize.width, camSize.height, false, true);
				}
			}
		}
		
		protected function isValidMeasures(rect:Rectangle):Boolean
		{
			return !isNaN(rect.height) && !isNaN(rect.width) && (rect.height != 0 && rect.width != 0);
		}
		
		public function updateVideoBroadcasterMeasures(cameraWidth:Number = -1, cameraHeight:Number = -1, animate:Boolean = false, outNotIn:Boolean = false):void
		{
			var tmpHeight:Number = availableHeight;
			
			if(cameraWidth == -1 || cameraHeight == -1)
			{
				var foundCameraSize:Rectangle = getCameraDimensions( (!outNotIn) ? UtilsCamera.TWO_THIRDS : UtilsCamera.QUARTER );
				cameraWidth  = foundCameraSize.width;
				cameraHeight = foundCameraSize.height;
			}
			
			var lensSize:Number 		= cameraWidth 	* .55937;
			var lensRightPadding:Number = cameraWidth   * .22064;
			var lensTopPadding:Number   = cameraHeight  * .22//.21851; 
			var rectVideoSize:Rectangle	= getBroadcasterVideoDimensions(lensSize);
			
			//Tracer.log(this, "updateVideoBroadcasterMeasures - _videoBroadcaster: "+_videoBroadcaster);
			if(_videoBroadcaster)
			{
				_videoBroadcaster.height = rectVideoSize.height;
				_videoBroadcaster.width  = rectVideoSize.width;
			}
			if(!animate)
			{
				userCamera.width  = cameraFroozenFrame.width  = rectVideoSize.width;
				userCamera.height = cameraFroozenFrame.height = rectVideoSize.height;
				
				contentHolder.x = (outNotIn) ? 5 + lensRightPadding : (availableWidth  / 2  - cameraWidth  / 2)  + lensRightPadding;
				contentHolder.y = (outNotIn) ? 5 + lensTopPadding   : (tmpHeight  / 2 - cameraHeight  / 2) + lensTopPadding;
			}
			else
			{
				_freezeFrameMove.xFrom = contentHolder.x;
				_freezeFrameMove.yFrom = contentHolder.y;
				_freezeFrameMove.xTo   = (outNotIn) ? 5 + lensRightPadding : (availableWidth  / 2  - cameraWidth  / 2)  + lensRightPadding;
				_freezeFrameMove.yTo   = (outNotIn) ? 5 + lensTopPadding   : (tmpHeight  / 2 - cameraHeight / 2)  + lensTopPadding;
				
				//Tracer.log(this, "updateVideoBroadcasterMeasures - contentHolder.x: "+contentHolder.x+" contentHolder.y: "+contentHolder.y+" _freezeFrameMove.xTo: "+_freezeFrameMove.xTo+" _freezeFrameMove.yTo: "+_freezeFrameMove.yTo);
				
				_freezeFrameResize.widthFrom  = userCamera.width;
				_freezeFrameResize.widthTo	  = rectVideoSize.width;
				_freezeFrameResize.heightFrom = userCamera.height;
				_freezeFrameResize.heightTo	  = rectVideoSize.height;
				
				//Tracer.log(this, "updateVideoBroadcasterMeasures - userCamera.width: "+userCamera.width+" rectVideoSize.width: "+rectVideoSize.width+" userCamera.height: "+userCamera.height+" rectVideoSize.height: "+rectVideoSize.height);
			}
		}
	}
}