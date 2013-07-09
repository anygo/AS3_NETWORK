package cn.as3network.util
{
	import flash.utils.ByteArray;

	/**
	 *参数加密接口 
	 * @author 破晓
	 * 
	 */	
	public interface IParamEncrypt
	{
		/**
		 * 加密
		 * @param param
		 * @return
		 */
		 function encrypt(param:ByteArray):ByteArray;
		
		/**
		 * 解密
		 * @param param
		 * @return
		 */
		 function decrypt(param:ByteArray):ByteArray;
		 
		 /**
		  * 外部加密解密器 
		  * @param value
		  * 
		  */		 
		 function set outParamEncrypt(value:IParamEncrypt):void;
	}
}