sub Init()
    m.keyboard = m.top.FindNode("keyboard")
    m.buttons = m.top.FindNode("buttons")

    m.apiTokenTask = createObject("roSGNode", "ApiTokenTask")
    m.apiTokenTask.ObserveField("content", "SetApiToken")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")

    m.buttons.ObserveField("buttonSelected", "OnSubmit")
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

function OnSubmit():
    code = m.keyboard.text
    MakeAPIRequest(code)
end function

sub SetApiToken()
    tokenInfo = m.apiTokenTask.content
    if tokenInfo.status = "success" then
        authRegistry = CreateObject("roRegistrySection", "Authentication")
        authRegistry.Write("apiToken", tokenInfo.regToken)
        authRegistry.Write("apiTokenExpiry", tokenInfo.expiration)
        authRegistry.Flush()
    end if
end sub
