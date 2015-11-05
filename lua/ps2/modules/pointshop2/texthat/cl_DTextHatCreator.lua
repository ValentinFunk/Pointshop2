local PANEL = {}

function PANEL:Init( )
	self.modelAndPositioningPanel = vgui.Create( "DTextHatCreator_TextStage" )
	self.stepsPanel:AddStep( "Hat Settings", self.modelAndPositioningPanel )
end

vgui.Register( "DTextHatCreator", PANEL, "DItemCreator_Steps" )

local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

    self.color = Color( 255, 0, 0 )
    self.colorOutline = color_white

    self.rainbowCheckbox = vgui.Create( "DCheckBoxLabel", self )
    self.rainbowCheckbox:Dock( TOP )

    local colorsPanel = vgui.Create( "DPanel", self )
    colorsPanel:Dock( TOP )

    colorsPanel.left = vgui.Create( "DPanel", colorsPanel )
    colorsPanel.left:DockPadding( 5, 5, 5, 5 )
    colorsPanel.left:Dock( LEFT )

    colorsPanel.right = vgui.Create( "DPanel", colorsPanel )
    colorsPanel.right:DockPadding( 5, 5, 5, 5 )
    colorsPanel.right:Dock( RIGHT )

    function colorsPanel:PerformLayout( )
        self.left:SetWide( self:GetWide( ) / 2 )
        self.right:SetWide( self:GetWide( ) / 2 )
    end

    self.colorPicker = vgui.Create( "DFormColorPicker", colorsPanel.left )
    function self.colorPicker.OnColorPicked( _self, color )
        self.color = color
        self:UpdatePreview( )
    end

    self.colorPickerOutline = vgui.Create( "DFormColorPicker", colorsPanel.left )
    function self.colorPicker.OnColorPicked( _self, color )
        self.outlineColor = outlineColor
        self:UpdatePreview( )
    end

    self:addFormItem( )
end

function PANEL:UpdatePreview( )

end

function PANEL:Validate( saveTable )
    -- There are default values for everything so no need to validate
	return true
end

function PANEL:SaveItem( saveTable )
    saveTable.rainbow = self.rainbowCheckbox:GetValue( )
    saveTable.color = self.colorPicker:GetColor( )
    saveTable.outlineColor = self.colorPickerOutline:GetColor( )
end

function PANEL:EditItem( persistence, itemClass )
    self.rainbowCheckbox:SetChecked( persistence.rainbow )
    self.colorPicker:SetColor( persistence.color )
    self.colorPickerOutline:SetColor( persistence.outlineColor )
end

function PANEL:Paint( )
end

vgui.Register( "DTextHatCreator_TextStage", PANEL, "DItemCreator_Stage" )
