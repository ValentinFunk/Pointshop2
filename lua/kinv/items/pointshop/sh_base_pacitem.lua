ITEM.baseClass	= "base_pointshop_item"
ITEM.printName 	= "Pointshop PAC Item Base"

function ITEM:OnEquip( )
	self:DoPACAttach( self.outfit )
end

function ITEM:OnHolster( )
	self:DoPACDetach( self.outfit )
end

function ITEM:DoPACAttach( )

end

function ITEM:DoPACDetach( )

end