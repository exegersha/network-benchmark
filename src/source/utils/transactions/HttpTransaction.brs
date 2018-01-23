function HttpTransaction (request as Object) as Object
  prototype = {}

  '////////////////////////////
  '/// PUBLIC API ///
  '////////////////////////////

  'Designated type
  prototype.type = "HttpTransaction"

  'Start the http-based transaction (synchronuous)
  prototype.start = function () as Void
    m._startTransaction()
  end function

  'The response for the completed transaction.
  prototype.getResponse = function () as String
    return m._response
  end function

  '////////////////////////////////////////////////
  '/// PRIVATE PROPERTIES ///
  '////////////////////////////////////////////////

  prototype._request            = request
  prototype._response           = Invalid
  prototype._urlTransfer        = Invalid
  prototype._messagePort        = Invalid

  prototype.REQUEST_TIMEOUT     = 10000
  prototype.TRANSFER_STARTED    = 2
  prototype.TRANSFER_COMPLETED  = 1
  prototype.UNKNOWN_ERROR       = 0

  '///////////////////////////////////////////
  '/// PRIVATE METHODS ///
  '///////////////////////////////////////////

  prototype._getUrlTransfer = function () as Object
    if (m._urlTransfer = Invalid) then m._urlTransfer = CreateObject("roUrlTransfer")
    return m._urlTransfer
  end function

  prototype._getMessagePort = function () as Object
    if (m._messagePort = Invalid) then m._messagePort = CreateObject("roMessagePort")
    return m._messagePort
  end function

  prototype._startTransaction = function () as Object
    urlTransfer = m._getUrlTransfer()
    urlTransfer.setUrl(m._request.location)
    urlTransfer.setRequest(m._request.method)

    if m._request.headers <> Invalid
      headers = m._request.headers
      for each header in headers
        urlTransfer.addHeader(header, headers[header])
      end for
    end if

    port = m._getMessagePort()
    urlTransfer.setMessagePort(port)
    urlTransfer.retainBodyOnError(true)
    urlTransfer.EnableEncodings(true)

    if (m._request.method = "GET")
      requestSuccess = urlTransfer.asyncGetToString()
    else
      requestSuccess = urlTransfer.asyncPostFromString(m._request.body)
    end if

    'print "<HttpTransaction>._startTransaction m._request=";m._request
    'print "<HttpTransaction>._startTransaction requestSuccess=";requestSuccess

    response = Invalid

    if (requestSuccess)
      response = port.waitMessage(m.REQUEST_TIMEOUT)
      if (response <> Invalid AND response.getInt() = m.TRANSFER_STARTED)
        response = port.waitMessage(m.REQUEST_TIMEOUT)
      end if
    end if

    response_obj = {}

    if (response <> Invalid)
      response_obj.data = response.getString()
      response_obj.code = response.getResponseCode()
      response_obj.headers = response.getResponseHeaders()
    else
      response_obj.code = m.UNKNOWN_ERROR
    end if

    'print "<HttpTransaction>._startTransaction response_obj=";response_obj

    response_obj_as_json_str = FormatJson(response_obj)
    m._response = response_obj_as_json_str
  end function

  return prototype
end function
