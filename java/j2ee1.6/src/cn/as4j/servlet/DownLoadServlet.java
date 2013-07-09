package cn.as4j.servlet;

import java.io.*;
import java.net.URLDecoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author 破晓(QQ群:272732356)
 *
 */
@SuppressWarnings("serial")
@WebServlet("/DownLoad")
public class DownLoadServlet extends HttpServlet {

  /**
   * Constructor of the object.
   */
  public DownLoadServlet() {
    super();
  }

  /**
   * Destruction of the servlet. <br>
   */
  public void destroy() {
    super.destroy(); // Just puts "destroy" string in log
    // Put your code here
  }

  /**
   * The doGet method of the servlet. <br>
   *
   * This method is called when a form has its tag value method equals to get.
   * 
   * @param request the request send by the client to the server
   * @param response the response send by the server to the client
   * @throws ServletException if an error occurred
   * @throws IOException if an error occurred
   */
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    doPost(request, response);
  }

  /**
   * The doPost method of the servlet. <br>
   *
   * This method is called when a form has its tag value method equals to post.
   * 
   * @param request the request send by the client to the server
   * @param response the response send by the server to the client
   * @throws ServletException if an error occurred
   * @throws IOException if an error occurred
   */
  @SuppressWarnings("deprecation")
  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String strFilePath = URLDecoder.decode(new String(request.getParameter("fliename").getBytes("iso-8859-1"),"utf-8"),"utf-8");
    String serverPath = URLDecoder.decode(new String(request.getParameter("fliePath").getBytes("iso-8859-1"),"utf-8"),"utf-8");
    String sysPath = request.getRealPath("/" + serverPath + "/");
    String fullFileName = sysPath + "/" + strFilePath;
    InputStream   is=null;   
    OutputStream   os=null;    
    try {
      //设置request对象的字符编码   
      request.setCharacterEncoding("utf-8");   
      File file = new File(fullFileName);
      if(strFilePath == null || strFilePath == "" || file.exists() == false){
        response.setContentType("text/html;charset=utf-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
        out.println("<HTML>");
        out.println("  <HEAD>");
        out.println("    <TITLE>ERROR</TITLE>");
        out.println("    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>");
        out.println("  </HEAD>");
        out.println("  <BODY>");
        out.println("    <p><center><font color='#ff0000' size='20'><b>");
        out.println("您所下载的文件不存在，可能已被管理员删除或已经转向了其他的地址，请与客服联系！");
        out.println("    </b></font> </center></p> <br> <br>");
        out.println("   <center> <font color='#ff00ff' size='12'><b>");
        out.println("    <a href='/'>返回首页</a><br>");
        out.println("    <a href='DownLoad?fliename=" + request.getParameter("fliename") + "'>重新下载</a>");
        out.println("    </b></font> </center> <br>");
        out.println("  </BODY>");
        out.println("</HTML>");
        out.flush();
        out.close();
      } else {

      response.setContentType("application/force-download;charset=utf-8");
      //response.setCharacterEncoding("utf-8"); 
      response.setHeader("Content-Disposition","attachment;filename=\"" + request.getParameter("fliename") + "\"");
      is = new BufferedInputStream(new FileInputStream(fullFileName));   
      //定义输出字节流   
      ByteArrayOutputStream baos = new ByteArrayOutputStream();   
      //定义response的输出流   
      os = new BufferedOutputStream(response.getOutputStream());   
      //定义buffer   
      byte[] buffer=new byte[4*1024];//4k   Buffer   
      int read =0;   
      //从文件中读入数据并写到输出字节流中   
      while ((read=is.read(buffer))!=-1){   
        baos.write(buffer,0,read);   
      }   
      //将输出字节流写到response的输出流中   
      os.write(baos.toByteArray());     
      }
    } catch (Exception e) {
      if (!e.getClass().getSimpleName().equals("ClientAbortException")) {        
        e.printStackTrace();
        response.setContentType("text/html;charset=utf-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
        out.println("<HTML>");
        out.println("  <HEAD>");
        out.println("    <TITLE>ERROR</TITLE>");
        out.println("    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>");
        out.println("  </HEAD>");
        out.println("  <BODY>");
        out.println("    <p><center><font color='#ff0000' size='20'><b>");
        out.println("网络连接超时，下载链接丢失，请重试！");
        out.println("    </b></font> </center> </p><br><br>");
        out.println("    <center><font color='#ff00ff' size='12'><b>");
        out.println("    <a href='/'>返回首页</a><br>");
        out.println("    <a href='DownLoad?fliename=" + request.getParameter("fliename") + "'>重新下载</a>");
        out.println("    </b></font> </center> <br>");
        out.println("  </BODY>");
        out.println("</HTML>");
        out.flush();
        out.close();
      }
    }
    finally{   
      //关闭输出字节流和response输出流   
		if(os !=null)
			os.close();   
		if(is != null)
			is.close();   
    }  
  }

  /**
   * Initialization of the servlet. <br>
   *
   * @throws ServletException if an error occurs
   */
  public void init() throws ServletException {
    // Put your code here
  }

}
