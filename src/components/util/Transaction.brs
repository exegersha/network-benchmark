'Executed when the Transaction TaskNode is created
function init()
  m.top.functionName = "load"
end function

'Executed when the Task control status is set to "RUN"
function load()
  if (m.top <> Invalid)
    json_str = invalid

    'XXX: The following retry is required because on slow connections the request
    '       may not have been set in the field. The retry provides enough delay
    '       to resolve the issue
    count = 1
    while json_str = invalid and count < 6
      json_str = m.top.request
      count = count + 1
    end while

    json_obj = ParseJson(json_str)
    
    'print "<Transaction>.load() json_obj=";json_obj
    'print "<Transaction>.load() json_obj.headers=";json_obj.headers

    transaction = GetAbstractTransaction(json_obj)

    'print "<Transaction>.load() transaction=";transaction

    if (transaction <> Invalid)
      transaction.start()

      'print "<Transaction>.load() transaction.start() !!!! "
      'print "<Transaction>.load() transaction.getResponse()=";transaction.getResponse()

      m.top.response = transaction.getResponse()

      'print "<Transaction>.load() m.top.response = transaction.getResponse() !!!!"
    else
      response_obj = {code:0}
      response_obj_as_json_str = FormatJson(response_obj)
      m.top.response = response_obj_as_json_str
    end if
  end if
end function
