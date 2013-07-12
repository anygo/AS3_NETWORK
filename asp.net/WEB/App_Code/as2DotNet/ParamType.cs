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
    public static const byte UNFOUND = 127;
	
	/**null*/
    public static const byte NULL = 0;
	/**Boolean*/
    public static const byte BOOLEAN = 1;
	/**int*/
    public static const byte INT = 2; 
	/**String*/
    public static const byte STRING = 3; 
	/**ByteArray, []*/
    public static const byte BYTE_ARRAY = 4; 
	/**Array*/
    public static const byte ARRAY = 5;
	/**Date*/
    public static const byte DATE = 6;
	/**Object*/
    public static const byte OBJECT = 7;
	/**xml*/
    public static const byte XML = 8;
	
	/**model*/
    public static const byte MODEL = 10;
	
	//////////////////////////////////////////////////////////////////
	//                                       AS 类型    11 - 20
	//////////////////////////////////////////////////////////////////
	
	/**uint*/
    public static const byte UINT = 11;
	/**Number*/
    public static const byte NUMBER = 12;
	/**Dictionary*/
    public static const byte DICTIONARY = 13;
    /**uShort*/
    public static const byte USHORT = 14;
	/**Short*/
    public static const byte SHORT = 15;
	/**ubyte*/
    public static const byte UBYTE = 16;
	/**float*/
    public static const byte FLOAT = 17;
	/**byte*/
	public static const byte BYTE = 18;
}