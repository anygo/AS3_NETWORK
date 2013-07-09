using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MODEL
{
    public abstract class ModelBasic
    {
        private string _modelName;
        public ModelBasic(string modelNameSpace)
        {
            _modelName = modelNameSpace;
        }

        public string getModelNameSpace()
        {
            return _modelName;
        }
    }
}
