package cn.as4j.servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;

import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * 类名 ：UploadFile 
 * @author 破晓(QQ群:272732356)
 */
@SuppressWarnings("serial")
@WebServlet("/Upload")
public class UploadFile extends HttpServlet {

  // 限制文件的上传大小
  private static final int    INT_MAX_POST_SIZE        = 2 * 1024 * 1024 * 1024;
  // 设置内存写入临界值
  private static final int    INT_THRESHOLD_SIZE       = 4096;

  public UploadFile() {
    super();
  }

  @Override
  public void destroy() {
    super.destroy();
  }

  /**
   * 接收从客户端传来的数据，并保存在指定的目录文件中
   * @param request
   * @param response
   * @throws ServletException
   * @throws IOException
   * @author 破晓
   */
  @SuppressWarnings("deprecation")
  protected void processRequest(HttpServletRequest request,
                                HttpServletResponse response) 
                                throws ServletException, IOException {
    try {
      // 文件存放的路径，此处可以从客户端指定，如果需要请去掉注释
      String strFolderName = URLDecoder.decode(new String(request.getParameter("folderName").getBytes("iso-8859-1"),"utf-8"),"utf-8");
      
      // 从客户端生成并传来的文件名
      String strFileName = URLDecoder.decode(new String(request.getParameter("fileName").getBytes("iso-8859-1"),"utf-8"),"utf-8");
    
      // 创建磁盘文件工厂
      DiskFileItemFactory objectFactory = new DiskFileItemFactory();
      
      // 设置直接存储内存临界值4M，节约内存
      objectFactory.setSizeThreshold(INT_THRESHOLD_SIZE);

      // 创建上传处理器
      ServletFileUpload objectUpload = new ServletFileUpload(objectFactory);
      
      // 设置最大允许上传文件大小
      objectUpload.setSizeMax(INT_MAX_POST_SIZE);
      
      // 取得客户端请求，放入迭代器
      List<?> lstFileItems = objectUpload.parseRequest(request);
      Iterator<?> itrRequest = lstFileItems.iterator();

      // 循环取出请求，并处理上传
      while (itrRequest.hasNext()) {
        
        //生成代写文件
        FileItem fileTemp = (FileItem) itrRequest.next();
        
        //判断是否为文件表单内容
        if (!fileTemp.isFormField()) {
          
          // 取得文件名
          String strFromName = new String(fileTemp.getName().getBytes("gbk"), "utf-8");

          // 取得文件扩展名
          if(strFileName.length() == 0)
        	  strFileName = strFromName;
          else
        	  strFileName += strFromName.substring(strFromName.lastIndexOf("."));
          
         // 写入文件
          fileTemp.write(new File(request.getRealPath("/" + strFolderName) + "/" + strFileName));
        }
      }
    }
    catch (Exception e) {
    	request.setCharacterEncoding("utf-8");   
    	response.setContentType("text/html;charset=utf-8");
        PrintWriter out = response.getWriter();
        out.println("error;");
        out.println(e.toString());
        out.flush();
        out.close();
      e.printStackTrace();
    }
  }

  /**
   * servlet 的 GET 方法，全部交给processRequest(request, response)处理
   * @param request
   * @param response
   * @throws ServletException
   * @throws IOException
   * @author 破晓
   */
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    processRequest(request, response);
  }

  /**
   * servlet 的 POST 方法，全部交给processRequest(request, response)处理
   * @param request
   * @param response
   * @throws ServletException
   * @throws IOException
   * @author 破晓
   */
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    processRequest(request, response);
  }

}
