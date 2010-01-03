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
                msg = {
                    type = 'input',
                    name = 'My Message',
                    desc = 'The message for my addon',
                    set = 'SetMyMessage',
                    get = 'GetMyMessage',
                },
            }
        },
        
        dummy = {
            name = 'Dummy',
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
                macroEditBox = {
                    name = 'Macro Edit Box',
                    type = 'input',
                    desc = 'Edit your macro',
                    set = 'SetMacroBody',
                    get = 'GetMacroBody',
                    multiline = true,
                    width = 'full',
                    order = 30
                },
                createMacro = {
                    name = 'Create Macro',
                    type = 'execute',
                    desc = 'Creates a macro',
                    func = 'CreateMacro',
                    order = 50,
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
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MMMunch", "Dummy", "MuchMoreMunch", "dummy")
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

function MMMunch:GetMacroBody(info)
    return self.selectedMacroBody
end

function MMMunch:SetMacroBody(info, body)
    local name = options.args.dummy.args.macroSelectBox.values[self.selectedMacro]
    --self.db.profile.macroTable[self.selectedMacro][1] = name
    self.db.profile.macroTable[self.selectedMacro][2] = body

    self.selectedMacroBody = body
    self:Printf("Set selected macro body: %s", name)   
end

function MMMunch:GetSelectMacro(info)
    if self.selectedMacro then
        self:Printf("Get selected macro: %s", options.args.dummy.args.macroSelectBox.values[self.selectedMacro])
        
        return options.args.dummy.args.macroSelectBox.values[self.selectedMacro]
    end
    return nil
end

function MMMunch:SetSelectMacro(info, key)
    self.selectedMacro = key
    local name = options.args.dummy.args.macroSelectBox.values[self.selectedMacro]
    local body = self.db.profile.macroTable[self.selectedMacro][2]
    self:SetMacroBody(info, body)
    self:Printf("Set selected macro: %s", name)    
end

function MMMunch:GetNewMacro(info)
end

function MMMunch:SetNewMacro(info, name)
    local body = self.defaultMacroBody
    local macroID = self:GenerateMacro(name, body)
    
    -- Check if name has been used before
    
    if macroID then
        table.insert(self.db.profile.macroTable, {name, body})
        self:Print("Macro created")
    else
        self:Print("Macro could not be generated")
    end
    
    self:UpdateMacroList()
end

function MMMunch:UpdateMacroList()
    local macroList = {}
    for i, macro in ipairs(self.db.profile.macroTable) do
        table.insert(macroList, macro[1])
    end
    
    options.args.dummy.args.macroSelectBox.values = macroList
end

function MMMunch:GenerateMacro(name,body)
   
    if not self.inCombat then 
        local macroID = GetMacroIndexByName(name)
        
        if macroID == 0 then 
            macroID = CreateMacro(name, 1, body, nil, 1)
        else
            macroID = EditMacro(macroID, name, 1, body, 1, nil)
        end
        
        self:Print("Create Macro Here")
        
        return macroID
    end
    
    return nil
end

function MMMunch:CreateMacro(name,body)
    name = "myMacro"
    body = "#showtooltip"
    local macroID = self:GenerateMacro(name,body)
    if macroID then 
        PickupMacro(macroID)
    end
end

-----------------------
function MMMunch:Test()
    local itemList = self:BagScan()
    local category = "Consumable.Potion.Recovery.Healing"
    local subset = self:ExtractSubset(itemList, category)
    
    self:SortPriority(subset)
    
    self:Printf("itemID: %d, priority: %d, setname: %s", subset[1][1], subset[1][2], subset[1][3])
    self:Printf("itemID: %d, priority: %d, setname: %s", subset[2][1], subset[2][2], subset[2][3])
end
