package com.airmyth.net.as3network.net.http
{
	
	import com.airmyth.IDestroy;
	import com.airmyth.net.as3network.event.UploadEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	[Event(name="uploadFileSelected", type="com.airmyth.net.as3network.event.UploadEvent")]
	[Event(name="uploadFileError", type="com.airmyth.net.as3network.event.UploadEvent")]
	[Event(name="uploadFileComplete", type="com.airmyth.net.as3network.event.UploadEvent")]
	[Event(name="uploadFileUploadCompleteData", type="com.airmyth.net.as3network.event.UploadEvent")]
	[Event(name="uploadFileProgress", type="com.airmyth.net.as3network.event.UploadEvent")]
	
	/**
	 * 上传文件
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class UpLoad extends EventDispatcher implements IDestroy
	{
		/**目标是java*/
		public static const JAVA_SERVER:String = "/Upload";
		/**目标是asp.net*/
		public static const ASP_SERVER:String = "/Upload.aspx";
		/**目标是php*/
		public static const PHP_SERVER:String = "/Upload.php";
		
		private var m_file : FileReference;
		private var _serverPath:String;
		private var _folderName:String;
		private var _fileName:String;
		
		private var _serverType:String = JAVA_SERVER;
		
		private var _isSelectedFile:Boolean;
		
		/**
		 * 上传构造函数 
		 * @param serverTypeValue 服务器类型 （本类提供的常量）
		 * @param serverPathValue  服务器地址
		 * @param folderNameValue 上传的目标路径（相对于服务器地址）
		 * @param fileNameValue 上传到服务器时的文件名（如果为 空字符串 则取本地文件名, 不含后缀名）
		 * 
		 * @see UpLoad.JAVA_SERVER
		 * @see UpLoad.ASP_SERVER
		 * @see UpLoad.PHP_SERVER
		 */	
		public function UpLoad(serverTypeValue:String=JAVA_SERVER, serverPathValue:String="", folderNameValue:String="", fileNameValue:String="")
		{
			super();
			
			_serverType = serverTypeValue;
			_serverPath = serverPathValue;
			_folderName = folderNameValue;
			_fileName = fileNameValue.split("%").join("");
		}
		
		/**
		 * 选择文件
		 * @param fileFilter 文件类型过滤器 [FileFilter, FileFilter, FileFilter.....]
		 */
		public function selectFile(fileFilters:Array = null) : void {
			clear();
			initEventListener();
			//打开选择文件的窗口
			m_file.browse(fileFilters);
		}
		
		private function initEventListener():void
		{
			//实例对象
			if(!m_file)
				m_file = new FileReference();
			// 对上传时的IO异常监听
			m_file.addEventListener(IOErrorEvent.IO_ERROR, uploadIOErrorHandle);
			m_file.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			m_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			//上传文件过程的监听
			m_file.addEventListener(ProgressEvent.PROGRESS, onProgress);
			//选择文件的监听 
			m_file.addEventListener(Event.SELECT, onSelect);
			//上传完毕的监听
			m_file.addEventListener(Event.COMPLETE, completeHandle);
			
			m_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
			//			m_file.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
		}
		
		private function clear():void
		{
			if(m_file)
			{
				m_file.removeEventListener(IOErrorEvent.IO_ERROR, uploadIOErrorHandle);
				m_file.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				m_file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				//上传文件过程的监听
				m_file.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				//选择文件的监听 
				m_file.removeEventListener(Event.SELECT, onSelect);
				//上传完毕的监听
				m_file.removeEventListener(Event.COMPLETE, completeHandle);
				
				m_file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
				
				m_file = null;
			}
		}
		
		/**
		 * 开始上传 
		 * 
		 */		
		public function upLoad(file:FileReference=null):void
		{
			if(file)
			{
				clear();
				m_file = file;
				initEventListener();
			}
			if(m_file == null) return;
			if(m_file.size > 2 * 1024 * 1024 * 1024)
				dispatchEvent(new UploadEvent(UploadEvent.ERROR, {error:new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "文件太大")}));
			//如果加入folderName参数，可在客户端将保存文件的文件夹名传过去
			var request: URLRequest = new URLRequest(); 
			request.url = encodeURI(_serverPath + _serverType + "?folderName=" + _folderName +"&fileName=" + _fileName);
			try {
				m_file.upload( request,"FileData",false );
			} 
			catch (error : Error) {
				trace(error.message.toString());
			}
		}
		
		private function completeHandle(event:Event):void
		{
			dispatchEvent(new UploadEvent(UploadEvent.COMPLETE));
		}
		
		private function uploadCompleteDataHandler(event:DataEvent):void
		{
			var arr:Array = event.data.split(";");
			var obj:Object = {};
			obj.result = arr[0];
			if(obj.result == "error")
			{
				obj.message = event.data;
			}
			else
			{
				obj.fileName = arr[1];
				obj.filePath = arr[2];
			}
			dispatchEvent(new UploadEvent(UploadEvent.UPLOAD_COMPLETE_DATA, obj));
		}
		
		private function onSelect(event:Event):void
		{
			_isSelectedFile = true;
			dispatchEvent(new UploadEvent(UploadEvent.SELECTED, {file:event.currentTarget}));
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			dispatchEvent(new UploadEvent(UploadEvent.PROGRESS, {progress:event}));
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			if(event.type == HTTPStatusEvent.HTTP_RESPONSE_STATUS)
			{
				event.status;
			}
			else
			{
			}
		}
		
		private function uploadIOErrorHandle(event:IOErrorEvent):void
		{
			dispatchEvent(new UploadEvent(UploadEvent.ERROR, {error:event}));
		}

		/**
		 * 是否选择文件 
		 * @return 
		 * 
		 */		
		public function get isSelectedFile():Boolean
		{
			return _isSelectedFile;
		}

		/**
		 *  服务器地址
		 * @return 
		 * 
		 */		
		public function get serverPath():String
		{
			return _serverPath;
		}

		public function set serverPath(value:String):void
		{
			_serverPath = value;
		}

		/**
		 *  上传的目标路径（相对于服务器地址）
		 * @return 
		 * 
		 */		
		public function get folderName():String
		{
			return _folderName;
		}

		public function set folderName(value:String):void
		{
			_folderName = value;
		}

		/**
		 *  上传到服务器时的文件名（如果为 空字符串 则取本地文件名）
		 * @return 
		 * 
		 */		
		public function get fileName():String
		{
			return _fileName;
		}

		public function set fileName(value:String):void
		{
			
			_fileName = value.split("%").join("");
		}

		public function destroy():void
		{
			m_file = null;
		}

		/**
		 * 服务器类型 
		 * @return 
		 * 
		 */		
		public function get serverType():String
		{
			return _serverType;
		}

		public function set serverType(value:String):void
		{
			_serverType = value;
		}

	}
}