local addonName, ExadTweaks = ...
local pairs, gsub = pairs, string.gsub
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local IsInInstance, IsDesaturated = IsInInstance, IsDesaturated
local UnitClass, UnitExists, UnitCanAttack, GetUnitName = UnitClass, UnitExists, UnitCanAttack, GetUnitName
local UnitIsPlayer, UnitPlayerControlled, UnitIsUnit, UnitClassification = UnitIsPlayer, UnitPlayerControlled, UnitIsUnit, UnitClassification
local UnitIsConnected, UnitSelectionColor = UnitIsConnected, UnitSelectionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- Hide Raid frame titles
local function HideFrameTitles(groupIndex)
    local frame

    if groupIndex and groupIndex > 0 then
        frame = _G["CompactRaidGroup" .. groupIndex .. "Title"]
    else
        frame = _G["CompactPartyFrameTitle"]
    end

    if frame then
        frame:SetAlpha(0)
    end
end

-- Class colored scoreboard
local function ColorScoreBoard()
    local _, instanceType = IsInInstance()
    if not (instanceType == "pvp" or instanceType == "arena") then
        return
    end
    local index = GetNumBattlefieldScores()
    for i = 1, index do
        local ScoreBoard = _G["WorldStateScoreButton" .. i .. "NameText"]

        if ScoreBoard then
            local name, _, _, _, _, _, _, _, _, class = GetBattlefieldScore(i)
            if name and class then
                local color = GetClassColorObj(class)
                ScoreBoard:SetText(color:WrapTextInColorCode(name))
            end
        end
    end
end

-- Some PvPIcon tweaks for BG/Arena/CP Classes

local function PvPIcon()
    local _, instanceType = IsInInstance()
    for i, v in pairs({
        PlayerPVPIcon,
        TargetFrameTextureFramePVPIcon,
        TargetFrameTextureFramePVPIcon,
        PartyMemberFrame1PVPIcon,
        PartyMemberFrame2PVPIcon,
        PartyMemberFrame3PVPIcon,
        PartyMemberFrame4PVPIcon
    }) do
        if instanceType == "arena" then
            v:SetAlpha(0)
            if FocusFrame then
                FocusFrameTextureFramePVPIcon:SetAlpha(0)
            end
        else
            v:SetAlpha(0.45)
            if FocusFrame then
                FocusFrameTextureFramePVPIcon:SetAlpha(0.45)
            end
        end
    end
end

-- Hide indicators and fancy glows

local function HideGlows()
    for _, v in pairs({
        PlayerStatusTexture,
        PlayerStatusGlow,
        PlayerRestGlow,
        PlayerRestIcon,
        PlayerAttackGlow,
        PlayerAttackBackground
    }) do
        if v:IsShown() then
            v:Hide()
        end
    end
end

-- Remove server name from raid frames
if CompactUnitFrame_UpdateName then
    hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
        local _, instanceType = IsInInstance()
        local name = frame.overlay.name
        local xName = GetUnitName(frame.unit, true)
        if (instanceType == "pvp" or instanceType == "arena") then
            if (xName) then
                local noRealm = gsub(xName, "%-[^|]+", "")
                name:SetText(noRealm)
            end
        end
    end)
end

-- Class colored health and/or gradient

function ExadTweaks.ExadTweaksF:GradientColour(statusbar)
    if (not statusbar or statusbar.disconnected) then
        return
    end

    local min, max = statusbar:GetMinMaxValues()
    if (max <= min) then
        return
    end

    local value = statusbar:GetValue()
    if ((value < min) or (value > max)) then
        return
    end

    value = (value - min) / (max - min)

    local r, g
    if (value > 0.5) then
        r = (1.0 - value) * 2
        g = 1.0
    else
        r = 1.0
        g = value * 2
    end
    statusbar:SetStatusBarColor(r, g, 0.0)

    return
end

local function colour(statusbar, unit)
    if not statusbar then
        return
    end

    if unit then
        if UnitIsConnected(unit) and unit == statusbar.unit then
            if UnitIsPlayer(unit) and UnitClass(unit) and ExadTweaks.db.ClassHP then
                local _, class = UnitClass(unit)
                local c = RAID_CLASS_COLORS[class]
                if c then
                    statusbar:SetStatusBarColor(c.r, c.g, c.b)
                end
            elseif (ExadTweaks.db.GradientHP and UnitCanAttack("player", unit)) or not (ExadTweaks.db.ClassHP or ExadTweaks.db.unithp) then
                ExadTweaks.ExadTweaksF:GradientColour(statusbar)
            elseif ExadTweaks.db.unithp then
                local red, green = UnitSelectionColor(unit)
                if red == 0 then
                    statusbar:SetStatusBarColor(0, 1, 0)
                elseif green == 0 then
                    statusbar:SetStatusBarColor(1, 0, 0)
                else
                    statusbar:SetStatusBarColor(1, 1, 0)
                end
            --elseif (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
                --statusbar:SetStatusBarColor(.5, .5, .5)
            end
        end
    end
end

local function manabarRecolor(manaBar)
    if not manaBar or not UnitIsUnit(manaBar.unit, "player") then
        return
    end

    if not manaBar.lockColor then
        local playerDeadOrGhost = manaBar.unit == "player" and (UnitIsDead("player") or UnitIsGhost("player")) and not UnitIsFeignDeath("player")
        if not playerDeadOrGhost then
            manaBar:SetStatusBarColor(0.498, 0, 1.0)
        end
    end
end

-- Classification

local classificationTexture = {
    ["worldboss"] = {
        ["thin"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\UI-TargetingFrame-Elite",
        ["thick"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-Elite",
        ["thick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-Elite2",
        ["nthin"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Elite",
        ["nthin2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Elite2",
        ["nthick"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-Elite",
        ["nthick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-Elite2",
    },
    ["rareelite"] = {
        ["thin"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\UI-TargetingFrame-Rare-Elite",
        ["thick"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-RareElite",
        ["thick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-RareElite2",
        ["nthin"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Rare-Elite",
        ["nthin2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Rare-Elite2",
        ["nthick"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-RareElite",
        ["nthick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-RareElite2",
    },
    ["elite"] = {
        ["thin"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\UI-TargetingFrame-Elite",
        ["thick"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-Elite",
        ["thick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-Elite2",
        ["nthin"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Elite",
        ["nthin2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Elite2",
        ["nthick"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-Elite",
        ["nthick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-Elite2",
    },
    ["rare"] = {
        ["thin"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\UI-TargetingFrame-Rare",
        ["thick"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-Rare",
        ["thick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-Rare2",
        ["nthin"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Rare",
        ["nthin2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame-Rare2",
        ["nthick"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-Rare",
        ["nthick2"] = "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-Rare2",
    },
}

local function FrameTexture(frame, classification)
    local textureName = ""

    if ExadTweaks.db.AsuriFrame then
        frame:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\target\\AsuriFrame")
        frame:SetVertexColor(ExadTweaks.db.Colval, ExadTweaks.db.Colval, ExadTweaks.db.Colval)
        return
    end

    if classification and classificationTexture[classification] then
        if ExadTweaks.db.ThickFrames and (ExadTweaks.db.Colval >= 0.3) then
            textureName = ExadTweaks.db.NoLevel and classificationTexture[classification]["nthick2"] or classificationTexture[classification]["thick2"]
        elseif ExadTweaks.db.ThickFrames then
            textureName = ExadTweaks.db.NoLevel and classificationTexture[classification]["nthick"] or classificationTexture[classification]["thick"]
        else
            if ExadTweaks.db.NoLevel then
                textureName = (ExadTweaks.db.Colval >= 0.3) and classificationTexture[classification]["nthin2"] or classificationTexture[classification]["nthin"]
            else
                textureName = classificationTexture[classification]["thin"]
            end
        end
        frame:SetVertexColor((ExadTweaks.db.Colval >= 0.3) and ExadTweaks.db.Colval or 1, (ExadTweaks.db.Colval >= 0.3) and ExadTweaks.db.Colval or 1, (ExadTweaks.db.Colval >= 0.3) and ExadTweaks.db.Colval or 1)
    end

    if textureName == "" then
        if ExadTweaks.db.ThickFrames then
            textureName = ExadTweaks.db.NoLevel and "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-Thick-TargetingFrame" or "Interface\\AddOns\\ExadTweaks\\textures\\target\\Thick-TargetingFrame"
        else
            textureName = ExadTweaks.db.NoLevel and "Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\NoLevel-UI-TargetingFrame" or "Interface\\TargetingFrame\\UI-TargetingFrame"
        end
        frame:SetVertexColor(ExadTweaks.db.Colval, ExadTweaks.db.Colval, ExadTweaks.db.Colval)
    end

    frame:SetTexture(textureName)
end

local function CheckClassification(self, forceNormalTexture)
    local classification = UnitClassification(self.unit)
    local textureName = ""

    FrameTexture(self.borderTexture, classification)

    if textureName == "" then
        forceNormalTexture = true
    end

    if ExadTweaks.db.ClassNames then
        local _, class = UnitClass(self.unit)
        local c = RAID_CLASS_COLORS[class]
        if c and UnitIsPlayer(self.unit) then
            self.name:SetVertexColor(c.r, c.g, c.b)
            if ExadTweaks.db.ClassBG and not ExadTweaks.db.AsuriFrame then
                self.name:SetFontObject("SystemFont_Outline_Small")
            end
        else
            self.name:SetVertexColor(1, 0.81960791349411, 0, 1)
        end
    end

    if ExadTweaks.db.NoLevel and not ExadTweaks.db.AsuriFrame then
        self.levelText:SetAlpha(0)
        if self.threatIndicator then
            self.threatIndicator:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\ui-targetingframe-flash")
        end
    end

    if ExadTweaks.db.ThickFrames then
        self.highLevelTexture:SetPoint("CENTER", self.levelText, "CENTER", 0, 0)
        self.nameBackground:Hide()
        self.name:ClearAllPoints()
        self.name:SetPoint("CENTER", self, "CENTER", -50, 35)
        self.name:SetFontObject("SystemFont_Outline_Small")
        self.name:SetShadowOffset(0, 0)

        self.healthbar:ClearAllPoints()
        self.healthbar:SetPoint("CENTER", self, "CENTER", -50, 14)
        self.healthbar:SetHeight(27)
        if self.healthbar.LeftText then
            self.healthbar.LeftText:ClearAllPoints()
            self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 7, 0)
        end
        if self.healthbar.RightText then
            self.healthbar.RightText:ClearAllPoints()
            self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -4, 0)
        end
        if self.healthbar.TextString then
            self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        end

        if self.deadText then
            self.deadText:ClearAllPoints()
            self.deadText:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        end

        self.manabar:ClearAllPoints()
        self.manabar:SetPoint("CENTER", self, "CENTER", -50, -7)

        if self.manabar.LeftText then
            self.manabar.LeftText:ClearAllPoints()
            self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 7, 0)
        end
        if self.manabar.RightText then
            self.manabar.RightText:ClearAllPoints()
            self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -4, 0)
        end
        if self.manabar.TextString then
            self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0)
        end

        if GetCVar("threatShowNumeric") == "1" then
            if TargetFrameNumericalThreat then
                TargetFrameNumericalThreat:SetScale(0.9)
                TargetFrameNumericalThreat:ClearAllPoints()
                TargetFrameNumericalThreat:SetPoint("CENTER", TargetFrame, "CENTER", 44, 50)
            end
            if FocusFrame and FocusFrameNumericalThreat then
                FocusFrameNumericalThreat:ClearAllPoints()
                FocusFrameNumericalThreat:SetPoint("CENTER", FocusFrame, "CENTER", 44, 48)
            end
        end

        if (forceNormalTexture) then
            self.haveElite = nil
        else
            self.haveElite = true
        end
    elseif ExadTweaks.db.AsuriFrame then
        self.highLevelTexture:SetAlpha(0)
        self.nameBackground:SetAlpha(0)
        self.nameBackground:Hide()
        self.levelText:SetAlpha(0)
        if self.threatIndicator then
            self.threatIndicator:SetAlpha(0)
        end
        self.name:ClearAllPoints()
        self.name:SetPoint("CENTER", self, "CENTER", -50, 25)
        self.name:SetShadowOffset(1, -1)

        self.healthbar:ClearAllPoints()
        self.healthbar:SetPoint("CENTER", self, "CENTER", -50, 7)
        self.healthbar:SetHeight(16)
        if self.healthbar.LeftText then
            self.healthbar.LeftText:ClearAllPoints()
            self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 7, 0)
        end
        if self.healthbar.RightText then
            self.healthbar.RightText:ClearAllPoints()
            self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -4, 0)
        end
        if self.healthbar.TextString then
            self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        end

        if self.deadText then
            self.deadText:ClearAllPoints()
            self.deadText:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        end

        self.manabar:ClearAllPoints()
        self.manabar:SetPoint("CENTER", self, "CENTER", -50, -7)

        if self.manabar.LeftText then
            self.manabar.LeftText:ClearAllPoints()
            self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 7, -1)
        end
        if self.manabar.RightText then
            self.manabar.RightText:ClearAllPoints()
            self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -4, -1)
        end
        if self.manabar.TextString then
            self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, -1)
        end
        if (forceNormalTexture) then
            self.haveElite = nil
            local bg = _G[self:GetName() .. "Background"]
            if bg then
                bg:SetSize(119, 30)
                bg:ClearAllPoints()
                bg:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
            end
        else
            self.haveElite = true
            local bg = _G[self:GetName() .. "Background"]
            if bg then
                bg:SetSize(119, 30)
            end
        end
    end
end

-- Fix Portrait gaps

local function OnLoad()
    TargetFrameToTPortrait:ClearAllPoints()
    TargetFrameToTPortrait:SetPoint("LEFT", TargetFrameToT, "LEFT", 5, 0)
    if FocusFrame then
        FocusFrameToTPortrait:ClearAllPoints()
        FocusFrameToTPortrait:SetPoint("LEFT", FocusFrameToT, "LEFT", 5, 0)
    end
end



-- Class portrait frames

local CLASS_TEXTURE = "Interface\\AddOns\\ExadTweaks\\textures\\classes\\%s.blp"

local function ClassPortrait(self)
    if self.unit == "pet" then
        return
    end

    if self.portrait and UnitIsPlayer(self.unit) then
        local _, class = UnitClass(self.unit)
        if class then
            self.portrait:SetTexture(CLASS_TEXTURE:format(class))
        end
    else
        format(self.unit)
    end
end

local buttonNames = { "ActionButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton",
                      "MultiBarRightButton", "MultiBarLeftButton", "PetActionButton" }

local function HideHotkeys()
    for _, buttonName in pairs(buttonNames) do
        for i = 1, 12 do
            local hotKey = _G[buttonName .. i .. "HotKey"]
            if hotKey and ExadTweaks.db.HideHotkey then
                hotKey:SetAlpha(0)
            end
            local name = _G[buttonName .. i .. "Name"]
            if name and ExadTweaks.db.HideMacro then
                name:SetAlpha(0)
            end
        end
    end
end

local function PlayerArtThick(self)
    local classification

    if ExadTweaks.db.NoLevel or ExadTweaks.db.AsuriFrame then
        PlayerLevelText:Hide()
    end

    if ExadTweaks.db.ClassNames and not ExadTweaks.db.AsuriFrame then
        local _, class = UnitClass("player")
        local c = RAID_CLASS_COLORS[class]
        if c then
            self.name:SetVertexColor(c.r, c.g, c.b)
            if ExadTweaks.db.ClassBG then
                self.name:SetFontObject("SystemFont_Outline_Small")
            end
        end
    end

    if ExadTweaks.db.RareElite then
        classification = "rareelite"
    elseif ExadTweaks.db.GoldElite then
        classification = "elite"
    elseif ExadTweaks.db.Rare then
        classification = "rare"
    end

    if ExadTweaks.db.AsuriFrame and classification then
        if not AsuriChain then
            local asuriChain = PlayerFrameTexture:GetParent():CreateTexture("AsuriChain", "BORDER", nil, 1)
            if classification == "rare" or classification == "rareelite" then
                asuriChain:SetTexture("Interface\\Addons\\ExadTweaks\\textures\\target\\ChainAsuri")
            else
                asuriChain:SetTexture("Interface\\Addons\\ExadTweaks\\textures\\target\\ChainAsuriGold")
            end
            asuriChain:SetTexCoord(1, 0, 0, 1)
            asuriChain:SetSize(256, 128)
            asuriChain:SetPoint("CENTER", PlayerFrame, "CENTER", 12, -14)
            asuriChain:Show()
        elseif not AsuriChain:IsShown() then
            AsuriChain:Show()
        end
    end

    FrameTexture(PlayerFrameTexture, classification)

    if ExadTweaks.db.ThickFrames then
        self.name:ClearAllPoints()
        self.name:SetPoint("CENTER", self, "CENTER", 50, 35)
        self.name:SetFontObject("SystemFont_Outline_Small")
        self.name:SetShadowOffset(0, 0)
        self.healthbar:ClearAllPoints()
        self.healthbar:SetPoint("CENTER", self, "CENTER", 50, 14)
        self.healthbar:SetHeight(27)
        if self.healthbar.LeftText then
            self.healthbar.LeftText:ClearAllPoints()
            self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 7, 0)
        end
        if self.healthbar.RightText then
            self.healthbar.RightText:ClearAllPoints()
            self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -4, 0)
        end
        self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        self.manabar:ClearAllPoints()
        self.manabar:SetPoint("CENTER", self, "CENTER", 50, -7)
        self.manabar:SetHeight(13)
        if self.manabar.LeftText then
            self.manabar.LeftText:ClearAllPoints()
            self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 7, 0)
        end
        if self.manabar.RightText then
            self.manabar.RightText:ClearAllPoints()
            self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -4, 0)
        end
        self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0)
    elseif ExadTweaks.db.AsuriFrame then
        self.name:SetAlpha(0)
        PlayerFrameBackground:SetSize(119, 29)
        PlayerFrameBackground:SetPoint("TOPLEFT", 106, -34)
        self.healthbar:ClearAllPoints()
        self.healthbar:SetPoint("CENTER", self, "CENTER", 50, 7)
        self.healthbar:SetHeight(16)

        if self.healthbar.LeftText then
            self.healthbar.LeftText:ClearAllPoints()
            self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 7, 0)
        end
        if self.healthbar.RightText then
            self.healthbar.RightText:ClearAllPoints()
            self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -4, 0)
        end
        self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        self.manabar:ClearAllPoints()
        self.manabar:SetPoint("CENTER", self, "CENTER", 50, -7)
        self.manabar:SetHeight(13)
        if self.manabar.LeftText then
            self.manabar.LeftText:ClearAllPoints()
            self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 7, -1)
        end
        if self.manabar.RightText then
            self.manabar.RightText:ClearAllPoints()
            self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -4, -1)
        end
        self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, -1)
    end
end

local function VehicleArtThick(self, vehicleType)
    if (vehicleType == "Natural") then
        PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic")
        PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash")
        PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
        self.healthbar:SetSize(103, 12)
        self.healthbar:SetPoint("TOPLEFT", 116, -41)
        self.manabar:SetSize(103, 12)
        self.manabar:SetPoint("TOPLEFT", 116, -52)
    else
        PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame")
        PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
        PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
        self.healthbar:SetSize(100, 12)
        self.healthbar:SetPoint("TOPLEFT", 119, -41)
        self.manabar:SetSize(100, 12)
        self.manabar:SetPoint("TOPLEFT", 119, -52)
    end

    if AsuriChain and AsuriChain:IsShown() then
        AsuriChain:Hide()
    end
end

local function PetArtThick()
    PetFrameTexture:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\target\\UI-SmallTargetingFrame")
    PetName:SetAlpha(0)
    PetFrameHealthBar:SetHeight(13)
    PetFrameHealthBar:ClearAllPoints()
    PetFrameHealthBar:SetPoint("CENTER", PetFrame, "CENTER", 16, 5)
    PetFrameManaBar:ClearAllPoints()
    PetFrameManaBar:SetPoint("CENTER", PetFrame, "CENTER", 16, -7)
    PetFrameHealthBar.TextString:ClearAllPoints()
    PetFrameHealthBar.TextString:SetPoint("CENTER", PetFrameHealthBar, "CENTER", 0, -0.5)
    PetFrameManaBar.TextString:ClearAllPoints()
    PetFrameManaBar.TextString:SetPoint("CENTER", PetFrameManaBar, "CENTER", 0, 0)
    if PetFrameHealthBarTextLeft then
        PetFrameHealthBarTextLeft:ClearAllPoints()
        PetFrameHealthBarTextLeft:SetPoint("TOPLEFT", 45, -18)
    end
    if PetFrameHealthBarTextRight then
        PetFrameHealthBarTextRight:ClearAllPoints()
        PetFrameHealthBarTextRight:SetPoint("TOPRIGHT", -14, -18)
    end
    if PetFrameManaBarTextLeft then
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", 45, -7)
    end
    if PetFrameManaBarTextRight then
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", -14, -7)
    end
end

local function ApplyThickness()
    if not ExadTweaks.db.AsuriFrame then
        PlayerFrame.name:ClearAllPoints()
        PlayerFrame.name:SetPoint("TOP", PlayerFrameHealthBar, 0, 15)
        PlayerStatusTexture:SetTexture("Interface\\Addons\\ExadTweaks\\textures\\target\\UI-Player-Status2");
    end
    PlayerRestGlow:SetAlpha(0)
    hooksecurefunc("PetFrame_Update", PetArtThick)
    hooksecurefunc(PlayerFrameGroupIndicator, "Show", PlayerFrameGroupIndicator.Hide)
    hooksecurefunc("PlayerFrame_ToVehicleArt", VehicleArtThick)
end

local IsUsableAction, GetActionCount, IsConsumableAction = IsUsableAction, GetActionCount, IsConsumableAction
local IsStackableAction, IsActionInRange, RANGE_INDICATOR = IsStackableAction, IsActionInRange, RANGE_INDICATOR

local function Usable(button)
    local action = button.action
    local icon = _G[button:GetName() .. "Icon"]

    if not action or not icon then
        return
    end

    local isUsable, notEnoughMana = IsUsableAction(action)
    local count = GetActionCount(action)

    if isUsable then
        icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        icon:SetDesaturated(0)
    elseif notEnoughMana then
        icon:SetVertexColor(0.3, 0.3, 0.3, 1.0)
        icon:SetDesaturated(1)
    elseif (IsConsumableAction(action) or IsStackableAction(action)) and count == 0 then
        if not icon:IsDesaturated() then
            icon:SetDesaturated(1)
        end
    else
        if UnitExists("target") or UnitExists("focus") then
            icon:SetVertexColor(0.4, 0.4, 0.4, 1.0)
            icon:SetDesaturated(1)
        else
            icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
            icon:SetDesaturated(0)
        end
    end
end

local function RangeIndicator(self, checksRange, inRange)
    local valid = IsActionInRange(self.action);
    checksRange = (valid ~= nil)
    inRange = checksRange and valid;
    local icon = _G[self:GetName() .. "Icon"]

    if checksRange and inRange ~= 1 then
        icon:SetVertexColor(1.0, 0.35, 0.35, 0.75)
        icon:SetDesaturated(1)
    else
        Usable(self)
    end
end

local conflictingAddons = {
    "BuffSizer",
    "ClassicAuraDurations",
    "DarkModeUI",
    "EasyFrames",
    "LargerSelfAuras",
    "RiizUI",
    "TextureScript",
    "SUI",
    "whoaUnitFrames_WotLK",
    "whoaThickFrames_WotLK",
    "BetterBlizzFrames",
}

local e = CreateFrame("Frame")
e:RegisterEvent("PLAYER_LOGIN")
e:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if ExadTweaks.db.FadeIcon or ExadTweaks.db.HideHotkey or ExadTweaks.db.HideMacro then
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
        end

        if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC and not IsAddOnLoaded("Precognito") then
            for _, v in pairs { PlayerFrameHealthBar, TargetFrameHealthBar, FocusFrameHealthBar } do
                if v and v.MyHealPredictionBar then
                    v.MyHealPredictionBar.FillMask:SetTexture("Interface\\TargetingFrame\\UI-StatusBar", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                end
                if v and v.OtherHealPredictionBar then
                    v.OtherHealPredictionBar.FillMask:SetTexture("Interface\\TargetingFrame\\UI-StatusBar", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                end
            end
        end

        for _, v in ipairs(conflictingAddons) do
            if IsAddOnLoaded(v) then
                ChatFrame1:AddMessage("|cff009cffExadTweaks:|r disable |cffffff00" .. v .. "|r to avoid bugs.")
            end
        end

        if ExadTweaks.db.ToTDebuffs or ExadTweaks.db.AsuriFrame then
            for _, totFrame in ipairs({ TargetFrameToT, FocusFrameToT }) do
                -- totFrame:HookScript("OnShow", function()
                for i = 1, 4 do
                    local dbf = _G[totFrame:GetName() .. "Debuff" .. i]
                    if dbf and dbf:GetAlpha() > 0 then
                        dbf:SetAlpha(0)
                    end
                end
            end
            -- end)
        end

        if ExadTweaks.db.ThickFrames or ExadTweaks.db.AsuriFrame then
            ApplyThickness()
        end

        if ExadTweaks.db.AsuriFrame then
            local hideToTName, hideFoTName
            hooksecurefunc(TargetFrameToT.name, "SetText", function(self)
                if hideToTName then
                    return
                end
                hideToTName = true
                self:SetText("")
                hideToTName = false
            end)
            if FocusFrameToT then
                hooksecurefunc(FocusFrameToT.name, "SetText", function(self)
                    if hideFoTName then
                        return
                    end
                    hideFoTName = true
                    self:SetText("")
                    hideFoTName = false
                end)
            end

            PlayerMasterIcon:SetAlpha(0)
            PlayerLeaderIcon:SetAlpha(0)

            TargetFrameToT:SetSize(10, 10)
            TargetFrameToTTextureFrame:Hide()
            TargetFrameToTHealthBar:Hide()
            TargetFrameToTManaBar:Hide()
            TargetFrameToTBackground:Hide()
            TargetFrameToT:ClearAllPoints()
            TargetFrameToT:SetPoint("CENTER", TargetFrame, "RIGHT", -70, -15)
            TargetFrameToT:SetScale(0.9)
            TargetFrameToTTextureFrameDeadText:SetAlpha(0)
            TargetFrame.name:SetAlpha(0)
            PlayerPVPIcon:SetAlpha(0)
            TargetFrameTextureFramePVPIcon:SetAlpha(0)

            FocusFrameToT:SetSize(10, 10)
            FocusFrameToTTextureFrame:Hide()
            FocusFrameToTHealthBar:Hide()
            FocusFrameToTManaBar:Hide()
            FocusFrameToTBackground:Hide()
            FocusFrameToT:ClearAllPoints()
            FocusFrameToT:SetPoint("CENTER", FocusFrame, "LEFT", -75, -15)
            FocusFrameToT:SetScale(0.9)
            FocusFrameToTTextureFrameDeadText:SetAlpha(0)
            FocusFrameTextureFramePVPIcon:SetAlpha(0)
            FocusFrame.name:SetAlpha(0)

            -- Flip frame
            FocusFrameTextureFrameTexture:SetTexCoord(1, 0.09375, 0, 0.78125)
            for i = 1, FocusFrameTextureFrameTexture:GetNumPoints() do
                local point, relativeTo, relativePoint, xOfs, yOfs = FocusFrameTextureFrameTexture:GetPoint(i)
                FocusFrameTextureFrameTexture:SetPoint(point, relativeTo, relativePoint, xOfs - 100, yOfs)
            end

            FocusFramePortrait:ClearAllPoints()
            FocusFramePortrait:SetPoint("TOPRIGHT", FocusFrame, "TOPRIGHT", -225, -12)
            FocusFrameTextureFrameLeaderIcon:ClearAllPoints()
            FocusFrameTextureFrameLeaderIcon:SetPoint("TOPRIGHT", FocusFrameTextureFrame, "TOPRIGHT", -105, -15)

            -- fix castbar position

            SetCVar("fullSizeFocusFrame", 1)

            if not ExadTweaks.db.Class_Portrait then
                hooksecurefunc("UnitFramePortrait_Update",function(self)
                    if self == TargetFrameToT or self == FocusFrameToT then
                        if self.portrait then
                            if UnitIsPlayer(self.unit) then
                                local _, class = UnitClass(self.unit)
                                local t = CLASS_ICON_TCOORDS[class]
                                if t then
                                    self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                                    self.portrait:SetTexCoord(unpack(t))
                                end
                            else
                                self.portrait:SetTexCoord(0,1,0,1)
                            end
                        end
                    end
                end)
            end
        end

        if ExadTweaks.db.NoLevel or ExadTweaks.db.ThickFrames or ExadTweaks.db.AsuriFrame or ExadTweaks.db.GoldElite or ExadTweaks.db.RareElite or ExadTweaks.db.Rare or ExadTweaks.db.ClassNames then
            hooksecurefunc("PlayerFrame_ToPlayerArt", PlayerArtThick)
        end

        if (ExadTweaks.db.ClassHP or ExadTweaks.db.GradientHP or ExadTweaks.db.unithp) then
            hooksecurefunc("UnitFrameHealthBar_Update", colour)
            hooksecurefunc("HealthBar_OnValueChanged", function(self)
                colour(self, self.unit)
            end)
        end
        if ExadTweaks.db.Class_Portrait then
            hooksecurefunc("UnitFramePortrait_Update", ClassPortrait)
        end
        if ExadTweaks.db.ScoreBoard then
            hooksecurefunc("WorldStateScoreFrame_Update", ColorScoreBoard)
        end
        if ExadTweaks.db.HideGlows or ExadTweaks.db.AsuriFrame then
            hooksecurefunc("PlayerFrame_UpdateStatus", HideGlows)
        end
        if ExadTweaks.db.HideIndicator then
            hooksecurefunc(PlayerHitIndicator, "Show", PlayerHitIndicator.Hide)
            hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
        end
        if ExadTweaks.db.HideTitles then
            if not ExadTweaks.db.ThickFrames or not ExadTweaks.db.AsuriFrame then
                hooksecurefunc(PlayerFrameGroupIndicator, "Show", PlayerFrameGroupIndicator.Hide)
            end
            if CompactRaidGroup_GenerateForGroup then
                hooksecurefunc("CompactRaidGroup_GenerateForGroup", HideFrameTitles)
            end
            if CompactPartyFrame_Generate then
                hooksecurefunc("CompactPartyFrame_Generate", HideFrameTitles)
            end
            for i = 0, 8 do
                HideFrameTitles(i)
            end
        end
        if ExadTweaks.db.pimp then
            hooksecurefunc("UnitFrameManaBar_UpdateType", manabarRecolor)
        end
        if ExadTweaks.db.HideAggro then
            if CompactUnitFrame_UpdateAggroHighlight then
                hooksecurefunc("CompactUnitFrame_UpdateAggroHighlight", function(self)
                    if self.aggroHighlight and (self.aggroHighlight:GetAlpha() > 0) then
                        self.aggroHighlight:SetAlpha(0)
                        return
                    end
                end)
            end
        end
        if ExadTweaks.db.roleIcon then
            hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
                if not frame.roleIcon then
                    return
                end

                if frame.roleIcon:IsShown() and (frame.roleIcon:GetAlpha() > 0) then
                    frame.roleIcon:SetAlpha(0);
                end
            end)
        end
        if ExadTweaks.db.Stance then
            local stancebar = CreateFrame("Frame", nil, UIParent)
            stancebar:Hide()
            ShapeshiftBarFrame:UnregisterAllEvents()
            ShapeshiftBarFrame:SetParent(stancebar)
        end

        if (not ExadTweaks.db.ThickFrames or not ExadTweaks.db.AsuriFrame) and (ExadTweaks.db.ClassBG or ExadTweaks.db.transparent) then
            hooksecurefunc("TargetFrame_CheckFaction", function(self)
                if ExadTweaks.db.ClassBG and UnitIsPlayer(self.unit) then
                    local _, class = UnitClass(self.unit)
                    local c = RAID_CLASS_COLORS[class]
                    if c then
                        self.nameBackground:SetVertexColor(c.r, c.g, c.b)
                    end
                else
                    self.nameBackground:SetVertexColor(0, 0, 0, 0.5)
                end
            end)
        end

        if ExadTweaks.db.ClassBG and not ExadTweaks.db.AsuriFrame then
            if PlayerFrame:IsShown() and not PlayerFrame.bg then
                local _, class = UnitClass("player")
                local c = RAID_CLASS_COLORS[class]
                local bg = PlayerFrame:CreateTexture()
                bg:SetPoint("TOPLEFT", PlayerFrameBackground)
                bg:SetPoint("BOTTOMRIGHT", PlayerFrameBackground, 0, 22)
                bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
                if c then
                    bg:SetVertexColor(c.r, c.g, c.b)
                end
                PlayerFrame.bg = true
            end
            TargetFrameNameBackground:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
            if FocusFrame then
                FocusFrameNameBackground:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
            end
        end

        if ExadTweaks.db.AutoReady then
            ReadyCheckFrame:HookScript("OnShow", function(self)
                ReadyCheckFrameYesButton:Click()
            end)
        end
        if ExadTweaks.db.BuffAlpha then
            hooksecurefunc("AuraButton_OnUpdate", function(self)
                if self:GetAlpha() < 1 then
                    self:SetAlpha(1)
                end
            end)
        end

        if ExadTweaks.db.RangeIndicator and not (IsAddOnLoaded("Bartender4") or IsAddOnLoaded("tullaRange")) then
            hooksecurefunc("ActionButton_OnUpdate", RangeIndicator)
        end

        if ExadTweaks.db.HidePetText then
            if PetFrameHealthBarText then
                PetFrameHealthBarText:SetAlpha(0)
            end
            if PetFrameManaBarText then
                PetFrameManaBarText:SetAlpha(0)
            end
        end

        OnLoad()

        if ExadTweaks.db.ThickFrames or ExadTweaks.db.AsuriFrame or ExadTweaks.db.NoLevel or (ExadTweaks.db.Colval < 0.3) or ExadTweaks.db.ClassNames then
            hooksecurefunc("TargetFrame_CheckClassification", CheckClassification)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if ExadTweaks.db.FadeIcon and not ExadTweaks.db.AsuriFrame then
            PvPIcon()
        end

        if ExadTweaks.db.HideHotkey or ExadTweaks.db.HideMacro then
            HideHotkeys()
        end
    end
end)

