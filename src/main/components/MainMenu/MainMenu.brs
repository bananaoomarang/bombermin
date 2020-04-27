sub Init()
    m.menulist = m.top.FindNode("menulist")
    m.loginbutton = m.top.FindNode("loginbutton")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")


    authRegistry = CreateObject("roRegistrySection", "Authentication")
    if authRegistry.Exists("apiToken") then
        m.loginbutton.title = "Logout"
    else
        m.loginbutton.title = "Login"
    end if
end sub

sub OnFocusedChildChanged()
    if m.menulist <> invalid and m.top.IsInFocusChain() and not m.menulist.HasFocus() then
        m.menulist.SetFocus(true)
    end if
end sub
