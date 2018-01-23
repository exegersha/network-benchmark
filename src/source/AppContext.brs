function AppContext() as Object

  if m.appContext = Invalid
    m.appContext = {

      screen:Invalid
      scene:Invalid

      messagePort:Invalid

      init: function (_sceneReference as Object, _port as Object) as Void
        m.screen = _sceneReference
        m.messagePort = _port
      end function

      setScene: function(scene as Object) as Void
        m.scene = scene
      end function
    }
  end if

  return m.appContext
end function