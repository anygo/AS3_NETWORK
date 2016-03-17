package com.airmyth.net.as3network.net.http
{
  import com.airmyth.net.as3network.model.Server;

	/**
	 * java通信 类
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class ASCallJava extends AbstractInvoker
	{
		/**
		 * 构造函数 相同的service 可使用一个实例 
		 * @param serverURL 服务器VO
		 * @param serviceName 服务名称（service名称）
		 * 
		 */		
		public function ASCallJava(server:Server=null, serviceName:String=null)
		{
			super(server, serviceName);
		}
		
		override protected function get servletPath():String
		{
			return "/ControlServlet";
		}
	}
}