' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    live_request = GETGBResourceAsync("/video/current-live")
    recent_request = GETGBResourceAsync("/videos", [
        ["sort", "publish_date:desc"],
        ["limit", "20"]
    ])
    saved_times_request = GETGBResourceAsync("/video/get-all-saved-times")
    shows_request = GETGBResourceAsync("/video_shows", [
        ["sort", "title:asc"]
    ])

    continue_watching_lookups = GetContinueLookups(saved_times_request, 10)
    continue_watching = LookupVideos(continue_watching_lookups)

    live_json = GBWaitFor(live_request).json
    recent_json = GBWaitFor(recent_request).json
    json = GBWaitFor(shows_request).json

    rootNodeArray = ParseJsonToNodeArray(json, live_json, recent_json, continue_watching)
    m.top.content.Update(rootNodeArray)
end sub

'
' Get list of videos to lookup for 'continue watching'
'
function GetContinueLookups(saved_times_request as Object, max = 5 as Integer) as Object
    json = GBWaitFor(saved_times_request).json
    continue_watching_lookups = []

    for each item in json.savedTimes
        if item.savedTime <> "-1"
            continue_watching_lookups.Push(item.videoId)

            if continue_watching_lookups.Count() >= max:
                return continue_watching_lookups
            end if
        end if
    end for

    return continue_watching_lookups
end function

'
' Lookup videos in parallel
'
function LookupVideos(videoIds as Object) as Object
    '
    ' There is no 'map' method so far as I can tell lol
    '
    requests = []
    jsons = []
    videos = []

    for each id in videoIds
        if id <> invalid
            requests.Push(GETGBResourceAsync("/video/" + id.ToStr()))
        end if
    end for

    for each request in requests
        jsons.Push(GBWaitFor(request).json)
    end for

    for each json in jsons
        if json <> invalid and json.results <> invalid
            videos.Push(json.results)
        end if
    end for

    return videos
end function

function ParseJsonToNodeArray(json as Object, live_json as Object, recent_json as Object, continue_watching as Object) as Object
    if json = invalid then return []

    shows = GBVideosToContent(json.results)
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
        recentItems = GBVideosToContent(recent_json.results)

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

    if continue_watching.Count() > 0
        continueItems = GBVideosToContent(continue_watching)
        rows.Push({
            title: "Continue Watching"
            children: continueItems
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
