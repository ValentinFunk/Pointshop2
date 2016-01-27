ITEM.baseClass	= "base_hat"
ITEM.PrintName	= "Jump Pack"
ITEM.Description = "Makes you jump higher!"
ITEM.Price = {
	points = 1000,
}

ITEM.static.validSlots = {
	"Accessory",
}

ITEM.static.iconInfo = {
	["shop"] = {
		["iconMaterial"] = "",
		["useMaterialIcon"] = false,
		["iconViewInfo"] = {
			["fov"] = 74.620961142622,
			["angles"] = Angle(27.75, 99.875, 0),
			["origin"] = Vector(-9.75, -22.46875, 57),
		},
	},
	["inv"] = {
		["iconMaterial"] = "",
		["useMaterialIcon"] = false,
		["iconViewInfo"] = {
			["fov"] = 90,
			["angles"] = Angle(48.84375, 99.875, 0),
			["origin"] = Vector(-2.71875, -22.4375, 62.84375),
		},
	},
}

function ITEM.static.getBaseOutfit( )
	return {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
						[1] = {
							["children"] = {
								[1] = {
									["children"] = {
										[1] = {
											["children"] = {
											},
											["self"] = {
												["Velocity"] = 300,
												["UniqueID"] = "492751156",
												["StickToSurface"] = false,
												["EndSize"] = 50,
												["Material"] = "particle/smokesprites_0005",
												["NumberParticles"] = 10,
												["Gravity"] = Vector(0, 0, -100),
												["Collide"] = false,
												["Position"] = Vector(0.84375, 0, 0),
												["Sliding"] = false,
												["Color1"] = Vector(200, 200, 200),
												["AlignToSurface"] = false,
												["ClassName"] = "particles",
												["Bounce"] = 10.8,
												["EditorExpand"] = true,
												["Angles"] = Angle(0, -179.4375, 0),
												["Spread"] = 0.2,
												["Lighting"] = false,
												["FireDelay"] = 0.01,
												["StartSize"] = 5,
												["PositionSpread"] = 0.1,
											},
										},
										[2] = {
											["children"] = {
											},
											["self"] = {
												["Arguments"] = "jump@@0.5",
												["UniqueID"] = "4206270507",
												["Invert"] = true,
												["Event"] = "animation_event",
												["Name"] = "jump",
												["ClassName"] = "event",
											},
										},
									},
									["self"] = {
										["Velocity"] = 300,
										["DrawOrder"] = 1,
										["UniqueID"] = "135234957",
										["StickToSurface"] = false,
										["EndSize"] = 10,
										["Material"] = "sprites/flamelet1",
										["EditorExpand"] = true,
										["StartAlpha"] = 200,
										["AirResistance"] = 4.8,
										["StartSize"] = 5,
										["Collide"] = false,
										["Position"] = Vector(0.84375, 0, 0),
										["Sliding"] = false,
										["Angles"] = Angle(0, -179.4375, 0),
										["Lighting"] = false,
										["AlignToSurface"] = false,
										["Gravity"] = Vector(0, 0.09375, -100),
										["Bounce"] = 10.8,
										["ClassName"] = "particles",
										["DoubleSided"] = false,
										["Spread"] = 0.2,
										["FireDelay"] = 0.01,
										["NumberParticles"] = 10,
										["DieTime"] = 1,
										["Color1"] = Vector(200, 200, 200),
									},
								},
							},
							["self"] = {
								["ClassName"] = "model",
								["EditorExpand"] = true,
								["UniqueID"] = "2613842725",
								["Position"] = Vector(-6.09375, -5.125, 3.875),
								["Size"] = 0.3,
								["Bone"] = "spine",
								["Model"] = "models/xqm/jetenginemedium.mdl",
								["Angles"] = Angle(-1.1875, -94.40625, -15.125),
							},
						},
						[2] = {
							["children"] = {
							},
							["self"] = {
								["Angles"] = Angle(33.4375, 0, 0),
								["ClassName"] = "model",
								["UniqueID"] = "2559247851",
								["Position"] = Vector(0.96875, 0, 5.78125),
								["EditorExpand"] = true,
								["Bone"] = "spine",
								["Model"] = "models/xqm/polex1.mdl",
								["Scale"] = Vector(0.375, 1, 1),
							},
						},
					},
					["self"] = {
						["Angles"] = Angle(-14.875, 91.375, 0),
						["ClassName"] = "model",
						["UniqueID"] = "709861256",
						["Position"] = Vector(5.0625, -5.75, -2.09375),
						["EditorExpand"] = true,
						["Bone"] = "spine",
						["Model"] = "models/xqm/polex1.mdl",
						["Scale"] = Vector(0.375, 1, 1),
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "1708383976",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		}
	}, 10000
end

function ITEM:Think( )
	KInventory.Items.base_hat.Think( self )
	
	if self:GetOwner( ):KeyDown( IN_JUMP ) then
		self:GetOwner( ):SetVelocity( self:GetOwner( ):GetUp( ) * 6 )
	end
end
Pointshop2.AddItemHook( "Think", ITEM )

function ITEM.static.getOutfitForModel( model )
	return ITEM.static.getBaseOutfit( )
end
