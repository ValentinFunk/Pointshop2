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

	self.textSize = vgui.Create( "DNumberWang" )
    local pnl = self:addFormItem( "Text Size", self.textSize )
	self.textSize:SetValue( 10 )

    self.rainbowCheckbox = vgui.Create( "DCheckBoxLabel", self )
	local pnl = self:addFormItem( "Rainbox Color", self.rainbowCheckbox )


    local colorsPanel = vgui.Create( "DPanel", self )
    colorsPanel:Dock( TOP )
    colorsPanel:SetTall( 150 )
    colorsPanel.Paint = function( ) end

    colorsPanel.left = vgui.Create( "DPanel", colorsPanel )
    colorsPanel.left:DockPadding( 5, 5, 5, 5 )
    colorsPanel.left:Dock( LEFT )
    colorsPanel.left.Paint = function( ) end

    colorsPanel.right = vgui.Create( "DPanel", colorsPanel )
    colorsPanel.right:DockPadding( 5, 5, 5, 5 )
    colorsPanel.right:Dock( RIGHT )
    colorsPanel.right.Paint = function( ) end

    function colorsPanel:PerformLayout( )
        self.left:SetWide( self:GetWide( ) / 2 )
        self.right:SetWide( self:GetWide( ) / 2 )
    end

    local lbl = vgui.Create( "DLabel", colorsPanel.left )
    lbl:Dock( TOP )
    lbl:SetText( "Text Color" )

    self.colorPicker = vgui.Create( "DColorMixer", colorsPanel.left )
    self.colorPicker:SetPalette( false )
    self.colorPicker:SetWangs( false )
    self.colorPicker:SetAlphaBar( false )
    self.colorPicker:Dock( FILL )
    function self.colorPicker.OnColorPicked( _self, color )
        self.color = color
        self:UpdatePreview( )
    end

    local lbl = vgui.Create( "DLabel", colorsPanel.right )
    lbl:Dock( TOP )
    lbl:SetText( "Outline Color" )

    self.colorPickerOutline = vgui.Create( "DColorMixer", colorsPanel.right )
    self.colorPickerOutline:SetPalette( false )
    self.colorPickerOutline:SetWangs( false )
    self.colorPickerOutline:SetAlphaBar( false )
    self.colorPickerOutline:Dock( FILL )
    function self.colorPicker.OnColorPicked( _self, color )
        self.outlineColor = outlineColor
        self:UpdatePreview( )
    end

    local preview = vgui.Create( "DPanel", self )
    preview:Dock( TOP )
    preview:SetContentAlignment( 5 )
	preview:SetTall( 35 )
    function preview.Paint( _self, w, h )
		derma.SkinHook( "Paint", "InnerPanel", _self, w, h )
        draw.SimpleTextOutlined( "Preview Text", self:GetSkin().TabFont, w / 2, h / 2, self.colorPicker:GetColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, self.colorPickerOutline:GetColor( ) )
    end
end

function PANEL:Think( )
	if self.rainbowCheckbox:GetChecked( ) then
		self.colorPicker:SetColor( HSVToColor( RealTime( ) * 40 % 360, 1, 1 ) )
	end
end

function PANEL:UpdatePreview( )

end

function PANEL:Validate( saveTable )
    -- There are default values for everything so no need to validate
	return true
end

function PANEL:SaveItem( saveTable )
    saveTable.rainbow = self.rainbowCheckbox:GetChecked( )
    saveTable.color = self.colorPicker:GetColor( )
    saveTable.outlineColor = self.colorPickerOutline:GetColor( )
	saveTable.size = 0.0275 * self.textSize:GetValue( )
end

function PANEL:EditItem( persistence, itemClass )
    self.rainbowCheckbox:SetChecked( persistence.rainbow )
    self.colorPicker:SetColor( persistence.color )
    self.colorPickerOutline:SetColor( persistence.outlineColor )
	self.textSize:SetValue( persistence.size / 0.0275 )
end

function PANEL:Paint( )
end

vgui.Register( "DTextHatCreator_TextStage", PANEL, "DItemCreator_Stage" )
