package com.airmyth.net.as3network.net.http
{
	import com.airmyth.net.as3network.event.UploadEventDispatcher;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * 下载 
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class DownLoad extends EventDispatcher
	{
		/**目标是java*/
		public static const JAVA_SERVER:String = "/DownLoad";
		/**目标是asp.net*/
		public static const ASP_SERVER:String = "/DownLoad.aspx";
		/**目标是php*/
		public static const PHP_SERVER:String = "/DownLoad.php";
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
		 * @param serverType 服务器类型（本类提供的常量）
		 * @param serverPath  服务器地址
		 * @param filePath  文件地址（相对于服务器）
		 * @param fileName  文件名（包括后缀名）
		 * 
		 * @see DownLoad.JAVA_SERVER
		 * @see DownLoad.ASP_SERVER
		 * @see DownLoad.PHP_SERVER
		 */		
		public static function downLoadByHTTP(serverType:String, serverPath:String, filePath:String, fileName:String):void
		{
			var request:URLRequest = new URLRequest();
			request.url = encodeURI(serverPath + serverType + "?filePath=" + filePath + "&fileName=" + fileName);
			navigateToURL(request, "_blank");
		}
		
		/**
		 * 
		 * @param serverType 服务器类型
		 * @param serverPath  服务器地址
		 * @param filePath  文件地址（相对于服务器）
		 * @param fileName  文件名（包括后缀名）
		 * 
		 */		
		public static function downLoad(serverType:String, serverPath:String, filePath:String, fileName:String, saveName:String=null):void
		{
      saveName ||= fileName;
			var request:URLRequest = new URLRequest();
			request.url = encodeURI(serverPath + serverType + "?filePath=" + filePath + "&fileName=" + fileName);
			var file:FileReference = new FileReference();
			if(fileName.indexOf(".") < 0)
				fileName += ".zip";
			
			file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
			file.addEventListener(Event.OPEN, openHandler);
			file.addEventListener(Event.CANCEL, cancelHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			file.download(request, saveName);
			
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