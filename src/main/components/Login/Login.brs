sub Init()
    m.keyboard = m.top.FindNode("keyboard")
    m.buttons = m.top.FindNode("buttons")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
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
