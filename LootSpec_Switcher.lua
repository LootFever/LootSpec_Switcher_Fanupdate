--[[

	Copyright (c) 2013 Bastien Clément

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local size, space = 16, 2
--local anchor = CreateFrame("Frame", "LootSpecSwitcher", UIParent)
local anchor = CreateFrame("Frame", "LootSpecSwitcher", UIParent, BackdropTemplateMixin and "BackdropTemplate")
local buttons = {}

--anchor:SetPoint("CENTER", 0, 0)
anchor:SetPoint("TOPRIGHT","UIParent","CENTER", -541, -366)
anchor:SetFrameStrata("LOW")


local backdrop = {
	bgFile = "Interface\\BUTTONS\\WHITE8X8",
	edgeFile = "",
	tile = false, tileSize = 0, edgeSize = 4,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

anchor:SetBackdrop(backdrop)
anchor:SetBackdropColor(0, 0, 0, 0)

local function OnDragStart()
	anchor:StartMoving()
end

local function OnDragStop()
	anchor:StopMovingOrSizing()
end

anchor:SetClampedToScreen(true)
anchor:SetMovable(true)
anchor:RegisterForDrag("LeftButton")
anchor:SetScript("OnDragStart", OnDragStart)
anchor:SetScript("OnDragStop", OnDragStop)

anchor:EnableMouse(false)

local function ButtonHandler(id)
	return function()
		if GetLootSpecialization() == id then
			SetLootSpecialization(0)
		else
			SetLootSpecialization(id)
		end
	end
end

local function Init()
	local numSpecs = GetNumSpecializations()
	anchor:SetSize((size * numSpecs) + (space * (numSpecs + 1)), size + (space * 2))
	
	for i = 1, numSpecs do
		local id, _, _, icon = GetSpecializationInfo(i)
		
		local button = CreateFrame("Button", nil, anchor)
		button:SetSize(size, size)
		button:SetPoint("CENTER", anchor, "BOTTOMLEFT", ((i - 1) * (size + space)) + (size / 2) + space, (size / 2) + space)
		
		button:SetScript("OnClick", ButtonHandler(id))
		
		local tex = button:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture(icon)
		button.tex = tex
		
		buttons[id] = button
	end
end

function UpdateButtons(_, ev)
	if ev == "PLAYER_ENTERING_WORLD" and Init then
		Init()
		Init = nil
	end
	
	local current = GetLootSpecialization()
	
	for id, button in pairs(buttons) do
		if current == 0 or id == current then
			button.tex:SetAlpha(1)
		else
			button.tex:SetAlpha(0.5)
		end
	end
end

anchor:RegisterEvent("PLAYER_ENTERING_WORLD")
anchor:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
anchor:SetScript("OnEvent", UpdateButtons)

local locked = true
local function SlashHandler()
	if locked then
		anchor:SetBackdropColor(0, 0, 0, 0.6)
		anchor:EnableMouse(true)
	else
		anchor:SetBackdropColor(0, 0, 0, 0)
		anchor:EnableMouse(false)
	end
	locked = not locked
end

SlashCmdList.LSS = SlashHandler
SLASH_LSS1 = "/lsswitch"
