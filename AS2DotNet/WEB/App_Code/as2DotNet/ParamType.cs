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
    public const byte UNFOUND = 127;
	
	/**null*/
    public const byte NULL = 0;
	/**Boolean*/
    public const byte BOOLEAN = 1;
	/**int*/
    public const byte INT = 2; 
	/**String*/
    public const byte STRING = 3; 
	/**ByteArray, []*/
    public const byte BYTE_ARRAY = 4; 
	/**Array*/
    public const byte ARRAY = 5;
	/**Date*/
    public const byte DATE = 6;
	/**Object*/
    public const byte OBJECT = 7;
	/**xml*/
    public const byte XML = 8;
	
	/**model*/
    public const byte MODEL = 10;
	
	//////////////////////////////////////////////////////////////////
	//                                       AS 类型    11 - 20
	//////////////////////////////////////////////////////////////////
	
	/**uint*/
    public const byte UINT = 11;
	/**Number*/
    public const byte NUMBER = 12;
	/**Dictionary*/
    public const byte DICTIONARY = 13;
    /**uShort*/
    public const byte USHORT = 14;
	/**Short*/
    public const byte SHORT = 15;
	/**ubyte*/
    public const byte UBYTE = 16;
	/**float*/
    public const byte FLOAT = 17;
	/**byte*/
    public const byte BYTE = 18;
}