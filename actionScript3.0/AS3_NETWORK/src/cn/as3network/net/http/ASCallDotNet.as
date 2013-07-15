package cn.as3network.net.http
{
	import flash.utils.Endian;

	/**
	 * asp.net通信 类
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public dynamic class ASCallDotNet extends AbstractInvoker
	{
		/**
		 * 构造函数 相同的service 可使用一个实例 
		 * @param serverURL 服务器地址
		 * @param serviceName 服务名称（service名称）
		 * 
		 */		
		public function ASCallDotNet(serverURL:String=null, serviceName:String=null)
		{
			super(serverURL, serviceName);
			if(encoder)
				encoder.endian = Endian.LITTLE_ENDIAN;
			if(decoder)
				decoder.endian = Endian.LITTLE_ENDIAN;
		}
		
		override protected function get servletPath():String
		{
			return "/Default.aspx";
		}
	}
}