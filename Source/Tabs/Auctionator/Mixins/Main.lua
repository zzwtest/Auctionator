
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
  ns.HookAu.jlAndSellState = 1 
  GAUTickerJIANLOU_TSM()
end 



function AuctionatorConfigTabMixin:StartAutoSell()
  ns.HookAu.auDoItemSell()
end 



function AuctionatorConfigTabMixin:Reload()
  ReloadUI()
end 


-- 1 捡漏 
-- 2 售卖 
function AuctionatorConfigTabMixin:StartJLAndSell()
 
  ns.HookAu.jlAndSellState = 1 
  local function _do_switch() 
    ns.HookAu.LogWarn("ns.HookAu.auNoneSlotIndex ",#ns.HookAu.auNoneSlotIndex , " ns.HookAu.auSellItems", #ns.HookAu.auSellItems)  
    local wait_sell_time = (#ns.HookAu.auSellItems - #ns.HookAu.auNoneSlotIndex) * 15
    if wait_sell_time <= 0 then wait_sell_time = 1 end 
    ns.HookAu.LogWarn("wait_sell_time ",wait_sell_time)
    if ns.HookAu.jlAndSellState == 2 then
      ns.HookAu.jlAndSellState = 1
      ns.HookAu.LogWarn("准备切换 开始捡漏 ， 停止售卖 ") 
      C_Timer.After(30,GAUTickerJIANLOU_TSM)  
      C_Timer.After(400,_do_switch)  
      
    elseif  ns.HookAu.jlAndSellState == 1 then
      ns.HookAu.jlAndSellState = 2
      ns.HookAu.LogWarn("准备切换 开始售卖 ， 停止捡漏 ") 
      C_Timer.After(10,ns.HookAu.auDoItemSell) 
      C_Timer.After(wait_sell_time,_do_switch)  
  
    end 
  end

  _do_switch() 
end 




