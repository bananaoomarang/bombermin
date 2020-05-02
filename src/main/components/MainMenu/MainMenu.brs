sub Init()
    m.menulist = m.top.FindNode("menulist")
    m.buttons = m.top.FindNode("menucontent")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")

    m.top.SetFields({
        theme: {
            BackgroundColor: "@{background_color}"
            OverhangLogoUri: "@{images.top_image}"
        }
    })

    RefreshButtons()
end sub

sub OnFocusedChildChanged()
    if m.menulist <> invalid and m.top.IsInFocusChain() and not m.menulist.HasFocus() then
        m.menulist.SetFocus(true)
    end if
end sub

function RefreshButtons()
    authRegistry = CreateObject("roRegistrySection", "Authentication")
    if m.loginbutton = invalid
        m.loginbutton = m.buttons.createChild("ContentNode")
    end if

    if authRegistry.Exists("apiToken") then
        m.loginbutton.title = "Logout"

        if m.showsButton = invalid
            m.showsButton = m.buttons.CreateChild("ContentNode")
            m.showsButton.title = "Shows"
        end if

        if m.searchButton = invalid
            m.searchButton = m.buttons.CreateChild("ContentNode")
            m.searchButton.title = "Search"
        end if
    else
        m.loginbutton.title = "Login"
        if m.showsButton <> invalid
            m.buttons.removeChild(m.showsButton)
        end if

        if m.searchButton <> invalid
            m.buttons.removeChild(m.searchButton)
        end if
    end if
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
    RefreshButtons()
end function
