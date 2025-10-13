local _, ExadTweaks = ...
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

local MM = CreateFrame("Frame")
MM:RegisterEvent("ADDON_LOADED")
MM:SetScript("OnEvent", function(self, event, addon)
    -- Validación inicial crítica
    if not ExadTweaks or not ExadTweaks.db or not ExadTweaks.db.Colval then 
        return 
    end
    
    local colVal = ExadTweaks.db.Colval

    if not (IsAddOnLoaded("SexyMap") or (IsAddOnLoaded("Leatrix_Plus") and LeaPlusDB and LeaPlusDB["MinimapModder"] == "On")) and addon == "Blizzard_TimeManager" then
        -- Protección para TimeManagerClockButton
        if TimeManagerClockButton then
            local success, region = pcall(TimeManagerClockButton.GetRegions, TimeManagerClockButton)
            if success and region and region.SetVertexColor then
                region:SetVertexColor(colVal, colVal, colVal)
            end
        end

        if not ExadTweaks.db.minimapChanges then
            if MinimapBorderTop and MinimapBorderTop.SetVertexColor then
                MinimapBorderTop:SetVertexColor(colVal, colVal, colVal)
            end
            return
        end

        -- Hide stuff con protección
        if MiniMapWorldMapButton and MiniMapWorldMapButton.Show and MiniMapWorldMapButton.Hide then
            hooksecurefunc(MiniMapWorldMapButton, "Show", function() 
                if MiniMapWorldMapButton then
                    MiniMapWorldMapButton:Hide() 
                end
            end)
        end

        if MinimapNorthTag and MinimapNorthTag.Show and MinimapNorthTag.Hide then
            hooksecurefunc(MinimapNorthTag, "Show", function() 
                if MinimapNorthTag then
                    MinimapNorthTag:Hide() 
                end
            end)
        end

        -- Ocultar elementos con verificación
        local elementsToHide = {
            MinimapBorderTop,
            MinimapToggleButton,
            MinimapZoomIn,
            MinimapZoomOut,
            MinimapNorthTag,
            MiniMapMailBorder,
            MinimapBorder,
            MiniMapWorldMapButton,
        }
        
        for _, v in pairs(elementsToHide) do
            if v and v.Hide and v.SetAlpha then
                pcall(v.Hide, v)
                pcall(v.SetAlpha, v, 0)
            end
        end

        -- Zoom in with mousewheel con protección completa
        if Minimap and Minimap.EnableMouseWheel and Minimap.SetScript then
            pcall(Minimap.EnableMouseWheel, Minimap, true)
            Minimap:SetScript('OnMouseWheel', function(minimap, delta)
                if not minimap or not minimap.GetZoom or not minimap.SetZoom then return end
                
                local currentZoom = minimap:GetZoom()
                if not currentZoom then return end
                
                if delta > 0 and currentZoom < 5 then
                    minimap:SetZoom(currentZoom + 1)
                elseif delta < 0 and currentZoom > 0 then
                    minimap:SetZoom(currentZoom - 1)
                end
            end)
        end

        if MiniMapTracking and MiniMapTracking.Hide then
            MiniMapTracking:Hide()
            if Minimap and Minimap.SetScript then
                Minimap:SetScript("OnMouseUp", function(minimap, btn)
                    if btn == "RightButton" and ToggleDropDownMenu then
                        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MiniMapTracking", 0, -5)
                    elseif Minimap_OnClick then
                        Minimap_OnClick(minimap)
                    end
                end)
            end
        end

        if MiniMapMailFrame and MiniMapMailFrame.ClearAllPoints and MiniMapMailFrame.SetPoint then
            MiniMapMailFrame:ClearAllPoints()
            MiniMapMailFrame:SetPoint("TOPLEFT", -6, 0)
        end
        
        if MiniMapMailIcon and MiniMapMailIcon.SetTexture then
            MiniMapMailIcon:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\mailicon")
        end

        -- Square minimap con validaciones
        local MinimapSize = 175
        if Minimap and Minimap.SetMaskTexture and Minimap.SetSize then
            pcall(Minimap.SetMaskTexture, Minimap, "Interface\\AddOns\\ExadTweaks\\textures\\rectangle")
            
            if MinimapBorderTop and MinimapBorderTop.SetTexture then
                pcall(MinimapBorderTop.SetTexture, MinimapBorderTop, 0)
            end
            
            Minimap:SetSize(MinimapSize, MinimapSize)
            
            if Minimap.SetHitRectInsets then
                Minimap:SetHitRectInsets(0, 0, 24, 24)
            end
            
            local success, p, r, rp, ofx, ofy = pcall(Minimap.GetPoint, Minimap)
            if success and p then
                Minimap:ClearAllPoints()
                Minimap:SetPoint(p, r, rp, ofx - 10, ofy)
            end
        end

        -- New border
        if not Minimap then return end
        
        local bg = CreateFrame("Frame", nil, Minimap)
        if bg then
            bg:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -21)
            bg:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 1, 21)
            bg:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\CHATFRAMEBACKGROUND", edgeSize = 2 })
            bg:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.7)
            bg:SetBackdropColor(0.1, 0.1, 0.1)
        end

        local topbg
        if MinimapCluster then
            topbg = CreateFrame("Frame", nil, MinimapCluster)
            topbg:SetParent(MinimapCluster)
            topbg:SetPoint("TOP", Minimap, "BOTTOM", 0, 21)
            topbg:SetSize(MinimapSize + 2, 15)
            topbg:SetBackdrop({ 
                bgFile = "Interface\\ChatFrame\\CHATFRAMEBACKGROUND", 
                edgeFile = "Interface\\ChatFrame\\CHATFRAMEBACKGROUND", 
                edgeSize = 2 
            })
            topbg:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.5)
            topbg:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
            topbg:EnableMouse(false)
        else
            return
        end

        -- Clock con múltiples validaciones
        if TimeManagerClockTicker and MinimapZoneTextButton and topbg then
            TimeManagerClockTicker:SetParent(MinimapZoneTextButton)
            if TimeManagerClockTicker.SetFont then
                TimeManagerClockTicker:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            end
            TimeManagerClockTicker:ClearAllPoints()
            TimeManagerClockTicker:SetPoint("LEFT", topbg, "LEFT", 2, 0)
            if TimeManagerClockTicker.SetJustifyH then
                TimeManagerClockTicker:SetJustifyH("LEFT")
            end
        end
        
        if TimeManagerClockButton and MinimapZoneTextButton and MinimapZoneText then
            TimeManagerClockButton:SetParent(MinimapZoneTextButton)
            if TimeManagerClockButton.SetAlpha then
                TimeManagerClockButton:SetAlpha(0)
            end
            TimeManagerClockButton:ClearAllPoints()
            if TimeManagerClockButton.SetWidth then
                TimeManagerClockButton:SetWidth(42)
            end
            TimeManagerClockButton:SetPoint("LEFT", MinimapZoneText, "LEFT", -52, 0)
        end

        -- ZoneText con validaciones
        if MinimapZoneText then
            if MinimapZoneText.SetFont then
                MinimapZoneText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            end
            if MinimapZoneText.SetJustifyH then
                MinimapZoneText:SetJustifyH("RIGHT")
            end
            if MinimapZoneText.SetWidth then
                MinimapZoneText:SetWidth(120)
            end
            MinimapZoneText:ClearAllPoints()
            MinimapZoneText:SetPoint("RIGHT", topbg, "RIGHT", 0, 0)
        end
        
        if MinimapZoneTextButton and ToggleMinimap then
            MinimapZoneTextButton:HookScript("OnClick", function()
                pcall(ToggleMinimap)
            end)
            MinimapZoneTextButton:ClearAllPoints()
            MinimapZoneTextButton:SetPoint("RIGHT", topbg, "RIGHT", 2, -1)
        end

        -- PVP Button
        if MiniMapBattlefieldBorder and MiniMapBattlefieldBorder.Hide then
            MiniMapBattlefieldBorder:Hide()
        end
        
        if MiniMapBattlefieldFrame then
            MiniMapBattlefieldFrame:ClearAllPoints()
            MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -5, 20)
        end

        -- Instance Difficulty
        if MiniMapInstanceDifficulty and MiniMapInstanceDifficulty.GetPoint then
            local success, r, p, re, xoff, yoff = pcall(MiniMapInstanceDifficulty.GetPoint, MiniMapInstanceDifficulty)
            if success and r then
                MiniMapInstanceDifficulty:SetParent(Minimap)
                MiniMapInstanceDifficulty:ClearAllPoints()
                MiniMapInstanceDifficulty:SetPoint(r, p, re, 2.5, yoff)
            end
        end

        -- Reposition LFG Button
        if MiniMapLFGFrame then
            MiniMapLFGFrame:ClearAllPoints()
            MiniMapLFGFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -14, -6)
            if MiniMapLFGFrameBorder and MiniMapLFGFrameBorder.Hide then
                MiniMapLFGFrameBorder:Hide()
            end
        end

        -- GameTimeFrame
        if GameTimeFrame then
            if GameTimeFrame.SetNormalTexture then
                GameTimeFrame:SetNormalTexture("Interface\\AddOns\\ExadTweaks\\textures\\cal")
            end
            if GameTimeFrame.SetPushedTexture then
                GameTimeFrame:SetPushedTexture("")
            end
            if GameTimeFrame.SetHighlightTexture then
                GameTimeFrame:SetHighlightTexture("")
            end
            if GameTimeFrame.SetScale then
                GameTimeFrame:SetScale(0.8)
            end
            
            local success, r, p, re, xoff, yoff = pcall(GameTimeFrame.GetPoint, GameTimeFrame, 1)
            if success and r then
                GameTimeFrame:ClearAllPoints()
                GameTimeFrame:SetPoint(r, p, re, xoff, yoff - 30)
            end
            
            if GameTimeFrame.SetAlpha then
                GameTimeFrame:SetAlpha(0)
            end
            
            GameTimeFrame:HookScript("OnEnter", function(frame) 
                if frame and frame.SetAlpha then
                    frame:SetAlpha(1) 
                end
            end)
            GameTimeFrame:HookScript("OnLeave", function(frame) 
                if frame and frame.SetAlpha then
                    frame:SetAlpha(0) 
                end
            end)
        end

        -- Move Buffs
        if ConsolidatedBuffs and ConsolidatedBuffs.GetPoint and UIParent then
            local success, r, p, re, xoff, yoff = pcall(ConsolidatedBuffs.GetPoint, ConsolidatedBuffs)
            if success and r == "TOPRIGHT" and p == UIParent and re == "TOPRIGHT" and math.ceil(xoff) == -180 and math.ceil(yoff) == -13 then
                ConsolidatedBuffs:ClearAllPoints()
                ConsolidatedBuffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -205, -27)
            end
        end

        -- Disable cluster clicks
        if MinimapCluster and MinimapCluster.EnableMouse then
            MinimapCluster:EnableMouse(false)
        end

        -- Tracking fix con protección total
        if MiniMapTrackingIcon and GetTrackingTexture then
            local success, trackingTexture = pcall(GetTrackingTexture)
            if success and trackingTexture ~= nil then
                if MiniMapTrackingIcon.GetTexture then
                    local currentTexture = MiniMapTrackingIcon:GetTexture()
                    if not currentTexture and MiniMapTrackingIcon.SetTexture then
                        MiniMapTrackingIcon:SetTexture(trackingTexture)
                        if MiniMapTracking and MiniMapTracking.Show then
                            MiniMapTracking:Show()
                        end
                    end
                end
            end
        end

        if MiniMapTracking and MiniMapTrackingBorder then
            if MiniMapTrackingBorder.SetAtlas then
                pcall(MiniMapTrackingBorder.SetAtlas, MiniMapTrackingBorder, "Forge-ColorSwatchBorder", true)
            end
            if MiniMapTrackingBorder.SetSize then
                MiniMapTrackingBorder:SetSize(22, 22)
            end
            MiniMapTrackingBorder:ClearAllPoints()
            MiniMapTrackingBorder:SetPoint("CENTER", MiniMapTracking, "CENTER")

            if MiniMapTrackingIcon then
                if MiniMapTrackingIcon.SetSize then
                    MiniMapTrackingIcon:SetSize(16, 16)
                end
                MiniMapTrackingIcon:ClearAllPoints()
                MiniMapTrackingIcon:SetPoint("CENTER", MiniMapTracking, "CENTER")
                if MiniMapTrackingIcon.SetTexCoord then
                    MiniMapTrackingIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                end
            end

            if MinimapBackdrop then
                MiniMapTracking:ClearAllPoints()
                MiniMapTracking:SetPoint("TOPLEFT", MinimapBackdrop, "LEFT", -5, -26)
            end
        end

        -- Re-anchor all buttons
        local buttonsPerRow = 6
        local spacing = 32
        local showingButtons = false

        local buttonAnchor = CreateFrame("Frame", "RougeMMAnchor", MinimapCluster)
        buttonAnchor:SetPoint("TOPLEFT", topbg, "BOTTOMLEFT", -2, 0)
        buttonAnchor:SetSize(1, 1)
        buttonAnchor:Hide()

        local function GetAllLibDBIconButtons()
            local results = {}
            if not _G then return results end
            
            for key, frame in pairs(_G) do
                local success = pcall(function()
                    if type(frame) == "table"
                            and type(frame.GetName) == "function"
                            and frame:GetName()
                            and type(frame:GetName()) == "string"
                            and frame:GetName():match("^LibDBIcon10_")
                            and type(frame.SetPoint) == "function" then
                        table.insert(results, frame)
                    end
                end)
            end
            return results
        end

        local function ShowMinimapButtons()
            local row, col = 0, 0
            local buttons = GetAllLibDBIconButtons()
            local prevButton

            for _, button in ipairs(buttons) do
                pcall(function()
                    if button and button.GetName then
                        local name = button:GetName()
                        if name ~= prevButton then
                            prevButton = name
                            button:ClearAllPoints()
                            button:SetParent(buttonAnchor)
                            button:SetPoint("TOPLEFT", buttonAnchor, "TOPLEFT", col * spacing, -row * spacing)
                            if button.Show then
                                button:Show()
                            end

                            col = col + 1
                            if col >= buttonsPerRow then
                                col = 0
                                row = row + 1
                            end
                        end
                    end
                end)
            end

            if #buttons > 0 then
                buttonAnchor:Show()
            end
        end

        local function HideMinimapButtons()
            local buttons = GetAllLibDBIconButtons()
            for _, button in ipairs(buttons) do
                pcall(function()
                    if button and button.Hide then
                        button:Hide()
                    end
                end)
            end
            buttonAnchor:Hide()
        end

        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                pcall(ShowMinimapButtons)
                buttonAnchor:Hide()

                local buttons = GetAllLibDBIconButtons()
                for _, button in ipairs(buttons) do
                    pcall(function()
                        if not button or not button.GetName then return end
                        local name = button:GetName()

                        if button == _G["LibDBIcon10_BugSack"] and _G["BugSackLDB"] then
                            local btn = _G["BugSackLDB"]
                            if btn and btn.Update then
                                hooksecurefunc(btn, "Update", function()
                                    pcall(function()
                                        if not buttonAnchor:IsShown() then
                                            if btn.icon == "Interface\\AddOns\\BugSack\\Media\\icon_red" then
                                                button:ClearAllPoints()
                                                button:SetParent(Minimap)
                                                button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 10, -5)
                                                if button.SetFrameLevel then
                                                    button:SetFrameLevel(999)
                                                end
                                                if button.Show then
                                                    button:Show()
                                                end
                                            elseif btn.icon == "Interface\\AddOns\\BugSack\\Media\\icon" then
                                                ShowMinimapButtons()
                                                buttonAnchor:Hide()
                                            end
                                        end
                                    end)
                                end)
                            end
                        end

                        local success, regions = pcall(button.GetRegions, button)
                        if not success then return end
                        
                        local regionsTable = {regions}
                        local icon = regionsTable[3]
                        local borderIcon = regionsTable[2]

                        if borderIcon and borderIcon.IsObjectType and borderIcon:IsObjectType("Texture") then
                            if borderIcon.SetTexture then
                                borderIcon:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\artifactforge")
                            end
                            if borderIcon.SetTexCoord then
                                borderIcon:SetTexCoord(0.216797, 0.324219, 0.826172, 0.879883)
                            end
                            borderIcon:ClearAllPoints()
                            borderIcon:SetPoint("CENTER", button, "CENTER")
                            if borderIcon.SetSize then
                                borderIcon:SetSize(28, 28)
                            end
                            if borderIcon.SetDrawLayer then
                                borderIcon:SetDrawLayer("OVERLAY", 1)
                            end
                            if borderIcon.Show then
                                borderIcon:Show()
                            end
                            if borderIcon.SetVertexColor then
                                borderIcon:SetVertexColor(0.1, 0.1, 0.1, 1.0)
                            end
                        end

                        if icon and icon.IsObjectType and icon:IsObjectType("Texture") then
                            icon:ClearAllPoints()
                            icon:SetPoint("CENTER", button, "CENTER")
                            if icon.SetSize then
                                icon:SetSize(22, 22)
                            end
                            if icon.SetTexCoord then
                                icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                            end
                        end
                    end)
                end
            end)
        end

        local toggleTrigger = CreateFrame("Frame", nil, topbg)
        toggleTrigger:SetSize(21, 21)
        toggleTrigger:SetPoint("BOTTOMRIGHT", topbg, "BOTTOMRIGHT", 2, 12)
        toggleTrigger:EnableMouse(true)

        local iconTexture = toggleTrigger:CreateTexture(nil, "OVERLAY")
        iconTexture:SetAllPoints()
        iconTexture:SetTexture("Interface\\AddOns\\ExadTweaks\\textures\\transmogrify")
        iconTexture:SetSize(36, 30)
        iconTexture:SetTexCoord(0.507812, 0.578125, 0.300781, 0.359375)
        iconTexture:Show()

        if C_Timer and C_Timer.After then
            C_Timer.After(45, function()
                if toggleTrigger and toggleTrigger.SetAlpha then
                    toggleTrigger:SetAlpha(0)
                end
            end)
        end

        toggleTrigger:SetScript("OnMouseUp", function()
            showingButtons = not showingButtons
            if showingButtons then
                buttonAnchor:Show()
            else
                buttonAnchor:Hide()
            end
        end)

        toggleTrigger:SetScript("OnEnter", function(trigger)
            if GameTooltip then
                GameTooltip:SetOwner(toggleTrigger, "ANCHOR_TOPRIGHT")
                GameTooltip:SetText("Click to show or hide minimap buttons", 1, 1, 1)
                GameTooltip:Show()
            end
            if trigger and trigger.SetAlpha then
                trigger:SetAlpha(1)
            end
        end)

        toggleTrigger:SetScript("OnLeave", function(trigger)
            if GameTooltip and GameTooltip.Hide then
                GameTooltip:Hide()
            end
            if trigger and trigger.SetAlpha then
                trigger:SetAlpha(0)
            end
        end)

        -- Re-position bar when shown/hidden
        if Minimap and Minimap.HookScript then
            Minimap:HookScript("OnShow", function()
                if topbg then
                    topbg:ClearAllPoints()
                    topbg:SetPoint("TOP", Minimap, "BOTTOM", 0, 21)
                end

                if toggleTrigger then
                    toggleTrigger:ClearAllPoints()
                    toggleTrigger:SetPoint("BOTTOMRIGHT", topbg, "BOTTOMRIGHT", 2, 12)
                end
            end)

            Minimap:HookScript("OnHide", function()
                if topbg and MinimapCluster then
                    topbg:ClearAllPoints()
                    topbg:SetPoint("TOP", MinimapCluster, "TOP", 0, -25)
                end

                if toggleTrigger then
                    toggleTrigger:ClearAllPoints()
                    toggleTrigger:SetPoint("TOPLEFT", topbg, "TOPLEFT", -20, 3)
                    if toggleTrigger.SetAlpha then
                        toggleTrigger:SetAlpha(1)
                    end
                    if C_Timer and C_Timer.After then
                        C_Timer.After(5, function()
                            if toggleTrigger and toggleTrigger.SetAlpha then
                                toggleTrigger:SetAlpha(0)
                            end
                        end)
                    end
                end
            end)
        end

        -- Ping snitch con protección completa
        local pingTicker
        if Minimap and Minimap.RegisterEvent and Minimap.HookScript then
            Minimap:RegisterEvent("MINIMAP_PING")
            Minimap:HookScript("OnEvent", function(map, evt, unit)
                pcall(function()
                    if evt == "MINIMAP_PING" and unit ~= "player" and UnitName then
                        local name = UnitName(unit)
                        if name and MinimapZoneText and MinimapZoneText.SetText then
                            MinimapZoneText:SetText(name)

                            if UnitClass then
                                local _, class = UnitClass(unit)
                                local c = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class]) or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[class])
                                if c and MinimapZoneText.SetTextColor then
                                    MinimapZoneText:SetTextColor(c.r, c.g, c.b)
                                end
                            end

                            if pingTicker and pingTicker.Cancel then
                                pingTicker:Cancel()
                            end

                            if C_Timer and C_Timer.NewTimer and Minimap_Update then
                                pingTicker = C_Timer.NewTimer(2, function()
                                    pcall(Minimap_Update)
                                    pingTicker = nil
                                end)
                            end
                        end
                    end
                end)
            end)
        end

        -- for other addons
        function GetMinimapShape()
            return "SQUARE"
        end
        
    elseif not (IsAddOnLoaded("SexyMap")) and addon == "Blizzard_GroupFinder_VanillaStyle" then
        if not ExadTweaks.db.minimapChanges then
            if LFGMinimapFrameBorder and LFGMinimapFrameBorder.SetVertexColor then
                LFGMinimapFrameBorder:SetVertexColor(colVal, colVal, colVal)
            end
        else
            local frame = LFGMinimapFrame
            if frame then
                if C_LFGList and not C_LFGList.HasActiveEntryInfo() then
                    if frame.SetAlpha then
                        frame:SetAlpha(0)
                    end
                end

                local borderName = frame:GetName() and (frame:GetName() .. "Border")
                local border = borderName and _G[borderName]
                if border and border.Hide then
                    border:Hide()
                end

                -- Move to topleft corner
                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -14, -6)

                -- Mouseover hide/show
                frame:HookScript("OnEnter", function(f)
                    if f and f.GetAlpha and f.SetAlpha and f:GetAlpha() < 1 then
                        f:SetAlpha(1)
                    end
                end)

                frame:HookScript("OnLeave", function(f)
                    if C_LFGList and not C_LFGList.HasActiveEntryInfo() then
                        if f and f.SetAlpha then
                            f:SetAlpha(0)
                        end
                    end
                end)

                -- Hide by default, show when actively searching
                frame:HookScript("OnEvent", function(f, evt)
                    if evt == "LFG_LIST_ACTIVE_ENTRY_UPDATE" and C_LFGList then
                        if f and f.SetAlpha then
                            if C_LFGList.HasActiveEntryInfo() then
                                f:SetAlpha(1)
                            else
                                f:SetAlpha(0)
                            end
                        end
                    end
                end)
            end
        end
    end
end)