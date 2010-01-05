MMMunch = LibStub("AceAddon-3.0"):NewAddon("MMMunch", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")

local PLACEHOLDER_CATEGORIES = {
    hpp = {
        "Consumable.Potion.Recovery.Healing.Basic",
        "Consumable.Potion.Recovery.Rejuvenation",
    },
    mpp = {
        "Consumable.Potion.Recovery.Mana.Basic",
        "Consumable.Potion.Recovery.Rejuvenation",
    },
    hps = {"Consumable.Warlock.Healthstone"},
    mps = {"Consumable.Cooldown.Stone.Mana.Mana Stone"},
    hpf = {
        "Consumable.Food.Edible.Combo.Conjured",
        "Consumable.Food.Edible.Basic.Conjured",
        "Consumable.Food.Edible.Basic.Non-Conjured",
        "Consumable.Food.Edible.Combo",
    },
    mpf = {
        "Consumable.Food.Edible.Combo.Conjured",
        "Consumable.Water.Conjured",
        "Consumable.Water.Basic",
        "Consumable.Food.Combo Mana",
    },
    b = {"Consumable.Bandage.Basic"},
}

local PT_SETS = {}
for _, categories in pairs(PLACEHOLDER_CATEGORIES) do
    for _, category in ipairs(categories) do
        table.insert(PT_SETS, category)
    end
end

local options = {
    name = "MuchMoreMunch",
    handler = MMMunch,
    type = 'group',
    args = {
        general = {
            name = 'General',
            type = 'group',
            args = {
                newMacro = {
                    name = 'New',
                    type = 'input',
                    desc = 'Create a new empty macro',
                    set = 'SetNewMacro',
                    get = 'GetNewMacro',
                    order = 10,
                },
                macroSelectBox = {
                    name = 'Existing Macros',
                    type = 'select',
                    desc = 'Select a macro to edit',
                    set = 'SetSelectMacro',
                    get = 'GetSelectMacro',
                    style = 'dropdown',
                    values = {},
                    order = 20,
                },
                macroName = {
                    name = 'Macro Name',
                    type = 'input',
                    desc = 'Macro being edited',
                    set = 'SetMacroName',
                    get = 'GetMacroName',
                    width = 'full',
                    order = 30,
                },
                macroEditBox = {
                    name = 'Macro Text',
                    type = 'input',
                    desc = 'Edit your macro. Valid placeholders are:\n\n<hpp> - health potions\n<hps> - healthstones\n<mpp> - mana potions\n<mps> - mana gems\n<hpf> - health food\n<mpf> - mana food\n<b> - bandage\n',
                    set = 'SetMacroBody',
                    get = 'GetMacroBody',
                    multiline = true,
                    width = 'full',
                    order = 32
                },

                macroDeleteBox = {
                    name = 'Delete macro',
                    type = 'select',
                    desc = 'Select a macro to be deleted',
                    set = 'SetMacroDelete',
                    get = 'GetMacroDelete',
                    style = 'dropdown',
                    values = {},
                    order = 40,
                    confirm = true,
                    confirmText = 'Are you sure you wish to delete the selected macro?'
                },
                
                previewHeader = {
                    name = 'Preview Macro',
                    type = 'header',
                    order = 50,
                },
                
                previewBody = {
                    name = '\n\n\n\n\n',
                    type = 'description',
                    order = 60,
                },
                
                blank1 = {
                    name = '',
                    type = 'header',
                    order = 100
                },
                
                createMacro = {
                    name = 'Create Macro',
                    type = 'execute',
                    desc = 'Creates a macro that can be dragged onto your action bar',
                    func = 'CreateMacro',
                    disabled = true,
                    order = 110,
                    width = 'full',
                },
                
                
            },
        },
        
    },
}

local defaults = {
    profile = {
        setting = true,
        macroTable = {},
    },
}

local PT = LibStub("LibPeriodicTable-3.1")

function MMMunch:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("MMMunchDB", defaults)
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MMMunch", options, nil)

    -- initialize flags
    self.inCombat = nil
    self.defaultMacroBody = "#showtooltip\n/use <hpp>;"
    self.selectedMacro = nil
    self.selectedMacroName = ""
    self.selectedMacroBody = ""
    self.delayedMacroUpdate = false
    self.tagString = "\n#MMM"
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerLeaveCombat")
    self:RegisterBucketEvent("BAG_UPDATE", 0.5, "OnBagUpdate")
    
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")    
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    -- Create Interface Config Options
    local ACD = LibStub("AceConfigDialog-3.0")
    ACD:AddToBlizOptions("MMMunch", "MuchMoreMunch", nil, "general")
    ACD:AddToBlizOptions("MMMunch", "Profile", "MuchMoreMunch", "profile")
    
    MMMunch:RegisterChatCommand("mmm", function() InterfaceOptionsFrame_OpenToCategory("MuchMoreMunch") end)
    
    -- Populate lists
    self:UpdateMacroList()
end

function MMMunch:OnEnable()
    -- Called when the addon is enabled
end

function MMMunch:OnDisable()
    -- Called when the addon is disabled
end

function MMMunch:OnPlayerLogin()
    self.itemList = self:BagScan()
end

function MMMunch:OnPlayerEnterCombat()
    self.inCombat = true
end

function MMMunch:OnPlayerLeaveCombat()
    self.inCombat = false
    if self.delayedMacroUpdate == true then
        self:UpdateBlizzMacros()
        self.delayedMacroUpdate = false
    end
end

function MMMunch:OnBagUpdate()
    self.itemList = self:BagScan()
    if not self.inCombat then 
        self:UpdateBlizzMacros()
    else
        self.delayedMacroUpdate = true
    end
    self:UpdateDisplayedMacro()
end

function MMMunch:ItemIdFromLink(itemLink)
    if itemLink == nil then return nil end

    local found, _, itemString = string.find(itemLink, "|H(.+)|h")
    if found then
        local _, itemId = strsplit(":", itemString)
        return tonumber(itemId)
    end
    return nil
end

function MMMunch:CreateSubTable()
    local subTable = {}
    
    for placeHolder, categories in pairs(PLACEHOLDER_CATEGORIES) do
        local bestItem = nil
        
        for i, category in ipairs(categories) do
            local items = self:ExtractSubset(self.itemList, category)
            bestItem = self:FindBestItem(items, bestItem, category)
        end
        
        if bestItem ~= nil then 
            subTable[placeHolder] = bestItem.itemID
        end

    end

    return subTable
end

function MMMunch:FindBestItem(items, best, category)
    for i, item in ipairs(items) do
        item = {
            itemID = item.itemID,
            value = item.setValues[category],
            count = item.count,
            isConjured = item.isConjured,
            isCombo = item.isCombo,
        }
        if best == nil then
            best = item
        else
            if (item.value > best.value)
                or (item.value == best.value and item.isConjured)
                or ((item.value == best.value)
                        and ((item.count < best.count)
                            and (not best.isConjured)
                            and ((not item.isCombo)
                                or (best.isCombo)))) then
                
                best = item
            end
        end
    end

    return best
end

function MMMunch:BagScan()
    local itemList = {}
    local playerLevel = UnitLevel("player")

    for bagID = 0, NUM_BAG_SLOTS do
        local numberOfSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numberOfSlots do
            local itemID = MMMunch:ItemIdFromLink(GetContainerItemLink(bagID, slotID))
            if itemID and (playerLevel >= select(5, GetItemInfo(itemID))) then
                for i, set in ipairs(PT_SETS) do
                    -- check if the item belongs to this set
                    local value = PT:ItemInSet(itemID, set)
                    
                    -- if it does, add it to the table of items for this set
                    if value then
                        local count = GetItemCount(itemID)
                        local item = itemList[itemID]
                        
                        if item == nil then
                            -- create the item object
                            item = {
                                itemID = itemID,
                                setValues = {[set]=tonumber(value)},
                                count = count,
                                isConjured = self:IsConjuredCategory(set),
                                isCombo = self:IsComboCategory(set),
                            }
                            itemList[itemID] = item
                        else
                            -- add this set and its value to the item object
                            item.setValues[set] = tonumber(value)
                            item.isConjured = item.isConjured or self:IsConjuredCategory(set)
                            item.isCombo = item.isCombo or self:IsComboCategory(set)
                        end
                    end
                    
                end
            end
        end
    end
    
    return itemList
end

function MMMunch:IsConjuredCategory(category)
    if (not(string.find(category, "Conjured")) and (string.find(category, "Non-Conjured"))) then return true end
    
    return false
end

function MMMunch:IsComboCategory(category)
    if string.find(category, "Combo") then return true end
    
    return false
end

function MMMunch:ExtractSubset(itemList, category)
    local subset = {}
    
    for itemID, item in pairs(itemList) do
        if PT:ItemInSet(itemID, category) then
            table.insert(subset, item)
        end
    end
        
    return subset
end



-- Config dialog UI
function MMMunch:GetNewMacro(info)
    return ""
end

function MMMunch:SetNewMacro(info, name)
    if strtrim(name) == "" then return end
    
    local body = self.defaultMacroBody
    self.db.profile.macroTable[name] = body
    self:UpdateMacroList()
    
    self.selectedMacroName = name
    self:UpdateDisplayedMacro()
end

function MMMunch:UpdateDisplayedMacro()
    name = self.selectedMacroName
    self.selectedMacro = self:GetMacroListKeyByName(name)
    if self.selectedMacro then 
        self.selectedMacroBody = self.db.profile.macroTable[name]
        options.args.general.args.macroName.disabled = false
        options.args.general.args.macroEditBox.disabled = false
        options.args.general.args.previewBody.name = self:ProcessMacro(self.selectedMacroBody)
        options.args.general.args.createMacro.disabled = false
    else
        self.selectedMacroName = nil
        self.selectedMacroBody = nil
        options.args.general.args.macroName.disabled = true
        options.args.general.args.macroEditBox.disabled = true
        options.args.general.args.previewBody.name = '\n\n\n\n\n'
        options.args.general.args.createMacro.disabled = true
    end
end

function MMMunch:GetSelectMacro(info)
    return self.selectedMacro
end

function MMMunch:SetSelectMacro(info, key)
    -- Update contents of macro edit box
    local name = options.args.general.args.macroSelectBox.values[key]
    self.selectedMacroName = name
    self:UpdateDisplayedMacro()
end

function MMMunch:GetMacroName(info)
    return self.selectedMacroName
end

function MMMunch:SetMacroName(info, name)
    if strtrim(name) == "" then return end
    
    -- Grabs the macro text stored under the old name and stores it under the new name
    local body = self.db.profile.macroTable[self.selectedMacroName]
    self.db.profile.macroTable[name] = body
    
    -- Erases the old name and sets the new name as the selection
    self.db.profile.macroTable[self.selectedMacroName] = nil
    self.selectedMacroName = name
    self:UpdateMacroList()
    self:UpdateDisplayedMacro()
end

function MMMunch:GetMacroBody(info)
    return self.selectedMacroBody
end

function MMMunch:SetMacroBody(info, body)
    self.db.profile.macroTable[self.selectedMacroName] = body
    self.selectedMacroBody = body
    self:UpdateDisplayedMacro()
    if not self.inCombat then
        self:GenerateMacro(self.selectedMacroName, body, false)
    else
        self.delayedMacroUpdate = true
    end
end

function MMMunch:UpdateMacroList()
    local macroList = {}
    for name, body in pairs(self.db.profile.macroTable) do
        table.insert(macroList, name)
    end
    
    table.sort(macroList)
    options.args.general.args.macroSelectBox.values = macroList
    options.args.general.args.macroDeleteBox.values = macroList
end

function MMMunch:GetMacroListKeyByName(name)
    local index = nil
    
    for i, macroName in ipairs(options.args.general.args.macroSelectBox.values) do
        if macroName == name then
            index = i
            break
        end
    end
    
    return index
end



-- Macro Processing
function MMMunch:ProcessMacro(body)
    local subTable = self:CreateSubTable()
    return self:SubPlaceHolders(body, subTable)
end

local PLACEHOLDER_PATTERN = "<([%l,%s]+)>"

function MMMunch:SubPlaceHolders(template, subTable)
    return string.gsub(template, PLACEHOLDER_PATTERN, self:SubPatternFunc(subTable))
end

function MMMunch:SubPatternFunc(subTable)
    return function (chunk)
        local bits = {strsplit(",", chunk)}
        local subbedString = ""
        for i, bit in ipairs(bits) do
            local itemID = subTable[strtrim(bit)]
            if itemID then
                if #subbedString > 0 then
                    subbedString = subbedString .. ", "
                end
                subbedString = subbedString .. "item:".. itemID
            end
        end
        
        return subbedString
    end
end

function MMMunch:CreateMacro()
    local name = self.selectedMacroName
    local body = self.selectedMacroBody
    local macroID = nil
    if not self.inCombat then     
        macroID = self:GenerateMacro(name, body, true)
    end
    
    if macroID > 0 then 
        PickupMacro(macroID)
    end
end

function MMMunch:GenerateMacro(name, body, create, macroID)
    if not macroID then macroID = GetMacroIndexByName(name) end

    if macroID == 0 and create then 
        macroID = CreateMacro(name, 1, self:ProcessMacro(body) .. self.tagString, nil, 1)
    elseif macroID > 0 then
        local macroBody = GetMacroBody(macroID)
        if string.find(tostring(macroBody), self.tagString) then
            macroID = EditMacro(macroID, name, 1, self:ProcessMacro(body) .. self.tagString, 1, nil)
        else
            macroID = 0
            self:Printf("Blizzard macro update aborted: An unrecognised macro called %s already exists. Please rename your macro.", name)
        end
    end
    
    return macroID
end

function MMMunch:GetMacroDelete(info)
    return nil
end

function MMMunch:SetMacroDelete(info, key)
    local name = options.args.general.args.macroDeleteBox.values[key] 
    self.db.profile.macroTable[name] = nil

    self:UpdateMacroList()
    self:UpdateDisplayedMacro()

    -- Do not add deletion of the blizzard macro!
    -- The action bar is tied to the macroID which changes when the macro is re-created
end

-- Process actual macros in Blizz macro interface
function MMMunch:UpdateBlizzMacros()
    local globalMacroCount, _ = GetNumMacros()
    
    for macroID = 1, globalMacroCount do
        local name, _, _, _ = GetMacroInfo(macroID)
        local body = self.db.profile.macroTable[name]
        if not (body == nil) then
            -- we've found a match and we want to update it
            self:GenerateMacro(name, body, false, macroID)
        end
    end
end



-- Profile Handling
function MMMunch:RefreshConfig()
    self:UpdateMacroList()
    if not self.inCombat then 
        self:UpdateBlizzMacros()
    else
        self.delayedMacroUpdate = true
    end
    self:UpdateDisplayedMacro()
end