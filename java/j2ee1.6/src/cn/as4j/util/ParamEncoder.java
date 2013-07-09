package cn.as4j.util;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;

import cn.as4j.bean.IParamResolve;
import cn.as4j.model.DataVo;
import cn.as4j.model.ModelBasic;


/**
 * 序列化返回值
 * @author 破晓
 * @version 1.0_debug
 */
@SuppressWarnings("rawtypes")
public class ParamEncoder {
	public IParamResolve outEncoder;

	private static ParamEncoder instance;
	
	public static ParamEncoder getInstance()
	{
		if(instance == null)
			instance = new ParamEncoder();
		
		return instance;
	}
	
	/**
	 * 序列化返回值
	 * @param data
	 * @param steam
	 * @return
	 * @throws Exception
	 */
	public byte[] encode(DataVo data) throws Exception
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		dos.writeUTF(data.getResultStatus());
		if(data.getResultStatus() == "error")
		{
			dos.writeUTF(data.getErrorMessage());
		}
		else
		{
			dos.writeUTF(data.getServiceName());
			dos.writeUTF(data.getMethodName());
			writeAll(data.getResult(), dos);
		}
		
		return bos.toByteArray();
	}
	
	public void writeAll(Object result, DataOutputStream dos) throws Exception
	{
		if(result == null)
		{
			dos.writeByte(ParamType.NULL);
		}
		else if(outEncoder != null && outEncoder.encode(result, dos))
		{
			return;
		}
		else if(result instanceof Boolean)
		{
			dos.writeByte(ParamType.BOOLEAN);  // 写入类型
			dos.writeBoolean((Boolean)result);
		}
		else if(result instanceof Integer || result instanceof Short || result instanceof Byte)
		{
			dos.writeByte(ParamType.INT);  // 写入类型
			dos.writeInt((Integer)result);
		}
		else if(result instanceof Double || result instanceof Float || result instanceof Long)
		{
			dos.writeByte(ParamType.NUMBER);  // 写入类型
			dos.writeDouble((Double)result);
		}
		else if(result instanceof String || result instanceof Character || result instanceof BigDecimal || result instanceof BigInteger)
		{
			dos.writeByte(ParamType.STRING);  // 写入类型
			dos.writeUTF(result.toString());
		}
		else if(result instanceof Date || result instanceof Calendar)
		{
			Date date;
			if(result instanceof Calendar)
				date = ((Calendar)result).getTime();
			else
				date = (Date)result;
			
			SimpleDateFormat sf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:ms");

			dos.writeByte(ParamType.DATE);  // 写入类型
			dos.writeUTF(sf.format(date));
		}
		else if(result instanceof Document)
		{
			TransformerFactory tf = TransformerFactory.newInstance();   
            Transformer t = tf.newTransformer();   
//            t.setOutputProperty("encoding", "UTF-8");// 
            ByteArrayOutputStream bos = new ByteArrayOutputStream();   
            t.transform(new DOMSource((Document)result), new StreamResult(bos));   
            
            dos.writeByte(ParamType.XML);  // 写入类型
			dos.writeUTF(bos.toString("UTF-8"));
		}
		else if(result instanceof Byte[] || result instanceof byte[])
		{ 
			byte[] b;
			if(result instanceof Byte[])
			{
				b = new byte[((Byte[])result).length];
				int loop = 0;
				for(Byte ib : (Byte[])result)
				{
					b[loop++] = ib.byteValue();
				}
			}
			else
				b = ((byte[])result);
			
			int len = b.length;
			dos.writeByte(ParamType.BYTE_ARRAY);  // 写入类型
			dos.writeInt(len);
			dos.write(b, 0, len);
		}
		else if(result instanceof Object[])
		{
			writeArray((Object[])result, dos);
		}
		else if(result instanceof List)
		{
			writeList((List)result, dos);
		}
		else if(result instanceof Map)
		{
			writeMap((Map)result, dos);
		}
		else if(result instanceof ModelBasic)
		{
			writeModel((ModelBasic)result, dos);
		}
		else if(result instanceof Object)
		{
			writeObject(result, dos);
		}
		else
		{
			dos.writeByte(ParamType.UNFOUND);  // 写入类型
			dos.writeUTF(result.toString());
		}
	}
	
	public void writeModel(ModelBasic model, DataOutputStream dos) throws Exception
	{
		dos.writeByte(ParamType.MODEL);// 写入类型
		dos.writeUTF(model.getModelNameSpace());

		Map<String, Object> map = new HashMap<String, Object>();
		Method[] ms = model.getClass().getMethods();
		for(Method m : ms) {
			String functionName = m.getName();
			if(functionName.startsWith("get") && functionName != "getModelNameSpace" && functionName != "getClass")
			{
				map.put(fristToLower(functionName.substring(3, functionName.length())), m.invoke(model));
			}
		}


		dos.writeInt(map.size());
		Iterator iterator = map.keySet().iterator();
		while(iterator.hasNext()) {
			Object key = iterator.next();//key
			dos.writeUTF(key.toString());
			writeAll(map.get(key), dos);
		}
	}
	
	public void writeArray(Object[] lobj, DataOutputStream dos) throws Exception
	{
		dos.writeByte(ParamType.ARRAY);// 写入类型
		dos.writeInt(lobj.length);
		for(Object item : lobj)
		{
			writeAll(item, dos);
		}
	}
	
	public void writeList(List lst, DataOutputStream dos) throws Exception
	{
		dos.writeByte(ParamType.ARRAY);// 写入类型
		dos.writeInt(lst.size());
		for(Object item : lst)
		{
			writeAll(item, dos);
		}
	}
	
	public void writeMap(Map map, DataOutputStream dos) throws Exception
	{
		dos.writeByte(ParamType.OBJECT);// 写入类型
		dos.writeInt(map.size());
		
		Iterator iterator = map.keySet().iterator();
		while(iterator.hasNext()) {
			Object key = iterator.next();//key
			dos.writeUTF(key.toString());
			writeAll(map.get(key), dos);
		}
	}
	
	public void writeObject(Object obj, DataOutputStream dos) throws Exception
	{
		dos.writeByte(ParamType.OBJECT);  // 写入类型
		Field[] fs = obj.getClass().getFields();
		dos.writeInt(fs.length);
		for(Field item : fs)
		{
			dos.writeUTF(item.getName());
			writeAll(item.get(obj), dos);
		}
	}
	
	/**
	 *首字母改为小写 
	 * @param value
	 * @return 
	 * 
	 */		
	private String fristToLower(String value)
	{
		return value.substring(0, 1).toLowerCase() + value.substring(1);
	}
}
