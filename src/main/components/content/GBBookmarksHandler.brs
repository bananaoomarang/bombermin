' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function SaveTime(content as Object, position as Integer) as Object
    json = GETGBResource("/video/save-time", [
        ["video_id", content.id],
        ["time_to_save", position.ToStr()]
    ]).json
    return json
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
