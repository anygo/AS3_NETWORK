package com.azri.as4j.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.w3c.dom.Document;


/**
 * 数据类型
 * @author 破晓
 *
 */
@SuppressWarnings("rawtypes")
public class ParamType {
	//////////////////////////////////////////////////////////////////
	//                                       公有 类型     0 - 10
	//////////////////////////////////////////////////////////////////

	/**未知类型*/
	public static final byte UNFOUND = 127;
	
	/**null*/
	public static final byte NULL = 0;
	/**Boolean*/
	public static final byte BOOLEAN = 1;
	/**int*/
	public static final byte INT = 2; 
	/**String*/
	public static final byte STRING = 3; 
	/**ByteArray, []*/
	public static final byte BYTE_ARRAY = 4; 
	/**Array*/
	public static final byte ARRAY = 5;
	/**Date*/
	public static final byte DATE = 6;
	/**Object*/
	public static final byte OBJECT = 7;
	/**xml*/
	public static final byte XML = 8;
	
	/**model*/
	public static final byte MODEL = 10;
	
	//////////////////////////////////////////////////////////////////
	//                                       AS 类型    11 - 20
	//////////////////////////////////////////////////////////////////
	
	/**uint*/
	public static final byte UINT = 11;
	/**Number*/
	public static final byte NUMBER = 12;
	/**Dictionary*/
	public static final byte DICTIONARY = 13;
	
	
	private static Map<Class, Class> typeMap = null;
	public static Map<Class, Class> getTypeMap() throws Exception
	{
		if(typeMap == null)
		{
			typeMap = new HashMap<Class, Class>();
			typeMap.put(ArrayList.class, List.class);
			typeMap.put(Class.forName("com.sun.org.apache.xerces.internal.dom.DeferredDocumentImpl"), Document.class);
		}
		
		return typeMap;
	}
}
