function _GenURL(path as String, params as Object) as Object:
    baseUrl = "https://www.giantbomb.com/api"

    authRegistry = CreateObject("roRegistrySection", "Authentication")
    apiKey = ""
    if authRegistry.Exists("apiToken") then
        apiKey = authRegistry.Read("apiToken")
    end if

    urlStr = baseUrl + path + "/?format=json"

    for each param in params
        urlStr = urlStr + "&" + param[0] + "=" + param[1]
    end for
    if apiKey <> ""
        urlStr = urlStr + "&api_key=" + apiKey
    end if

    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)

    return url
end function

'
' path: API path to resource (example: "/videos")
' params: list of query params given as key/val (example: ["resource_type", "video"])
'
' Returns: Object with keys json and res (json is parsed JSON body, res is the raw response object)
'
function GETGBResource(path as String, params = [] as Object) as Object:
    url = _GenURL(path, params)
    rawReponse = url.GetToString()
    json = ParseJSON(rawReponse)

    return {
        json: json,
        res: rawReponse
    }
end function

'
' path: API path to resource (example: "/videos")
' params: list of query params given as key/val (example: ["resource_type", "video"])
'
' Returns: Object with keys url and port (url is the URL object, port is the message port to wait on for response)
'
function GETGBResourceAsync(path as String, params = [] as Object) as Object:
    url = _GenURL(path, params)

    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)
    success = url.AsyncGetToString()

    if success = false
        return invalid
    end if

    return {
        url: url
        port: port
    }
end function

'
' Given an object with url/port (from GETGBResourceasync)
' wait for and return response
'
function GBWaitFor(request as Object):
    url = request.url
    port = request.port

    '
    ' Adapted from:
    '
    ' https://blog.roku.com/developer/2012/08/17/communicating-with-web-services-from-brightscript
    '
    while (true)
        msg = wait(0, port)
        if (type(msg) = "roUrlEvent")
            code = msg.GetResponseCode()
            playlist = CreateObject("roArray", 10, true)
            rawReponse = msg.GetString()
            json = ParseJSON(rawReponse)
            return {
                json: json,
                rawReponse: rawReponse
            }
        else if (event = invalid)
            url.AsyncCancel()
            return invalid
        endif
    end while
end function

'
' Return the best available video quality
'
' TODO: Also could we make it 'adaptive'?
'
function GBBestVideo(item as Object) as String
    if item.hd_url <> invalid
        return item.hd_url
    end if

    if item.high_url <> invalid
        return item.high_url
    end if

    if item.low_url <> invalid
        return item.low_url
    end if

    return ""
end function

'
' Return ContentNode for video object
'
function GBVideoToContent(video as Object) as Object
    item = CreateObject("roSGNode", "ContentNode")
    item.SetFields({
        title: video.title
        Description: video.deck
        sdposterurl: video.image.screen_url
        hdposterurl: video.image.screen_large_url,
        guid: video.guid
    })
    return item
end function

'
' Return list of ContentNodes for list of videos
'
function GBVideosToContent(videos as Object) as Object
    items = []

    for each video in videos
        items.Push(GBVideoToContent(video))
    end for

    return items
end function
