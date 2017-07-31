-- These are weighted chances, which means
-- that e.g. 4 is 4 times as likely to occur as 1
-- or 101 is 101 times as likely to occur as 1
Pointshop2.Rarities = {
	{ name = "Very Common", chance = 101 },
	{ name = "Common", chance = 47 },
	{ name = "Uncommon", chance = 21 },
	{ name = "Rare", chance = 10 },
	{ name = "Very Rare", chance = 4 },
	{ name = "Extremely Rare", chance = 1 },
}

--Chance -> Name
Pointshop2.RarityMap = {
	[101] = "Very Common",
	[47] = "Common",
	[21] = "Uncommon",
	[10] = "Rare",
	[4] = "Very Rare",
	[1] = "Extremely Rare"
}

Pointshop2.RarityColorMap = {
	[101] = Color( 157, 157, 157 ),
	[47] = Color( 120, 120, 120 ),
	[21] = Color( 30, 255, 0 ),
	[10] = Color( 0, 112, 255 ),
	[4] = Color( 163, 53, 236 ),
	[1] = Color( 255, 128, 0 )
}

-- End of configuration

local sum = LibK._.reduce(LibK._.keys(Pointshop2.RarityColorMap), 0, function(a, b) return a + b end)
Pointshop2.RaritiesNormalized = {
	RarityColorMap = {},
	RarityMap = {}
}
for k, v in pairs(Pointshop2.RarityColorMap) do
	Pointshop2.RaritiesNormalized.RarityColorMap[k / sum] = v
end
for k, v in pairs(Pointshop2.RarityMap) do
	Pointshop2.RaritiesNormalized.RarityMap[k / sum] = v
end
Pointshop2.RaritiesNormalized.Rarities = LibK._.map(Pointshop2.Rarities, function(rarityObject) 
	return {
		 name = rarityObject.name,
		 chance = rarityObject.chance / sum,
		 color = Pointshop2.RarityColorMap[rarityObject.chance]
	}
end)

function Pointshop2.GetRarityInfoFromName(name)
	for k, v in pairs(Pointshop2.RaritiesNormalized.Rarities) do
		if v.name == name then
			return v
		end
	end
end

-- Returns rarity information for a chance in % (e.g. 0.1 for 10%)
function Pointshop2.GetRarityInfoFromNormalized(normalizedChance)
	local maxRarity = 0
	for i = #Pointshop2.RaritiesNormalized.Rarities, 1, -1 do
		rarity = Pointshop2.RaritiesNormalized.Rarities[i]
		maxRarity = maxRarity + rarity.chance
		if normalizedChance <= maxRarity then
			return rarity
		end
	end
end

-- Returns rarity information for a chance in absolute values
function Pointshop2.GetRarityInfoFromAbsolute(absoluteChance)
	local maxRarity = 0
	for i = #Pointshop2.Rarities, 1, -1 do
		rarityObject = Pointshop2.Rarities[i]
		maxRarity = maxRarity + rarityObject.chance
		if absoluteChance <= maxRarity then
			return {
				name = rarityObject.name,
				chance = rarityObject.chance,
				color = Pointshop2.RarityColorMap[rarityObject.chance]
			}
		end
	end
end