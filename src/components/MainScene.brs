'//////////////////
'/// bootstrapped commands in the Main scope
'//////////////////

sub init()
  m.top.backgroundURI = "pkg:/images/purplebg.jpg"

  deviceInfo = CreateObject("roDeviceInfo")
  scrollText = m.top.findNode("scrollText")
  scrollText.width = deviceInfo.GetUIResolution().width - 80
  scrollText.height = deviceInfo.GetUIResolution().height - 80
  scrollText.setFocus(true)

  screenMediator = GetMainViewMediator()
  screenMediator.setMainContainer(m.top.findNode("scrollText"))

  m.indexLabel = m.top.findNode("indexLabel")
  m.simpleTask = CreateObject("roSGNode", "SimpleTask")
  m.simpleTask.ObserveField("index", "onIndexChanged")
  m.simpleTask.control = "RUN"

  GetTransactionPool().init()
  NetworkBenchmarkCommand().execute()
end sub

function onIndexChanged() as void
    str = "Time running (in seconds): " + stri(m.simpleTask.index)
    m.indexLabel.text = str
end function
