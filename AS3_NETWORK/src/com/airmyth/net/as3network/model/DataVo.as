package com.airmyth.net.as3network.model
{
	import flash.events.HTTPStatusEvent;
	
	/**
	 * 数据 
	 * @author 破晓
	 * 
	 */	
	public class DataVo
	{
		public function DataVo()
		{
		}
		
		/** 通信ID */
		public var ACUID:String = "";
		
		/**服务名称*/
		public var serviceName:String;
		/**函数名称*/
		public var methodName:String;
		/**参数列表*/
		public var params:Array;
		
		/**返回状态 error:异常； success:成功*/
		public var resultStatus:String;
		/**返回值*/
		public var result:*;
		/**异常信息*/
		public var errorMessage:String;
		
		public var httpStatus:HTTPStatusEvent;
		
		public var requestHeads:Object;
	}
}