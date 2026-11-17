local Capping = CreateFrame("Button", "Capping", UIParent)
local self = Capping
local L = CappingLocale
Capping.L = L
CappingLocale = nil

local media = LibStub("LibSharedMedia-3.0")
media:Register("statusbar", "BantoBarReverse", "Interface\\AddOns\\Capping\\BantoBarReverse")

local _G = getfenv(0)
local format, strmatch, strlower, type = format, strmatch, strlower, type
local min, floor, math_sin, math_pi, tonumber = min, floor, math.sin, math.pi, tonumber
local GetTime, time = GetTime, time

local db, wasInBG, bgmap, bgtab, realm, _, instance
local activebars, bars, currentq, bgdd = { }, { }, { }, { }
local av, ab, eots, wsg, winter, ioc = L["Alterac Valley"], L["Arathi Basin"], L["Eye of the Storm"], L["Warsong Gulch"], L["Wintergrasp"], L["Isle of Conquest"]
local stamin = 1 / 60
local narrowed, borderhidden, pointset, ACountText, HCountText
Capping.backdrop = { bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", }
Capping.activebars = activebars

local ShowOptions
local oSetPoint = Capping.SetPoint
local nofunc = function() end
local function ToggleAnchor()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end
local function SetPoints(this, lp, lrt, lrp, lx, ly, rp, rrt, rrp, rx, ry)
	this:ClearAllPoints()
	this:SetPoint(lp, lrt, lrp, lx, ly)
	if rp then this:SetPoint(rp, rrt, rrp, rx, ry) end
end
local function SetWH(this, w, h)
	this:SetWidth(w)
	this:SetHeight(h)
end
local function NewText(parent, font, fontsize, justifyH, justifyV, overlay)
	local t = parent:CreateFontString(nil, overlay or "OVERLAY")
	if fontsize then
		t:SetFont(font, fontsize)
		t:SetShadowColor(0, 0, 0)
		t:SetShadowOffset(1, -1)
	else
		t:SetFontObject(font)
	end
	t:SetJustifyH(justifyH)
	t:SetJustifyV(justifyV)
	return t
end

local StartWinterGraspTimer, warned
local wgnext = 0
local function WGInProgress()

	local now = GetTime()
	if now < wgnext then return end
	wgnext = now + 10
	if GetMapInfo() == "LakeWintergrasp" then
		Capping:StopBar(_G.WINTERGRASP_IN_PROGRESS or "WG in Progress")
	elseif StartWinterGraspTimer() then
		Capping:StopBar(_G.WINTERGRASP_IN_PROGRESS or "WG in Progress")
	end
end
local function WGSoon(remain)
	if remain < 60 and remain > 59 and not Capping.wgwarned then
		Capping.wgwarned = true
		RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format(PVPBATTLEGROUND_WINTERGRASPTIMER_TOOLTIP, "1m"))
	end
end
local function WGStarting()
	if GetMapInfo() ~= "LakeWintergrasp" then
		Capping:StartBar(_G.WINTERGRASP_IN_PROGRESS or "WG in Progress", 1805, 1805, "Interface\\Icons\\INV_EssenceOfWintergrasp", "info2", 10, true, nil, nil, WGInProgress)
	end
end
StartWinterGraspTimer = function()
	if not db.winter or IsInInstance() then return end
	local duration = GetWintergraspWaitTime() or 0
	if duration < 1 then
		db[realm] = nil
		return Capping:StopBar(winter)
	end
	db[realm] = time() + duration
	Capping.wgwarned = nil
	Capping:StartBar(winter, (duration > 900 and 8400) or 900, duration, "Interface\\Icons\\INV_EssenceOfWintergrasp", "info1", true, true, nil, WGStarting, WGSoon)
	return true
end
local function StartMoving(this) this:StartMoving() end
local function CreateMover(oldframe, w, h, dragstopfunc)
	local mover = oldframe or CreateFrame("Button", nil, UIParent)
	SetWH(mover, w, h)
	mover:SetBackdrop(Capping.backdrop)
	mover:SetBackdropColor(0, 0, 0, 0.7)
	mover:SetMovable(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", StartMoving)
	mover:SetScript("OnDragStop", dragstopfunc)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover.close = CreateFrame("Button", nil, mover, "UIPanelCloseButton")
	SetWH(mover.close, 20, 20)
	mover.close:SetPoint("TOPRIGHT", 5, 5)
	return mover
end
hooksecurefunc(WorldStateAlwaysUpFrame, "SetPoint", function()
	if not db or not db.sbx then return end
	oSetPoint(WorldStateAlwaysUpFrame, "TOP", UIParent, "TOPLEFT", db.sbx, db.sby)
end)
local function wsaufu()
	if not db or not db.cbx then return end
	local nexty = 0
	for i = 1, NUM_EXTENDED_UI_FRAMES or 0 do
		local cb = _G["WorldStateCaptureBar"..i]
		if cb and cb:IsShown() then
			cb:ClearAllPoints()
			cb:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", db.cbx, db.cby - nexty)
			nexty = nexty + cb:GetHeight()
		end
	end
end
hooksecurefunc("WorldStateAlwaysUpFrame_Update", wsaufu)
hooksecurefunc(VehicleSeatIndicator, "SetPoint", function()
	if not db or not db.seatx then return end
	oSetPoint(VehicleSeatIndicator, "TOPRIGHT", UIParent, "BOTTOMLEFT", db.seatx, db.seaty)
end)
local function UpdateZoneMapVisibility()
	if (not bgmap or not bgmap:IsShown()) and GetCVar("showBattlefieldMinimap") ~= "0" then
		if not bgmap then
			LoadAddOn("Blizzard_BattlefieldMinimap")

			if not bgmap and BattlefieldMinimap and Capping.InitBGMap then Capping:InitBGMap() end
		end
		if bgmap then bgmap:Show() end
	end
end
hooksecurefunc("WorldMapZoneMinimapDropDown_OnClick", function()
	if GetMapInfo() == "LakeWintergrasp" then
		UpdateZoneMapVisibility()
	end
end)

local elist, clist = {}, {}
Capping:SetScript("OnEvent", function(this, event, ...)
	this[elist[event] or event](this, ...)
end)
function Capping:RegisterTempEvent(event, other)
	self:RegisterEvent(event)
	elist[event] = other or event
end
function Capping:CheckCombat(func)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		for i = 1, #clist do
			if clist[i] == func then return end
		end
		tinsert(clist, func)
	else
		func(self)
	end
end
function Capping:PLAYER_REGEN_ENABLED()
	for k, v in ipairs(clist) do
		v(self)
	end
	wipe(clist)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

Capping:RegisterEvent("ADDON_LOADED")

function Capping:ADDON_LOADED(a1)

	if a1 ~= "Capping" then return end

	CappingDB = CappingDB or {}
	db = CappingCharDB or (CappingDB.profiles and CappingDB.profiles.Default) or CappingDB
	self.db = db
	if db.dbinit ~= 6 then
		db.dbinit = 6
		local function SetDefaults(db, t)
			for k, v in pairs(t) do
				if type(db[k]) == "table" then
					SetDefaults(db[k], v)
				else
					db[k] = (db[k] ~= nil and db[k]) or v
				end
			end
		end
		SetDefaults(db, {
			av = true, avquest = true, ab = true, wsg = true, arena = true, eots = true, winter = true, ioc = true,
			port = true, wait = true,
			mapscale = 1.3, narrow = true, hidemapborder = false,
			texture = "BantoBarReverse",
			width = 200, height = 15, inset = 0, spacing = 1,
			mainup = false, reverse = false, fill = false,
			iconpos = "<-", timepos = "<-",
			font = "Friz Quadrata TT", fontsize = 10,
			colors = {
				alliance = { r=0.0, g=0.0, b=1.0, a=1.0, },
				horde = { r=1.0, g=0.0, b=0.0, a=1.0, },
				info1 = { r=0.6, g=0.6, b=0.6, a=1.0, },
				info2 = { r=1.0, g=1.0, b=0.0, a=1.0, },
				font = { r=1, g=1, b=1, a=1, },
			},
		})
	end
	db.colors.spark = db.colors.spark or { r=1, g=1, b=1, a=1, }
	for _, key in pairs({"alliance", "horde", "info1", "info2"}) do
		local c = db.colors[key]
		if c and (not c.a or c.a < 0.15) then
			c.a = 1.0
		end
	end
  	SlashCmdList.CAPPING = ShowOptions
   	SLASH_CAPPING1 = "/capping"

   	realm = GetCVar("realmName")

	local panel = CreateFrame("Frame")
	panel.name = "Capping"
	panel:SetScript("OnShow", function(this)
		local t1 = NewText(this, GameFontNormalLarge, nil, "LEFT", "TOP", "ARTWORK")
		t1:SetPoint("TOPLEFT", 16, -16)
		t1:SetText(this.name)

		local t2 = NewText(this, GameFontHighlightSmall, nil, "LEFT", "TOP", "ARTWORK")
		t2:SetHeight(43)
		SetPoints(t2, "TOPLEFT", t1, "BOTTOMLEFT", 0, -8, "RIGHT", this, "RIGHT", -32, 0)
		t2:SetNonSpaceWrap(true)
		local function GetInfo(field)
			return GetAddOnMetadata("Capping", field) or "N/A"
		end
		t2:SetFormattedText("Notes: %s\nAuthor: %s\nVersion: %s", GetInfo("Notes"), GetInfo("Author"), GetInfo("Version"))

		local b = CreateFrame("Button", nil, this, "UIPanelButtonTemplate")
		SetWH(b, 120, 20)
		b:SetText(_G.GAMEOPTIONS_MENU)
		b:SetScript("OnClick", ShowOptions)
		b:SetPoint("TOPLEFT", t2, "BOTTOMLEFT", -2, -8)
		this:SetScript("OnShow", nil)
	end)
	InterfaceOptions_AddCategory(panel)

	self:Hide()
	if db.x then
		self:SetPoint(db.p or "TOPLEFT", UIParent, db.rp or "TOPLEFT", db.x, db.y)
	else
		self:SetPoint("CENTER", UIParent, "CENTER", 200, -100)
	end
	CreateMover(self, db.width, 10, function(this)
		this:StopMovingOrSizing()
		local a,b,c,d,e = this:GetPoint()
		db.p, db.rp, db.x, db.y = a, c, floor(d + 0.5), floor(e + 0.5)
	end)
	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", ShowOptions)
	self:SetNormalFontObject(GameFontHighlightSmall)
	self:SetText("Capping")

	if db.sbx then WorldStateAlwaysUpFrame:SetPoint("TOP") end
	if db.cbx then wsaufu() end
	if db.seatx then VehicleSeatIndicator:SetPoint("TOPRIGHT") end

	if BattlefieldMinimap then
		self:InitBGMap()
	else
		function Capping:ADDON_LOADED(a1)
			if a1 ~= "Blizzard_BattlefieldMinimap" then return end
			self:InitBGMap()
		end
	end
	if IsLoggedIn() then
		self:PLAYER_ENTERING_WORLD()
	else
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function Capping:InitBGMap()

	bgmap, bgtab = BattlefieldMinimap, BattlefieldMinimapTab
	BattlefieldMinimapOptions = BattlefieldMinimapOptions or { opacity = 0.7, locked = true, showPlayers = true, }

	bgmap:UnregisterEvent("PLAYER_LOGOUT")
	bgmap:UnregisterEvent("ADDON_LOADED")

	bgdd.text, bgdd.func = "Capping", ShowOptions
	hooksecurefunc("BattlefieldMinimapTabDropDown_Initialize", function() UIDropDownMenu_AddButton(bgdd, 1) end)

	hooksecurefunc(bgtab, "StopMovingOrSizing", function()
		if Capping.initializingMap then return end
		local x, y = bgtab:GetCenter()
		if not x or not y then return end
		BattlefieldMinimapOptions.position = BattlefieldMinimapOptions.position or { }
		BattlefieldMinimapOptions.position.x = floor(x - (narrowed and pointset and 153 or 0) + 0.5)
		BattlefieldMinimapOptions.position.y = floor(y + 0.5)
		db.bgmapx, db.bgmapy = BattlefieldMinimapOptions.position.x, BattlefieldMinimapOptions.position.y
		Capping:ModMap()
	end)

	if BattlefieldMinimapOptions.position and BattlefieldMinimapOptions.position.x then
		bgtab:SetPoint("CENTER", UIParent, "BOTTOMLEFT", BattlefieldMinimapOptions.position.x, BattlefieldMinimapOptions.position.y)
	elseif db.bgmapx then
		bgtab:SetPoint("CENTER", UIParent, "BOTTOMLEFT", db.bgmapx, db.bgmapy)
	end

	Capping.initializingMap = true
	bgtab:StopMovingOrSizing()
	Capping.initializingMap = nil
	bgtab:SetUserPlaced(true)
	BattlefieldMinimap_OnEvent(nil, "ADDON_LOADED", "Blizzard_BattlefieldMinimap")
	self:ModMap()
	self:UnregisterEvent("ADDON_LOADED")
	self.InitBGMap, self.ADDON_LOADED = nil, nofunc
end

function Capping:PLAYER_ENTERING_WORLD()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:UPDATE_BATTLEFIELD_STATUS()
	self:ZoneCheck()
	if db.winter and not StartWinterGraspTimer() and db[realm] and time() < db[realm] then
		self:StartBar(winter, 9225, db[realm] - time(), "Interface\\Icons\\INV_EssenceOfWintergrasp", "info1", 1500, true)
	end
	PVPBattlegroundFrame:HookScript("OnShow", StartWinterGraspTimer)
	self.PLAYER_ENTERING_WORLD = nil
end

function Capping:ZONE_CHANGED_NEW_AREA()

	if wasInBG then
		self:ResetAll()
	end
	self:ZoneCheck()
end

local tohide = { }
local function HideProtectedStuff()
	for _, v in ipairs(tohide) do
		v:Hide()
	end
end

function Capping:AddFrameToHide(frame)

	tinsert(tohide, frame)
end

function Capping:ResetAll()

	wasInBG = false
	for event in pairs(elist) do
		elist[event] = nil
		self:UnregisterEvent(event)
	end
	for value, _ in pairs(activebars) do
		self:StopBar(value)
		activebars[value] = nil
	end
	if self.ClearBGData then self:ClearBGData() end
	self:CheckCombat(HideProtectedStuff)
	if ACountText then ACountText:SetText("") end
	if HCountText then HCountText:SetText("") end
end

local function LoadBGModule()
	if Capping.StartAB then return true end
	local run = Capping.RunBGPart
	Capping.RunBGPart = nil
	if run then run() end
	return Capping.StartAB and true or false
end

function Capping:ZoneCheck()

	SetMapToCurrentZone()
	_, instance = IsInInstance()
	if instance == "pvp" then
		local z = GetMapInfo()
		wasInBG = true
		local want = (z == "WarsongGulch" and db.wsg) or (z == "NetherstormArena" and db.eots) or (z == "ArathiBasin" and db.ab)
			or (z == "AlteracValley" and db.av) or (z == "IsleofConquest" and db.ioc)
		if want and LoadBGModule() then
			if z == "WarsongGulch" then
				self:StartWSG()
			elseif z == "NetherstormArena" then
				self:StartEotS()
			elseif z == "ArathiBasin" then
				self:StartAB()
			elseif z == "AlteracValley" then
				self:StartAV()
			elseif z == "IsleofConquest" then
				self:StartIoC()
			end
		end
		if not self.bgtotals then
			self.bgtotals = CreateFrame("Frame", nil, AlwaysUpFrame1)
			self.bgtotals:SetScript("OnUpdate", function(this, elapsed)
				this.elapsed = (this.elapsed or 0) + elapsed
				if this.elapsed < 4 then return end
				this.elapsed = 0
				RequestBattlefieldScoreData()
			end)
			self:AddFrameToHide(self.bgtotals)
		end
		self.bgtotals:Show()

		self:RegisterTempEvent("UPDATE_BATTLEFIELD_SCORE", "UpdateCountText")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "CheckStartTimer")
		RequestBattlefieldScoreData()

		UpdateZoneMapVisibility()
	elseif GetMapInfo() == "LakeWintergrasp" then
		StartWinterGraspTimer()
		UpdateZoneMapVisibility()
		wasInBG = true
		Capping.CheckWinterEnd = StartWinterGraspTimer
		self:RegisterTempEvent("CHAT_MSG_RAID_BOSS_EMOTE", "CheckWinterEnd")
		if db.winter and LoadBGModule() then
			self:StartWintergrasp()
		end
	else
		if instance == "arena" then
			self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "CheckStartTimer")
			wasInBG = true
		else
			StartWinterGraspTimer()
		end
		if bgmap and bgmap:IsShown() and GetCVar("showBattlefieldMinimap") ~= "2" then
			bgmap:Hide()
		end
	end
	self:ModMap()
end

local clipPrefixes = { "BattlefieldMinimapPOI", "BattlefieldMinimapRaid", "BattlefieldMinimapParty", "BattlefieldMinimapFlag", "BattlefieldMinimapVehicle" }
local clipFrames = { {}, {}, {}, {}, {} }
local clipper
local function ClipNarrowIcons()
	if not narrowed or not bgmap or not BattlefieldMinimap2 or not BattlefieldMinimap3 then return end
	local l, r = BattlefieldMinimap2:GetLeft(), BattlefieldMinimap3:GetRight()
	if not l or not r then return end
	local ts = bgmap:GetEffectiveScale()
	l, r = l * ts, r * ts
	for p = 1, #clipPrefixes do

		local cache = clipFrames[p]
		local n = #cache
		while n < 60 do
			local f = _G[clipPrefixes[p]..(n + 1)]
			if not f then break end
			n = n + 1
			cache[n] = f
		end
		for i = 1, n do
			local f = cache[i]
			if f:IsShown() then
				local cx = f:GetCenter()
				if cx then
					cx = cx * f:GetEffectiveScale()
					if cx < l or cx > r then f:Hide() end
				end
			end
		end
	end
end

function Capping:ModMap(disable)

	if not bgmap or not bgtab then return end
	bgmap:SetScale(db.mapscale)
	disable = instance ~= "pvp" or disable

	if db.narrow and not narrowed and not disable then
		BattlefieldMinimap1:Hide() BattlefieldMinimap4:Hide() BattlefieldMinimap5:Hide()
		BattlefieldMinimap8:Hide() BattlefieldMinimap9:Hide() BattlefieldMinimap12:Hide()
		BattlefieldMinimapBackground:SetWidth(256 / 2)
		BattlefieldMinimapBackground:SetPoint("TOPLEFT", -12 + 64, 12)
		BattlefieldMinimapCorner:SetPoint("TOPRIGHT", -2 - 52, 3 + 1)
		SetWH(BattlefieldMinimapCorner, 24, 24)
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", bgmap, "TOPRIGHT", 2 - 53, 7)
		SetWH(BattlefieldMinimapCloseButton, 24, 24)
		narrowed = 1
	elseif narrowed and (disable or not db.narrow) then
		BattlefieldMinimap1:Show() BattlefieldMinimap4:Show() BattlefieldMinimap5:Show()
		BattlefieldMinimap8:Show() BattlefieldMinimap9:Show() BattlefieldMinimap12:Show()
		BattlefieldMinimapBackground:SetWidth(256)
		BattlefieldMinimapBackground:SetPoint("TOPLEFT", -12, 12)
		BattlefieldMinimapCorner:SetPoint("TOPRIGHT", -2, 3)
		SetWH(BattlefieldMinimapCorner, 32, 32)
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", bgmap, "TOPRIGHT", 2, 7)
		SetWH(BattlefieldMinimapCloseButton, 32, 32)
		narrowed = nil
		if BattlefieldMinimap_Update then BattlefieldMinimap_Update() end
	end

	if not Capping.narrowClipHooked then
		Capping.narrowClipHooked = true
		if BattlefieldMinimap_Update then hooksecurefunc("BattlefieldMinimap_Update", ClipNarrowIcons) end

		clipper = CreateFrame("Frame", nil, bgmap)
		clipper:Hide()
		local acc = 0
		clipper:SetScript("OnUpdate", function(_, elapsed)
			acc = acc + elapsed
			if acc > 0.25 then acc = 0; ClipNarrowIcons() end
		end)
	end
	if narrowed then
		clipper:Show()
		ClipNarrowIcons()
	else
		clipper:Hide()
	end

	local tx, ty = bgtab:GetCenter()
	if narrowed and not db.narrowanchorleft and not pointset then
		if tx then
			bgtab:ClearAllPoints()
			bgtab:SetPoint("CENTER", UIParent, "BOTTOMLEFT", tx + (116 * db.mapscale), ty)
			bgtab:SetUserPlaced(true)
			pointset = true
		end
	elseif not narrowed and pointset then
		if tx then
			bgtab:ClearAllPoints()
			bgtab:SetPoint("CENTER", UIParent, "BOTTOMLEFT", tx - (116 * db.mapscale), ty)
		end
		pointset = nil
	end

	if db.hidemapborder and not borderhidden then
		BattlefieldMinimapBackground:Hide()
		BattlefieldMinimapCorner:Hide()
		BattlefieldMinimapCloseButton:SetParent(bgtab)
		BattlefieldMinimapCloseButton:SetScale(db.mapscale)
		if not Capping.closeButtonHooked then
			BattlefieldMinimapCloseButton:HookScript("OnClick", function() bgmap:Hide() end)
			Capping.closeButtonHooked = true
		end
		borderhidden = true
	elseif not db.hidemapborder and borderhidden then
		BattlefieldMinimapBackground:Show()
		BattlefieldMinimapCorner:Show()
		BattlefieldMinimapCloseButton:SetParent(bgmap)
		BattlefieldMinimapCloseButton:SetScale(1)
		borderhidden = nil
	end

	bgmap:ClearAllPoints()
	bgmap:SetPoint("TOPLEFT", bgtab, "BOTTOMLEFT", (narrowed and -64) or 0, (borderhidden and 0) or -5)
end

do
	local q, p = L["Queue: %s"], L["Port: %s"]
	local maxq = MAX_BATTLEFIELD_QUEUES
	local GetBattlefieldStatus = GetBattlefieldStatus
	local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
	local GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited = GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited

	function Capping:UPDATE_BATTLEFIELD_STATUS()

		if not db.port and not db.wait then return end

		for map in pairs(currentq) do
			currentq[map] = 0
		end
		for i = 1, maxq, 1 do
			local status, map, _, _, _, teamsize, _ = GetBattlefieldStatus(i)
			if map and (teamsize or 0) > 0 then
				map = format("%s (%dv%d)", map, teamsize, teamsize)
			end
			if status == "confirm" and db.port then
				self:StopBar(format(q, map))
				self:StartBar(format(p, map), instance == "pvp" and 20 or 40, GetBattlefieldPortExpiration(i), "Interface\\Icons\\Ability_TownWatch", "info2", true, true)
				currentq[map] = i
			elseif status == "queued" and db.wait then
				local esttime = GetBattlefieldEstimatedWaitTime(i) * 0.001
				local estremain = esttime - GetBattlefieldTimeWaited(i) * 0.001
				self:StartBar(format(q, map), esttime > 1 and esttime or 1, estremain > 1 and estremain or 1, "Interface\\Icons\\INV_Misc_Note_03", "info1", 1500, true)
				currentq[map] = i
			end
		end
		for map, flag in pairs(currentq) do
			if flag == 0 then
				self:StopBar(format(p, map))
				self:StopBar(format(q, map))
				currentq[map] = nil
			end
		end
	end
end

local temp = { }
local function CheckActive(barid)
	local f = bars[barid]
	if f and f:IsShown() then return f end
end
local function DoReport(this, chan)
	if not activebars[this.name] then return end
	local faction = (this.color == "horde" and _G.FACTION_HORDE) or (this.color == "alliance" and _G.FACTION_ALLIANCE) or ""
	SendChatMessage(format(L["%s: %s - %d:%02d"], faction, this.displaytext:GetText(), this.remaining * stamin, this.remaining % 60), chan)
end
local function CheckQueue(name, join)
	local qid = currentq[(gsub(name, "^(.+): ", ""))]
	if type(qid) == "number" then
		AcceptBattlefieldPort(qid, join)
		return true
	end

end
local function ReportBG(barid)
	local this = CheckActive(barid)
	if not this then return end
	if not CheckQueue(this.name, true) then
		DoReport(this, "BATTLEGROUND")
	end
end
local function ReportSAY(barid)
	local this = CheckActive(barid)
	if not this then return end
	DoReport(this, "SAY")
end
local function CancelBar(barid)
	local this = CheckActive(barid)
	if not this then return end
	if not CheckQueue(this.name, nil) then
		Capping:StopBar(nil, this)
	end
end
local function BarOnClick(this, button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			ReportSAY(this.id)
		elseif IsControlKeyDown() then
			ReportBG(this.id)
		else
			ToggleAnchor()
		end
	elseif button == "RightButton" then
		if IsControlKeyDown() then
			CancelBar(this.id)
		else
			if Capping.ShowBarPopup then
				Capping.ShowBarPopup(this.id)
			else
				ShowOptions(nil, this.id)
			end
		end
	end
end

local function SetDepleteValue(this, remain, duration)
	this.bar:SetValue( (remain > 0 and remain or 0.0001) / duration )
end
local function SetFillValue(this, remain, duration)
	this.bar:SetValue( ((remain > 0 and duration - remain) or duration) / duration )
end
local function BarOnUpdate(this, a1)
	this.elapsed = this.elapsed + a1
	if this.elapsed < this.throt then return end
	this.elapsed = 0

	local remain = this.endtime - GetTime()
	this.remaining = remain

	this:SetValue(remain, this.duration)
	this.pfunction(remain)
	if remain < 60 then
		if remain < 10 then
			if remain > 0.5 then
				this:SetAlpha(0.75 + 0.25 * math_sin(remain * math_pi))
			elseif remain > -1.5 then
				this:SetAlpha((remain + 1.5) * 0.5)
			elseif this.noclose then
				if remain < -this.noclose then
					pcall(this.endfunction)
					Capping:StopBar(nil, this)
				else
					this:SetAlpha(0.7)
					this.throt = 10
					pcall(this.endfunction)
				end
				return
			else
				pcall(this.endfunction)
				return Capping:StopBar(nil, this)
			end
			this.throt = 0.05
		end
		this.timetext:SetFormattedText("%d", remain < 0 and 0 or remain)
	elseif remain < 600 then
		this.timetext:SetFormattedText("%d:%02d", remain * stamin, remain % 60)
	elseif remain < 3600 then
		this.timetext:SetFormattedText("%dm", remain * stamin)
	else
		this.timetext:SetFormattedText("|cffaaaaaa%d:%02d|r", remain / 3600, remain % 3600 * stamin)
	end
end
local function lsort(a, b)
	return bars[a].remaining < bars[b].remaining
end
local function SortBars()
	wipe(temp)
	for i = 1, #bars, 1 do
		temp[i] = i
	end
	sort(temp, lsort)
	local pdown, pup = -1, -1
	for _, k in ipairs(temp) do
		local f = bars[k]
		if f:IsShown() then
			if f.down then
				SetPoints(f, "TOPLEFT", bars[pdown] or Capping, "BOTTOMLEFT", 0, -(db.spacing or 1))
				pdown = k
			else
				SetPoints(f, "BOTTOMLEFT", bars[pup] or Capping, "TOPLEFT", 0, db.spacing or 1)
				pup = k
			end
		end
	end
end
local function SetValue(this, frac)
	frac = (frac < 0.0001 and 0.0001) or (frac > 1 and 1) or frac
	this:SetWidth(frac * this.basevalue)
	this:SetTexCoord(0, frac, 0, 1)
end
local function SetReverseValue(this, frac)
	frac = (frac < 0.0001 and 0.0001) or (frac > 1 and 1) or frac
	this:SetWidth(frac * this.basevalue)
	this:SetTexCoord(frac, 0, 0, 1)
end
local function UpdateBarLayout(f)
	local inset, w, h, tc = db.inset or 0, db.width or 200, db.height or 12, db.colors.font
	local icon, bar, barback, spark, timetext, displaytext = f.icon, f.bar, f.barback, f.spark, f.timetext, f.displaytext
	local nh = h * (db.altstyle and 0.25 or 1)
	local ih = nh - 2 * inset
	ih = ih > 0 and ih or 0.5
	SetWH(f, w, h)
	SetWH(icon, h, h)
	SetWH(barback, w - h, nh)
	bar:SetHeight(ih)
	spark:SetHeight(2.35 * ih)
	spark:SetVertexColor(db.colors.spark.r, db.colors.spark.g, db.colors.spark.b, db.colors.spark.a)
	timetext:SetTextColor(tc.r, tc.g, tc.b, tc.a)
	displaytext:SetTextColor(tc.r, tc.g, tc.b, tc.a)
	f.SetValue = db.fill and SetFillValue or SetDepleteValue
	if db.iconpos == "X" then
		icon:Hide()
		barback:SetWidth(w)
		SetPoints(barback, "BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
	elseif db.iconpos == "->" then
		icon:Show()
		SetPoints(icon, "RIGHT", f, "RIGHT", 0, 0)
		SetPoints(barback, "BOTTOMRIGHT", icon, "BOTTOMLEFT", 0, 0)
	else
		icon:Show()
		SetPoints(icon, "LEFT", f, "LEFT", 0, 0)
		SetPoints(barback, "BOTTOMLEFT", icon, "BOTTOMRIGHT", 0, 0)
	end
	if db.timepos == "->" then
		SetPoints(timetext, "RIGHT", barback, "RIGHT", -(4 + inset), db.altstyle and (0.5 * h) or 0)
		SetPoints(displaytext, "LEFT", barback, "LEFT", (4 + inset), db.altstyle and (0.5 * h) or 0, "RIGHT", timetext, "LEFT", -(4 + inset), 0)
	else
		SetPoints(displaytext, "LEFT", barback, "LEFT", db.fontsize * 3, db.altstyle and (0.5 * h) or 0, "RIGHT", barback, "RIGHT", -(4 + inset), 0)
		SetPoints(timetext, "RIGHT", displaytext, "LEFT", -db.fontsize / 2.2, 0)
	end
	if db.reverse then
		SetPoints(bar, "RIGHT", barback, "RIGHT", -inset, 0)
		spark:SetPoint("CENTER", bar, "LEFT", 0, 0)
		bar.SetValue = SetReverseValue
	else
		SetPoints(bar, "LEFT", barback, "LEFT", inset, 0)
		spark:SetPoint("CENTER", bar, "RIGHT", 0, 0)
		bar.SetValue = SetValue
	end
	f:EnableMouse(not db.lockbar)
	local iconWidth = (db.iconpos == "X") and 0 or h
	bar.basevalue = (w - iconWidth) - (2 * inset)
	if bar.basevalue < 1 then bar.basevalue = 1 end
	if f:IsShown() then
		BarOnUpdate(f, 11)
	end
end

function Capping:GetBar(name, getone)

	local f, tf
	for k, b in ipairs(bars) do
		if b.name == name then
			f = b
		elseif getone and not tf and not b:IsShown() then
			tf = b
		end
	end
	if not getone then return f end

	f = f or tf
	if not f then
		local texture = media:Fetch("statusbar", db.texture)
		local font = media:Fetch("font", db.font)

		f = CreateFrame("Button", nil, UIParent)
		f:Hide()
		f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		f:SetScript("OnClick", BarOnClick)
		f:SetScript("OnUpdate", BarOnUpdate)
		f.icon = f:CreateTexture(nil, "ARTWORK")
		f.barback = f:CreateTexture(nil, "BACKGROUND")
		f.barback:SetTexture(texture)
		f.bar = f:CreateTexture(nil, "ARTWORK")
		f.bar:SetTexture(texture)

		local spark = f:CreateTexture(nil, "OVERLAY")
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetBlendMode("ADD")
		spark:SetAlpha(0.8)
		spark:SetWidth(18)
		f.spark = spark

		f.timetext = NewText(f, font, db.fontsize, "RIGHT", "CENTER")
		f.displaytext = NewText(f, font, db.fontsize, "LEFT", "CENTER")

		UpdateBarLayout(f)
		tinsert(bars, f)
		f.id = #bars
	end
	return f
end

function Capping:StartBar(name, duration, remaining, icondata, colorid, nonactive, separate, specialText, endfunction, periodicfunction)

	if not duration or not remaining then return end
	if remaining <= 0 then return end
	if duration <= 0 then duration = remaining end
	local icon, l, r, t, b
	if icondata and icondata == self.iconpath then
		icon, l, r, t, b = icondata[1], icondata[2], icondata[3], icondata[4], icondata[5]
	else
		icon, l, r, t, b = icondata, 0.07, 0.93, 0.07, 0.93
	end
	local c = db.colors[colorid or "info1"] or db.colors.info1
	if db.onegroup then
		separate = db.mainup
	elseif db.mainup then
		separate = not separate
	end
	duration = (duration < remaining and remaining) or duration

	local f = self:GetBar(name, true)
	f.name = name
	f.color = colorid
	f.endtime = GetTime() + remaining
	f.duration = duration
	f.remaining = remaining
	f.down = not separate
	f.noclose = type(nonactive) == "number" and nonactive
	f.throt = (duration < 300 and 0.1) or (duration < 600 and 0.25) or 0.5
	f.elapsed = f.throt - 0.01
	f.endfunction = endfunction or nofunc
	f.pfunction = periodicfunction or nofunc

	f.displaytext:SetText(specialText or name)
	f.icon:SetTexture(icon)
	f.icon:SetTexCoord(l or 0, r or 1, t or 0, b or 1)
	f.bar:SetVertexColor(c.r, c.g, c.b, c.a or 0.9)
	f.barback:SetVertexColor(c.r * 0.3, c.g * 0.3, c.b * 0.3, db.bgalpha or 0.7)
	f:SetAlpha(1)

	activebars[name] = (not nonactive and colorid) or nil
	f:Show()
	SortBars()
end

function Capping:StopBar(name, this)

	local f = this or self:GetBar(name)
	if f then
		if f.name then activebars[f.name] = nil end
		f.name = ""
		f:Hide()
		SortBars()
	end
end

local timetil

function Capping:CheckStartTimer(a1)

	timetil = timetil or {
		[strlower(L["1 minute"])] = 62,
		[strlower(L["One minute until"])] = 62,
		[strlower(L["60 seconds"])] = 62,
		[strlower(L["30 seconds"])] = 31,
		[strlower(L["15 seconds"])] = 16,
		[strlower(L["Forty five seconds"])] = 46,
		[strlower(L["Thirty seconds until"])] = 31,
		[strlower(L["Fifteen seconds until"])] = 16,
	}
	if type(a1) ~= "string" then return end
	a1 = strlower(a1)
	for text, duration in pairs(timetil) do
		if strfind(a1, text, 1, true) then
			self:StartBar(L["Battle Begins"], 62, duration, "Interface\\Icons\\Spell_Holy_PrayerOfHealing", "info2")
			break
		end
	end
	if instance == "arena" and strfind(a1, strlower(L["has begun"]), 1, true) then
		local spell, _, icon = GetSpellInfo(34709)
		self:StartBar(spell, 93, 93, icon, "info2")
	end
end

local GetBattlefieldScore, GetNumBattlefieldScores = GetBattlefieldScore, GetNumBattlefieldScores

function Capping:UpdateCountText()

	local auf1 = _G["AlwaysUpFrame1"]
	local auf2 = _G["AlwaysUpFrame2"]
	if not auf1 or not auf2 then return end
	local na, nh
	for i = 1, GetNumBattlefieldScores(), 1 do
		local _, _, _, _, _, ifaction = GetBattlefieldScore(i)
		if ifaction == 0 then
			nh = (nh or 0) + 1
		elseif ifaction == 1 then
			na = (na or 0) + 1
		end
	end
	local auf1Icon = _G["AlwaysUpFrame1Icon"]
	local auf2Icon = _G["AlwaysUpFrame2Icon"]
	if not auf1Icon or not auf2Icon then return end
	ACountText = ACountText or self:CreateText(auf1, 10, "CENTER", auf1Icon, 3, 2, auf1Icon, -19, 16)
	HCountText = HCountText or self:CreateText(auf2, 10, "CENTER", auf2Icon, 3, 2, auf2Icon, -19, 16)
	ACountText:SetText(na or "")
	HCountText:SetText(nh or "")

	local offset = ((not auf1Icon:GetTexture() or auf1Icon:GetTexture() == "") and 1) or 0
	local iconA = _G["AlwaysUpFrame"..(1 + offset).."Icon"]
	local iconH = _G["AlwaysUpFrame"..(2 + offset).."Icon"]
	if iconA then SetPoints(ACountText, "TOPLEFT", iconA, "TOPLEFT", 3, 2, "BOTTOMRIGHT", iconA, "BOTTOMRIGHT", -19, 16) end
	if iconH then SetPoints(HCountText, "TOPLEFT", iconH, "TOPLEFT", 3, 2, "BOTTOMRIGHT", iconH, "BOTTOMRIGHT", -19, 16) end
end

function Capping:CreateText(parent, fontsize, justifyH, tlrp, tlx, tly, brrp, brx, bry)

	local text = NewText(parent, GameFontNormal:GetFont(), fontsize, justifyH, "CENTER")
	SetPoints(text, "TOPLEFT", tlrp, "TOPLEFT", tlx, tly, "BOTTOMRIGHT", brrp, "BOTTOMRIGHT", brx, bry)
	text:SetShadowColor(0,0,0)
	text:SetShadowOffset(-1, -1)
	return text
end

Capping.bars = bars
Capping.priv = {
	UpdateBarLayout = UpdateBarLayout, SortBars = SortBars, ToggleAnchor = ToggleAnchor,
	ReportBG = ReportBG, ReportSAY = ReportSAY, CancelBar = CancelBar,
	CreateMover = CreateMover, wsaufu = wsaufu,
	GetMapTab = function() return bgtab end,
}

function ShowOptions(a1, id)
	if not Capping.OpenOptions then
		local run = Capping.RunOptionsPart
		Capping.RunOptionsPart = nil
		if run then run() end
		if not Capping.OpenOptions then return end
	end
	Capping.OpenOptions(a1, id)
end

CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}
CONFIGMODE_CALLBACKS.Capping = function(action, mode)
	if action == "ON" then
		ShowOptions()
		if Capping.Exec then Capping.Exec("test") end
		if self then
			self:Show()
			UpdateZoneMapVisibility()
		end
	elseif action == "OFF" and self then
		self:Hide()
		if Capping.optFrame then Capping.optFrame:Hide() end
		if bgmap and bgmap:IsShown() and GetCVar("showBattlefieldMinimap") ~= "2" then
			bgmap:Hide()
		end
	end
end
