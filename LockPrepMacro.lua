local class = UnitClass("player")
if class ~= "Warlock" then
    -- Not really any point for this addon if you're not a lock!
    print("LockPrepMacro: Not a lock!")
    return
end

LockPrepMacro, HSTraded = CreateFrame("Button", "LockPrepMacro", nil, "SecureActionButtonTemplate"), false
local events = {}

function NoBuffExists(tar, checkedBuff)
    for i=1,32 do
        local buff = UnitBuff(tar,i)
        if buff == checkedBuff then
            return false
        end
    end
    return true
end

function NoItemExists(item)
    for i=0,4 do
        for x=1,GetContainerNumSlots(i) do 
            local y=GetContainerItemLink(i,x) 
            if y then 
                if string.find(GetItemInfo(y),item) ~= nil then
                    return false
                end
            end
        end
    end
    return true
end

function NoCastingSpecificSpell(checkedSpell)
    local spell = UnitCastingInfo('player')
    if spell ~= checkedSpell then
        return true
    end
    return false
end

-- function NoChannelingSpecificSpell(checkedSpell)
--     local spell = UnitChannelInfo('player')
--     if spell ~= checkedSpell then
--         return true
--     end
--     return false
-- end

function NoTradingHS()
    local item1 = GetTradePlayerItemInfo(1)
    if item1 == "Master Healthstone" then
        return false
    end
    return true
end

function ArenaCheck(num)
    -- local inArena, inRankedArena = IsActiveBattlefieldArena()
    local members = GetNumGroupMembers()
    if members == num then
        return true
    end
    return false
end

function RoSReady()
    local start, duration, cdEnabled = GetSpellCooldown('Ritual of Souls');
    if (start > 0 and duration > 15 and cdEnabled == 1) then
        -- If channeling the spell cdEnabled will be 0
        return false
    end
    return true
end


function UpdateLockPrep()

    if ArenaCheck(2) then
        local texts = {
            [1] = "/cast [nopet:Imp] Summon Imp\n/stopcasting [pet:Imp]\n/run UpdateLockPrep()",
            [2] = "/cast [@party1] Fire Shield\n/cast [@party1] Unending Breath\n/run UpdateLockPrep()",
            [3] = "/cast [@player] Fire Shield\n/cast [@player] Unending Breath\n/run UpdateLockPrep()",
            [4] = "/cast [@party1] Detect Invisibility\n/run UpdateLockPrep()",
            [5] = "/cast [@player] Detect Invisibility\n/run UpdateLockPrep()",
            [6] = "/cast Fel Armor\n/run UpdateLockPrep()",
            [7] = "/cast [pet:Imp] Summon Voidwalker\n/stopcasting [pet:Voidwalker]\n/run UpdateLockPrep()",
            [8] = "/cast Create Spellstone\n/run UpdateLockPrep()",
            [9] = "/equip Master Spellstone\n/run UpdateLockPrep()",
            [10] = "/cast Create Healthstone\n/run UpdateLockPrep()",
            [11] = "/run if not TradeFrame:IsShown() then InitiateTrade('party1') end\n/run UpdateLockPrep()",
            [12] = "/run for i=0,4 do for x=1,GetContainerNumSlots(i) do y=GetContainerItemLink(i,x) if y then if string.find(GetItemInfo(y),'Healthstone') ~= nil then UseContainerItem(i,x) return end end end end\n/run UpdateLockPrep()",
            [13] = "/run AcceptTrade()\n/run UpdateLockPrep()",
        }
        if not UnitExists('pet') then
            -- Summon Imp if no pet exists
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif (NoBuffExists('player', 'Fire Shield') or NoBuffExists('party1', 'Fire Shield')) and UnitCreatureFamily('pet') ~= "Imp" then
            -- Summon Imp if missing Fire Shield and pet is not Imp
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif NoBuffExists('party1', 'Fire Shield') or NoBuffExists('party1', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party1
            LockPrepMacro:SetAttribute("macrotext", texts[2])
        elseif NoBuffExists('player', 'Fire Shield') or NoBuffExists('player', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on player
            LockPrepMacro:SetAttribute("macrotext", texts[3])
        elseif NoBuffExists('party1', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party1
            LockPrepMacro:SetAttribute("macrotext", texts[4])
        elseif NoBuffExists('player', 'Detect Invisibility') then
            -- Cast Detect Invisibility on player
            LockPrepMacro:SetAttribute("macrotext", texts[5])
        elseif NoBuffExists('player', 'Fel Armor') then
            -- Cast Fel Armor
            LockPrepMacro:SetAttribute("macrotext", texts[6])
        elseif UnitCreatureFamily('pet') == "Imp" and NoCastingSpecificSpell('Summon Voidwalker') then
            -- Summon Voidwalker
            LockPrepMacro:SetAttribute("macrotext", texts[7])
        elseif not IsEquippedItem('Master Spellstone') and NoItemExists('Master Spellstone') then
            -- Cast Master Spellstone
            LockPrepMacro:SetAttribute("macrotext", texts[8])
        elseif not NoItemExists('Master Spellstone') and not IsEquippedItem('Master Spellstone') then
            -- Equip Master Spellstone
            LockPrepMacro:SetAttribute("macrotext", texts[9])
        elseif not HSTraded and NoItemExists('Healthstone') then
            -- Cast HS
            LockPrepMacro:SetAttribute("macrotext", texts[10])
        elseif not HSTraded and not NoItemExists('Healthstone') and not TradeFrame:IsShown() then
            -- Initiate Trade
            LockPrepMacro:SetAttribute("macrotext", texts[11])
        elseif not HSTraded and TradeFrame:IsShown() and NoTradingHS() then
            -- Trade HS
            LockPrepMacro:SetAttribute("macrotext", texts[12])
        elseif TradeFrame:IsShown() and not HSTraded then
            -- Accept Trade
            LockPrepMacro:SetAttribute("macrotext", texts[13])
        elseif HSTraded and NoItemExists('Healthstone') then
            -- Cast HS
            LockPrepMacro:SetAttribute("macrotext", texts[10])
        else
            -- Do nothing
            LockPrepMacro:SetAttribute("macrotext", "/stopcasting\n/run UpdateLockPrep()")
        end
    elseif ArenaCheck(3) then
        local texts = {
            [1] = "/cast [nopet] Summon Imp\n/stopcasting [pet:Imp]\n/run UpdateLockPrep()",
            [2] = "/cast [@party1] Fire Shield\n/cast [@party1] Unending Breath\n/run UpdateLockPrep()",
            [3] = "/cast [@party2] Fire Shield\n/cast [@party2] Unending Breath\n/run UpdateLockPrep()",
            [4] = "/cast [@player] Fire Shield\n/cast [@player] Unending Breath\n/run UpdateLockPrep()",
            [5] = "/cast [@party1] Detect Invisibility\n/run UpdateLockPrep()",
            [6] = "/cast [@party2] Detect Invisibility\n/run UpdateLockPrep()",
            [7] = "/cast [@player] Detect Invisibility\n/run UpdateLockPrep()",
            [8] = "/cast Fel Armor\n/run UpdateLockPrep()",
            [9] = "/cast [pet:Imp] Summon Voidwalker\n/stopcasting [pet:Voidwalker]\n/run UpdateLockPrep()",
            [10] = "/cast Create Spellstone\n/run UpdateLockPrep()",
            [11] = "/equip Master Spellstone\n/run UpdateLockPrep()",
            [12] = "/cast Ritual of Souls\n/run UpdateLockPrep()",
        }
        if not UnitExists('pet') then
            -- Summon Imp if no pet exists
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif (NoBuffExists('player', 'Fire Shield') or NoBuffExists('party1', 'Fire Shield') or NoBuffExists('party2', 'Fire Shield')) and UnitCreatureFamily('pet') ~= "Imp" then
            -- Summon Imp if missing Fire Shield and pet is not Imp
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif NoBuffExists('party1', 'Fire Shield') or NoBuffExists('party1', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party1
            LockPrepMacro:SetAttribute("macrotext", texts[2])
        elseif NoBuffExists('party2', 'Fire Shield') or NoBuffExists('party2', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party2
            LockPrepMacro:SetAttribute("macrotext", texts[3])
        elseif NoBuffExists('player', 'Fire Shield') or NoBuffExists('player', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on player
            LockPrepMacro:SetAttribute("macrotext", texts[4])
        elseif NoBuffExists('party1', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party1
            LockPrepMacro:SetAttribute("macrotext", texts[5])
        elseif NoBuffExists('party2', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party2
            LockPrepMacro:SetAttribute("macrotext", texts[6])
        elseif NoBuffExists('player', 'Detect Invisibility') then
            -- Cast Detect Invisibility on player
            LockPrepMacro:SetAttribute("macrotext", texts[7])
        elseif NoBuffExists('player', 'Fel Armor') then
            -- Cast Fel Armor
            LockPrepMacro:SetAttribute("macrotext", texts[8])
        elseif UnitCreatureFamily('pet') == "Imp" and NoCastingSpecificSpell('Summon Voidwalker') then
            -- Summon Voidwalker
            LockPrepMacro:SetAttribute("macrotext", texts[9])
        elseif not IsEquippedItem('Master Spellstone') and NoItemExists('Master Spellstone') then
            -- Cast Master Spellstone if it's not equipped and not in bags
            LockPrepMacro:SetAttribute("macrotext", texts[10])
        elseif not NoItemExists('Master Spellstone') and not IsEquippedItem('Master Spellstone') then
            -- Equip Master Spellstone if it exists
            LockPrepMacro:SetAttribute("macrotext", texts[11])
        elseif RoSReady() then
            -- HS for all!!!
            LockPrepMacro:SetAttribute("macrotext", texts[12])
        else
            -- Do nothing
            LockPrepMacro:SetAttribute("macrotext", "/stopcasting\n/run UpdateLockPrep()")
        end
    elseif ArenaCheck(5) then
        local texts = {
            [1] = "/cast [nopet] Summon Imp\n/stopcasting [pet:Imp]\n/run UpdateLockPrep()",
            [2] = "/cast [@party1] Fire Shield\n/cast [@party1] Unending Breath\n/run UpdateLockPrep()",
            [3] = "/cast [@party2] Fire Shield\n/cast [@party2] Unending Breath\n/run UpdateLockPrep()",
            [4] = "/cast [@party3] Fire Shield\n/cast [@party3] Unending Breath\n/run UpdateLockPrep()",
            [5] = "/cast [@party4] Fire Shield\n/cast [@party4] Unending Breath\n/run UpdateLockPrep()",
            [6] = "/cast [@player] Fire Shield\n/cast [@player] Unending Breath\n/run UpdateLockPrep()",
            [7] = "/cast [@party1] Detect Invisibility\n/run UpdateLockPrep()",
            [8] = "/cast [@party2] Detect Invisibility\n/run UpdateLockPrep()",
            [9] = "/cast [@party3] Detect Invisibility\n/run UpdateLockPrep()",
            [10] = "/cast [@party4] Detect Invisibility\n/run UpdateLockPrep()",
            [11] = "/cast [@player] Detect Invisibility\n/run UpdateLockPrep()",
            [12] = "/cast Fel Armor\n/run UpdateLockPrep()",
            [13] = "/cast [pet:Imp] Summon Voidwalker\n/stopcasting [pet:Voidwalker]\n/run UpdateLockPrep()",
            [14] = "/cast Create Spellstone\n/run UpdateLockPrep()",
            [15] = "/equip Master Spellstone\n/run UpdateLockPrep()",
            [16] = "/cast Ritual of Souls\n/run UpdateLockPrep()",
        }
        if not UnitExists('pet') then
            -- Summon Imp if no pet exists
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif (NoBuffExists('player', 'Fire Shield') or NoBuffExists('party1', 'Fire Shield') or NoBuffExists('party2', 'Fire Shield') or NoBuffExists('party3', 'Fire Shield') or NoBuffExists('party4', 'Fire Shield')) and UnitCreatureFamily('pet') ~= "Imp" then
            -- Summon Imp if missing Fire Shield and pet is not Imp
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif NoBuffExists('party1', 'Fire Shield') or NoBuffExists('party1', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party1
            LockPrepMacro:SetAttribute("macrotext", texts[2])
        elseif NoBuffExists('party2', 'Fire Shield') or NoBuffExists('party2', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party2
            LockPrepMacro:SetAttribute("macrotext", texts[3])
        elseif NoBuffExists('party3', 'Fire Shield') or NoBuffExists('party3', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party3
            LockPrepMacro:SetAttribute("macrotext", texts[4])
        elseif NoBuffExists('party4', 'Fire Shield') or NoBuffExists('party4', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on party4
            LockPrepMacro:SetAttribute("macrotext", texts[5])
        elseif NoBuffExists('player', 'Fire Shield') or NoBuffExists('player', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on player
            LockPrepMacro:SetAttribute("macrotext", texts[6])
        elseif NoBuffExists('party1', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party1
            LockPrepMacro:SetAttribute("macrotext", texts[7])
        elseif NoBuffExists('party2', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party2
            LockPrepMacro:SetAttribute("macrotext", texts[8])
        elseif NoBuffExists('party3', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party3
            LockPrepMacro:SetAttribute("macrotext", texts[9])
        elseif NoBuffExists('party4', 'Detect Invisibility') then
            -- Cast Detect Invisibility on party4
            LockPrepMacro:SetAttribute("macrotext", texts[10])
        elseif NoBuffExists('player', 'Detect Invisibility') then
            -- Cast Detect Invisibility on player
            LockPrepMacro:SetAttribute("macrotext", texts[11])
        elseif NoBuffExists('player', 'Fel Armor') then
            -- Cast Fel Armor
            LockPrepMacro:SetAttribute("macrotext", texts[12])
        elseif UnitCreatureFamily('pet') == "Imp" and NoCastingSpecificSpell('Summon Voidwalker') then
            -- Summon Voidwalker
            LockPrepMacro:SetAttribute("macrotext", texts[13])
        elseif not IsEquippedItem('Master Spellstone') and NoItemExists('Master Spellstone') then
            -- Cast Master Spellstone if it's not equipped and not in bags
            LockPrepMacro:SetAttribute("macrotext", texts[14])
        elseif not NoItemExists('Master Spellstone') and not IsEquippedItem('Master Spellstone') then
            -- Equip Master Spellstone if it exists
            LockPrepMacro:SetAttribute("macrotext", texts[15])
        elseif RoSReady() then
            -- HS for all!!!
            LockPrepMacro:SetAttribute("macrotext", texts[16])
        else
            -- Do nothing
            LockPrepMacro:SetAttribute("macrotext", "/stopcasting\n/run UpdateLockPrep()")
        end
    else
        local texts = {
            [1] = "/cast [nopet:Imp] Summon Imp\n/stopcasting [pet:Imp]\n/run UpdateLockPrep()",
            [3] = "/cast [@player] Fire Shield\n/cast [@player] Unending Breath\n/run UpdateLockPrep()",
            [5] = "/cast [@player] Detect Invisibility\n/run UpdateLockPrep()",
            [6] = "/cast Fel Armor\n/run UpdateLockPrep()",
            [7] = "/cast [pet:Imp] Summon Voidwalker\n/stopcasting [pet:Voidwalker]\n/run UpdateLockPrep()",
            [8] = "/cast Create Spellstone\n/run UpdateLockPrep()",
            [9] = "/equip Master Spellstone\n/run UpdateLockPrep()",
            [10] = "/cast Create Healthstone\n/run UpdateLockPrep()",
        }
        if not UnitExists('pet') then
            -- Summon Imp if no pet exists
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif NoBuffExists('player', 'Fire Shield') and UnitCreatureFamily('pet') ~= "Imp" then
            -- Summon Imp if missing Fire Shield and pet is not Imp
            LockPrepMacro:SetAttribute("macrotext", texts[1])
        elseif NoBuffExists('player', 'Fire Shield') or NoBuffExists('player', 'Unending Breath') then
            -- Cast Fire Shield and Unending Breath on player
            LockPrepMacro:SetAttribute("macrotext", texts[3])
        elseif NoBuffExists('player', 'Detect Invisibility') then
            -- Cast Detect Invisibility on player
            LockPrepMacro:SetAttribute("macrotext", texts[5])
        elseif NoBuffExists('player', 'Fel Armor') then
            -- Cast Fel Armor
            LockPrepMacro:SetAttribute("macrotext", texts[6])
        elseif UnitCreatureFamily('pet') == "Imp" then
            -- Summon Voidwalker
            LockPrepMacro:SetAttribute("macrotext", texts[7])
        elseif not IsEquippedItem('Master Spellstone') and NoItemExists('Master Spellstone') then
            -- Cast Master Spellstone if it's not equipped and not in bags
            LockPrepMacro:SetAttribute("macrotext", texts[8])
        elseif not NoItemExists('Master Spellstone') and not IsEquippedItem('Master Spellstone') then
            -- Equip Master Spellstone if it exists
            LockPrepMacro:SetAttribute("macrotext", texts[9])
        elseif NoItemExists('Healthstone') then
            -- Cast HS
            LockPrepMacro:SetAttribute("macrotext", texts[10])
        else
            -- Do nothing
            LockPrepMacro:SetAttribute("macrotext", "/stopcasting\n/run UpdateLockPrep()")
        end
    end
end

function events:PLAYER_LOGIN(...)
    LockPrepMacro:RegisterForClicks("AnyUp")
    LockPrepMacro:SetAttribute("type", "macro")
end

function events:PLAYER_ENTERING_WORLD(...)
    HSTraded = false
    LockPrepMacro:SetAttribute("macrotext", "/cast Summon Imp\n/run UpdateLockPrep()")
    -- UpdateLockPrep()
end

function events:TRADE_CLOSED(...)
    HSTraded = true
end

LockPrepMacro:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

for key, val in pairs(events) do
    LockPrepMacro:RegisterEvent(key)
end
