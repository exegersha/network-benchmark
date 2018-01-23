function NetworkBenchmarkCommand() 

  prototype = {}

  'Array structured as: <request.id>:<nn>,  <nn>=time in seconds to complete the request/response.
  prototype._requestBenchmark = {}

  prototype._totalRequests = 50
  prototype._requestsCompleted = 0

  prototype._dateUtils = GetDateUtils()
  prototype._mainViewMediator = GetMainViewMediator()

  prototype.execute = function() as Object
    'request Items in a loop
    m._itemsService = GetItemsService()
    m._itemsService.addEventListener(m._itemsService.LOAD_SUCCESS, "_loadItemSuccess", m)
    m._itemsService.addEventListener(m._itemsService.LOAD_NETWORK_FAIL, "_loadItemFail", m)
    m._itemsService.addEventListener(m._itemsService.LOAD_SERVICE_FAIL, "_loadItemFail", m)
    

    id = 868

    m._mainViewMediator.addText("TRIGGERING "+ (m._totalRequests + 1).toStr() +" REQUESTS...")

    m._initialTimestap = m._dateUtils.getTimeStamp()

    for i=id to id+m._totalRequests 
      timestamp = m._dateUtils.getTimeStamp()
      'print "<NetworkBenchmarkCommand> Start requesting i=";i ;" timestamp="; timestamp ;"..."

      requestId = m._itemsService.load(i.toStr())
      'print "<NetworkBenchmarkCommand> ... requested ID=";requestID

      m._requestBenchmark.addReplace(requestId, timestamp)
    end for      
  end function

  prototype._loadItemSuccess = function(payload as Object)
    'print "<NetworkBenchmarkCommand>._loadItemSuccess for request ID="; payload.id
  
    m._mainViewMediator.addText("Load Success for request ID="+ payload.id)
    m._logResults(payload)

    'print "<NetworkBenchmarkCommand>._loadItemSuccess called payload=";payload
    'print "<NetworkBenchmarkCommand>._loadItemSuccess called data=";parseJson(payload.getresponse().data)
    'm._appConfig = parseJson(payload.getresponse().data)
  end function

  prototype._loadItemFail = function(payload as Object)
    'print "<NetworkBenchmarkCommand>._loadItemFail FAILED request ID"; payload.id
    'print "<NetworkBenchmarkCommand>._loadItemFail called payload=";payload
    m._mainViewMediator.addText("Load Fail for request ID="+ payload.id)
    m._logResults(payload)
  end function

  prototype._removeListeners = function() as Void
    m._itemsService.removeEventListener(m._itemsService.LOAD_SUCCESS, "_loadItemSuccess", m)
    m._itemsService.removeEventListener(m._itemsService.LOAD_NETWORK_FAIL, "_loadItemFail", m)
    m._itemsService.removeEventListener(m._itemsService.LOAD_SERVICE_FAIL, "_loadItemFail", m)
  end function

  prototype._logResults = function(payload as Object) as Void
    responseTimeStamp = m._dateUtils.getTimeStamp()
    requestTimeStamp = m._requestBenchmark.lookup(payload.id)
    m._requestBenchmark.addReplace(payload.id, responseTimeStamp - requestTimeStamp)
    m._requestsCompleted = m._requestsCompleted + 1

    if (m._requestsCompleted > m._totalRequests)
      m._printOutResults()
      m._removeListeners()
    end if
  end function

  prototype._printOutResults = function() as Void
    'print "<NetworkBenchmarkCommand>._logResults "
    m._mainViewMediator.addText(chr(10) + "TIME TO COMPLETE EACH REQUEST (in seconds):")
    for each item in m._requestBenchmark.Items()
        'print "<NetworkBenchmarkCommand> "; item.key ;" : "; item.value
        m._mainViewMediator.addText(item.key +" : "+ item.value.toStr())
    end for
    'print "<NetworkBenchmarkCommand>._logResults overall network time: "; m._dateUtils.getTimeStamp() - m._initialTimestap
    m._mainViewMediator.addText(chr(10) + "OVERALL NETWORK TIME (in seconds): "+ (m._dateUtils.getTimeStamp() - m._initialTimestap).toStr())
  end function

  return prototype

end function
