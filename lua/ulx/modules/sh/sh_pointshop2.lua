if SERVER then
	ULib.ucl.registerAccess("pointshop2 manageitems", ULib.ACCESS_SUPERADMIN, "Permission to modify item categories", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 createitems", ULib.ACCESS_SUPERADMIN, "Permission to create new items", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 manageusers", ULib.ACCESS_SUPERADMIN, "Permission to manage users(give points, items)", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 managemodules", ULib.ACCESS_SUPERADMIN, "Permission to manage modules and use settings", "Pointshop 2" )
end