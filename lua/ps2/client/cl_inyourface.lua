function Pointshop2.ItemInYourFace(itemIcon)
	Pointshop2.InYourFaceItem = vgui.Create("DPanel")
	Pointshop2.InYourFaceItem:SetSize(128, 128)
	Pointshop2.InYourFaceItem:SetPaintedManually(true)
	function Pointshop2.InYourFaceItem:Paint(w, h)
		surface.SetDrawColor(color_white)
		surface.DrawRect(0, 0, w, h)
	end

	itemIcon:SetParent(Pointshop2.InYourFaceItem)
	itemIcon:Dock(FILL)

	local start = Pointshop2.InYourFaceItem:GetWide()
	local diff = math.min(ScrW(), ScrH()) - start
	local promise, tween = LibK.tween( easing.outQuart, 0.5, function( p )
		if not IsValid(Pointshop2.InYourFaceItem) then return end
		Pointshop2.InYourFaceItem.size = { start + diff * p, start + diff * p }
	end )
	Pointshop2.InYourFaceItem.tween1 = tween
	timer.Simple(0.25, function()
		local promise, tween = LibK.tween( easing.outQuart, 0.25, function( p )
			if not IsValid(Pointshop2.InYourFaceItem) then return end
			Pointshop2.InYourFaceItem.blend = 1 - p
		end )
		Pointshop2.InYourFaceItem.tween2 = tween
	end)
end

hook.Add("DrawOverlay", "drawinyourface", function()
	if not IsValid(Pointshop2.InYourFaceItem) then
		return
	end

	if Pointshop2.InYourFaceItem.tween1 then
		if Pointshop2.InYourFaceItem.tween1:update() then
			return Pointshop2.InYourFaceItem:Remove()
		end
	end
	if Pointshop2.InYourFaceItem.tween2 then
		if Pointshop2.InYourFaceItem.tween2:update() then
			return Pointshop2.InYourFaceItem:Remove()
		end
	end

	local itemIcon = Pointshop2.InYourFaceItem
	surface.SetAlphaMultiplier(itemIcon.blend or 1)
	DisableClipping(true)
	
		local w, h = unpack(Pointshop2.InYourFaceItem.size)
		itemIcon:SetSize(w, h)
		Pointshop2.InYourFaceItem:SetPaintedManually(false)
		render.SetBlend(itemIcon.blend or 1)
		itemIcon:PaintAt( ScrW() / 2 - w / 2, ScrH() / 2  - h / 2 )
		if itemIcon.SetAlpha then
			itemIcon:SetAlpha((itemIcon.blend or 1) * 255)
		end
		render.SetBlend(1)
		Pointshop2.InYourFaceItem:SetPaintedManually(true)

	DisableClipping(false)
	surface.SetAlphaMultiplier(1.0)
end)