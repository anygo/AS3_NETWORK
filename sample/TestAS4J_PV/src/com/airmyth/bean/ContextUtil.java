package com.airmyth.bean;

import java.io.File;
import java.lang.reflect.Constructor;
import java.net.URL;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;

/**
 * @author 破晓
 *
 */
public class ContextUtil {
	/**单例*/
	private static ContextUtil instance;
	
	/**获取Bean的工厂*/
	private IBeanFactory beanFactory = null;
	
	/**获取Service所在的包名*/
	private String servicePackage;
	/**外部解析器*/
	private IParamResolve outerResolve;
	/**外部加密解密器*/
	private IParamEncrypt outerEncrypt;
	
    /** 无法实现IModelBasic接口的数据模型类，比如已经打好包的无法修改的 */	
	private List<String> modelBasic = new ArrayList<String>();
	
	private boolean cache = true;
	
	private ContextUtil() throws Exception
	{
		initData();
	}
	
	private void initData() throws Exception
	{
		serviceCache = new HashMap<String, Object>();
		URL fileUrl = getClass().getResource("/as2javaConfig.xml");

		if(fileUrl != null)
		{
			String fileName = URLDecoder.decode(new String(fileUrl.getPath().getBytes("iso-8859-1"),"utf-8"),"utf-8");
			File f = new File(fileName);
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc = builder.parse(f);
			
			NamedNodeMap beanFactoryCon = doc.getElementsByTagName("beanFactory").item(0).getAttributes();
			NamedNodeMap serviceCon = doc.getElementsByTagName("service").item(0).getAttributes();
			NamedNodeMap outerResolveCon = doc.getElementsByTagName("outerResolve").item(0).getAttributes();
			NamedNodeMap outerEncryptCon = doc.getElementsByTagName("outerEncrypt").item(0).getAttributes();
			NodeList modelBasicCon = doc.getElementsByTagName("model");
			
			for(int loop=0; loop<modelBasicCon.getLength(); loop++)
			{
				modelBasic.add(modelBasicCon.item(loop).getAttributes().getNamedItem("class").getNodeValue());
			}
			
			servicePackage = serviceCon.getNamedItem("package").getNodeValue();
			cache = "true".equals(serviceCon.getNamedItem("cache").getNodeValue());
			
			String outerResolvePath = outerResolveCon.getNamedItem("class").getNodeValue();
			String outerEncryptPath = outerEncryptCon.getNamedItem("class").getNodeValue();
			if(outerResolvePath.length() > 0)
				outerResolve = (IParamResolve) Class.forName(outerResolvePath).newInstance();
			if(outerEncryptPath.length() > 0)
				outerEncrypt = (IParamEncrypt) Class.forName(outerEncryptPath).newInstance();
			
			String beanFactoryPath = beanFactoryCon.getNamedItem("class").getNodeValue();
			String beanConfigName = beanFactoryCon.getNamedItem("config").getNodeValue();
			
			if(beanFactoryPath.length() > 0)
			{
				Constructor<?> bfConstructor = Class.forName(beanFactoryPath).getConstructor(String.class);
				beanFactory = (IBeanFactory) bfConstructor.newInstance(beanConfigName);
			}
		}
	}
	
	/**
	 * 获取外部解析器
	 * @return
	 */
	public IParamResolve getOuterResolve()
	{
		return outerResolve;
	}
	
	
	/**
	 * 获取外部加密解密器
	 * @return
	 */
	public IParamEncrypt getOuterEncrypt()
	{
		return outerEncrypt;
	}
	
	
	/**
	 * 获取Service所在的包名
	 * @return
	 */
	public String getServicePackage() {
		return servicePackage;
	}
	
	/**
	 * 获取唯一实例
	 * @return
	 * @throws Exception 
	 */
	public static ContextUtil getInstance() throws Exception
	{
		if(instance == null)
			instance = new ContextUtil();
		
		return instance;
	}
	
	private Map<String, Object> serviceCache;

	/**
	 * 根据service名称返回对应的类
	 * @param serviceName
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("rawtypes")
	
	public Object getBean(String serviceName) throws Exception {
		if(!cache)
		{
			if(beanFactory != null)
			{
				return serviceCache.get(serviceName);
			}
			
			return Class.forName(servicePackage + "." + serviceName);
		}
		
		if(serviceCache.containsKey(serviceName))
			return serviceCache.get(serviceName);
		else
		{
			if(beanFactory != null)
			{
				serviceCache.put(serviceName, beanFactory.getBean(serviceName));
				return serviceCache.get(serviceName);
			}
			
			Class cls = Class.forName(servicePackage + "." + serviceName);
			if(cls != null)
			{
				serviceCache.put(serviceName, cls.newInstance());
				return serviceCache.get(serviceName);
			}
			else
				return null;
		}
	}

	
	private static HttpServletRequest request;
	
	public static HttpServletRequest getRequest() {
		return request;
	}

	public static void setRequest(HttpServletRequest value) {
		request = value;
	}
	
	public List<String> getModelBasic()
	{
		return modelBasic;
	}
	
	
	/**
	 *  验证model是否是合法的数据模型
	 * @param modelClass
	 * @return
	 */
	public boolean checkModelBasic(String modelClass)
	{
		return modelBasic.contains(modelClass);
	}
}