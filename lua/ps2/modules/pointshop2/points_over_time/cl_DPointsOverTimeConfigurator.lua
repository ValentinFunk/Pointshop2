local PANEL = {}

function PANEL:Init( )
	self:SetTitle( "Points over time" )
	self:SetSize( 800, 400 )
	self:Center( )
	self:DockPadding( 10, 40, 10, 10 )

	local left = vgui.Create( "DPanel", self )
	left:Dock( LEFT )
	left:SetWide( 200 )
	left.Paint = function( ) end
	--Derma_Hook( left, "Paint", "Paint", "InnerPanel" )

	self.tbl = vgui.Create( "DListView", left )
	self.tbl:SetMultiSelect( false )
	self.tbl:AddColumn( "Rank" )
	self.tbl:AddColumn( "Multiplier" )
	self.tbl:AddColumn( "Points Given" )
	self.tbl:Dock( FILL )
	function self.tbl.OnRowRightClick( tbl, id, line )
		local menu = DermaMenu()
		menu:SetSkin( Pointshop2.Config.DermaSkin )

		menu:AddOption( "Edit", function( )
			self:EditRank( line.rank, line.multiplier )
		end )

		menu:AddOption( "Remove", function( )
			self.data["PointsOverTime.GroupMultipliers"][line.rank.internalName] = nil
			self.tbl:RemoveLine( id )
		end )

		menu:Open( )
	end

	self.addBtn = vgui.Create( "DButton", left )
	self.addBtn:SetText( "Add Rank" )
	self.addBtn:Dock( BOTTOM )
	self.addBtn:SetTall( 30 )
	self.addBtn:DockMargin( 0, 5, 0, 0 )
	self.addBtn:SetImage( "pointshop2/plus24.png" )
	self.addBtn.m_Image:SetSize( 16, 16 )
	function self.addBtn.DoClick( )
		self:OpenAddRankFrame( )
	end

	local main = vgui.Create( "DPanel", self )
	main:Dock( FILL )
	main:DockMargin( 10, 0, 0, 0 )
	main.Paint = function( ) end

	self.infoPanel = vgui.Create( "DInfoPanel", main )
	self.infoPanel:Dock( TOP )
	self.infoPanel:SetInfo( "Points over Time", "This can be used to give players points over time on gamemodes without integration plugins. Each player is given the amount of points specified.\nWhen a gamemode has an integration plugin, points over time are not given. (Check 'Force Enable' to always enable Points over Time)\n\nTo give bonus points to certain ranks (e.g. donator) use the table on the left.\nA multiplier of 2 means that donators receive double the points." )
	self.infoPanel:DockMargin( 0, 0, 0, 10 )

	local panel = vgui.Create( "DPanel", main )
	panel:Dock( TOP )
	panel:DockMargin( 5, 0, 5, 5 )
	panel.Paint = function( ) end

	panel.label = vgui.Create( "DLabel", panel )
	panel.label:SetText( "Points" )
	panel.label:Dock( LEFT )
	panel.label:SetWide( 150 )

	panel.control = vgui.Create( "DNumberWang", panel )
	panel.control:Dock( LEFT )
	panel.control:SetMin( 1 )
	panel.control:SetMax( 10000 )
	function panel.control.OnValueChanged( p, value )
		self.data["PointsOverTime.Points"] = value
		self.confirmTop:SetPoints( value )
		self:OnPointsChanged( )
	end

	self.pointsPanel = panel

	local panel = vgui.Create( "DPanel", main )
	panel:Dock( TOP )
	panel:DockMargin( 5, 0, 5, 5 )
	panel.Paint = function( ) end

	panel.label = vgui.Create( "DLabel", panel )
	panel.label:SetText( "Delay in minutes" )
	panel.label:Dock( LEFT )
	panel.label:SetWide( 150 )

	panel.control = vgui.Create( "DNumberWang", panel )
	panel.control:Dock( LEFT )
	panel.control:SetMin( 1 )
	panel.control:SetMax( 60 )
	function panel.control.OnValueChanged( p, value )
		self.data["PointsOverTime.Delay"] = value
		self.confirmTop:SetDelay( value )
	end

	self.delayPanel = panel

	local forcePanel = vgui.Create( "DPanel", main )
	forcePanel:Dock( TOP )
	forcePanel:DockMargin( 5, 0, 5, 5 )
	forcePanel.Paint = function( ) end
	forcePanel:SetTooltip( "Force Points over Time regardless of gamemode" )

	forcePanel.label = vgui.Create( "DLabel", forcePanel )
	forcePanel.label:SetText( "Force Enable" )
	forcePanel.label:Dock( LEFT )
	forcePanel.label:SetWide( 150 )

	local p =  vgui.Create("DPanel", forcePanel)
	p:Dock(LEFT)
	function p:Paint() end

	forcePanel.control = vgui.Create( "DCheckBox", p )
	function forcePanel.control.OnChange( p, value )
		self.data["PointsOverTime.ForceEnable"] = value
	end

	self.forcePanel = forcePanel

	self.confirmTop = vgui.Create( "DPanel", main )
	self.confirmTop:Dock( TOP )
	self.confirmTop:DockMargin( 5, 5, 0, 0 )
	self.confirmTop.color = color_white
	self.confirmTop.font = "Default"
	function self.confirmTop:ApplySchemeSettings( )
		self.color = self:GetSkin().Highlight
		self.font = self:GetSkin().fontName
		if self.delay then
			self:Update( self.points, self.delay )
		end
	end
	function self.confirmTop:SetPoints( pts )
		self:Update( pts, self.delay )
	end
	function self.confirmTop:SetDelay( delay )
		self:Update( self.points, delay )
	end
	function self.confirmTop:Update( points, delay )
		self.points, self.delay = points, delay
		local text = Format( "<font=%s>Give <colour=%i,%i,%i,255>%i</colour> Points to Players every <colour=%i,%i,%i,255>%i</colour> minutes</font>",
			self.font,
			self.color.r, self.color.g, self.color.b,
			points,
			self.color.r, self.color.g, self.color.b,
			delay
		)
		self.parsed = markup.Parse( text )
		self:InvalidateLayout( )
	end
	function self.confirmTop:Paint( w, h )
		surface.SetDrawColor( color_black )
		if self.parsed then
			self.parsed:Draw( 0, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		end
	end
	function self.confirmTop:PerformLayout( )
		if self.parsed then
			self:SetSize( self.parsed.totalWidth, self.parsed.totalHeight )
		end
	end
	self.confirmTop:Update( 0, 0 )

	self.buttons = vgui.Create( "DPanel", main )
	self.buttons:Dock( BOTTOM )
	self.buttons:SetTall( 30 )
	self.buttons.Paint = function( ) end
	--self.buttons:DockPadding( 5, 5, 5, 5 )
	--Derma_Hook( self.buttons, "Paint", "Paint", "InnerPanel" )

	self.save = vgui.Create( "DButton", self.buttons )
	self.save:SetText( "Save" )
	self.save:SetImage( "pointshop2/floppy1.png" )
	self.save:SetWide( 180 )
	self.save.m_Image:SetSize( 16, 16 )
	self.save:Dock( RIGHT )
	function self.save.DoClick( )
		self:Save( )
	end
end

function PANEL:RankInfoUpdated( rank, multiplier )
	local line
	for k, v in pairs( self.tbl:GetLines( ) ) do
		if v.rank.internalName == rank.internalName then
			line = v
		end
	end

	if not line then
		line = self.tbl:AddLine( "", "", "" )
	end
	line.Columns[1]:SetText( rank.title )
	line.Columns[2]:SetText( multiplier )
	line.Columns[3]:SetText( multiplier * self.pointsPanel.control:GetValue( ) )

	line.multiplier = multiplier
	line.rank = rank

	self.data["PointsOverTime.GroupMultipliers"][rank.internalName] = multiplier
end

function PANEL:OnPointsChanged( )
	for k, line in pairs( self.tbl:GetLines( ) ) do
		line.Columns[3]:SetText( line.multiplier * self.pointsPanel.control:GetValue( ) )
	end
end

function PANEL:OpenAddRankFrame( )
	local frame = vgui.Create( "DPointsOverTimeConfigurator_AddRank" )
	frame:Center( )
	frame:MakePopup( )
	--frame:DoModal( )
	frame:SetSkin( Pointshop2.Config.DermaSkin )

	function frame.OnSaved( frame, rank, multiplier )
		self:RankInfoUpdated( rank, multiplier )
		frame:Remove( )
	end

	return frame
end

function PANEL:EditRank( rank, multiplier )
	local frame = self:OpenAddRankFrame( )
	frame:EditRank( rank, multiplier )
end

function PANEL:ApplySchemeSettings( )
	self.delayPanel.label:SetFont( self:GetSkin( ).fontName or "DermaDefault" )
	self.forcePanel.label:SetFont( self:GetSkin( ).fontName or "DermaDefault" )
	self.pointsPanel.label:SetFont( self:GetSkin( ).fontName or "DermaDefault" )
	self.confirmTop:Update( 0, 0 )
	self.save:SetFont( self:GetSkin( ).SmallTitleFont )
end

function PANEL:SetModule( mod )
	self.mod = mod
end

function PANEL:SetData( data )
	self.data = data
	timer.Simple( 0.01, function( )
		self.delayPanel.control:SetValue( self.data["PointsOverTime.Delay"] )
		self.pointsPanel.control:SetValue( self.data["PointsOverTime.Points"] )
		self.forcePanel.control:SetChecked( self.data["PointsOverTime.ForceEnable"] )
		self.delayPanel.control:OnChange( )
		self.pointsPanel.control:OnChange( )
	end )

	local titleLookup = {}
	for k, v in pairs( PermissionInterface.getRanks( ) ) do
		titleLookup[v.internalName] = v.title
	end
	for rankName, multiplier in pairs( self.data["PointsOverTime.GroupMultipliers"] ) do
		local rank = {
			title = titleLookup[rankName] or rankName,
			internalName = rankName
		}
		self:RankInfoUpdated( rank, multiplier )
	end
end

function PANEL:Verify( settings )
	if settings["PointsOverTime.Delay"] < 1 then
		return false, "Delay has to be greater than 1"
	end

	if settings["PointsOverTime.Points"] > 20000000 then
		return false, "Points amount is too large"
	end

	if settings["PointsOverTime.Points"] < 0 then
		return false, "Points amount need to be >0"
	end

	return true
end

function PANEL:Save( )
	local success, err = self:Verify( self.data )
	if not success then
		Derma_Message( err, "Can't save settings" )
		return
	end
	Pointshop2View:getInstance( ):saveSettings( self.mod, "Server", self.data )
	self:Remove( )
end

vgui.Register( "DPointsOverTimeConfigurator", PANEL, "DFrame" )
