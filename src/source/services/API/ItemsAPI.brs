function ItemsAPI()

  if (m._ItemsAPI = Invalid)

    prototype = TransactionService()

    prototype.getItemChildrenList = function(pid, ppage="", ppage_size="", pmax_rating="", plist_order="", pdevice="", psubscription="", psegments="", pfeature_flags="")
      req = {
        "id": pid,
        "page": ppage,
        "page_size": ppage_size,
        "max_rating": pmax_rating,
        "list_order": plist_order,
        "device": pdevice,
        "subscription": psubscription,
        "segments": psegments,
        "feature_flags": pfeature_flags
      }

      return {
        method: "GET",
        params: req,
        uri: "/items/"+pid+"/children"
      }
    end function

    prototype.getItemRelatedList = function(pid, ppage="", ppage_size="", pmax_rating="", pdevice="", psubscription="", psegments="", pfeature_flags="")
      req = {
        "id": pid,
        "page": ppage,
        "page_size": ppage_size,
        "max_rating": pmax_rating,
        "device": pdevice,
        "subscription": psubscription,
        "segments": psegments,
        "feature_flags": pfeature_flags
      }

      return {
        method: "GET",
        params: req,
        uri: "/items/"+pid+"/related"
      }
    end function

    prototype.getItem = function(pid, pmax_rating="", pexpand="", pselect_season="", puse_custom_id="", pdevice="", psubscription="", psegments="", pfeature_flags="")
      req = {
        "id": pid,
        "max_rating": pmax_rating,
        "expand": pexpand,
        "select_season": pselect_season,
        "use_custom_id": puse_custom_id,
        "device": pdevice,
        "subscription": psubscription,
        "segments": psegments,
        "feature_flags": pfeature_flags
      }

      return {
        method: "GET",
        params: req,
        uri: "/items/"+pid+""
      }
    end function

    prototype.getPublicItemMediaFiles = function(pid, pdevice, pmedia_file_delivery="", pmedia_file_resolution="", pdevice_id="", psubscription="", psegments="", pfeature_flags="")
      req = {
        "id": pid,
        "device": pdevice,
        "media_file_delivery": pmedia_file_delivery,
        "media_file_resolution": pmedia_file_resolution,
        "device_id": pdevice_id,
        "subscription": psubscription,
        "segments": psegments,
        "feature_flags": pfeature_flags
      }

      return {
        method: "GET",
        params: req,
        uri: "/items/"+pid+"/videos"
      }
    end function

    m._ItemsAPI = prototype
  end if

  return m._ItemsAPI
end function
