local PANEL = {}

function PANEL:Init( )
	self.panelsWaiting = {}
	self.panels = {}
	self.scrollingPanel = nil

	self.spaceY = 2
	self.fadeDuration = 0.3
	self.maxPanels = 5
	
	self.notificationsPanel = vgui.Create( "DPanel", self )
	self.notificationsPanel:Dock( FILL )
	self.notificationsPanel.Paint = function( ) end
	
	self.totalScorePanel = vgui.Create( "DLabel", self )
	self.totalScorePanel:Dock( RIGHT )
	self.totalScorePanel:SetWide( 100 )
	self.totalScorePanel:DockMargin( 15, 0, 0, 0 )
	self.totalScorePanel:SetSkin( Pointshop2.Config.DermaSkin )
	self.totalScorePanel:SetFont( self.totalScorePanel:GetSkin().TabFont )
	self.totalScorePanel:SetContentAlignment( 7 )
	self.totalScorePanel:SetColor( color_white )
	self.totalScorePanel:SetAlpha( 0 )
	self.scoreAnim = Derma_Anim( "Anim", self, function( self, anim, delta, data )
		if anim.Finished then 
			if data.To == 0 then
				self.accumulatedPoints = 0
				self.totalScorePanel:SetText( self.accumulatedPoints )
			end
			return
		end
		
		self.totalScorePanel:SetAlpha( Lerp( delta, data.From, data.To ) )
	end )
	
	self.accumulatedPoints = 0
	self.lastPointAdd = 0
end

function PANEL:PointsAdded( points ) 
	self.accumulatedPoints = self.accumulatedPoints + points
	self.lastPointAdd = RealTime( )
	self.totalScorePanel:SetText( self.accumulatedPoints )
	
	self.scoreAnim:Start( 0.3, { From = self.totalScorePanel:GetAlpha( ), To = 255 } )
end

function PANEL:Think( )
	if #self.panelsWaiting > 0 and
		#self.panels < self.maxPanels and
		not IsValid( self.scrollingPanel ) then
		self.scrollingPanel = table.remove( self.panelsWaiting, 1 ) -- POP
		self:StartScrollingPanel( )
	end
	
	self:InvalidateLayout( )
	
	self.scoreAnim:Run( )
	if self.lastPointAdd + 3 < RealTime( ) and #self.panels == 0 then
		if not self.scoreAnim:Active( ) then
			self.scoreAnim:Start( 0.3, { From = self.totalScorePanel:GetAlpha( ), To = 0 } )
		end
	end
end

function PANEL:StartScrollingPanel( )
	local panel = self.scrollingPanel
	panel:SetVisible( true )
	panel:SetParent( self.notificationsPanel )
	panel:SetPos( 0, -panel:GetTall( ) )
	panel:SetWide( self.notificationsPanel:GetWide( ) )
	local amountToScroll = -panel:GetTall( )
	LibK.tween( easing.inQuad, self.fadeDuration, function( progress )
		panel:SetPos( 0, amountToScroll * ( 1 - progress ) )
		panel:SetAlpha( 255 * progress )
	end )
	:Done( function( )
		table.insert( self.panels, 1, panel ) --Enqueue
		self.scrollingPanel = nil
		
		--Fade out when lifetime expired
		timer.Simple( panel._scrollLifetime, function( )
			local size = panel:GetTall( )
			LibK.tween( easing.outQuad, self.fadeDuration, function( progress )
				panel:SetAlpha( 255 * ( 1 - progress ) )
				panel:SetTall( size * ( 1 - progress ) )
			end )
			:Done( function( )
				panel:Remove( )
				for k, v in pairs( self.panels ) do 
					if v == panel then
						self.panels[k] = nil
					end
				end
			end )
		end )
	end )
end

function PANEL:PerformLayout( )
	local yPos = 0
	if IsValid( self.scrollingPanel ) then
		local x, y = self.scrollingPanel:GetPos( )
		yPos = y + self.scrollingPanel:GetTall( )
	end
	
	for k, panel in pairs( self.panels ) do
		local x, y = panel:GetPos( )
		panel:SetPos( x, yPos )
		yPos = yPos + self.spaceY + panel:GetTall( )
	end
end

function PANEL:AddNotify( pnl, lifetime )
	lifetime = lifetime or 3
	pnl._scrollLifetime = lifetime
	pnl:SetVisible( false )
	table.insert( self.panelsWaiting, pnl )
end

function PANEL:AddPointNotification( text, points, small )
	local panel = vgui.Create( "DLabel" )
	
	local message = string.upper( text ) .. " " .. points
	if points > 0 then
		message = string.upper( text ) .. " +" .. points
	end
	
	panel:SetText( message )
	panel:SetContentAlignment( 6 )
	panel:SetSkin( Pointshop2.Config.DermaSkin )
	if small then
		panel:SetFont( panel:GetSkin().fontName )
	else
		panel:SetFont( panel:GetSkin().SmallTitleFont )
	end
	panel:SizeToContents( )
	panel:SetColor( color_white )
	
	self:AddNotify( panel )
	self:PointsAdded( points )
end

function PANEL:Paint( w, h )

end

vgui.Register( 'DPointFeed', PANEL, "DPanel" )