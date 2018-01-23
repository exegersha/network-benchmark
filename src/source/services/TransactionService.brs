'//////////////////
'/// Abstract Service that all network-based services must inherit from.
'//////////////////

function TransactionService() as Object
  prototype = EventDispatcher()

  ' dependencies
  prototype._transactionPool = GetTransactionPool()
  prototype._guidGenerator   = GuidGenerator()
  prototype._debugLoggingFilter = Debug().FILTER_NONE

  ' '////////////////////////////
  ' '/// PUBLIC API ///
  ' '////////////////////////////

  prototype.LOAD_SUCCESS      = "Service.LOAD_SUCCESS"
  prototype.LOAD_NETWORK_FAIL = "Service.LOAD_NETWORK_FAIL"
  prototype.LOAD_SERVICE_FAIL = "Service.LOAD_SERVICE_FAIL"

  'Attempt to load a specific location
  '@param options the request options
  prototype.load = function (options as Object, debugLoggingFilter=Debug().FILTER_NONE as String) as Void
    m._debugLoggingFilter = debugLoggingFilter
    m._load(options)
  end function

  ' ToDo: test this
  prototype.clearRequestFromActiveQueue = function(id as String) as Void
    m._activeRequests.Delete(id)
  end function

  prototype.hasActiveRequests = function () as Boolean
    return (m._activeRequests.count() > 0)
  end function

  ' '////////////////////////////////////////////////
  ' '/// PRIVATE PROPERTIES ///
  ' '////////////////////////////////////////////////

  prototype._activeRequests = {}

  prototype._CONTENT_TYPE        = "Content-Type"
  prototype._ACCEPT_HEADER       = "Accept"
  prototype._APP_JSON_MIME_TYPE  = "application/json"
  prototype._AUTHORIZATION_KEY   = "Authorization"

  ' '//////////////////////////////////////////
  ' '/// PRIVATE METHODS ///
  ' '//////////////////////////////////////////

  prototype._getGetHttpRequest = function () as Object
    return GetHttpRequest()
  end function

  prototype._load = function (options as Object) as String
    request = m._createRequest(options)
    m._transactionPool.queue(request)
    return request.id
  end function

  prototype._createRequest = function (options as Object) as Object
    request = m._getGetHttpRequest()

    if options.location <> Invalid
      request.setRequestUrl(options.location)
    end if

    if options.method <> Invalid
      request.setRequestMethod(options.method)
    end if

    if options.headers <> Invalid
      request.setRequestHeaders(options.headers)
    end if

    if options.body <> Invalid
      if (type(options.body) <> "String" OR type(options.body) <> "roString")
        options.body = FormatJson(options.body)
      end if
      request.setRequestBody(options.body)
    end if

    request.setTransactionCompleteHandler({
      callback: m._transactionComplete,
      context: m,
    })

    request.id = m._guidGenerator.generate()
    ' ToDo: Test this
    m._activeRequests.addReplace(request.id, request)

    return request
  end function

  prototype._getRequest = function (id) as Dynamic
    return m._activeRequests.Lookup(id)
  end function

  ' ToDo: test this
  prototype._handleTransactionSuccess = function (request as Object) as Void
    Debug().printF(["[Transaction] succeeded for ", request.getRequestUrl()], m._debugLoggingFilter)
    m.dispatchEvent(m.LOAD_SUCCESS, request)
  end function

  prototype._handleTransactionFailure = function (request as Object) as Void
    Debug().printF(["[Transaction] failed for ", request.getRequestUrl()], m._debugLoggingFilter)
    if (m._isResponseCodeNetworkError(request.getResponse().code))
      request.isNetworkError = true
    end if
    m.dispatchEvent(m.LOAD_SERVICE_FAIL, request)
  end function

  ' ToDo: test this
  prototype._transactionComplete = function (context as Object, requestId as String) as Void
    'print "<TransactionService>._transactionComplete context=";context ;" requestId=";requestId
    HTTP_CODE_RANGE = {
      SUCCESS_FROM: 0,
      ERROR_FROM: 400,
    }
    m = context
    request = m._getRequest(requestId)
    m.clearRequestFromActiveQueue(requestId)
    response = request.getResponse()
    if (response <> Invalid)
      parsedResponse = parseJSON(response)
      request.setResponse(parsedResponse)
      if (parsedResponse.code > HTTP_CODE_RANGE.SUCCESS_FROM AND parsedResponse.code < HTTP_CODE_RANGE.ERROR_FROM)
        m._handleTransactionSuccess(request)
      else
        m._handleTransactionFailure(request)
      end if
    else
      response = { code: HTTP_CODE_RANGE.SUCCESS_FROM }
      request.setResponse(response)
      m._handleTransactionFailure(request)
    end if
  end function

  ' ToDo: test this
  prototype._isResponseCodeNetworkError = function (responseCode as Integer) as Boolean
    result = false

    if (responseCode = 0)   then result = true  ' NOTE: error generated by app code
    if (responseCode = -5)  then result = true  ' NOTE: CURLE_COULDNT_RESOLVE_PROXY
    if (responseCode = -6)  then result = true  ' NOTE: CURLE_COULDNT_RESOLVE_HOST
    if (responseCode = -7)  then result = true  ' NOTE: CURLE_COULDNT_CONNECT
    if (responseCode = -28) then result = true  ' NOTE: CURLE_OPERATION_TIMEDOUT
    if (responseCode = -52) then result = true  ' NOTE: CURLE_GOT_NOTHING

    return result
  end function

  return prototype
end function