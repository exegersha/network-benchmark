function GetTransactionPool() as Object
  if (m._transactionPoolSingleton = Invalid)

    prototype = {}

    prototype._MAXIMUM_TRANSACTIONS = 8
    prototype._requestQueue = []

    prototype._activeRequestQueue = {}
    prototype._transactionPool = []
    prototype._activeTransactionPool = {}

    '////////////////////////////
    '/// PUBLIC API ///
    '////////////////////////////

    prototype.init = function () as Void
      for i = m._MAXIMUM_TRANSACTIONS to 1 step -1
        m._transactionPool.push(m._createTransaction())
      end for
    end function

    prototype.queue = function(request as Object) as Void
      m._requestQueue.push(request)
      m._processQueue()
    end function

    prototype.getRequest = function(transactionId) as Object
      return m._activeRequestQueue.Lookup(transactionId)
    end function

    prototype.recycle = function(transaction) as Void
      m._recycle(transaction)
    end function

    '////////////////////////////
    '/// PRIVATE API ///
    '////////////////////////////

    prototype._createTransaction = function () as Object
      return createObject("roSGNode", "Transaction")
    end function

    prototype._processQueue = function ()
      if (m._requestQueue.count() = 0)
        return invalid
      end if

      transaction = m._getTransaction()

      if (transaction = Invalid)
        return invalid
      end if

      request = m._requestQueue.shift()

      transaction.id = request.id

      m._activeRequestQueue.addReplace(request.id, request)
      m._activeTransactionPool.addReplace(transaction.id, transaction)

      m._configureTransaction(transaction, request)
    end function

    prototype._getTransaction = function () as Object
      return m._transactionPool.shift()
    end function

    prototype._configureTransaction = function (transaction as Object, request as Object) as Void
      transaction.observeField("response", "TransactionPool_transactionComplete")
      transaction.request = request.convertToJson()
      transaction.control = "RUN"
      transaction.observeField("state", "TransactionPool_stateChanged")
    end function

    prototype._recycle = function (transaction as Object) as Void
      transactionId = transaction.id
      m._activeRequestQueue.Delete(transactionId)
      transaction.unobserveField("response")
      transaction.unobserveField("state")
      transaction.control = "INIT"
      transaction.request = ""
      transaction.response = ""
      transaction.id = ""

      m._transactionPool.push(transaction)
      m._activeTransactionPool.Delete(transactionId)
      m._processQueue()
    end function

    m._transactionPoolSingleton = prototype
  end if
  return m._transactionPoolSingleton
end function

function TransactionPool_transactionComplete (sgNodeEvt as Object) as Void
  transactionId = sgNodeEvt.getNode()
  request =  GetTransactionPool().getRequest(transactionId)
  request.setResponse(sgNodeEvt.getData())
  completeHandler = request.getTransactionCompleteHandler()
  completeHandler.callback(completeHandler.context, transactionId)
end function

function TransactionPool_stateChanged(event) as Void
  if event.getData() = "stop"
    transaction = event.getRoSGNode()
    GetTransactionPool().recycle(transaction)
  end if
end function

function TransactionPool_destroy() as Void
  if (m._transactionPoolSingleton <> Invalid)
    m._transactionPoolSingleton = Invalid
  end if
end function
