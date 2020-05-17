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
    if rowContent.title = "Browse"
        ShowShowsView()
    else if rowContent.title = "Search"
        ShowSearchView()
    else if rowContent.title = "Login"
        ShowLoginView()
    else if rowContent.title = "Logout"
        m.mainmenu.callFunc("Logout")
    else
        print "invalid button!"
    end if
    ' detailsView = ShowDetailsView(rowContent, selectedIndex[1])
    ' detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

function ShowSearchView() as object
    searchView = CreateObject("roSGNode", "SearchView")
    searchView.theme = {
        BackgroundColor: "@{background_color}"
        OverhangLogoUri: "@{images.top_image}"
    }
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
    m.login.ObserveField("closeSignal", "OnCloseLogin")
    m.top.ComponentController.CallFunc("show", {
        view: m.login
    })
end function

sub OnCloseLogin()
    '
    ' There surely has to be a better way to do this lol
    ' Should investigate how eg the details view handles it
    '
    if m.login.closesignal = 1 or m.login.closesignal = 2
        Show({})
    end if
end sub
    

sub OnSearchItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    rowContent = grid.content.GetChild(selectedIndex[0])
    video = rowContent.GetChild(selectedIndex[1])
    detailsView = ShowDetailsView(video, selectedIndex[1], false)
    ' detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    ' m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub
