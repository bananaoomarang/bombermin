' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    authRegistry = CreateObject("roRegistrySection", "Authentication")
    apiKey = ""
    if authRegistry.Exists("apiToken") then
        apiKey = authRegistry.Read("apiToken")
    end if

    urlStr = "https://www.giantbomb.com/api/video_shows/?format=json"
    if apiKey <> ""
        urlStr = urlStr + "&api_key=" + apiKey
    end if 

    ' create a roUrlTransfer object
    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)

    ' make an API call
    rawReponse = url.GetToString()
    json = ParseJSON(rawReponse)
    rootNodeArray = ParseJsonToNodeArray(json)
    m.top.content.Update(rootNodeArray)
end sub

function ParseJsonToNodeArray(json as Object) as Object
    if json = invalid then return []

    shows = []
    for each item in json.results
        contentItem = CreateObject("roSGNode", "ContentNode")
        contentItem.SetFields({
            title: item.title
            Description: item.deck
            sdposterurl: item.image.screen_url
            hdposterurl: item.image.screen_large_url,
            guid: item.guid
        })
        shows.Push(contentItem)
    end for
    rows = []
    letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".Split(",")

    for each letter in letters
        row = {
            title: letter
            children: []
        }

        for each show in shows
            if LCase(show.title.Left(1)) = LCase(letter)
                row.children.Push(show)
            end if
        end for

        if row.children.Count() > 0:
            rows.Push(row)
        end if
    end for

    return {
        children: rows
    }
end function
