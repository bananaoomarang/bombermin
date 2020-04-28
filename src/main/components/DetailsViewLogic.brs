' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowDetailsView(video as Object, index as Integer, isContentList = true as Boolean) as Object
    details = CreateObject("roSGNode", "DetailsView")
    ' Observe the content, so that when it is set the callback
    ' function will run and the buttons can be created
    details.ObserveField("currentItem", "OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")

    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigDetails: {
            name: "VideoDetailsHandler",
            fields: {
                video: video 
            }
        }
    })
    details.SetFields({
        content: content
        jumpToItem: index
        isContentList: isContentList
    })
    ' This will cause the View to be shown on the View
    m.top.ComponentController.CallFunc("show", {
        view: details
    })
    return details
end function

sub OnDetailsContentSet(event as Object)
    details = event.GetRoSGNode()
    currentItem = event.GetData()
    print "CURRENT ITEM"
    print currentItem
    if currentItem <> invalid
        buttonsToCreate = []

        if currentItem.url <> invalid and currentItem.url <> ""
            buttonsToCreate.Push({ title: "Play", id: "play" })
        end if

        if buttonsToCreate.Count() = 0
            buttonsToCreate.Push({ title: "No Content to play", id: "no_content" })
        end if
        btnsContent = CreateObject("roSGNode", "ContentNode")
        btnsContent.Update({ children: buttonsToCreate })
    end if
    details.buttons = btnsContent
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
        OpenVideoPlayer(details.content, details.itemFocused, details.isContentList)
    else
        ' handle all other button presses
    end if
end sub
