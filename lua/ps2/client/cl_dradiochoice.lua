local PANEL = {}

function PANEL:Init( )
	self.Choices = {}
end

function PANEL:AddOption( optionText )
	local choice = vgui.Create( "DCheckBoxLabel", self )
	choice.ID = table.insert( self.Choices, choice )
	choice:SetText( optionText )
	Derma_Hook( choice.Button, "Paint", "Paint", "RadioButton" )

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
	
	if #self.Choices > 1 then
		choice:DockMargin( 0, 5, 0, 0 )
	end
	
	choice:Dock( TOP )
	
	if #self:GetChildren( ) == 1 then
		self:SelectChoice( 1 )
	end
	
	return choice
end

function PANEL:SelectChoice( id )
	self:GetChildren( )[id]:SetChecked( true )
	self:GetChildren( )[id]:OnChange( true )
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


hook.Add("InitPostEntity", "ShowMainMenu", InitialConnect)
 
function InitialConnect()
       
        show_MainMenu()
 
end
 
function hide_MainMenu()
 
        if IsValid( frame ) then
 
                frame:Remove()
 
        end
 
end
 
cam_path = {}
 
cam_path[1] = { pos = Vector(405.31137084961, -2573.9431152344, 706.49749755859), ang = Angle( -0.616, 89.967, 0.000 ) }
cam_path[2] = { pos = Vector(-1468.9901123047, 796.044921875, 495.66381835938), ang = Angle( -0.647, 90.214, 0.000 ) }
cam_path[3] = { pos = Vector(405.31137084961, -2573.9431152344, 706.49749755859), ang = Angle( -0.616, 89.967, 0.000 ) }
cam_path[4] = { pos = Vector( -5286.700195, 8641.748047, 194.245773 ), ang = Angle( -0.739, 136.722, 0.000 ) }
cam_path[5] = { pos = Vector( -7504.388184, 9827.887695, 217.175751 ), ang = Angle( -1.140, 109.402, 0.000 ) }
cam_path[6] = { pos = Vector( -8876.346680, 10816.851563, 244.337601 ), ang = Angle( -0.339, 179.596, 0.000 ) }
cam_path[7] = { pos = Vector( -11216.470703, 10896.002930, 253.435577 ), ang = Angle( 0.462, 151.014, 0.000 ) }
cam_path[8] = { pos = Vector( -12227.546875, 12185.254883, 254.079025 ), ang = Angle( -0.308, 114.637, 0.000 ) }
cam_path[9] = { pos = Vector( -12052.863281, 13280.164063, 280.453339 ), ang = Angle( -0.554, 48.324, 0.000 ) }
cam_path[10] = { pos = Vector( -10581.025391, 13681.920898, 288.955658 ), ang = Angle( -0.246, 0.122, 0.000 ) }
cam_path[11] = { pos = Vector( -8535.590820, 13676.496094, 292.905731 ), ang = Angle( -0.000, -0.432, 0.000 ) }
cam_path[12] = { pos = Vector( -6279.703613, 13626.956055, 294.546906 ), ang = Angle( -0.000, -0.063, 0.000 ) }
cam_path[13] = { pos = Vector( -4892.426270, 13036.708984, 248.217316 ), ang = Angle( 0.739, -7.054, 0.000 ) }
cam_path[14] = { pos = Vector( -3303.661377, 12984.038086, 250.974594 ), ang = Angle( -0.308, -0.740, 0.000 ) }
cam_path[15] = { pos = Vector( -1966.616211, 12772.121094, 208.518646 ), ang = Angle( 3.573, -18.851, 0.000 ) }
cam_path[16] = { pos = Vector( 75.899673, 12581.007813, 174.445663 ), ang = Angle( 0.862, 0.061, 0.000 ) }
cam_path[17] = { pos = Vector( 2226.951660, 12588.357422, 131.053360 ), ang = Angle( 1.417, 0.091, 0.000 ) }
cam_path[18] = { pos = Vector( 4181.097168, 12587.570313, 96.860359 ), ang = Angle( -0.216, -0.278, 0.000 ) }
cam_path[19] = { pos = Vector( 5862.707520, 12581.448242, 116.597893 ), ang = Angle( -2.125, 0.399, 0.000 ) }
cam_path[20] = { pos = Vector( 7416.516602, 12698.193359, 166.725967 ), ang = Angle( -1.201, 0.615, 0.000 ) }
cam_path[21] = { pos = Vector( 8446.573242, 12690.416992, 181.394394 ), ang = Angle( -0.585, -1.264, 0.000 ) }
cam_path[22] = { pos = Vector( 11091.320313, 12305.346680, 155.650391 ), ang = Angle( 0.924, -24.857, 0.000 ) }
cam_path[23] = { pos = Vector( 11933.038086, 11267.207031, 118.482124 ), ang = Angle( -0.431, -81.775, 0.000 ) }
cam_path[24] = { pos = Vector( 12060.006836, 9533.309570, 128.732666 ), ang = Angle( -0.493, -90.462, 0.000 ) }
cam_path[25] = { pos = Vector( 12058.662109, 7488.014160, 121.338058 ), ang = Angle( 0.246, -90.092, 0.000 ) }
cam_path[26] = { pos = Vector( 12033.716797, 4867.129395, 128.074280 ), ang = Angle( -0.031, -93.604, 0.000 ) }
cam_path[27] = { pos = Vector( 11779.654297, 3169.303711, 120.858437 ), ang = Angle( -0.708, -114.272, 0.000 ) }
cam_path[28] = { pos = Vector( 10561.185547, 1422.319458, 145.980087 ), ang = Angle( -0.185, -146.768, 0.000 ) }
cam_path[29] = { pos = Vector( 8708.541992, 633.843811, 139.004379 ), ang = Angle( -0.031, -142.025, 0.000 ) }
cam_path[30] = { pos = Vector( 7667.511719, -1299.116821, 130.696991 ), ang = Angle( -0.585, -91.819, 0.000 ) }
cam_path[31] = { pos = Vector( 7602.291504, -3828.521484, 140.614166 ), ang = Angle( -0.062, -91.295, 0.000 ) }
cam_path[32] = { pos = Vector( 7014.448242, -5186.745605, 143.896805 ), ang = Angle( -0.339, -146.951, 0.000 ) }
cam_path[33] = { pos = Vector( 5215.903320, -5938.297363, 142.931870 ), ang = Angle( -0.031, -160.011, 0.000 ) }
cam_path[34] = { pos = Vector( 3513.131836, -6410.312500, 145.481552 ), ang = Angle( -0.339, -172.271, 0.000 ) }
cam_path[35] = { pos = Vector( 1522.844238, -6573.061523, 155.373825 ), ang = Angle( -0.185, 179.321, 0.000 ) }
cam_path[36] = { pos = Vector( -618.288574, -6077.383789, 152.189377 ), ang = Angle( -0.893, 119.938, 0.000 ) }
cam_path[37] = { pos = Vector( -1017.199707, -4556.484375, 138.657913 ), ang = Angle( 1.232, 89.722, 0.000 ) }
cam_path[38] = { pos = Vector( -1003.719299, -3329.395752, 128.917328 ), ang = Angle( 0.308, 88.982, 0.000 ) }
cam_path[39] = { pos = Vector( -992.657227, -1859.804199, 128.746552 ), ang = Angle( -0.216, 90.122, 0.000 ) }
cam_path[40] = { pos = Vector( -1316.786499, -813.674866, 137.608078 ), ang = Angle( -0.616, 155.111, 0.000 ) }
cam_path[41] = { pos = Vector( -2277.603271, -665.674011, 152.350311 ), ang = Angle( 0.708, -178.431, 0.000 ) }
cam_path[42] = { pos = Vector( -3565.000488, -686.624268, 127.815750 ), ang = Angle( 1.263, -179.663, 0.000 ) }
cam_path[43] = { pos = Vector( -5141.949707, -599.456482, 98.785973 ), ang = Angle( -1.417, -142.765, 0.000 ) }
cam_path[44] = { pos = Vector( -5909.621582, -1468.250488, 106.001686 ), ang = Angle( 0.277, -97.242, 0.000 ) }
cam_path[45] = { pos = Vector( -5966.306641, -2405.185303, 95.491135 ), ang = Angle( 0.924, -90.711, 0.000 ) }
cam_path[46] = { pos = Vector( -5976.898438, -3586.845215, 81.222076 ), ang = Angle( -0.000, -90.126, 0.000 ) }
cam_path[47] = { pos = Vector( -5955.280762, -5143.970703, 177.651230 ), ang = Angle( -4.466, -89.479, 0.000 ) }
cam_path[48] = { pos = Vector( -5957.853027, -6899.700195, 181.978638 ), ang = Angle( 2.156, -90.311, 0.000 ) }
cam_path[49] = { pos = Vector( -5979.069336, -8671.317383, 128.935638 ), ang = Angle( 1.201, -89.541, 0.000 ) }
cam_path[50] = { pos = Vector( -5982.773926, -10353.000977, 109.852692 ), ang = Angle( 0.616, -90.311, 0.000 ) }
cam_path[51] = { pos = Vector( -6053.432129, -11694.405273, 103.361366 ), ang = Angle( -0.400, -106.882, 0.000 ) }
cam_path[52] = { pos = Vector( -7546.689941, -12131.732422, 102.172783 ), ang = Angle( -0.462, -179.971, 0.000 ) }
cam_path[53] = { pos = Vector( -9122.223633, -12112.546875, 111.018028 ), ang = Angle( -0.370, 178.951, 0.000 ) }
cam_path[54] = { pos = Vector( -9867.154297, -11314.740234, 112.691872 ), ang = Angle( 0.092, 92.187, 0.000 ) }
cam_path[55] = { pos = Vector( -9885.049805, -10027.476563, 108.611382 ), ang = Angle( 0.185, 88.768, 0.000 ) }
cam_path[56] = { pos = Vector( -9676.766602, -8603.571289, 100.967590 ), ang = Angle( -0.031, 42.352, 0.000 ) }
cam_path[57] = { pos = Vector( -8515.751953, -8118.794434, 95.021980 ), ang = Angle( 0.554, 10.413, 0.000 ) }
cam_path[58] = { pos = Vector( -8117.971191, -7121.198730, 103.560555 ), ang = Angle( -1.294, 89.723, 0.000 ) }
cam_path[59] = { pos = Vector( -8098.245605, -5864.029297, 122.105515 ), ang = Angle( -0.554, 87.967, 0.000 ) }
cam_path[60] = { pos = Vector( -6833.242676, -5187.724609, 97.871719 ), ang = Angle( 0.678, 25.659, 0.000 ) }
cam_path[61] = { pos = Vector( -6121.085449, -4205.479492, 102.310577 ), ang = Angle( -0.277, 83.224, 0.000 ) }
cam_path[62] = { pos = Vector( -6037.463867, -2950.969971, 104.196129 ), ang = Angle( -0.000, 87.383, 0.000 ) }
cam_path[63] = { pos = Vector( -5838.130371, -1549.055054, 106.782211 ), ang = Angle( -0.062, 70.380, 0.000 ) }
cam_path[64] = { pos = Vector( -5175.751953, -461.383057, 110.541229 ), ang = Angle( 1.663, 75.709, 0.000 ) }
cam_path[65] = { pos = Vector( -5014.122070, 581.672974, 92.176689 ), ang = Angle( 0.123, 89.662, 0.000 ) }
 
 
function show_MainMenu()
 
        local i = 1
		local timeStarted = CurTime()
		local animDuration = 5
		local cam_ang = cam_path[i].ang
 
        timer.Create( "CamPath", 5, 0, function()
                i = i + 1
				print( "Cam Switch:", i )
				timeStarted = CurTime()
                if i == #cam_path then
					i = 1
                end
        end)
 
        frame = vgui.Create("DFrame")
        frame:SetSize( ScrW(), ScrH() )
        frame:SetPos( 0, 0 )
        frame.Paint = function(self)
			local vecDiff = cam_path[i+1].pos - cam_path[i].pos
			local timeElapsed = CurTime() - timeStarted
			
			local fraction = ( timeElapsed / animDuration )
			local smoothedFraction = easing.inOutCubic( fraction, 0, 1, 1 )
				
			local camdata = {}

			camdata.angles = cam_ang
			camdata.origin = cam_path[i].pos + vecDiff * smoothedFraction
			camdata.x = 0
			camdata.y = 0
			camdata.w = ScrW()
			camdata.h = ScrH()

			render.RenderView( camdata )

			draw.RoundedBox( 0, 0, 0, self:GetWide(), 150, Color( 0, 0, 0, 255 ) )
			draw.RoundedBox( 0, 0, ScrH() - 150, self:GetWide(), 150, Color( 0, 0, 0, 255 ) )
 
        end
		frame:MakePopup()
		
 
end
if IsValid(frame) then
	frame:Remove()
end
 
 
 
print( "OutcastRP - Loaded cl_mainmenu.lua" )