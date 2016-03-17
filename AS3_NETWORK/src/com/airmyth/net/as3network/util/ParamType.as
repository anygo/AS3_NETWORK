package com.airmyth.net.as3network.util
{
	

	/**
	 * 数据类型
	 * @author 破晓
	 * 
	 */	
	public class ParamType
	{
		public function ParamType()
		{
		}
		
		//////////////////////////////////////////////////////////////////
		//                                       公有 类型     0 - 10
		//////////////////////////////////////////////////////////////////

		/**未知类型*/
		public static const UNFOUND:int = 127;
		
		/**null*/
		public static const NULL:int = 0;
		/**Boolean*/
		public static const BOOLEAN:int = 1;
		/**int*/
		public static const INT:int = 2; 
		/**String*/
		public static const STRING:int = 3; 
		/**ByteArray, byte[]*/
		public static const BYTE_ARRAY:int = 4; 
		/**Array*/
		public static const ARRAY:int = 5;
		/**Date*/
		public static const DATE:int = 6;
		/**Object*/
		public static const OBJECT:int = 7;
		/**xml*/
		public static const XML:int = 8;
		
		/**model*/
		public static const MODEL:int = 10;
		
		//////////////////////////////////////////////////////////////////
		//                                       AS 类型    11 - 20
		//////////////////////////////////////////////////////////////////
		
		/**uint*/
		public static const UINT:int = 11;
		/**Number*/
		public static const NUMBER:int = 12;
		/**Dictionary*/
		public static const DICTIONARY:int = 13;
		/**uShort*/
		public static const USHORT:int = 14;
		/**Short*/
		public static const SHORT:int = 15;
		/**ubyte*/
		public static const UBYTE:int = 16;
		/**float*/
		public static const FLOAT:int = 17;
		/**byte*/
		public static const BYTE:int = 18;
		
	}
}