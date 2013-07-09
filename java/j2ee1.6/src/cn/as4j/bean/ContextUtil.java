package cn.as4j.bean;

import java.io.File;
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
public class ContextUtil {
	/**单例*/
	private static ContextUtil instance;
	
	/**获取Service所在的包名*/
	private String servicePackage;
	/**外部解析器*/
	private IParamResolve outerResolve;
	/**外部加密解密器*/
	private IParamEncrypt outerEncrypt;
	
	private ContextUtil() throws Exception
	{
		initData();
	}
	
	private void initData() throws Exception
	{
		URL fileUrl = getClass().getResource("/as2javaConfig.xml");

		if(fileUrl != null)
		{
			String fileName = URLDecoder.decode(new String(fileUrl.getPath().getBytes("iso-8859-1"),"utf-8"),"utf-8");
			File f = new File(fileName);
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc = builder.parse(f);
			
			NamedNodeMap beanFactoryCon = doc.getElementsByTagName("service").item(0).getAttributes();
			NamedNodeMap outerResolveCon = doc.getElementsByTagName("outerResolve").item(0).getAttributes();
			NamedNodeMap outerEncryptCon = doc.getElementsByTagName("outerEncrypt").item(0).getAttributes();
			
			servicePackage = beanFactoryCon.getNamedItem("package").getNodeValue();
			
			String outerResolvePath = outerResolveCon.getNamedItem("class").getNodeValue();
			String outerEncryptPath = outerEncryptCon.getNamedItem("class").getNodeValue();
			if(outerResolvePath.length() > 0)
				outerResolve = (IParamResolve) Class.forName(outerResolvePath).newInstance();
			if(outerEncryptPath.length() > 0)
				outerEncrypt = (IParamEncrypt) Class.forName(outerEncryptPath).newInstance();
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

	/**
	 * 根据service名称返回对应的类
	 * @param serviceName
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("rawtypes")
	
	public Object getBean(String serviceName) throws Exception {
		Class cls = Class.forName(servicePackage + "." + serviceName);
        if(cls != null)
        	return cls.newInstance();
        else
        	return null;
	}
}
