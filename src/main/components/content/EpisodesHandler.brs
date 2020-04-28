sub GetContent()
    videoShow = m.top.videoShow
    show_id = videoShow.guid.Split("-")[1]
    json = GETGBResource("/videos", [
        ["sort", "publish_date:asc"],
        ["offset", "0"],
        ["filter", "video_show:" + show_id]
    ]).json

    seasonAA = {
        children: []
    }

    for each item in json.results:
        seasonAA.children.Push({
            id: item.id
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
