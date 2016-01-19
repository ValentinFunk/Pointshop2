local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.itemTable = vgui.Create( "DListView", self )
	self.itemTable:Dock( FILL )
	self.itemTable:SetMultiSelect( false )
	self.itemTable:AddColumn( "Day" ):SetMaxWidth( 30 )
	self.itemTable:AddColumn( "Item" )
	self.itemTable:AddColumn( "Actions" ):SetMaxWidth( 160 )
	self.itemTable:SetDataHeight( 30 )

	self.bottomBar = vgui.Create( "DPanel", self )
	self.bottomBar:Dock( BOTTOM )
	self.bottomBar:DockMargin( 0, 5, 0, 0 )
	self.bottomBar.Paint = function() end
	self.bottomBar:SetTall( 40 )
end

function PANEL:InitDays( days )
	self.lines = {}
	for i = 1, days do
		local line = self.itemTable:AddLine( i )
		line.day = i
		line.Columns[3] = self:GenerateActionsControl( line )
		self.lines[i] = line
	end
	self.lineCount = days
end

function PANEL:GenerateActionsControl( line )
	local pnl = vgui.Create( "DPanel", line )
	pnl:DockPadding( 10, 3, 10, 3 )

	local _self = self
	function pnl:Refresh( )
		for k, v in pairs( self:GetChildren( ) ) do
			v:Remove( )
		end

		if line.factory then
			pnl.edit = vgui.Create( "DButton", pnl )
			pnl.edit:SetText( "Configure" )
			function pnl.edit.DoClick( )
				local frame = vgui.Create( "DFrame" )
				frame:SetSize( 800, math.Clamp( ScrH( ), 0, 768 ) )
				frame:SetTitle( "Edit Settings" )
				frame:SetSkin( Pointshop2.Config.DermaSkin )

				local ctrl = vgui.Create( line.factory:GetConfiguratorControl( ), frame )
				ctrl:Dock( FILL )
				ctrl:Edit( line.factory:GetLoadedSettings( ) )

				frame.save = vgui.Create( "DButton", frame )
				frame.save:Dock( BOTTOM )
				frame.save:SetText( "Save" )
				function frame.save.DoClick( )
					if not ctrl:GetSettingsForSave( ) then return end

					line.factory.settings = ctrl:GetSettingsForSave( )
					line.Columns[2]:SetText( line.factory:GetShortDesc( ) )
					frame:Remove( )
				end
				frame:MakePopup( )
				frame:Center( )
			end
			pnl.edit:Dock( LEFT )

			pnl.remove = vgui.Create( "DButton", pnl )
			pnl.remove:SetText( "Reset" )
			function pnl.remove.DoClick( )
				line.Columns[2]:SetText( "" )

				line.factory = nil
				pnl:Refresh( )
			end
			pnl.remove:Dock( LEFT )
			pnl.remove:DockMargin ( 5, 0, 0, 0 )
		else
			pnl.add = vgui.Create( "DButton", pnl )
			pnl.add:SetText( "Set Item" )
			pnl.add:Dock( FILL )
			function pnl.add.DoClick( )
				local frame = vgui.Create( "DItemFactoryConfigurationFrame" )
				frame:MakePopup( )
				frame:Center( )
				function frame.OnFinish( frame, class, settings )
					if not settings then return end
					frame:Remove( )

					_self:SetFactory( line, class, settings )
				end
			end
		end
	end
	pnl:Refresh( )

	return pnl
end

function PANEL:SetFactory( line, factoryClass, settings )
	local instance = factoryClass:new( )
	instance.settings = settings
	line.factory = instance

	line.Columns[2]:SetText( instance:GetShortDesc( ) )
	line.Columns[3]:Refresh( )

	if not line.factory:IsValid( ) then
		line.Paint = function( p, w, h )
			surface.SetDrawColor( 255, 0, 0 )
			surface.DrawRect( 0, 0, w, h )
		end
		line:SetTooltip( "WARNING: The factory is not valid. Please remove it!" )
	end
end

function PANEL:GetSaveData( )
	local data = { }
	for i = 1, self.lineCount do
		local line = self.lines[i]
		if not line.factory then
			continue
		end

		data[i] = {
			factoryClassName = line.factory.class.name,
			factorySettings = line.factory.settings,
		}
	end
	return data
end

function PANEL:LoadSaveData( data )
	for day, v in pairs( data ) do
		local factoryClass = getClass( v.factoryClassName )
		if not factoryClass then
			KLogf( 3, "[ERROR] Invalid factory class %s", tostring( v.factoryClassName ) )
			continue
		end

		self:SetFactory( self.lines[day], factoryClass, v.factorySettings )
	end
end

function PANEL:Paint( )

end

vgui.Register( "DCalendarItemPicker", PANEL, "DPanel" )
