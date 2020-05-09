sub GetContent()
    videoShow = m.top.videoShow
    page = m.top.page
    order = m.top.order

    offset = (page - 1) * 100
    show_id = videoShow.guid.Split("-")[1]

    queryParams = [
        ["sort", "publish_date:" + order],
        ["offset", offset.ToStr()]
    ]

    if show_id <> invalid
        queryParams.Push(["filter", "video_show:" + show_id])
    end if

    json = GETGBResource("/videos", queryParams).json

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
            url: GBBestVideo(item)
        })
    end for

    if page > 1
        seasonAA.children.Push({
            id: "prev-page",
            title: "Previous page"
        })
    end if

    if (offset + json.number_of_page_results) < json.number_of_total_results
        seasonAA.children.Push({
            id: "next-page",
            title: "Next page"
        })
    end if

    if order = "asc"
        orderTitle = "Newest first"
    else if order = "desc"
        orderTitle = "Oldest first"
    end if

    seasonAA.children.Push({
        id: "toggle-order",
        title: orderTitle
    })

    seasonAA.Append({
        title: videoShow.title
        contentType: "section"
    })

    rootChildren = {
        children: [seasonAA]
    }
    m.top.content.Update(rootChildren)
end sub
