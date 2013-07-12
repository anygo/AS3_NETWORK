using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml;
using System.Reflection;

/// <summary>
///ContextUtil 的摘要说明
/// </summary>
public class ContextUtil
{
    private static ContextUtil instance;
    private XmlDocument xmlDoc;


    /**外部解析器*/
    private IParamResolve outerResolve;
    /**外部加密解密器*/
    private IParamEncrypt outerEncrypt;

    Assembly modelDLL;
    Assembly serviceDLL;
    string serviceNameSpace;

    private string _serverPath;

	public ContextUtil(string serverPath)
	{
        _serverPath = serverPath;

        initData();
	}
    

    private void initData()
    {
        xmlDoc = new XmlDocument();
        xmlDoc.Load(_serverPath + "/as2aspx.xml");

        XmlNode rootNode = xmlDoc.SelectSingleNode("config");

        string modelUrl = rootNode.SelectSingleNode("model").InnerText;
        string serviceUrl = rootNode.SelectSingleNode("service").InnerText;
        serviceNameSpace = rootNode.SelectSingleNode("service").Attributes.GetNamedItem("nameSpace").Value;
        modelDLL = Assembly.LoadFrom(_serverPath + modelUrl);
        serviceDLL = Assembly.LoadFrom(_serverPath + serviceUrl);

        XmlAttributeCollection outerResolveXAC = rootNode.SelectSingleNode("outerResolve").Attributes;
        string outerResolveDLL = outerResolveXAC.GetNamedItem("dll").Value;
        string outerResolveClass = outerResolveXAC.GetNamedItem("class").Value;

        XmlAttributeCollection outerEncryptXAC = rootNode.SelectSingleNode("outerEncrypt").Attributes;
        string outerEncryptDLL = outerResolveXAC.GetNamedItem("dll").Value;
        string outerEncryptClass = outerResolveXAC.GetNamedItem("class").Value;

        if (outerResolveDLL != "" && outerResolveClass != "")
        {
            Type outerResolveType = Assembly.LoadFrom(_serverPath + outerResolveDLL).GetType(outerResolveClass);
            outerResolve = (IParamResolve)System.Activator.CreateInstance(outerResolveType);
        }
        if (outerEncryptDLL != "" && outerEncryptClass != "")
        {
            Type outerEncryptType = Assembly.LoadFrom(_serverPath + outerEncryptDLL).GetType(outerEncryptClass);
            outerEncrypt = (IParamEncrypt)System.Activator.CreateInstance(outerEncryptType);
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
     * 获取service的命名空间
     */
    public string getServiceNameSpace()
    {
        return serviceNameSpace;
    }

    /**
     * 获取实体类
     * 
     */
    public Type getModel(string modelName)
    {
        if (modelDLL == null) return null;

        Type t = modelDLL.GetType(modelName);
        //动态生成ClassLibrary1.Class类的实例 
//        ModelBasic model = (ModelBasic)System.Activator.CreateInstance(t);

        return t;
    }

    /**
     * 获取service实例
     * 
     */
    public Type getService(string serviceName)
    {
        if (serviceDLL == null) return null;

        Type t = serviceDLL.GetType(serviceName);
        //动态生成ClassLibrary1.Class类的实例 
//        Object service = System.Activator.CreateInstance(t);

        return t;
    }

    public static ContextUtil getInstance(string serverPath)
    {
        if (serverPath == null)
            return instance;
        if (instance == null)
            instance = new ContextUtil(serverPath);

        return instance;
    }
}