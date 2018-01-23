function GetDateUtils() as Object
  if (m._dateUtilsSingleton = Invalid)
    prototype = {}
  
    prototype.getTimeStamp = function() as Integer
      date = CreateObject("roDateTime")
      date.Mark()
      return date.AsSeconds()
    end function

    m._dateUtilsSingleton = prototype
  end if
  
  return m._dateUtilsSingleton
end function

function DestroyDateUtils() as Void
  m._dateUtilsSingleton = Invalid
end function