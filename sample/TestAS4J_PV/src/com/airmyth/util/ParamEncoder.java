package com.airmyth.util;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;

import com.airmyth.bean.ContextUtil;
import com.airmyth.bean.IParamResolve;
import com.airmyth.model.DataVo;
import com.airmyth.model.IModelBasic;


/**
 * 序列化返回值
 * @author 破晓
 * @version 1.0_debug
 */
@SuppressWarnings("rawtypes")
public class ParamEncoder {
	private IParamResolve _outEncoder;

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
	public byte[] encode(DataVo data, IParamResolve outEncoder) throws Exception
	{
		_outEncoder = outEncoder;
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		
		dos.writeUTF(data.getACUID());
		dos.writeUTF(data.getServiceName());
		dos.writeUTF(data.getMethodName());
		dos.writeUTF(data.getResultStatus());
		if(data.getResultStatus() == "error")
			dos.writeUTF(data.getErrorMessage());
		else
			writeAll(data.getResult(), dos);
		
		_outEncoder = null;
		
		
		return bos.toByteArray();
	}
	
	public void writeAll(Object result, DataOutputStream dos) throws Exception
	{
		if(result == null)
		{
			dos.writeByte(ParamType.NULL);
		}
		else if(_outEncoder != null && _outEncoder.encode(result, dos))
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
			
//			SimpleDateFormat sf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:ms");
//			dos.writeUTF(sf.format(date));

			dos.writeByte(ParamType.DATE);  // 写入类型
			dos.writeDouble(date.getTime());
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
		else if(result instanceof IModelBasic)
		{
			writeModel((IModelBasic)result, dos);
		}
		else if(ContextUtil.getInstance().checkModelBasic(result.getClass().getName()))
		{
			writeModel(result, dos);
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
	
	public void writeModel(Object model, DataOutputStream dos) throws Exception
	{
		dos.writeByte(ParamType.MODEL);// 写入类型
		dos.writeUTF(model.getClass().getName());

		Map<String, Method> map = CacheUtil.getModelGetter(model);
		
		dos.writeInt(map.size());
		Iterator iterator = map.keySet().iterator();
		while(iterator.hasNext()) {
			Object key = iterator.next();//key
			dos.writeUTF(key.toString());
			writeAll(map.get(key).invoke(model), dos);
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
}
