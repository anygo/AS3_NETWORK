using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Upload : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "text/plain";
        string uploadFolder = Request.QueryString["folderName"];
        string fileName = Request.QueryString["fileName"];
        if (fileName == null || fileName.Length == 0)
            fileName = Request.Form["Filename"];
        HttpFileCollection files = Request.Files;
        if (files.Count > 0)
        {
            string path = Server.MapPath(uploadFolder);
            HttpPostedFile file = files[0];
            if (file != null && file.ContentLength > 0)
            {
                string savePath = path + "/" + fileName;
                file.SaveAs(savePath);
            }
        }
        else
        {
            Response.Write("参数错误");
            Response.End();
        }     
    }
}