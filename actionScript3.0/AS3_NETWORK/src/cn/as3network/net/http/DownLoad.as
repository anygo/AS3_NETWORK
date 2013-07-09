package cn.as3network.net.http
{
	import cn.as3network.event.UploadEventDispatcher;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	/**
	 * 下载 
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class DownLoad extends EventDispatcher
	{
		/**
		 * 构造函数 
		 * 
		 */		
		public function DownLoad()
		{
			super();
		}
		
		/**
		 * 下载文件 
		 * @param serverPath  服务器地址
		 * @param filePath  文件地址（相对于服务器）
		 * @param fileName  文件名（包括后缀名）
		 * 
		 */		
		public static function downLoadByHTTP(serverPath:String, filePath:String, fileName:String, isRealPath:Boolean=false):void
		{
			var request:URLRequest = new URLRequest();
			request.url = encodeURI(serverPath + "/DownLoad?fliePath=" + filePath + "&fliename=" + fileName + "&realPath=" + int(isRealPath));
			navigateToURL(request, "_blank");
		}
		
		public static function downLoad(serverPath:String, filePath:String, fileName:String, isRealPath:Boolean=false):void
		{
			var request:URLRequest = new URLRequest();
			request.url = encodeURI(serverPath + "/DownLoad?fliePath=" + filePath + "&fliename=" + fileName + "&realPath=" + int(isRealPath));
			var file:FileReference = new FileReference();
			if(fileName.indexOf(".") < 0)
				fileName += ".zip";
			
			file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
			file.addEventListener(Event.OPEN, openHandler);
			file.addEventListener(Event.CANCEL, cancelHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			file.download(request, fileName);
			
			function openHandler(evt:Event):void{
				UploadEventDispatcher.getInstance().dispatchEvent(evt);
			}
			
			function cancelHandler(evt:Event):void{
				UploadEventDispatcher.getInstance().dispatchEvent(evt);
			}
			
			function errorHandler(evt:IOErrorEvent):void{
				UploadEventDispatcher.getInstance().dispatchEvent(evt);
			}
			
			function progressHandler(evt:ProgressEvent):void
			{
				UploadEventDispatcher.getInstance().dispatchEvent(evt);
			}
			
			function completeHandler(evt:Event):void{
				UploadEventDispatcher.getInstance().dispatchEvent(evt);
				evt.currentTarget.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				evt.currentTarget.removeEventListener(Event.COMPLETE, completeHandler);
				evt.currentTarget.removeEventListener(Event.OPEN, openHandler);
				evt.currentTarget.removeEventListener(Event.CANCEL, cancelHandler);
				evt.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			}
		}
	}
}