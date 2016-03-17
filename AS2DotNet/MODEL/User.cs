using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MODEL
{
    /**
     * 会员
     */
    public class User :IModelBasic
    {
        private int _id;               // 用户Id
        private string _username;      // 用户名
        private string _password;      // 密码
        private string _address;       // 地址
        private string _phone;         // 手机号
        private string _realName;      // 真实姓名

        public User()
        {
            
        }

        public string nickName
        {
            get { return _realName; }
            set { _realName = value; }
        }

        public string phone
        {
            get { return _phone; }
            set { _phone = value; }
        }

        public string address
        {
            get { return _address; }
            set { _address = value; }
        }

        public string username
        {
            get { return _username; }
            set { _username = value; }
        }

        public string password
        {
            get { return _password; }
            set { _password = value; }
        }

        public int id
        {
            set { _id = value; }
            get { return _id; }
        }
    }
}
