local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack = unpack;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true) then return; end

	TradeSkillFrame:StripTextures(true)
	TradeSkillListScrollFrame:StripTextures()
	TradeSkillDetailScrollFrame:StripTextures()
	TradeSkillFrameInset:StripTextures()
	TradeSkillExpandButtonFrame:StripTextures()
	TradeSkillDetailScrollChildFrame:StripTextures()

	TradeSkillFrame:SetTemplate("Transparent")
	TradeSkillRankFrame:StripTextures()
	TradeSkillRankFrame:CreateBackdrop("Default")
	TradeSkillRankFrame:SetStatusBarTexture(E["media"].normTex)
	TradeSkillFilterButton:StripTextures(true)
	S:HandleButton(TradeSkillCreateButton, true)
	S:HandleButton(TradeSkillCancelButton, true)
	TradeSkillFilterButton:CreateBackdrop('Default', true)
	TradeSkillFilterButton.backdrop:SetAllPoints()
	S:HandleButton(TradeSkillCreateAllButton, true)
	S:HandleButton(TradeSkillViewGuildCraftersButton, true)

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)

	TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
	TradeSkillLinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
	TradeSkillLinkButton:GetHighlightTexture():Kill()
	TradeSkillLinkButton:CreateBackdrop("Default")
	TradeSkillLinkButton:Size(17, 14)
	TradeSkillLinkButton:Point("LEFT", TradeSkillLinkFrame, "LEFT", 5, -1)
	S:HandleEditBox(TradeSkillFrameSearchBox)
	S:HandleEditBox(TradeSkillInputBox)
	S:HandleNextPrevButton(TradeSkillDecrementButton)
	S:HandleNextPrevButton(TradeSkillIncrementButton)
	TradeSkillIncrementButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0)

	S:HandleCloseButton(TradeSkillFrameCloseButton)

	local once = false
	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		TradeSkillSkillIcon:StyleButton()
		TradeSkillSkillIcon:SetTemplate("Default")
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			TradeSkillSkillIcon:GetNormalTexture():SetInside()
		end
		
		TradeSkillRankFrame:SetStatusBarColor(0.11, 0.50, 1.00)
		TradeSkillRankFrame:Height(17)
		TradeSkillRankFrame:Width(275)
		TradeSkillRankFrame:Point("TOPLEFT", TradeSkillFrame, "TOPLEFT", 30, -22)
		
		TradeSkillFrameSearchBox:Point("TOPLEFT", TradeSkillRankFrame, "BOTTOMLEFT", 30, -20)
		TradeSkillFrameSearchBox:Height(17)
		TradeSkillFrameSearchBox:Width(170)
		
		TradeSkillFilterButton:Height(20)
		TradeSkillFilterButton:Width(60)
		TradeSkillFilterButton:Point("LEFT", TradeSkillFilterFrame, "LEFT", 5, 0)
		
		TradeSkillLinkButton:Point("LEFT", TradeSkillLinkFrame, "LEFT", 5, -38)

		for i=1, MAX_TRADE_SKILL_REAGENTS do
			local button = _G["TradeSkillReagent"..i]
			local icon = _G["TradeSkillReagent"..i.."IconTexture"]
			local count = _G["TradeSkillReagent"..i.."Count"]
			
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("OVERLAY")
			if not icon.backdrop then
				icon.backdrop = CreateFrame("Frame", nil, button)
				icon.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
				icon.backdrop:SetTemplate("Default")
				icon.backdrop:SetOutside(icon)
			end

			icon:SetParent(icon.backdrop)
			count:SetParent(icon.backdrop)
			count:SetDrawLayer("OVERLAY")
			button:StyleButton()

			if i > 2 and once == false then
				local point, anchoredto, point2, x, y = button:GetPoint()
				button:ClearAllPoints()
				button:Point(point, anchoredto, point2, x, y - 3)
				once = true
			end

			_G["TradeSkillReagent"..i.."NameFrame"]:Kill()
		end
		
		local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(id);
		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if (quality and quality > 1) then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality));
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			end
		end
		local numReagents = GetTradeSkillNumReagents(id);
		for i = 1, numReagents, 1 do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
			local reagentLink = GetTradeSkillReagentItemLink(id, i)
			local reagent = _G["TradeSkillReagent"..i]
			if reagent:IsShown() then
				if reagentLink then
					local quality = select(3, GetItemInfo(reagentLink))
					if (quality and quality > 1) then
						_G["TradeSkillReagent"..i.."IconTexture"].backdrop:SetBackdropBorderColor(GetItemQualityColor(quality));
					else
						_G["TradeSkillReagent"..i.."IconTexture"].backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				end
			end
		end
	end)

	hooksecurefunc('TradeSkillFrame_Update', function()
		local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
		local diplayedSkills = TRADE_SKILLS_DISPLAYED;
		local numTradeSkills = GetNumTradeSkills();
		local buttonIndex = 1
		for i = 1, diplayedSkills, 1 do
			local skillIndex = i + skillOffset
			local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(skillIndex);
			local hasFilterBar = TradeSkillFilterBar:IsShown();
			if ( skillIndex <= numTradeSkills ) then
				if ( skillType == "header" ) then
					if hasFilterBar then 
						buttonIndex = i + 1;
					else
						buttonIndex = i;
					end
					local skillButton = _G["TradeSkillSkill"..buttonIndex];
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
					skillButton:GetNormalTexture():Size(10)
					skillButton:GetNormalTexture():SetPoint("LEFT", 3, 2);
					skillButton:SetHighlightTexture('')
					if ( isExpanded ) then
						skillButton:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375)
					else
						skillButton:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
					end
					--skillButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
					--skillButton:GetDisabledTexture():SetPoint("LEFT", 3, 2);
					--skillButton:GetDisabledTexture():Size(10)
					--skillButton:GetDisabledTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
					--skillButton:GetDisabledTexture():SetDesaturated(true)
				end
			end
		end
	end)
	
	--Collapse All Button
	TradeSkillCollapseAllButton:HookScript('OnUpdate', function(self)
		self:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self:SetHighlightTexture("")
		self:GetNormalTexture():SetPoint("LEFT", 3, 2)
		self:GetNormalTexture():Size(10)
		if (self.collapsed) then
			self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
		else
			self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375)
		end
		self:SetDisabledTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self:GetDisabledTexture():SetPoint("LEFT", 3, 2)
		self:GetDisabledTexture():Size(10)
		self:GetDisabledTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
		self:GetDisabledTexture():SetDesaturated(true)
	end)
	
	--Guild Crafters
	TradeSkillGuildFrame:StripTextures()
	TradeSkillGuildFrame:SetTemplate("Transparent")
	TradeSkillGuildFrame:Point("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
	TradeSkillGuildFrameContainer:StripTextures()
	TradeSkillGuildFrameContainer:SetTemplate("Default")
	S:HandleCloseButton(TradeSkillGuildFrameCloseButton)

end

S:RegisterSkin("Blizzard_TradeSkillUI", LoadSkin);