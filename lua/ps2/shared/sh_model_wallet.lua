Pointshop2.Wallet = class( "Pointshop2.Wallet" )
local Wallet = Pointshop2.Wallet 

Wallet.static.DB = "Pointshop2"

Wallet.static.model = {
	tableName = "ps2_wallet",
	fields = {
		ownerId = "int",
		points = "int",
		premiumPoints = "int"
	},
	belongsTo = {
		Owner = {
			class = "KPlayer",
			foreignKey = "ownerId",
			onDelete = "CASCADE"
		}
	}
}

Wallet:include( DatabaseModel )