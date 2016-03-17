package com.airmyth.util;

import java.beans.PropertyDescriptor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class CacheUtil {
	/** 缓存数据模型的所有属性 */
	private static Map<String, Map<String, Field>> modelFieldCache = new HashMap<String, Map<String,Field>>();
	
	@SuppressWarnings("rawtypes")
	public static Map<String, Field> getFieldCache(Class cls)
	{
		String nameSpace = cls.getName();
		if(modelFieldCache.containsKey(nameSpace))
			return modelFieldCache.get(nameSpace);
		Field[] fileds;
		Class tempCls = cls;
		Map<String, Field> filedMap= new HashMap<String, Field>();
		while(!tempCls.equals(Object.class))
		{
			try
			{
				fileds = tempCls.getDeclaredFields();
				
				for(Field tf :fileds)
				{
					filedMap.put(tf.getName(), tf);
				}
				tempCls = tempCls.getSuperclass();
			}
			catch(Exception e)
			{
				System.out.println(e);
			}
		}
		
		modelFieldCache.put(nameSpace, filedMap);
		
		return filedMap;
	}
	
	private static Map<String, Map<String, Method>> modelGetterCache = new HashMap<String, Map<String,Method>>();
	
	/**
	 * 获取model的所有getter方法
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("rawtypes")
	public static Map<String, Method> getModelGetter(Object model) throws Exception
	{
		Class cls = model.getClass();
		String className = cls.getName();
		if(modelGetterCache.containsKey(className))
		{
			return modelGetterCache.get(className);
		}
		
		Map<String, Method> map = new HashMap<String, Method>();
		Map<String, Field> filedMap = getFieldCache(cls);
		Collection<Field> fileds = filedMap.values();
		PropertyDescriptor pd = null;  
		for(Field tf : fileds) {
			if(tf.isEnumConstant())
				continue;
			int tm = tf.getModifiers();
			if(Modifier.isStatic(tm) || Modifier.isPublic(tm))
				continue;
			String fieldName = tf.getName();
			pd = new PropertyDescriptor(fieldName, cls);
			map.put(fieldName, pd.getReadMethod());
		}
		modelGetterCache.put(className, map);
		
		return map;
	}
	
	private static Map<String, Map<String, Method>> serviceMethodCache = new HashMap<String, Map<String,Method>>();
	
	/**
	 * 缓存service中的所有函数
	 * @param service
	 * @param method
	 * @param bean
	 * @return
	 * @throws Exception
	 */
	public static Method getMethodAtService(String service, String method, Object bean) throws Exception
	{
		Map<String, Method> methods = null;
		if(serviceMethodCache.containsKey(service))
			methods = serviceMethodCache.get(service);
		else
		{
			methods = new HashMap<String, Method>();
			Method[] ms = bean.getClass().getMethods();
			for(Method tm:ms)
			{
				methods.put(tm.getName(), tm);
			}
			
			serviceMethodCache.put(service, methods);
		}
		
		if(methods.containsKey(method))
			return methods.get(method);
		else
			throw new NoSuchMethodException("在service：" + service + " 中未发现函数：" + method);
	}
	
	/**
	 * 获取实例中指定属性的值
	 * @param bean
	 * @param property
	 * @return
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 */
	@SuppressWarnings("rawtypes")
	public static Object getValueAtBean(Object bean, String property) throws IllegalArgumentException, IllegalAccessException
	{
		Field[] fileds;
		Class tempCls = bean.getClass();
		Map<String, Field> filedMap= new HashMap<String, Field>();
		while(!tempCls.equals(Object.class))
		{
			try
			{
				fileds = tempCls.getDeclaredFields();
				
				for(Field tf :fileds)
				{
					filedMap.put(tf.getName(), tf);
				}
				tempCls = tempCls.getSuperclass();
			}
			catch(Exception e)
			{
				System.out.println(e);
			}
		}
		
		if(filedMap.containsKey(property))
			return filedMap.get(property).get(bean);
		
		return null;
	}

}
