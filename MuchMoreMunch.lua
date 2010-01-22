MMMunch = LibStub("AceAddon-3.0"):NewAddon("MMMunch", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MMMunch", true)

local PLACEHOLDER_CATEGORIES = {
    hpp = {
        "Consumable.Potion.Recovery.Healing.Basic",
        "Consumable.Potion.Recovery.Rejuvenation",
        "Consumable.Potion.Recovery.Health.Anywhere",
    },
    mpp = {
        "Consumable.Potion.Recovery.Mana.Basic",
        "Consumable.Potion.Recovery.Rejuvenation",
        "Consumable.Potion.Recovery.Mana.Anywhere",
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

local PRESET_MACROS = {
    ["mHP"] = "#showtooltip\n/castsequence [nocombat] reset=120 <hps,hpp,hpp>\n"..
              "/castsequence [combat] reset=combat <hps,hpp>",
    ["mMP"] = "#showtooltip\n/use <mpp>",
    ["mFood"] = "#showtooltip\n/use <hpf>",
    ["mWater"] = "#showtooltip\n/use <mpf>",
    ["mBandage"] = "#showtooltip\n/use [@player] <b>",
    ["mAllHP"] = "#showtooltip\n/use [mod,@player] <b>; [nocombat] <hpf>\n/castsequence [nomod,combat] reset=combat <hps,hpp>",
    ["mAllMP"] = "#showtooltip\n/use [nomod,nocombat] <mpf>\n/castsequence [nomod,combat] reset=combat <mps,mpp>",
}

local options = {
    name = "MuchMoreMunch",
    handler = MMMunch,
    type = 'group',
    args = {
        general = {
            name = L['General'],
            type = 'group',
            args = {
                newMacro = {
                    name = L['New Macro'],
                    type = 'input',
                    desc = L['Create a new empty macro'],
                    set = 'SetNewMacro',
                    get = 'GetNewMacro',
                    order = 10,
                },
                macroSelectBox = {
                    name = L['Existing Macros'],
                    type = 'select',
                    desc = L['Select a macro to edit'],
                    set = 'SetSelectMacro',
                    get = 'GetSelectMacro',
                    style = 'dropdown',
                    values = {},
                    order = 20,
                },
                macroName = {
                    name = L['Macro Name'],
                    type = 'input',
                    desc = L['Macro being edited'],
                    set = 'SetMacroName',
                    get = 'GetMacroName',
                    width = 'full',
                    order = 30,
                },
                macroEditBox = {
                    name = L['Macro Text'],
                    type = 'input',
                    desc = L['Edit your macro. Valid placeholders are:\n\n<hpp> - health potions\n<hps> - healthstones\n<mpp> - mana potions\n<mps> - mana gems\n<hpf> - health food\n<mpf> - mana food\n<b> - bandage\n\nMultiple placeholders can be combined for use in a castsequence, e.g. <hps,hpp>'],
                    set = 'SetMacroBody',
                    get = 'GetMacroBody',
                    multiline = true,
                    width = 'full',
                    order = 32
                },

                macroDeleteBox = {
                    name = L['Delete macro'],
                    type = 'select',
                    desc = L['Select a macro to be deleted'],
                    set = 'SetMacroDelete',
                    get = 'GetMacroDelete',
                    style = 'dropdown',
                    values = {},
                    order = 40,
                    confirm = true,
                    confirmText = L['Are you sure you wish to delete the selected macro?']
                },

                previewHeader = {
                    name = L['Preview Macro'],
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
                    name = L['Create Macro'],
                    type = 'execute',
                    desc = L['Creates a macro that can be dragged onto your action bar'],
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
    self.defaultMacroBody = "#showtooltip\n/use <hpp>"
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

    self.db.RegisterCallback(self, "OnNewProfile", "InitializePresets")
    self.db.RegisterCallback(self, "OnProfileReset", "InitializePresets")
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")

    -- Create Interface Config Options
    local ACD = LibStub("AceConfigDialog-3.0")
    ACD:AddToBlizOptions("MMMunch", "MuchMoreMunch", nil, "general")
    ACD:AddToBlizOptions("MMMunch", L["Profile"], "MuchMoreMunch", "profile")

    self:RegisterChatCommand("mmm", function() InterfaceOptionsFrame_OpenToCategory("MuchMoreMunch") end)
    self:RegisterChatCommand("muchmoremunch", function() InterfaceOptionsFrame_OpenToCategory("MuchMoreMunch") end)

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
    -- this space for rent
end

function MMMunch:OnPlayerEnterCombat()
    self.inCombat = true
end

function MMMunch:OnPlayerLeaveCombat()
    self.inCombat = false
    if self.delayedMacroUpdate == true then
        self:UpdateAll()
        self.delayedMacroUpdate = false
    end
end

function MMMunch:OnBagUpdate()
    if not self.inCombat then
        self:UpdateAll()
    else
        self.delayedMacroUpdate = true
    end
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

function MMMunch:CreateSubTable(itemList)
    local subTable = {}

    for _, item in pairs(itemList) do
        for itemType, _ in pairs(item.setValues) do
            local bestItem = nil
            local bestItemID = subTable[itemType]
            if bestItemID then bestItem = itemList[bestItemID] end

            bestItemID = self:FindBestItem(item, bestItem, itemType)

            if bestItemID ~= nil then subTable[itemType] = bestItemID end
        end
    end

    return subTable
end

function MMMunch:FindBestItem(item, best, itemType)
    if best == nil then
        best = item
    else
        local itemValue = item.setValues[itemType]
        local bestValue = best.setValues[itemType]

        if (itemValue > bestValue)
            or (itemValue == bestValue and item.isConjured and not(best.isConjured))
            or ((itemValue == bestValue) and (best.isCombo) and (not item.isCombo) and (not best.isConjured))
            or ((itemValue == bestValue) and (item.count < best.count)
                and ((item.isConjured == best.isConjured) and (item.isCombo == best.isCombo)))
            then

            best = item
        end

    end

    return best.itemID
end

function MMMunch:BagScan()
    local itemList = {}
    local playerLevel = UnitLevel("player")

    for bagID = 0, NUM_BAG_SLOTS do
        for slotID = 1, GetContainerNumSlots(bagID) do
            local itemID = self:ItemIdFromLink(GetContainerItemLink(bagID, slotID))
            -- skip this step if empty or item already found
            if itemID and not(itemList[itemID]) then
                local itemLevel = select(5, GetItemInfo(itemID))
                if itemLevel and (playerLevel >= itemLevel) then
                    for placeholder, categories in pairs(PLACEHOLDER_CATEGORIES) do
                        for _, set in ipairs(categories) do
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
                                        setValues = {[placeholder] = tonumber(value)},
                                        count = count,
                                        isConjured = self:IsConjuredCategory(set),
                                        isCombo = self:IsComboCategory(set),
                                    }
                                    itemList[itemID] = item
                                else
                                    -- add this set and its value to the item object
                                    item.setValues[placeholder] = tonumber(value)
                                    item.isConjured = item.isConjured or self:IsConjuredCategory(set)
                                    item.isCombo = item.isCombo or self:IsComboCategory(set)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return itemList
end

function MMMunch:UpdateAll()
    local itemList = self:BagScan()
    self.subTable = self:CreateSubTable(itemList)
    self:UpdateBlizzMacros()
    self:UpdateDisplayedMacro()
end

function MMMunch:IsConjuredCategory(category)
    if string.find(category, "Conjured") and not (string.find(category, "Non%-Conjured")) then
        return true
    end
    return false
end

function MMMunch:IsComboCategory(category)
    if string.find(category, "Combo") then return true end

    return false
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
    return self:SubPlaceHolders(body, self.subTable)
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
            self:Print(L["Blizzard macro update aborted: An unrecognised macro called %s already exists. Please rename your macro."](name))
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
function MMMunch:InitializePresets(db, profile)
    for k,v in pairs(PRESET_MACROS) do
        self.db.profile.macroTable[k] = v
    end
    self:RefreshConfig()
end

function MMMunch:RefreshConfig()
    self:UpdateMacroList()
    if not self.inCombat then
        self:UpdateBlizzMacros()
    else
        self.delayedMacroUpdate = true
    end
    self:UpdateDisplayedMacro()
end