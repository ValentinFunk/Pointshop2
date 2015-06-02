KInventory = {}

KInventory.Mixins = {}
function KInventory.RegisterItemClassMixin( class, mixin )
	KInventory.Mixins[class] = KInventory.Mixins[class] or {}
	table.insert( KInventory.Mixins[class], mixin )
end