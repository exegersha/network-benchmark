function HttpsTransaction (request as Object) as Object
  prototype = HttpTransaction(request)

  '////////////////////////////
  '/// PUBLIC API ///
  '////////////////////////////

  'Designated type
  prototype.type = "HttpsTransaction"

  'Start the http-based transaction (synchronuous)
  prototype.start = function () as Void
    m._getUrlTransfer().SetCertificatesFile("common:/certs/ca-bundle.crt")
    m._getUrlTransfer().InitClientCertificates()
    m._startTransaction()
  end function

  return prototype
end function
