local ADDON_NAME, ADDON = ...
local ADDON_RollFrame = ADDON.RollFrame
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)
-----------------------------------------------------------------------------------

local NUM_GROUP_LOOT_FRAMES = 4

-- "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
-- "Interface\\DialogFrame\\UI-DialogBox-Gold-Border"
-- "Interface\\DialogFrame\\UI-DialogBox-Gold-Corner"
-- "Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon"

local TEX_CYAN = {
    ["BACKGROUND"] =  "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Cyan-Background",
    ["BORDER"] =      "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Cyan-Border",
    ["CORNER"] =      "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Cyan-Corner",
    ["DRAGON"] =      "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Cyan-Dragon",
}

local TEX_RED = {
    ["BACKGROUND"] =  "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Red-Background",
    ["BORDER"] =      "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Red-Border",
    ["CORNER"] =      "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Red-Corner",
    ["DRAGON"] =      "Interface\\AddOns\\Rollbot\\Textures\\UI-DialogBox\\UI-DialogBox-Red-Dragon",
}

local TEX = {
    ["RED"] = TEX_RED,
    ["CYAN"] = TEX_CYAN,
}

-----------------------------------------------------------------------------------

local function TryOpenNextNewFrame(itemID, rollTime, useTexture, showDelete, showCount, onClick)
    for i=1, NUM_GROUP_LOOT_FRAMES do
        local frameName = "Rollbot_RollFrame"..i
        local frame = _G[frameName]
        if ( not frame:IsShown() ) then
            frame.onClick = onClick
            frame.itemID = itemID
            frame.rollTime = rollTime
            frame.textures = TEX[useTexture]
            frame.showDelete = showDelete
            frame.showCount = showCount
            _G[frameName.."Timer"]:SetMinMaxValues(0, rollTime)
            frame:Show()
            return true
        end
    end
    return false
end

local openFrameQueue = {}

local function QueueAdd(v)
    tinsert(openFrameQueue, v)
end

local function QueueRun()
    local q = openFrameQueue[1]
    if ( q ~= nil ) then
        local ok = TryOpenNextNewFrame(
            q.itemID,
            q.rollTime,
            q.useTexture,
            q.showDelete,
            q.showCount,
            q.onClick
        )
        if ( ok ) then
            tremove(openFrameQueue, 1)
        end
    end
end

-----------------------------------------------------------------------------------

function ADDON_RollFrame.Show(itemID, rollTime, useTexture, showDelete, showCount, onClick)
    QueueAdd({
        itemID = itemID,
        rollTime = rollTime,
        useTexture = useTexture,
        showDelete = showDelete,
        showCount = showCount,
        onClick = onClick,
    })
    QueueRun()
end

-----------------------------------------------------------------------------------

function Rollbot_RollFrame_OnClick(self)
    self:SetChecked(not self:GetChecked()) -- disable check by click
    local frame = self:GetParent()
    if ( frame.onClick ) then
        frame.onClick(frame.itemID, self:GetID())
    end
    frame:Hide()
    QueueRun()
end

function Rollbot_RollFrame_OnShow(self)
	AlertFrame_FixAnchors()

	local id = self:GetID()
  local itemID = self.itemID
  local t = self.textures

  local name, link, quality, level, minLevel, type, subType, stackCount, equipLoc, texture, sellPrice = GetItemInfo(itemID)
	if ( name == nil ) then
      self:Hide()
      return
	end

  self:ClearAllPoints()
  self:SetPoint("TOPLEFT", _G["GroupLootFrame"..id], "TOPLEFT")

  self:SetBackdrop({
      bgFile = t.BACKGROUND,
      edgeFile = t.BORDER,
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  _G[self:GetName().."Corner"]:SetTexture(t.CORNER)
  _G[self:GetName().."Decoration"]:SetTexture(t.DRAGON)
  _G[self:GetName().."Decoration"]:Show()

  if ( self.showDelete ) then
      _G[self:GetName().."DeleteButton"]:Show()
      _G[self:GetName().."RollButton"]:SetPoint("TOPRIGHT", -80, -14) -- make space for bin
  else
      _G[self:GetName().."DeleteButton"]:Hide()
      _G[self:GetName().."RollButton"]:SetPoint("TOPRIGHT", -48, -14) -- original
  end

  if ( self.showCount ~= nil ) then
      _G[self:GetName().."IconFrameCount"]:Show()
      _G[self:GetName().."IconFrameCount"]:SetText(self.showCount)
  else
      _G[self:GetName().."IconFrameCount"]:Hide()
  end

	local color = ITEM_QUALITY_COLORS[quality] or { r = 1, g = 1, b = 1 }
	_G[self:GetName().."IconFrameIcon"]:SetTexture(texture)
	_G[self:GetName().."Name"]:SetText(name)
	_G[self:GetName().."Name"]:SetVertexColor(color.r, color.g, color.b)

end

function Rollbot_RollFrame_OnHide(self)
	AlertFrame_FixAnchors()
end

function Rollbot_RollFrame_OnUpdate(self, elapsed)
  local frame = self:GetParent()
	local min, max = self:GetMinMaxValues()
  frame.rollTime = frame.rollTime - elapsed
	if ( (frame.rollTime < min) or (frame.rollTime > max) ) then
		frame.rollTime = min
	end
	self:SetValue(frame.rollTime)
end

-----------------------------------------------------------------------------------
