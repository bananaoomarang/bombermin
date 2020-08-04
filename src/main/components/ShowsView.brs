function ShowShowsView() as Object
    ' Create an GridView object and assign some fields
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.SetFields({
        style: "standard"
        posterShape: "16x9"
        theme: {
            BackgroundColor: "@{colors.background}"
            OverhangLogoUri: "@{images.top_image}"
            titleColor: "@{colors.primary}"
            rowTitleColor: "@{colors.primary}"
            rowCounterColor: "@{colors.primary}"
            textColor: "@{colors.secondary}"

        }
    })
    m.grid.ObserveField("rowItemSelected", "OnShowSelected")
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "ShowHandler"
        }
    })
    m.grid.content = content
    ' This will run the content handler and show the Grid
    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })
    return m.grid
end function

sub OnShowSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    videoShow = row.GetChild(selectedIndex[1])

    if videoShow.id = "show-more-recent"
        ShowEpisodePickerView(videoShow)
        return
    end if

    if row.title = "Live" or row.title = "Recent Videos" or row.title = "Continue Watching"
        ShowDetailsView(videoShow, 0, false)
        return
    end if

    ShowEpisodePickerView(videoShow)
end sub
