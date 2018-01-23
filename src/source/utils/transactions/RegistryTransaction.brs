function GetRegistryTransaction (location as String) as Object
  prototype = {}

  '////////////////////////////
  '/// PUBLIC API ///
  '////////////////////////////

  prototype.location = location

  'Designated type
  prototype.type = "RegistryTransaction"

  prototype.start = function () as Void
    startIndex = m.location.Instr("//")
    urlWithoutProtocol = m.location.Mid(startIndex)
    responseObj = { code: 0 }
    if (NOT urlWithoutProtocol.Instr("//") > 0)
      structure = m.location.tokenize("/")
      method = structure[1]
      section = structure[2]
      key = structure[3]

      if (method = "read")
        if key <> invalid
          responseObj = m._read(section, key)
        else
          responseObj = m._read(section)
        end if
      else if (method = "write")
        value = structure[4]
        responseObj = m._write(section, key, value)
      else if (method = "delete")
        responseObj = m._delete(section, key)
      end if
    end if
    responseObjAsJson = FormatJson(responseObj)
    m._response = responseObjAsJson
  end function

  'The response-code assigned to the completed transaction. This integer is either
  '0 for a fail or 1 for success.
  prototype.getResponse = function () as Object
    return m._response
  end function

  '////////////////////////////////////////////////
  '/// PRIVATE PROPERTIES ///
  '////////////////////////////////////////////////

  prototype._location = location
  prototype._response = Invalid

  '///////////////////////////////////////////
  '/// PRIVATE METHODS ///
  '///////////////////////////////////////////

  ' Returns an entire section or single value from the registry
  prototype._read = function (section as String, key = "" as String) as Object
    response = { code: 0 }
    if (section <> "")
      sec = m._getRegistrySection(section)
      if key <> ""
        if sec.Exists(key)
          response.data = sec.Read(key)
        end if
      else
        responseData = {}
        hasKeyList = false
        for each sectionKey in sec.GetKeyList()
          hasKeyList = true
          responseData[sectionKey] = sec.Read(sectionKey)
        end for
        if (hasKeyList) then  response.data = FormatJson(responseData)
      end if
      response.code = 200
    end if
    return response
  end function

  prototype._write = function (section as String, key as String, value as String) as Object
    response = { code: 0 }
    hasValidParameters = (key <> "") AND (value <> "") AND (section <> "")
    if (hasValidParameters)
      sec = m._getRegistrySection(section)
      if (sec.Write(key, value) = true AND sec.Flush() = true)
        response.code = 200
      end if
    end if
    return response
  end function

  prototype._delete = function (section as String, key as String) as Object
    response = { code: 0 }
    hasValidParameters = (key <> "") AND (section <> "")
    if (hasValidParameters)
      sec = m._getRegistrySection(section)
      if (sec.Delete(key) = true AND sec.Flush() = true)
        response.code = 200
      end if
    end if
    return response
  end function

  prototype._getRegistrySection = function (section as String) as Object
    return CreateObject("roRegistrySection", section)
  end function

  return prototype
end function
