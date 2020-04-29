sub GetContent()
    videoShow = m.top.videoShow
    page = m.top.page

    offset = (page - 1) * 100
    show_id = videoShow.guid.Split("-")[1]

    json = GETGBResource("/videos", [
        ["sort", "publish_date:asc"],
        ["offset", offset.ToStr()],
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

    if page > 1
        seasonAA.children.Push({
            id: "prev-page",
            title: "Previous page"
        })
    end if

    print json
    if (offset + json.number_of_page_results) < json.number_of_total_results
        seasonAA.children.Push({
            id: "next-page",
            title: "Next page"
        })
    end if

    seasonAA.Append({
        title: videoShow.title
        contentType: "section"
    })

    rootChildren = {
        children: [seasonAA]
    }
    m.top.content.Update(rootChildren)
end sub
