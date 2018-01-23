'//////////////////
'/// Debug utility
'//////////////////
function Debug () as Object
  if (m._debugSingleton = Invalid)

    prototype = {}


    '////////////////////////////
    '/// PUBLIC API ///
    '////////////////////////////

    prototype.FILTER_NONE = "NONE"
    prototype.FILTER_NETWORK = "NETWORK"
    prototype.FILTER_VIDEO = "VIDEO"
    prototype.FILTER_NETWORK_VERBOSE = "NETWORK_VERBOSE"
    prototype.FILTER_ALL = "ALL"

    prototype.initialise = function (debugLoggingFilter=m.FILTER_NETWORK as String) as Void
      m._debugLoggingFilter = debugLoggingFilter
    end function

    prototype.getFilterLevel = function () as String
      return m._debugLoggingFilter
    end function

    prototype.printF = function (content="" as Dynamic, filterLevel=m.FILTER_NETWORK as String) as Void
      message = ""
      if (m._debugLoggingFilter <> m.NONE AND m._canPrintThisFilter(filterLevel))
        contentType = Type(content)
        if (contentType = "String")
          message = content
        else if (contentType = "roArray")
          for each item in content
            itemType = Type(item)
            if (itemType = "roString" OR itemType = "String")
              message = message + item
            else if (itemType="roInteger" OR itemType="roInt")
              message = message + item.toStr()
            else if (itemType="roFloat")
              message = message + Str(item)
            else if (itemType="roBoolean")
              if (item)
                message = message + "True"
              else
                message = message + "False"
              end if
            else
              message = message + itemType
            end if
          end for
        else
          message = contentType
        end if
        m._print(message)
      end if
    end function


    '////////////////////////////////////////////////
    '/// PRIVATE PROPERTIES ///
    '////////////////////////////////////////////////

    prototype._debugLoggingFilter = prototype.FILTER_NETWORK
    prototype._dateTime = CreateObject("roDateTime")


    '//////////////////////////////////////////
    '/// PRIVATE METHODS ///
    '//////////////////////////////////////////

    prototype._canPrintThisFilter = function (filterLevel as String) as Boolean
      canPrintFilter = false
      if (m._debugLoggingFilter = m.FILTER_ALL)
        canPrintFilter = true
      else if (m._debugLoggingFilter = m.FILTER_VIDEO AND filterLevel = m.FILTER_VIDEO)
        canPrintFilter = true
      else if (m._debugLoggingFilter = m.FILTER_NETWORK AND filterLevel = m.FILTER_NETWORK)
        canPrintFilter = true
      else if (m._debugLoggingFilter = m.FILTER_NETWORK_VERBOSE AND (filterLevel = m.FILTER_NETWORK OR filterLevel = m.FILTER_NETWORK_VERBOSE))
        canPrintFilter = true
      else if (m._debugLoggingFilter = m.FILTER_ALL AND (filterLevel = m.FILTER_NETWORK OR filterLevel = m.FILTER_NETWORK_VERBOSE OR filterLevel = n.FILTER_ALL))
        canPrintFilter = true
      end if
      return canPrintFilter
    end function

    prototype._print = function (message as String) as Void
      m._dateTime.Mark()
      print m._dateTime.ToISOString();" ";message
    end function


    m._debugSingleton = prototype
  end if

  return m._debugSingleton
end function


function DestroyDebug () as Void
  m._debugSingleton = Invalid
end function
