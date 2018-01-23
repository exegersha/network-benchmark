function GetItemsService () as Object
  if (m._itemsServiceSingleton = Invalid)
    prototype = ItemsAPI()

    prototype.load = function(id as String) as String
      BASE_URL = "https://apollo-rocket.massivision.com"

      api = m.getItem(id)
      
      ENDPOINT = api.uri

      requestHeaders = {}
      requestHeaders[m._CONTENT_TYPE] = m._APP_JSON_MIME_TYPE
      requestHeaders[m._ACCEPT_HEADER] = m._APP_JSON_MIME_TYPE

    options = {
        location: BASE_URL + ENDPOINT,
        method: "GET",
        headers: requestHeaders,
      }

      'print "<GetItemsService>.load options=";options

      return m._load(options)
    end function

    prototype.destroy = function ()
    end function

    m._itemsServiceSingleton = prototype
  end if
  return m._itemsServiceSingleton
end function

function DestroyItemsService () as Void
  if (m._itemsServiceSingleton <> Invalid)
    m._itemsServiceSingleton.destroy()
    m._itemsServiceSingleton = Invalid
  end if
end function
