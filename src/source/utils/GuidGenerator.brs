' Credit: TheEndless, https://forums.roku.com/viewtopic.php?t=51587

function GuidGenerator() as Object
  if (m._guidGeneratorSingleton = Invalid)

    prototype = {}

    '////////////////////////////
    '/// PUBLIC API ///
    '////////////////////////////

    prototype.generate = function() As String
      Return "{" + m._getRandomHexString(8) + "-" + m._getRandomHexString(4) + "-" + m._getRandomHexString(4) + "-" + m._getRandomHexString(4) + "-" + m._getRandomHexString(12) + "}"
    end function

    '////////////////////////////
    '/// PRIVATE API ///
    '////////////////////////////

    prototype._getRandomHexString = function(length As Integer) As String
      hexChars = "0123456789ABCDEF"
      hexString = ""
      for i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
        next
        return hexString
      end function

      m._guidGeneratorSingleton = prototype
    end if
    return m._guidGeneratorSingleton
  end function
