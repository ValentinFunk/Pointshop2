Pointshop2.CategoryTree = class( "Pointshop2.CategoryTree" )
local CategoryTree = Pointshop2.CategoryTree

-- Sorts the tree to make sure categories are in the correct order
local function recursiveSort( tree )
	for k, v in pairs( tree.subcategories ) do
		recursiveSort( v )
	end
	table.sort( tree.subcategories, function( a, b )
		return a.self.id < b.self.id
	end )
end

-- This converts the flat category structure as found in the database to a tree representation.
-- itemMappings is a list of itemMapping DB entries, flatStructure is a list of category db entries
function CategoryTree:initialize( flatStructure, itemMappings )
  local root = self

  local lookup = {}
  for k, v in pairs( flatStructure ) do
    local node = {
      self = {
        id = tonumber( v.id ),
        label = v.label,
        icon = v.icon
      },
      subcategories = {},
      items = {},
      parentId = v.parent
    }
		if not v.parent then
			for _k, _v in pairs( node ) do
				self[_k] = _v
			end
			lookup[v.id] = self
			node = self
		else
    	lookup[v.id] = node
		end

    for k, dbItemMapping in pairs( itemMappings ) do
      if dbItemMapping.categoryId == node.self.id then
        table.insert( node.items, dbItemMapping.itemClass )
      end
    end
  end

  for k, v in pairs( lookup ) do
    if lookup[v.parentId] then
      lookup[v.parentId].subcategories = lookup[v.parentId].subcategories or {}
      table.insert( lookup[v.parentId].subcategories, v )
    end
  end
  recursiveSort( root )
end

function CategoryTree:getNodeByName( name, rootNode )
  rootNode = rootNode or self

  for k, v in pairs( rootNode.subcategories or {} ) do
    if v.self.label == name then
      return v
    end

    local foundInSubcategory = self:getNodeByName( name, v )
    if foundInSubcategory then
      return foundInSubcategory
    end
  end
end

function CategoryTree:getNotForSaleNode( )
  if not self._notForSaleNode then
    self._notForSaleNode = self:getNodeByName( "Not for sale Items" )
  end
  return self._notForSaleNode
end

function CategoryTree:getNotForSaleItemClassNames( )
	if not self._nfsItemIds then
    local itemIds = {}

    local function recursiveAddItemIds( rootNode )
      for k, v in pairs( rootNode.subcategories or {} ) do
        for _, itemId in pairs( v.items ) do
					table.insert( itemIds, itemId )
				end
        recursiveAddItemIds( v )
      end
    end
    recursiveAddItemIds( self:getNotForSaleNode( ) )

    self._nfsItemIds = itemIds
  end

  return self._nfsItemIds
end
