using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BLL;
using MODEL;
using System.Collections;
using System.IO;
using System.Text;
using as2DotNet;
using System.Reflection;

public partial class _Default : System.Web.UI.Page
{
	private ParamEncoder encoder;
	private ParamDecoder decoder;
    private IParamEncrypt encrypt;
	private DataVO dataVo;
    private ContextUtil context;
    private Stream output;

    protected void Page_Load(object sender, EventArgs e)
    {
        byte[] byteData = null;
        try
        { 
            if (context == null)
            {
                context = ContextUtil.getInstance(Server.MapPath("."));
                encrypt = context.getOuterEncrypt();
            }

            if (encoder == null)
                encoder = ParamEncoder.getInstance();
            if (decoder == null)
                decoder = ParamDecoder.getInstance();

            Stream sis = Request.InputStream;
            BinaryReader reader = new BinaryReader(sis, Encoding.UTF8);
            int size = Request.ContentLength;

            reader.Read(byteData, 0, size);
            reader.Close();
            reader.Dispose();


            // 解密
            if (encrypt != null)
                byteData = encrypt.decrypt(byteData);

            dataVo = decoder.decoder(byteData, context.getOuterResolve());
            Type serviceCls = context.getService(context.getServiceNameSpace() + "." + dataVo.ServiceName);

            MethodInfo method = serviceCls.GetMethod(dataVo.MethodName);

            object result = method.Invoke(System.Activator.CreateInstance(serviceCls), dataVo.Param);

            dataVo.Result = result;
            dataVo.ResultStatus = "success";
            byte[] resultData = encoder.encode(dataVo, context.getOuterResolve());

            if (encrypt != null)
                resultData = encrypt.encrypt(resultData);

            output = Response.OutputStream;
            output.Write(resultData, 0, resultData.Length);
            output.Flush();
            output.Close();
            output.Dispose();
        }
        catch(Exception exc)
        {
            if (dataVo == null && byteData != null)
                dataVo = decoder.decoder(byteData, context.getOuterResolve());
            if (dataVo == null)
               dataVo = new DataVO();
            dataVo.ResultStatus = "error";
            dataVo.ErrorMessage = exc.ToString();
            byte[] resultData = encoder.encode(dataVo, context.getOuterResolve());

            if (encrypt != null)
                resultData = encrypt.encrypt(resultData);
            output = Response.OutputStream;
            output.Write(resultData, 0, resultData.Length);
            output.Flush();
            output.Close();
            output.Dispose();
        }
    }

        public string readString(BinaryReader reader)
        {
            ushort len = reader.ReadUInt16();
            System.Text.UTF8Encoding converter = new System.Text.UTF8Encoding();
            string str = converter.GetString(reader.ReadBytes(len), 0, len);

            return str;
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

        public void writeUnsignedShort(BinaryWriter writer, ushort value)
        {
            writer.Write(value);
        }
}