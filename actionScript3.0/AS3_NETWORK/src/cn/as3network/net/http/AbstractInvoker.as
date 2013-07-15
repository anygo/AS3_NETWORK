package cn.as3network.net.http
{
	import cn.as3network.IDispose;
	import cn.as3network.event.FaultEvent;
	import cn.as3network.event.ResultEvent;
	import cn.as3network.model.DataVo;
	import cn.as3network.util.IParamEncrypt;
	import cn.as3network.util.IParamResolve;
	import cn.as3network.util.ParamDecoder;
	import cn.as3network.util.ParamEncoder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	/**
	 * 回调成功，返回方法调用结果 
	 */
	[Event(name="callServerResultEvent", type="cn.as3network.event.ResultEvent")]
	/**
	 * 方法调用失败 
	 */
	[Event(name="callServerFailEvent", type="cn.as3network.event.FaultEvent")]
	
	/**
	 * 关闭连接 
	 */
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * 通信 基类（抽象类）
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	
	public class AbstractInvoker extends EventDispatcher implements IDispose
	{
		private var _server:String;
		private var _data:DataVo;
		
		private var loader:URLStream;
		private var request:URLRequest;
		protected var encoder:ParamEncoder;
		protected var decoder:ParamDecoder;
		
		private var _outerResolve:IParamResolve;
		private var _outerEncrypt:IParamEncrypt;
		
		private var _isClose:Boolean;
		
		private var _methods:Array = [];
		
		/**
		 * 构造函数 相同的service 可使用一个实例 
		 * @param serverURL 服务器地址
		 * @param serviceName 服务名称（service名称）
		 * 
		 */		
		public function AbstractInvoker(serverURL:String=null, serviceName:String=null)
		{
			super();
			
			_data = new DataVo();
			
			loader = new URLStream();
			loader.addEventListener(Event.COMPLETE, onCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			request = new URLRequest();
			request.method = URLRequestMethod.POST;
			request.contentType = "application/octet-stream";
			
			server = serverURL;
			_data.serviceName = serviceName;
			
			if(!encoder)
				encoder = new ParamEncoder();
			if(!decoder)
				decoder = new ParamDecoder();
		}
		
		public function dispose():void
		{
			close();
		}
		
		/**
		 * 发送数据 
		 * @param methodName 函数名
		 * @param parma 参数列表
		 * 
		 */		
		public function send(methodName:String, params:Array=null):void
		{
			if(_isClose)
				throw new Error("连接已关闭", "-1010");
			if(request.url == null || request.url.length == 0)
				throw new Error("服务器地址不能为空", "-1009");
			
			_data.methodName = methodName;
			_data.params = params;
			
			var requestData:ByteArray = encoder.encode(_data, _outerResolve?_outerResolve.encode:null);
			//加密
			if(_outerEncrypt)
				requestData = _outerEncrypt.encrypt(requestData);
			request.data = requestData
			loader.load(request);
		}
		
		/**
		 * 关闭连接，等待垃圾回收 
		 * 
		 */		
		public function close():void
		{
			encoder = null;
			decoder = null;
			_outerResolve = null;
			_outerEncrypt = null;
			
			_data = null;
			
			loader.removeEventListener(Event.COMPLETE, onCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			loader = null;
			request = null;
			
			_isClose = true;
			
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			var error:FaultEvent = new FaultEvent(event);
			dispatchEvent(error);
			if(this[error.methodName])
				(this[error.methodName] as Method).dispatchEvent(error);
		}
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			var error:FaultEvent = new FaultEvent(event);
			dispatchEvent(error);
			if(this[error.methodName])
				(this[error.methodName] as Method).dispatchEvent(error);
		}
		
		private function onCompleteHandler(event:Event):void
		{
			var stream :URLStream = event.currentTarget as URLStream;
			
			var resultStream:ByteArray = new ByteArray();
			stream.readBytes(resultStream, 0, stream.bytesAvailable);
			// 解密
			if(_outerEncrypt)
				resultStream = _outerEncrypt.decrypt(resultStream);
			
			var resultData:DataVo = decoder.decode(resultStream, _outerResolve?_outerResolve.decode:null);
			
			if(resultData.resultStatus == "error")
			{
				var error:FaultEvent = new FaultEvent(resultData);
				dispatchEvent(error);
				if(this[error.methodName])
					(this[error.methodName] as Method).dispatchEvent(error);
			}
			else
			{
				var e:ResultEvent = new ResultEvent(resultData);
				dispatchEvent(e);
				(this[resultData.methodName] as Method).dispatchEvent(e);
			}
		}
		
		/**
		 *  服务器地址 
		 * @return 
		 * 
		 */		
		public function get server():String
		{
			return _server;
		}
		
		/**
		 * 服务器地址 
		 * @param value 如：http://localhost:8080
		 * 
		 */		
		public function set server(value:String):void
		{
			if(_isClose)
				throw new Error("连接已关闭", "-1010");
			_server = value;
			
			if(request)
				request.url = _server + servletPath;
		}
		
		/**
		 * 服务名称 
		 * @return 
		 * 
		 */		
		public function get serviceName():String
		{
			return _data.serviceName;
		}
		
		public function set serviceName(value:String):void
		{
			_data.serviceName = value;
		}
		
		/**
		 * 设置外部解析器 
		 * @param value
		 * 
		 */		
		public function set outerResolve(value:IParamResolve):void
		{
			if(_isClose)
				throw new Error("连接已关闭", "-1010");
			_outerResolve = value;
		}
		
		/**
		 * 外部加密解密器 
		 * @param value
		 * 
		 */		
		public function set outerEncrypt(value:IParamEncrypt):void
		{
			if(_isClose)
				throw new Error("连接已关闭", "-1010");
			_outerEncrypt = value;
		}
		
		/**连接是否关闭*/
		public function get isClose():Boolean
		{
			return _isClose;
		}
		
		[Inspectable(category="General", arrayType="cn.as3network.net.http.Method")]
		public function get methods():Array
		{
			return _methods;
		}
		public function set methods(value:Array):void
		{
			_methods = value;
			for each(var m:Method in _methods)
			{
				m.sendHandler = send;
				this[m.name] = m;
			}
		}
		
		/**
		 * 根据名称返回相应的 Method
		 * @param name
		 * @return 
		 * 
		 * @see Method
		 */		
		public function getMethod(name:String):Method
		{
			for each(var m:Method in _methods)
			{
				if(m.name == name)
					return m;
			}
			return null;
		}
		
		protected function get servletPath():String
		{
			return "";
		}
	}
}