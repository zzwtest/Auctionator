
---@type ns
local ns = select(2, ...) 


AuctionatorConfigTabMixin = {}

function AuctionatorConfigTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigTabMixin:OnLoad()")

  if Auctionator.Constants.IsClassic then
    -- Reposition lower down translator entries so that they don't go past the
    -- bottom of the tab
    self.frFR:SetPoint("TOPLEFT", self.deDE, "TOPLEFT", 300, 0)
  end
end

function AuctionatorConfigTabMixin:OpenOptions()
  if Settings and SettingsPanel then
    Settings.OpenToCategory(AUCTIONATOR_L_AUCTIONATOR)
  else
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY)
  end
end



function AuctionatorConfigTabMixin:StartAutoScan()
  -- ns.myTicker = C_Timer.NewTimer(3,GAUTicker)
  StartAUScan()
end 

function AuctionatorConfigTabMixin:StartAutoJianLou()
  GAUTickerJIANLOU_TSM()
end 



function AuctionatorConfigTabMixin:StartAutoSell()
  ns.HookAu.auDoItemSell()
end 



function AuctionatorConfigTabMixin:Reload()
  ReloadUI()
end 