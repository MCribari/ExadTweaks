local _, ExadTweaks = ...
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local IsInInstance = IsInInstance
local GetText, UnitIsGhost = GetText, UnitIsGhost
local activePlates = {}
local currentPlate, highlightBorder = nil, nil

if not C_NamePlate then return end

local function AddElements(plate, unit)
    local _, castBar = plate:GetChildren()
    local _, border, cbborder, _, _, overlay, name, levelText, bossicon, raidicon, elite = plate:GetRegions()

    plate.castBar = castBar
    plate.unit = unit
    name:Hide()
    --name:ClearAllPoints()
    --name:SetPoint("CENTER", UIParent, "CENTER", 10000, 10000)
    --plate.name = name

    -- Create name
    if not plate.newName then
        local newName = plate:CreateFontString(nil, "ARTWORK")
        newName:SetFont(STANDARD_TEXT_FONT, 12)
        newName:SetWidth(150)
        newName:SetHeight(9)
        newName:SetPoint("BOTTOM", border, "TOP", 0, -15)
        newName:SetTextColor(1, 1, 1)
        plate.newName = newName
    end

    -- Create castBar text
    if not plate.castText then
        plate.castText = plate:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
        plate.castText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        plate.castText:SetSize(120, 16)
        plate.castText:SetPoint("CENTER", plate.castBar, "CENTER", 0, 1)
    end

    -- Set name
    plate.newName :SetText(name:GetText())

    -- Hide stuff
    bossicon:SetAlpha(0)
    raidicon:SetAlpha(0)
    elite:SetAlpha(0)

    -- Color border
    border:SetVertexColor(ExadTweaks.db.Colval, ExadTweaks.db.Colval, ExadTweaks.db.Colval)

    plate.cbborder = cbborder

    -- Extra mods
    if ExadTweaks.db.ModPlates and not ExadTweaks.db.AsuriFrame then
        plate.newName:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        levelText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        plate.newName:ClearAllPoints()
        plate.newName:SetPoint("BOTTOM", border, "TOP", 0, -17)
    else
        plate.newName:SetFont(STANDARD_TEXT_FONT, 12)
        plate.newName:ClearAllPoints()
        plate.newName:SetPoint("BOTTOM", border, "TOP", 0, -15)
    end

    if ExadTweaks.db.NoLevel or ExadTweaks.db.AsuriFrame then
        if border then
            border:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\nolevel\\Nameplate-Border-nolevel")
        end

        if levelText then
            levelText:Hide()
            levelText:SetAlpha(0)
        end

        -- Adjust healthbar size
        local HealthBar = plate:GetChildren()
        if HealthBar then
            HealthBar:SetWidth(148)
        end

        -- Adjust overlay size
        overlay:ClearAllPoints()
        overlay:SetPoint("TOPLEFT", plate, "TOPLEFT", 0, 0)
        overlay:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", 24, 0)
    end

    -- Arena numbers
    local _, type = IsInInstance()
    if ExadTweaks.db.ArenaNumbers and type == "arena" then
        for i = 1, 5 do
            if UnitIsUnit(unit, "arena" .. i) then
                plate.newName:SetText(i)
                plate.newName:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
                plate.newName:ClearAllPoints()
                plate.newName:SetPoint("BOTTOM", plate, "TOP", 0, -15)
                levelText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            end
        end
    end
end

local function HighlightTargetPlate()
    highlightBorder:Hide()
    currentPlate = nil

    local plate = UnitExists("target") and C_NamePlate.GetNamePlateForUnit("target")
    if plate and plate:IsShown() and UnitIsUnit("target", plate.unit or "") then
        highlightBorder:SetParent(plate)
        highlightBorder:SetAllPoints(plate)
        highlightBorder:SetFrameLevel(plate:GetFrameLevel() + 1)
        highlightBorder:SetAlpha(0.9)
        highlightBorder:Show()
        currentPlate = plate
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if not ExadTweaks.db.ModPlates and not ExadTweaks.db.AsuriFrame then
            self:UnregisterAllEvents()
            self:Hide()
            return
        end
        if ExadTweaks.db.ModPlates then
            highlightBorder = CreateFrame("Frame")
            highlightBorder:SetFrameStrata("HIGH")
            highlightBorder:Hide()

            local borderTexture = highlightBorder:CreateTexture(nil, "OVERLAY")
            borderTexture:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\Nameplate-highlight")
            borderTexture:SetAllPoints(highlightBorder)
            borderTexture:SetVertexColor(1, 1, 1)

            self:RegisterEvent("PLAYER_TARGET_CHANGED")
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        HighlightTargetPlate()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        wipe(activePlates)
        return
    end

    local unit = ...
    if not unit then return end

    local plate =  C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then
        return
    end

    if event == "NAME_PLATE_UNIT_ADDED" then
        AddElements(plate, unit)
        activePlates[plate] = true

        if ExadTweaks.db.ModPlates and UnitIsUnit("target", unit) then
            HighlightTargetPlate()
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        activePlates[plate] = nil

        if ExadTweaks.db.ModPlates and currentPlate and currentPlate.unit == unit then
            highlightBorder:Hide()
            currentPlate = nil
        end
    end
end)

frame:SetScript("OnUpdate", function()
    for plate in pairs(activePlates) do
        if plate and plate:IsShown() then

            -- Preserve coloring
            --if plate.newName:GetText() == plate.name:GetText() then
            --    plate.newName:SetTextColor(plate.name:GetTextColor())
            --end

            -- Unit is a ghost.. why show a plate?
            if UnitIsGhost(plate.unit) then
                plate:SetAlpha(0)
            else
                plate:SetAlpha(1)
            end

            -- Set cast text
            local cb = plate.castBar
            if not cb or not plate.castText then return end

            if cb:IsShown() then
                local name, _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(plate.unit)
                if not name then
                    name, _, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(plate.unit)
                end

                if name then
                    if plate.cbborder then
                        plate.cbborder:SetVertexColor(ExadTweaks.db.Colval, ExadTweaks.db.Colval, ExadTweaks.db.Colval)
                    end

                    plate.castText:SetText(name)
                    if not plate.castText:IsShown() then
                        plate.castText:Show()
                    end
                else
                    plate.castText:SetText("")
                    if plate.castText:IsShown() then
                        plate.castText:Hide()
                    end
                end
            else
                plate.castText:SetText("")
                if plate.castText:IsShown() then
                    plate.castText:Hide()
                end
            end
        end
    end
end)