local PANEL = {}

function PANEL:Init( )
	self.Choices = {}
end

function PANEL:AddOption( optionText )
	local choice = vgui.Create( "DCheckBoxLabel", self )
	choice.ID = table.insert( self.Choices, choice )
	choice:SetText( optionText )
	Derma_Hook( PANEL, "Paint", "Paint", "RadioButton" )

	function choice.OnChange( pnl, val )
		self:ChoiceSelected( pnl, val )
	end
	
	local setValue = choice.Button.SetValue
	function choice.Button.SetValue( btn, value )
		if self:GetSelectedOption( ) and self:GetSelectedOption( ).Button == btn then
			if not value then
				return 
			end
		end
		setValue( btn, value )
	end
	
	choice:Dock( TOP )
	
	if #self:GetChildren( ) == 1 then
		self:SelectChoice( 1 )
	end
end

function PANEL:SelectChoice( id )
	self:GetChildren( )[id]:SetChecked( true )
end

function PANEL:ChoiceSelected( pnl, val )
	if val == false then return end
	
	for k, v in pairs( self.Choices ) do
		if not IsValid( v ) then continue end 
		
		if v == pnl then 
			continue
		end
		
		v:SetChecked( false )
	end
	self:OnChange( )
end

function PANEL:OnChange( )
	--for override
end

function PANEL:GetSelectedOption( )
	for k, v in pairs( self:GetChildren( ) ) do
		if v:GetChecked( ) then
			return v
		end
	end
end

function PANEL:Paint( )
end

derma.DefineControl( "DRadioChoice", "", PANEL, "DPanel" )