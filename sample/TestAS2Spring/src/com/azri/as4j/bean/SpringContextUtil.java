package com.azri.as4j.bean;

import java.io.File;
import java.lang.reflect.Constructor;
import java.net.URL;
import java.net.URLDecoder;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;



/**
 * @author 破晓
 *
 */
public class SpringContextUtil {
	/**单例*/
	private static SpringContextUtil instance;
	
	/**获取Bean的工厂*/
	private IBeanFactory beanFactory;
	/**外部解析器*/
	private IParamResolve outerResolve;
	/**外部加密解密器*/
	private IParamEncrypt outerEncrypt;
	
	private SpringContextUtil() throws Exception
	{
		initData();
	}
	
	@SuppressWarnings("rawtypes")
	private void initData() throws Exception
	{
		String beanFactoryPath = "cn.as4j.bean.AS2JAVABeanFactory";
		String beanConfigName = "applicationContext.xml";
		
		URL fileUrl = getClass().getResource("/as2javaConfig.xml");

//		if(fileUrl != null)
		{
			String fileName = URLDecoder.decode(new String(fileUrl.getPath().getBytes("iso-8859-1"),"utf-8"),"utf-8");
			File f = new File(fileName);
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc = builder.parse(f);
			
			NamedNodeMap beanFactoryCon = doc.getElementsByTagName("beanFactory").item(0).getAttributes();
			NamedNodeMap outerResolveCon = doc.getElementsByTagName("outerResolve").item(0).getAttributes();
			NamedNodeMap outerEncryptCon = doc.getElementsByTagName("outerEncrypt").item(0).getAttributes();
			
			beanFactoryPath = beanFactoryCon.getNamedItem("class").getNodeValue();
			beanConfigName = beanFactoryCon.getNamedItem("config").getNodeValue();
			
			String outerResolvePath = outerResolveCon.getNamedItem("class").getNodeValue();
			String outerEncryptPath = outerEncryptCon.getNamedItem("class").getNodeValue();
			if(outerResolvePath.length() > 0)
				outerResolve = (IParamResolve) Class.forName(outerResolvePath).newInstance();
			if(outerEncryptPath.length() > 0)
				outerEncrypt = (IParamEncrypt) Class.forName(outerEncryptPath).newInstance();
		}
		
		Constructor bfConstructor = Class.forName(beanFactoryPath).getConstructor(String.class);
		beanFactory = (IBeanFactory) bfConstructor.newInstance(beanConfigName);
	}
	
	/**
	 * 根据名称获取Bean
	 * @param beanName
	 * @return
	 */
	public Object getBean(String beanName)
	{
		return beanFactory.getBean(beanName);
	}
	
	/**
	 * 判断Bean是否存在
	 * @param beanName
	 * @return
	 */
	public Boolean containsBean(String beanName)
	{
		return beanFactory.containsBean(beanName);
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
	 * 获取唯一实例
	 * @return
	 * @throws Exception 
	 */
	public static SpringContextUtil getInstance() throws Exception
	{
		if(instance == null)
			instance = new SpringContextUtil();
		
		return instance;
	}
}
