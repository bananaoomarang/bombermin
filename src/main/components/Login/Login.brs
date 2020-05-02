sub Init()
    m.keyboard = m.top.FindNode("keyboard")
    m.buttons = m.top.FindNode("buttons")

    m.apiTokenTask = createObject("roSGNode", "ApiTokenTask")
    m.apiTokenTask.ObserveField("content", "SetApiToken")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")

    m.buttons.ObserveField("buttonSelected", "OnButtonSelected")

    m.top.SetFields({
        theme: {
            BackgroundColor: "@{background_color}"
            OverhangLogoUri: "@{images.top_image}"
        }
    })
end sub

sub OnFocusedChildChanged()
    if m.keyboard <> invalid and m.top.IsInFocusChain() and not m.keyboard.HasFocus() and not m.buttons.IsInFocusChain() then
        m.keyboard.SetFocus(true)
    end if
end sub

function OnKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press then
        if key = "down" and m.keyboard.IsInFocusChain() then:
            m.buttons.SetFocus(true)
            handled = true
        else if key = "up" and m.buttons.IsInFocusChain() then:
            m.keyboard.SetFocus(true)
            handled = true
        end if
    end if

    return handled
end function

function makeAPIRequest(code as String)
    m.apiTokenTask.control = "STOP"
    m.apiTokenTask.setField("code", code)
    m.apiTokenTask.control = "RUN"
end function

function OnButtonSelected(event as Object):
    selectedIndex = event.getData()
    selectedButton = m.buttons.getChild(selectedIndex)
    code = m.keyboard.text

    if selectedButton.text = "OK" and code <> ""
        MakeAPIRequest(code)
    else if selectedButton.text = "Cancel"
        m.top.closesignal = 2
    end if
end function

sub SetApiToken()
    tokenInfo = m.apiTokenTask.content
    if tokenInfo.status = "success" then
        authRegistry = CreateObject("roRegistrySection", "Authentication")
        authRegistry.Write("apiToken", tokenInfo.regToken)
        authRegistry.Write("apiTokenExpiry", tokenInfo.expiration)
        authRegistry.Flush()
        m.top.closesignal = 1
    end if
end sub
