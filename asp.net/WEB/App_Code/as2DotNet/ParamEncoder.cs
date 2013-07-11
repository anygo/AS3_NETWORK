using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Text;

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
            MemoryStream stream = new MemoryStream();
            BinaryWriter writer = new BinaryWriter(stream);

            writeUTF(writer, data.ResultStatus);
            if (data.ResultStatus == "error")
            {
                writeUTF(writer, data.ErrorMessage);
            }
            else
            {
                writeUTF(writer, data.ServiceName);
                writeUTF(writer, data.MethodName);
                writeAll(writer, data.Result);
            }

            return stream.GetBuffer();
        }

        public void writeAll(BinaryWriter writer, object data)
        {
            if (data == null)
            {
                writeByte(writer, ParamType.NULL);
            }
            else if (outEncoder != null && outEncoder.encode(data, writer))
            {
                return;
            }
            else if (data is string)
            {
                writeByte(writer, ParamType.STRING);
                writeUTF(writer, (string)data);
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
