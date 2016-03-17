package com.airmyth.util;

import java.beans.PropertyDescriptor;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.StringReader;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import com.airmyth.bean.IParamResolve;
import com.airmyth.model.DataVo;

/**
 * 解析参数
 * @author 破晓
 *
 */
@SuppressWarnings({ "rawtypes", "unchecked" })
public class ParamDecoder {

	private IParamResolve _outDecoder;
	
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
	public DataVo decoder(byte[] data, IParamResolve outDecoder) throws Exception
	{		
		_outDecoder = outDecoder;
		ByteArrayInputStream bis = new ByteArrayInputStream(data);
		DataInputStream dis = new DataInputStream(bis);
		
		DataVo dataVo = new DataVo();
		
		if(dis.available() != dis.readInt())
			throw new Exception("丢包了");
		
		dataVo.setACUID(dis.readUTF());
		dataVo.setServiceName(dis.readUTF());  // 读取服务名称
		dataVo.setMethodName(dis.readUTF()); // 读取函数名称
		
		// 读取参数
		Object[] params = null;
		int len = dis.readInt();
		if(len == 0)
		{
			System.out.println("warning:###AS端没有传参数");
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
		
		_outDecoder = null;
		
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
		
		if(type != ParamType.NULL && _outDecoder != null)
		{
			outer = _outDecoder.decode(type, dis);
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
//			DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:ms");
//			param = df.parse();
//			String strd = dis.readUTF();
//			String[] dateTime = strd.split(" ");
//			String[] date = dateTime[0].split("-");
//			String[] time = dateTime[1].split(":");
//			Date d = new Date(Integer.parseInt(date[0]), 
//					Integer.parseInt(date[1]), 
//					Integer.parseInt(date[2]), 
//					Integer.parseInt(time[0]), 
//					Integer.parseInt(time[1]), 
//					Integer.parseInt(time[2]));
			param = new Date((long) dis.readDouble());
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
	public Object readModel(DataInputStream dis) throws Exception
	{
		Object model = null;
		String nameSpace = dis.readUTF();
		Class cls = Class.forName(nameSpace);
		model = cls.newInstance();
		int len = dis.readInt();
		
		String fieldName = null;
		Method method;
		
		
		Map<String, Field> filedMap = CacheUtil.getFieldCache(cls);
		
		PropertyDescriptor pd = null;  
		Object param = null;
		try
		{
			for(int loop=0; loop<len; loop++)
			{
				fieldName = dis.readUTF();
				
				param = readAll(dis);
				
				if(filedMap.containsKey(fieldName))
				{
					pd = new PropertyDescriptor(fieldName, cls);
					method = pd.getWriteMethod();
					//param = pd.getPropertyType().cast(param);  // 强制类型转换
					method.invoke(model, new Object[]{param});
				}
				else
				{
					System.out.println("warning: ###类" + nameSpace + "中，属性：【" + fieldName + "】  未定义，所以没有对该属性进行赋值");
				}
			}
		} 
		catch (IllegalArgumentException e)
		{
			if(filedMap != null && filedMap.containsKey(fieldName))
				throw new ClassCastException(nameSpace + "类中的属性：" 
						+ fieldName + "类型转换失败 ,正确的类型为：" + filedMap.get(fieldName).getType()
						+ "但实际为：" + ((param!=null)?param.getClass().getName():"null"));
			else
				throw e;
		}
		
		return model;
	}
}
