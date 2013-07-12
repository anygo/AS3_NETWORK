using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Text;
using System.Collections;
using System.Reflection;
using MODEL;
using System.Xml;

namespace as2DotNet
{
    /// <summary>
    ///ParamDecoder 的摘要说明
    /// </summary>
    public class ParamDecoder
    {
	    public IParamResolve outDecoder;
	
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
        public DataVO decoder(byte[] data)
        {
            Stream stream = new MemoryStream(data);
            BinaryReader reader = new BinaryReader(stream, Encoding.UTF8);
            
            DataVO dataVo = new DataVO();
            dataVo.ServiceName = readString(reader); // 读取服务名称
            dataVo.MethodName = readString(reader); // 读取函数名称

            // 读取参数
		    Object[] param = null;
            int len = reader.ReadInt32();
            if (len == 0)
            {

            }
            else
            { 
                param = new Object[len];
			    for(int loop=0; loop<len; loop++)
			    {
                    param[loop] = readAll(reader);
			    }
            }
            dataVo.Param = param;

            return dataVo;
        }

        public Object readAll(BinaryReader reader)
        {
            Object param = null;
            Object outer = null;
            byte type = reader.ReadByte();
            if(type != ParamType.NULL && outDecoder != null)
		    {
                outer = outDecoder.decode(type, reader);
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
                param = reader.ReadBoolean();
		    }
		    else if(type == ParamType.INT || type == ParamType.UINT)
		    {
                param = reader.ReadInt32();
		    }
		    else if(type == ParamType.STRING)
		    {
                param = readString(reader);
		    }
		    else if(type == ParamType.BYTE_ARRAY)
		    {
                int len = reader.ReadInt32();
                param = reader.ReadBytes(len);
		    }
		    else if(type == ParamType.NUMBER)
		    {
                param = reader.ReadDouble();
		    }
		    else if(type == ParamType.ARRAY)
		    {
                param = readArray(reader);
		    }
		    else if(type == ParamType.XML)
		    {
                XmlDocument doc = new XmlDocument();
                StringReader sReader = new StringReader(readString(reader));
                doc.Load(sReader);
//                doc.LoadXml(readString(reader));
		    }
		    else if(type == ParamType.DATE)
		    {
                param = DateTime.ParseExact(readString(reader), "yyyy-MM-dd HH:mm:ss:fff", null);
		    }
		    else if(type == ParamType.MODEL)
		    {
                param = readModel(reader);
		    }
		    else if(type == ParamType.DICTIONARY || type == ParamType.OBJECT)
		    {
                param = readObject(reader);
		    }
		    else if(type == ParamType.UNFOUND)
		    {
                param = readString(reader);
		    }
		    else
		    {
			    throw new Exception("参数格式错误");
		    }

            return param;
        }

        public string readString(BinaryReader reader)
        {
            ushort len = reader.ReadUInt16();
            System.Text.UTF8Encoding converter = new System.Text.UTF8Encoding();
            string str = converter.GetString(reader.ReadBytes(len), 0, len);
            
            return str;
        }

        public ArrayList readArray(BinaryReader reader)
        {
            ArrayList lst = new ArrayList();
            int len = reader.ReadInt32();

            for (int loop = 0; loop < len; loop++)
            {
                lst.Add(readAll(reader));
            }

            return lst;
        }

        public Hashtable readObject(BinaryReader reader)
        {
            Hashtable hb = new Hashtable();
            int len = reader.ReadInt32();
            for (int loop = 0; loop < len; loop++)
            {
                hb.Add(readString(reader), readAll(reader));
            }
            return hb;
        }

        public ModelBasic readModel(BinaryReader reader)
        {
            ModelBasic model = null;
            string nameSpace = readString(reader);

            Type modelCls = ContextUtil.getInstance(null).getModel(nameSpace);
            model = (ModelBasic)System.Activator.CreateInstance(modelCls);
            int len = reader.ReadInt32();

            string fieldName;
            PropertyInfo property;
            for (int loop = 0; loop < len; loop++)
            {
                fieldName = readString(reader);
                object param = readAll(reader);

                property = modelCls.GetProperty(fieldName);
                property.SetValue(model, param, null);
            }

            return model;
        }

    }
}

