local function genericDelete( panels )
	local menu = DermaMenu( )
	menu:SetSkin( Pointshop2.Config.DermaSkin )
	local btn = menu:AddOption( "Delete", function( )
		Derma_Query( "Do you really want to permanently remove " .. #panels .. " items?", "Confirm",
			/*"Yes and refund players", function( )
				Pointshop2View:getInstance( ):removeItem( itemClass, true )
			end,*/
			"Yes", function( )
				local toRemove = {}
				for k, v in pairs( panels ) do
					local itemClass = v:GetItemClass( )

					local persistence = Pointshop2View:getInstance( ):getPersistenceForClass( itemClass )
					if persistence == "STATIC" then
						Derma_Message( "The Item " .. itemClass.PrintName .. " is Lua defined and cannot be deleted ingame. To delete it remove " .. itemClass.originFilePath, "Info" )
						continue
					end

					table.insert( toRemove, itemClass )
				end
				Pointshop2View:getInstance( ):removeItems( toRemove )
			end,
			"No", function( )
			end
		)
	end )
	btn:SetImage( "pointshop2/cross66.png" )
	btn.m_Image:SetSize( 16, 16 )

	local btn = menu:AddOption( "Restrict Server", function( )
		local frame = vgui.Create( "DSelectServers" )
		frame:MakePopup( )
		frame:Center( )
		function frame.OnSave( )
			local itemClassNames = {}
			for k, v in pairs( panels ) do
				local itemClass = v:GetItemClass( )

				local persistence = Pointshop2View:getInstance( ):getPersistenceForClass( itemClass )
				if persistence == "STATIC" then
					Derma_Message( "The Item " .. itemClass.PrintName .. " is Lua defined and cannot be modified ingame. To modify it edit " .. itemClass.originFilePath, "Info" )
					continue
				end

				table.insert( itemClassNames, itemClass.className )
			end
			local validServers = frame:GetSelectedIds( )
			Pointshop2View:getInstance( ):updateServerRestrictions( itemClassNames, validServers )
		end
	end )
	btn:SetImage( "pointshop2/rack1.png" )
	btn.m_Image:SetSize( 16, 16 )

	local btn = menu:AddOption( "Restrict Ranks", function( )
		local frame = vgui.Create( "DSelectRanks" )
		frame:MakePopup( )
		frame:Center( )
		function frame.OnSave( )
			local itemClassNames = {}
			for k, v in pairs( panels ) do
				local itemClass = v:GetItemClass( )

				local persistence = Pointshop2View:getInstance( ):getPersistenceForClass( itemClass )
				if persistence == "STATIC" then
					Derma_Message( "The Item " .. itemClass.PrintName .. " is Lua defined and cannot be modified ingame. To modify it edit " .. itemClass.originFilePath, "Info" )
					continue
				end

				table.insert( itemClassNames, itemClass.className )
			end

			local validRanks = frame:GetSelectedRanks( )
			Pointshop2View:getInstance( ):updateRankRestrictions( itemClassNames, validRanks )
		end
	end )
	btn:SetImage( "pointshop2/sign.png" )
	btn.m_Image:SetSize( 16, 16 )

	menu:Open( )
end

hook.Add( "PS2_MultiItemSelectOpenMenu", "AddDeleteMenu", function( panels )
	genericDelete( panels )
end )
