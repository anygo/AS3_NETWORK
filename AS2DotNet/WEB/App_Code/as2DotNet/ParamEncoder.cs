using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Text;
using System.Collections;
using System.Xml;
using MODEL;
using System.Reflection;

namespace as2DotNet
{
    /// <summary>
    ///ParamEncoder 的摘要说明
    /// </summary>
    public class ParamEncoder
    {
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
        public byte[] encode(DataVO data, IParamResolve outEncoder)
	    {
            _outEncoder = outEncoder;

            MemoryStream stream = new MemoryStream();
            BinaryWriter writer = new BinaryWriter(stream);

            long startPos = writer.BaseStream.Position;
            writeUInt(writer, 0);

            writeUTF(writer, data.ACUID);
            writeUTF(writer, data.ServiceName);
            writeUTF(writer, data.MethodName);
            writeUTF(writer, data.ResultStatus);
            if (data.ResultStatus == "error")
            {
                writeUTF(writer, data.ErrorMessage);
            }
            else
            {
                writeAll(writer, data.Result);
            }

            _outEncoder = null;

            return stream.GetBuffer();
        }

        public void writeAll(BinaryWriter writer, object data)
        {
            if (data == null)
            {
                writeByte(writer, ParamType.NULL);
            }
            else if (_outEncoder != null && _outEncoder.encode(data, writer))
            {
                return;
            }
            else if (data is bool)
            {
                writeByte(writer, ParamType.BOOLEAN);
                writeBoolean(writer, (bool)data);
            }
            else if (data is string)
            {
                writeByte(writer, ParamType.STRING);
                writeUTF(writer, (string)data);
            }
            else if (data is byte)
            {
                writeByte(writer, ParamType.BYTE);
                writeByte(writer, (byte)data);
            }
            else if (data is sbyte)
            {
                writeByte(writer, ParamType.UBYTE);
                writeByte(writer, (byte)data);
            }
            else if (data is double)
            {
                writeByte(writer, ParamType.NUMBER);
                writeDouble(writer, (byte)data);
            }
            else if (data is float)
            {
                writeByte(writer, ParamType.FLOAT);
                writeFloat(writer, (float)data);
            }
            else if (data is int)
            {
                writeByte(writer, ParamType.INT);
                writeInt(writer, (int)data);
            }
            else if (data is uint)
            {
                writeByte(writer, ParamType.UINT);
                writeUInt(writer, (uint)data);
            }
            else if (data is long)
            {
                writeByte(writer, ParamType.NUMBER);
                writeDouble(writer, (double)data);
            }
            else if (data is short)
            {
                writeByte(writer, ParamType.SHORT);
                writeShort(writer, (short)data);
            }
            else if (data is ushort)
            {
                writeByte(writer, ParamType.USHORT);
                writeUnsignedShort(writer, (ushort)data);
            }
            else if (data is DateTime)
            {
                writeDate(writer, (DateTime)data);
            } 
            else if (data is byte[])
            {
                writeByte(writer, ParamType.BYTE_ARRAY);
                byte[] b = (byte[])data;
                writeInt(writer, b.Length);
                writeBytes(writer, b);
            }
            else if (data is ArrayList)
            {
                writeArrayList(writer, (ArrayList)data);
            }
            else if (data is object[])
            { 
                writeArray(writer, (object[])data);
            }
            else if (data is XmlDocument)
            {
                writeXML(writer, (XmlDocument)data);
            }
            else if (data is IModelBasic)
            {
                writeModel(writer, (IModelBasic)data);
            }
            else if (data is Hashtable)
            {
                writeHashtable(writer, (Hashtable)data);
            }
            else if (ContextUtil.getInstance(null).checkModelBasic(data.GetType().FullName))
            {
                writeModel(writer, data);
            }
            else if (data is object)
            {
                writeObject(writer, data);
            }
            else
            {
                writeByte(writer, ParamType.UNFOUND);
                writeUTF(writer, (string)data);
            }
        }

        public void writeDate(BinaryWriter writer, DateTime value)
        { 
            writeByte(writer, ParamType.DATE);
            //writeUTF(writer, value.ToString("yyyy-MM-dd HH:mm:ss:fff"));
            TimeSpan ts = value - DateTime.Parse("1970-1-1");
            writeDouble(writer, ts.TotalMilliseconds);
        }

        public void writeXML(BinaryWriter writer, XmlDocument value)
        {
            writeByte(writer, ParamType.XML);
            MemoryStream stream = new MemoryStream();
            XmlWriter xw = new XmlTextWriter(stream, System.Text.Encoding.UTF8);
            value.Save(xw);
            StreamReader sr = new StreamReader(stream, System.Text.Encoding.UTF8);
            stream.Position = 0;
            string XMLString = sr.ReadToEnd();
            sr.Close();
            stream.Close();

            writeUTF(writer, XMLString);
        }

        public void writeArrayList(BinaryWriter writer, ArrayList value)
        {
            writeByte(writer, ParamType.ARRAY);
            writeInt(writer, value.Count);
            foreach (object item in value)
            {
                writeAll(writer, item);
            }
        }

        public void writeArray(BinaryWriter writer, object[] value)
        {
            writeByte(writer, ParamType.ARRAY);
            writeInt(writer, value.Length);
            foreach (object item in value)
            {
                writeAll(writer, item);
            }
        }

        public void writeHashtable(BinaryWriter writer, Hashtable value)
        {
            writeByte(writer, ParamType.OBJECT);
            writeInt(writer, value.Count);
            foreach (DictionaryEntry item in value) //ht为一个Hashtable实例
            {
                writeUTF(writer, (string)item.Key);//de.Key对应于keyvalue键值对key
                writeAll(writer, item.Value);//de.Key对应于keyvalue键值对value
            }
        }

        public void writeModel(BinaryWriter writer, Object value)
        {
            writeByte(writer, ParamType.MODEL);
            writeUTF(writer, value.GetType().FullName);
            Type type = value.GetType();
            PropertyInfo[] properties = type.GetProperties();
            writeInt(writer, properties.Length);
            foreach (PropertyInfo item in properties)
            {
                writeUTF(writer, item.Name);
                writeAll(writer, item.GetValue(value, null));
            }
        }

        public void writeObject(BinaryWriter writer, object value)
        {
            writeByte(writer, ParamType.OBJECT);
            Type type = value.GetType();
            PropertyInfo[] properties = type.GetProperties();
            writeInt(writer, properties.Length);
            foreach (PropertyInfo item in properties)
            {
                writeUTF(writer, item.Name);
                writeAll(writer, item.GetValue(value, null));
            }
        }

        public void writeUTF(BinaryWriter writer, string value)
        {
            long startPos = writer.BaseStream.Position;
            writeUnsignedShort(writer, 0);
            writeUTFBytes(writer, value);
            long endPos = writer.BaseStream.Position;
            ushort len = (ushort)(endPos - startPos - 2);
            writer.BaseStream.Position = startPos;
            writeUnsignedShort(writer, len);
            writer.BaseStream.Position = endPos;
        }

        public void writeUTFBytes(BinaryWriter writer, string value)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(value);
            writer.Write(bytes);
        }

        public void writeBoolean(BinaryWriter writer, bool value)
        {
            writer.Write(value);
        }

        public void writeByte(BinaryWriter writer, byte value)
        {
            writer.Write(value);
        }

        public void writeBytes(BinaryWriter writer, byte[] value)
        {
            writer.Write(value);
        }

        public void writeDouble(BinaryWriter writer, double value)
        {
            writer.Write(value);
        }

        public void writeFloat(BinaryWriter writer, float value)
        {
            writer.Write(value);
        }

        public void writeInt(BinaryWriter writer, int value)
        {
            writer.Write(value);
        }
        public void writeUInt(BinaryWriter writer, uint value)
        {
            writer.Write(value);
        }

        public void writeShort(BinaryWriter writer, short value)
        {
            writer.Write(value);
        }

        public void writeUnsignedShort(BinaryWriter writer, ushort value)
        {
            writer.Write(value);
        }
    }
}
