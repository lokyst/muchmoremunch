MMMunch = LibStub("AceAddon-3.0"):NewAddon("MMMunch", "AceConsole-3.0", "AceEvent-3.0")

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
                    name = 'Macro Selection Box',
                    type = 'select',
                    desc = 'Select the macro to edit',
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
                    name = 'Macro Edit Box',
                    type = 'input',
                    desc = 'Edit your macro',
                    set = 'SetMacroBody',
                    get = 'GetMacroBody',
                    multiline = true,
                    width = 'full',
                    order = 32
                },

                macroDeleteBox = {
                    name = 'Delete macro',
                    type = 'select',
                    desc = 'Delete a macro',
                    set = 'SetMacroDelete',
                    get = 'GetMacroDelete',
                    style = 'dropdown',
                    values = {},
                    order = 40,
                    confirm = true,
                    confirmText = 'Are you sure you wish to delete the selected macro?'
                },
                
                previewHeader = {
                    name = 'Preview',
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
                    desc = 'Creates a macro',
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

MMMunch.inCombat = nil
MMMunch.defaultMacroBody = "#showtooltip"
MMMunch.selectedMacro = nil
MMMunch.selectedMacroName = ""
MMMunch.selectedMacroBody = ""

local PT = LibStub("LibPeriodicTable-3.1")

MMMunch:RegisterChatCommand("mmm", "Test")

function MMMunch:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("MMMunchDB", defaults)
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MMMunch", options, {"mmmunch"})
    
    -- Register events
    MMMunch:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
    MMMunch:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerEnterCombat")
    MMMunch:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerLeaveCombat")
    
    -- Create Interface Config Options
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MMMunch", "MuchMoreMunch", nil, "general")
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MMMunch", "Profile", "MuchMoreMunch", "profile")
    
    -- Populate lists
    self:UpdateMacroList()
end

function MMMunch:OnEnable()
    -- Called when the addon is enabled
end

function MMMunch:OnDisable()
    -- Called when the addon is disabled
end

function MMMunch:GetMyMessage(info)
    self:Print("Hello, get function!")
    return self.myMessageVar
end

function MMMunch:SetMyMessage(info, input)
    self.myMessageVar = input
    self:Print("Hello, set function!")
end

function MMMunch:OnPlayerLogin()
end

function MMMunch:OnPlayerEnterCombat()
    self.inCombat = true
end

function MMMunch:OnPlayerLeaveCombat()
    self.inCombat = false
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

local PT_SETS = {
    "Consumable.Potion.Recovery.Healing.Basic",
    "Consumable.Potion.Recovery.Mana.Basic",
    "Consumable.Warlock.Healthstone",
    "Consumable.Water.Basic",
    "Consumable.Water.Conjured",
    "Consumable.Food.Edible.Basic",
    "Consumable.Food.Edible.Combo",
    "Consumable.Bandage.Basic",
}

function MMMunch:BagScan()
    local itemList = {}

    for bagID = 0, NUM_BAG_SLOTS do
        local numberOfSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numberOfSlots do
            local itemID = MMMunch:ItemIdFromLink(GetContainerItemLink(bagID, slotID))
            if itemID then
            
                for i, set in ipairs(PT_SETS) do
                    
                    local priority, setname = PT:ItemInSet(itemID, set)
                    if priority or setname then
                        --self:Printf("bagID: %d, slotID: %d, itemID: %d, priority: %s, setname: %s", bagID, slotID, itemID, priority, setname)
                        table.insert(itemList, {itemID, tonumber(priority), setname})
                        break
                    end
                end
                
            end
        end
    end
    
    return itemList
end

function MMMunch:ExtractSubset(itemList,category)
    local subset = {}
    
    for i, itemInfo in ipairs(itemList) do
        local itemID, priority, setname = itemInfo[1], itemInfo[2], itemInfo[3]
        
        if string.find(setname, category) == 1 then
            table.insert(subset, itemInfo)
        end
    end
    
    return subset
end

function MMMunch:SortPriority(subset)
    table.sort(subset, function(a,b) return a[2]>b[2] end)
    
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
        options.args.general.args.previewBody.name = self:ProcessMacro()
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

function MMMunch:ProcessMacro()
    return self.selectedMacroBody
end

function MMMunch:CreateMacro()
    local name = self.selectedMacroName
    local body = self.selectedMacroBody
    local macroID = self:GenerateMacro(name,body)
    if macroID then 
        PickupMacro(macroID)
    end
end

function MMMunch:GenerateMacro(name,body)
    if not self.inCombat then 
        local macroID = GetMacroIndexByName(name)
        if macroID == 0 then 
            macroID = CreateMacro(name, 1, body, nil, 1)
        else
            macroID = EditMacro(macroID, name, 1, body, 1, nil)
        end
        
        self:Print("Macro created")
        return macroID
    end

    self:Print("Macro could not be generated")    
    return nil
end

function MMMunch:GetMacroDelete(info)
    return nil
end

function MMMunch:SetMacroDelete(info,key)
    local name = options.args.general.args.macroDeleteBox.values[key] 
    self.db.profile.macroTable[name] = nil

    self:UpdateMacroList()
    self:UpdateDisplayedMacro()
    
    -- Add code for deleting any macro buttons by that name
end

-----------------------
function MMMunch:Test()
    local itemList = self:BagScan()
    local category = "Consumable.Potion.Recovery.Healing"
    local subset = self:ExtractSubset(itemList, category)
    
    self:SortPriority(subset)
    
    --self:Printf("itemID: %d, priority: %d, setname: %s", subset[1][1], subset[1][2], subset[1][3])
    --self:Printf("itemID: %d, priority: %d, setname: %s", subset[2][1], subset[2][2], subset[2][3])
end
