local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.notifications = {}
	self.stackDirection = 8 --numpad arrows
	self.notificationsWaiting = {} --queue
	self.notifications = {}
	
	self.lblTitle = vgui.Create( "DLabel", self )
	self.lblTitle:DockMargin( 3, 3, 3, 3 )
	self.lblTitle:Dock( TOP )
	self.lblTitle:SetFont( self:GetSkin( ).TabFont )
	self.lblTitle:SetText( " Pointshop 2" )
	self.lblTitle:SetColor( color_white )
	self.lblTitle:SizeToContents( )
	self.lblTitle:SetTall( self.lblTitle:GetTall( ) + 3 )
	
	self.panelSlidingIn = false
	self.slidingStarted = 0
	self.slideInDuration = 0.5 --1/2 second
	
	--If no notifications are left, fade self out
	self.fadedOut = false
	self.fading = false
	
	self:SetZPos( 10000 )
	self:SetDrawOnTop( true )
end

function PANEL:addNotification( panel )
	table.insert( self.notificationsWaiting, panel )
	panel:SetVisible( false )
	panel:SetWide( self:GetWide( ) )
	return panel
end

function PANEL:fadeIn( )
	if not self.fading then
		self.fadeStart = CurTime( )
		self.fading = true
	end
	
	local timeElapsed = CurTime( ) - self.fadeStart
	local height = easing.inOutCubic( timeElapsed, 0, 25, self.slideInDuration / 2 )
	self:SetTall( height )
	if timeElapsed >= self.slideInDuration / 2 then
		self.fadedOut = false
		self.fading = false
		return true
	end
	return false
end

function PANEL:fadeOut( )
	if not self.fading then
		self.fadeStart = CurTime( )
		self.fading = true
	end
	local timeElapsed = CurTime( ) - self.fadeStart
	local height = easing.inOutCubic( timeElapsed, 25, -25, self.slideInDuration / 2 )
	height = math.Clamp( height, 0.01, 25 )
	self:SetTall( height )
	if timeElapsed >= self.slideInDuration / 2 then
		self.fadedOut = true
		self.fading = false
		return true
	end
	return false
end

function PANEL:Think( )
	if ( #self.notifications > 0 or #self.notificationsWaiting > 0 ) and self.fadedOut then
		if not self:fadeIn( ) then
			return
		end
	elseif #self.notifications == 0 and not self.fadedOut then
		if not self:fadeOut( ) then
			return
		end
	end
	
	if self.fadedOut then 
		return
	end
	
	if not self.panelSlidingIn and #self.notificationsWaiting > 0 then
		self.panelSlidingIn = table.remove( self.notificationsWaiting, 1 ) --Dequeue
		self.panelSlidingIn:SetParent( self )
		self.panelSlidingIn:SetVisible( true )
		if not self.panelSlidingIn.duration or not isnumber(self.panelSlidingIn.duration) then
			KLogf(2, "KNotification Manager: got duration %s", tostring(self.panelSlidingIn.duration))
			self.panelSlidingIn.duration = 15
		end
		self.panelSlidingIn.slideOutStart = CurTime( ) + self.panelSlidingIn.duration + self.slideInDuration
		self.slidingStarted = CurTime( )
		table.insert( self.notifications, self.panelSlidingIn )
		surface.PlaySound( self.panelSlidingIn.sound or "kreport/misc_menu_4.wav" )
	end
	
	if IsValid( self.panelSlidingIn ) then
		if CurTime( ) < self.slidingStarted + self.slideInDuration then
			local timeElapsed = CurTime( ) - self.slidingStarted
			local height = easing.inOutCubic( timeElapsed, 0, self.panelSlidingIn.targetHeight or 100, self.slideInDuration )
			self.panelSlidingIn:SetTall( height )
		else
			self.panelSlidingIn = nil --Sliding in done, not sliding anymore
		end
	end
	
	--Position the rest
	local y = self.lblTitle:GetTall( ) + 3
	for k, notificationPanel in pairs( self.notifications ) do
		if CurTime( ) > notificationPanel.slideOutStart then
			if CurTime( ) > notificationPanel.slideOutStart + self.slideInDuration then
				notificationPanel:Remove( )
				self.notifications[k] = nil
			else
				local timeElapsed = CurTime( ) - notificationPanel.slideOutStart
				local height = easing.inOutCubic( timeElapsed, notificationPanel.targetHeight, -notificationPanel.targetHeight, self.slideInDuration )
				notificationPanel:SetTall( height )
			end
		end
		
		y = y + 1 --a little margin
		notificationPanel:SetPos( 0, y )
		y = y + notificationPanel:GetTall( )
	end
	self:SetTall( y )
end

function PANEL:ForceSlideOut( notificationPanel )
	if notificationPanel.slideOutStart and CurTime() >= notificationPanel.slideOutStart then
		return
	end

	notificationPanel.slideOutStart = CurTime()
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

derma.DefineControl( "KNotificationManagerPanel", "Logic for drawing notifications", PANEL, "DPanel" )