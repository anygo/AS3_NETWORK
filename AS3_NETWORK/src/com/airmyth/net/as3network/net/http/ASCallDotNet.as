package com.airmyth.net.as3network.net.http
{
	import com.airmyth.net.as3network.model.Server;
	
	import flash.utils.Endian;

	/**
	 * asp.net通信 类
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class ASCallDotNet extends AbstractInvoker
	{
		/**
		 * 构造函数 相同的service 可使用一个实例 
		 * @param server 服务器VO
		 * @param serviceName 服务名称（service名称）
		 * 
		 */		
		public function ASCallDotNet(server:Server=null, serviceName:String=null)
		{
			super(server, serviceName);
		}
		
		/**
		 * 字节序
		 * @return 
		 * 
		 * @see ByteArray.endian
		 */	
		override protected function get endian():String
		{
			return Endian.LITTLE_ENDIAN;
		}
		
		override protected function get servletPath():String
		{
			return "/Default.aspx";
		}
	}
}