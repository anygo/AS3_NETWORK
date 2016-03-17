using System;
using System.Collections;
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

    private Hashtable modelBasics = new Hashtable();

    Assembly modelDLL;
    Assembly serviceDLL;
    string serviceNameSpace;

    private bool cacheService = true;

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
        string cache = rootNode.SelectSingleNode("service").Attributes.GetNamedItem("cache").Value;
        cacheService = "true".Equals(cache);

        XmlNodeList modelList = rootNode.SelectSingleNode("ModelBasic").ChildNodes;
        string mitem;
        for (int loop = 0; loop < modelList.Count; loop++)
        {
            mitem = modelList.Item(loop).Attributes.GetNamedItem("class").Value;
            if (mitem != "")
                modelBasics.Add(mitem, mitem);
        }

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

    private Hashtable serviceCache = new Hashtable();

    /**
     * 获取service实例
     * 
     */
    public Type getService(string serviceName)
    {
        if (serviceDLL == null) return null;

        if (!cacheService)
            return serviceDLL.GetType(serviceName);

        if (!serviceCache.ContainsKey(serviceName))
        {
            Type t = serviceDLL.GetType(serviceName);
            serviceCache.Add(serviceName, t);
        }
        
        //动态生成ClassLibrary1.Class类的实例 
//        Object service = System.Activator.CreateInstance(t);
        return (Type)serviceCache[serviceName];
    }

    /***
     * 校验是否是合法数据模型
     **/
    public bool checkModelBasic(string mo)
    {
        return modelBasics.Contains(modelBasics);
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