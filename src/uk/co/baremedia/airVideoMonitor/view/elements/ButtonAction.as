package uk.co.baremedia.airVideoMonitor.view.elements
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClearActive;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear_Left;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear_LeftActive;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear_Middle;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear_MiddleActive;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear_Right;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonClear_RightActive;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonColumn_Base;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonColumn_BaseActive;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonColumn_Middle;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonColumn_MiddleActive;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonColumn_Top;
	import uk.co.baremedia.airVideoMonitor.view.skins.assets.FXGButtonColumn_TopActive;
	
	public class ButtonAction extends Button
	{
		public static const ROUND_CORNERS			:String = "roundCorners";
		public static const MIDDLE					:String = "middle";
		public static const LEFT					:String = "left";
		public static const RIGHT					:String = "right";
		public static const TOP						:String = "top";
		public static const BASE					:String = "base";
		public static const COLUMN_MIDDLE			:String = "columnMiddle";
		
		[SkinPart(required="true")]
		public var iconHolder						:IVisualElementContainer;
		
		[SkinPart(required="true")]
		public var skinHolder						:IVisualElementContainer;
		
		[Bindable] public var down					:Boolean;
		
		[Bindable(event="activeChange")] 
		public var active			 				:Boolean;
		[Bindable] public var toggleButton			:Boolean;
		
		[Inspectable(defaultValue="none", enumeration="roundCorners,left,middle,right,top,base,none,columnMiddle")]
		[Bindable] public var buttonPosition		:String = "none";
		[Bindable] public var iconInactive			:Class;
		[Bindable] public var iconActivate			:Class;
		
		public function ButtonAction()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		protected function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			setActive(active);
		}
		
		protected function onClick(event:MouseEvent):void
		{
			setActive( (active) ? false : true ); //!active;
		}
		
		public function setActive(value:Boolean):void
		{
			active = value;
			
			if(iconHolder)
			{
				//if(iconInactive == FXGMuteMic) Tracer.log(this, "setActivate - active: "+value);
			
				if(!value) 				deactivate();
				else if(iconActivate) 	activate();
			
				if(toggleButton) setBackgrounSkin(value);
				dispatchEvent( new Event("activeChange") );	
			}
		}
		
		protected function setBackgrounSkin(active:Boolean):void
		{
			if(skinHolder.numElements > 0) skinHolder.removeAllElements();
			
			var activeBackground:Boolean = (active) ? (toggleButton) : false;
			
			if(buttonPosition == ROUND_CORNERS)
			{
				skinHolder.addElement( !activeBackground  ? new FXGButtonClear() : new FXGButtonClearActive() );
			}
			else if(buttonPosition == MIDDLE)
			{
				skinHolder.addElement( !activeBackground ? new FXGButtonClear_Middle() : new FXGButtonClear_MiddleActive() );	
			}
			else if(buttonPosition == LEFT)
			{
				skinHolder.addElement( !activeBackground  ? new FXGButtonClear_Left() : new FXGButtonClear_LeftActive() );
			}
			else if(buttonPosition == RIGHT)
			{
				skinHolder.addElement( !activeBackground ? new FXGButtonClear_Right() : new FXGButtonClear_RightActive() );
			}
			else if(buttonPosition == TOP)
			{
				skinHolder.addElement( !activeBackground ? new FXGButtonColumn_Top() : new FXGButtonColumn_TopActive() );
			}
			else if(buttonPosition == COLUMN_MIDDLE)
			{
				skinHolder.addElement( !activeBackground ? new FXGButtonColumn_Middle() : new FXGButtonColumn_MiddleActive() );
			}
			else if(buttonPosition == BASE)
			{
				skinHolder.addElement( !activeBackground ? new FXGButtonColumn_Base() : new FXGButtonColumn_BaseActive() );
			}
			
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if(iconHolder && skinHolder)
			{
				setBackgrounSkin(false);
				addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		protected function onUp(event:MouseEvent):void
		{
			down = false;
		}
		
		private function onDown(event:MouseEvent):void
		{
			down = true;	
		}
		
		protected function deactivate():void
		{
			//Tracer.log(this, "deactivate - iconInactive: "+iconInactive);
			clearIconHolder();
			if(iconInactive) iconHolder.addElement( new iconInactive() );
		}
		
		protected function activate():void
		{
			//Tracer.log(this, "activate");
			clearIconHolder();
			iconHolder.addElement( new iconActivate() );
		}
		
		private function clearIconHolder():void
		{
			if(iconHolder.numElements > 0 ) iconHolder.removeAllElements();
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == iconHolder)
			{
				removeEventListener(MouseEvent.CLICK, onClick);
				removeEventListener(MouseEvent.CLICK, onUp);
				removeEventListener(MouseEvent.CLICK, onDown);
			}
		}
		
	}
}