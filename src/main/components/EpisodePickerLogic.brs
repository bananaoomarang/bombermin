' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowEpisodePickerView(videoShow = invalid as Object) as Object
    ' Create an CategoryListView object and set the posterShape field
    episodePicker = CreateObject("roSGNode", "CategoryListView")
    episodePicker.posterShape = "16x9"
    episodePicker.theme = {
        BackgroundColor: "@{background_color}"
        OverhangLogoUri: "@{images.top_image}"
    }

    content = CreateObject("roSGNode", "ContentNode")
    ' This gets the seasonContent we parsed out in GridHandler
    content.AddFields({
        HandlerConfigCategoryList: {
            name: "EpisodesHandler"
            fields: {
                videoShow: videoShow
                page: 1
            }
        }
    })
    episodePicker.content = content
    episodePicker.ObserveField("selectedItem", "OnEpisodeSelected")
    ' This will show the CategoryListView to the View and call SeasonsHandler
    m.top.ComponentController.CallFunc("show", {
        view: episodePicker
    })
    return episodePicker
end function

sub OnEpisodeSelected(event as Object)
    ' GetRoSGNode returns the object that was being observed
    categoryList = event.GetRoSGNode()
    ' GetData returns the field that was being observed
    itemSelected = event.GetData()
    category = categoryList.content.GetChild(itemSelected[0])
    item = category.GetChild(itemSelected[1])

    if item.id = "next-page"
        NextPage(categoryList)
        return
    else if item.id = "prev-page"
        PreviousPage(categoryList)
        return
    end if

    details = ShowDetailsView(item, 0, false)
end sub

function NextPage(categoryList)
    page = categoryList.content.HandlerConfigCategoryList.fields.page
    LoadPage(categoryList, page + 1)
end function

function PreviousPage(categoryList)
    page = categoryList.content.HandlerConfigCategoryList.fields.page
    LoadPage(categoryList, page - 1)
end function

function LoadPage(categoryList as Object, page as Integer)
    if page < 0
        page = 0
    end if

    '
    ' Is there like... A way to do this that's not this lol
    '
    ' Maybe we are supposed to modify the existing content to trigger the update
    '
    videoShow = categoryList.content.HandlerConfigCategoryList.fields.videoShow

    content = CreateObject("roSGnode", "ContentNode")
    content.AddFields({
        HandlerConfigCategoryList: {
            name: "EpisodesHandler"
            fields: {
                videoShow: videoShow
                page: page
            }
        }
    })
    categoryList.content = content

    categoryList.animateToItemInCategory = 0
end function
