local PANEL = {}

function PANEL:Init( )
	local itemDesc = self
	function self.buttonsPanel:AddTexthatActions( )
        self.textEntry = vgui.Create( "DTextEntry", self )
        self.textEntry:Dock( TOP )
        self.textEntry:DockMargin( 0, 5, 0, 0 )
        self.textEntry:SetText( itemDesc.item.text or "Change Me" )
        function self.textEntry:AllowInput( strValue )
            if #strValue < 16 then
                return true
            end
            return true
        end

		self.useButton = vgui.Create( "DButton", self )
		self.useButton:SetText( "Change Text" )
		self.useButton:DockMargin( 0, 5, 0, 0 )
		self.useButton:Dock( TOP )

		function self.useButton.DoClick( )
			itemDesc.item:UserSetText( self.textEntry:GetText() )
		end
	end
end

function PANEL:SetItem( item, noButtons )
	self.BaseClass.SetItem( self, item, noButtons )
	if not noButtons then
		self.buttonsPanel:AddTexthatActions( )
	end
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
end

function PANEL:SelectionReset( )
	self.BaseClass.SelectionReset( self )
	if self.texthatPanel then
		self.texthatPanel:Remove( )
	end
end

derma.DefineControl( "DTexthatItemDescription", "", PANEL, "DPointshopItemDescription" )
