function MessageBus () as Object

  if (m.messageBus = invalid)
    m.messageBus = EventDispatcher()
  end if
  return m.messageBus

end function