'
' path: API path to resource (example: "/videos")
' params: list of query params given as key/val (example: ["resource_type", "video"])
'
' Returns: Object with keys json and res (json is parsed JSON body, res is the raw response object)
'
function GETGBResource(path as String, params = [] as Object) as Object:
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
    rawReponse = url.GetToString()
    json = ParseJSON(rawReponse)

    return {
        json: json,
        res: rawReponse
    }
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
