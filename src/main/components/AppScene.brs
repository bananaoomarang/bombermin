' ********** Copyright 2019 Roku Corp. All Rights Reserved. **********

'This is the main entry point to the channel scene.
'This function will be called by library when channel is ready to be shown.
' sub Show(args as Object)
'     searchView = CreateObject("roSGNode", "SearchView")
'     searchView.hintText = "Enter search term"
'     ' query field will be changed each time user has typed something
'     searchView.ObserveFieldScoped("query", "OnSearchQuery")
'     searchView.ObserveFieldScoped("rowItemSelected", "OnSearchItemSelected")

'     ' this will trigger job to show this screen
'     m.top.ComponentController.CallFunc("show", {
'         view: searchView
'     })
'     m.top.signalBeacon("AppLaunchComplete")
' end sub


' sub Show(args as Object)
'     ' Create an GridView object and assign some fields
'     m.grid = CreateObject("roSGNode", "GridView")
'     m.grid.SetFields({
'         style: "standard"
'         posterShape: "16x9"
'     })
'     content = CreateObject("roSGNode", "ContentNode")
'     ' This tells the GridView where to go to fetch the content
'     content.AddFields({
'         HandlerConfigGrid: {
'             name: "GridHandler"
'         }
'     })
'     m.grid.content = content
'     ' This will run the content handler and show the Grid
'     m.top.ComponentController.CallFunc("show", {
'         view: m.grid
'     })
'     m.top.signalBeacon("AppLaunchComplete")
' end sub

sub Show(args as Object)
    m.mainmenu = m.top.findNode("mainmenu")

    m.mainmenu.ObserveFieldScoped("itemSelected", "OnMenuItemSelected")
    m.top.ComponentController.CallFunc("show", {
        view: m.mainmenu
    })
    m.top.signalBeacon("AppLaunchComplete")
end sub

sub OnMenuItemSelected(event as Object)
    m.mainmenu.visible = false
    labelList = event.GetRoSGNode()
    selectedIndex = event.GetData()

    rowContent = labelList.content.GetChild(selectedIndex)
    if rowContent.title = "Shows"
        ShowShowsView()
    else if rowContent.title = "Search"
        ShowSearchView()
    end if
    ' detailsView = ShowDetailsView(rowContent, selectedIndex[1])
    ' detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

function ShowSearchView() as object
    searchView = CreateObject("roSGNode", "SearchView")
    searchView.hintText = "Enter search term"
    ' query field will be changed each time user has typed something
    searchView.ObserveFieldScoped("query", "OnSearchQuery")
    searchView.ObserveFieldScoped("rowItemSelected", "OnSearchItemSelected")

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: searchView
    })
    return searchView
end function

sub OnSearchQuery(event as Object)
    query = event.GetData()
    searchView = event.GetRoSGNode()

    content = CreateObject("roSGNode", "ContentNode")
    if query.Len() > 2 ' perform search if user has typed at least three characters
        content.AddFields({
            HandlerConfigSearch: {
                name: "CHSearch"
                query: query ' pass the query to the content handler
            }
        })
    end if
    ' setting the content with handlerConfigSearch will create
    ' the content handler where search should be performed
    ' setting the clear content node or invalid will clear the grid with results
    searchView.content = content
end sub

sub OnSearchItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    rowContent = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(rowContent, selectedIndex[1])
    ' detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    ' m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub
