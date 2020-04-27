sub GetContent()
    videoShow = m.top.videoShow

    authRegistry = CreateObject("roRegistrySection", "Authentication")
    apiKey = ""
    if authRegistry.Exists("apiToken") then
        apiKey = authRegistry.Read("apiToken")
    end if

    urlStr = "https://www.giantbomb.com/api/videos/?format=json"
    urlStr = urlStr + "&sort=publish_date:asc"
    if apiKey <> ""
        urlStr = urlStr + "&api_key=" + apiKey
    end if

    show_id = videoShow.guid.Split("-")[1]
    urlStr = urlStr + "&filter=video_show:" + show_id

    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)
    rawReponse = url.GetToString()
    json = ParseJSON(rawReponse)

    seasonAA = {
        children: []
    }

    for each item in json.results:
        seasonAA.children.Push({
            title: item.name
            Description: item.deck
            sdposterurl: item.image.screen_url
            hdposterurl: item.image.screen_large_url
            url: item.high_url
        })
    end for

    seasonAA.Append({
        title: videoShow.title
        contentType: "section"
    })
    rootChildren = {
       children: [seasonAA]
    }
    m.top.content.Update(rootChildren)
end sub
