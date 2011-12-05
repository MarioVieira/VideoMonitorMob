package uk.co.baremedia.airVideoMonitor.interfaces
{
	import mx.core.IVisualElementContainer;
	
	import spark.components.supportClasses.GroupBase;

	public interface IVideoPresenter
	{
		function get videoPresenter():IVisualElementContainer;
		function updateFilmReelVisible():void;
		function set fullScreen(value:Boolean):void;
		function get fullScreen():Boolean;
		function resetVideoPresenterScale():void;
	}
}