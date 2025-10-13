local addonName, ExadTweaks = ...
local CL = {}
CL.NF = {}

local classcolors = {
    ["HUNTER"] = CreateColor(0.67, 0.83, 0.45),
    ["WARLOCK"] = CreateColor(0.53, 0.53, 0.93),
    ["PRIEST"] = CreateColor(1.0, 1.0, 1.0),
    ["PALADIN"] = CreateColor(0.96, 0.55, 0.73),
    ["MAGE"] = CreateColor(0.25, 0.78, 0.92),
    ["ROGUE"] = CreateColor(1.0, 0.96, 0.41),
    ["DRUID"] = CreateColor(1.0, 0.49, 0.04),
    ["SHAMAN"] = CreateColor(0.0, 0.44, 0.87),
    ["WARRIOR"] = CreateColor(0.78, 0.61, 0.43),
    ["DEATHKNIGHT"] = CreateColor(0.77, 0.12 , 0.23),
    ["MONK"] = CreateColor(0.0, 1.00 , 0.59),
};


function CL:CreateClassOutlines(unit, frame)
    local outlineEnabled = ExadTweaks.db.classoutline
    local isPlayer = UnitIsPlayer(unit)
    local classification = UnitClassification(unit)
    local asuriFrameEnabled = ExadTweaks.db.AsuriFrame
    local noLevel = ExadTweaks.db.NoLevel
    
    if not self.NF[unit] then
        local nfUnit = CreateFrame("Frame", nil, frame)
        nfUnit:ClearAllPoints()
        nfUnit:SetPoint("CENTER", frame.portrait, "BOTTOMLEFT", 32, 32)
        nfUnit:SetSize(62, 62)
        nfUnit.texture = nfUnit:CreateTexture(nil, "BORDER")
        nfUnit.texture:SetAllPoints(nfUnit)
        nfUnit:SetScale(1)
        nfUnit:Hide()
        self.NF[unit] = nfUnit
        
        local defaultTexture = noLevel and "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\Priest"
                              or "Interface\\AddOns\\ExadTweaks\\textures\\target\\Priest"
        nfUnit.texture:SetTexture(defaultTexture)
    end

    local nfUnit = self.NF[unit]
    
    if asuriFrameEnabled and not isPlayer and classification ~= "normal" then
        local texturePath = (classification == "elite" or classification == "worldboss")
                and "Interface\\AddOns\\ExadTweaks\\textures\\target\\ChainAsuriGold"
                or ((classification == "rareelite" or classification == "rare")
                and "Interface\\AddOns\\ExadTweaks\\textures\\target\\ChainAsuri")

        if frame == FocusFrame then
            nfUnit.texture:SetTexCoord(1, 0, 0, 1)
            nfUnit:ClearAllPoints()
            nfUnit:SetPoint("CENTER", frame.portrait, "BOTTOMLEFT", 85, 12)
        else
            nfUnit:ClearAllPoints()
            nfUnit:SetPoint("CENTER", frame.portrait, "BOTTOMLEFT", -22, 12)
        end
        nfUnit.texture:SetTexture(texturePath)
        nfUnit.texture:SetVertexColor(1, 1, 1)
        nfUnit:SetSize(256, 128)
        nfUnit:Show()
        return
    end
    
    if not isPlayer or not outlineEnabled then
        nfUnit:Hide()
        return
    end
    
    if asuriFrameEnabled then
        nfUnit.texture:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\Priest")
        nfUnit:ClearAllPoints()
        nfUnit:SetPoint("CENTER", frame.portrait, "BOTTOMLEFT", 32, 32)
        nfUnit:SetSize(62, 62)
    end
    
    local _, class = UnitClass(unit)
    local c = classcolors[class]
    if c then
        nfUnit.texture:SetVertexColor(c.r, c.g, c.b)
    end
    nfUnit:Show()
end

function CL:hookfunc()
    if self.portrait then
        if self.unit == "focus" or self.unit == "target" then
            CL:CreateClassOutlines(self.unit, self)
        end
    end
end

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:SetScript("OnEvent", function(self, event, ...)
    if ... == addonName then
        if ExadTweaks.db.classoutline or ExadTweaks.db.AsuriFrame then
            hooksecurefunc("UnitFramePortrait_Update", CL.hookfunc)
        end
    end
end)