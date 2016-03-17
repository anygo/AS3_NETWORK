package com.airmyth.net.as3network.net.socket
{
  import com.airmyth.net.as3network.model.Server;
  
  import flash.events.EventDispatcher;
  
  public class SocketClient extends EventDispatcher 
  {
    public function SocketClient(serverValue:Server=null)
    {
      super();
    }
  }
}