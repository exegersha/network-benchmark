function GetMainViewMediator () as Object
  if (m._viewMediatorSingleton = Invalid)
    prototype = EventDispatcher()

    '////////////////////////////
    '/// PUBLIC API ///
    '////////////////////////////

    prototype.setMainContainer = function (mainContainer as Object) as Void
      if (m._mainContainer = Invalid)
        m._mainContainer = mainContainer
      end if
      m._mainContainer.ObserveField("back", "_rootBackHandler")
    end function

    prototype.getMainContainer= function () as Object
      return m._mainContainer
    end function

    prototype.addText = function(text as String) as Void
        m._maincontainer.text = m._maincontainer.text + chr(10) + text
    end function

'    prototype.exitApp = function () as void
'      m._maincontainer.getScene().setField("closeApp", true)
'    end function

    '////////////////////////////////////////////////
    '/// PRIVATE PROPERTIES ///
    '////////////////////////////////////////////////

    'prototype._mainContainer = Invalid
    'print "<GetMainViewMediator> INIT _mainContainer=Invalid"

    '///////////////////////////////////////////
    '/// PRIVATE METHODS ///
    '///////////////////////////////////////////

    prototype._destroyViews = function () as Object
      m._mainContainer = Invalid
    end function

    m._viewMediatorSingleton = prototype
  end if
  return m._viewMediatorSingleton
end function

function DestroyMainViewMediator () as Void
  m._viewMediatorSingleton = Invalid
end function

function _rootBackHandler () as Void
  'm._viewMediatorSingleton.dispatchEvent(GetEventType().BACK_REQUESTED)
end function
