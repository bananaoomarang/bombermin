sub Init()
    m.menulist = m.top.FindNode("menulist")
    m.buttons = m.top.FindNode("menucontent")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")

    m.menuList.ObserveFieldScoped("itemSelected", "OnMenuItemSelected")

    m.top.SetFields({
        theme: {
            BackgroundColor: "@{background_color}"
            OverhangLogoUri: "@{images.top_image}"
        }
    })

    '
    ' You can't seem to specify this in the XML
    '
    ' Go ahead, just you try.
    '
    sectionVideoQuality = m.top.FindNode("section-video-quality")
    sectionVideoQuality.contenttype = "SECTION"

    LoadSettings()
end sub

sub OnFocusedChildChanged()
    if m.menulist <> invalid and m.top.IsInFocusChain() and not m.menulist.HasFocus() then
        m.menulist.SetFocus(true)
    end if
end sub

sub OnMenuItemSelected(event as Object)
    labelList = event.GetRoSGNode()
    selectedIndex = event.GetData()
    currSectionIndex = labelList.currFocusSection

    currSection = labelList.content.GetChild(currSectionIndex)
    selectedItem = currSection.GetChild(selectedIndex)

    if currSection.title = "Video Quality"
        SaveVideoQuality(selectedItem.title)
    end if
end sub

function SaveVideoQuality(quality as String)
    quality = LCASE(quality)

    settingsRegistry = CreateObject("roRegistrySection", "Settings")
    settingsRegistry.Write("videoQuality", quality)
    settingsRegistry.Flush()
end function

function LoadSettings()
    settingsRegistry = CreateObject("roRegistrySection", "Settings")
    userQuality = settingsRegistry.Read("videoQuality")

    '
    ' Hey I just want to say I'm sorry
    ' I'm sorry I did this but I coultn't see an easier way
    ' Be strong
    '
    indices = {
        videoQualityfhd: 0
        videoQualityhd: 1
        videoQualitysd: 2
    }

    if userQuality = invalid
        userQuality = "hd"
        SaveVideoQuality(userQuality)
    end if

    index = indices["videoQuality" + userQuality]
    if index <> invalid
        m.menuList.checkedItem = index
    end if
end function
