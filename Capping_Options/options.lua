local Capping = Capping
if not Capping or not Capping.priv then return end

local _G = getfenv(0)
local P = Capping.priv
local db = Capping.db
local L = Capping.L
local media = LibStub("LibSharedMedia-3.0")
local format, floor, max = format, floor, max
local bars, activebars = Capping.bars, Capping.activebars
local av, ab, eots, wsg, winter, ioc = L["Alterac Valley"], L["Arathi Basin"], L["Eye of the Storm"], L["Warsong Gulch"], L["Wintergrasp"], L["Isle of Conquest"]
local UpdateBarLayout, SortBars, ToggleAnchor = P.UpdateBarLayout, P.SortBars, P.ToggleAnchor
local ReportBG, ReportSAY, CancelBar = P.ReportBG, P.ReportSAY, P.CancelBar
local CreateMover, wsaufu = P.CreateMover, P.wsaufu

local optFrame, barid, Exec
function Capping.OpenOptions(a1, id)
	barid = type(id) == "number" and id
	if not optFrame then
	local abbrv = { av = av, ab = ab, eots = eots, wsg = wsg, winter = winter, ioc = ioc, }
	local sbmover, cbmover, seatmover
	local swatches = {}
	local function RefreshSwatches()
		for key, btn in pairs(swatches) do
			local c, nt = db.colors[key], btn:GetNormalTexture()
			if c and nt then nt:SetVertexColor(c.r, c.g, c.b) end
		end
	end
	local function UpdateLook(k)
		if k == "colors" then RefreshSwatches() end
		local texture = media:Fetch("statusbar", db.texture)
		local font = media:Fetch("font", db.font)
		local fc = db.colors.font
		Capping:SetWidth(db.width)
		for index, f in pairs(bars) do
			f.bar:SetTexture(texture)
			f.barback:SetTexture(texture)
			f.timetext:SetFont(font, db.fontsize-1)
			f.displaytext:SetFont(font, db.fontsize)
			f:SetHeight(db.height)
			if k == "colors" or k == "bgalpha" then
				local bc = db.colors[f.color or "info1"] or db.colors.info1
				f.bar:SetVertexColor(bc.r, bc.g, bc.b, bc.a or 1)
				f.barback:SetVertexColor(bc.r * 0.3, bc.g * 0.3, bc.b * 0.3, db.bgalpha or 0.7)
			end
			if k == "mainup" then f.down = not f.down end
			if k == "onegroup" and db.onegroup then f.down = not db.mainup end
			UpdateBarLayout(f)
		end
		SortBars()
		Capping:ModMap()
	end
	local function HideCheck(b)
		if b and b.GetName and _G[b:GetName().."Check"] then
			_G[b:GetName().."Check"]:Hide()
		end
	end
	Exec = function(k, value)
		if k == "anchor" then ToggleAnchor()
		elseif k == "syncav" and Capping.SyncAV and GetRealZoneText() == av then Capping:SyncAV()
		elseif k == "reportbg" then ReportBG(value)
		elseif k == "reportsay" then ReportSAY(value)
		elseif k == "enterbattle" then ReportBG(value)
		elseif k == "leavequeue" or k == "canceltimer" then CancelBar(value)
		elseif k == "test" then
			local testicon = "Interface\\Icons\\Ability_ThunderBolt"
			Capping:StartBar(L["Test"].." - ".._G.OTHER.."1", 100, 100, testicon, "info1", true, true)
			Capping:StartBar(L["Test"].." - ".._G.OTHER.."2", 75, 75, testicon, "info2", true, true)
			Capping:StartBar(L["Test"].." - ".._G.FACTION_ALLIANCE, 45, 45, testicon, "alliance", true)
			Capping:StartBar(L["Test"].." - ".._G.FACTION_HORDE, 100, 100, testicon, "horde", true)
			Capping:StartBar(L["Test"], 75, 75, testicon, "info2", true)
		elseif k == "movesb" then
			sbmover = sbmover or CreateMover(nil, 220, 48, function(this)
				this:StopMovingOrSizing()
				db.sbx, db.sby = floor(this:GetLeft() + 50.5), floor(this:GetTop() - GetScreenHeight() + 10.5)
				WorldStateAlwaysUpFrame:SetPoint("TOP")
			end)
			sbmover:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", WorldStateAlwaysUpFrame:GetLeft() - 50, WorldStateAlwaysUpFrame:GetTop() - 10)
			sbmover:Show()
		elseif k == "movecb" then
			cbmover = cbmover or CreateMover(nil, 173, 27, function(this)
				this:StopMovingOrSizing()
				db.cbx, db.cby = floor(this:GetRight() + 0.5), floor(this:GetTop() + 0.5)
				wsaufu()
			end)
			local x, y = db.cbx or max(0, MinimapCluster:GetRight() - CONTAINER_OFFSET_X), db.cby or max(20, MinimapCluster:GetBottom())
			cbmover:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)
			cbmover:Show()
		elseif k == "moveseat" then
			seatmover = seatmover or CreateMover(nil, 128, 128, function(this)
				this:StopMovingOrSizing()
				db.seatx, db.seaty = floor(this:GetRight() + 0.5), floor(this:GetTop() + 0.5)
				VehicleSeatIndicator:SetPoint("TOPRIGHT")
			end)
			seatmover:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", VehicleSeatIndicator:GetRight(), VehicleSeatIndicator:GetTop())
			seatmover:Show()
		elseif k == "resetmap" and P.GetMapTab() then
			P.GetMapTab():ClearAllPoints()
			P.GetMapTab():SetPoint("CENTER")
		elseif k == "resetall" and IsShiftKeyDown() then
			CappingDB, CappingCharDB = nil, nil
			ReloadUI()
		end
	end

	local function OpenColorPicker(colorkey)
		local dbc = db.colors[colorkey]
		if not dbc then return end
		ColorPickerFrame.func = function()
			dbc.r, dbc.g, dbc.b = ColorPickerFrame:GetColorRGB()
			dbc.a = 1 - OpacitySliderFrame:GetValue()
			UpdateLook("colors")
		end
		ColorPickerFrame.cancelFunc = function(pv)
			dbc.r, dbc.g, dbc.b, dbc.a = pv.r, pv.g, pv.b, 1 - pv.opacity
			UpdateLook("colors")
		end
		ColorPickerFrame.opacityFunc = ColorPickerFrame.func
		ColorPickerFrame.previousValues = { r = dbc.r, g = dbc.g, b = dbc.b, opacity = 1 - dbc.a }

		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - dbc.a
		ColorPickerFrame:SetColorRGB(dbc.r, dbc.g, dbc.b)
		OpacitySliderFrame:SetValue(1 - dbc.a)
		ColorPickerFrame:Show()
	end

	local PWIDTH, PHEIGHT = 450, 510
	optFrame = CreateFrame("Frame", "CappingOptionsFrame", UIParent)
	optFrame:SetWidth(PWIDTH)
	optFrame:SetHeight(PHEIGHT)
	optFrame:SetPoint("CENTER")
	optFrame:SetFrameStrata("DIALOG")
	optFrame:SetBackdrop({
		bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	optFrame:SetMovable(true)
	optFrame:SetClampedToScreen(true)
	optFrame:RegisterForDrag("LeftButton")
	optFrame:SetScript("OnDragStart", function(this) this:StartMoving() end)
	optFrame:SetScript("OnDragStop",  function(this) this:StopMovingOrSizing() end)
	optFrame:Hide()

	local titleTex = optFrame:CreateTexture(nil, "ARTWORK")
	titleTex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	titleTex:SetWidth(256); titleTex:SetHeight(64)
	titleTex:SetPoint("TOP", 0, 12)
	local titleText = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titleText:SetPoint("TOP", 0, 4)
	titleText:SetText("|cff5555ffCapping|r")

	local closeBtn = CreateFrame("Button", "CappingOptClose", optFrame, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", -2, -3)
	closeBtn:SetScript("OnClick", function() optFrame:Hide() end)

	local tabNames = { _G.BATTLEFIELDS or "Battlegrounds", "Timer Bar", _G.BATTLEFIELD_MINIMAP or "BG Map", _G.OTHER or "Other" }
	local contentFrames = {}
	local activeTab = 1

	local function SelectTab(idx)
		activeTab = idx
		for i, cf in ipairs(contentFrames) do
			if i == idx then cf:Show() else cf:Hide() end
		end
		for i = 1, #tabNames do
			local t = _G["CappingOptTab"..i]
			if t then
				if i == idx then t:LockHighlight() else t:UnlockHighlight() end
			end
		end
	end

	optFrame:SetScript("OnShow", function() SelectTab(activeTab) end)

	optFrame.numTabs = #tabNames
	for i = 1, #tabNames do
		local cf = CreateFrame("Frame", nil, optFrame)
		cf:SetPoint("TOPLEFT", 14, -56)
		cf:SetPoint("BOTTOMRIGHT", -14, 14)
		cf:Hide()
		contentFrames[i] = cf
	end

	for i, name in ipairs(tabNames) do
		local t = CreateFrame("Button", "CappingOptTab"..i, optFrame, "UIPanelButtonTemplate")
		t:SetWidth(100)
		t:SetHeight(22)
		t:SetText(name)
		t.index = i
		t:SetScript("OnClick", function(this) SelectTab(this.index) end)
		if i == 1 then
			t:SetPoint("TOPLEFT", 14, -32)
		else
			t:SetPoint("LEFT", _G["CappingOptTab"..(i-1)], "RIGHT", 4, 0)
		end
	end

	local sliderCount = 0
	local function MakeSlider(parent, label, dbkey, minv, maxv, step, fmt, yoff, defv)
		sliderCount = sliderCount + 1
		local fmtStr = fmt or (step >= 1 and "%d" or "%.2f")
		local s = CreateFrame("Slider", "CappingSlider"..sliderCount, parent, "OptionsSliderTemplate")
		s:SetWidth(PWIDTH - 80)
		s:SetMinMaxValues(minv, maxv)
		s:SetValueStep(step)
		s:SetValue(db[dbkey] or defv or minv)
		s:SetPoint("TOP", parent, "TOP", 0, yoff)
		_G[s:GetName().."Low"]:SetText(format(fmtStr, minv))
		_G[s:GetName().."High"]:SetText(format(fmtStr, maxv))
		_G[s:GetName().."Text"]:SetText(label..": "..format(fmtStr, db[dbkey] or defv or minv))
		s:SetScript("OnValueChanged", function(this, val)
			val = floor(val / step + 0.5) * step
			db[dbkey] = val
			_G[this:GetName().."Text"]:SetText(label..": "..format(fmtStr, val))
			UpdateLook(dbkey)
		end)
		return s
	end

	local cbCount = 0
	local function MakeCheckbox(parent, label, dbkey, xoff, yoff, specialFunc)
		cbCount = cbCount + 1
		local cb = CreateFrame("CheckButton", "CappingCB"..cbCount, parent, "UICheckButtonTemplate")
		cb:SetPoint("TOPLEFT", parent, "TOPLEFT", xoff, yoff)
		_G[cb:GetName().."Text"]:SetText(label)
		cb:SetChecked(db[dbkey] and true or false)
		cb:SetScript("OnClick", function(this)
			db[dbkey] = this:GetChecked() and true or false
			if specialFunc then
				specialFunc(db[dbkey])
			elseif abbrv[dbkey] then
				if GetRealZoneText() == abbrv[dbkey] then
					Capping:ZONE_CHANGED_NEW_AREA()
				elseif dbkey == "winter" and not db[dbkey] then
					Capping:StopBar(winter)
				end
			elseif dbkey == "perchar" then
				if CappingCharDB then CappingCharDB = nil else CappingCharDB = db end
				ReloadUI()
			else
				UpdateLook(dbkey)
			end
		end)
		return cb
	end

	local btnCount = 0
	local function MakeButton(parent, label, xoff, yoff, w, h, onclick)
		btnCount = btnCount + 1
		local b = CreateFrame("Button", "CappingBtn"..btnCount, parent, "UIPanelButtonTemplate")
		b:SetWidth(w or 130)
		b:SetHeight(h or 22)
		b:SetText(label)
		b:SetPoint("TOPLEFT", parent, "TOPLEFT", xoff, yoff)
		b:SetScript("OnClick", onclick)
		return b
	end

	local ddCount = 0
	local function MakeDropdown(parent, label, dbkey, listtype, xoff, yoff)
		ddCount = ddCount + 1
		local ddLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		ddLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", xoff + 2, yoff)
		ddLabel:SetText(label)

		local dd = CreateFrame("Frame", "CappingDD"..ddCount, parent, "UIDropDownMenuTemplate")
		dd:SetPoint("TOPLEFT", parent, "TOPLEFT", xoff - 16, yoff - 16)
		local list = media:List(listtype)
		UIDropDownMenu_SetWidth(dd, 160)
		UIDropDownMenu_SetText(dd, db[dbkey] or "")
		UIDropDownMenu_Initialize(dd, function()
			for _, v in ipairs(list) do
				local info = {}
				info.text = v
				info.checked = (db[dbkey] == v)
				info.func = function()
					db[dbkey] = v
					UIDropDownMenu_SetText(dd, v)
					UpdateLook(dbkey)
				end
				UIDropDownMenu_AddButton(info)
			end
		end)
		return dd
	end

	local function MakeColorSwatch(parent, label, colorkey, xoff, yoff)
		local btn = CreateFrame("Button", nil, parent)
		btn:SetWidth(18); btn:SetHeight(18)
		btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xoff, yoff)
		btn:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
		swatches[colorkey] = btn
		local dbc = db.colors[colorkey]
		local nt = btn:GetNormalTexture()
		if dbc and nt then nt:SetVertexColor(dbc.r, dbc.g, dbc.b) end
		local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		lbl:SetPoint("LEFT", btn, "RIGHT", 4, 0)
		lbl:SetText(label)
		btn:SetScript("OnClick", function()
			OpenColorPicker(colorkey)
		end)
		return btn
	end

	local function MakeSection(parent, label, yoff)
		local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yoff)
		lbl:SetText("|cffffcc00"..label.."|r")
		local line = parent:CreateTexture(nil, "ARTWORK")
		line:SetHeight(1)
		line:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -2)
		line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yoff - 12)
		line:SetTexture(0.5, 0.5, 0.5, 0.5)
		return lbl
	end

	local bgTab = contentFrames[1]

	MakeSection(bgTab, _G.BATTLEFIELDS or "Battlegrounds", -8)

	MakeCheckbox(bgTab, L["Alterac Valley"],    "av",    12, -30)
	MakeCheckbox(bgTab, L["Arathi Basin"],       "ab",    12, -55)
	MakeCheckbox(bgTab, L["Eye of the Storm"],   "eots",  12, -80)
	MakeCheckbox(bgTab, L["Isle of Conquest"],   "ioc",   12, -105)
	MakeCheckbox(bgTab, L["Warsong Gulch"],      "wsg",   12, -130)
	MakeCheckbox(bgTab, L["Wintergrasp"],        "winter",12, -155)

	MakeSection(bgTab, "AV Options", -188)
	MakeCheckbox(bgTab, L["Auto Quest Turnins"], "avquest", 12, -205)
	MakeButton(bgTab, L["Request Sync"], 16, -232, 140, 22, function()
		if GetRealZoneText() == av then Exec("syncav") end
	end)

	local barTab = contentFrames[2]

	MakeSection(barTab, "Size", -8)
	MakeSlider(barTab, "Width",        "width",    20, 600, 2,   "%d",  -30)
	MakeSlider(barTab, "Height",       "height",   2,  100, 1,   "%d",  -75)
	MakeSlider(barTab, "Border Width", "inset",    0,  8,   1,   "%d",  -120)
	MakeSlider(barTab, "Spacing",      "spacing",  0,  10,  1,   "%d",  -165)
	MakeSlider(barTab, "Font Size",    "fontsize", 4,  28,  1,   "%d",  -210)

	MakeSection(barTab, "Appearance", -258)
	MakeDropdown(barTab, "Texture", "texture", "statusbar", 8,  -272)
	MakeDropdown(barTab, "Font",    "font",    "font",      220, -272)

	MakeSection(barTab, "Layout", -328)

	local ipos = db.iconpos or "<-"
	local tpos = db.timepos or "<-"
	local iconLabel = barTab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	iconLabel:SetPoint("TOPLEFT", barTab, "TOPLEFT", 12, -344)
	iconLabel:SetText("Icon:")
	local iL = MakeButton(barTab, "Left (<-)", 50, -340, 90, 20, function()
		db.iconpos = "<-"
		UpdateLook("iconpos")
	end)
	local iR = MakeButton(barTab, "Right (->)", 145, -340, 90, 20, function()
		db.iconpos = "->"
		UpdateLook("iconpos")
	end)
	local iX = MakeButton(barTab, "Hide (X)", 240, -340, 90, 20, function()
		db.iconpos = "X"
		UpdateLook("iconpos")
	end)

	local tLabel = barTab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	tLabel:SetPoint("TOPLEFT", barTab, "TOPLEFT", 12, -370)
	tLabel:SetText("Time:")
	MakeButton(barTab, "Left (<-)", 50, -366, 90, 20, function()
		db.timepos = "<-"
		UpdateLook("timepos")
	end)
	MakeButton(barTab, "Right (->)", 145, -366, 90, 20, function()
		db.timepos = "->"
		UpdateLook("timepos")
	end)

	MakeSection(barTab, "Misc", -400)
	MakeCheckbox(barTab, "Fill Grow",        "fill",     12,  -416)
	MakeCheckbox(barTab, "Fill Right",       "reverse",  150, -416)
	MakeCheckbox(barTab, "Flip Bar Stack",   "mainup",   12,  -440)
	MakeCheckbox(barTab, "Single Group",     "onegroup", 150, -440)
	MakeCheckbox(barTab, "Lock Bars",        "lockbar",  12,  -464)
	MakeCheckbox(barTab, "Alt Bar Style",    "altstyle", 150, -464)

	MakeButton(barTab, "Test Bars", 8, -492, 100, 22, function()
		Exec("test")
	end)

	local mapTab = contentFrames[3]

	MakeSection(mapTab, _G.BATTLEFIELD_MINIMAP or "Battlefield Minimap", -8)
	MakeCheckbox(mapTab, L["Narrow Map Mode"],   "narrow",          12, -30)
	MakeCheckbox(mapTab, L["Narrow Anchor Left"],"narrowanchorleft",12, -55)
	MakeCheckbox(mapTab, L["Hide Border"],        "hidemapborder",   12, -80, function()
		Capping:ModMap()
	end)
	MakeSlider(mapTab, "Map Scale", "mapscale", 0.5, 3.0, 0.05, "%.2f", -115)
	MakeButton(mapTab, _G.RESET or "Reset Map", 12, -165, 130, 22, function()
		if P.GetMapTab() then
			P.GetMapTab():ClearAllPoints()
			P.GetMapTab():SetPoint("CENTER")
		end
	end)

	MakeSection(mapTab, "Colors", -205)
	MakeColorSwatch(mapTab, _G.FACTION_ALLIANCE or "Alliance", "alliance", 12,  -222)
	MakeColorSwatch(mapTab, _G.FACTION_HORDE    or "Horde",    "horde",    12,  -244)
	MakeColorSwatch(mapTab, "Info 1",                           "info1",    12,  -266)
	MakeColorSwatch(mapTab, "Info 2",                           "info2",    12,  -288)
	MakeColorSwatch(mapTab, "Font",                             "font",     150, -222)
	MakeColorSwatch(mapTab, "Spark",                            "spark",    150, -244)

	MakeSection(mapTab, "Background Opacity", -318)
	MakeSlider(mapTab, "Opacity", "bgalpha", 0, 1, 0.05, "%.2f", -340, 0.7)

	local otherTab = contentFrames[4]

	MakeSection(otherTab, "Timers", -8)
	MakeCheckbox(otherTab, L["Port Timer"], "port", 12, -30)
	MakeCheckbox(otherTab, L["Wait Timer"], "wait", 12, -55)

	MakeSection(otherTab, "Move Frames", -85)
	MakeButton(otherTab, L["Move Scoreboard"],   12, -105, 140, 22, function() Exec("movesb") end)
	MakeButton(otherTab, L["Move Capture Bar"],  160, -105, 140, 22, function() Exec("movecb") end)
	MakeButton(otherTab, L["Move Vehicle Seat"], 12,  -133, 140, 22, function() Exec("moveseat") end)

	MakeSection(otherTab, "Profile", -165)
	MakeCheckbox(otherTab, (_G.CHARACTER or "Character").." Save", "perchar", 12, -182)

	MakeSection(otherTab, "Danger Zone", -215)
	local resetBtn = MakeButton(otherTab, _G.RESET_TO_DEFAULT or "Reset to Default", 12, -232, 200, 22, function()
		if IsShiftKeyDown() then Exec("resetall") end
	end)
	local resetHint = otherTab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	resetHint:SetPoint("TOPLEFT", otherTab, "TOPLEFT", 12, -258)
	resetHint:SetText("|cffff4444Hold SHIFT and click to confirm reset.|r")

	MakeSection(otherTab, "Anchor", -280)
	MakeButton(otherTab, L["Show/Hide Anchor"], 12, -297, 160, 22, function() ToggleAnchor() end)

	local barPopup = CreateFrame("Frame", "CappingBarPopup", UIParent)
	barPopup:SetWidth(180)
	barPopup:SetBackdrop({
		bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	barPopup:SetBackdropColor(0, 0, 0, 0.9)
	barPopup:SetFrameStrata("TOOLTIP")
	barPopup:SetClampedToScreen(true)
	barPopup:Hide()
	barPopup:SetScript("OnLeave", function(this)
		if not MouseIsOver(this) then this:Hide() end
	end)

	local popTitle = barPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	popTitle:SetPoint("TOP", 0, -10)
	popTitle:SetWidth(160)

	local popBtns = {}
	local popBtnLabels = {
		[1] = { L["Send to BG"],    function() if barid then Exec("reportbg", barid) end barPopup:Hide() end },
		[2] = { L["Send to SAY"],   function() if barid then Exec("reportsay", barid) end barPopup:Hide() end },
		[3] = { L["Cancel Timer"],  function() if barid then Exec("canceltimer", barid) end barPopup:Hide() end },
		[4] = { _G.ENTER_BATTLE or "Enter Battle", function() if barid then Exec("enterbattle", barid) end barPopup:Hide() end },
		[5] = { _G.LEAVE_QUEUE  or "Leave Queue",  function() if barid then Exec("leavequeue", barid) end barPopup:Hide() end },
		[6] = { _G.GAMEOPTIONS_MENU or "Options",  function() barPopup:Hide() Capping.OpenOptions() end },
	}
	for i, info in ipairs(popBtnLabels) do
		local b = CreateFrame("Button", nil, barPopup, "UIPanelButtonTemplate")
		b:SetWidth(160); b:SetHeight(20)
		b:SetText(info[1])
		b:SetPoint("TOP", barPopup, "TOP", 0, -24 - (i-1) * 24)
		b:SetScript("OnClick", info[2])
		popBtns[i] = b
	end
	barPopup:SetHeight(24 + #popBtnLabels * 24 + 8)

	Capping.ShowBarPopup = function(bid)
		barid = bid
		local b = bid and bars[bid]
		if not b then return end
		local bname = b.name
		popTitle:SetText(bname)

		local isActive = activebars[bname]
		local isWinter = (bname == winter)
		popBtns[1][isActive and not isWinter and "Show" or "Hide"](popBtns[1])
		popBtns[2][isActive and not isWinter and "Show" or "Hide"](popBtns[2])
		popBtns[3]:Show()
		popBtns[4][not isActive and not isWinter and "Show" or "Hide"](popBtns[4])
		popBtns[5][not isActive and not isWinter and "Show" or "Hide"](popBtns[5])
		popBtns[6]:Show()
		barPopup:ClearAllPoints()
		barPopup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		barPopup:Show()
	end

	Capping.Exec, Capping.optFrame = Exec, optFrame
	end

	if type(barid) == "number" then
		if Capping.ShowBarPopup then Capping.ShowBarPopup(barid) end
	else
		if optFrame:IsShown() then
			optFrame:Hide()
		else
			optFrame:Show()
		end
	end
end
