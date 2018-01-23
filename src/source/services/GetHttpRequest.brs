'//////////////////
'/// service.AbstractService
'/// HTTP request wrapper
'//////////////////
function GetHttpRequest () as Object
  prototype = {}

  prototype._method = "GET"
  prototype._location = Invalid
  prototype._body = Invalid
  prototype._headers = Invalid
  prototype._transactionCompleteHandler = Invalid
  prototype._response = Invalid

  prototype.getRequestMethod = function () as String
    return m._method
  end function

  prototype.setRequestMethod = function (value as String) as Void
    m._method = value
  end function

  prototype.getRequestUrl = function () as String
    return m._location
  end function

  prototype.setRequestUrl = function (value as String) as Void
    m._location = value
  end function

  prototype.getRequestBody = function () as String
    return m._body
  end function

  prototype.setRequestBody = function (value as String) as Void
    m._body = value
  end function

  prototype.getRequestHeaders = function () as Object
    return m._headers
  end function

  prototype.setRequestHeaders = function (value as Object) as Void
    m._headers = value
  end function

  prototype.getTransactionCompleteHandler = function () as Object
    return m._transactionCompleteHandler
  end function

  prototype.setTransactionCompleteHandler = function (value as Object) as Void
    m._transactionCompleteHandler = value
  end function

  prototype.setResponse = function (value as Dynamic) as Void
    m._response = value
  end function

  prototype.getResponse = function () as Dynamic
    return m._response
  end function

  prototype.convertToJson = function () as String
    props = {}
    props.location = m._location
    props.method = m._method

    if m._body <> Invalid
      props.body = m._body
    end if

    if m._headers <> Invalid
      props.headers = m._headers
    end if

    props_as_json_string = FormatJson(props)
    return props_as_json_string
  end function

  return prototype
end function
