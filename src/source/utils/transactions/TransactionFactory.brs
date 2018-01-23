function GetAbstractTransaction (request as Object) as Object
  location = request.location
  protocol = location.tokenize(":")[0]

  if (protocol = "http")
    return HttpTransaction(request)
  else if (protocol = "https")
    return HttpsTransaction(request)
  else if (protocol = "pkg")
    return GetPkgTransaction(location)
  else if (protocol = "registry")
    return GetRegistryTransaction(location)
  else
    return Invalid
  end if

end function
