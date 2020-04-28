sub GetContent()
    video = m.top.video

    json = GETGBResource("/video/get-saved-time", [
        ["video_id", video.id]
    ]).json

    if json.savedTime <> invalid and Type(json.savedTime) = "String"
        bookmarkPosition = json.savedTime.ToFloat()
    else
        bookmarkPosition = 0
    end if

    '
    ' Problem here is that we need to pass in a dict (or whatever man)
    ' to Update or it won't get the data. Can we get just this structure
    ' out of a ContentNode? I couldn't. It's your problem now.
    '
    m.top.content.Update({
        id: video.id
        description: video.description
        hdposterurl: video.hdposterurl
        sdposterurl: video.sdposterurl
        title: video.title
        url: video.url,
        bookmarkPosition: bookmarkPosition
    })
end sub
