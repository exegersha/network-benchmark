sub Main()
  showChannelSGScreen()
end sub

sub showChannelSGScreen()
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("MainScene")
  AppContext().init(screen, m.port)
  AppContext().setScene(scene)
  
  screen.show()

  screenMediator = GetMainViewMediator()
  screenMediator.setMainContainer(scene.findNode("scrollText"))

  GetTransactionPool().init()
  NetworkBenchmarkCommand().execute()

  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)
    if msgType = "roSGNodeEvent"
      if (msg.GetField() = "closeApp")
        screen.close()
      else
        event = msg.getNode()+ "_" + msg.getField() + "_Event"
        'print "MessagePort roSGNodeEvent node:"; msg.getNode(); " updated:"; msg.getField()
        'print "MessagePort roSGNodeEvent event:"; event
        MessageBus().dispatchEvent(event, {data: msg.getData(), id: msg.getNode()})
      end if
    end if
    if msgType = "roSGScreenEvent"
        if msg.isScreenClosed() then return
    end if
  end while
end sub
