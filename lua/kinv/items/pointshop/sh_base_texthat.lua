ITEM.baseClass	= "base_hat"
ITEM.PrintName	= "Texthat"
ITEM.Description = "The texthat"

ITEM.static.validSlots = {
	"Hat",
}

function ITEM.static.getOutfitForModel( model )
	return {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
						[1] = {
							["children"] = {
							},
							["self"] = {
								["Max"] = 360,
								["UniqueID"] = "4150845444",
								["Hide"] = true,
								["Name"] = "rainbow",
								["VariableName"] = "Color",
								["ClassName"] = "proxy",
								["InputDivider"] = 0.4,
								["InputMultiplier"] = 1.8,
								["Expression"] = "hsv_to_color(time() *20 % 360, 1, 1)",
							},
						},
					},
					["self"] = {
						["Outline"] = 1,
						["UniqueID"] = "3494032761",
						["Name"] = "Hello",
						["EditorExpand"] = true,
						["Position"] = Vector(14.734375, -0.2509765625, -0.0009765625),
						["ClassName"] = "text",
						["Size"] = 0.275,
						["Font"] = "DermaLarge",
						["Color"] = Vector(0, 255, 254),
						["OutlineColor"] = Vector(0, 0, 0),
						["Angles"] = Angle(90, -82.253997802734, 5.1226412324468e-005),
						["Text"] = "Customize this Text",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "3385648173",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},
	}
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	Pointshop2.Items.base_pointshop_item.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )

	itemTable.color = persistenceItem.color
	itemTable.outlineColor = persistenceItem.outlineColor
	itemTable.rainbow = persistenceItem.rainbow
	itemTable.size = persistenceItem.size

	itemTable.baseOutfit = {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
						[1] = {
							["children"] = {
							},
							["self"] = {
								["Max"] = 360,
								["UniqueID"] = "4150845444",
								["Hide"] = itemTable.rainbow,
								["Name"] = "rainbow",
								["VariableName"] = "Color",
								["ClassName"] = "proxy",
								["InputDivider"] = 0.4,
								["InputMultiplier"] = 1.8,
								["Expression"] = "hsv_to_color(time() *20 % 360, 1, 1)",
							},
						},
					},
					["self"] = {
						["Outline"] = 1,
						["UniqueID"] = "3494032761",
						["Name"] = "Hello",
						["EditorExpand"] = true,
						["Position"] = Vector(14.734375, -0.2509765625, -0.0009765625),
						["ClassName"] = "text",
						["Size"] = itemTable.size,
						["Font"] = "DermaLarge",
						["Color"] = itemTable.color,
						["OutlineColor"] = itemTable.outlineColor,
						["Angles"] = Angle(90, -82.253997802734, 5.1226412324468e-005),
						["Text"] = "Example Text",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "3385648173",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},
	}
end

function ITEM.static:GetPointshopIconControl( )
	return "DTexthatItemIcon"
end

function ITEM.static.GetPointshopDescriptionControl( )
	return "DTexthatItemDescription"
end
