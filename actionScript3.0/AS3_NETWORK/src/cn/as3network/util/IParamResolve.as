package cn.as3network.util
{
	import flash.utils.ByteArray;

	/**
	 * 外部解析器接口 
	 * @author 破晓
	 * 
	 */	
	public interface IParamResolve
	{
		/**
		 * 序列化 
		 * @param param
		 * @param stream
		 * @return 
		 * 
		 */		
		 function encode(param:*, stream:ByteArray):Boolean;
		
		/**
		 * 反序列化 
		 * @param type 类型
		 * @param stream
		 * @return 
		 * 
		 */		
		 function decode(type:int, stream:ByteArray):*;
		 
		 /**
		  * 外部解析接口 
		  * @param value
		  * 
		  */		 
		 function set outParamResolve(value:IParamResolve):void;
	}
}