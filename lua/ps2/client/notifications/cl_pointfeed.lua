local function createPointFeed( )
	if IsValid( GAMEMODE.PS2_PF ) then
		GAMEMODE.PS2_PF:Remove( ) -- for reloads
	end
	
	Pointshop2.PointFeed = vgui.Create( "DPointFeed" )
	Pointshop2.PointFeed:SetSize( ScrW( ) / 3, ScrH( ) / 5 )
	Pointshop2.PointFeed:ParentToHUD( )
	Pointshop2.PointFeed:SetPos( ScrW( ) / 2 - Pointshop2.PointFeed:GetWide( ) / 2, ScrH( ) - Pointshop2.PointFeed:GetTall( ) - 20 )
	GAMEMODE.PS2_PF = Pointshop2.PointFeed
end

hook.Add( "InitPostEntity", "AddPointFeed", function( )
	createPointFeed( )
end )

hook.Add( "OnReloaded", "AddPointFeed", function( )
	if LibK.Debug then
		createPointFeed( )
	end
end )