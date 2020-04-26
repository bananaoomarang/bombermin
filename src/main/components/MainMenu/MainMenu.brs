sub Init()
    m.menulist = m.top.FindNode("menulist")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
end sub

sub OnFocusedChildChanged()
    if m.menulist <> invalid and m.top.IsInFocusChain() and not m.menulist.HasFocus() then
        m.menulist.SetFocus(true)
    end if
end sub
