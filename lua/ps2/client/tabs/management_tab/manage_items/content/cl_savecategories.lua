function Pointshop2.DoSaveCategories( categoriesNode, notForSaleNode )
    if IsValid( nodeToSelect ) then
        nodeToSelectText = nodeToSelect:GetText( )
    end

    local function recursiveAddCategory( node, tbl )
        if not IsValid( node ) then
            return
        end

        local nodeInTable = {
            self = {
                label = node:GetText( ),
                icon = node:GetIcon( )
            },
            subcategories = { },
            items = { }
        }

        if node.ChildNodes then
            for k, childNode in pairs( node.ChildNodes:GetChildren( ) ) do
                recursiveAddCategory( childNode, nodeInTable.subcategories )
            end
        end

        --make sure it has all items it should contain
        node:DoPopulate( )
        for k, itemIcon in pairs( node.PropPanel:GetItems( ) ) do
            table.insert( nodeInTable.items, itemIcon.itemClass.className )
        end

        table.insert( tbl, nodeInTable )
    end

    local categoriesWithItems = {
        self = {
            label = "Root",
            icon = "Root",
        },
        items = {},
        subcategories = {},
    }
    for k, v in ipairs( {categoriesNode, notForSaleNode} ) do
        recursiveAddCategory( v, categoriesWithItems.subcategories )
    end

    if #categoriesWithItems == 1 then
        debug.Trace()
        Derma_Message( "Your changes cold not be saved. Please change something and save again", "Error")
        return
    end

    Pointshop2View:getInstance( ):saveCategoryOrganization( categoriesWithItems )
end
