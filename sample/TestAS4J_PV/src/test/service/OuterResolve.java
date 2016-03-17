package test.service;

import java.io.DataInputStream;
import java.io.DataOutputStream;

import com.airmyth.bean.IParamResolve;

public class OuterResolve implements IParamResolve {

	@Override
	public boolean encode(Object param, DataOutputStream dos) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public Object decode(byte type, DataInputStream dos) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setOutParamResolve(IParamResolve value) {
		// TODO Auto-generated method stub

	}

}
