package com.airmyth.net.as3network.net.http
{	
	import com.airmyth.net.as3network.NetWorkFactory;
	import com.airmyth.net.as3network.event.NetFaultEvent;
	import com.airmyth.net.as3network.event.NetResultEvent;
	import com.airmyth.net.as3network.model.DataVo;
	import com.airmyth.net.as3network.model.Server;
	import com.airmyth.net.as3network.model.Session;
	import com.airmyth.net.as3network.net.IInvoker;
	import com.airmyth.net.as3network.util.IParamEncrypt;
	import com.airmyth.net.as3network.util.IParamResolve;
	import com.airmyth.net.as3network.util.ParamDecoder;
	import com.airmyth.net.as3network.util.ParamEncoder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * 回调成功，返回方法调用结果 
	 */
	[Event(name="result", type="com.airmyth.net.as3network.event.NetResultEvent")]
	/**
	 * 方法调用失败 
	 */
	[Event(name="fault", type="com.airmyth.net.as3network.event.NetFaultEvent")]
	
	/**
	 * 关闭连接 
	 */
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * 通信 基类（抽象类）
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	
	[DefaultProperty("methods")]
	public class AbstractInvoker extends EventDispatcher implements IInvoker
	{
		private var _server:Server;
		
		private var _serviceName:String;
		
		private var _outerResolve:IParamResolve;
		private var _outerEncrypt:IParamEncrypt;
		
		private var _methods:Array = [];
		private var _isClose:Boolean;
		
		/**
		 * 构造函数 相同的service 可使用一个实例 
		 * @param server 服务器
		 * @param serviceName 服务名称（service名称）
		 * 
		 */		
		public function AbstractInvoker(serverValue:Server=null, service:String=null)
		{
			super();
			
			server = serverValue;
			_serviceName = service;
		}
		
		public function destroy():void
		{
			close();
		}
		
		public function send(methodName:String, params:Array=null, resultHandler:Function=null, faultHandler:Function=null, paramTypes:Array=null, requestHeads:Object=null):Session
		{
			server ||= NetWorkFactory.getInstance().getServer();   // TODO: 这里有时间再优化，在这里不应该出现 NetWorkFactory 这个类
			if(!server)
				throw new Error("server 还没有完成初始化，请在NetWorkFactory实例的Complete事件触发后再调用", "-1011");
			var session:Session = new Session();
			session.invoker = this;
			session.url = _server.url + servletPath;
			session.method = getMethod(methodName);
			session.resultHandler = resultHandler;
			session.faultHandler = faultHandler;
			session.data.params = params;
			session.data.methodName = methodName;
			session.data.serviceName = _serviceName;
			session.paramTypes = paramTypes;
			
			session.data.requestHeads = requestHeads;
			
			AbstractChannelManager.getInstance().addTask(session);
			return session;
		}
		
		public function getRequestData(dvo:Session):ByteArray
		{
			var requestData:ByteArray = ParamEncoder.instance.encode(dvo, endian, _outerResolve?_outerResolve.encode:null, server.checkRegularModels, server.getServerModelByData);
			//加密
			if(_outerEncrypt)
				requestData = _outerEncrypt.encrypt(requestData);
			
			return requestData;
		}		
		
		public function fail(error:*, session:Session):void
		{
			var errorEvt:NetFaultEvent = new NetFaultEvent(error, session);
			if(session.faultHandler != null)
				session.faultHandler(errorEvt);
			
			dispatchEvent(errorEvt);
			session.method.dispatchEvent(errorEvt);
		}
		
		public function success(result:ByteArray, session:Session):void
		{
			
			// 解密
			if(_outerEncrypt)
				result = _outerEncrypt.decrypt(result);
			
			var resultData:DataVo = ParamDecoder.instance.decode(result, endian, _outerResolve?_outerResolve.decode:null, server.getModel);
			
			session.data.result = resultData.result;
			session.data.resultStatus = resultData.resultStatus;
			
			if(resultData.resultStatus == "error")
				fail(resultData, session);
			else
			{
				var e:NetResultEvent = new NetResultEvent(session);
				if(session.resultHandler != null)
					session.resultHandler(e);
				dispatchEvent(e);
				
				session.method.dispatchEvent(e);
			}
		}
		
		/**
		 * 关闭连接，等待垃圾回收 
		 * 
		 */		
		public function close():void
		{
			_outerResolve = null;
			_outerEncrypt = null;
			
			_server = null;
			
			methods = [];
			
			_isClose = true;
			
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 *  服务器地址 
		 * @return 
		 * 
		 */		
		public function get server():Server
		{
			return _server;
		}
		
		/**
		 * 服务器地址 
		 * @param value 如：http://localhost:8080
		 * 
		 */		
		public function set server(value:Server):void
		{
			if(_isClose)
				throw new Error("连接已关闭", "-1010");
			_server = value;
		}
		
		/**
		 * 服务名称 
		 * @return 
		 * 
		 */		
		public function get serviceName():String
		{
			return _serviceName;
		}
		
		public function set serviceName(value:String):void
		{
			_serviceName = value;
		}
		
		/**
		 * 设置外部解析器 
		 * @param value
		 * 
		 */		
		public function set outerResolve(value:IParamResolve):void
		{
			_outerResolve = value;
		}
		
		/**
		 * 外部加密解密器 
		 * @param value
		 * 
		 */		
		public function set outerEncrypt(value:IParamEncrypt):void
		{
			_outerEncrypt = value;
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
				_methods[m.name] = m;
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
			var m:Method = _methods[name];
			if(!m)
			{
				m = new Method();
				m.name = name;
				m.sendHandler = send;
				_methods.push(m);
				_methods[name] = m;
			}
			return m;
		}
		
		protected function get servletPath():String
		{
			return "";
		}
		
		public function get isClose():Boolean
		{
			return _isClose;
		}
		
		/**
		 * 字节序
		 * @return 
		 * 
		 * @see ByteArray.endian
		 */	
		protected function get endian():String
		{
			return Endian.BIG_ENDIAN;
		}
	}
}
