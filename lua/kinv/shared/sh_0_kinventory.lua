KInventory = {}
KInventory.Mixins = {}

-- Registers a class mixin (see middleclass docs).
-- This can be used to extend/patch item classes and their definitions
function KInventory.RegisterItemClassMixin( className, mixin )
	-- Class already loaded, apply mixin now
	if KInventory.Items and KInventory.Items[className] then
		print(KInventory.Items[className])
		KInventory.ApplyMixin( KInventory.Items[className], mixin )
	end

	-- Class not yet loaded, apply once loaded
	KInventory.Mixins[className] = KInventory.Mixins[className] or {}
	table.insert( KInventory.Mixins[className], mixin )
end

-- Apply all registered mixins to className
function KInventory.ApplyMixins( className )
	if KInventory.Mixins[className] then
		for _, mixin in pairs( KInventory.Mixins[className] ) do
			KInventory.ApplyMixin( KInventory.Items[className], mixin )
		end
	end
end

-- Apply single mixin to a class if not already done
function KInventory.ApplyMixin( klaas, mixin )
	klaas.__mixinsApplied = klaas.__mixinsApplied or {}
	if not klaas.__mixinsApplied[mixin] then
		klaas:include( mixin )
		klaas.__mixinsApplied[mixin] = true
	end 
end