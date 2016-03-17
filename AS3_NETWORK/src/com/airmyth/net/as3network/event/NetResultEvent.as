package com.airmyth.net.as3network.event
{
  import com.airmyth.net.as3network.model.DataVo;
  import com.airmyth.net.as3network.model.Session;
  import com.airmyth.net.as3network.net.IInvoker;
  
  import flash.events.Event;
  import flash.utils.getTimer;
  
  public class NetResultEvent extends Event
  {
    public static const RESULT:String = "result";
    
    private var _result:DataVo;
    
    private var _session:Session;
    
    public function NetResultEvent(sessionInfo:Session, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(RESULT, bubbles, cancelable);
      
      _session = sessionInfo;
	  _session.endTime = getTimer();
    }
    

    public function get session():Session
    {
      return _session;
    }

    public function get sessionID():String
    {
      return _session.data.ACUID;
    }

    public function get invoker():IInvoker
    {
      return _session.invoker;
    }

    public function get result():DataVo
    {
      return _session.data;
    }

    override public function clone():Event
    {
      return new NetResultEvent(_session);
    }
  }
}