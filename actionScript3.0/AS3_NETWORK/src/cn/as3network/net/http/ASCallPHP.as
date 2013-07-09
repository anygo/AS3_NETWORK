package cn.as3network.net.http
{

	/**
	 * 通信 类
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public dynamic class ASCallPHP extends AbstractInvoker
	{
		private const SERVLET_PATH:String = "/as2php/AS2PHP.php";
		
		/**
		 * 构造函数 相同的service 可使用一个实例 
		 * @param serverURL 服务器地址
		 * @param serviceName 服务名称（service名称）
		 * 
		 */		
		public function ASCallPHP(serverURL:String=null, serviceName:String=null)
		{
			super(serverURL, serviceName);
		}
		
		override protected function get servletPath():String
		{
			return "/as2php/AS2PHP.php";
		}
	}
}