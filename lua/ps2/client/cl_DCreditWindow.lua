local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Pointshop 2 Credits" )

	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	self.scroll:GetCanvas( ):SetTall( 2000000 )

	self:SetSize( 500, 500 )
	self:Center( )

	hook.Run( "PS2_PopulateCredits", self )
end

function PANEL:AddCreditSection( title, text )
	local panel = vgui.Create( "DInfoPanelHTML", self.scroll )
	panel:Dock( TOP )
	panel:SetInfo( title, text, "pointshop2/favourite2.png" )
	panel:DockMargin( 5, 10, 10, 10 )

end

vgui.Register( "DCreditWindow", PANEL, "DFrame" )

hook.Add( "PS2_PopulateCredits", "AddIconCredits", function( panel )
	panel:AddCreditSection( "Pointshop 2", [[
Pointshop 2 designed & scripted with <3 by Kamshak.

The script wouldn't be possible without the help of many people. Thanks go to:

The CyberGmod community, especially Dazzaoh, STEEZE, Phoenixf129 and Reuben. Thank you for hosting the test server and the help with testing and the script and crunching bugs. Special thanks for the generous donation of the PAC items included. Many thanks go to GRiiM for making the nice banner!

NiandraLades for pointshop 2 exclusive trails and allowing the inclusion of her numerous trail Packs and her kind help with writing documentation.

!cake for his remarkable work with GLib, a technical tool that is used throughout the script and makes it possible to handle large amounts of data very efficiently.

MDave for his help on complex questions, especially on topics such as stencils.

adamburton aka _Undefined for the original pointshop script

CapsAdmin for PAC3, which is used to provide the advanced hat/accessory positioning editor and the rendering of advanced items, as well as ludata

Vercas for vON, the flexible lua serializer

Lexic for the creation of the lua Promises system used throughout the script to provide non-blocking, blazing fast mysql queries

To the server/community owners for sharing their experience with pointshop and giving great input on how to improve
	]] )

	panel:AddCreditSection( "Icons", Pointshop2.IconCredits )
end )

Pointshop2.IconCredits = [[
 materials/pointshop2/actualize.png
Icon made by Yannick from flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/advanced.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/briefcase3.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/category1.png
Icon made by Picol.org from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/category2.png
Icon made by Picol.org from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/cowboy5.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/crime1.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/dollar103.png
Icon made by SimpleIcon.com from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/donation.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/edit21.png
Icon made by Picol.org from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/fedora.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/floppy1.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/folder62.png
Icon made by Iconmoon.io from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/hand129.png
Icon made by Icons8 from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/magnifier12.png
Icon made by SimpleIcon.com from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/pencil54.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/plus24.png
Icon made by Iconmoon.io from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/settings12.png
Icon made by Picol.org from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/small43.png
Icon made by Adam Whitcroft from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/transfer.png
Icon made by Adam Whitcroft from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/user48.png
Icon made by Picol.org from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/winner2.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/wizard.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/info20.png
Icon made by Icons8 from www.flaticon.com under http://creativecommons.org/licenses/by/3.0/

materials/pointshop2/rack1.png
Icon made by Freepik.com from www.flaticon.com

materials/pointshop2/clock125.png
Icon made by Freepik.com from www.flaticon.com

All other items made by Freepik.com from www.flaticon.com under Flaticon Basic License (http://cdn.flaticon.com/license/license.pdf)
]]
