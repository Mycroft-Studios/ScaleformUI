UIMenu = setmetatable({}, UIMenu)
UIMenu.__index = UIMenu
UIMenu.__call = function()
    return "UIMenu"
end

---New
---@param Title string
---@param Subtitle string
---@param X number
---@param Y number
---@param TxtDictionary string
---@param TxtName string
---@param Heading number
---@param R number
---@param G number
---@param B number
---@param A number
function UIMenu.New(Title, Subtitle, X, Y, TxtDictionary, TxtName)
    local X, Y = tonumber(X) or 0, tonumber(Y) or 0
    if Title ~= nil then
        Title = tostring(Title) or ""
    else
        Title = ""
    end
    if Subtitle ~= nil then
        Subtitle = tostring(Subtitle) or ""
    else
        Subtitle = ""
    end
    if TxtDictionary ~= nil then
        TxtDictionary = tostring(TxtDictionary) or "commonmenu"
    else
        TxtDictionary = "commonmenu"
    end
    if TxtName ~= nil then
        TxtName = tostring(TxtName) or "interaction_bgd"
    else
        TxtName = "interaction_bgd"
    end
    local _UIMenu = {
        Title = Title,
        Subtitle = Subtitle,
        Position = { X = X, Y = Y },
        Pagination = { Min = 0, Max = 7, Total = 7 },
        Extra = {},
        Description = {},
        Items = {},
        Windows = {},
        Children = {},
        _menuGlare = 0,
        Controls = {
            Back = {
                Enabled = true,
            },
            Select = {
                Enabled = true,
            },
            Left = {
                Enabled = true,
            },
            Right = {
                Enabled = true,
            },
            Up = {
                Enabled = true,
            },
            Down = {
                Enabled = true,
            },
        },
        ParentMenu = nil,
        ParentItem = nil,
        _Visible = false,
        ActiveItem = 1000,
        Dirty = false,
        ReDraw = true,
        InstructionalButtons = {},
        OnIndexChange = function(menu, newindex)
        end,
        OnListChange = function(menu, list, newindex)
        end,
        OnSliderChange = function(menu, slider, newindex)
        end,
        OnProgressChange = function(menu, progress, newindex)
        end,
        OnCheckboxChange = function(menu, item, checked)
        end,
        OnListSelect = function(menu, list, index)
        end,
        OnSliderSelect = function(menu, slider, index)
        end,
        OnProgressSelect = function(menu, progress, index)
        end,
        OnItemSelect = function(menu, item, index)
        end,
        OnMenuChanged = function(oldmenu, newmenu, change)
        end,
        Settings = {
            InstructionalButtons = true,
            MultilineFormats = true,
            ScaleWithSafezone = true,
            ResetCursorOnOpen = true,
            MouseControlsEnabled = true,
            MouseEdgeEnabled = true,
            ControlDisablingEnabled = true,
            Audio = {
                Library = "HUD_FRONTEND_DEFAULT_SOUNDSET",
                UpDown = "NAV_UP_DOWN",
                LeftRight = "NAV_LEFT_RIGHT",
                Select = "SELECT",
                Back = "BACK",
                Error = "ERROR",
            },
            EnabledControls = {
                Controller = {
                    { 0, 2 }, -- Look Up and Down
                    { 0, 1 }, -- Look Left and Right
                    { 0, 25 }, -- Aim
                    { 0, 24 }, -- Attack
                },
                Keyboard = {
                    { 0, 201 }, -- Select
                    { 0, 195 }, -- X axis
                    { 0, 196 }, -- Y axis
                    { 0, 187 }, -- Down
                    { 0, 188 }, -- Up
                    { 0, 189 }, -- Left
                    { 0, 190 }, -- Right
                    { 0, 202 }, -- Back
                    { 0, 217 }, -- Select
                    { 0, 242 }, -- Scroll down
                    { 0, 241 }, -- Scroll up
                    { 0, 239 }, -- Cursor X
                    { 0, 240 }, -- Cursor Y
                    { 0, 31 }, -- Move Up and Down
                    { 0, 30 }, -- Move Left and Right
                    { 0, 21 }, -- Sprint
                    { 0, 22 }, -- Jump
                    { 0, 23 }, -- Enter
                    { 0, 75 }, -- Exit Vehicle
                    { 0, 71 }, -- Accelerate Vehicle
                    { 0, 72 }, -- Vehicle Brake
                    { 0, 59 }, -- Move Vehicle Left and Right
                    { 0, 89 }, -- Fly Yaw Left
                    { 0, 9 }, -- Fly Left and Right
                    { 0, 8 }, -- Fly Up and Down
                    { 0, 90 }, -- Fly Yaw Right
                    { 0, 76 }, -- Vehicle Handbrake
                },
            },
        }
    }

    if Subtitle ~= "" and Subtitle ~= nil then
        _UIMenu.Subtitle = Subtitle
    end
    _UIMenu._menuGlare = Scaleform.Request("mp_menu_glare")
    return setmetatable(_UIMenu, UIMenu)
end

---DisEnableControls
---@param bool boolean
function UIMenu:DisEnableControls(bool)
    if bool then
        EnableAllControlActions(2)
    else
        DisableAllControlActions(2)
    end

    if bool then
        return
    else
        if not IsInputDisabled(2) then
            for Index = 1, #self.Settings.EnabledControls.Controller do
                EnableControlAction(self.Settings.EnabledControls.Controller[Index][1], self.Settings.EnabledControls.Controller[Index][2], true)
            end
        else
            for Index = 1, #self.Settings.EnabledControls.Keyboard do
                EnableControlAction(self.Settings.EnabledControls.Keyboard[Index][1], self.Settings.EnabledControls.Keyboard[Index][2], true)
            end
        end
    end
end

---InstructionalButtons
---@param bool boolean
function UIMenu:InstructionalButtons(bool)
    if bool ~= nil then
        self.Settings.InstrucitonalButtons = tobool(bool)
    end
end

---SetBannerSprite
---@param Sprite string
---@param IncludeChildren boolean
function UIMenu:SetBannerSprite(Sprite, IncludeChildren)
    if Sprite() == "Sprite" then
        self.Logo = Sprite
        self.Logo:Size(431 + self.WidthOffset, 107)
        self.Logo:Position(self.Position.X, self.Position.Y)
        self.Banner = nil
        if IncludeChildren then
            for Item, Menu in pairs(self.Children) do
                Menu.Logo = Sprite
                Menu.Logo:Size(431 + self.WidthOffset, 107)
                Menu.Logo:Position(self.Position.X, self.Position.Y)
                Menu.Banner = nil
            end
        end
    end
end

---CurrentSelection
---@param value number
function UIMenu:CurrentSelection(value)
    if tonumber(value) then
        if #self.Items == 0 then
            self.ActiveItem = 0
        end
        self.Items[self:CurrentSelection()]:Selected(false)
        self.ActiveItem = 1000000 - (1000000 % #self.Items) + tonumber(value)
        if self:CurrentSelection() > self.Pagination.Max then
            self.Pagination.Min = self:CurrentSelection() - self.Pagination.Total
            self.Pagination.Max = self:CurrentSelection()
        elseif self:CurrentSelection() < self.Pagination.Min then
            self.Pagination.Min = self:CurrentSelection()
            self.Pagination.Max = self:CurrentSelection() + self.Pagination.Total
        end
    else
        if #self.Items == 0 then
            return 1
        else
            if self.ActiveItem % #self.Items == 0 then
                return 1
            else
                return self.ActiveItem % #self.Items + 1
            end
        end
    end
end


---AddWindow
---@param Window table
function UIMenu:AddWindow(Window)
    if Window() == "UIMenuWindow" then
        Window:SetParentMenu(self)
        table.insert(self.Windows, Window)
    end
end

---RemoveWindowAt
---@param Index table
function UIMenu:RemoveWindowAt(Index)
    if tonumber(Index) then
        if self.Windows[Index] then
            table.remove(self.Windows, Index)
        end
    end
end

---AddItem
---@param Item table
function UIMenu:AddItem(Item)
    if Item() == "UIMenuItem" then
        Item:SetParentMenu(self)
        table.insert(self.Items, Item)
    end
end

---RemoveItemAt
---@param Index table
function UIMenu:RemoveItemAt(Index)
    if tonumber(Index) then
        if self.Items[Index] then
            local SelectedItem = self:CurrentSelection()
            if #self.Items > self.Pagination.Total and self.Pagination.Max == #self.Items - 1 then
                self.Pagination.Min = self.Pagination.Min - 1
                self.Pagination.Max = self.Pagination.Max + 1
            end
            table.remove(self.Items, tonumber(Index))
            self:CurrentSelection(SelectedItem)
        end
    end
end

---RefreshIndex
function UIMenu:RefreshIndex()
    if #self.Items == 0 then
        self.ActiveItem = 1000
        self.Pagination.Max = self.Pagination.Total + 1
        self.Pagination.Min = 0
        return
    end
    self.Items[self:CurrentSelection()]:Selected(false)
    self.ActiveItem = 1000 - (1000 % #self.Items)
    self.Pagination.Max = self.Pagination.Total + 1
    self.Pagination.Min = 0
end

---Clear
function UIMenu:Clear()
    self.Items = {}
end

---Visible
---@param bool boolean
function UIMenu:Visible(bool)
    if bool ~= nil then
        self._Visible = tobool(bool)
        self.JustOpened = tobool(bool)
        self.Dirty = tobool(bool)

        if self.ParentMenu ~= nil then return end
        if #self.Children > 0 and self.Children[self.Items[self:CurrentSelection()]] ~= nil and self.Children[self.Items[self:CurrentSelection()]]:Visible() then return end
        if bool then
            self.OnMenuChanged(nil, self, "opened")
            self:BuildUpMenu()
        else
            self.OnMenuChanged(self, nil, "closed")
            ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL")
        end
        if self.Settings.ResetCursorOnOpen then
            local W, H = GetScreenResolution()
            SetCursorLocation(W / 2, H / 2)
        end
    else
        return self._Visible
    end
end

function UIMenu:LoadScaleform()
    RequestStreamedTextureDict("commonmenu", true)
    RequestStreamedTextureDict("pause_menu_pages_char_mom_dad", true)
    RequestStreamedTextureDict(TxtDictionary, true)
    RequestStreamedTextureDict("char_creator_portraits", true)

    while not HasStreamedTextureDictLoaded("commonmenu") and 
        not HasStreamedTextureDictLoaded("pause_menu_pages_char_mom_dad") and 
        not HasStreamedTextureDictLoaded(TxtDictionary) and 
        not HasStreamedTextureDictLoaded("char_creator_portraits") do
        Citizen.Wait(0)
    end
end

function UIMenu:BuildUpMenu()
    self:LoadScaleform()
    while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end
    ScaleformUI.Scaleforms._ui:CallFunction("CREATE_MENU", self.Title, self.Subtitle, self.TxtDictionary, self.TxtName)
    if #self.Windows > 0 then
       ScaleformUI.Scaleforms._ui:CallFunction("ADD_HERITAGE_WINDOW", Windows[1].Mom, Windows[1].Dad)
    end
    local timer = GetGameTimer()
    if #self.Items == 0 then
        while #self.Items == 0 do
            Citizen.Wait(0)
            if GetGameTimer() - timer > 150 then
                ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", self:CurrentSelection())
                SetStreamedTextureDictAsNoLongerNeeded(self.TxtDictionary)
                SetStreamedTextureDictAsNoLongerNeeded("commonmenu")
                SetStreamedTextureDictAsNoLongerNeeded("pause_menu_pages_char_mom_dad")
                SetStreamedTextureDictAsNoLongerNeeded("char_creator_portraits")
                return
            end
        end
    end
    for it, item in pairs (self.Items) do
        self:LoadScaleform()
        local Type, SubType = item()

        if SubType == "UIMenuListItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", 1, item:Label(), item:Description(), table.concat(item.Items, ","), item:Index()-1, item.Base.MainColor, item.Base.HighlightColor, item.Base.TextColor, item.Base.HighlightedTextColor, item:Enabled(), item:BlinkDescription())
        elseif SubType == "UIMenuCheckboxItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", 2, item:Label(), item:Description(), item.CheckBoxStyle, item._Checked, item.Base.MainColor, item.Base.HighlightColor, item.Base.TextColor, item.Base.HighlightedTextColor, item:Enabled(), item:BlinkDescription())
        elseif SubType == "UIMenuSliderItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", 3, item:Label(), item:Description(), item._Max, item._Multiplier, item:Index(), item.Base.MainColor, item.Base.HighlightColor, item.Base.TextColor, item.Base.HighlightedTextColor, item.BackgroundSliderColor, item.SliderColor, item._heritage, item:Enabled(), item:BlinkDescription())
        elseif SubType == "UIMenuProgressItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", 4, item:Label(), item:Description(), item._Max, item._Multiplier, item:Index(), item.Base.MainColor, item.Base.HighlightColor, item.Base.TextColor, item.Base.HighlightedTextColor, item.SliderColor, item:Enabled(), item:BlinkDescription())
        elseif SubType == "UIMenuStatsItem" then
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", 5, item:Label(), item:Description(), item:Index(), item._Type, item._Color, item.Base.MainColor, item.Base.HighlightColor, item.Base.TextColor, item.Base.HighlightedTextColor, item:Enabled(), item:BlinkDescription())
        else
            ScaleformUI.Scaleforms._ui:CallFunction("ADD_ITEM", 0, item:Label(), item:Description(), item.MainColor, item.HighlightColor, item.TextColor, item.HighlightedTextColor, item:Enabled(), item:BlinkDescription())
            ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_LABEL", it - 1, item:RightLabel())
            if item.RightBadge ~= BadgeStyle.NONE then
                ScaleformUI.Scaleforms._ui:CallFunction("SET_RIGHT_BADGE", it - 1, GetSpriteDictionary(item.RightBadge), item.RightBadge)
            end
        end
        if #item.Panels > 0 then
            for pan, panel in pairs (item.Panels) do
                local pType, pSubType = panel()
                if pSubType == "UIMenuColorPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", it, 0, panel.Title, panel.ColorPanelColorType, panel.CurrentSelection)
                elseif pSubType == "UIMenuPercentagePanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", it, 1, panel.Title, panel.Min, panel.Max, panel.Percentage)
                elseif pSubType == "UIMenuGridPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", it, 2, panel.TopLabel, panel.RightLabel, panel.LeftLabel, panel.BottomLabel, panel.CirclePosition.X, panel.CirclePosition.Y, true, panel.GridType)
                elseif pSubType == "UIMenuStatisticsPanel" then
                    ScaleformUI.Scaleforms._ui:CallFunction("ADD_PANEL", it, 3)
                    if sp.Items.Count > 0 then
                        for b,stat in pairs (panel.Items) do
                            ScaleformUI.Scaleforms._ui:CallFunction("ADD_STATISTIC_TO_PANEL", it, pan, stat:Text(), stat:Value())
                        end
                    end
                end
            end
        end
    end
    ScaleformUI.Scaleforms._ui:CallFunction("SET_CURRENT_ITEM", 0)
    SetStreamedTextureDictAsNoLongerNeeded(self.TxtDictionary)
    SetStreamedTextureDictAsNoLongerNeeded("commonmenu")
    SetStreamedTextureDictAsNoLongerNeeded("pause_menu_pages_char_mom_dad")
    SetStreamedTextureDictAsNoLongerNeeded("char_creator_portraits")
end

---ProcessControl
function UIMenu:ProcessControl()
    if not self._Visible then
        return
    end

    if self.JustOpened then
        self.JustOpened = false
        return
    end

    if self.Controls.Back.Enabled and (IsDisabledControlJustReleased(0, 177) or IsDisabledControlJustReleased(1, 177) or IsDisabledControlJustReleased(2, 177) or IsDisabledControlJustReleased(0, 199) or IsDisabledControlJustReleased(1, 199) or IsDisabledControlJustReleased(2, 199)) then
        self:GoBack()
    end

    if #self.Items == 0 then
        return
    end

    if not self.UpPressed then
        if self.Controls.Up.Enabled and (IsDisabledControlJustPressed(0, 172) or IsDisabledControlJustPressed(1, 172) or IsDisabledControlJustPressed(2, 172) or IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(1, 241) or IsDisabledControlJustPressed(2, 241) or IsDisabledControlJustPressed(2, 241)) then
            Citizen.CreateThread(function()
                self.UpPressed = true
                if #self.Items > self.Pagination.Total + 1 then
                    self:GoUpOverflow()
                else
                    self:GoUp()
                end
                Citizen.Wait(175)
                while self.Controls.Up.Enabled and (IsDisabledControlPressed(0, 172) or IsDisabledControlPressed(1, 172) or IsDisabledControlPressed(2, 172) or IsDisabledControlPressed(0, 241) or IsDisabledControlPressed(1, 241) or IsDisabledControlPressed(2, 241) or IsDisabledControlPressed(2, 241)) do
                    if #self.Items > self.Pagination.Total + 1 then
                        self:GoUpOverflow()
                    else
                        self:GoUp()
                    end
                    Citizen.Wait(125)
                end
                self.UpPressed = false
            end)
        end
    end

    if not self.DownPressed then
        if self.Controls.Down.Enabled and (IsDisabledControlJustPressed(0, 173) or IsDisabledControlJustPressed(1, 173) or IsDisabledControlJustPressed(2, 173) or IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(1, 242) or IsDisabledControlJustPressed(2, 242)) then
            Citizen.CreateThread(function()
                self.DownPressed = true
                if #self.Items > self.Pagination.Total + 1 then
                    self:GoDownOverflow()
                else
                    self:GoDown()
                end
                Citizen.Wait(175)
                while self.Controls.Down.Enabled and (IsDisabledControlPressed(0, 173) or IsDisabledControlPressed(1, 173) or IsDisabledControlPressed(2, 173) or IsDisabledControlPressed(0, 242) or IsDisabledControlPressed(1, 242) or IsDisabledControlPressed(2, 242)) do
                    if #self.Items > self.Pagination.Total + 1 then
                        self:GoDownOverflow()
                    else
                        self:GoDown()
                    end
                    Citizen.Wait(125)
                end
                self.DownPressed = false
            end)
        end
    end

    if not self.LeftPressed then
        if self.Controls.Left.Enabled and (IsDisabledControlPressed(0, 174) or IsDisabledControlPressed(1, 174) or IsDisabledControlPressed(2, 174)) then
            local type, subtype = self.Items[self:CurrentSelection()]()
            Citizen.CreateThread(function()
                self.LeftPressed = true
                self:GoLeft()
                Citizen.Wait(175)
                while self.Controls.Left.Enabled and (IsDisabledControlPressed(0, 174) or IsDisabledControlPressed(1, 174) or IsDisabledControlPressed(2, 174)) do
                    self:GoLeft()
                    Citizen.Wait(125)
                end
                self.LeftPressed = false
            end)
        end
    end

    if not self.RightPressed then
        if self.Controls.Right.Enabled and (IsDisabledControlPressed(0, 175) or IsDisabledControlPressed(1, 175) or IsDisabledControlPressed(2, 175)) then
            Citizen.CreateThread(function()
                local type, subtype = self.Items[self:CurrentSelection()]()
                self.RightPressed = true
                self:GoRight()
                Citizen.Wait(175)
                while self.Controls.Right.Enabled and (IsDisabledControlPressed(0, 175) or IsDisabledControlPressed(1, 175) or IsDisabledControlPressed(2, 175)) do
                    self:GoRight()
                    Citizen.Wait(125)
                end
                self.RightPressed = false
            end)
        end
    end

    if self.Controls.Select.Enabled and (IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(1, 201) or IsDisabledControlJustPressed(2, 201)) then
        self:SelectItem()
    end
end

---GoUp
function UIMenu:GoUp()
    self.Items[self:CurrentSelection()]:Selected(false)
    BeginScaleformMovieMethod(ScaleformUI.Scaleforms._ui.handle, "SET_INPUT_EVENT")
    ScaleformMovieMethodAddParamInt(8)
    local ret = EndScaleformMovieMethodReturnValue()
    while not IsScaleformMovieMethodReturnValueReady(ret) do Wait(0) end
    self.ActiveItem = GetScaleformMovieFunctionReturnInt(ret)
    self.Items[self:CurrentSelection()]:Selected(true)
    PlaySoundFrontend(-1, self.Settings.Audio.UpDown, self.Settings.Audio.Library, true)
    self.OnIndexChange(self, self:CurrentSelection())
end

---GoDown
function UIMenu:GoDown()
    self.Items[self:CurrentSelection()]:Selected(false)
    BeginScaleformMovieMethod(ScaleformUI.Scaleforms._ui.handle, "SET_INPUT_EVENT")
    ScaleformMovieMethodAddParamInt(9)
    local ret = EndScaleformMovieMethodReturnValue()
    while not IsScaleformMovieMethodReturnValueReady(ret) do Wait(0) end
    self.ActiveItem = GetScaleformMovieFunctionReturnInt(ret)
    self.Items[self:CurrentSelection()]:Selected(true)
    PlaySoundFrontend(-1, self.Settings.Audio.UpDown, self.Settings.Audio.Library, true)
    self.OnIndexChange(self, self:CurrentSelection())
end

function UIMenu:GoLeft()
    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype ~= "UIMenuListItem" and subtype ~= "UIMenuSliderItem" and subtype ~= "UIMenuProgressItem" and subtype ~= "UIMenuStatsItem" then
        return
    end

    if not self.Items[self:CurrentSelection()]:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end

    BeginScaleformMovieMethod(ScaleformUI.Scaleforms._ui.handle, "SET_INPUT_EVENT")
    ScaleformMovieMethodAddParamInt(10)
    local ret = EndScaleformMovieMethodReturnValue()
    while not IsScaleformMovieMethodReturnValueReady(ret) do Wait(0) end
    local res = GetScaleformMovieFunctionReturnInt(ret)

    if subtype == "UIMenuListItem" then
        Item:Index(res)
        self.OnListChange(self, Item, Item._Index)
        Item.OnListChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuSliderItem" then
        Item:Index(res)
        self.OnSliderChange(self, Item, Item:Index())
        Item.OnSliderChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuProgressItem" then
        Item:Index(res)
        self.OnProgressChange(self, Item, Item:Index())
        Item.OnProgressChanged(self, Item, Item:Index())
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuStatsItem" then
        Item:Index(res)
        --self.OnStatsChange(self, Item, Item:Index())
        Item.OnStatsChanged(self, Item, Item._Index)
    end
end

---GoRight
function UIMenu:GoRight()
    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype ~= "UIMenuListItem" and subtype ~= "UIMenuSliderItem" and subtype ~= "UIMenuProgressItem" and subtype ~= "UIMenuStatsItem" then
        return
    end
    if not Item:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end

    BeginScaleformMovieMethod(ScaleformUI.Scaleforms._ui.handle, "SET_INPUT_EVENT")
    ScaleformMovieMethodAddParamInt(11)
    local ret = EndScaleformMovieMethodReturnValue()
    while not IsScaleformMovieMethodReturnValueReady(ret) do Wait(0) end
    local res = GetScaleformMovieFunctionReturnInt(ret)

    if subtype == "UIMenuListItem" then
        Item:Index(res)
        self.OnListChange(self, Item, Item._Index)
        Item.OnListChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuSliderItem" then
        Item:Index(res)
        self.OnSliderChange(self, Item, Item:Index())
        Item.OnSliderChanged(self, Item, Item._Index)
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuProgressItem" then
        Item:Index(res)
        self.OnProgressChange(self, Item, Item:Index())
        Item.OnProgressChanged(self, Item, Item:Index())
        PlaySoundFrontend(-1, self.Settings.Audio.LeftRight, self.Settings.Audio.Library, true)
    elseif subtype == "UIMenuStatsItem" then
        Item:Index(res)
        --self.OnStatsChange(self, Item, Item:Index())
        Item.OnStatsChanged(self, Item, Item._Index)
    end
end

---SelectItem
function UIMenu:SelectItem(play)
    if not self.Items[self:CurrentSelection()]:Enabled() then
        PlaySoundFrontend(-1, self.Settings.Audio.Error, self.Settings.Audio.Library, true)
        return
    end
    if play then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
    end

    local Item = self.Items[self:CurrentSelection()]
    local type, subtype = Item()
    if subtype == "UIMenuCheckboxItem" then
        print(Item:Checked())
        Item:Checked(not Item:Checked())
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnCheckboxChange(self, Item, Item.Checked)
        Item.CheckboxEvent(self, Item, Item.Checked)
    elseif subtype == "UIMenuListItem" then
        PlaySoundFrontend(-1, self.Settings.Audio.Select, self.Settings.Audio.Library, true)
        self.OnListSelect(self, Item, Item._Index)
        Item.OnListSelected(self, Item, Item._Index)
    else
        self.OnItemSelect(self, Item, self:CurrentSelection())
        Item.Activated(self, Item)
        if not self.Children[Item] then
            return
        end
        self:Visible(false)
        self.Children[Item]:Visible(true)
        self.OnMenuChanged(self, self.Children[self.Items[self:CurrentSelection()]], true)
        ScaleformUI.Scaleforms._ui:CallFunction("CLEAR_ALL")
        ScaleformUI.Scaleforms.InstructionalButtons:Enabled(true)
        ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(Children[MenuItems[CurrentSelection]].InstructionalButtons)
        --_poolcontainer.MenuChangeEv(this, Children[MenuItems[CurrentSelection]], MenuState.ChangeForward)
        self.OnMenuChanged(self, self.Children[Item], "forwards")
        self.ParentMenu.OnMenuChanged(self, self.Children[Item], "forwards")
        self.Children[Item]:Visible(true)
        self.Children[Item]:BuildUpMenu()
    end
end

---GoBack
function UIMenu:GoBack()
    PlaySoundFrontend(-1, self.Settings.Audio.Back, self.Settings.Audio.Library, true)
    if self.ParentMenu ~= nil then
        ScaleformUI.Scaleforms._ui.CallFunction("CLEAR_ALL")
        ScaleformUI.Scaleforms.InstructionalButtons.Enabled = true
        ScaleformUI.Scaleforms.InstructionalButtons.SetInstructionalButtons(ParentMenu.InstructionalButtons)
        self.ParentMenu:Visible(true)
        self.ParentMenu:BuildUpMenu()
        self.OnMenuChanged(self, self.ParentMenu, "backwards")
        self.ParentMenu.OnMenuChanged(self, self.ParentMenu, "backwards")
    end
    self:Visible(false)
end

---BindMenuToItem
---@param Menu table
---@param Item table
function UIMenu:BindMenuToItem(Menu, Item)
    if Menu() == "UIMenu" and Item() == "UIMenuItem" then
        Menu.ParentMenu = self
        Menu.ParentItem = Item
        self.Children[Item] = Menu
    end
end

---ReleaseMenuFromItem
---@param Item table
function UIMenu:ReleaseMenuFromItem(Item)
    if Item() == "UIMenuItem" then
        if not self.Children[Item] then
            return false
        end
        self.Children[Item].ParentMenu = nil
        self.Children[Item].ParentItem = nil
        self.Children[Item] = nil
        return true
    end
end

---Draw
function UIMenu:Draw()
    if not self._Visible or ScaleformUI.Scaleforms.Warning:IsShowing() then return end
    while not ScaleformUI.Scaleforms._ui:IsLoaded() do Citizen.Wait(0) end

    HideHudComponentThisFrame(19)

    if self.Settings.ControlDisablingEnabled then
        self:DisEnableControls(false)
    end

    local x = self.Position.X / 1280
    local y = self.Position.Y / 720
    local width = 1280 / (720 * GetScreenAspectRatio(false))
    local height = 720 / 720
    ScaleformUI.Scaleforms._ui:Render2DNormal(x + (width / 2.0), y + (height / 2.0), width, height)

    if self.Glare then
        self._menuGlare:CallFunction("SET_DATA_SLOT", GetGameplayCamRelativeHeading())

        local gx = self.Position.X / 1280 + 0.4499
        local gy = self.Position.Y / 720 + 0.449

        self._menuGlare:Render2DNormal(gl.X, gl.Y, 1, 1)
    end

    for k,item in pairs(self.Items) do
        local Type, SubType = item()
        if SubType == "UIMenuSliderItem" or SubType == "UIMenuProgressItem" then
            ScaleformUI.Scaleforms._ui.CallFunction("UPDATE_ITEM", k-1, item:Description(), item.MainColor, item.HighlightColor, item.TextColor, item.HighlightedTextColor, item.SliderColor, item.BackgroundSliderColor)
        else
            ScaleformUI.Scaleforms._ui.CallFunction("UPDATE_ITEM", k-1, item:Description(), item.MainColor, item.HighlightColor, item.TextColor, item.HighlightedTextColor)
        end
    end
end

---ProcessMouse
function UIMenu:ProcessMouse()
    local menuSound = -1
    if not self._Visible or self.JustOpened or #self.Items == 0 or tobool(not IsInputDisabled(2)) or not self.Settings.MouseControlsEnabled then
        EnableControlAction(0, 2, true)
        EnableControlAction(0, 1, true)
        EnableControlAction(0, 25, true)
        EnableControlAction(0, 24, true)
        if self.Dirty then
            for _, Item in pairs(self.Items) do
                if Item:Hovered() then
                    Item:Hovered(false)
                end
            end
        end
        return
    end

    local Limit = #self.Items
    local ItemOffset = 0

    ShowCursorThisFrame()

    if #self.Items > self.Pagination.Total + 1 then
        Limit = self.Pagination.Max
    end

    if IsControlJustPressed(0, 24) then
        local mouse = { 
            X = GetDisabledControlNormal(0, 239) * (720 * GetScreenAspectRatio(false)) - self.X,
            Y = GetDisabledControlNormal(0, 240) * 720 - self.Y
        }
        BeginScaleformMovieMethod(ScaleformUI.Scaleforms._ui.handle, "SET_INPUT_MOUSE_EVENT_SINGLE")
        ScaleformMovieMethodAddParamFloat(mouse.X)
        ScaleformMovieMethodAddParamFloat(mouse.Y)
        local ret = EndScaleformMovieMethodReturnValue()
        while not IsScaleformMovieMethodReturnValueReady(ret) do Citizen.Wait(0) end
        local res = GetScaleformMovieMethodReturnValueString(ret)
        local split = split(res, ",")
        local type = split[1]
        local selection = tonumber(split[2])
        if type == "it" then
            if self:CurrentSelection() ~= selection then
                self:CurrentSelection(selection)
            else
                if tonumber(split[3]) == 0 or tonumber(split[3]) == 2 then
                    self:Select(false)
                elseif tonumber(split[3]) == 1 then
                    local it = self.Items[self:CurrentSelection()]
                    it:Index(tonumber(split[4]))
                    self:OnListChange(self, it, it._Index)
                    it.OnListChange(self, it, it._Index)
                elseif tonumber(split[3]) == 3 then
                    local it = self.Items[self:CurrentSelection()]
                    it:Index(tonumber(split[4]))
                    it.OnSliderChanged(self, it, it._Index)
                    self.OnSliderChange(self, it, it._Index)
                elseif tonumber(split[3]) == 4 then
                    local it = self.Items[self:CurrentSelection()]
                    it:Index(tonumber(split[4]))
                    it.OnProgressChanged(self, Item, Item._Index)
                    self:OnProgressChange(self, Item, Item._Index)
                end
            end
        elseif type == "pan" then
            if tonumber(split[3]) == 0 then
                local panel = self.Items[self:CurrentSelection()].Panels[selection+1]
                panel._value = tonumber(split[4])
                self:ColorPanelChange(panel.ParentItem, panel, panel:CurrentSelection())
                panel.PanelChanged(panel.ParentItem, panel, panel:CurrentSelection())
            end
        end
    elseif IsControlPressed(0, 24) then
        local mouse = { 
            X = GetDisabledControlNormal(0, 239) * (720 * GetScreenAspectRatio(false)) - self.X,
            Y = GetDisabledControlNormal(0, 240) * 720 - self.Y
        }
        BeginScaleformMovieMethod(ScaleformUI.Scaleforms._ui.Handle, "SET_INPUT_MOUSE_EVENT_CONTINUE")
        ScaleformMovieMethodAddParamFloat(mouse.X)
        ScaleformMovieMethodAddParamFloat(mouse.Y)
        local ret = EndScaleformMovieMethodReturnValue()
        while not IsScaleformMovieMethodReturnValueReady(ret) do Citizen.Wait(0) end
        local res = GetScaleformMovieMethodReturnValueString(ret)
        local split = split(res, ",")

        local type = split[1]
        local selection = tonumber(split[2])
        local _type = tonumber(split[3])
        local value = tonumber(split[4])
        if type == "it" then
            if _type == 3 then 
                local it = self.Items[self:CurrentSelection()]
                it.Value = tonumber(split[4])
                it.OnSliderChanged(self, it, it._Index)
                self.OnSliderChanged(self, it, it._Index)
                if HasSoundFinished(menuSound) then
                    menuSound = GetSoundId()
                    PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            elseif _type == 4 then
                local it = self.Items[self:CurrentSelection()]
                it.Value = tonumber(split[4])
                it.OnProgressChanged(self, Item, Item._Index)
                self:OnProgressChange(self, Item, Item._Index)
                if HasSoundFinished(menuSound) then
                        menuSound = GetSoundId()
                        PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
        elseif type == "pan" then
            if _type == 1 then 
                local panel = self.Items[self:CurrentSelection()].Panels[selection+1]
                panel._value = value
                self.PercentagePanelChange(panel.ParentItem, panel, panel.Percentage)
                panel.PercentagePanelChange()
                if HasSoundFinished(menuSound) then
                    menuSound = GetSoundId()
                    PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            elseif _type == 2 then 
                local panel = self.Items[self:CurrentSelection()].Panels[selection+1]
                panel._value = new(value, Convert.ToSingle(split[4]))
                self.GridPanelChange(panel.ParentItem, panel, panel.CirclePosition)
                panel.OnGridChange()
                if HasSoundFinished(menuSound) then
                    menuSound = GetSoundId()
                    PlaySoundFrontend(menuSound, "CONTINUOUS_SLIDER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
        end
    end

    if not HasSoundFinished(menuSound) then
        Citizen.Wait(1)
        StopSound(menuSound)
        ReleaseSoundId(menuSound)
    end
end

---AddInstructionButton
---@param button table
function UIMenu:AddInstructionButton(button)
    if type(button) == "table" and #button == 2 then
        table.insert(self.InstructionalButtons, button)
    end
end

---RemoveInstructionButton
---@param button table
function UIMenu:RemoveInstructionButton(button)
    if type(button) == "table" then
        for i = 1, #self.InstructionalButtons do
            if button == self.InstructionalButtons[i] then
                table.remove(self.InstructionalButtons, i)
                break
            end
        end
    else
        if tonumber(button) then
            if self.InstructionalButtons[tonumber(button)] then
                table.remove(self.InstructionalButtons, tonumber(button))
            end
        end
    end
end

---AddEnabledControl
---@param Inputgroup number
---@param Control number
---@param Controller table
function UIMenu:AddEnabledControl(Inputgroup, Control, Controller)
    if tonumber(Inputgroup) and tonumber(Control) then
        table.insert(self.Settings.EnabledControls[(Controller and "Controller" or "Keyboard")], { Inputgroup, Control })
    end
end

---RemoveEnabledControl
---@param Inputgroup number
---@param Control number
---@param Controller table
function UIMenu:RemoveEnabledControl(Inputgroup, Control, Controller)
    local Type = (Controller and "Controller" or "Keyboard")
    for Index = 1, #self.Settings.EnabledControls[Type] do
        if Inputgroup == self.Settings.EnabledControls[Type][Index][1] and Control == self.Settings.EnabledControls[Type][Index][2] then
            table.remove(self.Settings.EnabledControls[Type], Index)
            break
        end
    end
end
