using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace as2DotNet
{
    /// <summary>
    ///DataVO 的摘要说明
    /// </summary>
    public class DataVO
    {
        /** 通信ID */
        private String _ACUID = "";
        private String _serviceName;
        private String _methodName;
        private Object[] _param;
        private String _resultStatus;
        private Object _result;
        private String _errorMessage;

        public String ACUID
        {
            get { return _ACUID; }
            set { _ACUID = value; }
        }

        public String ServiceName
        {
            get { return _serviceName; }
            set { _serviceName = value; }
        }

        public String MethodName
        {
            get { return _methodName; }
            set { _methodName = value; }
        }

        public Object[] Param
        {
            get { return _param; }
            set { _param = value; }
        }

        public String ResultStatus
        {
            get { return _resultStatus; }
            set { _resultStatus = value; }
        }

        public Object Result
        {
            get { return _result; }
            set { _result = value; }
        }

        public String ErrorMessage
        {
            get { return _errorMessage; }
            set { _errorMessage = value; }
        }
    }
}

