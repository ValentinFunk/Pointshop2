--[[
    Provides a renderer for Hat Icons.
]]--

hook.Run( "PS2_DoUpdatePreviewModel" )
local plyModel = hook.Run( "PS2_GetPreviewModel" ) and hook.Run( "PS2_GetPreviewModel" ).model or "models/player/alyx.mdl"
local entity = ClientsideModel( plyModel, RENDERGROUP_OTHER )
entity.Owner = entity
pac.SetupENT( entity, "Owner" )
entity:SetNoDraw(true)
entity:SetIK( false )
local colAmbientLight = Color( 50, 50, 50 )
local colColor = Color( 255, 255, 255, 255 )
local directionalLight = {
	[BOX_TOP] = Color(255, 255, 255),
	[BOX_FRONT] = Color(255, 255, 255)
}
local iSeq = entity:LookupSequence( "walk_all" )
if ( iSeq <= 0 ) then iSeq = entity:LookupSequence( "WalkUnarmed_all" ) end
if ( iSeq <= 0 ) then iSeq = entity:LookupSequence( "walk_all_moderate" ) end

local function getPetModel(outfit)
	local function checkModel( part )
		for k, v in pairs( part.children or {} ) do
			local mdl = checkModel( v )
			if mdl then
				return mdl
			end
		end

		if part.self and part.self.Model then
			if part.self.Name == "Pet-Model" then
				return part.self.Model
			end
		end
	end

	for k, part in pairs( outfit ) do
		local mdl = checkModel( part )
		if mdl then
			return mdl
		end
	end
end

local function generateViewInfo( entity )
	local pos = entity:GetPos()
	local mn, mx = entity:GetRenderBounds()
	local middle = ( mn + mx ) * 0.5
	local size = 0
	size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
	size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
	size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )


	local at = entity:GetAttachment( entity:LookupAttachment( "eyes" ) )

	local ViewAngle = at.Ang + Angle( -10, 160, 0 )
	local ViewPos = at.Pos + ViewAngle:Forward() * -60 + ViewAngle:Up() * -2
	local view = {}

	view.fov		= 10
	view.origin		= ViewPos
	view.znear		= 0.1
	view.zfar		= 100
	view.angles		= ViewAngle

	return view
end

if ( iSeq > 0 ) then entity:ResetSequence( iSeq ) end
entity:FrameAdvance( 1 )
local function PaintHatIcon(itemClass)
	local outfit = itemClass.getOutfitForModel(plyModel)
	if not outfit then
		surface.SetDrawColor(255, 0, 0)
		surface.DrawRect(0, 0, 512, 512)
		draw.SimpleText( "Mising Outfit", "PS2_LargeHeading", 256, 256, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		Pointshop2View:getInstance():displayError( "Item " .. itemClass:GetPrintName() .. " has no base outfit! Please add one. (tell an admin)" )
		PrintTable(itemClass)
		return
	end
	pac.SetupENT( entity, "Owner" )
	entity.Owner = entity
	entity:AttachPACPart( outfit )
	entity:FrameAdvance( 1 )
	pac.ShowEntityParts( entity )
	
	local petModel = getPetModel( outfit )

	for k, v in pairs( entity.pac_outfits or {} ) do
		pac.HookEntityRender( entity, v )
	end
	
	if not petModel then
		local viewInfo = itemClass.iconInfo.shop.iconViewInfo
		entity:SetModel( plyModel )
		cam.Start3D( viewInfo.origin, viewInfo.angles, viewInfo.fov - 20, 0, 0, 512, 512, 5, 4096 )
			cam.IgnoreZ( true )
			render.SuppressEngineLighting( true )
			render.SetLightingOrigin( entity:GetPos() )
			render.ResetModelLighting( colAmbientLight.r/255, colAmbientLight.g/255, colAmbientLight.b/255 )
			render.SetColorModulation( colColor.r/255, colColor.g/255, colColor.b/255 )
			render.SetBlend( 1 )

			for i=0, 6 do
				local col = directionalLight[ i ]
				if ( col ) then
					render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
				end
			end

			pac.FlashlightDisable( true )
				pac.RenderOverride( entity, "opaque" )
				pac.RenderOverride( entity, "translucent", true )
				entity:DrawModel( )
				pac.RenderOverride( entity, "translucent", true )
			pac.FlashlightDisable( false )

			cam.IgnoreZ( false )
			render.SuppressEngineLighting( false )
		cam.End3D( )
	else
		print("petmdl", petModel )
		entity:SetModel( petModel )

		local camPos = Vector( 0, 30, 10 )
		local lookAt = Vector( 0, 0, 0 )
		local fov = 70
		local PrevMins, PrevMaxs = entity:GetRenderBounds()
		camPos = PrevMins:Distance(PrevMaxs) * Vector(0.65, 0.65, 0.5) 
		lookAt = (PrevMaxs + PrevMins) / 2

		-- local view = generateViewInfo( entity )
		local view = PositionSpawnIcon( entity, Vector(0, 0, 0), false )
		local ang = ( lookAt - camPos ):Angle()
		cam.Start3D( view.origin, view.angles, view.fov, 0, 0, 512, 512, view.znear, view.zfar )
			cam.IgnoreZ( true )
			render.SuppressEngineLighting( true )
			render.SetLightingOrigin( entity:GetPos() )
			render.ResetModelLighting( colAmbientLight.r/255, colAmbientLight.g/255, colAmbientLight.b/255 )
			render.SetColorModulation( colColor.r/255, colColor.g/255, colColor.b/255 )
			render.SetBlend( 1 )

			for i=0, 6 do
				local col = directionalLight[ i ]
				if ( col ) then
					render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
				end
			end

			entity:DrawModel( )

			cam.IgnoreZ( false )
			render.SuppressEngineLighting( false )
		cam.End3D( )
	end

	entity:RemovePACPart(outfit)
	pac.HideEntityParts( entity )
	for k, v in pairs( entity.pac_outfits or {} ) do
		pac.UnhookEntityRender( entity, v )
	end
end


local HatRendererMixin = {}
function HatRendererMixin:included( klass )
    klass.static.PaintIcon = function(cls)
        PaintHatIcon(cls)
    end
end
Pointshop2.RegisterItemClassMixin( "base_hat", HatRendererMixin )