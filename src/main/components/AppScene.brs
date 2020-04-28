sub Show(args as Object)
    m.mainmenu = CreateObject("roSGNode", "MainMenu")
    menuList = m.mainmenu.findNode("menulist")
    menuList.ObserveFieldScoped("itemSelected", "OnMenuItemSelected")
    m.top.ComponentController.CallFunc("show", {
        view: m.mainmenu
    })
    m.top.signalBeacon("AppLaunchComplete")
end sub

sub OnMenuItemSelected(event as Object)
    labelList = event.GetRoSGNode()
    selectedIndex = event.GetData()

    rowContent = labelList.content.GetChild(selectedIndex)
    if rowContent.title = "Shows"
        ShowShowsView()
    else if rowContent.title = "Search"
        ShowSearchView()
    else if rowContent.title = "Login"
        ShowLoginView()
    else if rowContent.title = "Logout"
        Logout()
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
                name: "SearchHandler"
                query: query ' pass the query to the content handler
            }
        })
    end if
    ' setting the content with handlerConfigSearch will create
    ' the content handler where search should be performed
    ' setting the clear content node or invalid will clear the grid with results
    searchView.content = content
end sub

function ShowLoginView() as object
    m.login = CreateObject("roSGNode", "Login")
    m.top.ComponentController.CallFunc("show", {
        view: m.login
    })
end function

function Logout()
    authRegistry = CreateObject("roRegistrySection", "Authentication")
    if authRegistry.Exists("apiToken") then
        authRegistry.Delete("apiToken")
    end if

    if authRegistry.Exists("apiTokenExpiry") then
        authRegistry.Delete("apiTokenExpiry")
    end if

    authRegistry.Flush()

    m.mainmenu.findNode("loginbutton").title = "Login"
end function

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
