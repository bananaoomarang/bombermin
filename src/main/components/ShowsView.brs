function ShowShowsView() as Object
    ' Create an GridView object and assign some fields
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.SetFields({
        style: "standard"
        posterShape: "16x9"
        theme: {
            BackgroundColor: "@{background_color}"
            OverhangLogoUri: "@{images.top_image}"
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

    if row.title = "Live"
        ShowDetailsView(videoShow, 0, false)
    else
        ShowEpisodePickerView(videoShow)
    end if
end sub
