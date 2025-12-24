
-- AutoDE v8.4.6
-- FINAL FINAL input handling (matches Molinari behavior exactly)

local addonName, ns = ...
AutoDEDB = AutoDEDB or { blacklistItems = {}, feedback = true }

local function Print(msg)
    if AutoDEDB.feedback then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoDE]|r "..msg)
    end
end

local function ItemID(link)
    return tonumber(link and link:match("item:(%d+)"))
end

local function IsBlacklisted(link)
    local id = ItemID(link)
    return id and AutoDEDB.blacklistItems[id]
end

local function CanDisenchant(link)
    local _, _, quality, _, _, _, _, _, _, _, _, classID = GetItemInfo(link)
    if not quality then return false end
    if classID ~= LE_ITEM_CLASS_ARMOR and classID ~= LE_ITEM_CLASS_WEAPON then return false end
    if quality <= 1 or quality >= 5 then return false end
    if IsBlacklisted(link) then return false end
    return true
end

local function IsLockbox(link)
    local classID, subID = select(12, GetItemInfoInstant(link))
    return classID == LE_ITEM_CLASS_CONTAINER and subID == 0
end

-- Secure overlay button
local button = CreateFrame("Button", "AutoDESecureOverlay", UIParent, "SecureActionButtonTemplate")
button:SetFrameStrata("TOOLTIP")
button:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-ItemButton-Highlight")
button:GetNormalTexture():SetTexCoord(0.11, 0.66, 0.11, 0.66)
button:RegisterForClicks("LeftButtonUp")
button:SetAttribute("alt-type1", "macro")
button:Hide()

-- IMPORTANT:
-- Mouse is enabled ONLY while the overlay is visible.
-- This allows LeftClick to fire, but releases RightClick when hidden.
button:SetScript("OnShow", function(self)
    self:EnableMouse(true)
end)

button:SetScript("OnHide", function(self)
    self:EnableMouse(false)
end)

GameTooltip:HookScript("OnTooltipSetItem", function(tt)
    if InCombatLockdown() or not IsAltKeyDown() then return end

    local _, link = tt:GetItem()
    if not link then return end

    local focus = GetMouseFocus()
    local parent = focus and focus:GetParent()
    local slot = focus and focus.GetID and focus:GetID()
    if not parent or not slot then return end

    local bag = parent:GetID()
    if GetContainerItemLink(bag, slot) ~= link then return end

    if IsLockbox(link) then
        button:SetAttribute("macrotext", string.format("/use %d %d", bag, slot))
    elseif CanDisenchant(link) and IsSpellKnown(13262) then
        button:SetAttribute("macrotext", string.format("/cast %s\n/use %d %d", GetSpellInfo(13262), bag, slot))
    else
        return
    end

    button:ClearAllPoints()
    button:SetAllPoints(focus)
    button:Show()
end)

button:RegisterEvent("MODIFIER_STATE_CHANGED")
button:RegisterEvent("PLAYER_REGEN_ENABLED")
button:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" or not IsAltKeyDown() or InCombatLockdown() then
        self:Hide()
    end
end)

-- Alt + RightClick blacklist (bag slot only)
hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, btn)
    if btn ~= "RightButton" or not IsAltKeyDown() then return end
    local link = GetContainerItemLink(self:GetParent():GetID(), self:GetID())
    if not link then return end
    local id = ItemID(link)
    if not id then return end
    AutoDEDB.blacklistItems[id] = not AutoDEDB.blacklistItems[id]
    Print((AutoDEDB.blacklistItems[id] and "Blacklisted" or "Removed from blacklist") .. ": " .. link)
end)

SLASH_AUTODE1 = "/autode"
SlashCmdList["AUTODE"] = function()
    Print("Alt + LeftClick = Disenchant / Lockbox")
    Print("Alt + RightClick = Toggle blacklist")
end
