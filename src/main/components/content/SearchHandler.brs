' ********** Copyright 2019 Roku Corp. All Rights Reserved. **********

sub GetContent()
    url = CreateObject("roUrlTransfer")
    json = GETGBResource("/search", [
        ["query", url.Escape(m.top.query)]
    ]).json
    
    if json.results <> invalid and json.results.Count() > 0
        ' parsing reponse to content items
        rows = {}
        for each item in json.results
            rowItem = {
                id: item.id,
                title: item.name
                shortDescriptionLine1: item.deck
                Description: item.deck
                sdposterurl: item.image.screen_url
                hdposterurl: item.image.screen_large_url
                url: item.high_url
            }
            if rows[item.resource_type] = invalid then rows[item.resource_type] = []
            rows[item.resource_type].Push(rowItem)
        end for

        ' building rows with specific content items
        rootChildren = {
            children: []
        }
        for each key in rows
            row = {
                children: []
            }
            row.title = Ucase(key.left(1)) + Lcase(key.Right(key.Len() - 1))
            row.children = rows[key]
            rootChildren.children.Push(row)
        end for

        ' update the root node with rows as children
        ' so they will be displayed in the view
        m.top.content.Update(rootChildren)
    end if
end sub
