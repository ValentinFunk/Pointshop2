ITEM.baseClass	= "base_pointshop_item"
ITEM.PrintName	= "Jump Height"

function ITEM:OnEquip( ply )
	ply.oldJumpPower = ply:GetJumpPower( )
	ply:SetJumpPower( ply.oldJumpPower * 2 ) 
end

function ITEM:OnHolster( ply )
	ply:SetJumpPower( ply.oldJumpPower )
end