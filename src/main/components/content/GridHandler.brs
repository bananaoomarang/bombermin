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

function ParseMediaItemToNode(mediaItem as Object, mediaType as String) as Object
    itemNode = Utils_AAToContentNode({
            "id": mediaItem.id
            "title": mediaItem.title
            "hdPosterUrl": mediaItem.thumbnail
            "Description": mediaItem.shortDescription
            "Categories": mediaItem.genres[0]
        })

    if mediaItem = invalid then
        return itemNode
    end if

    ' Assign movie specific fields
    if mediaType = "movies"
        Utils_forceSetFields(itemNode, {
            "Url": GetVideoUrl(mediaItem)
        })
    end if
    ' Assign series specific fields
    if mediaType = "series"
        seasons = mediaItem.seasons
        seasonArray = []
        for each season in seasons
            episodeArray = []
            episodes = season.Lookup("episodes")
            for each episode in episodes
                episodeNode = Utils_AAToContentNode(episode)
                Utils_forceSetFields(episodeNode, {
                    "url": GetVideoUrl(episode)
                    "title": episode.title
                    "hdPosterUrl": episode.thumbnail
                    "Description": episode.shortDescription
                })
                episodeArray.Push(episodeNode)
            end for
            seasonArray.Push(episodeArray)
        end for
        Utils_forceSetFields(itemNode, {
            "seasons": seasonArray
        })
    end if
    return itemNode
end function

function GetVideoUrl(mediaItem as Object) as String
    content = mediaItem.Lookup("content")
    if content = invalid then
        return ""
    end if

    videos = content.Lookup("videos")
    if videos = invalid then
        return ""
    end if

    entry = videos.GetEntry(0)
    if entry = invalid then
        return ""
    end if

    url = entry.Lookup("url")
    if url = invalid then
        return ""
    end if

    return url
end function
