function GetPkgTransaction (location as String) as Object
  prototype = {}

  '////////////////////////////
  '/// PUBLIC API ///
  '////////////////////////////

  'Designated type
  prototype.type = "PkgTransaction"

  'Start the pkg-based transaction (synchronuous)
  prototype.start = function () as Void
    asciiFileData = m._readAsciiFile()

    response_obj = {}

    if (asciiFileData <> "")
      response_obj.data = asciiFileData
      response_obj.code = 200
    else
      response_obj.code = 0
      response_obj.data = ""
    end if

    response_obj_as_json_str = FormatJson(response_obj)
    m._response = response_obj_as_json_str
  end function

  'The response-code assigned to the completed transaction. This integer is either
  '0 for a fail or 1 for success.
  prototype.getResponse = function () as String
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

  prototype._readAsciiFile = function () as String
    return ReadASCIIFile(m._location)
  end function

  return prototype
end function
