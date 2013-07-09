using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
///ParamType 的摘要说明
/// </summary>
public class ParamType
{
	//////////////////////////////////////////////////////////////////
	//                                       公有 类型     0 - 10
	//////////////////////////////////////////////////////////////////

	/**未知类型*/
	public static byte UNFOUND = 127;
	
	/**null*/
	public static byte NULL = 0;
	/**Boolean*/
	public static byte BOOLEAN = 1;
	/**int*/
	public static byte INT = 2; 
	/**String*/
	public static byte STRING = 3; 
	/**ByteArray, []*/
	public static byte BYTE_ARRAY = 4; 
	/**Array*/
	public static byte ARRAY = 5;
	/**Date*/
	public static byte DATE = 6;
	/**Object*/
	public static byte OBJECT = 7;
	/**xml*/
	public static byte XML = 8;
	
	/**model*/
	public static byte MODEL = 10;
	
	//////////////////////////////////////////////////////////////////
	//                                       AS 类型    11 - 20
	//////////////////////////////////////////////////////////////////
	
	/**uint*/
	public static byte UINT = 11;
	/**Number*/
	public static byte NUMBER = 12;
	/**Dictionary*/
	public static byte DICTIONARY = 13;
}