package uk.co.baremedia.airVideoMonitor.view.elements
{
	import flash.events.MouseEvent;
	
	import mx.states.State;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import spark.components.Button;
	import spark.components.Image;
	import spark.utils.MultiDPIBitmapSource;
	
	[SkinState("toggle")]
	
	public class ButtonMobileToggle extends Button
	{
		public var toggleButton	:Boolean = true;
		private var _toggled	:Boolean;
		
		public function ButtonMobileToggle() 
		{
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onClick(event:MouseEvent):void
		{
			if(toggleButton && _toggled)
				_toggled = false;
			else if(toggleButton && !_toggled)
				_toggled = true;
			
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			var state:String = super.getCurrentSkinState();
			
			if(_toggled) 
				return "toggle";
			else if(state != "down")
				return state;
			else 
				return "up"; 
		}
		
		public function setActive(active:Boolean):void
		{
			_toggled = active;
			invalidateSkinState();
		}
		
		public function get active():Boolean
		{
			return _toggled;
		}
	}
}