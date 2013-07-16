您可以使用ashx代替aspx

BLL 文件夹为测试时使用，正式项目可以删掉
MODEL/User.cs    为测试时使用，正式项目可以删掉

类型对应关系
AS         to    ASP.NET
null,undefined     null
Boolean            bool
int,uint           int
Number             double
String             string
ByteArray          byte[]
Array              ArrayList
XML                XmlDocument
Date               DateTime
Dictionary,Object  Hashtable
ModelBasic         ModelBasic


ASP.NET   to         AS
null                null
bool                Boolean
string              Sting
byte,int,short      int
sbyte,uint,ushort   uint
double,long,float   Number
DateTime            Date
byte[]              ByteArray
ArrayList,object[]  Array
object,Hashtable    Object
XmlDocument         XML
ModelBasic          ModelBasic