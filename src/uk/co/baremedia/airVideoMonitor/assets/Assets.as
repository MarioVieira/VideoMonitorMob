package uk.co.baremedia.airVideoMonitor.assets
{
	import uk.co.baremedia.gnomo.utils.UtilsDeviceInfo;

	public class Assets
	{
		[Embed(source="assets/gestures_130.png")] public static var Gestures:Class;

		[Embed(source="assets/splash_200DPI.png")] public static var splash_200DPI:Class;
		[Embed(source="assets/splash_160DPI.png")] public static var splash_160DPI:Class;
		[Embed(source="assets/splash_130DPI.png")] public static var splash_130DPI:Class;
		
		[Embed(source="assets/cameraWidth_80.png")]  public static var cameraWidth_80:Class;
		[Embed(source="assets/cameraWidth_120.png")] public static var cameraWidth_120:Class;
		[Embed(source="assets/cameraWidth_135.png")] public static var cameraWidth_135:Class;
		[Embed(source="assets/cameraWidth_150.png")] public static var cameraWidth_150:Class;
		[Embed(source="assets/cameraWidth_192.png")] public static var cameraWidth_192:Class;
		[Embed(source="assets/cameraWidth_213.png")] public static var cameraWidth_213:Class;
		[Embed(source="assets/cameraWidth_240.png")] public static var cameraWidth_240:Class;
		[Embed(source="assets/cameraWidth_320.png")] public static var cameraWidth_320:Class;
		[Embed(source="assets/cameraWidth_300.png")] public static var cameraWidth_300:Class;
		[Embed(source="assets/cameraWidth_360.png")] public static var cameraWidth_360:Class;
		[Embed(source="assets/cameraWidth_400.png")] public static var cameraWidth_400:Class;
		[Embed(source="assets/cameraWidth_480.png")] public static var cameraWidth_480:Class;
		[Embed(source="assets/cameraWidth_512.png")] public static var cameraWidth_512:Class;
		[Embed(source="assets/cameraWidth_640.png")] public static var cameraWidth_640:Class;
		
		[Embed(source="assets/notiferLeftBar_160.png")] public static var notiferLeftBar_160:Class;
		[Embed(source="assets/notiferLeftBar_160.png")] public static var notiferLeftBar_240:Class;
		[Embed(source="assets/notiferLeftBar_160.png")] public static var notiferLeftBar_320:Class;
		
		[Embed(source="assets/languageIcon.png")] 		  public static var languageIcon:Class;
		[Embed(source="assets/languageIcon_down.png")] 	  public static var languageIconDown:Class;
		[Embed(source="assets/languageIcon_320.png")] 	  public static var languageIcon_320:Class;
		[Embed(source="assets/languageIconDown_320.png")] 	  public static var languageIconDown_320:Class;
		
		[Embed(source="assets/notiferMiddleBar_160.png")] public static var notiferMiddleBar_160:Class;
		[Embed(source="assets/notiferMiddleBar_160.png")] public static var notiferMiddleBar_240:Class;
		[Embed(source="assets/notiferMiddleBar_160.png")] public static var notiferMiddleBar_320:Class;
		[Embed(source="assets/notiferMiddleBarNoAplha_160.png")] public static var notiferMiddleBarLong_160:Class;
		
		[Embed(source="assets/notiferRightBar_160.png")] public static var notiferRightBar_160:Class;
		[Embed(source="assets/notiferRightBar_160.png")] public static var notiferRightBar_240:Class;
		[Embed(source="assets/notiferRightBar_160.png")] public static var notiferRightBar_320:Class;
		
		[Embed(source="assets/01-arrow-east.png")] 	public static var arrowEast:Class;
		[Embed(source="assets/01-arrow-east@2x.png")] 	public static var arrowEast_320:Class;
		
		[Embed(source="assets/updaterLeft.png")] 	public static var updaterLeft:Class;
		[Embed(source="assets/updaterMiddle_2.png")] public static var updaterMiddle:Class;
		[Embed(source="assets/updaterRight.png")] 			public static var updaterRight:Class;
		[Embed(source="assets/updaterLeftMiddle.png")] 			public static var updaterLeftMiddle:Class;
		[Embed(source="assets/updaterLeftBottom.png")] 			public static var updaterLeftBottom:Class;
		[Embed(source="assets/updaterMiddleMiddle_2.png")] 		public static var updaterMiddleMiddle:Class;
		[Embed(source="assets/updaterRightMiddle.png")] 		public static var updaterRightMiddle:Class;
		[Embed(source="assets/updaterMiddleBottom_2.png")] 		public static var updaterMiddleBottom:Class;
		[Embed(source="assets/updaterRightBottom.png")] 		public static var updaterRightBottom:Class;
		[Embed(source="assets/updaterMiddleHorizontal.png")] 	public static var updaterMiddleHorizontal:Class;
		
		[Embed(source="assets/removeButton_160.png")] 	public static var removeButton_160:Class;
		[Embed(source="assets/removeButton_240.png")] 	public static var removeButton_240:Class;
		[Embed(source="assets/removeButton_320.png")] 	public static var removeButton_320:Class;
		
		[Embed(source="assets/radioButton_160.png")] 		public static var radioButton_160:Class;
		[Embed(source="assets/radioButton_240.png")] 		public static var radioButton_240:Class;
		[Embed(source="assets/radioButton_320.png")] 		public static var radioButton_320:Class;
		
		[Embed(source="assets/radioButtonDown_160.png")] 	public static var radioButtonSelected_160:Class;
		[Embed(source="assets/radioButtonDown_240.png")] 	public static var radioButtonSelected_240:Class;
		[Embed(source="assets/radioButtonDown_320.png")] 	public static var radioButtonSelected_320:Class;
		
		public static function get buttonMiddle_160():Class{	return (UtilsDeviceInfo.isIOS) ? _buttonMiddle_160 : buttonMiddle_240; };
		[Embed(source="assets/buttonMiddle_160.png")] 		private static var _buttonMiddle_160:Class;
		
		public static function get buttonMiddleActive_160():Class{	return (UtilsDeviceInfo.isIOS) ? _buttonMiddleActive_160 : buttonMiddleActive_240; };
		[Embed(source="assets/buttonMiddleActive_160.png")] private static var _buttonMiddleActive_160:Class;
		
		[Embed(source="assets/buttonMiddle_240.png")] 		public static var buttonMiddle_240:Class;
		[Embed(source="assets/buttonMiddleActive_240.png")] public static var buttonMiddleActive_240:Class;
		[Embed(source="assets/buttonMiddle_320.png")] 		public static var buttonMiddle_320:Class;
		[Embed(source="assets/buttonMiddleActive_320.png")] public static var buttonMiddleActive_320:Class;
		
		
		public static function get buttonBaseActive_160():Class{ return (UtilsDeviceInfo.isIOS) ? _buttonBaseActive_160 : buttonBaseActive_240 };
		[Embed(source="assets/buttonBaseActive_160.png")] 	private static var _buttonBaseActive_160:Class;
		
		public static function get buttonBase_160():Class{ return (UtilsDeviceInfo.isIOS) ? _buttonBase_160 : buttonBase_240 };
		[Embed(source="assets/buttonBase_160.png")] 		private static var _buttonBase_160:Class;
		
		[Embed(source="assets/buttonBaseActive_240.png")] 	public static var buttonBaseActive_240:Class;
		[Embed(source="assets/buttonBase_240.png")] 		public static var buttonBase_240:Class;
		[Embed(source="assets/buttonBaseActive_320.png")] 	public static var buttonBaseActive_320:Class;
		[Embed(source="assets/buttonBase_320.png")] 		public static var buttonBase_320:Class;
		
		public static function get iconHelp_160():Class{ return (UtilsDeviceInfo.isIOS) ? _iconHelp_160 : iconHelp_240 };
		[Embed(source="assets/iconsHelp_160.png")] 			private static var _iconHelp_160:Class;
		[Embed(source="assets/iconsHelp_240.png")] 			public static var iconHelp_240:Class;
		[Embed(source="assets/iconsHelp_320.png")] 			public static var iconHelp_320:Class;
		
		public static function get iconGetCams_160():Class{ return (UtilsDeviceInfo.isIOS) ? _iconGetCams_160 : iconGetCams_240 };
		[Embed(source="assets/iconGetCams_160.png")] 		private static var _iconGetCams_160:Class;
		[Embed(source="assets/iconGetCams_240.png")] 		public static var iconGetCams_240:Class;
		[Embed(source="assets/iconGetCams_320.png")] 		public static var iconGetCams_320:Class;
		
		public static function get iconHD_160():Class{ return (UtilsDeviceInfo.isIOS) ? _iconHD_160 : iconHD_240 };
		[Embed(source="assets/iconHD_160.png")] 			private static var _iconHD_160:Class;
		[Embed(source="assets/iconHD_240.png")] 			public static var iconHD_240:Class;
		[Embed(source="assets/iconHD_320.png")] 			public static var iconHD_320:Class;
		
	[Embed(source="assets/splash_sonyP.png")] 			public static var splash_SonyP:Class; 
		
		
	}
}