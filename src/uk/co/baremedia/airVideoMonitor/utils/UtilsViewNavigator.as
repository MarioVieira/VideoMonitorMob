package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.FlexGlobals;
	
	import org.as3.mvcsInjector.utils.Tracer;
	import org.osflash.signals.Signal;
	
	import spark.components.View;
	import spark.transitions.SlideViewTransition;
	import spark.transitions.ViewTransitionDirection;
	
	import uk.co.baremedia.airVideoMonitor.model.ModelAIRMonitor;
	import uk.co.baremedia.airVideoMonitor.view.components.CompMonitor;
	
	import view.Broadcaster;
	import view.HelpPage;
	
	public final class UtilsViewNavigator
	{
		public var openMenuSignal			:Signal; 
		private static var _instance		:UtilsViewNavigator;
		protected var watchMenuInteraction	:ChangeWatcher;
		private var _checkTime				:Timer;
		
		public function UtilsViewNavigator(blocker:SingletonBlocker)
		{
			if(!blocker) throw new Error("use UtilsViewWatcher.instance");
		}
		
		public static function pushVideoMonitor():void
		{
			UtilsVideoReceiver.activeView.navigator.pushView(Broadcaster, null, null, getTransition(ViewTransitionDirection.RIGHT, HelpPage as View, Broadcaster as View) );
		}
		
		/*public static function pushHelpPage():void
		{
			activeView.navigator.pushView(HelpPage, null, null, getTransition(ViewTransitionDirection.LEFT, Broadcaster as View, HelpPage as View) );
		}*/
		
		public static function pushHelpPage(model:ModelAIRMonitor):void
		{
			
			model.openHelpPage = true;
		}
		
		protected static function getTransition(direction:String, startView:View, endView:View):SlideViewTransition
		{
			var transition:SlideViewTransition 		= new SlideViewTransition();
			transition.startView 					= startView;
			transition.endView 						= endView;
			transition.suspendBackgroundProcessing 	= true;
			transition.direction 					= direction;
			return transition; 
		}
		
		public static function get activeView():View
		{
			return FlexGlobals.topLevelApplication.navigator.activeView;
		}
		
		public static function openViewMenu(monitorComp:CompMonitor):void
		{
			//Tracer.log(UtilsViewNavigator, "openViewMenu");
			monitorComp.updateViewMenuItems();
			if(!_instance)
				initialize();
			
			_instance.isViewMenuOpen = true;
			FlexGlobals.topLevelApplication.viewMenuOpen = true;
		}
		
		public function set isViewMenuOpen(value:Boolean):void
		{
			startViewMenuClosedWatcher(value);
			openMenuSignal.dispatch(value);
		}
		
		public static function get instance():UtilsViewNavigator
		{
			if(!_instance) 
			{
				initialize();
				_instance.initializeOptionsWatcher();
			}
			return _instance;	
		}
		
		public function initializeOptionsWatcher():void
		{
			_checkTime = new Timer(2000);
			_checkTime.addEventListener(TimerEvent.TIMER, onCheckMenuClosed);
		}
		
		public function startViewMenuClosedWatcher(startNotStop:Boolean):void
		{
			//Tracer.log(this, "startViewMenuClosedWatcher");
			if(_checkTime)
			{
				if(startNotStop) _checkTime.start();
				else			 _checkTime.stop();
			}
		}
		
		protected function onCheckMenuClosed(event:TimerEvent):void
		{
			//Tracer.log(UtilsViewNavigator, "viewMenuOpen: "+FlexGlobals.topLevelApplication.viewMenuOpen);
			if(!FlexGlobals.topLevelApplication.viewMenuOpen)
			{
				isViewMenuOpen = false;
			}
		}
		
		/*public function set watchViewMenuOpen(value:Boolean):void
		{
			if(value)
			{
				setTimeout(openAdd, 5000) 
			}
		}
		
		private function openAdd():void
		{
			isViewMenuOpen = false;
		}
		
		*/
		
		private static function initialize():void
		{
			_instance = new UtilsViewNavigator(new SingletonBlocker());
			_instance.openMenuSignal = new Signal(Boolean);
		}
		
	}
}

class SingletonBlocker{}