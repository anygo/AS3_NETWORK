using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;

namespace as2DotNet
{
    /// <summary>
    ///ParamEncoder 的摘要说明
    /// </summary>
    public class ParamEncoder
    {
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
	    public byte[] encode(DataVO data)
	    {
            byte[] resultData = new byte[10];
            //BufferedStream bs = new BufferedStream();
            Stream stream = new MemoryStream(data);
            BinaryWriter reader = new BinaryWriter(stream, Encoding.UTF8);
            return null;
        }
    }
}
