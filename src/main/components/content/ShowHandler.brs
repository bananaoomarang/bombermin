' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    live_json = GETGBResource("/video/current-live").json
    recent_json = GETGBResource("/videos", [
        ["sort", "publish_date:desc"],
        ["limit", "20"]
    ]).json
    json = GETGBResource("/video_shows", [
        ["sort", "title:asc"]
    ]).json
    rootNodeArray = ParseJsonToNodeArray(json, live_json, recent_json)
    m.top.content.Update(rootNodeArray)
end sub

function ParseJsonToNodeArray(json as Object, live_json as Object, recent_json as Object) as Object
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

    if live_json <> invalid and live_json.video <> invalid
        video = live_json.video
        liveItem = CreateObject("roSGNode", "ContentNode")
        imageUrl = video.image
        if Left(imageUrl, 8) <> "https://" and Left(imageUrl, 7) <> "http://"
            imageUrl = "https://" + imageUrl
        end if
        liveItem.SetFields({
            title: video.title,
            sdposterurl: imageUrl
            hdposterurl: imageUrl
            fhdposterurl: imageUrl
            url: video.stream
        })
        rows.Push({
            title: "Live"
            children: [liveItem]
        })
    end if

    if recent_json <> invalid and recent_json.results <> invalid
        recentItems = []

        for each video in recent_json.results
            item = CreateObject("roSGNode", "ContentNode")

            item.SetFields({
                title: video.name
                Description: video.deck
                sdposterurl: video.image.screen_url
                hdposterurl: video.image.screen_large_url
                guid: video.guid
                url: GBBestVideo(video)
            })

            recentItems.Push(item)
        end for

        showMoreItem = CreateObject("roSGNode", "ContentNode")
        showMoreItem.SetFields({
            id: "show-more-recent"
            title: "More recent"
            fhdposterurl: "pkg:/images/more_fhd.png"
            hdposterurl: "pkg:/images/more_fhd.png"
            sdposterurl: "pkg:/images/more_sd.png"
        })
        recentItems.Push(showMoreItem)
        rows.Push({
            title: "Recent Videos"
            children: recentItems
        })
    end if

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
