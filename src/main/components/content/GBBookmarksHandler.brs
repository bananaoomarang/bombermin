' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function SaveTime(content as Object, position as Integer) as Object
    authRegistry = CreateObject("roRegistrySection", "Authentication")
    apiKey = ""
    if authRegistry.Exists("apiToken") then
        apiKey = authRegistry.Read("apiToken")
    end if

    urlStr = "https://www.giantbomb.com/api/video/save-time/?format=json"
    if apiKey <> ""
        urlStr = urlStr + "&api_key=" + apiKey
    end if

    urlStr = urlStr + "&video_id=" + content.id
    urlStr = urlStr + "&time_to_save=" + position.ToStr()

    ' create a roUrlTransfer object
    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)
    rawReponse = url.GetToString()
    return ParseJSON(rawReponse)
end function

'BookmarksHandler interface functions'
sub SaveBookmark()
    content = m.top.content
    position = m.top.position
    SaveTime(content, position)
end sub

'
' Not sure if we have to stub this...
' this is actually handled in VideoDetailsHandler
' maybe would be better here?
'
' Revisit...
'
function GetBookmark() as Integer
    content = m.top.content
    return content.bookmarkPosition
end function

sub RemoveBookmark()
    content = m.top.content
    SaveTime(content, -1)
end sub
