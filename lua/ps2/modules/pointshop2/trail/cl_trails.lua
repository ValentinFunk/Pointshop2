local callback
function Pointshop2.RequestServerTrails( onReceived )
	callback = onReceived
	net.Start( "RequestServerTrails" )
	net.SendToServer( )
end

net.Receive( "RequestServerTrails", function( )
	local trails = net.ReadTable( )
	print( "Got ", #trails )
	callback( trails )
end )