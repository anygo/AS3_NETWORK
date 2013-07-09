package cn.as4j.util;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.StringReader;
import java.lang.reflect.Method;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import cn.as4j.bean.IParamResolve;
import cn.as4j.model.DataVo;
import cn.as4j.model.ModelBasic;

/**
 * 解析参数
 * @author 破晓
 *
 */
@SuppressWarnings({ "rawtypes", "unchecked" })
public class ParamDecoder {

	public IParamResolve outDecoder;
	
private static ParamDecoder instance;
	
	public static ParamDecoder getInstance()
	{
		if(instance == null)
			instance = new ParamDecoder();
		
		return instance;
	}
	
	/**
	 * 解析数据
	 * @param dis
	 * @return
	 * @throws Exception
	 */
	public DataVo decoder(byte[] data) throws Exception
	{		
		ByteArrayInputStream bis = new ByteArrayInputStream(data);
		DataInputStream dis = new DataInputStream(bis);
		
		DataVo dataVo = new DataVo();
		dataVo.setServiceName(dis.readUTF());  // 读取服务名称
		dataVo.setMethodName(dis.readUTF()); // 读取函数名称
		
		// 读取参数
		Object[] params = null;
		int len = dis.readInt();
		if(len == 0)
		{
			
		}
		else
		{
			params = new Object[len];
			for(int loop=0; loop<len; loop++)
			{
				params[loop] = readAll(dis);
			}
		}
		dataVo.setParams(params);
		
		return dataVo;
	}
	
	/**
	 * 构建数据
	 * @param dis
	 * @return
	 * @throws Exception
	 */
	public Object readAll(DataInputStream dis) throws Exception
	{
		Object param = null;
		Object outer = null;
		byte type = dis.readByte();
		
		if(type != ParamType.NULL && outDecoder != null)
		{
			outer = outDecoder.decode(type, dis);
		}
		if(type == ParamType.NULL)
		{
			param = null;
		}
		else if(outer != null)
		{
			return outer;
		}
		else if(type == ParamType.BOOLEAN)
		{
			param = dis.readBoolean();
		}
		else if(type == ParamType.INT || type == ParamType.UINT)
		{
			param = dis.readInt();
		}
		else if(type == ParamType.STRING)
		{
			param = dis.readUTF();
		}
		else if(type == ParamType.BYTE_ARRAY)
		{
			int len = dis.readInt();
			byte[] b = new byte[len];
			dis.read(b, 0, len);
			param = b;
		}
		else if(type == ParamType.NUMBER)
		{
			param = dis.readDouble();
		}
		else if(type == ParamType.ARRAY)
		{
			param = readArray(dis);
		}
		else if(type == ParamType.XML)
		{
			
			String xmlStr = dis.readUTF();   
            StringReader sr = new StringReader(xmlStr);   
            InputSource is = new InputSource(sr);   
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();   
            DocumentBuilder builder;   
            builder = factory.newDocumentBuilder();   
            Document doc = builder.parse(is); 
            param = doc;
		}
		else if(type == ParamType.DATE)
		{
			DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:ms");
			param = df.parse(dis.readUTF());
		}
		else if(type == ParamType.MODEL)
		{
			param = readModel(dis);
		}
		else if(type == ParamType.DICTIONARY || type == ParamType.OBJECT)
		{
			param = readObject(dis);
		}
		else if(type == ParamType.UNFOUND)
		{
			param = dis.readUTF();
		}
		else
		{
			System.out.println(type);
			throw new Exception("参数格式错误");
		}
		
		return param;
	}
	
	/**
	 * 读取数组
	 * @param dis
	 * @return
	 * @throws Exception
	 */
	public List readArray(DataInputStream dis) throws Exception
	{
		List lst = new ArrayList();
		int len = dis.readInt();
		
		for(int loop=0; loop<len; loop++)
		{
			lst.add(readAll(dis));
		}
		
		return lst;
	}
	
	/**
	 * 读取Object
	 * @param dis
	 * @return
	 * @throws Exception
	 */
	public Map<String, Object> readObject(DataInputStream dis) throws Exception
	{
		Map<String, Object> map = new HashMap<String, Object>();
		int len = dis.readInt();
		for(int loop=0; loop<len; loop++)
		{
			map.put(dis.readUTF(), readAll(dis));
		}
		
		return map;
	}
	
	
	/**
	 * 读取Model
	 * @param dis
	 * @return
	 * @throws Exception
	 */
	public ModelBasic readModel(DataInputStream dis) throws Exception
	{
		ModelBasic model = null;
		String nameSpace = dis.readUTF();
		Class cls = Class.forName(nameSpace);
		model = (ModelBasic)cls.newInstance();
		int len = dis.readInt();
		
		String functionName;
		String fieldName;
		Method method;
		for(int loop=0; loop<len; loop++)
		{
			fieldName = dis.readUTF();
			functionName = "set" + upperFirst(fieldName);
			Object param = readAll(dis);
			if(param == null)
			{
				method = model.getClass().getMethod(functionName, model.getClass().getDeclaredField(fieldName).getType());
			}
			else
			{
				method = model.getClass().getMethod(functionName, param.getClass()); 
			}
			method.invoke(model, param);
		}
		
		return model;
	}
	
	/**
	  * 将首字母转化为大写的方法
	  * 
	  * @param str
	  *            :需要转化的字符
	  * @return 转化后的结果
	  */
	 public static String upperFirst(String str) {
	  String first = str.substring(0, 1);
	  String last = str.substring(1);
	  return first.toUpperCase() + last;
	 }
}
