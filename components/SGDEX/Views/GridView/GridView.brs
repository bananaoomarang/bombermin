' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    initGridViewNodes()

    m.Handler_ConfigField = "HandlerConfigGrid"

    m.gridNode = invalid
    ' this is to store theme attributes as set theme is called in init o theme should be set after node is created

    ' Observe SGDEXComponent fields
    m.top.ObserveField("style", "RebuildRowList")
    m.top.ObserveField("posterShape", "RebuildRowList")
    m.top.ObserveField("content", "OnContentSet")

    m.top.ObserveFieldScoped("rowItemFocused", "OnRowItemFocusedChange")
    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")

    ' Set default values
    m.top.style = "standard"
    m.top.posterShape = "16x9"
end sub

sub initGridViewNodes()
    m.details = m.top.viewContentGroup.CreateChild("ItemDetailsView")
    m.details.id = "details"
    m.details.translation = [125, 0]
    m.details.maxWidth = 666

    layoutGroup = m.top.CreateChild("LayoutGroup")
    layoutGroup.translation = [640, 360]
    layoutGroup.horizAlignment = "center"
    layoutGroup.vertAlignment = "center"

    m.spinner = layoutGroup.CreateChild("BusySpinner")
    m.spinner.visible = false
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
end sub

sub OnShowSpinnerChange()
    showSpinner = m.top.showSpinner

    if m.gridNode <> invalid
        m.gridNode.visible = not showSpinner
    end if

    m.spinner.visible = showSpinner
    if showSpinner
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
        OnRowItemFocusedChange()
        rowItemFocused = m.gridNode.rowItemFocused
        valuesToFire = [0, 0]
        if rowItemFocused <> invalid and rowItemFocused.count() > 1
            if rowItemFocused[0] >= 0 then
                valuesToFire[0] = rowItemFocused[0]
            end if
            if rowItemFocused[1] >= 0 then
                valuesToFire[1] = rowItemFocused[1]
            end if
        end if
        m.top.rowItemFocused = valuesToFire
    end if
end sub

sub OnUpdateFocusedItem()
    OnRowItemFocusedChange()
end sub

sub OnFocusedChildChanged()
    if m.gridNode <> invalid and m.top.IsInFocusChain() and not m.gridNode.HasFocus()
        m.gridNode.SetFocus(true)
    end if
end sub

sub RebuildRowList()
    configuration = GetConfigurationForStyle(m.top.style)
    if configuration <> invalid
        CreateNewOrUpdateGridNode(configuration.node, configuration.fields)
        if m.gridNode <> invalid AND m.gridNode.subtype() <> "ZoomRowList"
            CreateNewOrUpdateGridNode("", GetConfigurationForPosterShape(m.top.posterShape, m.gridNode.rowHeights))
        end if
    end if
end sub

sub CreateNewOrUpdateGridNode(componentName = "" as String, fields = {} as Object)
    observers = {
        "rowItemFocused": "SimulateAlias"
        "rowItemSelected": "SimulateAlias"
        "numRows": "SimulateAlias"
        "jumpToRowItem": "SimulateAlias"
        "jumpToRow": "SimulateAlias"
    }

    if componentName.Len() > 0 and m.gridNode <> invalid and m.gridNode.Subtype() <> componentName
        ' remove precious node and observers
        m.top.RemoveChild(m.gridNode)
        for each field in observers
            m.gridNode.UnobserveFieldScoped(field)
        end for
        m.gridNode = invalid
    end if

    ' If node don't created or removed then create new grid node
    if m.gridNode = invalid
        m.gridNode = m.top.viewContentGroup.CreateChild(componentName)
        m.gridNode.AddField("itemTextColorLine1", "color", true)
        m.gridNode.AddField("itemTextColorLine2", "color", true)
        m.gridNode.AddField("itemTextBackgroundColor", "string", true)

        if m.LastThemeAttributes <> invalid then
            SGDEX_SetTheme(m.LastThemeAttributes)
        end if
        if m.top.IsInFocusChain() then m.gridNode.SetFocus(true)
        if m.gridNode <> invalid
            for each field in observers
                m.gridNode.ObserveFieldScoped(field, observers[field])
            end for
            if m.top.content <> invalid then m.gridNode.content = m.top.content
        end if
    end if

    if m.gridNode <> invalid and fields <> invalid
        m.gridNode.SetFields(fields)
    end if
end sub

sub OnContentSet(event as Object)
    content = m.top.content

    if m.gridNode <> invalid
        isNewContent = m.gridNode.content = invalid or content = invalid or not m.gridNode.content.IsSameNode(content)
        if isNewContent then
            ' new content received, completely rebuild gridNode and restore focus if needed
            wasFocused = m.gridNode.HasFocus()

            m.top.viewContentGroup.RemoveChild(m.gridNode)
            m.gridNode = invalid
            RebuildRowList()

            if wasFocused
                m.gridNode.SetFocus(true)
            end if

            if m.gridNode.rowItemFocused = invalid or m.gridNode.rowItemFocused.Count() = 0
                m.gridNode.rowItemFocused = [0, 0]
            end if
            OnRowItemFocusedChange()
        end if
    end if
end sub

sub OnRowItemFocusedChange()
    if m.gridNode <> invalid
        content = m.top.content
        itemContent = invalid
        focusedItem = m.gridNode.rowItemFocused
        if content <> invalid and Type(focusedItem) = "roArray" and focusedItem.Count() = 2
            rowIndex = focusedItem[0]
            if rowIndex < 0 then rowIndex = 0
            row = content.GetChild(rowIndex)
            if row <> invalid
                itemIndex = focusedItem[1]
                if itemIndex < 0 then itemIndex = 0
                itemContent = row.GetChild(itemIndex)
            end if
        end if
        m.details.content = itemContent
    end if
end sub

sub SimulateAlias(event as Object)
    if m.gridNode <> invalid
        field = event.GetField()
        data = event.GetData()
        SetAliasData(field, data)
    end if
end sub

sub SetAliasData(field as String, data as Object)
    m.top[field] = data
    if m.gridNode <> invalid
        m.gridNode[field] = data
    end if
end sub

function GetConfigurationForStyle(style as String) as Object
    ' Base row list configuration fields
    rowItemAspectRatio = GetRowsAspectRatio()
    rowListRowHeight = GetDefaultRowHeight()
    xRowTranslation = 125

    ' adjust the position of the grid depending on whether
    ' the developer wants the metadata area displayed
    m.details.visible = m.top.showMetadata
    if m.top.showMetadata
        rowListTranslation = [xRowTranslation, 145]
    else
        rowListTranslation = [xRowTranslation, 0]
    end if
    zoomRowListHeight = 720 - rowListTranslation[1]

    rowListRowWidth = 1280 - xRowTranslation * 2
    rowListHeroRowHeight = 280
    rowTitleHeight = 30
    defaultItemSpacing = [20, 35 + rowTitleHeight]

    showRowCounter = true
    showRowLabel = true

    ' Custom UI components
    rowFocusAnimationStyle = "fixedFocusWrap"
    itemComponentName = "StandardGridItemComponent"
    rowTitleComponentName = "DefaultRowTitleComponent"

    baseZoomRowListConfig = {
        itemComponentName: itemComponentName
        wrap: false
        rowWidth : rowListRowWidth
        translation: rowListTranslation

        ' focusLimit is a special field to specify the height of the
        ' zoomRowList area where the focus can be
        focusLimit : rowListRowHeight - 1

        spacingAfterRow: defaultItemSpacing[1]
        spacingAfterRowItem: defaultItemSpacing[0]

        rowItemYOffset: rowTitleHeight
        rowItemZoomYOffset: rowTitleHeight
        rowItemAspectRatio: rowItemAspectRatio

        ' To make row counter to be placed symmetrically from right edge
        rowCounterOffset: [[rowListRowWidth, 0]]

        showRowCounter: showRowCounter
        showRowTitle: showRowLabel
    }

    styles = {
        "standard": {
            node : "ZoomRowList"
            fields: {
                rowZoomHeight: rowListRowHeight
                rowItemZoomHeight: rowListRowHeight
                rowHeight: rowListRowHeight
                rowItemHeight: rowListRowHeight
            }
        }
        "hero": {
            node : "ZoomRowList"
            fields: {
                rowZoomHeight: [rowListHeroRowHeight, rowListRowHeight]
                rowItemZoomHeight: [rowListHeroRowHeight, rowListRowHeight]
                rowHeight: rowListRowHeight
                rowItemHeight: rowListRowHeight
            }
        }
        "zoom": {
            node : "ZoomRowList"
            fields: {
                rowZoomHeight: [rowListHeroRowHeight]
                rowItemZoomHeight: [rowListHeroRowHeight]
                rowHeight: rowListRowHeight
                rowItemHeight: rowListRowHeight
            }
        }
    }
    if styles[style] = invalid then style = "standard"
    config = styles[style]

    if config.node = "ZoomRowList" then
        complexZoomRowListConfig = baseZoomRowListConfig
        complexZoomRowListConfig.append(config.fields)
        config.fields = complexZoomRowListConfig
    end if

    return config
end function

function GetRowsAspectRatio() as Object
    styles = {
        "portrait": 3.0 / 4.0
        "4x3": 4.0 / 3.0
        "16x9": 16.0 / 9.0
        "square": 1.0
    }
    posterShape = m.top.posterShape
    if styles[posterShape] = invalid then posterShape = "16x9"

    ' if rowPosterShapes was set then set appropriate aspect ratio to rows
    rowPosterShapes = m.top.rowPosterShapes
    if rowPosterShapes <> invalid and rowPosterShapes.Count() > 0
        rowsAspectRatio = []
        for each shape in rowPosterShapes
            if styles[shape] <> invalid
                rowsAspectRatio.Push(styles[shape])
            else
                rowsAspectRatio.Push(styles[posterShape])
            end if
        end for
        rowsAspectRatio.Push(styles[posterShape]) ' set rest of rows to posterShape
        return rowsAspectRatio
    end if

    return [styles[posterShape]]
end function

function GetDefaultRowHeight() as Float
    defaultItemHeight = 100
    topMargin = 45 ' label height + spacing
    if m.top.posterShape = "portrait" then
        defaultItemHeight = defaultItemHeight * 1.5
    end if

    return defaultItemHeight + topMargin
end function

function GetRowItemSizeForPosterShape(style as String, rowHeight as Integer) as Object
    topMargin = 45 ' label height + spacing
    height = rowHeight - topMargin
    styles = {
        "portrait": [Int(height * 3 / 4), height]
        "4x3": [Int(height * 4 / 3), height]
        "16x9": [Int(height * 16 / 9), height]
        "square": [height, height]
    }
    if styles[style] = invalid then style = "16x9"
    return styles[style]
end function

function GetConfigurationForPosterShape(style as String, rowHeights as Object) as Object
    if Type(rowHeights) <> "roArray" or rowHeights.Count() = 0 then return invalid
    rowItemSize = []

    for each height in rowHeights
        rowItemSize.Push(GetRowItemSizeForPosterShape(style, height))
    end for

    return { rowItemSize: rowItemSize }
end function

sub SGDEX_SetTheme(theme as Object)
    colorTheme = {
        TextColor: {
            gridNode: [
                "rowLabelColor"
                "rowTitleColor"
                "rowCounterColor"
                "itemTextColorLine1"
                "itemTextColorLine2"
            ]
            details: [
                "titleColor"
                "descriptionColor"
            ]
        }
        focusRingColor: {
            gridNode: ["focusBitmapBlendColor"]
        }
    }

    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)

    gridThemeAttributes = {
        rowLabelColor:       { gridNode: ["rowLabelColor", "rowTitleColor", "rowCounterColor"] }
        focusRingColor:      { gridNode: "focusBitmapBlendColor" }
        focusFootprintColor: { gridNode: "focusFootprintBlendColor" }
        itemTextColorLine1:  { gridNode: "itemTextColorLine1" }
        itemTextColorLine2:  { gridNode: "itemTextColorLine2" }
        itemTextBackgroundColor: { gridNode : "itemTextBackgroundColor"}

        ' details attributes
        descriptionmaxWidth: { details: "maxWidth" }
        titleColor:          { details: "titleColor" }
        descriptionColor:    { details: "descriptionColor" }
        descriptionMaxLines: { details: "descriptionMaxLines" }

        busySpinnerColor: { spinner : { poster: "blendColor"} }
    }
    SGDEX_setThemeFieldstoNode(m, gridThemeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "gridView"
end function

' If need to adjust GridView according to ButtonBar
sub SGDEX_UpdateViewUI()
end sub
