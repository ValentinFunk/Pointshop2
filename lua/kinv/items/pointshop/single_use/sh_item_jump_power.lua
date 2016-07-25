ITEM.baseClass	= "base_single_use"
ITEM.PrintName	= "Jump Power"
ITEM.Description = "Use to get 2x Jump Power!"
ITEM.material = "pointshop2/small65.png"

function ITEM:CanBeUsed( )
	local canBeUsed, reason = ITEM.super.CanBeUsed( self )
	if not canBeUsed then
		return false, reason
	end

	local ply = self:GetOwner( )
	if not ply:Alive( ) or ( ply.IsSpec and ply:IsSpec( ) ) then
		return false, "You need to be alive to use this item"
	end
	return true
end

function ITEM:OnUse( )
	self:GetOwner( ):SetJumpPower( self:GetOwner( ):GetJumpPower( ) * 2 )
end
