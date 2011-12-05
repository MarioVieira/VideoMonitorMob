package uk.co.baremedia.airVideoMonitor.model
{
	import mx.core.UIComponent;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenter;
	import uk.co.baremedia.airVideoMonitor.vo.VOVideoPresenter;

	public class ModelVideoPresenter
	{
		protected var _screens:Vector.<VOVideoPresenter> = new Vector.<VOVideoPresenter>;
		
		public function addVideoPresenter(presenter:IVideoPresenter, constainer:UIComponent):void
		{
			if(!presenter)
				return;
			
			var presenterVO:VOVideoPresenter = new VOVideoPresenter(presenter, constainer, _screens.length)
			
			//Tracer.log(this, "addScreen - presenter: "+presenter+" screenIndex: "+presenterVO.screenIndex);
			_screens.push(presenterVO);
		}
		
		public function get screens():Vector.<VOVideoPresenter>
		{
			return _screens;
		}
	}
}