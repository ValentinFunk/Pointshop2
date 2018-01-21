local previewItemClass

local function validateOutfitList( previewPanel, ignorePreview )
	previewPanel.outfits = {}

	for _, item in pairs( LocalPlayer().PS2_EquippedItems ) do
		local isHat = instanceOf( Pointshop2.GetItemClassByName( "base_hat" ), item )
		if isHat and not item:NoPreview() then
			local outfit, id = item:getOutfitForModel( previewPanel.Entity:GetModel() )
			previewPanel.outfits[id] = outfit
		end
	end
	if previewItemClass and not ignorePreview then
		local outfit, id = previewItemClass.getOutfitForModel( previewPanel.Entity:GetModel( ) )
		previewPanel.outfits[id] = outfit
	end

	previewPanel.Entity.attachedOutfits = previewPanel.Entity.attachedOutfits or {}

	--Remove outfits not valid anymore
	for id, outfit in pairs( previewPanel.Entity.attachedOutfits ) do
		if not previewPanel.outfits[id] then
			print( "detaching", id )
			previewPanel.Entity:RemovePACPart( outfit )
			previewPanel.Entity.attachedOutfits[id] = nil
		end
	end

	--Add outfits that are not added yet
	for id, outfit in pairs( previewPanel.outfits ) do
		if not previewPanel.Entity.attachedOutfits[id] then
			previewPanel.Entity:AttachPACPart( outfit )
			timer.Simple(0, function( )
				if not IsValid(previewPanel.Entity) then
					return 
				end
				
				if not previewPanel.Entity.AttachPACPart then
					previewPanel.Entity.Owner = LocalPlayer()	
					pac.SetupENT( previewPanel.Entity, "Owner" ) --why u do dis?
				end
				previewPanel.Entity:AttachPACPart( outfit )
			end )
			previewPanel.Entity.attachedOutfits[id] = outfit
		end
	end
end

hook.Add( "PACItemSelected", "ItemSelected", function( itemClass )
	previewItemClass = itemClass
end )

hook.Add( "PACItemDeSelected", "ItemDeselected", function( itemClass )
	if previewItemClass == itemClass then
		previewItemClass = nil
	end
end )

local function preStart3d( self, ignorePreview )
	if not self.Entity.FindPACPart then
		--print( "Setting ent up for PAC", self.Entity )
		self.Entity.Owner = self.Entity
		pac.SetupENT( self.Entity, "Owner" )
	end

	validateOutfitList( self, ignorePreview )

	for k, v in pairs( self.Entity.pac_outfits or {} ) do
		pac.HookEntityRender( self.Entity, v )
	end
end

local function preDrawModel( self )
	pac.ShowEntityParts( self.Entity )
	pac.RenderOverride( self.Entity, "opaque" )
end

local function postDrawModel( self )
	pac.RenderOverride(self.Entity, "translucent", true)

	for k, v in pairs( self.Entity.pac_outfits or {} ) do
		pac.UnhookEntityRender( self.Entity, v )
	end
end

--Inventory Hooks
hook.Add( "PS2_InvPreviewPanelPaint_PreStart3D", "PACPreview", function( self )
	preStart3d( self, true )
end )

hook.Add( "PS2_InvPreviewPanelPaint_PreDrawModel", "prepac", function( self )
	preDrawModel( self )
end )

hook.Add( "PS2_InvPreviewPanelPaint_PostDrawModel", "postpac", function( self )
	postDrawModel( self )
end )

--Shop Hooks
hook.Add( "PS2_PreviewPanelPaint_PreStart3D", "PACPreview", function( self )
	preStart3d( self )
end )


hook.Add( "PS2_PreviewPanelPaint_PreDrawModel", "prepac", function( self )
	preDrawModel( self )
end )

hook.Add( "PS2_PreviewPanelPaint_PostDrawModel", "postpac", function( self )
	postDrawModel( self )
end )
